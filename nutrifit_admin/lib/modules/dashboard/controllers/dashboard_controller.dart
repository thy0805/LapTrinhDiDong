import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, StreamSubscription> _activitySubscriptions = {};
  final Map<String, double> _userCaloriesMap = {};

  var totalUsers = 0.obs;
  var totalWorkouts = 0.obs;
  var totalFoods = 0.obs;
  var totalCaloriesBurned = 0.0.obs;
  var userGrowthData = <double>[].obs;
  var genderDistribution = <String, int>{'Nam': 0, 'Nữ': 0}.obs;
  
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToStats();
  }

  void _listenToStats() {
    isLoading.value = true;

    _firestore.collection('users').snapshots().listen((snapshot) {
      totalUsers.value = snapshot.docs.length;
      int male = 0;
      int female = 0;

      final currentUserIds = snapshot.docs.map((doc) => doc.id).toSet();
      _activitySubscriptions.keys
          .where((uid) => !currentUserIds.contains(uid))
          .toList()
          .forEach((uid) {
        _activitySubscriptions[uid]?.cancel();
        _activitySubscriptions.remove(uid);
        _userCaloriesMap.remove(uid);
      });

      for (var doc in snapshot.docs) {
        var data = doc.data();
        var gender = data['gender']?.toString() ?? 'Khác';
        if (gender == 'Male' || gender == 'Nam') {
          male++;
        } else if (gender == 'Female' || gender == 'Nữ') {
          female++;
        }

        final uid = doc.id;
        if (!_activitySubscriptions.containsKey(uid)) {
          _activitySubscriptions[uid] = _firestore
              .collection('users')
              .doc(uid)
              .collection('dailyActivities')
              .snapshots()
              .listen((activitiesSnapshot) {
            double userTotal = 0.0;
            for (var actDoc in activitiesSnapshot.docs) {
              final actData = actDoc.data();
              userTotal += (actData['calories'] as num?)?.toDouble() ?? 0.0;
            }
            _userCaloriesMap[uid] = userTotal;

            double grandTotal = 0.0;
            _userCaloriesMap.forEach((key, val) {
              grandTotal += val;
            });
            totalCaloriesBurned.value = grandTotal;
          });
        }
      }

      genderDistribution.value = {'Nam': male, 'Nữ': female};
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final firstDay = today.subtract(const Duration(days: 6));

      final growth = <double>[];
      for (int i = 0; i < 7; i++) {
        final day = firstDay.add(Duration(days: i));
        final dayEnd = i == 6
            ? now
            : day.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

        int count = 0;
        for (var doc in snapshot.docs) {
          final createdAt = _parseCreatedAt(doc.data()['createdAt']);
          if (createdAt == null || !createdAt.isAfter(dayEnd)) {
            count++;
          }
        }
        growth.add(count.toDouble());
      }
      userGrowthData.value = growth;
      isLoading.value = false;
    }, onError: (e) => Get.log("Lỗi stats users: $e"));

    _firestore.collection('exercises').snapshots().listen((snapshot) {
      totalWorkouts.value = snapshot.docs.length;
    });

    _firestore.collection('foods').snapshots().listen((snapshot) {
      totalFoods.value = snapshot.docs.length;
    });
  }

  void syncData() {
    _listenToStats();
    Get.snackbar('Đồng bộ', 'Dữ liệu Dashboard đang được cập nhật thời gian thực!');
  }

  DateTime? _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  void onClose() {
    for (var sub in _activitySubscriptions.values) {
      sub.cancel();
    }
    _activitySubscriptions.clear();
    super.onClose();
  }
}
