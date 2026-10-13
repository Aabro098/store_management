import 'dart:io';
import 'package:finco_customer/common/widgets/custom_alert_dialog.dart';
import 'package:finco_customer/common/widgets/custom_button.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:flutter/material.dart';

Future<T?> showCurvedDialog<T>({
  required BuildContext context,
  required Widget child,
  Duration transitionDuration = const Duration(milliseconds: 250),
  Curve curve = Curves.easeOutQuart,
  Curve reverseCurve = Curves.easeOutQuart,
}) {
  return showGeneralDialog(
    context: context,
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => PopScope(
      canPop: false,
      child: child,
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(
              begin: 0.90,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: curve,
                reverseCurve: reverseCurve,
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            ),
          ),
        ],
      );
    },
  );
}

CustomAlertDialog showExitAppDialog(BuildContext context) {
  return CustomAlertDialog(
    title: 'Exit App?',
    content: 'Are you sure you want to exit the app?',
    actionsBuilder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: AppSizes.sm,
        children: [
          Expanded(
            child: CustomElevatedButton(
              color: AppColors.fg,
              onPressed: () {
                navigatorKey.currentState!.pop();
              },
              isDisabled: false,
              isLoading: false,
              label: 'Cancel',
              showGradient: false,
            ),
          ),
          Expanded(
            child: CustomElevatedButton(
              color: AppColors.danger,
              onPressed: () {
                exit(0);
              },
              isDisabled: false,
              isLoading: false,
              label: 'Exit',
            ),
          ),
        ],
      );
    },
  );
}

Widget showLogoutAppDialog(
  BuildContext context, {
  required Future<void> Function() onLogout,
}) {
  return _LogoutDialogContent(onLogout: onLogout);
}

class _LogoutDialogContent extends StatefulWidget {
  const _LogoutDialogContent({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<_LogoutDialogContent> createState() => _LogoutDialogContentState();
}

class _LogoutDialogContentState extends State<_LogoutDialogContent> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: CustomAlertDialog(
        title: 'Logout?',
        content: 'Are you sure you want to logout?',
        actionsBuilder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: AppSizes.sm,
            children: [
              Expanded(
                child: CustomElevatedButton(
                  color: AppColors.fg,
                  onPressed: _isLoading
                      ? null
                      : () {
                          navigatorKey.currentState!.pop();
                        },
                  label: 'Cancel',
                  isDisabled: _isLoading,
                  isLoading: false,
                ),
              ),
              Expanded(
                child: CustomElevatedButton(
                  color: AppColors.danger,
                  isLoading: _isLoading,
                  isDisabled: _isLoading,
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await widget.onLogout();
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  label: 'Logout',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget showDownloadFileDialog(
  BuildContext context, {
  required Future<void> Function() onDownload,
  required String fileName,
}) {
  return _DownloadFileDialogContent(
    onDownload: onDownload,
    fileName: fileName,
  );
}

class _DownloadFileDialogContent extends StatefulWidget {
  const _DownloadFileDialogContent({
    required this.onDownload,
    required this.fileName,
  });

  final Future<void> Function() onDownload;
  final String fileName;

  @override
  State<_DownloadFileDialogContent> createState() =>
      _DownloadFileDialogContentState();
}

class _DownloadFileDialogContentState
    extends State<_DownloadFileDialogContent> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: CustomAlertDialog(
        title: 'Download File?',
        content: 'Are you sure you want to download ${widget.fileName}?',
        actionsBuilder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: AppSizes.sm,
            children: [
              Expanded(
                child: CustomElevatedButton(
                  color: AppColors.fg,
                  onPressed: _isLoading
                      ? null
                      : () {
                          navigatorKey.currentState!.pop();
                        },
                  label: 'Cancel',
                  isDisabled: _isLoading,
                  isLoading: false,
                ),
              ),
              Expanded(
                child: CustomElevatedButton(
                  color: AppColors.danger,
                  isLoading: _isLoading,
                  isDisabled: _isLoading,
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            await widget.onDownload();
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  label: 'Download',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
