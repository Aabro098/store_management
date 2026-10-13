import 'dart:io';

import 'package:dio/dio.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/api_constants.dart';

/// Result of the upload-url step (step 1) — holds everything needed to PUT
/// the file and to later create the Document row.
class UploadUrlResult {
  const UploadUrlResult({required this.uploadUrl, required this.storageKey});

  final String uploadUrl;
  final String storageKey;
}

/// One entry of the `files` array sent to `POST /documents` (step 3) — the
/// metadata for a file whose bytes are already in the bucket.
class DocumentFileDraft {
  const DocumentFileDraft({
    required this.storageKey,
    required this.fileName,
    required this.fileSizeBytes,
    required this.mimeType,
  });

  final String storageKey;
  final String fileName;
  final int fileSizeBytes;
  final String mimeType;

  Map<String, dynamic> toJson() => {
        'storageKey': storageKey,
        'fileName': fileName,
        'fileSizeBytes': fileSizeBytes,
        'mimeType': mimeType,
      };
}

/// Implements the three-step document upload flow from API.md:
///
/// 1. `POST /documents/upload-url` — get a presigned S3 URL + storage key.
/// 2. `PUT` raw file bytes directly to that URL (no Authorization header).
/// 3. `POST /documents` — write the Document metadata row (fast).
///
/// Steps 1+2 are meant to run the instant the user picks a file / takes a
/// photo, so by the time they finish the rest of the form the bytes are
/// already in the bucket. Step 3 is what "Submit" calls.
class DocumentController {
  factory DocumentController() => _instance;
  DocumentController._internal();
  // Singleton instance
  static final DocumentController _instance = DocumentController._internal();

  /// Step 1 — ask the API for a presigned upload URL and a storage key.
  Future<UploadUrlResult> getUploadUrl({
    required String fileName,
    String? mimeType,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.post<Map<String, dynamic>>(
        UrlStrings.documentsUploadUrl,
        data: {
          'fileName': fileName,
          if (mimeType != null) 'mimeType': mimeType,
        },
      );

      final data = response.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Upload URL response was malformed.');
      }

      final uploadUrl = data['uploadUrl'];
      final storageKey = data['storageKey'];
      if (uploadUrl is! String ||
          uploadUrl.isEmpty ||
          storageKey is! String ||
          storageKey.isEmpty) {
        throw Exception('Upload URL response was missing required fields.');
      }

      return UploadUrlResult(uploadUrl: uploadUrl, storageKey: storageKey);
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Step 2 — PUT the raw file bytes straight to the presigned S3 URL.
  ///
  /// Deliberately uses a bare [Dio] with no interceptors: the presigned URL
  /// must NOT carry the API's `Authorization` header, and `Content-Type` must
  /// match the `mimeType` sent in step 1 (S3 validates it against the
  /// signature).
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required String filePath,
    required String mimeType,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Selected file could not be read.');
    }

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    try {
      await dio.put<void>(
        uploadUrl,
        data: await file.readAsBytes(),
        options: Options(
          headers: {'Content-Type': mimeType},
          responseType: ResponseType.plain,
        ),
      );
    } on DioException {
      rethrow;
    } finally {
      dio.close(force: true);
    }
  }

  /// Step 3 — create the `Document` row (status: `PENDING`) from the
  /// `storageKey` obtained in step 1. This is the fast metadata write that
  /// "Submit" runs.
  ///
  /// One call covers a whole submission batch: every file the user added in a
  /// single "Submit" tap goes out as one `files` array, and [note] — when
  /// given — is the annotation written for exactly those files. The server
  /// groups them under one batch and hooks them onto that day's existing
  /// submission, or creates a new `PENDING` one if it is the day's first.
  Future<Map<String, dynamic>?> createDocument({
    required List<DocumentFileDraft> files,
    String? note,
    String? documentDate,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.post<Map<String, dynamic>>(
        UrlStrings.documents,
        data: {
          'files': files.map((file) => file.toJson()).toList(),
          if (note != null && note.isNotEmpty) 'note': note,
          if (documentDate != null) 'documentDate': documentDate,
        },
      );

      return response.data;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// `GET /documents/daily-submissions?status=&page=&perPage=`.
  Future<Map<String, dynamic>?> getDocuments({
    String? status,
    int page = 1,
    int perPage = 10,
    String? dateKey,
  }) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.dailySubmissions,
        queryParameters: {
          'page': page,
          'perPage': perPage,
          if (status != null) 'status': status,
          if (dateKey != null) 'dateKey': dateKey,
        },
      );

      return response.data;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// `GET /documents/:id/download-url` — returns a temporary download URL.
  Future<String?> getDownloadUrl({required String documentId}) async {
    try {
      final dio = await DioClient.initClient();

      final response = await dio.get<Map<String, dynamic>>(
        UrlStrings.documentDownloadUrl(documentId),
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return data['downloadUrl'] as String?;
      }
      return null;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
