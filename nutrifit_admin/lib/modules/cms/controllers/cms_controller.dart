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
    _firestore.collection('articles').snapshots().listen((snapshot) {
      final List<ArticleItem> items = [];
      for (var doc in snapshot.docs) {
        try {
          var data = doc.data();
          final ts = data['createdAt'];
          DateTime timestamp;
          if (ts is Timestamp) {
            timestamp = ts.toDate();
          } else if (ts is String) {
            timestamp = DateTime.tryParse(ts) ?? DateTime.now();
          } else {
            timestamp = DateTime.now();
          }
          items.add(ArticleItem(
            id: doc.id,
            title: data['title']?.toString() ?? '',
            content: data['content']?.toString() ?? '',
            image: data['image']?.toString() ?? '',
            category: data['category']?.toString() ?? 'Tips',
            createdAt: timestamp,
          ));
        } catch (e) {
          Get.log("Error: $e");
        }
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      allArticles.value = items;
      isLoading.value = false;
    }, onError: (e) {
      Get.log("Error: $e");
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
