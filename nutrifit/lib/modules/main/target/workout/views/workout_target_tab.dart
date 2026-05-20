import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/exercise_details_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/exercise_management_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/add_workout_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';

class WorkoutTargetTab extends StatelessWidget {
  const WorkoutTargetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkoutController controller = Get.put(WorkoutController());

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _taoBieuDoWorkout(),
          SizedBox(height: 20),
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
                  'Lịch tập hàng ngày',
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
                        builder: (context) => WorkoutScheduleScreen(),
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
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bài tập hôm nay',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseManagementScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Thêm ngay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Obx(() {
            if (controller.isLoadingSchedules.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.todaySchedules.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Chưa có bài tập nào cho hôm nay!',
                    style: TextStyle(
                      color: Color(0xFFB6B4C1),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.todaySchedules.length,
              itemBuilder: (context, index) {
                final schedule = controller.todaySchedules[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: TodayWorkoutItemWidget(
                    schedule: schedule,
                    controller: controller,
                    title: schedule['exerciseName'] ?? 'Bài tập',
                    time: schedule['time'] ?? '--:--',
                    scheduleId: schedule['id'] ?? '',
                    isCompleted: schedule['isCompleted'] ?? false,
                    hinhAnh: (schedule['exerciseImage'] != null && schedule['exerciseImage'].toString().isNotEmpty)
                        ? schedule['exerciseImage']
                        : 'assets/fullbody.png',
                    mauNen: Color(0xFF00EFFF),
                  ),
                );
              },
            );
          }),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách bài tập',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseManagementScreen(),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseManagementScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4C95ADFE),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quản lý bài tập của bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoBieuDoWorkout() {
    final WorkoutController controller = Get.find<WorkoutController>();
    return Container(
      width: double.infinity,
      height: 240,
      padding: EdgeInsets.only(top: 25, bottom: 5, left: 15, right: 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4C95ADFE),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        double maxVal = 100.0;
        for (var val in controller.weeklyCompletionData) {
          if (val > maxVal) {
            maxVal = val;
          }
        }
        maxVal = ((maxVal / 20).ceil() * 20).toDouble();

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withValues(alpha: 0.2),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  interval: 20,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int v = value.toInt();
                    if (v < 0 || v > 6) return SizedBox();
                    
                    DateTime targetDate = DateTime.now().subtract(Duration(days: 6 - v));
                    List<String> thuList = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                    String thuStr = thuList[targetDate.weekday - 1];
                    String dateStr = '${targetDate.day}/${targetDate.month}';
                    
                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Text(
                        '$thuStr\n$dateStr',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          height: 1.2,
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
            maxY: maxVal,
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(controller.weeklyCompletionData.length, (index) {
                  return FlSpot(index.toDouble(), controller.weeklyCompletionData[index]);
                }),
                isCurved: true,
                color: Colors.white,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 1,
                        strokeColor: Get.theme.colorScheme.primary,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class TodayWorkoutItemWidget extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final WorkoutController controller;
  final String title;
  final String time;
  final String scheduleId;
  final bool isCompleted;
  final String hinhAnh;
  final Color mauNen;

  const TodayWorkoutItemWidget({
    super.key,
    required this.schedule,
    required this.controller,
    required this.title,
    required this.time,
    required this.scheduleId,
    required this.isCompleted,
    required this.hinhAnh,
    required this.mauNen,
  });

  @override
  State<TodayWorkoutItemWidget> createState() => _TodayWorkoutItemWidgetState();
}

class _TodayWorkoutItemWidgetState extends State<TodayWorkoutItemWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final combo = widget.controller.combos.firstWhereOrNull((c) => c.title == widget.title);

    String detailSubtitle = '';
    if (combo != null) {
      detailSubtitle = 'Tổng số bài tập: ${combo.exerciseIds.length} bài';
    } else {
      final exercise = widget.controller.allExercises.firstWhereOrNull((e) => e.title == widget.title);
      bool isCardio = exercise != null && (exercise.category.toLowerCase() == 'cardio' || exercise.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'));
      int sets = widget.schedule['sets'] ?? 3;
      int reps = widget.schedule['reps'] ?? 10;
      double weight = (widget.schedule['weight'] is num) ? (widget.schedule['weight'] as num).toDouble() : 0.0;
      int restTime = widget.schedule['restTime'] ?? 60;
      detailSubtitle = '$sets hiệp | $reps ${isCardio ? 'giây' : 'lần'}${weight > 0.0 ? ' | tạ ${weight.toStringAsFixed(1)}kg' : ''} | nghỉ ${restTime}s';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Color(0x111D1617),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
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
                      scheduleId: widget.scheduleId,
                      isCompleted: widget.isCompleted,
                    ),
                  ),
                );
                return;
              }

              final exercise = await widget.controller.getExerciseByName(widget.title);
              if (exercise != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailsScreen(
                      exercise: exercise,
                      scheduleId: widget.scheduleId,
                      isCompleted: widget.isCompleted,
                      initialReps: widget.schedule['reps'] ?? 10,
                      initialSets: widget.schedule['sets'] ?? 3,
                      initialWeight: (widget.schedule['weight'] is num) ? (widget.schedule['weight'] as num).toDouble() : 0.0,
                      initialRestTime: widget.schedule['restTime'] ?? 60,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              color: Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: widget.mauNen.withValues(alpha: 0.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.hinhAnh.startsWith('http')
                          ? Image.network(
                              widget.hinhAnh,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image, color: widget.mauNen),
                            )
                          : Image.asset(
                              widget.hinhAnh,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image, color: widget.mauNen),
                            ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${widget.time} • $detailSubtitle${widget.isCompleted ? ' • Hoàn thành' : ''}',
                          style: TextStyle(
                            color: widget.isCompleted ? Theme.of(context).colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF)),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (combo != null)
                    IconButton(
                      icon: Icon(
                        _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                      ),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFFA5A3AF)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        DateTime dateToPass;
                        if (widget.schedule['date'] != null && widget.schedule['date'] is Timestamp) {
                          dateToPass = (widget.schedule['date'] as Timestamp).toDate();
                        } else if (widget.schedule['date'] is DateTime) {
                          dateToPass = widget.schedule['date'] as DateTime;
                        } else {
                          dateToPass = DateTime.now();
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddWorkoutScheduleScreen(
                              scheduleId: widget.scheduleId,
                              exerciseName: widget.title,
                              exerciseImage: widget.hinhAnh,
                              initialTime: widget.time,
                              initialDate: dateToPass,
                              initialRepeatDays: widget.schedule['repeatDays'] != null
                                  ? List<bool>.from(widget.schedule['repeatDays'])
                                  : [false, false, false, false, false, false, false],
                              initialReps: widget.schedule['reps'] ?? 15,
                              initialSets: widget.schedule['sets'] ?? 3,
                              initialWeight: (widget.schedule['weight'] is num) ? (widget.schedule['weight'] as num).toDouble() : 0.0,
                              initialRestTime: widget.schedule['restTime'] ?? 60,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        widget.controller.removeSchedule(widget.scheduleId);
                      } else if (value == 'toggle') {
                        widget.controller.updateScheduleStatus(widget.scheduleId, !widget.isCompleted);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(widget.isCompleted ? 'Bỏ hoàn thành' : 'Đánh dấu hoàn thành'),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Chỉnh sửa'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa', style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: combo != null && _expanded
                ? Column(
                    children: [
                      const Divider(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Column(
                          children: combo.exerciseIds.map((exId) {
                            final ex = widget.controller.allExercises.firstWhereOrNull((e) => e.id == exId);
                            if (ex == null) return const SizedBox();

                            final bool isExCardio = ex.category.toLowerCase() == 'cardio' || ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio');
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
                                      isCompleted: widget.isCompleted,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedImageWidget(
                                          id: ex.id,
                                          type: 'exercises',
                                          url: ex.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.title,
                                            style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '$exSets hiệp | $exReps ${isExCardio ? 'giây' : 'lần'}${exWeight > 0.0 ? ' | tạ ${exWeight.toStringAsFixed(1)}kg' : ''} | nghỉ ${exRest}s',
                                            style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
