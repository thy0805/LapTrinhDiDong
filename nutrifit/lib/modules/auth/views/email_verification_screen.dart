import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrifit/core/services/mail_service.dart';
import '../controllers/auth_controller.dart';
import 'success_registration.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final authController = Get.find<AuthController>();
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  
  String _generatedOtp = '';
  int _countdown = 60;
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _generateAndSendOtp();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _generateAndSendOtp() async {
    if (_isSending) return;
    setState(() {
      _isSending = true;
    });

    final random = Random();
    _generatedOtp = (1000 + random.nextInt(9000)).toString();
    final userEmail = authController.userData['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
    final fullName = authController.userData['fullName'] ?? 'bạn';

    if (userEmail.isNotEmpty) {
      await MailService.sendEmailVerificationOtp(userEmail, fullName, _generatedOtp);
      Get.snackbar(
        'Đã gửi mã',
        'Mã xác thực đã được gửi tới email của bạn!',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }

    setState(() {
      _isSending = false;
    });
  }

  Future<void> _verifyOtp() async {
    String enteredOtp = _controllers.map((c) => c.text).join();
    if (enteredOtp.length < 4) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đầy đủ mã OTP!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (enteredOtp == _generatedOtp) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final userEmail = authController.userData['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
      
      if (uid != null && userEmail.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'isEmailVerified': true,
          'verifiedEmail': userEmail,
        });

        authController.userData['isEmailVerified'] = true;
        authController.userData['verifiedEmail'] = userEmail;

        if (authController.regNameController.text.isNotEmpty) {
          Get.offAll(() => const SuccessRegistration());
        } else {
          authController.regNameController.clear();
          authController.regPhoneController.clear();
          authController.regEmailController.clear();
          authController.regPasswordController.clear();
          Get.offAll(() => const SuccessRegistration());
        }
      }
    } else {
      Get.snackbar(
        'Xác thực thất bại',
        'Mã OTP nhập vào không chính xác!',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = authController.userData['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Xác thực tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Nhập mã xác thực',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mã OTP đã được gửi tới địa chỉ email:\n$userEmail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 30),
              _countdown > 0
                  ? Text(
                      'Gửi lại mã sau $_countdown giây',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        _generateAndSendOtp();
                        _startCountdown();
                      },
                      child: Text(
                        'Gửi lại mã mới',
                        style: TextStyle(
                          color: Get.theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
              const Spacer(),
              GestureDetector(
                onTap: _verifyOtp,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x4C95ADFE),
                        blurRadius: 22,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Xác nhận',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  authController.logout();
                },
                child: Text(
                  'Đăng xuất / Quay lại',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Get.theme.colorScheme.primary, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              _verifyOtp();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }
}
