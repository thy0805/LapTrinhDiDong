import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_screen_1.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Chào bạn nhen,',
                style: TextStyle(
                  color: Get.theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Chào mừng trở lại',
                style: TextStyle(
                  color: Get.theme.textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 40),
              _taoOTextForm(
                goiY: "Email",
                bieuTuong: Icons.email_outlined,
                controller: authController.loginEmailController,
              ),
              SizedBox(height: 15),
              _taoOTextForm(
                goiY: "Password",
                bieuTuong: Icons.lock_outline,
                laMatKhau: true,
                bieuTuongCuoi: Icons.visibility_off_outlined,
                controller: authController.loginPasswordController,
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: Color(0xFFACA3A5),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 250),
              GestureDetector(
                onTap: () {
                  authController.login();
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.login, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Hoặc',
                      style: TextStyle(
                        color: Get.theme.textTheme.bodyLarge?.color,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      authController.signInWithGoogle();
                    },
                    child: _taoNutMangXaHoi('assets/google.png'),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      authController.signInWithFacebook();
                    },
                    child: _taoNutMangXaHoi('assets/facebook.png'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Get.to(() => RegisterPage1());
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Bạn chưa có tài khoản? ',
                    style: TextStyle(
                      color: Get.theme.textTheme.bodyLarge?.color,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: 'Đăng ký ngay',
                        style: TextStyle(
                          color: Get.theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taoOTextForm({
    required String goiY,
    required IconData bieuTuong,
    bool laMatKhau = false,
    IconData? bieuTuongCuoi,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.brightness == Brightness.dark ? Get.theme.colorScheme.surface : const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: laMatKhau,
        decoration: InputDecoration(
          hintText: goiY,
          hintStyle: TextStyle(
            color: Color(0xFFACA3A5),
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(bieuTuong, color: Color(0xFF7B6F72), size: 20),
          suffixIcon: bieuTuongCuoi != null
              ? Icon(bieuTuongCuoi, color: Color(0xFF7B6F72), size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _taoNutMangXaHoi(String duongDanAnh) {
    return Container(
      width: 50,
      height: 50,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.80, color: Color(0xFFDDD9DA)),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Center(
        child: Image.asset(
          duongDanAnh,
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.link, size: 20, color: Colors.grey),
        ),
      ),
    );
  }
}
