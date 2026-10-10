class CollegeModel {
  final String id;
  final String universityId;
  final String name;
  final String shortName;
  final String domain;
  final String campusLocation;
  final String? logoUrl;
  final List<String> departments;

  const CollegeModel({
    required this.id,
    required this.universityId,
    required this.name,
    required this.shortName,
    required this.domain,
    required this.campusLocation,
    this.logoUrl,
    required this.departments,
  });

  factory CollegeModel.fromMap(Map<String, dynamic> map, String id) {
    return CollegeModel(
      id: id,
      universityId: map['university_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      shortName: map['short_name'] as String? ?? '',
      domain: map['domain'] as String? ?? '',
      campusLocation: map['campus_location'] as String? ?? '',
      logoUrl: map['logo_url'] as String?,
      departments: List<String>.from(map['departments'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'university_id': universityId,
      'name': name,
      'short_name': shortName,
      'domain': domain,
      'campus_location': campusLocation,
      'logo_url': logoUrl,
      'departments': departments,
    };
  }
}
