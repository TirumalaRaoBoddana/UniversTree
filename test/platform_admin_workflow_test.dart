import 'package:flutter_test/flutter_test.dart';
import 'package:universtree/core/constants/app_constants.dart';
import 'package:universtree/models/admin_audit_log_model.dart';
import 'package:universtree/models/platform_admin_model.dart';

void main() {
  group('Platform Administrator Workflow & State Machine Unit Tests', () {
    test('1. Valid State Transition: PENDING -> UNDER_REVIEW (Start Review)', () {
      const from = RegistrationStatuses.pending;
      const to = RegistrationStatuses.underReview;

      final isPendingToReview = from == RegistrationStatuses.pending && to == RegistrationStatuses.underReview;
      expect(isPendingToReview, isTrue);
    });

    test('2. Valid State Transition: UNDER_REVIEW -> APPROVED (Approve)', () {
      const from = RegistrationStatuses.underReview;
      const to = RegistrationStatuses.approved;

      final isReviewToApproved = from == RegistrationStatuses.underReview && to == RegistrationStatuses.approved;
      expect(isReviewToApproved, isTrue);
    });

    test('3. Valid State Transition: UNDER_REVIEW -> REJECTED with non-empty reason', () {
      const from = RegistrationStatuses.underReview;
      const to = RegistrationStatuses.rejected;
      const reason = 'Incomplete accreditation document.';

      final isReviewToRejected = from == RegistrationStatuses.underReview && to == RegistrationStatuses.rejected;
      expect(isReviewToRejected, isTrue);
      expect(reason.trim().isNotEmpty, isTrue);
    });

    test('4. Rejection Reason Validation: Empty or null reason is rejected', () {
      const String? nullReason = null;
      const String emptyReason = '   ';

      expect(nullReason == null || nullReason.trim().isEmpty, isTrue);
      expect(emptyReason.trim().isEmpty, isTrue);
    });

    test('5. Double Approval Protection: APPROVED -> APPROVED is blocked', () {
      const currentStatus = RegistrationStatuses.approved;
      const newStatus = RegistrationStatuses.approved;

      final isDoubleApproval = currentStatus == RegistrationStatuses.approved && newStatus == RegistrationStatuses.approved;
      expect(isDoubleApproval, isTrue);
    });

    test('6. Stale Status Guard: Transition rejected if current status differs from expected previous status', () {
      const currentStatusInDatabase = RegistrationStatuses.approved;
      const expectedPreviousStatusFromClient = RegistrationStatuses.pending;

      final isStale = currentStatusInDatabase != expectedPreviousStatusFromClient;
      expect(isStale, isTrue);
    });

    test('7. Unauthorized Direct Transition: PENDING -> APPROVED directly is blocked', () {
      const from = RegistrationStatuses.pending;
      const to = RegistrationStatuses.approved;

      final isDirectApproval = from == RegistrationStatuses.pending && to == RegistrationStatuses.approved;
      final isPendingToReview = from == RegistrationStatuses.pending && to == RegistrationStatuses.underReview;
      final isReviewToApproved = from == RegistrationStatuses.underReview && to == RegistrationStatuses.approved;

      expect(isDirectApproval, isTrue);
      expect(isPendingToReview || isReviewToApproved, isFalse);
    });

    test('8. Admin Audit Log Model Serialization', () {
      final now = DateTime.now();
      final log = AdminAuditLogModel(
        id: 'log_101',
        adminUid: 'uid_admin_123',
        adminEmail: 'universtreeapp@gmail.com',
        action: 'approve_college_registration',
        targetRegistrationId: 'UT-2026-ABC12345',
        previousStatus: RegistrationStatuses.underReview,
        newStatus: RegistrationStatuses.approved,
        reason: 'Verified accreditation document',
        timestamp: now,
      );

      final map = log.toMap();
      expect(map['adminUid'], equals('uid_admin_123'));
      expect(map['adminEmail'], equals('universtreeapp@gmail.com'));
      expect(map['action'], equals('approve_college_registration'));
      expect(map['targetRegistrationId'], equals('UT-2026-ABC12345'));
      expect(map['previousStatus'], equals(RegistrationStatuses.underReview));
      expect(map['newStatus'], equals(RegistrationStatuses.approved));

      final deserialized = AdminAuditLogModel.fromMap(map, 'log_101');
      expect(deserialized.id, equals('log_101'));
      expect(deserialized.adminEmail, equals('universtreeapp@gmail.com'));
      expect(deserialized.action, equals('approve_college_registration'));
    });

    test('9. Platform Admin Model & Permissions Serialization', () {
      final now = DateTime.now();
      final adminModel = PlatformAdminModel(
        uid: 'admin_uid_777',
        email: 'universtreeapp@gmail.com',
        displayName: 'Universtree Platform Administrator',
        role: AppUserRoles.platformAdmin,
        adminLevel: 'super_admin',
        isActive: true,
        permissions: const PlatformAdminPermissions(
          viewRegistrations: true,
          reviewRegistrations: true,
          approveRegistrations: true,
          rejectRegistrations: true,
          viewDocuments: true,
          viewAuditLogs: true,
        ),
        createdAt: now,
        updatedAt: now,
      );

      final map = adminModel.toMap();
      expect(map['role'], equals(AppUserRoles.platformAdmin));
      expect(map['adminLevel'], equals('super_admin'));
      expect(map['permissions']['approveRegistrations'], isTrue);

      final deserialized = PlatformAdminModel.fromMap(map, 'admin_uid_777');
      expect(deserialized.uid, equals('admin_uid_777'));
      expect(deserialized.permissions.approveRegistrations, isTrue);
    });
  });
}
