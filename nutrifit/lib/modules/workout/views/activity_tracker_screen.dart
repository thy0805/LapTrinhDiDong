import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/views/target_settings_screen.dart';
import 'package:nutrifit/modules/sleep/views/sleep_tracker_screen.dart';
import 'package:nutrifit/modules/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/workout/controllers/activity_controller.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({super.key});

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  List<Map<String, dynamic>> _danhSachMucTieu = [
    {
      'id': 'water',
      'icon': Icons.local_drink,
      'ten': 'Lượng nước',
      'active': true,
      'mucTieu': '8',
    },
    {
      'id': 'steps',
      'icon': Icons.directions_walk,
      'ten': 'Bước chân',
      'active': true,
      'mucTieu': '2400',
    },
    {
      'id': 'calories',
      'icon': Icons.local_fire_department,
      'ten': 'Calo tiêu thụ',
      'active': true,
      'mucTieu': '',
    },
    {
      'id': 'distance',
      'icon': Icons.map,
      'ten': 'Quãng đường',
      'active': true,
      'mucTieu': '',
    },
    {
      'id': 'heart',
      'icon': Icons.favorite,
      'ten': 'Nhịp tim',
      'active': false,
      'mucTieu': '',
    },
    {
      'id': 'move_minutes',
      'icon': Icons.timer,
      'ten': 'TG Vận động',
      'active': false,
      'mucTieu': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    Get.put(SleepController());
    Get.put(ActivityController());
    // Đồng bộ mục tiêu từ controller ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dongBoMucTieuTuControllers();
    });
  }

  void _dongBoMucTieuTuControllers() {
    final activityController = Get.find<ActivityController>();
    
    setState(() {
      for (var item in _danhSachMucTieu) {
        if (item['id'] == 'steps') {
          item['mucTieu'] = activityController.stepTarget.value.toString();
        } else if (item['id'] == 'water') {
          item['mucTieu'] = activityController.waterTarget.value.toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Theo dõi hoạt động',
          style: TextStyle(
            color: Color(0xFF1D1517),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1D1517)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _taoTheMucTieuHomNay(),
              const SizedBox(height: 30),
              _taoTheGiacNgu(),
              const SizedBox(height: 30),
              _taoPhanTienDoHoatDong(),
              const SizedBox(height: 30),
              _taoPhanHoatDongMoiNhat(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taoTheMucTieuHomNay() {
    final activityController = Get.find<ActivityController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFC050F6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mục tiêu hôm nay',
                style: TextStyle(
                  color: Color(0xFF1D1517),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () async {
                  for (var item in _danhSachMucTieu) {
                    if (item['id'] == 'steps') {
                      item['mucTieu'] = activityController.stepTarget.value.toString();
                    } else if (item['id'] == 'water') {
                      double w = activityController.waterTarget.value;
                      item['mucTieu'] = (w % 1 == 0) ? w.toInt().toString() : w.toString();
                    }
                  }

                  final ketQua = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TargetSettingsScreen(
                        danhSachHienTai: _danhSachMucTieu,
                      ),
                    ),
                  );
                  if (ketQua != null) {
                    setState(() {
                      _danhSachMucTieu = List<Map<String, dynamic>>.from(ketQua);
                    });
                    
                    // Lưu mục tiêu mới lên Firebase thông qua controller
                    final stepsItem = _danhSachMucTieu.firstWhere((e) => e['id'] == 'steps');
                    final waterItem = _danhSachMucTieu.firstWhere((e) => e['id'] == 'water');
                    
                    activityController.updateTargets(
                      newStepTarget: int.tryParse(stepsItem['mucTieu'].toString()),
                      newWaterTarget: double.tryParse(waterItem['mucTieu'].toString()),
                    );
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Builder(builder: (context) {
            List<Map<String, dynamic>> mucTieuHienThi = _danhSachMucTieu
                .where((item) => item['active'] == true)
                .toList();

            if (mucTieuHienThi.isNotEmpty) {
              return SizedBox(
                height: mucTieuHienThi.length > 2 ? 165 : 75,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    mainAxisExtent: 75,
                  ),
                  itemCount: mucTieuHienThi.length,
                  itemBuilder: (context, index) {
                    final item = mucTieuHienThi[index];
                    return Obx(() => _taoOChiTieu(
                      item['icon'],
                      _layGiaTriTuController(item['id'], activityController, item['mucTieu']?.toString() ?? ''),
                      item['ten'],
                    ));
                  },
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Chưa có mục tiêu nào được chọn',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  String _layGiaTriTuController(String id, ActivityController controller, String target) {
    String currentTarget = target;
    if (id == 'steps') {
      currentTarget = controller.stepTarget.value.toString();
    } else if (id == 'water') {
      double w = controller.waterTarget.value;
      currentTarget = (w % 1 == 0) ? w.toInt().toString() : w.toString();
    }

    String targetSuffix = (currentTarget.isNotEmpty && currentTarget != '0') ? ' / $currentTarget' : '';
    switch (id) {
      case 'water':
        return '${controller.water.value.toStringAsFixed(1)}$targetSuffix L';
      case 'steps':
        return '${controller.steps.value}$targetSuffix';
      case 'calories':
        return '${controller.calories.value.toStringAsFixed(0)}$targetSuffix kcal';
      case 'distance':
        return '${(controller.distance.value / 1000).toStringAsFixed(2)}$targetSuffix km';
      case 'heart':
        return '${controller.heartRate.value} bpm';
      case 'move_minutes':
        return '${controller.moveMinutes.value} phút';
      default:
        return '0';
    }
  }

  Widget _taoOChiTieu(IconData icon, String giatri, String ten) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC050F6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  giatri,
                  style: const TextStyle(
                    color: Color(0xFFCC8FED),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ten,
                  style: const TextStyle(
                    color: Color(0xFFB6B4C1),
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taoPhanTienDoHoatDong() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tiến độ hoạt động',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF66), Color(0xFF00EFFF)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Row(
                children: [
                  Text(
                    'Hàng tuần',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x111D1617),
                blurRadius: 40,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              minY: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const style = TextStyle(
                        color: Color(0xFFB6B4C1),
                        fontSize: 12,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = const Text('CN', style: style);
                          break;
                        case 1:
                          text = const Text('T2', style: style);
                          break;
                        case 2:
                          text = const Text('T3', style: style);
                          break;
                        case 3:
                          text = const Text('T4', style: style);
                          break;
                        case 4:
                          text = const Text('T5', style: style);
                          break;
                        case 5:
                          text = const Text('T6', style: style);
                          break;
                        case 6:
                          text = const Text('T7', style: style);
                          break;
                        default:
                          text = const Text('', style: style);
                          break;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: text,
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                _taoCotBieuDo(0, 4, isGreen: true),
                _taoCotBieuDo(1, 7, isGreen: false),
                _taoCotBieuDo(2, 5, isGreen: true),
                _taoCotBieuDo(3, 6, isGreen: false),
                _taoCotBieuDo(4, 8, isGreen: true),
                _taoCotBieuDo(5, 3, isGreen: false),
                _taoCotBieuDo(6, 6, isGreen: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _taoCotBieuDo(int x, double y, {required bool isGreen}) {
    List<Color> gradientColors = isGreen
        ? [const Color(0xFF00FF66), const Color(0xFF00EFFF)]
        : [const Color(0xFFC050F6), const Color(0xFFEEA4CE)];

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: const Color(0xFFF7F8F8),
          ),
        ),
      ],
    );
  }

  Widget _taoPhanHoatDongMoiNhat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hoạt động mới nhất',
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
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _taoItemHoatDong(
          icon: Icons.water_drop,
          title: 'Uống 300ml nước',
          time: 'Khoảng 3 phút trước',
          isGreen: true,
        ),
        const SizedBox(height: 15),
        _taoItemHoatDong(
          icon: Icons.fastfood,
          title: 'Ăn vặt (Fitbar)',
          time: 'Khoảng 10 phút trước',
          isGreen: false,
        ),
      ],
    );
  }

  Widget _taoItemHoatDong({
    required IconData icon,
    required String title,
    required String time,
    required bool isGreen,
  }) {
    List<Color> gradientColors = isGreen
        ? [const Color(0xFF00FF66), const Color(0xFF00EFFF)]
        : [const Color(0xFFC050F6), const Color(0xFFEEA4CE)];

    return Container(
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
              color: gradientColors[0].withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: gradientColors[0]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1D1517),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFFA3A8AC),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Color(0xFFA3A8AC), size: 20),
        ],
      ),
    );
  }

  Widget _taoTheGiacNgu() {
    final sleepController = Get.find<SleepController>();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SleepTrackerScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x111D1617),
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Obx(() {
          double totalDuration = sleepController.lastNightSleep.value;
          int th = totalDuration.floor();
          int tm = ((totalDuration - th) * 60).round();

          double deepSleep = totalDuration * 0.6;
          int dh = deepSleep.floor();
          int dm = ((deepSleep - dh) * 60).round();

          double lightSleep = totalDuration * 0.4;
          int lh = lightSleep.floor();
          int lm = ((lightSleep - lh) * 60).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Giấc ngủ đêm qua',
                    style: TextStyle(
                      color: Color(0xFF1D1517),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFA5A3AF),
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.nights_stay,
                    color: Color(0xFFC050F6),
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    '${th}h ${tm}m',
                    style: const TextStyle(
                      color: Color(0xFFC050F6),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Ngủ sâu (${dh}h ${dm}m)',
                style: const TextStyle(
                  color: Color(0xFF7B6F72),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: const Color(0xFFF7F8F8),
                color: const Color(0xFFC050F6),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 15),
              Text(
                'Ngủ nông (${lh}h ${lm}m)',
                style: const TextStyle(
                  color: Color(0xFF7B6F72),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: 0.4,
                backgroundColor: const Color(0xFFF7F8F8),
                color: const Color(0xFF00EFFF),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          );
        }),
      ),
    );
  }
}
