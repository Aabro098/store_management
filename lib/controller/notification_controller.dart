import 'package:dio/dio.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';

class NotificationController {
  factory NotificationController() => _instance;
  NotificationController._internal();
  // Singleton instance
  static final NotificationController _instance =
      NotificationController._internal();

  Future<Map<String, dynamic>?> getNotifications({
    bool? isRead,
    int page = 1,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.notifications,
        queryParameters: {
          'page': page,
          'perPage': 10,
          if (isRead != null) 'read': isRead,
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

  Future<void> markAllRead() async {
    try {
      final dio = await DioClient.initClient();

      await dio.post<Map<String, dynamic>>(
        UrlStrings.markAllRead,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
