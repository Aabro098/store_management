import 'package:dio/dio.dart';
import 'package:finco_customer/controller/dashboard_controller.dart';
import 'package:finco_customer/controller/document_controller.dart';
import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/models/daily_submission_model.dart';
import 'package:finco_customer/models/dashboard_summary_model.dart';
import 'package:finco_customer/models/document_day_model.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    DashboardController? dashboardController,
    DocumentController? documentController,
  })  : _dashboardController = dashboardController ?? DashboardController(),
        _documentController = documentController ?? DocumentController();

  final DashboardController _dashboardController;
  final DocumentController _documentController;

  DashboardSummaryModel? _summary;
  bool _isLoading = false;
  String? _errorMessage;

  List<DailySubmissionModel> _pendingDocuments = const [];
  bool _isDocumentsLoading = false;
  String? _documentsError;

  DashboardSummaryModel? get summary => _summary;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// The newest pending documents (top 10), shown on the home screen.
  List<DailySubmissionModel> get pendingDocuments => _pendingDocuments;

  bool get isDocumentsLoading => _isDocumentsLoading;

  String? get documentsError => _documentsError;

  Future<void> fetchDashboardSummary() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dashboardController.getDashboardSummary();

      if (response == null) {
        throw Exception('Failed to load dashboard summary');
      }

      _summary = _parseSummary(response);
    } on DioException catch (e) {
      _errorMessage = DioClient.parseDioError(e);
    } on Object catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DashboardSummaryModel? _parseSummary(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return DashboardSummaryModel.fromJson(data);
    }
    return DashboardSummaryModel.fromJson(json);
  }

  /// Fetches the newest 10 pending documents for the home screen.
  Future<void> fetchPendingDocuments() async {
    if (_isDocumentsLoading) return;
    _isDocumentsLoading = true;
    _documentsError = null;
    notifyListeners();

    try {
      final response = await _documentController.getDocuments(
        status: 'PENDING',
      );

      if (response == null) {
        throw Exception('Failed to load pending documents');
      }

      final submissions =
          _parseSubmissions(response['data']) ?? const <DailySubmissionModel>[];
      final pending = submissions.where((submission) => submission.isPending).toList()
        ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
      _pendingDocuments = pending.take(10).toList(growable: false);
    } on DioException catch (e) {
      _documentsError = DioClient.parseDioError(e);
    } on Object catch (e) {
      _documentsError = e.toString();
    } finally {
      _isDocumentsLoading = false;
      notifyListeners();
    }
  }

  /// The API groups submissions under their day, so the day wrappers are
  /// flattened away and each submission keeps the `dateKey` of its day.
  List<DailySubmissionModel>? _parseSubmissions(dynamic rawList) {
    final days = BaseModel.parseList<DocumentDayModel>(
      rawList,
      (item) => DocumentDayModel.fromJson(
        Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
      ),
    );
    if (days == null) return null;
    return days.expand((day) => day.submissions).toList();
  }

  void clear() {
    _summary = null;
    _pendingDocuments = const [];
    _isLoading = false;
    _isDocumentsLoading = false;
    _errorMessage = null;
    _documentsError = null;
    notifyListeners();
  }

  /// Sets the unread notifications count on the cached summary to 0.
  void markAllNotificationsRead() {
    final summary = _summary;
    if (summary == null) return;
    _summary = DashboardSummaryModel(
      overdue: summary.overdue,
      pendingApproval: summary.pendingApproval,
      activeWork: summary.activeWork,
      pendingDocs: summary.pendingDocs,
      unreadNotifications: 0,
    );
    notifyListeners();
  }
}
