import 'dart:ui';

import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:intl/intl.dart';

class MeetingModel {
  MeetingModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.location,
    required this.meetingLink,
    required this.createdById,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.statusColor,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    final status = BaseModel.parseString(json['status']) ?? '';
    return MeetingModel(
      id: BaseModel.parseString(json['id']) ?? '',
      clientId: BaseModel.parseString(json['clientId']) ?? '',
      title: BaseModel.parseString(json['title']) ?? '',
      description: BaseModel.parseString(json['description']) ?? '',
      scheduledAt: _formatTime(BaseModel.parseString(json['scheduledAt'])),
      durationMinutes: BaseModel.parseInt(json['durationMinutes']) ?? 0,
      location: BaseModel.parseString(json['location']),
      meetingLink: BaseModel.parseString(json['meetingLink']),
      createdById: BaseModel.parseString(json['createdById']) ?? '',
      status: status,
      createdAt: _formatTime(BaseModel.parseString(json['createdAt'])),
      updatedAt: BaseModel.parseString(json['updatedAt']),
      statusColor: _statusColorFor(status),
    );
  }

  final String id;
  final String clientId;
  final String title;
  final String description;
  final String? scheduledAt;
  final int durationMinutes;
  final String? location;
  final String? meetingLink;
  final String createdById;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Color statusColor;

  static Color _statusColorFor(String status) {
    switch (status) {
      case 'SCHEDULED':
        return AppColors.primary;

      case 'COMPLETED':
        return AppColors.fincoOrange;

      case 'CANCELLED':
        return AppColors.danger;

      default:
        return AppColors.primary;
    }
  }

  static String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('MMM d, yyyy, h:mm a').format(parsed.toLocal());
  }
}
