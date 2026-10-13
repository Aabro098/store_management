import 'dart:async';

import 'package:dio/dio.dart';
import 'package:finco_customer/common/widgets/custom_button.dart';
import 'package:finco_customer/common/widgets/loading_indicator.dart';
import 'package:finco_customer/extensions/context_extensions.dart';
import 'package:finco_customer/models/daily_submission_model.dart';
import 'package:finco_customer/models/document_file_model.dart';
import 'package:finco_customer/models/upload_batch_model.dart';
import 'package:finco_customer/providers/calendar_provider.dart';
import 'package:finco_customer/providers/work_provider.dart';
import 'package:finco_customer/screens/Work/calendar_widget.dart';
import 'package:finco_customer/screens/Work/upload_documents_dialog.dart';
import 'package:finco_customer/services/dio_services.dart';
import 'package:finco_customer/utils/constants/colors.dart';
import 'package:finco_customer/utils/constants/sizes.dart';
import 'package:finco_customer/utils/helpers/helper_functions.dart';
import 'package:finco_customer/utils/helpers/style_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class WorkDetailsDocuments extends StatefulWidget {
  const WorkDetailsDocuments({super.key});

  @override
  State<WorkDetailsDocuments> createState() => _WorkDetailsDocumentsState();
}

class _WorkDetailsDocumentsState extends State<WorkDetailsDocuments> {
  late final CalendarProvider _calendar;

