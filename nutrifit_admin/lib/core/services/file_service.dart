import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class FileService extends GetxService {
  final String _cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dhhhclbra/image/upload';
  final String _uploadPreset = 'ml_default';

  Future<String?> pickAndUploadImage(String path, {String? fileName}) async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.first.bytes != null) {
        Uint8List fileBytes = result.files.first.bytes!;
        
        var request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
        request.fields['upload_preset'] = _uploadPreset;
        request.fields['folder'] = path;
        
        // Nếu có truyền fileName (Food ID), thì dùng nó làm public_id để ghi đè
        if (fileName != null && fileName.isNotEmpty) {
          request.fields['public_id'] = fileName;
          request.fields['overwrite'] = 'true';
        }
        
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: result.files.first.name,
        ));

        var response = await request.send();
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
      );

      if (result != null && result.files.first.bytes != null) {
        Uint8List fileBytes = result.files.first.bytes!;
        
        var request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
        request.fields['upload_preset'] = _uploadPreset;
        request.fields['folder'] = path;
        
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: result.files.first.name,
        ));

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var decodedData = json.decode(responseData);
          return decodedData['secure_url'];
        }
      }
      return null;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể upload GIF/Video: $e');
      return null;
    }
  }
}
