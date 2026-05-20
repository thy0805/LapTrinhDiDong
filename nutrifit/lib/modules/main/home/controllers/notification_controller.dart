import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/core/services/mail_service.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';

class AppNotification {
  final String id;
  final String title;
  final String timeLabel;
  final DateTime timestamp;
  final IconData icon;
  final List<Color> colors;

  AppNotification({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.timestamp,
    required this.icon,
    required this.colors,
  });
}

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;
  final RxSet<String> notifiedSchedules = <String>{}.obs;
  Timer? _hourlyTimer;
  Timer? _minuteTimer;

  @override
  void onInit() {
    super.onInit();
    _generateInitialNotifications();
    _startHourlyTimer();
    _startMinuteTimer();
    _initBackgroundExecution();
    _listenToAdminNotifications();
  }

  @override
  void onClose() {
    _hourlyTimer?.cancel();
    _minuteTimer?.cancel();
    super.onClose();
  }

  Future<void> _initBackgroundExecution() async {
    try {
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "NutriFit đang chạy ngầm",
        notificationText: "Ứng dụng đang chạy ngầm để nhắc nhở sức khỏe",
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
      );
      bool hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
      if (hasPermissions) {
        await FlutterBackground.enableBackgroundExecution();
      }
    } catch (_) {}
  }

  void _generateInitialNotifications() {
    _cleanOldNotifications();
  }

  void _startHourlyTimer() {
    _hourlyTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _addSmartReminder();
      _cleanOldNotifications();
    });
  }

  void _startMinuteTimer() {
    _minuteTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _checkDynamicReminders();
    });
  }

  Future<void> _sendSystemNotification(String title, String body) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.hashCode.abs() % 1000000 + 20000;
      final settings = AlarmSettings(
        id: notificationId,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: 'assets/audio/silent.mp3',
        loopAudio: false,
        vibrate: false,
        warningNotificationOnKill: false,
        volumeSettings: VolumeSettings.fade(
          volume: 0.0,
          fadeDuration: const Duration(seconds: 1),
        ),
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
        ),
      );
      await Alarm.set(alarmSettings: settings);
    } catch (_) {}
  }

  Future<void> sendDualNotification(String title, String body, IconData icon, List<Color> colors) async {
    addNotification(title, icon, colors);
    await _sendSystemNotification(title, body);
  }

  Future<void> sendRingingAlarm(String title, String body, IconData icon, List<Color> colors) async {
    addNotification(title, icon, colors);
    try {
      final alarmId = DateTime.now().millisecondsSinceEpoch.hashCode.abs() % 1000000 + 40000;
      final settings = AlarmSettings(
        id: alarmId,
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: 'assets/audio/silent.mp3',
        loopAudio: false,
        vibrate: false,
        androidFullScreenIntent: false,
        warningNotificationOnKill: false,
        volumeSettings: VolumeSettings.fade(
          volume: 0.0,
          fadeDuration: const Duration(seconds: 1),
        ),
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
        ),
      );
      await Alarm.set(alarmSettings: settings);
    } catch (_) {}
  }

  void _checkDynamicReminders() async {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final auth = Get.find<AuthController>();
    final userName = auth.userName;
    final userPronoun = auth.userPronoun;

    if (hour >= 0 && hour < 4) {
      final lateNightKey = 'latenight_$todayStr';
      if (!notifiedSchedules.contains(lateNightKey)) {
        notifiedSchedules.add(lateNightKey);
        await sendDualNotification(
          'Trễ rồi ngủ đi $userName ơi! 🥱',
          'Đã quá nửa đêm rồi mà $userPronoun vẫn còn hoạt động trên app nè. Đi ngủ sớm để giữ gìn sức khỏe nhen!',
          Icons.bedtime,
          [const Color(0xFFCC8FED), const Color(0xFF6B50F6)],
        );
      }
    }

    final waterHours = [9, 11, 14, 16, 18, 20];
    if (waterHours.contains(hour) && minute == 0) {
      final waterKey = 'water_${hour}_$todayStr';
      if (!notifiedSchedules.contains(waterKey)) {
        notifiedSchedules.add(waterKey);
        await sendDualNotification(
          '$userName ơi, uống nước thôi! 💧',
          'Đến giờ nạp nước rồi nè. Làm một ly nước mát lạnh để thanh lọc cơ thể đi $userPronoun!',
          Icons.local_drink,
          [const Color(0xFF00FF66), const Color(0xFF00EFFF)],
        );
      }
    }

    if (hour == 8 && minute == 30) {
      final morningCheckKey = 'checkin_morning_$todayStr';
      if (!notifiedSchedules.contains(morningCheckKey)) {
        notifiedSchedules.add(morningCheckKey);
        await sendDualNotification(
          'Chào buổi sáng $userName! ☀️',
          'Hôm nay $userPronoun thế nào? Bắt đầu ngày mới đầy năng lượng và đừng quên ăn sáng nhé!',
          Icons.wb_sunny,
          [const Color(0xFFFF9900), const Color(0xFFFFCC00)],
        );
      }
    }

    if (hour == 20 && minute == 30) {
      final eveningCheckKey = 'checkin_evening_$todayStr';
      if (!notifiedSchedules.contains(eveningCheckKey)) {
        notifiedSchedules.add(eveningCheckKey);
        await sendDualNotification(
          '$userName ơi, hôm nay $userPronoun thế nào? 🥰',
          'Một ngày dài trôi qua rồi. Thư giãn đầu óc và chuẩn bị nghỉ ngơi đi $userPronoun nha!',
          Icons.sentiment_very_satisfied,
          [const Color(0xFFFF4B2B), const Color(0xFFFF416C)],
        );
      }
    }

    if (Get.isRegistered<SleepController>()) {
      final sleepCtrl = Get.find<SleepController>();
      for (var s in sleepCtrl.schedules) {
        if (s['bedtime'] != null && s['isActive'] == true) {
          try {
            final bedtime = DateTime.parse(s['bedtime']);
            final targetTime = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
            final diff = targetTime.difference(now).inMinutes;
            if (diff > 0 && diff <= 60) {
              final sleepKey = 'sleep_bedtime_${s['id']}_$todayStr';
              if (!notifiedSchedules.contains(sleepKey)) {
                notifiedSchedules.add(sleepKey);
                await sendDualNotification(
                  'Sắp đến giờ ngủ rồi $userName ơi! 🌙',
                  'Còn 1 tiếng nữa là đến giờ đi ngủ theo lịch của $userPronoun rồi. Chuẩn bị ngủ thôi nhen!',
                  Icons.bedtime,
                  [const Color(0xFFCC8FED), const Color(0xFF6B50F6)],
                );
              }
            }
          } catch (_) {}
        }
      }
    }

    if (Get.isRegistered<WorkoutController>()) {
      final workoutCtrl = Get.find<WorkoutController>();
      for (var s in workoutCtrl.todaySchedules) {
        if (s['time'] != null && s['isCompleted'] != true) {
          try {
            final timeStr = s['time'] as String;
            final parts = timeStr.split(':');
            final h = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final targetTime = DateTime(now.year, now.month, now.day, h, m);
            final diff = targetTime.difference(now).inMinutes;
            if (diff > 0 && diff <= 60) {
              final workoutKey = 'workout_${s['id']}_$todayStr';
              if (!notifiedSchedules.contains(workoutKey)) {
                notifiedSchedules.add(workoutKey);
                await sendDualNotification(
                  'Chuẩn bị tập luyện thôi $userName ơi! 💪',
                  'Còn 1 tiếng nữa là đến giờ tập bài ${s['exerciseName']} rồi đó. Lên dây cót tinh thần nhen!',
                  Icons.fitness_center,
                  [const Color(0xFF6B50F6), const Color(0xFF00EFFF)],
                );
              }
            } else if (diff == 0) {
              final workoutAlarmKey = 'workout_alarm_${s['id']}_$todayStr';
              if (!notifiedSchedules.contains(workoutAlarmKey)) {
                notifiedSchedules.add(workoutAlarmKey);
                await sendRingingAlarm(
                  'Đến giờ tập luyện rồi $userName ơi! 💪',
                  'Đã đến giờ tập bài ${s['exerciseName']} rồi đó $userPronoun. Lên đồ tập thôi nhen!',
                  Icons.fitness_center,
                  [const Color(0xFF6B50F6), const Color(0xFF00EFFF)],
                );
              }
            }
          } catch (_) {}
        }
      }
    }

    if (Get.isRegistered<NutritionController>()) {
      final nutritionCtrl = Get.find<NutritionController>();
      for (var m in nutritionCtrl.todayMeals) {
        if (m['time'] != null && m['id'] != null) {
          try {
            final timeStr = m['time'] as String;
            final parts = timeStr.split(':');
            final h = int.parse(parts[0]);
            final mMin = int.parse(parts[1]);
            final targetTime = DateTime(now.year, now.month, now.day, h, mMin);
            final diff = targetTime.difference(now).inMinutes;
            if (diff > 0 && diff <= 60) {
              final mealKey = 'meal_${m['id']}_$todayStr';
              if (!notifiedSchedules.contains(mealKey)) {
                notifiedSchedules.add(mealKey);
                await sendDualNotification(
                  'Sắp đến giờ ăn rồi $userName ơi! 🥗',
                  'Còn 1 tiếng nữa là đến giờ ăn ${m['name']} (${m['type']}) rồi nè. Chuẩn bị nạp năng lượng thôi!',
                  Icons.restaurant,
                  [const Color(0xFFFF4B2B), const Color(0xFFFF416C)],
                );
              }
            } else if (diff == 0) {
              final mealAlarmKey = 'meal_alarm_${m['id']}_$todayStr';
              if (!notifiedSchedules.contains(mealAlarmKey)) {
                notifiedSchedules.add(mealAlarmKey);
                await sendRingingAlarm(
                  'Đến giờ ăn rồi $userName ơi! 🥗',
                  'Đã đến giờ ăn ${m['name']} (${m['type']}) rồi nè $userPronoun. Nạp năng lượng thôi!',
                  Icons.restaurant,
                  [const Color(0xFFFF4B2B), const Color(0xFFFF416C)],
                );
              }
            }
          } catch (_) {}
        }
      }
    }
  }

  void _addSmartReminder() {
    final now = DateTime.now();
    final hour = now.hour;
    final activityController = Get.find<ActivityController>();
    final sleepController = Get.find<SleepController>();
    final user = FirebaseAuth.instance.currentUser;

    String? title;
    IconData icon = Icons.notifications_active;
    List<Color> colors = [const Color(0xFFCC8FED), const Color(0xFF6B50F6)];

    bool sentSleepReminder = false;
    for (var s in sleepController.schedules) {
      if (s['bedtime'] != null) {
        try {
          DateTime bedtime = DateTime.parse(s['bedtime']);
          DateTime scheduledForToday = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
          if (scheduledForToday.isBefore(now)) scheduledForToday = scheduledForToday.add(const Duration(days: 1));
          
          Duration diff = scheduledForToday.difference(now);
          if (diff.inHours <= 2 && diff.inMinutes > 60) {
            title = 'Chỉ còn gần 2 tiếng nữa là đến giờ ngủ! Hãy thư giãn nhé 🌙';
            icon = Icons.bedtime;
            sentSleepReminder = true;
            if (user != null && user.email != null) {
              final auth = Get.find<AuthController>();
              final userName = user.displayName ?? (auth.userData['fullName'] ?? 'Người dùng');
              MailService.sendReminderEmail(user.email!, userName, 'đi ngủ');
            }
            break;
          }
        } catch (_) {}
      }
    }

    if (!sentSleepReminder) {
      if (hour >= 18) {
        if (activityController.steps.value < activityController.stepTarget.value) {
          title = '${Get.find<AuthController>().userName} còn một chút nữa là đạt mục tiêu bước chân rồi, cố lên! 🔥';
          icon = Icons.directions_walk;
        }
      } else if (hour >= 11 && hour <= 13) {
        title = 'Đừng quên ghi lại bữa trưa của mình nhé! 🍽️';
        icon = Icons.restaurant;
      }
    }

    if (title != null) {
      addNotification(title, icon, colors);
    }
  }

  void _cleanOldNotifications() {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    notifications.removeWhere((n) => n.timestamp.isBefore(oneDayAgo));
  }

  void addNotification(String title, IconData icon, List<Color> colors) {
    if (notifications.isNotEmpty && notifications.first.title == title) return;

    notifications.insert(0, AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      timeLabel: 'Vừa xong',
      timestamp: DateTime.now(),
      icon: icon,
      colors: colors,
    ));
    _cleanOldNotifications();
  }

  void removeNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  void clearAll() {
    notifications.clear();
  }

  void _listenToAdminNotifications() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('notifications').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final title = data['title']?.toString() ?? '';
          final body = data['body']?.toString() ?? '';
          final ts = data['createdAt'];
          DateTime timestamp;
          if (ts is Timestamp) {
            timestamp = ts.toDate();
          } else if (ts is String) {
            timestamp = DateTime.tryParse(ts) ?? DateTime.now();
          } else {
            timestamp = DateTime.now();
          }
          final id = doc.id;

          final exists = notifications.any((n) => n.id == id);
          if (!exists) {
            notifications.add(AppNotification(
              id: id,
              title: '$title: $body',
              timeLabel: _formatTimeLabel(timestamp),
              timestamp: timestamp,
              icon: Icons.notifications_active_outlined,
              colors: const [Color(0xFF465FFF), Color(0xFF00FF66)],
            ));
          } else {
            final idx = notifications.indexWhere((n) => n.id == id);
            if (idx != -1) {
              notifications[idx] = AppNotification(
                id: id,
                title: '$title: $body',
                timeLabel: _formatTimeLabel(timestamp),
                timestamp: timestamp,
                icon: Icons.notifications_active_outlined,
                colors: const [Color(0xFF465FFF), Color(0xFF00FF66)],
              );
            }
          }
        } catch (e) {
          Get.log("Error: $e");
        }
      }
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }, onError: (e) {
      Get.log("Error: $e");
    });
  }

  String _formatTimeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
  }
}
