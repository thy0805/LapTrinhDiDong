import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/security_controller.dart';
import 'change_password_screen.dart';
import 'link_account_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isLinked = false;

  @override
  void initState() {
    super.initState();
    _checkLinkedStatus();
  }

  void _checkLinkedStatus() {
    final user = FirebaseAuth.instance.currentUser;
    final providers = user?.providerData.map((p) => p.providerId).toList() ?? [];
    setState(() {
      _isLinked = providers.contains('password');
    });
  }

  @override
  Widget build(BuildContext context) {
    final SecurityController controller = Get.put(SecurityController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Bảo mật & Quyền riêng tư',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'BẢO MẬT ỨNG DỤNG'),
              _buildCard(context, [
                Obx(() => _buildSwitchRow(
                      context,
                      Icons.phonelink_lock_rounded,
                      'Khóa ứng dụng bằng PIN',
                      'Yêu cầu nhập mã khóa khi mở ứng dụng',
                      controller.isAppLockEnabled.value,
                      (val) => controller.toggleAppLock(val),
                    )),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Color(0xFFF7F8F8)),
                ),
                Obx(() => _buildSwitchRow(
                      context,
                      Icons.fingerprint_rounded,
                      'Mở khóa bằng vân tay/FaceID',
                      'Sử dụng sinh trắc học để mở khóa nhanh',
                      controller.isBiometricEnabled.value,
                      (val) => controller.toggleBiometric(val),
                    )),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'DỮ LIỆU & QUYỀN RIÊNG TƯ'),
              _buildCard(context, [
                _buildActionRow(
                  context,
                  Icons.sync_rounded,
                  'Liên kết Health Connect',
                  'Đồng bộ dữ liệu bước chân, calo, giấc ngủ',
                  () => controller.syncHealthPermissions(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Color(0xFFF7F8F8)),
                ),
                Obx(() => _buildSwitchRow(
                      context,
                      Icons.visibility_off_outlined,
                      'Chế độ ẩn danh chỉ số',
                      'Tự động ẩn/làm mờ chỉ số nhạy cảm khi chia sẻ',
                      controller.isGhostModeEnabled.value,
                      (val) => controller.toggleGhostMode(val),
                    )),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'TÀI KHOẢN'),
              _buildCard(context, [
                _buildActionRow(
                  context,
                  Icons.lock_reset_rounded,
                  'Đổi mật khẩu',
                  'Đổi mật khẩu bảo mật qua PIN/OTP 6 số',
                  () {
                    if (_isLinked) {
                      Get.to(() => const ChangePasswordScreen());
                    } else {
                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_person_outlined, color: Get.theme.colorScheme.primary, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa liên kết mật khẩu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tài khoản của bạn hiện đang đăng nhập qua Google/Facebook. Vui lòng thiết lập liên kết email & mật khẩu trước khi đổi nhé!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Đóng'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Get.theme.colorScheme.primary,
                                        ),
                                        onPressed: () async {
                                          Get.back();
                                          await Get.to(() => const LinkAccountScreen());
                                          _checkLinkedStatus();
                                        },
                                        child: const Text('Liên kết ngay', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Color(0xFFF7F8F8)),
                ),
                _buildActionRow(
                  context,
                  Icons.link_rounded,
                  'Cập nhật liên kết tài khoản',
                  'Liên kết bảo mật qua Google, Facebook hoặc mật khẩu',
                  () async {
                    await Get.to(() => const LinkAccountScreen());
                    _checkLinkedStatus();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Color(0xFFF7F8F8)),
                ),
                _buildDangerRow(
                  Icons.delete_forever_rounded,
                  'Xóa tài khoản',
                  'Xóa vĩnh viễn tài khoản và toàn bộ dữ liệu cơ thể',
                  context,
                  controller,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFF1D1517).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        activeThumbColor: Get.theme.colorScheme.primary,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Get.theme.colorScheme.primary, size: 20),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Get.theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
        ),
      ),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildDangerRow(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context,
    SecurityController controller,
  ) {
    return ListTile(
      onTap: () => _showDeleteConfirmDialog(context, controller),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SecurityController controller) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Xóa tài khoản vĩnh viễn?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hành động này không thể hoàn tác. Toàn bộ tiến trình tập luyện, dữ liệu calo, lịch trình và hồ sơ cơ thể của bạn sẽ bị xóa sạch khỏi hệ thống.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Get.theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Hủy bỏ',
                          style: TextStyle(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await controller.deleteUserAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Đồng ý xóa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
