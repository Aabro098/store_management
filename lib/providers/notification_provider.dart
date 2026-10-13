import 'package:dio/dio.dart';
import 'package:finco_customer/controller/notification_controller.dart';
import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/models/notification_model.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/services/notification_service.dart';
import 'package:flutter/material.dart';

/// The two notification tabs. Every tab reads the same [NotificationProvider]
/// instance and reuses the same fetching logic, only differing in the `read`
/// query parameter sent to the API.
enum NotificationTab {
  unread,
  all;

  bool? get isRead {
    switch (this) {
      case NotificationTab.unread:
        return false;
      case NotificationTab.all:
        return null;
    }
  }

  String get label {
    switch (this) {
      case NotificationTab.unread:
        return 'Unread';
      case NotificationTab.all:
        return 'All';
    }
  }
}

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({
    NotificationController? notificationController,
    NotificationService? notificationService,
  })  : _notificationController =
            notificationController ?? NotificationController(),
        _notificationService = notificationService ?? NotificationService();

  final NotificationController _notificationController;
  final NotificationService _notificationService;

  bool? _arePushNotificationsEnabled;
  bool _isUpdatingPushNotifications = false;
  int _pushNotificationsRequestId = 0;

  bool get arePushNotificationsEnabled => _arePushNotificationsEnabled ?? false;

  bool get isUpdatingPushNotifications => _isUpdatingPushNotifications;

  final Map<NotificationTab, List<NotificationModel>> _itemsByTab = {};
  final Map<NotificationTab, bool> _isLoading = {};
  final Map<NotificationTab, bool> _isLoadingMore = {};
  final Map<NotificationTab, String?> _errorMessage = {};
  final Map<NotificationTab, int> _page = {};
  final Map<NotificationTab, int> _totalPages = {};

  List<NotificationModel> itemsForTab(NotificationTab tab) =>
      List.unmodifiable(_itemsByTab[tab] ?? const []);

  bool isLoadingFor(NotificationTab tab) => _isLoading[tab] ?? false;

  bool isLoadingMoreFor(NotificationTab tab) => _isLoadingMore[tab] ?? false;

  String? errorMessageFor(NotificationTab tab) => _errorMessage[tab];

  bool hasMoreFor(NotificationTab tab) =>
      (_page[tab] ?? 1) < (_totalPages[tab] ?? 1);

  Future<void> loadPushNotificationSetting() async {
    if (_arePushNotificationsEnabled != null || _isUpdatingPushNotifications) {
      return;
    }

    final requestId = ++_pushNotificationsRequestId;
    _isUpdatingPushNotifications = true;
    notifyListeners();

    try {
      final isEnabled = await _notificationService.isPushNotificationsEnabled();
      if (requestId != _pushNotificationsRequestId) return;
      _arePushNotificationsEnabled = isEnabled;
    } on Object {
      if (requestId == _pushNotificationsRequestId) {
        _arePushNotificationsEnabled = false;
      }
    } finally {
      if (requestId == _pushNotificationsRequestId) {
        _isUpdatingPushNotifications = false;
        notifyListeners();
      }
    }
  }

  Future<bool> setPushNotificationsEnabled({required bool isEnabled}) async {
    if (_isUpdatingPushNotifications) return false;
    if (_arePushNotificationsEnabled == isEnabled) return true;

    final requestId = ++_pushNotificationsRequestId;
    _isUpdatingPushNotifications = true;
    notifyListeners();

    try {
      final didUpdate = await _notificationService.setPushNotificationsEnabled(
        isEnabled: isEnabled,
      );
      if (requestId == _pushNotificationsRequestId && didUpdate) {
        _arePushNotificationsEnabled = isEnabled;
      }
      return didUpdate && requestId == _pushNotificationsRequestId;
    } on Object {
      return false;
    } finally {
      if (requestId == _pushNotificationsRequestId) {
        _isUpdatingPushNotifications = false;
        notifyListeners();
      }
    }
  }

  /// Fetches (or appends) the first / next page of notifications for [tab].
  Future<void> fetchItems(NotificationTab tab, {bool loadMore = false}) async {
    if (isLoadingFor(tab) || isLoadingMoreFor(tab)) return;
    final nextPage = loadMore ? (_page[tab] ?? 1) + 1 : 1;
    if (loadMore && !hasMoreFor(tab)) return;

    loadMore ? _isLoadingMore[tab] = true : _isLoading[tab] = true;
    _errorMessage[tab] = null;
    notifyListeners();

    try {
      final response = await _notificationController.getNotifications(
        page: nextPage,
        isRead: tab.isRead,
      );

      if (response == null) {
        throw Exception('Failed to load notifications');
      }

      final items =
          _parseItems(response['data']) ?? const <NotificationModel>[];

      if (loadMore) {
        _itemsByTab[tab] = [..._itemsByTab[tab] ?? const [], ...items];
      } else {
        _itemsByTab[tab] = items;
      }

      _page[tab] = nextPage;
      final meta = response['meta'];
      if (meta is Map<String, dynamic>) {
        _totalPages[tab] = BaseModel.parseInt(meta['totalPages']) ?? 1;
      } else {
        _totalPages[tab] = 1;
      }
    } on DioException catch (e) {
      _errorMessage[tab] = DioClient.parseDioError(e);
    } on Object catch (e) {
      _errorMessage[tab] = e.toString();
    } finally {
      _isLoading[tab] = false;
      _isLoadingMore[tab] = false;
      notifyListeners();
    }
  }

  List<NotificationModel>? _parseItems(dynamic rawList) {
    return BaseModel.parseList<NotificationModel>(
      rawList,
      (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
    );
  }

  bool _isMarkingAllRead = false;

  bool get isMarkingAllRead => _isMarkingAllRead;

  /// Marks every notification as read server-side, keeps the cached lists in
  /// sync, and empties the unread tab.
  Future<void> markAllRead() async {
    if (_isMarkingAllRead) return;
    _isMarkingAllRead = true;
    notifyListeners();

    try {
      await _notificationController.markAllRead();

      for (final tab in NotificationTab.values) {
        final items = _itemsByTab[tab];
        if (items == null || items.isEmpty) continue;
        _itemsByTab[tab] = [
          for (final item in items) item.copyWith(isUnread: false),
        ];
      }

      _itemsByTab[NotificationTab.unread] = [];
      _page[NotificationTab.unread] = 0;
      _totalPages[NotificationTab.unread] = 0;
    } on DioException {
      rethrow;
    } on Object {
      rethrow;
    } finally {
      _isMarkingAllRead = false;
      notifyListeners();
    }
  }

  void clear() {
    _itemsByTab.clear();
    _isLoading.clear();
    _isLoadingMore.clear();
    _errorMessage.clear();
    _page.clear();
    _totalPages.clear();
    _pushNotificationsRequestId++;
    _arePushNotificationsEnabled = null;
    _isUpdatingPushNotifications = false;
    _isMarkingAllRead = false;
    notifyListeners();
  }
}
