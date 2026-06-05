import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:alarm/alarm.dart';
import 'package:health/health.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrifit/modules/auth/views/welcome_screen_1.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/core/services/media_service.dart';
import 'package:nutrifit/core/services/sync_service.dart';
import 'package:nutrifit/core/services/gamification_service.dart';
import 'package:nutrifit/core/theme/theme_controller.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await Firebase.initializeApp();
    await Hive.initFlutter();
    await Hive.openBox('security_settings');
    await Alarm.init();
    await initializeDateFormatting('vi_VN', null);
    Health().configure();

    await Get.putAsync(() => MediaService().init());
    final syncService = await Get.putAsync(() => SyncService().init());

    Get.put(AuthController());
    Get.put(ThemeController());
    Get.put(GamificationService());

    Future.delayed(const Duration(seconds: 5), () {
      syncService.startSilentSync();
    });
  } catch (e) {
    debugPrint("--- Startup Error: $e ---");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NutriFit',
        theme: themeController.currentTheme,
        home: const WelcomeScreen1(),
      ),
    );
  }
}
