import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/core/widgets/app_table.dart';
import 'package:nutrifit_admin/modules/feedback/controllers/feedback_controller.dart';
import 'package:intl/intl.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());

    return Obx(() {
      TailAdminDesign.isDark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý Phản hồi & Lỗi',
            style: GoogleFonts.outfit(
              fontSize: TailAdminDesign.font2xl,
              fontWeight: FontWeight.bold,
              color: TailAdminDesign.textMain,
            ),
          ),
          Text(
            'Tiếp nhận và xử lý các báo cáo lỗi, góp ý từ người dùng app.',
            style: GoogleFonts.outfit(
              fontSize: TailAdminDesign.fontSm,
              color: TailAdminDesign.textMuted,
            ),
          ),
          const SizedBox(height: TailAdminDesign.sp8),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return AppTable<FeedbackItem>(
              title: 'Danh sách Ticketing',
              columns: const ['EMAIL', 'LOẠI', 'NỘI DUNG', 'NGÀY GỬI', 'TRẠNG THÁI', 'THAO TÁC'],
              data: controller.feedbacks,
              cellBuilder: (item) {
                final statusColor = item.status == 'resolved' ? TailAdminDesign.success : TailAdminDesign.danger;
                
                return [
                  DataCell(Text(item.userEmail, style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontWeight: FontWeight.w500))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item.type == 'Lỗi' ? TailAdminDesign.danger : TailAdminDesign.warning).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                      ),
                      child: Text(item.type, style: GoogleFonts.outfit(color: item.type == 'Lỗi' ? TailAdminDesign.danger : TailAdminDesign.warning, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 250,
                      child: Text(item.message, style: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    )
                  ),
                  DataCell(Text(DateFormat('dd/MM HH:mm').format(item.createdAt), style: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 12))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        item.status == 'resolved' ? 'Đã xử lý' : 'Đang chờ',
                        style: GoogleFonts.outfit(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        if (item.status != 'resolved')
                          IconButton(
                            onPressed: () => controller.resolveFeedback(item.id), 
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 20), 
                            color: TailAdminDesign.success,
                            tooltip: 'Đã fix',
                          ),
                        IconButton(
                          onPressed: () => controller.deleteFeedback(item.id),
                          icon: const Icon(Icons.delete_outline_rounded, size: 20),
                          color: TailAdminDesign.danger,
                          tooltip: 'Xóa',
                        ),
                      ],
                    ),
                  ),
                ];
              },
            );
          }),
        ],
      );
    });
  }
}
