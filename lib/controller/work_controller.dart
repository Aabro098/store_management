import 'package:dio/dio.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';

class WorkController {
  factory WorkController() => _instance;
  WorkController._internal();
  // Singleton instance
  static final WorkController _instance = WorkController._internal();

  Future<Map<String, dynamic>?> getWorkItems({
    int page = 1,
    String? status,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.workItems,
        queryParameters: {
          'page': page,
          'perPage': 10,
          if (status != null) 'status': status,
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

  Future<Map<String, dynamic>?> getDocumentStats() async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.documentStats,
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
