import 'dart:io';

import 'package:finco_customer/controller/auth_controller.dart';
import 'package:finco_customer/services/firebase_background_handler.dart';
import 'package:finco_customer/utils/local_storage/user_prefs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _isPluginInitialized = false;
  bool _isFirebaseMessagingInitialized = false;
  String? _fcmToken;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'finco_push',
    'Push Notifications',
    description: 'Finco customer push notifications',
    importance: Importance.max,
  );

  Future<void> _ensurePluginInitialized() async {
    if (_isPluginInitialized) return;

    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings();
    const linuxInitializationSettings =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
      macOS: iosInitSettings,
      linux: linuxInitializationSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _isPluginInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidGranted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false;
    if (androidGranted) {
      // debugPrint('🔹 Android notification permission granted');
    } else {
      // debugPrint('⚠️ Android notification permission denied');
    }

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // final settings = await _messaging.requestPermission();
    // debugPrint('🔹 FCM permission: ${settings.authorizationStatus}');
  }

  Future<bool> isPermissionGranted() async {
    await _ensurePluginInitialized();

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }

    final iosPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final options = await iosPlugin.checkPermissions();
      return options?.isEnabled ?? false;
    }

    final macPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    if (macPlugin != null) {
      final options = await macPlugin.checkPermissions();
      return options?.isEnabled ?? false;
    }

    return false;
  }

  Future<bool> requestPermission() async {
    await _ensurePluginInitialized();
    await _requestPermissions();
    return isPermissionGranted();
  }

  Future<bool> isPushNotificationsEnabled() async {
    final preference = await getPushNotificationPreference();
    final hasPermission = await isPermissionGranted();
    return hasPermission && (preference ?? true);
  }

  Future<bool> setPushNotificationsEnabled({required bool isEnabled}) async {
    if (isEnabled) {
      if (!await requestPermission()) return false;
      if (!await _registerFcmTokenWithBackend()) return false;
    } else if (!await _unregisterFcmTokenWithBackend()) {
      return false;
    }

    await setPushNotificationPreference(isEnabled: isEnabled);
    return true;
  }

  Future<void> initNotification() async {
    await _ensurePluginInitialized();
    await _requestPermissions();
    await _initFirebaseMessaging();
  }

  /// Returns the current FCM token, fetching a fresh one from Firebase when
  /// none is cached yet or [forceRefresh] is true.
  Future<String?> getFcmToken({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await _messaging.deleteToken();
        _fcmToken = null;
      }

      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        return _fcmToken;
      }

      return _fcmToken = await _messaging.getToken();
    } on Exception {
      // debugPrint('⚠️ Failed to get FCM token: $e');
      return _fcmToken;
    }
  }

  /// Sends the device FCM token to the backend. Safe to fire-and-forget.
  Future<void> registerFcmTokenWithBackend() async {
    await _registerFcmTokenWithBackend();
  }

  Future<bool> _registerFcmTokenWithBackend() async {
    try {
      final token = await getFcmToken();
      if (token == null || token.isEmpty) return false;

      // final deviceId = await getOrCreateDeviceId();
      final deviceType = Platform.isIOS ? 'IOS' : 'ANDROID';

      await AuthController().sendFCMToken(token: token, platform: deviceType);
      return true;
    } on Exception {
      return false;
    }
  }

  /// Unregisters the device FCM token from the backend so push stops for
  /// this device. Safe to fire-and-forget; failures never block sign-out.
  Future<void> unregisterFcmTokenWithBackend() async {
    await _unregisterFcmTokenWithBackend();
  }

  Future<bool> _unregisterFcmTokenWithBackend() async {
    try {
      final token = await getFcmToken();
      if (token == null || token.isEmpty) return true;

      await AuthController().deleteDeviceToken(token: token);
      return true;
    } on Exception {
      return false;
    }
  }

  Future<void> _initFirebaseMessaging() async {
    if (_isFirebaseMessagingInitialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await getFcmToken();

    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      // debugPrint('🔹 FCM token refreshed: $token');
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    _isFirebaseMessagingInitialized = true;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _showNotification(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {}

  NotificationDetails _notificationDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  Future<void> _showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await _ensurePluginInitialized();
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails(),
    );
  }
}
