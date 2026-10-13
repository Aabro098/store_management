import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppListTileTheme {
  static ListTileThemeData get lightTheme => ListTileThemeData(
        dense: false,
        visualDensity: VisualDensity.compact,
        horizontalTitleGap: AppSizes.md,
        titleTextStyle: AppTypography.lightTextTheme.bodyLarge?.copyWith(
          color: AppColors.fg,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: AppSizes.sm,
        ),
        tileColor: AppColors.backgroundColor,
        titleAlignment: ListTileTitleAlignment.center,
        minVerticalPadding: 0,
      );
}
