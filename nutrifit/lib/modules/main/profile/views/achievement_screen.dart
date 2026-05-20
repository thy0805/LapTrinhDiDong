import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/core/services/gamification_service.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final AuthController auth = Get.find<AuthController>();
    final GamificationService gamification = Get.find<GamificationService>();
    final ActivityController activity = Get.find<ActivityController>();
    
    final int exp = auth.userData['exp'] ?? 0;
    final int level = gamification.getLevel(exp);
    final String title = gamification.getTitle(level);
    
    final double waterVal = activity.water.value;
    final double waterTarget = activity.waterTarget.value;
    final double stepsVal = activity.steps.value.toDouble();
    final double stepsTarget = activity.stepTarget.value.toDouble();
    
    final range = gamification.getExpRangeForLevel(level);
    int nextLevelExp = range['max']!;
    int currentLevelBaseExp = range['min']!;

    final int expToNext = nextLevelExp - exp;
    final double progress = (nextLevelExp - currentLevelBaseExp) > 0 
        ? (exp - currentLevelBaseExp) / (nextLevelExp - currentLevelBaseExp) 
        : 1.0;
    final displayExpToNext = expToNext > 0 ? expToNext : 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Thành tích & Huy hiệu', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins')),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLevelCard(theme, level, title, displayExpToNext, progress.clamp(0.0, 1.0)),
            const SizedBox(height: 30),
            
            _buildCategoryHeader('Vận Động', isDark),
            _buildBadgeGrid([
              _BadgeData('Tân binh', Icons.stars, 'starter'),
              _BadgeData('Kẻ Lữ Hành', Icons.map, 'million_steps'),
              _BadgeData('Tốc Biến', Icons.bolt, 'noon_sprinter'),
              _BadgeData('Chiến Thần', Icons.local_fire_department, 'burn_500'),
            ], auth.userData['achievements'] ?? {}, theme),

            const SizedBox(height: 25),
            _buildCategoryHeader('Dinh Dưỡng', isDark),
            _buildBadgeGrid([
              _BadgeData('Thủy Thần', Icons.water_drop, 'water_god'),
              _BadgeData('Giả Kim', Icons.psychology, 'calorie_master'),
              _BadgeData('Healthy', Icons.eco, 'healthy_eater'),
            ], auth.userData['achievements'] ?? {}, theme),

            const SizedBox(height: 25),
            _buildCategoryHeader('Kỷ Luật', isDark),
            _buildBadgeGrid([
              _BadgeData('Chinh Phục', Icons.emoji_events, 'reached_target_weight'),
              _BadgeData('Perfect Day', Icons.check_circle, 'perfect_day'),
              _BadgeData('Kiến Tạo', Icons.auto_awesome, 'created_comparison'),
              _BadgeData('Lực Sĩ', Icons.fitness_center, 'workout_warrior'),
            ], auth.userData['achievements'] ?? {}, theme),

            const SizedBox(height: 25),
            Obx(() {
               final ach = auth.userData['achievements'] ?? {};
               bool hasHidden = ach['midnight_owl'] == true || ach['early_bird_special'] == true || ach['overachiever_extreme'] == true || ach['desert_mode'] == true;
               if (!hasHidden) return const SizedBox.shrink();
               
               return Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    _buildCategoryHeader('Thành Tựu Ẩn', isDark),
                    _buildBadgeGrid([
                      if (ach['midnight_owl'] == true) _BadgeData('Cú Đêm', Icons.nights_stay, 'midnight_owl'),
                      if (ach['early_bird_special'] == true) _BadgeData('Bình Minh', Icons.wb_sunny, 'early_bird_special'),
                      if (ach['overachiever_extreme'] == true) _BadgeData('Quá Sức', Icons.warning_amber, 'overachiever_extreme'),
                      if (ach['desert_mode'] == true) _BadgeData('Sa Mạc', Icons.wb_cloudy, 'desert_mode'),
                    ], ach, theme),
                    const SizedBox(height: 25),
                 ],
               );
            }),

            Text('Nhiệm vụ hàng ngày', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins')),
            const SizedBox(height: 15),
            Obx(() => Column(
              children: [
                _buildQuestItem(
                  'Uống ${waterTarget.toStringAsFixed(1)}L nước', 
                  waterTarget > 0 ? waterVal / waterTarget : 0, 
                  '${waterVal.toStringAsFixed(1)}/${waterTarget.toStringAsFixed(1)} L', 
                  Icons.water_drop_outlined, 
                  Colors.blue, 
                  theme
                ),
                _buildQuestItem(
                  'Đi bộ ${stepsTarget.toInt()} bước', 
                  stepsTarget > 0 ? stepsVal / stepsTarget : 0, 
                  '${stepsVal.toInt()}/${stepsTarget.toInt()}', 
                  Icons.directions_walk_outlined, 
                  Colors.orange, 
                  theme
                ),
                _buildQuestItem(
                  'Hoàn thành lịch tập', 
                  activity.completionScore.value / 10, 
                  '${activity.completionScore.value.toInt()}/10', 
                  Icons.check_circle_outline, 
                  Colors.green, 
                  theme
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins')),
    );
  }

  Widget _buildBadgeGrid(List<_BadgeData> badges, Map ach, ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final b = badges[index];
        bool isUnlocked = b.key == 'starter' || ach[b.key] == true;
        return GestureDetector(
          onTap: () => _showBadgeDetail(context, b, isUnlocked, theme),
          child: _buildBadgeItem(b.name, b.icon, isUnlocked, theme),
        );
      },
    );
  }

  void _showBadgeDetail(BuildContext context, _BadgeData badge, bool isUnlocked, ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badge.icon, size: 80, color: isUnlocked ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(height: 20),
            Text(badge.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 15),
            Text(
              isUnlocked ? 'Bạn đã mở khóa thành tựu này! Quá tuyệt vời!' : 'Thành tựu này vẫn còn là một bí ẩn... Hãy tiếp tục rèn luyện để khám phá nhé!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('ĐÓNG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(ThemeData theme, int level, String title, int expToNext, double progress) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level $level: $title', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    Text(expToNext > 0 ? 'Còn $expToNext XP để lên cấp kế tiếp' : 'Đã đạt cấp tối đa!', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String name, IconData iconData, bool isUnlocked, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked ? (isDark ? const Color(0xFF2C2C2E) : Colors.white) : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200),
            shape: BoxShape.circle,
            boxShadow: isUnlocked && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)] : null,
          ),
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.3,
            child: Icon(iconData, size: 30, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, 
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isUnlocked ? (isDark ? Colors.white : Colors.black) : Colors.grey, fontFamily: 'Poppins')
        ),
      ],
    );
  }

  Widget _buildQuestItem(String title, double progress, String trailing, IconData iconData, Color iconColor, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = progress >= 1.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCompleted ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted ? theme.colorScheme.primary.withValues(alpha: 0.1) : iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconData, size: 20, color: isCompleted ? theme.colorScheme.primary : iconColor),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black, fontFamily: 'Poppins')),
                ],
              ),
              Text(trailing, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF3C3C3E) : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? theme.colorScheme.primary : iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final String name;
  final IconData icon;
  final String key;
  _BadgeData(this.name, this.icon, this.key);
}
