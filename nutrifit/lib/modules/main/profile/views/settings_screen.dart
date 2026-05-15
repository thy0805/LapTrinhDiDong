import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Cài đặt', showBackButton: true),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(25),
                children: [
                  _buildGroup('Giao diện & Chủ đề', theme, [
                    _buildSwitchItem('Chế độ Tối (Dark Mode)', themeController.isDarkMode.obs, (v) => themeController.toggleDarkMode(v), theme),
                    _buildSwitchItem('Giao diện Xanh biển', themeController.isBlueColor.obs, (v) => themeController.toggleColorTheme(v), theme),
                  ]),
                  const SizedBox(height: 25),
                  _buildGroup('Quyền riêng tư', theme, [
                    _buildSwitchItem('Công khai cân nặng', controller.isWeightPublic, (v) => controller.updatePrivacy('isWeightPublic', v), theme),
                    _buildSwitchItem('Công khai chiều cao', controller.isHeightPublic, (v) => controller.updatePrivacy('isHeightPublic', v), theme),
                    _buildSwitchItem('Công khai tiến độ ảnh', controller.isProgressPublic, (v) => controller.updatePrivacy('isProgressPublic', v), theme),
                  ]),
                  const SizedBox(height: 25),
                  _buildGroup('Đơn vị & Ngôn ngữ', theme, [
                    _buildSimpleItem('Đơn vị đo lường', 'KG, CM', theme),
                    _buildSimpleItem('Ngôn ngữ', 'Tiếng Việt', theme),
                  ]),
                  const SizedBox(height: 25),
                  _buildGroup('Thông báo', theme, [
                    _buildSwitchItem('Nhắc nhở tập luyện', true.obs, (v) {}, theme),
                    _buildSwitchItem('Nhắc nhở uống nước', true.obs, (v) {}, theme),
                  ]),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: controller.logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.red.shade100)),
                    ),
                    child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  Center(child: Text('Phiên bản 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(String title, ThemeData theme, List<Widget> children) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF7F8F8), borderRadius: BorderRadius.circular(15)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(String title, RxBool value, Function(bool) onChanged, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
      trailing: Obx(() => Switch(
        value: value.value,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
      )),
    );
  }

  Widget _buildSimpleItem(String title, String subtitle, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? Colors.white54 : Colors.grey),
      onTap: () {},
    );
  }
}
