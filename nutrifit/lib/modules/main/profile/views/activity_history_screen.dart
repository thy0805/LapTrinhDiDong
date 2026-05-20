import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityController controller = Get.find<ActivityController>();
    
    controller.fetchHistory();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Lịch sử hoạt động', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                SizedBox(height: 16),
                Text('Chưa có lịch sử hoạt động nào nhen!', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20),
          itemCount: controller.activityHistory.length,
          itemBuilder: (context, index) {
            var activity = controller.activityHistory[index];
            return _buildHistoryItem(activity);
          },
        );
      }),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> activity) {
    String dateStr = activity['id'] ?? 'Không rõ';
    if (dateStr.contains('-')) {
      DateTime? dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        dateStr = DateFormat('dd/MM/yyyy').format(dt);
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
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
              Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
            ],
          ),
          Divider(height: 30),
          _buildStatRow(Icons.directions_walk, 'Bước chân', '${activity['steps'] ?? 0} bước', Colors.orange),
          SizedBox(height: 12),
          _buildStatRow(Icons.local_fire_department, 'Calo tiêu thụ', '${(activity['calories'] ?? 0.0).toStringAsFixed(0)} kcal', Colors.redAccent),
          SizedBox(height: 12),
          _buildStatRow(Icons.water_drop, 'Nước uống', '${(activity['water'] ?? 0.0).toStringAsFixed(1)} L', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 15),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
        Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
