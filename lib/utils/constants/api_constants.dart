class UrlStrings {
  UrlStrings._();

  //! Base URLs
  static const String baseUrlDev =
      'https://api-worktracker.margintopsolutions.com.np/api/v1';

  static const String baseUrlStaging =
      'https://api-worktracker.margintopsolutions.com.np/api/v1';

  static const String baseUrlProd =
      'https://api-worktracker.margintopsolutions.com.np/api/v1';

  static const String login = '/login';
  static const String me = '/me';
  static const String logout = '/logout';
  static const String changePassword = '/change-password';

  static const String dashboardSummary = '/dashboard/summary';

  static const String workItems = '/work-items';

  static const notifications = '/notifications';
  static const markAllRead = '/notifications/mark-all-read';

  static const meetings = '/meetings';

  static const deviceToken = '/device-tokens';

  static const documents = '/documents';
  static const dailySubmissions = '/documents/daily-submissions';
  static const documentStats = '/documents/daily-submissions/stats';
  static const documentsUploadUrl = '/documents/upload-url';
  static String documentDownloadUrl(String documentId) =>
      '/documents/$documentId/download-url';

  static const deactivateAccount = '/deactivate-account';
}
