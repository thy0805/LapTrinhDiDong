import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nutrifit/modules/main/target/sleep/views/alarm_ring_screen.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';

import 'package:nutrifit/modules/main/target/workout/controllers/health_service.dart';
import 'package:nutrifit/core/services/gamification_service.dart';

class SleepController extends GetxController with WidgetsBindingObserver {
  final HealthService _healthService = Get.find<HealthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GamificationService _gamification = Get.find<GamificationService>();

  var sleepLogs = <Map<String, dynamic>>[].obs;
  var schedules = <Map<String, dynamic>>[].obs;

  var targetSleepHours = 8.0.obs;
  var isTracking = false.obs;
  var trackStartTime = Rx<DateTime?>(null);
  var trackingDuration = '00:00:00'.obs;
  Timer? _trackingTimer;
  StreamSubscription<AlarmSet>? _alarmSubscription;
  int _currentSnoozeCount = 0;

  var weeklySleepData = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  var weeklyLabels = <String>['', '', '', '', '', '', ''].obs;
  var sleepDebt = 0.0.obs;
  var lastNightSleep = 0.0.obs;
  var sleepTrend = 0.0.obs;
  var nextSleepCountdown = 'Chưa có lịch ngủ'.obs;
  Timer? _countdownTimer;

  String get uid => _auth.currentUser?.uid ?? '';
  String get userName => Get.find<AuthController>().userData['fullName'] ?? 'Người dùng';
  String get userPronoun => (Get.find<AuthController>().userData['gender'] == 'Male') ? 'ông' : 'bà';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchTargetSleep();
    fetchSleepLogs();
    fetchSchedules();
    _checkAndRequestAlarmPermissions();
    _listenToAlarmRing();
    _checkAndNavigateToRingingAlarm();
    _startCountdownTimer();
    _restoreTrackingState();
    Future.delayed(Duration(seconds: 5), () {
      syncWithHealthFit(showNotification: false);
    });
    Timer.periodic(Duration(minutes: 10), (timer) {
      if (_healthService.isAuthorized.value) {
        syncWithHealthFit(showNotification: false);
      }
    });
  }

  void _startCountdownTimer() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(
      Duration(minutes: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    if (schedules.isEmpty) {
      nextSleepCountdown.value = 'Chưa có lịch ngủ';
      return;
    }

    DateTime now = DateTime.now();
    DateTime? nearestBedtime;
    for (var s in schedules) {
      if (s['bedtime'] != null) {
        try {
          DateTime bedtime = DateTime.parse(s['bedtime']);
          DateTime scheduledForToday = DateTime(
            now.year,
            now.month,
            now.day,
            bedtime.hour,
            bedtime.minute,
          );
          if (scheduledForToday.isBefore(now)) {
            scheduledForToday = scheduledForToday.add(Duration(days: 1));
          }
          if (nearestBedtime == null ||
              scheduledForToday.isBefore(nearestBedtime)) {
            nearestBedtime = scheduledForToday;
          }
        } catch (e) {
          debugPrint('Error parsing bedtime: $e');
        }
      }
    }

    if (nearestBedtime != null) {
      Duration diff = nearestBedtime.difference(now);
      int hours = diff.inHours;
      int minutes = diff.inMinutes % 60;
      nextSleepCountdown.value = "Còn ${hours}h ${minutes}m nữa đến giờ ngủ";
    } else {
      nextSleepCountdown.value = 'Chưa có lịch ngủ';
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _alarmSubscription?.cancel();
    _trackingTimer?.cancel();
    _countdownTimer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndNavigateToRingingAlarm();
    }
  }

  Future<void> _checkAndNavigateToRingingAlarm() async {
    try {
      final alarms = await Alarm.getAlarms();
      for (var alarm in alarms) {
        final isRinging = await Alarm.isRinging(alarm.id);
        if (isRinging) {
          if (alarm.loopAudio == true) {
            Get.to(() => AlarmRingScreen(alarmSettings: alarm));
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking ringing alarm: $e');
    }
  }

  Future<void> _checkAndRequestAlarmPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      debugPrint('Error checking or requesting alarm permissions: $e');
    }
  }

  void _listenToAlarmRing() {
    _alarmSubscription = Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isNotEmpty) {
        final alarm = alarmSet.alarms.first;
        if (alarm.loopAudio == true) {
          Get.to(() => AlarmRingScreen(alarmSettings: alarm));
        }
      }
    });
  }

  void fetchTargetSleep() async {
    if (uid.isEmpty) return;
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('targetSleepHours')) {
          targetSleepHours.value = (data['targetSleepHours'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error fetching target sleep: $e');
    }
  }

  Future<void> updateTargetSleep(double newTarget) async {
    if (uid.isEmpty) return;
    try {
      await _firestore.collection('users').doc(uid).set({
        'targetSleepHours': newTarget,
      }, SetOptions(merge: true));
      targetSleepHours.value = newTarget;
      _calculateAnalytics();
      Get.snackbar(
        'Cập nhật thành công',
        'Đã đổi mục tiêu ngủ thành ${newTarget.toStringAsFixed(1)} giờ',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error updating target sleep: $e');
    }
  }

  void fetchSleepLogs() {
    if (uid.isEmpty) return;
    _firestore
        .collection('users')
        .doc(uid)
        .collection('sleepLogs')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isEmpty) {
            sleepLogs.value = [];
          } else {
            sleepLogs.value = snapshot.docs.map((doc) => doc.data()).toList();
          }
          _calculateAnalytics();
        });
  }

  void fetchSchedules() {
    if (uid.isEmpty) return;
    _firestore
        .collection('users')
        .doc(uid)
        .collection('schedules')
        .snapshots()
        .listen((snapshot) {
          schedules.value = snapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  void _calculateAnalytics() {
    List<double> weekData = [0, 0, 0, 0, 0, 0, 0];
    List<String> labels = ['', '', '', '', '', '', ''];
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    DateTime monday = today.subtract(Duration(days: today.weekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime date = monday.add(Duration(days: i));
      labels[i] = "${_getVietnameseDay(date.weekday)}\n${date.day}/${date.month}";
    }
    weeklyLabels.value = labels;

    if (sleepLogs.isEmpty) {
      weeklySleepData.value = weekData;
      sleepDebt.value = 0.0;
      lastNightSleep.value = 0.0;
      sleepTrend.value = 0.0;
      return;
    }

    if (sleepLogs.isNotEmpty) {
      var sortedLogs = sleepLogs.where((log) => log['date'] != null).toList();
      if (sortedLogs.isNotEmpty) {
        sortedLogs.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
        
        var firstLog = sortedLogs.first;
        DateTime firstLogDate = DateTime.parse(firstLog['date']);
        DateTime firstLogDay = DateTime(firstLogDate.year, firstLogDate.month, firstLogDate.day);
        int daysDiff = today.difference(firstLogDay).inDays;

        if (daysDiff == 0 || daysDiff == 1) {
          lastNightSleep.value = (firstLog['duration'] ?? 0.0).toDouble();

          DateTime nightBeforeDate = firstLogDay.subtract(const Duration(days: 1));
          String nightBeforeStr = "${nightBeforeDate.year}-${nightBeforeDate.month.toString().padLeft(2, '0')}-${nightBeforeDate.day.toString().padLeft(2, '0')}";
          var nightBeforeLog = sortedLogs.firstWhereOrNull((log) => log['date'] == nightBeforeStr);

          if (nightBeforeLog != null) {
            double yesterdaySleep = (nightBeforeLog['duration'] ?? 0.0).toDouble();
            if (yesterdaySleep > 0) {
              sleepTrend.value =
                  ((lastNightSleep.value - yesterdaySleep) / yesterdaySleep) * 100;
            } else {
              sleepTrend.value = 0.0;
            }
          } else {
            sleepTrend.value = 0.0;
          }
        } else {
          lastNightSleep.value = 0.0;
          sleepTrend.value = 0.0;
        }
      }
    }

    for (var log in sleepLogs) {
      try {
        DateTime logDate = DateTime.parse(log['date']);
        DateTime logDay = DateTime(logDate.year, logDate.month, logDate.day);

        int diffFromMonday = logDay.difference(monday).inDays;
        if (diffFromMonday >= 0 && diffFromMonday < 7) {
          weekData[diffFromMonday] += (log['duration'] ?? 0.0).toDouble();
        }
      } catch (e) {
        debugPrint('Error calculating analytics for log: $e');
      }
    }

    double expectedHours = today.weekday * targetSleepHours.value;
    double sleptHours = 0.0;
    for (int i = 0; i < today.weekday; i++) {
      sleptHours += weekData[i];
    }
    double debt = expectedHours - sleptHours;

    weeklySleepData.value = weekData;
    weeklyLabels.value = labels;
    sleepDebt.value = debt > 0 ? debt : 0.0;
  }

  String _getVietnameseDay(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  Future<void> saveManualLog(DateTime start, DateTime end, String mood) async {
    if (uid.isEmpty) return;
    final duration = end.difference(start).inMinutes / 60.0;
    final dateStr =
        "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleepLogs')
        .doc(dateStr)
        .set({
          'startTime': start.toIso8601String(),
          'endTime': end.toIso8601String(),
          'duration': duration,
          'mood': mood,
          'date': dateStr,
        });

    _gamification.awardSleepExp(
      duration, 
      targetSleepHours.value, 
      mood.isNotEmpty && mood != 'Từ Health Connect',
      _currentSnoozeCount <= 1
    );
    
    _gamification.checkTimeBasedAchievements('wakeup');
    
    _currentSnoozeCount = 0;
  }

  Future<void> addOrUpdateSchedule({
    String? id,
    required String title,
    DateTime? bedtime,
    required DateTime alarmTime,
    required List<bool> repeatDays,
    required int snoozeDuration,
    required bool isVibrate,
    required String type,
    required String soundPath,
  }) async {
    if (uid.isEmpty) return;

    Map<String, dynamic> data = {
      'title': title,
      'alarmTime': alarmTime.toIso8601String(),
      'repeatDays': repeatDays,
      'snoozeDuration': snoozeDuration,
      'isVibrate': isVibrate,
      'isActive': true,
      'type': type,
      'soundPath': soundPath,
    };

    if (bedtime != null) {
      data['bedtime'] = bedtime.toIso8601String();
    }

    int alarmId;

    if (id == null) {
      var docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .add(data);
      alarmId = docRef.id.hashCode.abs() % 2147483647;
      await docRef.update({'alarmId': alarmId});
    } else {
      alarmId = id.hashCode.abs() % 2147483647;
      data['alarmId'] = alarmId;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .doc(id)
          .update(data);
    }

    await setSmartAlarm(
      alarmId,
      alarmTime,
      title,
      isVibrate,
      snoozeDuration,
      soundPath,
    );
    if (bedtime != null) {
      await setBedtimeReminder(alarmId + 1, bedtime);
    }
  }

  Future<void> deleteSchedule(String id) async {
    if (uid.isEmpty) return;
    try {
      var doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .doc(id)
          .get();
      if (doc.exists) {
        int alarmId = doc.data()?['alarmId'] ?? id.hashCode.abs() % 2147483647;
        await Alarm.stop(alarmId);
        await Alarm.stop(alarmId + 1);
      }
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
    }
  }

  Future<void> setSmartAlarm(
    int alarmId,
    DateTime dateTime,
    String title,
    bool isVibrate,
    int snoozeDuration,
    String soundPath,
  ) async {
    final now = DateTime.now();
    dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      dateTime.hour,
      dateTime.minute,
      0, 0,
    );

    if (dateTime.isBefore(now)) {
      dateTime = dateTime.add(Duration(days: 1));
    }

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: dateTime,
      assetAudioPath: soundPath,
      loopAudio: true,
      vibrate: isVibrate,
      androidFullScreenIntent: true,
      warningNotificationOnKill: false,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: 'Vuốt để tắt hoặc nhắc lại sau $snoozeDuration phút',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> setBedtimeReminder(int reminderId, DateTime bedtime) async {
    final now = DateTime.now();
    DateTime reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime.hour,
      bedtime.minute,
    ).subtract(Duration(minutes: 15));

    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(Duration(days: 1));
    }

    final reminderSettings = AlarmSettings(
      id: reminderId,
      dateTime: reminderTime,
      assetAudioPath: 'assets/audio/silent.mp3',
      loopAudio: false,
      vibrate: false,
      warningNotificationOnKill: false,
      volumeSettings: VolumeSettings.fade(
        volume: 0.0,
        fadeDuration: Duration(seconds: 1),
      ),
      notificationSettings: NotificationSettings(
        title: 'Bedtime Reminder',
        body:
            'Còn 15 phút nữa là đến giờ ngủ. $userPronoun nên chuẩn bị lên giường nhé!',
      ),
    );
    await Alarm.set(alarmSettings: reminderSettings);
  }

  Future<void> snoozeAlarm(AlarmSettings settings) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('schedules')
          .where('title', isEqualTo: settings.notificationSettings.title)
          .limit(1)
          .get();
      int snoozeMins = 5;
      if (docSnapshot.docs.isNotEmpty) {
        snoozeMins = docSnapshot.docs.first.data()['snoozeDuration'] ?? 5;
      }

      final newSettings = settings.copyWith(
        dateTime: DateTime.now().add(Duration(minutes: snoozeMins)),
      );
      _currentSnoozeCount++;
      await Alarm.stop(settings.id);
      await Alarm.set(alarmSettings: newSettings);
    } catch (e) {
      final newSettings = settings.copyWith(
        dateTime: DateTime.now().add(Duration(minutes: 5)),
      );
      _currentSnoozeCount++;
      await Alarm.stop(settings.id);
      await Alarm.set(alarmSettings: newSettings);
    }
  }

  Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
  }

  void _restoreTrackingState() {
    try {
      final box = Hive.box('security_settings');
      final isTr = box.get('sleep_is_tracking', defaultValue: false) as bool;
      if (isTr) {
        final startStr = box.get('sleep_track_start_time') as String?;
        if (startStr != null) {
          final startTime = DateTime.tryParse(startStr);
          if (startTime != null) {
            isTracking.value = true;
            trackStartTime.value = startTime;
            _trackingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              final duration = DateTime.now().difference(trackStartTime.value!);
              String hours = duration.inHours.toString().padLeft(2, '0');
              String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
              String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
              trackingDuration.value = "$hours:$minutes:$seconds";
            });
          }
        }
      }
    } catch (_) {}
  }

  void startTracking() {
    isTracking.value = true;
    trackStartTime.value = DateTime.now();
    try {
      final box = Hive.box('security_settings');
      box.put('sleep_is_tracking', true);
      box.put('sleep_track_start_time', trackStartTime.value!.toIso8601String());
    } catch (_) {}
    _trackingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final duration = DateTime.now().difference(trackStartTime.value!);
      String hours = duration.inHours.toString().padLeft(2, '0');
      String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      trackingDuration.value = "$hours:$minutes:$seconds";
    });
  }

  Future<void> stopTracking(String mood) async {
    if (!isTracking.value || trackStartTime.value == null) return;
    _trackingTimer?.cancel();
    try {
      final box = Hive.box('security_settings');
      box.put('sleep_is_tracking', false);
      box.delete('sleep_track_start_time');
    } catch (_) {}
    await saveManualLog(trackStartTime.value!, DateTime.now(), mood);
    isTracking.value = false;
    trackStartTime.value = null;
    trackingDuration.value = '00:00:00';
    Get.snackbar(
      'Hoàn tất',
      'Đã ghi nhận giấc ngủ! Cảm giác: $mood',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
    );
  }

  Future<void> syncWithHealthFit({bool showNotification = true, bool? forceRequestPermissions}) async {
    final bool force = forceRequestPermissions ?? showNotification;
    try {
      if (showNotification) {
        Get.snackbar(
          'Đang đồng bộ',
          'Đang kết nối với Health Connect...',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }

      if (force && !_healthService.isAuthorized.value) {
        bool ok = await _healthService.requestPermissions();
        if (!ok) return;
      }

      if (!_healthService.isAuthorized.value) return;

      var types = [HealthDataType.SLEEP_SESSION];

      if (_healthService.isAuthorized.value) {
        DateTime now = DateTime.now();
        DateTime yesterday = now.subtract(Duration(days: 7));
        List<HealthDataPoint> healthData = await _healthService.health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: types,
        );

        if (healthData.isNotEmpty) {
          Map<String, double> dailyDuration = {};
          for (var point in healthData) {
            double hours =
                point.dateTo.difference(point.dateFrom).inMinutes / 60.0;
            if (hours > 0) {
              final end = point.dateTo;
              final dateStr = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";
              dailyDuration[dateStr] = (dailyDuration[dateStr] ?? 0) + hours;
            }
          }

          int count = 0;
          for (var entry in dailyDuration.entries) {
            double existingDuration = 0.0;
            var existingLog = sleepLogs.firstWhereOrNull((log) => log['date'] == entry.key);
            if (existingLog != null && existingLog['duration'] != null) {
              existingDuration = (existingLog['duration'] as num).toDouble();
            }

            if (entry.value > existingDuration) {
              await _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('sleepLogs')
                  .doc(entry.key)
                  .set({
                    'duration': entry.value,
                    'date': entry.key,
                    'mood': 'Từ Health Connect',
                  }, SetOptions(merge: true));
              _gamification.awardSleepExp(
                entry.value,
                targetSleepHours.value,
                false,
                true,
              );
              count++;
            }
          }

          if (count > 0 && showNotification) {
            Get.snackbar(
              'Thành công',
              'Đã đồng bộ $count bản ghi giấc ngủ từ thiết bị!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              icon: Icon(Icons.check_circle, color: Colors.white),
            );
          } else if (showNotification) {
            Get.snackbar(
              'Thông báo',
              'Không tìm thấy bản ghi giấc ngủ mới hoặc dữ liệu đã được cập nhật.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } else if (showNotification) {
          Get.snackbar(
            'Thông báo',
            'Chưa có dữ liệu giấc ngủ mới trên thiết bị.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } else if (showNotification) {
        Get.snackbar(
          'Từ chối quyền',
          'Vui lòng cấp quyền Health Connect để đồng bộ.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (showNotification) {
        Get.snackbar(
          'Lỗi đồng bộ',
          'Không thể lấy dữ liệu: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
