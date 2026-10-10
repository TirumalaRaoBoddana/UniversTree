class RegistrationDocument {
  final String documentId;
  final String type;
  final String originalFileName;
  final String storagePath;
  final String contentType;
  final int sizeBytes;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String status;

  const RegistrationDocument({
    required this.documentId,
    required this.type,
    required this.originalFileName,
    required this.storagePath,
    required this.contentType,
    required this.sizeBytes,
    required this.uploadedAt,
    required this.uploadedBy,
    this.status = 'uploaded',
  });

  factory RegistrationDocument.fromMap(Map<String, dynamic> map, [String? id]) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value.runtimeType.toString() == 'Timestamp') return (value as dynamic).toDate();
      return DateTime.now();
    }

    return RegistrationDocument(
      documentId: id ?? map['documentId'] as String? ?? map['document_id'] as String? ?? map['id'] as String? ?? '',
      type: map['type'] as String? ?? map['document_type'] as String? ?? 'supporting_document',
      originalFileName: map['originalFileName'] as String? ?? map['original_file_name'] as String? ?? map['file_name'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? map['storage_path'] as String? ?? '',
      contentType: map['contentType'] as String? ?? map['content_type'] as String? ?? 'application/pdf',
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? (map['size_in_bytes'] as num?)?.toInt() ?? 0,
      uploadedAt: parseDateTime(map['uploadedAt'] ?? map['uploaded_at']),
      uploadedBy: map['uploadedBy'] as String? ?? map['uploaded_by'] as String? ?? '',
      status: map['status'] as String? ?? 'uploaded',
    );
  }

  Map<String, dynamic> toMap() => {
    'documentId': documentId,
    'type': type,
    'originalFileName': originalFileName,
    'storagePath': storagePath,
    'contentType': contentType,
    'sizeBytes': sizeBytes,
    'uploadedAt': uploadedAt.millisecondsSinceEpoch,
    'uploadedBy': uploadedBy,
    'status': status,
  };

  RegistrationDocument copyWith({
    String? documentId,
    String? type,
    String? originalFileName,
    String? storagePath,
    String? contentType,
    int? sizeBytes,
    DateTime? uploadedAt,
    String? uploadedBy,
    String? status,
  }) {
    return RegistrationDocument(
      documentId: documentId ?? this.documentId,
      type: type ?? this.type,
      originalFileName: originalFileName ?? this.originalFileName,
      storagePath: storagePath ?? this.storagePath,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      status: status ?? this.status,
    );
  }
}