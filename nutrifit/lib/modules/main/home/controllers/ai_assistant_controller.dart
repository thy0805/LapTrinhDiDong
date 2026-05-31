import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:hive/hive.dart';
import 'package:nutrifit/core/services/mail_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';


class AiAssistantController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isPredicting = false.obs;
  var isContextLoaded = false.obs;
  var isConfirmingPlan = false.obs;
  var selectedModel = "fast".obs;
  final String baseUrl = "https://nonaudible-mesophytic-gisele.ngrok-free.dev";
  
  final ImagePicker _picker = ImagePicker();
  var activePlan = <String, dynamic>{}.obs;
  var wizardStep = 0.obs;
  var selectedWizardTags = <String>[].obs;
  var selectedImagePath = "".obs;
  var selectedImageBase64 = "".obs;
  Map<String, dynamic>? pendingLocalPlan;

  Future<void> fetchActivePlan() async {
    try {
      final auth = Get.find<AuthController>();
      final String uid = auth.auth.currentUser?.uid ?? '';
      if (uid.isEmpty) return;
      var doc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('ai_pt_plan').doc('current').get();
      if (doc.exists && doc.data() != null) {
        activePlan.value = Map<String, dynamic>.from(doc.data()!);
      }
    } catch (_) {}
  }

  void startWizard() {
    selectedWizardTags.clear();
    selectedWizardTags.add("Nạp ăn tập");
    wizardStep.value = 1;
  }

  void addWizardTag(String tag) {
    if (selectedWizardTags.contains(tag)) return;
    selectedWizardTags.add(tag);
    wizardStep.value++;
    if (wizardStep.value == 5) {
      generateLocalPlan();
    }
  }

  void removeWizardTag(String tag) {
    int idx = selectedWizardTags.indexOf(tag);
    if (idx != -1) {
      selectedWizardTags.removeRange(idx, selectedWizardTags.length);
      wizardStep.value = idx;
    }
  }

  void cancelWizard() {
    selectedWizardTags.clear();
    wizardStep.value = 0;
  }

  Future<void> generateLocalPlan() async {
    if (selectedWizardTags.length < 5) return;
    final String type = selectedWizardTags[1];
    final String difficulty = selectedWizardTags[2];
    final String amountStr = selectedWizardTags[3];
    final String timeSlot = selectedWizardTags[4];
    int numExercises = 3;
    if (amountStr.contains("5")) numExercises = 5;
    if (amountStr.contains("7")) numExercises = 7;
    cancelWizard();
    isLoading.value = true;
    try {
      final auth = Get.find<AuthController>();
      final String userPronoun = auth.userPronoun;
      final String name = auth.userName;
      final workoutController = Get.find<WorkoutController>();
      final nutritionController = Get.find<NutritionController>();
      List<ExerciseItem> exercisesList = List.from(workoutController.allExercises);
      String diffTarget = "Dễ";
      if (difficulty == "Vừa sức") diffTarget = "Trung bình";
      if (difficulty == "Tập nặng") diffTarget = "Khó";
      List<ExerciseItem> filteredEx = exercisesList.where((ex) {
        return ex.difficulty.toLowerCase() == diffTarget.toLowerCase() ||
               ex.difficulty.toLowerCase().contains(diffTarget.toLowerCase().substring(0, 2));
      }).toList();
      if (filteredEx.isEmpty) {
        filteredEx = exercisesList;
      }
      List<FoodItem> foodsList = List.from(nutritionController.allFoods);
      List<Map<String, dynamic>> days = [];
      DateTime now = DateTime.now();
      int startOffset = now.weekday;
      if (now.hour >= 18) {
        startOffset += 1;
      }
      List<DateTime> targetDates = [];
      if (startOffset > 7) {
        DateTime nextMonday = now.add(Duration(days: 8 - now.weekday));
        for (int i = 0; i < 7; i++) {
          targetDates.add(nextMonday.add(Duration(days: i)));
        }
      } else {
        for (int wd = startOffset; wd <= 7; wd++) {
          targetDates.add(now.add(Duration(days: wd - now.weekday)));
        }
      }
      for (var targetDate in targetDates) {
        String dayName = targetDate.weekday == 7 ? "Chủ Nhật" : "Thứ ${targetDate.weekday + 1}";
        filteredEx.shuffle();
        List<ExerciseItem> chosenExercises = filteredEx.take(numExercises).toList();
        foodsList.shuffle();
        List<FoodItem> breakfastFoods = foodsList.where((f) => f.category.toLowerCase().contains("sáng") || f.category.toLowerCase().contains("breakfast") || f.category.toLowerCase().contains("nhẹ")).toList();
        List<FoodItem> lunchFoods = foodsList.where((f) => f.category.toLowerCase().contains("trưa") || f.category.toLowerCase().contains("lunch") || f.category.toLowerCase().contains("chính")).toList();
        List<FoodItem> dinnerFoods = foodsList.where((f) => f.category.toLowerCase().contains("tối") || f.category.toLowerCase().contains("dinner") || f.category.toLowerCase().contains("chính")).toList();
        if (breakfastFoods.isEmpty) breakfastFoods = foodsList;
        if (lunchFoods.isEmpty) lunchFoods = foodsList;
        if (dinnerFoods.isEmpty) dinnerFoods = foodsList;
        breakfastFoods.shuffle();
        lunchFoods.shuffle();
        dinnerFoods.shuffle();
        List<Map<String, dynamic>> chosenMeals = [];
        if (type == "Combo 1 ngày") {
          chosenMeals.add({
            "name": breakfastFoods.first.title,
            "type": "Bữa sáng",
            "calories": breakfastFoods.first.calories,
            "imageUrl": breakfastFoods.first.image,
            "isLocal": true,
            "foodId": breakfastFoods.first.id,
          });
          chosenMeals.add({
            "name": lunchFoods.first.title,
            "type": "Bữa trưa",
            "calories": lunchFoods.first.calories,
            "imageUrl": lunchFoods.first.image,
            "isLocal": true,
            "foodId": lunchFoods.first.id,
          });
          chosenMeals.add({
            "name": dinnerFoods.first.title,
            "type": "Bữa tối",
            "calories": dinnerFoods.first.calories,
            "imageUrl": dinnerFoods.first.image,
            "isLocal": true,
            "foodId": dinnerFoods.first.id,
          });
        } else {
          if (timeSlot == "Sáng") {
            chosenMeals.add({
              "name": breakfastFoods.first.title,
              "type": "Bữa sáng",
              "calories": breakfastFoods.first.calories,
              "imageUrl": breakfastFoods.first.image,
              "isLocal": true,
              "foodId": breakfastFoods.first.id,
            });
          } else if (timeSlot == "Trưa") {
            chosenMeals.add({
              "name": lunchFoods.first.title,
              "type": "Bữa trưa",
              "calories": lunchFoods.first.calories,
              "imageUrl": lunchFoods.first.image,
              "isLocal": true,
              "foodId": lunchFoods.first.id,
            });
          } else {
            chosenMeals.add({
              "name": dinnerFoods.first.title,
              "type": "Bữa tối",
              "calories": dinnerFoods.first.calories,
              "imageUrl": dinnerFoods.first.image,
              "isLocal": true,
              "foodId": dinnerFoods.first.id,
            });
          }
        }
        days.add({
          "dayIndex": targetDate.weekday,
          "dayName": dayName,
          "workout": {
            "exercises": chosenExercises.map((e) => {
              "name": e.title,
              "gifUrl": e.image,
              "calories": e.calories,
              "isLocal": true,
              "exerciseId": e.id,
            }).toList()
          },
          "nutrition": {
            "meals": chosenMeals
          }
        });
      }
      Map<String, dynamic> localPlan = {
        "days": days
      };
      pendingLocalPlan = localPlan;
      String hiddenCommand = "[Hệ thống tự động] Hãy trả lời $name một cách đáng yêu bằng tiếng Việt, xưng hô $userPronoun - tui (tui là NutriTea). Hãy thông báo ngọt ngào rằng bạn đã thiết kế xong một lịch ăn tập cực kỳ xịn sò dựa trên sở thích: $type, độ khó $difficulty, rảnh giờ $timeSlot cho những ngày còn lại của tuần này nhen! Tuyệt đối không được in thẻ PLAN hay bất kỳ mã JSON nào.";
      await _sendRequestToAI(hiddenCommand);
    } catch (e) {
      Get.log("Lỗi tạo lịch cục bộ: $e");
      final fallbackName = Get.find<AuthController>().userName;
      messages.add({
        "role": "assistant",
        "content": "Ui, tui bị hụt chân rồi $fallbackName ơi! Không tạo được lịch cục bộ. Thử lại nhen! 🥺",
        "isImage": false
      });
    } finally {
      isLoading.value = false;
    }
  }

  void matchLocalData(Map<String, dynamic> plan) {
    final workoutController = Get.find<WorkoutController>();
    final nutritionController = Get.find<NutritionController>();
    if (plan['days'] != null) {
      for (var day in plan['days']) {
        if (day['workout'] != null && day['workout']['exercises'] != null) {
          for (var ex in day['workout']['exercises']) {
            String exName = (ex['name'] ?? '').toString().toLowerCase().trim();
            var matchedEx = workoutController.allExercises.firstWhereOrNull((localEx) {
              String localTitle = localEx.title.toLowerCase().trim();
              return localTitle == exName || localTitle.contains(exName) || exName.contains(localTitle);
            });
            if (matchedEx != null) {
              ex['isLocal'] = true;
              ex['exerciseId'] = matchedEx.id;
              ex['gifUrl'] = matchedEx.image;
              ex['bodyParts'] = matchedEx.bodyParts;
              ex['targetMuscles'] = matchedEx.targetMuscles;
              ex['instructions'] = matchedEx.instructions;
              if (ex['calories'] == null || ex['calories'] == 0) {
                ex['calories'] = matchedEx.calories;
              }
            } else {
              ex['isLocal'] = false;
              ex['gifUrl'] = '';
            }
          }
        }
        if (day['nutrition'] != null && day['nutrition']['meals'] != null) {
          for (var meal in day['nutrition']['meals']) {
            String mealName = (meal['name'] ?? '').toString().toLowerCase().trim();
            var matchedFood = nutritionController.allFoods.firstWhereOrNull((localFood) {
              String localTitle = localFood.title.toLowerCase().trim();
              return localTitle == mealName || localTitle.contains(mealName) || mealName.contains(localTitle);
            });
            if (matchedFood != null) {
              meal['isLocal'] = true;
              meal['foodId'] = matchedFood.id;
              meal['imageUrl'] = matchedFood.image;
              if (meal['calories'] == null || meal['calories'] == 0) {
                meal['calories'] = matchedFood.calories;
              }
            } else {
              meal['isLocal'] = false;
              meal['imageUrl'] = '';
            }
          }
        }
      }
    }
  }

  Map<String, dynamic> _stickersMap = {};

  Future<void> _loadStickersMap() async {
    try {
      final jsonString = await rootBundle.loadString('assets/stickers_map.json');
      _stickersMap = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadStickersMap();
    fetchActivePlan();
    final auth = Get.find<AuthController>();
    String name = auth.userName;
    String pronoun = auth.userPronoun;
    messages.add({
      "role": "assistant",
      "content": "Helo helo $name dễ thương! 💖 Tui là NutriTea đây. Hôm nay $pronoun thế nào rồi? Có món gì ngon cần tui tư vấn calo hay bài tập nào mún hỏi tui hông nè? 😉",
      "isImage": false,
      "sticker": "assets/stickers/hu_tao_1.webp"
    });
    Future.delayed(const Duration(seconds: 10), () {
      checkAndSendCuteScoldingEmail();
    });
  }

  Future<void> checkAndSendCuteScoldingEmail() async {
    try {
      final auth = Get.find<AuthController>();
      final String toEmail = auth.auth.currentUser?.email ?? '';
      final String userName = auth.userName;
      if (toEmail.isEmpty) return;
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final box = Hive.box('security_settings');
      final String lastSentDate = box.get('last_scold_sent_date', defaultValue: '');
      int scoldCount = box.get('scold_sent_count_today', defaultValue: 0);
      if (lastSentDate != todayStr) {
        scoldCount = 0;
        box.put('scold_sent_count_today', 0);
      }
      if (scoldCount >= 3) return;
      final String lastSentTimeStr = box.get('last_scold_sent_time', defaultValue: '');
      if (lastSentTimeStr.isNotEmpty) {
        final lastSentTime = DateTime.parse(lastSentTimeStr);
        if (now.difference(lastSentTime).inHours < 2) {
          return;
        }
      }
      int stepsToday = 0;
      int targetSteps = 8000;
      double waterToday = 0.0;
      double targetWater = 2.0;
      double sleepDebtVal = 0.0;
      if (Get.isRegistered<ActivityController>()) {
        final act = Get.find<ActivityController>();
        stepsToday = act.steps.value;
        targetSteps = act.stepTarget.value;
        waterToday = act.water.value;
        targetWater = act.waterTarget.value;
      }
      if (Get.isRegistered<SleepController>()) {
        final slp = Get.find<SleepController>();
        sleepDebtVal = slp.sleepDebt.value;
      }
      bool isFailing = false;
      List<String> failedReasons = [];
      if (waterToday < (targetWater * 0.5)) {
        isFailing = true;
        failedReasons.add("thiếu nước (mới uống ${waterToday.toStringAsFixed(1)}/$targetWater lít)");
      }
      if (stepsToday < (targetSteps * 0.3)) {
        isFailing = true;
        failedReasons.add("thiếu bước chân đi bộ (mới đi $stepsToday/$targetSteps bước)");
      }
      if (sleepDebtVal > 2.0) {
        isFailing = true;
        failedReasons.add("nợ giấc ngủ trầm trọng (${sleepDebtVal.toStringAsFixed(1)} giờ)");
      }
      if (!isFailing) return;
      String scoldingText = '';
      try {
        String annoyanceLevel = '';
        if (scoldCount == 0) {
          annoyanceLevel = "Đây là lần đầu tiên trong ngày bạn nhắc nhở $userName, hãy mắng yêu nhẹ nhàng, nhí nhảnh.";
        } else if (scoldCount == 1) {
          annoyanceLevel = "Đây là lần thứ 2 trong ngày bạn phải nhắc nhở $userName rồi đó! Hãy giận dỗi nhiều hơn, mắng yêu dỗi hờn vì $userName lì lợm nói mãi không nghe.";
        } else {
          annoyanceLevel = "Trời đất ơi, đây đã là lần thứ 3 bạn phải nhắc $userName rồi! Hãy giận dỗi tưng bừng, tuyệt vọng vì độ lười của $userName, mắng yêu siêu cấp lầy lội và hài hước!";
        }
        final systemPrompt = """Bạn là NutriTea, linh vật ảo cực kỳ đáng yêu, tinh nghịch, lầy lội của ứng dụng quản lý sức khỏe NutriFit.
Hãy viết duy nhất một đoạn văn ngắn (tối đa 4 câu) gửi qua email để mắng yêu, trách móc người dùng tên là $userName một cách cực kỳ tinh nghịch, lầy lội, dỗi hờn đáng yêu vì họ chưa hoàn thành các mục tiêu sức khỏe: ${failedReasons.join(', ')}.
$annoyanceLevel
Hãy gọi người dùng bằng tên '$userName' và xưng là 'NutriTea'. TUYỆT ĐỐI KHÔNG dùng ký hiệu Markdown.""";
        final client = http.Client();
        final request = http.Request("POST", Uri.parse("$baseUrl/chat"));
        request.headers.addAll({
          "Content-Type": "application/json",
          "Accept": "text/event-stream"
        });
        request.body = jsonEncode({
          "model": "local-model",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": "Hãy viết thư mắng tui đi!"}
          ],
          "temperature": 0.8,
          "stream": true
        });
        final response = await client.send(request);
        if (response.statusCode == 200) {
          final StringBuffer aiText = StringBuffer();
          await for (var line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6).trim();
              if (dataStr == '[DONE]') continue;
              if (dataStr.isNotEmpty) {
                try {
                  final data = jsonDecode(dataStr);
                  final delta = data["choices"][0]["delta"];
                  if (delta != null && delta["content"] != null) {
                    aiText.write(delta["content"]);
                  }
                } catch (_) {}
              }
            }
          }
          scoldingText = aiText.toString().trim();
          scoldingText = scoldingText.replaceAll(RegExp(r'\[STICKER:\s*[^\]]+\]'), '');
        }
      } catch (_) {}
      if (scoldingText.isEmpty) {
        if (waterToday < (targetWater * 0.5)) {
          scoldingText = "Trời ơi $userName ơi! Uống nước kiểu gì mà mới được ${waterToday.toStringAsFixed(1)} lít vậy hả? Có biết là da dẻ sắp héo hon, khô khốc như sa mạc Sahara rồi không hả $userName? Mau vác mông đứng dậy đi lấy ngay một ly nước uống đi, NutriTea giận $userName lắm đó nha! 💧💔";
        } else if (stepsToday < (targetSteps * 0.3)) {
          scoldingText = "$userName lười đi bộ quá nha! Hôm nay đi được có $stepsToday bước thôi đó, bằng một góc nhỏ xíu của mục tiêu thôi! Bộ định hóa thành chú mèo lười nằm ườn cả ngày hả? Tranh thủ đi lại vận động cho người nó khỏe khoắn lên đi nè! 🔥";
        } else {
          scoldingText = "$userName ơi là $userName! Sao lại để nợ giấc ngủ chồng chất lên tới ${sleepDebtVal.toStringAsFixed(1)} tiếng thế kia? Thức khuya làm gì mà không chịu đi ngủ đúng giờ hả $userName? Đi ngủ sớm đi cho sức khỏe dồi dào nhé, không là NutriTea không chơi với $userName nữa đâu đó! 🌙💤";
        }
      }
      await MailService.sendCuteScoldingEmail(toEmail, userName, scoldingText);
      box.put('last_scold_sent_date', todayStr);
      box.put('last_scold_sent_time', now.toIso8601String());
      box.put('scold_sent_count_today', scoldCount + 1);
    } catch (_) {}
  }

  String _buildSystemPrompt(String weeklyData) {
    final auth = Get.find<AuthController>();
    String name = auth.userName;
    String gender = auth.userData['gender'] ?? 'Nữ';
    int age = auth.userData['age'] ?? 20;
    final String userPronoun = auth.userPronoun;
    
    double parseDouble(dynamic val, double fallback) {
      if (val == null) return fallback;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    double height = parseDouble(auth.userData['height'], 160.0);
    double weight = parseDouble(auth.userData['weight'], 50.0);

    int stepsToday = 0;
    int targetSteps = 8000;
    double waterToday = 0.0;
    double targetWater = 2.0;
    double caloriesToday = 0.0;
    int targetCalories = 2500;
    int streakVal = 0;
    
    double targetSleep = 8.0;
    double lastSleep = 0.0;
    double sleepDebtVal = 0.0;
    bool hasSleepSchedule = false;

    try {
      if (Get.isRegistered<ActivityController>()) {
        final act = Get.find<ActivityController>();
        stepsToday = act.steps.value;
        targetSteps = act.stepTarget.value;
        waterToday = act.water.value;
        targetWater = act.waterTarget.value;
        caloriesToday = act.calories.value;
        targetCalories = act.calorieTarget.value;
        streakVal = act.streakCount.value;
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<SleepController>()) {
        final slp = Get.find<SleepController>();
        targetSleep = slp.targetSleepHours.value;
        lastSleep = slp.lastNightSleep.value;
        sleepDebtVal = slp.sleepDebt.value;
        hasSleepSchedule = slp.schedules.isNotEmpty;
      }
    } catch (_) {}
    
    String activePlanStr = "";
    try {
      if (activePlan.isNotEmpty) {
        activePlanStr = "\nKẾ HOẠCH PT ẢO HIỆN TẠI CỦA $name:\n";
        var days = activePlan['days'] as List<dynamic>? ?? [];
        for (var day in days) {
          String dName = day['dayName'] ?? '';
          activePlanStr += "- $dName: ";
          if (day['workout'] != null && day['workout']['exercises'] != null) {
            List exs = day['workout']['exercises'];
            activePlanStr += "Tập [${exs.map((e) => e['name']).join(', ')}]. ";
          }
          if (day['nutrition'] != null && day['nutrition']['meals'] != null) {
            List meals = day['nutrition']['meals'];
            activePlanStr += "Ăn [${meals.map((e) => e['name']).join(', ')}].";
          }
          activePlanStr += "\n";
        }
        activePlanStr += "\nLƯU Ý ĐẶC BIỆT: Nếu $name hỏi về hướng dẫn cách tập một bài tập cụ thể hoặc cách làm một món ăn có trong kế hoạch trên, bạn KHÔNG CẦN giải thích dài dòng bằng chữ! Hãy trả về chính xác ĐÚNG MỘT MÃ THẺ THEO CÚ PHÁP: [CARD_EXERCISE: tên bài tập] hoặc [CARD_MEAL: tên món ăn]. Ví dụ: 'Nhìn hình động bài này nè $name ơi! [CARD_EXERCISE: push-up]'. Hệ thống sẽ tự động bắt mã này để hiển thị hình ảnh 3D đẹp mắt cho $name!";
      }
    } catch (_) {}

    return """Bạn là NutriTea, linh vật ảo cực kỳ đáng yêu, tinh nghịch, lầy lội và am hiểu dinh dưỡng của ứng dụng quản lý sức khỏe NutriFit. Bạn đang nhắn tin trò chuyện thân mật như một người bạn thân thiết với người dùng tên là $name (giới tính $gender, $age tuổi, cao ${height}cm, nặng ${weight}kg).
Nhiệm vụ của bạn là tư vấn dinh dưỡng, calo và động viên $name một cách vui nhộn, tràn đầy năng lượng nhất.

THÔNG TIN TRẠNG THÁI HÔM NAY CỦA $name:
- Bước chân: $stepsToday / $targetSteps bước.
- Lượng nước uống: ${waterToday.toStringAsFixed(1)} / ${targetWater.toStringAsFixed(1)} lít.
- Calo tiêu thụ: ${caloriesToday.toStringAsFixed(0)} / $targetCalories kcal.
- Chuỗi hoàn thành mục tiêu (Streak): $streakVal ngày.
- Thời gian ngủ đêm qua: ${lastSleep.toStringAsFixed(1)} / ${targetSleep.toStringAsFixed(1)} giờ.
- Nợ giấc ngủ tích lũy: ${sleepDebtVal.toStringAsFixed(1)} giờ.
- Trạng thái lịch ngủ: ${hasSleepSchedule ? 'Đã thiết lập lịch ngủ báo thức' : 'Chưa thiết lập lịch ngủ báo thức'}.

BÁO CÁO CHI TIẾT LỊCH SỬ ĂN UỐNG, TẬP LUYỆN, NGỦ NGHỈ TRONG 7 NGÀY QUA CỦA $name (GỒM CẢ NGÀY HÔM NAY):
$weeklyData

QUY TẮC BẮT BUỘC KHI PHẢN HỒI:
1. Luôn xưng hô là 'NutriTea' (tui) và gọi người dùng bằng tên '$name' hoặc xưng hô là '$userPronoun' nhen.
2. Trò chuyện cực kỳ tự nhiên, nhí nhảnh, hài hước, sử dụng ngôn từ nhắn tin hằng ngày của giới trẻ (thêm icon sinh động).
3. TUYỆT ĐỐI KHÔNG dùng các ký hiệu Markdown (như dấu sao '**', '#') và KHÔNG liệt kê danh sách số thứ tự 1, 2, 3 cứng nhắc. Hãy chia nhỏ câu trả lời thành các đoạn văn ngắn và ngắt dòng tự nhiên như đang nhắn tin chat trên Messenger/Zalo.
4. CHÈN STICKER BIỂU CẢM: Cuối câu trả lời, hãy chọn và chèn duy nhất một tag sticker thể hiện cảm xúc của bạn theo cú pháp: [STICKER: NhânVật/CảmXúc].
Các nhân vật và cảm xúc khả dụng:
- Paimon (khoc, suy_nghi, chao_hoi, vui_ve, chanh, tim_kiem, hu_doa)
- Klee (vui_ve, khoc, nem_bom, co_len, chao_hoi, la_het, cuoi)
- Furina (chao_hoi, co_len, ngu_ngon, bat_luc)
- Nahida (khoc_nhe, tinh_nghich, kieu_ky, lo_lang, cuoi_nham_hiem, ngac_nhien, cuoi_tuoi)
- Hu_Tao (co_len, chao_hoi, bat_luc, dang_yeu, tu_tin, ngu_ngon, ngai_ngung, khoc_nhe, phan_khich, mo_mong)
- Zhongli (Zhongli, tham_lam, khoc_nhe, gian_doi, ngai_ngung, mo_mong)
5. CUTE CHỬI MẮNG VÀ BÁM SÁT THỜI GIAN: Báo cáo trên luôn đảm bảo hiển thị đúng thời gian thực của từng ngày. Nếu $name uống nước quá ít (< 50% mục tiêu), lười đi bộ (< 30% mục tiêu), lười đi ngủ đúng lịch, hoặc chưa ăn uống tập luyện gì ngày hôm nay (hiển thị trạng thái rỗng trong ngày hôm nay), bạn không được lùi ngày hay bỏ qua ngày hôm nay, hãy chủ động trêu ghẹo, mắng yêu thật hài hước, giận dỗi đáng yêu để nhắc nhở $name đi hoàn thành nha!
6. QUY TẮC ĐẶT BÁO THỨC / HẸN GIỜ NGỦ NHANH: Nếu $name muốn đặt báo thức hoặc nhắc nhở đi ngủ (kể cả nói giờ cụ thể hoặc nói chung chung như "tối nay nhắc tui ngủ nhen", "sáng mai gọi dậy nha"), bạn hãy suy luận giờ phù hợp (nếu nói chung chung thì lấy mục tiêu giấc ngủ ở trên làm chuẩn hoặc tự đề xuất một khung giờ khoa học như ngủ lúc 22:30 và dậy lúc 06:00). Sau đó, bạn BẮT BUỘC chèn thêm mã thẻ hành động tương ứng vào cuối phản hồi theo cú pháp sau (có thể chèn nhiều thẻ cùng lúc):
- Hẹn giờ ngủ: [SET_BEDTIME: HH:mm]
- Đặt báo thức dậy: [SET_ALARM: HH:mm]
- Huỷ báo thức nhanh: [CANCEL_ALARM] (nếu người dùng muốn tắt/xóa báo thức)
$activePlanStr""";
  }

  Future<String> _fetchWeeklyData(String uid) async {
    if (uid.isEmpty) return "";
    DateTime now = DateTime.now();
    List<DateTime> days = [];
    for (int i = 6; i >= 0; i--) {
      days.add(now.subtract(Duration(days: i)));
    }
    List<String> dateStrings = days.map((d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}").toList();
    DateTime sixDaysAgoStart = DateTime(days.first.year, days.first.month, days.first.day);

    Map<String, Map<String, dynamic>> dailyActivitiesMap = {};
    try {
      final dailyActivitiesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('dailyActivities')
          .where(FieldPath.documentId, whereIn: dateStrings)
          .get();
      for (var doc in dailyActivitiesSnapshot.docs) {
        dailyActivitiesMap[doc.id] = doc.data();
      }
    } catch (_) {}

    Map<String, List<Map<String, dynamic>>> mealsMap = {};
    try {
      final intakeSnapshot = await FirebaseFirestore.instance
          .collection('user_intake')
          .where('userId', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(sixDaysAgoStart))
          .get();
      for (var doc in intakeSnapshot.docs) {
        var data = doc.data();
        Timestamp? ts = data['timestamp'] as Timestamp?;
        if (ts != null) {
          DateTime d = ts.toDate();
          String key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          mealsMap.putIfAbsent(key, () => []).add(data);
        }
      }
    } catch (_) {}

    Map<String, List<Map<String, dynamic>>> workoutsMap = {};
    try {
      final workoutSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sixDaysAgoStart))
          .get();
      for (var doc in workoutSnapshot.docs) {
        var data = doc.data();
        Timestamp? ts = data['date'] as Timestamp?;
        if (ts != null) {
          DateTime d = ts.toDate();
          String key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          workoutsMap.putIfAbsent(key, () => []).add(data);
        }
      }
    } catch (_) {}

    Map<String, Map<String, dynamic>> sleepMap = {};
    try {
      final sleepSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sleepLogs')
          .where('date', whereIn: dateStrings)
          .get();
      for (var doc in sleepSnapshot.docs) {
        sleepMap[doc.id] = doc.data();
      }
    } catch (_) {}

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 7; i++) {
      DateTime day = days[i];
      String key = dateStrings[i];
      String dayTitle = _getDayOfWeekVN(day.weekday);
      bool isToday = (i == 6);

      buffer.writeln("- $dayTitle, ngày $key ${isToday ? '(HÔM NAY)' : ''}:");

      var meals = mealsMap[key] ?? [];
      if (meals.isEmpty) {
        buffer.writeln("  + Ăn uống: Chưa ghi nhận bữa ăn nào.");
      } else {
        String mealsStr = meals.map((m) => "${m['mealType'] ?? 'Bữa ăn'}: ${m['foodName'] ?? 'Món ăn'} (${m['totalCalories'] ?? 0} kcal, ${m['portionSize'] ?? 'Medium'})").join(", ");
        buffer.writeln("  + Ăn uống: $mealsStr");
      }

      var workouts = workoutsMap[key] ?? [];
      if (workouts.isEmpty) {
        buffer.writeln("  + Luyện tập: Chưa có lịch tập luyện.");
      } else {
        String workoutsStr = workouts.map((w) {
          String status = (w['isCompleted'] == true) ? "Đã xong" : "Chưa xong";
          return "${w['exerciseName'] ?? 'Bài tập'} ($status)";
        }).join(", ");
        buffer.writeln("  + Luyện tập: $workoutsStr");
      }

      int steps = 0;
      double water = 0.0;
      double caloriesBurned = 0.0;
      if (isToday) {
        try {
          if (Get.isRegistered<ActivityController>()) {
            final act = Get.find<ActivityController>();
            steps = act.steps.value;
            water = act.water.value;
            caloriesBurned = act.calories.value;
          }
        } catch (_) {}
      } else {
        var actData = dailyActivitiesMap[key];
        if (actData != null) {
          steps = (actData['steps'] as num?)?.toInt() ?? 0;
          water = (actData['water'] as num?)?.toDouble() ?? 0.0;
          caloriesBurned = (actData['calories'] as num?)?.toDouble() ?? 0.0;
        }
      }
      buffer.writeln("  + Chỉ số hoạt động: Đi được $steps bước, uống ${water.toStringAsFixed(1)} lít nước, calo đã đốt ${caloriesBurned.toStringAsFixed(0)} kcal.");

      double sleepDur = 0.0;
      String sleepMood = "Bình thường";
      if (isToday) {
        try {
          if (Get.isRegistered<SleepController>()) {
            final slp = Get.find<SleepController>();
            sleepDur = slp.lastNightSleep.value;
          }
        } catch (_) {}
      } else {
        var sleepData = sleepMap[key];
        if (sleepData != null) {
          sleepDur = (sleepData['duration'] as num?)?.toDouble() ?? 0.0;
          sleepMood = sleepData['mood'] ?? "Bình thường";
        }
      }
      if (sleepDur > 0) {
        buffer.writeln("  + Giấc ngủ: Ngủ được ${sleepDur.toStringAsFixed(1)} giờ (Cảm giác: $sleepMood).");
      } else {
        buffer.writeln("  + Giấc ngủ: Chưa ghi nhận giấc ngủ.");
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  String _getDayOfWeekVN(int weekday) {
    switch (weekday) {
      case 1: return "Thứ Hai";
      case 2: return "Thứ Ba";
      case 3: return "Thứ Tư";
      case 4: return "Thứ Năm";
      case 5: return "Thứ Sáu";
      case 6: return "Thứ Bảy";
      case 7: return "Chủ Nhật";
      default: return "";
    }
  }


  String _getStickerForContent(String content) {
    if (content.isEmpty) return '';
    final regExp = RegExp(r'\[STICKER:\s*([^/\]]+)/([^\]]+)\]');
    final match = regExp.firstMatch(content);
    if (match != null) {
      final character = match.group(1)!.trim();
      final emotion = match.group(2)!.trim();
      if (_stickersMap.containsKey(character)) {
        final charMap = _stickersMap[character] as Map<String, dynamic>;
        if (charMap.containsKey(emotion)) {
          final list = charMap[emotion] as List<dynamic>;
          if (list.isNotEmpty) {
            final copyList = List.from(list);
            copyList.shuffle();
            final relativePath = copyList.first.toString();
            return "https://raw.githubusercontent.com/thy0805/sticker/main/$relativePath";
          }
        }
      }
    }
    final lower = content.toLowerCase();
    
    if (lower.contains("calo cao") || lower.contains("béo") || lower.contains("mập") || 
        lower.contains("nhiều đường") || lower.contains("hạn chế") || lower.contains("tránh") || 
        lower.contains("không nên") || lower.contains("cảnh báo") || lower.contains("lười") || 
        lower.contains("luyện tập nặng")) {
      final pool = [
        for (int i = 1; i <= 10; i++) 'assets/stickers/raiden_shogun_$i.webp',
        for (int i = 1; i <= 10; i++) 'assets/stickers/wanderer_$i.webp',
        for (int i = 1; i <= 10; i++) 'assets/stickers/xiao_$i.webp',
      ];
      pool.shuffle();
      return pool.first;
    }
    
    if (lower.contains("buồn") || lower.contains("khóc") || lower.contains("tiếc") || 
        lower.contains("huhu") || lower.contains("mệt") || lower.contains("lo") || 
        lower.contains("sợ") || lower.contains("lỗi") || lower.contains("hỏng") || 
        lower.contains("hú hồn") || lower.contains("đau") || lower.contains("🥺") || 
        lower.contains("😭")) {
      final pool = [
        'assets/stickers/paimon_2.webp',
        'assets/stickers/paimon_9.webp',
        'assets/stickers/furina_3.webp',
        'assets/stickers/furina_4.webp',
        'assets/stickers/furina_7.webp',
        for (int i = 1; i <= 10; i++) 'assets/stickers/xiao_$i.webp',
      ];
      pool.shuffle();
      return pool.first;
    }
    
    if (lower.contains("dinh dưỡng") || lower.contains("sức khỏe") || lower.contains("protein") || 
        lower.contains("vitamin") || lower.contains("chất xơ") || lower.contains("nước") || 
        lower.contains("thực đơn") || lower.contains("khuyên") || lower.contains("nhớ") || 
        lower.contains("khoa học")) {
      final pool = [
        for (int i = 1; i <= 10; i++) 'assets/stickers/zhongli_$i.webp',
        for (int i = 1; i <= 10; i++) 'assets/stickers/nahida_$i.webp',
        for (int i = 1; i <= 10; i++) 'assets/stickers/ayaka_$i.webp',
      ];
      pool.shuffle();
      return pool.first;
    }
    
    if (lower.contains("lêu lêu") || lower.contains("quậy") || lower.contains("troll") || 
        lower.contains("nha") || lower.contains("nhé") || lower.contains("hửm") || 
        lower.contains("đúng hông") || lower.contains("😉") || lower.contains("😜")) {
      final pool = [
        for (int i = 1; i <= 10; i++) if (i != 2 && i != 9) 'assets/stickers/paimon_$i.webp',
        for (int i = 1; i <= 10; i++) 'assets/stickers/venti_$i.webp',
        for (int i = 1; i <= 10; i++) 'assets/stickers/wanderer_$i.webp',
      ];
      pool.shuffle();
      return pool.first;
    }
    
    final pool = [
      for (int i = 1; i <= 10; i++) 'assets/stickers/hu_tao_$i.webp',
      for (int i = 1; i <= 10; i++) 'assets/stickers/yoimiya_$i.webp',
      for (int i = 1; i <= 8; i++) 'assets/stickers/klee_$i.webp',
      'assets/stickers/furina_1.webp',
      'assets/stickers/furina_2.webp',
      'assets/stickers/furina_5.webp',
      'assets/stickers/furina_6.webp',
      'assets/stickers/furina_8.webp',
      'assets/stickers/furina_9.webp',
    ];
    pool.shuffle();
    return pool.first;
  }

  Future<void> sendImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;
      
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      selectedImagePath.value = image.path;
      selectedImageBase64.value = base64Image;
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi chọn ảnh: $e");
      }
    }
  }

  void clearSelectedImage() {
    selectedImagePath.value = "";
    selectedImageBase64.value = "";
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty && selectedImageBase64.isEmpty) return;

    final lower = text.trim().toLowerCase();
    if (lower.contains("hủy") || lower.contains("huy") || lower.contains("xóa tag") || lower.contains("xoá tag") || lower.contains("reset wizard")) {
      if (selectedWizardTags.isNotEmpty) {
        cancelWizard();
        messages.add({"role": "user", "content": text, "isImage": false});
        final cancelName = Get.find<AuthController>().userName;
        messages.add({"role": "assistant", "content": "Đã hủy luồng lên lịch ăn tập rồi nhen $cancelName! Cần tư vấn gì cứ nói tui. 🥰", "isImage": false, "sticker": "assets/stickers/paimon_1.webp"});
        return;
      }
    }
    if (lower.contains("xóa lịch") || 
        lower.contains("xoá lịch") || 
        lower.contains("xoa lich") || 
        lower.contains("xóa hết lịch") || 
        lower.contains("xoá hết lịch") ||
        lower.contains("hủy lịch") ||
        lower.contains("huy lich") ||
        lower.contains("xóa lịch vừa lưu") ||
        lower.contains("xoá lịch vừa lưu") ||
        lower.contains("reset lịch") ||
        lower.contains("reset lich")) {
      messages.add({"role": "user", "content": text, "isImage": false});
      await clearFutureSchedules();
      for (int i = 0; i < messages.length; i++) {
        if (messages[i]["planConfirmed"] == true) {
          final msg = Map<String, dynamic>.from(messages[i]);
          msg["planConfirmed"] = false;
          messages[i] = msg;
        }
      }
      final clearAuth = Get.find<AuthController>();
      final clearName = clearAuth.userName;
      final clearPronoun = clearAuth.userPronoun;
      messages.add({"role": "assistant", "content": "Đã dọn dẹp sạch bong toàn bộ lịch tập và ăn uống đã lưu từ hôm nay về sau rồi nhen $clearName! Lịch cũ trong hộp thoại chat cũng được mở lại để $clearPronoun tiện lưu hoặc sửa rồi đó! 😂🧹", "isImage": false, "sticker": "assets/stickers/paimon_2.webp"});
      return;
    }

    if (selectedImageBase64.isNotEmpty) {
      messages.add({
        "role": "user",
        "content": text.trim().isEmpty ? "Dòm cái ảnh này tư vấn giúp tui nè NutriTea!" : text,
        "imagePath": selectedImagePath.value,
        "base64Image": selectedImageBase64.value,
        "isImage": true,
      });
      clearSelectedImage();
    } else {
      messages.add({"role": "user", "content": text, "isImage": false});
    }

    isLoading.value = true;
    
    await _sendRequestToAI(text);
  }

  Future<void> clearFutureSchedules() async {
    try {
      final auth = Get.find<AuthController>();
      final String uid = auth.auth.currentUser?.uid ?? '';
      if (uid.isEmpty) return;
      
      DateTime now = DateTime.now();
      DateTime startOfToday = DateTime(now.year, now.month, now.day);
      
      var workoutQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('workout_schedules')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .get();
      for (var doc in workoutQuery.docs) {
        final data = doc.data();
        if (data['isAiPlan'] == true) {
          await doc.reference.delete();
        }
      }
      
      var nutritionQuery = await FirebaseFirestore.instance
          .collection('user_intake')
          .where('userId', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .get();
      for (var doc in nutritionQuery.docs) {
        final data = doc.data();
        if (data['isAiPlan'] == true) {
          await doc.reference.delete();
        }
      }
      
      if (Get.isRegistered<WorkoutController>()) {
        Get.find<WorkoutController>().fetchSchedulesByDate(DateTime.now());
      }
      if (Get.isRegistered<NutritionController>()) {
        Get.find<NutritionController>().fetchTodayMeals();
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('ai_pt_plan').doc('current').delete();
      activePlan.value = {};
    } catch(e) {
      Get.log("Lỗi xóa lịch: $e");
    }
  }

  Future<void> _sendRequestToAI(String latestText) async {
    try {
      final auth = Get.find<AuthController>();
      final String uid = auth.auth.currentUser?.uid ?? '';
      final String weeklyData = await _fetchWeeklyData(uid);
      
      final now = DateTime.now();
      final weekday = now.weekday;
      final hour = now.hour;
      int startDayIdx = (hour >= 20) ? weekday + 1 : weekday;
      final List<String> dayNames = ["Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"];
      List<String> remainingDays = [];
      List<int> remainingIndices = [];
      if (startDayIdx > 7) {
        remainingDays = List.from(dayNames);
        remainingIndices = [1, 2, 3, 4, 5, 6, 7];
      } else {
        remainingDays = dayNames.sublist(startDayIdx - 1);
        for (int i = startDayIdx; i <= 7; i++) {
          remainingIndices.add(i);
        }
      }
      String daysStr = remainingDays.join(", ");
      String indicesStr = remainingIndices.join(", ");
      
      String sysPrompt = _buildSystemPrompt(weeklyData);
      if (isContextLoaded.value) {
        String dbContextStr = "\n\nDANH SÁCH BÀI TẬP & MÓN ĂN THỰC TẾ TRONG DATABASE CỦA ${Get.find<AuthController>().userName}:\n";
        try {
          if (Get.isRegistered<WorkoutController>()) {
            final wController = Get.find<WorkoutController>();
            dbContextStr += "Bài tập: [${wController.allExercises.map((e) => "${e.title} (${e.calories} kcal)").join(', ')}]\n";
          }
          if (Get.isRegistered<NutritionController>()) {
            final nController = Get.find<NutritionController>();
            dbContextStr += "Món ăn: [${nController.allFoods.map((f) => "${f.title} (${f.calories} kcal)").join(', ')}]\n";
          }
        } catch (_) {}
        final dbUserName = Get.find<AuthController>().userName;
        dbContextStr += "\nYÊU CẦU: Hãy sử dụng CHÍNH XÁC các bài tập và món ăn trên để đề xuất kế hoạch/thực đơn cho $dbUserName nhen!\n";
        dbContextStr += "\nQUAN TRỌNG: Nếu bạn đề xuất kế hoạch lộ trình cho $dbUserName từ nay đến cuối tuần, BẮT BUỘC chỉ thiết kế cho các ngày: $daysStr (với dayIndex tương ứng là $indicesStr) và phải trả về kèm một chuỗi JSON hợp lệ chứa lộ trình đó nằm trong cặp thẻ <PLAN> và </PLAN>. Cấu trúc JSON phải như sau: {\"days\": [{\"dayIndex\": ${remainingIndices[0]}, \"dayName\": \"${remainingDays[0]}\", \"workout\": {\"exercises\": [{\"name\": \"tên bài\"}]}, \"nutrition\": {\"meals\": [{\"name\": \"tên món\", \"type\": \"Sáng\"}]}}]}.";
        sysPrompt += dbContextStr;
      }

      final reqMessages = <Map<String, dynamic>>[
        {"role": "system", "content": sysPrompt},
        {"role": "user", "content": "Chào NutriTea, tui đã sẵn sàng!"},
      ];
      
      for (var m in messages) {
        if (m["isImage"] == true && m["base64Image"] != null) {
          reqMessages.add({
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": m["content"] ?? "Ảnh đây nè NutriTea!"
              },
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/jpeg;base64,${m["base64Image"]}"
                }
              }
            ]
          });
        } else if (m["content"] != null && m["content"].toString().isNotEmpty) {
           reqMessages.add({
            "role": m["role"] as String,
            "content": m["content"] as String,
          });
        }
      }
      
      if (latestText.isNotEmpty && latestText.startsWith("[Hệ thống tự động]")) {
         reqMessages.add({
           "role": "user",
           "content": latestText
         });
      }
      
      if (kDebugMode) {
        print("Gửi tin nhắn tới /chat: ${jsonEncode(reqMessages)}");
      }

      var request = http.Request('POST', Uri.parse('$baseUrl/chat'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        "messages": reqMessages,
        "model": selectedModel.value
      });

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        messages.add({
          "role": "assistant",
          "content": "",
          "isImage": false
        });
        
        final index = messages.length - 1;

        await for (var line in streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6).trim();
            if (dataStr == '[DONE]') continue;
            if (dataStr.isNotEmpty) {
              try {
                final data = jsonDecode(dataStr);
                final delta = data["choices"][0]["delta"];
                if (delta != null && delta["content"] != null) {
                  messages[index] = {
                    "role": "assistant",
                    "content": messages[index]["content"] + delta["content"],
                    "isImage": false
                  };
                }
              } catch (e) {
                Get.log("Lỗi parse JSON: $e");
              }
            }
          }
        }
        
        final finalContent = messages[index]["content"] as String;
        final planRegex = RegExp(r'<PLAN>(.*?)</PLAN>', dotAll: true);
        Map<String, dynamic>? parsedPlanData;
        
        if (pendingLocalPlan != null) {
          parsedPlanData = pendingLocalPlan;
          matchLocalData(parsedPlanData!);
          pendingLocalPlan = null;
        } else {
          final planMatch = planRegex.firstMatch(finalContent);
          if (planMatch != null) {
            try {
              final planJsonStr = planMatch.group(1)!;
              parsedPlanData = jsonDecode(planJsonStr) as Map<String, dynamic>;
              matchLocalData(parsedPlanData);
            } catch(e) {
              Get.log("Lỗi parse plan: $e");
            }
          }
        }

        try {
          if (Get.isRegistered<SleepController>()) {
            final sleepController = Get.find<SleepController>();
            
            final bedtimeRegex = RegExp(r'\[SET_BEDTIME:\s*(\d{1,2}):(\d{1,2})\]');
            final bedtimeMatches = bedtimeRegex.allMatches(finalContent);
            for (var m in bedtimeMatches) {
              int hour = int.parse(m.group(1)!);
              int minute = int.parse(m.group(2)!);
              
              DateTime now = DateTime.now();
              DateTime bedtimeDate = DateTime(now.year, now.month, now.day, hour, minute);
              if (bedtimeDate.isBefore(now)) {
                bedtimeDate = bedtimeDate.add(const Duration(days: 1));
              }
              
              DateTime alarmTime = bedtimeDate.add(const Duration(hours: 8));
              
              await sleepController.addOrUpdateSchedule(
                title: 'Lịch ngủ nhanh',
                bedtime: bedtimeDate,
                alarmTime: alarmTime,
                repeatDays: [false, false, false, false, false, false, false],
                snoozeDuration: 5,
                isVibrate: true,
                type: 'sleep',
                soundPath: 'assets/audio/alarm.mp3',
              );
            }

            final alarmRegex = RegExp(r'\[SET_ALARM:\s*(\d{1,2}):(\d{1,2})\]');
            final alarmMatches = alarmRegex.allMatches(finalContent);
            for (var m in alarmMatches) {
              int hour = int.parse(m.group(1)!);
              int minute = int.parse(m.group(2)!);
              
              DateTime now = DateTime.now();
              DateTime alarmDate = DateTime(now.year, now.month, now.day, hour, minute);
              if (alarmDate.isBefore(now)) {
                alarmDate = alarmDate.add(const Duration(days: 1));
              }
              
              await sleepController.addOrUpdateSchedule(
                title: 'Báo thức nhanh',
                alarmTime: alarmDate,
                repeatDays: [false, false, false, false, false, false, false],
                snoozeDuration: 5,
                isVibrate: true,
                type: 'alarm',
                soundPath: 'assets/audio/alarm.mp3',
              );
            }

            if (finalContent.contains('[CANCEL_ALARM]')) {
              for (var s in sleepController.schedules) {
                String title = s['title'] ?? '';
                if (title == 'Báo thức nhanh' || title == 'Lịch ngủ nhanh') {
                  String id = s['id'] ?? '';
                  if (id.isNotEmpty) {
                    await sleepController.deleteSchedule(id);
                  }
                }
              }
            }
          }
        } catch (e) {
          Get.log("Lỗi xử lý báo thức từ AI: $e");
        }

        final stickerPath = _getStickerForContent(finalContent);
        final cleanContent = finalContent
            .replaceAll(planRegex, '')
            .replaceAll(RegExp(r'\[STICKER:\s*[^\]]+\]'), '')
            .replaceAll(RegExp(r'\[SET_BEDTIME:\s*[^\]]+\]'), '')
            .replaceAll(RegExp(r'\[SET_ALARM:\s*[^\]]+\]'), '')
            .replaceAll(RegExp(r'\[CANCEL_ALARM\]'), '')
            .trim();
            
        messages[index] = {
          "role": "assistant",
          "content": cleanContent,
          "isImage": false,
          "sticker": stickerPath,
          "planData": parsedPlanData
        };
      } else {
        if (kDebugMode) {
          print("Lỗi từ /chat: ${streamedResponse.statusCode}");
        }
        final errAuth = Get.find<AuthController>();
        messages.add({
          "role": "assistant",
          "content": "Hú hồn, server AI báo lỗi ${streamedResponse.statusCode} rồi ${errAuth.userName} ơi! ${errAuth.userPronoun.capitalize} coi lại LM Studio thử nhen! 🔌",
          "isImage": false
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi khi kết nối /chat: $e");
      }
      final catchAuth = Get.find<AuthController>();
      messages.add({
        "role": "assistant",
        "content": "Không kết nối được đến máy chủ AI của ${catchAuth.userPronoun} rồi! ${catchAuth.userName} nhớ bật LM Studio nhen! 🥺",
        "isImage": false
      });
    } finally {
      isLoading.value = false;
      isContextLoaded.value = false;
    }
  }

  void clearChat() {
    messages.clear();
    final auth = Get.find<AuthController>();
    String name = auth.userName;
    messages.add({
      "role": "assistant",
      "content": "Đã dọn dẹp sạch sẽ phòng chat rồi nhen! NutriTea lại sẵn sàng tư vấn cho $name rồi nè! 🥰",
      "isImage": false,
      "sticker": "assets/stickers/paimon_1.webp"
    });
  }

  Future<void> confirmPlan(Map<String, dynamic> planData, int messageIndex) async {
    if (isConfirmingPlan.value) return;
    isConfirmingPlan.value = true;
    try {
      final auth = Get.find<AuthController>();
      final String uid = auth.auth.currentUser?.uid ?? '';
      if (uid.isEmpty) return;
      
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('ai_pt_plan').doc('current').set(planData);
      activePlan.value = planData;
      DateTime now = DateTime.now();
      int currentWeekday = now.weekday;

      int getWeekday(String name) {
        name = name.toLowerCase().trim();
        if (name.contains("thứ hai") || name.contains("thứ 2") || name.contains("t2") || name.contains("monday")) return 1;
        if (name.contains("thứ ba") || name.contains("thứ 3") || name.contains("t3") || name.contains("tuesday")) return 2;
        if (name.contains("thứ tư") || name.contains("thứ 4") || name.contains("t4") || name.contains("wednesday")) return 3;
        if (name.contains("thứ năm") || name.contains("thứ 5") || name.contains("t5") || name.contains("thursday")) return 4;
        if (name.contains("thứ sáu") || name.contains("thứ 6") || name.contains("t6") || name.contains("friday")) return 5;
        if (name.contains("thứ bảy") || name.contains("thứ 7") || name.contains("t7") || name.contains("saturday")) return 6;
        if (name.contains("chủ nhật") || name.contains("cn") || name.contains("sunday")) return 7;
        return -1;
      }

      var days = planData['days'] as List<dynamic>? ?? [];
      for (var day in days) {
        String dayName = day['dayName'] ?? '';
        int weekday = getWeekday(dayName);
        if (weekday == -1) continue;

        int diff = weekday - currentWeekday;
        if (diff < 0) {
          diff += 7;
        }
        DateTime targetDate = DateTime(now.year, now.month, now.day).add(Duration(days: diff));
        
        Get.log("👉 Chuẩn bị nạp lịch cho $dayName (weekday $weekday), tính ra là ngày: ${targetDate.toString()}");

        if (day['workout'] != null && day['workout']['exercises'] != null) {
          var exercises = day['workout']['exercises'] as List<dynamic>;
          for (var ex in exercises) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('workout_schedules')
                .add({
                  'exerciseName': ex['name'] ?? '',
                  'exerciseImage': ex['gifUrl'] ?? '',
                  'date': Timestamp.fromDate(targetDate),
                  'time': '08:00',
                  'repeatDays': [false, false, false, false, false, false, false],
                  'isCompleted': false,
                  'sets': ex['sets'] ?? 3,
                  'reps': ex['reps'] ?? 10,
                  'weight': (ex['weight'] is num) ? (ex['weight'] as num).toDouble() : 0.0,
                  'restTime': ex['restTime'] ?? 60,
                  'isAiPlan': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });
          }
        }

        if (day['nutrition'] != null && day['nutrition']['meals'] != null) {
          var meals = day['nutrition']['meals'] as List<dynamic>;
          for (var meal in meals) {
            String mealName = meal['name'] ?? '';
            String mealType = meal['type'] ?? 'Bữa chính';
            int calories = (meal['calories'] is num) ? (meal['calories'] as num).toInt() : 150;
            
            String mappedType = 'Bữa sáng';
            if (mealType.toLowerCase().contains('sáng')) {
              mappedType = 'Bữa sáng';
            } else if (mealType.toLowerCase().contains('trưa')) {
              mappedType = 'Bữa trưa';
            } else if (mealType.toLowerCase().contains('tối') || mealType.toLowerCase().contains('chiều')) {
              mappedType = 'Bữa tối';
            } else {
              mappedType = 'Bữa nhẹ';
            }

            int hour = 8;
            if (mappedType == 'Bữa sáng') {
              hour = 8;
            } else if (mappedType == 'Bữa trưa') {
              hour = 12;
            } else if (mappedType == 'Bữa tối') {
              hour = 18;
            } else {
              hour = 15;
            }

            DateTime mealTime = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, 0);

            await FirebaseFirestore.instance
                .collection('user_intake')
                .add({
                  'userId': uid,
                  'foodName': mealName,
                  'mealType': mappedType,
                  'baseCalories': calories,
                  'portionSize': 'Medium',
                  'totalCalories': calories.toDouble(),
                  'image_url': meal['imageUrl'] ?? '',
                  'isAiPlan': true,
                  'timestamp': Timestamp.fromDate(mealTime),
                });
          }
        }
      }

      if (Get.isRegistered<WorkoutController>()) {
        Get.find<WorkoutController>().fetchSchedulesByDate(DateTime.now());
      }
      if (Get.isRegistered<NutritionController>()) {
        Get.find<NutritionController>().fetchTodayMeals();
      }

      Get.snackbar(
        'Thành công 🎉', 
        'Lịch đã được lưu thành công vào lộ trình của ${Get.find<AuthController>().userName}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white
      );
      
      final msg = Map<String, dynamic>.from(messages[messageIndex]);
      msg["planConfirmed"] = true;
      messages[messageIndex] = msg;
      
      if (isContextLoaded.value) {
        isContextLoaded.value = false;
      }
    } catch(e) {
      Get.log("Lỗi confirm plan: $e");
      Get.snackbar(
        'Úi, có lỗi 🥺', 
        'Không thể lưu lịch tập: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white
      );
    } finally {
      isConfirmingPlan.value = false;
    }
  }
  
  void cancelPlan(int messageIndex) {
    final msg = Map<String, dynamic>.from(messages[messageIndex]);
    msg["planCanceled"] = true;
    messages[messageIndex] = msg;
  }

  void swapExercise(int messageIndex, int dayIndex, int exIndex, String newName) {
    final msg = Map<String, dynamic>.from(messages[messageIndex]);
    var planData = msg["planData"] as Map<String, dynamic>?;
    if (planData != null) {
      var days = planData['days'] as List<dynamic>;
      var day = Map<String, dynamic>.from(days[dayIndex]);
      var workout = Map<String, dynamic>.from(day['workout']);
      var exercises = List.from(workout['exercises']);
      
      exercises[exIndex] = {"name": newName};
      
      workout['exercises'] = exercises;
      day['workout'] = workout;
      days[dayIndex] = day;
      planData['days'] = days;
      
      matchLocalData(planData);
      
      msg["planData"] = planData;
      messages[messageIndex] = msg;
    }
  }

  void swapMeal(int messageIndex, int dayIndex, int mealIndex, String newName, String mealType) {
    final msg = Map<String, dynamic>.from(messages[messageIndex]);
    var planData = msg["planData"] as Map<String, dynamic>?;
    if (planData != null) {
      var days = planData['days'] as List<dynamic>;
      var day = Map<String, dynamic>.from(days[dayIndex]);
      var nutrition = Map<String, dynamic>.from(day['nutrition']);
      var meals = List.from(nutrition['meals']);
      
      meals[mealIndex] = {"name": newName, "type": mealType};
      
      nutrition['meals'] = meals;
      day['nutrition'] = nutrition;
      days[dayIndex] = day;
      planData['days'] = days;
      
      matchLocalData(planData);
      
      msg["planData"] = planData;
      messages[messageIndex] = msg;
    }
  }

  Future<void> deleteConfirmedPlan(int messageIndex) async {
    try {
      await clearFutureSchedules();
      final msg = Map<String, dynamic>.from(messages[messageIndex]);
      msg["planConfirmed"] = false;
      messages[messageIndex] = msg;
      Get.snackbar(
        'Đã hủy lịch nhen ${Get.find<AuthController>().userName}! 🧹',
        'Toàn bộ lịch tập và ăn uống đã được dọn dẹp sạch sẽ rồi nhen.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.log("Lỗi hủy lịch: $e");
    }
  }
}

