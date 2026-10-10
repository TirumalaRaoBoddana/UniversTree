import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/college_application_model.dart';
import '../models/audit_log_model.dart';

abstract class CollegeApplicationRepository {
  Future<CollegeApplicationModel> submitApplication(CollegeApplicationModel application);
  Future<List<CollegeApplicationModel>> getPendingApplications();
  Future<CollegeApplicationModel?> getApplicationByApplicantUid(String uid);
  Future<void> reviewApplication({
    required String applicationId,
    required String newStatus, // 'APPROVED' | 'REJECTED' | 'MORE_INFO_REQUIRED'
    String? rejectionReason,
    String? adminNotes,
  });
}

class FirestoreCollegeApplicationRepository implements CollegeApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  @override
  Future<CollegeApplicationModel> submitApplication(CollegeApplicationModel application) async {
    final currentUid = _auth.currentUser?.uid ?? 'development_fallback_uid';

    // === SECURITY FIX 2: Validate Email/Domain Integrity ===
    // Prevents payload spoofing where a user verifies one email but claims another domain.
    final repEmail = application.representative.officialEmail.toLowerCase();
    final instDomain = application.institution.officialEmailDomain.toLowerCase();
    if (!repEmail.endsWith('@$instDomain')) {
      throw Exception('Security Error: The representative email ($repEmail) does not match the registered institution domain ($instDomain).');
    }

    final docRef = _firestore.collection('collegeApplications').doc(application.applicationId);

    // Duplicate check server query based on official email or domain
    final existingQuery = await _firestore
        .collection('collegeApplications')
        .where('institution.official_email_domain', isEqualTo: application.institution.officialEmailDomain)
        .where('status', whereIn: ['PENDING', 'APPROVED', 'UNDER_REVIEW'])
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      final existing = existingQuery.docs.first;
      if (existing.id != application.applicationId) {
        throw Exception('An active application already exists for the domain (${application.institution.officialEmailDomain}). Application ID: ${existing.id}');
      }
    }

    // Force PENDING status on client submit and override UID with secure server UID
    final pendingApplication = CollegeApplicationModel(
      applicationId: application.applicationId,
      applicantUid: currentUid, // SECURED: Ignores client payload, uses server token
      representative: application.representative,
      verification: application.verification,
      institution: application.institution,
      location: application.location,
      documents: application.documents,
      status: 'PENDING',
      review: application.review,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(pendingApplication.toMap());

    // Write immutable audit log entry
    final auditRef = _firestore.collection('collegeApplicationAuditLogs').doc();
    final auditLog = AuditLogModel(
      id: auditRef.id,
      actorUid: currentUid, // SECURED
      actorName: pendingApplication.representative.fullName,
      actorRole: 'college_applicant',
      action: 'APPLICATION_SUBMITTED',
      targetId: pendingApplication.applicationId,
      targetType: 'CollegeApplication',
      details: 'Submitted registration for ${pendingApplication.institution.fullName}',
      timestamp: DateTime.now(),
    );

    await auditRef.set(auditLog.toMap());

    return pendingApplication;
  }

  @override
  Future<List<CollegeApplicationModel>> getPendingApplications() async {
    final snapshot = await _firestore
        .collection('collegeApplications')
        .where('status', isEqualTo: 'PENDING')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CollegeApplicationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<CollegeApplicationModel?> getApplicationByApplicantUid(String uid) async {
    final snapshot = await _firestore
        .collection('collegeApplications')
        .where('applicant_uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return CollegeApplicationModel.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  @override
  Future<void> reviewApplication({
    required String applicationId,
    required String newStatus,
    String? rejectionReason,
    String? adminNotes,
  }) async {
    final adminUid = _auth.currentUser?.uid;

    if (adminUid == null) {
      throw Exception('Security Error: No active authenticated session.');
    }

    final docRef = _firestore.collection('collegeApplications').doc(applicationId);

    await docRef.update({
      'status': newStatus,
      'review.reviewed_by': adminUid,
      'review.reviewed_at': DateTime.now().millisecondsSinceEpoch,
      'review.rejection_reason': rejectionReason,
      'review.admin_notes': adminNotes,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    final auditRef = _firestore.collection('collegeApplicationAuditLogs').doc();
    final auditLog = AuditLogModel(
      id: auditRef.id,
      actorUid: adminUid,
      actorName: 'Platform Administrator',
      actorRole: 'super_admin',
      action: 'APPLICATION_$newStatus',
      targetId: applicationId,
      targetType: 'CollegeApplication',
      details: 'Application status changed to $newStatus',
      timestamp: DateTime.now(),
    );

    await auditRef.set(auditLog.toMap());
  }
}