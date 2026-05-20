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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Cài đặt', showBackButton: true),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(25),
                children: [
                  _buildGroup('Giao diện & Chủ đề', theme, [
                    Obx(() {
                      String activeName = 'Hồng ngọt ngào';
                      if (themeController.currentThemeMode.value == 'darkAbyss') {
                        activeName = 'Hố sâu thẳm (Dark Abyss)';
                      } else if (themeController.currentThemeMode.value == 'oceanBlue') {
                        activeName = 'Xanh đại dương (Ocean Blue)';
                      }
                      return _buildSimpleItem(
                        'Chủ đề màu sắc',
                        activeName,
                        theme,
                        onTap: () => _showThemeSelectorBottomSheet(context, themeController),
                      );
                    }),
                  ]),
                  SizedBox(height: 25),
                  _buildGroup('Quyền riêng tư', theme, [
                    _buildSwitchItem('Công khai cân nặng', controller.isWeightPublic, (v) => controller.updatePrivacy('isWeightPublic', v), theme),
                    _buildSwitchItem('Công khai chiều cao', controller.isHeightPublic, (v) => controller.updatePrivacy('isHeightPublic', v), theme),
                    _buildSwitchItem('Công khai tiến độ ảnh', controller.isProgressPublic, (v) => controller.updatePrivacy('isProgressPublic', v), theme),
                  ]),
                  SizedBox(height: 25),
                  _buildGroup('Đơn vị & Ngôn ngữ', theme, [
                    _buildSimpleItem('Đơn vị đo lường', 'KG, CM', theme),
                    _buildSimpleItem('Ngôn ngữ', 'Tiếng Việt', theme),
                  ]),
                  SizedBox(height: 25),
                  _buildGroup('Thông báo', theme, [
                    _buildSwitchItem('Nhắc nhở tập luyện', true.obs, (v) {}, theme),
                    _buildSwitchItem('Nhắc nhở uống nước', true.obs, (v) {}, theme),
                  ]),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: controller.logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade50,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade100)),
                    ),
                    child: Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                  Center(child: Text('Phiên bản 1.0.0', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey, fontSize: 12))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectorBottomSheet(BuildContext context, ThemeController themeController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn chủ đề giao diện',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Obx(() => Column(
                children: [
                  _buildThemeOption(
                    context: context,
                    themeController: themeController,
                    modeValue: 'pinkLight',
                    title: 'Hồng ngọt ngào',
                    subtitle: 'Giao diện mặc định ngọt ngào, đầy sức sống',
                    bgColor: Color(0xFFF8F9FA),
                    accentColor: Get.theme.colorScheme.primary,
                    icon: Icons.light_mode_rounded,
                  ),
                  SizedBox(height: 12),
                  _buildThemeOption(
                    context: context,
                    themeController: themeController,
                    modeValue: 'darkAbyss',
                    title: 'Hố sâu thẳm (Dark Abyss)',
                    subtitle: 'Huyền bí và êm dịu lấy cảm hứng từ VS Code',
                    bgColor: Color(0xFF000C18),
                    accentColor: Color(0xFF38BDF8),
                    icon: Icons.dark_mode_rounded,
                  ),
                  SizedBox(height: 12),
                  _buildThemeOption(
                    context: context,
                    themeController: themeController,
                    modeValue: 'oceanBlue',
                    title: 'Xanh đại dương (Ocean Blue)',
                    subtitle: 'Sắc xanh năng động, tươi mát như gió biển',
                    bgColor: Color(0xFFF0F6FC),
                    accentColor: Color(0xFF0284C7),
                    icon: Icons.water_drop_rounded,
                  ),
                ],
              )),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeController themeController,
    required String modeValue,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color accentColor,
    required IconData icon,
  }) {
    final isSelected = themeController.currentThemeMode.value == modeValue;
    return GestureDetector(
      onTap: () {
        themeController.changeThemeMode(modeValue);
        Get.back();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
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
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: isDark ? theme.colorScheme.surface : Color(0xFFF7F8F8), borderRadius: BorderRadius.circular(15)),
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

  Widget _buildSimpleItem(String title, String subtitle, ThemeData theme, {VoidCallback? onTap}) {
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? Colors.white54 : Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}
