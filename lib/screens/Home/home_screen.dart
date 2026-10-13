import 'dart:async';

import 'package:finco_customer/common/widgets/loading_indicator.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/models/daily_submission_model.dart';
import 'package:finco_customer/models/meeting_model.dart';
import 'package:finco_customer/providers/dashboard_provider.dart';
import 'package:finco_customer/providers/index_provider.dart';
import 'package:finco_customer/providers/meeting_provider.dart';
import 'package:finco_customer/providers/user_provider.dart';
import 'package:finco_customer/screens/Work/upload_documents_dialog.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:finco_customer/utils/helpers/style_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class WorkCountDataModel {
  WorkCountDataModel({
    required this.title,
    required this.value,
    this.color,
  });

  final String title;
  final int value;
  final Color? color;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MeetingProvider>();
      for (final status in MeetingStatus.values) {
        if (provider.itemsForStatus(status).isEmpty) {
          unawaited(provider.fetchItems(status));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final meetingProvider = context.watch<MeetingProvider>();

    final summary = dashboardProvider.summary;
    final today = todayFormatted();
    final workDetailsCount = [
      WorkCountDataModel(
        title: 'PENDING DOCS',
        value: summary?.pendingDocs ?? 0,
      ),
      WorkCountDataModel(title: 'OPEN WORK', value: summary?.activeWork ?? 0),
      WorkCountDataModel(
        title: 'ALERTS',
        value: (summary?.overdue ?? 0) + (summary?.unreadNotifications ?? 0),
        color: AppColors.danger,
      ),
    ];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSizes.md),
          Text(
            today,
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.fgMuted,
            ),
          ),
          SizedBox(height: AppSizes.sm),
          Text(
            userProvider.user?.businessName ?? 'N/A',
            style: context.textTheme.displayLarge,
          ),
          SizedBox(height: AppSizes.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...workDetailsCount.asMap().entries.map((entry) {
                final index = entry.key;
                final detail = entry.value;

                return Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: countValue(detail: detail),
                      ),
                      if (index < workDetailsCount.length - 1)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSizes.smMd),
                          child: Container(
                            color: AppColors.border,
                            height: 72.h,
                            width: 1.w,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: AppSizes.lg),
          updateTodayDocuments(),
          SizedBox(height: AppSizes.lg),
          titleValue(
            title: 'Next Meeting',
            value: 'All Meetings',
            onTap: () {
              context.read<IndexProvider>().index = 2;
            },
          ),
          SizedBox(height: AppSizes.md),
          _nextMeetingSection(meetingProvider),
          SizedBox(height: AppSizes.lg),
          titleValue(
            title: 'Document follow-ups',
            value: 'Documents',
            onTap: () {
              context.read<IndexProvider>().index = 1;
            },
          ),
          SizedBox(height: AppSizes.md),
          documentsWidget(),
        ],
      ),
    );
  }

  Column countValue({required WorkCountDataModel detail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.value.toString(),
          style: context.textTheme.displayLarge
              ?.copyWith(fontSize: 32.sp, color: detail.color),
        ),
        Text(
          detail.title,
          style: context.textTheme.labelMedium
              ?.copyWith(color: AppColors.fgMuted, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget updateTodayDocuments() {
    final today = todayFormatted();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await showCurvedDialog<void>(
          context: context,
          child: UploadDocumentsDialog(
            selectedDate: DateTime.now(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingHoriz,
          vertical: AppSizes.paddingVert,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.lg),
          color: AppColors.fincoOrange,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingHoriz,
                vertical: AppSizes.paddingVert,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withAlpha(32),
              ),
              child: const Icon(
                Iconsax.document_upload,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: AppSizes.smMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload today's documents",
                    style: context.textTheme.headlineSmall
                        ?.copyWith(color: AppColors.white),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    today,
                    style: context.textTheme.titleSmall
                        ?.copyWith(color: AppColors.white.withAlpha(212)),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.smMd),
            Icon(
              Icons.arrow_forward,
              color: AppColors.white.withAlpha(212),
            ),
          ],
        ),
      ),
    );
  }

  Widget titleValue({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.textTheme.titleLarge,
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            value,
            style: context.textTheme.titleMedium
                ?.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _nextMeetingSection(MeetingProvider meetingProvider) {
    if (meetingProvider.itemsForStatus(MeetingStatus.scheduled).isEmpty) {
      return noMeeting();
    }
    return nextMeeting(
      meeting: meetingProvider.itemsForStatus(MeetingStatus.scheduled).first,
    );
  }

  Widget noMeeting() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Text(
        'No meetings scheduled.',
        style: context.textTheme.bodyMedium?.copyWith(color: AppColors.fgMuted),
      ),
    );
  }

  Container nextMeeting({required MeetingModel meeting}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingHoriz,
        vertical: AppSizes.paddingVert,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.elevation,
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                getWeekdayShort(meeting.scheduledAt ?? ''),
                style: context.textTheme.bodySmall,
              ),
              Text(
                getDay(meeting.scheduledAt ?? ''),
                style: context.textTheme.headlineMedium,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.smMd),
            child: Container(
              width: 2.w,
              height: 42.h,
              color: AppColors.border,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meeting.title,
                style: context.textTheme.titleMedium,
              ),
              Text(
                meeting.scheduledAt ?? 'N/A',
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget documentsWidget() {
    final dashboardProvider = context.watch<DashboardProvider>();
    final documents = dashboardProvider.pendingDocuments;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingHoriz,
        vertical: AppSizes.paddingVert,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.elevation,
      ),
      child: Column(
        children: [
          if (dashboardProvider.isDocumentsLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.smMd),
              child: const LoadingIndicator(),
            )
          else if (documents.isNotEmpty)
            ...List.generate(
              documents.length,
              (index) => Column(
                children: [
                  documentRow(documents[index]),
                  if (index != documents.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.smMd),
                      child: const Divider(color: AppColors.border),
                    ),
                ],
              ),
            )
          else
            Text(
              "No documents follow up. You're clear.",
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.fgMuted),
            ),
        ],
      ),
    );
  }

  Widget documentRow(DailySubmissionModel submission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pending Submission',
                style: context.textTheme.titleLarge,
              ),
            ),
            SizedBox(width: AppSizes.md),
            const SizedBox(
              height: 8,
              width: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.fincoOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.xs),
        Text(
          formatDateString(submission.dateKey),
          style: context.textTheme.bodySmall?.copyWith(color: AppColors.fg),
        ),
      ],
    );
  }
}
