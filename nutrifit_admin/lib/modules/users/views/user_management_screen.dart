import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrifit_admin/core/theme/tailadmin_design_system.dart';
import 'package:nutrifit_admin/core/widgets/app_table.dart';
import 'package:nutrifit_admin/modules/users/controllers/user_management_controller.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserManagementController>();

    return Obx(() {
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý người dùng',
                  style: GoogleFonts.outfit(
                    fontSize: TailAdminDesign.font2xl,
                    fontWeight: FontWeight.bold,
                    color: TailAdminDesign.textMain,
                  ),
                ),
                Text(
                  'Quản lý và theo dõi thông tin người dùng hệ thống.',
                  style: GoogleFonts.outfit(
                    fontSize: TailAdminDesign.fontSm,
                    color: TailAdminDesign.textMuted,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text('Xuất báo cáo', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: TailAdminDesign.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd)),
              ),
            ),
          ],
        ),
        const SizedBox(height: TailAdminDesign.sp8),
        Container(
          padding: const EdgeInsets.all(TailAdminDesign.sp4),
          decoration: BoxDecoration(
            color: TailAdminDesign.bgCard,
            borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg),
            border: Border.all(color: TailAdminDesign.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => controller.searchText.value = val,
                  style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm User (Tên, Email)...',
                    hintStyle: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: TailAdminDesign.textMuted, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                      borderSide: BorderSide(color: TailAdminDesign.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: TailAdminDesign.border),
                  borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedTag.value,
                    dropdownColor: TailAdminDesign.bgCard,
                    style: GoogleFonts.outfit(color: TailAdminDesign.textMain, fontSize: 14),
                    items: ['Tất cả', 'Thừa cân', 'Thiếu cân', 'Cân đối', 'Chăm chỉ', 'Bỏ cuộc'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => controller.selectedTag.value = val!,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TailAdminDesign.sp6),
        controller.isLoading.value
          ? const Center(child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(color: TailAdminDesign.brand500),
            ))
          : AppTable<Map<String, dynamic>>(
              title: 'Hồ sơ người dùng',
              columns: const ['USER', 'LIÊN HỆ', 'SMART TAGS', 'TRẠNG THÁI', 'THAO TÁC'],
              data: controller.paginatedUsers,
              currentPage: controller.currentPage.value,
              totalPages: controller.totalPages,
              onPageChanged: (page) => controller.setPage(page),
              cellBuilder: (user) {
                final String id = user['id']?.toString() ?? '';
                final status = user['status'] ?? 'Active';
                final statusColor = status == 'Active' ? TailAdminDesign.success : TailAdminDesign.danger;
                final List<dynamic> tags = user['tags'] ?? [];

                return [
                  DataCell(
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TailAdminDesign.brand500.withValues(alpha: 0.1),
                            image: _getAvatarUrl(user) != null 
                                ? DecorationImage(image: NetworkImage(_getAvatarUrl(user)!), fit: BoxFit.cover) 
                                : null,
                          ),
                          child: _getAvatarUrl(user) == null 
                            ? Center(
                                child: Text(
                                  (user['fullName'] != null && user['fullName'].toString().isNotEmpty) ? user['fullName'].toString().substring(0, 1).toUpperCase() : 'U',
                                  style: GoogleFonts.outfit(color: TailAdminDesign.brand500, fontWeight: FontWeight.bold),
                                ),
                              )
                            : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['fullName']?.toString() ?? 'N/A', 
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: TailAdminDesign.textMain)),
                            Text('ID: ${id.length > 8 ? id.substring(0, 8) : id}', 
                              style: GoogleFonts.outfit(fontSize: 12, color: TailAdminDesign.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['email']?.toString() ?? 'N/A', style: GoogleFonts.outfit(fontSize: 13, color: TailAdminDesign.textMain)),
                        Text(user['phone']?.toString() ?? 'Chưa cập nhật', style: GoogleFonts.outfit(fontSize: 11, color: TailAdminDesign.textMuted)),
                      ],
                    ),
                  ),
                  DataCell(
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTagColor(tag.toString()).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(TailAdminDesign.radiusSm),
                        ),
                        child: Text(
                          tag.toString(),
                          style: GoogleFonts.outfit(color: _getTagColor(tag.toString()), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )).toList(),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        status.toString(),
                        style: GoogleFonts.outfit(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility_outlined, size: 20, color: TailAdminDesign.brand500),
                          onPressed: () => _showUserDetails(context, user),
                          tooltip: 'Xem hồ sơ',
                        ),
                        IconButton(
                          icon: Icon(status == 'Active' ? Icons.block_rounded : Icons.check_circle_outline, 
                            size: 20, color: status == 'Active' ? TailAdminDesign.danger : TailAdminDesign.success),
                          onPressed: () => controller.toggleSuspendUser(id, status.toString()),
                          tooltip: status == 'Active' ? 'Khóa' : 'Mở khóa',
                        ),
                        IconButton(
                          icon: Icon(Icons.track_changes_rounded, size: 20, color: TailAdminDesign.warning),
                          onPressed: () => _showGoalDialog(context, id, user),
                          tooltip: 'Giao mục tiêu',
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
      ],
    );
    });
  }


  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Thừa cân': return TailAdminDesign.danger;
      case 'Thiếu cân': return TailAdminDesign.warning;
      case 'Cân đối': return TailAdminDesign.success;
      case 'Chăm chỉ': return TailAdminDesign.brand500;
      case 'Bỏ cuộc': return TailAdminDesign.textMuted;
      default: return TailAdminDesign.textMuted;
    }
  }

  String? _getAvatarUrl(Map<String, dynamic> user) {
    return user['avatar'] ?? user['photoURL'] ?? user['photoUrl'] ?? user['avatarUrl'];
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    final avatarUrl = _getAvatarUrl(user);
    Get.dialog(
      Dialog(
        backgroundColor: TailAdminDesign.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusLg)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hồ sơ chi tiết', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: TailAdminDesign.textMain)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TailAdminDesign.brand500.withValues(alpha: 0.1),
                      image: avatarUrl != null ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover) : null,
                    ),
                    child: avatarUrl == null ? Icon(Icons.person, size: 40, color: TailAdminDesign.brand500) : null,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['fullName'] ?? 'N/A', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: TailAdminDesign.textMain)),
                        Text(user['email'] ?? 'N/A', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: (user['tags'] as List<dynamic>).map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _getTagColor(tag).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                            child: Text(tag, style: GoogleFonts.outfit(color: _getTagColor(tag), fontSize: 12, fontWeight: FontWeight.bold)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildStatCard('BMI', user['bmi'] ?? '0.0', Icons.monitor_weight_outlined, TailAdminDesign.brand500),
                  const SizedBox(width: 16),
                  _buildStatCard('Streak', '${user['streak'] ?? 0} ngày', Icons.local_fire_department_rounded, TailAdminDesign.danger),
                  const SizedBox(width: 16),
                  _buildStatCard('Cân nặng', '${user['weight'] ?? 0} kg', Icons.fitness_center_rounded, TailAdminDesign.success),
                ],
              ),
              const SizedBox(height: 24),
              Text('Lịch sử tập luyện gần đây', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: TailAdminDesign.textMain)),
              const SizedBox(height: 12),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: TailAdminDesign.hover,
                  borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
                  border: Border.all(color: TailAdminDesign.border),
                ),
                child: Center(child: Text('Biểu đồ lịch sử sẽ hiển thị ở đây', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted))),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _showDeleteDialog(user['id'], user['fullName'] ?? '', Get.find()),
                    style: OutlinedButton.styleFrom(foregroundColor: TailAdminDesign.danger, side: BorderSide(color: TailAdminDesign.danger)),
                    child: const Text('Xóa người dùng'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(backgroundColor: TailAdminDesign.brand500, foregroundColor: Colors.white),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TailAdminDesign.bgCard,
          borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd),
          border: Border.all(color: TailAdminDesign.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: TailAdminDesign.textMain)),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, color: TailAdminDesign.textMuted)),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, String uid, Map<String, dynamic> user) {
    final stepController = TextEditingController(text: '8000');
    final caloController = TextEditingController(text: '2000');

    Get.dialog(
      AlertDialog(
        backgroundColor: TailAdminDesign.bgCard,
        title: Text('Giao mục tiêu mới', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: TailAdminDesign.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Admin đang thiết kế lộ trình riêng cho ${user['fullName']}', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: stepController,
              decoration: InputDecoration(labelText: 'Mục tiêu bước chân', border: OutlineInputBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd))),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloController,
              decoration: InputDecoration(labelText: 'Mục tiêu Calories nạp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(TailAdminDesign.radiusMd))),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Get.find<UserManagementController>().updateUserGoals(uid, {
                'dailySteps': int.tryParse(stepController.text) ?? 8000,
                'dailyCalories': int.tryParse(caloController.text) ?? 2000,
                'assignedBy': 'Admin',
                'assignedAt': DateTime.now().toIso8601String(),
              });
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: TailAdminDesign.brand500, foregroundColor: Colors.white),
            child: const Text('Gửi lộ trình'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id, String name, UserManagementController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: TailAdminDesign.bgCard,
        title: Text('Xác nhận xóa', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: TailAdminDesign.textMain)),
        content: Text('Bà có chắc muốn xóa user "$name" hông Thy? Hành động này không thể hoàn tác.', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Hông', style: GoogleFonts.outfit(color: TailAdminDesign.textMuted))),
          ElevatedButton(
            onPressed: () {
              controller.deleteUser(id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: TailAdminDesign.danger, foregroundColor: Colors.white),
            child: const Text('Xóa lẹ đi'),
          ),
        ],
      ),
    );
  }
}
