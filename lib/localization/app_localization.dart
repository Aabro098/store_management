import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The [AppLocalizations] class provides localization support for the application,
/// allowing it to display content in different languages based on the user's locale.
///
/// It loads localized strings from JSON files located in the `lib/constant/language/`
/// directory, with each file named according to the language code (e.g., `en.json`).
/// The class offers methods to retrieve localized strings and integrates with Flutter's
/// localization system via a delegate.
///
/// Usage:
/// - Include [AppLocalizations.delegate] in the `localizationsDelegates` list of your app.
/// - Access localized strings using `AppLocalizations.of(context)?.translate('key')`.
///
/// Example:
/// ```dart
/// Text(AppLocalizations.of(context)?.translate('hello') ?? 'hello')
/// ```
/// The [_AppLocalizationsDelegate] class is a custom [LocalizationsDelegate] for
/// [AppLocalizations]. It determines supported locales, loads localized resources,
/// and manages reload behavior for localization changes.
///
/// This delegate should be added to the app's `localizationsDelegates` to enable
/// localization support.
class AppLocalizations {
  /// Creates an instance of [AppLocalizations] for the specified [locale].
  ///
  /// The [locale] parameter determines the language and region settings
  /// used for localizing the application's content.
  AppLocalizations(this.locale);

  /// The locale associated with the current instance, representing the language and region settings.
  final Locale locale;

  /// Returns the [AppLocalizations] instance associated with the given [BuildContext].
  ///
  /// This method is typically used to access localized resources within the widget tree.
  /// Returns `null` if no [AppLocalizations] instance is found in the context.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// A static constant that provides the localization delegate for [AppLocalizations].
  ///
  /// This delegate is used to load and manage localized resources for the application.
  /// It should be included in the `localizationsDelegates` list of the app to enable
  /// localization support.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  /// Loads the localized strings for the current locale from a JSON file.
  ///
  /// The method reads the JSON file located at `lib/constant/language/{locale.languageCode}.json`
  /// using the [rootBundle]. It then decodes the JSON content into a map and converts all values
  /// to strings, storing them in `_localizedStrings`.
  ///
  /// Returns `true` when the loading and parsing are successful.
  /// Throws an exception if the file cannot be loaded or parsed.
  Future<bool> load() async {
    final jsonString = await rootBundle
        .loadString('lib/localization/${locale.languageCode}.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  /// Returns the localized string corresponding to the given [key].
  /// If the [key] does not exist in the localized strings, it returns the [key] itself as a fallback.
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ne'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
