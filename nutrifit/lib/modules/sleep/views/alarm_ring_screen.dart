import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';
import 'package:nutrifit/modules/sleep/controllers/sleep_controller.dart';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;
  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SleepController>();
    DateTime now = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(now),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  alarmSettings.notificationSettings.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const Text(
                    'VUỐT ĐỂ TƯƠNG TÁC',
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(
                              Icons.snooze,
                              color: Colors.white54,
                              size: 30,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(
                              Icons.alarm_off,
                              color: Colors.white54,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // Vuốt phải (Trái sang Phải): Tắt
                            await controller.stopAlarm(alarmSettings.id);
                            Get.back();
                          } else if (direction == DismissDirection.endToStart) {
                            // Vuốt trái (Phải sang Trái): Nhắc lại
                            await controller.snoozeAlarm(alarmSettings);
                            Get.back();
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFC050F6),
                          ),
                          child: const Icon(
                            Icons.alarm,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
