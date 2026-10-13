import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppDialogTheme {
  AppDialogTheme._();

  static DialogThemeData get lightTheme => DialogThemeData(
        elevation: 0,
        alignment: Alignment.center,
        backgroundColor: AppColors.bgElevated,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingHoriz,
          vertical: AppSizes.lg,
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.md,
        ),
        titleTextStyle: AppTypography.sectionTitle,
        contentTextStyle: AppTypography.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
      );
}
