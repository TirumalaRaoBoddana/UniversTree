import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/registration_document.dart';

class DocumentUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const List<String> allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  // 🌟 FIX 1: Max file size reduced to 3 MB
  static const int maxFileSizeBytes = 3 * 1024 * 1024;

  void _validateFile(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    if (!allowedExtensions.contains(ext)) {
      throw Exception('Invalid file format ($ext). Only PDF, JPG, JPEG, and PNG files are allowed.');
    }
    if (file.size > maxFileSizeBytes) {
      throw Exception('File size exceeds the 3 MB limit. Please compress your document.');
    }
  }

  // 🌟 FIX 2: Safe extension parsing to prevent RangeError crashes
  String _sanitizeFileName(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) {
      // File has no extension
      return fileName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    }

    final namePart = fileName.substring(0, lastDotIndex);
    final extPart = fileName.substring(lastDotIndex);
    final safeName = namePart.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    return '$safeName$extPart';
  }

  Future<RegistrationDocument?> pickAndUploadDocument({
    required String requestId,
    required String documentType,
    required String uid,
    Function(double)? onProgress,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    _validateFile(file);

    final safeFileName = _sanitizeFileName(file.name);
    final documentId = 'DOC-${DateTime.now().millisecondsSinceEpoch}';

    // Enforced Secure Storage Path
    final storagePath = 'college_registration_requests/$requestId/documents/$documentId/$safeFileName';

    final ext = safeFileName.split('.').last.toLowerCase();
    final contentType = ext == 'pdf' ? 'application/pdf' : 'image/$ext';

    final ref = _storage.ref().child(storagePath);

    // SECURITY PATCH: Explicitly append customMetadata so Firebase Storage Rules can verify ownership
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {
        'uploadedBy': uid,
      },
    );

    UploadTask uploadTask;

    if (file.bytes != null) {
      uploadTask = ref.putData(file.bytes!, metadata);
    } else if (file.path != null) {
      uploadTask = ref.putFile(File(file.path!), metadata);
    } else {
      throw Exception('Could not read file data.');
    }

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        switch (event.state) {
          case TaskState.running:
            final progress = event.bytesTransferred / event.totalBytes;
            onProgress(progress);
            break;
          case TaskState.error:
            throw Exception('Storage upload failed due to network or permission issues.');
          default:
            break;
        }
      });
    }

    await uploadTask;

    return RegistrationDocument(
      documentId: documentId,
      type: documentType,
      originalFileName: safeFileName,
      storagePath: storagePath,
      contentType: contentType,
      sizeBytes: file.size,
      uploadedAt: DateTime.now(),
      uploadedBy: uid,
      status: 'uploaded',
    );
  }

  Future<void> deleteDocument(String storagePath) async {
    if (storagePath.isEmpty) return;
    try {
      await _storage.ref().child(storagePath).delete();
    } catch (e) {
      // Ignore exception if document was already deleted or doesn't exist
    }
  }
}