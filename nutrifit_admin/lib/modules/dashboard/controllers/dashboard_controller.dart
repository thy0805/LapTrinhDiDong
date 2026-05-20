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
      userGrowthData.value = [120, 150, 180, 220, 250, 310, totalUsers.value.toDouble()];
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

  @override
  void onClose() {
    for (var sub in _activitySubscriptions.values) {
      sub.cancel();
    }
    _activitySubscriptions.clear();
    super.onClose();
  }
}
