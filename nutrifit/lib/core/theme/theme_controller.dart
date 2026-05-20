import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  final currentThemeMode = 'pinkLight'.obs;
  final _box = Hive.box('security_settings');

  bool get isDarkMode => currentThemeMode.value == 'darkAbyss';
  bool get isBlueColor => currentThemeMode.value == 'oceanBlue';

  @override
  void onInit() {
    super.onInit();
    currentThemeMode.value = _box.get('app_theme_mode', defaultValue: 'pinkLight');
  }

  ThemeData get currentTheme {
    switch (currentThemeMode.value) {
      case 'darkAbyss':
        return AppTheme.darkAbyss;
      case 'oceanBlue':
        return AppTheme.oceanBlue;
      default:
        return AppTheme.pinkLight;
    }
  }

  void changeThemeMode(String mode) {
    _box.put('app_theme_mode', mode);
    currentThemeMode.value = mode;
    Get.changeTheme(currentTheme);
  }

  void toggleDarkMode(bool value) {
    changeThemeMode(value ? 'darkAbyss' : 'pinkLight');
  }

  void toggleColorTheme(bool value) {
    changeThemeMode(value ? 'oceanBlue' : 'pinkLight');
  }
}
