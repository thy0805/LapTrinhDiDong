import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/nutrition/views/meal_details_screen.dart';
import 'package:nutrifit/modules/nutrition/views/add_meal_schedule_screen.dart';
import 'package:nutrifit/modules/nutrition/views/ai_scanner_screen.dart';
import 'package:nutrifit/modules/nutrition/controllers/food_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:nutrifit/core/utils/dynamic_text_helper.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';

class FoodManagementScreen extends StatefulWidget {
  final String? initialCategory;
  const FoodManagementScreen({super.key, this.initialCategory});

  @override
  State<FoodManagementScreen> createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen> with SingleTickerProviderStateMixin {
  final FoodController controller = Get.put(FoodController());
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
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  // Danh mục món ăn lấy từ Firestore nhen
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
    'Món truyền thống'
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppHeader(
                  title: _isSearching ? '' : 'Thực đơn 30 món',
                  showBackButton: true,
                  extraActions: [
                    PopupMenuItem(
                      value: 'search',
                      child: Row(
                        children: [
                          Icon(_isSearching ? Icons.close : Icons.search, size: 20, color: const Color(0xFF1D1517)),
                          const SizedBox(width: 10),
                          Text(_isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Tìm món ngon cho ${DynamicTextHelper.getName()}...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFFA5A3AF), fontSize: 14),
                      ),
                      style: const TextStyle(color: Color(0xFF1D1517), fontSize: 14),
                      onChanged: (value) => controller.setSearchText(value),
                    ),
                  ),
                ),
              const TabBar(
                isScrollable: false,
                labelColor: Color(0xFFC050F6),
                unselectedLabelColor: Color(0xFFB6B4C1),
                indicatorColor: Color(0xFFC050F6),
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
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _expandAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.small(
                    heroTag: 'camera_fab',
                    backgroundColor: const Color(0xFFCC8FED),
                    onPressed: () {
                      _toggleMenu();
                      Get.to(() => const AiScannerScreen());
                    },
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
              ScaleTransition(
                scale: _expandAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.small(
                    heroTag: 'manual_fab',
                    backgroundColor: const Color(0xFFEEA4CE),
                    onPressed: () {
                      _toggleMenu();
                      _showManualEntryPopup(context);
                    },
                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ),
              ),
              GestureDetector(
                onLongPress: _toggleMenu,
                child: FloatingActionButton(
                  heroTag: 'main_fab',
                  backgroundColor: const Color(0xFFC050F6),
                  elevation: 4,
                  onPressed: _toggleMenu,
                  child: AnimatedRotation(
                    turns: _isMenuOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1517).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nhập món ăn thủ công',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Tên món ăn...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFoodsTab() {
    return Column(
      children: [
        Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: _categories.map((cat) {
              bool isSelected = controller.selectedCategory.value == cat;
              return GestureDetector(
                onTap: () => controller.setCategory(cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC050F6)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC050F6)
                          : const Color(0xFFF7F8F8),
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFA5A3AF),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )),
        Expanded(
          child: Obx(() {
            if (controller.filteredFoods.isEmpty) {
               return const Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.no_food, size: 60, color: Color(0xFFB6B4C1)),
                     SizedBox(height: 16),
                     Text(
                       'Hổng tìm thấy món nào hết trơn!',
                       style: TextStyle(color: Color(0xFFB6B4C1), fontFamily: 'Poppins'),
                     ),
                   ],
                 ),
               );
            }
            return GridView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Đổi thành 2 cho hình to đẹp hơn
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: controller.filteredFoods.length,
              itemBuilder: (context, index) {
                return _buildGridFoodItem(controller.filteredFoods[index]);
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
        return const Center(
          child: Text(
            'Chưa có món ăn yêu thích nào.',
            style: TextStyle(color: Color(0xFFB6B4C1), fontFamily: 'Poppins'),
          ),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85,
        ),
        itemCount: favList.length,
        itemBuilder: (context, index) {
          return _buildGridFoodItem(favList[index]);
        },
      );
    });
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
      children: const [
        Text(
          'Gần đây',
          style: TextStyle(
            color: Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Chưa có lịch sử món ăn.',
              style: TextStyle(color: Color(0xFFB6B4C1), fontFamily: 'Poppins'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridFoodItem(FoodItem food) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const MealDetailsScreen(), arguments: food);
      },
      onLongPress: () {
        _showOptionsBottomSheet(food);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    child: Obx(() => GestureDetector(
                      onTap: () => controller.toggleFavorite(food),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          food.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                          color: food.isFavorite.value ? Colors.red : Colors.grey,
                          size: 18,
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${food.calories} kcal',
                    style: const TextStyle(
                      color: Color(0xFFC050F6),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1517).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                food.title,
                style: const TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => ListTile(
                leading: Icon(
                  food.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                  color: food.isFavorite.value ? Colors.red : const Color(0xFFB6B4C1),
                ),
                title: Text(
                  food.isFavorite.value ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  controller.toggleFavorite(food);
                  Navigator.pop(context);
                },
              )),
              ListTile(
                leading: const Icon(Icons.visibility, color: Color(0xFFB6B4C1)),
                title: const Text(
                  'Xem chi tiết',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const MealDetailsScreen(), arguments: food);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFB6B4C1),
                ),
                title: const Text(
                  'Đặt lịch ăn',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => AddMealScheduleScreen(foodName: food.title));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

