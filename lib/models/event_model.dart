class EventModel {
  final String id;
  final String tenantId;
  final String collegeId;
  final String organizerName;
  final String organizerType; // 'club' | 'department' | 'college'
  final String title;
  final String description;
  final String? bannerUrl;
  final String venue;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final String visibility; // 'private' | 'global'
  final int rsvpCount;
  final bool isRsvped;
  final String? registrationLink;

  const EventModel({
    required this.id,
    required this.tenantId,
    required this.collegeId,
    required this.organizerName,
    required this.organizerType,
    required this.title,
    required this.description,
    this.bannerUrl,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.visibility,
    this.rsvpCount = 0,
    this.isRsvped = false,
    this.registrationLink,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      tenantId: map['tenant_id'] as String? ?? '',
      collegeId: map['college_id'] as String? ?? '',
      organizerName: map['organizer_name'] as String? ?? 'Campus Organizers',
      organizerType: map['organizer_type'] as String? ?? 'club',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      bannerUrl: map['banner_url'] as String?,
      venue: map['venue'] as String? ?? 'Main Auditorium',
      startTime: map['start_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int)
          : DateTime.now(),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
          : DateTime.now().add(const Duration(hours: 2)),
      category: map['category'] as String? ?? 'Technical',
      visibility: map['visibility'] as String? ?? 'private',
      rsvpCount: (map['rsvp_count'] as num?)?.toInt() ?? 0,
      isRsvped: map['is_rsvped'] as bool? ?? false,
      registrationLink: map['registration_link'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenant_id': tenantId,
      'college_id': collegeId,
      'organizer_name': organizerName,
      'organizer_type': organizerType,
      'title': title,
      'description': description,
      'banner_url': bannerUrl,
      'venue': venue,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'category': category,
      'visibility': visibility,
      'rsvp_count': rsvpCount,
      'registration_link': registrationLink,
    };
  }

  EventModel copyWith({
    int? rsvpCount,
    bool? isRsvped,
  }) {
    return EventModel(
      id: id,
      tenantId: tenantId,
      collegeId: collegeId,
      organizerName: organizerName,
      organizerType: organizerType,
      title: title,
      description: description,
      bannerUrl: bannerUrl,
      venue: venue,
      startTime: startTime,
      endTime: endTime,
      category: category,
      visibility: visibility,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      isRsvped: isRsvped ?? this.isRsvped,
      registrationLink: registrationLink,
    );
  }
}
