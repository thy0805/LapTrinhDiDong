import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrifit/modules/main/target/sleep/views/sleep_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
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
              SizedBox(height: 10),
              Obx(() => _taoBieuDoGiacNgu(chieuRong, sleepController)),
              SizedBox(height: chieuCao * 0.02),
              Obx(() {
                final debt = sleepController.sleepDebt.value;
                Color bgColor;
                Color textColor;
                IconData icon;
                String message;

                if (debt == 0.0) {
                  bgColor = const Color(0xFFE8F5E9);
                  textColor = const Color(0xFF2E7D32);
                  icon = Icons.check_circle_rounded;
                  message = 'Thật tuyệt vời! ${sleepController.userPronoun} đã ngủ rất đầy đủ giấc trong tuần này rồi. Cơ thể đang cực kỳ tràn đầy năng lượng nha! 💚';
                } else if (debt <= 4.0) {
                  bgColor = const Color(0xFFFFF3E0);
                  textColor = const Color(0xFFE65100);
                  icon = Icons.info_rounded;
                  message = '${sleepController.userPronoun == 'ông' ? 'Ông' : 'Bà'} đang hơi thiếu ngủ nhẹ một chút (nợ ngủ ${debt.toStringAsFixed(1)} giờ trong tuần). Nhớ tranh thủ ngủ bù để hồi phục sức khoẻ nhen! 🧡';
                } else {
                  bgColor = const Color(0xFFFFEBEE);
                  textColor = const Color(0xFFC62828);
                  icon = Icons.warning_rounded;
                  message = 'Cảnh báo! ${sleepController.userPronoun == 'ông' ? 'Ông' : 'Bà'} đang thiếu ngủ khá nhiều đó nha (nợ ngủ ${debt.toStringAsFixed(1)} giờ trong tuần). Phải sắp xếp đi ngủ sớm ngay đi nè! 💔';
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: textColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: chieuCao * 0.02),
              Obx(() => _taoNutTracking(context, sleepController)),
              SizedBox(height: chieuCao * 0.03),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
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
                            colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
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
                  color: Color(0xFF1D1517),
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
                color: Colors.white,
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
                        color: Colors.grey[300],
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
                      color: Color(0xFF1D1517),
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // Row Đi ngủ
                  _buildDateTimeRow(
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
                  Divider(height: 40, thickness: 1, color: Color(0xFFF7F8F8)),
                  
                  // Row Thức dậy
                  _buildDateTimeRow(
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
                      color: Color(0xFF1D1517),
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
                              color: isSelected ? Get.theme.colorScheme.primary : Colors.grey[200]!,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(emoji, style: TextStyle(fontSize: 24)),
                              SizedBox(height: 5),
                              Text(m, style: TextStyle(
                                fontSize: 12, 
                                fontFamily: 'Poppins',
                                color: isSelected ? Get.theme.colorScheme.primary : Colors.grey[600],
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

  Widget _buildDateTimeRow({required String label, required String value, required VoidCallback onTap}) {
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
                color: Color(0xFF1D1517),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Color(0xFF7B6F72),
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.chevron_right, color: Color(0xFF7B6F72), size: 20),
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
    String tieuDe,
    String gio,
    String phuDe,
    String svgPath,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
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
            decoration: BoxDecoration(
              color: Color(0xFFF7F8F8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Get.theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: tieuDe,
                    style: TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: gio,
                        style: TextStyle(
                          color: Color(0xFFA5A3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  phuDe,
                  style: TextStyle(
                    color: Color(0xFFA5A3AF),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Color(0xFFB6B4C1),
          ),
        ],
      ),
    );
  }
}
