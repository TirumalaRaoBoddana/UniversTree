class AdminAuditLogModel {
  final String id;
  final String adminUid;
  final String adminEmail;
  final String action;
  final String targetRegistrationId;
  final String previousStatus;
  final String newStatus;
  final String? reason;
  final DateTime timestamp;

  const AdminAuditLogModel({
    required this.id,
    required this.adminUid,
    required this.adminEmail,
    required this.action,
    required this.targetRegistrationId,
    required this.previousStatus,
    required this.newStatus,
    this.reason,
    required this.timestamp,
  });

  factory AdminAuditLogModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminAuditLogModel(
      id: id,
      adminUid: map['adminUid'] as String? ?? '',
      adminEmail: map['adminEmail'] as String? ?? '',
      action: map['action'] as String? ?? '',
      targetRegistrationId: map['targetRegistrationId'] as String? ?? '',
      previousStatus: map['previousStatus'] as String? ?? '',
      newStatus: map['newStatus'] as String? ?? '',
      reason: map['reason'] as String?,
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
              : DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminUid': adminUid,
      'adminEmail': adminEmail,
      'action': action,
      'targetRegistrationId': targetRegistrationId,
      'previousStatus': previousStatus,
      'newStatus': newStatus,
      'reason': reason,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
