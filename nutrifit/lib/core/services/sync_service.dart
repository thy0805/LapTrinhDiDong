import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrifit/core/services/media_service.dart';
import 'package:flutter/foundation.dart';

class SyncService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late MediaService _mediaService;
  
  late Box _syncBox;
  late Box _foodBox;
  late Box _exerciseBox;

  Future<SyncService> init() async {
    _mediaService = Get.find<MediaService>();
    _syncBox = await Hive.openBox('sync_metadata');
    _foodBox = await Hive.openBox('cached_foods');
    _exerciseBox = await Hive.openBox('cached_exercises');
    return this;
  }

  // Bắt đầu quá trình đồng bộ âm thầm
  Future<void> startSilentSync() async {
    debugPrint('--- SyncService: Bắt đầu đồng bộ thông minh... ---');
    await syncFoods();
    await syncExercises();
    debugPrint('--- SyncService: Đồng bộ hoàn tất! ---');
  }

  Future<void> syncFoods() async {
    try {
      int lastSync = _syncBox.get('last_food_sync', defaultValue: 0);
      DateTime lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSync);

      Query query = _firestore.collection('foods');
      if (lastSync > 0) {
        query = query.where('updated_at', isGreaterThan: lastSyncDate);
      }

      var snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.isEmpty) continue;

          String foodId = doc.id;
          String imageUrl = data['image_url'] ?? '';

          data['id'] = foodId;
          Map<String, dynamic> cleanData = _sanitizeData(data);
          await _foodBox.put(foodId, cleanData);

          if (imageUrl.isNotEmpty) {
            _mediaService.downloadAndSaveFile(foodId, 'foods', imageUrl);
          }
        }
        await _syncBox.put('last_food_sync', DateTime.now().millisecondsSinceEpoch);
        debugPrint('--- SyncService: Đã cập nhật ${snapshot.docs.length} món ăn mới ---');
      }
    } catch (e) {
      debugPrint('--- SyncService: Lỗi đồng bộ món ăn: $e ---');
    }
  }

  Future<void> syncExercises() async {
    try {
      int lastSync = _syncBox.get('last_exercise_sync', defaultValue: 0);
      DateTime lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSync);

      Query query = _firestore.collection('exercises');
      if (lastSync > 0) {
        query = query.where('updated_at', isGreaterThan: lastSyncDate);
      }

      var snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.isEmpty) continue;

          String exId = doc.id;
          data['exerciseId'] = exId;
          data['id'] = exId;
          
          Map<String, dynamic> cleanData = _sanitizeData(data);
          await _exerciseBox.put(exId, cleanData);
        }
        await _syncBox.put('last_exercise_sync', DateTime.now().millisecondsSinceEpoch);
        debugPrint('--- SyncService: Đã cập nhật ${snapshot.docs.length} bài tập mới ---');
      }
    } catch (e) {
      debugPrint('--- SyncService: Lỗi đồng bộ bài tập: $e ---');
    }
  }

  Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    Map<String, dynamic> sanitized = {};
    data.forEach((key, value) {
      if (value is Timestamp) {
        sanitized[key] = value.millisecondsSinceEpoch;
      } else if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeData(value);
      } else if (value is List) {
        sanitized[key] = value.map((e) {
          if (e is Map<String, dynamic>) return _sanitizeData(e);
          if (e is Timestamp) return e.millisecondsSinceEpoch;
          return e;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  List<Map<String, dynamic>> getAllCachedFoods() {
    return _foodBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<Map<String, dynamic>> getAllCachedExercises() {
    return _exerciseBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
