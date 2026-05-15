import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  final _isBlueColor = false.obs;

  bool get isDarkMode => _isDarkMode.value;
  bool get isBlueColor => _isBlueColor.value;

  ThemeData get currentTheme {
    if (_isBlueColor.value) {
      return _isDarkMode.value ? AppTheme.blueDark : AppTheme.blueLight;
    } else {
      return _isDarkMode.value ? AppTheme.pinkDark : AppTheme.pinkLight;
    }
  }

  void toggleDarkMode(bool value) {
    _isDarkMode.value = value;
    Get.changeTheme(currentTheme);
  }

  void toggleColorTheme(bool value) {
    _isBlueColor.value = value;
    Get.changeTheme(currentTheme);
  }
}
