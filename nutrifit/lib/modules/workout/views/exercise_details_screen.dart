import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nutrifit/modules/workout/controllers/workout_controller.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseItem exercise;
  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D1517), size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1D1517)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: chieuRong * 0.08, vertical: chieuCao * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: chieuCao * 0.25,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
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
                      decoration: const BoxDecoration(
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Image.network(
                    widget.exercise.image, 
                    height: chieuCao * 0.2,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: chieuCao * 0.03),
            Text(
              widget.exercise.title,
              style: const TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${widget.exercise.difficulty} | Đốt cháy ${widget.exercise.calories} Calo',
              style: const TextStyle(
                color: Color(0xFFB6B4C1),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            if (widget.exercise.equipments.isNotEmpty) ...[
              const Text(
                'Dụng cụ cần thiết',
                style: TextStyle(
                  color: Color(0xFF1D1517),
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
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.exercise.equipments.length,
                  itemBuilder: (context, index) {
                    final equipName = widget.exercise.equipments[index];
                    return _taoDungCu(_getEquipmentIcon(equipName), equipName, chieuRong);
                  },
                ),
              ),
              SizedBox(height: chieuCao * 0.02),
            ],
            if (widget.exercise.targetMuscles.isNotEmpty)
              Text('Cơ mục tiêu: ${widget.exercise.targetMuscles.join(', ')}', style: const TextStyle(color: Color(0xFFB6B4C1), fontSize: 12, fontFamily: 'Poppins')),
            if (widget.exercise.secondaryMuscles.isNotEmpty)
              Text('Cơ phụ: ${widget.exercise.secondaryMuscles.join(', ')}', style: const TextStyle(color: Color(0xFFB6B4C1), fontSize: 12, fontFamily: 'Poppins')),
            SizedBox(height: chieuCao * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cách thực hiện',
                  style: TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${widget.exercise.instructions.length} Bước',
                  style: const TextStyle(
                    color: Color(0xFFA5A3AF),
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
              const Text('Chưa có hướng dẫn cho bài tập này.', style: TextStyle(color: Color(0xFFB6B4C1), fontFamily: 'Poppins')),
            SizedBox(height: chieuCao * 0.03),
            const Text(
              'Tùy chỉnh số lần tập',
              style: TextStyle(
                color: Color(0xFF1D1517),
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
                scrollController: FixedExtentScrollController(initialItem: 5),
                selectionOverlay: Container(
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Color(0xFFC6C4D3), width: 1),
                    ),
                  ),
                ),
                onSelectedItemChanged: (int index) {},
                children: List<Widget>.generate(20, (int index) {
                  int giaTri = 25 + index;
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.exercise.calories} Calo',
                          style: const TextStyle(
                            color: Color(0xFFA5A3AF),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '$giaTri',
                          style: const TextStyle(
                            color: Color(0xFF1D1517),
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'lần',
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
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: chieuRong * 0.08, 
              right: chieuRong * 0.08, 
              bottom: chieuCao * 0.02, 
              top: chieuCao * 0.01
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
                    'Lưu',
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

  Widget _taoBuocThucHien(String soThuTu, String tieuDe, String moTa, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC050F6), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    soThuTu,
                    style: const TextStyle(
                      color: Color(0xFFC050F6),
                      fontSize: 10,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: CustomPaint(
                    size: const Size(1, double.infinity),
                    painter: _VeDuongVienDoc(color: const Color(0xFFC050F6)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    style: const TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    moTa,
                    style: const TextStyle(
                      color: Color(0xFFB6B4C1),
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
      ),
    );
  }

  IconData _getEquipmentIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('tạ')) return Icons.fitness_center;
    if (name.contains('dây')) return Icons.sync;
    if (name.contains('nước')) return Icons.local_drink;
    if (name.contains('thảm')) return Icons.crop_landscape;
    return Icons.fitness_center;
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
}

class _VeDuongVienDoc extends CustomPainter {
  final Color color;

  _VeDuongVienDoc({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var max = size.height;
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