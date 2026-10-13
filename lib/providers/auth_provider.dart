import 'dart:async';
import 'package:dio/dio.dart';
import 'package:finco_customer/controller/auth_controller.dart';
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

  Future<void> restoreSession() async {
    final token = await getSecureToken();

    _isAuthenticated = token.isNotEmpty;
    if (_isAuthenticated) {}
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
      final status = response['status'] as String?;
      if (status == null || status.isEmpty) {
        throw Exception('Login failed: Status missing');
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

  /// Clears the local session (prefs, controllers and auth state) without
  /// calling the server. Used on 401 / token-expiry handling to avoid a
  /// recursive logout request.
  Future<void> reset() async {
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
