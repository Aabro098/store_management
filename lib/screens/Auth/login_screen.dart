import 'package:dio/dio.dart';
import 'package:finco_customer/common/widgets/custom_button.dart';
import 'package:finco_customer/common/widgets/text_form_field.dart';
import 'package:finco_customer/common/widgets/version_number.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/screens/Home/home_screen.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/Validators/validator.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/image_strings.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin({
    required String email,
    required String password,
  }) async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.login(
        email: email,
        password: password,
      );
      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        HomeScreen.routeName,
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: AppSizes.paddingHoriz,
              vertical: AppSizes.paddingVert,
            ),
            child: Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: AppSizes.md),
                      Center(
                        child: Image.asset(
                          AppImages.fincoLogo,
                          width: 200.w,
                        ),
                      ),
                      SizedBox(height: AppSizes.md),
                      SizedBox(
                        width: 292.w,
                        child: Text(
                          'Documents , work status and meetings - in one place',
                          style: context.textTheme.bodySmall
                              ?.copyWith(fontSize: AppSizes.fontBase),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: AppSizes.md),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          color: AppColors.accentSoft,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingHoriz,
                            vertical: AppSizes.paddingVert,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign in',
                                style: context.textTheme.titleLarge,
                              ),
                              SizedBox(height: AppSizes.sm),
                              Text(
                                'Login with your email and password.',
                                style: context.textTheme.bodySmall,
                              ),
                              SizedBox(height: AppSizes.formHeight),
                              TextFieldData(
                                controller: provider.emailController,
                                hintText: 'Enter your email',
                                label: 'Email',
                                validator: Validators.email,
                                textInputAction: TextInputAction.next,
                                enabled: !provider.isLoading,
                              ),
                              SizedBox(height: AppSizes.formHeight),
                              TextFieldData(
                                controller: provider.passwordController,
                                hintText: 'Enter your password',
                                label: 'Password',
                                isPassword: true,
                                validator: Validators.password,
                                enabled: !provider.isLoading,
                              ),
                              SizedBox(height: AppSizes.lg),
                              CustomElevatedButton(
                                label: 'Sign in',
                                isDisabled: provider.isLoading,
                                isLoading: provider.isLoading,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await _handleLogin(
                                      email:
                                          provider.emailController.text.trim(),
                                      password: provider.passwordController.text
                                          .trim(),
                                    );
                                  } else {
                                    return;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.lg),
                      const VersionNumber(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
