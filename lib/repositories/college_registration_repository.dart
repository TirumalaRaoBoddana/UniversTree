import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/registration_auth_service.dart';
import '../models/college_registration.dart';
import '../models/registration_status.dart';

abstract class CollegeRegistrationRepository {
  Future<CollegeRegistration?> getActiveRegistration();
  Future<CollegeRegistration> createDraft();
  Future<void> saveStep(CollegeRegistration registration);
  Future<void> submitRegistration(String requestId);
  Future<void> logAuditAction(
      String requestId,
      String action,
      String fromStatus,
      String toStatus, [
        Map<String, dynamic>? metadata,
      ]);
  Future<bool> checkDomainExists(String officialDomain, String currentRequestId);
}

class FirestoreCollegeRegistrationRepository implements CollegeRegistrationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final RegistrationAuthService _authService = RegistrationAuthService();

  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Security Error: No active authenticated session.');
    }
    return uid;
  }

  /// Generates a human-readable deterministic Registration ID (e.g., UT-REG-2026-A1B2C3)
  String _generateRequestId() {
    final year = DateTime.now().year;
    final randomPart = _firestore.collection('college_registration_requests').doc().id.substring(0, 6).toUpperCase();
    return 'UT-REG-$year-$randomPart';
  }

  @override
  Future<CollegeRegistration?> getActiveRegistration() async {
    // Ensure the anonymous auth token is active and recognized
    final user = await _authService.ensureActiveSession();

    // 🌟 FIX: Query by applicantUid only to prevent missing composite index errors on physical devices
    final snapshot = await _firestore
        .collection('college_registration_requests')
        .where('applicantUid', isEqualTo: user.uid)
        .get(const GetOptions(source: Source.server));

    if (snapshot.docs.isEmpty) return null;

    // Sort locally by updatedAt descending to pick the most recent draft
    final docs = snapshot.docs.toList();
    docs.sort((a, b) {
      final aData = a.data();
      final bData = b.data();

      dynamic parseTime(dynamic val) {
        if (val == null) return DateTime.now();
        if (val is Timestamp) return val.toDate();
        if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
        return DateTime.now();
      }

      final DateTime aTime = parseTime(aData['updatedAt'] ?? aData['updated_at']);
      final DateTime bTime = parseTime(bData['updatedAt'] ?? bData['updated_at']);
      return bTime.compareTo(aTime);
    });

    return CollegeRegistration.fromMap(
      docs.first.data(),
      docs.first.id,
    );
  }

  @override
  Future<CollegeRegistration> createDraft() async {
    final user = await _authService.ensureActiveSession();
    final uid = user.uid;

    // Duplicate Protection: Prevent creating a new draft if an active/pending one exists
    final existingRegistration = await getActiveRegistration();
    if (existingRegistration != null && !existingRegistration.status.isTerminal) {
      return existingRegistration;
    }

    final requestId = _generateRequestId();
    final docRef = _firestore.collection('college_registration_requests').doc(requestId);
    final draft = CollegeRegistration.newDraft(
      requestId: requestId,
      applicantUid: uid,
    );

    // Initial write utilizes server-side timestamps for audit accuracy
    final data = draft.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(data);

    await logAuditAction(requestId, 'registration_created', 'none', RegistrationStatus.draft.value);
    return draft;
  }

  @override
  Future<void> saveStep(CollegeRegistration registration) async {
    final uid = _currentUid;

    // Strict Ownership Boundary
    if (registration.applicantUid != uid) {
      throw Exception('Security Error: Ownership mismatch. You cannot modify a registration you do not own.');
    }

    final docRef = _firestore.collection('college_registration_requests').doc(registration.requestId);
    final updateData = registration.toMap();
    updateData['updatedAt'] = FieldValue.serverTimestamp();

    // Strip nested fields that should only be modified via explicit secure transactions (like submission)
    updateData.remove('createdAt');
    updateData.remove('applicantUid');

    await docRef.update(updateData);
  }

  @override
  Future<void> submitRegistration(String requestId) async {
    final uid = _currentUid;
    final regRef = _firestore.collection('college_registration_requests').doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(regRef);
      if (!snapshot.exists) {
        throw Exception('Registration request does not exist.');
      }

      final data = snapshot.data()!;
      if (data['applicantUid'] != uid) {
        throw Exception('Security Error: Ownership mismatch during submission.');
      }

      final currentStatus = RegistrationStatus.fromString(data['status'] as String?);

      // We allow submission from 'ready_for_review' OR 'additional_information_required'
      if (!currentStatus.isEditable) {
        throw Exception('Registration cannot be submitted from its current state.');
      }

      final isResubmission = currentStatus == RegistrationStatus.additionalInformationRequired;
      final newStatus = isResubmission ? RegistrationStatus.resubmitted.value : RegistrationStatus.submitted.value;

      // =======================================================================
      // ATOMIC DOMAIN RESERVATION & RACE CONDITION PREVENTION
      // =======================================================================
      final institutionMap = data['institution'] as Map? ?? {};
      final officialDomain = (institutionMap['officialDomain'] as String? ?? '').trim().toLowerCase();
      if (officialDomain.isEmpty) {
        throw Exception('Official domain cannot be empty.');
      }

      // Check the dedicated domain registry atomically
      final domainRef = _firestore.collection('registered_domains').doc(officialDomain);
      final domainSnapshot = await transaction.get(domainRef);

      if (domainSnapshot.exists) {
        final existingRequestId = domainSnapshot.data()?['requestId'];
        if (existingRequestId != requestId) {
          throw Exception('Domain uniqueness violation: "@$officialDomain" is already registered or pending.');
        }
      }

      // Reserve the domain atomically for this request
      transaction.set(domainRef, {
        'requestId': requestId,
        'reservedBy': uid,
        'reservedAt': FieldValue.serverTimestamp(),
      });

      // =======================================================================
      transaction.update(regRef, {
        'status': newStatus,
        'currentStep': 8, // Route to Tracking UI
        'updatedAt': FieldValue.serverTimestamp(),
        'review.submittedAt': FieldValue.serverTimestamp(),
      });

      // Write immutable audit log
      final auditRef = regRef.collection('audit_logs').doc();
      transaction.set(auditRef, {
        'action': isResubmission ? 'registration_resubmitted' : 'registration_submitted',
        'from': currentStatus.value,
        'to': newStatus,
        'performedBy': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // =======================================================================
      // SYNC USER PROFILE: Ensure SplashScreen routes them to pending screen
      // =======================================================================
      final userRef = _firestore.collection('users').doc(uid);
      final representativeMap = data['representative'] as Map? ?? {};
      final repName = representativeMap['fullName'] as String? ?? 'Administrator';

      transaction.set(userRef, {
        'role': 'college_admin',
        'tenant_id': officialDomain.replaceAll('.', '_'),
        'college_id': officialDomain.replaceAll('.', '_'),
        'university_id': 'pending_univ',
        'department': 'Administration',
        'verification_status': 'pending',
        'registration_id': requestId,
        'display_name': repName,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> logAuditAction(
      String requestId,
      String action,
      String fromStatus,
      String toStatus, [
        Map<String, dynamic>? metadata,
      ]) async {
    final uid = _auth.currentUser?.uid ?? 'system';
    final auditRef = _firestore
        .collection('college_registration_requests')
        .doc(requestId)
        .collection('audit_logs')
        .doc();

    await auditRef.set({
      'action': action,
      'from': fromStatus,
      'to': toStatus,
      'performedBy': uid,
      'metadata': metadata ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> checkDomainExists(String officialDomain, String currentRequestId) async {
    final cleanDomain = officialDomain.trim().toLowerCase();
    if (cleanDomain.isEmpty) return false;

    // Use a fast O(1) document lookup instead of a query for instant UI feedback
    final domainDoc = await _firestore.collection('registered_domains').doc(cleanDomain).get();
    if (domainDoc.exists) {
      final ownerRequestId = domainDoc.data()?['requestId'] as String?;
      // Return true (duplicate exists) if the found document is NOT the current user's active draft
      return ownerRequestId != currentRequestId;
    }
    return false;
  }
}