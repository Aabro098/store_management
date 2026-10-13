import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/models/notification_model.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    required this.notification,
    super.key,
  });
  final NotificationModel notification;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: AppSizes.paddingHoriz,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.xs),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.smMd),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: notification.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  size: 16.sp,
                  color: notification.iconColor,
                ),
              ),
              SizedBox(width: AppSizes.smMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            formatTitle(notification.type),
                            style: context.textTheme.titleMedium?.copyWith(
                              color: AppColors.fg,
                            ),
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () {},
                        //   child: Icon(
                        //     notification.isUnread
                        //         ? Icons.check
                        //         : Icons.done_all,
                        //     size: 18.sp,
                        //     color: AppColors.primary,
                        //   ),
                        // ),
                        if (notification.isUnread) ...[
                          SizedBox(width: AppSizes.smMd),
                          Container(
                            width: 8.w,
                            height: 8.h,
                            margin: EdgeInsets.only(top: 6.h),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      notification.description,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: AppSizes.xs),
                    Text(
                      notification.time,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
