import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/tenant_context.dart';
import '../models/college_request_model.dart';
import '../models/faculty_request_model.dart';
import '../models/platform_admin_model.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;

    final doc = await _firestore.collection('users').doc(fbUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }

    return UserModel(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? 'User',
      role: 'student',
      tenantId: 'default_tenant',
      collegeId: 'default_college',
      universityId: 'default_univ',
      department: 'General',
      academicYear: 1,
      branch: 'General',
      verificationStatus: 'verified',
      profileCompleted: true,
      joinedAt: DateTime.now(),
    );
  }

  @override
  Future<TenantContext> getTenantContext() async {
    final user = await getCurrentUser();
    if (user != null && user.collegeId.isNotEmpty) {
      final doc = await _firestore.collection('colleges').doc(user.collegeId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return TenantContext(
          tenantId: user.tenantId,
          collegeId: user.collegeId,
          universityId: user.universityId,
          collegeName: data['name'] as String? ?? 'Campus',
          collegeShortName: data['short_name'] as String? ?? 'Campus',
          department: user.department,
          academicYear: user.academicYear,
        );
      }
    }
    return TenantContext.empty();
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }

    final user = UserModel(
      uid: uid,
      email: email,
      displayName: credential.user!.displayName ?? email.split('@').first,
      role: 'student',
      tenantId: 'ceg_main',
      collegeId: 'ceg_main',
      universityId: 'anna_univ',
      department: 'CSE',
      academicYear: 3,
      branch: 'CS',
      verificationStatus: 'verified',
      joinedAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  @override
  Future<UserModel> registerStudent({
    required String email,
    required String password,
    required String displayName,
    required String collegeDomain,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    await credential.user?.updateDisplayName(displayName);

    final user = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: 'student',
      tenantId: collegeDomain.replaceAll('.', '_'),
      collegeId: collegeDomain.replaceAll('.', '_'),
      universityId: 'universtree_univ',
      department: 'General',
      academicYear: 1,
      branch: 'General',
      verificationStatus: 'verified',
      joinedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
    return user;
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
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    await credential.user?.updateDisplayName(displayName);

    final collegeId = email.split('@').last.replaceAll('.', '_');
    final user = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: 'faculty',
      tenantId: collegeId,
      collegeId: collegeId,
      universityId: 'universtree_univ',
      department: department,
      academicYear: 0,
      branch: 'Faculty',
      verificationStatus: 'pending',
      joinedAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(uid).set(user.toMap());

    final request = FacultyRequestModel(
      id: uid,
      facultyUid: uid,
      facultyName: displayName,
      facultyEmail: email,
      collegeId: collegeId,
      collegeName: 'Campus Institution',
      department: department,
      designation: designation,
      facultyIdNumber: facultyIdNumber,
      status: 'pending',
      submittedAt: DateTime.now(),
    );
    await _firestore.collection('faculty_verification_requests').doc(uid).set(request.toMap());

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
    final currentUid = _firebaseAuth.currentUser?.uid;
    if (currentUid == null) {
      throw Exception('Unauthorized: You must verify your session before submitting.');
    }

    final reqDoc = _firestore.collection('college_registration_requests').doc();
    final req = CollegeRequestModel(
      id: reqDoc.id,
      institutionName: institutionName,
      shortName: shortName,
      officialEmail: officialEmail,
      officialDomain: officialDomain,
      officialWebsite: officialWebsite,
      campusLocation: campusLocation,
      administratorUid: currentUid,
      administratorName: administratorName,
      status: 'pending',
      submittedAt: DateTime.now(),
    );
    await reqDoc.set(req.toMap());

    return req;
  }

  // Link the submitted registration to the active user session
  Future<void> linkPendingCollegeRegistration(
      String requestId,
      String representativeName,
      String officialEmail,
      String domain
      ) async {
    final currentUid = _firebaseAuth.currentUser?.uid;
    if (currentUid == null) {
      throw Exception('Security Error: No active authenticated session.');
    }

    final userRef = _firestore.collection('users').doc(currentUid);
    await userRef.set({
      'uid': currentUid,
      'email': officialEmail,
      'display_name': representativeName,
      'role': 'college_admin',
      'tenant_id': domain.replaceAll('.', '_'),
      'college_id': domain.replaceAll('.', '_'),
      'university_id': 'pending_univ',
      'department': 'Administration',
      'academic_year': 0,
      'branch': 'Admin',
      'verification_status': 'pending',
      'registration_id': requestId,
      'profile_completed': true,
      'joined_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<UserModel> signInSuperAdmin(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    fb.UserCredential credential;

    try {
      credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on fb.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('The email address provided is invalid.');
        case 'user-disabled':
          throw Exception('This administrator account has been disabled by support.');
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Incorrect email or password. Please try again.');
        case 'too-many-requests':
          throw Exception('Access temporarily blocked due to too many failed attempts.');
        default:
          throw Exception('Authentication failed. Please check your credentials.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }

    final user = credential.user!;
    final uid = user.uid;

    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims ?? {};
    final roleClaim = claims['role'] as String?;

    if (roleClaim != 'platform_admin' && roleClaim != 'super_admin') {
      final adminDoc = await _firestore.collection('platform_administrators').doc(uid).get();
      if (!adminDoc.exists || adminDoc.data()?['isActive'] != true) {
        await _firebaseAuth.signOut();
        throw Exception('Access Denied: Custom claims and administrator record do not grant platform governance rights.');
      }
    }

    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();

    UserModel adminUser;
    if (userDoc.exists && userDoc.data() != null) {
      adminUser = UserModel.fromMap(userDoc.data()!, uid);
    } else {
      adminUser = UserModel(
        uid: uid,
        email: cleanEmail,
        displayName: user.displayName ?? 'Universtree Platform Administrator',
        role: roleClaim ?? 'platform_admin',
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
      await userRef.set(adminUser.toMap(), SetOptions(merge: true));
    }

    return adminUser;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No administrator account found with this email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Please enter a valid email address.');
      }
      throw Exception(e.message ?? 'Failed to send password reset email.');
    } catch (e) {
      throw Exception('An unexpected error occurred while resetting the password.');
    }
  }
}