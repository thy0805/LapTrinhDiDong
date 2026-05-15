import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import '../controllers/dashboard_controller.dart';

class ProfitChart extends StatelessWidget {
  const ProfitChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      int total = controller.totalUsers.value;
      if (total == 0) total = 1;
      
      int male = controller.genderDistribution['Nam'] ?? 0;
      int female = controller.genderDistribution['Nữ'] ?? 0;
      int other = total - male - female;

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
              'Tỉ lệ Giới tính User',
              style: GoogleFonts.outfit(
                fontSize: TailAdminDesign.fontLg,
                fontWeight: FontWeight.bold,
                color: TailAdminDesign.textMain,
              ),
            ),
            const SizedBox(height: TailAdminDesign.sp6),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      color: const Color(0xFF3C50E0),
                      value: male.toDouble(),
                      title: male > 0 ? '${(male/total*100).toStringAsFixed(0)}%' : '',
                      radius: 35,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF80CAEE),
                      value: female.toDouble(),
                      title: female > 0 ? '${(female/total*100).toStringAsFixed(0)}%' : '',
                      radius: 35,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (other > 0)
                      PieChartSectionData(
                        color: TailAdminDesign.warning,
                        value: other.toDouble(),
                        title: '${(other/total*100).toStringAsFixed(0)}%',
                        radius: 35,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TailAdminDesign.sp4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(const Color(0xFF3C50E0), 'Nam'),
                const SizedBox(width: TailAdminDesign.sp4),
                _buildLegend(const Color(0xFF80CAEE), 'Nữ'),
                const SizedBox(width: TailAdminDesign.sp4),
                _buildLegend(TailAdminDesign.warning, 'Khác'),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
