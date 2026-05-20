import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/target/workout/views/congratulations_screen.dart';
import 'package:nutrifit/core/widgets/cached_image_widget.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final List<WorkoutExecutionItem> items;
  final String title;
  final String? scheduleId;

  const WorkoutExecutionScreen({
    super.key,
    required this.items,
    required this.title,
    this.scheduleId,
  });

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  int _currentItemIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _remainingRestSeconds = 0;
  Timer? _restTimer;

  bool _isCardioPlaying = false;
  int _remainingCardioSeconds = 0;
  Timer? _cardioTimer;
  bool _isProcessingClick = false;
  bool _isWorkoutCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartCardioTimer();
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _cardioTimer?.cancel();
    super.dispose();
  }

  void _checkAndStartCardioTimer() {
    _cardioTimer?.cancel();
    final currentItem = widget.items[_currentItemIndex];
    if (_isCardio(currentItem.exercise)) {
      setState(() {
        _isCardioPlaying = true;
        _remainingCardioSeconds = currentItem.reps;
      });
      _cardioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingCardioSeconds > 1) {
          setState(() {
            _remainingCardioSeconds--;
          });
        } else {
          _cardioTimer?.cancel();
          HapticFeedback.vibrate();
          if (currentItem.restTime > 0) {
            _startRestTimer(currentItem.restTime);
          } else {
            _skipRestTimer();
          }
        }
      });
    }
  }

  void _skipCardioTimer() {
    _cardioTimer?.cancel();
    HapticFeedback.vibrate();
    final currentItem = widget.items[_currentItemIndex];
    if (currentItem.restTime > 0) {
      _startRestTimer(currentItem.restTime);
    } else {
      _skipRestTimer();
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    _cardioTimer?.cancel();
    setState(() {
      _remainingRestSeconds = seconds;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingRestSeconds > 1) {
        setState(() {
          _remainingRestSeconds--;
        });
      } else {
        _skipRestTimer();
      }
    });
  }

  void _skipRestTimer() {
    _restTimer?.cancel();
    HapticFeedback.vibrate();

    final currentItem = widget.items[_currentItemIndex];

    if (_currentSet < currentItem.sets) {
      setState(() {
        _currentSet++;
        _isResting = false;
      });
      _checkAndStartCardioTimer();
    } else {
      if (_currentItemIndex < widget.items.length - 1) {
        setState(() {
          _currentItemIndex++;
          _currentSet = 1;
          _isResting = false;
        });
        _checkAndStartCardioTimer();
      } else {
        _completeWorkout();
      }
    }
  }

  void _completeWorkout() async {
    if (_isWorkoutCompleting) return;
    _isWorkoutCompleting = true;
    final controller = Get.find<WorkoutController>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    await controller.completeWorkoutSession(
      widget.items,
      scheduleId: widget.scheduleId,
      title: widget.title,
    );
    if (mounted) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CongratulationsScreen(),
        ),
      );
    }
  }

  bool _isCardio(ExerciseItem ex) {
    return ex.category.toLowerCase() == 'cardio' ||
        ex.bodyParts.any((bp) => bp.toLowerCase() == 'cardio');
  }

  @override
  Widget build(BuildContext context) {
    final chieuCao = MediaQuery.of(context).size.height;
    final chieuRong = MediaQuery.of(context).size.width;
    final currentItem = widget.items[_currentItemIndex];
    final exercise = currentItem.exercise;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D1517),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1D1517),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  'Thoát tập luyện?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1D1517),
                  ),
                ),
                content: Text(
                  'Bạn có chắc chắn muốn dừng buổi tập này không?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade300
                        : const Color(0xFF7B6F72),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tiếp tục tập', style: TextStyle(fontFamily: 'Poppins')),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Thoát', style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isResting ? _buildRestView(chieuCao, chieuRong) : _buildActiveView(chieuCao, chieuRong, exercise, currentItem),
        ),
      ),
    );
  }

  Widget _buildRestView(double chieuCao, double chieuRong) {
    final nextItem = _currentSet < widget.items[_currentItemIndex].sets
        ? widget.items[_currentItemIndex]
        : (_currentItemIndex < widget.items.length - 1 ? widget.items[_currentItemIndex + 1] : null);

    return Container(
      key: const ValueKey('rest'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'THỜI GIAN NGHỈ NGƠI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Get.theme.colorScheme.primary,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: chieuCao * 0.04),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: chieuRong * 0.5,
                height: chieuRong * 0.5,
                child: CircularProgressIndicator(
                  value: _remainingRestSeconds / (widget.items[_currentItemIndex].restTime > 0 ? widget.items[_currentItemIndex].restTime : 60),
                  strokeWidth: 10,
                  backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_remainingRestSeconds',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1D1517),
                    ),
                  ),
                  Text(
                    'giây',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: chieuCao * 0.06),
          if (nextItem != null) ...[
            Text(
              'TIẾP THEO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nextItem.exercise.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1D1517),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _currentSet < widget.items[_currentItemIndex].sets
                  ? 'Hiệp ${_currentSet + 1} trên ${nextItem.sets}'
                  : 'Hiệp 1 trên ${nextItem.sets} (${_isCardio(nextItem.exercise) ? "${nextItem.reps} giây" : "${nextItem.reps} lần"})',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: chieuCao * 0.06),
          GestureDetector(
            onTap: _skipRestTimer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: Get.theme.colorScheme.primary, width: 1.5),
                color: Get.theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              child: Text(
                'Bỏ qua nghỉ ngơi',
                style: TextStyle(
                  color: Get.theme.colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(double chieuCao, double chieuRong, ExerciseItem exercise, WorkoutExecutionItem currentItem) {
    return SizedBox(
      key: const ValueKey('active'),
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Center(
                    child: Container(
                      width: chieuRong * 0.88,
                      height: chieuCao * 0.22,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedImageWidget(
                          id: exercise.id,
                          type: 'exercises',
                          url: exercise.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: chieuCao * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1D1517),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bài tập ${_currentItemIndex + 1} trên ${widget.items.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Hiệp $_currentSet / ${currentItem.sets}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: chieuCao * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(
                        icon: Icons.repeat,
                        label: _isCardio(exercise) ? 'Thời gian' : 'Số lần',
                        value: _isCardio(exercise) ? '${currentItem.reps} giây' : '${currentItem.reps} lần',
                      ),
                      if (currentItem.weight > 0)
                        _buildInfoChip(
                          icon: Icons.fitness_center,
                          label: 'Mức tạ',
                          value: '${currentItem.weight.toStringAsFixed(1)} kg',
                        )
                      else
                        _buildInfoChip(
                          icon: Icons.person_outline,
                          label: 'Kháng lực',
                          value: 'Tay không',
                        ),
                      _buildInfoChip(
                        icon: Icons.timer_outlined,
                        label: 'Nghỉ',
                        value: '${currentItem.restTime} giây',
                      ),
                    ],
                  ),
                  SizedBox(height: chieuCao * 0.03),
                  Text(
                    'Hướng dẫn thực hiện',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1D1517),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(exercise.instructions.length, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.transparent
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Get.theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              exercise.instructions[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                height: 1.5,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade300
                                    : const Color(0xFF7B6F72),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: chieuRong * 0.08,
              vertical: chieuCao * 0.02,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: _isCardioPlaying
                ? GestureDetector(
                    onTap: _skipCardioTimer,
                    child: Container(
                      height: chieuCao * 0.065,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Get.theme.colorScheme.primary, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          'Đang tập: ${_remainingCardioSeconds}s (Bỏ qua)',
                          style: TextStyle(
                            color: Get.theme.colorScheme.primary,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _isProcessingClick ? null : () async {
                      if (_isProcessingClick) return;
                      setState(() {
                        _isProcessingClick = true;
                      });
                      if (currentItem.restTime > 0) {
                        _startRestTimer(currentItem.restTime);
                      } else {
                        _skipRestTimer();
                      }
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (mounted) {
                        setState(() {
                          _isProcessingClick = false;
                        });
                      }
                    },
                    child: Container(
                      height: chieuCao * 0.065,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
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
                          'Hoàn thành Hiệp $_currentSet',
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
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Get.theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Get.theme.colorScheme.primary, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Poppins',
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1D1517),
            ),
          ),
        ],
      ),
    );
  }
}