  @override
  void initState() {
    super.initState();
    _calendar = context.read<CalendarProvider>();
    _calendar.addListener(_onCalendarChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchDocuments(_calendar.selectedDate);
    });
  }

  @override
  void dispose() {
    _calendar.removeListener(_onCalendarChanged);
    super.dispose();
  }

  void _onCalendarChanged() {
    if (!mounted) return;
    _fetchDocuments(_calendar.selectedDate);
  }

  void _fetchDocuments(DateTime date, {bool force = false}) {
    if (!mounted) return;
    unawaited(
      context.read<WorkProvider>().fetchDocumentsForDate(date, force: force),
    );
  }

  Future<void> _openUploadDialog() async {
    final selectedDate = _calendar.selectedDate;
    await showCurvedDialog<void>(
      context: context,
      child: UploadDocumentsDialog(selectedDate: selectedDate),
    );
    if (!mounted) return;
    _fetchDocuments(_calendar.selectedDate, force: true);
  }

  Future<void> _handleDownload(DocumentFileModel file) async {
    final workProvider = context.read<WorkProvider>();
    try {
      final url = file.url;
      if (url.isNotEmpty) {
        await workProvider.openFileUrl(url);
      } else {
        await workProvider.downloadFile(documentId: file.id);
      }
    } on DioException catch (e) {
      final errorMessage = DioClient.parseDioError(e);
      showErrorSnackbar(errorMessage);
    } on Exception {
      showErrorSnackbar('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = context.watch<WorkProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CalendarWidget(),
        SizedBox(height: AppSizes.lg),
        Consumer<CalendarProvider>(
          builder: (context, calendar, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                calendar.selectedDateLabel,
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(width: AppSizes.lg),
              _addButton(),
            ],
          ),
        ),
        SizedBox(height: AppSizes.lg),
        _documentsSection(workProvider),
      ],
    );
  }

  Widget _documentsSection(WorkProvider workProvider) {
    final submissions = workProvider.documents;
    if (workProvider.isDocumentsLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: const LoadingIndicator(),
      );
    }

    final error = workProvider.documentsError;
    if (error != null && submissions.isEmpty) {
      return _errorState(error);
    }

    if (submissions.isEmpty) {
      return noDocuments();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...submissions.asMap().entries.expand(
              (entry) => [
                _submissionCard(entry.value),
                if (entry.key != submissions.length - 1)
                  SizedBox(height: AppSizes.smMd),
              ],
            ),
      ],
    );
  }

  Widget _errorState(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.warning_2, color: AppColors.error),
          SizedBox(height: AppSizes.sm),
          Text(
            error,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.md),
          OutlinedButton(
            onPressed: () =>
                _fetchDocuments(_calendar.selectedDate, force: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _submissionCard(DailySubmissionModel submission) {
    final reviewNote = submission.reviewNote?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: AppShadows.elevation,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Submission status',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              _statusBadge(submission.status),
            ],
          ),
        ),
        if (reviewNote != null && reviewNote.isNotEmpty) ...[
          SizedBox(height: AppSizes.smMd),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.smMd),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              boxShadow: AppShadows.elevation,
            ),
            child: Text(
              reviewNote,
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
        SizedBox(height: AppSizes.smMd),
        if (submission.uploads.isEmpty)
          Text(
            'No files in this submission.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.fgMuted,
            ),
          )
        else
          ...submission.uploads.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == submission.uploads.length - 1
                        ? 0
                        : AppSizes.sm,
                  ),
                  child: _uploadBatch(entry.value),
                ),
              ),
      ],
    );
  }

  /// One card per "Submit" tap. A note is rendered as a caption inside the same
  /// card as the files it was submitted with, so the pairing is obvious.
  Widget _uploadBatch(UploadBatchModel batch) {
    final note = batch.note?.trim();
    final uploadedAt = batch.uploadedAt;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: AppShadows.elevation,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note != null && note.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.smMd,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningSoft.withAlpha(200),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                boxShadow: AppShadows.elevation,
              ),
              child: Text(
                'Note for these files: $note',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.deepOrange.shade900,
                ),
              ),
            ),
            SizedBox(height: AppSizes.md),
          ],
          if (batch.files.isEmpty)
            Text(
              'No files in this upload.',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.fgMuted,
              ),
            )
          else
            ...batch.files.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      // Tight gap: files sharing a batch belong together inside
                      // the same card, unlike separate batches below.
                      bottom:
                          entry.key == batch.files.length - 1 ? 0 : AppSizes.sm,
                    ),
                    child: _fileRow(entry.value),
                  ),
                ),
          if (uploadedAt != null && uploadedAt.isNotEmpty) ...[
            if (batch.files.isNotEmpty) SizedBox(height: AppSizes.sm),
            Padding(
              padding: EdgeInsets.only(left: AppSizes.smMd),
              child: Text(
                formatDateString(
                  uploadedAt,
                  pattern: 'h:mm a',
                ),
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.fgMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fileRow(DocumentFileModel file) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await showCurvedDialog<Widget>(
          context: context,
          child: showDownloadFileDialog(
            context,
            onDownload: () => _handleDownload(file),
            fileName: file.fileName,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.sm,
          horizontal: AppSizes.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              file.isPdf ? Iconsax.document_text : Iconsax.document,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                file.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall
                    ?.copyWith(color: AppColors.primary),
              ),
            ),
            SizedBox(width: AppSizes.lg),
            Icon(
              Icons.north_east,
              color: AppColors.primary,
              size: AppSizes.iconSm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final normalizedStatus = status.toUpperCase();
    final color = switch (normalizedStatus) {
      'VERIFIED' || 'APPROVED' => AppColors.success,
      'REJECTED' => AppColors.error,
      _ => AppColors.warning,
    };
    final label = formatTitle(status.isEmpty ? 'Unknown' : status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(AppSizes.radiusBadge),
      ),
      child: Text(
        label,
        style: context.textTheme.titleSmall?.copyWith(
          color: color,
          fontSize: AppSizes.fontXs,
        ),
      ),
    );
  }

  Widget noDocuments() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(AppSizes.lg),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.smMd),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.document,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Nothing for this day',
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Upload files or a note for the selected date.',
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.md),
            _uploadButton(),
          ],
        ),
      ),
    );
  }

  Widget _uploadButton() {
    return SizedBox(
      width: 200.w,
      child: CustomElevatedButton(
        label: 'Upload for this day',
        icon: Iconsax.document_upload,
        isDisabled: false,
        isLoading: false,
        onPressed: () => unawaited(_openUploadDialog()),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        unawaited(_openUploadDialog());
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.document_upload,
              color: AppColors.fg,
              size: AppSizes.iconSm,
            ),
            SizedBox(width: AppSizes.smMd),
            Text(
              'Add',
              style: context.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
