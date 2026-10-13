import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:finco_customer/common/widgets/custom_button.dart';
import 'package:finco_customer/common/widgets/text_form_field.dart';
import 'package:finco_customer/controller/document_controller.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/app_globals.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentsDialog extends StatefulWidget {
  const UploadDocumentsDialog({required this.selectedDate, super.key});

  final DateTime selectedDate;

  @override
  State<UploadDocumentsDialog> createState() => _UploadDocumentsDialogState();
}

class _UploadDocumentsDialogState extends State<UploadDocumentsDialog> {
  final DocumentController _documentController = DocumentController();
  final TextEditingController _noteController = TextEditingController();
  final List<_SelectedFile> _selectedFiles = [];

  /// Files whose steps 1+2 are still running; cleared the moment they settle.
  final Set<_SelectedFile> _pendingUploads = {};
  Completer<void>? _awaitUploadsCompleter;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _noteController.addListener(_onNoteChanged);
  }

  void _onNoteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _noteController
      ..removeListener(_onNoteChanged)
      ..dispose();
    super.dispose();
  }

  /// Kicks off steps 1+2 the instant a file is picked / photo is taken, so the
  /// bytes are already in the bucket while the user finishes the rest of the
  /// form. "Submit" then only runs step 3 (a fast metadata write).
  Future<void> _pickFiles() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xls', 'xlsx', 'pdf', 'jpeg', 'png', 'jpg'],
    );
    if (files.isEmpty) return;
    for (final file in files) {
      final path = file.path;
      if (path == null || path.isEmpty) continue;
      final selected = _SelectedFile(name: file.name, path: path);
      if (!mounted) return;
      setState(() {
        _addFile(selected);
      });
      unawaited(_startUpload(selected));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;
    final selected = _SelectedFile(name: picked.name, path: picked.path);
    if (!mounted) return;
    setState(() {
      _addFile(selected);
    });
    unawaited(_startUpload(selected));
  }

  void _addFile(_SelectedFile file) {
    if (!_selectedFiles.any(
      (f) => f.name == file.name && f.path == file.path,
    )) {
      _selectedFiles.add(file);
    }
  }

  Future<void> _startUpload(_SelectedFile file) async {
    _pendingUploads.add(file);
    _setFileStatus(file, status: _UploadStatus.requestingUrl);
    try {
      final mimeType = mimeTypeFor(file.name);
      file.mimeType = mimeType;
      final uploadInfo = await _documentController.getUploadUrl(
        fileName: file.name,
        mimeType: mimeType,
      );

      _setFileStatus(file, status: _UploadStatus.uploading);
      await _documentController.uploadToPresignedUrl(
        uploadUrl: uploadInfo.uploadUrl,
        filePath: file.path,
        mimeType: mimeType,
      );

      file.storageKey = uploadInfo.storageKey;
      _setFileStatus(file, status: _UploadStatus.uploaded);
    } on DioException catch (e) {
      _setFileStatus(
        file,
        status: _UploadStatus.failed,
        error: DioClient.parseDioError(e),
      );
    } on Object catch (e) {
      _setFileStatus(
        file,
        status: _UploadStatus.failed,
        error: e.toString(),
      );
    } finally {
      _pendingUploads.remove(file);
      if (_pendingUploads.isEmpty) {
        final completer = _awaitUploadsCompleter;
        _awaitUploadsCompleter = null;
        completer?.complete();
      }
    }
  }

  void _setFileStatus(
    _SelectedFile file, {
    required _UploadStatus status,
    String? error,
  }) {
    if (!mounted) return;
    setState(() {
      file
        ..status = status
        ..errorMessage = error;
    });
  }

  /// Converts a selected calendar day into the ISO-8601 string sent as
  /// `documentDate`. Uses local noon (not midnight) so the date doesn't slip
  /// back/forth a day when converted to UTC.
  String _zonedIsoStringFor(DateTime date) {
    final noonLocal = DateTime(date.year, date.month, date.day, 12);
    return noonLocal.toUtc().toIso8601String();
  }

  Future<void> _waitForPendingUploads() async {
    if (_pendingUploads.isEmpty) return;
    final completer = Completer<void>();
    _awaitUploadsCompleter = completer;
    await completer.future;
  }

  void _removeFile(int index) {
    _pendingUploads.remove(_selectedFiles[index]);
    if (!mounted) return;
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  /// Submits everything picked in this dialog as a single batch. The note (if
  /// any) is sent as a plain string on the same request, so it is guaranteed to
  /// be grouped with exactly these files — no separate round trip.
  Future<void> _submit() async {
    if (_isSubmitting) return;

    // Let any in-flight steps 1+2 finish first, then submit whatever has a
    // storage key (failed uploads simply won't be submitted).
    await _waitForPendingUploads();
    if (!mounted) return;

    final ready = _selectedFiles.where((f) => f.storageKey != null).toList();
    final note = _noteController.text.trim();
    if (ready.isEmpty && note.isEmpty) {
      showErrorSnackbar(
        "Nothing to submit. Add a file or a note, then check each item's upload status.",
      );
      return;
    }

    // Preserve the selected calendar day on the stored timestamp. Local noon
    // (not midnight) avoids a silent one-day shift when UTC is ahead of the
    // device's timezone.
    final documentDate = _zonedIsoStringFor(widget.selectedDate);

    setState(() => _isSubmitting = true);

    try {
      final response = await _documentController.createDocument(
        files: [
          for (final file in ready)
            DocumentFileDraft(
              storageKey: file.storageKey!,
              fileName: file.name,
              fileSizeBytes: file.sizeBytes,
              mimeType: file.mimeType,
            ),
        ],
        note: note.isEmpty ? null : note,
        documentDate: documentDate,
      );

      if (response == null) {
        throw Exception('No response from server');
      }

      if (!mounted) return;
      showSuccessSnackbar('Submitted successfully.');
      navigatorKey.currentState?.pop();
    } on DioException catch (e) {
      if (!mounted) return;
      showErrorSnackbar(DioClient.parseDioError(e));
    } on Object catch (e) {
      if (!mounted) return;
      showErrorSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showPickOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add file',
                  style: dialogContext.textTheme.titleLarge
                      ?.copyWith(color: AppColors.fg),
                ),
                SizedBox(height: AppSizes.md),
                _PickOption(
                  icon: Icons.photo_camera_outlined,
                  label: 'Take a photo',
                  subtitle: 'Open the camera and capture a photo',
                  onTap: () {
                    navigatorKey.currentState?.pop();
                    _takePhoto();
                  },
                ),
                SizedBox(height: AppSizes.sm),
                _PickOption(
                  icon: Icons.folder_open_outlined,
                  label: 'Browse files',
                  subtitle: 'Choose a file from your device',
                  onTap: () {
                    navigatorKey.currentState?.pop();
                    _pickFiles();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        constraints: BoxConstraints(
          maxWidth: context.width * 0.9,
          minWidth: context.width * 0.8,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingHoriz,
          vertical: AppSizes.paddingVert,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Upload for the day',
                      textAlign: TextAlign.start,
                      style: context.textTheme.headlineMedium
                          ?.copyWith(color: AppColors.fg),
                    ),
                  ),
                  SizedBox(width: AppSizes.md),
                  GestureDetector(
                    onTap: _isSubmitting
                        ? null
                        : () {
                            navigatorKey.currentState?.pop();
                          },
                    child: const Icon(
                      Icons.close,
                      color: AppColors.fgMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.md),
              Text(
                'Add files and an optional note for ${formatDate(widget.selectedDate)}. Submissions stay pending until your team reviews them.',
                textAlign: TextAlign.start,
                style: context.textTheme.bodySmall
                    ?.copyWith(color: AppColors.fgMuted),
              ),
              SizedBox(height: AppSizes.md),
              const Divider(color: AppColors.border),
              SizedBox(height: AppSizes.md),
              Text(
                'Files',
                textAlign: TextAlign.center,
                style:
                    context.textTheme.titleLarge?.copyWith(color: AppColors.fg),
              ),
              SizedBox(height: AppSizes.smMd),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.smMd,
                  vertical: AppSizes.sm,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _showPickOptions,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.smMd,
                          vertical: AppSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          color: AppColors.primarySoft,
                        ),
                        child: Text(
                          'Choose File',
                          style: context.textTheme.titleSmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedFiles.isNotEmpty) ...[
                SizedBox(height: AppSizes.smMd),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < _selectedFiles.length;
                            index++) ...[
                          if (index > 0) SizedBox(height: AppSizes.sm),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.smMd,
                              vertical: AppSizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedFiles[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(color: AppColors.black),
                                      ),
                                      if (_selectedFiles[index].status ==
                                          _UploadStatus.failed) ...[
                                        SizedBox(height: AppSizes.xs),
                                        Text(
                                          'Upload failed',
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppColors.error,
                                            fontSize: AppSizes.fontSm,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppSizes.sm),
                                _FileStatusIcon(
                                  status: _selectedFiles[index].status,
                                ),
                                SizedBox(width: AppSizes.sm),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _removeFile(index),
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.fg,
                                    size: AppSizes.iconSm,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: AppSizes.sm),
              Text(
                'You can select multiple files for the same day.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall
                    ?.copyWith(color: AppColors.fgMuted),
              ),
              SizedBox(height: AppSizes.md),
              Text(
                'Note',
                textAlign: TextAlign.center,
                style:
                    context.textTheme.titleLarge?.copyWith(color: AppColors.fg),
              ),
              SizedBox(height: AppSizes.smMd),
              TextFieldData(
                hintText: 'Optional - add details for your supervisor...',
                controller: _noteController,
                maxLines: 3,
              ),
              SizedBox(height: AppSizes.md),
              const Divider(color: AppColors.border),
              SizedBox(height: AppSizes.lg),
              CustomElevatedButton(
                label: 'Submit',
                isDisabled: _isSubmitting ||
                    (_selectedFiles.isEmpty &&
                        _noteController.text.trim().isEmpty),
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
              SizedBox(height: AppSizes.md),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isSubmitting
                    ? null
                    : () {
                        navigatorKey.currentState?.pop();
                      },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingHoriz,
                    vertical: AppSizes.smMd,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Text(
                    'Cancel',
                    style: context.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedFile {
  _SelectedFile({required this.name, required this.path});

  final String name;
  final String path;
  String mimeType = 'application/octet-stream';
  String? storageKey;
  _UploadStatus status = _UploadStatus.idle;
  String? errorMessage;

  int get sizeBytes {
    final file = File(path);
    return file.existsSync() ? file.lengthSync() : 0;
  }
}

enum _UploadStatus {
  idle,
  requestingUrl,
  uploading,
  uploaded,
  failed,
}

/// Compact progress indicator shown next to each picked file.
class _FileStatusIcon extends StatelessWidget {
  const _FileStatusIcon({required this.status});

  final _UploadStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _UploadStatus.uploaded:
        return Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: AppSizes.iconSm,
        );
      case _UploadStatus.failed:
        return Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: AppSizes.iconSm,
        );
      case _UploadStatus.idle:
      case _UploadStatus.requestingUrl:
      case _UploadStatus.uploading:
        return SizedBox(
          height: AppSizes.iconXs,
          width: AppSizes.iconXs,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        );
    }
  }
}

String mimeTypeFor(String fileName) {
  final extension = fileName.split('.').last.toLowerCase();
  switch (extension) {
    case 'pdf':
      return 'application/pdf';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'csv':
      return 'text/csv';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    default:
      return 'application/octet-stream';
  }
}

class _PickOption extends StatelessWidget {
  const _PickOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.smMd,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.sm),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.titleMedium
                        ?.copyWith(color: AppColors.fg),
                  ),
                  SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: AppColors.fgMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
