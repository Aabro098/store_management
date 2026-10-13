import 'package:finco_customer/common/widgets/loading_indicator.dart';
import 'package:finco_customer/config/flavor_config.dart';
import 'package:finco_customer/localization/app_localization.dart';
import 'package:finco_customer/providers/auth_provider.dart';
import 'package:finco_customer/providers/localization_provider.dart';
import 'package:finco_customer/providers/theme.provider.dart';
import 'package:finco_customer/routes/app_routes.dart';
import 'package:finco_customer/screens/Auth/login_screen.dart';
import 'package:finco_customer/screens/Home/home_screen.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/localization_manager.dart';
import 'package:finco_customer/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    context.read<LocalizationProvider>().loadSavedLocale();
    context.read<ThemeProvider>().loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LocalizationProvider, ThemeProvider, AuthProvider>(
      builder: (context, localizationProvider, themeProvider, authProvider, _) {
        return ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            builder: (context, child) {
              if (FlavorConfig.instance.isProd) {
                return child!;
              }
              return Banner(
                message: FlavorConfig.instance.flavor.name.toUpperCase(),
                location: BannerLocation.topEnd,
                child: child,
              );
            },
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            locale: localizationProvider.locale,
            scaffoldMessengerKey: scaffoldMessengerKey,
            supportedLocales: LocalizationManager.supportedLocaleList,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              return supportedLocales.firstWhere(
                (supportedLocale) =>
                    supportedLocale.languageCode == locale?.languageCode &&
                    supportedLocale.countryCode == locale?.countryCode,
                orElse: () => supportedLocales.first,
              );
            },
            theme: AppTheme.lightTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: (settings) {
              final builder = appRoutes[settings.name];
              if (builder == null) {
                return _errorRoute(settings.name);
              }
              return MaterialPageRoute(
                builder: (_) => builder(settings),
                settings: settings,
              );
            },
            title: FlavorConfig.instance.appName,
            home: _buildHome(authProvider),
          ),
        );
      },
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    if (!authProvider.isSessionChecked) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }

  Route<dynamic> _errorRoute(String? name) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Route not found')),
        body: Center(child: Text('No route defined for $name')),
      ),
    );
  }
}
