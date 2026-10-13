import 'package:dio/dio.dart';
import 'package:finco_customer/config/flavor_config.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/screens/Auth/login_screen.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/provider_reset.dart';
import 'package:finco_customer/utils/local_storage/user_prefs.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

/// Class for Using the DioClient for managing HTTP networking.
class DioClient {
  DioClient._();
  //! ALWAYS USE  '_method': 'DELETE' OR 'PUT' inside data.
  //* Eg.
  //*  final formData = FormData.fromMap({
  //* '_method': 'DELETE',
  //* });
  //* final response = await dio.post('/user/delete', data: formData);

  /// Initialize the Dio Client with default parameters.
  static Future<Dio> initClient() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: FlavorConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        // receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
          // 'Accept-Language': code,
        },
      ),
    );
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(RequestLogInterceptor());
    return dio;
  }

  /// Initialize the Dio Client for public access without authentication .
  static Future<Dio> initPublicClient() async {
    // final code = await getCode();
    final dio = Dio(
      BaseOptions(
        baseUrl: FlavorConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
          // 'Accept-Language': code,
        },
      ),
    );
    dio.interceptors.add(RequestLogInterceptor());
    return dio;
  }

  static String parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Connection timed out. Please try again later.';
    }

    final response = e.response;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      // ✅ Check for multiple field errors FIRST
      final errors = data['errors'];
      if (errors != null && errors is Map<String, dynamic>) {
        final allErrors = <String>[];

        for (final entry in errors.entries) {
          final value = entry.value;

          if (value is List && value.isNotEmpty) {
            allErrors.add('${value.first}');
          } else if (value is String && value.isNotEmpty) {
            allErrors.add(value);
          }
        }

        if (allErrors.isNotEmpty) {
          return allErrors.join('\n');
        }
      } else if (errors is List) {
        for (final e in errors) {
          if (e is Map<String, dynamic>) {
            final msgs = (e['message'] as List<dynamic>?)?.join(', ') ?? '';
            if (msgs.isNotEmpty) return msgs;
          }
        }
      }

      // ✅ Fallback to generic message extraction for other formats
      final extractedMessage = extractMessage(data);
      if (extractedMessage != null) {
        return extractedMessage;
      }

      return 'Unknown server error';
    }

    return e.message ?? 'No response received';
  }

  static String formatFieldName(String field) {
    return field.replaceAll('_', ' ').toUpperCase();
  }

  static String? extractMessage(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    if (value is Map) {
      // Case 1: Check if "message" key contains field-specific errors
      if (value['message'] is Map) {
        final messageMap = value['message'] as Map;

        // Extract first field's error message
        for (final fieldValue in messageMap.values) {
          if (fieldValue is List && fieldValue.isNotEmpty) {
            // Return first error from the list
            return fieldValue.first?.toString();
          } else if (fieldValue is String && fieldValue.isNotEmpty) {
            return fieldValue;
          }
        }
      }

      // Case 2: Direct "message" with string value
      if (value['message'] is String &&
          (value['message'] as String).isNotEmpty) {
        return value['message'] as String;
      }

      // Case 3: Check for direct field errors at root level
      for (final entry in value.entries) {
        if (entry.key == 'status') continue; // Skip status field

        if (entry.value is List && (entry.value as List).isNotEmpty) {
          return (entry.value as List).first?.toString();
        } else if (entry.value is String &&
            (entry.value as String).isNotEmpty) {
          return entry.value as String;
        }
      }

      // Case 4: Recursive fallback for nested structures
      for (final v in value.values) {
        final result = extractMessage(v);
        if (result != null) return result;
      }
    }

    if (value is List && value.isNotEmpty) {
      // Handle arrays of error messages
      return value.first?.toString();
    }

    return null;
  }
}

class RequestLogInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('┌── Dio Request');
      debugPrint('│ URL: ${options.uri}');
      debugPrint('│ Token: ${options.headers['Authorization']}');
      debugPrint('│ Body: ${_requestBody(options.data)}');
      debugPrint('└──────────────');
    }
    handler.next(options);
  }

  String _requestBody(dynamic data) {
    if (data == null) return 'null';
    if (data is FormData) {
      final fields = data.fields.map((e) => '${e.key}: ${e.value}').join(', ');
      final files =
          data.files.map((e) => '${e.key}: ${e.value.filename}').join(', ');
      return 'FormData(fields: {$fields}, files: {$files})';
    }
    return data.toString();
  }
}

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getSecureToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final authProvider = context.read<AuthProvider>();
        resetSessionProviders(context);
        await authProvider.reset();
      } else {
        await clearPrefs();
      }

      await navigatorKey.currentState?.pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (_) => false,
      );
    }

    handler.next(err); // IMPORTANT: continue error propagation
  }
}
