import 'package:finco_customer/providers/calendar_provider.dart';
import 'package:finco_customer/providers/dashboard_provider.dart';
import 'package:finco_customer/providers/index_provider.dart';
import 'package:finco_customer/providers/meeting_provider.dart';
import 'package:finco_customer/providers/notification_provider.dart';
import 'package:finco_customer/providers/user_provider.dart';
import 'package:finco_customer/providers/work_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Clears every session-scoped provider so the next login starts with a
/// pristine state. Theme and localization are intentionally kept untouched:
/// they are per-device preferences, not per-session data.
void resetSessionProviders(BuildContext context) {
  context.read<IndexProvider>().reset();
  context.read<CalendarProvider>().reset();
  context.read<UserProvider>().clear();
  context.read<WorkProvider>().clear();
  context.read<MeetingProvider>().clear();
  context.read<NotificationProvider>().clear();
  context.read<DashboardProvider>().clear();
}
