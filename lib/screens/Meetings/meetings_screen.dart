import 'package:finco_customer/common/widgets/loading_indicator.dart';
import 'package:finco_customer/common/widgets/meeting_card.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/models/meeting_model.dart';
import 'package:finco_customer/providers/meeting_provider.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeetingProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        for (final status in MeetingStatus.values) {
          await provider.fetchItems(status);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSizes.md),
            Text(
              'SCHEDULE',
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.fgMuted,
                letterSpacing: 1.2,
                fontSize: AppSizes.fontMd,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Meetings',
              style: context.textTheme.headlineMedium,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Upcoming and past meetings with your assigned team.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgMuted,
                fontSize: AppSizes.fontSm,
              ),
            ),
            for (final status in MeetingStatus.values) ...[
              SizedBox(height: AppSizes.lg),
              _buildStatusSection(context, provider, status),
            ],
            SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    MeetingProvider provider,
    MeetingStatus status,
  ) {
    final items = provider.itemsForStatus(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status.title,
          style: context.textTheme.titleLarge,
        ),
        SizedBox(height: AppSizes.smMd),
        _buildStatusContent(context, provider, status, items),
      ],
    );
  }

  Widget _buildStatusContent(
    BuildContext context,
    MeetingProvider provider,
    MeetingStatus status,
    List<MeetingModel> items,
  ) {
    final isLoading = provider.isLoadingFor(status);
    final isLoadingMore = provider.isLoadingMoreFor(status);
    final error = provider.errorMessageFor(status);

    if (isLoading && items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: const LoadingIndicator(),
      );
    }

    if (error != null && items.isEmpty) {
      return Column(
        children: [
          Text(
            error,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: AppColors.fgMuted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.smMd),
          Center(
            child: TextButton(
              onPressed: () => provider.fetchItems(status),
              child: Text(
                'Retry',
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (items.isEmpty) {
      return noMeeting(
        title: _emptyTitleFor(status),
        message: _emptyMessageFor(status),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: AppSizes.smMd),
          MeetingCard(meeting: items[i]),
        ],
        if (provider.hasMoreFor(status) || isLoadingMore) ...[
          SizedBox(height: AppSizes.smMd),
          Center(
            child: _SeeMoreButton(
              isLoading: isLoadingMore,
              onTap: () => provider.fetchItems(status, loadMore: true),
            ),
          ),
        ],
      ],
    );
  }

  String _emptyTitleFor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.scheduled:
        return 'Nothing scheduled';
      case MeetingStatus.completed:
        return 'No completed meetings';
      case MeetingStatus.cancelled:
        return 'No cancelled meetings';
    }
  }

  String _emptyMessageFor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.scheduled:
        return 'No upcoming meetings on your calendar';
      case MeetingStatus.completed:
        return 'Meetings you have attended will show up here';
      case MeetingStatus.cancelled:
        return 'Cancelled meetings will show up here';
    }
  }

  Widget noMeeting({
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingHoriz,
        vertical: AppSizes.paddingVert,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.smMd),
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.calendar,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SeeMoreButton extends StatelessWidget {
  const _SeeMoreButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppSizes.smMd),
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade100 : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 14.sp,
                height: 14.sp,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppSizes.sm),
            ] else
              Icon(Iconsax.arrow_down, size: 16.sp, color: AppColors.primary),
            SizedBox(width: AppSizes.sm),
            Text(
              isLoading ? 'Loading...' : 'See more',
              style: context.textTheme.labelMedium?.copyWith(
                color: isLoading ? AppColors.fgMuted : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
