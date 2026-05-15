import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrifit/modules/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/sleep/views/add_sleep_schedule_screen.dart';
import 'package:nutrifit/modules/sleep/views/add_alarm_screen.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class SleepScheduleScreen extends StatefulWidget {
  const SleepScheduleScreen({super.key});

  @override
  State<SleepScheduleScreen> createState() => _SleepScheduleScreenState();
}

class _SleepScheduleScreenState extends State<SleepScheduleScreen> {
  final controller = Get.find<SleepController>();
  late DateTime _ngayDuocChon;
  late List<DateTime> _danhSachNgay;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    DateTime homNay = DateTime.now();
    _ngayDuocChon = DateTime(homNay.year, homNay.month, homNay.day);
    _taoDanhSachNgay();
  }

  void _taoDanhSachNgay() {
    _danhSachNgay = [];
    for (int i = -3; i <= 30; i++) {
      _danhSachNgay.add(_ngayDuocChon.add(Duration(days: i)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chieuRong = MediaQuery.of(context).size.width;
    String chuoiThangNam = 'Tháng ${_ngayDuocChon.month} ${_ngayDuocChon.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppHeader(
                    title: 'Lịch ngủ',
                    showBackButton: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFFA5A3AF),
                      size: 14,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      chuoiThangNam,
                      style: const TextStyle(
                        color: Color(0xFFA5A3AF),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFA5A3AF),
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.04),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _danhSachNgay.length,
                    itemBuilder: (context, index) =>
                        _taoOChonNgay(_danhSachNgay[index], chieuRong),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  key: ValueKey(_ngayDuocChon),
                  child: Obx(() {
                    final filteredSchedules = controller.schedules.where((item) {
                      bool isRepeating =
                          (item['repeatDays'] as List<dynamic>?)?.any(
                            (e) => e == true,
                          ) ??
                          false;
                      if (isRepeating) {
                        int weekdayIndex = _ngayDuocChon.weekday - 1;
                        return item['repeatDays'][weekdayIndex] == true;
                      } else {
                        DateTime alarmDate = DateTime.parse(item['alarmTime']);
                        return alarmDate.year == _ngayDuocChon.year &&
                            alarmDate.month == _ngayDuocChon.month &&
                            alarmDate.day == _ngayDuocChon.day;
                      }
                    }).toList();

                    if (filteredSchedules.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có lịch trình nào',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.06),
                      itemCount: filteredSchedules.length,
                      itemBuilder: (context, index) {
                        final item = filteredSchedules[index];
                        final alarmTime = DateTime.parse(item['alarmTime']);
                        bool isAlarmOnly = item['type'] == 'alarm';

                        return Dismissible(
                          key: Key(item['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            controller.deleteSchedule(item['id']);
                          },
                          child: GestureDetector(
                            onTap: () {
                              if (isAlarmOnly) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddAlarmScreen(existingSchedule: item),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddSleepScheduleScreen(
                                      existingSchedule: item,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              children: [
                                _taoItemLichTrinh(
                                  '${item['title']}, ',
                                  DateFormat('HH:mm').format(alarmTime),
                                  isAlarmOnly ? 'Báo thức' : 'Lịch ngủ toàn diện',
                                  isAlarmOnly ? 'assets/img/Icon-Alaarm.svg' : 'assets/img/Icon-Bed.svg',
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
            if (_isFabOpen)
              GestureDetector(
                onTap: () => setState(() => _isFabOpen = false),
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabOpen) ...[
            FloatingActionButton.extended(
              heroTag: 'btn1',
              onPressed: () {
                setState(() => _isFabOpen = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAlarmScreen(),
                  ),
                );
              },
              backgroundColor: Colors.white,
              icon: SvgPicture.asset(
                'assets/img/Icon-Alaarm.svg',
                width: 24,
              ),
              label: const Text(
                'Thêm Báo thức',
                style: TextStyle(
                  color: Color(0xFFC050F6),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 15),
            FloatingActionButton.extended(
              heroTag: 'btn2',
              onPressed: () {
                setState(() => _isFabOpen = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSleepScheduleScreen(),
                  ),
                );
              },
              backgroundColor: Colors.white,
              icon: SvgPicture.asset(
                'assets/img/Icon-Bed.svg',
                width: 24,
              ),
              label: const Text(
                'Thêm Lịch ngủ',
                style: TextStyle(
                  color: Color(0xFFC050F6),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
          FloatingActionButton(
            heroTag: 'btnMain',
            onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
            backgroundColor: const Color(0xFFC050F6),
            child: Icon(
              _isFabOpen ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoOChonNgay(DateTime ngay, double chieuRong) {
    bool dangChon =
        ngay.year == _ngayDuocChon.year &&
        ngay.month == _ngayDuocChon.month &&
        ngay.day == _ngayDuocChon.day;
    List<String> tenThu = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return GestureDetector(
      onTap: () => setState(() {
        _ngayDuocChon = ngay;
        _taoDanhSachNgay();
      }),
      child: Container(
        width: chieuRong * 0.16,
        margin: EdgeInsets.symmetric(horizontal: chieuRong * 0.015),
        decoration: BoxDecoration(
          gradient: dangChon
              ? const LinearGradient(
                  colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
                )
              : null,
          color: dangChon ? null : const Color(0xFFF7F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tenThu[ngay.weekday - 1],
              style: TextStyle(
                color: dangChon ? Colors.white : const Color(0xFF7B6F72),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              ngay.day.toString(),
              style: TextStyle(
                color: dangChon ? Colors.white : const Color(0xFF7B6F72),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoItemLichTrinh(
    String tieuDe,
    String gio,
    String phuDe,
    String svgPath,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x111D1617),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            svgPath,
            width: 30,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.alarm, color: Color(0xFFC050F6), size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontFamily: 'Poppins'),
                    children: [
                      TextSpan(
                        text: tieuDe,
                        style: const TextStyle(
                          color: Color(0xFF1D1517),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: gio,
                        style: const TextStyle(
                          color: Color(0xFFB6B4C1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  phuDe,
                  style: const TextStyle(
                    color: Color(0xFFB6B4C1),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit, color: Color(0xFFA5A3AF), size: 20),
        ],
      ),
    );
  }
}
