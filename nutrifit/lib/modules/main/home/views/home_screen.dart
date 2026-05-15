import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/sleep/views/sleep_tracker_screen.dart';
import 'package:nutrifit/modules/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/target/views/target_settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final SleepController sleepController = Get.find<SleepController>();
    final ActivityController activityController =
        Get.find<ActivityController>();
    final NutritionController nutritionController =
        Get.find<NutritionController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(authController, activityController),
              const SizedBox(height: 20),
              Obx(
                () => _buildSmartSuggestion(
                  activityController.smartSuggestion.value,
                ),
              ),
              const SizedBox(height: 25),
              Obx(() => _buildTodayGoals(activityController, sleepController)),
              const SizedBox(height: 25),
              Obx(() => _buildActivityOverview(activityController, nutritionController)),
              const SizedBox(height: 25),
              Obx(() {
                double weight =
                    double.tryParse(authController.userData['weight'] ?? '0') ??
                    0;
                double height =
                    double.tryParse(authController.userData['height'] ?? '0') ??
                    0;
                double bmi = 0;
                String status = "Chưa có dữ liệu";
                if (height > 0 && weight > 0) {
                  bmi = weight / ((height / 100) * (height / 100));
                  status = bmi < 18.5
                      ? "Bạn hơi gầy đó nha"
                      : (bmi < 24.9
                            ? "Cân nặng của bạn rất chuẩn"
                            : "Cần chú ý cân nặng nhé");
                }
                return _buildBMICard(bmi.toStringAsFixed(1), status);
              }),
              const SizedBox(height: 25),
              _buildProgressChart(activityController),
              const SizedBox(height: 25),
              Obx(() => _buildNextSleepBanner(sleepController)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(AuthController auth, ActivityController activity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng trở lại,',
                style: TextStyle(
                  color: Color(0xFFA5A3AF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userData['fullName'] ?? 'Người dùng',
                          style: const TextStyle(
                            color: Color(0xFF1D1517),
                            fontSize: 22,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC050F6).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Lv. 12', style: TextStyle(color: Color(0xFFC050F6), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text('750 / 1000 XP', style: TextStyle(color: Color(0xFFA5A3AF), fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    if (activity.streakCount.value > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '🔥 ${activity.streakCount.value}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildHeaderMenu(),
      ],
    );
  }

  Widget _buildHeaderMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_horiz, size: 16, color: Color(0xFF1D1517)),
      ),
      onSelected: (value) {
        if (value == 'notifications') {
          // Navigate to notifications
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'notifications',
          child: Row(
            children: [
              Icon(
                Icons.notifications_none,
                size: 20,
                color: Color(0xFF1D1517),
              ),
              SizedBox(width: 10),
              Text(
                'Thông báo',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSuggestion(String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFC050F6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFC050F6).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFC050F6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayGoals(ActivityController activity, SleepController sleep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mục tiêu hôm nay',
              style: TextStyle(
                color: Color(0xFF1D1517),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const TargetSettingsScreen()),
              child: const Icon(
                Icons.settings_outlined,
                color: Color(0xFFA5A3AF),
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildGoalCircle(
                'Bước chân',
                activity.steps.value,
                activity.stepTarget.value,
                Icons.directions_walk,
                const [Color(0xFFC050F6), Color(0xFFEEA4CE)],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildGoalCircle(
                'Nước',
                activity.water.value,
                activity.waterTarget.value,
                Icons.local_drink,
                const [Color(0xFF00FF66), Color(0xFF00EFFF)],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildGoalCircle(
                'Giấc ngủ',
                sleep.lastNightSleep.value,
                sleep.targetSleepHours.value,
                Icons.bedtime,
                const [Color(0xFFCC8FED), Color(0xFF6B50F6)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalCircle(
    String title,
    num current,
    num target,
    IconData icon,
    List<Color> colors,
  ) {
    double progress = target > 0 ? (current / target).toDouble() : 0;
    progress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(colors[0]),
                ),
              ),
              Icon(icon, color: colors[0], size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1D1517),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${current is double ? current.toStringAsFixed(1) : current}',
            style: TextStyle(
              color: colors[0],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOverview(
    ActivityController activity,
    NutritionController nutrition,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhật ký hoạt động',
          style: TextStyle(
            color: Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 15),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 2.2,
          ),
          children: [
            _buildSmallStatCard(
              'Calo nạp',
              '${nutrition.totalCaloriesIntake.toInt()}',
              'kcal',
              Icons.fastfood_outlined,
              Colors.orange,
            ),
            _buildSmallStatCard(
              'Calo tiêu',
              '${activity.calories.value.toInt()}',
              'kcal',
              Icons.local_fire_department_outlined,
              Colors.redAccent,
            ),
            _buildSmallStatCard(
              'Quãng đường',
              (activity.distance.value / 1000).toStringAsFixed(1),
              'km',
              Icons.map_outlined,
              Colors.blue,
            ),
            _buildSmallStatCard(
              'Vận động',
              '${activity.moveMinutes.value}',
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
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
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
                      style: const TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: const TextStyle(
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

  Widget _buildBMICard(String score, String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC050F6).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chỉ số BMI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
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
          const SizedBox(width: 15),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(ActivityController activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiến độ hoạt động',
          style: TextStyle(
            color: Color(0xFF1D1517),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Obx(
            () => BarChart(
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
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Color(0xFFB6B4C1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Text('CN', style: style);
                          case 1:
                            return const Text('T2', style: style);
                          case 2:
                            return const Text('T3', style: style);
                          case 3:
                            return const Text('T4', style: style);
                          case 4:
                            return const Text('T5', style: style);
                          case 5:
                            return const Text('T6', style: style);
                          case 6:
                            return const Text('T7', style: style);
                          default:
                            return const Text('', style: style);
                        }
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  7,
                  (i) => _buildBarGroup(i, activity.weeklyScores[i]),
                ),
              ),
            ),
          ),
        ),
        Obx(() => IconButton(
          onPressed: activity.isSyncing.value ? null : () => activity.manualSync(),
          icon: activity.isSyncing.value 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC050F6)))
            : const Icon(Icons.sync_rounded, color: Color(0xFFC050F6)),
          tooltip: 'Đồng bộ dữ liệu Health',
        )),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xFFC050F6), Color(0xFFEEA4CE)],
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

  Widget _buildNextSleepBanner(SleepController controller) {
    bool isTracking = controller.isTracking.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isTracking
            ? const Color(0xFFEEA4CE)
            : const Color(0xFFC050F6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(
            isTracking ? Icons.bedtime : Icons.access_time_filled,
            color: isTracking ? Colors.white : const Color(0xFFC050F6),
            size: 28,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTracking ? 'Đang theo dõi giấc ngủ' : 'Lịch ngủ tiếp theo',
                  style: TextStyle(
                    color: isTracking ? Colors.white : const Color(0xFF1D1517),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isTracking
                      ? controller.trackingDuration.value
                      : controller.nextSleepCountdown.value,
                  style: TextStyle(
                    color: isTracking
                        ? Colors.white.withValues(alpha: 0.8)
                        : const Color(0xFF7B6F72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.to(() => const SleepTrackerScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCC8FED), Color(0xFF6B50F6)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'Chi tiết',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
