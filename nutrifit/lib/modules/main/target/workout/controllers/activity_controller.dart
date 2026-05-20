import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import 'package:nutrifit/modules/main/target/workout/controllers/health_service.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/core/services/gamification_service.dart';
import 'package:nutrifit/core/services/sync_service.dart';
import 'workout_controller.dart';

class ActivityController extends GetxController {
  final HealthService _healthService = Get.find<HealthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GamificationService _gamification = Get.find<GamificationService>();

  var steps = 0.obs;
  var water = 0.0.obs;
  var distance = 0.0.obs;
  var calories = 0.0.obs;
  var activeCalories = 0.0.obs;
  var bmrCalories = 0.0.obs;
  var workoutCalories = 0.0.obs;
  var heartRate = 0.obs;
  var moveMinutes = 0.obs;

  var stepTarget = 8000.obs;
  var waterTarget = 2.0.obs;
  var calorieTarget = 2500.obs;

  var completionScore = 0.0.obs;
  var weeklyScores = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  var streakCount = 0.obs;
  var smartSuggestion = 'Khởi đầu ngày mới với 1 ly nước nhé!'.obs;
  var activityHistory = <Map<String, dynamic>>[].obs;
  var isLoadingHistory = false.obs;
  var isSyncing = false.obs;

  Timer? _syncTimer;
  Timer? _suggestionTimer;

  String get uid => _auth.currentUser?.uid ?? '';
  String get userName => Get.find<AuthController>().userData['fullName'] ?? 'Người dùng';
  String get userPronoun => (Get.find<AuthController>().userData['gender'] == 'Male') ? 'ông' : 'bà';

