import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:nutrifit/core/services/sync_service.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/core/services/gamification_service.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';

class ExerciseItem {
  final String id;
  final String title;
  final String difficulty;
  final int calories;
  final String description;
  final String category;
  final String image;
  var isFavorite = false.obs;

  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  ExerciseItem({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.calories,
    required this.description,
    required this.category,
    required this.image,
    bool favorite = false,
    this.bodyParts = const [],
    this.equipments = const [],
    this.targetMuscles = const [],
    this.secondaryMuscles = const [],
    this.instructions = const [],
  }) {
    isFavorite.value = favorite;
  }
}

class ComboItem {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  var exerciseIds = <String>[].obs;
  var exerciseReps = <String, int>{}.obs;
  var exerciseSets = <String, int>{}.obs;
  var exerciseWeights = <String, double>{}.obs;
  var exerciseRestTimes = <String, int>{}.obs;
  var isFavorite = false.obs;

  ComboItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    List<String> exerciseIds = const [],
    Map<String, int> exerciseReps = const {},
    Map<String, int> exerciseSets = const {},
    Map<String, double> exerciseWeights = const {},
    Map<String, int> exerciseRestTimes = const {},
    bool favorite = false,
  }) {
    this.exerciseIds.value = exerciseIds;
    this.exerciseReps.value = exerciseReps;
    this.exerciseSets.value = exerciseSets;
    this.exerciseWeights.value = exerciseWeights;
    this.exerciseRestTimes.value = exerciseRestTimes;
    isFavorite.value = favorite;

    for (var id in exerciseIds) {
      if (!this.exerciseReps.containsKey(id)) {
        this.exerciseReps[id] = 10;
      }
      if (!this.exerciseSets.containsKey(id)) {
        this.exerciseSets[id] = 3;
      }
      if (!this.exerciseWeights.containsKey(id)) {
        this.exerciseWeights[id] = 0.0;
      }
      if (!this.exerciseRestTimes.containsKey(id)) {
        this.exerciseRestTimes[id] = 60;
      }
    }
  }
}

class WorkoutController extends GetxController {
  var allExercises = <ExerciseItem>[].obs;
  var filteredExercises = <ExerciseItem>[].obs;
  var combos = <ComboItem>[].obs;
  var searchText = ''.obs;
  var selectedCategory = 'Tất cả'.obs;
  var availableCategories = <String>['Tất cả'].obs;
  var isLoading = true.obs;
  var currentLanguage = 'en'.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _syncService = Get.find<SyncService>();
  final GamificationService _gamification = Get.find<GamificationService>();

  StreamSubscription? _exerciseSubscription;

  var todaySchedules = <Map<String, dynamic>>[].obs;
  var selectedDateSchedules = <Map<String, dynamic>>[].obs;
  var completedSchedules = <Map<String, dynamic>>[].obs;
  final _isProcessingStatus = <String, bool>{}.obs;
  var isLoadingSchedules = false.obs;
  var isLoadingSelectedDateSchedules = false.obs;
  var isLoadingCompletedSchedules = false.obs;
  var weeklyCompletionData = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  var isResting = false.obs;
  var restSecondsRemaining = 0.obs;
  var totalRestTime = 0.obs;
  Timer? _restTimer;

  String get uid => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadInitialExercises();
    _loadInitialCombos();
    
    final authController = Get.find<AuthController>();
    if (authController.userData.isNotEmpty) {
      fetchSchedulesByDate(DateTime.now());
      _fetchWeeklyWorkoutCompletion();
      fetchCompletedSchedules();
    }
    
    ever(authController.userData, (data) {
      if (data.isNotEmpty && todaySchedules.isEmpty && !isLoadingSchedules.value) {
        fetchSchedulesByDate(DateTime.now());
        _fetchWeeklyWorkoutCompletion();
        fetchCompletedSchedules();
      }
    });

