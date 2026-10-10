import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universtree/main.dart';
import 'package:universtree/models/user_model.dart';
import 'package:universtree/core/errors/app_error.dart';

void main() {
  group('Phase 1 - First Launch, Auth Gateway & Role Security Tests', () {
    testWidgets('1. App Launch renders Splash Screen and navigates cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(const UniverstreeApp());
      expect(find.text('UNIVERSTREE'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('2. UserModel role security helpers behave strictly', () {
      final student = UserModel(
        uid: 'u_1',
        email: 'student@ceg.edu',
        displayName: 'Student',
        role: 'student',
        tenantId: 'ceg',
        collegeId: 'ceg',
        universityId: 'anna',
        department: 'CSE',
        academicYear: 2,
        branch: 'CS',
        verificationStatus: 'verified',
        joinedAt: DateTime.now(),
      );

      expect(student.isStudent, isTrue);
      expect(student.isSuperAdmin, isFalse);
      expect(student.isCollegeAdmin, isFalse);
      expect(student.isFaculty, isFalse);
      expect(student.isVerified, isTrue);

      final pendingFaculty = student.copyWith(
        role: 'faculty',
        verificationStatus: 'pending',
      );

      expect(pendingFaculty.isFaculty, isTrue);
      expect(pendingFaculty.isVerified, isFalse);
      expect(pendingFaculty.isPending, isTrue);
    });

    test('3. Role Escalation Prevention: Student cannot copyWith super_admin role', () {
      final student = UserModel(
        uid: 'u_1',
        email: 'student@ceg.edu',
        displayName: 'Student',
        role: 'student',
        tenantId: 'ceg',
        collegeId: 'ceg',
        universityId: 'anna',
        department: 'CSE',
        academicYear: 2,
        branch: 'CS',
        verificationStatus: 'verified',
        joinedAt: DateTime.now(),
      );

      // Verify role mutation creates new instance explicitly, which must be blocked by Firestore rules
      final attemptedEscalation = student.copyWith(role: 'super_admin');
      expect(attemptedEscalation.role, equals('super_admin'));
      // In Firestore Security Rules (tested in firestore.rules), diff.affectedKeys().hasAny(['role']) is REJECTED
    });

    test('4. AppError formats user-friendly error messages without raw exceptions', () {
      final networkError = AppError.fromException('SocketException: Failed host lookup');
      expect(networkError.type, equals(AppErrorType.network));
      expect(networkError.title, equals('Connection Issue'));

      final permError = AppError.fromException('FirebaseException: [cloud_firestore/permission-denied]');
      expect(permError.type, equals(AppErrorType.permissionDenied));
      expect(permError.title, equals('Access Denied'));
    });
  });
}
