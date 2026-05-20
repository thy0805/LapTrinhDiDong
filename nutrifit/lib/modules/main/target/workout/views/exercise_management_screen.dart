import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/target/workout/views/exercise_details_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/add_workout_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_details_screen.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: null,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppHeader(
                  title: _isSearching ? '' : 'Quản lý bài tập',
                  showBackButton: true,
                  extraActions: [
                    PopupMenuItem(
                      value: 'search',
                      child: Row(
                        children: [
                          Icon(_isSearching ? Icons.close : Icons.search, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
                          SizedBox(width: 10),
                          Text(_isSearching ? 'Đóng tìm kiếm' : 'Tìm kiếm', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'lang',
                      child: Row(
                        children: [
                          Icon(Icons.language, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
                          SizedBox(width: 10),
                          Obx(() => Text('Ngôn ngữ: ${controller.currentLanguage.value.toUpperCase()}', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        hintText: 'Tìm kiếm bài tập...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Color(0xFFA5A3AF), fontSize: 14),
                      ),
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517), fontSize: 14),
                      onChanged: (value) => controller.setSearchText(value),
                    ),
                  ),
                ),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Get.theme.colorScheme.primary,
                unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Color(0xFFB6B4C1),
                indicatorColor: Get.theme.colorScheme.primary,
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: controller.availableCategories.map((cat) {
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
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Color(0xFFF7F8F8)),
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
        )),
        Expanded(
          child: Obx(() => CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              if (!controller.hasMore.value && controller.allExercises.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Đã tải hết bài tập',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
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
        return Center(
          child: Text(
            'Chưa có bài tập yêu thích nào.',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1), fontFamily: 'Poppins'),
          ),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
      padding: EdgeInsets.all(20),
      children: [
        GestureDetector(
          onTap: () {
            _showCreateComboDialog();
          },
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                  child: Icon(Icons.add, color: Colors.white),
                ),
                SizedBox(width: 15),
                Expanded(
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
        SizedBox(height: 25),
        Text(
          'Combo của tôi',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: Text(
            'Bạn chưa tạo combo nào.',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1), fontFamily: 'Poppins'),
          ),
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Combo đề xuất',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Xem thêm',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Obx(() => Column(
          children: controller.combos.map((combo) => _buildComboListItem(combo)).toList(),
        )),
      ],
    );
  }

  Widget _buildComboListItem(ComboItem combo) {
    final comboExercises = controller.getExercisesForCombo(combo);
    double wFactor = _getUserWeight() / 65.0;
    double totalCalories = 0;
    for (var ex in comboExercises) {
      int reps = combo.exerciseReps[ex.id] ?? 10;
      int sets = combo.exerciseSets[ex.id] ?? 3;
      totalCalories += ((ex.calories * reps * sets) / 10.0) * wFactor;
    }
    final totalCaloriesInt = totalCalories.round();
    final totalTime = comboExercises.length * 3;
    final subtitle = '${comboExercises.length} Bài tập | $totalTime Phút | $totalCaloriesInt Calo';

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
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Get.theme.colorScheme.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  combo.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.fitness_center,
                    color: Get.theme.colorScheme.primary,
                    size: 30,
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      combo.title,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72),
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
                  color: combo.isFavorite.value ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Color(0xFFA5A3AF)),
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
                combo.title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),
              Obx(() => ListTile(
                leading: Icon(
                  combo.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: combo.isFavorite.value
                      ? Colors.red
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1)),
                ),
                title: Text(
                  combo.isFavorite.value
                      ? 'Bỏ khỏi yêu thích'
                      : 'Thêm vào yêu thích',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  controller.toggleComboFavorite(combo);
                  Navigator.pop(context);
                },
              )),
              ListTile(
                leading: Icon(Icons.visibility, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1)),
                title: Text(
                  'Xem chi tiết',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
                leading: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                ),
                title: Text(
                  'Đặt lịch tập',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
    return Obx(() {
      if (controller.isLoadingCompletedSchedules.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.completedSchedules.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 15),
              Text(
                'Chưa có lịch sử tập luyện nào',
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
        padding: const EdgeInsets.all(20),
        itemCount: controller.completedSchedules.length,
        itemBuilder: (context, index) {
          final schedule = controller.completedSchedules[index];
          final String name = schedule['exerciseName'] ?? 'Tập luyện';
          
          DateTime date;
          if (schedule['date'] is Timestamp) {
            date = (schedule['date'] as Timestamp).toDate();
          } else if (schedule['date'] is DateTime) {
            date = schedule['date'] as DateTime;
          } else {
            date = DateTime.now();
          }

          String formattedDate = _formatHistoryDate(date, schedule['time'] ?? '');

          int reps = schedule['reps'] ?? 10;
          int sets = schedule['sets'] ?? 3;
          int restTime = schedule['restTime'] ?? 60;
          int durationSecs = (sets * reps * 2) + ((sets - 1) * restTime);
          int durationMins = (durationSecs / 60).ceil();
          if (durationMins < 1) durationMins = 1;
          String duration = '$durationMins phút';

          return GestureDetector(
            onTap: () async {
              final exercise = await controller.getExerciseByName(name);
              if (context.mounted) {
                if (exercise != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseDetailsScreen(
                        exercise: exercise,
                        scheduleId: schedule['id'],
                        isCompleted: true,
                        initialReps: reps,
                        initialSets: sets,
                        initialWeight: (schedule['weight'] is num) ? (schedule['weight'] as num).toDouble() : 0.0,
                        initialRestTime: restTime,
                      ),
                    ),
                  );
                } else {
                  Get.snackbar(
                    'Oops!',
                    'Không tìm thấy dữ liệu chi tiết của bài tập này.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: _buildHistoryItem(context, name, formattedDate, duration),
          );
        },
      );
    });
  }

  String _formatHistoryDate(DateTime date, String time) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    
    String dayStr;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      dayStr = 'Hôm nay';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      dayStr = 'Hôm qua';
    } else {
      dayStr = '${date.day} Tháng ${date.month}';
    }

    if (time.isNotEmpty) {
      return '$dayStr, $time';
    }
    return dayStr;
  }

  Widget _buildHistoryItem(BuildContext context, String name, String time, String duration) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Color(0x111D1617),
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
              color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.check_circle, color: Get.theme.colorScheme.primary),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '$time • $duration',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
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
          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Get.theme.colorScheme.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
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
              SizedBox(height: 8),
              Text(
                exercise.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              Obx(() => Icon(
                exercise.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                color: exercise.isFavorite.value ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Color(0xFFA5A3AF)),
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
                exercise.title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 20),
              Obx(() => ListTile(
                leading: Icon(
                  exercise.isFavorite.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: exercise.isFavorite.value
                      ? Colors.red
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1)),
                ),
                title: Text(
                  exercise.isFavorite.value
                      ? 'Bỏ khỏi yêu thích'
                      : 'Thêm vào yêu thích',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  controller.toggleFavorite(exercise);
                  Navigator.pop(context);
                },
              )),
              ListTile(
                leading: Icon(Icons.visibility, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1)),
                title: Text(
                  'Xem chi tiết',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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
                leading: Icon(Icons.playlist_add, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1)),
                title: Text(
                  'Thêm vào Combo',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToComboDialog(exercise);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                ),
                title: Text(
                  'Đặt lịch tập',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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

  void _showCreateComboDialog({ExerciseItem? initialExercise}) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Tạo Combo Mới',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            ),
          ),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Tên combo',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey,
              ),
            ),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  controller.createNewCombo(
                    titleController.text.trim(),
                    initialExercise != null ? [initialExercise.id] : [],
                  );
                  Navigator.pop(context);
                  Get.snackbar('Thành công', 'Đã tạo combo mới', snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: Text('Tạo', style: TextStyle(color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _showAddToComboDialog(ExerciseItem exercise) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Thêm vào Combo',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() => ListView.builder(
              shrinkWrap: true,
              itemCount: controller.combos.length,
              itemBuilder: (context, index) {
                final combo = controller.combos[index];
                return ListTile(
                  title: Text(
                    combo.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    ),
                  ),
                  subtitle: Text(
                    '${combo.exerciseIds.length} bài tập',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72),
                    ),
                  ),
                  onTap: () {
                    controller.addExerciseToCombo(combo.id, exercise.id);
                    Navigator.pop(context);
                    Get.snackbar('Thành công', 'Đã thêm ${exercise.title} vào ${combo.title}', snackPosition: SnackPosition.BOTTOM);
                  },
                );
              },
            )),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCreateComboDialog(initialExercise: exercise);
              },
              child: Text('Tạo combo mới', style: TextStyle(color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  double _getUserWeight() {
    try {
      final auth = Get.find<AuthController>();
      final authData = auth.userData;
      if (authData.containsKey('weight') && authData['weight'] != null) {
        final wVal = authData['weight'];
        if (wVal is num) {
          return wVal.toDouble();
        } else if (wVal is String) {
          return double.tryParse(wVal) ?? 65.0;
        }
      }
    } catch (_) {}
    return 65.0;
  }
}

