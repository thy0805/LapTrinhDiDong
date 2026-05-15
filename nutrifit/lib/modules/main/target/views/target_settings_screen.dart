import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/views/workout_target_tab.dart';
import 'package:nutrifit/modules/main/target/views/nutrition_target_tab.dart';
import 'package:nutrifit/modules/main/target/views/other_target_tab.dart';
import 'package:nutrifit/modules/main/target/views/sleep_target_tab.dart';
import 'package:nutrifit/modules/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/home/views/widgets/app_header.dart';

class TargetSettingsScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? danhSachHienTai;

  const TargetSettingsScreen({super.key, this.danhSachHienTai});

  @override
  State<TargetSettingsScreen> createState() => _TargetSettingsScreenState();
}

class _TargetSettingsScreenState extends State<TargetSettingsScreen> {
  late List<Map<String, dynamic>> _danhSach;
  final ActivityController _activityController = Get.find<ActivityController>();

  @override
  void initState() {
    super.initState();
    _khoiTaoDanhSach();
  }

  void _khoiTaoDanhSach() {
    if (widget.danhSachHienTai != null) {
      _danhSach = List<Map<String, dynamic>>.from(widget.danhSachHienTai!.map((item) => Map<String, dynamic>.from(item)));
    } else {
      _danhSach = [
        {'id': 'water', 'icon': Icons.local_drink, 'ten': 'Lượng nước', 'active': true, 'mucTieu': _activityController.waterTarget.value.toString()},
        {'id': 'steps', 'icon': Icons.directions_walk, 'ten': 'Bước chân', 'active': true, 'mucTieu': _activityController.stepTarget.value.toString()},
        {'id': 'calories', 'icon': Icons.local_fire_department, 'ten': 'Calo tiêu thụ', 'active': true, 'mucTieu': ''},
        {'id': 'distance', 'icon': Icons.map, 'ten': 'Quãng đường', 'active': true, 'mucTieu': ''},
        {'id': 'heart', 'icon': Icons.favorite, 'ten': 'Nhịp tim', 'active': false, 'mucTieu': ''},
        {'id': 'move_minutes', 'icon': Icons.timer, 'ten': 'TG Vận động', 'active': false, 'mucTieu': ''},
      ];
    }
  }

  void _capNhatTrangThai(String tenMucTieu, bool giaTriMoi) {
    setState(() {
      final index = _danhSach.indexWhere((item) => item['ten'] == tenMucTieu);
      if (index != -1) {
        _danhSach[index]['active'] = giaTriMoi;
      }
    });
    _saveToController();
  }

  bool _layTrangThai(String tenMucTieu) {
    final item = _danhSach.firstWhere(
      (item) => item['ten'] == tenMucTieu,
      orElse: () => {'active': false},
    );
    return item['active'] as bool;
  }

  void _capNhatGiaTriMucTieu(String tenMucTieu, String giaTriMoi) {
    setState(() {
      final index = _danhSach.indexWhere((item) => item['ten'] == tenMucTieu);
      if (index != -1) {
        _danhSach[index]['mucTieu'] = giaTriMoi;
      }
    });
    _saveToController();
  }

  String _layGiaTriMucTieu(String tenMucTieu) {
    final item = _danhSach.firstWhere(
      (item) => item['ten'] == tenMucTieu,
      orElse: () => {'mucTieu': ''},
    );
    return item['mucTieu']?.toString() ?? '';
  }

  void _saveToController() {
    final stepsItem = _danhSach.firstWhere((e) => e['id'] == 'steps', orElse: () => {});
    final waterItem = _danhSach.firstWhere((e) => e['id'] == 'water', orElse: () => {});
    
    if (stepsItem.isNotEmpty && stepsItem['mucTieu'] != null) {
      _activityController.updateTargets(
        newStepTarget: int.tryParse(stepsItem['mucTieu'].toString()),
      );
    }
    if (waterItem.isNotEmpty && waterItem['mucTieu'] != null) {
      _activityController.updateTargets(
        newWaterTarget: double.tryParse(waterItem['mucTieu'].toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AppHeader(
              title: 'Cài đặt mục tiêu',
              showBackButton: widget.danhSachHienTai != null,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xFFC050F6),
            unselectedLabelColor: Color(0xFFB6B4C1),
            indicatorColor: Color(0xFFC050F6),
            isScrollable: true,
            tabs: [
              Tab(text: 'Tập luyện'),
              Tab(text: 'Dinh dưỡng'),
              Tab(text: 'Giấc ngủ'),
              Tab(text: 'Khác'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const WorkoutTargetTab(),
            const NutritionTargetTab(),
            const SleepTargetTab(),
            OtherTargetTab(
              getStatus: _layTrangThai,
              updateStatus: _capNhatTrangThai,
              getTarget: _layGiaTriMucTieu,
              updateTarget: _capNhatGiaTriMucTieu,
            ),
          ],
        ),
      ),
    );
  }
}
