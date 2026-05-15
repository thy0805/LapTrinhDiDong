import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class AddWorkoutScheduleScreen extends StatefulWidget {
  final String? exerciseName;
  final String? exerciseImage;
  final String? scheduleId;
  final String? initialTime;
  final DateTime? initialDate;
  final List<bool>? initialRepeatDays;

  const AddWorkoutScheduleScreen({
    super.key,
    this.exerciseName,
    this.exerciseImage,
    this.scheduleId,
    this.initialTime,
    this.initialDate,
    this.initialRepeatDays,
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC050F6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D1517),
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

  @override
  Widget build(BuildContext context) {
    final kichThuoc = MediaQuery.of(context).size;
    final chieuRong = kichThuoc.width;
    final chieuCao = kichThuoc.height;
    
    String ngayHienTai = getVietnameseDate(_ngayDuocChon);

    return Scaffold(
      backgroundColor: Colors.white,
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
                          const Icon(Icons.calendar_today, color: Color(0xFFA5A3AF), size: 16),
                          const SizedBox(width: 10),
                          Text(
                            ngayHienTai,
                            style: const TextStyle(
                              color: Color(0xFFB6B4C1),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.04),
                    const Text(
                      'Thời gian',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
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
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFC050F6),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xFF1D1517),
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
                            color: const Color(0xFFF7F8F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_gioDuocChon.toString().padLeft(2, '0')}:${_phutDuocChon.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC050F6),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: chieuCao * 0.05),
                    const Text(
                      'Lặp lại',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
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
                                    ? const Color(0xFFC050F6)
                                    : const Color(0xFFF7F8F8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _ngayLapLai[index],
                                  style: TextStyle(
                                    color: _ngayDuocChonTrongTuan[index] ? Colors.white : const Color(0xFFA5A3AF),
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
                    const Text(
                      'Chi tiết bài tập',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: chieuCao * 0.02),
                    _taoMenuTuyChon(Icons.fitness_center, 'Chọn bài tập', giaTri: widget.exerciseName ?? 'Tập thân trên'),
                    SizedBox(height: chieuCao * 0.015),
                    _taoMenuTuyChon(Icons.swap_vert, 'Độ khó', giaTri: 'Người mới'),
                    SizedBox(height: chieuCao * 0.015),
                    _taoMenuTuyChon(Icons.repeat, 'Tùy chỉnh số lần tập', coMuiTen: true),
                    SizedBox(height: chieuCao * 0.015),
                    _taoMenuTuyChon(Icons.monitor_weight_outlined, 'Tùy chỉnh mức tạ', coMuiTen: true),
                  ],
                ),
              ),
            ),
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
                        color: const Color(0xFFF7F8F8),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Center(
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: Color(0xFFC050F6),
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
                      final WorkoutController controller = Get.find<WorkoutController>();
                      
                      String timeStr = '${_gioDuocChon.toString().padLeft(2, '0')}:${_phutDuocChon.toString().padLeft(2, '0')}';
                      
                      if (widget.scheduleId != null) {
                        await controller.updateSchedule(
                          scheduleId: widget.scheduleId!,
                          exerciseName: widget.exerciseName ?? 'Tập thân trên',
                          exerciseImage: widget.exerciseImage ?? '',
                          date: _ngayDuocChon,
                          time: timeStr,
                          repeatDays: _ngayDuocChonTrongTuan,
                        );
                      } else {
                        await controller.addSchedule(
                          exerciseName: widget.exerciseName ?? 'Tập thân trên',
                          exerciseImage: widget.exerciseImage ?? '',
                          date: _ngayDuocChon,
                          time: timeStr,
                          repeatDays: _ngayDuocChonTrongTuan,
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

  Widget _taoMenuTuyChon(IconData icon, String tieuDe, {String? giaTri, bool coMuiTen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB6B4C1), size: 20),
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
          if (giaTri != null)
            Text(
              giaTri,
              style: const TextStyle(
                color: Color(0xFFA5A3AF),
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
            ),
          if (coMuiTen || giaTri != null) ...[
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFA5A3AF), size: 14),
          ]
        ],
      ),
    );
  }
}