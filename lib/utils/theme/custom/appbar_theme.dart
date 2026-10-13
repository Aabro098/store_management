import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppAppBarTheme {
  AppAppBarTheme._();

  static AppBarTheme get lightAppBarTheme => AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.fg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.sectionTitle,
        iconTheme: const IconThemeData(color: AppColors.fg, size: 20),
        actionsIconTheme: const IconThemeData(color: AppColors.fg, size: 20),
        centerTitle: false,
        toolbarHeight: 56.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      );
}
