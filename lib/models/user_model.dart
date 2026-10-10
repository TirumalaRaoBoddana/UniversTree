class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role; // 'student' | 'faculty' | 'college_admin' | 'super_admin'
  final String tenantId;
  final String collegeId;
  final String universityId;
  final String department;
  final int academicYear;
  final String branch;
  final String verificationStatus; // 'verified' | 'pending' | 'rejected' | 'suspended'
  final bool profileCompleted;
  final DateTime joinedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.tenantId,
    required this.collegeId,
    required this.universityId,
    required this.department,
    required this.academicYear,
    required this.branch,
    required this.verificationStatus,
    this.profileCompleted = true,
    required this.joinedAt,
  });

  bool get isStudent => role == 'student';
  bool get isFaculty => role == 'faculty';
  bool get isCollegeAdmin => role == 'college_admin';
  bool get isSuperAdmin => role == 'super_admin';

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';
  bool get isSuspended => verificationStatus == 'suspended';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] as String? ?? '',
      displayName: map['display_name'] as String? ?? 'User',
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'student',
      tenantId: map['tenant_id'] as String? ?? '',
      collegeId: map['college_id'] as String? ?? '',
      universityId: map['university_id'] as String? ?? '',
      department: map['department'] as String? ?? 'General',
      academicYear: (map['academic_year'] as num?)?.toInt() ?? 1,
      branch: map['branch'] as String? ?? '',
      verificationStatus: map['verification_status'] as String? ?? 'verified',
      profileCompleted: map['profile_completed'] as bool? ?? true,
      joinedAt: map['joined_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['joined_at'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'role': role,
      'tenant_id': tenantId,
      'college_id': collegeId,
      'university_id': universityId,
      'department': department,
      'academic_year': academicYear,
      'branch': branch,
      'verification_status': verificationStatus,
      'profile_completed': profileCompleted,
      'joined_at': joinedAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? role,
    String? verificationStatus,
    bool? profileCompleted,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl,
      role: role ?? this.role,
      tenantId: tenantId,
      collegeId: collegeId,
      universityId: universityId,
      department: department,
      academicYear: academicYear,
      branch: branch,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      joinedAt: joinedAt,
    );
  }
}
