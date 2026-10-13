import 'package:finco_customer/models/base_model.dart';

class DocumentStatsModel {
  const DocumentStatsModel({
    required this.pending,
    required this.verified,
    required this.rejected,
  });

  factory DocumentStatsModel.fromJson(Map<String, dynamic> json) {
    return DocumentStatsModel(
      pending: BaseModel.parseInt(json['pending']) ?? 0,
      verified: BaseModel.parseInt(json['verified']) ?? 0,
      rejected: BaseModel.parseInt(json['rejected']) ?? 0,
    );
  }

  final int pending;
  final int verified;
  final int rejected;
}
