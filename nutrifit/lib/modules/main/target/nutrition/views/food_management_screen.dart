import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/meal_details_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/add_meal_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/views/ai_scanner_screen.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';

class FoodManagementScreen extends StatefulWidget {
  final String? initialCategory;
  const FoodManagementScreen({super.key, this.initialCategory});

  @override
  State<FoodManagementScreen> createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen>
    with SingleTickerProviderStateMixin {
  final NutritionController controller = Get.find<NutritionController>();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      controller.setCategory(widget.initialCategory!);
    } else {
      controller.setCategory('Tất cả');
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  final List<String> _categories = [
    'Tất cả',
    'Món nước',
    'Món khô',
    'Ăn sáng',
    'Ăn sáng/trưa',
    'Quà vặt',
    'Ăn nhẹ',
    'Cơm gia đình',
    'Đồ ngọt',
    'Món truyền thống',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: null,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppHeader(
                  title: _isSearching ? '' : 'Thực đơn',
                  showBackButton: true,
                  extraActions: [
                    PopupMenuItem(
                      value: 'search',
                      child: Row(
                        children: [
                          Icon(
                            _isSearching ? Icons.close : Icons.search,
                            size: 20,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onActionSelected: (value) {
                    if (value == 'search') {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          controller.setSearchText('');
                        }
                      });
                    }
                  },
                ),
              ),
              if (_isSearching)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText:
                            'Tìm món ngon cho ${Get.find<AuthController>().userName}...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Color(0xFFA5A3AF),
                          fontSize: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 14,
                      ),
                      onChanged: (value) => controller.setSearchText(value),
                    ),
                  ),
                ),
              TabBar(
                isScrollable: false,
                labelColor: Get.theme.colorScheme.primary,
                unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                indicatorColor: Get.theme.colorScheme.primary,
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'Khám phá'),
                  Tab(text: 'Yêu thích'),
                  Tab(text: 'Lịch sử'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFoodsTab(),
                    _buildFavoritesTab(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _expandAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.small(
                    heroTag: 'camera_fab',
                    backgroundColor: Color(0xFFCC8FED),
                    onPressed: () {
                      _toggleMenu();
                      Get.to(() => AiScannerScreen());
                    },
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              ScaleTransition(
                scale: _expandAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.small(
                    heroTag: 'contribute_fab',
                    backgroundColor: Colors.orange,
                    onPressed: () {
                      _toggleMenu();
                      _showContributeFoodPopup(context);
                    },
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              ScaleTransition(
                scale: _expandAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.small(
                    heroTag: 'manual_fab',
                    backgroundColor: Get.theme.colorScheme.secondary,
                    onPressed: () {
                      _toggleMenu();
                      _showManualEntryPopup(context);
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onLongPress: _toggleMenu,
                child: FloatingActionButton(
                  heroTag: 'main_fab',
                  backgroundColor: Get.theme.colorScheme.primary,
                  elevation: 4,
                  onPressed: _toggleMenu,
                  child: AnimatedRotation(
                    turns: _isMenuOpen ? 0.125 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualEntryPopup(BuildContext context) {
    String tenMon = '';
    String soCalo = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFF1D1517).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Nhập món ăn thủ công',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  onChanged: (v) => tenMon = v,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Tên món ăn...',
                    hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  onChanged: (v) => soCalo = v,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Lượng Calo (kcal)...',
                    hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (tenMon.trim().isEmpty) {
                      Get.snackbar('Thông báo', 'Vui lòng nhập tên món ăn');
                      return;
                    }
                    Navigator.pop(context);
                    Get.to(() => AddMealScheduleScreen(
                      foodName: tenMon,
                      foodCalories: int.tryParse(soCalo) ?? 0,
                      portionSize: 'Medium',
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Get.theme.colorScheme.primary,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Tiếp tục', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContributeFoodPopup(BuildContext context) {
    String name = '';
    String calories = '';
    String protein = '0';
    String carbs = '0';
    String fat = '0';
    String category = 'Ăn nhẹ';
    String unit = 'Phần';
    String customUnit = '';
    bool showCustomUnit = false;
    File? imageFile;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final units = controller.availableUnits;
            if (!units.contains('Tùy chọn khác...')) {
              units.add('Tùy chọn khác...');
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFF1D1517).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Đóng góp món ăn mới',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (file != null) {
                              setModalState(() {
                                imageFile = File(file.path);
                              });
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: imageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(imageFile!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 30, color: Get.theme.colorScheme.primary),
                                      SizedBox(height: 8),
                                      Text(
                                        'Chọn ảnh',
                                        style: TextStyle(
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                                          fontSize: 11,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        onChanged: (v) => name = v,
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Tên món ăn...',
                          labelText: 'Tên món ăn',
                          hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) => calories = v,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Calo (kcal)...',
                                labelText: 'Lượng Calo',
                                hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: category,
                                  dropdownColor: Theme.of(context).colorScheme.surface,
                                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setModalState(() {
                                        category = v;
                                      });
                                    }
                                  },
                                  items: _categories.where((c) => c != 'Tất cả').map((c) {
                                    return DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontFamily: 'Poppins')));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: unit,
                                  dropdownColor: Theme.of(context).colorScheme.surface,
                                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setModalState(() {
                                        unit = v;
                                        showCustomUnit = (v == 'Tùy chọn khác...');
                                      });
                                    }
                                  },
                                  items: units.map((u) {
                                    return DropdownMenuItem(value: u, child: Text(u, style: TextStyle(fontFamily: 'Poppins')));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          if (showCustomUnit) ...[
                            SizedBox(width: 15),
                            Expanded(
                              child: TextField(
                                onChanged: (v) => customUnit = v,
                                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Nhập đơn vị...',
                                  labelText: 'Đơn vị tính',
                                  hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Thành phần dinh dưỡng (Tùy chọn)',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) => protein = v,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Protein (g)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => carbs = v,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Carbs (g)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => fat = v,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Fat (g)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (name.trim().isEmpty) {
                                  Get.snackbar('Lỗi', 'Vui lòng nhập tên món ăn');
                                  return;
                                }
                                if (calories.trim().isEmpty) {
                                  Get.snackbar('Lỗi', 'Vui lòng nhập lượng calo');
                                  return;
                                }
                                int cal = int.tryParse(calories) ?? 0;
                                String finalUnit = showCustomUnit ? customUnit : unit;
                                if (finalUnit.trim().isEmpty || finalUnit == 'Tùy chọn khác...') {
                                  Get.snackbar('Lỗi', 'Vui lòng chọn hoặc nhập đơn vị tính');
                                  return;
                                }

                                setModalState(() {
                                  isSubmitting = true;
                                });

                                bool success = await controller.contributeFood(
                                  name: name,
                                  calories: cal,
                                  category: category,
                                  unit: finalUnit,
                                  protein: protein,
                                  carbs: carbs,
                                  fat: fat,
                                  localImagePath: imageFile?.path,
                                );

                                setModalState(() {
                                  isSubmitting = false;
                                });

                                if (success) {
                                  Get.back();
                                  Get.snackbar('Thành công', 'Đã gửi yêu cầu duyệt món ăn mới. Cảm ơn bạn nhen!');
                                } else {
                                  Get.snackbar('Lỗi', 'Có lỗi xảy ra, vui lòng thử lại');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Get.theme.colorScheme.primary,
                          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text('Gửi đóng góp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFoodsTab() {
    return Column(
      children: [
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: _categories.map((cat) {
                bool isSelected = controller.selectedCategory.value == cat;
                return GestureDetector(
                  onTap: () => controller.setCategory(cat),
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Get.theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Get.theme.colorScheme.primary
                            : (Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8)),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF)),
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.filteredFoods.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food, size: 60, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Color(0xFFB6B4C1)),
                    SizedBox(height: 16),
                    Text(
                      'Hổng tìm thấy món nào hết trơn!',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }
            return GridView.builder(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 80),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: controller.filteredFoods.length,
              itemBuilder: (context, index) {
                return _buildGridFoodItem(context, controller.filteredFoods[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return Obx(() {
      final favList = controller.favoriteFoods;
      if (favList.isEmpty) {
        return Center(
          child: Text(
            'Chưa có món ăn yêu thích nào.',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1), fontFamily: 'Poppins'),
          ),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 80,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85,
        ),
        itemCount: favList.length,
        itemBuilder: (context, index) {
          return _buildGridFoodItem(context, favList[index]);
        },
      );
    });
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      if (controller.isLoadingHistory.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.mealHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 15),
              Text(
                'Chưa có lịch sử ăn uống nào',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        itemCount: controller.mealHistory.length,
        itemBuilder: (context, index) {
          final meal = controller.mealHistory[index];
          final String name = meal['foodName'] ?? 'Bữa ăn';
          final String type = meal['mealType'] ?? 'Khác';
          final double cal = (meal['totalCalories'] is num) ? (meal['totalCalories'] as num).toDouble() : 0.0;
          
          DateTime date;
          if (meal['timestamp'] is Timestamp) {
            date = (meal['timestamp'] as Timestamp).toDate();
          } else if (meal['timestamp'] is DateTime) {
            date = meal['timestamp'] as DateTime;
          } else {
            date = DateTime.now();
          }

          String formattedDate = _formatHistoryDate(date);
          String hinhAnh = meal['image_url'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : const Color(0x111D1617),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildHistoryMealImage(hinhAnh),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$type • ${cal.toStringAsFixed(0)} kcal • $formattedDate',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFFA5A3AF),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  String _formatHistoryDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    String timeStr = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hôm nay, $timeStr';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Hôm qua, $timeStr';
    } else {
      return '${date.day}/${date.month}, $timeStr';
    }
  }

  Widget _buildHistoryMealImage(String? imageSource) {
    if (imageSource == null || imageSource.isEmpty) {
      return Icon(Icons.fastfood, color: Get.theme.colorScheme.primary, size: 24);
    }
    try {
      if (imageSource.startsWith('http')) {
        return Image.network(
          imageSource,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Get.theme.colorScheme.primary, size: 24),
        );
      } else if (imageSource.startsWith('/') || imageSource.contains('cache')) {
        return Image.file(
          File(imageSource),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Get.theme.colorScheme.primary, size: 24),
        );
      } else {
        return Image.asset(
          imageSource,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Icon(Icons.fastfood, color: Get.theme.colorScheme.primary, size: 24),
        );
      }
    } catch (e) {
      return Icon(Icons.fastfood, color: Get.theme.colorScheme.primary, size: 24);
    }
  }

  Widget _buildGridFoodItem(BuildContext context, FoodItem food) {
    return GestureDetector(
      onTap: () {
        Get.to(() => MealDetailsScreen(), arguments: food);
      },
      onLongPress: () {
        _showOptionsBottomSheet(food);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: CachedImageWidget(
                      id: food.id,
                      type: 'foods',
                      url: food.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(
                      () => GestureDetector(
                        onTap: () => controller.toggleFavorite(food),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            food.isFavorite.value
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: food.isFavorite.value
                                ? Colors.red
                                : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${food.calories} kcal',
                    style: TextStyle(
                      color: Get.theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(FoodItem food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFF1D1517).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Text(
                food.title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),
              Obx(
                () => ListTile(
                  leading: Icon(
                    food.isFavorite.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: food.isFavorite.value
                        ? Colors.red
                        : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1)),
                  ),
                  title: Text(
                    food.isFavorite.value
                        ? 'Bỏ khỏi yêu thích'
                        : 'Thêm vào yêu thích',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  ),
                  onTap: () {
                    controller.toggleFavorite(food);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.visibility, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1)),
                title: Text(
                  'Xem chi tiết',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => MealDetailsScreen(), arguments: food);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                ),
                title: Text(
                  'Đặt lịch ăn',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => AddMealScheduleScreen(
                    foodName: food.title,
                    foodCalories: food.calories,
                    foodImage: food.image,
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

