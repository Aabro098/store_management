import 'dart:async';

import 'package:dio/dio.dart';
import 'package:finco_customer/common/widgets/custom_button.dart';
import 'package:finco_customer/common/widgets/loading_indicator.dart';
import 'package:finco_customer/common/widgets/notification_card.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/providers/dashboard_provider.dart';
import 'package:finco_customer/providers/notification_provider.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/image_strings.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: NotificationTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markAllRead(
    BuildContext context,
    NotificationProvider provider,
  ) async {
    try {
      await provider.markAllRead();
      if (!context.mounted) return;
      context.read<DashboardProvider>().markAllNotificationsRead();
      showSuccessSnackbar('All notifications marked as read.');
    } on DioException catch (e) {
      showErrorSnackbar(DioClient.parseDioError(e));
    } on Object {
      showErrorSnackbar('Failed to mark all notifications as read.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final displayCount =
        (dashboardProvider.summary?.unreadNotifications ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              AppImages.fincoLogo,
              width: 120.w,
            ),
            SizedBox(width: AppSizes.paddingHoriz),
            Text(
              'Alerts',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(
                AppSizes.paddingHoriz,
                AppSizes.paddingVert,
                AppSizes.paddingHoriz,
                AppSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INBOX',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: AppColors.fgMuted,
                          letterSpacing: 1.2,
                          fontSize: AppSizes.fontMd,
                        ),
                      ),
                      SizedBox(height: AppSizes.sm),
                      Text(
                        'Alerts',
                        style: context.textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  SizedBox(width: AppSizes.smMd),
                  GestureDetector(
                    onTap: provider.isMarkingAllRead
                        ? null
                        : () => _markAllRead(context, provider),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.smMd,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          if (provider.isMarkingAllRead)
                            SizedBox(
                              width: AppSizes.sm,
                              height: AppSizes.sm,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          else
                            const Icon(Icons.done_all),
                          SizedBox(width: AppSizes.sm),
                          Text(
                            'Mark all',
                            style: context.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: AppSizes.paddingHoriz,
              ),
              child: Text(
                'Updates on work, documents and meetings.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.fgMuted,
                  fontSize: AppSizes.fontSm,
                ),
              ),
            ),
            SizedBox(height: AppSizes.md),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: AppSizes.paddingHoriz,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabAlignment: TabAlignment.fill,
                  tabs: NotificationTab.values
                      .map(
                        (tab) => Tab(
                          text: tab.label == 'Unread' && displayCount == true
                              ? 'Unread (${dashboardProvider.summary?.unreadNotifications})'
                              : tab.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: AppSizes.md),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: NotificationTab.values
                    .map((tab) => _NotificationList(tab: tab))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends StatefulWidget {
  const _NotificationList({required this.tab});

  final NotificationTab tab;

  @override
  State<_NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<_NotificationList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    final provider = context.read<NotificationProvider>();
    if (provider.itemsForTab(widget.tab).isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(provider.fetchItems(widget.tab));
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context
          .read<NotificationProvider>()
          .fetchItems(widget.tab, loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.itemsForTab(widget.tab);

    if (provider.isLoadingFor(widget.tab) && items.isEmpty) {
      return const LoadingIndicator();
    }

    if (provider.errorMessageFor(widget.tab) != null && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessageFor(widget.tab)!,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.fgMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.md),
            CustomElevatedButton(
              isDisabled: false,
              isLoading: false,
              onPressed: () =>
                  context.read<NotificationProvider>().fetchItems(widget.tab),
              label: 'Retry',
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.tab.label.toLowerCase()} alerts',
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.fgMuted,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<NotificationProvider>().fetchItems(widget.tab),
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: AppSizes.lg),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            items.length + (provider.isLoadingMoreFor(widget.tab) ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: AppSizes.smMd),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: const LoadingIndicator(),
            );
          }
          return NotificationCard(notification: items[index]);
        },
      ),
    );
  }
}
