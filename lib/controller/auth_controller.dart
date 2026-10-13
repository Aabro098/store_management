import 'package:dio/dio.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';
import 'package:finco_customer/utils/local_storage/user_prefs.dart';

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
      final dio = await DioClient.initPublicClient();

      final response = await dio.post<Map<String, dynamic>>(
        UrlStrings.login,
        data: FormData.fromMap({
          'email': email,
          'password': password,
        }),
      );
      final responseData = response.data;
      return responseData;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendFCMToken({
    required String token,
    required String platform,
  }) async {
    try {
      final dio = await DioClient.initClient();
      await dio.post<Map<String, dynamic>>(
        UrlStrings.deviceToken,
        data: {
          'token': token,
          'platform': platform,
        },
      );
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDeviceToken({required String token}) async {
    try {
      final dio = await DioClient.initPublicClient();
      final authToken = await getSecureToken();

      await dio.delete<void>(
        '${UrlStrings.deviceToken}/${Uri.encodeComponent(token)}',
        options: Options(
          headers: {
            if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
          },
        ),
      );
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOwnDetails() async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.me,
      );

      final responseData = response.data;
      return responseData;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> logout() async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.post<Map<String, dynamic>>(
        UrlStrings.logout,
      );

      final responseData = response.data;
      return responseData;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.post<Map<String, dynamic>>(
        UrlStrings.changePassword,
        data: {
          'currentPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      final responseData = response.data;
      return responseData;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> deactivateAccount({
    required String confirmName,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.post<Map<String, dynamic>>(
        UrlStrings.deactivateAccount,
        data: {'confirmName': confirmName},
      );

      final responseData = response.data;
      return responseData;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
