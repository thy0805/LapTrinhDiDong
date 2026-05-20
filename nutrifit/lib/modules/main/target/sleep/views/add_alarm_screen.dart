import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class AddAlarmScreen extends StatefulWidget {
  final Map<String, dynamic>? existingSchedule;
  const AddAlarmScreen({super.key, this.existingSchedule});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  final controller = Get.find<SleepController>();
  late DateTime alarmTime;
  bool isVibrate = true;
  int snoozeDuration = 5;
  String soundPath = 'assets/audio/alarm.mp3';
  List<bool> selectedDays = List.generate(7, (index) => false);
  final List<String> days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      alarmTime = DateTime.parse(widget.existingSchedule!['alarmTime']);
      isVibrate = widget.existingSchedule!['isVibrate'] ?? true;
      snoozeDuration = widget.existingSchedule!['snoozeDuration'] ?? 5;
      soundPath = widget.existingSchedule!['soundPath'] ?? 'assets/audio/alarm.mp3';
      List<dynamic> savedDays = widget.existingSchedule!['repeatDays'] ?? List.generate(7, (index) => false);
      selectedDays = savedDays.map((e) => e as bool).toList();
    } else {
      alarmTime = DateTime.now().add(Duration(minutes: 5));
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(alarmTime),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        alarmTime = DateTime(
          alarmTime.year,
          alarmTime.month,
          alarmTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chieuRong = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(
                title: widget.existingSchedule != null ? 'Sửa Báo thức' : 'Thêm Báo thức',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(chieuRong * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Center(
              child: GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(alarmTime),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Lặp lại vào các ngày',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDays[index] = !selectedDays[index];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedDays[index]
                          ? Get.theme.colorScheme.primary
                          : (Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: selectedDays[index]
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF)),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: selectedDays[index]
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Âm báo thức',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                DropdownButton<String>(
                  value: soundPath,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  items: [
                    DropdownMenuItem(value: 'assets/audio/alarm.mp3', child: Text('Mặc định', style: TextStyle(fontFamily: 'Poppins'))),
                    DropdownMenuItem(value: 'assets/audio/gentle.mp3', child: Text('Nhẹ nhàng', style: TextStyle(fontFamily: 'Poppins'))),
                    DropdownMenuItem(value: 'assets/audio/nature.mp3', child: Text('Thiên nhiên', style: TextStyle(fontFamily: 'Poppins'))),
                  ],
                  onChanged: (String? val) {
                    if (val != null) setState(() => soundPath = val);
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thời gian nhắc lại (Snooze)',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                DropdownButton<int>(
                  value: snoozeDuration,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  items: [1, 5, 10, 15, 20, 30].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '$value phút',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      if (newValue != null) snoozeDuration = newValue;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.vibration,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                    size: 20,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Rung khi đổ chuông',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Switch(
                    value: isVibrate,
                    onChanged: (val) {
                      setState(() {
                        isVibrate = val;
                      });
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: Get.theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(chieuRong * 0.08),
          child: GestureDetector(
            onTap: () async {
              String title = 'Báo thức';
              if (selectedDays.contains(true)) {
                List<String> activeDays = [];
                for (int i = 0; i < 7; i++) {
                  if (selectedDays[i]) activeDays.add(days[i]);
                }
                title = activeDays.length == 7
                    ? 'Báo thức (Cả tuần)'
                    : 'Báo thức (${activeDays.join(', ')})';
              }

              await controller.addOrUpdateSchedule(
                id: widget.existingSchedule?['id'],
                title: title,
                alarmTime: alarmTime,
                repeatDays: selectedDays,
                snoozeDuration: snoozeDuration,
                isVibrate: isVibrate,
                type: 'alarm',
                soundPath: soundPath,
              );

              Get.back();
              Get.snackbar(
                'Thành công',
                'Đã lưu cấu hình báo thức',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Center(
                child: Text(
                  'Lưu Báo thức',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
