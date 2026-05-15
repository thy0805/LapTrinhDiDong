import 'package:flutter/material.dart';

class OtherTargetTab extends StatefulWidget {
  final bool Function(String) getStatus;
  final void Function(String, bool) updateStatus;
  final String Function(String)? getTarget;
  final void Function(String, String)? updateTarget;

  const OtherTargetTab({
    super.key,
    required this.getStatus,
    required this.updateStatus,
    this.getTarget,
    this.updateTarget,
  });

  @override
  State<OtherTargetTab> createState() => _OtherTargetTabState();
}

class _OtherTargetTabState extends State<OtherTargetTab> {
  late TextEditingController _waterController;
  late TextEditingController _stepController;

  @override
  void initState() {
    super.initState();
    _waterController = TextEditingController(text: widget.getTarget?.call('Lượng nước') ?? '8');
    _stepController = TextEditingController(text: widget.getTarget?.call('Bước chân') ?? '2400');
  }

  @override
  void dispose() {
    _waterController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _taoItemDatMucTieu(
            icon: Icons.local_drink,
            title: 'Mục tiêu Lượng nước',
            controller: _waterController,
            unit: 'Lít',
            tenMucTieu: 'Lượng nước',
          ),
          const SizedBox(height: 15),
          _taoItemDatMucTieu(
            icon: Icons.directions_walk,
            title: 'Mục tiêu Bước chân',
            controller: _stepController,
            unit: 'Bước',
            tenMucTieu: 'Bước chân',
          ),
          const SizedBox(height: 30),
          const Text(
            '* Kcal sẽ được tự động tính toán dựa trên số bước chân bạn hoàn thành so với mục tiêu này.',
            style: TextStyle(color: Color(0xFFA5A3AF), fontSize: 11, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  Widget _taoItemDatMucTieu({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String unit,
    required String tenMucTieu,
  }) {
    bool isSwitched = widget.getStatus(tenMucTieu);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x111D1617), blurRadius: 40, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00EFFF).withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: const Color(0xFF00EFFF)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Color(0xFF1D1517), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: isSwitched,
                onChanged: (value) => widget.updateStatus(tenMucTieu, value),
                activeTrackColor: const Color(0xFFC050F6),
              ),
            ],
          ),
          if (isSwitched) ...[
            const Divider(height: 25),
            Row(
              children: [
                const Text('Mục tiêu:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  height: 35,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) {
                      if (widget.updateTarget != null) {
                        widget.updateTarget!(tenMucTieu, value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Text(unit, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
