import 'package:dio/dio.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';

class MeetingController {
  factory MeetingController() => _instance;
  MeetingController._internal();
  // Singleton instance
  static final MeetingController _instance = MeetingController._internal();

  Future<Map<String, dynamic>?> getMeetings({
    int page = 1,
    String? status,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.meetings,
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
}
