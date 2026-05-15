import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/workout/views/exercise_details_screen.dart';
import 'package:nutrifit/modules/workout/views/add_workout_schedule_screen.dart';
import 'package:nutrifit/modules/workout/views/workout_details_screen.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';

class ExerciseManagementScreen extends StatefulWidget {
  const ExerciseManagementScreen({super.key});

  @override
  State<ExerciseManagementScreen> createState() =>
      _ExerciseManagementScreenState();
}

class _ExerciseManagementScreenState extends State<ExerciseManagementScreen> {
  final WorkoutController controller = Get.put(WorkoutController());
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreExercises();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppHeader(
                  title: _isSearching ? '' : 'Quản lý bài tập',
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
                    PopupMenuItem(
                      value: 'lang',
                      child: Row(
                        children: [
                          const Icon(Icons.language, size: 20, color: Color(0xFF1D1517)),
                          const SizedBox(width: 10),
                          Obx(() => Text('Ngôn ngữ: ${controller.currentLanguage.value.toUpperCase()}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14))),
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
                    } else if (value == 'lang') {
                      controller.changeLanguage(controller.currentLanguage.value == 'en' ? 'vi' : 'en');
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
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm bài tập...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFFA5A3AF), fontSize: 14),
                      ),
                      style: const TextStyle(color: Color(0xFF1D1517), fontSize: 14),
                      onChanged: (value) => controller.setSearchText(value),
                    ),
                  ),
                ),
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Color(0xFFC050F6),
                unselectedLabelColor: Color(0xFFB6B4C1),
                indicatorColor: Color(0xFFC050F6),
                labelStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'Bài tập'),
                  Tab(text: 'Yêu thích'),
                  Tab(text: 'Combo'),
                  Tab(text: 'Lịch sử'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildExercisesTab(),
                    _buildFavoritesTab(),
                    _buildCombosTab(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesTab() {
    return Column(
      children: [
        Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: controller.availableCategories.map((cat) {
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
          child: Obx(() => CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildGridExerciseItem(controller.filteredExercises[index]);
                    },
                    childCount: controller.filteredExercises.length,
                  ),
                ),
              ),
              if (controller.isMoreLoading.value)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFC050F6),
                      ),
                    ),
                  ),
                ),
              if (!controller.hasMore.value && controller.allExercises.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Đã tải hết bài tập',
                        style: TextStyle(
                          color: Color(0xFFA5A3AF),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return Obx(() {
      final favList = controller.favoriteExercises;
      if (favList.isEmpty) {
        return const Center(
          child: Text(
            'Chưa có bài tập yêu thích nào.',
            style: TextStyle(color: Color(0xFFB6B4C1), fontFamily: 'Poppins'),
          ),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.8,
        ),
        itemCount: favList.length,
        itemBuilder: (context, index) {
          return _buildGridExerciseItem(favList[index]);
        },
      );
    });
  }

  Widget _buildCombosTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4C95ADFE),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tạo Combo Mới',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Ghép các bài tập theo ý thích của bạn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Combo của tôi',
          style: TextStyle(
            color: Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'Bạn chưa tạo combo nào.',
            style: TextStyle(color: Color(0xFFB6B4C1), fontFamily: 'Poppins'),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Combo đề xuất',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Xem thêm',
                style: TextStyle(
                  color: Color(0xFFA5A3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Obx(() => Column(
          children: controller.combos.map((combo) => _buildComboListItem(combo)).toList(),
        )),
      ],
    );
  }

  Widget _buildComboListItem(ComboItem combo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailsScreen(combo: combo),
          ),
        );
      },
      onLongPress: () {
        _showComboOptionsBottomSheet(combo);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFEEA4CE).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  combo.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fitness_center,
                    color: Color(0xFFC050F6),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      combo.title,
                      style: const TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      combo.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7B6F72),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => IconButton(
                icon: Icon(
                  combo.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                  color: combo.isFavorite.value ? Colors.red : const Color(0xFFA5A3AF),
                ),
                onPressed: () => controller.toggleComboFavorite(combo),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showComboOptionsBottomSheet(ComboItem combo) {
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
                combo.title,
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
                  combo.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: combo.isFavorite.value
                      ? Colors.red
                      : const Color(0xFFB6B4C1),
                ),
                title: Text(
                  combo.isFavorite.value
                      ? 'Bỏ khỏi yêu thích'
                      : 'Thêm vào yêu thích',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  controller.toggleComboFavorite(combo);
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailsScreen(combo: combo),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFB6B4C1),
                ),
                title: const Text(
                  'Đặt lịch tập',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWorkoutScheduleScreen(
                        exerciseName: combo.title,
                        exerciseImage: combo.image,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '30 ngày qua',
          style: TextStyle(
            color: Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 15),
        _buildHistoryItem(
          'Tập toàn thân cơ bản',
          'Hôm qua, 06:30 CH',
          '32 phút',
        ),
        _buildHistoryItem('Đốt mỡ bụng', '25 Tháng 5, 07:00 SA', '20 phút'),
        _buildHistoryItem('Tập thân trên', '23 Tháng 5, 05:45 CH', '40 phút'),
      ],
    );
  }

  Widget _buildHistoryItem(String name, String time, String duration) {
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
              color: const Color(0xFFC050F6).withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFFC050F6)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$time • $duration',
                  style: const TextStyle(
                    color: Color(0xFFA5A3AF),
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
  }

  Widget _buildGridExerciseItem(ExerciseItem exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailsScreen(exercise: exercise),
          ),
        );
      },
      onLongPress: () {
        _showOptionsBottomSheet(exercise);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEA4CE).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Hero(
                  tag: exercise.id,
                  child: CachedImageWidget(
                    id: exercise.id,
                    type: 'exercises',
                    url: exercise.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              Obx(() => Icon(
                exercise.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                color: exercise.isFavorite.value ? Colors.red : const Color(0xFFA5A3AF),
                size: 14,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(ExerciseItem exercise) {
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
                exercise.title,
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
                  exercise.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: exercise.isFavorite.value
                      ? Colors.red
                      : const Color(0xFFB6B4C1),
                ),
                title: Text(
                  exercise.isFavorite.value
                      ? 'Bỏ khỏi yêu thích'
                      : 'Thêm vào yêu thích',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  controller.toggleFavorite(exercise);
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseDetailsScreen(exercise: exercise),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFB6B4C1),
                ),
                title: const Text(
                  'Đặt lịch tập',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWorkoutScheduleScreen(
                        exerciseName: exercise.title,
                        exerciseImage: exercise.image,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

