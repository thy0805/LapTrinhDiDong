import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/target/workout/views/add_workout_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_details_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/exercise_details_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/exercise_management_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'dart:io';
import 'package:nutrifit/core/services/media_service.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> {
  late DateTime _ngayDuocChon;
  late List<DateTime> _danhSachNgay;
  late WorkoutController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WorkoutController>();
    DateTime homNay = DateTime.now();
    _ngayDuocChon = DateTime(homNay.year, homNay.month, homNay.day);
    _taoDanhSachNgay();
    controller.fetchSchedulesForSelectedDate(_ngayDuocChon);
  }

  @override
  void dispose() {
    controller.isLoadingSelectedDateSchedules.value = false;
    super.dispose();
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
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
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
      controller.fetchSchedulesForSelectedDate(_ngayDuocChon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    String chuoiThangNam = 'Tháng ${_ngayDuocChon.month} ${_ngayDuocChon.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Lịch tập luyện', showBackButton: true),
            ),
            SizedBox(height: chieuCao * 0.02),
            GestureDetector(
              onTap: () => _chonNgayTuLich(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Color(0xFFA5A3AF),
                    size: 14,
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  Text(
                    chuoiThangNam,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Color(0xFFA5A3AF),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Color(0xFFA5A3AF),
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
                physics: BouncingScrollPhysics(),
                itemCount: _danhSachNgay.length,
                itemBuilder: (context, index) {
                  return _taoOChonNgay(_danhSachNgay[index], chieuRong);
                },
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSelectedDateSchedules.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    int gio = index;
                    String chuoiGio = '${gio.toString().padLeft(2, '0')}:00';

                    final schedulesInHour = controller.selectedDateSchedules
                        .where((s) {
                          try {
                            String time = s['time']?.toString() ?? '';
                            if (time.isEmpty) return false;
                            int scheduleHour =
                                int.tryParse(time.split(':')[0]) ?? -1;
                            return scheduleHour == gio;
                          } catch (e) {
                            return false;
                          }
                        })
                        .toList();

                    return _taoDongThoiGian(
                      chuoiGio,
                      gio,
                      chieuRong,
                      schedulesInHour,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
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
          heroTag: 'workout_schedule_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExerciseManagementScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white),
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
        });
        controller.fetchSchedulesForSelectedDate(_ngayDuocChon);
      },
      child: Container(
        width: chieuRong * 0.16,
        margin: EdgeInsets.symmetric(horizontal: chieuRong * 0.015),
        decoration: BoxDecoration(
          gradient: dangChon
              ? LinearGradient(
                  colors: [
                    Get.theme.colorScheme.primary,
                    Get.theme.colorScheme.secondary,
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                )
              : null,
          color: dangChon
              ? null
              : (Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF1E293B)
                    : Color(0xFFF7F8F8)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              thuStr,
              style: TextStyle(
                color: dangChon
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Color(0xFF7B6F72)),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 5),
            Text(
              ngay.day.toString(),
              style: TextStyle(
                color: dangChon
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Color(0xFF7B6F72)),
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
    double chieuCaoO = schedules.length > 1
        ? (schedules.length * 75.0 + 20.0)
        : 80.0;

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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Positioned(
            left: chieuRong * 0.2,
            right: chieuRong * 0.08,
            top: 28,
            child: Container(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Color(0xFFF7F8F8),
            ),
          ),
          if (schedules.isNotEmpty)
            Positioned(
              left: chieuRong * 0.2,
              right: chieuRong * 0.08,
              top: 10,
              child: Column(
                children: schedules
                    .map(
                      (s) => ScheduleWorkoutItemWidget(
                        schedule: s,
                        controller: controller,
                        chieuRong: chieuRong,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class ScheduleWorkoutItemWidget extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final WorkoutController controller;
  final double chieuRong;

  const ScheduleWorkoutItemWidget({
    super.key,
    required this.schedule,
    required this.controller,
    required this.chieuRong,
  });

  @override
  State<ScheduleWorkoutItemWidget> createState() =>
      _ScheduleWorkoutItemWidgetState();
}

class _ScheduleWorkoutItemWidgetState extends State<ScheduleWorkoutItemWidget> {
  bool _expanded = false;

  Widget _buildScheduleImage(String hinhAnh, String title) {
    if (!hinhAnh.startsWith('http')) {
      return Image.asset(
        hinhAnh.isNotEmpty ? hinhAnh : 'assets/fullbody.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.fitness_center,
          color: Get.theme.colorScheme.primary,
          size: 20,
        ),
      );
    }

    final mediaService = Get.find<MediaService>();
    final exercise = widget.controller.allExercises.firstWhereOrNull(
      (e) => e.title == title,
    );

    if (exercise != null) {
      final localPath = mediaService.getLocalPath(
        exercise.id,
        'exercises',
        hinhAnh,
      );
      if (mediaService.isFileExists(localPath)) {
        return Image.file(
          File(localPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.fitness_center,
            color: Get.theme.colorScheme.primary,
            size: 20,
          ),
        );
      }
    }

    return Image.network(
      hinhAnh,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.fitness_center,
        color: Get.theme.colorScheme.primary,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = widget.schedule['isCompleted'] ?? false;
    String imageValue = widget.schedule['exerciseImage'] ?? '';
    String hinhAnh = imageValue.isEmpty ? 'assets/fullbody.png' : imageValue;
    String scheduleId = widget.schedule['id'] ?? '';
    String title = widget.schedule['exerciseName'] ?? 'Bài tập';
    String time = widget.schedule['time'] ?? '';

    final combo = widget.controller.combos.firstWhereOrNull(
      (c) => c.title == title,
    );

    String detailSubtitle = '';
    if (combo != null) {
      detailSubtitle = 'Tổng số bài tập: ${combo.exerciseIds.length} bài';
    } else {
      final exercise = widget.controller.allExercises.firstWhereOrNull(
        (e) => e.title == title,
      );
      bool isCardio =
          exercise != null &&
          (exercise.category.toLowerCase() == 'cardio' ||
              exercise.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'));
      int sets = widget.schedule['sets'] ?? 3;
      int reps = widget.schedule['reps'] ?? 10;
      double weight = (widget.schedule['weight'] is num)
          ? (widget.schedule['weight'] as num).toDouble()
          : 0.0;
      int restTime = widget.schedule['restTime'] ?? 60;
      detailSubtitle =
          '$sets hiệp | $reps ${isCardio ? 'giây' : 'lần'}${weight > 0.0 ? ' | tạ ${weight.toStringAsFixed(1)}kg' : ''} | nghỉ ${restTime}s';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.1)
                : Color(0xFF1D1617).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isCompleted
              ? Get.theme.colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              if (combo != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutDetailsScreen(
                      combo: combo,
                      scheduleId: scheduleId,
                      isCompleted: isCompleted,
                    ),
                  ),
                );
                return;
              }

              final exercise = await widget.controller.getExerciseByName(title);
              if (exercise != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailsScreen(
                      exercise: exercise,
                      scheduleId: scheduleId,
                      isCompleted: isCompleted,
                      initialReps: widget.schedule['reps'] ?? 10,
                      initialSets: widget.schedule['sets'] ?? 3,
                      initialWeight: (widget.schedule['weight'] is num)
                          ? (widget.schedule['weight'] as num).toDouble()
                          : 0.0,
                      initialRestTime: widget.schedule['restTime'] ?? 60,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Get.theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildScheduleImage(hinhAnh, title),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Color(0xFF1D1517),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          '$time • $detailSubtitle${isCompleted ? ' • Hoàn thành' : ''}',
                          style: TextStyle(
                            color: isCompleted
                                ? Get.theme.colorScheme.primary
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade400
                                      : Color(0xFFA5A3AF)),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (combo != null)
                    IconButton(
                      icon: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color(0xFF1D1517),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Color(0xFFA5A3AF),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddWorkoutScheduleScreen(
                              exerciseName: title,
                              exerciseImage: hinhAnh,
                              initialTime: time,
                              scheduleId: scheduleId,
                              initialDate:
                                  (widget.schedule['date'] != null &&
                                      widget.schedule['date'] is Timestamp)
                                  ? (widget.schedule['date'] as Timestamp)
                                        .toDate()
                                  : (widget.schedule['date'] is DateTime
                                        ? widget.schedule['date'] as DateTime
                                        : DateTime.now()),
                              initialRepeatDays:
                                  widget.schedule['repeatDays'] != null
                                  ? List<bool>.from(
                                      widget.schedule['repeatDays'],
                                    )
                                  : [
                                      false,
                                      false,
                                      false,
                                      false,
                                      false,
                                      false,
                                      false,
                                    ],
                              initialReps: widget.schedule['reps'] ?? 15,
                              initialSets: widget.schedule['sets'] ?? 3,
                              initialWeight: (widget.schedule['weight'] is num)
                                  ? (widget.schedule['weight'] as num)
                                        .toDouble()
                                  : 0.0,
                              initialRestTime:
                                  widget.schedule['restTime'] ?? 60,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        widget.controller.removeSchedule(scheduleId);
                      } else if (value == 'toggle') {
                        widget.controller.updateScheduleStatus(
                          scheduleId,
                          !isCompleted,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(
                          isCompleted ? 'Bỏ hoàn thành' : 'Đánh dấu hoàn thành',
                        ),
                      ),
                      PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Xóa',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (combo != null && _expanded) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: combo.exerciseIds.map((exId) {
                  final ex = widget.controller.allExercises.firstWhereOrNull(
                    (e) => e.id == exId,
                  );
                  if (ex == null) return const SizedBox();

                  final bool isExCardio =
                      ex.category.toLowerCase() == 'cardio' ||
                      ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio');
                  final int exSets = combo.exerciseSets[exId] ?? 3;
                  final int exReps = combo.exerciseReps[exId] ?? 10;
                  final double exWeight = combo.exerciseWeights[exId] ?? 0.0;
                  final int exRest = combo.exerciseRestTimes[exId] ?? 60;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailsScreen(
                            exercise: ex,
                            comboId: combo.id,
                            initialReps: exReps,
                            initialSets: exSets,
                            initialWeight: exWeight,
                            initialRestTime: exRest,
                            isCompleted: isCompleted,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Get.theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedImageWidget(
                                id: ex.id,
                                type: 'exercises',
                                url: ex.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.title,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Color(0xFF1D1517),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$exSets hiệp | $exReps ${isExCardio ? 'giây' : 'lần'}${exWeight > 0.0 ? ' | tạ ${exWeight.toStringAsFixed(1)}kg' : ''} | nghỉ ${exRest}s',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade400
                                        : Color(0xFFA5A3AF),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
