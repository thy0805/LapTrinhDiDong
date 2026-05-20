import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/food_management_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/add_meal_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/ai_scanner_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/meal_schedule_screen.dart';
import 'package:nutrifit/core/services/media_service.dart';

class NutritionTargetTab extends StatefulWidget {
  const NutritionTargetTab({super.key});

  @override
  State<NutritionTargetTab> createState() => _NutritionTargetTabState();
}

class _NutritionTargetTabState extends State<NutritionTargetTab> {
  final NutritionController controller = Get.find<NutritionController>();

  @override
  void initState() {
    super.initState();
    DateTime homNay = DateTime.now();
    controller.fetchMealsByDate(DateTime(homNay.year, homNay.month, homNay.day));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          SizedBox(height: 15),
          _taoBieuDoDinhDuong(),
          SizedBox(height: 30),
          _buildMealsListSection(context),
          SizedBox(height: 30),
          _buildFoodSearchSection(context),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dinh dưỡng bữa ăn',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Text(
                'Hàng tuần',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildMealsListSection(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch ăn uống hàng ngày',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealScheduleScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Kiểm tra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bữa ăn trong ngày',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodManagementScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'Thêm mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Obx(() {
          if (controller.todayMeals.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '${Get.find<AuthController>().userData['gender'] == 'Male' ? 'Ông' : 'Bà'} chưa có món nào cho ngày này!',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.todayMeals.length,
            itemBuilder: (context, index) {
              final meal = controller.todayMeals[index];
              return _taoItemMonAnThuong(context, meal, controller);
            },
          );
        }),
      ],
    );
  }

  Widget _buildFoodSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gợi ý tìm món ăn',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 15),
        SizedBox(
          height: 170,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: [
              _taoTheTimMonAn(context, 'Bữa sáng', '120+ Món ăn', const [Color(0xFF00FF66), Color(0xFF00EFFF)]),
              SizedBox(width: 15),
              _taoTheTimMonAn(context, 'Bữa trưa', '130+ Món ăn', [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
              SizedBox(width: 15),
              _taoTheTimMonAn(context, 'Quét AI', 'Nhận diện món', [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary], isScanner: true),
            ],
          ),
        ),
      ],
    );
  }


  Widget _taoBieuDoDinhDuong() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Color(0x111D1617),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        return LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final style = TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1), fontSize: 10);
                    List<String> days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                    return Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt() % 7], style: style),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0, maxX: 6, minY: 0, maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(7, (index) => FlSpot(index.toDouble(), controller.weeklyNutritionData[index])),
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 2,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _taoItemMonAnThuong(BuildContext context, Map<String, dynamic> meal, NutritionController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.1) : Color(0x0D1D1617),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)),
            child: _buildMealImage(meal['image'], meal['id']),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['name'],
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${meal['time']} | ${meal['calories']}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF)),
            onSelected: (value) {
              if (value == 'edit') {
                TimeOfDay? initialTime;
                try {
                  String? timeStr = meal['time'];
                  if (timeStr != null) {
                    List<String> parts = timeStr.split(':');
                    int h = int.parse(parts[0]);
                    int m = int.parse(parts[1]);
                    initialTime = TimeOfDay(hour: h, minute: m);
                  }
                } catch (_) {}

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMealScheduleScreen(
                      mealId: meal['id'],
                      foodName: meal['name'],
                      foodImage: meal['image'],
                      initialType: meal['type'],
                      initialDate: DateTime.now(),
                      initialTime: initialTime,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                controller.removeMeal(meal['id']);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('Sửa')),
              PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _taoTheTimMonAn(BuildContext context, String title, String subtitle, List<Color> mauNen, {bool isScanner = false}) {
    return GestureDetector(
      onTap: () {
        if (isScanner) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AiScannerScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FoodManagementScreen(initialCategory: title)));
        }
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : mauNen[0].withValues(alpha: 0.2),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(80), bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(gradient: LinearGradient(colors: mauNen), borderRadius: BorderRadius.circular(50)),
              child: Text('Chọn', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealImage(String? imageSource, String? mealId) {
    if (imageSource == null || imageSource.isEmpty) {
      return Icon(Icons.fastfood, color: Get.theme.colorScheme.primary);
    }
    Widget img;
    if (imageSource.startsWith('http')) {
      final mediaService = Get.find<MediaService>();
      if (mealId != null) {
        final localPath = mediaService.getLocalPath(mealId, 'foods', imageSource);
        if (mediaService.isFileExists(localPath)) {
          img = Image.file(
            File(localPath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, color: Get.theme.colorScheme.primary),
          );
          return ClipOval(child: img);
        }
      }

      img = Image.network(
        imageSource, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, color: Get.theme.colorScheme.primary),
      );
    } else if (imageSource.startsWith('/') || imageSource.contains('cache')) {
      img = Image.file(
        File(imageSource), 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, color: Get.theme.colorScheme.primary),
      );
    } else {
      img = Image.asset(
        imageSource, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, color: Get.theme.colorScheme.primary),
      );
    }
    return ClipOval(child: img);
  }
}

