import 'package:dio/dio.dart';
import 'package:finco_customer/controller/document_controller.dart';
import 'package:finco_customer/controller/work_controller.dart';
import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/models/daily_submission_model.dart';
import 'package:finco_customer/models/document_day_model.dart';
import 'package:finco_customer/models/document_stats_model.dart';
import 'package:finco_customer/models/work_item_model.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

/// The five work items tabs. Every tab reads the same [WorkProvider] instance
/// and reuses the same fetching logic, only differing in the `status` query
/// parameter sent to the API.
enum WorkTab {
  all,
  pending,
  inProgress,
  completed,
  approved;

  String? get status {
    switch (this) {
      case WorkTab.all:
        return null;
      case WorkTab.pending:
        return WorkItemStatus.pending;
      case WorkTab.inProgress:
        return WorkItemStatus.inProgress;
      case WorkTab.completed:
        return WorkItemStatus.completed;
      case WorkTab.approved:
        return WorkItemStatus.approved;
    }
  }
}

class WorkProvider extends ChangeNotifier {
  WorkProvider({
    WorkController? workController,
    DocumentController? documentController,
  })  : _workController = workController ?? WorkController(),
        _documentController = documentController ?? DocumentController();

  final WorkController _workController;
  final DocumentController _documentController;

  final Map<WorkTab, List<WorkItem>> _itemsByTab = {};
  final Map<WorkTab, bool> _isLoading = {};
  final Map<WorkTab, bool> _isLoadingMore = {};
  final Map<WorkTab, String?> _errorMessage = {};
  final Map<WorkTab, int> _page = {};
  final Map<WorkTab, int> _totalPages = {};

  List<DailySubmissionModel> _documents = const [];
  String? _documentsDateKey;
  String? _loadedDocumentsDateKey;
  bool _isDocumentsLoading = false;
  String? _documentsError;
  int _documentsRequestId = 0;

  DocumentStatsModel? _documentStats;
  bool _isDocumentStatsLoading = false;
  String? _documentStatsError;
  int _documentStatsRequestId = 0;

  List<WorkItem> itemsForTab(WorkTab tab) =>
      List.unmodifiable(_itemsByTab[tab] ?? const []);

  bool isLoadingFor(WorkTab tab) => _isLoading[tab] ?? false;

  bool isLoadingMoreFor(WorkTab tab) => _isLoadingMore[tab] ?? false;

  String? errorMessageFor(WorkTab tab) => _errorMessage[tab];

  bool hasMoreFor(WorkTab tab) => (_page[tab] ?? 1) < (_totalPages[tab] ?? 1);

  List<DailySubmissionModel> get documents => List.unmodifiable(_documents);

  String? get documentsDateKey => _documentsDateKey;

  bool get isDocumentsLoading => _isDocumentsLoading;

  String? get documentsError => _documentsError;

  DocumentStatsModel? get documentStats => _documentStats;

  bool get isDocumentStatsLoading => _isDocumentStatsLoading;

  String? get documentStatsError => _documentStatsError;

