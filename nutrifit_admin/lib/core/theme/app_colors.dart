import 'package:flutter/material.dart';
import 'tailadmin_design_system.dart';

class AppColors {
  static Color get primary => TailAdminDesign.brand500;
  static Color get secondary => TailAdminDesign.brand600;
  static Color get background => TailAdminDesign.bgMain;
  static Color get sidebarBg => TailAdminDesign.bgCard;
  
  static Color get textMain => TailAdminDesign.textMain;
  static Color get textGrey => TailAdminDesign.textMuted;
  static Color get white => TailAdminDesign.bgCard;
  
  static Color get success => const Color(0xFF10B981);
  static Color get danger => const Color(0xFFEF4444);
  static Color get warning => const Color(0xFFF59E0B);
  static Color get info => const Color(0xFF3BA2B8);
  
  static Color get divider => TailAdminDesign.border;
  static Color get border => TailAdminDesign.border;
  static Color get cardBg => TailAdminDesign.bgCard;
  static Color get greyLight => TailAdminDesign.isDark ? TailAdminDesign.darkCard : const Color(0xFFF7F9FC);
  static Color get hoverGrey => TailAdminDesign.hover;
}
