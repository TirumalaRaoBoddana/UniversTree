class InstitutionWebsite {
  final String id;
  final String type;
  final String? customType;
  final String url;
  final String? description;
  final bool isPrimary;
  final bool formatValid;
  final String domainConsistency;
  final String ownershipStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InstitutionWebsite({
    required this.id,
    required this.type,
    this.customType,
    required this.url,
    this.description,
    this.isPrimary = false,
    this.formatValid = true,
    this.domainConsistency = 'not_checked',
    this.ownershipStatus = 'unverified',
    this.createdAt,
    this.updatedAt,
  });

  factory InstitutionWebsite.fromMap(Map<String, dynamic> map) {
    return InstitutionWebsite(
      id: map['id'] as String? ?? 'web_${DateTime.now().millisecondsSinceEpoch}',
      type: map['type'] as String? ?? 'Official College/University Website',
      customType: map['customType'] as String?,
      url: map['url'] as String? ?? '',
      description: map['description'] as String?,
      isPrimary: map['isPrimary'] as bool? ?? false,
      formatValid: map['formatValid'] as bool? ?? true,
      domainConsistency: map['domainConsistency'] as String? ?? 'not_checked',
      ownershipStatus: map['ownershipStatus'] as String? ?? 'unverified',
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'customType': customType,
    'url': url,
    'description': description,
    'isPrimary': isPrimary,
    'formatValid': formatValid,
    'domainConsistency': domainConsistency,
    'ownershipStatus': ownershipStatus,
    'createdAt': createdAt?.millisecondsSinceEpoch,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
  };

  InstitutionWebsite copyWith({
    String? id,
    String? type,
    String? customType,
    String? url,
    String? description,
    bool? isPrimary,
    bool? formatValid,
    String? domainConsistency,
    String? ownershipStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InstitutionWebsite(
      id: id ?? this.id,
      type: type ?? this.type,
      customType: customType ?? this.customType,
      url: url ?? this.url,
      description: description ?? this.description,
      isPrimary: isPrimary ?? this.isPrimary,
      formatValid: formatValid ?? this.formatValid,
      domainConsistency: domainConsistency ?? this.domainConsistency,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}