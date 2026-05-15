import 'package:flutter/material.dart';
import 'package:nutrifit/modules/workout/views/exercise_details_screen.dart';
import 'package:nutrifit/modules/workout/controllers/workout_controller.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final ComboItem? combo;
  final List<ExerciseItem>? exercises;

  const WorkoutDetailsScreen({super.key, this.combo, this.exercises});

  List<ExerciseItem> _getExercises() {
    if (exercises != null && exercises!.isNotEmpty) return exercises!;
    return [
      ExerciseItem(id: 'EX_1', title: 'Khởi động', difficulty: 'Dễ', calories: 15, description: '', category: 'Toàn thân', image: '', equipments: []),
      ExerciseItem(id: 'EX_2', title: 'Bật nhảy chéo tay', difficulty: 'Vừa', calories: 45, description: '', category: 'Toàn thân', image: '', equipments: []),
      ExerciseItem(id: 'EX_3', title: 'Nhảy dây', difficulty: 'Vừa', calories: 60, description: '', category: 'Toàn thân', image: '', equipments: ['Dây nhảy']),
      ExerciseItem(id: 'EX_4', title: 'Nâng tạ', difficulty: 'Khó', calories: 80, description: '', category: 'Toàn thân', image: '', equipments: ['Tạ đòn']),
      ExerciseItem(id: 'EX_5', title: 'Nghỉ ngơi', difficulty: 'Dễ', calories: 0, description: '', category: 'Khác', image: '', equipments: ['Chai nước 1L']),
    ];
  }

  int _calculateTotalCalories(List<ExerciseItem> exList) {
    return exList.fold(0, (sum, item) => sum + item.calories);
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
    if (name.contains('tạ')) return Icons.fitness_center;
    if (name.contains('dây')) return Icons.sync;
    if (name.contains('nước')) return Icons.local_drink;
    if (name.contains('thảm')) return Icons.crop_landscape;
    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFC050F6),
            expandedHeight: chieuCao * 0.35,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    combo?.image ?? 'assets/workoutfullbody.png',
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) => const Icon(
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
              decoration: const BoxDecoration(
                color: Colors.white,
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
                          color: const Color(0xFF1D1517).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    Text(
                      combo?.title ?? 'Combo Toàn thân',
                      style: const TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Builder(
                      builder: (context) {
                        final exList = _getExercises();
                        final totalCal = _calculateTotalCalories(exList);
                        return Text(
                          '${exList.length} Bài tập | ${(exList.length * 3) + 15} Phút | $totalCal Calo',
                          style: const TextStyle(
                            color: Color(0xFFB6B4C1),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        );
                      }
                    ),
                    SizedBox(height: chieuCao * 0.03),

                    _taoTheThongTin(
                      icon: Icons.calendar_today,
                      tieuDe: 'Lên lịch tập',
                      giaTri: '27/5, 09:00 SA',
                      mauNen: const [Color(0xFF00FF66), Color(0xFF00EFFF)],
                      chieuRong: chieuRong,
                    ),
                    SizedBox(height: chieuCao * 0.015),
                    _taoTheThongTin(
                      icon: Icons.swap_vert,
                      tieuDe: 'Độ khó',
                      giaTri: 'Người mới',
                      mauNen: const [Color(0xFFC050F6), Color(0xFFEEA4CE)],
                      chieuRong: chieuRong,
                    ),
                    SizedBox(height: chieuCao * 0.03),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dụng cụ cần thiết',
                          style: TextStyle(
                            color: Color(0xFF1D1517),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final equips = _getUniqueEquipments(_getExercises());
                            return Text(
                              '${equips.length} Món',
                              style: const TextStyle(
                                color: Color(0xFFA5A3AF),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                    SizedBox(height: chieuCao * 0.015),

                    SizedBox(
                      height: chieuCao * 0.16,
                      child: Builder(
                        builder: (context) {
                          final equips = _getUniqueEquipments(_getExercises());
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: equips.length,
                            itemBuilder: (context, index) {
                              final equip = equips[index];
                              return _taoDungCu(_getEquipmentIcon(equip), equip, chieuRong);
                            },
                          );
                        }
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.03),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Bài tập trong Combo',
                          style: TextStyle(
                            color: Color(0xFF1D1517),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: chieuCao * 0.02),

                    Builder(
                      builder: (context) {
                        final exList = _getExercises();
                        return Column(
                          children: exList.map((ex) {
                            return _taoItemBaiTap(
                              context,
                              ex,
                              '10x', 
                              Icons.fitness_center,
                              chieuRong,
                            );
                          }).toList(),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: chieuRong * 0.08,
              right: chieuRong * 0.08,
              bottom: chieuCao * 0.02,
              top: chieuCao * 0.01,
            ),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: chieuCao * 0.075,
                width: double.infinity,
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
                child: const Center(
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
    required IconData icon,
    required String tieuDe,
    required String giaTri,
    required List<Color> mauNen,
    required double chieuRong,
  }) {
    return Container(
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
              style: const TextStyle(
                color: Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            giaTri,
            style: const TextStyle(
              color: Color(0xFFB6B4C1),
              fontSize: 10,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFFB6B4C1),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _taoDungCu(IconData icon, String ten, double chieuRong) {
    return Padding(
      padding: EdgeInsets.only(right: chieuRong * 0.04),
      child: Column(
        children: [
          Container(
            width: chieuRong * 0.21,
            height: chieuRong * 0.21,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFB6B4C1), size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            ten,
            style: const TextStyle(
              color: Color(0xFF1D1517),
              fontSize: 12,
              fontFamily: 'Poppins',
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
    IconData icon,
    double chieuRong,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: chieuRong * 0.04),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExerciseDetailsScreen(exercise: exercise),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: chieuRong * 0.16,
              height: chieuRong * 0.16,
              decoration: BoxDecoration(
                color: const Color(0xFFC050F6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFC050F6)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    thoiGian,
                    style: const TextStyle(
                      color: Color(0xFFB6B4C1),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB6B4C1)),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Color(0xFFB6B4C1),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
