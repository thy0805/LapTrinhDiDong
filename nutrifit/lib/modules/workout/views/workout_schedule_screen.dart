import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/workout/views/add_workout_schedule_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> {
  late DateTime _ngayDuocChon;
  late List<DateTime> _danhSachNgay;
  final WorkoutController controller = Get.find<WorkoutController>();

  @override
  void initState() {
    super.initState();
    DateTime homNay = DateTime.now();
    _ngayDuocChon = DateTime(homNay.year, homNay.month, homNay.day);
    _taoDanhSachNgay();
    controller.fetchSchedulesByDate(_ngayDuocChon);
  }

  void _taoDanhSachNgay() {
    _danhSachNgay = [];
    for (int i = -3; i <= 30; i++) {
      _danhSachNgay.add(_ngayDuocChon.add(Duration(days: i)));
    }
  }

  Future<void> _chonNgayTuLich(BuildContext context) async {
    final DateTime? ngayMoi = await showDatePicker(
      context: context,
      initialDate: _ngayDuocChon,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC050F6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D1517),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC050F6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (ngayMoi != null && ngayMoi != _ngayDuocChon) {
      setState(() {
        _ngayDuocChon = ngayMoi;
        _taoDanhSachNgay();
      });
      controller.fetchSchedulesByDate(_ngayDuocChon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    String chuoiThangNam = 'Tháng ${_ngayDuocChon.month} ${_ngayDuocChon.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(
                title: 'Lịch tập luyện',
                showBackButton: true,
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            GestureDetector(
              onTap: () => _chonNgayTuLich(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFFA5A3AF),
                    size: 14,
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  Text(
                    chuoiThangNam,
                    style: const TextStyle(
                      color: Color(0xFFA5A3AF),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFA5A3AF),
                    size: 14,
                  ),
                ],
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            SizedBox(
              height: chieuCao * 0.1,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.04),
                physics: const BouncingScrollPhysics(),
                itemCount: _danhSachNgay.length,
                itemBuilder: (context, index) {
                  return _taoOChonNgay(_danhSachNgay[index], chieuRong);
                },
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSchedules.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    int gio = index + 6;
                    String chuoiGio = '${gio.toString().padLeft(2, '0')}:00';
                    
                    final schedulesInHour = controller.todaySchedules.where((s) {
                      String time = s['time'] ?? '';
                      int scheduleHour = int.tryParse(time.split(':')[0]) ?? -1;
                      return scheduleHour == gio;
                    }).toList();

                    return _taoDongThoiGian(chuoiGio, gio, chieuRong, schedulesInHour);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x4C95ADFE),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddWorkoutScheduleScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _taoOChonNgay(DateTime ngay, double chieuRong) {
    bool dangChon =
        ngay.year == _ngayDuocChon.year &&
        ngay.month == _ngayDuocChon.month &&
        ngay.day == _ngayDuocChon.day;
    List<String> tenThu = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    String thuStr = tenThu[ngay.weekday - 1];

    return GestureDetector(
      onTap: () {
        setState(() {
          _ngayDuocChon = ngay;
          _taoDanhSachNgay();
        });
        controller.fetchSchedulesByDate(_ngayDuocChon);
      },
      child: Container(
        width: chieuRong * 0.16,
        margin: EdgeInsets.symmetric(horizontal: chieuRong * 0.015),
        decoration: BoxDecoration(
          gradient: dangChon
              ? const LinearGradient(
                  colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                )
              : null,
          color: dangChon ? null : const Color(0xFFF7F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              thuStr,
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

  Widget _taoDongThoiGian(
    String chuoiGio,
    int gioThucTe,
    double chieuRong,
    List<Map<String, dynamic>> schedules,
  ) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: chieuRong * 0.06,
            top: 20,
            child: Text(
              chuoiGio,
              style: const TextStyle(
                color: Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Positioned(
            left: chieuRong * 0.2,
            right: chieuRong * 0.08,
            top: 28,
            child: Container(height: 1, color: const Color(0xFFF7F8F8)),
          ),
          if (schedules.isNotEmpty)
            Positioned(
              left: chieuRong * 0.2,
              right: chieuRong * 0.08,
              top: 10,
              child: Column(
                children: schedules.map((s) => _taoTheLichTap(s, chieuRong)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _taoTheLichTap(Map<String, dynamic> schedule, double chieuRong) {
    bool isCompleted = schedule['isCompleted'] ?? false;
    String hinhAnh = schedule['exerciseImage'] ?? 'assets/fullbody.png';
    String scheduleId = schedule['id'];
    String title = schedule['exerciseName'] ?? 'Bài tập';
    String time = schedule['time'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D1617).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isCompleted ? const Color(0xFFC050F6).withValues(alpha: 0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFC050F6).withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: hinhAnh.startsWith('http')
                  ? Image.network(
                      hinhAnh,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.fitness_center, color: Color(0xFFC050F6), size: 20),
                    )
                  : Image.asset(
                      hinhAnh,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.fitness_center, color: Color(0xFFC050F6), size: 20),
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
                    color: const Color(0xFF1D1517),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '$time${isCompleted ? ' • Hoàn thành' : ''}',
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFFC050F6) : const Color(0xFFA5A3AF),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFA5A3AF), size: 20),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWorkoutScheduleScreen(
                      scheduleId: scheduleId,
                      exerciseName: title,
                      exerciseImage: hinhAnh,
                      initialTime: time,
                      initialDate: (schedule['date'] as Timestamp).toDate(),
                      initialRepeatDays: List<bool>.from(schedule['repeatDays']),
                    ),
                  ),
                );
              } else if (value == 'delete') {
                controller.removeSchedule(scheduleId);
              } else if (value == 'toggle') {
                controller.updateScheduleStatus(scheduleId, !isCompleted);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(isCompleted ? 'Bỏ hoàn thành' : 'Đánh dấu hoàn thành'),
              ),
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
    );
  }
}
