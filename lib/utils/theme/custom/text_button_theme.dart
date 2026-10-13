import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppTextButtonTheme {
  AppTextButtonTheme._();

  static TextButtonThemeData get lightTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.fgMuted,
          textStyle: AppTypography.cardTitle.copyWith(
            color: AppColors.primary,
          ),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
}
