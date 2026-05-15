import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/workout/views/workout_schedule_screen.dart';
import 'package:nutrifit/modules/workout/views/exercise_details_screen.dart';
import 'package:nutrifit/modules/workout/views/exercise_management_screen.dart';
import 'package:nutrifit/modules/workout/views/add_workout_schedule_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutTargetTab extends StatelessWidget {
  const WorkoutTargetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkoutController controller = Get.put(WorkoutController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _taoBieuDoWorkout(),
          const SizedBox(height: 20),
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
                  'Lịch tập hàng ngày',
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
                        builder: (context) => const WorkoutScheduleScreen(),
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
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bài tập hôm nay',
                style: TextStyle(
                  color: Color(0xFF1D1517),
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
                      builder: (context) => const ExerciseManagementScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
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
          const SizedBox(height: 15),
          Obx(() {
            if (controller.isLoadingSchedules.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.todaySchedules.isEmpty) {
              return const Center(
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
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.todaySchedules.length,
              itemBuilder: (context, index) {
                final schedule = controller.todaySchedules[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _taoItemTapLuyen(
                    context,
                    schedule['exerciseName'],
                    schedule['time'],
                    schedule['id'],
                    schedule['isCompleted'],
                    schedule['exerciseImage'] ?? 'assets/fullbody.png',
                    const Color(0xFF00EFFF),
                    controller,
                    schedule,
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách bài tập',
                style: TextStyle(
                  color: Color(0xFF1D1517),
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
                      builder: (context) => const ExerciseManagementScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(0xFFA5A3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseManagementScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
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
              child: const Row(
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
      height: 220,
      padding: const EdgeInsets.only(top: 25, bottom: 10, left: 15, right: 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
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
      child: Obx(() => LineChart(
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
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 20,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
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
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 0:
                      text = const Text('Sun', style: style);
                      break;
                    case 1:
                      text = const Text('Mon', style: style);
                      break;
                    case 2:
                      text = const Text('Tue', style: style);
                      break;
                    case 3:
                      text = const Text('Wed', style: style);
                      break;
                    case 4:
                      text = const Text('Thu', style: style);
                      break;
                    case 5:
                      text = const Text('Fri', style: style);
                      break;
                    case 6:
                      text = const Text('Sat', style: style);
                      break;
                    default:
                      text = const Text('', style: style);
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: text,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
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
                      strokeColor: const Color(0xFFC050F6),
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _taoItemTapLuyen(
    BuildContext context,
    String title,
    String time,
    String scheduleId,
    bool isCompleted,
    String hinhAnh,
    Color mauNen,
    WorkoutController controller,
    Map<String, dynamic> schedule,
  ) {
    return GestureDetector(
      onTap: () {
        final exerciseName = schedule['exerciseName'] ?? title;
        final exercise = controller.allExercises.firstWhere(
          (ex) => ex.title == exerciseName,
          orElse: () => ExerciseItem(
            id: scheduleId,
            title: exerciseName,
            difficulty: 'Trung bình',
            calories: 300,
            description: 'Chưa có mô tả',
            category: 'Khác',
            image: hinhAnh,
            equipments: [],
            instructions: [],
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailsScreen(exercise: exercise),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mauNen.withValues(alpha: 0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: hinhAnh.startsWith('http')
                      ? Image.network(
                          hinhAnh,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image, color: mauNen),
                        )
                      : Image.asset(
                          hinhAnh,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image, color: mauNen),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
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
              icon: const Icon(Icons.more_vert, color: Color(0xFFA5A3AF)),
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
      ),
    );
  }
}
