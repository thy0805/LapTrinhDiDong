import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../auth/views/login_screen.dart';

class ProfileController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var fullName = ''.obs;
  var goal = ''.obs;
  var height = ''.obs;
  var weight = ''.obs;
  var age = ''.obs;
  var avatarUrl = ''.obs;
  var coverUrl = ''.obs;
  var bio = ''.obs;
  var phone = ''.obs;
  var gender = 'Female'.obs;
  var location = 'TP. Hồ Chí Minh'.obs;

  var isWeightPublic = true.obs;
  var isHeightPublic = true.obs;
  var isProgressPublic = false.obs;

  var nameController = TextEditingController();
  var heightController = TextEditingController();
  var weightController = TextEditingController();
  var bioController = TextEditingController();
  var phoneController = TextEditingController();
  var locationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void fetchUserData() {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      firestore.collection('users').doc(uid).snapshots().listen((doc) {
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
          fullName.value = data['fullName'] ?? '';
          goal.value = data['goal'] ?? '';
          height.value = data['height']?.toString() ?? '';
          weight.value = data['weight']?.toString() ?? '';
          avatarUrl.value = data['avatarUrl'] ?? '';
          coverUrl.value = data['coverUrl'] ?? '';
          bio.value = data['bio'] ?? '';
          phone.value = data['phone'] ?? '';
          gender.value = data['gender'] ?? 'Female';
          location.value = data['location'] ?? 'TP. Hồ Chí Minh';
          
          isWeightPublic.value = data['isWeightPublic'] ?? true;
          isHeightPublic.value = data['isHeightPublic'] ?? true;
          isProgressPublic.value = data['isProgressPublic'] ?? false;

          String dob = data['dateOfBirth'] ?? '';
          if (dob.isNotEmpty) age.value = _calculateAge(dob);
        }
      });
    }
  }

  String _calculateAge(String dobStr) {
    try {
      List<String> parts = dobStr.split('/');
      if (parts.length == 3) {
        DateTime dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        DateTime today = DateTime.now();
        int calculatedAge = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) calculatedAge--;
        return calculatedAge.toString();
      }
    } catch (e) { return '22'; }
    return '22';
  }

  Future<CroppedFile?> _cropImage(String sourcePath, bool isAvatar) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: isAvatar ? const CropAspectRatio(ratioX: 1, ratioY: 1) : const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: isAvatar ? 'Cắt ảnh đại diện' : 'Cắt ảnh bìa',
            toolbarColor: const Color(0xFFC050F6),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isAvatar ? CropAspectRatioPreset.square : CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true),
        IOSUiSettings(
          title: isAvatar ? 'Cắt ảnh đại diện' : 'Cắt ảnh bìa',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
  }

  Future<String?> _uploadToCloudinary(String imagePath) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFFC050F6))), barrierDismissible: false);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://api.cloudinary.com/v1_1/dhhhclbra/image/upload'));
      request.fields['upload_preset'] = 'ml_default';
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      var response = await request.send();
      Get.back();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        return json.decode(responseData)['secure_url'];
      }
    } catch (e) { Get.back(); }
    return null;
  }

  Future<void> updateAvatar() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      CroppedFile? croppedFile = await _cropImage(image.path, true);
      if (croppedFile != null) {
        String? url = await _uploadToCloudinary(croppedFile.path);
        if (url != null) await firestore.collection('users').doc(auth.currentUser!.uid).update({'avatarUrl': url});
      }
    }
  }

  Future<void> updateCover() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      CroppedFile? croppedFile = await _cropImage(image.path, false);
      if (croppedFile != null) {
        String? url = await _uploadToCloudinary(croppedFile.path);
        if (url != null) await firestore.collection('users').doc(auth.currentUser!.uid).update({'coverUrl': url});
      }
    }
  }

  void updatePrivacy(String field, bool value) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({field: value});
  }

  void showEditProfileDialog() {
    nameController.text = fullName.value;
    heightController.text = height.value;
    weightController.text = weight.value;
    bioController.text = bio.value;
    phoneController.text = phone.value;
    locationController.text = location.value;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chỉnh sửa hồ sơ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),
              _buildField(nameController, 'Họ và tên', Icons.person_outline),
              const SizedBox(height: 15),
              _buildField(bioController, 'Tiểu sử (Bio)', Icons.info_outline),
              const SizedBox(height: 15),
              _buildField(phoneController, 'Số điện thoại', Icons.phone_android_outlined, isNum: true),
              const SizedBox(height: 15),
              _buildField(locationController, 'Vị trí', Icons.location_on_outlined),
              const SizedBox(height: 15),
              const Text('Giới tính', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  _buildGenderOption('Male', 'Nam', Icons.male),
                  const SizedBox(width: 15),
                  _buildGenderOption('Female', 'Nữ', Icons.female),
                ],
              )),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildField(heightController, 'Cao (cm)', Icons.height, isNum: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField(weightController, 'Nặng (kg)', Icons.monitor_weight_outlined, isNum: true)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC050F6),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () async {
                  Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                  await firestore.collection('users').doc(auth.currentUser!.uid).update({
                    'fullName': nameController.text.trim(),
                    'bio': bioController.text.trim(),
                    'height': heightController.text.trim(),
                    'weight': weightController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'location': locationController.text.trim(),
                    'gender': gender.value,
                  });
                  Get.back(); // Tắt loading
                  Get.back(); // Tắt bottomsheet
                  Get.snackbar('Thành công', 'Hồ sơ đã được cập nhật!', 
                    backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
                },
                child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    bool isSelected = gender.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => gender.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFC050F6).withValues(alpha: 0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFFC050F6) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? const Color(0xFFC050F6) : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? const Color(0xFFC050F6) : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNum = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFFC050F6)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC050F6))),
      ),
    );
  }

  void logout() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    Get.offAll(() => const LoginPage());
  }
}
