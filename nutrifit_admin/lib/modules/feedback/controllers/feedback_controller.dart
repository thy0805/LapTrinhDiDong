import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FeedbackItem {
  final String id;
  final String userEmail;
  final String message;
  final String type;
  final String status;
  final DateTime createdAt;

  FeedbackItem({
    required this.id,
    required this.userEmail,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
  });
}

class FeedbackController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var feedbacks = <FeedbackItem>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeedbacks();
  }

  void fetchFeedbacks() {
    isLoading.value = true;
    _firestore.collection('feedbacks').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      feedbacks.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return FeedbackItem(
          id: doc.id,
          userEmail: data['userEmail'] ?? 'Ẩn danh',
          message: data['message'] ?? '',
          type: data['type'] ?? 'Lỗi',
          status: data['status'] ?? 'pending',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      isLoading.value = false;
    });
  }

  Future<void> resolveFeedback(String id) async {
    try {
      await _firestore.collection('feedbacks').doc(id).update({'status': 'resolved'});
      Get.snackbar('Thành công', 'Đã đánh dấu xử lý phản hồi');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xử lý: $e');
    }
  }

  Future<void> deleteFeedback(String id) async {
    try {
      await _firestore.collection('feedbacks').doc(id).delete();
      Get.snackbar('Thành công', 'Đã xóa phản hồi');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa: $e');
    }
  }
}
