import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FileService extends GetxService {
  final String _cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dhhhclbra/auto/upload';
  final String _uploadPreset = 'ml_default';

  Future<String?> pickAndUploadImage(String path) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        var request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
        request.fields['upload_preset'] = _uploadPreset;
        request.fields['folder'] = path;
        
        if (result.files.first.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            result.files.first.bytes!,
            filename: result.files.first.name,
          ));
        } else if (result.files.first.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            result.files.first.path!,
          ));
        } else {
          Get.back();
          return null;
        }

        var response = await request.send();
        Get.back();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var decodedData = json.decode(responseData);
          return decodedData['secure_url'];
        } else {
          Get.snackbar('Lỗi', 'Cloudinary trả về lỗi: ${response.statusCode}');
        }
      }
      return null;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Lỗi', 'Không thể upload ảnh: $e');
      return null;
    }
  }

  Future<String?> pickAndUploadGif(String path) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif', 'mp4'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

        var request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
        request.fields['upload_preset'] = _uploadPreset;
        request.fields['folder'] = path;
        
        if (result.files.first.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            result.files.first.bytes!,
            filename: result.files.first.name,
          ));
        } else if (result.files.first.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            result.files.first.path!,
          ));
        } else {
          Get.back();
          return null;
        }

        var response = await request.send();
        Get.back();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var decodedData = json.decode(responseData);
          return decodedData['secure_url'];
        } else {
          Get.snackbar('Lỗi', 'Cloudinary trả về lỗi: ${response.statusCode}');
        }
      }
      return null;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Lỗi', 'Không thể upload GIF/Video: $e');
      return null;
    }
  }
}
