import 'package:finco_customer/common/widgets/cutsom_snack_bar.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void showErrorSnackbar(
  String message, {
  BuildContext? context,
}) {
  TopSnackbar.show(
    navigatorKey.currentContext!,
    TopSnackbar.error(message),
  );
}

void showSuccessSnackbar(
  String message, {
  BuildContext? context,
}) {
  TopSnackbar.show(
    navigatorKey.currentContext!,
    TopSnackbar.success(message),
  );
}

void showInfoSnackbar(
  String message, {
  BuildContext? context,
}) {
  TopSnackbar.show(
    navigatorKey.currentContext!,
    TopSnackbar.info(message),
  );
}

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

/// Formats today's date as e.g. "Tuesday, September 18".
String todayFormatted({String pattern = 'EEEE, MMMM d'}) =>
    DateFormat(pattern).format(DateTime.now());

/// Formats a [DateTime] using the given [pattern], e.g. "Sep 18, 2026".
String formatDate(DateTime date, {String pattern = 'MMM d, yyyy'}) =>
    DateFormat(pattern).format(date);

/// Formats an ISO-8601 [String] date using [formatDate]. Falls back to the
/// raw string when it can't be parsed (e.g. already formatted or null).
String formatDateString(String? date, {String pattern = 'MMM d, yyyy'}) {
  if (date == null || date.isEmpty) return '';
  final parsed = DateTime.tryParse(date);
  return parsed != null ? formatDate(parsed, pattern: pattern) : date;
}

String formatTitle(String title) {
  return title
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String getWeekdayShort(String dateString) {
  final date = DateFormat('MMM dd, yyyy, h:mm a').parse(dateString);
  return DateFormat('EEE').format(date).toUpperCase();
}

String getDay(String dateString) {
  final date = DateFormat('MMM dd, yyyy, h:mm a').parse(dateString);
  return DateFormat('dd').format(date);
}

Future<void> launchUrlString(String urlString) async {
  final url = Uri.parse(urlString);

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $urlString');
  }
}
