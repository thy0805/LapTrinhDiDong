import 'package:get/get.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';

class HomeController extends GetxController {
  final AuthController auth = Get.find<AuthController>();
  final SleepController sleep = Get.find<SleepController>();
  final ActivityController activity = Get.find<ActivityController>();
  final NutritionController nutrition = Get.find<NutritionController>();

  String get userName => auth.userName;
  String get userPronoun => auth.userPronoun;
  int get streak => activity.streakCount.value;
  String get suggestion => activity.smartSuggestion.value;

  Future<void> manualSync() async {
    await activity.manualSync();
  }
}
