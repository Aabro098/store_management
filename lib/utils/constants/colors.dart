import 'package:flutter/material.dart';

/// Brand tokens from DESIGN.md. Prefer these over raw hex in widgets.
class AppColors {
  AppColors._();

  // Brand palette — primary teal (#0f9696)
  static const Color primary = Color(0xFF0F9696);
  static const Color primaryDark = Color(0xFF0B7575);
  static const Color primarySoft = Color(0xFFE6F4F4);

  static const Color accent = Color(0xFFE6F4F4);
  static const Color accentSoft = Color(0xFFEEF6F6);

  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFD1FAE5);

  static const Color info = Color(0xFF10A0A0);
  static const Color infoSoft = Color(0xFFE6F4F4);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);

  static const Color danger = Color(0xFFD03050);
  static const Color dangerSoft = Color(0xFFFDE8EC);

  static const Color fg = Color(0xFF2C2C2C);
  static const Color fgMuted = Color(0xFF6A6A6A);

  // Design-system neutrals
  static const Color secondary = Color(0xFFEEF6F6);
  static const Color secondaryForeground = Color(0xFF0F9696);
  static const Color muted = Color(0xFFEFEEEC);
  static const Color mutedForeground = Color(0xFF6A6A6A);

  static const Color border = Color(0xFFE8E6E3);

  /// Warm off-white app canvas
  static const Color bg = Color(0xFFF7F6F4);
  static const Color bgElevated = Color(0xFFFFFFFF);
  static const Color bgSubtle = Color(0xFFEFEEEC);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Brand accents (FINCO)
  static const Color fincoTeal = Color(0xFF10A0A0);
  static const Color fincoOrange = Color(0xFFE08030);
  static const Color fincoMagenta = Color(0xFFD03050);
  static const Color fincoCharcoal = Color(0xFF404040);
  static const Color fincoYellow = Color(0xFFF5C518);

  static const Color scrim = Color(0x662C2C2C);

  /// 0 2px 10px -4px rgb(44 44 44 / 0.08)
  static const Color shadow = Color(0x142C2C2C);

  /// Material / snackbar aliases
  static const Color error = danger;
  static const Color surface = bg;
  static const Color background = bg;

  static Color? get backgroundColor => null;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> elevation = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
