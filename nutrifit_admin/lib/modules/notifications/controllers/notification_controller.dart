import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var titleController = ''.obs;
  var bodyController = ''.obs;
  var selectedSegment = 'Tất cả'.obs;
  var isLoading = false.obs;

  Future<void> sendNotification() async {
    if (titleController.value.isEmpty || bodyController.value.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ tiêu đề và nội dung');
      return;
    }

    isLoading.value = true;
    try {
      // Logic gửi thông báo qua FCM sẽ được thực hiện ở Backend (Cloud Functions)
      // Ở đây ta ghi vào Firestore 'notifications' để trigger function
      await _firestore.collection('notifications').add({
        'title': titleController.value,
        'body': bodyController.value,
        'segment': selectedSegment.value,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Thành công', 'Thông báo đã được đưa vào hàng chờ gửi!');
      titleController.value = '';
      bodyController.value = '';
      isLoading.value = false;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi thông báo: $e');
      isLoading.value = false;
    }
  }
}
