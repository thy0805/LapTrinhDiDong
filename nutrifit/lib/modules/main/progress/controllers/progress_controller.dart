import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../profile/controllers/profile_controller.dart';
import '../views/ghost_camera_screen.dart';

class ProgressController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var progressPhotos = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  
  var lastPhotoUrl = ''.obs;
  var userExp = 0.obs;

  var beforePhoto = Rxn<Map<String, dynamic>>();
  var afterPhoto = Rxn<Map<String, dynamic>>();
  var hasReceivedComparisonBadge = false.obs;

  // Giai đoạn 3: Dữ liệu cho Biểu đồ
  var weightHistory = <Map<String, dynamic>>[].obs; 
  var targetWeight = 65.0.obs; 
  var hasReachedTargetBadge = false.obs;

  // Giai đoạn 4: Controller chụp màn hình
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchProgressPhotos();
    fetchWeightHistory();
  }

  void fetchUserData() async {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        userExp.value = data['exp'] ?? 0;
      }
    }
  }

  void fetchProgressPhotos() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      firestore
          .collection('users')
          .doc(uid)
          .collection('progress_photos')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          progressPhotos.value = [];
          lastPhotoUrl.value = '';
        } else {
          progressPhotos.value = snapshot.docs.map((doc) {
            var data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          if (progressPhotos.isNotEmpty) {
            lastPhotoUrl.value = progressPhotos.first['imageUrl'] ?? '';
          } else {
            lastPhotoUrl.value = '';
          }
        }
      });
    }
  }

  void fetchWeightHistory() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      firestore
          .collection('users')
          .doc(uid)
          .collection('weight_history')
          .orderBy('date', descending: false)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          weightHistory.value = [];
        } else {
          weightHistory.value = snapshot.docs.map((doc) => doc.data()).toList();
        }
        _checkTargetWeightGamification();
      });
    }
  }

  List<FlSpot> get chartSpots {
    if (weightHistory.isEmpty) return [const FlSpot(0, 0)];
    
    List<FlSpot> spots = [];
    for (int i = 0; i < weightHistory.length; i++) {
      double weight = double.tryParse(weightHistory[i]['weight'].toString()) ?? 0.0;
      spots.add(FlSpot(i.toDouble(), weight));
    }
    return spots;
  }

  void _checkTargetWeightGamification() {
    if (weightHistory.isEmpty || hasReachedTargetBadge.value) return;

    double latestWeight = double.tryParse(weightHistory.last['weight'].toString()) ?? 0.0;
    
    if (latestWeight <= targetWeight.value && latestWeight > 0) {
      hasReachedTargetBadge.value = true;
      _addGamificationExp(200, 'Bạn đã đạt được Mục Tiêu Cân Nặng!');
      Get.snackbar(
        '🏆 Kẻ Chinh Phục', 
        'Chúc mừng bạn đã hoàn thành xuất sắc mục tiêu đề ra!', 
        backgroundColor: Colors.yellow[700],
        colorText: Colors.white,
        duration: const Duration(seconds: 5)
      );
    }
  }

  Future<void> _addGamificationExp(int expToAdd, String message) async {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      userExp.value += expToAdd;
      await firestore.collection('users').doc(uid).set({'exp': FieldValue.increment(expToAdd)}, SetOptions(merge: true));
      Get.snackbar('🎮 +$expToAdd EXP', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      
      if (progressPhotos.length == 4) {
        Get.snackbar('🏆 Huy Hiệu Mới', 'Mở khóa: Kỷ luật thép!', duration: const Duration(seconds: 4), backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      }
    }
  }

  Future<void> addProgressPhoto() async {
    final ImagePicker picker = ImagePicker();
    
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Thêm ảnh tiến độ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFC050F6)),
              title: const Text('Chụp ảnh với Bóng Ma (Ghosting)', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFC050F6)),
              title: const Text('Chọn từ thư viện', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == ImageSource.camera) {
       Get.to(() => const GhostCameraScreen());
       return; 
    }

    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      await uploadAndSavePhoto(image.path);
    }
  }

  Future<void> uploadAndSavePhoto(String imagePath) async {
      isLoading.value = true;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFFC050F6))),
        barrierDismissible: false,
      );

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/dhhhclbra/image/upload'),
        );
        request.fields['upload_preset'] = 'ml_default';
        request.files.add(await http.MultipartFile.fromPath('file', imagePath));

        var response = await request.send();
        Get.back(); 

        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonResult = json.decode(responseData);
          String secureUrl = jsonResult['secure_url'];

          String? uid = auth.currentUser?.uid;
          if (uid != null) {
            String currentWeightStr = '';
            if (Get.isRegistered<ProfileController>()) {
              currentWeightStr = Get.find<ProfileController>().weight.value;
            }

            await firestore
                .collection('users')
                .doc(uid)
                .collection('progress_photos')
                .add({
              'imageUrl': secureUrl,
              'weightAtTime': currentWeightStr,
              'createdAt': FieldValue.serverTimestamp(),
            });

            await firestore.collection('users').doc(uid).collection('weight_history').add({
              'weight': currentWeightStr,
              'date': FieldValue.serverTimestamp(),
            });

            await _addGamificationExp(10, 'Đã cập nhật ảnh tiến độ mới!');
          }
        }
      } catch (e) {
        Get.back();
        Get.snackbar("Lỗi", "Không thể tải ảnh lên", backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
  }

  // --- COMPARISON LOGIC ---
  void selectPhotoForComparison(Map<String, dynamic> photoData, bool isBefore) {
    if (isBefore) {
      beforePhoto.value = photoData;
    } else {
      afterPhoto.value = photoData;
    }
    _checkComparisonGamification();
  }

  String get weightDifferenceText {
    if (beforePhoto.value == null || afterPhoto.value == null) return "0 kg";
    
    double weightBefore = double.tryParse(beforePhoto.value!['weightAtTime'].toString()) ?? 0;
    double weightAfter = double.tryParse(afterPhoto.value!['weightAtTime'].toString()) ?? 0;
    double diff = weightAfter - weightBefore;
    
    if (diff == 0) return "Không đổi";
    if (diff < 0) return "Giảm ${diff.abs().toStringAsFixed(1)} kg \n🔥";
    return "Tăng ${diff.toStringAsFixed(1)} kg \n💪"; 
  }

  String get timeDifferenceText {
    if (beforePhoto.value == null || afterPhoto.value == null) return "0 ngày";
    
    Timestamp? timeBefore = beforePhoto.value!['createdAt'] as Timestamp?;
    Timestamp? timeAfter = afterPhoto.value!['createdAt'] as Timestamp?;
    
    if (timeBefore == null || timeAfter == null) return "0 ngày";

    Duration difference = timeAfter.toDate().difference(timeBefore.toDate());
    int days = difference.inDays.abs(); 
    
    return "Sau $days ngày";
  }

  void _checkComparisonGamification() {
    if (beforePhoto.value != null && afterPhoto.value != null && !hasReceivedComparisonBadge.value) {
      hasReceivedComparisonBadge.value = true;
      _addGamificationExp(100, 'Tạo ảnh Before/After thành công!');
      Get.snackbar(
        '🏆 Huy Hiệu Mới', 
        'Danh hiệu: Người kiến tạo vóc dáng!', 
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4)
      );
    }
  }

  void deletePhoto(String docId) {
    Get.defaultDialog(
      title: "Xóa ảnh",
      titleStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      middleText: "Bạn có chắc chắn muốn xóa ảnh tiến độ này không?",
      middleTextStyle: const TextStyle(fontFamily: 'Poppins'),
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      cancelTextColor: const Color(0xFFC050F6),
      onConfirm: () async {
        Get.back();
        String? uid = auth.currentUser?.uid;
        if (uid != null) {
          await firestore.collection('users').doc(uid).collection('progress_photos').doc(docId).delete();
        }
      }
    );
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> shareComparisonImage(Uint8List? imageBytes) async {
    if (imageBytes == null) {
      Get.snackbar('Lỗi', 'Không thể tạo ảnh chia sẻ.');
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/thanh_qua_fitness.png').create();
      await imagePath.writeAsBytes(imageBytes);

      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath.path)], 
          text: 'Cùng xem sự lột xác của tôi $timeDifferenceText! 💪🔥 Tải app ngay để tập luyện cùng tôi nhé!',
        ),
      );

      if (shareResult.status == ShareResultStatus.success) {
        _addGamificationExp(50, 'Chia sẻ thành công! Lan tỏa năng lượng tích cực!');
        
        if (userExp.value >= 500) {
           Get.snackbar(
            '🌟 Khung Avatar Mới', 
            'Đạt mốc 500 EXP! Bạn đã mở khóa Khung Avatar Level 2 trong Cài đặt.', 
            backgroundColor: Colors.purpleAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 5)
          );
        }
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Chia sẻ thất bại: $e');
    }
  }
}
