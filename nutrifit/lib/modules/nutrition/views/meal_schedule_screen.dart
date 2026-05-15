import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/nutrition/views/food_management_screen.dart';
import 'package:nutrifit/modules/nutrition/views/ai_scanner_screen.dart';
import 'package:nutrifit/modules/nutrition/views/add_meal_schedule_screen.dart';
import 'package:nutrifit/modules/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class MealScheduleScreen extends StatefulWidget {
  const MealScheduleScreen({super.key});

  @override
  State<MealScheduleScreen> createState() => _MealScheduleScreenState();
}

class _MealScheduleScreenState extends State<MealScheduleScreen> {
  late DateTime _ngayDuocChon;
  late List<DateTime> _danhSachNgay;

  @override
  void initState() {
    super.initState();
    DateTime homNay = DateTime.now();
    _ngayDuocChon = DateTime(homNay.year, homNay.month, homNay.day);
    _taoDanhSachNgay();
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC050F6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D1517),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC050F6),
              ),
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
    }
  }

  void _hienThiPopupCauHinh(BuildContext context, String tenMon, bool laMonTuTao) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1517).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cấu hình món: $tenMon',
                style: const TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              if (laMonTuTao) ...[
                const Text(
                  'Đây là món tự chụp, vui lòng nhập lượng Calo:',
                  style: TextStyle(
                    color: Color(0xFFB6B4C1),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Nhập số Calo (VD: 300)',
                    border: OutlineInputBorder(),
                    suffixText: 'kCal',
                  ),
                ),
              ] else ...[
                const Text(
                  'Nhập khẩu phần ăn để tính toán Calo tự động:',
                  style: TextStyle(
                    color: Color(0xFFB6B4C1),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Nhập lượng (VD: 100)',
                    border: OutlineInputBorder(),
                    suffixText: 'Gram',
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC050F6),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Lưu cấu hình',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NutritionController controller = Get.put(NutritionController());
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    String chuoiThangNam = 'Tháng ${_ngayDuocChon.month} ${_ngayDuocChon.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(
                title: 'Lịch ăn uống',
                showBackButton: true,
                extraActions: [
                  PopupMenuItem(
                    value: 'scanner',
                    child: Row(
                      children: [
                        Icon(Icons.document_scanner_outlined, size: 20, color: Color(0xFFC050F6)),
                        SizedBox(width: 10),
                        Text('Quét món ăn AI', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                onActionSelected: (value) {
                  if (value == 'scanner') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AiScannerScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            GestureDetector(
              onTap: () => _chonNgayTuLich(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFFA5A3AF),
                    size: 14,
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  Text(
                    chuoiThangNam,
                    style: const TextStyle(
                      color: Color(0xFFA5A3AF),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: chieuRong * 0.05),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFA5A3AF),
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
                physics: const BouncingScrollPhysics(),
                itemCount: _danhSachNgay.length,
                itemBuilder: (context, index) {
                  return _taoOChonNgay(_danhSachNgay[index], chieuRong);
                },
              ),
            ),
            SizedBox(height: chieuCao * 0.02),
            Expanded(
              child: Obx(() {
                if (controller.todayMeals.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bạn chưa lên lịch bữa ăn nào cho ngày này.',
                      style: TextStyle(
                        color: Color(0xFFB6B4C1),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.06),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.todayMeals.length,
                  itemBuilder: (context, index) {
                    final meal = controller.todayMeals[index];
                    return _taoItemMonAnThuong(
                      context,
                      meal['name'],
                      '${meal['type']} | ${meal['calories']}',
                      Icons.restaurant_menu,
                      false,
                      meal,
                      controller,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FoodManagementScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
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
      },
      child: Container(
        width: chieuRong * 0.16,
        margin: EdgeInsets.symmetric(horizontal: chieuRong * 0.015),
        decoration: BoxDecoration(
          gradient: dangChon
              ? const LinearGradient(
                  colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                )
              : null,
          color: dangChon ? null : const Color(0xFFF7F8F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              thuStr,
              style: TextStyle(
                color: dangChon ? Colors.white : const Color(0xFF7B6F72),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              ngay.day.toString(),
              style: TextStyle(
                color: dangChon ? Colors.white : const Color(0xFF7B6F72),
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

  Widget _taoItemMonAnThuong(
    BuildContext context,
    String tenMon,
    String thoiGian,
    IconData icon,
    bool laMonTuTao,
    Map<String, dynamic> meal,
    NutritionController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D1617).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildMealImage(meal['image'], icon, laMonTuTao),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenMon,
                  style: const TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  thoiGian,
                  style: TextStyle(
                    color: laMonTuTao ? Colors.redAccent : const Color(0xFFB6B4C1),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFB6B4C1)),
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
              } else if (value == 'config') {
                _hienThiPopupCauHinh(context, tenMon, laMonTuTao);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'config',
                child: Text('Cấu hình Calo'),
              ),
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
  }

  Widget _buildMealImage(String? imageSource, IconData fallbackIcon, bool laMonTuTao) {
    if (imageSource == null || imageSource.isEmpty) {
      return Icon(fallbackIcon, color: laMonTuTao ? Colors.orange : const Color(0xFFB6B4C1));
    }

    Widget imageWidget;
    if (imageSource.startsWith('http')) {
      imageWidget = Image.network(imageSource, fit: BoxFit.cover);
    } else if (imageSource.startsWith('/') || imageSource.contains('cache')) {
      // Đây là đường dẫn file cục bộ từ AI Scanner
      imageWidget = Image.file(File(imageSource), fit: BoxFit.cover);
    } else {
      // Đây là asset mặc định
      imageWidget = Image.asset(imageSource, fit: BoxFit.cover);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
    );
  }
}
