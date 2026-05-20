import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_target_tab.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/nutrition_target_tab.dart';
import 'package:nutrifit/modules/main/target/other/views/other_target_tab.dart';
import 'package:nutrifit/modules/main/target/sleep/views/sleep_target_tab.dart';
import 'package:nutrifit/modules/main/target/other/controllers/target_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/health_service.dart';
import 'package:nutrifit/modules/main/home/views/main_screen.dart';

class TargetSettingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? danhSachHienTai;
  final int? initialIndex;

  const TargetSettingsScreen({super.key, this.danhSachHienTai, this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final TargetController controller = Get.put(TargetController());
    final TargetTabController tabController = Get.find<TargetTabController>();
    
    if (danhSachHienTai != null) {
      controller.initTargets(existingTargets: danhSachHienTai);
    }

    if (initialIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tabController.changeTab(initialIndex!);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: AppHeader(
            title: 'Cài đặt mục tiêu',
            showBackButton: danhSachHienTai != null,
            extraActions: [
              PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF1D1517)),
                    SizedBox(width: 10),
                    Text('Hướng dẫn Fit', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                  ],
                ),
              ),
            ],
            onActionSelected: (value) {
              if (value == 'help') {
                _showGuideDialog(context);
              }
            },
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: tabController.tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Color(0xFFB6B4C1),
          indicatorColor: Theme.of(context).colorScheme.primary,
          isScrollable: true,
          tabs: [
            Tab(text: 'Tập luyện'),
            Tab(text: 'Dinh dưỡng'),
            Tab(text: 'Giấc ngủ'),
            Tab(text: 'Khác'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController.tabController,
        children: [
          WorkoutTargetTab(),
          NutritionTargetTab(),
          SleepTargetTab(),
          OtherTargetTab(),
        ],
      ),
    );
  }
  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text('Hướng dẫn kết nối Fit', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGuideStep(context, '1', 'Tải Google Fit và Health Connect từ Play Store để app có thể lấy dữ liệu vận động.'),
              SizedBox(height: 15),
              _buildGuideStep(context, '2', 'Đăng nhập cùng 1 tài khoản Google trên cả 2 ứng dụng đó.'),
              SizedBox(height: 15),
              _buildGuideStep(context, '3', 'Bấm nút dưới đây để cấp quyền cho NutriFit truy cập dữ liệu sức khỏe.'),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.find<HealthService>().requestPermissions();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text('Cấp quyền ngay', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Đóng', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildGuideStep(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
          child: Text(number, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(fontFamily: 'Poppins', fontSize: 13))),
      ],
    );
  }
}

