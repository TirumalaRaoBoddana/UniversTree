class DocumentMetadataModel {
  final String id;
  final String documentType;
  final String fileName;
  final String contentType;
  final int sizeInBytes;
  final DateTime uploadedAt;
  final String base64Data; // Added for embedded storage

  const DocumentMetadataModel({
    required this.id,
    required this.documentType,
    required this.fileName,
    required this.contentType,
    required this.sizeInBytes,
    required this.uploadedAt,
    required this.base64Data,
  });

  factory DocumentMetadataModel.fromMap(Map<String, dynamic> map, String id) {
    return DocumentMetadataModel(
      id: id,
      documentType: map['document_type'] as String? ?? 'authorization_letter',
      fileName: map['file_name'] as String? ?? '',
      contentType: map['content_type'] as String? ?? 'application/pdf',
      sizeInBytes: (map['size_in_bytes'] as num?)?.toInt() ?? 0,
      uploadedAt: map['uploaded_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['uploaded_at'] as int)
          : DateTime.now(),
      base64Data: map['base64_data'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'document_type': documentType,
      'file_name': fileName,
      'content_type': contentType,
      'size_in_bytes': sizeInBytes,
      'uploaded_at': uploadedAt.millisecondsSinceEpoch,
      'base64_data': base64Data,
    };
  }
}