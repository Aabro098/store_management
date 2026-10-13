import 'package:dio/dio.dart';
import 'package:finco_customer/controller/meeting_controller.dart';
import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/models/meeting_model.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:flutter/material.dart';

/// The three meeting statuses. Each status keeps its own paginated list inside
/// [MeetingProvider] and is fetched with the matching `status` query parameter.
enum MeetingStatus {
  scheduled,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case MeetingStatus.scheduled:
        return 'SCHEDULED';
      case MeetingStatus.completed:
        return 'COMPLETED';
      case MeetingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get title {
    switch (this) {
      case MeetingStatus.scheduled:
        return 'Scheduled';
      case MeetingStatus.completed:
        return 'Completed';
      case MeetingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class MeetingProvider extends ChangeNotifier {
  MeetingProvider({MeetingController? meetingController})
      : _meetingController = meetingController ?? MeetingController();

  final MeetingController _meetingController;

  final Map<MeetingStatus, List<MeetingModel>> _itemsByStatus = {};
  final Map<MeetingStatus, bool> _isLoading = {};
  final Map<MeetingStatus, bool> _isLoadingMore = {};
  final Map<MeetingStatus, String?> _errorMessage = {};
  final Map<MeetingStatus, int> _page = {};
  final Map<MeetingStatus, int> _totalPages = {};

  List<MeetingModel> itemsForStatus(MeetingStatus status) =>
      List.unmodifiable(_itemsByStatus[status] ?? const []);

  bool isLoadingFor(MeetingStatus status) => _isLoading[status] ?? false;

  bool isLoadingMoreFor(MeetingStatus status) =>
      _isLoadingMore[status] ?? false;

  String? errorMessageFor(MeetingStatus status) => _errorMessage[status];

  /// Whether another page is available to load via "See more".
  bool hasMoreFor(MeetingStatus status) =>
      (_page[status] ?? 1) < (_totalPages[status] ?? 1);

  /// Fetches the first page for [status], or appends the next page when
  /// [loadMore] is true.
  Future<void> fetchItems(MeetingStatus status, {bool loadMore = false}) async {
    if (isLoadingFor(status) || isLoadingMoreFor(status)) return;
    final nextPage = loadMore ? (_page[status] ?? 1) + 1 : 1;
    if (loadMore && !hasMoreFor(status)) return;

    loadMore ? _isLoadingMore[status] = true : _isLoading[status] = true;
    _errorMessage[status] = null;
    notifyListeners();

    try {
      final response = await _meetingController.getMeetings(
        page: nextPage,
        status: status.label,
      );

      if (response == null) {
        throw Exception('Failed to load meetings');
      }

      final items = _parseItems(response['data']) ?? const <MeetingModel>[];

      if (loadMore) {
        _itemsByStatus[status] = [
          ..._itemsByStatus[status] ?? const [],
          ...items,
        ];
      } else {
        _itemsByStatus[status] = items;
      }

      _page[status] = nextPage;
      final meta = response['meta'];
      if (meta is Map<String, dynamic>) {
        _totalPages[status] = BaseModel.parseInt(meta['totalPages']) ?? 1;
      } else {
        _totalPages[status] = 1;
      }
    } on DioException catch (e) {
      _errorMessage[status] = DioClient.parseDioError(e);
    } on Object catch (e) {
      _errorMessage[status] = e.toString();
    } finally {
      _isLoading[status] = false;
      _isLoadingMore[status] = false;
      notifyListeners();
    }
  }

  List<MeetingModel>? _parseItems(dynamic rawList) {
    return BaseModel.parseList<MeetingModel>(
      rawList,
      (item) => MeetingModel.fromJson(item as Map<String, dynamic>),
    );
  }

  void clear() {
    _itemsByStatus.clear();
    _isLoading.clear();
    _isLoadingMore.clear();
    _errorMessage.clear();
    _page.clear();
    _totalPages.clear();
    notifyListeners();
  }
}
