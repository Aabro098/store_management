import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 20.w,
        width: 20.h,
        child: CircularProgressIndicator(
          color: context.colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
