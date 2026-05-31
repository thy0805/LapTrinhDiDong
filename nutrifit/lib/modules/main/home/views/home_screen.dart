import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/home/controllers/home_controller.dart';
import 'package:nutrifit/modules/main/home/views/main_screen.dart';
import 'package:nutrifit/core/services/gamification_service.dart';

import 'package:nutrifit/modules/main/home/views/notification_screen.dart';
import 'package:nutrifit/modules/main/home/views/monthly_overview_screen.dart';
import 'package:nutrifit/modules/main/home/views/articles_screen.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController home = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(context, home),
              SizedBox(height: 20),
              Obx(
                () => _buildSmartSuggestion(
                  context,
                  home.suggestion,
                ),
              ),
              SizedBox(height: 25),
              const HomeStepTrackerCard(),
              SizedBox(height: 25),
              const HomeWaterTrackerCard(),
              SizedBox(height: 25),
              const HomeSleepTrackerCard(),
              SizedBox(height: 25),
              Obx(() => _buildActivityOverview(context, home)),
              SizedBox(height: 25),
              Obx(() {
                double weight =
                    double.tryParse(home.auth.userData['weight'] ?? '0') ??
                    0;
                double height =
                    double.tryParse(home.auth.userData['height'] ?? '0') ??
                    0;
                double bmi = 0;
                String status = "Chưa có dữ liệu";
                if (height > 0 && weight > 0) {
                  bmi = weight / ((height / 100) * (height / 100));
                  status = bmi < 18.5
                      ? "${home.userPronoun} hơi gầy đó nha"
                      : (bmi < 24.9
                            ? "Cân nặng của ${home.userPronoun} rất chuẩn"
                            : "Cần chú ý cân nặng nhé");
                }
                return _buildBMICard(context, bmi.toStringAsFixed(1), status);
              }),
              SizedBox(height: 25),
              _buildProgressChart(context, home),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, HomeController home) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào mừng trở lại,',
                style: TextStyle(
                  color: Color(0xFFA5A3AF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 4),
              Obx(
                () => Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          home.userName,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                            fontSize: 22,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final gamification = Get.find<GamificationService>();
                            final int exp = home.auth.userData['exp'] ?? 0;
                            final int level = gamification.getLevel(exp);
                            
                            final range = gamification.getExpRangeForLevel(level);
                            int nextLevelExp = range['max']!;

                            return Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('Lv. $level', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(width: 8),
                                Text('$exp / $nextLevelExp XP', style: TextStyle(color: Color(0xFFA5A3AF), fontSize: 10)),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    if (home.streak > 0) ...[
                      SizedBox(width: 8),
                      Text(
                        '🔥 ${home.streak}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildHeaderMenu(context),
      ],
    );
  }

  Widget _buildHeaderMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 45),
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.more_horiz, size: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517)),
      ),
      onSelected: (value) {
        if (value == 'notifications') {
          Get.to(() => const NotificationScreen());
        } else if (value == 'articles') {
          Get.to(() => const ArticlesScreen());
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'notifications',
          child: Row(
            children: [
              Icon(
                Icons.notifications_none,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
              ),
              const SizedBox(width: 10),
              const Text(
                'Thông báo',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'articles',
          child: Row(
            children: [
              Icon(
                Icons.article_outlined,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
              ),
              const SizedBox(width: 10),
              const Text(
                'Mẹo & Kiến thức',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSuggestion(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildActivityOverview(BuildContext context, HomeController home) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nhật ký hoạt động',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => MonthlyOverviewScreen());
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Tổng quan tháng',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        GridView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 2.2,
          ),
          children: [
            _buildSmallStatCard(
              context,
              'Calo nạp',
              '${home.nutrition.totalCaloriesIntake.toInt()}',
              'kcal',
              Icons.fastfood_outlined,
              Colors.orange,
            ),
            Tooltip(
              message: 'Calo tiêu thụ = Vận động (Fit) + BMR + Luyện tập (App)',
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 3),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900.withValues(alpha: 0.9) : Color(0xFF1D1517).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 12),
              child: _buildSmallStatCard(
                context,
                'Calo tiêu',
                '${home.activity.calories.value.toInt()}',
                'kcal',
                Icons.local_fire_department_outlined,
                Colors.redAccent,
              ),
            ),
            _buildSmallStatCard(
              context,
              'Quãng đường',
              (home.activity.distance.value / 1000).toStringAsFixed(1),
              'km',
              Icons.map_outlined,
              Colors.blue,
            ),
            _buildSmallStatCard(
              context,
              'Vận động',
              '${home.activity.moveMinutes.value}',
              'phút',
              Icons.timer_outlined,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFFB6B4C1),
                    fontSize: 10,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(
                        color: Color(0xFFB6B4C1),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard(BuildContext context, String score, String status) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Color(0xFF1D1517).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Chỉ số BMI của bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Chỉ số hiện tại: $score',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('< 18.5', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
                          Text('Thiếu cân', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('18.5 - 24.9', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
                          Text('Bình thường', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('25.0 - 29.9', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
                          Text('Thừa cân', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('≥ 30.0', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                          Text('Béo phì', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chỉ số BMI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    status,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 15),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 8,
                    ),
                  ),
                ),
                Text(
                  score,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildProgressChart(BuildContext context, HomeController home) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến độ hoạt động',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 15),
        Container(
          height: 220,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Obx(
            () => BarChart(
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
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xFFB6B4C1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return Text('CN', style: style);
                          case 1:
                            return Text('T2', style: style);
                          case 2:
                            return Text('T3', style: style);
                          case 3:
                            return Text('T4', style: style);
                          case 4:
                            return Text('T5', style: style);
                          case 5:
                            return Text('T6', style: style);
                          case 6:
                            return Text('T7', style: style);
                          default:
                            return Text('', style: style);
                        }
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  7,
                  (i) => _buildBarGroup(context, i, home.activity.weeklyScores[i]),
                ),
              ),
            ),
          ),
        ),
        Obx(() => IconButton(
          onPressed: home.activity.isSyncing.value ? null : () => home.manualSync(),
          icon: home.activity.isSyncing.value 
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
            : Icon(Icons.sync_rounded, color: Theme.of(context).colorScheme.primary),
        )),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(BuildContext context, int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(20),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Color(0xFFF7F8F8),
          ),
        ),
      ],
    );
  }




}

class HomeWaterBubble {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double angle;
  double wobbleSpeed;

  HomeWaterBubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
    required this.wobbleSpeed,
  });
}

class HomeWaterTrackerCard extends StatefulWidget {
  const HomeWaterTrackerCard({super.key});

  @override
  State<HomeWaterTrackerCard> createState() => _HomeWaterTrackerCardState();
}

class _HomeWaterTrackerCardState extends State<HomeWaterTrackerCard>
    with TickerProviderStateMixin {
  final ActivityController _controller = Get.find<ActivityController>();
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  late Worker _worker;

  double _animatedRatio = 0.0;
  double _currentWaterRatio = 0.0;
  final List<HomeWaterBubble> _bubbles = [];
  final double _cupWidth = 85.0;
  final double _cupHeight = 135.0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    double currentVal = _controller.water.value;
    double targetVal = _controller.waterTarget.value > 0 ? _controller.waterTarget.value : 2.0;
    _currentWaterRatio = (currentVal / targetVal).clamp(0.0, 1.0);
    _animatedRatio = _currentWaterRatio;

    _levelAnimation = Tween<double>(begin: _animatedRatio, end: _animatedRatio).animate(_levelController);

    _waveController.addListener(() {
      setState(() {
        _updateBubbles();
      });
    });

    _worker = ever(_controller.water, (double val) {
      double targetVal = _controller.waterTarget.value > 0 ? _controller.waterTarget.value : 2.0;
      double newRatio = (val / targetVal).clamp(0.0, 1.0);
      _animateToRatio(newRatio);
    });
  }

  void _animateToRatio(double targetRatio) {
    _levelAnimation = Tween<double>(
      begin: _animatedRatio,
      end: targetRatio,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeOutBack,
    ));
    _levelController.forward(from: 0.0);
  }

  void _levelListener() {
    setState(() {
      _animatedRatio = _levelAnimation.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _levelAnimation.addListener(_levelListener);
  }

  @override
  void dispose() {
    _levelAnimation.removeListener(_levelListener);
    _waveController.dispose();
    _levelController.dispose();
    _worker.dispose();
    super.dispose();
  }

  void _updateBubbles() {
    double targetSurfaceY = _cupHeight * (1.0 - _animatedRatio);

    for (int i = _bubbles.length - 1; i >= 0; i--) {
      var bubble = _bubbles[i];
      bubble.y -= bubble.speed;
      bubble.angle += bubble.wobbleSpeed;
      bubble.x += sin(bubble.angle) * 0.3;

      if (bubble.y <= targetSurfaceY + 15) {
        bubble.opacity -= 0.05;
        bubble.size *= 0.95;
      }

      if (bubble.y <= targetSurfaceY || bubble.opacity <= 0 || bubble.size <= 0.4) {
        _bubbles.removeAt(i);
      }
    }

    if (_bubbles.length < 15 && _animatedRatio > 0.02) {
      if (Random().nextDouble() < 0.25) {
        _bubbles.add(HomeWaterBubble(
          x: Random().nextDouble() * (_cupWidth - 20) + 10,
          y: _cupHeight - 10,
          size: Random().nextDouble() * 4 + 2,
          speed: Random().nextDouble() * 1.2 + 0.5,
          opacity: Random().nextDouble() * 0.6 + 0.4,
          angle: Random().nextDouble() * pi * 2,
          wobbleSpeed: Random().nextDouble() * 0.06 + 0.02,
        ));
      }
    }
  }

  void _spawnBurst() {
    for (int i = 0; i < 20; i++) {
      _bubbles.add(HomeWaterBubble(
        x: Random().nextDouble() * (_cupWidth - 20) + 10,
        y: _cupHeight - Random().nextDouble() * 20 - 10,
        size: Random().nextDouble() * 6 + 3,
        speed: Random().nextDouble() * 3.0 + 1.0,
        opacity: Random().nextDouble() * 0.8 + 0.2,
        angle: Random().nextDouble() * pi * 2,
        wobbleSpeed: Random().nextDouble() * 0.15 + 0.05,
      ));
    }
  }

  void _handleAddWater(double amountInLiters) {
    _controller.addWater(amountInLiters);
    _spawnBurst();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showWaterInput(context, _controller),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: _cupWidth + 20,
                  height: _cupHeight + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0xFF00B0FF).withValues(alpha: 0.02) : const Color(0xFF42A5F5).withValues(alpha: 0.04),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: _cupWidth,
                      height: _cupHeight,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                          bottom: Radius.circular(30),
                        ),
                      ),
                      child: ClipPath(
                        clipper: HomeGlassCupClipper(),
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(_cupWidth, _cupHeight),
                                  painter: HomeWaveAndBubblePainter(
                                    waveAnimation: _waveController.value,
                                    ratio: _animatedRatio,
                                    bubbles: _bubbles,
                                    isDark: isDark,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 25,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 30,
                              bottom: 30,
                              width: 2.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.25),
                                      Colors.white.withValues(alpha: 0.01),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: _cupWidth - 2,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.elliptical(_cupWidth - 2, 12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.2),
                          isDark ? Colors.white.withValues(alpha: 0.01) : Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Cốc Nước Ma Thuật',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDark ? Colors.white : const Color(0xFF1D1517),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '💧',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    double curVal = _controller.water.value;
                    double trgVal = _controller.waterTarget.value > 0 ? _controller.waterTarget.value : 2.0;
                    int pct = ((curVal / trgVal) * 100).round().clamp(0, 999);
                    return Text(
                      'Đã đạt $pct% (${curVal.toStringAsFixed(2)}L / ${trgVal.toStringAsFixed(1)}L)',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFADA4A5) : const Color(0xFF7B6F72),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildMiniAddButton(context, '+100ml', () => _handleAddWater(0.1), isDark),
                        const SizedBox(width: 8),
                        _buildMiniAddButton(context, '+250ml', () => _handleAddWater(0.25), isDark),
                        const SizedBox(width: 8),
                        _buildMiniAddButton(context, '+500ml', () => _handleAddWater(0.5), isDark),
                      ],
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

  Widget _buildMiniAddButton(BuildContext context, String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0284C7).withValues(alpha: 0.15), const Color(0xFF0D9488).withValues(alpha: 0.08)]
                    : [Colors.white, Colors.white.withValues(alpha: 0.7)],
              ),
              border: Border.all(
                color: isDark ? const Color(0xFF0284C7).withValues(alpha: 0.2) : Colors.grey.shade200,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0284C7),
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showWaterInput(BuildContext context, dynamic activityController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFD1D1D1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Hôm nay ${activityController.userName} uống bao nhiêu rồi? 💧',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1D1517),
              ),
            ),
            const SizedBox(height: 30),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAdjustButton(
                  context,
                  icon: Icons.remove_rounded,
                  onPressed: () {
                    if (activityController.water.value >= 0.1) {
                      activityController.addWater(-0.1);
                    }
                  },
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    Text(
                      activityController.water.value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Text(
                      'Lít',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA5A3AF),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 30),
                _buildAdjustButton(
                  context,
                  icon: Icons.add_rounded,
                  onPressed: () => activityController.addWater(0.1),
                ),
              ],
            )),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAddButton(context, '+100ml', () => activityController.addWater(0.1)),
                _buildQuickAddButton(context, '+250ml', () => activityController.addWater(0.25)),
                _buildQuickAddButton(context, '+500ml', () => activityController.addWater(0.5)),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  'Xong rồi nè!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAdjustButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class HomeGlassCupClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - 5, size.height - 10);
    path.quadraticBezierTo(size.width - 7, size.height, size.width - 15, size.height);
    path.lineTo(15, size.height);
    path.quadraticBezierTo(7, size.height, 5, size.height - 10);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HomeWaveAndBubblePainter extends CustomPainter {
  final double waveAnimation;
  final double ratio;
  final List<HomeWaterBubble> bubbles;
  final bool isDark;

  HomeWaveAndBubblePainter({
    required this.waveAnimation,
    required this.ratio,
    required this.bubbles,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (ratio <= 0.0) return;

    final double surfaceY = size.height * (1.0 - ratio);
    final double waveHeight = 5.0;
    final double waveFrequency = 2.0 * pi / size.width;

    final Path wavePath1 = Path();
    wavePath1.moveTo(0, surfaceY);
    for (double x = 0; x <= size.width; x++) {
      double y = surfaceY + sin((waveAnimation * 2.0 * pi) + (x * waveFrequency)) * waveHeight;
      wavePath1.lineTo(x, y);
    }
    wavePath1.lineTo(size.width, size.height);
    wavePath1.lineTo(0, size.height);
    wavePath1.close();

    final Paint wavePaint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF00EFFF).withValues(alpha: 0.55),
                const Color(0xFF00B0FF).withValues(alpha: 0.75),
                const Color(0xFF0060FF).withValues(alpha: 0.9),
              ]
            : [
                const Color(0xFF00EFFF).withValues(alpha: 0.65),
                const Color(0xFF42A5F5).withValues(alpha: 0.8),
                const Color(0xFF1565C0).withValues(alpha: 0.95),
              ],
      ).createShader(Rect.fromLTWH(0, surfaceY - waveHeight, size.width, size.height - surfaceY + waveHeight));

    final Path wavePath2 = Path();
    wavePath2.moveTo(0, surfaceY);
    for (double x = 0; x <= size.width; x++) {
      double y = surfaceY + cos((waveAnimation * 2.0 * pi * 0.8) + (x * waveFrequency * 1.2)) * waveHeight * 0.8;
      wavePath2.lineTo(x, y);
    }
    wavePath2.lineTo(size.width, size.height);
    wavePath2.lineTo(0, size.height);
    wavePath2.close();

    final Paint wavePaint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF00B0FF).withValues(alpha: 0.4),
                const Color(0xFF0060FF).withValues(alpha: 0.6),
                const Color(0xFF0F172A).withValues(alpha: 0.85),
              ]
            : [
                const Color(0xFF42A5F5).withValues(alpha: 0.45),
                const Color(0xFF1565C0).withValues(alpha: 0.65),
                const Color(0xFF0D47A1).withValues(alpha: 0.85),
              ],
      ).createShader(Rect.fromLTWH(0, surfaceY - waveHeight, size.width, size.height - surfaceY + waveHeight));

    canvas.drawPath(wavePath2, wavePaint2);
    canvas.drawPath(wavePath1, wavePaint1);

    final Paint bubblePaint = Paint();
    for (var bubble in bubbles) {
      bubblePaint.color = Colors.white.withValues(alpha: bubble.opacity);
      canvas.drawCircle(
        Offset(bubble.x, bubble.y),
        bubble.size,
        bubblePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HomeWaveAndBubblePainter oldDelegate) => true;
}

