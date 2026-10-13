import 'dart:async';

import 'package:finco_customer/utils/local_storage/localization_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provider for managing and persisting app localization.
/// Handles loading, switching, and notifying listeners of locale changes.
class LocalizationProvider extends ChangeNotifier {
  // Get the locale of the device by default
  // Locale _locale = PlatformDispatcher.instance.locale;

  // For now the default is the english locale
  Locale _locale = const Locale('en', 'US');

  /// Helper to get the current locale value
  Locale get locale => _locale;

  /// Load the saved locale from SharedPreferences when initialized
  Future<void> loadSavedLocale() async {
    _locale = await loadLocaleFromSharedPreference();
    notifyListeners();
  }

  /// Change the locale and save it to SharedPreferences
  Future<void> switchLocale(Locale newLocale) async {
    _locale = newLocale;
    // TtsService().updateLocale(_locale);
    if (kDebugMode) {
      print(_locale);
    }
    unawaited(saveLocaleToSharedPreference(newLocale));
    notifyListeners(); // Notify listeners to rebuild with the new locale
  }
}
