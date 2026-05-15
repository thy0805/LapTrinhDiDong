import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import 'package:nutrifit/modules/workout/controllers/health_service.dart';

class ActivityController extends GetxController {
  final HealthService _healthService = Get.find<HealthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var steps = 0.obs;
  var water = 0.0.obs;
  var distance = 0.0.obs;
  var calories = 0.0.obs;
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

  @override
  void onInit() {
    super.onInit();
    fetchTargets().then((_) {
      _fetchWeeklyActivities();
      _fetchDailyActivityFromFirebase().then((_) {
        syncWithGoogleFit();
        _calculateCompletionScore();
      });
    });
    
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      syncWithGoogleFit();
      _calculateCompletionScore();
    });

    _updateSmartSuggestion();
    _suggestionTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _updateSmartSuggestion();
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
        smartSuggestion.value = 'Bạn đang làm rất tốt, tiếp tục phát huy nhé! ✨';
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
      
      final dayOfWeek = DateTime.now().weekday;
      int indexInChart = (dayOfWeek % 7);
      weeklyScores[indexInChart] = completionScore.value;
      
      if (completionScore.value >= 8) {
        streakCount.value = 3;
      }
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
    
    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: i));
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('dailyActivities')
            .doc(dateStr)
            .get();
            
        if (doc.exists && doc.data() != null) {
          var data = doc.data() as Map<String, dynamic>;
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
      } catch (e) {
        debugPrint("Lỗi kéo data tuần: $e");
      }
    }
    weeklyScores.value = newWeeklyScores;
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
    await syncWithGoogleFit();
    if (steps.value > 0) {
      Get.snackbar('Thành công', 'Đã đồng bộ ${steps.value} bước chân!', 
        backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
    } else {
      Get.snackbar('Thông báo', 'Không tìm thấy dữ liệu mới từ Health Connect. Thy kiểm tra lại app Fit nhen!', 
        backgroundColor: Colors.orange.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  Future<void> syncWithGoogleFit() async {
    if (isSyncing.value) return;
    isSyncing.value = true;
    
    try {
      debugPrint("--- ActivityController: Bắt đầu đồng bộ... ---");
      if (!_healthService.isAuthorized.value) {
        bool ok = await _healthService.requestPermissions();
        if (!ok) {
          isSyncing.value = false;
          return;
        }
      }

      var types = [
        HealthDataType.STEPS,
        HealthDataType.WATER,
        HealthDataType.DISTANCE_DELTA,
        HealthDataType.ACTIVE_ENERGY_BURNED,
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
      double totalCalories = 0.0;
      int totalMoveMinutes = 0;
      List<int> heartRates = [];
      List<HealthDataPoint> caloriePoints = [];

      for (var point in healthData) {
        try {
          if (point.value is NumericHealthValue) {
            num value = (point.value as NumericHealthValue).numericValue;
            if (point.type == HealthDataType.WATER) {
              totalWater += value.toDouble();
            } else if (point.type == HealthDataType.DISTANCE_DELTA) {
              totalDistance += value.toDouble();
            } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED || point.type.name == 'TOTAL_CALORIES_BURNED') {
              caloriePoints.add(point);
            } else if (point.type == HealthDataType.HEART_RATE) {
              heartRates.add(value.toInt());
            }
          }
        } catch (e) {
          continue;
        }
      }

      double maxBmrCalories = 0.0;
      for (var point in caloriePoints) {
        double value = (point.value as NumericHealthValue).numericValue.toDouble();
        Duration duration = point.dateTo.difference(point.dateFrom);
        if (duration.inHours >= 4) {
          if (value > maxBmrCalories) maxBmrCalories = value;
        } else {
          totalCalories += value;
        }
      }

      totalCalories += maxBmrCalories;

      steps.value = max(steps.value, totalSteps);
      water.value = max(water.value, totalWater);
      distance.value = max(distance.value, totalDistance);
      calories.value = max(calories.value, totalCalories);
      moveMinutes.value = max(moveMinutes.value, totalMoveMinutes);

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
    calories.value += workoutKcal;
    _updateFirestoreCalories();
    _calculateCompletionScore();
  }

  Future<void> _updateFirestoreCalories() async {
    if (uid.isEmpty) return;
    DateTime now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await _firestore.collection('users').doc(uid).collection('dailyActivities').doc(dateStr).set({
      'calories': calories.value,
      'lastSync': now.toIso8601String(),
    }, SetOptions(merge: true));
  }
}
