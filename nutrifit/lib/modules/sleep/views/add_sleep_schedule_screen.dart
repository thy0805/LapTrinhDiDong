import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nutrifit/modules/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class AddSleepScheduleScreen extends StatefulWidget {
  final Map<String, dynamic>? existingSchedule;
  const AddSleepScheduleScreen({super.key, this.existingSchedule});

  @override
  State<AddSleepScheduleScreen> createState() => _AddSleepScheduleScreenState();
}

class _AddSleepScheduleScreenState extends State<AddSleepScheduleScreen> {
  final controller = Get.find<SleepController>();
  final nameController = TextEditingController();
  late DateTime bedtime;
  late DateTime alarmTime;
  List<bool> selectedDays = List.generate(7, (index) => false);
  final List<String> days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  bool isVibrate = true;
  int snoozeDuration = 5;
  String soundPath = 'assets/audio/alarm.mp3';

  @override
  void initState() {
    super.initState();
    if (widget.existingSchedule != null) {
      nameController.text = widget.existingSchedule!['title'].toString().split(
        ' (',
      )[0];
      bedtime = DateTime.parse(widget.existingSchedule!['bedtime']);
      alarmTime = DateTime.parse(widget.existingSchedule!['alarmTime']);
      isVibrate = widget.existingSchedule!['isVibrate'] ?? true;
      snoozeDuration = widget.existingSchedule!['snoozeDuration'] ?? 5;
      soundPath =
          widget.existingSchedule!['soundPath'] ?? 'assets/audio/alarm.mp3';
      List<dynamic> savedDays =
          widget.existingSchedule!['repeatDays'] ??
          List.generate(7, (index) => false);
      selectedDays = savedDays.map((e) => e as bool).toList();
    } else {
      bedtime = DateTime.now();
      alarmTime = DateTime.now().add(const Duration(hours: 8));
    }
  }

  Future<void> _selectTime(bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isBedtime ? bedtime : alarmTime),
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
        if (isBedtime) {
          bedtime = DateTime(
            bedtime.year,
            bedtime.month,
            bedtime.day,
            picked.hour,
            picked.minute,
          );
        } else {
          alarmTime = DateTime(
            alarmTime.year,
            alarmTime.month,
            alarmTime.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chieuRong = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(
                title: widget.existingSchedule != null ? 'Sửa Lịch ngủ' : 'Thêm Lịch ngủ',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(chieuRong * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            const Text(
              'Tên lịch ngủ',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ví dụ: Ngủ trưa, Ngủ nướng...',
                  hintStyle: TextStyle(color: Color(0xFFC6C4D3), fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'Giờ đi ngủ',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _selectTime(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(bedtime),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC050F6),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Giờ báo thức',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _selectTime(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(alarmTime),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC050F6),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Lặp lại vào các ngày',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 15),
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
                          ? const Color(0xFFC050F6)
                          : const Color(0xFFF7F8F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        days[index],
                        style: TextStyle(
                          color: selectedDays[index]
                              ? Colors.white
                              : const Color(0xFFA5A3AF),
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Âm báo thức',
                  style: TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                DropdownButton<String>(
                  value: soundPath,
                  items: const [
                    DropdownMenuItem(
                      value: 'assets/audio/alarm.mp3',
                      child: Text(
                        'Mặc định',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'assets/audio/gentle.mp3',
                      child: Text(
                        'Nhẹ nhàng',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'assets/audio/nature.mp3',
                      child: Text(
                        'Thiên nhiên',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                  onChanged: (String? val) {
                    if (val != null) setState(() => soundPath = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thời gian nhắc lại (Snooze)',
                  style: TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                DropdownButton<int>(
                  value: snoozeDuration,
                  items: [1, 5, 10, 15, 20, 30].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '$value phút',
                        style: const TextStyle(fontFamily: 'Poppins'),
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
              String repeatingText = "Chỉ một lần";
              if (selectedDays.contains(true)) {
                List<String> activeDays = [];
                for (int i = 0; i < 7; i++) {
                  if (selectedDays[i]) activeDays.add(days[i]);
                }
                repeatingText = activeDays.length == 7
                    ? "Cả tuần"
                    : activeDays.join(', ');
              }

              await controller.addOrUpdateSchedule(
                id: widget.existingSchedule?['id'],
                title: nameController.text.isEmpty
                    ? 'Lịch ngủ ($repeatingText)'
                    : '${nameController.text} ($repeatingText)',
                bedtime: bedtime,
                alarmTime: alarmTime,
                repeatDays: selectedDays,
                snoozeDuration: snoozeDuration,
                isVibrate: isVibrate,
                type: 'sleep',
                soundPath: soundPath,
              );
              Get.back();
              Get.snackbar(
                'Thành công',
                'Đã lưu lịch ngủ',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Center(
                child: Text(
                  'Lưu Lịch ngủ',
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
