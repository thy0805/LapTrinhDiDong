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
import 'package:nutrifit/core/services/gamification_service.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import '../views/ai_pose_camera_screen.dart';

class ProgressController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GamificationService _gamification = Get.find<GamificationService>();

  var progressPhotos = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  
  var lastPhotoUrl = ''.obs;
  var userExp = 0.obs;

  String get userName => Get.find<AuthController>().userData['fullName'] ?? 'Người dùng';
  String get userPronoun => (Get.find<AuthController>().userData['gender'] == 'Male') ? 'ông' : 'bà';

  var beforePhoto = Rxn<Map<String, dynamic>>();
  var afterPhoto = Rxn<Map<String, dynamic>>();
  var hasReceivedComparisonBadge = false.obs;

  var weightHistory = <Map<String, dynamic>>[].obs; 
  var targetWeight = 0.0.obs; 
  var hasReachedTargetBadge = false.obs;

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
        targetWeight.value = double.tryParse(data['targetWeight']?.toString() ?? '0') ?? 0.0;
        hasReachedTargetBadge.value = data['achievements']?['reachedTargetWeight'] ?? false;
        hasReceivedComparisonBadge.value = data['achievements']?['createdComparison'] ?? false;
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
    if (weightHistory.isEmpty) return [FlSpot(0, 0)];
    
    List<FlSpot> spots = [];
    for (int i = 0; i < weightHistory.length; i++) {
      double weight = double.tryParse(weightHistory[i]['weight'].toString()) ?? 0.0;
      spots.add(FlSpot(i.toDouble(), weight));
    }
    return spots;
  }

  void _checkTargetWeightGamification() {
    if (weightHistory.isEmpty || hasReachedTargetBadge.value || targetWeight.value <= 0) return;

    double latestWeight = double.tryParse(weightHistory.last['weight'].toString()) ?? 0.0;
    
    if (latestWeight <= targetWeight.value && latestWeight > 0) {
      hasReachedTargetBadge.value = true;
      _gamification.awardExp(200, '$userPronoun đã đạt được Mục Tiêu Cân Nặng!');
      _gamification.unlockAchievement('reached_target_weight', 'Kẻ Chinh Phục', 'Chạm đến mốc Cân Nặng Mục Tiêu thành công! 🏆', 200);
    }
  }


  Future<void> addProgressPhoto() async {
    final ImagePicker picker = ImagePicker();
    
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Thêm ảnh tiến độ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Get.theme.colorScheme.primary),
              title: Text(
                'Chụp ảnh với Bóng Ma (Ghosting)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                ),
              ),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Get.theme.colorScheme.primary),
              title: Text(
                'Chọn từ thư viện',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(Get.context!).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                ),
              ),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == ImageSource.camera) {
       Get.to(() => const AiPoseCameraScreen());
       return; 
    }

    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      await uploadAndSavePhoto(image.path);
    }
  }

  Future<void> uploadAndSavePhoto(String imagePath, {List<Map<String, dynamic>>? poseData}) async {
      isLoading.value = true;
      Get.dialog(
        Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.primary)),
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

            double estimatedBodyFat = 0.0;
            double shoulderHipRatio = 0.0;

            if (poseData != null) {
              try {
                final responseMetrics = await http.post(
                  Uri.parse('https://nonaudible-mesophytic-gisele.ngrok-free.dev/progress/metrics'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({'landmarks': poseData}),
                );
                if (responseMetrics.statusCode == 200) {
                  final resData = json.decode(responseMetrics.body);
                  estimatedBodyFat = (resData['estimated_body_fat'] as num?)?.toDouble() ?? 0.0;
                  shoulderHipRatio = (resData['shoulder_hip_ratio'] as num?)?.toDouble() ?? 0.0;
                }
              } catch (_) {}
            }

            await firestore
                .collection('users')
                .doc(uid)
                .collection('progress_photos')
                .add({
              'imageUrl': secureUrl,
              'weightAtTime': currentWeightStr,
              'createdAt': FieldValue.serverTimestamp(),
              'estimatedBodyFat': estimatedBodyFat,
              'shoulderHipRatio': shoulderHipRatio,
            });

            await firestore.collection('users').doc(uid).collection('weight_history').add({
              'weight': currentWeightStr,
              'date': FieldValue.serverTimestamp(),
            });

            await _gamification.awardExp(10, 'Đã cập nhật ảnh tiến độ mới!');
          }
        }
      } catch (e) {
        Get.back();
        Get.snackbar("Lỗi", "Không thể tải ảnh lên", backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
  }

  Future<String> analyzeComparison() async {
    if (beforePhoto.value == null || afterPhoto.value == null) {
      throw Exception('Cần chọn đủ 2 ảnh trước khi phân tích!');
    }
    final beforeUrl = beforePhoto.value!['imageUrl'];
    final afterUrl = afterPhoto.value!['imageUrl'];
    final authController = Get.find<AuthController>();
    final name = authController.userName;
    final pronoun = authController.userPronoun;
    final response = await http.post(
      Uri.parse('https://nonaudible-mesophytic-gisele.ngrok-free.dev/progress/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'before_url': beforeUrl,
        'after_url': afterUrl,
        'name': name,
        'pronoun': pronoun,
      }),
    );
    if (response.statusCode == 200) {
      final resData = json.decode(response.body);
      return resData['analysis'] ?? '';
    } else {
      throw Exception('Không thể kết nối đến AI Server.');
    }
  }

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
      _gamification.unlockAchievement('created_comparison', 'Người Kiến Tạo Vóc Dáng', 'Tạo ảnh Before/After thành công!', 100);
    }
  }

  void deletePhoto(String docId) {
    Get.defaultDialog(
      title: "Xóa ảnh",
      titleStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      middleText: "$userPronoun có chắc chắn muốn xóa ảnh tiến độ này không?",
      middleTextStyle: TextStyle(fontFamily: 'Poppins'),
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      cancelTextColor: Get.theme.colorScheme.primary,
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
        await _gamification.awardExp(50, 'Chia sẻ thành công! Lan tỏa năng lượng tích cực!');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Chia sẻ thất bại: $e');
    }
  }
}
