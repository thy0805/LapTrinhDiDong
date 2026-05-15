import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var users = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var searchText = ''.obs;
  var selectedTag = 'Tất cả'.obs;
  
  var currentPage = 1.obs;
  var itemsPerPage = 10;
  
  StreamSubscription? _usersSubscription;

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((user) {
      final String name = (user['fullName'] ?? user['displayName'] ?? '').toString().toLowerCase();
      final String email = (user['email'] ?? '').toString().toLowerCase();
      final String search = searchText.value.toLowerCase();
      
      final matchesSearch = name.contains(search) || email.contains(search);

      final List<dynamic> rawTags = user['tags'] ?? [];
      final tags = rawTags.map((e) => e.toString()).toList();
      final matchesTag = selectedTag.value == 'Tất cả' || tags.contains(selectedTag.value);

      return matchesSearch && matchesTag;
    }).toList();
  }

  int get totalPages {
    int len = filteredUsers.length;
    if (len == 0) return 1;
    return (len / itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> get paginatedUsers {
    var filtered = filteredUsers;
    int start = (currentPage.value - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    
    if (start < 0) start = 0;
    if (start >= filtered.length) return [];
    
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  @override
  void onClose() {
    _usersSubscription?.cancel();
    super.onClose();
  }

  void fetchUsers() {
    isLoading.value = true;
    _usersSubscription?.cancel();
    
    _usersSubscription = _firestore.collection('users').snapshots().listen((snapshot) {
      try {
        users.value = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;

          double weight = 0;
          if (data['weight'] != null) {
            weight = (data['weight'] is num) 
                ? (data['weight'] as num).toDouble() 
                : (double.tryParse(data['weight'].toString()) ?? 0);
          }

          double height = 0;
          if (data['height'] != null) {
            double rawHeight = (data['height'] is num) 
                ? (data['height'] as num).toDouble() 
                : (double.tryParse(data['height'].toString()) ?? 0);
            height = rawHeight / 100;
          }

          double bmi = (height > 0) ? weight / (height * height) : 0;

          List<String> tags = [];
          if (bmi > 25) tags.add('Thừa cân');
          if (bmi < 18.5 && bmi > 0) tags.add('Thiếu cân');
          if (bmi >= 18.5 && bmi <= 25) tags.add('Cân đối');

          int streak = 0;
          if (data['streak'] != null) {
            streak = (data['streak'] is num) ? (data['streak'] as num).toInt() : (int.tryParse(data['streak'].toString()) ?? 0);
          }
          
          if (streak > 7) tags.add('Chăm chỉ');
          if (streak == 0) tags.add('Bỏ cuộc');

          data['bmi'] = bmi.toStringAsFixed(1);
          data['tags'] = tags;
          data['status'] = data['status'] ?? 'Active';

          return data;
        }).toList();
        isLoading.value = false;
      } catch (e) {
        isLoading.value = false;
      }
    }, onError: (error) {
      isLoading.value = false;
    });
  }

  Future<void> toggleSuspendUser(String uid, String currentStatus) async {
    try {
      String newStatus = currentStatus == 'Active' ? 'Suspended' : 'Active';
      await _firestore.collection('users').doc(uid).update({
        'status': newStatus,
      });
      Get.snackbar('Thành công', 'Đã chuyển trạng thái user sang $newStatus');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái: $e');
    }
  }

  Future<void> updateUserGoals(String uid, Map<String, dynamic> goals) async {
    try {
      await _firestore.collection('users').doc(uid).update({'targets': goals});
      Get.snackbar('Thành công', 'Đã thiết lập lộ trình mới cho User');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật mục tiêu: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      Get.snackbar('Thành công', 'Đã xóa người dùng khỏi hệ thống');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa người dùng: $e');
    }
  }

  void setPage(int page) {
    currentPage.value = page;
  }
}

