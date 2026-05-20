import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/other/views/target_settings_screen.dart';
import 'package:nutrifit/modules/main/home/views/main_screen.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Theo dõi hoạt động',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _taoTheMucTieuHomNay(),
              SizedBox(height: 30),
              _taoTheGiacNgu(),
              SizedBox(height: 30),
              _taoPhanTienDoHoatDong(),
              SizedBox(height: 30),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu hôm nay',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: () async {
                  for (var item in _danhSachMucTieu) {
                    if (item['id'] == 'steps') {
                      item['mucTieu'] = activityController.stepTarget.value
                          .toString();
                    } else if (item['id'] == 'water') {
                      double w = activityController.waterTarget.value;
                      item['mucTieu'] = (w % 1 == 0)
                          ? w.toInt().toString()
                          : w.toString();
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
                      _danhSachMucTieu = List<Map<String, dynamic>>.from(
                        ketQua,
                      );
                    });

                    final stepsItem = _danhSachMucTieu.firstWhere(
                      (e) => e['id'] == 'steps',
                    );
                    final waterItem = _danhSachMucTieu.firstWhere(
                      (e) => e['id'] == 'water',
                    );

                    activityController.updateTargets(
                      newStepTarget: int.tryParse(
                        stepsItem['mucTieu'].toString(),
                      ),
                      newWaterTarget: double.tryParse(
                        waterItem['mucTieu'].toString(),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Builder(
            builder: (context) {
              List<Map<String, dynamic>> mucTieuHienThi = _danhSachMucTieu
                  .where((item) => item['active'] == true)
                  .toList();

              if (mucTieuHienThi.isNotEmpty) {
                return SizedBox(
                  height: mucTieuHienThi.length > 2 ? 165 : 75,
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          mainAxisExtent: 75,
                        ),
                    itemCount: mucTieuHienThi.length,
                    itemBuilder: (context, index) {
                      final item = mucTieuHienThi[index];
                      return Obx(
                        () => _taoOChiTieu(
                          icon: item['icon'],
                          giatri: _layGiaTriTuController(
                            item['id'],
                            activityController,
                            item['mucTieu']?.toString() ?? '',
                          ),
                          ten: item['ten'],
                          onTap: item['id'] == 'calories'
                              ? () => activityController.showCalorieFormula()
                              : (item['id'] == 'water'
                                    ? () => _showWaterInput(
                                        context,
                                        activityController,
                                      )
                                    : null),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Chưa có mục tiêu nào được chọn',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _layGiaTriTuController(
    String id,
    ActivityController controller,
    String target,
  ) {
    String currentTarget = target;
    if (id == 'steps') {
      currentTarget = controller.stepTarget.value.toString();
    } else if (id == 'water') {
      double w = controller.waterTarget.value;
      currentTarget = (w % 1 == 0) ? w.toInt().toString() : w.toString();
    }

    String targetSuffix = (currentTarget.isNotEmpty && currentTarget != '0')
        ? ' / $currentTarget'
        : '';
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

  Widget _taoOChiTieu({
    required IconData icon,
    required String giatri,
    required String ten,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Get.theme.colorScheme.primary),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    giatri,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFFCC8FED),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ten,
                    style: TextStyle(
                      color: Color(0xFFB6B4C1),
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ten == 'Calo tiêu thụ')
                    Text(
                      '(Vận động+BMR+Tập)',
                      style: TextStyle(
                        color: Get.theme.colorScheme.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoPhanTienDoHoatDong() {
    final activityController = Get.find<ActivityController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ hoạt động',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF00B0FF)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
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
        SizedBox(height: 15),
        Obx(
          () => Container(
            height: 200,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Color(0x111D1617),
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
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
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
                            text = Text('CN', style: style);
                            break;
                          case 1:
                            text = Text('T2', style: style);
                            break;
                          case 2:
                            text = Text('T3', style: style);
                            break;
                          case 3:
                            text = Text('T4', style: style);
                            break;
                          case 4:
                            text = Text('T5', style: style);
                            break;
                          case 5:
                            text = Text('T6', style: style);
                            break;
                          case 6:
                            text = Text('T7', style: style);
                            break;
                          default:
                            text = Text('', style: style);
                            break;
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: text,
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _taoCotBieuDo(
                    0,
                    activityController.weeklyScores[0],
                    colorType: 'blue',
                  ),
                  _taoCotBieuDo(
                    1,
                    activityController.weeklyScores[1],
                    colorType: 'purple',
                  ),
                  _taoCotBieuDo(
                    2,
                    activityController.weeklyScores[2],
                    colorType: 'blue',
                  ),
                  _taoCotBieuDo(
                    3,
                    activityController.weeklyScores[3],
                    colorType: 'purple',
                  ),
                  _taoCotBieuDo(
                    4,
                    activityController.weeklyScores[4],
                    colorType: 'blue',
                  ),
                  _taoCotBieuDo(
                    5,
                    activityController.weeklyScores[5],
                    colorType: 'purple',
                  ),
                  _taoCotBieuDo(
                    6,
                    activityController.weeklyScores[6],
                    colorType: 'blue',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _taoCotBieuDo(
    int x,
    double y, {
    required String colorType,
  }) {
    List<Color> gradientColors = colorType == 'blue'
        ? [Color(0xFF42A5F5), Color(0xFF00B0FF)]
        : [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary];

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
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFFF7F8F8),
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
            Text(
              'Hoạt động mới nhất',
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
                  color: Color(0xFFA5A3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        _taoItemHoatDong(
          icon: Icons.water_drop,
          title: 'Uống 300ml nước',
          time: 'Khoảng 3 phút trước',
          colorType: 'blue',
        ),
        SizedBox(height: 15),
        _taoItemHoatDong(
          icon: Icons.fastfood,
          title: 'Ăn vặt (Fitbar)',
          time: 'Khoảng 10 phút trước',
          colorType: 'purple',
        ),
      ],
    );
  }

  Widget _taoItemHoatDong({
    required IconData icon,
    required String title,
    required String time,
    required String colorType,
  }) {
    List<Color> gradientColors = colorType == 'blue'
        ? [Color(0xFF42A5F5), Color(0xFF00B0FF)]
        : [Get.theme.colorScheme.primary, Get.theme.colorScheme.secondary];

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1D2430) : Colors.white,
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
              color: gradientColors[0].withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: gradientColors[0]),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA3A8AC),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, color: Color(0xFFA3A8AC), size: 20),
        ],
      ),
    );
  }

  Widget _taoTheGiacNgu() {
    final sleepController = Get.find<SleepController>();

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        final mainController = Get.find<MainScreenController>();
        mainController.setTab(1);
        Get.find<TargetTabController>().changeTab(2);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Color(0x111D1617),
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
                children: [
                  Text(
                    'Giấc ngủ đêm qua',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
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
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.nights_stay,
                    color: Get.theme.colorScheme.primary,
                    size: 30,
                  ),
                  SizedBox(width: 15),
                  Text(
                    '${th}h ${tm}m',
                    style: TextStyle(
                      color: Get.theme.colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Ngủ sâu (${dh}h ${dm}m)',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Color(0xFF7B6F72),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 5),
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFFF7F8F8),
                color: Get.theme.colorScheme.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(height: 15),
              Text(
                'Ngủ nông (${lh}h ${lm}m)',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Color(0xFF7B6F72),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 5),
              LinearProgressIndicator(
                value: 0.4,
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Color(0xFFF7F8F8),
                color: Color(0xFF00EFFF),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showWaterInput(
    BuildContext context,
    ActivityController activityController,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.2) : Color(0xFFD1D1D1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 25),
            Text(
              'Hôm nay ${activityController.userName} uống bao nhiêu rồi? 💧',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
              ),
            ),
            SizedBox(height: 30),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAdjustButton(
                    icon: Icons.remove_rounded,
                    onPressed: () {
                      if (activityController.water.value >= 0.1) {
                        activityController.addWater(-0.1);
                      }
                    },
                  ),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Text(
                        activityController.water.value.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF42A5F5),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Lít',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFA5A3AF),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 30),
                  _buildAdjustButton(
                    icon: Icons.add_rounded,
                    onPressed: () => activityController.addWater(0.1),
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAddButton(
                  '+100ml',
                  () => activityController.addWater(0.1),
                ),
                _buildQuickAddButton(
                  '+250ml',
                  () => activityController.addWater(0.25),
                ),
                _buildQuickAddButton(
                  '+500ml',
                  () => activityController.addWater(0.5),
                ),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF42A5F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  'Xong rồi nè!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF42A5F5).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Color(0xFF42A5F5), size: 30),
      ),
    );
  }

  Widget _buildQuickAddButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF42A5F5).withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Color(0xFF42A5F5),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
