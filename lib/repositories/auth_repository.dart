import '../models/user_model.dart';
import '../models/tenant_context.dart';
import '../models/college_request_model.dart';
import '../models/faculty_request_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<TenantContext> getTenantContext();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> registerStudent({
    required String email,
    required String password,
    required String displayName,
    required String collegeDomain,
  });
  Future<FacultyRequestModel> registerFacultyRequest({
    required String email,
    required String password,
    required String displayName,
    required String department,
    required String designation,
    String? facultyIdNumber,
  });
  Future<CollegeRequestModel> submitCollegeRegistration({
    required String institutionName,
    required String shortName,
    required String officialEmail,
    required String officialDomain,
    required String officialWebsite,
    required String campusLocation,
    required String administratorName,
  });
  Future<UserModel> signInSuperAdmin(String email, String password);
  Future<void> signOut();

  // ADDED: Password reset contract
  Future<void> sendPasswordResetEmail(String email);
}

class MockAuthRepository implements AuthRepository {
  // Singleton instance to preserve state across app navigation
  static final MockAuthRepository _instance = MockAuthRepository._internal();
  factory MockAuthRepository() => _instance;
  MockAuthRepository._internal();

  // Null by default so new users see Splash -> Welcome -> Role Selection
  UserModel? _currentUser;

  final TenantContext _tenantContext = const TenantContext(
    tenantId: 'ceg_main',
    collegeId: 'ceg_main',
    universityId: 'anna_univ',
    collegeName: 'College of Engineering, Guindy',
    collegeShortName: 'CEG',
    department: 'CSE',
    academicYear: 3,
  );

  final List<CollegeRequestModel> _collegeRequests = [];
  final List<FacultyRequestModel> _facultyRequests = [];

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<TenantContext> getTenantContext() async {
    return _tenantContext;
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (email.contains('superadmin')) {
      return signInSuperAdmin(email, password);
    } else if (email.contains('admin')) {
      _currentUser = UserModel(
        uid: 'u_admin_1',
        email: email,
        displayName: 'College Administrator',
        role: 'college_admin',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        universityId: 'anna_univ',
        department: 'Administration',
        academicYear: 0,
        branch: 'Admin',
        verificationStatus: 'verified',
        profileCompleted: true,
        joinedAt: DateTime.now(),
      );
      return _currentUser!;
    } else if (email.contains('faculty')) {
      _currentUser = UserModel(
        uid: 'u_fac_1',
        email: email,
        displayName: 'Dr. R. Ramanathan',
        role: 'faculty',
        tenantId: 'ceg_main',
        collegeId: 'ceg_main',
        universityId: 'anna_univ',
        department: 'CSE',
        academicYear: 0,
        branch: 'Faculty',
        verificationStatus: 'verified',
        profileCompleted: true,
        joinedAt: DateTime.now(),
      );
      return _currentUser!;
    }

    _currentUser = UserModel(
      uid: 'u_101',
      email: email,
      displayName: 'Aditya Kumar',
      role: 'student',
      tenantId: 'ceg_main',
      collegeId: 'ceg_main',
      universityId: 'anna_univ',
      department: 'CSE',
      academicYear: 3,
      branch: 'B.Tech Computer Science',
      verificationStatus: 'verified',
      profileCompleted: true,
      joinedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> registerStudent({
    required String email,
    required String password,
    required String displayName,
    required String collegeDomain,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = UserModel(
      uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      role: 'student',
      tenantId: 'ceg_main',
      collegeId: 'ceg_main',
      universityId: 'anna_univ',
      department: 'General',
      academicYear: 1,
      branch: 'Engineering',
      verificationStatus: 'verified',
      profileCompleted: true,
      joinedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<FacultyRequestModel> registerFacultyRequest({
    required String email,
    required String password,
    required String displayName,
    required String department,
    required String designation,
    String? facultyIdNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final request = FacultyRequestModel(
      id: 'freq_${DateTime.now().millisecondsSinceEpoch}',
      facultyUid: 'u_fac_${DateTime.now().millisecondsSinceEpoch}',
      facultyName: displayName,
      facultyEmail: email,
      collegeId: 'ceg_main',
      collegeName: 'College of Engineering, Guindy',
      department: department,
      designation: designation,
      facultyIdNumber: facultyIdNumber,
      status: 'pending',
      submittedAt: DateTime.now(),
    );
    _facultyRequests.add(request);

    // Set pending user session
    _currentUser = UserModel(
      uid: request.facultyUid,
      email: email,
      displayName: displayName,
      role: 'faculty',
      tenantId: 'ceg_main',
      collegeId: 'ceg_main',
      universityId: 'anna_univ',
      department: department,
      academicYear: 0,
      branch: 'Faculty',
      verificationStatus: 'pending',
      profileCompleted: true,
      joinedAt: DateTime.now(),
    );

    return request;
  }

  @override
  Future<CollegeRequestModel> submitCollegeRegistration({
    required String institutionName,
    required String shortName,
    required String officialEmail,
    required String officialDomain,
    required String officialWebsite,
    required String campusLocation,
    required String administratorName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final req = CollegeRequestModel(
      id: 'creq_${DateTime.now().millisecondsSinceEpoch}',
      institutionName: institutionName,
      shortName: shortName,
      officialEmail: officialEmail,
      officialDomain: officialDomain,
      officialWebsite: officialWebsite,
      campusLocation: campusLocation,
      administratorUid: 'u_admin_${DateTime.now().millisecondsSinceEpoch}',
      administratorName: administratorName,
      status: 'pending',
      submittedAt: DateTime.now(),
    );
    _collegeRequests.add(req);

    // Set pending college admin session
    _currentUser = UserModel(
      uid: req.administratorUid,
      email: officialEmail,
      displayName: administratorName,
      role: 'college_admin',
      tenantId: 'pending_tenant',
      collegeId: 'pending_college',
      universityId: 'pending_univ',
      department: 'Administration',
      academicYear: 0,
      branch: 'Admin',
      verificationStatus: 'pending',
      profileCompleted: true,
      joinedAt: DateTime.now(),
    );

    return req;
  }

  @override
  Future<UserModel> signInSuperAdmin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = UserModel(
      uid: 'u_super_admin',
      email: email,
      displayName: 'Platform Administrator',
      role: 'super_admin',
      tenantId: 'platform_global',
      collegeId: 'platform_global',
      universityId: 'platform_global',
      department: 'Platform Governance',
      academicYear: 0,
      branch: 'Governance',
      verificationStatus: 'verified',
      profileCompleted: true,
      joinedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  // ADDED: Mock implementation for password reset
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulates a network delay for sending the reset email
    await Future.delayed(const Duration(milliseconds: 800));
  }
}