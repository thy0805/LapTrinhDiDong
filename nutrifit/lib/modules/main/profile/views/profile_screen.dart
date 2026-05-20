import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';
import '../controllers/profile_controller.dart';
import 'settings_screen.dart';
import 'achievement_screen.dart';
import 'security_settings_screen.dart';
import 'activity_history_screen.dart';
import '../../progress/views/progress_gallery_screen.dart';
import 'support_ticket_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppHeader(title: 'Hồ sơ', showBackButton: false),
              ),
              _buildHeader(context, controller),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    _buildStats(context, controller),
                    SizedBox(height: 25),
                    _buildSection(context, 'Tài khoản', [
                      _buildMenuItem(context, Icons.person_outline, 'Dữ liệu cá nhân', onTap: () => controller.showEditProfileDialog()),
                      _buildMenuItem(context, Icons.emoji_events_outlined, 'Thành tích', onTap: () => Get.to(() => AchievementScreen())),
                      _buildMenuItem(context, Icons.pie_chart_outline, 'Lịch sử hoạt động', onTap: () => Get.to(() => ActivityHistoryScreen())),
                      _buildMenuItem(
                        context,
                        Icons.bar_chart, 
                        'Tiến độ tập luyện', 
                        isLast: true, 
                        onTap: () => Get.to(() => ProgressGalleryScreen())
                      ),
                    ]),
                    SizedBox(height: 20),
                    _buildSection(context, 'Cài đặt', [
                      _buildMenuItem(context, Icons.settings_outlined, 'Cài đặt hệ thống', onTap: () => Get.to(() => SettingsScreen())),
                      _buildMenuItem(context, Icons.privacy_tip_outlined, 'Bảo mật & Quyền riêng tư', onTap: () => Get.to(() => SecuritySettingsScreen())),
                      _buildMenuItem(context, Icons.help_outline, 'Gửi phiếu hỗ trợ', isLast: true, onTap: () => Get.to(() => const SupportTicketScreen())),
                    ]),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileController controller) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: controller.updateCover,
              child: Obx(() => Container(
                height: 200,
                width: double.infinity,
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                child: controller.coverUrl.value.isNotEmpty
                    ? CachedImageWidget(
                        id: controller.auth.currentUser?.uid ?? 'cover',
                        type: 'covers',
                        url: controller.coverUrl.value,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 40),
              )),
            ),
            Positioned(
              bottom: -50,
              child: GestureDetector(
                onTap: controller.updateAvatar,
                child: Obx(() => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.primary]),
                  ),
                  child: ClipOval(
                    child: controller.avatarUrl.value.isNotEmpty
                        ? CachedImageWidget(
                            id: controller.auth.currentUser?.uid ?? 'avatar',
                            type: 'avatars',
                            url: controller.avatarUrl.value,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                )),
              ),
            ),
          ],
        ),
        SizedBox(height: 60),
        Obx(() => Text(
          controller.fullName.value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
          ),
        )),
        SizedBox(height: 5),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
            SizedBox(width: 4),
            Text(controller.location.value, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13)),
            SizedBox(width: 15),
            Icon(controller.gender.value == 'Male' ? Icons.male : Icons.female, size: 14, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 4),
            Text(controller.gender.value == 'Male' ? 'Nam' : 'Nữ', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        )),
        SizedBox(height: 10),
        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
          child: Text(
            controller.bio.value.isNotEmpty ? controller.bio.value : 'Chưa có tiểu sử. Hãy viết gì đó về bạn!',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700, fontSize: 13, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        )),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: controller.showEditProfileDialog,
              icon: Icon(Icons.edit, size: 14),
              label: Text('Sửa hồ sơ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
            ),
            SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.share, size: 14),
              label: Text('Chia sẻ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, ProfileController controller) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _buildStatCard(context, controller.height, 'cm', 'Chiều cao', Icons.height, [theme.colorScheme.primary, theme.colorScheme.secondary]),
        SizedBox(width: 15),
        _buildStatCard(context, controller.weight, 'kg', 'Cân nặng', Icons.monitor_weight_outlined, [theme.colorScheme.secondary, theme.colorScheme.primary]),
        SizedBox(width: 15),
        _buildStatCard(context, controller.age, 'tuổi', 'Tuổi', Icons.cake_outlined, [theme.colorScheme.primary, theme.colorScheme.secondary]),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, RxString value, String unit, String label, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(height: 8),
            Obx(() => Text(
              value.value,
              style: TextStyle(color: colors[0], fontWeight: FontWeight.bold, fontSize: 16),
            )),
            Text(
              '$unit $label',
              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            SizedBox(width: 15),
            Expanded(child: Text(title, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700))),
            Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey),
          ],
        ),
      ),
    );
  }
}
