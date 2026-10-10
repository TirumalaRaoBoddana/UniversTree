class FacultyRequestModel {
  final String id;
  final String facultyUid;
  final String facultyName;
  final String facultyEmail;
  final String collegeId;
  final String collegeName;
  final String department;
  final String designation;
  final String? facultyIdNumber;
  final String status; // 'pending' | 'verified' | 'rejected'
  final String? rejectionReason;
  final DateTime submittedAt;

  const FacultyRequestModel({
    required this.id,
    required this.facultyUid,
    required this.facultyName,
    required this.facultyEmail,
    required this.collegeId,
    required this.collegeName,
    required this.department,
    required this.designation,
    this.facultyIdNumber,
    required this.status,
    this.rejectionReason,
    required this.submittedAt,
  });

  factory FacultyRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return FacultyRequestModel(
      id: id,
      facultyUid: map['faculty_uid'] as String? ?? '',
      facultyName: map['faculty_name'] as String? ?? '',
      facultyEmail: map['faculty_email'] as String? ?? '',
      collegeId: map['college_id'] as String? ?? '',
      collegeName: map['college_name'] as String? ?? '',
      department: map['department'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      facultyIdNumber: map['faculty_id_number'] as String?,
      status: map['status'] as String? ?? 'pending',
      rejectionReason: map['rejection_reason'] as String?,
      submittedAt: map['submitted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['submitted_at'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'faculty_uid': facultyUid,
      'faculty_name': facultyName,
      'faculty_email': facultyEmail,
      'college_id': collegeId,
      'college_name': collegeName,
      'department': department,
      'designation': designation,
      'faculty_id_number': facultyIdNumber,
      'status': status,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt.millisecondsSinceEpoch,
    };
  }

  FacultyRequestModel copyWith({
    String? status,
    String? rejectionReason,
  }) {
    return FacultyRequestModel(
      id: id,
      facultyUid: facultyUid,
      facultyName: facultyName,
      facultyEmail: facultyEmail,
      collegeId: collegeId,
      collegeName: collegeName,
      department: department,
      designation: designation,
      facultyIdNumber: facultyIdNumber,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt,
    );
  }
}
