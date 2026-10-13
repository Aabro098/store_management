import 'package:finco_customer/models/base_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserData implements BaseModel {
  const UserData({
    required this.clientName,
    required this.clientId,
    required this.businessName,
    required this.businessEmail,
    required this.phone,
    required this.panVat,
    required this.nature,
    required this.clientEmail,
    required this.assignedSupervisorName,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      clientName: BaseModel.parseString(json['name']) ?? '',
      clientId: BaseModel.parseString(json['clientId']) ?? '',
      businessName: BaseModel.parseString(json['businessName']) ?? '',
      businessEmail: BaseModel.parseString(json['email']) ?? '',
      phone: BaseModel.parseString(json['phone']) ?? '',
      panVat: BaseModel.parseString(json['panVat']) ?? '',
      nature: BaseModel.parseString(json['nature']) ?? '',
      clientEmail: BaseModel.parseString(json['clientEmail']) ?? '',
      assignedSupervisorName:
          BaseModel.parseString(json['assignedSupervisorName']) ?? '',
    );
  }

  factory UserData.fromRow() {
    throw UnimplementedError('UserData.fromRow not implemented');
  }
  final String clientName;
  final String clientId;
  final String businessName;
  final String businessEmail;
  final String phone;
  final String panVat;
  final String nature;
  final String clientEmail;
  final String assignedSupervisorName;

  Map<String, dynamic> toJson() {
    return {
      'name': clientName,
      'clientId': clientId,
      'businessName': businessName,
      'phone': phone,
      'panVat': panVat,
      'nature': nature,
      'clientEmail': clientEmail,
      'assignedSupervisorName': assignedSupervisorName,
    };
  }

  UserData copyWith({
    String? clientName,
    String? clientId,
    String? businessName,
    String? businessEmail,
    String? phone,
    String? panVat,
    String? nature,
    String? clientEmail,
    String? assignedSupervisorName,
  }) {
    return UserData(
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      phone: phone ?? this.phone,
      panVat: panVat ?? this.panVat,
      nature: nature ?? this.nature,
      clientEmail: clientEmail ?? this.clientEmail,
      assignedSupervisorName:
          assignedSupervisorName ?? this.assignedSupervisorName,
    );
  }
}
