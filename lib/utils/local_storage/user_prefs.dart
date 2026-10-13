import 'package:shared_preferences/shared_preferences.dart';

const _authTokenKey = 'auth_token';
const _pushNotificationsEnabledKey = 'push_notifications_enabled';

Future<String> getSecureToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_authTokenKey);
  return token ?? '';
}

Future<void> storeSecureToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_authTokenKey, token);
}

Future<bool> hasValidSession() async {
  final token = await getSecureToken();
  return token.isNotEmpty;
}

Future<void> setFirstOpen({
  required bool isFirst,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirst', isFirst);
}

Future<bool> getFirstOpen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirst') ?? false;
}

Future<bool?> getPushNotificationPreference() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_pushNotificationsEnabledKey);
}

Future<void> setPushNotificationPreference({required bool isEnabled}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_pushNotificationsEnabledKey, isEnabled);
}

Future<void> clearPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_authTokenKey);
}
