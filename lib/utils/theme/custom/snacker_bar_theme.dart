import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppSnackerBarTheme {
  AppSnackerBarTheme._();

  static SnackBarThemeData get lightTheme => SnackBarThemeData(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.fg,
        actionTextColor: AppColors.white,
        closeIconColor: AppColors.white,
        dismissDirection: DismissDirection.down,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        insetPadding: EdgeInsets.symmetric(
          vertical: AppSizes.sm,
          horizontal: AppSizes.paddingHoriz,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
      );
}
