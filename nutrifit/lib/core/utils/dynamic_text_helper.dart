import 'package:get/get.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';

class DynamicTextHelper {
  static String getName() {
    try {
      final authController = Get.find<AuthController>();
      String fullName = authController.userData['fullName']?.toString() ?? 'bạn';
      // Lấy tên cuối cùng (tên gọi)
      return fullName.split(' ').last;
    } catch (e) {
      return 'bạn';
    }
  }

  static String getPronoun() {
    try {
      final authController = Get.find<AuthController>();
      String gender = authController.userData['gender']?.toString() ?? 'Female';
      if (gender == 'Male') return 'ông';
      if (gender == 'Female') return 'bà';
      return 'bạn';
    } catch (e) {
      return 'bạn';
    }
  }

  static String getGreeting() {
    return 'Hôm nay ${getName()} ăn món gì vậy?';
  }

  static String getSuccessMessage(String foodName) {
    return 'Tui đã ghi chú món $foodName vào nhật ký cho ${getPronoun()} rồi đó!';
  }
}