class HomeStepTrackerCard extends StatefulWidget {
  const HomeStepTrackerCard({super.key});

  @override
  State<HomeStepTrackerCard> createState() => _HomeStepTrackerCardState();
}

class _HomeStepTrackerCardState extends State<HomeStepTrackerCard>
    with TickerProviderStateMixin {
  final ActivityController _controller = Get.find<ActivityController>();
  late AnimationController _stepLevelController;
  late Animation<double> _stepLevelAnimation;
  late AnimationController _bobController;
  late Worker _worker;

  double _animatedRatio = 0.0;
  final List<StepParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _stepLevelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    double currentVal = _controller.steps.value.toDouble();
    double targetVal = _controller.stepTarget.value > 0 ? _controller.stepTarget.value.toDouble() : 5000.0;
    double initialRatio = (currentVal / targetVal).clamp(0.0, 1.0);
    _animatedRatio = initialRatio;

    _stepLevelAnimation = Tween<double>(begin: initialRatio, end: initialRatio).animate(_stepLevelController);

    _bobController.addListener(() {
      setState(() {
        _updateParticles();
      });
    });

    _worker = ever(_controller.steps, (int val) {
      double targetVal = _controller.stepTarget.value > 0 ? _controller.stepTarget.value.toDouble() : 5000.0;
      double newRatio = (val.toDouble() / targetVal).clamp(0.0, 1.0);
      _animateToRatio(newRatio);
      _spawnBurst();
    });
  }

  void _animateToRatio(double targetRatio) {
    _stepLevelAnimation = Tween<double>(
      begin: _animatedRatio,
      end: targetRatio,
    ).animate(CurvedAnimation(
      parent: _stepLevelController,
      curve: Curves.easeOutBack,
    ));
    _stepLevelController.forward(from: 0.0);
  }

  void _stepLevelListener() {
    setState(() {
      _animatedRatio = _stepLevelAnimation.value;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stepLevelAnimation.addListener(_stepLevelListener);
  }

  @override
  void dispose() {
    _stepLevelAnimation.removeListener(_stepLevelListener);
    _stepLevelController.dispose();
    _bobController.dispose();
    _worker.dispose();
    super.dispose();
  }

  void _updateParticles() {
    for (int i = _particles.length - 1; i >= 0; i--) {
      var p = _particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.opacity -= 0.04;
      p.size *= 0.95;
      if (p.opacity <= 0 || p.size <= 0.5) {
        _particles.removeAt(i);
      }
    }
  }

  void _spawnBurst() {
    final r = Random();
    for (int i = 0; i < 15; i++) {
      double angle = r.nextDouble() * 2 * pi;
      double speed = r.nextDouble() * 2.0 + 1.0;
      _particles.add(StepParticle(
        x: 50.0,
        y: 50.0,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: r.nextDouble() * 4.0 + 2.0,
        opacity: 1.0,
        color: i % 2 == 0 ? const Color(0xFFCC8FED) : const Color(0xFF6B50F6),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        final mainController = Get.find<MainScreenController>();
        mainController.setTab(1);
        Get.find<TargetTabController>().changeTab(0);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: HomeStepPainter(
                      ratio: _animatedRatio,
                      particles: _particles,
                      isDark: isDark,
                      primaryColor: Theme.of(context).colorScheme.primary,
                      secondaryColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _bobController,
                  builder: (context, child) {
                    double offset = _bobController.value * -6.0;
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: Icon(
                        Icons.directions_walk_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Vũ Điệu Bước Chân',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDark ? Colors.white : const Color(0xFF1D1517),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '✨',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    int cur = _controller.steps.value;
                    int trg = _controller.stepTarget.value > 0 ? _controller.stepTarget.value : 5000;
                    int pct = ((cur / trg) * 100).round().clamp(0, 999);
                    return Text(
                      'Đạt $pct% ($cur / $trg bước)',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFADA4A5) : const Color(0xFF7B6F72),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() {
                    double dist = _controller.distance.value / 1000.0;
                    double kcal = _controller.calories.value;
                    return Text(
                      '🔥 ${kcal.toStringAsFixed(0)} kcal   📍 ${dist.toStringAsFixed(2)} km',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double opacity;
  Color color;

  StepParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

class HomeStepPainter extends CustomPainter {
  final double ratio;
  final List<StepParticle> particles;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  HomeStepPainter({
    required this.ratio,
    required this.particles,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * ratio,
      false,
      progressPaint,
    );

    const int totalFootprints = 10;
    for (int i = 0; i < totalFootprints; i++) {
      double stepRatio = i / totalFootprints;
      double angle = stepRatio * 2 * pi - pi / 2;
      Offset footPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      bool isActive = stepRatio <= ratio;
      Color footColor;
      if (isActive) {
        footColor = Color.lerp(primaryColor, secondaryColor, stepRatio) ?? primaryColor;
      } else {
        footColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300;
      }

      bool isLeft = i % 2 == 0;
      _drawFootprint(canvas, footPos, angle, isLeft, footColor);
    }

    final pPaint = Paint();
    for (var p in particles) {
      pPaint.color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.size, pPaint);
    }
  }

  void _drawFootprint(Canvas canvas, Offset pos, double angle, bool isLeft, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle + pi / 2);

    double sideOffset = isLeft ? -1.5 : 1.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(sideOffset, 2),
        width: 3.5,
        height: 5.5,
      ),
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(sideOffset * 0.9, -2),
        width: 4.5,
        height: 5,
      ),
      paint,
    );

    canvas.drawCircle(Offset(sideOffset * 0.5, -5.5), 1.0, paint);
    canvas.drawCircle(Offset(sideOffset * 1.0, -5.2), 0.8, paint);
    canvas.drawCircle(Offset(sideOffset * 1.4, -4.8), 0.7, paint);
    canvas.drawCircle(Offset(sideOffset * 1.8, -4.2), 0.6, paint);
    canvas.drawCircle(Offset(sideOffset * 2.2, -3.6), 0.5, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HomeStepPainter oldDelegate) => true;
}

class HomeSleepTrackerCard extends StatefulWidget {
  const HomeSleepTrackerCard({super.key});

  @override
  State<HomeSleepTrackerCard> createState() => _HomeSleepTrackerCardState();
}

class _HomeSleepTrackerCardState extends State<HomeSleepTrackerCard>
    with TickerProviderStateMixin {
  final SleepController _controller = Get.find<SleepController>();
  late AnimationController _starsController;
  late AnimationController _moonController;

  final List<SleepStar> _stars = [];
  final List<SleepZ> _zzzs = [];

  @override
  void initState() {
    super.initState();

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final r = Random();
    for (int i = 0; i < 30; i++) {
      _stars.add(SleepStar(
        x: r.nextDouble(),
        y: r.nextDouble(),
        size: r.nextDouble() * 2.0 + 0.6,
        baseOpacity: r.nextDouble() * 0.4 + 0.2,
        phase: r.nextDouble() * pi * 2,
      ));
    }

    _starsController.addListener(() {
      setState(() {
        if (_controller.isTracking.value) {
          _updateZzzs();
        }
      });
    });
  }

  @override
  void dispose() {
    _starsController.dispose();
    _moonController.dispose();
    super.dispose();
  }

  void _updateZzzs() {
    final r = Random();
    for (int i = _zzzs.length - 1; i >= 0; i--) {
      var z = _zzzs[i];
      z.y -= z.speed;
      z.x += sin(z.y * 0.05) * 0.4;
      z.opacity -= 0.015;
      if (z.opacity <= 0) {
        _zzzs.removeAt(i);
      }
    }

    if (_zzzs.length < 6 && r.nextDouble() < 0.06) {
      _zzzs.add(SleepZ(
        x: 50 + r.nextDouble() * 30,
        y: 75,
        speed: r.nextDouble() * 0.7 + 0.3,
        size: r.nextDouble() * 6 + 10,
        opacity: 1.0,
        text: r.nextBool() ? 'z' : 'Z',
      ));
    }
  }

  void _hienThiPopupCamXuc(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Sáng nay dậy thấy thế nào?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text('😁', style: TextStyle(fontSize: 24)),
                title: Text(
                  'Tươi tỉnh',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _controller.stopTracking('Tươi tỉnh');
                },
              ),
              ListTile(
                leading: Text('😐', style: TextStyle(fontSize: 24)),
                title: Text(
                  'Bình thường',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _controller.stopTracking('Bình thường');
                },
              ),
              ListTile(
                leading: Text('😫', style: TextStyle(fontSize: 24)),
                title: Text(
                  'Mệt mỏi',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _controller.stopTracking('Mệt mỏi');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isTracking = _controller.isTracking.value;
      return Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
              Color(0xFF0F172A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: HomeSleepPainter(
                    stars: _stars,
                    zzzs: _zzzs,
                    animationValue: _starsController.value,
                    moonScale: 1.0 + (_moonController.value * 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const SizedBox(width: 80),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isTracking ? 'Đang Ngủ Say...' : 'Vũ Trụ Giấc Ngủ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isTracking ? '😴' : '🌌',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (isTracking) ...[
                            Text(
                              _controller.trackingDuration.value,
                              style: const TextStyle(
                                fontSize: 24,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFF59D),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Chúc ngủ ngon nhen, ${_controller.userName}! 💤',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontFamily: 'Poppins',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ] else ...[
                            Text(
                              _controller.nextSleepCountdown.value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Giấc ngủ đêm qua: ${_controller.lastNightSleep.value.toStringAsFixed(1)}h',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFF59D),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (isTracking) {
                              _hienThiPopupCamXuc(context);
                            } else {
                              _controller.startTracking();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTracking ? Colors.redAccent : const Color(0xFF6B50F6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isTracking ? 'Thức dậy' : 'Đi ngủ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        if (!isTracking) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              final mainController = Get.find<MainScreenController>();
                              mainController.setTab(1);
                              Get.find<TargetTabController>().changeTab(2);
                            },
                            child: const Text(
                              'Chi tiết',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white70,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class SleepStar {
  double x;
  double y;
  double size;
  double baseOpacity;
  double phase;

  SleepStar({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.phase,
  });
}

class SleepZ {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  String text;

  SleepZ({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.text,
  });
}

class HomeSleepPainter extends CustomPainter {
  final List<SleepStar> stars;
  final List<SleepZ> zzzs;
  final double animationValue;
  final double moonScale;

  HomeSleepPainter({
    required this.stars,
    required this.zzzs,
    required this.animationValue,
    required this.moonScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint starPaint = Paint();
    for (var star in stars) {
      double currentOpacity = star.baseOpacity + sin(star.phase + animationValue * 2 * pi) * 0.15;
      currentOpacity = currentOpacity.clamp(0.05, 1.0);
      starPaint.color = Colors.white.withValues(alpha: currentOpacity);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        starPaint,
      );
    }

    final double moonRadius = 24.0;
    final Offset moonCenter = Offset(50, size.height / 2);

    final glowPaint = Paint()
      ..color = const Color(0xFFFFFDE7).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(moonCenter, moonRadius * moonScale * 1.5, glowPaint);

    final Path path1 = Path()..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius * moonScale));
    final Path path2 = Path()..addOval(Rect.fromCircle(center: Offset(moonCenter.dx - moonRadius * moonScale * 0.42, moonCenter.dy), radius: moonRadius * moonScale * 0.98));
    final Path moonPath = Path.combine(PathOperation.difference, path1, path2);

    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFDE7), Color(0xFFFBC02D)],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius * moonScale));

    canvas.drawPath(moonPath, moonPaint);

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var z in zzzs) {
      textPainter.text = TextSpan(
        text: z.text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: z.opacity),
          fontSize: z.size,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(z.x, z.y));
    }
  }

  @override
  bool shouldRepaint(covariant HomeSleepPainter oldDelegate) => true;
}
