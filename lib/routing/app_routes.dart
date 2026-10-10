class AppRoutes {
  // Splash & Public
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String roleSelection = '/auth/role-selection';

  // Onboarding & Registration
  static const String studentOnboarding = '/auth/student-onboarding';
  static const String facultyOnboarding = '/auth/faculty-onboarding';
  static const String collegeAdminOnboarding = '/auth/college-admin-onboarding';
  static const String collegeRegister = '/college/register';

  // Status Routes
  static const String facultyVerificationPending = '/auth/faculty-pending';
  static const String collegeRegistrationPending = '/auth/college-pending';
  static const String collegeRegistrationRejected = '/auth/college-rejected';
  static const String accountSuspended = '/auth/suspended';

  // Student/Faculty Shell Routes
  static const String home = '/app/home';
  static const String explore = '/app/explore';
  static const String academics = '/app/academics';
  static const String events = '/app/events';
  static const String chats = '/app/chats';
  static const String notifications = '/app/notifications';
  static const String profile = '/app/profile';

  // Protected Admin Consoles
  static const String collegeAdminDashboard = '/college-admin/dashboard';
  static const String platformAdminLogin = '/platform-admin/login';
  static const String platformAdminDashboard = '/platform-admin/dashboard';
  static const String platformAdminRegistrationDetails = '/platform-admin/registrations/:requestId';

  static String platformAdminRegistrationDetailsPath(String requestId) => '/platform-admin/registrations/$requestId';
}
