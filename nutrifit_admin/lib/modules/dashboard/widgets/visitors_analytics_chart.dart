import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import '../controllers/dashboard_controller.dart';

class VisitorsAnalyticsChart extends StatelessWidget {
  const VisitorsAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final data = controller.userGrowthData;
      if (data.isEmpty) return const Center(child: CircularProgressIndicator());

      return Container(
        padding: const EdgeInsets.all(TailAdminDesign.sp6),
        decoration: BoxDecoration(
          color: TailAdminDesign.bgCard,
          borderRadius: BorderRadius.circular(TailAdminDesign.radiusXl),
          border: Border.all(color: TailAdminDesign.border),
          boxShadow: TailAdminDesign.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tăng trưởng Người dùng (7 ngày qua)',
              style: GoogleFonts.outfit(
                fontSize: TailAdminDesign.fontLg,
                fontWeight: FontWeight.bold,
                color: TailAdminDesign.textMain,
              ),
            ),
            const SizedBox(height: TailAdminDesign.sp6),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) => FlLine(color: TailAdminDesign.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                          if (value.toInt() < 0 || value.toInt() >= days.length) return const Text('');
                          return SideTitleWidget(meta: meta, child: Text(days[value.toInt()], style: TextStyle(color: TailAdminDesign.textMuted, fontSize: 12)));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: TailAdminDesign.textMuted, fontSize: 12)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: (data.reduce((a, b) => a > b ? a : b) * 1.2),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: TailAdminDesign.brand500,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [TailAdminDesign.brand500.withValues(alpha: 0.1), TailAdminDesign.brand500.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
