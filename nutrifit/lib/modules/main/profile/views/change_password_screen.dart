import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:nutrifit/core/services/mail_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  int _stage = 0; 
  final _box = Hive.box('security_settings');
  final _currentPinInput = <String>[];
  String _otpCode = '';
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  void _startVerification() {
    final isAppLockEnabled = _box.get('isAppLockEnabled', defaultValue: false);
    final isBiometricEnabled = _box.get('isBiometricEnabled', defaultValue: false);

    if (!isAppLockEnabled && !isBiometricEnabled) {
      _goToOtpStage();
      return;
    }

    if (isBiometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticateBiometrics();
      });
    }
  }

  Future<void> _authenticateBiometrics() async {
    try {
      final localAuth = LocalAuthentication();
      final bool canAuth = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
      if (!canAuth) return;

      final bool didAuth = await localAuth.authenticate(
        localizedReason: 'Xác thực vân tay/FaceID để đổi mật khẩu',
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (didAuth) {
        _goToOtpStage();
      }
    } catch (_) {}
  }

  void _onPinKeyPress(String digit) {
    if (_currentPinInput.length < 4) {
      setState(() {
        _currentPinInput.add(digit);
      });

      if (_currentPinInput.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), () {
          final enteredPin = _currentPinInput.join();
          final savedPin = _box.get('appPasscode', defaultValue: '');
          if (enteredPin == savedPin) {
            _goToOtpStage();
          } else {
            setState(() {
              _currentPinInput.clear();
            });
            Get.snackbar(
              'Bảo mật',
              'Mã PIN không chính xác',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          }
        });
      }
    }
  }

  void _onPinDelete() {
    if (_currentPinInput.isNotEmpty) {
      setState(() {
        _currentPinInput.removeLast();
      });
    }
  }

  void _goToOtpStage() async {
    final random = Random();
    final otpVal = 1000 + random.nextInt(9000);
    setState(() {
      _otpCode = otpVal.toString();
      _stage = 1;
    });

    final user = FirebaseAuth.instance.currentUser;
    final toEmail = user?.email ?? '';
    final userName = user?.displayName ?? 'Bạn';

    if (toEmail.isNotEmpty) {
      Get.snackbar(
        'Đang gửi mã...',
        'Nutritea đang gửi mã OTP về hòm thư $toEmail của bạn nhen!',
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
      
      bool success = await MailService.sendOtpEmail(toEmail, userName, _otpCode);
      if (success) {
        Get.snackbar(
          'Mã OTP đã gửi',
          'Đã gửi tới $toEmail. Vui lòng kiểm tra hộp thư!',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi gửi mail',
          'Không thể gửi đến $toEmail. Bạn kiểm tra lại mạng hoặc SMTP nha!',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } else {
      Get.snackbar(
        'Lỗi',
        'Không tìm thấy email của bạn',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _verifyOtp() {
    if (_otpController.text.trim() == _otpCode) {
      setState(() {
        _stage = 2;
      });
    } else {
      Get.snackbar(
        'Lỗi',
        'Mã OTP không chính xác',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final newPass = _newPasswordController.text.trim();
      await user?.updatePassword(newPass);
      Get.back();
      Get.snackbar(
        'Thành công',
        'Đã thay đổi mật khẩu tài khoản của bạn!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          'Xác thực lại',
          'Vui lòng đăng xuất và đăng nhập lại trước khi đổi mật khẩu để bảo mật.',
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          e.message ?? 'Không thể đổi mật khẩu',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Đổi mật khẩu', showBackButton: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStageContent(theme, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageContent(ThemeData theme, bool isDark) {
    if (_stage == 0) {
      return _buildPinVerificationView(theme, isDark);
    } else if (_stage == 1) {
      return _buildOtpEntryView(theme, isDark);
    } else {
      return _buildNewPasswordView(theme, isDark);
    }
  }

  Widget _buildPinVerificationView(ThemeData theme, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.lock_outline_rounded, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          'Xác thực mã PIN hoặc vân tay của bạn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1D1517),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final hasDigit = index < _currentPinInput.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasDigit ? theme.colorScheme.primary : Colors.grey.shade300,
                border: Border.all(
                  color: hasDigit ? theme.colorScheme.primary : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPinNumButton('1', isDark),
                  _buildPinNumButton('2', isDark),
                  _buildPinNumButton('3', isDark),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPinNumButton('4', isDark),
                  _buildPinNumButton('5', isDark),
                  _buildPinNumButton('6', isDark),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPinNumButton('7', isDark),
                  _buildPinNumButton('8', isDark),
                  _buildPinNumButton('9', isDark),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _authenticateBiometrics,
                    child: Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      child: Icon(Icons.fingerprint_rounded, color: theme.colorScheme.primary, size: 36),
                    ),
                  ),
                  _buildPinNumButton('0', isDark),
                  GestureDetector(
                    onTap: _onPinDelete,
                    child: Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      child: Icon(Icons.backspace_outlined, color: isDark ? Colors.white : const Color(0xFF1D1517), size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinNumButton(String value, bool isDark) {
    return GestureDetector(
      onTap: () => _onPinKeyPress(value),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1D1517),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpEntryView(ThemeData theme, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.mark_email_read_outlined, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          'Nhập mã xác thực OTP gồm 4 chữ số',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1D1517),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mã OTP đã được gửi đến email đăng ký của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Xác thực OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildNewPasswordView(ThemeData theme, bool isDark) {
    return _isSubmitting
        ? Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('Đang cập nhật mật khẩu...', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
              ],
            ),
          )
        : Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.vpn_key_outlined, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Thiết lập mật khẩu mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D1517),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                    prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu xác nhận không trùng khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Cập nhật mật khẩu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          );
  }
}
