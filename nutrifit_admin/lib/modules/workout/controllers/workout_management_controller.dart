import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nutrifit_admin/core/models/workout_model.dart';
import 'dart:async';

class WorkoutManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var allExercises = <ExerciseItem>[].obs;
  var isLoading = true.obs;
  var searchText = ''.obs;
  var selectedCategory = 'All'.obs;
  var availableCategories = <String>['All'].obs;

  final Map<String, Map<String, String>> _interfaceTranslations = {
    'en': {
      'title': 'Workout Management',
      'subtitle': 'Comprehensive exercise system for NutriFit users.',
      'add_btn': 'Add Exercise',
      'search_hint': 'Search exercise name...',
      'table_title': 'Exercise List',
      'col_img': 'IMAGE',
      'col_name': 'EXERCISE NAME',
      'col_diff': 'DIFFICULTY',
      'col_cal': 'CAL/MIN',
      'col_cat': 'CATEGORY',
      'col_act': 'ACTIONS',
      'page': 'Page',
    },
    'vi': {
      'title': 'Quản lý Bài tập',
      'subtitle': 'Hệ thống bài tập chuyên sâu cho người dùng NutriFit.',
      'add_btn': 'Thêm bài tập',
      'search_hint': 'Tìm kiếm tên bài tập...',
      'table_title': 'Danh sách bài tập',
      'col_img': 'ẢNH',
      'col_name': 'TÊN BÀI TẬP',
      'col_diff': 'ĐỘ KHÓ',
      'col_cal': 'CALO/PHÚT',
      'col_cat': 'DANH MỤC',
      'col_act': 'THAO TÁC',
      'page': 'Trang',
    }
  };

  String translate(String key) => _interfaceTranslations[currentLanguage.value]?[key] ?? key;

  var currentLanguage = 'en'.obs;
  
  StreamSubscription? _exerciseSubscription;
  
  var currentPage = 1.obs;
  var itemsPerPage = 20;

  @override
  void onInit() {
    super.onInit();
    fetchExercises();
  }

  void changeLanguage(String lang) {
    if (currentLanguage.value == lang) return;
    currentLanguage.value = lang;
    
    String allLabel = lang == 'vi' ? 'Tất cả' : 'All';
    availableCategories.value = [allLabel];
    selectedCategory.value = allLabel;
    
    currentPage.value = 1;
    fetchExercises();
  }


  void fetchExercises() {
    isLoading.value = true;
    _exerciseSubscription?.cancel();
    
    String collectionName = currentLanguage.value == 'vi' ? 'exercises_vi' : 'exercises';
    
    _exerciseSubscription = _firestore.collection(collectionName).snapshots().listen((snapshot) {
      allExercises.value = snapshot.docs.map((doc) {
        var data = doc.data();
        
        String title = data['name'] ?? data['title'] ?? data['displayName'] ?? (currentLanguage.value == 'vi' ? 'Chưa có tên' : 'No Name');
        String image = data['gifUrl'] ?? data['gif_url'] ?? data['url'] ?? data['image'] ?? data['image_url'] ?? '';

        
        String category = '';
        if (data['bodyParts'] != null && data['bodyParts'] is List && data['bodyParts'].isNotEmpty) {
          category = data['bodyParts'][0];
        } else {
          category = data['category'] ?? (currentLanguage.value == 'vi' ? 'Khác' : 'Other');
        }

        String description = data['description'] ?? '';
        if (description.isEmpty && data['instructions'] != null) {
          if (data['instructions'] is List) {
            description = (data['instructions'] as List).join('\n');
          } else {
            description = data['instructions'].toString();
          }
        }

        return ExerciseItem(
          id: doc.id,
          title: title,
          difficulty: data['difficulty'] ?? (currentLanguage.value == 'vi' ? 'Dễ' : 'Easy'),
          calories: data['calories'] ?? 0,
          description: description,
          category: category,
          image: image,
          instructions: data['instructions'] is List ? List<String>.from(data['instructions']) : [],
        );
      }).toList();
      
      String allLabel = currentLanguage.value == 'vi' ? 'Tất cả' : 'All';
      Set<String> cats = {allLabel};
      for (var ex in allExercises) {
        if (ex.category.isNotEmpty) cats.add(ex.category);
      }
      availableCategories.value = cats.toList();
      
      isLoading.value = false;
    });
  }

  List<ExerciseItem> get filteredExercises {
    String allLabel = currentLanguage.value == 'vi' ? 'Tất cả' : 'All';
    return allExercises.where((ex) {
      bool matchesSearch = ex.title.toLowerCase().contains(searchText.value.toLowerCase());
      bool matchesCategory = selectedCategory.value == allLabel || ex.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get totalPages => (filteredExercises.length / itemsPerPage).ceil();

  List<ExerciseItem> get paginatedExercises {
    int start = (currentPage.value - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    var filtered = filteredExercises;
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  void nextPage() {
    if (currentPage.value < totalPages) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  void setSearchText(String text) {
    searchText.value = text;
    currentPage.value = 1; 
  }
  
  void setCategory(String cat) {
    selectedCategory.value = cat;
    currentPage.value = 1; 
  }

  Future<void> deleteExercise(String id) async {
    try {
      String collectionName = currentLanguage.value == 'vi' ? 'exercises_vi' : 'exercises';
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa bài tập: $e');
    }
  }

  Future<void> addExercise(ExerciseItem ex) async {
    try {
      String collectionName = currentLanguage.value == 'vi' ? 'exercises_vi' : 'exercises';
      
      // Chuyen description thanh list instructions
      List<String> instList = ex.description.split('\n').where((s) => s.trim().isNotEmpty).toList();

      await _firestore.collection(collectionName).add({
        'name': ex.title,
        'difficulty': ex.difficulty,
        'calories': ex.calories,
        'description': ex.description,
        'instructions': instList,
        'bodyParts': [ex.category],
        'gifUrl': ex.image,
        'updated_at': FieldValue.serverTimestamp(),
      });
      Get.back();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm bài tập: $e');
    }
  }

  Future<void> updateExercise(String id, ExerciseItem ex) async {
    try {
      String collectionName = currentLanguage.value == 'vi' ? 'exercises_vi' : 'exercises';
      
      // Chuyen description thanh list instructions
      List<String> instList = ex.description.split('\n').where((s) => s.trim().isNotEmpty).toList();

      await _firestore.collection(collectionName).doc(id).update({
        'name': ex.title,
        'difficulty': ex.difficulty,
        'calories': ex.calories,
        'description': ex.description,
        'instructions': instList,
        'bodyParts': [ex.category],
        'gifUrl': ex.image,
        'updated_at': FieldValue.serverTimestamp(),
      });
      Get.back();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật bài tập: $e');
    }
  }
}
