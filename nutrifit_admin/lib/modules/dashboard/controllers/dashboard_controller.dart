import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      for (var doc in snapshot.docs) {
        var data = doc.data();
        var gender = data['gender']?.toString() ?? 'Khác';
        if (gender == 'Male' || gender == 'Nam') {
          male++;
        } else if (gender == 'Female' || gender == 'Nữ') {
          female++;
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
}
