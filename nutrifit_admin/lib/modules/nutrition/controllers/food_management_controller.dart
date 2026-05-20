import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nutrifit_admin/core/models/food_item.dart';

class FoodManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var allFoods = <FoodItem>[].obs;
  var isLoading = true.obs;
  var searchText = ''.obs;
  var selectedCategory = 'Tất cả'.obs;
  var activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFoods();
  }

  void fetchFoods() {
    isLoading.value = true;
    _firestore.collection('foods').snapshots().listen((snapshot) {
      allFoods.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return FoodItem(
          id: doc.id,
          title: data['name'] ?? '',
          calories: (data['base_calories'] ?? 0).toString(),
          category: data['category'] ?? '',
          image: data['image_url'] ?? '',
          protein: data['protein']?.toString() ?? '0',
          carbs: data['carbs']?.toString() ?? '0',
          fat: data['fat']?.toString() ?? '0',
          status: data['status'] ?? 'approved',
          unit: data['unit'] ?? 'Phần',
          createdBy: data['createdBy'] ?? '',
        );
      }).toList();
      isLoading.value = false;
    });
  }

  List<FoodItem> get filteredFoods {
    return allFoods.where((food) {
      bool matchesSearch = food.title.toLowerCase().contains(searchText.value.toLowerCase());
      bool matchesCategory = selectedCategory.value == 'Tất cả' || food.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<FoodItem> get pendingFoods => allFoods.where((f) => f.status == 'pending').toList();
  List<FoodItem> get approvedFoods => allFoods.where((f) => f.status == 'approved').toList();

  void setSearchText(String text) => searchText.value = text;
  void setCategory(String cat) => selectedCategory.value = cat;

  Future<void> approveFood(String id) async {
    try {
      await _firestore.collection('foods').doc(id).update({
        'status': 'approved',
        'updated_at': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Thành công', 'Đã duyệt món ăn');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể duyệt món ăn: $e');
    }
  }

  Future<void> deleteFood(String id) async {
    try {
      await _firestore.collection('foods').doc(id).delete();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa món ăn: $e');
    }
  }

  Future<void> addFood(FoodItem food) async {
    try {
      await _firestore.collection('foods').add({
        'name': food.title,
        'base_calories': int.tryParse(food.calories) ?? 0,
        'category': food.category,
        'image_url': food.image,
        'protein': food.protein,
        'carbs': food.carbs,
        'fat': food.fat,
        'status': 'approved',
        'unit': food.unit,
        'createdBy': food.createdBy,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      Get.back();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm món ăn: $e');
    }
  }

  Future<void> updateFood(String id, FoodItem food) async {
    try {
      await _firestore.collection('foods').doc(id).update({
        'name': food.title,
        'base_calories': int.tryParse(food.calories) ?? 0,
        'category': food.category,
        'image_url': food.image,
        'protein': food.protein,
        'carbs': food.carbs,
        'fat': food.fat,
        'status': food.status,
        'unit': food.unit,
        'createdBy': food.createdBy,
        'updated_at': FieldValue.serverTimestamp(),
      });
      Get.back();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật món ăn: $e');
    }
  }
}
