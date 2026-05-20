import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class HealthService extends GetxService {
  final Health _health = Health();
  var isAuthorized = false.obs;

  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.WATER,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
  ];

  Future<HealthService> init() async {
    if (GetPlatform.isAndroid) {
      await _health.installHealthConnect();
    }
    await requestPermissions();
    return this;
  }

  Future<bool> requestPermissions() async {
    try {
      debugPrint("--- HealthService: Đang xin tất cả quyền Health Connect... ---");
      
      // Xin cả quyền READ cho tất cả các loại
      final permissions = _types.map((e) => HealthDataAccess.READ).toList();
      
      bool? hasPermissions = await _health.hasPermissions(_types, permissions: permissions);
      
      if (hasPermissions == true) {
        debugPrint("--- HealthService: Đã có đủ quyền rồi! ---");
        isAuthorized.value = true;
        return true;
      }

      bool requested = await _health.requestAuthorization(_types, permissions: permissions);
      isAuthorized.value = requested;
      
      if (requested) {
        debugPrint("--- HealthService: Cấp quyền thành công! ---");
      } else {
        debugPrint("--- HealthService: Người dùng từ chối cấp quyền. ---");
      }
      return requested;
    } catch (e) {
      debugPrint("--- HealthService: Lỗi khi xin quyền: $e ---");
      isAuthorized.value = false;
      return false;
    }
  }

  Health get health => _health;
  List<HealthDataType> get types => _types;
}
