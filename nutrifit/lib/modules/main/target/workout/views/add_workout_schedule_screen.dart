import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class AddWorkoutScheduleScreen extends StatefulWidget {
  final String? exerciseName;
  final String? exerciseImage;
  final String? scheduleId;
  final String? initialTime;
  final DateTime? initialDate;
  final List<bool>? initialRepeatDays;
  final int initialReps;
  final int initialSets;
  final double initialWeight;
  final int initialRestTime;

  const AddWorkoutScheduleScreen({
    super.key,
    this.exerciseName,
    this.exerciseImage,
    this.scheduleId,
    this.initialTime,
    this.initialDate,
    this.initialRepeatDays,
    this.initialReps = 15,
    this.initialSets = 3,
    this.initialWeight = 0.0,
    this.initialRestTime = 60,
  });

  @override
  State<AddWorkoutScheduleScreen> createState() => _AddWorkoutScheduleScreenState();
}

class _AddWorkoutScheduleScreenState extends State<AddWorkoutScheduleScreen> {
  late int _gioDuocChon;
  late int _phutDuocChon;
  final List<String> _ngayLapLai = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  late List<bool> _ngayDuocChonTrongTuan;
  late DateTime _ngayDuocChon;

  String? _selectedName;
  String? _selectedImage;
  ComboItem? _comboSelected;

  int _reps = 15;
  int _sets = 3;
  double _weight = 0.0;
  int _restTime = 60;
  String _difficulty = 'Người mới';

  @override
  void initState() {
    super.initState();
    _ngayDuocChon = widget.initialDate ?? DateTime.now();
    _ngayDuocChonTrongTuan = widget.initialRepeatDays ?? [false, false, false, false, false, false, false];
    
    if (widget.initialTime != null) {
      final parts = widget.initialTime!.split(':');
      _gioDuocChon = int.parse(parts[0]);
      _phutDuocChon = int.parse(parts[1]);
    } else {
      _gioDuocChon = DateTime.now().hour;
      _phutDuocChon = DateTime.now().minute;
    }

    _selectedName = widget.exerciseName;
    _selectedImage = widget.exerciseImage;
    _reps = widget.initialReps;
    _sets = widget.initialSets;
    _weight = widget.initialWeight;
    _restTime = widget.initialRestTime;

    final controller = Get.find<WorkoutController>();
    if (_selectedName != null) {
      final combo = controller.combos.firstWhereOrNull((c) => c.title == _selectedName);
      if (combo != null) {
        _comboSelected = combo;
      } else {
        final exercise = controller.allExercises.firstWhereOrNull((e) => e.title == _selectedName);
        if (exercise != null) {
          _difficulty = exercise.difficulty;
        }
      }
    }
    _updateEstimatedCalories();
  }

  double _estimatedCalories = 0.0;

