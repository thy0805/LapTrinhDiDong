import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';

class TargetController extends GetxController {
  final ActivityController _activityController = Get.find<ActivityController>();
  final AuthController _authController = Get.find<AuthController>();

  var targets = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    initTargets();
  }

  void initTargets({List<Map<String, dynamic>>? existingTargets}) {
    if (existingTargets != null) {
      targets.value = List<Map<String, dynamic>>.from(
          existingTargets.map((item) => Map<String, dynamic>.from(item)));
    } else {
      targets.value = [
        {
          'id': 'water',
          'icon': Icons.local_drink,
          'ten': 'Lượng nước',
          'active': true,
          'mucTieu': _activityController.waterTarget.value.toString()
        },
        {
          'id': 'steps',
          'icon': Icons.directions_walk,
          'ten': 'Bước chân',
          'active': true,
          'mucTieu': _activityController.stepTarget.value.toString()
        },
        {
          'id': 'target_weight',
          'icon': Icons.monitor_weight,
          'ten': 'Cân nặng mục tiêu',
          'active': true,
          'mucTieu': _authController.userData['targetWeight']?.toString() ?? ''
        },
        {
          'id': 'calories',
          'icon': Icons.local_fire_department,
          'ten': 'Calo tiêu thụ',
          'active': true,
          'mucTieu': _activityController.calorieTarget.value.toString()
        },
        {
          'id': 'distance',
          'icon': Icons.map,
          'ten': 'Quãng đường',
          'active': true,
          'mucTieu': ''
        },
        {
          'id': 'heart',
          'icon': Icons.favorite,
          'ten': 'Nhịp tim',
          'active': false,
          'mucTieu': ''
        },
        {
          'id': 'move_minutes',
          'icon': Icons.timer,
          'ten': 'TG Vận động',
          'active': false,
          'mucTieu': ''
        },
      ];
    }
  }

  void updateStatus(String id, bool newValue) {
    final index = targets.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      targets[index]['active'] = newValue;
      targets.refresh();
      saveToControllers();
    }
  }

  bool getStatus(String id) {
    final item = targets.firstWhere(
      (item) => item['id'] == id,
      orElse: () => {'active': false},
    );
    return item['active'] as bool;
  }

  void updateTargetValue(String id, String newValue) {
    final index = targets.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      targets[index]['mucTieu'] = newValue;
      targets.refresh();
      saveToControllers();
    }
  }

  String getTargetValue(String id) {
    final item = targets.firstWhere(
      (item) => item['id'] == id,
      orElse: () => {'mucTieu': ''},
    );
    return item['mucTieu']?.toString() ?? '';
  }

  void saveToControllers() {
    final stepsItem =
        targets.firstWhere((e) => e['id'] == 'steps', orElse: () => {});
    final waterItem =
        targets.firstWhere((e) => e['id'] == 'water', orElse: () => {});
    final calorieItem =
        targets.firstWhere((e) => e['id'] == 'calories', orElse: () => {});

    if (stepsItem.isNotEmpty && stepsItem['mucTieu'] != null) {
      _activityController.updateTargets(
        newStepTarget: int.tryParse(stepsItem['mucTieu'].toString()),
      );
    }
    if (waterItem.isNotEmpty && waterItem['mucTieu'] != null) {
      _activityController.updateTargets(
        newWaterTarget: double.tryParse(waterItem['mucTieu'].toString()),
      );
    }
    if (calorieItem.isNotEmpty && calorieItem['mucTieu'] != null) {
      _activityController.updateTargets(
        newCalorieTarget: int.tryParse(calorieItem['mucTieu'].toString()),
      );
    }

    final weightItem =
        targets.firstWhere((e) => e['id'] == 'target_weight', orElse: () => {});
    if (weightItem.isNotEmpty && weightItem['mucTieu'] != null) {
      String uid = _authController.auth.currentUser!.uid;
      _authController.firestore.collection('users').doc(uid).update(
          {'targetWeight': weightItem['mucTieu'].toString()});
    }
  }
}
