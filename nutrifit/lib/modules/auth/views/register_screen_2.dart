import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_screen_3.dart';

class RegisterPage2 extends StatelessWidget {
  const RegisterPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/reg2.png',
                height: 250,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),
              Text(
                'Hoàn thiện hồ sơ của bạn',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Nó sẽ giúp chúng tôi hiểu rõ hơn về bạn!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B6F72),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 30),
              _buildDropdownField(authController),
              SizedBox(height: 15),
              _buildTextFieldWithSuffixIcon(
                hintText: "Ngày sinh",
                icon: Icons.calendar_today_outlined,
                suffixIcon: Icons.keyboard_arrow_down,
                controller: authController.regDobController,
              ),
              SizedBox(height: 15),
              _buildTextFieldWithUnit(
                hintText: "Cân nặng của bạn",
                icon: Icons.monitor_weight_outlined,
                unit: "KG",
                controller: authController.regWeightController,
              ),
              SizedBox(height: 15),
              _buildTextFieldWithUnit(
                hintText: "Chiều cao của bạn",
                icon: Icons.height_outlined,
                unit: "CM",
                controller: authController.regHeightController,
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  Get.to(() => RegisterPage3());
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
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
                      Text(
                        'Tiếp theo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
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

  Widget _buildDropdownField(AuthController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: Obx(
          () => DropdownButton<String>(
            isExpanded: true,
            value: controller.selectedGender.value.isEmpty
                ? null
                : controller.selectedGender.value,
            hint: Row(
              children: const [
                Icon(Icons.group_outlined, color: Color(0xFF7B6F72), size: 20),
                SizedBox(width: 10),
                Text(
                  "Chọn giới tính",
                  style: TextStyle(
                    color: Color(0xFFACA3A5),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            items: <String>['Nam', 'Nữ', 'Khác'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                controller.selectedGender.value = newValue;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithSuffixIcon({
    required String hintText,
    required IconData icon,
    required IconData suffixIcon,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Color(0xFFACA3A5),
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
          prefixIcon: Icon(icon, color: Color(0xFF7B6F72), size: 20),
          suffixIcon: Icon(
            suffixIcon,
            color: Color(0xFF7B6F72),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithUnit({
    required String hintText,
    required IconData icon,
    required String unit,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Color(0xFFACA3A5),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
                prefixIcon: Icon(
                  icon,
                  color: Color(0xFF7B6F72),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                unit,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
