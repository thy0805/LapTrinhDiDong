import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:nutrifit/modules/workout/controllers/activity_controller.dart';

class AppNotification {
  final String id;
  final String title;
  final String timeLabel;
  final DateTime timestamp;
  final IconData icon;
  final List<Color> colors;

  AppNotification({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.timestamp,
    required this.icon,
    required this.colors,
  });
}

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;
  Timer? _hourlyTimer;

  @override
  void onInit() {
    super.onInit();
    _generateInitialNotifications();
    _startHourlyTimer();
  }

  @override
  void onClose() {
    _hourlyTimer?.cancel();
    super.onClose();
  }

  void _generateInitialNotifications() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour > 7) {
      addNotification('Khởi đầu ngày mới với 1 ly nước nhé! ✨', Icons.local_drink, [const Color(0xFF00FF66), const Color(0xFF00EFFF)]);
    }
    if (hour > 12) {
      addNotification('Đã đến giờ ăn trưa rồi, nạp năng lượng thôi! 🥗', Icons.lunch_dining, [const Color(0xFFC050F6), const Color(0xFFEEA4CE)]);
    }
    
    _cleanOldNotifications();
  }

  void _startHourlyTimer() {
    _hourlyTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _addSmartReminder();
      _cleanOldNotifications();
    });
  }

  void _addSmartReminder() {
    final now = DateTime.now();
    final hour = now.hour;
    final activityController = Get.find<ActivityController>();

    String title = 'Đã đến giờ kiểm tra tiến độ sức khỏe của bạn rồi!';
    IconData icon = Icons.notifications_active;
    List<Color> colors = [const Color(0xFFCC8FED), const Color(0xFF6B50F6)];

    if (hour >= 22) {
      title = 'Sắp đến giờ đi ngủ rồi, hãy thư giãn một chút nhé. 🌙';
      icon = Icons.bedtime;
    } else if (hour >= 18) {
      if (activityController.steps.value < activityController.stepTarget.value) {
        title = 'Bạn còn một chút nữa là đạt mục tiêu bước chân rồi, cố lên! 🔥';
        icon = Icons.directions_walk;
      }
    } else if (hour >= 11 && hour <= 13) {
      title = 'Đừng quên ghi lại bữa trưa của mình nhé! 🍽️';
      icon = Icons.restaurant;
    }

    addNotification(title, icon, colors);
  }

  void _cleanOldNotifications() {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    notifications.removeWhere((n) => n.timestamp.isBefore(oneDayAgo));
  }

  void addNotification(String title, IconData icon, List<Color> colors) {
    if (notifications.isNotEmpty && notifications.first.title == title) return;

    notifications.insert(0, AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      timeLabel: 'Vừa xong',
      timestamp: DateTime.now(),
      icon: icon,
      colors: colors,
    ));
    _cleanOldNotifications();
  }

  void removeNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  void clearAll() {
    notifications.clear();
  }
}
