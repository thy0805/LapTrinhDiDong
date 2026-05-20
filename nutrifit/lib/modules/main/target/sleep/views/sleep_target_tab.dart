import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrifit/modules/main/target/sleep/views/sleep_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/sleep/views/add_alarm_screen.dart';
import 'package:nutrifit/modules/main/target/sleep/views/add_sleep_schedule_screen.dart';

class SleepTargetTab extends StatelessWidget {
  const SleepTargetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;
    final sleepController = Get.find<SleepController>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: chieuRong * 0.06,
        vertical: chieuCao * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.tune, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
                onPressed: () => _hienThiSuaMucTieu(context, sleepController),
              ),
              IconButton(
                icon: Icon(Icons.health_and_safety, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
                onPressed: () => sleepController.syncWithHealthFit(),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
                onPressed: () => _hienThiNhapThuCong(context, sleepController),
              ),
            ],
          ),
          Obx(() => _taoBieuDoGiacNgu(chieuRong, sleepController)),
          SizedBox(height: chieuCao * 0.02),
          Obx(() {
            if (sleepController.sleepDebt.value > 0) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF2D1616) : Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${sleepController.userPronoun} đang nợ ngủ ${sleepController.sleepDebt.value.toStringAsFixed(1)} giờ trong tuần này. Hãy cố gắng ngủ đủ giấc nhé!',
                        style: TextStyle(
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
            return SizedBox.shrink();
          }),
          SizedBox(height: chieuCao * 0.02),
          Obx(() => _taoNutTracking(context, sleepController)),
          SizedBox(height: chieuCao * 0.03),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch ngủ hằng ngày',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
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
                        builder: (context) => SleepScheduleScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
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
          Text(
            'Lịch trình hôm nay',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: chieuCao * 0.02),
          Obx(() {
            if (sleepController.schedules.isEmpty) {
              return Padding(
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
              physics: NeverScrollableScrollPhysics(),
              itemCount: sleepController.schedules.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: 15),
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
                if (a.isBefore(now)) a = a.add(Duration(days: 1));
                Duration diff = a.difference(now);

                String amPm = a.hour >= 12 ? 'CH' : 'SA';
                int hour = a.hour > 12
                    ? a.hour - 12
                    : (a.hour == 0 ? 12 : a.hour);

                return _taoItemLichTrinh(
                  context,
                  schedule,
                  sleepController,
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
    );
  }

  void _hienThiSuaMucTieu(BuildContext context, SleepController controller) {
    double tempGoal = controller.targetSleepHours.value;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Thiết lập mục tiêu ngủ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${tempGoal.toStringAsFixed(1)} giờ',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Slider(
                    value: tempGoal,
                    min: 4.0,
                    max: 12.0,
                    divisions: 16,
                    activeColor: Get.theme.colorScheme.primary,
                    onChanged: (val) => setState(() => tempGoal = val),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        controller.updateTargetSleep(tempGoal);
                        Navigator.pop(context);
                      },
                      child: Text(
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
                  SizedBox(height: 20),
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
          title: Text(
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
                leading: Text('😁', style: TextStyle(fontSize: 24)),
                title: Text(
                  'Tươi tỉnh',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.stopTracking('Tươi tỉnh');
                },
              ),
              ListTile(
                leading: Text('😐', style: TextStyle(fontSize: 24)),
                title: Text(
                  'Bình thường',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.stopTracking('Bình thường');
                },
              ),
              ListTile(
                leading: Text('😫', style: TextStyle(fontSize: 24)),
                title: Text(
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
    DateTime startTime = DateTime.now().subtract(Duration(hours: 8));
    DateTime endTime = DateTime.now();
    String mood = 'Bình thường';

    String formatDisplay(DateTime dt) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);

      String dateLabel = '';
      if (date == today) {
        dateLabel = 'Hôm nay';
      } else if (date == today.subtract(Duration(days: 1))) {
        dateLabel = 'Hôm qua';
      } else {
        dateLabel = '${dt.day}/${dt.month}';
      }

      return '$dateLabel  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                left: 25,
                right: 25,
                top: 20,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Thêm giấc ngủ thủ công',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  _buildDateTimeRow(
                    context: context,
                    label: 'Đi ngủ',
                    value: formatDisplay(startTime),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startTime,
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        if (!context.mounted) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(startTime),
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
                    },
                  ),
                  Divider(height: 40, thickness: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Color(0xFFF7F8F8)),
                  
                  _buildDateTimeRow(
                    context: context,
                    label: 'Thức dậy',
                    value: formatDisplay(endTime),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endTime,
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now().add(Duration(days: 1)),
                      );
                      if (pickedDate != null) {
                        if (!context.mounted) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(endTime),
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
                    },
                  ),
                  SizedBox(height: 30),
                  
                  Text(
                    'Cảm giác sau khi dậy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Tươi tỉnh', 'Bình thường', 'Mệt mỏi'].map((m) {
                      bool isSelected = mood == m;
                      String emoji = m == 'Tươi tỉnh' ? '😁' : (m == 'Bình thường' ? '😐' : '😫');
                      return GestureDetector(
                        onTap: () => setState(() => mood = m),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Get.theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Get.theme.colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey[200]!),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(emoji, style: TextStyle(fontSize: 24)),
                              SizedBox(height: 5),
                              Text(m, style: TextStyle(
                                fontSize: 12, 
                                fontFamily: 'Poppins',
                                color: isSelected ? Get.theme.colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey[600]),
                              )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 5,
                        shadowColor: Get.theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      onPressed: () {
                        if (endTime.isBefore(startTime)) {
                          endTime = endTime.add(Duration(days: 1));
                        }
                        controller.saveManualLog(startTime, endTime, mood);
                        Navigator.pop(context);
                        Get.snackbar(
                          'Thành công ✨',
                          'Đã ghi nhận giấc ngủ của ${controller.userName}!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        'LƯU KẾT QUẢ',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimeRow({required BuildContext context, required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72),
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.chevron_right, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72), size: 20),
              ],
            ),
          ],
        ),
      ),
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
        duration: Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: isTracking ? 30 : 15),
        decoration: BoxDecoration(
          color: isTracking ? Get.theme.colorScheme.secondary : Get.theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isTracking
              ? [
                  BoxShadow(
                    color: Get.theme.colorScheme.secondary.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              isTracking ? 'Kết thúc giấc ngủ' : 'Bắt đầu đi ngủ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isTracking) ...[
              SizedBox(height: 15),
              Text(
                controller.trackingDuration.value,
                style: TextStyle(
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
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Get.theme.colorScheme.primary,
            Get.theme.colorScheme.secondary,
          ],
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
                Text(
                  'Giấc ngủ đêm qua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '${gioNgumQua}h ${phutNguHomQua}m',
                  style: TextStyle(
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
                padding: EdgeInsets.symmetric(
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
                        ? Color(0xFF41D641)
                        : Colors.redAccent,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
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
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
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
                            style: TextStyle(
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
                    dotData: FlDotData(show: false),
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
    BuildContext context,
    Map<String, dynamic> schedule,
    SleepController controller,
    String tieuDe,
    String gio,
    String phuDe,
    String svgPath,
  ) {
    return GestureDetector(
      onTap: () {
        bool isAlarmOnly = schedule['type'] == 'alarm';
        if (isAlarmOnly) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAlarmScreen(existingSchedule: schedule),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSleepScheduleScreen(existingSchedule: schedule),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Color(0x111D1617),
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
              errorBuilder: (ctx, error, stackTrace) =>
                  Icon(Icons.alarm, color: Theme.of(context).colorScheme.primary, size: 30),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'Poppins'),
                      children: [
                        TextSpan(
                          text: tieuDe,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: gio,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    phuDe,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                  bool isAlarmOnly = schedule['type'] == 'alarm';
                  if (isAlarmOnly) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAlarmScreen(existingSchedule: schedule),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSleepScheduleScreen(existingSchedule: schedule),
                      ),
                    );
                  }
                } else if (value == 'delete') {
                  controller.deleteSchedule(schedule['id']);
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
