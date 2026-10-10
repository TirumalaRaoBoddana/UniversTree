class AuditLogModel {
  final String id;
  final String actorUid;
  final String actorName;
  final String actorRole;
  final String action; // e.g. 'COLLEGE_APPROVED', 'COLLEGE_REJECTED', 'FACULTY_VERIFIED'
  final String targetId;
  final String targetType;
  final String details;
  final DateTime timestamp;

  const AuditLogModel({
    required this.id,
    required this.actorUid,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.targetId,
    required this.targetType,
    required this.details,
    required this.timestamp,
  });

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String id) {
    return AuditLogModel(
      id: id,
      actorUid: map['actor_uid'] as String? ?? '',
      actorName: map['actor_name'] as String? ?? '',
      actorRole: map['actor_role'] as String? ?? '',
      action: map['action'] as String? ?? '',
      targetId: map['target_id'] as String? ?? '',
      targetType: map['target_type'] as String? ?? '',
      details: map['details'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'actor_uid': actorUid,
      'actor_name': actorName,
      'actor_role': actorRole,
      'action': action,
      'target_id': targetId,
      'target_type': targetType,
      'details': details,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
