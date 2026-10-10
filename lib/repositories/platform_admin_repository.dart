import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/platform_admin_model.dart';
import '../models/admin_audit_log_model.dart';
import '../models/college_registration.dart';
import '../models/registration_status.dart';
import '../models/college_application_model.dart' show ReviewChecklistModel;

abstract class PlatformAdminRepository {
  Future<PlatformAdminModel?> getPlatformAdminProfile(String uid);
  Stream<List<CollegeRegistration>> streamAllRegistrations();
  Future<bool> checkForDuplicateDomain(String domain, String excludeAppId);
  Future<void> updateChecklist({required String requestId, required ReviewChecklistModel checklist});
  Future<void> reviewRegistrationStatus({
    required String requestId,
    required RegistrationStatus previousStatus,
    required RegistrationStatus newStatus,
    String? rejectionCategory,
    String? rejectionReason,
    String? requestedChanges,
    String? adminNotes,
  });
  Stream<List<AdminAuditLogModel>> streamAuditLogs({String? requestId});
}

class FirestorePlatformAdminRepository implements PlatformAdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  @override
  Future<PlatformAdminModel?> getPlatformAdminProfile(String uid) async {
    final doc = await _firestore.collection('platform_administrators').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return PlatformAdminModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  @override
  Stream<List<CollegeRegistration>> streamAllRegistrations() {
    return _firestore
        .collection('college_registration_requests')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CollegeRegistration.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<bool> checkForDuplicateDomain(String domain, String excludeAppId) async {
    final query = await _firestore
        .collection('college_registration_requests')
        .where('institution.officialDomain', isEqualTo: domain.trim().toLowerCase())
        .where('status', isEqualTo: RegistrationStatus.approved.value)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return false;
    return query.docs.first.id != excludeAppId;
  }

  @override
  Future<void> updateChecklist({required String requestId, required ReviewChecklistModel checklist}) async {
    await _firestore.collection('college_registration_requests').doc(requestId).update({
      'review.checklist': checklist.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reviewRegistrationStatus({
    required String requestId,
    required RegistrationStatus previousStatus,
    required RegistrationStatus newStatus,
    String? rejectionCategory,
    String? rejectionReason,
    String? requestedChanges,
    String? adminNotes,
  }) async {
    _validateStateTransition(previousStatus, newStatus);
    final currentFbUser = _firebaseAuth.currentUser;
    if (currentFbUser == null) {
      throw Exception('Security Error: No active authenticated administrator session.');
    }
    final adminUid = currentFbUser.uid;
    final adminEmail = currentFbUser.email ?? 'admin@universtree.app';

    await _firestore.runTransaction((transaction) async {
      final regRef = _firestore.collection('college_registration_requests').doc(requestId);
      final snapshot = await transaction.get(regRef);
      if (!snapshot.exists) throw Exception('Registration request does not exist.');

      final data = snapshot.data() ?? {};
      final currentStatus = RegistrationStatus.fromString(data['status'] as String?);

      if (currentStatus != previousStatus) {
        throw Exception('Stale state detected. Current application status is "${currentStatus.value}". Please refresh.');
      }
      if (currentStatus.isTerminal) {
        throw Exception('Decision has already been finalized. Status override is prohibited.');
      }

      final updateData = <String, dynamic>{
        'status': newStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
        'review.reviewedBy': adminUid,
        'review.reviewedAt': FieldValue.serverTimestamp(),
      };

      if (rejectionCategory != null) updateData['review.rejectionCategory'] = rejectionCategory;
      if (rejectionReason != null) updateData['review.rejectionReason'] = rejectionReason;
      if (requestedChanges != null) updateData['review.requestedChanges'] = requestedChanges;
      if (adminNotes != null) updateData['review.reviewerNotes'] = adminNotes;

      transaction.update(regRef, updateData);

      if (newStatus == RegistrationStatus.approved) {
        final applicantUid = data['applicantUid'] as String? ?? '';
        final instMap = data['institution'] as Map? ?? {};
        final domain = instMap['officialDomain'] as String? ?? 'college';
        final collegeId = domain.replaceAll('.', '_');
        final collegeName = instMap['name'] as String? ?? 'Campus College';

        final collegeRef = _firestore.collection('colleges').doc(collegeId);
        transaction.set(collegeRef, {
          'id': collegeId,
          'name': collegeName,
          'domain': domain,
          'website': instMap['website'] ?? '',
          'status': 'ACTIVE',
          'approved_at': FieldValue.serverTimestamp(),
          'approved_by': adminUid,
        }, SetOptions(merge: true));

        if (applicantUid.isNotEmpty) {
          final userRef = _firestore.collection('users').doc(applicantUid);
          transaction.set(userRef, {
            'role': 'college_admin',
            'college_id': collegeId,
            'tenant_id': collegeId,
            'verification_status': 'verified',
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    });

    final auditRef = _firestore.collection('admin_audit_logs').doc();
    await auditRef.set({
      'adminUid': adminUid,
      'adminEmail': adminEmail,
      'action': 'APPLICATION_${newStatus.value.toUpperCase()}',
      'targetRegistrationId': requestId,
      'previousStatus': previousStatus.value,
      'newStatus': newStatus.value,
      'reason': rejectionReason ?? requestedChanges ?? adminNotes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static void _validateStateTransition(RegistrationStatus fromStatus, RegistrationStatus toStatus) {
    final allowed = {
      RegistrationStatus.submitted: [RegistrationStatus.underReview],
      RegistrationStatus.resubmitted: [RegistrationStatus.underReview], // Phase 14 Fix
      RegistrationStatus.underReview: [RegistrationStatus.approved, RegistrationStatus.rejected, RegistrationStatus.additionalInformationRequired],
    };
    if (!(allowed[fromStatus]?.contains(toStatus) ?? false)) {
      throw Exception('Invalid state transition from "${fromStatus.value}" to "${toStatus.value}". Action blocked by security state machine.');
    }
  }

  @override
  Stream<List<AdminAuditLogModel>> streamAuditLogs({String? requestId}) {
    Query query = _firestore.collection('admin_audit_logs').orderBy('timestamp', descending: true);
    if (requestId != null && requestId.isNotEmpty) {
      query = query.where('targetRegistrationId', isEqualTo: requestId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AdminAuditLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }
}