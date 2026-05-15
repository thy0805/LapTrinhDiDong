import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrifit/modules/sleep/views/sleep_schedule_screen.dart';
import 'package:nutrifit/modules/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class SleepTrackerScreen extends StatelessWidget {
  const SleepTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;
    final sleepController = Get.find<SleepController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: chieuRong * 0.06,
            vertical: chieuCao * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: 'Theo dõi giấc ngủ',
                showBackButton: true,
                extraActions: const [
                  PopupMenuItem(
                    value: 'set_goal',
                    child: Row(
                      children: [
                        Icon(Icons.tune, size: 20, color: Color(0xFF1D1517)),
                        SizedBox(width: 10),
                        Text('Mục tiêu ngủ', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'sync_health',
                    child: Row(
                      children: [
                        Icon(Icons.sync, size: 20, color: Color(0xFF1D1517)),
                        SizedBox(width: 10),
                        Text('Đồng bộ Health', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add_manual',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF1D1517)),
                        SizedBox(width: 10),
                        Text('Thêm thủ công', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                onActionSelected: (value) {
                  if (value == 'set_goal') {
                    _hienThiSuaMucTieu(context, sleepController);
                  } else if (value == 'sync_health') {
                    sleepController.syncWithHealthFit();
                  } else if (value == 'add_manual') {
                    _hienThiNhapThuCong(context, sleepController);
                  }
                },
              ),
              const SizedBox(height: 10),
              Obx(() => _taoBieuDoGiacNgu(chieuRong, sleepController)),
              SizedBox(height: chieuCao * 0.02),
              Obx(() {
                if (sleepController.sleepDebt.value > 0) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Bạn đang nợ ngủ ${sleepController.sleepDebt.value.toStringAsFixed(1)} giờ trong tuần này. Hãy cố gắng ngủ đủ giấc nhé!',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              SizedBox(height: chieuCao * 0.02),
              Obx(() => _taoNutTracking(context, sleepController)),
              SizedBox(height: chieuCao * 0.03),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFC050F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lịch ngủ hằng ngày',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SleepScheduleScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          'Kiểm tra',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: chieuCao * 0.04),
              const Text(
                'Lịch trình hôm nay',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: chieuCao * 0.02),
              Obx(() {
                if (sleepController.schedules.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Chưa có lịch trình nào cho hôm nay',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF7B6F72),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sleepController.schedules.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    var schedule = sleepController.schedules[index];
                    bool isBedtime =
                        schedule['bedtime'] != null &&
                        schedule['type'] != 'alarm';
                    DateTime time = DateTime.parse(
                      isBedtime ? schedule['bedtime'] : schedule['alarmTime'],
                    );

                    DateTime now = DateTime.now();
                    DateTime a = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      time.hour,
                      time.minute,
                    );
                    if (a.isBefore(now)) a = a.add(const Duration(days: 1));
                    Duration diff = a.difference(now);

                    String amPm = a.hour >= 12 ? 'CH' : 'SA';
                    int hour = a.hour > 12
                        ? a.hour - 12
                        : (a.hour == 0 ? 12 : a.hour);

                    return _taoItemLichTrinh(
                      isBedtime ? 'Bedtime, ' : 'Alarm, ',
                      '${hour.toString().padLeft(2, '0')}:${a.minute.toString().padLeft(2, '0')} $amPm',
                      'trong ${diff.inHours} giờ ${diff.inMinutes % 60} phút',
                      isBedtime
                          ? 'assets/img/Icon-Bed.svg'
                          : 'assets/img/Icon-Alaarm.svg',
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _hienThiSuaMucTieu(BuildContext context, SleepController controller) {
    double tempGoal = controller.targetSleepHours.value;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Thiết lập mục tiêu ngủ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${tempGoal.toStringAsFixed(1)} giờ',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC050F6),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Slider(
                    value: tempGoal,
                    min: 4.0,
                    max: 12.0,
                    divisions: 16,
                    activeColor: const Color(0xFFC050F6),
                    onChanged: (val) => setState(() => tempGoal = val),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC050F6),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        controller.updateTargetSleep(tempGoal);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Lưu mục tiêu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _hienThiPopupCamXuc(BuildContext context, SleepController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sáng nay dậy thấy thế nào?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('😁', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'Tươi tỉnh',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.stopTracking('Tươi tỉnh');
                },
              ),
              ListTile(
                leading: const Text('😐', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'Bình thường',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.stopTracking('Bình thường');
                },
              ),
              ListTile(
                leading: const Text('😫', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'Mệt mỏi',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.stopTracking('Mệt mỏi');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _hienThiNhapThuCong(BuildContext context, SleepController controller) {
    DateTime startTime = DateTime.now().subtract(const Duration(hours: 8));
    DateTime endTime = DateTime.now();
    String mood = 'Bình thường';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String formatDT(DateTime dt) {
              return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thêm giấc ngủ thủ công',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text(
                      'Bắt đầu ngủ',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      formatDT(startTime),
                      style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFFC050F6)),
                    ),
                    trailing: const Icon(Icons.calendar_month, color: Color(0xFFC050F6)),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        if (context.mounted) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startTime),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (pickedTime != null) {
                            setState(() {
                              startTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      'Kết thúc ngủ',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      formatDT(endTime),
                      style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFFC050F6)),
                    ),
                    trailing: const Icon(Icons.calendar_month, color: Color(0xFFC050F6)),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        if (context.mounted) {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(endTime),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (pickedTime != null) {
                            setState(() {
                              endTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: mood,
                    items: ['Tươi tỉnh', 'Bình thường', 'Mệt mỏi']
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => mood = val);
                    },
                    decoration: InputDecoration(
                      labelText: 'Cảm giác',
                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC050F6),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (endTime.isBefore(startTime)) {
                          Get.snackbar(
                            'Lỗi',
                            'Thời gian kết thúc phải sau thời gian bắt đầu',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        controller.saveManualLog(startTime, endTime, mood);
                        Navigator.pop(context);
                        Get.snackbar(
                          'Thành công',
                          'Đã thêm giấc ngủ thủ công',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: const Text(
                        'Lưu',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _taoNutTracking(BuildContext context, SleepController controller) {
    bool isTracking = controller.isTracking.value;
    return GestureDetector(
      onTap: () {
        if (isTracking) {
          _hienThiPopupCamXuc(context, controller);
        } else {
          controller.startTracking();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isTracking ? 30 : 15),
        decoration: BoxDecoration(
          color: isTracking ? const Color(0xFFEEA4CE) : const Color(0xFFC050F6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isTracking
              ? [
                  BoxShadow(
                    color: const Color(0xFFEEA4CE).withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              isTracking ? 'Kết thúc giấc ngủ' : 'Bắt đầu đi ngủ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isTracking) ...[
              const SizedBox(height: 15),
              Text(
                controller.trackingDuration.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _taoBieuDoGiacNgu(double chieuRong, SleepController controller) {
    int gioNgumQua = controller.lastNightSleep.value.floor();
    int phutNguHomQua = ((controller.lastNightSleep.value - gioNgumQua) * 60)
        .round();

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Color(0xFF00FF66), Color(0xFF00EFFF)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giấc ngủ đêm qua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${gioNgumQua}h ${phutNguHomQua}m',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (controller.sleepTrend.value != 0)
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${controller.sleepTrend.value > 0 ? '+' : ''}${controller.sleepTrend.value.toStringAsFixed(0)}% increase',
                  style: TextStyle(
                    color: controller.sleepTrend.value > 0
                        ? const Color(0xFF41D641)
                        : Colors.redAccent,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(
              top: 80,
              bottom: 10,
              left: 10,
              right: 20,
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                        );
                        Widget text;
                        String label = '';
                        int index = value.toInt();
                        if (index >= 0 &&
                            index < controller.weeklyLabels.length) {
                          label = controller.weeklyLabels[index];
                        }
                        text = Text(label, style: style);
                        return SideTitleWidget(meta: meta, child: text);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 4,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${value.toInt()}h',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 12,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: controller.targetSleepHours.value,
                      color: Colors.white.withValues(alpha: 0.8),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.weeklySleepData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8F8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFC050F6),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: tieuDe,
                    style: const TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: gio,
                        style: const TextStyle(
                          color: Color(0xFFA5A3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  phuDe,
                  style: const TextStyle(
                    color: Color(0xFFA5A3AF),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_right,
            color: Color(0xFFB6B4C1),
          ),
        ],
      ),
    );
  }
}
