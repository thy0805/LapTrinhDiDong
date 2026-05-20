import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/main/target/other/controllers/target_controller.dart';

class OtherTargetTab extends StatefulWidget {
  const OtherTargetTab({super.key});

  @override
  State<OtherTargetTab> createState() => _OtherTargetTabState();
}

class _OtherTargetTabState extends State<OtherTargetTab> {
  final TargetController controller = Get.find<TargetController>();
  late TextEditingController _waterController;
  late TextEditingController _stepController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _waterController = TextEditingController(text: controller.getTargetValue('water'));
    _stepController = TextEditingController(text: controller.getTargetValue('steps'));
    _weightController = TextEditingController(text: controller.getTargetValue('target_weight'));
  }

  @override
  void dispose() {
    _waterController.dispose();
    _stepController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'id': 'water', 'title': 'Mục tiêu Lượng nước', 'unit': 'Lít', 'icon': Icons.local_drink, 'color': Color(0xFF00EFFF)},
      {'id': 'steps', 'title': 'Mục tiêu Bước chân', 'unit': 'Bước', 'icon': Icons.directions_walk, 'color': Get.theme.colorScheme.primary},
      {'id': 'target_weight', 'title': 'Cân nặng mục tiêu', 'unit': 'Kg', 'icon': Icons.monitor_weight, 'color': Colors.amber},
      {'id': 'calories', 'title': 'Mục tiêu Calo', 'unit': 'Kcal', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'id': 'distance', 'title': 'Quãng đường', 'unit': 'Km', 'icon': Icons.map, 'color': Colors.blue},
      {'id': 'heart', 'title': 'Nhịp tim', 'unit': 'BPM', 'icon': Icons.favorite, 'color': Colors.redAccent},
      {'id': 'move_minutes', 'title': 'TG Vận động', 'unit': 'Phút', 'icon': Icons.timer, 'color': Colors.green},
    ];

    return Obx(() => SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: _taoItemDatMucTieu(
                  icon: item['icon'] as IconData,
                  title: item['title'] as String,
                  unit: item['unit'] as String,
                  tenMucTieu: item['id'] as String,
                  mauChuDao: item['color'] as Color,
                ),
              )),
          SizedBox(height: 15),
          Text(
            '* Kcal sẽ được tự động tính toán dựa trên số bước chân bạn hoàn thành so với mục tiêu này.',
            style: TextStyle(color: Color(0xFFA5A3AF), fontSize: 11, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          )
        ],
      )),
    );
  }

  Widget _taoItemDatMucTieu({
    required IconData icon,
    required String title,
    required String unit,
    required String tenMucTieu,
    required Color mauChuDao,
  }) {
    bool isSwitched = controller.getStatus(tenMucTieu);
    TextEditingController textController;
    if (tenMucTieu == 'water') {
      textController = _waterController;
    } else if (tenMucTieu == 'steps') {
      textController = _stepController;
    } else if (tenMucTieu == 'target_weight') {
      textController = _weightController;
    } else {
      textController = TextEditingController(text: controller.getTargetValue(tenMucTieu));
    }

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.2) : Color(0x111D1617),
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mauChuDao.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: mauChuDao),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1D1517),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) => controller.updateStatus(tenMucTieu, value),
                activeThumbColor: Colors.white,
                activeTrackColor: mauChuDao,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
              ),
            ],
          ),
          if (isSwitched) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Color(0xFFF7F8F8),
                thickness: 1,
              ),
            ),
            Row(
              children: [
                Icon(Icons.track_changes, size: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF)),
                SizedBox(width: 8),
                Text(
                  'Mục tiêu:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFFA5A3AF),
                    fontFamily: 'Poppins',
                  ),
                ),
                Spacer(),
                Container(
                  width: 80,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E293B) : Color(0xFFF7F8F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: mauChuDao,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      controller.updateTargetValue(tenMucTieu, value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Color(0xFF7B6F72),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}