  @override
  void onInit() {
    super.onInit();
    fetchTargets().then((_) {
      _fetchWeeklyActivities();
      _fetchStreak();
      _fetchDailyActivityFromFirebase().then((_) {
        syncWithGoogleFit();
        _calculateCompletionScore();
      });
    });
    
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      syncWithGoogleFit();
      _calculateCompletionScore();
    });

    _updateSmartSuggestion();
    _suggestionTimer = Timer.periodic(Duration(minutes: 30), (timer) {
      _updateSmartSuggestion();
    });

    ever(activeCalories, (_) => updateMoveMinutes());

    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isRegistered<WorkoutController>()) {
        final workoutCtrl = Get.find<WorkoutController>();
        ever(workoutCtrl.todaySchedules, (_) => updateMoveMinutes());
        updateMoveMinutes();
      }
    });
  }

  void _updateSmartSuggestion() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 9) {
      smartSuggestion.value = 'Khởi đầu ngày mới với 1 ly nước nhé! 💧';
    } else if (hour < 12) {
      if (steps.value < (stepTarget.value * 0.3)) {
        smartSuggestion.value = 'Còn thiếu hơi nhiều bước chân, đi bộ một chút không? 🚶‍♂️';
      } else {
        smartSuggestion.value = 'Làm việc năng suất nhé! Đừng quên uống nước. 🥤';
      }
    } else if (hour < 15) {
      smartSuggestion.value = 'Giờ nghỉ trưa rồi, bổ sung năng lượng thôi! 🥗';
    } else if (hour < 18) {
      if (steps.value < (stepTarget.value * 0.7)) {
        smartSuggestion.value = 'Chiều rồi, tranh thủ hoàn thành mục tiêu bước chân nào! 🔥';
      } else {
        smartSuggestion.value = '$userPronoun đang làm rất tốt, tiếp tục phát huy nhé! ✨';
      }
    } else {
      smartSuggestion.value = 'Sắp đến giờ đi ngủ rồi, thư giãn đầu óc thôi. 🌙';
    }
  }

  void _calculateCompletionScore() {
    try {
      double stepRatio = min(1.0, steps.value / (stepTarget.value > 0 ? stepTarget.value : 8000));
      double waterRatio = min(1.0, water.value / (waterTarget.value > 0 ? waterTarget.value : 2.0));
      double burnRatio = min(1.0, calories.value / (calorieTarget.value > 0 ? calorieTarget.value : 2500));

      completionScore.value = ((stepRatio + waterRatio + burnRatio) / 3.0) * 10;
      
      if (completionScore.value >= 10) {
        _gamification.unlockAchievement(
          'perfect_day', 
          'Perfect Day', 
          'Đạt điểm tuyệt đối 10/10 cho tất cả hoạt động trong ngày! 🌈', 
          100
        );
      }
      
      final dayOfWeek = DateTime.now().weekday;
      int indexInChart = (dayOfWeek % 7);
      weeklyScores[indexInChart] = completionScore.value;
      weeklyScores.refresh();
      
      if (completionScore.value >= 8) {
        _updateStreak();
      }

      _gamification.checkCalorieBurnMilestones(calories.value);
      _gamification.checkOverachiever(calories.value, calorieTarget.value.toDouble());

      _gamification.checkWaterMilestones(water.value, waterTarget.value);
      _gamification.checkStepMilestones(steps.value, stepTarget.value.toInt());
      
      _gamification.checkTimeBasedAchievements('steps', value: steps.value.toDouble());
      _gamification.checkTimeBasedAchievements('late_activity');

      _gamification.checkPerfectDay(completionScore.value);
      
      _gamification.updateUserStats('totalSteps', steps.value);
      _gamification.updateUserStats('totalWater', water.value);
      
      // Check complex streak-based achievements
      if (activityHistory.isNotEmpty) {
        _gamification.checkComplexAchievements(
          activityHistory, 
          calorieTarget.value.toDouble(), 
          stepTarget.value, 
          waterTarget.value
        );
      }
      
      final authCtrl = Get.find<AuthController>();
      double totalSteps = (authCtrl.userData['totalSteps'] ?? 0).toDouble();
      _gamification.checkLifetimeAchievements(totalSteps: totalSteps);

      // Ultimate achievement check
      int uniqueCount = (authCtrl.userData['completed_exercise_ids'] as List?)?.length ?? 0;
      _gamification.checkUltimateAchievement(uniqueCount, streakCount.value);
    } catch (e) {
      debugPrint('Error calculating completion score: $e');
    }
  }

  Future<void> fetchTargets() async {
    if (uid.isEmpty) return;
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('stepTarget')) {
          stepTarget.value = (data['stepTarget'] as num).toInt();
        }
        if (data.containsKey('waterTarget')) {
          waterTarget.value = (data['waterTarget'] as num).toDouble();
        }
        if (data.containsKey('calorieTarget')) {
          calorieTarget.value = (data['calorieTarget'] as num).toInt();
        }
      }
    } catch (e) {
      debugPrint('Error fetching targets: $e');
    }
  }

  Future<void> updateTargets({int? newStepTarget, double? newWaterTarget, int? newCalorieTarget}) async {
    if (uid.isEmpty) return;
    try {
      Map<String, dynamic> data = {};
      if (newStepTarget != null) {
        data['stepTarget'] = newStepTarget;
        stepTarget.value = newStepTarget;
      }
      if (newWaterTarget != null) {
        data['waterTarget'] = newWaterTarget;
        waterTarget.value = newWaterTarget;
      }
      if (newCalorieTarget != null) {
        data['calorieTarget'] = newCalorieTarget;
        calorieTarget.value = newCalorieTarget;
      }

      if (data.isNotEmpty) {
        await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
        _calculateCompletionScore();
      }
    } catch (e) {
      debugPrint('Error updating targets: $e');
    }
  }

  Future<void> _fetchDailyActivityFromFirebase() async {
    if (uid.isEmpty) return;
    DateTime now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyActivities')
          .doc(dateStr)
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        steps.value = (data['steps'] as num?)?.toInt() ?? 0;
        water.value = (data['water'] as num?)?.toDouble() ?? 0.0;
        distance.value = (data['distance'] as num?)?.toDouble() ?? 0.0;
        workoutCalories.value = (data['workoutCalories'] as num?)?.toDouble() ?? 0.0;
        activeCalories.value = (data['activeCalories'] as num?)?.toDouble() ?? 0.0;
        bmrCalories.value = (data['bmrCalories'] as num?)?.toDouble() ?? 0.0;
        calories.value = (data['calories'] as num?)?.toDouble() ?? 0.0;
        moveMinutes.value = (data['moveMinutes'] as num?)?.toInt() ?? 0;
        heartRate.value = (data['heartRate'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      debugPrint("Lỗi khi kéo data từ Firebase: $e");
    }
  }

  Future<void> _fetchWeeklyActivities() async {
    if (uid.isEmpty) return;
    DateTime now = DateTime.now();
    List<double> newWeeklyScores = [0, 0, 0, 0, 0, 0, 0];
    List<String> dateStrings = [];
    
    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: i));
      dateStrings.add("${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
    }
    
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyActivities')
          .where(FieldPath.documentId, whereIn: dateStrings)
          .get();
          
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String dateStr = doc.id;
        DateTime date = DateTime.parse(dateStr);
        
        int dSteps = (data['steps'] as num?)?.toInt() ?? 0;
        double dWater = (data['water'] as num?)?.toDouble() ?? 0.0;
        double dCalories = (data['calories'] as num?)?.toDouble() ?? 0.0;
        
        double sTarget = stepTarget.value > 0 ? stepTarget.value.toDouble() : 8000;
        double wTarget = waterTarget.value > 0 ? waterTarget.value : 2.0;
        double cTarget = calorieTarget.value > 0 ? calorieTarget.value.toDouble() : 2500;
        
        double stepRatio = min(1.0, dSteps / sTarget);
        double waterRatio = min(1.0, dWater / wTarget);
        double burnRatio = min(1.0, dCalories / cTarget);
        
        double score = ((stepRatio + waterRatio + burnRatio) / 3.0) * 10;
        int indexInChart = (date.weekday % 7);
        newWeeklyScores[indexInChart] = score;
      }
      if (newWeeklyScores.length == 7) {
        weeklyScores.value = newWeeklyScores;
      }
    } catch (e) {
      debugPrint("Lỗi kéo data tuần: $e");
    }
  }

  Future<void> fetchHistory() async {
    if (uid.isEmpty) return;
    isLoadingHistory.value = true;
    try {
      var snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyActivities')
          .orderBy('lastSync', descending: true)
          .limit(14)
          .get();

      activityHistory.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Lỗi fetchHistory: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _suggestionTimer?.cancel();
    super.onClose();
  }

  Future<void> manualSync() async {
    if (isSyncing.value) return;
    Get.snackbar('Đang đồng bộ', 'App đang kéo dữ liệu từ Health Connect nhen...', 
      snackPosition: SnackPosition.TOP, backgroundColor: Colors.blue.withValues(alpha: 0.1));
    await syncWithGoogleFit(forceRequestPermissions: true);
    if (steps.value > 0) {
      Get.snackbar('Thành công', 'Đã đồng bộ ${steps.value} bước chân!', 
        backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    } else {
      Get.snackbar('Thông báo', 'Không tìm thấy dữ liệu mới từ Health Connect. $userPronoun kiểm tra lại app Fit nhen!', 
        backgroundColor: Colors.orange.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  Future<void> syncWithGoogleFit({bool forceRequestPermissions = false}) async {
    if (isSyncing.value) return;
    isSyncing.value = true;
    
    try {
      debugPrint("--- ActivityController: Bắt đầu đồng bộ... ---");
      if (forceRequestPermissions && !_healthService.isAuthorized.value) {
        bool ok = await _healthService.requestPermissions();
        if (!ok) {
          isSyncing.value = false;
          return;
        }
      }

      if (!_healthService.isAuthorized.value) {
        isSyncing.value = false;
        return;
      }

      var types = [
        HealthDataType.STEPS,
        HealthDataType.WATER,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.BASAL_ENERGY_BURNED,
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.HEART_RATE,
      ];

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      int? dailySteps = await _healthService.health.getTotalStepsInInterval(startOfDay, now);
      int totalSteps = dailySteps ?? 0;

      List<HealthDataPoint> healthData = [];
      for (var type in types) {
        try {
          var data = await _healthService.health.getHealthDataFromTypes(
            startTime: startOfDay,
            endTime: now,
            types: [type],
          );
          healthData.addAll(data);
        } catch (e) {
          debugPrint('Error fetching data for type $type: $e');
        }
      }

      double totalWater = 0.0;
      double totalDistance = 0.0;
      double totalActive = 0.0;
      double totalBasal = 0.0;
      double totalTotal = 0.0;
      List<int> heartRates = [];

      for (var point in healthData) {
        try {
          if (point.value is NumericHealthValue) {
            num value = (point.value as NumericHealthValue).numericValue;
            double val = value.toDouble();

            if (point.type == HealthDataType.WATER) {
              totalWater += val;
            } else if (point.type == HealthDataType.DISTANCE_DELTA) {
              totalDistance += val;
            } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              totalActive += val;
            } else if (point.type == HealthDataType.BASAL_ENERGY_BURNED || point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
              if (point.dateTo.isAfter(now)) {
                double totalMin = point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
                double elapsedMin = now.difference(point.dateFrom).inMinutes.toDouble();
                if (totalMin > 0) {
                  val = val * (max(0.0, min(totalMin, elapsedMin)) / totalMin);
                }
              }
              if (point.type == HealthDataType.BASAL_ENERGY_BURNED) {
                totalBasal += val;
              } else {
                totalTotal += val;
              }
            } else if (point.type == HealthDataType.HEART_RATE) {
              heartRates.add(value.toInt());
            }
          }
        } catch (e) {
          continue;
        }
      }

      if (totalBasal <= 0 && totalTotal > 0) {
        totalBasal = max(0.0, totalTotal - totalActive);
      }

      steps.value = max(steps.value, totalSteps);
      
      if (totalWater > 0) {
        water.value = totalWater; 
      }
      
      distance.value = max(distance.value, totalDistance);
      activeCalories.value = totalActive;
      bmrCalories.value = totalBasal;
      
      calories.value = activeCalories.value + bmrCalories.value + workoutCalories.value;
      updateMoveMinutes();

      if (heartRates.isNotEmpty) {
        heartRates.sort();
        heartRate.value = max(heartRate.value, heartRates.last);
      }

      if (uid.isNotEmpty) {
        final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        await _firestore.collection('users').doc(uid).collection('dailyActivities').doc(dateStr).set({
          'steps': steps.value,
          'water': water.value,
          'distance': distance.value,
          'activeCalories': activeCalories.value,
          'bmrCalories': bmrCalories.value,
          'workoutCalories': workoutCalories.value,
          'calories': calories.value,
          'moveMinutes': moveMinutes.value,
          'heartRate': heartRate.value,
          'lastSync': now.toIso8601String(),
        }, SetOptions(merge: true));
      }
      _calculateCompletionScore();
      debugPrint("--- ActivityController: Đồng bộ XONG! Steps: ${steps.value} ---");
    } catch (e) {
      debugPrint('Error in syncWithGoogleFit: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  void addWorkoutCalories(double workoutKcal) {
    workoutCalories.value += workoutKcal;
    calories.value += workoutKcal;
    _updateFirestoreCaloriesValue(workoutKcal);
    _calculateCompletionScore();
  }

  void addWater(double amount) {
    water.value += amount;
    _updateFirestoreWater();
    _calculateCompletionScore();
  }

  void updateWater(double newValue) {
    water.value = newValue;
    _updateFirestoreWater();
    _calculateCompletionScore();
  }

  Future<void> _updateFirestoreWater() async {
    if (uid.isEmpty) return;
    DateTime now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final syncService = Get.find<SyncService>();
    bool online = await syncService.hasInternet();
    if (online) {
      await _firestore.collection('users').doc(uid).collection('dailyActivities').doc(dateStr).set({
        'water': water.value,
        'lastSync': now.toIso8601String(),
      }, SetOptions(merge: true));
    } else {
      await syncService.addPendingLog('water', {
        'dateStr': dateStr,
        'water': water.value,
      });
    }
  }

  Future<void> _updateFirestoreCaloriesValue(double workoutKcal) async {
    if (uid.isEmpty) return;
    DateTime now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await _firestore.collection('users').doc(uid).collection('dailyActivities').doc(dateStr).set({
      'calories': FieldValue.increment(workoutKcal),
      'workoutCalories': FieldValue.increment(workoutKcal),
      'lastSync': now.toIso8601String(),
    }, SetOptions(merge: true));
  }

  void showCalorieFormula() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_graph_rounded, color: Get.theme.colorScheme.primary, size: 40),
              ),
              SizedBox(height: 20),
              Text(
                'Bí mật đằng sau con số!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1D1517),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '$userName tò mò công thức tính Calo tiêu thụ hôm nay đúng hông? Để tui bật mí cho nè:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF7B6F72), fontFamily: 'Poppins'),
              ),
              SizedBox(height: 24),
              _buildFormulaItem('🏃‍♂️ Calo vận động', activeCalories.value, 'Từ Google Fit'),
              _buildFormulaItem('🧬 Calo BMR', bmrCalories.value, 'Năng lượng cơ bản'),
              _buildFormulaItem('💪 Calo luyện tập', workoutCalories.value, 'Từ bài tập trong app'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Color(0xFFF7F8F8), thickness: 2),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${activeCalories.value.toStringAsFixed(0)} + ${bmrCalories.value.toStringAsFixed(0)} + ${workoutCalories.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '= ${calories.value.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1D1517),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    'Đã hiểu, quá chuẩn luôn!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulaItem(String title, double value, String subTitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1517),
                ),
              ),
              Text(
                subTitle,
                style: TextStyle(fontSize: 11, color: Color(0xFFADA4A5)),
              ),
            ],
          ),
          Text(
            '${value.toStringAsFixed(0)} kcal',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Get.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchStreak() async {
    if (uid.isEmpty) return;
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).collection('streaks').doc('current').get();
      if (snap.exists) {
        streakCount.value = snap['count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching streak: $e');
    }
  }

  Future<void> _updateStreak() async {
    if (uid.isEmpty) return;
    
    DateTime now = DateTime.now();
    String todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    DocumentReference streakRef = _firestore.collection('users').doc(uid).collection('streaks').doc('current');
    DocumentSnapshot snap = await streakRef.get();
    
    int currentStreak = 0;
    String lastActiveDate = "";
    
    if (snap.exists) {
      currentStreak = snap['count'] ?? 0;
      lastActiveDate = snap['lastDate'] ?? "";
    }
    
    if (lastActiveDate == todayStr) return;
    
    DateTime yesterday = now.subtract(Duration(days: 1));
    String yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
    
    if (lastActiveDate == yesterdayStr) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }
    
    await streakRef.set({
      'count': currentStreak,
      'lastDate': todayStr,
    });
    
    streakCount.value = currentStreak;
    
    _gamification.awardStreakExp(currentStreak);
  }

  void updateMoveMinutes() {
    double minutesFromFit = activeCalories.value / 6.0;
    double totalInAppMinutes = 0.0;
    
    if (Get.isRegistered<WorkoutController>()) {
      final workoutCtrl = Get.find<WorkoutController>();
      double totalInAppSeconds = 0.0;
      for (var schedule in workoutCtrl.todaySchedules) {
        if (schedule['isCompleted'] == true) {
          final name = schedule['exerciseName'] ?? '';
          final combo = workoutCtrl.combos.firstWhereOrNull((c) => c.title == name);
          if (combo != null) {
            for (var exId in combo.exerciseIds) {
              final exercise = workoutCtrl.allExercises.firstWhereOrNull((e) => e.id == exId);
              double factor = 1.0;
              if (exercise != null) {
                if (exercise.difficulty == 'Khó') {
                  factor = 1.3;
                } else if (exercise.difficulty == 'Trung bình') {
                  factor = 1.15;
                }
              }
              int reps = combo.exerciseReps[exId] ?? 10;
              int sets = combo.exerciseSets[exId] ?? 3;
              int rest = combo.exerciseRestTimes[exId] ?? 60;
              double exSecs = ((sets * reps * 2.5) + ((sets - 1) * rest)) * factor;
              totalInAppSeconds += exSecs;
            }
          } else {
            final exercise = workoutCtrl.allExercises.firstWhereOrNull((e) => e.title == name);
            double factor = 1.0;
            if (exercise != null) {
              if (exercise.difficulty == 'Khó') {
                factor = 1.3;
              } else if (exercise.difficulty == 'Trung bình') {
                factor = 1.15;
              }
            }
            int reps = schedule['reps'] ?? 10;
            int sets = schedule['sets'] ?? 3;
            int rest = schedule['restTime'] ?? 60;
            double exSecs = ((sets * reps * 2.5) + ((sets - 1) * rest)) * factor;
            totalInAppSeconds += exSecs;
          }
        }
      }
      totalInAppMinutes = totalInAppSeconds / 60.0;
    }
    
    moveMinutes.value = (minutesFromFit + totalInAppMinutes).round();
    _updateFirestoreMoveMinutes();
  }

  Future<void> _updateFirestoreMoveMinutes() async {
    if (uid.isEmpty) return;
    DateTime now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await _firestore.collection('users').doc(uid).collection('dailyActivities').doc(dateStr).set({
      'moveMinutes': moveMinutes.value,
      'lastSync': now.toIso8601String(),
    }, SetOptions(merge: true));
  }
}
