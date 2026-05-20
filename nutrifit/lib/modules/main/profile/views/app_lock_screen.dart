import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../modules/main/home/views/main_screen.dart';

enum AppLockMode { verify, setup, disable }

class AppLockScreen extends StatefulWidget {
  final AppLockMode mode;
  final VoidCallback? onSuccess;

  const AppLockScreen({
    super.key,
    this.mode = AppLockMode.verify,
    this.onSuccess,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final List<String> _currentInput = [];
  final _box = Hive.box('security_settings');
  
  String _titleText = '';
  String _firstPin = '';
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _initializeMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometrics();
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    final isBiometric = _box.get('isBiometricEnabled', defaultValue: false);
    if (widget.mode != AppLockMode.verify || !isBiometric) return;

    try {
      final localAuth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await localAuth.isDeviceSupported();

      if (!canAuthenticate) return;

      final bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Xác thực sinh trắc học để mở khóa ứng dụng',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          Get.offAll(() => const MainScreen());
        }
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
    }
  }

  void _initializeMode() {
    if (widget.mode == AppLockMode.verify) {
      _titleText = 'Nhập mã PIN để mở khóa';
    } else if (widget.mode == AppLockMode.setup) {
      _titleText = 'Thiết lập mã PIN mới';
      _isConfirming = false;
      _firstPin = '';
    } else {
      _titleText = 'Nhập mã PIN hiện tại để tắt';
    }
  }

  void _onKeyPress(String digit) {
    if (_currentInput.length < 4) {
      setState(() {
        _currentInput.add(digit);
      });

      if (_currentInput.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), _processPasscode);
      }
    }
  }

  void _onDelete() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput.removeLast();
      });
    }
  }

  void _processPasscode() {
    final enteredPin = _currentInput.join();
    _currentInput.clear();

    if (widget.mode == AppLockMode.verify) {
      final savedPin = _box.get('appPasscode', defaultValue: '');
      if (enteredPin == savedPin) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          Get.offAll(() => const MainScreen());
        }
      } else {
        _showError('Mã PIN không chính xác');
      }
    } else if (widget.mode == AppLockMode.setup) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = enteredPin;
          _isConfirming = true;
          _titleText = 'Nhập lại mã PIN để xác nhận';
        });
      } else {
        if (enteredPin == _firstPin) {
          _box.put('isAppLockEnabled', true);
          _box.put('appPasscode', enteredPin);
          Get.back(result: true);
          Get.snackbar(
            'Thành công',
            'Đã kích hoạt khóa ứng dụng bằng mã PIN',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          setState(() {
            _isConfirming = false;
            _firstPin = '';
            _titleText = 'Thiết lập mã PIN mới';
          });
          _showError('Mã xác nhận không trùng khớp. Vui lòng thiết lập lại');
        }
      }
    } else if (widget.mode == AppLockMode.disable) {
      final savedPin = _box.get('appPasscode', defaultValue: '');
      if (enteredPin == savedPin) {
        _box.put('isAppLockEnabled', false);
        _box.put('appPasscode', '');
        Get.back(result: true);
        Get.snackbar(
          'Thành công',
          'Đã tắt tính năng khóa ứng dụng',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        _showError('Mã PIN không chính xác. Không thể tắt khóa');
      }
    }
  }

  void _showError(String message) {
    setState(() {});
    Get.snackbar(
      'Bảo mật',
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.mode != AppLockMode.verify
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => Get.back(result: false),
                      )
                    : const SizedBox(height: 48),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _titleText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1D1517),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final hasDigit = index < _currentInput.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasDigit ? theme.colorScheme.primary : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    border: Border.all(
                      color: hasDigit ? theme.colorScheme.primary : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumButton('1'),
                      _buildNumButton('2'),
                      _buildNumButton('3'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumButton('4'),
                      _buildNumButton('5'),
                      _buildNumButton('6'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumButton('7'),
                      _numCell('8'),
                      _buildNumButton('9'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBiometricButton(),
                      _buildNumButton('0'),
                      _buildDeleteButton(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildNumButton(String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _onKeyPress(value),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1D1517),
          ),
        ),
      ),
    );
  }

  Widget _numCell(String value) {
    return _buildNumButton(value);
  }

  Widget _buildDeleteButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          color: isDark ? Colors.white : const Color(0xFF1D1517),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    final isBiometric = _box.get('isBiometricEnabled', defaultValue: false);
    if (widget.mode != AppLockMode.verify || !isBiometric) {
      return const SizedBox(width: 70, height: 70);
    }

    return GestureDetector(
      onTap: _authenticateWithBiometrics,
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: Icon(
          Icons.fingerprint_rounded,
          color: Get.theme.colorScheme.primary,
          size: 40,
        ),
      ),
    );
  }
}
