import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/workout/views/exercise_details_screen.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/target/workout/views/add_workout_schedule_screen.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_execution_screen.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final ComboItem? combo;
  final List<ExerciseItem>? exercises;
  final String? scheduleId;
  final bool isCompleted;

  const WorkoutDetailsScreen({super.key, this.combo, this.exercises, this.scheduleId, this.isCompleted = false});

  List<ExerciseItem> _getExercises() {
    if (exercises != null && exercises!.isNotEmpty) return exercises!;
    if (combo != null) {
      try {
        final controller = Get.find<WorkoutController>();
        final comboExercises = controller.getExercisesForCombo(combo!);
        if (comboExercises.isNotEmpty) return comboExercises;
      } catch (e) {
        debugPrint('Error getting combo exercises: $e');
      }
    }
    return [];
  }

  int _getExerciseReps(String exerciseId) {
    if (combo == null) return 10;
    return combo!.exerciseReps[exerciseId] ?? 10;
  }

  int _calculateTotalTime(List<ExerciseItem> exList) {
    if (combo == null) return (exList.length * 3) + 15;
    
    int totalMinutes = 0;
    for (var ex in exList) {
      int reps = _getExerciseReps(ex.id);
      totalMinutes += (reps / 10 * 2).ceil();
    }
    return totalMinutes + 5;
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

  int _calculateTotalCalories(List<ExerciseItem> exList) {
    double w = _getUserWeight() / 65.0;
    if (combo == null) return (exList.fold(0, (sum, item) => sum + item.calories) * w).round();
    
    double total = 0;
    for (var ex in exList) {
      int reps = _getExerciseReps(ex.id);
      int sets = combo!.exerciseSets[ex.id] ?? 3;
      total += ((ex.calories * reps * sets) / 10.0) * w;
    }
    return total.round();
  }

  List<String> _getUniqueEquipments(List<ExerciseItem> exList) {
    Set<String> equipSet = {};
    for (var ex in exList) {
      if (ex.equipments.isNotEmpty) {
        equipSet.addAll(ex.equipments);
      }
    }
    if (equipSet.isEmpty) {
      equipSet.addAll(['Tạ đòn', 'Dây nhảy', 'Chai nước 1L']);
    }
    return equipSet.toList();
  }

  IconData _getEquipmentIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('tạ') || name.contains('dumbbell') || name.contains('barbell') || name.contains('kettlebell')) return Icons.fitness_center;
    if (name.contains('dây') || name.contains('band') || name.contains('rope') || name.contains('cable')) return Icons.all_inclusive;
    if (name.contains('nước') || name.contains('water')) return Icons.local_drink;
    if (name.contains('thảm') || name.contains('mat')) return Icons.crop_landscape;
    if (name.contains('machine') || name.contains('smith') || name.contains('elliptical')) return Icons.settings_applications;
    if (name.contains('ball')) return Icons.sports_basketball;
    if (name.contains('bike')) return Icons.directions_bike;
    if (name.contains('wheel') || name.contains('roller')) return Icons.motion_photos_auto;
    if (name.contains('body weight') || name.contains('body')) return Icons.accessibility_new;
    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Get.theme.colorScheme.primary,
            expandedHeight: chieuCao * 0.35,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              if (combo != null) ...[
                Obx(() => IconButton(
                  icon: Icon(
                    combo!.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                    color: combo!.isFavorite.value ? Colors.red : Colors.white,
                  ),
                  onPressed: () => Get.find<WorkoutController>().toggleComboFavorite(combo!),
                )),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    combo?.image ?? 'assets/workoutfullbody.png',
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.fitness_center,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
              child: Padding(
                padding: EdgeInsets.all(chieuRong * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: chieuRong * 0.13,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFF1D1517).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    Text(
                      combo?.title ?? 'Combo Toàn thân',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 5),
                    Obx(() {
                      final exList = _getExercises();
                      final totalCal = _calculateTotalCalories(exList);
                      final totalTime = _calculateTotalTime(exList);
                      return Text(
                        '${exList.length} Bài tập | $totalTime Phút | $totalCal Calo',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      );
                    }),
                    SizedBox(height: chieuCao * 0.03),
                    if (!isCompleted) ...[
                      _taoTheThongTin(
                        context: context,
                        icon: Icons.calendar_today,
                        tieuDe: 'Lên lịch tập',
                        giaTri: 'Chọn lịch',
                        mauNen: const [Color(0xFF00FF66), Color(0xFF00EFFF)],
                        chieuRong: chieuRong,
                        onTap: () {
                          if (combo != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddWorkoutScheduleScreen(
                                  exerciseName: combo!.title,
                                  exerciseImage: combo!.image,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: chieuCao * 0.015),
                      _taoTheThongTin(
                        context: context,
                        icon: Icons.swap_vert,
                        tieuDe: 'Độ khó (Tất cả bài tập)',
                        giaTri: 'Chỉnh sửa',
                        mauNen: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                        chieuRong: chieuRong,
                        onTap: () {
                          if (combo != null) {
                            _showDifficultyBottomSheet(context);
                          } else {
                            Get.snackbar('Thông báo', 'Chỉ áp dụng cho Combo');
                          }
                        },
                      ),
                      SizedBox(height: chieuCao * 0.03),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dụng cụ cần thiết',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Obx(() {
                          final equips = _getUniqueEquipments(_getExercises());
                          return Text(
                            '${equips.length} Món',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: chieuCao * 0.015),

                    SizedBox(
                      height: chieuCao * 0.16,
                      child: Obx(() {
                        final equips = _getUniqueEquipments(_getExercises());
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          itemCount: equips.length,
                          itemBuilder: (context, index) {
                            final equip = equips[index];
                            return _taoDungCu(context, _getEquipmentIcon(equip), equip, chieuRong);
                          },
                        );
                      }),
                    ),
                    SizedBox(height: chieuCao * 0.03),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bài tập trong Combo',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        if (combo != null && !isCompleted)
                          GestureDetector(
                            onTap: () {
                              _showAddExerciseDialog(context);
                            },
                            child: Text('Thêm bài tập', style: TextStyle(color: Get.theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                      ],
                    ),
                    SizedBox(height: chieuCao * 0.02),

                    Obx(() {
                      final exList = _getExercises();
                      return Column(
                        children: exList.map((ex) {
                          return _taoItemBaiTap(
                            context,
                            ex,
                            '${_getExerciseReps(ex.id)}x', 
                            chieuRong,
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isCompleted
          ? Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.08, vertical: chieuCao * 0.02),
                  child: Container(
                    height: chieuCao * 0.075,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Đã hoàn thành',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: chieuRong * 0.08,
                    right: chieuRong * 0.08,
                    bottom: chieuCao * 0.02,
                    top: chieuCao * 0.01,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final exList = _getExercises();
                      if (exList.isEmpty) {
                        Get.snackbar('Thông báo', 'Combo này chưa có bài tập nào!');
                        return;
                      }

                      final execItems = exList.map((ex) {
                        int reps = combo?.exerciseReps[ex.id] ?? 10;
                        int sets = combo?.exerciseSets[ex.id] ?? 3;
                        double weight = combo?.exerciseWeights[ex.id] ?? 0.0;
                        int restTime = combo?.exerciseRestTimes[ex.id] ?? 60;

                        return WorkoutExecutionItem(
                          exercise: ex,
                          sets: sets,
                          reps: reps,
                          weight: weight,
                          restTime: restTime,
                        );
                      }).toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutExecutionScreen(
                            items: execItems,
                            title: combo?.title ?? 'Tập luyện Combo',
                            scheduleId: scheduleId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: chieuCao * 0.075,
                      width: double.infinity,
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
                          'Bắt đầu tập',
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
              ),
            ),
    );
  }

  Widget _taoTheThongTin({
    required BuildContext context,
    required IconData icon,
    required String tieuDe,
    required String giaTri,
    required List<Color> mauNen,
    required double chieuRong,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(chieuRong * 0.04),
        decoration: BoxDecoration(
          color: mauNen[0].withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
      child: Row(
        children: [
          Icon(icon, color: mauNen[0], size: 20),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              tieuDe,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            giaTri,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
              fontSize: 10,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 10),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
            size: 14,
          ),
        ],
      ),
      ),
    );
  }

  Widget _taoDungCu(BuildContext context, IconData icon, String ten, double chieuRong) {
    return Padding(
      padding: EdgeInsets.only(right: chieuRong * 0.04),
      child: Column(
        children: [
          Container(
            width: chieuRong * 0.21,
            height: chieuRong * 0.21,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4C95ADFE),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: chieuRong * 0.21,
            child: Text(
              ten,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoItemBaiTap(
    BuildContext context,
    ExerciseItem exercise,
    String thoiGian,
    double chieuRong,
  ) {
    final controller = Get.find<WorkoutController>();
    return Padding(
      padding: EdgeInsets.only(bottom: chieuRong * 0.04),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailsScreen(
                exercise: exercise,
                comboId: combo?.id,
                initialReps: combo?.exerciseReps[exercise.id] ?? 10,
                initialSets: combo?.exerciseSets[exercise.id] ?? 3,
                initialWeight: combo?.exerciseWeights[exercise.id] ?? 0.0,
                initialRestTime: combo?.exerciseRestTimes[exercise.id] ?? 60,
                isCompleted: isCompleted,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: chieuRong * 0.16,
              height: chieuRong * 0.16,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Get.theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedImageWidget(
                  id: exercise.id,
                  type: 'exercises',
                  url: exercise.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    thoiGian,
                    style: TextStyle(
                      color: Get.theme.colorScheme.primary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (combo != null && !isCompleted)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Xóa bài tập',
                    middleText: 'Bạn có chắc chắn muốn xóa bài tập này khỏi combo không?',
                    textCancel: 'Hủy',
                    textConfirm: 'Xóa',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      controller.removeExerciseFromCombo(combo!.id, exercise.id);
                      Get.back();
                    },
                  );
                },
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Color(0xFFB6B4C1)),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final controller = Get.find<WorkoutController>();
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredList = controller.allExercises.where((ex) {
              return ex.title.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thêm bài tập', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                        IconButton(
                          icon: Icon(Icons.close, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm bài tập...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
                          hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Color(0xFFA5A3AF), fontSize: 14),
                        ),
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517), fontSize: 14),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final ex = filteredList[index];
                          return GestureDetector(
                            onTap: () {
                              controller.addExerciseToCombo(combo!.id, ex.id);
                              Navigator.pop(context);
                              Get.snackbar('Thành công', 'Đã thêm ${ex.title} vào ${combo!.title}', snackPosition: SnackPosition.BOTTOM);
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
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedImageWidget(
                                          id: ex.id,
                                          type: 'exercises',
                                          url: ex.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      ex.title,
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _showDifficultyBottomSheet(BuildContext context) {
    final List<String> options = ['Người mới', 'Trung bình', 'Nâng cao'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFF1D1517).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Chỉnh độ khó cho Combo',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tất cả các bài tập trong combo sẽ được cập nhật độ khó đồng bộ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFF7B6F72),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              ...options.map((opt) => ListTile(
                    leading: const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      final controller = Get.find<WorkoutController>();
                      final exList = _getExercises();

                      for (var ex in exList) {
                        bool isCardio = ex.category.toLowerCase() == 'cardio' ||
                            ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio');
                        int sets = 3;
                        int reps = isCardio ? 30 : 10;
                        int restTime = 60;

                        if (opt == 'Trung bình') {
                          sets = 4;
                          reps = isCardio ? 45 : 12;
                          restTime = 45;
                        } else if (opt == 'Nâng cao') {
                          sets = 5;
                          reps = isCardio ? 60 : 15;
                          restTime = 30;
                        }

                        double weight = combo?.exerciseWeights[ex.id] ?? 0.0;
                        controller.updateExerciseDetails(combo!.id, ex.id, reps, sets, weight, restTime);
                      }
                      Navigator.pop(context);
                      Get.snackbar(
                        'Thành công',
                        'Đã cập nhật tất cả bài tập về mức $opt',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
