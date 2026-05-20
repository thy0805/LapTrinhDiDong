import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class MucTieu {
  final String hinhAnh;
  final String tieuDe;
  final String moTa;

  MucTieu({required this.hinhAnh, required this.tieuDe, required this.moTa});
}

class RegisterPage3 extends StatefulWidget {
  const RegisterPage3({super.key});

  @override
  State<RegisterPage3> createState() => _RegisterPage3State();
}

class _RegisterPage3State extends State<RegisterPage3> {
  final PageController _dieuKhienTrang = PageController(viewportFraction: 0.75);
  final AuthController authController = Get.find<AuthController>();

  final List<MucTieu> danhSachMucTieu = [
    MucTieu(
      hinhAnh: 'assets/goal1.png',
      tieuDe: 'Cải Thiện Vóc dáng',
      moTa:
          'Lượng mỡ trong cơ thể tui rất thấp nên tui muốn xây dựng thêm cơ bắp ',
    ),
    MucTieu(
      hinhAnh: 'assets/goal2.png',
      tieuDe: 'Săn chắc & Thon gọn',
      moTa: 'Tui thuộc tạng người "skinny fat". Tui muốn tăng cơ nạc đúng cách',
    ),
    MucTieu(
      hinhAnh: 'assets/goal3.png',
      tieuDe: 'Giảm mỡ',
      moTa: 'Tui đang thừa cân và tui muốn giảm cân để có cơ thể khỏe mạnh hơn',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'Mục tiêu của bạn là gì?',
              style: TextStyle(
                color: Get.theme.textTheme.bodyLarge?.color,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'Nó sẽ giúp chúng tôi chọn chương trình tốt nhất cho bạn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B6F72),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: PageView.builder(
                controller: _dieuKhienTrang,
                itemCount: danhSachMucTieu.length,
                onPageChanged: (index) {
                  authController.selectedGoal.value =
                      danhSachMucTieu[index].tieuDe;
                },
                itemBuilder: (context, index) {
                  return _taoTheMucTieu(danhSachMucTieu[index]);
                },
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: GestureDetector(
                onTap: () {
                  if (authController.auth.currentUser != null) {
                    authController.updateSocialProfile();
                  } else {
                    authController.register();
                  }
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
                  child: Center(
                    child: Text(
                      'Xác nhận',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoTheMucTieu(MucTieu mucTieu) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        shadows: const [
          BoxShadow(
            color: Color(0x4CC58BF2),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              mucTieu.hinhAnh,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 20),
          Text(
            mucTieu.tieuDe,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Container(width: 50, height: 1, color: Colors.white),
          SizedBox(height: 15),
          Text(
            mucTieu.moTa,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
