import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({required this.onTap, this.title, super.key});

  final VoidCallback onTap;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back, size: AppSizes.iconSm),
          SizedBox(width: AppSizes.sm),
          Text(title ?? 'Back', style: context.textTheme.titleLarge),
        ],
      ),
    );
  }
}
