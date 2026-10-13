import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/theme/custom/appbar_theme.dart';
import 'package:finco_customer/utils/theme/custom/bottom_nav_theme.dart';
import 'package:finco_customer/utils/theme/custom/card_theme.dart';
import 'package:finco_customer/utils/theme/custom/chip_theme.dart';
import 'package:finco_customer/utils/theme/custom/dialog_theme.dart';
import 'package:finco_customer/utils/theme/custom/elevated_button_theme.dart';
import 'package:finco_customer/utils/theme/custom/filled_button_theme.dart';
import 'package:finco_customer/utils/theme/custom/input_decoration_theme.dart';
import 'package:finco_customer/utils/theme/custom/list_tile_theme.dart';
import 'package:finco_customer/utils/theme/custom/outlined_button_theme.dart';
import 'package:finco_customer/utils/theme/custom/snacker_bar_theme.dart';
import 'package:finco_customer/utils/theme/custom/switch_theme.dart';
import 'package:finco_customer/utils/theme/custom/tab_bar_theme.dart';
import 'package:finco_customer/utils/theme/custom/text_button_theme.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ColorScheme get _colorScheme => const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primarySoft,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.fincoTeal,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondary,
        onSecondaryContainer: AppColors.primary,
        tertiary: AppColors.success,
        onTertiary: AppColors.white,
        tertiaryContainer: AppColors.successSoft,
        onTertiaryContainer: AppColors.success,
        error: AppColors.danger,
        errorContainer: AppColors.dangerSoft,
        onErrorContainer: AppColors.danger,
        onSurface: AppColors.fg,
        onSurfaceVariant: AppColors.fgMuted,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        surfaceContainerLowest: AppColors.bg,
        surfaceContainerLow: AppColors.bgElevated,
        surfaceContainer: AppColors.bgSubtle,
        surfaceContainerHigh: AppColors.bgSubtle,
        surfaceContainerHighest: AppColors.bgSubtle,
        inverseSurface: AppColors.fg,
        onInverseSurface: AppColors.white,
        inversePrimary: AppColors.primarySoft,
        scrim: AppColors.scrim,
        shadow: AppColors.shadow,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppTypography.fontFamily,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.bg,
        canvasColor: AppColors.bg,
        cardColor: AppColors.bgElevated,
        dividerColor: AppColors.border,
        disabledColor: AppColors.fgMuted,
        hintColor: AppColors.fgMuted,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        textTheme: AppTypography.lightTextTheme,
        primaryTextTheme: AppTypography.lightTextTheme.apply(
          bodyColor: AppColors.white,
          displayColor: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.fg, size: 20),
        primaryIconTheme: const IconThemeData(color: AppColors.white, size: 20),
        inputDecorationTheme: AppInputDecoration.getLightTheme,
        elevatedButtonTheme: AppElevatedButtonTheme.getLightTheme,
        outlinedButtonTheme: AppOutlinedButtonTheme.lightTheme,
        textButtonTheme: AppTextButtonTheme.lightTheme,
        filledButtonTheme: AppFilledButtonTheme.lightTheme,
        appBarTheme: AppAppBarTheme.lightAppBarTheme,
        dialogTheme: AppDialogTheme.lightTheme,
        tabBarTheme: AppTabBarTheme.lightTheme,
        snackBarTheme: AppSnackerBarTheme.lightTheme,
        chipTheme: AppChipTheme.lightTheme,
        switchTheme: AppSwitchTheme.lightTheme,
        bottomNavigationBarTheme: AppBottomNavTheme.lightTheme,
        navigationBarTheme: AppBottomNavTheme.materialLightTheme,
        cardTheme: AppCardTheme.lightTheme,
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        listTileTheme: AppListTileTheme.lightTheme,
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.bg;
          }),
          checkColor: WidgetStateProperty.all(AppColors.white),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXs),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.fgMuted;
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: CircleBorder(),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.primarySoft,
          circularTrackColor: AppColors.primarySoft,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.bgElevated,
          surfaceTintColor: Colors.transparent,
          modalBarrierColor: AppColors.scrim,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXl),
            ),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.bgElevated,
          surfaceTintColor: Colors.transparent,
          textStyle: AppTypography.body,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AppColors.fg,
            borderRadius: BorderRadius.circular(AppSizes.radiusBadge),
          ),
          textStyle: AppTypography.caption.copyWith(color: AppColors.white),
        ),
        badgeTheme: const BadgeThemeData(
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColors.fg,
            backgroundColor: AppColors.bg,
            side: const BorderSide(color: AppColors.border),
            shape: const CircleBorder(),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.primarySoft,
          thumbColor: AppColors.primary,
          overlayColor: Color(0x29FF5A5F),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.border),
          radius: Radius.circular(AppSizes.radiusPill),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColors.bg,
          headerBackgroundColor: AppColors.primary,
          headerForegroundColor: AppColors.white,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }
            return AppColors.fg;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
          todayBorder: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
        ),
      );
}
