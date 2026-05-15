import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/nutrition/views/food_management_screen.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class AddMealScheduleScreen extends StatefulWidget {
  final String? foodName;
  final int? foodCalories;
  final String? portionSize;
  final String? mealId;
  final String? initialType;
  final DateTime? initialDate;
  final List<bool>? initialRepeatDays;

  const AddMealScheduleScreen({
    super.key,
    this.foodName,
    this.foodCalories,
    this.portionSize,
    this.mealId,
    this.initialType,
    this.initialDate,
    this.initialRepeatDays,
  });

  @override
  State<AddMealScheduleScreen> createState() => _AddMealScheduleScreenState();
}

class _AddMealScheduleScreenState extends State<AddMealScheduleScreen> {
  late String _tagDuocChon;
  final List<String> _cacTag = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Bữa nhẹ'];
  final List<String> _ngayLapLai = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  late List<bool> _ngayDuocChonTrongTuan;
  late DateTime _ngayDuocChon;

  @override
  void initState() {
    super.initState();
    _tagDuocChon = widget.initialType ?? 'Bữa sáng';
    _ngayDuocChon = widget.initialDate ?? DateTime.now();
    _ngayDuocChonTrongTuan = widget.initialRepeatDays ?? [false, false, false, false, false, false, false];
  }

  String getVietnameseDate(DateTime date) {
    List<String> weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    String weekday = weekdays[date.weekday % 7];
    return '$weekday, ${date.day} Tháng ${date.month} ${date.year}';
  }

  Future<void> _chonNgay(BuildContext context) async {
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
          ),
          child: child!,
        );
      },
    );
    if (ngayMoi != null && ngayMoi != _ngayDuocChon) {
      setState(() {
        _ngayDuocChon = ngayMoi;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;
    
    String ngayHienTai = getVietnameseDate(_ngayDuocChon);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.08, vertical: chieuCao * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                title: widget.mealId != null ? 'Sửa lịch ăn' : 'Thêm lịch ăn',
                showBackButton: true,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _chonNgay(context),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFA5A3AF), size: 16),
                    const SizedBox(width: 10),
                    Text(
                      ngayHienTai,
                      style: const TextStyle(
                        color: Color(0xFFB6B4C1),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: chieuCao * 0.04),
              const Text(
                'Chọn Bữa Ăn',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: chieuCao * 0.02),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _cacTag.map((tag) {
                  bool isSelected = _tagDuocChon == tag;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tagDuocChon = tag;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFC050F6) : const Color(0xFFF7F8F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFA5A3AF),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: chieuCao * 0.05),
              const Text(
                'Lặp lại',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: chieuCao * 0.02),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_ngayLapLai.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _ngayDuocChonTrongTuan[index] = !_ngayDuocChonTrongTuan[index];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _ngayDuocChonTrongTuan[index]
                              ? const Color(0xFFC050F6)
                              : const Color(0xFFF7F8F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _ngayLapLai[index],
                            style: TextStyle(
                              color: _ngayDuocChonTrongTuan[index] ? Colors.white : const Color(0xFFA5A3AF),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: chieuCao * 0.05),
              const Text(
                'Chi tiết món ăn',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: chieuCao * 0.02),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FoodManagementScreen()),
                  );
                },
                child: _taoMenuTuyChon(Icons.restaurant_menu, 'Chọn món ăn', giaTri: widget.foodName ?? 'Chưa chọn món', coMuiTen: true),
              ),
              SizedBox(height: chieuCao * 0.015),
              _taoMenuTuyChon(Icons.category, 'Bữa ăn', giaTri: _tagDuocChon),
              SizedBox(height: chieuCao * 0.015),
              _taoMenuTuyChon(Icons.notifications_active, 'Thông báo', coMuiTen: true),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: chieuRong * 0.08, 
              right: chieuRong * 0.08, 
              bottom: chieuCao * 0.02, 
              top: chieuCao * 0.01
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: chieuCao * 0.075,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Center(
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Color(0xFFC050F6),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final NutritionController controller = Get.find<NutritionController>();
                      if (widget.mealId != null) {
                        controller.updateMeal(
                          id: widget.mealId!,
                          name: widget.foodName ?? 'Món tự chọn',
                          type: _tagDuocChon,
                        );
                      } else {
                        controller.addMeal(
                          widget.foodName ?? 'Món tự chọn',
                          _tagDuocChon,
                          calories: widget.foodCalories ?? 0,
                          portionSize: widget.portionSize ?? 'Medium',
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: chieuCao * 0.075,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
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
                          widget.mealId != null ? 'Cập nhật' : 'Thêm ngay',
                          style: const TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taoMenuTuyChon(IconData icon, String tieuDe, {String? giaTri, bool coMuiTen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB6B4C1), size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              tieuDe,
              style: const TextStyle(
                color: Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          if (giaTri != null)
            Text(
              giaTri,
              style: const TextStyle(
                color: Color(0xFFA5A3AF),
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
            ),
          if (coMuiTen || giaTri != null) ...[
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFA5A3AF), size: 14),
          ]
        ],
      ),
    );
  }
}
