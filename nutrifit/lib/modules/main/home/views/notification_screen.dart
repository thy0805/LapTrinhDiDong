import 'package:flutter/material.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Thông báo', showBackButton: true),
            ),
            Expanded(
              child: Obx(() => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                itemCount: controller.notifications.length,
                separatorBuilder: (context, index) => _taoDuongKe(context),
                itemBuilder: (context, index) {
                  final n = controller.notifications[index];
                  return _taoItemThongBao(
                    context,
                    icon: n.icon,
                    gradientColors: n.colors,
                    title: n.title,
                    time: n.timeLabel,
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoDuongKe(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Divider(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFFC6C4D3), thickness: 1, height: 1),
    );
  }

  Widget _taoItemThongBao(
    BuildContext context, {
    required IconData icon,
    required List<Color> gradientColors,
    required String title,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: gradientColors,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                time,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFFB6B4C1),
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Icon(Icons.more_vert, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFFB6B4C1), size: 16),
        ),
      ],
    );
  }
}
