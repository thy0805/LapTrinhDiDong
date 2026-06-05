import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/modules/notifications/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Obx(() {
      TailAdminDesign.isDark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hệ thống Thông báo',
            style: GoogleFonts.outfit(
              fontSize: TailAdminDesign.font2xl,
              fontWeight: FontWeight.bold,
              color: TailAdminDesign.textMain,
            ),
          ),
          Text(
            'Gửi thông báo Push Notification đến người dùng hệ thống.',
            style: GoogleFonts.outfit(
              fontSize: TailAdminDesign.fontSm,
              color: TailAdminDesign.textMuted,
            ),
          ),
          const SizedBox(height: TailAdminDesign.sp8),
          Container(
            width: 800,
            padding: const EdgeInsets.all(TailAdminDesign.sp6),
            decoration: BoxDecoration(
              color: TailAdminDesign.bgCard,
              borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg),
              border: Border.all(color: TailAdminDesign.border),
              boxShadow: TailAdminDesign.shadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Tiêu đề thông báo'),
                TextField(
                  onChanged: (val) => controller.titleController.value = val,
                  style: GoogleFonts.outfit(color: TailAdminDesign.textMain),
                  decoration: _buildInputDecoration(
                    'Nhập tiêu đề (Ví dụ: Nhắc nhở uống nước)',
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Nội dung thông báo'),
                TextField(
                  onChanged: (val) => controller.bodyController.value = val,
                  maxLines: 4,
                  style: GoogleFonts.outfit(color: TailAdminDesign.textMain),
                  decoration: _buildInputDecoration(
                    'Nhập nội dung tin nhắn gửi đến User...',
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Đối tượng nhận tin'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: TailAdminDesign.border),
                    borderRadius: BorderRadius.circular(
                      TailAdminDesign.radiusMd,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedSegment.value,
                      isExpanded: true,
                      dropdownColor: TailAdminDesign.bgCard,
                      style: GoogleFonts.outfit(
                        color: TailAdminDesign.textMain,
                      ),
                      items:
                          [
                            'Tất cả',
                            'User chưa tập hôm nay',
                            'User thừa cân',
                            'User VIP',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (val) =>
                          controller.selectedSegment.value = val!,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.sendNotification(),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      controller.isLoading.value
                          ? 'Đang xử lý...'
                          : 'BẮN THÔNG BÁO NGAY',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TailAdminDesign.brand500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TailAdminDesign.radiusMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Lịch sử gửi thông báo',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TailAdminDesign.textMain,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TailAdminDesign.hover,
              borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg),
              border: Border.all(
                color: TailAdminDesign.border,
                style: BorderStyle.none,
              ),
            ),
            child: Center(
              child: Text(
                'Chưa có lịch sử gửi thông báo nào.',
                style: GoogleFonts.outfit(color: TailAdminDesign.textMuted),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TailAdminDesign.textMain,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(
        color: TailAdminDesign.textMuted,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
        borderSide: BorderSide(color: TailAdminDesign.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
        borderSide: BorderSide(color: TailAdminDesign.brand500, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}
