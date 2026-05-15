import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AiScannerController extends GetxController {
  var selectedImage = Rxn<File>();
  var isScanning = false.obs;
  
  // Danh sách các món gợi ý từ AI
  var predictions = <Map<String, dynamic>>[].obs;
  
  // Món ăn đang được chọn để tính calo
  var selectedFood = Rxn<Map<String, dynamic>>();
  
  // Hệ số khẩu phần ăn: 0.8 (Nhỏ), 1.0 (Vừa), 1.2 (Lớn)
  var portionMultiplier = 1.0.obs;
  var selectedPortion = 'Medium'.obs; // 'Small', 'Medium', 'Large'
  
  // Các thông số tùy chỉnh mới
  var customCalories = 0.obs;
  var selectedMealType = 'Bữa ăn AI'.obs;
  var selectedTime = DateTime.now().obs;
  var isManualEntry = false.obs;
  var manualFoodName = ''.obs;

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  var isUploading = false.obs;

  // URL Backend (Dùng ngrok ma thuật của Thy)
  final String apiUrl = "https://nonaudible-mesophytic-gisele.ngrok-free.dev/predict";

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        reset();
        selectedImage.value = File(pickedFile.path);
        await scanFood();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e');
    }
  }

  Future<void> scanFood() async {
    if (selectedImage.value == null) return;

    isScanning.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', selectedImage.value!.path)
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        
        List<dynamic> apiResults = data['predictions'];
        predictions.clear();

        // Lấy thông tin chi tiết từ Firestore cho Top 3 kết quả
        for (var i = 0; i < apiResults.length && i < 3; i++) {
          var res = apiResults[i];
          var foodDoc = await _firestore.collection('foods').doc(res['id']).get();
          
          if (foodDoc.exists) {
            var foodData = foodDoc.data()!;
            predictions.add({
              'id': res['id'],
              'confidence': res['confidence'],
              'name': foodData['name'],
              'base_calories': foodData['base_calories'],
              'unit': foodData['unit'],
              'image_url': foodData['image_url'],
              'category': foodData['category'],
            });
          }
        }

        if (predictions.isNotEmpty) {
          selectFood(predictions[0]); // Mặc định chọn món đầu tiên
        }
      } else {
        Get.snackbar('Lỗi', 'Server AI đang bận. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể kết nối đến AI Server. Thy nhớ bật server Python lên nha!');
      debugPrint('AI Scan Error: $e');
    } finally {
      isScanning.value = false;
    }
  }

  void selectFood(Map<String, dynamic> food) {
    selectedFood.value = food;
    customCalories.value = (food['base_calories'] as num).toInt();
    isManualEntry.value = false;
  }

  void setManualEntry() {
    isManualEntry.value = true;
    selectedFood.value = null;
    manualFoodName.value = 'Món ăn mới';
    customCalories.value = 300; // Mặc định
  }

  void updateCalories(int calories) {
    customCalories.value = calories;
  }

  void updateMealType(String type) {
    selectedMealType.value = type;
  }

  void updateTime(DateTime time) {
    selectedTime.value = time;
  }

  void updatePortion(String size) {
    selectedPortion.value = size;
    if (size == 'Small') {
      portionMultiplier.value = 0.8;
    } else if (size == 'Large') {
      portionMultiplier.value = 1.2;
    } else {
      portionMultiplier.value = 1.0;
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage.value == null) return null;
    
    isUploading.value = true;
    try {
      String fileName = 'ai_scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('meal_images').child(fileName);
      UploadTask uploadTask = ref.putFile(selectedImage.value!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('--- Upload Error: $e ---');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  int get calculatedCalories {
    if (isManualEntry.value) return customCalories.value;
    if (selectedFood.value == null) return 0;
    
    // Nếu người dùng đã sửa calo thủ công thì lấy số đó, không thì tính theo portion
    if (customCalories.value != (selectedFood.value!['base_calories'] as num).toInt()) {
        return customCalories.value;
    }
    
    double base = (selectedFood.value!['base_calories'] as num).toDouble();
    return (base * portionMultiplier.value).round();
  }

  void reset() {
    selectedImage.value = null;
    predictions.clear();
    selectedFood.value = null;
    portionMultiplier.value = 1.0;
    selectedPortion.value = 'Medium';
    customCalories.value = 0;
    isManualEntry.value = false;
    selectedTime.value = DateTime.now();
  }
}

