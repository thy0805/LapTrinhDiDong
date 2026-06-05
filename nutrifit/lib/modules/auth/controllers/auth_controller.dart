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
import '../views/email_verification_screen.dart';
import '../views/login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrifit/modules/main/profile/views/app_lock_screen.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/health_service.dart';
import 'package:nutrifit/modules/main/target/sleep/controllers/sleep_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/nutrition_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/activity_controller.dart';
import 'package:nutrifit/modules/main/target/workout/controllers/workout_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/notification_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/home_controller.dart';
import 'package:nutrifit/modules/main/profile/controllers/profile_controller.dart';
import 'package:nutrifit/modules/main/profile/controllers/security_controller.dart';
import 'package:nutrifit/modules/main/target/other/controllers/target_controller.dart';
import 'package:nutrifit/modules/main/progress/controllers/progress_controller.dart';
import 'package:nutrifit/modules/main/home/controllers/ai_assistant_controller.dart';
import 'package:nutrifit/modules/main/target/nutrition/controllers/ai_scanner_controller.dart';

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
  var isAuthLoading = false.obs;

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

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String? validateLoginInput() {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      return 'Vui lòng nhập đầy đủ email và mật khẩu.';
    }
    if (!_isValidEmail(email)) {
      return 'Email không đúng định dạng.';
    }
    return null;
  }

  String? validateRegisterStep1() {
    final name = regNameController.text.trim();
    final email = regEmailController.text.trim();
    final password = regPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Vui lòng nhập đầy đủ họ tên, email và mật khẩu.';
    }
    if (!_isValidEmail(email)) {
      return 'Email không đúng định dạng.';
    }
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    return null;
  }

  void _showAuthError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  String _friendlyFirebaseAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Email không đúng định dạng.';
        case 'user-disabled':
          return 'Tài khoản này đã bị vô hiệu hóa.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email hoặc mật khẩu không đúng.';
        case 'email-already-in-use':
          return 'Email này đã được đăng ký.';
        case 'weak-password':
          return 'Mật khẩu phải có ít nhất 6 ký tự.';
        case 'network-request-failed':
          return 'Không có kết nối mạng. Vui lòng thử lại.';
        default:
          return error.message ?? 'Có lỗi xảy ra. Vui lòng thử lại.';
      }
    }
    return 'Có lỗi xảy ra. Vui lòng thử lại.';
  }

  void login() async {
    final inputError = validateLoginInput();
    if (inputError != null) {
      _showAuthError('Lỗi đăng nhập', inputError);
      return;
    }
    if (isAuthLoading.value) return;

    try {
      isAuthLoading.value = true;
      await auth.signInWithEmailAndPassword(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );
      _fetchUserData(auth.currentUser!.uid);
      isAuthLoading.value = false;
      _navigateToMainScreen();
    } catch (e) {
      isAuthLoading.value = false;
      Get.snackbar(
        "Lỗi đăng nhập",
        _friendlyFirebaseAuthError(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void register() async {
    final inputError = validateRegisterStep1();
    if (inputError != null) {
      _showAuthError('Lỗi đăng ký', inputError);
      return;
    }
    if (isAuthLoading.value) return;

    try {
      isAuthLoading.value = true;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: regEmailController.text.trim(),
        password: regPasswordController.text,
      );

      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': regNameController.text.trim(),
        'phone': regPhoneController.text.trim(),
        'email': regEmailController.text.trim(),
        'gender': selectedGender.value,
        'dateOfBirth': regDobController.text.trim(),
        'weight': regWeightController.text.trim(),
        'height': regHeightController.text.trim(),
        'goal': selectedGoal.value,
        'isEmailVerified': false,
        'verifiedEmail': '',
        'createdAt': DateTime.now(),
      });

      _fetchUserData(userCredential.user!.uid);
      
      MailService.sendWelcomeEmail(
        regEmailController.text.trim(),
        regNameController.text.trim(),
      );

      isAuthLoading.value = false;
      _navigateToMainScreen();
    } catch (e) {
      isAuthLoading.value = false;
      Get.snackbar(
        "Lỗi đăng ký",
        _friendlyFirebaseAuthError(e),
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
      String email = auth.currentUser!.email ?? regEmailController.text.trim();
      await firestore.collection('users').doc(uid).set({
        'fullName': auth.currentUser!.displayName ?? regNameController.text.trim(),
        'phone': regPhoneController.text.trim(),
        'email': email,
        'gender': selectedGender.value,
        'dateOfBirth': regDobController.text.trim(),
        'weight': regWeightController.text.trim(),
        'height': regHeightController.text.trim(),
        'goal': selectedGoal.value,
        'isEmailVerified': true,
        'verifiedEmail': email,
        'createdAt': DateTime.now(),
      });
      _fetchUserData(uid);

      MailService.sendWelcomeEmail(
        email,
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
    if (Hive.isBoxOpen('cached_intake')) {
      await Hive.box('cached_intake').clear();
    } else {
      var box = await Hive.openBox('cached_intake');
      await box.clear();
      await box.close();
    }
    Get.delete<HealthService>();
    Get.delete<SleepController>();
    Get.delete<NutritionController>();
    Get.delete<ActivityController>();
    Get.delete<WorkoutController>();
    Get.delete<NotificationController>();
    Get.delete<HomeController>();
    Get.delete<ProfileController>();
    Get.delete<SecurityController>();
    Get.delete<TargetController>();
    Get.delete<ProgressController>();
    Get.delete<AiAssistantController>();
    Get.delete<AiScannerController>();
    Get.delete<MainScreenController>();
    Get.delete<TargetTabController>();
    Get.offAll(() => const LoginPage());
  }

  void _navigateToMainScreen() {
    if (userData.isEmpty) {
      String? uid = auth.currentUser?.uid;
      if (uid != null) {
        firestore.collection('users').doc(uid).get().then((doc) {
          if (doc.exists) {
            userData.value = doc.data() as Map<String, dynamic>;
            _checkVerificationAndNavigate();
          } else {
            Get.offAll(() => const RegisterPage2());
          }
        });
      }
    } else {
      _checkVerificationAndNavigate();
    }
  }

  void _checkVerificationAndNavigate() {
    final email = userData['email']?.toString() ?? '';
    final verifiedEmail = userData['verifiedEmail']?.toString() ?? '';
    final isVerified = userData['isEmailVerified'] as bool? ?? false;

    if (!isVerified || email != verifiedEmail) {
      Get.offAll(() => const EmailVerificationScreen());
    } else {
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
}