  void _updateEstimatedCalories() async {
    if (_selectedName == null || _selectedName!.isEmpty) {
      setState(() {
        _estimatedCalories = 0.0;
      });
      return;
    }
    final controller = Get.find<WorkoutController>();
    double calo = 0.0;
    if (_comboSelected != null) {
      calo = await controller.calculateCaloriesForExercise(_selectedName!);
    } else {
      calo = await controller.calculateCaloriesForExercise(
        _selectedName!,
        scheduleReps: _reps,
        scheduleSets: _sets,
        scheduleWeight: _weight,
        scheduleRestTime: _restTime,
      );
    }
    if (mounted) {
      setState(() {
        _estimatedCalories = calo;
      });
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: Get.theme.colorScheme.primary,
                    onPrimary: Colors.black,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Get.theme.colorScheme.primary,
                    onPrimary: Colors.white,
                    onSurface: const Color(0xFF1D1517),
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

  void _showExerciseSelectionSheet() {
    final controller = Get.find<WorkoutController>();
    String tempSearch = '';
    String tempCategory = 'Tất cả';
    int activeTab = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textCol = isDark ? Colors.white : const Color(0xFF1D1517);
            final descCol = isDark ? Colors.grey.shade400 : const Color(0xFFB6B4C1);
            final bgCol = isDark ? const Color(0xFF1E293B) : const Color(0xFFF7F8F8);

            final filteredEx = controller.allExercises.where((ex) {
              final matchSearch = ex.title.toLowerCase().contains(tempSearch.toLowerCase());
              final matchCat = tempCategory == 'Tất cả' || ex.category == tempCategory;
              return matchSearch && matchCat;
            }).toList();

            final filteredCb = controller.combos.where((cb) {
              return cb.title.toLowerCase().contains(tempSearch.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF1D1517).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Chọn bài tập / Combo',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: bgCol,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm bài tập...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: descCol),
                        hintStyle: TextStyle(color: descCol, fontSize: 14),
                      ),
                      style: TextStyle(color: textCol, fontSize: 14),
                      onChanged: (val) {
                        setSheetState(() {
                          tempSearch = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => activeTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: activeTab == 0 ? Get.theme.colorScheme.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Bài tập',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: activeTab == 0 ? FontWeight.bold : FontWeight.normal,
                                  color: activeTab == 0 ? Get.theme.colorScheme.primary : descCol,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => activeTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: activeTab == 1 ? Get.theme.colorScheme.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Combo',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: activeTab == 1 ? FontWeight.bold : FontWeight.normal,
                                  color: activeTab == 1 ? Get.theme.colorScheme.primary : descCol,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (activeTab == 0) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.availableCategories.map((cat) {
                          final isSel = tempCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                tempCategory = cat;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Get.theme.colorScheme.primary : bgCol,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSel ? Colors.white : descCol,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  Expanded(
                    child: activeTab == 0
                        ? ListView.builder(
                            itemCount: filteredEx.length,
                            itemBuilder: (context, idx) {
                              final ex = filteredEx[idx];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    ex.image,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.fitness_center, color: Get.theme.colorScheme.primary),
                                  ),
                                ),
                                title: Text(ex.title, style: TextStyle(color: textCol, fontFamily: 'Poppins', fontSize: 14)),
                                subtitle: Text(ex.difficulty, style: TextStyle(color: descCol, fontFamily: 'Poppins', fontSize: 12)),
                                onTap: () {
                                  setState(() {
                                    _selectedName = ex.title;
                                    _selectedImage = ex.image;
                                    _comboSelected = null;
                                    _difficulty = ex.difficulty;
                                  });
                                  _updateEstimatedCalories();
                                  Navigator.pop(context);
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: filteredCb.length,
                            itemBuilder: (context, idx) {
                              final cb = filteredCb[idx];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    cb.image,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.fitness_center, color: Get.theme.colorScheme.primary),
                                  ),
                                ),
                                title: Text(cb.title, style: TextStyle(color: textCol, fontFamily: 'Poppins', fontSize: 14)),
                                subtitle: Text('${cb.exerciseIds.length} bài tập', style: TextStyle(color: descCol, fontFamily: 'Poppins', fontSize: 12)),
                                onTap: () {
                                  setState(() {
                                    _selectedName = cb.title;
                                    _selectedImage = cb.image;
                                    _comboSelected = cb;
                                  });
                                  _updateEstimatedCalories();
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDifficultyDialog({bool isGeneralCombo = false, String? exerciseId}) {
    showDialog(
      context: context,
      builder: (context) {
        final options = ['Người mới', 'Trung bình', 'Nâng cao'];
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Chọn độ khó',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              return ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  final controller = Get.find<WorkoutController>();
                  setState(() {
                    if (isGeneralCombo && _comboSelected != null) {
                      for (var exId in _comboSelected!.exerciseIds) {
                        final ex = controller.allExercises.firstWhereOrNull((e) => e.id == exId);
                        bool isCardio = ex != null &&
                            (ex.category.toLowerCase() == 'cardio' ||
                                ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'));
                        
                        if (opt == 'Người mới') {
                          _comboSelected!.exerciseSets[exId] = 3;
                          _comboSelected!.exerciseReps[exId] = isCardio ? 30 : 10;
                          _comboSelected!.exerciseRestTimes[exId] = 60;
                        } else if (opt == 'Trung bình') {
                          _comboSelected!.exerciseSets[exId] = 4;
                          _comboSelected!.exerciseReps[exId] = isCardio ? 45 : 12;
                          _comboSelected!.exerciseRestTimes[exId] = 45;
                        } else {
                          _comboSelected!.exerciseSets[exId] = 5;
                          _comboSelected!.exerciseReps[exId] = isCardio ? 60 : 15;
                          _comboSelected!.exerciseRestTimes[exId] = 30;
                        }
                      }
                      _difficulty = opt;
                    } else if (exerciseId != null && _comboSelected != null) {
                      final ex = controller.allExercises.firstWhereOrNull((e) => e.id == exerciseId);
                      bool isCardio = ex != null &&
                          (ex.category.toLowerCase() == 'cardio' ||
                              ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'));

                      if (opt == 'Người mới') {
                        _comboSelected!.exerciseSets[exerciseId] = 3;
                        _comboSelected!.exerciseReps[exerciseId] = isCardio ? 30 : 10;
                        _comboSelected!.exerciseRestTimes[exerciseId] = 60;
                      } else if (opt == 'Trung bình') {
                        _comboSelected!.exerciseSets[exerciseId] = 4;
                        _comboSelected!.exerciseReps[exerciseId] = isCardio ? 45 : 12;
                        _comboSelected!.exerciseRestTimes[exerciseId] = 45;
                      } else {
                        _comboSelected!.exerciseSets[exerciseId] = 5;
                        _comboSelected!.exerciseReps[exerciseId] = isCardio ? 60 : 15;
                        _comboSelected!.exerciseRestTimes[exerciseId] = 30;
                      }
                    } else {
                      _difficulty = opt;
                      bool isCardio = false;
                      if (_selectedName != null) {
                        final ex = controller.allExercises.firstWhereOrNull((e) => e.title == _selectedName);
                        if (ex != null &&
                            (ex.category.toLowerCase() == 'cardio' ||
                                ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'))) {
                          isCardio = true;
                        }
                      }

                      if (opt == 'Người mới') {
                        _sets = 3;
                        _reps = isCardio ? 30 : 10;
                        _restTime = 60;
                      } else if (opt == 'Trung bình') {
                        _sets = 4;
                        _reps = isCardio ? 45 : 12;
                        _restTime = 45;
                      } else {
                        _sets = 5;
                        _reps = isCardio ? 60 : 15;
                        _restTime = 30;
                      }
                    }
                  });
                  _updateEstimatedCalories();
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showRepsDialog({String? exerciseId}) {
    final controller = Get.find<WorkoutController>();
    bool isCardio = false;
    if (exerciseId != null) {
      final ex = controller.allExercises.firstWhereOrNull((e) => e.id == exerciseId);
      if (ex != null && (ex.category.toLowerCase() == 'cardio' || ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'))) {
        isCardio = true;
      }
    } else if (_selectedName != null) {
      final ex = controller.allExercises.firstWhereOrNull((e) => e.title == _selectedName);
      if (ex != null && (ex.category.toLowerCase() == 'cardio' || ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'))) {
        isCardio = true;
      }
    }

    final textController = TextEditingController(
      text: exerciseId != null && _comboSelected != null
          ? (_comboSelected!.exerciseReps[exerciseId] ?? 10).toString()
          : _reps.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            isCardio ? 'Nhập thời gian tập (giây)' : 'Nhập số lần tập',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: isCardio ? 'Nhập số giây (ví dụ: 30)' : 'Nhập số (ví dụ: 12)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(textController.text) ?? 10;
                setState(() {
                  if (exerciseId != null && _comboSelected != null) {
                    _comboSelected!.exerciseReps[exerciseId] = val;
                  } else {
                    _reps = val;
                  }
                });
                _updateEstimatedCalories();
                Navigator.pop(context);
              },
              child: Text('Lưu', style: TextStyle(color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _showWeightDialog({String? exerciseId}) {
    final textController = TextEditingController(
      text: exerciseId != null && _comboSelected != null
          ? (_comboSelected!.exerciseWeights[exerciseId] ?? 0.0).toString()
          : _weight.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Nhập mức tạ (kg)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: 'Nhập cân nặng (ví dụ: 5.5)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(textController.text) ?? 0.0;
                setState(() {
                  if (exerciseId != null && _comboSelected != null) {
                    _comboSelected!.exerciseWeights[exerciseId] = val;
                  } else {
                    _weight = val;
                  }
                });
                _updateEstimatedCalories();
                Navigator.pop(context);
              },
              child: Text('Lưu', style: TextStyle(color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _showRestTimeDialog({String? exerciseId}) {
    final textController = TextEditingController(
      text: exerciseId != null && _comboSelected != null
          ? (_comboSelected!.exerciseRestTimes[exerciseId] ?? 60).toString()
          : _restTime.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Nhập thời gian nghỉ (giây)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: 'Nhập số giây (ví dụ: 60)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(textController.text) ?? 60;
                setState(() {
                  if (exerciseId != null && _comboSelected != null) {
                    _comboSelected!.exerciseRestTimes[exerciseId] = val;
                  } else {
                    _restTime = val;
                  }
                });
                _updateEstimatedCalories();
                Navigator.pop(context);
              },
              child: Text('Lưu', style: TextStyle(color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _showSetsDialog() {
    final textController = TextEditingController(text: _sets.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Nhập số hiệp tập (Sets)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: 'Nhập số (ví dụ: 3)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(textController.text) ?? 3;
                setState(() {
                  _sets = val;
                });
                _updateEstimatedCalories();
                Navigator.pop(context);
              },
              child: Text('Lưu', style: TextStyle(color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _showSetsComboDialog(String exerciseId) {
    final textController = TextEditingController(
      text: (_comboSelected!.exerciseSets[exerciseId] ?? 3).toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Nhập số hiệp (Sets)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
            decoration: const InputDecoration(hintText: 'Nhập số hiệp (ví dụ: 3)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(textController.text) ?? 3;
                setState(() {
                  _comboSelected!.exerciseSets[exerciseId] = val;
                });
                _updateEstimatedCalories();
                Navigator.pop(context);
              },
              child: Text('Lưu', style: TextStyle(color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _showSwapExerciseDialog(String oldExerciseId) {
    final controller = Get.find<WorkoutController>();
    String tempSearch = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textCol = isDark ? Colors.white : const Color(0xFF1D1517);
            final descCol = isDark ? Colors.grey.shade400 : const Color(0xFFB6B4C1);

            final list = controller.allExercises.where((ex) {
              return ex.title.toLowerCase().contains(tempSearch.toLowerCase());
            }).toList();

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Chọn bài tập thay thế',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm bài tập...',
                        hintStyle: TextStyle(color: descCol),
                        prefixIcon: Icon(Icons.search, color: descCol),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          tempSearch = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, idx) {
                          final ex = list[idx];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                ex.image,
                                width: 35,
                                height: 35,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.fitness_center, color: Get.theme.colorScheme.primary),
                              ),
                            ),
                            title: Text(ex.title, style: TextStyle(color: textCol, fontFamily: 'Poppins', fontSize: 13)),
                            onTap: () {
                              setState(() {
                                if (_comboSelected != null) {
                                  int idxOfOld = _comboSelected!.exerciseIds.indexOf(oldExerciseId);
                                  if (idxOfOld != -1) {
                                    _comboSelected!.exerciseIds[idxOfOld] = ex.id;
                                    _comboSelected!.exerciseReps[ex.id] = _comboSelected!.exerciseReps[oldExerciseId] ?? 10;
                                    _comboSelected!.exerciseSets[ex.id] = _comboSelected!.exerciseSets[oldExerciseId] ?? 3;
                                    _comboSelected!.exerciseWeights[ex.id] = _comboSelected!.exerciseWeights[oldExerciseId] ?? 0.0;
                                    _comboSelected!.exerciseRestTimes[ex.id] = _comboSelected!.exerciseRestTimes[oldExerciseId] ?? 60;

                                    _comboSelected!.exerciseReps.remove(oldExerciseId);
                                    _comboSelected!.exerciseSets.remove(oldExerciseId);
                                    _comboSelected!.exerciseWeights.remove(oldExerciseId);
                                    _comboSelected!.exerciseRestTimes.remove(oldExerciseId);
                                  }
                                }
                              });
                              _updateEstimatedCalories();
                              Navigator.pop(context);
                            },
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

  Widget _buildComboExercisesSwipeBox(double chieuRong, double chieuCao) {
    if (_comboSelected == null) return const SizedBox.shrink();
    final controller = Get.find<WorkoutController>();
    final comboExs = controller.getExercisesForCombo(_comboSelected!);

    if (comboExs.isEmpty) {
      return Center(
        child: Text(
          'Combo không có bài tập nào',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : const Color(0xFFB6B4C1),
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1D1517);
    final descCol = isDark ? Colors.grey.shade400 : const Color(0xFFB6B4C1);
    final bgCol = isDark ? const Color(0xFF1E293B) : const Color(0xFFF7F8F8);

    return Container(
      height: 250,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: PageView.builder(
        itemCount: comboExs.length,
        itemBuilder: (context, index) {
          final ex = comboExs[index];
          final exId = ex.id;
          final r = _comboSelected!.exerciseReps[exId] ?? 10;
          final s = _comboSelected!.exerciseSets[exId] ?? 3;
          final w = _comboSelected!.exerciseWeights[exId] ?? 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      ex.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.fitness_center, color: Get.theme.colorScheme.primary, size: 30),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textCol,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Bài tập ${index + 1}/${comboExs.length} trong Combo',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: descCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.blueAccent),
                    onPressed: () => _showSwapExerciseDialog(ex.id),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  children: [
                    _buildMiniActionCard('Độ khó riêng', ex.difficulty, () => _showDifficultyDialog(exerciseId: exId)),
                    _buildMiniActionCard('Số hiệp', '$s hiệp', () => _showSetsComboDialog(exId)),
                    _buildMiniActionCard(
                      ex.category.toLowerCase() == 'cardio' || ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio')
                          ? 'Thời gian'
                          : 'Số lần',
                      ex.category.toLowerCase() == 'cardio' || ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio')
                          ? '$r giây'
                          : '$r lần',
                      () => _showRepsDialog(exerciseId: exId),
                    ),
                    _buildMiniActionCard('Mức tạ', '${w.toStringAsFixed(1)} kg', () => _showWeightDialog(exerciseId: exId)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMiniActionCard(String title, String val, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1D1517);
    final descCol = isDark ? Colors.grey.shade400 : const Color(0xFFB6B4C1);
    final innerBg = isDark ? const Color(0xFF0F172A) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: innerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: textCol.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: descCol,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    val,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.edit, size: 10, color: Get.theme.colorScheme.primary),
              ],
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : const Color(0xFF1D1517);
    final descCol = isDark ? Colors.grey.shade400 : const Color(0xFFB6B4C1);
    final bgCol = isDark ? const Color(0xFF1E293B) : const Color(0xFFF7F8F8);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppHeader(
                title: widget.scheduleId != null ? 'Sửa lịch tập' : 'Thêm lịch tập',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.08, vertical: chieuCao * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _chonNgay(context),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: descCol, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            ngayHienTai,
                            style: TextStyle(
                              color: descCol,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.04),
                    Text(
                      'Thời gian',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: _gioDuocChon, minute: _phutDuocChon),
                            initialEntryMode: TimePickerEntryMode.dial,
                            builder: (context, child) {
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: isDark
                                      ? ColorScheme.dark(
                                          primary: Get.theme.colorScheme.primary,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        )
                                      : ColorScheme.light(
                                          primary: Get.theme.colorScheme.primary,
                                          onPrimary: Colors.white,
                                          onSurface: const Color(0xFF1D1517),
                                        ),
                                ),
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                  child: child!,
                                ),
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _gioDuocChon = picked.hour;
                              _phutDuocChon = picked.minute;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 40,
                          ),
                          decoration: BoxDecoration(
                            color: bgCol,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_gioDuocChon.toString().padLeft(2, '0')}:${_phutDuocChon.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Get.theme.colorScheme.primary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: chieuCao * 0.05),
                    Text(
                      'Lặp lại',
                      style: TextStyle(
                        color: textCol,
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
                                    ? Get.theme.colorScheme.primary
                                    : bgCol,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _ngayLapLai[index],
                                  style: TextStyle(
                                    color: _ngayDuocChonTrongTuan[index] ? Colors.white : descCol,
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
                      'Chi tiết bài tập',
                      style: TextStyle(
                        color: textCol,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    _taoMenuTuyChon(context, Icons.fitness_center, 'Chọn bài tập', 
                      giaTri: _selectedName ?? 'Chưa chọn', 
                      coMuiTen: true, 
                      onTap: _showExerciseSelectionSheet
                    ),
                    SizedBox(height: chieuCao * 0.015),
                    if (_comboSelected != null) ...[
                      _taoMenuTuyChon(context, Icons.swap_vert, 'Độ khó đồng bộ (Combo)', 
                        giaTri: _difficulty, 
                        coMuiTen: true, 
                        onTap: () => _showDifficultyDialog(isGeneralCombo: true)
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Cài đặt riêng từng bài',
                        style: TextStyle(
                          color: textCol,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      _buildComboExercisesSwipeBox(chieuRong, chieuCao),
                    ] else ...[
                      Builder(
                        builder: (context) {
                          final controller = Get.find<WorkoutController>();
                          final singleEx = controller.allExercises.firstWhereOrNull((e) => e.title == _selectedName);
                          final isSingleCardio = singleEx != null && (singleEx.category.toLowerCase() == 'cardio' || singleEx.bodyParts.any((bp) => bp.toLowerCase() == 'cardio'));
                          return Column(
                            children: [
                              _taoMenuTuyChon(context, Icons.swap_vert, 'Độ khó', 
                                giaTri: _difficulty, 
                                coMuiTen: true, 
                                onTap: () => _showDifficultyDialog()
                              ),
                              SizedBox(height: chieuCao * 0.015),
                              _taoMenuTuyChon(context, isSingleCardio ? Icons.timer_outlined : Icons.repeat, isSingleCardio ? 'Thời gian tập' : 'Số lần tập', 
                                giaTri: isSingleCardio ? '$_reps giây' : '$_reps lần', 
                                coMuiTen: true, 
                                onTap: () => _showRepsDialog()
                              ),
                              SizedBox(height: chieuCao * 0.015),
                              _taoMenuTuyChon(context, Icons.grid_3x3, 'Số hiệp (Sets)', 
                                giaTri: '$_sets hiệp', 
                                coMuiTen: true, 
                                onTap: () => _showSetsDialog()
                              ),
                              SizedBox(height: chieuCao * 0.015),
                              _taoMenuTuyChon(context, Icons.monitor_weight_outlined, 'Mức tạ', 
                                giaTri: '${_weight.toStringAsFixed(1)} kg', 
                                coMuiTen: true, 
                                onTap: () => _showWeightDialog()
                              ),
                              SizedBox(height: chieuCao * 0.015),
                              _taoMenuTuyChon(context, Icons.timer_outlined, 'Thời gian nghỉ', 
                                giaTri: '$_restTime giây', 
                                coMuiTen: true, 
                                onTap: () => _showRestTimeDialog()
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                    if (_selectedName != null && _selectedName!.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF3F2B96), const Color(0xFFA8C0FF).withValues(alpha: 0.2)]
                                : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1).withValues(alpha: 0.2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orangeAccent,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ước tính tiêu hao',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textCol,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Năng lượng tiêu thụ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        color: descCol,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '${_estimatedCalories.toStringAsFixed(1)} Calo',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
                        color: bgCol,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Center(
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Get.theme.colorScheme.primary,
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
                    onTap: () async {
                      if (_selectedName == null || _selectedName!.isEmpty) {
                        Get.snackbar(
                          'Cảnh báo',
                          'Vui lòng chọn bài tập hoặc combo trước khi lưu!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orangeAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final WorkoutController controller = Get.find<WorkoutController>();
                      String timeStr = '${_gioDuocChon.toString().padLeft(2, '0')}:${_phutDuocChon.toString().padLeft(2, '0')}';
                      
                      if (_comboSelected != null) {
                        for (var exId in _comboSelected!.exerciseIds) {
                          int reps = _comboSelected!.exerciseReps[exId] ?? 10;
                          int sets = _comboSelected!.exerciseSets[exId] ?? 3;
                          double weight = _comboSelected!.exerciseWeights[exId] ?? 0.0;
                          int restTime = _comboSelected!.exerciseRestTimes[exId] ?? 60;
                          
                          await controller.updateExerciseDetails(
                            _comboSelected!.id,
                            exId,
                            reps,
                            sets,
                            weight,
                            restTime,
                          );
                        }
                      }

                      if (widget.scheduleId != null) {
                        await controller.updateSchedule(
                          scheduleId: widget.scheduleId!,
                          exerciseName: _selectedName!,
                          exerciseImage: _selectedImage ?? '',
                          date: _ngayDuocChon,
                          time: timeStr,
                          repeatDays: _ngayDuocChonTrongTuan,
                          reps: _reps,
                          sets: _sets,
                          weight: _weight,
                          restTime: _restTime,
                        );
                      } else {
                        await controller.addSchedule(
                          exerciseName: _selectedName!,
                          exerciseImage: _selectedImage ?? '',
                          date: _ngayDuocChon,
                          time: timeStr,
                          repeatDays: _ngayDuocChonTrongTuan,
                          reps: _reps,
                          sets: _sets,
                          weight: _weight,
                          restTime: _restTime,
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
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
                          widget.scheduleId != null ? 'Cập nhật' : 'Lưu',
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

  Widget _taoMenuTuyChon(BuildContext context, IconData icon, String tieuDe, {String? giaTri, bool coMuiTen = false, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF1E293B) : const Color(0xFFF7F8F8);
    final descCol = isDark ? Colors.grey.shade400 : const Color(0xFFB6B4C1);
    final valCol = isDark ? Colors.grey.shade300 : const Color(0xFFA5A3AF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: descCol, size: 20),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                tieuDe,
                style: TextStyle(
                  color: descCol,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (giaTri != null)
              Text(
                giaTri,
                style: TextStyle(
                  color: valCol,
                  fontSize: 10,
                  fontFamily: 'Poppins',
                ),
              ),
            if (coMuiTen || giaTri != null) ...[
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_ios, color: valCol, size: 14),
            ]
          ],
        ),
      ),
    );
  }
}
