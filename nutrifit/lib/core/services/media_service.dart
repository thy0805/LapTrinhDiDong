import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class MediaService extends GetxService {
  late Directory _appDocDir;

  Future<MediaService> init() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    await Directory('${_appDocDir.path}/foods').create(recursive: true);
    await Directory('${_appDocDir.path}/exercises').create(recursive: true);
    await Directory('${_appDocDir.path}/avatars').create(recursive: true);
    await Directory('${_appDocDir.path}/covers').create(recursive: true);
    return this;
  }

  // Lấy đường dẫn file cục bộ dựa trên ID và loại (foods/exercises)
  String getLocalPath(String id, String type, String url) {
    String extension = url.split('.').last.split('?').first;
    if (extension.length > 4) extension = 'png'; // Mặc định nếu không lấy được extension
    return '${_appDocDir.path}/$type/$id.$extension';
  }

  bool isFileExists(String path) {
    return File(path).existsSync();
  }

  Future<String?> downloadAndSaveFile(String id, String type, String url) async {
    if (url.isEmpty) return null;
    
    try {
      final String localPath = getLocalPath(id, type, url);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final File file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        return localPath;
      }
    } catch (e) {
      debugPrint('--- MediaService: Lỗi khi tải file $id: $e ---');
    }
    return null;
  }
}
