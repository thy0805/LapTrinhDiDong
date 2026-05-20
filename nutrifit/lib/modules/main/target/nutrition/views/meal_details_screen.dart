import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/add_meal_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';

class MealDetailsScreen extends StatefulWidget {
  const MealDetailsScreen({super.key});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  String selectedPortion = 'Medium';
  
  double getMultiplier() {
    if (selectedPortion == 'Small') return 0.8;
    if (selectedPortion == 'Large') return 1.2;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final FoodItem food = Get.arguments;
    final AuthController auth = Get.find<AuthController>();
    final String userName = auth.userData['fullName'] ?? 'Người dùng';
    final int calculatedCalories = (food.calories * getMultiplier()).round();
    
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Get.theme.colorScheme.primary,
            expandedHeight: chieuCao * 0.4,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              Obx(() => IconButton(
                icon: Icon(
                  food.isFavorite.value ? Icons.favorite : Icons.favorite_border, 
                  color: Colors.white
                ),
                onPressed: () => food.isFavorite.toggle(),
              )),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: food.id,
                    child: Image.network(
                      food.image,
                      width: 280,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.restaurant_menu,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
              child: Padding(
                padding: EdgeInsets.all(chieuRong * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: chieuRong * 0.13,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFF1D1517).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            food.title,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.purple.withValues(alpha: 0.2) : Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            food.category,
                            style: TextStyle(color: Get.theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(text: 'Dành riêng cho '),
                          TextSpan(
                            text: userName,
                            style: TextStyle(color: Get.theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.03),
                    
                    Text(
                      'Chọn khẩu phần của $userName',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPortionButton('Small', 'Nhỏ'),
                        _buildPortionButton('Medium', 'Vừa'),
                        _buildPortionButton('Large', 'Lớn'),
                      ],
                    ),
                    
                    SizedBox(height: chieuCao * 0.03),
                    Text(
                      'Dinh dưỡng dự kiến',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: [
                          _taoMucDinhDuong(
                            Icons.local_fire_department,
                            '$calculatedCalories kcal',
                          ),
                          _taoMucDinhDuong(Icons.scale, '1 ${food.unit}'),
                          _taoMucDinhDuong(Icons.timer, '15-20 phút'),
                        ],
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.03),
                    Text(
                      'Mô tả món ăn',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Món ${food.title} là một trong những niềm tự hào của ẩm thực Việt Nam. Đây là món ăn giàu dinh dưỡng, phù hợp để nạp năng lượng sau những buổi tập luyện vất vả cùng NutriFit.',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Color(0xFF7B6F72),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.03),
                    Text(
                      'Gợi ý kèm theo',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    SizedBox(
                      height: 130,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: [
                          _taoNguyenLieu(
                            Icons.local_drink,
                            'Nước lọc',
                            '500ml',
                            chieuRong,
                          ),
                          _taoNguyenLieu(
                            Icons.eco,
                            'Rau xanh',
                            '1 dĩa',
                            chieuRong,
                          ),
                          _taoNguyenLieu(
                            Icons.apple,
                            'Trái cây',
                            '1 phần',
                            chieuRong,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: chieuRong * 0.08,
              right: chieuRong * 0.08,
              bottom: chieuCao * 0.02,
              top: chieuCao * 0.01,
            ),
            child: GestureDetector(
              onTap: () {
                Get.to(() => AddMealScheduleScreen(
                  foodName: food.title,
                  foodCalories: food.calories,
                  foodImage: food.image,
                  portionSize: selectedPortion,
                ));
              },
              child: Container(
                height: chieuCao * 0.075,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                  ),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4C95ADFE),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Đặt lịch ăn ngay',
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
          ),
        ),
      ),
    );
  }

  Widget _buildPortionButton(String value, String label) {
    bool isSelected = selectedPortion == value;
    return GestureDetector(
      onTap: () => setState(() => selectedPortion = value),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Get.theme.colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8)),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF)),
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _taoMucDinhDuong(IconData icon, String thongTin) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Get.theme.colorScheme.primary.withValues(alpha: 0.2) : Get.theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Get.theme.colorScheme.primary, size: 18),
          SizedBox(width: 5),
          Text(
            thongTin,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoNguyenLieu(
    IconData icon,
    String ten,
    String soLuong,
    double chieuRong,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: chieuRong * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Get.theme.colorScheme.primary, size: 30),
          ),
          SizedBox(height: 10),
          Text(
            ten,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            soLuong,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
              fontSize: 10,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}


