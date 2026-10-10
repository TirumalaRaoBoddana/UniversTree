import 'location_data_model.dart';
import 'document_metadata_model.dart';

class RepresentativeModel {
  final String fullName;
  final String designation;
  final String officialEmail;
  final String phoneNumber;

  const RepresentativeModel({
    required this.fullName,
    required this.designation,
    required this.officialEmail,
    required this.phoneNumber,
  });

  factory RepresentativeModel.fromMap(Map<String, dynamic> map) {
    return RepresentativeModel(
      fullName: map['full_name'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      officialEmail: map['official_email'] as String? ?? '',
      phoneNumber: map['phone_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'designation': designation,
      'official_email': officialEmail,
      'phone_number': phoneNumber,
    };
  }
}

class VerificationStateModel {
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;

  const VerificationStateModel({
    required this.emailVerified,
    required this.phoneVerified,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
  });

  factory VerificationStateModel.fromMap(Map<String, dynamic> map) {
    return VerificationStateModel(
      emailVerified: map['email_verified'] as bool? ?? false,
      phoneVerified: map['phone_verified'] as bool? ?? false,
      emailVerifiedAt: map['email_verified_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['email_verified_at'] as int)
          : null,
      phoneVerifiedAt: map['phone_verified_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['phone_verified_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'email_verified_at': emailVerifiedAt?.millisecondsSinceEpoch,
      'phone_verified_at': phoneVerifiedAt?.millisecondsSinceEpoch,
    };
  }
}

class InstitutionDetailModel {
  final String fullName;
  final String type;
  final String officialWebsite;
  final String officialEmailDomain;

  const InstitutionDetailModel({
    required this.fullName,
    required this.type,
    required this.officialWebsite,
    required this.officialEmailDomain,
  });

  factory InstitutionDetailModel.fromMap(Map<String, dynamic> map) {
    return InstitutionDetailModel(
      fullName: map['full_name'] as String? ?? '',
      type: map['type'] as String? ?? 'College',
      officialWebsite: map['official_website'] as String? ?? '',
      officialEmailDomain: map['official_email_domain'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'type': type,
      'official_website': officialWebsite,
      'official_email_domain': officialEmailDomain,
    };
  }
}

class ReviewChecklistModel {
  final bool repIdentityVerified;
  final bool emailVerified;
  final bool phoneVerified;
  final bool institutionVerified;
  final bool locationVerified;
  final bool documentsVerified;
  final bool finalCheckCompleted;

  const ReviewChecklistModel({
    this.repIdentityVerified = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.institutionVerified = false,
    this.locationVerified = false,
    this.documentsVerified = false,
    this.finalCheckCompleted = false,
  });

  bool get isReadyForApproval =>
      repIdentityVerified &&
          emailVerified &&
          phoneVerified &&
          institutionVerified &&
          locationVerified &&
          documentsVerified &&
          finalCheckCompleted;

  factory ReviewChecklistModel.fromMap(Map<String, dynamic> map) {
    return ReviewChecklistModel(
      repIdentityVerified: map['rep_identity_verified'] as bool? ?? false,
      emailVerified: map['email_verified'] as bool? ?? false,
      phoneVerified: map['phone_verified'] as bool? ?? false,
      institutionVerified: map['institution_verified'] as bool? ?? false,
      locationVerified: map['location_verified'] as bool? ?? false,
      documentsVerified: map['documents_verified'] as bool? ?? false,
      finalCheckCompleted: map['final_check_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rep_identity_verified': repIdentityVerified,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'institution_verified': institutionVerified,
      'location_verified': locationVerified,
      'documents_verified': documentsVerified,
      'final_check_completed': finalCheckCompleted,
    };
  }

  ReviewChecklistModel copyWith({
    bool? repIdentityVerified,
    bool? emailVerified,
    bool? phoneVerified,
    bool? institutionVerified,
    bool? locationVerified,
    bool? documentsVerified,
    bool? finalCheckCompleted,
  }) {
    return ReviewChecklistModel(
      repIdentityVerified: repIdentityVerified ?? this.repIdentityVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      institutionVerified: institutionVerified ?? this.institutionVerified,
      locationVerified: locationVerified ?? this.locationVerified,
      documentsVerified: documentsVerified ?? this.documentsVerified,
      finalCheckCompleted: finalCheckCompleted ?? this.finalCheckCompleted,
    );
  }
}

class ReviewDetailModel {
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionCategory;
  final String? rejectionReason;
  final String? requestedChanges;
  final String? adminNotes;
  final ReviewChecklistModel checklist;

  const ReviewDetailModel({
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionCategory,
    this.rejectionReason,
    this.requestedChanges,
    this.adminNotes,
    this.checklist = const ReviewChecklistModel(),
  });

  factory ReviewDetailModel.fromMap(Map<String, dynamic> map) {
    DateTime? getDateTime(dynamic val) {
      if (val == null) return null;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val.runtimeType.toString() == 'Timestamp') return (val as dynamic).toDate();
      return null;
    }

    return ReviewDetailModel(
      reviewedBy: map['reviewed_by'] as String?,
      reviewedAt: getDateTime(map['reviewed_at']),
      rejectionCategory: map['rejection_category'] as String?,
      rejectionReason: map['rejection_reason'] as String?,
      requestedChanges: map['requested_changes'] as String?,
      adminNotes: map['admin_notes'] as String?,
      checklist: map['checklist'] != null
          ? ReviewChecklistModel.fromMap(Map<String, dynamic>.from(map['checklist'] as Map))
          : const ReviewChecklistModel(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.millisecondsSinceEpoch,
      'rejection_category': rejectionCategory,
      'rejection_reason': rejectionReason,
      'requested_changes': requestedChanges,
      'admin_notes': adminNotes,
      'checklist': checklist.toMap(),
    };
  }
}

class CollegeApplicationModel {
  final String applicationId;
  final String applicantUid;
  final RepresentativeModel representative;
  final VerificationStateModel verification;
  final InstitutionDetailModel institution;
  final LocationDataModel location;
  final List<DocumentMetadataModel> documents;
  final String status;
  final ReviewDetailModel review;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollegeApplicationModel({
    required this.applicationId,
    required this.applicantUid,
    required this.representative,
    required this.verification,
    required this.institution,
    required this.location,
    this.documents = const [],
    required this.status,
    required this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollegeApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    final docsList = (map['documents'] as List? ?? [])
        .map((d) => DocumentMetadataModel.fromMap(Map<String, dynamic>.from(d as Map), d['id'] as String? ?? ''))
        .toList();
    return CollegeApplicationModel(
      applicationId: id,
      applicantUid: map['applicant_uid'] as String? ?? '',
      representative: RepresentativeModel.fromMap(Map<String, dynamic>.from(map['representative'] as Map? ?? {})),
      verification: VerificationStateModel.fromMap(Map<String, dynamic>.from(map['verification'] as Map? ?? {})),
      institution: InstitutionDetailModel.fromMap(Map<String, dynamic>.from(map['institution'] as Map? ?? {})),
      location: LocationDataModel.fromMap(Map<String, dynamic>.from(map['location'] as Map? ?? {})),
      documents: docsList,
      status: map['status'] as String? ?? 'PENDING',
      review: ReviewDetailModel.fromMap(Map<String, dynamic>.from(map['review'] as Map? ?? {})),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'application_id': applicationId,
      'applicant_uid': applicantUid,
      'representative': representative.toMap(),
      'verification': verification.toMap(),
      'institution': institution.toMap(),
      'location': location.toMap(),
      'documents': documents.map((d) => d.toMap()).toList(),
      'status': status,
      'review': review.toMap(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}