import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/food_management_screen.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class AddMealScheduleScreen extends StatefulWidget {
  final String? foodName;
  final int? foodCalories;
  final String? foodImage;
  final String? portionSize;
  final String? mealId;
  final String? initialType;
  final DateTime? initialDate;
  final List<bool>? initialRepeatDays;
  final TimeOfDay? initialTime;

  const AddMealScheduleScreen({
    super.key,
    this.foodName,
    this.foodCalories,
    this.foodImage,
    this.portionSize,
    this.mealId,
    this.initialType,
    this.initialDate,
    this.initialRepeatDays,
    this.initialTime,
  });

  @override
  State<AddMealScheduleScreen> createState() => _AddMealScheduleScreenState();
}

class _AddMealScheduleScreenState extends State<AddMealScheduleScreen> {
  late String _mainMealType;
  bool _isSnack = false;
  final List<String> _ngayLapLai = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  late List<bool> _ngayDuocChonTrongTuan;
  late DateTime _ngayDuocChon;
  TimeOfDay? _gioDuocChon;

  @override
  void initState() {
    super.initState();
    String type = widget.initialType ?? 'Bữa sáng';
    _ngayDuocChon = widget.initialDate ?? DateTime.now();
    _ngayDuocChonTrongTuan = widget.initialRepeatDays ?? [false, false, false, false, false, false, false];
    _gioDuocChon = widget.initialTime;

    if (type == 'Bữa nhẹ') {
      _isSnack = true;
      if (_gioDuocChon != null) {
        int hour = _gioDuocChon!.hour;
        if (hour >= 6 && hour <= 10) {
          _mainMealType = 'Bữa sáng';
        } else if (hour >= 11 && hour <= 15) {
          _mainMealType = 'Bữa trưa';
        } else {
          _mainMealType = 'Bữa tối';
        }
      } else {
        _mainMealType = 'Bữa sáng';
      }
    } else {
      _isSnack = false;
      _mainMealType = type;
    }
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
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
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
      });
    }
  }

  Future<void> _chonGio(BuildContext context) async {
    final TimeOfDay? gioMoi = await showTimePicker(
      context: context,
      initialTime: _gioDuocChon ?? TimeOfDay.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (gioMoi != null) {
      setState(() {
        _gioDuocChon = gioMoi;
      });
    }
  }

  Future<void> _hienThiChonBuaAn(BuildContext context) async {
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn bữa ăn',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 15),
            ...['Bữa sáng', 'Bữa trưa', 'Bữa tối'].map((tag) {
              bool isSelected = _mainMealType == tag;
              return InkWell(
                onTap: () {
                  setState(() {
                    _mainMealType = tag;
                  });
                  Get.back();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Get.theme.colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: Get.theme.colorScheme.primary),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;
    
    String ngayHienTai = getVietnameseDate(_ngayDuocChon);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _chonNgay(context),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF), size: 16),
                    SizedBox(width: 10),
                    Text(
                      ngayHienTai,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: chieuCao * 0.04),
              Text(
                'Lặp lại',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
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
                        margin: EdgeInsets.only(right: 10),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _ngayDuocChonTrongTuan[index]
                              ? Get.theme.colorScheme.primary
                              : (Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _ngayLapLai[index],
                            style: TextStyle(
                              color: _ngayDuocChonTrongTuan[index] ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF)),
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
              Text(
                'Chi tiết món ăn',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
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
                    MaterialPageRoute(builder: (context) => FoodManagementScreen()),
                  );
                },
                child: _taoMenuTuyChon(context, Icons.restaurant_menu, 'Chọn món ăn', giaTri: widget.foodName ?? 'Chưa chọn món', coMuiTen: true),
              ),
              SizedBox(height: chieuCao * 0.015),
              GestureDetector(
                onTap: () => _chonGio(context),
                child: _taoMenuTuyChon(
                  context, 
                  Icons.access_time, 
                  'Thời gian ăn', 
                  giaTri: _gioDuocChon != null ? _gioDuocChon!.format(context) : 'Tự động', 
                  coMuiTen: true
                ),
              ),
              SizedBox(height: chieuCao * 0.015),
              GestureDetector(
                onTap: () => _hienThiChonBuaAn(context),
                child: _taoMenuTuyChon(context, Icons.category, 'Bữa ăn', giaTri: _mainMealType, coMuiTen: true),
              ),
              SizedBox(height: chieuCao * 0.015),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSnack = !_isSnack;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.spa, color: _isSnack ? Get.theme.colorScheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF))),
                      SizedBox(width: 15),
                      Text(
                        'Là bữa nhẹ (Snack)',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Spacer(),
                      Switch(
                        value: _isSnack,
                        onChanged: (val) {
                          setState(() {
                            _isSnack = val;
                          });
                        },
                        activeTrackColor: Get.theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: chieuCao * 0.015),
              _taoMenuTuyChon(context, Icons.notifications_active, 'Thông báo', coMuiTen: true),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Center(
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Get.theme.colorScheme.primary,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final NutritionController controller = Get.find<NutritionController>();
                      DateTime? customTime;
                      if (_gioDuocChon != null) {
                        customTime = DateTime(
                          _ngayDuocChon.year,
                          _ngayDuocChon.month,
                          _ngayDuocChon.day,
                          _gioDuocChon!.hour,
                          _gioDuocChon!.minute,
                        );
                      } else {
                        int hour = 9;
                        if (_mainMealType == 'Bữa trưa') {
                          hour = 14;
                        } else if (_mainMealType == 'Bữa tối') {
                          hour = 17;
                        } else if (!_isSnack) {
                          if (_mainMealType == 'Bữa sáng') hour = 7;
                          if (_mainMealType == 'Bữa trưa') hour = 12;
                          if (_mainMealType == 'Bữa tối') hour = 18;
                        }
                        customTime = DateTime(
                          _ngayDuocChon.year,
                          _ngayDuocChon.month,
                          _ngayDuocChon.day,
                          hour,
                          0,
                        );
                      }

                      String mealType = _isSnack ? 'Bữa nhẹ' : _mainMealType;

                      if (widget.mealId != null) {
                        controller.updateMeal(
                          id: widget.mealId!,
                          name: widget.foodName ?? 'Món tự chọn',
                          type: mealType,
                          customTime: customTime,
                        );
                      } else {
                        controller.addMeal(
                          widget.foodName ?? 'Món tự chọn',
                          mealType,
                          calories: widget.foodCalories ?? 0,
                          imageUrl: widget.foodImage,
                          portionSize: widget.portionSize ?? 'Medium',
                          customTime: customTime,
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: chieuCao * 0.075,
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
                          widget.mealId != null ? 'Cập nhật' : 'Thêm ngay',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taoMenuTuyChon(BuildContext context, IconData icon, String tieuDe, {String? giaTri, bool coMuiTen = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1), size: 20),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              tieuDe,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          if (giaTri != null)
            Text(
              giaTri,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
            ),
          if (coMuiTen || giaTri != null) ...[
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF), size: 14),
          ]
        ],
      ),
    );
  }
}
