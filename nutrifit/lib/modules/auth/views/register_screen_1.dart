import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_screen_2.dart';
import 'login_screen.dart';

class RegisterPage1 extends StatefulWidget {
  const RegisterPage1({super.key});

  @override
  State<RegisterPage1> createState() => _RegisterPage1State();
}

class _RegisterPage1State extends State<RegisterPage1> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Chào bạn nhen,',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 30),

              _taoONhapLieu(
                goiY: "Họ và tên",
                bieuTuong: Icons.person_outline,
                controller: authController.regNameController,
              ),
              SizedBox(height: 15),
              _taoONhapLieu(
                goiY: "Số điện thoại",
                bieuTuong: Icons.phone_android,
                controller: authController.regPhoneController,
              ),
              SizedBox(height: 15),
              _taoONhapLieu(
                goiY: "Email",
                bieuTuong: Icons.email_outlined,
                controller: authController.regEmailController,
              ),
              SizedBox(height: 15),
              _taoONhapLieu(
                goiY: "Mật khẩu",
                bieuTuong: Icons.lock_outline,
                laMatKhau: true,
                controller: authController.regPasswordController,
              ),

              SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: Get.theme.colorScheme.primary,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Bằng cách tiếp tục, bạn đồng ý với Chính sách bảo mật và Điều khoản sử dụng của chúng tôi',
                      style: TextStyle(
                        color: Color(0xFFACA3A5),
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              GestureDetector(
                onTap: () {
                  if (isChecked) {
                    Get.to(() => RegisterPage2());
                  } else {
                    Get.snackbar(
                      "Thông báo",
                      "Vui lòng đồng ý với điều khoản sử dụng!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orangeAccent,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
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
                  child: Center(
                    child: Text(
                      'Đăng ký',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25),

              Row(
                children: const [
                  Expanded(
                    child: Divider(color: Color(0xFFDDD9DA), thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Hoặc',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Color(0xFFDDD9DA), thickness: 1),
                  ),
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
                  Get.to(() => LoginPage());
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Bạn đã có tài khoản? ',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextSpan(
                        text: 'Đăng nhập',
                        style: TextStyle(
                          color: Get.theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
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

  Widget _taoONhapLieu({
    required String goiY,
    required IconData bieuTuong,
    bool laMatKhau = false,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : const Color(0xFFF7F8F8),
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
          prefixIcon: Icon(bieuTuong, color: Color(0xFF7B6F72)),
          suffixIcon: laMatKhau
              ? Icon(Icons.visibility_off, color: Color(0xFF7B6F72))
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
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDDD9DA), width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Image.asset(
          duongDanAnh,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.broken_image, color: Colors.grey, size: 24),
        ),
      ),
    );
  }
}
