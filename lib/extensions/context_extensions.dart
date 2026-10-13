import 'package:finco_customer/localization/app_localization.dart';
import 'package:finco_customer/utils/device/device_utility.dart';
import 'package:flutter/material.dart';

/// Extension on [BuildContext] providing a shorthand method for localized string translation.
///
/// The [tr] method returns the localized string  using [AppLocalizations].
extension LocalizationExtension on BuildContext {
  /// A method tr() for shorthand of AppLocalizations.of(this)!.translate(key)
  String tr(String key) {
    return AppLocalizations.of(this)!.translate(key);
  }

  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ThemeData get theme => Theme.of(this);

  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;

  bool get isDarkMode => DeviceUtility.isDarkMode(this);
}
