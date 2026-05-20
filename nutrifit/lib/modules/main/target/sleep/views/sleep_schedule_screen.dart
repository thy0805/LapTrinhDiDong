import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/sleep/views/add_sleep_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/sleep/views/add_alarm_screen.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: AppHeader(
                    title: 'Lịch ngủ',
                    showBackButton: true,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFFA5A3AF),
                      size: 14,
                    ),
                    SizedBox(width: 20),
                    Text(
                      chuoiThangNam,
                      style: TextStyle(
                        color: Color(0xFFA5A3AF),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(width: 20),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFA5A3AF),
                      size: 14,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.04),
                    physics: BouncingScrollPhysics(),
                    itemCount: _danhSachNgay.length,
                    itemBuilder: (context, index) =>
                        _taoOChonNgay(_danhSachNgay[index], chieuRong),
                  ),
                ),
                SizedBox(height: 30),
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
                        bool alarmMatches = alarmDate.year == _ngayDuocChon.year &&
                            alarmDate.month == _ngayDuocChon.month &&
                            alarmDate.day == _ngayDuocChon.day;
                        bool bedtimeMatches = false;
                        if (item['bedtime'] != null) {
                          DateTime bedtimeDate = DateTime.parse(item['bedtime']);
                          bedtimeMatches = bedtimeDate.year == _ngayDuocChon.year &&
                              bedtimeDate.month == _ngayDuocChon.month &&
                              bedtimeDate.day == _ngayDuocChon.day;
                        }
                        return alarmMatches || bedtimeMatches;
                      }
                    }).toList();

                    if (filteredSchedules.isEmpty) {
                      return Center(
                        child: Text(
                          'Chưa có lịch trình nào',
                          style: TextStyle(fontFamily: 'Poppins', color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72)),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 24,
                      itemBuilder: (context, index) {
                        int gio = index;
                        String chuoiGio = '${gio.toString().padLeft(2, '0')}:00';

                        final schedulesInHour = filteredSchedules.where((s) {
                          bool isAlarmOnly = s['type'] == 'alarm';
                          DateTime alarmTime = DateTime.parse(s['alarmTime']);
                          DateTime? bedtime = s['bedtime'] != null ? DateTime.parse(s['bedtime']) : null;
                          if (isAlarmOnly) {
                            return alarmTime.hour == gio;
                          } else {
                            bool isRepeating =
                                (s['repeatDays'] as List<dynamic>?)?.any(
                                  (e) => e == true,
                                ) ??
                                false;
                            if (isRepeating) {
                              return (bedtime != null && bedtime.hour == gio) || alarmTime.hour == gio;
                            } else {
                              bool showBedtime = bedtime != null &&
                                  bedtime.hour == gio &&
                                  bedtime.year == _ngayDuocChon.year &&
                                  bedtime.month == _ngayDuocChon.month &&
                                  bedtime.day == _ngayDuocChon.day;
                              bool showAlarm = alarmTime.hour == gio &&
                                  alarmTime.year == _ngayDuocChon.year &&
                                  alarmTime.month == _ngayDuocChon.month &&
                                  alarmTime.day == _ngayDuocChon.day;
                              return showBedtime || showAlarm;
                            }
                          }
                        }).toList();

                        return _taoDongThoiGian(chuoiGio, gio, chieuRong, schedulesInHour);
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
                    builder: (context) => AddAlarmScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              icon: SvgPicture.asset(
                'assets/img/Icon-Alaarm.svg',
                width: 24,
                colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Get.theme.colorScheme.primary, BlendMode.srcIn),
              ),
              label: Text(
                'Thêm Báo thức',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Get.theme.colorScheme.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 15),
            FloatingActionButton.extended(
              heroTag: 'btn2',
              onPressed: () {
                setState(() => _isFabOpen = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSleepScheduleScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              icon: SvgPicture.asset(
                'assets/img/Icon-Bed.svg',
                width: 24,
                colorFilter: ColorFilter.mode(Theme.of(context).brightness == Brightness.dark ? Colors.white : Get.theme.colorScheme.primary, BlendMode.srcIn),
              ),
              label: Text(
                'Thêm Lịch ngủ',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Get.theme.colorScheme.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
          FloatingActionButton(
            heroTag: 'btnMain',
            onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
            backgroundColor: Get.theme.colorScheme.primary,
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
              ? LinearGradient(
                  colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                )
              : null,
          color: dangChon ? null : (Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tenThu[ngay.weekday - 1],
              style: TextStyle(
                color: dangChon ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72)),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 5),
            Text(
              ngay.day.toString(),
              style: TextStyle(
                color: dangChon ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72)),
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

  Widget _taoDongThoiGian(
    String chuoiGio,
    int gio,
    double chieuRong,
    List<Map<String, dynamic>> schedules,
  ) {
    double chieuCaoO = schedules.length > 1 ? (schedules.length * 80.0 + 20.0) : 90.0;

    return SizedBox(
      width: chieuRong,
      height: chieuCaoO,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(width: chieuRong, height: chieuCaoO),
          Positioned(
            left: chieuRong * 0.06,
            top: 20,
            child: Text(
              chuoiGio,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Positioned(
            left: chieuRong * 0.2,
            right: chieuRong * 0.08,
            top: 28,
            child: Container(height: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Color(0xFFF7F8F8)),
          ),
          if (schedules.isNotEmpty)
            Positioned(
              left: chieuRong * 0.2,
              right: chieuRong * 0.08,
              top: 10,
              child: Column(
                children: schedules.map((s) {
                  DateTime? bedtime = s['bedtime'] != null ? DateTime.parse(s['bedtime']) : null;
                  bool isBedtimeHour = (bedtime != null && bedtime.hour == gio);
                  return _taoTheLichNguyet(s, isBedtimeHour);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _taoTheLichNguyet(Map<String, dynamic> item, bool isBedtimeHour) {
    String scheduleId = item['id'] ?? '';
    bool isAlarmOnly = item['type'] == 'alarm';
    DateTime alarmTime = DateTime.parse(item['alarmTime']);
    DateTime? bedtime = item['bedtime'] != null ? DateTime.parse(item['bedtime']) : null;

    String title = item['title'] ?? '';
    if (title.isEmpty) {
      title = isAlarmOnly ? 'Báo thức' : 'Lịch ngủ';
    }

    String displayTime = '';
    String displaySubtitle = '';
    String svgPath = '';

    if (isAlarmOnly) {
      displayTime = DateFormat('HH:mm').format(alarmTime);
      displaySubtitle = 'Báo thức thức dậy';
      svgPath = 'assets/img/Icon-Alaarm.svg';
    } else {
      if (isBedtimeHour) {
        displayTime = bedtime != null ? DateFormat('HH:mm').format(bedtime) : '';
        displaySubtitle = 'Đến giờ đi ngủ';
        svgPath = 'assets/img/Icon-Bed.svg';
      } else {
        displayTime = DateFormat('HH:mm').format(alarmTime);
        displaySubtitle = 'Giờ thức dậy';
        svgPath = 'assets/img/Icon-Alaarm.svg';
      }
    }

    return GestureDetector(
      onTap: () {
        if (isAlarmOnly) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAlarmScreen(existingSchedule: item),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSleepScheduleScreen(existingSchedule: item),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.1)
                  : const Color(0xFF1D1617).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SvgPicture.asset(
                    svgPath,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      isBedtimeHour ? Icons.bedtime : Icons.alarm,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$displayTime • $displaySubtitle',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFFA5A3AF),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFFA5A3AF),
                size: 20,
              ),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') {
                  if (isAlarmOnly) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAlarmScreen(existingSchedule: item),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSleepScheduleScreen(existingSchedule: item),
                      ),
                    );
                  }
                } else if (value == 'delete') {
                  controller.deleteSchedule(scheduleId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Chỉnh sửa'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
