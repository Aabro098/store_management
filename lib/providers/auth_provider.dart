import 'dart:async';

import 'package:dio/dio.dart';
import 'package:finco_customer/controller/auth_controller.dart';
import 'package:finco_customer/services/notification_service.dart';
import 'package:finco_customer/utils/local_storage/user_prefs.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSessionChecked = false;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  bool get isSessionChecked => _isSessionChecked;
  bool get isAuthenticated => _isAuthenticated;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> _shouldRegisterPushNotifications() async {
    try {
      return await NotificationService().isPushNotificationsEnabled();
    } on Object {
      return false;
    }
  }

  Future<void> restoreSession() async {
    final token = await getSecureToken();

    _isAuthenticated = token.isNotEmpty;
    if (_isAuthenticated && await _shouldRegisterPushNotifications()) {
      unawaited(NotificationService().registerFcmTokenWithBackend());
    }
    _isSessionChecked = true;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final response = await AuthController().login(
        email: email,
        password: password,
      );

      if (response == null) {
        throw Exception('Login failed: No response from server');
      }
      final responseData = response['data'] as Map<String, dynamic>;
      final token = responseData['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Login failed: Token missing');
      }
      await storeSecureToken(token);

      if (await _shouldRegisterPushNotifications()) {
        unawaited(NotificationService().registerFcmTokenWithBackend());
      }

      _isAuthenticated = true;
      notifyListeners();
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);

    try {
      final response = await AuthController().changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (response == null) {
        throw Exception('Change Password Failed: No response from server');
      }

      await reset();
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      final response = await AuthController().logout();

      if (response == null) {
        throw Exception('Logout failed: No response from server');
      }

      await NotificationService().unregisterFcmTokenWithBackend();
      await reset();
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deactivateAccount({required String confirmName}) async {
    try {
      final response =
          await AuthController().deactivateAccount(confirmName: confirmName);

      if (response == null) {
        throw Exception('Delete Account failed: No response from server');
      }

      await NotificationService().unregisterFcmTokenWithBackend();
      await reset();
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Clears the local session (prefs, controllers and auth state) without
  /// calling the server. Used on 401 / token-expiry handling to avoid a
  /// recursive logout request.
  Future<void> reset() async {
    await NotificationService().unregisterFcmTokenWithBackend();
    await clearPrefs();
    _isLoading = false;
    _isAuthenticated = false;
    _emailController.clear();
    _passwordController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _emailController.clear();
    _passwordController.clear();
    super.dispose();
  }
}
