import 'package:dio/dio.dart';

class AuthController {
  factory AuthController() => _instance;
  AuthController._internal();
  // Singleton instance
  static final AuthController _instance = AuthController._internal();

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> responseData;
      if (email == 'sushmitastha749@gmail.com' && password == 'Supi@123') {
        responseData = {
          'status': 'SUCCESS',
        };
      } else {
        responseData = {
          'status': 'FAILED',
        };
      }
      return responseData;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
