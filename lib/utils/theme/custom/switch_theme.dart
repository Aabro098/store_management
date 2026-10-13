import 'package:finco_customer/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class AppSwitchTheme {
  AppSwitchTheme._();

  static SwitchThemeData get lightTheme => SwitchThemeData(
        padding: EdgeInsets.zero,

        thumbColor: WidgetStateProperty.all(
          AppColors.white,
        ),

        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }

          return AppColors.border;
        }),

        trackOutlineColor: WidgetStateProperty.all(
          Colors.transparent,
        ),

        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.12),
        ),

        // Force the same thumb size for both states.
        thumbIcon: WidgetStateProperty.all(
          const Icon(
            Icons.circle,
            size: 16,
            color: Colors.white,
          ),
        ),
      );
}
