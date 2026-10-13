import 'package:dio/dio.dart';
import 'package:finco_customer/common/widgets/custom_button.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/providers/user_provider.dart';
import 'package:finco_customer/screens/Auth/login_screen.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:finco_customer/utils/helpers/provider_reset.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountDialogContent extends StatefulWidget {
  const DeleteAccountDialogContent({super.key});

  @override
  State<DeleteAccountDialogContent> createState() =>
      _DeleteAccountDialogContentState();
}

class _DeleteAccountDialogContentState
    extends State<DeleteAccountDialogContent> {
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final name =
      navigatorKey.currentContext?.read<UserProvider>().user?.clientName;

  bool _isDeleting = false;

  bool get _hasTypedName => _nameController.text.trim() == name;

  // bool get _canSubmit =>
  //     _hasTypedDelete && _passwordController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    // _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    // if (!_canSubmit || _isDeleting) return;
    if (_isDeleting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isDeleting = true);
    try {
      await context
          .read<AuthProvider>()
          .deactivateAccount(confirmName: _nameController.text.trim());
      if (!mounted) return;
      resetSessionProviders(context);
      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (route) => false,
      );
    } on DioException catch (e) {
      showErrorSnackbar(DioClient.parseDioError(e));
    } on Exception {
      showErrorSnackbar('Failed to delete account. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.md),
        ),
        title: Text(
          'Delete Account?',
          style: context.textTheme.titleLarge?.copyWith(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "This will delete your account and sign you out everywhere. You won't be able to log in again unless an admin or your supervisor restores access.",
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: AppSizes.md),
              Text(
                'Type your name ($name) to confirm',
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: AppSizes.md),
              TextField(
                controller: _nameController,
                enabled: !_isDeleting,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Type $name',
                ),
              ),
              // ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  color: AppColors.fg,
                  onPressed: () {
                    navigatorKey.currentState?.pop();
                  },
                  label: 'Cancel',
                  isDisabled: _isDeleting,
                  isLoading: _isDeleting,
                ),
              ),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: CustomElevatedButton(
                  onPressed: !_isDeleting ? _deleteAccount : null,
                  label: 'Delete',
                  color: AppColors.danger,
                  isDisabled: !_hasTypedName || _isDeleting,
                  isLoading: _isDeleting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
