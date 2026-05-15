import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nutrifit/core/services/sync_service.dart';

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
  var isFavorite = false.obs;

  ComboItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    bool favorite = false,
  }) {
    isFavorite.value = favorite;
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
  
  StreamSubscription? _exerciseSubscription;

  var todaySchedules = <Map<String, dynamic>>[].obs;
  var isLoadingSchedules = false.obs;
  var weeklyCompletionData = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  String get uid => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadInitialExercises();
    _loadInitialCombos();
    fetchSchedulesByDate(DateTime.now());
    _fetchWeeklyWorkoutCompletion();
  }

  @override
  void onClose() {
    _exerciseSubscription?.cancel();
    super.onClose();
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
        
        // Tránh block UI khi map một list quá lớn (gây crash/ANR)
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
      String collectionName = currentLanguage.value == 'vi' ? 'exercises_vi' : 'exercises';
      
      Query query = _firestore.collection(collectionName)
          .orderBy('name')
          .limit(_limit);
          
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot snapshot = await query.get(const GetOptions(source: Source.serverAndCache));
      
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
    if (data['bodyParts'] != null && data['bodyParts'] is List && data['bodyParts'].isNotEmpty) {
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
      calories: data['calories'] ?? 0,
      description: description,
      category: category,
      image: image,
      bodyParts: data['bodyParts'] != null ? List<String>.from(data['bodyParts']) : [],
      equipments: data['equipments'] != null ? List<String>.from(data['equipments']) : [],
      targetMuscles: data['targetMuscles'] != null ? List<String>.from(data['targetMuscles']) : [],
      secondaryMuscles: data['secondaryMuscles'] != null ? List<String>.from(data['secondaryMuscles']) : [],
      instructions: data['instructions'] != null ? List<String>.from(data['instructions']) : [],
    );
  }

  void loadMoreExercises() async {
    if (isMoreLoading.value || !hasMore.value) return;
    
    isMoreLoading.value = true;
    await _fetchExercises();
    isMoreLoading.value = false;
  }

  Future<void> fetchSchedulesByDate(DateTime date) async {
    if (uid.isEmpty) return;
    
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
          .get();

      todaySchedules.value = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Lỗi: $e");
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  Future<void> addSchedule({
    required String exerciseName,
    required String exerciseImage,
    required DateTime date,
    required String time,
    required List<bool> repeatDays,
  }) async {
    if (uid.isEmpty) return;

    try {
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
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      fetchSchedulesByDate(date);
      _fetchWeeklyWorkoutCompletion();
    } catch (e) {
      debugPrint("Lỗi khi thêm lịch tập: $e");
    }
  }

  Future<void> updateSchedule({
    required String scheduleId,
    required String exerciseName,
    required String exerciseImage,
    required DateTime date,
    required String time,
    required List<bool> repeatDays,
  }) async {
    if (uid.isEmpty) return;

    try {
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
      });
      
      fetchSchedulesByDate(date);
    } catch (e) {
      debugPrint("Lỗi khi cập nhật lịch tập: $e");
    }
  }

  Future<void> updateScheduleStatus(String scheduleId, bool isCompleted) async {
    if (uid.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .doc(scheduleId)
          .update({'isCompleted': isCompleted});
          
      int index = todaySchedules.indexWhere((s) => s['id'] == scheduleId);
      if (index != -1) {
        todaySchedules[index]['isCompleted'] = isCompleted;
        todaySchedules.refresh();
      }
      _fetchWeeklyWorkoutCompletion();
    } catch (e) {
      debugPrint("Lỗi khi cập nhật trạng thái lịch tập: $e");
    }
  }

  Future<void> removeSchedule(String scheduleId) async {
    if (uid.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .doc(scheduleId)
          .delete();
      
      todaySchedules.removeWhere((s) => s['id'] == scheduleId);
      _fetchWeeklyWorkoutCompletion();
    } catch (e) {
      debugPrint("Lỗi khi xóa lịch tập: $e");
    }
  }

  Future<void> _fetchWeeklyWorkoutCompletion() async {
    if (uid.isEmpty) return;
    DateTime now = DateTime.now();
    List<double> newCompletionData = [0, 0, 0, 0, 0, 0, 0];

    for (int i = 0; i < 7; i++) {
      DateTime targetDate = now.subtract(Duration(days: i));
      DateTime startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      try {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('workout_schedules')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('date', isLessThan: Timestamp.fromDate(endOfDay))
            .get();

        if (snapshot.docs.isNotEmpty) {
          int total = snapshot.docs.length;
          int completed = snapshot.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['isCompleted'] == true;
          }).length;
          
          double percentage = (completed / total) * 100;
          int indexInChart = (targetDate.weekday % 7);
          newCompletionData[indexInChart] = percentage;
        }
      } catch (e) {
        debugPrint("Lỗi fetch weekly workout completion: $e");
      }
    }
    weeklyCompletionData.value = newCompletionData;
  }

  void _updateCategories() {
    Set<String> cats = {'Tất cả'};
    for (var ex in allExercises) {
      if (ex.category.isNotEmpty) cats.add(ex.category);
    }
    availableCategories.value = cats.toList();
  }

  void _loadInitialCombos() {
    combos.value = [
      ComboItem(
        id: 'C1',
        title: 'Tập toàn thân cơ bản',
        subtitle: '5 Bài tập | 15 Phút | 200 Calo',
        image: 'assets/workoutfullbody.png',
      ),
      ComboItem(
        id: 'C2',
        title: 'Đốt mỡ siêu tốc',
        subtitle: '7 Bài tập | 20 Phút | 320 Calo',
        image: 'assets/workoutfullbody.png',
      ),
      ComboItem(
        id: 'C3',
        title: 'Tăng cơ tay & ngực',
        subtitle: '6 Bài tập | 25 Phút | 250 Calo',
        image: 'assets/workoutfullbody.png',
      ),
    ];
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
      bool matchSearch = ex.title.toLowerCase().contains(searchText.value.toLowerCase());
      bool matchCategory = selectedCategory.value == 'Tất cả' || ex.category == selectedCategory.value;
      return matchSearch && matchCategory;
    }).toList();
  }

  void toggleFavorite(ExerciseItem exercise) {
    exercise.isFavorite.value = !exercise.isFavorite.value;
  }

  void toggleComboFavorite(ComboItem combo) {
    combo.isFavorite.value = !combo.isFavorite.value;
  }

  List<ExerciseItem> get favoriteExercises => allExercises.where((ex) => ex.isFavorite.value).toList();
  List<ComboItem> get favoriteCombos => combos.where((cb) => cb.isFavorite.value).toList();
}
