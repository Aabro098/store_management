import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/models/document_file_model.dart';

/// One "Submit" tap from the client: everything uploaded together, sharing
/// the same [uploadBatchId].
///
/// A batch may carry a [note] alongside its [files] — that note is the
/// client's annotation written for those specific files, which is why they
/// have to be rendered together rather than as unrelated flat rows.
class UploadBatchModel {
  const UploadBatchModel({
    this.uploadBatchId,
    this.uploadedAt,
    this.note,
    this.files = const <DocumentFileModel>[],
  });

  factory UploadBatchModel.fromJson(Map<String, dynamic> json) {
    return UploadBatchModel(
      uploadBatchId: BaseModel.parseString(json['uploadBatchId']),
      uploadedAt: BaseModel.parseString(json['uploadedAt']),
      note: BaseModel.parseString(json['note']),
      files: BaseModel.parseList<DocumentFileModel>(
            json['files'],
            (item) => DocumentFileModel.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          ) ??
          const <DocumentFileModel>[],
    );
  }

  final String? uploadBatchId;
  final String? uploadedAt;
  final String? note;
  final List<DocumentFileModel> files;

  bool get hasNote => note != null && note!.trim().isNotEmpty;

  bool get isEmpty => !hasNote && files.isEmpty;
}
