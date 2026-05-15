import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/nutrition/views/meal_schedule_screen.dart';
import 'package:nutrifit/modules/nutrition/views/food_management_screen.dart';
import 'package:nutrifit/modules/nutrition/views/add_meal_schedule_screen.dart';
import 'package:nutrifit/modules/nutrition/controllers/nutrition_controller.dart';

class NutritionTargetTab extends StatelessWidget {
  const NutritionTargetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final NutritionController controller = Get.put(NutritionController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dinh dưỡng bữa ăn',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Hàng tuần',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _taoBieuDoDinhDuong(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFC050F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch ăn uống hằng ngày',
                  style: TextStyle(
                    color: Color(0xFF1D1517),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
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
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hôm nay ăn gì',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodManagementScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    'Thêm ngay',
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
          const SizedBox(height: 15),
          Obx(() {
            if (controller.todayMeals.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Bạn chưa thêm món nào cho hôm nay!',
                    style: TextStyle(
                      color: Color(0xFFB6B4C1),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.todayMeals.length,
              itemBuilder: (context, index) {
                final meal = controller.todayMeals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x111D1617),
                        blurRadius: 40,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEEA4CE).withValues(alpha: 0.2),
                        ),
                        child: _buildMealImage(meal['image']),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal['name'],
                              style: const TextStyle(
                                color: Color(0xFF1D1517),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${meal['time']} | ${meal['calories']}',
                              style: const TextStyle(
                                color: Color(0xFFA5A3AF),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFFA5A3AF)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMealScheduleScreen(
                                  mealId: meal['id'],
                                  foodName: meal['name'],
                                  initialType: meal['type'],
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            controller.removeMeal(meal['id']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Chỉnh sửa'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 30),
          const Text(
            'Tìm món ăn',
            style: TextStyle(
              color: Color(0xFF1D1517),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 170,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _taoTheTimMonAn(context, 'Bữa sáng', '120+ Món ăn', const [
                  Color(0xFF00FF66),
                  Color(0xFF00EFFF),
                ]),
                const SizedBox(width: 15),
                _taoTheTimMonAn(context, 'Bữa trưa', '130+ Món ăn', const [
                  Color(0xFFC050F6),
                  Color(0xFFEEA4CE),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoBieuDoDinhDuong() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x111D1617),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        final NutritionController controller = Get.find<NutritionController>();
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: const Color(0xFFF7F8F8), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Color(0xFFB6B4C1),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    );
                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = const Text('CN', style: style);
                        break;
                      case 1:
                        text = const Text('T2', style: style);
                        break;
                      case 2:
                        text = const Text('T3', style: style);
                        break;
                      case 3:
                        text = const Text('T4', style: style);
                        break;
                      case 4:
                        text = const Text('T5', style: style);
                        break;
                      case 5:
                        text = const Text('T6', style: style);
                        break;
                      case 6:
                        text = const Text('T7', style: style);
                        break;
                      default:
                        text = const Text('', style: style);
                        break;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: text,
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(7, (index) {
                  return FlSpot(index.toDouble(), controller.weeklyNutritionData[index]);
                }),
                isCurved: true,
                color: const Color(0xFF00EFFF),
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 1,
                        strokeColor: const Color(0xFF00EFFF),
                      ),
                ),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _taoTheTimMonAn(
    BuildContext context,
    String title,
    String subtitle,
    List<Color> mauNen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodManagementScreen(
              initialCategory: title,
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: mauNen[0].withValues(alpha: 0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(80),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: mauNen),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'Chọn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealImage(String? imageSource) {
    if (imageSource == null || imageSource.isEmpty) {
      return const Icon(Icons.fastfood, color: Color(0xFFC050F6));
    }

    Widget imageWidget;
    if (imageSource.startsWith('http')) {
      imageWidget = Image.network(imageSource, fit: BoxFit.cover);
    } else if (imageSource.startsWith('/') || imageSource.contains('cache')) {
      imageWidget = Image.file(File(imageSource), fit: BoxFit.cover);
    } else {
      imageWidget = Image.asset(imageSource, fit: BoxFit.cover);
    }

    return ClipOval(
      child: imageWidget,
    );
  }
}
