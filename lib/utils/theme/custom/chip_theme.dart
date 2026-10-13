import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppChipTheme {
  AppChipTheme._();

  static ChipThemeData get lightTheme => ChipThemeData(
        backgroundColor: AppColors.bgSubtle,
        selectedColor: AppColors.primarySoft,
        disabledColor: AppColors.bgSubtle,
        deleteIconColor: AppColors.fgMuted,
        labelStyle: AppTypography.caption.copyWith(
          color: AppColors.fg,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: AppTypography.badge.copyWith(
          color: AppColors.primary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 0,
      );
}
