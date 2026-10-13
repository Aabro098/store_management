import 'package:finco_customer/app.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/providers/calendar_provider.dart';
import 'package:finco_customer/providers/dashboard_provider.dart';
import 'package:finco_customer/providers/index_provider.dart';
import 'package:finco_customer/providers/localization_provider.dart';
import 'package:finco_customer/providers/meeting_provider.dart';
import 'package:finco_customer/providers/notification_provider.dart';
import 'package:finco_customer/providers/theme.provider.dart';
import 'package:finco_customer/providers/user_provider.dart';
import 'package:finco_customer/providers/work_provider.dart';
import 'package:finco_customer/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

/// Shared app bootstrap. Start a flavor entrypoint instead of this file:
/// `flutter run --flavor dev -t lib/main_dev.dart`

Future<void> bootstrap() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await NotificationService().initNotification();
  } on Exception catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Firebase / notification init failed: $e');
    }
  }

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => IndexProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WorkProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
      ],
      child: const App(),
    ),
  );

  Future.delayed(const Duration(seconds: 2), FlutterNativeSplash.remove);
}
