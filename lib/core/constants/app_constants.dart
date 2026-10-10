class AppUserRoles {
  static const String student = 'student';
  static const String faculty = 'faculty';
  static const String collegeAdmin = 'college_admin';
  static const String platformAdmin = 'platform_admin';
}

class AppAccountTypes {
  static const String student = 'student';
  static const String faculty = 'faculty';
  static const String collegeAdministrator = 'college_administrator';
  static const String platformAdministrator = 'platform_administrator';
}

class RegistrationStatuses {
  static const String pending = 'PENDING';
  static const String underReview = 'UNDER_REVIEW';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
}

class FirestoreCollections {
  static const String users = 'users';
  static const String platformAdministrators = 'platform_administrators';
  static const String collegeApplications = 'collegeApplications';
  static const String adminAuditLogs = 'admin_audit_logs';
  static const String colleges = 'colleges';
}
