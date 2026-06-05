import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nutrifit/core/services/gamification_service.dart';
import 'package:nutrifit/core/services/sync_service.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';

class FoodItem {
  final String id;
  final String title;
  final int calories;
  final String category;
  final String image;
  final String unit;
  final String createdBy;
  final String protein;
  final String carbs;
  final String fat;
  final String status;
  final RxBool isFavorite;

  FoodItem({
    required this.id,
    required this.title,
    required this.calories,
    required this.category,
    required this.image,
    this.unit = 'Phần',
    this.createdBy = '',
    this.protein = '0',
    this.carbs = '0',
    this.fat = '0',
    this.status = 'approved',
    bool isFav = false,
  }) : isFavorite = isFav.obs;
}

class NutritionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GamificationService _gamification = Get.find<GamificationService>();
  final _syncService = Get.find<SyncService>();

  var todayMeals = <Map<String, dynamic>>[].obs;
  var weeklyNutritionData = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  late Box _cacheBox;

  var searchText = ''.obs;
  var selectedCategory = 'Tất cả'.obs;
  final RxList<FoodItem> allFoods = <FoodItem>[].obs;

  var mealHistory = <Map<String, dynamic>>[].obs;
  var isLoadingHistory = false.obs;
  StreamSubscription? _intakeSubscription;

  bool get hasMealToday => todayMeals.isNotEmpty;

  double get totalCaloriesIntake {
    double total = 0;
    for (var meal in todayMeals) {
      String calStr = meal['calories']?.toString() ?? '0';
      double val =
          double.tryParse(calStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      total += val;
    }
    return total;
  }

  @override
  void onInit() async {
    super.onInit();
    _cacheBox = await Hive.openBox('cached_intake');
    _loadFromCache();
    fetchTodayMeals();
    _fetchWeeklyNutrition();
    fetchFoods();
    fetchMealHistory();
  }

  void fetchMealHistory() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    isLoadingHistory.value = true;
    _intakeSubscription?.cancel();
    _intakeSubscription = _firestore
        .collection('user_intake')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            var list = snapshot.docs.map((doc) {
              var data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();

            list.sort((a, b) {
              Timestamp? tA = a['timestamp'] as Timestamp?;
              Timestamp? tB = b['timestamp'] as Timestamp?;
              if (tA == null && tB == null) return 0;
              if (tA == null) return 1;
              if (tB == null) return -1;
              return tB.compareTo(tA);
            });

            mealHistory.value = list;
            isLoadingHistory.value = false;
          },
          onError: (error) {
            debugPrint("Loi fetchMealHistory: $error");
            isLoadingHistory.value = false;
          },
        );
  }

  @override
  void onClose() {
    _intakeSubscription?.cancel();
    super.onClose();
  }

  void fetchFoods() {
    final cachedFoods = _syncService.getAllCachedFoods();
    if (cachedFoods.isNotEmpty) {
      allFoods.value = cachedFoods.map((data) {
        String id = data['id'] ?? '';
        return _mapDataToFood(id, data);
      }).toList();
    }

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
      unit: data['unit'] ?? 'Phần',
      createdBy: data['createdBy'] ?? '',
      protein: data['protein']?.toString() ?? '0',
      carbs: data['carbs']?.toString() ?? '0',
      fat: data['fat']?.toString() ?? '0',
      status: data['status'] ?? 'approved',
    );
  }

  List<FoodItem> get filteredFoods {
    String? myEmail = _auth.currentUser?.email;
    return allFoods.where((food) {
      bool isAuthorized =
          food.status == 'approved' ||
          (food.status == 'pending' && food.createdBy == myEmail);
      if (!isAuthorized) return false;

      bool matchesSearch = food.title.toLowerCase().contains(
        searchText.value.toLowerCase(),
      );
      bool matchesCategory =
          selectedCategory.value == 'Tất cả' ||
          food.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<FoodItem> get favoriteFoods {
    String? myEmail = _auth.currentUser?.email;
    return allFoods.where((food) {
      bool isAuthorized =
          food.status == 'approved' ||
          (food.status == 'pending' && food.createdBy == myEmail);
      return food.isFavorite.value && isAuthorized;
    }).toList();
  }

  List<String> get availableUnits {
    Set<String> units = {'Gram', 'Phần', 'Chai', 'Lon', 'Chén', 'Bát', 'Đĩa'};
    for (var food in allFoods) {
      if (food.unit.isNotEmpty) {
        units.add(food.unit);
      }
    }
    return units.toList();
  }

  Future<String?> _uploadToCloudinary(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dhhhclbra/image/upload'),
      );
      request.fields['upload_preset'] = 'ml_default';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['secure_url'];
      }
    } catch (e) {
      debugPrint("Lỗi upload Cloudinary: $e");
    }
    return null;
  }

  Future<bool> contributeFood({
    required String name,
    required int calories,
    required String category,
    required String unit,
    String protein = '0',
    String carbs = '0',
    String fat = '0',
    String? localImagePath,
  }) async {
    try {
      String? myEmail = _auth.currentUser?.email;
      if (myEmail == null) return false;

      String imageUrl = '';
      if (localImagePath != null && localImagePath.isNotEmpty) {
        String? uploaded = await _uploadToCloudinary(localImagePath);
        if (uploaded != null) imageUrl = uploaded;
      }

      await _firestore.collection('foods').add({
        'name': name,
        'base_calories': calories,
        'category': category,
        'unit': unit,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'image_url': imageUrl,
        'status': 'pending',
        'createdBy': myEmail,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("Lỗi đóng góp món ăn: $e");
      return false;
    }
  }

  void setSearchText(String text) => searchText.value = text;

  void setCategory(String cat) => selectedCategory.value = cat;

  void toggleFavorite(FoodItem food) {
    food.isFavorite.value = !food.isFavorite.value;
  }

  Future<void> _fetchWeeklyNutrition() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    List<double> newData = [0, 0, 0, 0, 0, 0, 0];

    double calTarget = 2500;
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('calorieTarget')) {
          calTarget = (data['calorieTarget'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint("Lỗi fetch calorieTarget: $e");
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('user_intake')
          .where('userId', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
          .get();

      Map<int, double> dailyTotals = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime date = ((data['timestamp'] as Timestamp?) ?? Timestamp.now())
            .toDate();
        int dayIndex = date.weekday % 7;
        double calories = (data['totalCalories'] as num?)?.toDouble() ?? 0.0;
        dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0.0) + calories;
      }

      for (int i = 0; i < 7; i++) {
        double total = dailyTotals[i] ?? 0.0;
        double percentage = (total / calTarget) * 100;
        if (percentage > 100) percentage = 100;
        newData[i] = percentage;
      }
    } catch (e) {
      debugPrint("Lỗi fetch weekly nutrition: $e");
    }

    weeklyNutritionData.value = newData;
  }

  void _loadFromCache() {
    var cached = _cacheBox.get('today_meals');
    if (cached != null && cached is List) {
      todayMeals.value = cached
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  void fetchTodayMeals() {
    fetchMealsByDate(DateTime.now());
  }

  void fetchMealsByDate(DateTime date) {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    _firestore
        .collection('user_intake')
        .where('userId', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .listen(
          (snapshot) {
            var newList = snapshot.docs.map((doc) {
              var data = doc.data();
              return {
                'id': doc.id,
                'name': data['foodName'],
                'type': data['mealType'],
                'time': _formatTimestamp(
                  (data['timestamp'] as Timestamp?) ?? Timestamp.now(),
                ),
                'calories': '${data['totalCalories']} kCal',
                'image': data['image_url'] ?? '',
                'portionSize': data['portionSize'],
                'description': data['description'] ?? '',
              };
            }).toList();

            todayMeals.value = newList;
            DateTime now = DateTime.now();
            if (date.year == now.year &&
                date.month == now.month &&
                date.day == now.day) {
              _cacheBox.put('today_meals', newList);
            }
          },
          onError: (error) {
            debugPrint(
              "--- NutritionController: Lỗi truy vấn Firestore: $error ---",
            );
          },
        );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  DateTime _getAutoTimeForMealType(String type, DateTime? customTime) {
    if (customTime != null) return customTime;
    DateTime now = DateTime.now();
    int hour = 7;
    try {
      if (type == 'Bữa sáng') {
        hour = 6 + (DateTime.now().millisecondsSinceEpoch % 5);
      } else if (type == 'Bữa trưa') {
        hour = 11 + (DateTime.now().millisecondsSinceEpoch % 5);
      } else if (type == 'Bữa tối' || type == 'Bữa chiều') {
        hour = 16 + (DateTime.now().millisecondsSinceEpoch % 4);
      } else if (type == 'Bữa nhẹ') {
        int soSnacks = todayMeals.where((m) => m['type'] == 'Bữa nhẹ').length;
        if (soSnacks == 0) {
          hour = 9;
        } else if (soSnacks == 1) {
          hour = 14;
        } else if (soSnacks == 2) {
          hour = 17;
        } else {
          hour = 21;
        }
      }
    } catch (_) {}

    return DateTime(now.year, now.month, now.day, hour, 0);
  }

  void _addMealToLocalList(
    String name,
    String type,
    double totalCalories,
    String? imageUrl,
    String portionSize,
    DateTime mealTime,
  ) {
    var mealMap = {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'type': type,
      'time': '${mealTime.hour}:${mealTime.minute.toString().padLeft(2, '0')}',
      'calories': '$totalCalories kCal',
      'image': imageUrl ?? '',
      'portionSize': portionSize,
      'description': '',
    };
    todayMeals.add(mealMap);
    _cacheBox.put('today_meals', todayMeals.toList());
  }

  Future<void> addMeal(
    String name,
    String type, {
    int calories = 0,
    String? imageUrl,
    String portionSize = 'Medium',
    DateTime? customTime,
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    DateTime mealTime = _getAutoTimeForMealType(type, customTime);
    double totalCalories = _calculateTotal(calories, portionSize);

    bool online = await _syncService.hasInternet();
    if (online) {
      await _firestore.collection('user_intake').add({
        'userId': uid,
        'foodName': name,
        'mealType': type,
        'baseCalories': calories,
        'portionSize': portionSize,
        'totalCalories': totalCalories,
        'image_url': imageUrl,
        'timestamp': Timestamp.fromDate(mealTime),
      });
    } else {
      await _syncService.addPendingLog('meal', {
        'userId': uid,
        'foodName': name,
        'mealType': type,
        'baseCalories': calories,
        'portionSize': portionSize,
        'totalCalories': totalCalories,
        'image_url': imageUrl,
        'timestamp': mealTime.millisecondsSinceEpoch,
      });
      _addMealToLocalList(
        name,
        type,
        totalCalories,
        imageUrl,
        portionSize,
        mealTime,
      );
    }
    _fetchWeeklyNutrition();
    _checkNutritionMilestones();
  }

  double _calculateTotal(int base, String size) {
    if (size == 'Small') return base * 0.8;
    if (size == 'Large') return base * 1.2;
    return base.toDouble();
  }

  Future<void> addMealWithCalories(
    String name,
    String type,
    int calories, {
    String? imagePath,
    String portionSize = 'Medium',
    DateTime? customTime,
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    DateTime mealTime = _getAutoTimeForMealType(type, customTime);

    bool online = await _syncService.hasInternet();
    if (online) {
      await _firestore.collection('user_intake').add({
        'userId': uid,
        'foodName': name,
        'mealType': type,
        'baseCalories': calories,
        'portionSize': portionSize,
        'totalCalories': calories,
        'image_url': imagePath,
        'timestamp': Timestamp.fromDate(mealTime),
      });
    } else {
      await _syncService.addPendingLog('meal', {
        'userId': uid,
        'foodName': name,
        'mealType': type,
        'baseCalories': calories,
        'portionSize': portionSize,
        'totalCalories': calories.toDouble(),
        'image_url': imagePath,
        'timestamp': mealTime.millisecondsSinceEpoch,
      });
      _addMealToLocalList(
        name,
        type,
        calories.toDouble(),
        imagePath,
        portionSize,
        mealTime,
      );
    }
    _fetchWeeklyNutrition();
    _checkNutritionMilestones();
  }

  Future<void> _checkNutritionMilestones() async {
    double target =
        (Get.find<AuthController>().userData['calorieTarget'] as num?)
            ?.toDouble() ??
        2500.0;
    _gamification.checkNutritionMilestones(
      todayMeals.length,
      totalCaloriesIntake,
      target,
    );

    await _gamification.checkNutritionBinge(todayMeals.length);
    final activityCtrl = Get.find<ActivityController>();
    final double waterIntake = activityCtrl.water.value;
    await _gamification.checkForgetfulness(todayMeals.length, waterIntake);

    int veggieCount = 0;
    for (var meal in todayMeals) {
      String desc = meal['description']?.toString().toLowerCase() ?? '';
      if (desc.contains('rau') ||
          desc.contains('healthy') ||
          desc.contains('trái cây')) {
        veggieCount++;
      }
    }
    int totalVeggie =
        (Get.find<AuthController>().userData['totalVeggieMeals'] ?? 0) +
        veggieCount;
    _gamification.checkLifetimeAchievements(veggieMeals: totalVeggie);
  }

  Future<void> removeMeal(String id) async {
    await _firestore.collection('user_intake').doc(id).delete();
    _fetchWeeklyNutrition();
  }

  Future<void> updateMeal({
    required String id,
    required String name,
    required String type,
    String? portionSize,
    DateTime? customTime,
  }) async {
    Map<String, dynamic> updates = {'foodName': name, 'mealType': type};
    if (portionSize != null) updates['portionSize'] = portionSize;
    if (customTime != null) {
      updates['timestamp'] = Timestamp.fromDate(customTime);
    }

    await _firestore.collection('user_intake').doc(id).update(updates);
    _fetchWeeklyNutrition();
  }
}
