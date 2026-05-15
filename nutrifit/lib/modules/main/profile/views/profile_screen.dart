import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import '../controllers/profile_controller.dart';
import 'settings_screen.dart';
import 'achievement_screen.dart';
import 'activity_history_screen.dart';
import '../../progress/views/progress_gallery_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppHeader(title: 'Hồ sơ', showBackButton: false),
              ),
              _buildHeader(controller),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStats(controller),
                    const SizedBox(height: 25),
                    _buildSection('Tài khoản', [
                      _buildMenuItem(Icons.person_outline, 'Dữ liệu cá nhân', onTap: () => controller.showEditProfileDialog()),
                      _buildMenuItem(Icons.emoji_events_outlined, 'Thành tích', onTap: () => Get.to(() => const AchievementScreen())),
                      _buildMenuItem(Icons.pie_chart_outline, 'Lịch sử hoạt động', onTap: () => Get.to(() => const ActivityHistoryScreen())),
                      _buildMenuItem(
                        Icons.bar_chart, 
                        'Tiến độ tập luyện', 
                        isLast: true, 
                        onTap: () => Get.to(() => const ProgressGalleryScreen())
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSection('Cài đặt', [
                      _buildMenuItem(Icons.settings_outlined, 'Cài đặt hệ thống', onTap: () => Get.to(() => const SettingsScreen())),
                      _buildMenuItem(Icons.privacy_tip_outlined, 'Quyền riêng tư', isLast: true),
                    ]),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileController controller) {
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image: controller.coverUrl.value.isNotEmpty 
                    ? DecorationImage(image: NetworkImage(controller.coverUrl.value), fit: BoxFit.cover) 
                    : null,
                ),
                child: controller.coverUrl.value.isEmpty ? const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 40) : null,
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
                    gradient: const LinearGradient(colors: [Color(0xFFEEA4CE), Color(0xFFC050F6)]),
                  ),
                  child: ClipOval(
                    child: controller.avatarUrl.value.isNotEmpty 
                      ? Image.network(controller.avatarUrl.value, fit: BoxFit.cover) 
                      : const Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Obx(() => Text(controller.fullName.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 5),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(controller.location.value, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(width: 15),
            Icon(controller.gender.value == 'Male' ? Icons.male : Icons.female, size: 14, color: const Color(0xFFC050F6)),
            const SizedBox(width: 4),
            Text(controller.gender.value == 'Male' ? 'Nam' : 'Nữ', style: const TextStyle(color: Color(0xFFC050F6), fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        )),
        const SizedBox(height: 10),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
          child: Text(
            controller.bio.value.isNotEmpty ? controller.bio.value : 'Chưa có tiểu sử. Hãy viết gì đó về bạn!',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        )),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: controller.showEditProfileDialog,
              icon: const Icon(Icons.edit, size: 14),
              label: const Text('Sửa hồ sơ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC050F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () {}, // Chia sẻ profile
              icon: const Icon(Icons.share, size: 14),
              label: const Text('Chia sẻ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC050F6),
                side: const BorderSide(color: Color(0xFFC050F6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(ProfileController controller) {
    return Row(
      children: [
        _buildStatCard(controller.height, 'cm', 'Chiều cao', Icons.height, [const Color(0xFFC050F6), const Color(0xFFEEA4CE)]),
        const SizedBox(width: 15),
        _buildStatCard(controller.weight, 'kg', 'Cân nặng', Icons.monitor_weight_outlined, [const Color(0xFF92A3FD), const Color(0xFF9DCEFF)]),
        const SizedBox(width: 15),
        _buildStatCard(controller.age, 'tuổi', 'Tuổi', Icons.cake_outlined, [const Color(0xFFCC8FED), const Color(0xFF6B50F6)]),
      ],
    );
  }

  Widget _buildStatCard(RxString value, String unit, String label, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              value.value,
              style: TextStyle(color: colors[0], fontWeight: FontWeight.bold, fontSize: 16),
            )),
            Text(
              '$unit $label',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC050F6), size: 22),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.grey))),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
