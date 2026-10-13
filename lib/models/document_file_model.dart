import 'package:finco_customer/models/base_model.dart';

/// A single uploaded file inside an upload batch.
///
/// [url] is a short-lived signed S3 link (about an hour), so it is only good
/// for the current session — call `/documents/:id/download-url` for a fresh
/// one when the returned [url] is empty or has expired.
class DocumentFileModel {
  const DocumentFileModel({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.url,
  });

  factory DocumentFileModel.fromJson(Map<String, dynamic> json) {
    return DocumentFileModel(
      id: BaseModel.parseString(json['id']) ?? '',
      fileName: BaseModel.parseString(json['fileName']) ?? '',
      mimeType: BaseModel.parseString(json['mimeType']) ?? '',
      fileSizeBytes: BaseModel.parseInt(json['fileSizeBytes']) ?? 0,
      url: BaseModel.parseString(json['url']) ?? '',
    );
  }

  final String id;
  final String fileName;
  final String mimeType;
  final int fileSizeBytes;
  final String url;

  bool get isPdf => mimeType.toLowerCase() == 'application/pdf';
}
