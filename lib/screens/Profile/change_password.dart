import 'package:dio/dio.dart';
import 'package:finco_customer/common/widgets/custom_button.dart';
import 'package:finco_customer/common/widgets/text_form_field.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/screens/Auth/login_screen.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/Validators/validator.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/image_strings.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:finco_customer/utils/helpers/provider_reset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static const String routeName = '/change-password';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _handleChangePassword() async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.changePassword(
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      if (!mounted) return;
      resetSessionProviders(context);
      showSuccessSnackbar(
        'Password changed successfully. Please log in again.',
      );
      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (_) => false,
      );
    } on DioException catch (e) {
      final errorMessage = DioClient.parseDioError(e);
      showErrorSnackbar(errorMessage);
    } on Exception {
      showErrorSnackbar('An unexpected error occurred. Please try again.');
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
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
              'Change Password',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: AppSizes.paddingHoriz,
              vertical: AppSizes.paddingVert,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: context.textTheme.headlineMedium,
                  ),
                  SizedBox(height: AppSizes.sm),
                  Text(
                    'Keep your account secure by updating your password regularly.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.fgMuted,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                  SizedBox(height: AppSizes.md),
                  TextFieldData(
                    label: 'Current Password',
                    hintText: 'Enter current password',
                    isPassword: true,
                    controller: _oldPasswordController,
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                    enabled: !authProvider.isLoading,
                  ),
                  SizedBox(height: AppSizes.formHeight),
                  TextFieldData(
                    label: 'New Password',
                    hintText: 'Enter new password',
                    isPassword: true,
                    controller: _newPasswordController,
                    validator: Validators.password,
                    textInputAction: TextInputAction.next,
                    enabled: !authProvider.isLoading,
                  ),
                  SizedBox(height: AppSizes.formHeight),
                  TextFieldData(
                    label: 'Confirm Password',
                    hintText: 'Confirm new password',
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) => Validators.confirmPassword(
                      _newPasswordController.text.trim(),
                      value,
                    ),
                    enabled: !authProvider.isLoading,
                  ),
                  SizedBox(height: AppSizes.lg),
                  CustomElevatedButton(
                    label: 'Change Password',
                    isDisabled: authProvider.isLoading,
                    isLoading: authProvider.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _handleChangePassword();
                      } else {
                        return;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
