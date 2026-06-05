import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class LinkAccountScreen extends StatefulWidget {
  const LinkAccountScreen({super.key});

  @override
  State<LinkAccountScreen> createState() => _LinkAccountScreenState();
}

class _LinkAccountScreenState extends State<LinkAccountScreen> {
  bool _hasPassword = false;
  bool _hasGoogle = false;
  bool _hasFacebook = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkProviders();
  }

  void _checkProviders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final providers = user.providerData.map((p) => p.providerId).toList();
      setState(() {
        _hasPassword = providers.contains('password');
        _hasGoogle = providers.contains('google.com');
        _hasFacebook = providers.contains('facebook.com');
      });
    }
  }

  Future<void> _linkGoogleAccount() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user.linkWithCredential(credential);
          _checkProviders();
          Get.snackbar(
            'Thành công',
            'Tài khoản Google đã liên kết thành công!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errMsg = 'Không thể liên kết Google';
      if (e.code == 'provider-already-linked') {
        errMsg = 'Tài khoản này đã được liên kết với Google rồi.';
      } else if (e.code == 'credential-already-in-use') {
        errMsg = 'Tài khoản Google này đã được liên kết với một tài khoản khác.';
      }
      Get.snackbar('Lỗi liên kết', errMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _linkFacebookAccount() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status == LoginStatus.success) {
          final AccessToken accessToken = result.accessToken!;
          final OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          await user.linkWithCredential(credential);
          _checkProviders();
          Get.snackbar(
            'Thành công',
            'Tài khoản Facebook đã liên kết thành công!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errMsg = 'Không thể liên kết Facebook';
      if (e.code == 'provider-already-linked') {
        errMsg = 'Tài khoản này đã được liên kết với Facebook rồi.';
      } else if (e.code == 'credential-already-in-use') {
        errMsg = 'Tài khoản Facebook này đã được liên kết với một tài khoản khác.';
      }
      Get.snackbar('Lỗi liên kết', errMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _linkEmailPassword(String email, String password) async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(email: email, password: password);
        await user.linkWithCredential(credential);
        await user.sendEmailVerification();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'email': email,
        });
        _checkProviders();
        Get.snackbar(
          'Thành công',
          'Tài khoản đã liên kết mật khẩu! Vui lòng xác thực email.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errMsg = 'Không thể liên kết mật khẩu';
      if (e.code == 'provider-already-linked') {
        errMsg = 'Mật khẩu đã được liên kết rồi.';
      } else if (e.code == 'email-already-in-use') {
        errMsg = 'Email này đã được sử dụng bởi một tài khoản khác.';
      } else if (e.code == 'weak-password') {
        errMsg = 'Mật khẩu quá yếu.';
      }
      Get.snackbar('Lỗi liên kết', errMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showEmailPasswordLinkDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dialogEmailController = TextEditingController();
    final dialogPasswordController = TextEditingController();
    final dialogConfirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_person_outlined, color: theme.colorScheme.primary, size: 36),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Liên kết Email & Mật khẩu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: dialogEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ Email',
                    labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                    prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!GetUtils.isEmail(value.trim())) {
                      return 'Định dạng email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dialogPasswordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                    prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dialogConfirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                    prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                  ),
                  validator: (value) {
                    if (value != dialogPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Hủy', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (dialogFormKey.currentState!.validate()) {
                            Get.back();
                            _linkEmailPassword(dialogEmailController.text.trim(), dialogPasswordController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text('Liên kết', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    double iconSize = 20.0,
    required String title,
    required String subtitle,
    required bool isLinked,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1D1517),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
        ),
      ),
      trailing: isLinked
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Đã liên kết',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.check_rounded,
                  color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                  size: 16,
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chưa liên kết',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ],
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isSubmitting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text('Đang thực hiện liên kết tài khoản...', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeader(title: 'Liên kết tài khoản', showBackButton: true),
                    const SizedBox(height: 24),
                    Text(
                      'TỐI ƯU HÓA ĐĂNG NHẬP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : const Color(0xFF1D1517).withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildLinkRow(
                            context: context,
                            icon: Icons.email_outlined,
                            iconColor: Colors.blue,
                            title: 'Email & Mật khẩu',
                            subtitle: _hasPassword ? (currentUser?.email ?? 'Đã liên kết') : 'Chưa liên kết',
                            isLinked: _hasPassword,
                            onTap: () {
                              if (!_hasPassword) {
                                _showEmailPasswordLinkDialog(context);
                              }
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF7F8F8)),
                          _buildLinkRow(
                            context: context,
                            icon: Icons.g_mobiledata_rounded,
                            iconColor: Colors.redAccent,
                            iconSize: 28,
                            title: 'Tài khoản Google',
                            subtitle: _hasGoogle ? 'Đã liên kết tài khoản Google' : 'Chưa liên kết',
                            isLinked: _hasGoogle,
                            onTap: () {
                              if (!_hasGoogle) {
                                _linkGoogleAccount();
                              }
                            },
                          ),
                          const Divider(height: 1, color: Color(0xFFF7F8F8)),
                          _buildLinkRow(
                            context: context,
                            icon: Icons.facebook_rounded,
                            iconColor: const Color(0xFF1877F2),
                            title: 'Liên kết Facebook',
                            subtitle: _hasFacebook ? 'Đã liên kết tài khoản Facebook' : 'Chưa liên kết',
                            isLinked: _hasFacebook,
                            onTap: () {
                              if (!_hasFacebook) {
                                _linkFacebookAccount();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
