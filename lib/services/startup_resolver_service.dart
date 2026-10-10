import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routing/app_routes.dart';
import '../models/registration_status.dart';

enum StartupDestination {
  welcome,
  studentHome,
  facultyHome,
  facultyPending,
  collegeRegistration,
  collegePending,
  collegeRejected,
  collegeAccountSetup,
  collegeAdminDashboard,
  platformAdminLogin,
  platformAdminConsole,
  onboarding,
  suspended,
  error,
}

class StartupResolverService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StartupResolverService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<StartupDestination> resolveStartupDestination() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return StartupDestination.welcome;
      }

      // 1. Check Platform Administrator status first via custom claims or collection
      try {
        final idTokenResult = await currentUser.getIdTokenResult(true);
        final claims = idTokenResult.claims ?? {};
        final roleClaim = claims['role'] as String?;
        if (roleClaim == 'platform_admin' || roleClaim == 'super_admin') {
          return StartupDestination.platformAdminConsole;
        }

        final adminDoc = await _firestore
            .collection('platform_administrators')
            .doc(currentUser.uid)
            .get()
            .timeout(const Duration(seconds: 5));
        if (adminDoc.exists && adminDoc.data()?['isActive'] == true) {
          return StartupDestination.platformAdminConsole;
        }
      } catch (_) {}

      // 2. Retrieve authoritative user profile from Firestore with timeout
      DocumentSnapshot<Map<String, dynamic>> userDoc;
      try {
        userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .timeout(const Duration(seconds: 6));
      } catch (_) {
        return StartupDestination.error;
      }

      if (!userDoc.exists || userDoc.data() == null) {
        return await _resolveCollegeRegistrationState(currentUser.uid);
      }

      final userData = userDoc.data()!;
      final verificationStatus = (userData['verification_status'] as String? ?? 'verified').toLowerCase();
      final role = (userData['role'] as String? ?? 'student').toLowerCase();

      // 3. Check account suspension or disablement
      if (verificationStatus == 'suspended' || verificationStatus == 'disabled') {
        return StartupDestination.suspended;
      }

      // 4. Role-based resolution
      if (role == 'student') {
        if (verificationStatus == 'pending') {
          return StartupDestination.onboarding;
        }
        return StartupDestination.studentHome;
      }

      if (role == 'faculty') {
        if (verificationStatus == 'pending') {
          return StartupDestination.facultyPending;
        }
        return StartupDestination.facultyHome;
      }

      if (role == 'college_admin') {
        if (verificationStatus == 'verified') {
          return StartupDestination.collegeAdminDashboard;
        }
        return await _resolveCollegeRegistrationState(currentUser.uid);
      }

      if (role == 'platform_admin' || role == 'super_admin') {
        return StartupDestination.platformAdminConsole;
      }

      return StartupDestination.welcome;
    } catch (_) {
      return StartupDestination.error;
    }
  }

  Future<StartupDestination> _resolveCollegeRegistrationState(String uid) async {
    try {
      final regQuery = await _firestore
          .collection('college_registration_requests')
          .where('applicantUid', isEqualTo: uid)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));

      if (regQuery.docs.isEmpty) {
        return StartupDestination.collegeRegistration;
      }

      final regData = regQuery.docs.first.data();
      final statusStr = regData['status'] as String? ?? 'draft';
      final status = RegistrationStatus.fromString(statusStr);

      if (status == RegistrationStatus.draft || status.isEditable) {
        return StartupDestination.collegeRegistration;
      }

      // Route submitted, resubmitted, or under review directly to the interactive tracking screen
      if (status == RegistrationStatus.submitted ||
          status == RegistrationStatus.resubmitted ||
          status == RegistrationStatus.underReview) {
        return StartupDestination.collegeRegistration;
      }

      if (status == RegistrationStatus.rejected) {
        return StartupDestination.collegeRejected;
      }

      if (status == RegistrationStatus.approved) {
        return StartupDestination.collegeAdminDashboard;
      }

      if (status == RegistrationStatus.suspended) {
        return StartupDestination.suspended;
      }

      return StartupDestination.collegeRegistration;
    } catch (_) {
      return StartupDestination.collegeRegistration;
    }
  }

  static String routeForDestination(StartupDestination destination) {
    switch (destination) {
      case StartupDestination.welcome:
        return AppRoutes.welcome;
      case StartupDestination.studentHome:
      case StartupDestination.facultyHome:
        return AppRoutes.home;
      case StartupDestination.facultyPending:
        return AppRoutes.facultyVerificationPending;
      case StartupDestination.collegeRegistration:
      case StartupDestination.collegePending:
        return AppRoutes.collegeRegister;
      case StartupDestination.collegeRejected:
        return AppRoutes.collegeRegistrationRejected;
      case StartupDestination.collegeAccountSetup:
      case StartupDestination.collegeAdminDashboard:
        return AppRoutes.collegeAdminDashboard;
      case StartupDestination.platformAdminLogin:
      case StartupDestination.platformAdminConsole:
        return AppRoutes.platformAdminDashboard;
      case StartupDestination.onboarding:
        return AppRoutes.studentOnboarding;
      case StartupDestination.suspended:
        return AppRoutes.accountSuspended;
      case StartupDestination.error:
        return AppRoutes.welcome;
    }
  }
}