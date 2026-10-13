import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppBottomNavTheme {
  AppBottomNavTheme._();

  static BottomNavigationBarThemeData get lightTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.fincoCharcoal,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.fgMuted,
      selectedLabelStyle: AppTypography.plusJakarta(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      unselectedLabelStyle: AppTypography.plusJakarta(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.fgMuted,
        letterSpacing: 0,
      ),
      selectedIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 20,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppColors.fgMuted,
        size: 20,
      ),
    );
  }

  static NavigationBarThemeData get materialLightTheme {
    return NavigationBarThemeData(
      backgroundColor: AppColors.fincoCharcoal,
      elevation: 0,
      height: 72,
      indicatorColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return AppTypography.plusJakarta(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? AppColors.white : Colors.white54,
          letterSpacing: 0,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.white : Colors.white54,
          size: 20,
        );
      }),
    );
  }
}
