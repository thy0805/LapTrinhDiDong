import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../controllers/progress_controller.dart';

class ProgressStatisticTab extends StatelessWidget {
  const ProgressStatisticTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biến Thiên Cân Nặng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
            'Mục tiêu của bạn: ${controller.targetWeight.value} kg',
            style: TextStyle(color: Colors.grey[600], fontFamily: 'Poppins'),
          )),
          const SizedBox(height: 30),

          // KHU VỰC VẼ BIỂU ĐỒ
          Expanded(
            child: Obx(() {
              if (controller.weightHistory.isEmpty) {
                return const Center(
                  child: Text('Chưa có dữ liệu. Hãy cập nhật cân nặng của bạn!', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                );
              }

              // Nếu đã đạt mục tiêu, đổi màu biểu đồ sang Vàng Gold (Gamification UX)
              Color lineColor = controller.hasReachedTargetBadge.value 
                  ? Colors.amber 
                  : const Color(0xFFC050F6);

              return LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false), // Ẩn lưới dọc cho thoáng mắt
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Chỉ hiển thị số thứ tự lần cân ở trục X
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Lần ${value.toInt() + 1}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Poppins')),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false), // Ẩn viền khung biểu đồ
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.chartSpots, // Đổ dữ liệu tọa độ từ Controller vào đây
                      isCurved: true, // Làm đường line cong mềm mại
                      color: lineColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true), // Hiện các dấu chấm ở mỗi lần cân
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withValues(alpha: 0.2), // Đổ bóng mờ gradient bên dưới đường line
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
