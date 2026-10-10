import '../core/constants/app_constants.dart';

class PlatformAdminPermissions {
  final bool viewRegistrations;
  final bool reviewRegistrations;
  final bool approveRegistrations;
  final bool rejectRegistrations;
  final bool viewDocuments;
  final bool viewAuditLogs;

  const PlatformAdminPermissions({
    this.viewRegistrations = true,
    this.reviewRegistrations = true,
    this.approveRegistrations = true,
    this.rejectRegistrations = true,
    this.viewDocuments = true,
    this.viewAuditLogs = true,
  });

  factory PlatformAdminPermissions.fromMap(Map<String, dynamic> map) {
    return PlatformAdminPermissions(
      viewRegistrations: map['viewRegistrations'] as bool? ?? true,
      reviewRegistrations: map['reviewRegistrations'] as bool? ?? true,
      approveRegistrations: map['approveRegistrations'] as bool? ?? true,
      rejectRegistrations: map['rejectRegistrations'] as bool? ?? true,
      viewDocuments: map['viewDocuments'] as bool? ?? true,
      viewAuditLogs: map['viewAuditLogs'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'viewRegistrations': viewRegistrations,
      'reviewRegistrations': reviewRegistrations,
      'approveRegistrations': approveRegistrations,
      'rejectRegistrations': rejectRegistrations,
      'viewDocuments': viewDocuments,
      'viewAuditLogs': viewAuditLogs,
    };
  }
}

class PlatformAdminModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final String adminLevel;
  final bool isActive;
  final PlatformAdminPermissions permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlatformAdminModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.adminLevel,
    required this.isActive,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlatformAdminModel.fromMap(Map<String, dynamic> map, String uid) {
    return PlatformAdminModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Universtree Platform Administrator',
      role: map['role'] as String? ?? 'platform_admin',
      adminLevel: map['adminLevel'] as String? ?? 'super_admin',
      isActive: map['isActive'] as bool? ?? true,
      permissions: map['permissions'] != null
          ? PlatformAdminPermissions.fromMap(Map<String, dynamic>.from(map['permissions']))
          : const PlatformAdminPermissions(),
      // Safely parses the 13-digit Number epoch timestamp back into a Dart DateTime
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as num).toInt())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as num).toInt())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'adminLevel': adminLevel,
      'isActive': isActive,
      'permissions': permissions.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}