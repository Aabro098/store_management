import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/models/meeting_model.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class MeetingCard extends StatelessWidget {
  const MeetingCard({required this.meeting, super.key});

  final MeetingModel meeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.smMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meeting.title,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.fg,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (meeting.scheduledAt != null &&
              meeting.scheduledAt!.isNotEmpty) ...[
            SizedBox(height: AppSizes.xs),
            Text(
              meeting.scheduledAt!,
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.fgMuted,
              ),
            ),
          ],
          if (meeting.description.isNotEmpty) ...[
            SizedBox(height: AppSizes.sm),
            Text(
              meeting.description,
              style: context.textTheme.labelMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: AppSizes.smMd),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: meeting.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  meeting.status,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: meeting.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (meeting.durationMinutes > 0) ...[
                SizedBox(width: AppSizes.sm),
                Text(
                  '${meeting.durationMinutes} min',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
          if (meeting.location != null && meeting.location!.isNotEmpty) ...[
            SizedBox(height: AppSizes.smMd),
            Row(
              children: [
                Icon(Iconsax.location, size: 16.sp, color: AppColors.fgMuted),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    meeting.location!,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: AppColors.fgMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
          // if (meeting.meetingLink != null &&
          //     meeting.meetingLink!.isNotEmpty) ...[
          //   SizedBox(height: AppSizes.smMd),
          //   GestureDetector(
          //     onTap: () {},
          //     child: Row(
          //       children: [
          //         Icon(Iconsax.video, size: 16.sp, color: AppColors.primary),
          //         SizedBox(width: AppSizes.sm),
          //         Text(
          //           'Join Meeting',
          //           style: context.textTheme.labelMedium?.copyWith(
          //             color: AppColors.primary,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}
