import 'package:flutter/foundation.dart';

/// A base class for data models, providing a standard interface for JSON
/// serialization, deserialization, equality comparison, and immutable updates.
@immutable
abstract class BaseModel {
  const BaseModel();

  // Factory constructor to create an instance from JSON
  /// ignore: avoid_unused_constructor_parameters
  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  // also give fromRow method for database if necessary in future
  // ignore: avoid_unused_constructor_parameters
  factory BaseModel.fromRow(Map<String, dynamic> row) =>
      throw UnimplementedError();

  /// Parses a dynamic value to an integer, returns null if parsing fails.
  static int? parseInt(dynamic data) {
    if (data is int) return data;
    if (data is String) return int.tryParse(data);
    if (kDebugMode) {
      print('Failed to parse int from $data (${data.runtimeType})');
    }
    return null;
  }

  static double? parseDouble(dynamic data) {
    if (data is double) return data;
    if (data is int) return data.toDouble();
    if (data is String) return double.tryParse(data);
    if (kDebugMode) {
      print('Failed to parse double from $data (${data.runtimeType})');
    }
    return null;
  }

  static bool? parseBool(dynamic data) {
    if (data is bool) return data;
    if (data is String) return data.toLowerCase() == 'true';
    if (data is int) return data == 1;
    if (kDebugMode) {
      print('Failed to parse bool from $data (${data.runtimeType})');
    }
    return null;
  }

  static String? parseString(dynamic data) {
    if (data is String) return data;
    if (data != null) return data.toString();
    if (kDebugMode) {
      print('Failed to parse string from $data (${data.runtimeType})');
    }
    return null;
  }

  static List<T>? parseList<T>(dynamic data, T Function(dynamic) parser) {
    if (data is List) {
      return data.map((item) => parser(item)).toList().cast<T>();
    }
    if (kDebugMode) {
      print('Failed to parse list from $data (${data.runtimeType})');
    }
    return null;
  }
}
