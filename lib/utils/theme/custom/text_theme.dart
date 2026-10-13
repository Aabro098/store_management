import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static String? get fontFamily => GoogleFonts.plusJakartaSans().fontFamily;

  /// Plus Jakarta Sans — weights 400/500/600/700 (DESIGN.md §Typography)
  static TextStyle plusJakarta({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.fg,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing ?? fontSize * -0.02,
      height: height,
    );
  }

  /// Display / screen title — compact semibold, tracking-tight
  static TextStyle get display => plusJakarta(
        fontSize: AppSizes.fontXXl,
        fontWeight: FontWeight.w600,
      );

  /// Section title — 16px semibold
  static TextStyle get sectionTitle => plusJakarta(
        fontSize: AppSizes.fontBase,
        fontWeight: FontWeight.w600,
      );

  /// Card / row title — 15px semibold
  static TextStyle get cardTitle => plusJakarta(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      );

  /// Body — 14px regular
  static TextStyle get body => plusJakarta(
        fontSize: AppSizes.fontSm,
        letterSpacing: 0,
      );

  /// Caption / meta — muted
  static TextStyle get caption => plusJakarta(
        fontSize: AppSizes.fontSm,
        color: AppColors.fgMuted,
        letterSpacing: 0,
      );

  /// Micro / badge — xs semibold, wide tracking
  static TextStyle get badge => plusJakarta(
        fontSize: AppSizes.micro,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      );

  /// Button label — 15px semibold
  static TextStyle get button => plusJakarta(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.white,
      );

  /// Overline / section label — xs semibold uppercase, wide tracking
  static TextStyle get overline => plusJakarta(
        fontSize: AppSizes.fontXs,
        fontWeight: FontWeight.w600,
        color: AppColors.fgMuted,
        letterSpacing: 1.2,
      );

  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: display,
        displayMedium: plusJakarta(
          fontSize: AppSizes.fontXXl,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: plusJakarta(
          fontSize: AppSizes.fontXXl,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: plusJakarta(
          fontSize: AppSizes.fontXXl,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: plusJakarta(
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: sectionTitle,
        titleLarge: sectionTitle,
        titleMedium: cardTitle,
        titleSmall: plusJakarta(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        bodyLarge: plusJakarta(
          fontSize: AppSizes.fontMd,
          letterSpacing: 0,
        ),
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button.copyWith(color: AppColors.fg),
        labelMedium: plusJakarta(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w500,
          color: AppColors.fgMuted,
          letterSpacing: 0,
        ),
        labelSmall: badge.copyWith(color: AppColors.fgMuted),
      );
}
