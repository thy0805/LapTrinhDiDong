import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:nutrifit/core/services/media_service.dart';
import 'package:nutrifit/modules/main/target/workout/views/add_workout_schedule_screen.dart';
import 'package:nutrifit/modules/main/target/workout/views/workout_execution_screen.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseItem exercise;
  final String? comboId;
  final int initialReps;
  final int initialSets;
  final double initialWeight;
  final int initialRestTime;

  final String? scheduleId;
  final bool isCompleted;

  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
    this.comboId,
    this.initialReps = 10,
    this.initialSets = 3,
    this.initialWeight = 0.0,
    this.initialRestTime = 60,
    this.scheduleId,
    this.isCompleted = false,
  });

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  late int _selectedReps;
  late int _selectedSets;
  late double _selectedWeight;
  late int _selectedRestTime;
  late String _selectedDifficulty;

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

  bool _isCardio() {
    return widget.exercise.category.toLowerCase() == 'cardio' ||
        widget.exercise.bodyParts.any((bp) => bp.toLowerCase() == 'cardio');
  }

  bool _isBodyweight() {
    return widget.exercise.equipments.any((eq) => eq.toLowerCase() == 'body weight');
  }

  bool _isStrength() {
    return !_isCardio() && !_isBodyweight();
  }

  bool _isWeighted() {
    final weightedEquip = [
      'dumbbell',
      'barbell',
      'olympic barbell',
      'ez barbell',
      'kettlebell',
      'weighted',
      'smith machine',
      'leverage machine',
      'sled machine',
      'cable',
      'trap bar'
    ];
    return widget.exercise.equipments.any((eq) => weightedEquip.contains(eq.toLowerCase()));
  }

  @override
  void initState() {
    super.initState();
    _selectedReps = widget.initialReps;
    _selectedSets = widget.initialSets;
    _selectedWeight = widget.initialWeight;
    _selectedRestTime = widget.initialRestTime;
    _selectedDifficulty = widget.exercise.difficulty.isNotEmpty
        ? widget.exercise.difficulty
        : 'Người mới';

    if (!_isStrength()) {
      _selectedWeight = 0.0;
    }

    int maxReps = _isCardio() ? 600 : (_isWeighted() ? 20 : 50);
    if (_selectedReps > maxReps) {
      _selectedReps = maxReps;
    }
  }

  Widget _buildExerciseImage(double chieuCao) {
    final mediaService = Get.find<MediaService>();
    final imageUrl = widget.exercise.image;
    
    if (imageUrl.startsWith('http')) {
      final localPath = mediaService.getLocalPath(widget.exercise.id, 'exercises', imageUrl);
      if (mediaService.isFileExists(localPath)) {
        return Image.file(
          File(localPath),
          height: chieuCao * 0.2,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
      return Image.network(
        imageUrl,
        height: chieuCao * 0.2,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    
    return Image.asset(
      imageUrl.isNotEmpty ? imageUrl : 'assets/fullbody.png',
      height: chieuCao * 0.2,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.fitness_center,
      color: Colors.white,
      size: 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              widget.exercise.isFavorite.value ? Icons.favorite : Icons.favorite_border,
              color: widget.exercise.isFavorite.value ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
            ),
            onPressed: () => Get.find<WorkoutController>().toggleFavorite(widget.exercise),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: chieuRong * 0.08,
          vertical: chieuCao * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: chieuCao * 0.25,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: Container(
                      width: chieuRong * 0.4,
                      height: chieuRong * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.3,
                    child: Container(
                      width: chieuRong * 0.3,
                      height: chieuRong * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  _buildExerciseImage(chieuCao),
                ],
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            Text(
              widget.exercise.title,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 5),
            Text(
              '$_selectedDifficulty | Đốt cháy ${((_selectedReps * _selectedSets * widget.exercise.calories * _getUserWeight() / 65.0) / 10.0).round()} Calo',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            if (!widget.isCompleted) ...[
              SizedBox(height: chieuCao * 0.02),
              _taoTheThongTin(
                context: context,
                icon: Icons.calendar_today,
                tieuDe: 'Lên lịch tập',
                giaTri: 'Chọn lịch',
                mauNen: const [Color(0xFF00FF66), Color(0xFF00EFFF)],
                chieuRong: chieuRong,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWorkoutScheduleScreen(
                        exerciseName: widget.exercise.title,
                        exerciseImage: widget.exercise.image,
                        initialReps: _selectedReps,
                        initialSets: _selectedSets,
                        initialWeight: _selectedWeight,
                        initialRestTime: _selectedRestTime,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: chieuCao * 0.015),
              _taoTheThongTin(
                context: context,
                icon: Icons.swap_vert,
                tieuDe: 'Độ khó',
                giaTri: _selectedDifficulty,
                mauNen: [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary],
                chieuRong: chieuRong,
                onTap: () => _showDifficultyBottomSheet(context),
              ),
              SizedBox(height: chieuCao * 0.015),
              _taoTheThongTin(
                context: context,
                icon: Icons.playlist_add,
                tieuDe: 'Thêm vào Combo',
                giaTri: 'Chọn',
                mauNen: const [Color(0xFFFF9900), Color(0xFFFF5E00)],
                chieuRong: chieuRong,
                onTap: () => _showAddToComboDialog(widget.exercise),
              ),
              SizedBox(height: chieuCao * 0.03),
            ] else
              SizedBox(height: 10),
            if (widget.exercise.equipments.isNotEmpty) ...[
              Text(
                'Dụng cụ cần thiết',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: chieuCao * 0.015),
              SizedBox(
                height: chieuCao * 0.16,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemCount: widget.exercise.equipments.length,
                  itemBuilder: (context, index) {
                    final equipName = widget.exercise.equipments[index];
                    return _taoDungCu(
                      context,
                      _getEquipmentIcon(equipName),
                      equipName,
                      chieuRong,
                    );
                  },
                ),
              ),
              SizedBox(height: chieuCao * 0.02),
            ],
            if (widget.exercise.targetMuscles.isNotEmpty)
              Text(
                'Cơ mục tiêu: ${widget.exercise.targetMuscles.join(', ')}',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            if (widget.exercise.secondaryMuscles.isNotEmpty)
              Text(
                'Cơ phụ: ${widget.exercise.secondaryMuscles.join(', ')}',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            SizedBox(height: chieuCao * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cách thực hiện',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${widget.exercise.instructions.length} Bước',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: chieuCao * 0.02),
            if (widget.exercise.instructions.isNotEmpty)
              ...List.generate(widget.exercise.instructions.length, (index) {
                return _taoBuocThucHien(
                  (index + 1).toString().padLeft(2, '0'),
                  'Bước ${index + 1}',
                  widget.exercise.instructions[index],
                  isLast: index == widget.exercise.instructions.length - 1,
                );
              })
            else
              Text(
                'Chưa có hướng dẫn cho bài tập này.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                  fontFamily: 'Poppins',
                ),
              ),
            if (!widget.isCompleted) ...[
              Text(
                'Tùy chỉnh hiệp & mức tạ',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: chieuCao * 0.01),
              _buildRowSelector(
                label: 'Số set tập',
                value: '$_selectedSets set',
                icon: Icons.repeat,
                onDecrement: () {
                  if (_selectedSets > 1) {
                    setState(() {
                      _selectedSets--;
                    });
                  }
                },
                onIncrement: () {
                  if (_selectedSets < 20) {
                    setState(() {
                      _selectedSets++;
                    });
                  }
                },
              ),
              if (_isStrength())
                _buildRowSelector(
                  label: 'Khối lượng tạ',
                  value: '${_selectedWeight.toStringAsFixed(1)} kg',
                  icon: Icons.fitness_center,
                  onDecrement: () {
                    if (_selectedWeight >= 2.5) {
                      setState(() {
                        _selectedWeight -= 2.5;
                      });
                    } else if (_selectedWeight > 0) {
                      setState(() {
                        _selectedWeight = 0.0;
                      });
                    }
                  },
                  onIncrement: () {
                    if (_selectedWeight < 300) {
                      setState(() {
                        _selectedWeight += 2.5;
                      });
                    }
                  },
                ),
              _buildRowSelector(
                label: 'Thời gian nghỉ',
                value: '$_selectedRestTime giây',
                icon: Icons.timer_outlined,
                onDecrement: () {
                  if (_selectedRestTime > 15) {
                    setState(() {
                      _selectedRestTime -= 15;
                    });
                  }
                },
                onIncrement: () {
                  if (_selectedRestTime < 600) {
                    setState(() {
                      _selectedRestTime += 15;
                    });
                  }
                },
              ),
              SizedBox(height: chieuCao * 0.02),
              SizedBox(height: chieuCao * 0.03),
              Text(
                _isCardio() ? 'Tùy chỉnh thời gian tập' : 'Tùy chỉnh số lần tập',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: chieuCao * 0.02),
              SizedBox(
                height: chieuCao * 0.25,
                child: CupertinoPicker(
                  itemExtent: 65,
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedReps - 1,
                  ),
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Color(0xFFC6C4D3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedReps = index + 1;
                    });
                  },
                  children: List<Widget>.generate(_isCardio() ? 600 : (_isWeighted() ? 20 : 50), (int index) {
                    int giaTri = index + 1;
                    int calo = ((widget.exercise.calories * giaTri * _selectedSets * _getUserWeight() / 65.0) / 10.0).round();
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.deepOrange,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '$calo Calo',
                            style: TextStyle(
                              color: Color(0xFFA5A3AF),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 20),
                          Text(
                            '$giaTri',
                            style: TextStyle(
                              color: _selectedReps == giaTri
                                  ? Get.theme.colorScheme.primary
                                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _isCardio() ? 'giây' : 'lần',
                            style: TextStyle(
                              color: Color(0xFFA5A3AF),
                              fontSize: 18,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: chieuCao * 0.05),
            ],
          ],
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
              top: chieuCao * 0.01,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            if (widget.isCompleted)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
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
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  if (widget.comboId != null)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.find<WorkoutController>().updateExerciseDetails(
                                widget.comboId!,
                                widget.exercise.id,
                                _selectedReps,
                                _selectedSets,
                                _selectedWeight,
                                _selectedRestTime,
                              );
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: chieuCao * 0.065,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Color(0xFF1E293B)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Center(
                                child: Text(
                                  'Lưu',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
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
                              final execItem = WorkoutExecutionItem(
                                exercise: widget.exercise,
                                sets: _selectedSets,
                                reps: _selectedReps,
                                weight: _selectedWeight,
                                restTime: _selectedRestTime,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutExecutionScreen(
                                    items: [execItem],
                                    title: widget.exercise.title,
                                    scheduleId: widget.scheduleId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: chieuCao * 0.065,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                                ),
                                borderRadius: BorderRadius.circular(99),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x4C95ADFE),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
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
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        final execItem = WorkoutExecutionItem(
                          exercise: widget.exercise,
                          sets: _selectedSets,
                          reps: _selectedReps,
                          weight: _selectedWeight,
                          restTime: _selectedRestTime,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutExecutionScreen(
                              items: [execItem],
                              title: widget.exercise.title,
                              scheduleId: widget.scheduleId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: chieuCao * 0.065,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                          ),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4C95ADFE),
                              blurRadius: 10,
                              offset: Offset(0, 5),
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
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _showAddToComboDialog(ExerciseItem exercise) {
    final controller = Get.find<WorkoutController>();
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
                    controller.addExerciseToCombo(
                      combo.id,
                      exercise.id,
                      reps: _selectedReps,
                      sets: _selectedSets,
                      weight: _selectedWeight,
                      restTime: _selectedRestTime,
                    );
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
                _showCreateComboDialog(exercise);
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

  void _showCreateComboDialog(ExerciseItem exercise) {
    final controller = Get.find<WorkoutController>();
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
                    [exercise.id],
                    reps: _selectedReps,
                    sets: _selectedSets,
                    weight: _selectedWeight,
                    restTime: _selectedRestTime,
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

  Widget _taoBuocThucHien(
    String soThuTu,
    String tieuDe,
    String moTa, {
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Get.theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  soThuTu,
                  style: TextStyle(
                    color: Get.theme.colorScheme.primary,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            if (!isLast)
              SizedBox(
                width: 1,
                height: 40,
                child: CustomPaint(
                  painter: _VeDuongVienDoc(color: Get.theme.colorScheme.primary),
                ),
              ),
          ],
        ),
        SizedBox(width: 15),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieuDe,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  moTa,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFB6B4C1),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getEquipmentIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('tạ') ||
        name.contains('dumbbell') ||
        name.contains('barbell') ||
        name.contains('kettlebell')) {
      return Icons.fitness_center;
    }
    if (name.contains('dây') ||
        name.contains('band') ||
        name.contains('rope') ||
        name.contains('cable')) {
      return Icons.all_inclusive;
    }
    if (name.contains('nước') || name.contains('water')) {
      return Icons.local_drink;
    }
    if (name.contains('thảm') || name.contains('mat')) {
      return Icons.crop_landscape;
    }
    if (name.contains('machine') ||
        name.contains('smith') ||
        name.contains('elliptical')) {
      return Icons.settings_applications;
    }
    if (name.contains('ball')) {
      return Icons.sports_basketball;
    }
    if (name.contains('bike')) {
      return Icons.directions_bike;
    }
    if (name.contains('wheel') || name.contains('roller')) {
      return Icons.motion_photos_auto;
    }
    if (name.contains('body weight') || name.contains('body')) {
      return Icons.accessibility_new;
    }
    return Icons.fitness_center;
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

  Widget _buildRowSelector({
    required String label,
    required String value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Get.theme.colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1D1517),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: isDark ? Colors.grey : Colors.grey.shade600),
                onPressed: onDecrement,
              ),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D1517),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Get.theme.colorScheme.primary),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
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
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                tieuDe,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade300
                      : const Color(0xFFB6B4C1),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Text(
              giaTri,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : const Color(0xFFB6B4C1),
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : const Color(0xFFB6B4C1),
              size: 14,
            ),
          ],
        ),
      ),
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
                'Chỉnh độ khó cho bài tập',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Số set, số lần/giây và thời gian nghỉ sẽ được tự động cập nhật.',
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
                      setState(() {
                        _selectedDifficulty = opt;
                        bool isCardio = _isCardio();
                        if (opt == 'Người mới') {
                          _selectedSets = 3;
                          _selectedReps = isCardio ? 30 : 10;
                          _selectedRestTime = 60;
                        } else if (opt == 'Trung bình') {
                          _selectedSets = 4;
                          _selectedReps = isCardio ? 45 : 12;
                          _selectedRestTime = 45;
                        } else {
                          _selectedSets = 5;
                          _selectedReps = isCardio ? 60 : 15;
                          _selectedRestTime = 30;
                        }
                      });
                      Navigator.pop(context);
                      Get.snackbar(
                        'Thành công',
                        'Đã cập nhật bài tập về mức $opt',
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

class _VeDuongVienDoc extends CustomPainter {
  final Color color;

  const _VeDuongVienDoc({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var max = size.height;
    if (max.isInfinite) return; 
    var dashHeight = 4.0;
    var dashSpace = 4.0;
    double startY = 0;

    while (startY < max) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
