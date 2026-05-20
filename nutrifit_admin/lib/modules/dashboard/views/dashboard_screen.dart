import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/app_animations.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/modules/dashboard/widgets/visitors_analytics_chart.dart';
import 'package:nutrifit_admin/modules/dashboard/widgets/profit_chart.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      TailAdminDesign.isDark;

      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(100),
            child: CircularProgressIndicator(color: TailAdminDesign.brand500),
          ),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppAnimations.slideUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào buổi sáng, Admin! 👋',
                      style: GoogleFonts.outfit(
                        fontSize: TailAdminDesign.font2xl,
                        fontWeight: FontWeight.bold,
                        color: TailAdminDesign.textMain,
                      ),
                    ),
                    Text(
                      'Đây là những gì đang diễn ra với NutriFit hôm nay.',
                      style: GoogleFonts.outfit(
                        fontSize: TailAdminDesign.fontSm,
                        color: TailAdminDesign.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.syncData(),
                icon: const Icon(Icons.sync_rounded, size: 18),
                label: Text('Đồng bộ Data', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TailAdminDesign.bgCard,
                  foregroundColor: TailAdminDesign.textMain,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: BorderSide(color: TailAdminDesign.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                ),
              ),
            ],
          ),
          const SizedBox(height: TailAdminDesign.sp8),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 700 ? 4 : (constraints.maxWidth > 450 ? 2 : 1);
              double aspectRatio = constraints.maxWidth > 700 ? 1.6 : (constraints.maxWidth > 450 ? 2.2 : 3.0);
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: TailAdminDesign.sp5,
                mainAxisSpacing: TailAdminDesign.sp5,
                childAspectRatio: aspectRatio,
                children: [
                  _buildAnimatedCard(0, 'Tổng người dùng', controller.totalUsers.value.toString(), Icons.people_alt_rounded, TailAdminDesign.brand500),
                  _buildAnimatedCard(
                    1,
                    'Calo tiêu thụ (Ước tính)',
                    controller.totalCaloriesBurned.value >= 1000
                        ? '${(controller.totalCaloriesBurned.value / 1000).toStringAsFixed(1)}k'
                        : controller.totalCaloriesBurned.value.toStringAsFixed(0),
                    Icons.local_fire_department_rounded,
                    const Color(0xFFF59E0B),
                  ),
                  _buildAnimatedCard(2, 'Tổng bài tập', controller.totalWorkouts.value.toString(), Icons.fitness_center_rounded, const Color(0xFF10B981)),
                  _buildAnimatedCard(3, 'Thực phẩm & Món ăn', controller.totalFoods.value.toString(), Icons.fastfood_rounded, const Color(0xFF3B82F6)),
                ],
              );
            },
          ),
        const SizedBox(height: TailAdminDesign.sp8),
        AppAnimations.fadeIn(
          duration: AppAnimations.slow,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 400,
                        child: VisitorsAnalyticsChart(),
                      ),
                    ),
                    const SizedBox(width: TailAdminDesign.sp5),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 400,
                        child: ProfitChart(),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: VisitorsAnalyticsChart(),
                    ),
                    const SizedBox(height: TailAdminDesign.sp5),
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: ProfitChart(),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
      );
    });
  }

  Widget _buildAnimatedCard(int index, String title, String value, IconData icon, Color color) {
    return AppAnimations.slideUp(
      duration: Duration(milliseconds: 300 + (index * 100)),
      child: _HoverStatCard(title: title, value: value, icon: icon, color: color),
    );
  }
}

class _HoverStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HoverStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<_HoverStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: TailAdminDesign.durationFast,
        curve: TailAdminDesign.curveStandard,
        transform: _isHovered ? Matrix4.diagonal3Values(1.02, 1.02, 1.0) : Matrix4.identity(),
        padding: const EdgeInsets.all(TailAdminDesign.sp6),
        decoration: BoxDecoration(
          color: TailAdminDesign.bgCard,
          borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg),
          boxShadow: _isHovered ? TailAdminDesign.shadowMd : TailAdminDesign.shadowSm,
          border: Border.all(
            color: _isHovered ? widget.color.withValues(alpha: 0.3) : TailAdminDesign.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: TailAdminDesign.durationFast,
              padding: const EdgeInsets.all(TailAdminDesign.sp3),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
              ),
              child: Icon(widget.icon, color: widget.color, size: 26),
            ),
            const SizedBox(width: TailAdminDesign.sp5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.outfit(
                      color: TailAdminDesign.textMuted,
                      fontSize: TailAdminDesign.fontXs,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.value,
                    style: GoogleFonts.outfit(
                      color: TailAdminDesign.textMain,
                      fontSize: TailAdminDesign.font2xl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
