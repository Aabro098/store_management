import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    required this.title,
    required this.content,
    required this.actionsBuilder,
    super.key,
  });

  /// Title for the dialog
  final String title;

  /// Icon leading of Title Text
  // final IconData titleIcon;

  /// Content for the dialog
  final String content;

  /// Check if dialog is critical and if so, color & title and icon red
  // final bool isCritical;

  /// List of actions for the dialog
  final Widget Function(BuildContext context) actionsBuilder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        constraints: BoxConstraints(
          maxWidth: context.width * 0.9,
          minWidth: context.width * 0.8,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingHoriz,
          vertical: AppSizes.paddingVert,
        ),
        titlePadding: EdgeInsets.all(AppSizes.md),
        actionsPadding: EdgeInsets.all(AppSizes.md),
        title: Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(color: AppColors.fg),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(color: AppColors.fg),
        ),
        actions: [
          actionsBuilder(context),
        ],
      ),
    );
  }
}
