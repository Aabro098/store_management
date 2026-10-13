import 'package:dio/dio.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';

class DashboardController {
  factory DashboardController() => _instance;
  DashboardController._internal();
  // Singleton instance
  static final DashboardController _instance = DashboardController._internal();

  Future<Map<String, dynamic>?> getDashboardSummary() async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.dashboardSummary,
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
