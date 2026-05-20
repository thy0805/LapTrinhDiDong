import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit/modules/auth/controllers/auth_controller.dart';
import 'package:nutrifit/core/services/mail_service.dart';

class GamificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';
  
  Map<String, dynamic> get userData => Get.find<AuthController>().userData;
  String get userEmail => userData['email'] ?? '';
  String get userName => userData['fullName'] ?? 'Người dùng';
  String get userPronoun => (userData['gender'] == 'Male') ? 'ông' : 'bà';

  Future<GamificationService> init() async {
    return this;
  }

  int getLevel(int exp) {
    if (exp < 1000) return 1;
    // Công thức: EXP >= 500 * n * (n-1)
    // Giải phương trình bậc 2: 500n^2 - 500n - exp = 0
    // n = (1 + sqrt(1 + 4 * exp / 500)) / 2
    return ((1 + sqrt(1 + 4 * exp / 500)) / 2).floor();
  }

  Map<String, int> getExpRangeForLevel(int level) {
    int currentLevelExp = 500 * level * (level - 1);
    int nextLevelExp = 500 * (level + 1) * level;
    return {
      'min': currentLevelExp,
      'max': nextLevelExp,
    };
  }

  String getTitle(int level) {
    if (level >= 20) return 'Huyền thoại thể hình';
    if (level >= 15) return 'Bậc thầy vóc dáng';
    if (level >= 10) return 'Chiến thần phòng tập';
    if (level >= 5) return 'Chiến binh rèn luyện';
    if (level >= 2) return 'Mầm non thể thao';
    return 'Tấm chiếu mới';
  }

  Future<void> awardExp(int amount, String message, {String? milestoneKey}) async {
    if (uid.isEmpty) return;

    if (milestoneKey != null) {
      DateTime now = DateTime.now();
      String dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      DocumentReference milestoneRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('milestones')
          .doc(dateStr);

      DocumentSnapshot snap = await milestoneRef.get();
      Map<String, dynamic> status = snap.exists ? (snap.data() as Map<String, dynamic>) : {};
      
      if (status[milestoneKey] == true) return;

      await milestoneRef.set({milestoneKey: true}, SetOptions(merge: true));
    }

    int currentExp = userData['exp'] ?? 0;
    int newExp = currentExp + amount;

    int currentLevel = getLevel(currentExp);
    int newLevel = getLevel(newExp);

    await _firestore.collection('users').doc(uid).update({
      'exp': FieldValue.increment(amount),
    });

    Get.find<AuthController>().userData['exp'] = newExp;

    Get.snackbar(
      '🎮 +$amount EXP',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );

    if (newLevel > currentLevel) {
      String newTitle = getTitle(newLevel);
      Get.snackbar(
        '🎊 THĂNG CẤP! 🎊',
        'Chúc mừng $userPronoun đã đạt Level $newLevel: $newTitle',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.stars, color: Colors.white),
      );

      if (userEmail.isNotEmpty) {
        MailService.sendLevelUpEmail(userEmail, userName, newLevel, newTitle);
      }
      
      _checkThemeUnlocks(newExp);
    }
  }

  void _checkThemeUnlocks(int exp) {
    if (exp >= 5000) {
      Get.snackbar('🎨 THEME MỚI', 'Đã mở khóa theme "Pastel Dream" & "Ocean Blue"! Check trong Profile nhen.',
        backgroundColor: Colors.blueAccent, colorText: Colors.white);
    } else if (exp >= 3000) {
      Get.snackbar('🌙 DARK MODE CHUYÊN SÂU', 'Đã mở khóa Dark Mode Neon cực chất!',
        backgroundColor: Colors.black87, colorText: Colors.white);
    }
  }

  Future<void> unlockAchievement(String id, String name, String desc, int expReward) async {
    if (uid.isEmpty) return;

    Map<String, dynamic> achievements = userData['achievements'] ?? {};
    if (achievements[id] == true) return;

    await _firestore.collection('users').doc(uid).set({
      'achievements': {id: true}
    }, SetOptions(merge: true));

    achievements[id] = true;
    Get.find<AuthController>().userData['achievements'] = achievements;

    Get.snackbar(
      '🏆 THÀNH TỰU MỚI',
      '$name: $desc',
      backgroundColor: Colors.orangeAccent,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.emoji_events, color: Colors.white),
    );

    await awardExp(expReward, 'Nhận thưởng từ thành tựu "$name"');

    _showAchievementDialog(name, desc, expReward);

    if (userEmail.isNotEmpty) {
      MailService.sendAchievementEmail(userEmail, userName, name, desc, expReward);
    }
  }

  void _showAchievementDialog(String name, String desc, int exp) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(colors: [Colors.white, Color(0xFFFDEBFF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, color: Get.theme.colorScheme.primary, size: 80),
              SizedBox(height: 20),
              Text('THÀNH TỰU MỚI!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Get.theme.colorScheme.primary, fontFamily: 'Poppins')),
              SizedBox(height: 10),
              Text(name, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              SizedBox(height: 10),
              Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'Poppins')),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('+$exp EXP', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text('TUYỆT VỜI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateUserStats(String key, dynamic value, {bool increment = true}) async {
    if (uid.isEmpty) return;
    if (increment) {
      await _firestore.collection('users').doc(uid).update({key: FieldValue.increment(value)});
      Get.find<AuthController>().userData[key] = (Get.find<AuthController>().userData[key] ?? 0) + value;
    } else {
      await _firestore.collection('users').doc(uid).update({key: value});
      Get.find<AuthController>().userData[key] = value;
    }
  }

  Future<void> checkWaterMilestones(double water, double target) async {
    if (water >= target * 1.2) {
      await awardExp(5, 'Vượt rào thành công! Thủy thần là đây chứ đâu! 🌊', milestoneKey: 'water_120');
    } else if (water >= target) {
      await awardExp(15, 'Tuyệt vời! Đã uống đủ ${target.toStringAsFixed(1)}L nước hôm nay! 🏆', milestoneKey: 'water_100');
    } else if (water >= target * 0.5) {
      await awardExp(5, 'Đạt 50% mục tiêu uống nước! Cố lên $userPronoun ơi! 💧', milestoneKey: 'water_50');
    }
  }

  Future<void> checkStepMilestones(int steps, int target) async {
    if (steps >= target * 1.5) {
      await awardExp(15, 'Kẻ cuồng chân! $userPronoun đi quá hăng hái luôn! 🔥', milestoneKey: 'steps_150');
    } else if (steps >= target) {
      await awardExp(20, 'Đạt chuẩn y tế rồi! Đôi chân vàng trong làng đi bộ! 🥇', milestoneKey: 'steps_target');
    } else if (steps >= 3000) {
      await awardExp(5, 'Đi dạo sương sương 3,000 bước. Khởi đầu tốt đó! 🚶‍♂️', milestoneKey: 'steps_3000');
    }
  }

  Future<void> checkCalorieBurnMilestones(double burned) async {
    if (burned >= 500) {
      await awardExp(50, 'Đốt trên 500 kcal! Một ngày tập luyện cực kỳ bạo chúa! 🔥🦾', milestoneKey: 'burn_500');
    } else if (burned >= 300) {
      await awardExp(30, 'Đốt được hơn 300 kcal rồi nè. Mồ hôi rơi là EXP tới! 💦', milestoneKey: 'burn_300');
    } else if (burned >= 100) {
      await awardExp(10, 'Cán mốc 100 kcal tiêu thụ. Tiếp tục phát huy nha! ⚡', milestoneKey: 'burn_100');
    }
  }

  Future<void> checkNutritionMilestones(int mealCount, double intake, double target) async {
    if (mealCount >= 3) {
      await awardExp(15, 'Đã ghi nhận đủ 3 bữa chính trong ngày. Ăn uống điều độ quá nè! 🥗', milestoneKey: 'meals_3');
    }

    if (intake >= target * 0.9 && intake <= target * 1.1 && intake > 0) {
      await awardExp(20, 'Calo nạp vào nằm trong ngưỡng an toàn. Rất kỷ luật! ⚖️', milestoneKey: 'safe_calories');
    }
  }

  Future<void> awardWorkoutExp(String difficulty) async {
    int exp = 15;
    String diffText = 'Dễ';
    if (difficulty.toLowerCase() == 'medium' || difficulty == 'Trung bình') {
      exp = 35;
      diffText = 'Trung bình';
    } else if (difficulty.toLowerCase() == 'hard' || difficulty == 'Khó') {
      exp = 60;
      diffText = 'Khó';
    }
    await awardExp(exp, 'Hoàn thành bài tập độ khó $diffText! Quá xịn! 💪');
  }

  Future<void> awardProgramComplete(String programName) async {
    await awardExp(150, 'Hoàn thành trọn vẹn giáo án "$programName"! Đẳng cấp là đây! 🏆🏅');
  }

  Future<void> checkLifetimeAchievements({
    double? totalSteps,
    int? veggieMeals,
    double? totalWater,
  }) async {
    if (uid.isEmpty) return;

    if (totalSteps != null && totalSteps >= 1000000) {
      await unlockAchievement('million_steps', 'Kẻ Lữ Hành Vĩ Đại', 'Tích lũy tổng cộng 1,000,000 bước chân. Một hành trình phi thường! 👣✨', 500);
    }

    if (veggieMeals != null && veggieMeals >= 10) {
      await unlockAchievement('healthy_eater', 'Người Chơi Hệ Healthy', 'Ghi nhận 10 bữa ăn đầy rau xanh và trái cây. 🥗🍎', 100);
    }

    if (totalWater != null && totalWater >= 100) {
      await unlockAchievement('water_god', 'Thủy Thần', 'Tích lũy 100 lít nước uống vào app. Cơ thể bạn đã được thanh lọc hoàn toàn! 🌊👑', 300);
    }
  }

  Future<void> checkTimeBasedAchievements(String type, {double? value}) async {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (type == 'steps' && value != null && value >= 5000 && hour >= 11 && hour <= 14) {
      await unlockAchievement('noon_sprinter', 'Tốc Biến Trưa Hè', 'Đạt trên 5,000 bước chân chỉ trong khung giờ nắng nóng nhất! 🔥🚶‍♂️', 100);
    }

    if (type == 'wakeup' && hour < 6) {
      await unlockAchievement('early_bird_special', 'Bình Minh Rực Rỡ', 'Dậy sớm trước 6h sáng và bắt đầu ngày mới đầy năng lượng! ☀️✨', 100);
    }

    if (type == 'late_activity' && hour >= 0 && hour <= 3) {
      await unlockAchievement('midnight_owl', 'Cú Đêm Lầm Lỡ', 'Bắt quả tang thức khuya nha! Mau đi ngủ đi để cơ bắp phục hồi! 🦉💤', 10);
    }
  }

  Future<void> checkOverachiever(double caloriesBurned, double target) async {
    if (caloriesBurned >= target * 3) {
      await unlockAchievement('overachiever_extreme', 'Hơi Quá Sức Rồi Đó', 'Vượt mục tiêu calo luyện tập tới 300%. Cháy rực rỡ nhưng nhớ giữ sức nha! 🔥🦾', 50);
    }
  }

  Future<void> checkDesertMode(int daysMissing) async {
    if (daysMissing >= 2) {
      await unlockAchievement('desert_mode', 'Sa Mạc Lời', 'Quên log nước suốt 48 giờ. Mau uống một ngụm nước để tưới mát tâm hồn đi! 🌵💧', 5);
    }
  }

  Future<void> checkPerfectDay(double score) async {
    if (score >= 10.0) {
      await awardExp(50, 'Ngày hoàn hảo! Đạt điểm 10/10 tuyệt đối cho mọi hoạt động! 🌈⭐', milestoneKey: 'perfect_day_bonus');
      await unlockAchievement('perfect_day', 'Perfect Day (Chuẩn Không Cần Chỉnh)', 'Đạt điểm completionScore tuyệt đối 10/10!', 100);
    }
  }

  Future<void> awardStreakExp(int days) async {
    if (days == 3) {
      await awardExp(30, 'Chuỗi 3 ngày liên tục! Khởi động thành công! ⚡');
    } else if (days == 7) {
      await awardExp(100, 'Chuỗi 7 ngày! Bạn đã tạo thành thói quen rồi đó! 🌟');
      await unlockAchievement('water_streak_7', 'Thủy Thần Trỗi Dậy', 'Hoàn thành mục tiêu uống nước liên tục trong 7 ngày. 🌊', 150);
    } else if (days == 21) {
      await awardExp(300, 'Chuỗi 21 ngày! Một lối sống mới đã hình thành! 🏆');
    } else if (days == 30) {
      await awardExp(500, 'Chuỗi 30 ngày! Kỷ luật thép, vóc dáng vàng! 💎');
    }
  }

  Future<void> checkComplexAchievements(List<Map<String, dynamic>> last7Days, double caloTarget, int stepTarget, double waterTarget) async {
    if (last7Days.length < 7) return;

    bool caloStreak7 = true;
    bool lazy7 = true;
    for (var day in last7Days) {
      double calo = (day['calories'] as num?)?.toDouble() ?? 0.0;
      double workoutCalo = (day['workoutCalories'] as num?)?.toDouble() ?? 0.0;
      if (calo < caloTarget) caloStreak7 = false;
      if (workoutCalo > 0) lazy7 = false;
    }

    if (caloStreak7) {
      await unlockAchievement('calo_warrior_7', 'Thánh Cày Calo', 'Vượt mục tiêu calo liên tiếp trong 7 ngày. Sức mạnh vô biên! 🔥🦾', 500);
    }

    if (lazy7) {
      await unlockAchievement('lazy_7', 'Kẻ Lười Biếng', 'Bỏ tập liên tiếp 7 ngày. Cơ bắp đang khóc thét đó $userPronoun ơi! 🛋️💤', 5);
    }

    if (last7Days.length >= 8) {
      bool scary8 = true;
      for (int i = 0; i < 8; i++) {
        var day = last7Days[i];
        double calo = (day['calories'] as num?)?.toDouble() ?? 0.0;
        int steps = (day['steps'] as num?)?.toInt() ?? 0;
        double water = (day['water'] as num?)?.toDouble() ?? 0.0;
        if (calo < caloTarget || steps < stepTarget || water < waterTarget) {
          scary8 = false;
          break;
        }
      }
      if (scary8) {
        await unlockAchievement('scary_8', 'Ôi đáng sợ quá!', 'Hoàn thành vượt định mức TẤT CẢ mục tiêu liên tục 8 ngày. Quái vật giới fitness! 👹💥', 1000);
      }
    }
  }

  Future<void> checkNutritionBinge(int mealCount) async {
    if (mealCount >= 5) {
      await unlockAchievement('glutton_5', 'Kẻ Phàm Ăn', 'Ăn tới 5 bữa một ngày. Dạ dày của $userPronoun làm bằng thép sao? 🍔🍕🍗', 50);
    }
  }

  Future<void> checkForgetfulness(int mealCount, double water) async {
    if (mealCount == 0 && water == 0) {
      await unlockAchievement('thirsty_hungry', 'Kẻ Đói Khát', 'Quên cả ăn lẫn uống suốt một ngày. Đừng để tâm hồn héo úa nhen! 🏜️💀', 5);
    }
  }

  Future<void> checkUltimateAchievement(int uniqueExercisesCount, int streak) async {
    if (uniqueExercisesCount >= 1300 && streak >= 3) {
      await unlockAchievement('not_human', 'CÓ CÒN LÀ CON NGƯỜI KHÔNG!??', 'Trải nghiệm hết 1300+ bài tập và giữ chuỗi phong độ cực cao. Huyền thoại của các huyền thoại! 👑🌌', 5000);
    }
  }

  Future<void> awardSleepExp(double duration, double target, bool moodLogged, bool noSnooze) async {
    if (duration >= target) {
      await awardExp(20, 'Ngủ đủ mục tiêu $target tiếng. Phục hồi năng lượng thôi! 😴', milestoneKey: 'sleep_target');
    }
    if (moodLogged) {
      await awardExp(5, 'Đã ghi nhận cảm xúc. $userPronoun quan tâm bản thân quá nè! 😊', milestoneKey: 'mood_logged');
    }
    if (noSnooze) {
      await awardExp(10, 'Dậy đúng giờ báo thức, không ngủ nướng! Quá kỷ luật! ⏰✨', milestoneKey: 'no_snooze');
    }
  }
}
