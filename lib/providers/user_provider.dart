import 'package:dio/dio.dart';
import 'package:finco_customer/controller/auth_controller.dart';
import 'package:finco_customer/models/user_model.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({AuthController? authController})
      : _authController = authController ?? AuthController();

  final AuthController _authController;

  UserData? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserData? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchUser() async {
    if (_isLoading) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authController.getOwnDetails();

      if (response == null) {
        throw Exception('Failed to load user details');
      }

      final rawData = response['data'];
      final userJson = rawData is Map<String, dynamic>
          ? rawData
          : rawData is Map
              ? Map<String, dynamic>.from(rawData)
              : response;

      _user = UserData.fromJson(userJson);
      _errorMessage = null;
    } on DioException catch (e) {
      _errorMessage = DioClient.parseDioError(e);
    } on Object catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
