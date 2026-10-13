import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    required this.label,
    required this.isDisabled,
    required this.isLoading,
    required this.onPressed,
    this.icon,
    this.color,
    this.showGradient,
    super.key,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final Color? color;
  final bool? showGradient;

  @override
  Widget build(BuildContext context) {
    final background = color ?? AppColors.primary;

    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        disabledBackgroundColor: background.withValues(alpha: 0.4),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && !isLoading) ...[
              Icon(icon, size: 16.sp, color: AppColors.white),
              SizedBox(width: 8.w),
            ],
            if (isLoading) ...[
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              context.tr(label),
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
