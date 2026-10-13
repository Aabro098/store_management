import 'dart:async';

import 'package:dio/dio.dart';
import 'package:finco_customer/common/widgets/delete_account_content.dart';
import 'package:finco_customer/common/widgets/version_number.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/providers/notification_provider.dart';
import 'package:finco_customer/providers/user_provider.dart';
import 'package:finco_customer/screens/Auth/login_screen.dart';
import 'package:finco_customer/screens/Profile/change_password.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/image_strings.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:finco_customer/utils/helpers/provider_reset.dart';
import 'package:finco_customer/utils/helpers/style_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class AccountModel {
  AccountModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
    this.hasSwitch,
    this.switchValue = false,
    this.onSwitchChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool? hasSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        context.read<NotificationProvider>().loadPushNotificationSetting(),
      );
    });
  }

  Future<void> _setPushNotificationsEnabled(bool isEnabled) async {
    final didUpdate = await context
        .read<NotificationProvider>()
        .setPushNotificationsEnabled(isEnabled: isEnabled);
    if (!mounted || didUpdate) return;
    showErrorSnackbar(
      isEnabled
          ? 'Enable notifications in system settings and try again.'
          : 'Notifications could not be turned off. Please try again.',
    );
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.logout();
      if (!mounted) return;
      resetSessionProviders(context);

      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (route) => false,
      );
    } on DioException catch (e) {
      final errorMessage = DioClient.parseDioError(e);
      showErrorSnackbar(errorMessage);
    } on Exception {
      showErrorSnackbar('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final detailsValue = [
      {
        'title': 'Phone',
        'value': userProvider.user?.phone ?? 'N/A',
      },
      {
        'title': 'Company',
        'value': userProvider.user?.businessName ?? 'N/A',
      },
      {
        'title': 'PAN / VAT',
        'value': userProvider.user?.panVat ?? 'N/A',
      },
      {
        'title': 'Nature',
        'value': userProvider.user?.nature ?? 'N/A',
      },
      {
        'title': 'Business email',
        'value': userProvider.user?.businessEmail ?? 'N/A',
      }
    ];

    final notificationsValue = [
      AccountModel(
        title: 'Notifications',
        subtitle: notificationProvider.arePushNotificationsEnabled
            ? 'Alerts for work, documents, and meetings'
            : 'All notifications are off',
        icon: Iconsax.notification,
        hasSwitch: true,
        switchValue: notificationProvider.arePushNotificationsEnabled,
        onSwitchChanged: notificationProvider.isUpdatingPushNotifications
            ? null
            : (isEnabled) {
                unawaited(_setPushNotificationsEnabled(isEnabled));
              },
        onTap: () {},
      ),
    ];

    final accountDetailsValue = [
      AccountModel(
        title: 'Change Password',
        subtitle: 'Update your login password',
        icon: Iconsax.key,
        onTap: () async {
          await navigatorKey.currentState
              ?.pushNamed(ChangePasswordScreen.routeName);
        },
      ),
      AccountModel(
        title: 'Sign out',
        subtitle: 'You will be returned to the login screen',
        icon: Iconsax.logout,
        color: AppColors.danger,
        onTap: () async {
          await showCurvedDialog<Widget>(
            context: context,
            child: showLogoutAppDialog(
              context,
              onLogout: () async {
                await _handleLogout();
              },
            ),
          );
        },
      ),
      AccountModel(
        title: 'Delete Account',
        subtitle: "You won't be able to log in until an admin restores access",
        icon: Iconsax.trash,
        color: AppColors.danger,
        onTap: () async {
          await showCurvedDialog<Widget>(
            context: context,
            child: const DeleteAccountDialogContent(),
          );
        },
      ),
    ];

    final privacyPolicy = [
      AccountModel(
        title: 'Privacy Policy',
        subtitle: 'How we collect and use your data',
        icon: Iconsax.security,
        onTap: () async {
          await launchUrlString(
            'https://finco-customer.margintopsolutions.com.np/privacy-policy',
          );
        },
      ),
      AccountModel(
        title: 'Terms & Conditions',
        subtitle: 'Rules and conditions for using our app',
        icon: Iconsax.document_text,
        onTap: () async {},
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: AppSizes.md),
          profileTile(userProvider: userProvider),
          SizedBox(height: AppSizes.lg),
          detailsSection(detailsValue),
          SizedBox(height: AppSizes.lg),
          accountSection(
            accountDetailsValue: notificationsValue,
            title: 'NOTIFICATIONS',
          ),
          SizedBox(height: AppSizes.lg),
          accountSection(
            accountDetailsValue: privacyPolicy,
            title: 'SECURITY',
          ),
          SizedBox(height: AppSizes.lg),
          accountSection(
            accountDetailsValue: accountDetailsValue,
            title: 'ACCOUNT',
          ),
          SizedBox(height: AppSizes.lg),
          const VersionNumber(),
          SizedBox(height: AppSizes.lg),
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              AppImages.fincoLogo,
              width: 92.w,
            ),
          ),
        ],
      ),
    );
  }

  Container profileTile({required UserProvider userProvider}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppShadows.elevation,
        color: AppColors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingHoriz,
              vertical: AppSizes.paddingVert,
            ),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft,
            ),
            child: Text(
              'NS',
              style: context.textTheme.titleLarge
                  ?.copyWith(color: AppColors.primary),
            ),
          ),
          SizedBox(width: AppSizes.paddingHoriz),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProvider.user?.clientName ?? 'N/A',
                style: context.textTheme.headlineSmall,
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                userProvider.user?.clientEmail ?? 'N/A',
                style: context.textTheme.titleSmall
                    ?.copyWith(color: AppColors.fgMuted),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                userProvider.user?.businessName ?? 'N/A',
                style: context.textTheme.titleSmall
                    ?.copyWith(color: AppColors.fgMuted.withAlpha(200)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget detailsSection(List<Map<String, String>> detailsValue) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppShadows.elevation,
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETAILS',
            style: context.textTheme.titleSmall
                ?.copyWith(color: AppColors.fgMuted, letterSpacing: 1.3),
          ),
          SizedBox(height: AppSizes.md),
          ...detailsValue.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;

            return Column(
              children: [
                details(
                  title: detail['title']!,
                  value: detail['value']!,
                ),
                if (index < detailsValue.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.smMd),
                    child: const Divider(color: AppColors.border),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget details({
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 172.w,
          child: Text(
            title,
            style: context.textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: AppSizes.paddingHoriz),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyLarge,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget accountSection({
    required List<AccountModel> accountDetailsValue,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppShadows.elevation,
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall
                ?.copyWith(color: AppColors.fgMuted, letterSpacing: 1.3),
          ),
          SizedBox(height: AppSizes.md),
          ...accountDetailsValue.asMap().entries.map((entry) {
            final index = entry.key;
            final account = entry.value;

            return Column(
              children: [
                accountDetailsTile(account: account),
                if (index < accountDetailsValue.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.smMd),
                    child: const Divider(color: AppColors.border),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget accountDetailsTile({required AccountModel account}) {
    return GestureDetector(
      onTap: (account.hasSwitch ?? false) ? null : account.onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            padding: EdgeInsets.all(AppSizes.xs),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: account.color != null
                  ? account.color?.withAlpha(32)
                  : AppColors.primarySoft,
            ),
            child: Icon(
              account.icon,
              color: account.color ?? AppColors.primary,
            ),
          ),
          SizedBox(width: AppSizes.md),
          SizedBox(
            width: account.hasSwitch ?? false ? 192.w : 200.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.title,
                  style: context.textTheme.titleMedium
                      ?.copyWith(color: account.color),
                ),
                SizedBox(height: AppSizes.xs),
                Text(
                  account.subtitle,
                  style: context.textTheme.bodySmall
                      ?.copyWith(fontSize: AppSizes.fontXs),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.md),
          const Spacer(),
          if (account.hasSwitch ?? false) ...[
            Switch(
              value: account.switchValue,
              onChanged: account.onSwitchChanged,
            ),
          ] else ...[
            Icon(
              Icons.arrow_forward_ios,
              size: AppSizes.iconXs,
              color: AppColors.fgMuted,
            ),
          ],
        ],
      ),
    );
  }
}
