import 'package:finco_customer/models/base_model.dart';
import 'package:flutter/foundation.dart';

/// Status values returned by the work-items API.
abstract final class WorkItemStatus {
  static const String pending = 'PENDING';
  static const String inProgress = 'IN_PROGRESS';
  static const String completed = 'COMPLETED';
  static const String approved = 'APPROVED';
}

@immutable
class WorkItem implements BaseModel {
  const WorkItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.expectedCompletionDate,
    required this.status,
    this.clientId,
    this.assignedStaffIds = const [],
    this.completedDateKeys = const [],
    this.completedAt,
    this.approvedAt,
    this.approvedById,
    this.createdById,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      id: BaseModel.parseString(json['id']) ?? '',
      title: BaseModel.parseString(json['title']) ?? '',
      description: BaseModel.parseString(json['description']) ?? '',
      clientId: BaseModel.parseString(json['clientId']),
      assignedStaffIds: BaseModel.parseList<String>(
            json['assignedStaffIds'],
            (item) => BaseModel.parseString(item) ?? '',
          ) ??
          [],
      assignedDate: BaseModel.parseString(json['assignedDate']) ?? '',
      expectedCompletionDate:
          BaseModel.parseString(json['expectedCompletionDate']) ?? '',
      status: BaseModel.parseString(json['status']) ?? '',
      completedDateKeys: BaseModel.parseList<String>(
            json['completedDateKeys'],
            (item) => BaseModel.parseString(item) ?? '',
          ) ??
          [],
      completedAt: BaseModel.parseString(json['completedAt']),
      approvedAt: BaseModel.parseString(json['approvedAt']),
      approvedById: BaseModel.parseString(json['approvedById']),
      createdById: BaseModel.parseString(json['createdById']),
    );
  }

  factory WorkItem.fromRow() {
    throw UnimplementedError('WorkItem.fromRow not implemented');
  }

  final String id;
  final String title;
  final String description;
  final String? clientId;
  final List<String> assignedStaffIds;
  final String assignedDate;
  final String expectedCompletionDate;
  final String status;
  final List<String> completedDateKeys;
  final String? completedAt;
  final String? approvedAt;
  final String? approvedById;
  final String? createdById;

  bool get isPending => status == WorkItemStatus.pending;
  bool get isInProgress => status == WorkItemStatus.inProgress;
  bool get isCompleted => status == WorkItemStatus.completed;
  bool get isApproved => status == WorkItemStatus.approved;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'clientId': clientId,
      'assignedStaffIds': assignedStaffIds,
      'assignedDate': assignedDate,
      'expectedCompletionDate': expectedCompletionDate,
      'status': status,
      'completedDateKeys': completedDateKeys,
      'completedAt': completedAt,
      'approvedAt': approvedAt,
      'approvedById': approvedById,
      'createdById': createdById,
    };
  }

  WorkItem copyWith({
    String? id,
    String? title,
    String? description,
    String? clientId,
    List<String>? assignedStaffIds,
    String? assignedDate,
    String? expectedCompletionDate,
    String? status,
    List<String>? completedDateKeys,
    String? completedAt,
    String? approvedAt,
    String? approvedById,
    String? createdById,
  }) {
    return WorkItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      assignedStaffIds: assignedStaffIds ?? this.assignedStaffIds,
      assignedDate: assignedDate ?? this.assignedDate,
      expectedCompletionDate:
          expectedCompletionDate ?? this.expectedCompletionDate,
      status: status ?? this.status,
      completedDateKeys: completedDateKeys ?? this.completedDateKeys,
      completedAt: completedAt ?? this.completedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedById: approvedById ?? this.approvedById,
      createdById: createdById ?? this.createdById,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          clientId == other.clientId &&
          listEquals(assignedStaffIds, other.assignedStaffIds) &&
          assignedDate == other.assignedDate &&
          expectedCompletionDate == other.expectedCompletionDate &&
          status == other.status &&
          listEquals(completedDateKeys, other.completedDateKeys) &&
          completedAt == other.completedAt &&
          approvedAt == other.approvedAt &&
          approvedById == other.approvedById &&
          createdById == other.createdById;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      clientId.hashCode ^
      Object.hashAll(assignedStaffIds) ^
      assignedDate.hashCode ^
      expectedCompletionDate.hashCode ^
      status.hashCode ^
      Object.hashAll(completedDateKeys) ^
      completedAt.hashCode ^
      approvedAt.hashCode ^
      approvedById.hashCode ^
      createdById.hashCode;

  @override
  String toString() =>
      'WorkItem(id: $id, title: $title, description: $description, clientId: $clientId, assignedStaffIds: $assignedStaffIds, assignedDate: $assignedDate, expectedCompletionDate: $expectedCompletionDate, status: $status, completedDateKeys: $completedDateKeys, completedAt: $completedAt, approvedAt: $approvedAt, approvedById: $approvedById, createdById: $createdById)';
}
