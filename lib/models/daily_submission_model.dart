import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/models/document_file_model.dart';
import 'package:finco_customer/models/upload_batch_model.dart';

/// One `DailySubmission` record — everything a client submitted on a single
/// calendar day, reviewed as one unit.
///
/// The API groups submissions under their day (`dateKey`), so the day is not
/// part of the submission payload; pass it in via [dateKey] when parsing.
class DailySubmissionModel {
  const DailySubmissionModel({
    required this.submissionId,
    required this.dateKey,
    required this.status,
    this.reviewNote,
    this.reviewedById,
    this.reviewedAt,
    this.createdAt,
    this.uploads = const <UploadBatchModel>[],
  });

  factory DailySubmissionModel.fromJson(
    Map<String, dynamic> json, {
    String dateKey = '',
  }) {
    return DailySubmissionModel(
      submissionId: BaseModel.parseString(json['submissionId']) ?? '',
      dateKey: dateKey,
      status: BaseModel.parseString(json['status']) ?? '',
      reviewNote: BaseModel.parseString(json['reviewNote']),
      reviewedById: BaseModel.parseString(json['reviewedById']),
      reviewedAt: BaseModel.parseString(json['reviewedAt']),
      createdAt: BaseModel.parseString(json['createdAt']),
      uploads: BaseModel.parseList<UploadBatchModel>(
            json['uploads'],
            (item) => UploadBatchModel.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          ) ??
          const <UploadBatchModel>[],
    );
  }

  final String submissionId;
  final String dateKey;
  final String status;
  final String? reviewNote;
  final String? reviewedById;
  final String? reviewedAt;
  final String? createdAt;
  final List<UploadBatchModel> uploads;

  bool get isPending => status.toUpperCase() == 'PENDING';

  /// Every file across every batch, in submission order.
  List<DocumentFileModel> get files => uploads
      .expand((upload) => upload.files)
      .toList(growable: false);

  int get fileCount => files.length;

  bool get hasNote => uploads.any((upload) => upload.hasNote);
}
