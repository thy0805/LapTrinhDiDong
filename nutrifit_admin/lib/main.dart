import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/firebase_options.dart';
import 'package:nutrifit_admin/modules/layout/views/admin_layout.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/core/services/firebase_service.dart';
import 'package:nutrifit_admin/core/services/file_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(FirebaseService());
  Get.put(FileService());
  Get.put(NavigationController());

  runApp(const NutriFitAdminApp());
}

class NutriFitAdminApp extends StatelessWidget {
  const NutriFitAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NutriFit Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        textTheme: GoogleFonts.outfitTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: TailAdminDesign.brand500,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1121),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: TailAdminDesign.brand500,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AdminLayout(),
    );
  }
}
