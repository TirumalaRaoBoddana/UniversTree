class DoubtModel {
  final String id;
  final String tenantId;
  final String collegeId;
  final String department;
  final String? subjectName;
  final String authorId;
  final String authorName;
  final String title;
  final String body;
  final List<String> tags;
  final int answerCount;
  final bool isResolved;
  final String visibility;
  final DateTime createdAt;

  const DoubtModel({
    required this.id,
    required this.tenantId,
    required this.collegeId,
    required this.department,
    this.subjectName,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.body,
    this.tags = const [],
    this.answerCount = 0,
    this.isResolved = false,
    required this.visibility,
    required this.createdAt,
  });

  factory DoubtModel.fromMap(Map<String, dynamic> map, String id) {
    return DoubtModel(
      id: id,
      tenantId: map['tenant_id'] as String? ?? '',
      collegeId: map['college_id'] as String? ?? '',
      department: map['department'] as String? ?? 'General',
      subjectName: map['subject_name'] as String?,
      authorId: map['author_id'] as String? ?? '',
      authorName: map['author_name'] as String? ?? 'Student',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List? ?? []),
      answerCount: (map['answer_count'] as num?)?.toInt() ?? 0,
      isResolved: map['is_resolved'] as bool? ?? false,
      visibility: map['visibility'] as String? ?? 'private',
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenant_id': tenantId,
      'college_id': collegeId,
      'department': department,
      'subject_name': subjectName,
      'author_id': authorId,
      'author_name': authorName,
      'title': title,
      'body': body,
      'tags': tags,
      'answer_count': answerCount,
      'is_resolved': isResolved,
      'visibility': visibility,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
