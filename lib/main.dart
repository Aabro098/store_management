import 'package:finco_customer/app.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/providers/localization_provider.dart';
import 'package:finco_customer/providers/theme.provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

Future<void> bootstrap() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
      ],
      child: const App(),
    ),
  );

  Future.delayed(const Duration(seconds: 2), FlutterNativeSplash.remove);
}
