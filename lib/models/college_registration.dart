import 'registration_status.dart';
import 'representative.dart';
import 'institution_details.dart';
import 'institution_location.dart';
import 'registration_document.dart';
import 'verification_state.dart';
import 'review_state.dart';

class CollegeRegistration {
  final String requestId;
  final String applicantUid;
  final RegistrationStatus status;
  final int currentStep;
  final Representative representative;
  final InstitutionDetails institution;
  final InstitutionLocation location;
  final List<RegistrationDocument> documents;
  final VerificationState verification;
  final ReviewState review;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollegeRegistration({
    required this.requestId,
    required this.applicantUid,
    required this.status,
    required this.currentStep,
    required this.representative,
    required this.institution,
    required this.location,
    this.documents = const [],
    required this.verification,
    required this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollegeRegistration.newDraft({
    required String requestId,
    required String applicantUid,
  }) {
    final now = DateTime.now();
    return CollegeRegistration(
      requestId: requestId,
      applicantUid: applicantUid,
      status: RegistrationStatus.draft,
      currentStep: 1,
      representative: Representative.empty(),
      institution: InstitutionDetails.empty(),
      location: InstitutionLocation.empty(),
      documents: const [],
      verification: const VerificationState(),
      review: const ReviewState(),
      createdAt: now,
      updatedAt: now,
    );
  }

  factory CollegeRegistration.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value.runtimeType.toString() == 'Timestamp') return (value as dynamic).toDate();
      return DateTime.now();
    }

    final docsList = (map['documents'] as List? ?? [])
        .map((d) => RegistrationDocument.fromMap(Map<String, dynamic>.from(d as Map)))
        .toList();

    return CollegeRegistration(
      requestId: docId ?? map['requestId'] as String? ?? map['application_id'] as String? ?? '',
      applicantUid: map['applicantUid'] as String? ?? map['applicant_uid'] as String? ?? '',
      status: RegistrationStatus.fromString(map['status'] as String?),
      currentStep: (map['currentStep'] as num?)?.toInt() ?? (map['current_step'] as num?)?.toInt() ?? 1,
      representative: Representative.fromMap(
        map['representative'] != null ? Map<String, dynamic>.from(map['representative'] as Map) : null,
      ),
      institution: InstitutionDetails.fromMap(
        map['institution'] != null ? Map<String, dynamic>.from(map['institution'] as Map) : null,
      ),
      location: InstitutionLocation.fromMap(
        map['location'] != null ? Map<String, dynamic>.from(map['location'] as Map) : null,
      ),
      documents: docsList,
      verification: VerificationState.fromMap(
        map['verification'] != null ? Map<String, dynamic>.from(map['verification'] as Map) : null,
      ),
      review: ReviewState.fromMap(
        map['review'] != null ? Map<String, dynamic>.from(map['review'] as Map) : null,
      ),
      createdAt: parseDateTime(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDateTime(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'requestId': requestId,
    'applicantUid': applicantUid,
    'status': status.value,
    'currentStep': currentStep,
    'representative': representative.toMap(),
    'institution': institution.toMap(),
    'location': location.toMap(),
    'documents': documents.map((d) => d.toMap()).toList(),
    'verification': verification.toMap(),
    'review': review.toMap(),
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  CollegeRegistration copyWith({
    String? requestId,
    String? applicantUid,
    RegistrationStatus? status,
    int? currentStep,
    Representative? representative,
    InstitutionDetails? institution,
    InstitutionLocation? location,
    List<RegistrationDocument>? documents,
    VerificationState? verification,
    ReviewState? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollegeRegistration(
      requestId: requestId ?? this.requestId,
      applicantUid: applicantUid ?? this.applicantUid,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      representative: representative ?? this.representative,
      institution: institution ?? this.institution,
      location: location ?? this.location,
      documents: documents ?? this.documents,
      verification: verification ?? this.verification,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}