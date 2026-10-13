import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopSnackbar {
  static OverlayEntry? _entry;

  /// Show snackbar. Prefer passing if you have a global navigator key.
  static void show(
    BuildContext context,
    Widget child, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Prefer explicit navKey overlay (most reliable)
      final overlay = navigatorKey.currentState?.overlay ??
          Overlay.of(context, rootOverlay: true);

      // remove existing then insert new
      _remove();

      _entry = OverlayEntry(
        builder: (_) => _TopSnackbarWidget(
          duration: duration,
          onRequestClose: _remove,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingHoriz,
                vertical: AppSizes.sm,
              ),
              child: child,
            ),
          ),
        ),
      );

      overlay.insert(_entry!);
    });
  }

  static void _remove() {
    _entry?.remove();
    _entry = null;
  }

  // convenience builders
  static Widget error(String message) => _defaultContainer(
        message,
        color: AppColors.white,
        containerColor: AppColors.danger,
        icon: Icons.cancel_outlined,
      );

  static Widget success(String message) => _defaultContainer(
        message,
        color: AppColors.white,
        containerColor: AppColors.success,
        icon: Icons.check_circle_rounded,
      );

  static Widget info(String message) => _defaultContainer(
        message,
        color: AppColors.white,
        containerColor: AppColors.fg,
        icon: Icons.info_rounded,
      );

  static Widget _defaultContainer(
    String message, {
    required Color color,
    required Color containerColor,
    required IconData icon,
  }) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingHoriz,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 12.w),
            Expanded(
              child: AutoSizeText(
                message,
                style: navigatorKey.currentContext!.textTheme.bodySmall
                    ?.copyWith(color: color),
              ),
            ),
            FilledButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingHoriz,
                  vertical: AppSizes.sm,
                ),
                textStyle: navigatorKey.currentContext!.textTheme.bodyMedium
                    ?.copyWith(color: color),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _remove,
              child: Text(
                'OK',
                style: AppTypography.lightTextTheme.labelMedium
                    ?.copyWith(color: AppColors.fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSnackbarWidget extends StatefulWidget {
  const _TopSnackbarWidget({
    required this.child,
    required this.onRequestClose,
    required this.duration,
  });
  final Widget child;
  final VoidCallback onRequestClose;
  final Duration duration;

  @override
  State<_TopSnackbarWidget> createState() => _TopSnackbarWidgetState();
}

class _TopSnackbarWidgetState extends State<_TopSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offset =
        Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOutQuart,
      ),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutQuart,
    );

    // start show animation
    unawaited(_ctrl.forward());

    // schedule auto-close: wait [duration], then reverse animation, then request close
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _ctrl.reverse();
      if (mounted) widget.onRequestClose();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Container(
        width: double.infinity,
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(opacity: _fade, child: widget.child),
        ),
      ),
    );
  }
}
