import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/views/home_screen.dart';
import 'package:nutrifit/modules/main/profile/views/profile_screen.dart';
import 'package:nutrifit/modules/main/progress/views/progress_tracker_screen.dart';
import 'package:nutrifit/modules/main/target/other/views/target_settings_screen.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/health_service.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/notification_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/home_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/home/views/ai_assistant_screen.dart';
import 'package:nutrifit/modules/main/progress/views/ai_pose_camera_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/ai_scanner_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/meal_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/sleep/views/sleep_schedule_screen.dart';
import 'package:nutrifit/modules/main/profile/views/support_chat_screen.dart';

class MainScreenController extends GetxController {
  var currentIndex = 0.obs;
  void setTab(int index) {
    currentIndex.value = index;
  }
}

class TargetTabController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
  }
  void changeTab(int index) {
    tabController.animateTo(index);
  }
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  bool _isFanOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    Get.put(HealthService()).init();
    Get.put(SleepController());
    Get.put(NutritionController());
    Get.put(ActivityController());
    Get.put(WorkoutController());
    Get.put(NotificationController());
    Get.put(HomeController());
    Get.put(MainScreenController());
    Get.put(TargetTabController());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFan() {
    setState(() {
      _isFanOpen = !_isFanOpen;
      if (_isFanOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeFan() {
    if (_isFanOpen) {
      setState(() {
        _isFanOpen = false;
        _animationController.reverse();
      });
    }
  }

  final List<Widget> _screens = [
    HomeScreen(),
    TargetSettingsScreen(),
    ProgressTrackerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainScreenController>();
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Obx(() => IndexedStack(index: mainController.currentIndex.value, children: _screens)),
          bottomNavigationBar: _taoThanhDieuHuong(),
          floatingActionButton: _isFanOpen ? const SizedBox.shrink() : _taoNutNoiOGiua(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
        if (_isFanOpen) _buildOverlay(),
        if (_isFanOpen) _buildRadialMenu(),
      ],
    );
  }

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: _closeFan,
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
        ),
      ),
    );
  }

  Widget _buildRadialMenu() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double centerX = width / 2;
    double centerY = height - 70;

    double radius = 125.0;
    final double startAngle = pi;
    final double angleStep = -pi / 4;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final buttons = <Widget>[];
            
            for (int i = 0; i < 5; i++) {
              double angle = startAngle + i * angleStep;
              double x = centerX + radius * cos(angle) * _animation.value;
              double y = centerY - radius * sin(angle) * _animation.value;
              
              buttons.add(
                _buildRadialButton(
                  icon: _getRadialIcon(i),
                  gradientColors: _getRadialGradient(i),
                  label: _getRadialLabel(i),
                  x: x,
                  y: y,
                  onTap: () => _handleRadialTap(i),
                ),
              );
            }
            
            return Stack(children: buttons);
          },
        ),
        Positioned(
          left: centerX - 32.5,
          top: centerY - 32.5,
          child: _taoNutNoiOGiua(),
        ),
      ],
    );
  }

  Widget _buildRadialButton({
    required IconData icon,
    required List<Color> gradientColors,
    required String label,
    required double x,
    required double y,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: x - 40,
      top: y - 50,
      width: 80,
      height: 85,
      child: ScaleTransition(
        scale: _animation,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  _closeFan();
                  onTap();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: gradientColors),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRadialIcon(int index) {
    switch (index) {
      case 0:
        return Icons.auto_awesome;
      case 1:
        return Icons.photo_camera_rounded;
      case 2:
        return Icons.qr_code_scanner_rounded;
      case 3:
        return Icons.calendar_month_rounded;
      case 4:
        return Icons.chat_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  String _getRadialLabel(int index) {
    switch (index) {
      case 0:
        return "Trợ lý AI";
      case 1:
        return "Chụp Body";
      case 2:
        return "Quét món";
      case 3:
        return "Lịch nhanh";
      case 4:
        return "Hỗ trợ";
      default:
        return "";
    }
  }

  List<Color> _getRadialGradient(int index) {
    switch (index) {
      case 0:
        return [Colors.blue, Colors.cyan];
      case 1:
        return [Colors.purple, Colors.pink];
      case 2:
        return [Colors.orange, Colors.amber];
      case 3:
        return [Colors.green, Colors.teal];
      case 4:
        return [Colors.indigo, Colors.blue];
      default:
        return [Colors.blue, Colors.cyan];
    }
  }

  void _handleRadialTap(int index) {
    switch (index) {
      case 0:
        Get.to(() => const AiAssistantScreen());
        break;
      case 1:
        Get.to(() => const AiPoseCameraScreen());
        break;
      case 2:
        Get.to(() => const AiScannerScreen());
        break;
      case 3:
        _showQuickScheduleDialog();
        break;
      case 4:
        Get.to(() => const SupportChatScreen());
        break;
    }
  }

  void _showQuickScheduleDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'LÊN LỊCH NHANH VẠN NĂNG',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 24),
            _buildScheduleItem(
              icon: Icons.alarm_rounded,
              title: 'Lịch ngủ & Báo thức',
              subtitle: 'Cài đặt giờ ngủ nghỉ và chuông báo',
              color: Colors.deepPurple,
              onTap: () {
                Get.back();
                Get.to(() => const SleepScheduleScreen());
              },
            ),
            const SizedBox(height: 12),
            _buildScheduleItem(
              icon: Icons.restaurant_rounded,
              title: 'Lịch ăn uống lành mạnh',
              subtitle: 'Lên thực đơn các buổi ăn trong ngày',
              color: Colors.green,
              onTap: () {
                Get.back();
                Get.to(() => const MealScheduleScreen());
              },
            ),
            const SizedBox(height: 12),
            _buildScheduleItem(
              icon: Icons.fitness_center_rounded,
              title: 'Lịch tập luyện thể thao',
              subtitle: 'Đặt kế hoạch đốt calo mỗi ngày',
              color: Colors.orange,
              onTap: () {
                Get.back();
                Get.to(() => const WorkoutScheduleScreen());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _taoThanhDieuHuong() {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
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
    final mainController = Get.find<MainScreenController>();
    return Obx(() => IconButton(
      icon: Icon(
        icon,
        color: mainController.currentIndex.value == index ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
        size: 28,
      ),
      onPressed: () => mainController.setTab(index),
    ));
  }

  Widget _taoNutNoiOGiua() {
    return GestureDetector(
      onTap: () {
        if (_isFanOpen) {
          _closeFan();
        } else {
          Get.to(() => const AiAssistantScreen());
        }
      },
      onLongPress: () {
        if (!_isFanOpen) {
          _toggleFan();
        }
      },
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _isFanOpen ? 0.125 : 0.0,
            child: Icon(
              _isFanOpen ? Icons.close_rounded : Icons.auto_awesome,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
