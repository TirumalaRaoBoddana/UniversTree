class CollegeRequestModel {
  final String id;
  final String institutionName;
  final String shortName;
  final String officialEmail;
  final String officialDomain;
  final String officialWebsite;
  final String campusLocation;
  final String administratorUid;
  final String administratorName;
  final List<String> submittedDocuments;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const CollegeRequestModel({
    required this.id,
    required this.institutionName,
    required this.shortName,
    required this.officialEmail,
    required this.officialDomain,
    required this.officialWebsite,
    required this.campusLocation,
    required this.administratorUid,
    required this.administratorName,
    this.submittedDocuments = const [],
    required this.status,
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory CollegeRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return CollegeRequestModel(
      id: id,
      institutionName: map['institution_name'] as String? ?? '',
      shortName: map['short_name'] as String? ?? '',
      officialEmail: map['official_email'] as String? ?? '',
      officialDomain: map['official_domain'] as String? ?? '',
      officialWebsite: map['official_website'] as String? ?? '',
      campusLocation: map['campus_location'] as String? ?? '',
      administratorUid: map['administrator_uid'] as String? ?? '',
      administratorName: map['administrator_name'] as String? ?? '',
      submittedDocuments: List<String>.from(map['submitted_documents'] as List? ?? []),
      status: map['status'] as String? ?? 'pending',
      rejectionReason: map['rejection_reason'] as String?,
      submittedAt: map['submitted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['submitted_at'] as int)
          : DateTime.now(),
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reviewed_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institution_name': institutionName,
      'short_name': shortName,
      'official_email': officialEmail,
      'official_domain': officialDomain,
      'official_website': officialWebsite,
      'campus_location': campusLocation,
      'administrator_uid': administratorUid,
      'administrator_name': administratorName,
      'submitted_documents': submittedDocuments,
      'status': status,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt.millisecondsSinceEpoch,
      'reviewed_at': reviewedAt?.millisecondsSinceEpoch,
    };
  }

  CollegeRequestModel copyWith({
    String? status,
    String? rejectionReason,
    DateTime? reviewedAt,
  }) {
    return CollegeRequestModel(
      id: id,
      institutionName: institutionName,
      shortName: shortName,
      officialEmail: officialEmail,
      officialDomain: officialDomain,
      officialWebsite: officialWebsite,
      campusLocation: campusLocation,
      administratorUid: administratorUid,
      administratorName: administratorName,
      submittedDocuments: submittedDocuments,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
