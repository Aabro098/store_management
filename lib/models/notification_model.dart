import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.status,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
    required this.isUnread,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = BaseModel.parseString(json['type']) ??
        BaseModel.parseString(json['notificationType']) ??
        '';
    final read = BaseModel.parseBool(json['read']) ??
        BaseModel.parseBool(json['isRead']) ??
        false;
    final iconStyle = _iconStyleFor(type);
    return NotificationModel(
      title: BaseModel.parseString(json['title']) ?? '',
      description: BaseModel.parseString(json['message']) ?? '',
      time: _formatTime(
        BaseModel.parseString(json['createdAt']) ??
            BaseModel.parseString(json['time']),
      ),
      type: type,
      status: BaseModel.parseString(json['status']) ?? '',
      iconBackgroundColor: iconStyle.iconBackgroundColor,
      iconColor: iconStyle.iconColor,
      icon: iconStyle.icon,
      isUnread: !read,
    );
  }

  final String title;
  final bool isUnread;
  final String description;
  final String time;
  final String type;
  final String status;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;

  NotificationModel copyWith({bool? isUnread}) {
    return NotificationModel(
      title: title,
      description: description,
      time: time,
      type: type,
      status: status,
      iconBackgroundColor: iconBackgroundColor,
      iconColor: iconColor,
      icon: icon,
      isUnread: isUnread ?? this.isUnread,
    );
  }

  static String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('MMM d, yyyy, h:mm a').format(parsed.toLocal());
  }

  static ({
    IconData icon,
    Color iconBackgroundColor,
    Color iconColor,
  }) _iconStyleFor(String type) {
    switch (type) {
      case 'WORK_ASSIGNED':
      case 'WORK_INCOMPLETE':
      case 'WORK_COMPLETED':
      case 'WORK_APPROVED':
        return (
          icon: Iconsax.briefcase,
          iconBackgroundColor: AppColors.primarySoft,
          iconColor: AppColors.primary,
        );
      case 'DOCUMENT_PENDING':
      case 'DOCUMENT_UPLOADED':
        return (
          icon: Iconsax.document_text,
          iconBackgroundColor: AppColors.warningSoft,
          iconColor: AppColors.fincoOrange,
        );
      case 'MEETING_SCHEDULED':
      case 'MEETING_UPDATED':
      case 'MEETING_CANCELLED':
        return (
          icon: Iconsax.calendar_tick,
          iconBackgroundColor: AppColors.infoSoft,
          iconColor: AppColors.info,
        );
      case 'CLIENT_ADDED':
      case 'CLIENT_REASSIGNED':
        return (
          icon: Iconsax.profile_2user,
          iconBackgroundColor: AppColors.dangerSoft,
          iconColor: AppColors.fincoMagenta,
        );
      case 'STAFF_ADDED':
        return (
          icon: Iconsax.user_add,
          iconBackgroundColor: AppColors.successSoft,
          iconColor: AppColors.success,
        );
      default:
        return (
          icon: Iconsax.notification,
          iconBackgroundColor: AppColors.primarySoft,
          iconColor: AppColors.primary,
        );
    }
  }
}
