import 'package:dio/dio.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/models/nav_bar_items.dart';
import 'package:finco_customer/providers/dashboard_provider.dart';
import 'package:finco_customer/providers/index_provider.dart';
import 'package:finco_customer/providers/user_provider.dart';
import 'package:finco_customer/screens/Notifications/notification_screen.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/image_strings.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:finco_customer/utils/helpers/style_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  static const String routeName = '/nav-screen';

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  late final List<NavTabItem> _items;
  late final List<GButton> _tabs;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _items = NavTabItem.pageList();

    _tabs = _items.map((item) {
      return GButton(
        icon: item.icon,
        text: item.label,
      );
    }).toList();

    _screens = _items.map((item) {
      return item.pageBuilder?.call() ?? const SizedBox.shrink();
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // INIT State after first frame is rendered
      // ignore: discarded_futures
      _getOwnDetails();
      context.read<DashboardProvider>()
        ..fetchDashboardSummary()
        ..fetchPendingDocuments();
    });
  }

  Future<void> _getOwnDetails() async {
    final userProvider = context.read<UserProvider>();
    try {
      await userProvider.fetchUser();
    } on DioException catch (e) {
      final errorMessage = DioClient.parseDioError(e);
      showErrorSnackbar(errorMessage);
    } on Exception {
      showErrorSnackbar('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<IndexProvider>().index;
    final dashboardProvider = context.watch<DashboardProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (selectedIndex != 0) {
          context.read<IndexProvider>().index = 0;
          return;
        } else {
          if (didPop) return;
          await showCurvedDialog<Widget>(
            context: context,
            child: showExitAppDialog(context),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                AppImages.fincoLogo,
                width: 120.w,
              ),
              SizedBox(width: AppSizes.paddingHoriz),
              Text(
                _items[selectedIndex].label,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await navigatorKey.currentState
                    ?.pushNamed(NotificationScreen.routeName);
              },
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: AppSizes.paddingHoriz),
                    child: GestureDetector(
                      child: Icon(
                        Iconsax.notification,
                        size: AppSizes.iconMd,
                      ),
                    ),
                  ),
                  if ((dashboardProvider.summary?.unreadNotifications ?? 0) >
                      0) ...[
                    Positioned(
                      top: 0,
                      right: AppSizes.md,
                      child: Container(
                        height: AppSizes.smMd,
                        width: 12.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.error,
                        ),
                        child: Center(
                          child: Text(
                            (dashboardProvider.summary?.unreadNotifications ??
                                    0)
                                .toString(),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontSize: 8.sp,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.paddingHoriz,
              0,
              AppSizes.paddingHoriz,
              AppSizes.smMd,
            ),
            child: SizedBox.expand(
              child: IndexedStack(
                index: selectedIndex,
                children: _screens,
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingHoriz,
                  vertical: 6.h,
                ),
                child: RepaintBoundary(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fg,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: GNav(
                      gap: AppSizes.sm,
                      tabBorderRadius: 100.r,
                      activeColor: AppColors.white,
                      color: Colors.grey.shade300,
                      tabBackgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.smMd,
                      ),
                      textSize: 12.sp,
                      iconSize: AppSizes.iconMd,
                      textStyle: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                      selectedIndex: selectedIndex,
                      haptic: false,
                      onTabChange: (index) {
                        context.read<IndexProvider>().index = index;
                      },
                      tabs: _tabs,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
