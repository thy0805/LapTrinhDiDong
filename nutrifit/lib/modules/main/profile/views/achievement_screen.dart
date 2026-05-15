import 'package:flutter/material.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Thành tích & Huy hiệu', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
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
            _buildLevelCard(theme),
            const SizedBox(height: 30),
            Text('Huy hiệu đã đạt được', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.8,
              children: [
                _buildBadgeItem('Người mới', Icons.emoji_emotions_outlined, true, theme),
                _buildBadgeItem('Chăm chỉ', Icons.local_fire_department_outlined, true, theme),
                _buildBadgeItem('Kình ngư', Icons.waves_outlined, true, theme),
                _buildBadgeItem('Lực sĩ', Icons.fitness_center_outlined, false, theme),
                _buildBadgeItem('Đúng giờ', Icons.bedtime_outlined, false, theme),
                _buildBadgeItem('Chuyên gia', Icons.workspace_premium_outlined, false, theme),
              ],
            ),
            const SizedBox(height: 30),
            Text('Nhiệm vụ hàng ngày', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 15),
            _buildQuestItem('Uống 2L nước', 0.7, '1.4/2.0 L', Icons.water_drop_outlined, Colors.blue, theme),
            _buildQuestItem('Đi bộ 5000 bước', 0.4, '2000/5000', Icons.directions_walk_outlined, Colors.orange, theme),
            _buildQuestItem('Hoàn thành bài tập', 1.0, '1/1', Icons.check_circle_outline, Colors.green, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(ThemeData theme) {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cấp độ 12', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Còn 250 XP để lên cấp 13', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.75,
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
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isUnlocked ? (isDark ? const Color(0xFF2C2C2E) : Colors.white) : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200),
            shape: BoxShape.circle,
            boxShadow: isUnlocked && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)] : null,
          ),
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.3,
            child: Icon(iconData, size: 40, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUnlocked ? (isDark ? Colors.white : Colors.black) : Colors.grey)),
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
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
              Text(trailing, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
