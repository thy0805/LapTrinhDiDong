import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nutrifit/core/services/sync_service.dart';

class FoodItem {
  final String id;
  final String title;
  final int calories;
  final String category;
  final String image;
  final RxBool isFavorite;

  FoodItem({
    required this.id,
    required this.title,
    required this.calories,
    required this.category,
    required this.image,
    bool isFav = false,
  }) : isFavorite = isFav.obs;
}

class FoodController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _syncService = Get.find<SyncService>();
  
  var searchText = ''.obs;
  var selectedCategory = 'Tất cả'.obs;

  // Danh sách món ăn từ Firestore
  final RxList<FoodItem> allFoods = <FoodItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFoods();
  }

  void fetchFoods() {
    // Ưu tiên lấy từ Hive trước nhen Thy
    final cachedFoods = _syncService.getAllCachedFoods();
    if (cachedFoods.isNotEmpty) {
      allFoods.value = cachedFoods.map((data) {
        // DocId thường được lưu trong data hoặc lấy từ key
        String id = data['id'] ?? ''; 
        return _mapDataToFood(id, data);
      }).toList();
    }

    // Vẫn lắng nghe Firestore để cập nhật nếu có thay đổi (Realtime)
    _firestore.collection('foods').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        allFoods.value = snapshot.docs.map((doc) {
          var data = doc.data();
          return _mapDataToFood(doc.id, data);
        }).toList();
      }
    });
  }

  FoodItem _mapDataToFood(String id, Map<String, dynamic> data) {
    return FoodItem(
      id: id,
      title: data['name'] ?? '',
      calories: data['base_calories'] ?? 0,
      category: data['category'] ?? 'Khác',
      image: data['image_url'] ?? '',
    );
  }

  List<FoodItem> get filteredFoods {
    return allFoods.where((food) {
      bool matchesSearch = food.title.toLowerCase().contains(searchText.value.toLowerCase());
      bool matchesCategory = selectedCategory.value == 'Tất cả' || food.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<FoodItem> get favoriteFoods {
    return allFoods.where((food) => food.isFavorite.value).toList();
  }

  void setSearchText(String text) => searchText.value = text;
  
  void setCategory(String cat) => selectedCategory.value = cat;

  void toggleFavorite(FoodItem food) {
    food.isFavorite.value = !food.isFavorite.value;
    // Có thể thêm logic lưu trạng thái yêu thích lên Firestore ở đây nếu Thy muốn
  }
}

