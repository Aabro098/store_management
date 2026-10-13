import 'package:finco_customer/models/base_model.dart';

class DashboardSummaryModel {
  DashboardSummaryModel({
    required this.overdue,
    required this.pendingApproval,
    required this.activeWork,
    required this.pendingDocs,
    required this.unreadNotifications,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      overdue: BaseModel.parseInt(json['overdue']) ?? 0,
      pendingApproval: BaseModel.parseInt(json['pendingApproval']) ?? 0,
      activeWork: BaseModel.parseInt(json['activeWork']) ?? 0,
      pendingDocs: BaseModel.parseInt(json['pendingDocs']) ?? 0,
      unreadNotifications: BaseModel.parseInt(json['unreadNotifications']) ?? 0,
    );
  }

  final int overdue;
  final int pendingApproval;
  final int activeWork;
  final int pendingDocs;
  final int unreadNotifications;

  DashboardSummaryModel copyWith() {
    return DashboardSummaryModel(
      overdue: overdue,
      pendingApproval: pendingApproval,
      activeWork: activeWork,
      pendingDocs: pendingDocs,
      unreadNotifications: unreadNotifications,
    );
  }
}
