class TenantContext {
  final String tenantId;
  final String collegeId;
  final String universityId;
  final String collegeName;
  final String collegeShortName;
  final String? department;
  final int? academicYear;

  const TenantContext({
    required this.tenantId,
    required this.collegeId,
    required this.universityId,
    required this.collegeName,
    required this.collegeShortName,
    this.department,
    this.academicYear,
  });

  factory TenantContext.empty() {
    return const TenantContext(
      tenantId: 'ceg_main',
      collegeId: 'ceg_main',
      universityId: 'anna_univ',
      collegeName: 'College of Engineering, Guindy',
      collegeShortName: 'CEG',
      department: 'CSE',
      academicYear: 3,
    );
  }

  TenantContext copyWith({
    String? tenantId,
    String? collegeId,
    String? universityId,
    String? collegeName,
    String? collegeShortName,
    String? department,
    int? academicYear,
  }) {
    return TenantContext(
      tenantId: tenantId ?? this.tenantId,
      collegeId: collegeId ?? this.collegeId,
      universityId: universityId ?? this.universityId,
      collegeName: collegeName ?? this.collegeName,
      collegeShortName: collegeShortName ?? this.collegeShortName,
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
    );
  }
}
