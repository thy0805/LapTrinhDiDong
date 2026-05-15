import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:nutrifit_admin/core/models/article_model.dart';

class CMSController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var allArticles = <ArticleItem>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  void fetchArticles() {
    isLoading.value = true;
    _firestore.collection('articles').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      allArticles.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return ArticleItem(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          image: data['image'] ?? '',
          category: data['category'] ?? 'Tips',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      isLoading.value = false;
    });
  }

  Future<void> addArticle(ArticleItem article) async {
    try {
      await _firestore.collection('articles').add({
        'title': article.title,
        'content': article.content,
        'image': article.image,
        'category': article.category,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.back();
      Get.snackbar('Thành công', 'Đã đăng bài viết mới');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đăng bài: $e');
    }
  }

  Future<void> updateArticle(String id, ArticleItem article) async {
    try {
      await _firestore.collection('articles').doc(id).update({
        'title': article.title,
        'content': article.content,
        'image': article.image,
        'category': article.category,
      });
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật bài viết');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật bài: $e');
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      await _firestore.collection('articles').doc(id).delete();
      Get.snackbar('Thành công', 'Đã xóa bài viết');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa bài: $e');
    }
  }
}
