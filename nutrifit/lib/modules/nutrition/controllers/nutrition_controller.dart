import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NutritionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var todayMeals = <Map<String, dynamic>>[].obs;
  var weeklyNutritionData = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  late Box _cacheBox;

  bool get hasMealToday => todayMeals.isNotEmpty;

  double get totalCaloriesIntake {
    double total = 0;
    for (var meal in todayMeals) {
      String calStr = meal['calories']?.toString() ?? '0';
      double val = double.tryParse(calStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
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
  }

  Future<void> _fetchWeeklyNutrition() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    DateTime now = DateTime.now();
    List<double> newData = [0, 0, 0, 0, 0, 0, 0];
    
    double calTarget = 2500;
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('calorieTarget')) {
          calTarget = (data['calorieTarget'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint("Lỗi fetch calorieTarget: $e");
    }

    for (int i = 0; i < 7; i++) {
      DateTime targetDate = now.subtract(Duration(days: i));
      DateTime startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      DateTime endOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);

      try {
        QuerySnapshot snapshot = await _firestore
            .collection('user_intake')
            .where('userId', isEqualTo: uid)
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThanOrEqualTo: endOfDay)
            .get();

        double dailyTotal = 0;
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          dailyTotal += (data['totalCalories'] as num?)?.toDouble() ?? 0.0;
        }
        
        double percentage = (dailyTotal / calTarget) * 100;
        if (percentage > 100) percentage = 100; 
        
        int indexInChart = (targetDate.weekday % 7);
        newData[indexInChart] = percentage;
      } catch (e) {
        debugPrint("Lỗi fetch weekly nutrition: $e");
      }
    }
    weeklyNutritionData.value = newData;
  }

  void _loadFromCache() {
    var cached = _cacheBox.get('today_meals');
    if (cached != null && cached is List) {
      todayMeals.value = cached.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  void fetchTodayMeals() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _firestore
        .collection('user_intake')
        .where('userId', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .listen((snapshot) {
      var newList = snapshot.docs.map((doc) {
        var data = doc.data();
        return {
          'id': doc.id,
          'name': data['foodName'],
          'type': data['mealType'],
          'time': _formatTimestamp(data['timestamp'] as Timestamp),
          'calories': '${data['totalCalories']} kCal',
          'image': data['image_url'] ?? 'assets/salad.png',
          'portionSize': data['portionSize'],
        };
      }).toList();
      
      todayMeals.value = newList;
      _cacheBox.put('today_meals', newList);
    }, onError: (error) {
      debugPrint("--- NutritionController: Lỗi truy vấn Firestore: $error ---");
      if (todayMeals.isEmpty) _loadFromCache();
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> addMeal(String name, String type, {int calories = 0, String? imageUrl, String portionSize = 'Medium', DateTime? customTime}) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('user_intake').add({
      'userId': uid,
      'foodName': name,
      'mealType': type,
      'baseCalories': calories,
      'portionSize': portionSize,
      'totalCalories': _calculateTotal(calories, portionSize),
      'image_url': imageUrl,
      'timestamp': customTime != null ? Timestamp.fromDate(customTime) : FieldValue.serverTimestamp(),
    });
    _fetchWeeklyNutrition();
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

    // Nếu đã truyền calories cuối cùng rồi thì không cần calculate lại nữa
    await _firestore.collection('user_intake').add({
      'userId': uid,
      'foodName': name,
      'mealType': type,
      'baseCalories': calories,
      'portionSize': portionSize,
      'totalCalories': calories,
      'image_url': imagePath,
      'timestamp': customTime != null ? Timestamp.fromDate(customTime) : FieldValue.serverTimestamp(),
    });
    _fetchWeeklyNutrition();
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
  }) async {
    Map<String, dynamic> updates = {
      'foodName': name,
      'mealType': type,
    };
    if (portionSize != null) updates['portionSize'] = portionSize;
    
    await _firestore.collection('user_intake').doc(id).update(updates);
    _fetchWeeklyNutrition();
  }
}
