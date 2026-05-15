import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/views/home_screen.dart';
import 'package:nutrifit/modules/main/profile/views/profile_screen.dart';
import 'package:nutrifit/modules/main/progress/views/progress_tracker_screen.dart';
import 'package:nutrifit/modules/main/target/views/target_settings_screen.dart';
import 'package:nutrifit/modules/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/workout/controllers/health_service.dart';
import 'package:nutrifit/modules/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/notification_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller dùng chung ngay tại đây để các màn hình con có thể dùng ngay
    Get.put(HealthService()).init();
    Get.put(SleepController());
    Get.put(NutritionController());
    Get.put(ActivityController());
    Get.put(NotificationController());
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const TargetSettingsScreen(),
    const ProgressTrackerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _taoThanhDieuHuong(),
      floatingActionButton: _taoNutNoiOGiua(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _taoThanhDieuHuong() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.0,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.analytics_outlined, 1),
            const SizedBox(width: 40),
            _buildNavItem(Icons.camera_alt_outlined, 2),
            _buildNavItem(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _currentIndex == index ? const Color(0xFFC050F6) : Colors.grey.shade400,
        size: 28,
      ),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }

  Widget _taoNutNoiOGiua() {
    return Container(
      width: 65,
      height: 65,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)]),
        boxShadow: [
          BoxShadow(color: Color(0x4C95ADFE), blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
      ),
    );
  }
}
