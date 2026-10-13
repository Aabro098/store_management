import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// *This class will use SharedPreferences for storing theme preferences
class ThemeStorage {
  ThemeStorage._();

  static const String _themeKey =
      'theme_mode'; // Saving the theme preferences by the key "theme_mode"

  // *Set the selected theme in the shared preferences.
  static Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final theme = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_themeKey, theme);
  }

  // *Get the theme from the shared preferences.
  static Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
}
