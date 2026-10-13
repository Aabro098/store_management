import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTabBarTheme {
  AppTabBarTheme._();

  static TabBarThemeData get lightTheme => TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(35),
        ),
        splashFactory: NoSplash.splashFactory,
        dividerColor: Colors.transparent,
        dividerHeight: 1,
        labelColor: AppColors.fg,
        unselectedLabelColor: AppColors.fgMuted,
        labelStyle: AppTypography.cardTitle,
        unselectedLabelStyle: AppTypography.plusJakarta(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.fgMuted,
          letterSpacing: 0,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelPadding: EdgeInsets.zero,
      );
}
