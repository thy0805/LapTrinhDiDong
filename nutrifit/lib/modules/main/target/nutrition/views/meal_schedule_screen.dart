import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/add_meal_schedule_screen.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'dart:io';

class MealScheduleScreen extends StatefulWidget {
  const MealScheduleScreen({super.key});

  @override
  State<MealScheduleScreen> createState() => _MealScheduleScreenState();
}

class _MealScheduleScreenState extends State<MealScheduleScreen> {
  late DateTime _ngayDuocChon;
  late List<DateTime> _danhSachNgay;
  late NutritionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NutritionController>();
    DateTime homNay = DateTime.now();
    _ngayDuocChon = DateTime(homNay.year, homNay.month, homNay.day);
    _taoDanhSachNgay();
    controller.fetchMealsByDate(_ngayDuocChon);
  }

  void _taoDanhSachNgay() {
    _danhSachNgay = [];
    for (int i = -3; i <= 30; i++) {
      _danhSachNgay.add(_ngayDuocChon.add(Duration(days: i)));
    }
  }

  Future<void> _chonNgayTuLich(BuildContext context) async {
    final DateTime? ngayMoi = await showDatePicker(
      context: context,
      initialDate: _ngayDuocChon,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Get.theme.colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Color(0xFF1D1517),
            ),
          ),
          child: child!,
        );
      },
    );

    if (ngayMoi != null && ngayMoi != _ngayDuocChon) {
      setState(() {
        _ngayDuocChon = ngayMoi;
        _taoDanhSachNgay();
      });
      controller.fetchMealsByDate(_ngayDuocChon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    String chuoiThangNam = 'Tháng ${_ngayDuocChon.month} ${_ngayDuocChon.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(title: 'Lịch ăn uống', showBackButton: true),
            ),
            SizedBox(height: chieuCao * 0.02),
            GestureDetector(
              onTap: () => _chonNgayTuLich(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Color(0xFFA5A3AF),
                    size: 14,
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  Text(
                    chuoiThangNam,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Color(0xFFA5A3AF),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Color(0xFFA5A3AF),
                    size: 14,
                  ),
                ],
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            SizedBox(
              height: chieuCao * 0.1,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.04),
                physics: BouncingScrollPhysics(),
                itemCount: _danhSachNgay.length,
                itemBuilder: (context, index) {
                  return _taoOChonNgay(_danhSachNgay[index], chieuRong);
                },
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            Expanded(
              child: Obx(() {
                final _ = controller.todayMeals.length;
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    int gio = index;
                    String chuoiGio = '${gio.toString().padLeft(2, '0')}:00';

                    final mealsInHour = controller.todayMeals.where((m) {
                      try {
                        String time = m['time']?.toString() ?? '';
                        if (time.isEmpty) return false;
                        int mealHour = int.tryParse(time.split(':')[0]) ?? -1;
                        return mealHour == gio;
                      } catch (e) {
                        return false;
                      }
                    }).toList();

                    return _taoDongThoiGian(
                      chuoiGio,
                      gio,
                      chieuRong,
                      mealsInHour,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x4C95ADFE),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'meal_schedule_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddMealScheduleScreen(initialDate: _ngayDuocChon),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _taoOChonNgay(DateTime ngay, double chieuRong) {
    bool dangChon =
        ngay.year == _ngayDuocChon.year &&
        ngay.month == _ngayDuocChon.month &&
        ngay.day == _ngayDuocChon.day;
    List<String> tenThu = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    String thuStr = tenThu[ngay.weekday - 1];

    return GestureDetector(
      onTap: () {
        setState(() {
          _ngayDuocChon = ngay;
          _taoDanhSachNgay();
        });
        controller.fetchMealsByDate(_ngayDuocChon);
      },
      child: Container(
        width: chieuRong * 0.16,
        margin: EdgeInsets.symmetric(horizontal: chieuRong * 0.015),
        decoration: BoxDecoration(
          gradient: dangChon
              ? LinearGradient(
                  colors: [
                    Get.theme.colorScheme.primary,
                    Get.theme.colorScheme.secondary,
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                )
              : null,
          color: dangChon
              ? null
              : (Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF1E293B)
                    : Color(0xFFF7F8F8)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              thuStr,
              style: TextStyle(
                color: dangChon
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Color(0xFF7B6F72)),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 5),
            Text(
              ngay.day.toString(),
              style: TextStyle(
                color: dangChon
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Color(0xFF7B6F72)),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoDongThoiGian(
    String chuoiGio,
    int gio,
    double chieuRong,
    List<Map<String, dynamic>> meals,
  ) {
    double chieuCaoO = meals.length > 1 ? (meals.length * 75.0 + 20.0) : 80.0;

    return SizedBox(
      width: chieuRong,
      height: chieuCaoO,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(width: chieuRong, height: chieuCaoO),
          Positioned(
            left: chieuRong * 0.06,
            top: 20,
            child: Text(
              chuoiGio,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Positioned(
            left: chieuRong * 0.2,
            right: chieuRong * 0.08,
            top: 28,
            child: Container(
              height: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Color(0xFFF7F8F8),
            ),
          ),
          if (meals.isNotEmpty)
            Positioned(
              left: chieuRong * 0.2,
              right: chieuRong * 0.08,
              top: 10,
              child: Column(
                children: meals
                    .map((m) => _taoTheLichAn(m, chieuRong))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _taoTheLichAn(Map<String, dynamic> meal, double chieuRong) {
    String hinhAnh = meal['image'] ?? '';
    String title = meal['name'] ?? 'Bữa ăn';
    String time = meal['time'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.1)
                : Color(0xFF1D1617).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildMealImage(hinhAnh),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Color(0xFF1D1517),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$time | ${meal['calories']}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Color(0xFFA5A3AF),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Color(0xFFA5A3AF),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'edit') {
                TimeOfDay? initialTime;
                try {
                  String timeStr = meal['time'] ?? '';
                  if (timeStr.isNotEmpty) {
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
                      foodName: title,
                      foodImage: hinhAnh,
                      initialType: meal['type'],
                      initialDate: _ngayDuocChon,
                      initialTime: initialTime,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                controller.removeMeal(meal['id']);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealImage(String? imageSource) {
    if (imageSource == null || imageSource.isEmpty) {
      return Icon(
        Icons.fastfood,
        color: Get.theme.colorScheme.primary,
        size: 20,
      );
    }
    try {
      if (imageSource.startsWith('http')) {
        return Image.network(
          imageSource,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Icon(
            Icons.fastfood,
            color: Get.theme.colorScheme.primary,
            size: 20,
          ),
        );
      } else if (imageSource.startsWith('/') || imageSource.contains('cache')) {
        return Image.file(
          File(imageSource),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Icon(
            Icons.fastfood,
            color: Get.theme.colorScheme.primary,
            size: 20,
          ),
        );
      } else {
        return Image.asset(
          imageSource,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Icon(
            Icons.fastfood,
            color: Get.theme.colorScheme.primary,
            size: 20,
          ),
        );
      }
    } catch (e) {
      return Icon(
        Icons.fastfood,
        color: Get.theme.colorScheme.primary,
        size: 20,
      );
    }
  }
}