  static String dateKeyFor(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Fetches (or appends) the first / next page of work items for [tab].
  Future<void> fetchItems(WorkTab tab, {bool loadMore = false}) async {
    if (isLoadingFor(tab) || isLoadingMoreFor(tab)) return;
    final nextPage = loadMore ? (_page[tab] ?? 1) + 1 : 1;
    if (loadMore && !hasMoreFor(tab)) return;

    loadMore ? _isLoadingMore[tab] = true : _isLoading[tab] = true;
    _errorMessage[tab] = null;
    notifyListeners();

    try {
      final response = await _workController.getWorkItems(
        page: nextPage,
        status: tab.status,
      );

      if (response == null) {
        throw Exception('Failed to load work items');
      }

      final items = _parseItems(response['data']) ?? const <WorkItem>[];

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

  Future<void> fetchDocumentStats({bool force = false}) async {
    if (!force && (_isDocumentStatsLoading || _documentStats != null)) {
      return;
    }

    final requestId = ++_documentStatsRequestId;
    _documentStatsError = null;
    _isDocumentStatsLoading = true;
    notifyListeners();

    try {
      final response = await _workController.getDocumentStats();

      if (requestId != _documentStatsRequestId) return;
      if (response == null) {
        throw Exception('Failed to load document stats');
      }

      final rawStats = response['data'];
      if (rawStats is! Map<String, dynamic>) {
        throw Exception('Invalid document stats response');
      }

      _documentStats = DocumentStatsModel.fromJson(rawStats);
    } on DioException catch (e) {
      if (requestId != _documentStatsRequestId) return;
      _documentStatsError = DioClient.parseDioError(e);
    } on Object catch (e) {
      if (requestId != _documentStatsRequestId) return;
      _documentStatsError = e.toString();
    } finally {
      if (requestId == _documentStatsRequestId) {
        _isDocumentStatsLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchDocumentsForDate(
    DateTime date, {
    bool force = false,
  }) {
    return fetchDocuments(
      dateKey: dateKeyFor(date),
      force: force,
    );
  }

  Future<void> fetchDocuments({
    required String dateKey,
    bool force = false,
  }) async {
    if (!force && _isDocumentsLoading && _documentsDateKey == dateKey) {
      return;
    }
    if (!force && _loadedDocumentsDateKey == dateKey) {
      return;
    }

    final requestId = ++_documentsRequestId;
    _documentsDateKey = dateKey;
    _loadedDocumentsDateKey = null;
    _documents = const [];
    _documentsError = null;
    _isDocumentsLoading = true;
    notifyListeners();

    try {
      final response = await _documentController.getDocuments(
        dateKey: dateKey,
        perPage: 100,
      );

      if (requestId != _documentsRequestId) return;
      if (response == null) {
        throw Exception('Failed to load documents');
      }

      _documents =
          _parseDocuments(response['data']) ?? const <DailySubmissionModel>[];
      _loadedDocumentsDateKey = dateKey;
    } on DioException catch (e) {
      if (requestId != _documentsRequestId) return;
      _documentsError = DioClient.parseDioError(e);
    } on Object catch (e) {
      if (requestId != _documentsRequestId) return;
      _documentsError = e.toString();
    } finally {
      if (requestId == _documentsRequestId) {
        _isDocumentsLoading = false;
        notifyListeners();
      }
    }
  }

  /// The API groups submissions under their day, so the day wrappers are
  /// flattened away and each submission keeps the `dateKey` of its day.
  List<DailySubmissionModel>? _parseDocuments(dynamic rawList) {
    final days = BaseModel.parseList<DocumentDayModel>(
      rawList,
      (item) => DocumentDayModel.fromJson(
        Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
      ),
    );
    if (days == null) return null;
    return days.expand((day) => day.submissions).toList();
  }

  List<WorkItem>? _parseItems(dynamic rawList) {
    return BaseModel.parseList<WorkItem>(
      rawList,
      (item) => WorkItem.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<void> downloadFile({required String documentId}) async {
    try {
      final response =
          await _documentController.getDownloadUrl(documentId: documentId);

      if (response == null) {
        throw Exception('Download failed: No response from server');
      }

      await launchUrlString(response);
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Opens a file with the signed URL the API already returned with the day's
  /// submissions, avoiding an extra `download-url` round trip. The link is only
  /// valid for about an hour, so it is never cached.
  Future<void> openFileUrl(String url) => launchUrlString(url);

  void clear() {
    _itemsByTab.clear();
    _isLoading.clear();
    _isLoadingMore.clear();
    _errorMessage.clear();
    _page.clear();
    _totalPages.clear();
    _documentsRequestId++;
    _documents = const [];
    _documentsDateKey = null;
    _loadedDocumentsDateKey = null;
    _isDocumentsLoading = false;
    _documentsError = null;
    _documentStatsRequestId++;
    _documentStats = null;
    _isDocumentStatsLoading = false;
    _documentStatsError = null;
    notifyListeners();
  }
}
