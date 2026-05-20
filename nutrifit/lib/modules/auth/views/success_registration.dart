import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:nutrifit/modules/main/home/views/main_screen.dart'; 
import '../controllers/auth_controller.dart';

class SuccessRegistration extends StatelessWidget {
  const SuccessRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userName = authController.regNameController.text.trim().isNotEmpty
        ? authController.regNameController.text.trim()
        : (authController.userData['fullName']?.toString() ?? 'bạn');

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/success.png',
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.check_circle_outline,
                  size: 150,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Chào mừng, $userName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Get.theme.textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Tài khoản của bạn đã sẵn sàng. Hãy cùng nhau chinh phục mục tiêu sức khỏe nhé!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7B6F72),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
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
                      'Bắt đầu ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
