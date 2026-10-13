import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  AppSizes._();

  // Spacing
  static double get xs => 4.h;
  static double get sm => 8.h;
  static double get smMd => 12.h;
  static double get md => 16.h;
  static double get lg => 24.h;
  static double get xl => 32.h;

  /// Screen gutter — DESIGN.md main padding `px-4 py-5`
  static double get paddingHoriz => 16.w;
  static double get paddingVert => 20.h;
  static double get formHeight => 12.h;
  static double get sectionGap => 20.h;
  static double get listGap => 12.h;

  // Icons
  static double get iconXs => 12.sp;
  static double get iconSm => 16.sp;
  static double get iconMd => 20.sp;
  static double get iconLg => 32.sp;
  static double get iconXl => 42.sp;

  // Radius — DESIGN.md §Spacing & radius
  static double get radiusXs => 8.r; // radius-sm — small chips
  static double get radiusBadge => 8.r; // compact chips / tooltips
  static double get radiusSm => 12.r; // radius-md — compact controls
  static double get radiusMd => 16.r; // radius-lg — buttons default
  static double get radiusLg => 20.r; // radius-xl — large controls
  static double get radiusXl => 24.r; // radius-2xl — cards, dialogs
  static double get radiusXXl => 28.r; // larger surfaces
  static double get radiusXXXl => 32.r; // profile / settings groups
  static double get radiusPill => 999.r; // pills

  // Type scale (UI.md §3.3)
  static double get nav => 10.sp;
  static double get micro => 11.sp;
  static double get fontXs => 12.sp;
  static double get fontSm => 14.sp;
  static double get fontMd => 15.sp;
  static double get fontBase => 16.sp;
  static double get fontLg => 18.sp;
  static double get fontXl => 20.sp;
  static double get fontXXl => 26.sp;
  static double get fontXXXl => 28.sp;

  static double get buttonHeight => 44.h;
  static double get switchHeight => 28.h;
  static double get switchWidth => 48.w;
}
