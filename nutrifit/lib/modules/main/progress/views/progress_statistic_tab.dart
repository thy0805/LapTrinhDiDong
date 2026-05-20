import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/progress_controller.dart';

class ProgressStatisticTab extends StatelessWidget {
  const ProgressStatisticTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressController controller = Get.find();

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biến Thiên Cân Nặng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            ),
          ),
          SizedBox(height: 10),
          Obx(() => Text(
            'Mục tiêu của bạn: ${controller.targetWeight.value} kg',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          )),
          SizedBox(height: 30),

          Expanded(
            child: Obx(() {
              if (controller.weightHistory.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có dữ liệu. Hãy cập nhật cân nặng của bạn!',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                );
              }

              Color lineColor = controller.hasReachedTargetBadge.value 
                  ? Colors.amber 
                  : Get.theme.colorScheme.primary;

              return LineChart(
                LineChartData(
                  minX: 0,
                  maxX: controller.weightHistory.length > 1 
                      ? (controller.weightHistory.length - 1).toDouble() 
                      : 1.0,
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1.0,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < controller.weightHistory.length && value == index.toDouble()) {
                            var log = controller.weightHistory[index];
                            dynamic dateVal = log['date'];
                            if (dateVal != null) {
                              DateTime? date;
                              if (dateVal is Timestamp) {
                                date = dateVal.toDate();
                              } else if (dateVal is String) {
                                date = DateTime.tryParse(dateVal);
                              }
                              if (date != null) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '${date.day}/${date.month}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Poppins'),
                                  ),
                                );
                              }
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('Lần ${index + 1}', style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Poppins')),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.chartSpots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withValues(alpha: 0.2),
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
