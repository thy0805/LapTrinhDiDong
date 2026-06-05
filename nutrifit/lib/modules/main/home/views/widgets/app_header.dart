import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/views/notification_screen.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<PopupMenuEntry<String>>? extraActions;
  final Function(String)? onActionSelected;

  const AppHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.extraActions,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.back();
                }
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF1E293B)
                      : const Color(0xFFF7F8F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1D1517),
                ),
              ),
            )
          else
            const SizedBox(width: 32),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1D1517),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF1E293B)
                    : const Color(0xFFF7F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_horiz,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1D1517),
              ),
            ),
            onSelected: (value) {
              if (value == 'notifications') {
                Get.to(() => const NotificationScreen());
              } else if (value == 'settings') {
              } else if (onActionSelected != null) {
                onActionSelected!(value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : const Color(0xFF1D1517),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Thông báo',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : const Color(0xFF1D1517),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Cài đặt',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (extraActions != null) ...extraActions!,
            ],
          ),
        ],
      ),
    );
  }
}
