import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late Box _pendingBox;

  Future<SyncService> init() async {
    _mediaService = Get.find<MediaService>();
    _syncBox = await Hive.openBox('sync_metadata');
    _foodBox = await Hive.openBox('cached_foods');
    _exerciseBox = await Hive.openBox('cached_exercises');
    _pendingBox = await Hive.openBox('pending_sync_box');

    Timer.periodic(const Duration(seconds: 15), (timer) async {
      await syncPendingLogs();
    });

    return this;
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> addPendingLog(String type, Map<String, dynamic> data) async {
    await _pendingBox.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> syncPendingLogs() async {
    if (_pendingBox.isEmpty) return;
    
    bool online = await hasInternet();
    if (!online) return;
    
    List<dynamic> keysToDelete = [];
    
    for (var key in _pendingBox.keys) {
      var item = _pendingBox.get(key);
      if (item == null || item is! Map) continue;
      
      String type = item['type'] ?? '';
      var data = Map<String, dynamic>.from(item['data'] ?? {});
      
      try {
        if (type == 'water') {
          String? uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            String dateStr = data['dateStr'] ?? '';
            double waterVal = (data['water'] as num?)?.toDouble() ?? 0.0;
            if (dateStr.isNotEmpty) {
              await _firestore.collection('users').doc(uid).collection('dailyActivities').doc(dateStr).set({
                'water': waterVal,
                'lastSync': DateTime.now().toIso8601String(),
              }, SetOptions(merge: true));
            }
          }
        } else if (type == 'meal') {
          await _firestore.collection('user_intake').add({
            'userId': data['userId'],
            'foodName': data['foodName'],
            'mealType': data['mealType'],
            'baseCalories': data['baseCalories'],
            'portionSize': data['portionSize'],
            'totalCalories': data['totalCalories'],
            'image_url': data['image_url'],
            'timestamp': Timestamp.fromMillisecondsSinceEpoch(data['timestamp']),
          });
        }
        keysToDelete.add(key);
      } catch (_) {}
    }
    
    for (var key in keysToDelete) {
      await _pendingBox.delete(key);
    }
  }

  Future<void> startSilentSync() async {
    bool isForceSynced = _syncBox.get('is_force_synced_v1', defaultValue: false);
    
    if (!isForceSynced) {
      await _syncBox.delete('last_food_sync');
      await _syncBox.delete('last_exercise_sync');
      await _syncBox.put('is_force_synced_v1', true);
    }

    await syncFoods();
    await syncExercises();
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
      int downloadedCount = 0;

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
            String localPath = _mediaService.getLocalPath(foodId, 'foods', imageUrl);
            if (!_mediaService.isFileExists(localPath)) {
              await _mediaService.downloadAndSaveFile(foodId, 'foods', imageUrl);
              downloadedCount++;
            }
          }
        }
        await _syncBox.put('last_food_sync', DateTime.now().millisecondsSinceEpoch);
        debugPrint('--- SyncService: Đã cập nhật ${snapshot.docs.length} món ăn. Tải mới $downloadedCount hình ảnh ---');
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
      int downloadedCount = 0;

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.isEmpty) continue;

          String exId = doc.id;
          String gifUrl = data['gifUrl'] ?? data['image'] ?? '';

          data['exerciseId'] = exId;
          data['id'] = exId;
          
          Map<String, dynamic> cleanData = _sanitizeData(data);
          await _exerciseBox.put(exId, cleanData);

          if (gifUrl.isNotEmpty && gifUrl.startsWith('http')) {
            String localPath = _mediaService.getLocalPath(exId, 'exercises', gifUrl);
            if (!_mediaService.isFileExists(localPath)) {
              await _mediaService.downloadAndSaveFile(exId, 'exercises', gifUrl);
              downloadedCount++;
            }
          }
        }
        await _syncBox.put('last_exercise_sync', DateTime.now().millisecondsSinceEpoch);
        debugPrint('--- SyncService: Đã cập nhật ${snapshot.docs.length} bài tập. Tải mới $downloadedCount GIF bài tập ---');
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
