import 'package:finco_customer/models/base_model.dart';
import 'package:finco_customer/models/daily_submission_model.dart';

/// The top level of the `GET /documents/daily-submissions` payload: one entry
/// per calendar day, each holding that day's submissions.
class DocumentDayModel {
  const DocumentDayModel({
    required this.dateKey,
    this.submissions = const <DailySubmissionModel>[],
  });

  factory DocumentDayModel.fromJson(Map<String, dynamic> json) {
    final dateKey = BaseModel.parseString(json['date']) ?? '';
    return DocumentDayModel(
      dateKey: dateKey,
      submissions: BaseModel.parseList<DailySubmissionModel>(
            json['submissions'],
            (item) => DailySubmissionModel.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
              dateKey: dateKey,
            ),
          ) ??
          const <DailySubmissionModel>[],
    );
  }

  final String dateKey;
  final List<DailySubmissionModel> submissions;

  int get fileCount => submissions.fold(0, (total, item) => total + item.fileCount);

  bool get isEmpty => submissions.isEmpty;
}
