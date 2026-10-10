import 'package:flutter_test/flutter_test.dart';
import 'package:universtree/core/validators/email_domain_validator.dart';
import 'package:universtree/models/college_application_model.dart';
import 'package:universtree/models/location_data_model.dart';
import 'package:universtree/models/document_metadata_model.dart';

void main() {
  group('College Registration & Verification Tests', () {
    test('1. Personal email providers are strictly rejected', () {
      final gmailRes = EmailDomainValidator.validate('principal@gmail.com');
      expect(gmailRes.isValid, isFalse);
      expect(gmailRes.isPersonalProvider, isTrue);
      expect(gmailRes.errorMessage, contains('Personal email addresses'));

      final yahooRes = EmailDomainValidator.validate('dean@yahoo.com');
      expect(yahooRes.isValid, isFalse);

      final outlookRes = EmailDomainValidator.validate('admin@outlook.com');
      expect(outlookRes.isValid, isFalse);
    });

    test('2. Valid institutional email domains are accepted and extracted', () {
      final eduRes = EmailDomainValidator.validate('principal@ceg.annauniv.edu');
      expect(eduRes.isValid, isTrue);
      expect(eduRes.isPersonalProvider, isFalse);
      expect(eduRes.domain, equals('ceg.annauniv.edu'));

      final inRes = EmailDomainValidator.validate('dean@mitindia.edu.in');
      expect(inRes.isValid, isTrue);
      expect(inRes.domain, equals('mitindia.edu.in'));
    });

    test('3. CollegeApplicationModel serializes verification & location cleanly', () {
      final app = CollegeApplicationModel(
        applicationId: 'UT-2026-88492011',
        applicantUid: 'u_test_applicant',
        representative: const RepresentativeModel(
          fullName: 'Dr. S. Meenakshi',
          designation: 'Registrar',
          officialEmail: 'registrar@ceg.annauniv.edu',
          phoneNumber: '+91 98765 43210',
        ),
        verification: VerificationStateModel(
          emailVerified: true,
          phoneVerified: true,
          emailVerifiedAt: DateTime.now(),
          phoneVerifiedAt: DateTime.now(),
        ),
        institution: const InstitutionDetailModel(
          fullName: 'College of Engineering, Guindy',
          type: 'College',
          officialWebsite: 'https://ceg.annauniv.edu',
          officialEmailDomain: 'ceg.annauniv.edu',
        ),
        location: const LocationDataModel(
          formattedAddress: 'Sardar Patel Rd, Guindy, Chennai',
          addressLine1: 'Sardar Patel Rd',
          city: 'Chennai',
          district: 'Chennai',
          state: 'Tamil Nadu',
          country: 'India',
          postalCode: '600025',
          latitude: 13.0102,
          longitude: 80.2357,
          placeId: 'ChIJX99CEGtnUjoR2WqA5Vp9PVE',
        ),
        documents: [
          DocumentMetadataModel(
            id: 'doc_1',
            documentType: 'authorization_letter',
            fileName: 'Official_Authorization_Letter.pdf',
            base64Data: 'JVBERi0xLjQ...',
            contentType: 'application/pdf',
            sizeInBytes: 1024 * 500,
            uploadedAt: DateTime.now(),
          ),
        ],
        status: 'PENDING',
        review: const ReviewDetailModel(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = app.toMap();
      expect(map['application_id'], equals('UT-2026-88492011'));
      expect(map['status'], equals('PENDING'));
      expect(map['verification']['email_verified'], isTrue);
      expect(map['verification']['phone_verified'], isTrue);
      expect(map['documents'].length, equals(1));

      final restored = CollegeApplicationModel.fromMap(map, app.applicationId);
      expect(restored.institution.fullName, equals('College of Engineering, Guindy'));
      expect(restored.location.city, equals('Chennai'));
    });
  });
}
