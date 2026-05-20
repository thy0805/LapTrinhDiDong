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
              columns: const ['EMAIL', 'TIÊU ĐỀ', 'LOẠI', 'NGÀY GỬI', 'TRẠNG THÁI', 'THAO TÁC'],
              data: controller.feedbacks.toList(),
              cellBuilder: (item) {
                final statusColor = item.status == 'resolved' ? TailAdminDesign.success : TailAdminDesign.danger;
                
                return [
                  DataCell(Text(item.userEmail, style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontWeight: FontWeight.w500))),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(item.title, style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    )
                  ),
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
                        IconButton(
                          onPressed: () => _showTicketDetails(context, item),
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          color: TailAdminDesign.brand500,
                          tooltip: 'Xem chi tiết',
                        ),
                        if (item.status != 'resolved')
                          IconButton(
                            onPressed: () => controller.resolveFeedback(item.id), 
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 20), 
                            color: TailAdminDesign.success,
                            tooltip: 'Đã giải quyết',
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

  void _showTicketDetails(BuildContext context, FeedbackItem item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg)),
        backgroundColor: TailAdminDesign.bgCard,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(TailAdminDesign.sp6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chi tiết Phiếu hỗ trợ',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TailAdminDesign.textMain,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    color: TailAdminDesign.textMuted,
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Người gửi:', item.userEmail),
              _buildDetailRow('Tiêu đề:', item.title),
              _buildDetailRow('Loại:', item.type),
              _buildDetailRow('Trạng thái:', item.status == 'resolved' ? 'Đã xử lý' : 'Đang chờ'),
              _buildDetailRow('Ngày gửi:', DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt)),
              const SizedBox(height: 16),
              Text(
                'Nội dung chi tiết / Lý do:',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: TailAdminDesign.textMain,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TailAdminDesign.isDark ? TailAdminDesign.darkBg : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                  border: Border.all(color: TailAdminDesign.border),
                ),
                child: Text(
                  item.message,
                  style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                ),
              ),
              if (item.imageUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Hình ảnh minh họa:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: TailAdminDesign.textMain,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
                    ),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: TailAdminDesign.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
