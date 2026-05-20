import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/health_service.dart';
import 'package:local_auth/local_auth.dart';
import '../views/app_lock_screen.dart';

class SecurityController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _box = Hive.box('security_settings');

  var isAppLockEnabled = false.obs;
  var isBiometricEnabled = false.obs;
  var isGhostModeEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    isAppLockEnabled.value = _box.get('isAppLockEnabled', defaultValue: false);
    isBiometricEnabled.value = _box.get('isBiometricEnabled', defaultValue: false);
    isGhostModeEnabled.value = _box.get('isGhostModeEnabled', defaultValue: false);
  }

  Future<void> toggleAppLock(bool value) async {
    if (value) {
      final success = await Get.to(() => AppLockScreen(mode: AppLockMode.setup));
      if (success == true) {
        isAppLockEnabled.value = true;
      } else {
        isAppLockEnabled.value = false;
      }
    } else {
      final success = await Get.to(() => AppLockScreen(mode: AppLockMode.disable));
      if (success == true) {
        isAppLockEnabled.value = false;
        _box.put('isBiometricEnabled', false);
        isBiometricEnabled.value = false;
      } else {
        isAppLockEnabled.value = true;
      }
    }
  }

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      if (!isAppLockEnabled.value) {
        Get.snackbar(
          'Bảo mật',
          'Vui lòng kích hoạt khóa bằng mã PIN trước khi bật vân tay',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        isBiometricEnabled.value = false;
        return;
      }

      final localAuth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        Get.snackbar(
          'Bảo mật',
          'Thiết bị không hỗ trợ hoặc chưa đăng ký sinh trắc học',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        isBiometricEnabled.value = false;
        return;
      }

      try {
        final bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Xác thực sinh trắc học của chủ thiết bị để kích hoạt',
          options: AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          _box.put('isBiometricEnabled', true);
          isBiometricEnabled.value = true;
          Get.snackbar(
            'Thành công',
            'Đã kích hoạt khóa ứng dụng bằng vân tay/FaceID',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          isBiometricEnabled.value = false;
        }
      } catch (e) {
        isBiometricEnabled.value = false;
        Get.snackbar(
          'Lỗi',
          'Không thể xác thực sinh trắc học: $e',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } else {
      _box.put('isBiometricEnabled', false);
      isBiometricEnabled.value = false;
      Get.snackbar(
        'Bảo mật',
        'Đã tắt tính năng khóa bằng vân tay/FaceID',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
    }
  }

  void toggleGhostMode(bool value) {
    _box.put('isGhostModeEnabled', value);
    isGhostModeEnabled.value = value;
    Get.snackbar(
      'Bảo mật',
      value ? 'Đã kích hoạt chế độ ẩn danh chỉ số' : 'Đã tắt chế độ ẩn danh chỉ số',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
    );
  }

  Future<void> requestPasswordReset() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
      Get.snackbar(
        'Thành công',
        'Đã gửi email đặt lại mật khẩu tới ${user.email}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể gửi email đặt lại mật khẩu: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> syncHealthPermissions() async {
    final healthService = Get.find<HealthService>();
    final success = await healthService.requestPermissions();
    if (success) {
      Get.snackbar(
        'Thành công',
        'Đã cập nhật liên kết dữ liệu Health Connect',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Thất bại',
        'Người dùng đã hủy hoặc từ chối cấp quyền',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final uidStr = user.uid;

      final intakeDocs = await _firestore.collection('user_intake').where('userId', isEqualTo: uidStr).get();
      for (var doc in intakeDocs.docs) {
        await doc.reference.delete();
      }

      final subcollections = ['sleepLogs', 'dailyActivities', 'schedules', 'combos', 'milestones', 'streaks'];
      for (var sub in subcollections) {
        final docs = await _firestore.collection('users').doc(uidStr).collection(sub).get();
        for (var doc in docs.docs) {
          await doc.reference.delete();
        }
      }

      await _firestore.collection('users').doc(uidStr).delete();
      await user.delete();

      Get.find<AuthController>().logout();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          'Yêu cầu xác thực lại',
          'Vui lòng đăng nhập lại để xác minh danh tính trước khi xóa tài khoản',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể xóa tài khoản: ${e.message}',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi không xác định: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
