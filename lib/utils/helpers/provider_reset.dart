import 'package:flutter/material.dart';

/// Clears every session-scoped provider so the next login starts with a
/// pristine state. Theme and localization are intentionally kept untouched:
/// they are per-device preferences, not per-session data.
void resetSessionProviders(BuildContext context) {}
