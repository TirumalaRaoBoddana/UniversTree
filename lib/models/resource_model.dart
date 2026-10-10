class ResourceModel {
  final String id;
  final String tenantId;
  final String collegeId;
  final String department;
  final int semester;
  final String subjectCode;
  final String subjectName;
  final String title;
  final String fileUrl;
  final String fileType; // 'pdf' | 'doc' | 'link'
  final String type; // 'pyq' | 'notes' | 'syllabus' | 'lab_manual' | 'reference'
  final String uploaderName;
  final int upvotes;
  final int downloadsCount;
  final String visibility; // 'private' | 'global'
  final DateTime createdAt;

  const ResourceModel({
    required this.id,
    required this.tenantId,
    required this.collegeId,
    required this.department,
    required this.semester,
    required this.subjectCode,
    required this.subjectName,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.type,
    required this.uploaderName,
    this.upvotes = 0,
    this.downloadsCount = 0,
    required this.visibility,
    required this.createdAt,
  });

  factory ResourceModel.fromMap(Map<String, dynamic> map, String id) {
    return ResourceModel(
      id: id,
      tenantId: map['tenant_id'] as String? ?? '',
      collegeId: map['college_id'] as String? ?? '',
      department: map['department'] as String? ?? 'General',
      semester: (map['semester'] as num?)?.toInt() ?? 1,
      subjectCode: map['subject_code'] as String? ?? '',
      subjectName: map['subject_name'] as String? ?? '',
      title: map['title'] as String? ?? '',
      fileUrl: map['file_url'] as String? ?? '',
      fileType: map['file_type'] as String? ?? 'pdf',
      type: map['type'] as String? ?? 'notes',
      uploaderName: map['uploader_name'] as String? ?? 'Faculty',
      upvotes: (map['upvotes'] as num?)?.toInt() ?? 0,
      downloadsCount: (map['downloads_count'] as num?)?.toInt() ?? 0,
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
      'semester': semester,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'title': title,
      'file_url': fileUrl,
      'file_type': fileType,
      'type': type,
      'uploader_name': uploaderName,
      'upvotes': upvotes,
      'downloads_count': downloadsCount,
      'visibility': visibility,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
