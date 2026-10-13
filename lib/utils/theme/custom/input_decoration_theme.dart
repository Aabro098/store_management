import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppInputDecoration {
  AppInputDecoration._();

  static OutlineInputBorder _border({
    Color color = AppColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecorationTheme get getLightTheme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTypography.body.copyWith(color: AppColors.fgMuted),
        labelStyle: AppTypography.plusJakarta(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: AppTypography.plusJakarta(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 4,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.smMd,
        ),
        suffixIconColor: AppColors.fgMuted,
        prefixIconColor: AppColors.fgMuted,
        border: _border(),
        enabledBorder: _border(),
        disabledBorder: _border(color: AppColors.fgMuted),
        focusedBorder: _border(color: AppColors.primary, width: 2),
        errorBorder: _border(color: AppColors.danger),
        focusedErrorBorder: _border(color: AppColors.danger, width: 1.5),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.danger),
      );
}
