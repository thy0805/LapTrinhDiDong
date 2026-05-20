import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:nutrifit/modules/main/home/views/main_screen.dart';
import 'package:nutrifit/core/services/mail_service.dart';
import '../views/success_registration.dart';
import '../views/register_screen_2.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrifit/modules/main/profile/views/app_lock_screen.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/health_service.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/notification_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/home_controller.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var loginEmailController = TextEditingController();
  var loginPasswordController = TextEditingController();

  var regNameController = TextEditingController();
  var regPhoneController = TextEditingController();
  var regEmailController = TextEditingController();
  var regPasswordController = TextEditingController();

  var regDobController = TextEditingController();
  var regWeightController = TextEditingController();
  var regHeightController = TextEditingController();

  var selectedGender = 'Female'.obs;
  var selectedGoal = 'Cải Thiện Vóc dáng'.obs;

  var userData = <String, dynamic>{}.obs;

  String get userName => userData['fullName']?.toString().split(' ').last ?? 'bạn';
  String get userPronoun => (userData['gender'] == 'Male') ? 'ông' : 'bà';

  String get greeting => 'Hôm nay $userName ăn món gì vậy?';
  String successMessage(String foodName) => 'Tui đã ghi chú món $foodName vào nhật ký cho $userPronoun rồi đó!';

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());

    Future.delayed(const Duration(seconds: 1), () async {
      User? user = auth.currentUser;
      if (user != null) {
        debugPrint("--- AuthController: Đã tìm thấy user với UID: ${user.uid} ---");
        DocumentSnapshot doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          debugPrint("--- AuthController: User đã tồn tại trong Firestore, đang kéo data... ---");
          _fetchUserData(user.uid);
          _navigateToMainScreen();
        } else {
          debugPrint("--- AuthController: User chưa có profile trong Firestore, chuyển qua trang đăng ký 2 ---");
          Get.offAll(() => const RegisterPage2());
        }
      } else {
        debugPrint("--- AuthController: Chưa đăng nhập, vui lòng đăng nhập! ---");
      }
    });
  }

  void _fetchUserData(String uid) {
    debugPrint("--- AuthController: Đang lắng nghe thay đổi data của user $uid ---");
    firestore.collection('users').doc(uid).snapshots().listen((event) {
      if (event.exists) {
        userData.value = event.data()!;
        debugPrint("--- AuthController: Đã cập nhật userData từ Firebase ---");
      } else {
        debugPrint("--- AuthController: Lỗi rồi, hông tìm thấy document của user này! ---");
      }
    });
  }

  void login() async {
    try {
      await auth.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text.trim(),
      );
      _fetchUserData(auth.currentUser!.uid);
      _navigateToMainScreen();
    } catch (e) {
      Get.snackbar(
        "Lỗi đăng nhập",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void register() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: regEmailController.text.trim(),
        password: regPasswordController.text.trim(),
      );

      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': regNameController.text.trim(),
        'phone': regPhoneController.text.trim(),
        'email': regEmailController.text.trim(),
        'password': regPasswordController.text.trim(),
        'gender': selectedGender.value,
        'dateOfBirth': regDobController.text.trim(),
        'weight': regWeightController.text.trim(),
        'height': regHeightController.text.trim(),
        'goal': selectedGoal.value,
        'createdAt': DateTime.now(),
      });

      _fetchUserData(userCredential.user!.uid);
      
      MailService.sendWelcomeEmail(
        regEmailController.text.trim(),
        regNameController.text.trim(),
      );

      Get.offAll(() => const SuccessRegistration());
    } catch (e) {
      Get.snackbar(
        "Lỗi đăng ký",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _handleSocialLogin(UserCredential userCredential) async {
    DocumentSnapshot doc = await firestore.collection('users').doc(userCredential.user!.uid).get();
    if (doc.exists) {
      _fetchUserData(userCredential.user!.uid);
      _navigateToMainScreen();
    } else {
      Get.offAll(() => const RegisterPage2());
    }
  }

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await auth.signInWithCredential(credential);
      _handleSocialLogin(userCredential);
    } catch (e) {
      Get.snackbar(
        "Lỗi Google",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );
        UserCredential userCredential = await auth.signInWithCredential(credential);
        _handleSocialLogin(userCredential);
      } else {
        Get.snackbar(
          "Lỗi Facebook",
          "Đăng nhập thất bại",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Lỗi Facebook",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void updateSocialProfile() async {
    try {
      String uid = auth.currentUser!.uid;
      await firestore.collection('users').doc(uid).set({
        'fullName': auth.currentUser!.displayName ?? regNameController.text.trim(),
        'phone': regPhoneController.text.trim(),
        'email': auth.currentUser!.email ?? regEmailController.text.trim(),
        'gender': selectedGender.value,
        'dateOfBirth': regDobController.text.trim(),
        'weight': regWeightController.text.trim(),
        'height': regHeightController.text.trim(),
        'goal': selectedGoal.value,
        'createdAt': DateTime.now(),
      });
      _fetchUserData(uid);

      MailService.sendWelcomeEmail(
        auth.currentUser!.email ?? '',
        auth.currentUser!.displayName ?? regNameController.text.trim(),
      );

      Get.offAll(() => const SuccessRegistration());
    } catch (e) {
      Get.snackbar(
        "Lỗi cập nhật",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void logout() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    userData.clear();
    Get.delete<HealthService>();
    Get.delete<SleepController>();
    Get.delete<NutritionController>();
    Get.delete<ActivityController>();
    Get.delete<WorkoutController>();
    Get.delete<NotificationController>();
    Get.delete<HomeController>();
  }

  void _navigateToMainScreen() {
    final box = Hive.box('security_settings');
    final isLock = box.get('isAppLockEnabled', defaultValue: false);
    final pin = box.get('appPasscode', defaultValue: '');
    if (isLock && pin.isNotEmpty) {
      Get.offAll(() => const AppLockScreen(mode: AppLockMode.verify));
    } else {
      Get.offAll(() => const MainScreen());
    }
  }
}
