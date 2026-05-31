import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityController controller = Get.find<ActivityController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    controller.fetchHistory();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Lịch sử hoạt động', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoadingHistory.value) {
          return Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.primary));
        }

        if (controller.activityHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: isDark ? Colors.white24 : Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Chưa có lịch sử hoạt động nào nhen!', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.activityHistory.length,
          itemBuilder: (context, index) {
            var activity = controller.activityHistory[index];
            return _buildHistoryItem(activity, isDark);
          },
        );
      }),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> activity, bool isDark) {
    String dateStr = activity['id'] ?? 'Không rõ';
    if (dateStr.contains('-')) {
      DateTime? dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        dateStr = DateFormat('dd/MM/yyyy').format(dt);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: TextStyle(fontWeight: FontWeight.bold, color: Get.theme.colorScheme.primary)),
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
            ],
          ),
          const Divider(height: 30),
          _buildStatRow(Icons.directions_walk, 'Bước chân', '${activity['steps'] ?? 0} bước', Colors.orange, isDark),
          const SizedBox(height: 12),
          _buildStatRow(Icons.local_fire_department, 'Calo tiêu thụ', '${(activity['calories'] ?? 0.0).toStringAsFixed(0)} kcal', Colors.redAccent, isDark),
          const SizedBox(height: 12),
          _buildStatRow(Icons.water_drop, 'Nước uống', '${(activity['water'] ?? 0.0).toStringAsFixed(1)} L', Colors.blue, isDark),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 15),
        Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }
}
