import 'college_application_model.dart' show ReviewChecklistModel;

class ReviewState {
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerUid;
  final String? reviewerNotes;
  final String? rejectionCategory;
  final String? rejectionReason;
  final String? requestedChanges;
  final ReviewChecklistModel checklist;

  const ReviewState({
    this.submittedAt,
    this.reviewedAt,
    this.reviewerUid,
    this.reviewerNotes,
    this.rejectionCategory,
    this.rejectionReason,
    this.requestedChanges,
    this.checklist = const ReviewChecklistModel(),
  });

  factory ReviewState.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ReviewState();
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      if (value.runtimeType.toString() == 'Timestamp') return (value as dynamic).toDate();
      return null;
    }

    return ReviewState(
      submittedAt: parseDateTime(map['submittedAt'] ?? map['submitted_at']),
      reviewedAt: parseDateTime(map['reviewedAt'] ?? map['reviewed_at']),
      reviewerUid: map['reviewerUid'] as String? ?? map['reviewed_by'] as String?,
      reviewerNotes: map['reviewerNotes'] as String? ?? map['admin_notes'] as String?,
      rejectionCategory: map['rejectionCategory'] as String? ?? map['rejection_category'] as String?,
      rejectionReason: map['rejectionReason'] as String? ?? map['rejection_reason'] as String?,
      requestedChanges: map['requestedChanges'] as String? ?? map['requested_changes'] as String?,
      checklist: map['checklist'] != null
          ? ReviewChecklistModel.fromMap(Map<String, dynamic>.from(map['checklist'] as Map))
          : const ReviewChecklistModel(),
    );
  }

  Map<String, dynamic> toMap() => {
    'submittedAt': submittedAt?.millisecondsSinceEpoch,
    'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
    'reviewerUid': reviewerUid,
    'reviewerNotes': reviewerNotes,
    'rejectionCategory': rejectionCategory,
    'rejectionReason': rejectionReason,
    'requestedChanges': requestedChanges,
    'checklist': checklist.toMap(),
  };

  ReviewState copyWith({
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewerUid,
    String? reviewerNotes,
    String? rejectionCategory,
    String? rejectionReason,
    String? requestedChanges,
    ReviewChecklistModel? checklist,
  }) {
    return ReviewState(
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerUid: reviewerUid ?? this.reviewerUid,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      rejectionCategory: rejectionCategory ?? this.rejectionCategory,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      requestedChanges: requestedChanges ?? this.requestedChanges,
      checklist: checklist ?? this.checklist,
    );
  }
}