    final activityController = Get.find<ActivityController>();
    ever(activityController.calorieTarget, (_) {
      _fetchWeeklyWorkoutCompletion();
    });
  }

  @override
  void onClose() {
    _exerciseSubscription?.cancel();
    _restTimer?.cancel();
    super.onClose();
  }

  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    totalRestTime.value = seconds;
    restSecondsRemaining.value = seconds;
    isResting.value = true;
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restSecondsRemaining.value > 0) {
        restSecondsRemaining.value--;
      } else {
        stopRestTimer();
      }
    });
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    isResting.value = false;
    restSecondsRemaining.value = 0;
  }

  void skipRestTimer() {
    stopRestTimer();
  }

  void changeLanguage(String lang) {
    if (currentLanguage.value == lang) return;
    currentLanguage.value = lang;
    selectedCategory.value = 'Tất cả';
    _loadInitialExercises();
  }

  var hasMore = true.obs;
  var isMoreLoading = false.obs;
  DocumentSnapshot? _lastDocument;
  final int _limit = 20;

  void _loadInitialExercises() async {
    isLoading.value = true;
    allExercises.clear();
    _lastDocument = null;
    hasMore.value = true;

    final cachedExercises = _syncService.getAllCachedExercises();
    if (cachedExercises.isNotEmpty) {
      List<ExerciseItem> loadedExercises = [];
      for (int i = 0; i < cachedExercises.length; i++) {
        var data = cachedExercises[i];
        String id = data['exerciseId'] ?? 'unknown';
        loadedExercises.add(_mapDocToExercise(id, data));

        if (i % 50 == 0) {
          await Future.delayed(Duration.zero);
        }
      }
      allExercises.value = loadedExercises;

      _updateCategories();
      _applyFilters();
      isLoading.value = false;
      return;
    }

    await _fetchExercises();
    isLoading.value = false;
  }

  Future<void> _fetchExercises() async {
    try {
      String collectionName = currentLanguage.value == 'vi'
          ? 'exercises_vi'
          : 'exercises';

      Query query = _firestore
          .collection(collectionName)
          .orderBy('name')
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot snapshot = await query.get(
        const GetOptions(source: Source.serverAndCache),
      );

      if (snapshot.docs.length < _limit) {
        hasMore.value = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        var newExercises = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return _mapDocToExercise(doc.id, data);
        }).toList();

        allExercises.addAll(newExercises);
        _updateCategories();
        _applyFilters();
      }
    } catch (e) {
      debugPrint("Loi tai bai tap: $e");
    }
  }

  ExerciseItem _mapDocToExercise(String id, Map<String, dynamic> data) {
    String title = data['name'] ?? data['title'] ?? 'Chưa có tên';
    String image = data['gifUrl'] ?? data['image'] ?? '';

    String category = '';
    if (data['bodyParts'] != null &&
        data['bodyParts'] is List &&
        data['bodyParts'].isNotEmpty) {
      category = data['bodyParts'][0];
    } else {
      category = data['category'] ?? 'Khác';
    }

    String description = '';
    if (data['instructions'] != null && data['instructions'] is List) {
      description = (data['instructions'] as List).join('\n');
    } else {
      description = data['description'] ?? '';
    }

    return ExerciseItem(
      id: id,
      title: title,
      difficulty: data['difficulty'] ?? 'Dễ',
      calories: (data['calories'] == null || data['calories'] == 0)
          ? (data['difficulty'] == 'Khó'
                ? 45
                : (data['difficulty'] == 'Trung bình' ? 30 : 15))
          : (data['calories'] is num ? (data['calories'] as num).toInt() : 30),
      description: description,
      category: category,
      image: image,
      bodyParts: data['bodyParts'] != null
          ? List<String>.from(data['bodyParts'])
          : [],
      equipments: data['equipments'] != null
          ? List<String>.from(data['equipments'])
          : [],
      targetMuscles: data['targetMuscles'] != null
          ? List<String>.from(data['targetMuscles'])
          : [],
      secondaryMuscles: data['secondaryMuscles'] != null
          ? List<String>.from(data['secondaryMuscles'])
          : [],
      instructions: data['instructions'] != null
          ? List<String>.from(data['instructions'])
          : [],
    );
  }

  void loadMoreExercises() async {
    if (isMoreLoading.value || !hasMore.value) return;

    isMoreLoading.value = true;
    await _fetchExercises();
    isMoreLoading.value = false;
  }

  int _currentReqId = 0;
  Future<void> fetchSchedulesByDate(DateTime date) async {
    if (uid.isEmpty) {
      isLoadingSchedules.value = false;
      return;
    }
    DateTime now = DateTime.now();
    if (date.year != now.year || date.month != now.month || date.day != now.day) {
      return;
    }
    isLoadingSchedules.value = true;
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get()
          .timeout(const Duration(seconds: 15));

      todaySchedules.value = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Loi: $e");
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  Future<void> fetchSchedulesForSelectedDate(DateTime date) async {
    if (uid.isEmpty) {
      isLoadingSelectedDateSchedules.value = false;
      return;
    }
    DateTime now = DateTime.now();
    bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday && !isLoadingSchedules.value) {
      selectedDateSchedules.value = List.from(todaySchedules);
      isLoadingSelectedDateSchedules.value = false;
      return;
    }
    int reqId = ++_currentReqId;
    isLoadingSelectedDateSchedules.value = true;
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get()
          .timeout(const Duration(seconds: 15));

      if (reqId == _currentReqId) {
        selectedDateSchedules.value = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      }
    } catch (e) {
      debugPrint("Loi: $e");
      if (e is TimeoutException && reqId == _currentReqId) {
        Get.snackbar('Lỗi kết nối', 'Không thể kết nối với Firebase, vui lòng kiểm tra mạng!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } finally {
      if (reqId == _currentReqId) {
        isLoadingSelectedDateSchedules.value = false;
      }
    }
  }

  Future<void> fetchCompletedSchedules() async {
    if (uid.isEmpty) return;
    isLoadingCompletedSchedules.value = true;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .where('isCompleted', isEqualTo: true)
          .orderBy('date', descending: true)
          .get()
          .timeout(const Duration(seconds: 15));

      completedSchedules.value = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Loi fetchCompletedSchedules: $e");
    } finally {
      isLoadingCompletedSchedules.value = false;
    }
  }

  Future<void> addSchedule({
    required String exerciseName,
    required String exerciseImage,
    required DateTime date,
    required String time,
    required List<bool> repeatDays,
    int sets = 3,
    int reps = 15,
    double weight = 0.0,
    int restTime = 60,
  }) async {
    int cleanSets = sets < 1 ? 1 : sets;
    int cleanReps = reps < 1 ? 1 : reps;
    double cleanWeight = weight < 0.0 ? 0.0 : weight;
    int cleanRestTime = restTime < 0 ? 0 : restTime;

    try {
      double volume = cleanWeight > 0 ? (cleanSets * cleanReps * cleanWeight) : (cleanSets * cleanReps).toDouble();
      
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .add({
            'exerciseName': exerciseName,
            'exerciseImage': exerciseImage,
            'date': Timestamp.fromDate(date),
            'time': time,
            'repeatDays': repeatDays,
            'sets': cleanSets,
            'reps': cleanReps,
            'weight': cleanWeight,
            'volume': volume,
            'restTime': cleanRestTime,
            'isCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      fetchSchedulesByDate(date);
      fetchSchedulesForSelectedDate(date);
      _fetchWeeklyWorkoutCompletion();
      fetchCompletedSchedules();
    } catch (e) {
      debugPrint("Loi: $e");
    }
  }

  Future<void> updateSchedule({
    required String scheduleId,
    required String exerciseName,
    required String exerciseImage,
    required DateTime date,
    required String time,
    required List<bool> repeatDays,
    int sets = 3,
    int reps = 15,
    double weight = 0.0,
    int restTime = 60,
  }) async {
    int cleanSets = sets < 1 ? 1 : sets;
    int cleanReps = reps < 1 ? 1 : reps;
    double cleanWeight = weight < 0.0 ? 0.0 : weight;
    int cleanRestTime = restTime < 0 ? 0 : restTime;

    try {
      double volume = cleanWeight > 0 ? (cleanSets * cleanReps * cleanWeight) : (cleanSets * cleanReps).toDouble();

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .doc(scheduleId)
          .update({
            'exerciseName': exerciseName,
            'exerciseImage': exerciseImage,
            'date': Timestamp.fromDate(date),
            'time': time,
            'repeatDays': repeatDays,
            'sets': cleanSets,
            'reps': cleanReps,
            'weight': cleanWeight,
            'volume': volume,
            'restTime': cleanRestTime,
          });

      DateTime now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        final oldSchedule = todaySchedules.firstWhereOrNull(
          (s) => s['id'] == scheduleId,
        );
        
        if (oldSchedule != null && (oldSchedule['isCompleted'] ?? false)) {
          double oldCalo = await calculateCaloriesForExercise(
            oldSchedule['exerciseName'] ?? '',
            scheduleReps: oldSchedule['reps'] ?? 0,
            scheduleSets: oldSchedule['sets'] ?? 0,
            scheduleWeight: (oldSchedule['weight'] is num) ? (oldSchedule['weight'] as num).toDouble() : 0.0,
            scheduleRestTime: oldSchedule['restTime'] ?? 60,
          );
          double newCalo = await calculateCaloriesForExercise(
            exerciseName,
            scheduleReps: cleanReps,
            scheduleSets: cleanSets,
            scheduleWeight: cleanWeight,
            scheduleRestTime: cleanRestTime,
          );
          if (newCalo != oldCalo) {
            Get.find<ActivityController>().addWorkoutCalories(newCalo - oldCalo);
          }
        }
      }

      fetchSchedulesByDate(date);
      fetchSchedulesForSelectedDate(date);
      fetchCompletedSchedules();
    } catch (e) {
      debugPrint("Loi: $e");
    }
  }

  Future<void> updateScheduleStatus(String scheduleId, bool isCompleted) async {
    if (uid.isEmpty) return;
    if (_isProcessingStatus[scheduleId] == true) return;
    _isProcessingStatus[scheduleId] = true;
    try {
      var scheduleMap = todaySchedules.firstWhereOrNull((s) => s['id'] == scheduleId)
          ?? selectedDateSchedules.firstWhereOrNull((s) => s['id'] == scheduleId);

      if (scheduleMap != null) {
        bool oldStatus = scheduleMap['isCompleted'] ?? false;
        if (oldStatus != isCompleted) {
          final exerciseName = scheduleMap['exerciseName'];
          final exercise = allExercises.firstWhereOrNull(
            (e) => e.title == exerciseName,
          );

          int reps = scheduleMap['reps'] ?? 0;
          int sets = scheduleMap['sets'] ?? 0;
          double weight = (scheduleMap['weight'] is num) ? (scheduleMap['weight'] as num).toDouble() : 0.0;
          int restTime = scheduleMap['restTime'] ?? 60;

          double calo = 0.0;
          if (isCompleted) {
            calo = await calculateCaloriesForExercise(
              exerciseName,
              scheduleReps: reps,
              scheduleSets: sets,
              scheduleWeight: weight,
              scheduleRestTime: restTime,
            );
          } else {
            calo = (scheduleMap['caloriesBurned'] as num?)?.toDouble() ?? 0.0;
            if (calo == 0.0) {
              calo = await calculateCaloriesForExercise(
                exerciseName,
                scheduleReps: reps,
                scheduleSets: sets,
                scheduleWeight: weight,
                scheduleRestTime: restTime,
              );
            }
          }

          String difficulty = 'Trung bình';
          if (exercise != null) {
            difficulty = exercise.difficulty;
          }

          if (calo > 0) {
            DateTime scheduleDate = (scheduleMap['date'] is Timestamp)
                ? (scheduleMap['date'] as Timestamp).toDate()
                : (scheduleMap['date'] is DateTime ? scheduleMap['date'] as DateTime : DateTime.now());
            DateTime now = DateTime.now();
            bool isToday = scheduleDate.year == now.year && scheduleDate.month == now.month && scheduleDate.day == now.day;

            if (isCompleted) {
              if (isToday) Get.find<ActivityController>().addWorkoutCalories(calo);
              await _gamification.awardWorkoutExp(difficulty);

              double volume = (scheduleMap['volume'] is num) ? (scheduleMap['volume'] as num).toDouble() : 0.0;
              if (volume > 0) {
                _checkProgressiveOverload(exerciseName, volume, weight);
              }

              final auth = Get.find<AuthController>();
              int totalCompleted = (auth.userData['totalWorkoutCompleted'] ?? 0) + 1;
              auth.userData['totalWorkoutCompleted'] = totalCompleted;
              
              List<dynamic> uniqueIds = List.from(auth.userData['completed_exercise_ids'] ?? []);
              final scheduleName = scheduleMap['exerciseName'] ?? '';
              
              final combo = combos.firstWhereOrNull((c) => c.title == scheduleName);
              if (combo != null) {
                for (var exId in combo.exerciseIds) {
                  if (exId.isNotEmpty && !uniqueIds.contains(exId)) {
                    uniqueIds.add(exId);
                  }
                }
              } else {
                String exerciseId = scheduleMap['exerciseId'] ?? scheduleName;
                if (exerciseId.isNotEmpty && !uniqueIds.contains(exerciseId)) {
                  uniqueIds.add(exerciseId);
                }
              }
              
              auth.userData['completed_exercise_ids'] = uniqueIds;

              await _firestore.collection('users').doc(uid).update({
                'totalWorkoutCompleted': totalCompleted,
                'completed_exercise_ids': uniqueIds,
              });

              if (totalCompleted >= 10) {
                await _gamification.unlockAchievement(
                  'workout_warrior',
                  'Lực Sĩ',
                  'Hoàn thành tổng cộng 10 bài tập. Cơ bắp đang lớn dần rồi đó! 💪',
                  100,
                );
              }
            } else {
              if (isToday) Get.find<ActivityController>().addWorkoutCalories(-calo);
            }
          }

          await _firestore
              .collection('users')
              .doc(uid)
              .collection('workout_schedules')
              .doc(scheduleId)
              .update({
            'isCompleted': isCompleted,
            'caloriesBurned': isCompleted ? calo : 0.0,
          });

          int todayIdx = todaySchedules.indexWhere((s) => s['id'] == scheduleId);
          if (todayIdx != -1) {
            todaySchedules[todayIdx]['isCompleted'] = isCompleted;
            todaySchedules[todayIdx]['caloriesBurned'] = isCompleted ? calo : 0.0;
            todaySchedules.refresh();
          }

          int selIdx = selectedDateSchedules.indexWhere((s) => s['id'] == scheduleId);
          if (selIdx != -1) {
            selectedDateSchedules[selIdx]['isCompleted'] = isCompleted;
            selectedDateSchedules[selIdx]['caloriesBurned'] = isCompleted ? calo : 0.0;
            selectedDateSchedules.refresh();
          }
        }
      }
      _fetchWeeklyWorkoutCompletion();
      fetchCompletedSchedules();
    } catch (e) {
      debugPrint("Loi: $e");
    } finally {
      _isProcessingStatus[scheduleId] = false;
    }
  }

  Future<void> _checkProgressiveOverload(String exerciseName, double currentVolume, double weight) async {
    if (uid.isEmpty || currentVolume <= 0) return;
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      QuerySnapshot maxWorkoutQuery = await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .where('exerciseName', isEqualTo: exerciseName)
          .where('isCompleted', isEqualTo: true)
          .where('date', isLessThan: Timestamp.fromDate(startOfDay))
          .orderBy('date', descending: true)
          .get();

      if (maxWorkoutQuery.docs.isNotEmpty) {
        double maxOldVolume = 0.0;
        for (var doc in maxWorkoutQuery.docs) {
          var oldData = doc.data() as Map<String, dynamic>;
          double v = (oldData['volume'] is num) ? (oldData['volume'] as num).toDouble() : 0.0;
          if (v > maxOldVolume) maxOldVolume = v;
        }

        if (maxOldVolume > 0 && currentVolume > maxOldVolume) {
          double increase = ((currentVolume - maxOldVolume) / maxOldVolume) * 100;
          String metric = weight > 0 ? "khối lượng tạ" : "tổng số lượng";
          Get.snackbar(
            'Phá Kỷ Lục Mới! 🏆',
            'Sức mạnh ($metric) của bạn đã vượt kỷ lục cá nhân ${increase.toStringAsFixed(1)}%!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      debugPrint("Loi progressive overload: $e");
    }
  }

  Future<void> removeSchedule(String scheduleId) async {
    if (uid.isEmpty) return;
    try {
      final schedule = todaySchedules.firstWhereOrNull(
        (s) => s['id'] == scheduleId,
      ) ?? selectedDateSchedules.firstWhereOrNull(
        (s) => s['id'] == scheduleId,
      );
      if (schedule != null) {
        DateTime date = (schedule['date'] is Timestamp)
            ? (schedule['date'] as Timestamp).toDate()
            : (schedule['date'] is DateTime ? schedule['date'] as DateTime : DateTime.now());
        DateTime now = DateTime.now();
        bool isCompleted = schedule['isCompleted'] ?? false;
        
        if (isCompleted && date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          double calo = (schedule['caloriesBurned'] as num?)?.toDouble() ?? 0.0;
          if (calo == 0.0) {
            calo = await calculateCaloriesForExercise(
              schedule['exerciseName'] ?? '',
              scheduleReps: schedule['reps'] ?? 0,
              scheduleSets: schedule['sets'] ?? 0,
              scheduleWeight: (schedule['weight'] is num) ? (schedule['weight'] as num).toDouble() : 0.0,
              scheduleRestTime: schedule['restTime'] ?? 60,
            );
          }
          if (calo > 0) {
            Get.find<ActivityController>().addWorkoutCalories(-calo);
          }
        }
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .doc(scheduleId)
          .delete();

      todaySchedules.removeWhere((s) => s['id'] == scheduleId);
      selectedDateSchedules.removeWhere((s) => s['id'] == scheduleId);
      _fetchWeeklyWorkoutCompletion();
      fetchCompletedSchedules();
    } catch (e) {
      debugPrint("Loi: $e");
    }
  }

  Future<void> _fetchWeeklyWorkoutCompletion() async {
    if (uid.isEmpty) return;

    List<double> newCompletionData = List.filled(7, 0.0);
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .get();

      Map<String, List<Map<String, dynamic>>> schedulesByDay = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp? ts = data['date'] as Timestamp?;
        if (ts != null) {
          DateTime d = ts.toDate();
          String key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          schedulesByDay.putIfAbsent(key, () => []).add(data);
        }
      }

      for (int i = 0; i < 7; i++) {
        DateTime date = now.subtract(Duration(days: i));
        String key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        
        List<Map<String, dynamic>>? daySchedules = schedulesByDay[key];
        double ratio = 0.0;
        if (daySchedules != null && daySchedules.isNotEmpty) {
          int completed = daySchedules.where((s) => s['isCompleted'] == true).length;
          ratio = (completed / daySchedules.length) * 100;
        }
        
        int indexInChart = 6 - i;
        newCompletionData[indexInChart] = ratio;
      }
      
      weeklyCompletionData.value = newCompletionData;
      weeklyCompletionData.refresh();
    } catch (e) {
      debugPrint("Loi fetch weekly workout completion: $e");
    }
  }

  void _updateCategories() {
    Set<String> cats = {'Tất cả'};
    for (var ex in allExercises) {
      if (ex.category.isNotEmpty) cats.add(ex.category);
    }
    availableCategories.value = cats.toList();
  }

  Future<void> _loadInitialCombos() async {
    if (uid.isEmpty) return;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('combos')
          .get();

      combos.value = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return ComboItem(
          id: doc.id,
          title: data['title'] ?? 'Combo',
          subtitle: data['subtitle'] ?? '',
          image: data['image'] ?? 'assets/workoutfullbody.png',
          exerciseIds: List<String>.from(data['exerciseIds'] ?? []),
          exerciseReps: (data['exerciseReps'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {},
          exerciseSets: (data['exerciseSets'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {},
          exerciseWeights: (data['exerciseWeights'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())) ?? {},
          exerciseRestTimes: (data['exerciseRestTimes'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {},
          favorite: data['isFavorite'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint("Loi: $e");
    }
  }

  List<ExerciseItem> getExercisesForCombo(ComboItem combo) {
    if (combo.exerciseIds.isEmpty) return [];
    return allExercises
        .where((ex) => combo.exerciseIds.contains(ex.id))
        .toList();
  }

  Future<void> addExerciseToCombo(
    String comboId,
    String exerciseId, {
    int reps = 10,
    int sets = 3,
    double weight = 0.0,
    int restTime = 60,
  }) async {
    if (uid.isEmpty) return;

    final comboIndex = combos.indexWhere((c) => c.id == comboId);
    if (comboIndex != -1) {
      if (!combos[comboIndex].exerciseIds.contains(exerciseId)) {
        combos[comboIndex].exerciseIds.add(exerciseId);
        combos[comboIndex].exerciseReps[exerciseId] = reps;
        combos[comboIndex].exerciseSets[exerciseId] = sets;
        combos[comboIndex].exerciseWeights[exerciseId] = weight;
        combos[comboIndex].exerciseRestTimes[exerciseId] = restTime;
        combos.refresh();

        try {
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('combos')
              .doc(comboId)
              .update({
                'exerciseIds': FieldValue.arrayUnion([exerciseId]),
                'exerciseReps.$exerciseId': reps,
                'exerciseSets.$exerciseId': sets,
                'exerciseWeights.$exerciseId': weight,
                'exerciseRestTimes.$exerciseId': restTime,
              });
        } catch (e) {
          debugPrint("Loi: $e");
        }
      }
    }
  }

  Future<void> createNewCombo(
    String title,
    List<String> initialExerciseIds, {
    int reps = 10,
    int sets = 3,
    double weight = 0.0,
    int restTime = 60,
  }) async {
    if (uid.isEmpty) return;

    Map<String, int> initialReps = {};
    Map<String, int> initialSets = {};
    Map<String, double> initialWeights = {};
    Map<String, int> initialRestTimes = {};

    for (var id in initialExerciseIds) {
      initialReps[id] = reps;
      initialSets[id] = sets;
      initialWeights[id] = weight;
      initialRestTimes[id] = restTime;
    }

    try {
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('combos')
          .add({
            'title': title,
            'subtitle': '',
            'image': 'assets/workoutfullbody.png',
            'exerciseIds': initialExerciseIds,
            'exerciseReps': initialReps,
            'exerciseSets': initialSets,
            'exerciseWeights': initialWeights,
            'exerciseRestTimes': initialRestTimes,
            'isFavorite': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

      combos.add(
        ComboItem(
          id: docRef.id,
          title: title,
          subtitle: '',
          image: 'assets/workoutfullbody.png',
          exerciseIds: List.from(initialExerciseIds),
          exerciseReps: initialReps,
          exerciseSets: initialSets,
          exerciseWeights: initialWeights,
          exerciseRestTimes: initialRestTimes,
        ),
      );
    } catch (e) {
      debugPrint("Loi: $e");
    }
  }

  Future<void> updateExerciseReps(
    String comboId,
    String exerciseId,
    int reps,
  ) async {
    if (uid.isEmpty) return;

    final combo = combos.firstWhereOrNull((c) => c.id == comboId);
    if (combo != null) {
      combo.exerciseReps[exerciseId] = reps;
      combos.refresh();

      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('combos')
            .doc(comboId)
            .update({'exerciseReps.$exerciseId': reps});
      } catch (e) {
        debugPrint("Loi: $e");
      }
    }
  }

  Future<void> updateExerciseDetails(
    String comboId,
    String exerciseId,
    int reps,
    int sets,
    double weight,
    int restTime,
  ) async {
    if (uid.isEmpty) return;

    int cleanSets = sets < 1 ? 1 : sets;
    int cleanReps = reps < 1 ? 1 : reps;
    double cleanWeight = weight < 0.0 ? 0.0 : weight;
    int cleanRestTime = restTime < 0 ? 0 : restTime;

    final combo = combos.firstWhereOrNull((c) => c.id == comboId);
    if (combo != null) {
      combo.exerciseReps[exerciseId] = cleanReps;
      combo.exerciseSets[exerciseId] = cleanSets;
      combo.exerciseWeights[exerciseId] = cleanWeight;
      combo.exerciseRestTimes[exerciseId] = cleanRestTime;
      combos.refresh();

      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('combos')
            .doc(comboId)
            .update({
              'exerciseReps.$exerciseId': cleanReps,
              'exerciseSets.$exerciseId': cleanSets,
              'exerciseWeights.$exerciseId': cleanWeight,
              'exerciseRestTimes.$exerciseId': cleanRestTime,
            });
      } catch (e) {
        debugPrint("Loi: $e");
      }
    }
  }

  Future<void> updateExerciseRestTime(
    String comboId,
    String exerciseId,
    int restTime,
  ) async {
    if (uid.isEmpty) return;

    final combo = combos.firstWhereOrNull((c) => c.id == comboId);
    if (combo != null) {
      combo.exerciseRestTimes[exerciseId] = restTime;
      combos.refresh();

      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('combos')
            .doc(comboId)
            .update({'exerciseRestTimes.$exerciseId': restTime});
      } catch (e) {
        debugPrint("Loi: $e");
      }
    }
  }

  void setSearchText(String text) {
    searchText.value = text;
    _applyFilters();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void _applyFilters() {
    filteredExercises.value = allExercises.where((ex) {
      bool matchSearch = ex.title.toLowerCase().contains(
        searchText.value.toLowerCase(),
      );
      bool matchCategory =
          selectedCategory.value == 'Tất cả' ||
          ex.category == selectedCategory.value;
      return matchSearch && matchCategory;
    }).toList();
  }

  void toggleFavorite(ExerciseItem exercise) {
    exercise.isFavorite.value = !exercise.isFavorite.value;
  }

  Future<void> toggleComboFavorite(ComboItem combo) async {
    if (uid.isEmpty) return;

    combo.isFavorite.value = !combo.isFavorite.value;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('combos')
          .doc(combo.id)
          .update({'isFavorite': combo.isFavorite.value});
    } catch (e) {
      debugPrint("Loi: $e");
    }
  }

  Future<void> removeExerciseFromCombo(String comboId, String exerciseId) async {
    if (uid.isEmpty) return;

    final comboIndex = combos.indexWhere((c) => c.id == comboId);
    if (comboIndex != -1) {
      final combo = combos[comboIndex];
      if (combo.exerciseIds.contains(exerciseId)) {
        combo.exerciseIds.remove(exerciseId);
        combo.exerciseReps.remove(exerciseId);
        combo.exerciseSets.remove(exerciseId);
        combo.exerciseWeights.remove(exerciseId);
        combo.exerciseRestTimes.remove(exerciseId);
        combos.refresh();

        try {
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('combos')
              .doc(comboId)
              .update({
            'exerciseIds': FieldValue.arrayRemove([exerciseId]),
            'exerciseReps.$exerciseId': FieldValue.delete(),
            'exerciseSets.$exerciseId': FieldValue.delete(),
            'exerciseWeights.$exerciseId': FieldValue.delete(),
            'exerciseRestTimes.$exerciseId': FieldValue.delete(),
          });
        } catch (e) {
          debugPrint("Loi: $e");
        }
      }
    }
  }

  Future<double> calculateCaloriesForExercise(
    String name, {
    int scheduleReps = 0,
    int scheduleSets = 0,
    double scheduleWeight = 0.0,
    int scheduleRestTime = 60,
  }) async {
    final authData = Get.find<AuthController>().userData;
    double userWeight = 65.0;
    if (authData.containsKey('weight') && authData['weight'] != null) {
      final wVal = authData['weight'];
      if (wVal is num) {
        userWeight = wVal.toDouble();
      } else if (wVal is String) {
        userWeight = double.tryParse(wVal) ?? 65.0;
      }
    }
    double wFactor = userWeight / 65.0;

    final combo = combos.firstWhereOrNull((c) => c.title == name);
    if (combo != null) {
      double total = 0;
      for (var exId in combo.exerciseIds) {
        final exercise = allExercises.firstWhereOrNull((e) => e.id == exId);
        int reps = combo.exerciseReps[exId] ?? 10;
        int sets = combo.exerciseSets[exId] ?? 3;

        int calBase = exercise?.calories ?? 15;
        double itemCalo = ((calBase * reps * sets) / 10.0) * wFactor;
        total += itemCalo;
      }
      return total;
    }

    final exercise = allExercises.firstWhereOrNull((e) => e.title == name);
    int calBase = 15;
    if (exercise != null) {
      calBase = exercise.calories;
    } else {
      try {
        String collectionName = currentLanguage.value == 'vi' ? 'exercises_vi' : 'exercises';
        var querySnap = await _firestore.collection(collectionName).where('name', isEqualTo: name).limit(1).get();
        if (querySnap.docs.isEmpty) {
          querySnap = await _firestore.collection(collectionName).where('title', isEqualTo: name).limit(1).get();
        }
        if (querySnap.docs.isNotEmpty) {
          var data = querySnap.docs.first.data();
          if (data['calories'] != null) {
            calBase = (data['calories'] as num).toInt();
          }
        }
      } catch (e) {
        debugPrint("Loi: $e");
      }
    }

    int r = scheduleReps > 0 ? scheduleReps : 10;
    int s = scheduleSets > 0 ? scheduleSets : 3;

    return ((calBase * r * s) / 10.0) * wFactor;
  }

  List<ExerciseItem> get favoriteExercises =>
      allExercises.where((ex) => ex.isFavorite.value).toList();
  List<ComboItem> get favoriteCombos =>
      combos.where((cb) => cb.isFavorite.value).toList();

  Future<ExerciseItem?> getExerciseByName(String name) async {
    final exercise = allExercises.firstWhereOrNull((e) => e.title == name);
    if (exercise != null) return exercise;

    try {
      String collectionName = currentLanguage.value == 'vi' ? 'exercises_vi' : 'exercises';
      var querySnap = await _firestore.collection(collectionName).where('name', isEqualTo: name).limit(1).get();
      if (querySnap.docs.isEmpty) {
        querySnap = await _firestore.collection(collectionName).where('title', isEqualTo: name).limit(1).get();
      }
      if (querySnap.docs.isNotEmpty) {
        var data = querySnap.docs.first.data();
        return _mapDocToExercise(querySnap.docs.first.id, data);
      }
    } catch (e) {
      debugPrint("Loi fetch getExerciseByName: $e");
    }
    return null;
  }

  Future<void> completeWorkoutSession(List<WorkoutExecutionItem> items, {String? scheduleId, String? title}) async {
    if (uid.isEmpty) return;
    try {
      double totalCalo = 0.0;
      final auth = Get.find<AuthController>();
      final activity = Get.find<ActivityController>();
      
      List<dynamic> uniqueIds = List.from(auth.userData['completed_exercise_ids'] ?? []);
      
      for (var item in items) {
        double calo = await calculateCaloriesForExercise(
          item.exercise.title,
          scheduleReps: item.reps,
          scheduleSets: item.sets,
          scheduleWeight: item.weight,
          scheduleRestTime: item.restTime,
        );
        totalCalo += calo;
        
        await _gamification.awardWorkoutExp(item.exercise.difficulty);
        
        if (!uniqueIds.contains(item.exercise.id)) {
          uniqueIds.add(item.exercise.id);
        }
      }
      
      if (totalCalo > 0) {
        activity.addWorkoutCalories(totalCalo);
      }
      
      int totalCompleted = (auth.userData['totalWorkoutCompleted'] ?? 0) + 1;
      auth.userData['totalWorkoutCompleted'] = totalCompleted;
      auth.userData['completed_exercise_ids'] = uniqueIds;
      
      await _firestore.collection('users').doc(uid).update({
        'totalWorkoutCompleted': totalCompleted,
        'completed_exercise_ids': uniqueIds,
      });
      
      if (totalCompleted >= 10) {
        await _gamification.unlockAchievement(
          'workout_warrior',
          'Lực Sĩ',
          'Hoàn thành tổng cộng 10 bài tập. Cơ bắp đang lớn dần rồi đó! 💪',
          100,
        );
      }

      if (scheduleId != null && scheduleId.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('workout_schedules')
            .doc(scheduleId)
            .update({
          'isCompleted': true,
          'caloriesBurned': totalCalo,
        });
      } else {
        DateTime now = DateTime.now();
        String t = title ?? (items.isNotEmpty ? items.first.exercise.title : 'Tập luyện');
        double firstWeight = 0.0;
        int firstReps = 10;
        int firstSets = 3;
        int firstRestTime = 60;
        String firstImage = 'assets/fullbody.png';
        if (items.isNotEmpty) {
          firstWeight = items.first.weight;
          firstReps = items.first.reps;
          firstSets = items.first.sets;
          firstRestTime = items.first.restTime;
          firstImage = items.first.exercise.image;
        }
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('workout_schedules')
            .add({
          'exerciseName': t,
          'exerciseImage': firstImage,
          'date': Timestamp.fromDate(now),
          'time': "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
          'isCompleted': true,
          'sets': firstSets,
          'reps': firstReps,
          'weight': firstWeight,
          'restTime': firstRestTime,
          'caloriesBurned': totalCalo,
        });
      }
      fetchSchedulesByDate(DateTime.now());
      _fetchWeeklyWorkoutCompletion();
      fetchCompletedSchedules();
    } catch (e) {
      debugPrint("Loi completeWorkoutSession: $e");
    }
  }
}

class WorkoutExecutionItem {
  final ExerciseItem exercise;
  final int sets;
  final int reps;
  final double weight;
  final int restTime;

  WorkoutExecutionItem({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restTime,
  });
}
