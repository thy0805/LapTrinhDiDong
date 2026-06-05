import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrifit_admin/modules/layout/views/admin_layout.dart';

class TailAdminDesign {
  static NavigationController get _nav => Get.find<NavigationController>();
  static bool get isDark => _nav.isDarkMode.value;

  static Color get bgMain => isDark ? darkBg : gray50;
  static Color get bgCard => isDark ? darkCard : Colors.white;
  static Color get textMain => isDark ? darkTextMain : gray900;
  static Color get textMuted => isDark ? darkTextSecondary : gray500;
  static Color get border => isDark ? darkBorder : gray200;
  static Color get hover => isDark ? darkBorder : gray50;

  static const Color brand50 = Color(0xFFEFF6FF);
  static const Color brand100 = Color(0xFFDBEAFE);
  static const Color brand200 = Color(0xFFBFDBFE);
  static const Color brand300 = Color(0xFF93C5FD);
  static const Color brand400 = Color(0xFF60A5FA);
  static const Color brand500 = Color(0xFF465FFF);
  static const Color brand600 = Color(0xFF2563EB);
  static const Color brand700 = Color(0xFF1D4ED8);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF101828);
  static const Color grayDark = Color(0xFF1A2231);

  static const Color darkBg = Color(0xFF0B1121);
  static const Color darkCard = Color(0xFF111928);
  static const Color darkBorder = Color(0xFF1F2937);
  static const Color darkTextMain = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF101828).withValues(alpha: isDark ? 0.3 : 0.05),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> get shadowDefault => [
    BoxShadow(
      color: const Color(0xFF101828).withValues(alpha: isDark ? 0.4 : 0.1),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: const Color(0xFF101828).withValues(alpha: isDark ? 0.2 : 0.06),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF101828).withValues(alpha: isDark ? 0.4 : 0.1),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: const Color(0xFF101828).withValues(alpha: isDark ? 0.2 : 0.06),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static const double radiusNone = 0.0;
  static const double radiusSm = 2.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radius2xl = 16.0;
  static const double radiusFull = 9999.0;

  static const double sp1 = 4.0;
  static const double sp2 = 8.0;
  static const double sp3 = 12.0;
  static const double sp4 = 16.0;
  static const double sp5 = 20.0;
  static const double sp6 = 24.0;
  static const double sp8 = 32.0;
  static const double sp10 = 40.0;
  static const double sp12 = 48.0;

  static const double fontXs = 12.0;
  static const double fontSm = 14.0;
  static const double fontBase = 16.0;
  static const double fontLg = 18.0;
  static const double fontXl = 20.0;
  static const double font2xl = 24.0;
  static const double font3xl = 30.0;

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Curve curveStandard = Cubic(0.4, 0.0, 0.2, 1.0);
  static const Curve curveIn = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve curveOut = Cubic(0.0, 0.0, 0.2, 1.0);

  static const double screenSm = 640.0;
  static const double screenMd = 768.0;
  static const double screenLg = 1024.0;
  static const double screenXl = 1280.0;
  static const double screen2xl = 1536.0;
}
