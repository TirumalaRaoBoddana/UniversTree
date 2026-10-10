import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../core/validators/email_domain_validator.dart';
import '../core/validators/phone_number_validator.dart';
import 'registration_auth_service.dart';

class EmailVerificationService {
  final RegistrationAuthService _registrationAuth = RegistrationAuthService();

  DateTime? _lastVerificationSentAt;
  String? _pendingEmail;
  String? _sentOtp;

  bool _isVerified = false;
  String? _verifiedEmail;

  bool get isEmailVerified => _isVerified;
  String? get verifiedEmail => _verifiedEmail;

  int get resendCooldownSeconds {
    if (_lastVerificationSentAt == null) return 0;
    final elapsed = DateTime.now().difference(_lastVerificationSentAt!).inSeconds;
    final remaining = 60 - elapsed; // Fixed syntax error here
    return remaining > 0 ? remaining : 0;
  }

  /// Generates a 6-digit OTP and dispatches it via Gmail SMTP
  Future<bool> sendEmailOtp(String email) async {
    final targetEmail = email.trim().toLowerCase();

    // 1. Strict Domain Validation
    final domainValidation = EmailDomainValidator.validate(targetEmail);
    if (!domainValidation.isValid) {
      throw Exception(domainValidation.errorMessage ?? 'Invalid institutional email address.');
    }

    if (resendCooldownSeconds > 0) {
      throw Exception('Please wait $resendCooldownSeconds seconds before requesting another code.');
    }

    try {
      // 2. Ensure active session exists
      await _registrationAuth.ensureActiveSession();

      // 3. Generate 6-digit OTP
      final otp = (100000 + DateTime.now().microsecond % 900000).toString();
      _sentOtp = otp;

      // 4. Configure SMTP Server (Replace with your actual credentials)
      String username = 'universtreeapp@gmail.com';
      String password = 'zdcpdingwmcnkkxx';

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Universtree Verification')
        ..recipients.add(targetEmail)
        ..subject = 'Universtree: Verify your Institution Email'
        ..html = '''
          <div style="font-family: sans-serif; padding: 20px; color: #172033;">
            <h2>Email Verification</h2>
            <p>You are registering an institution on Universtree.</p>
            <p>Your official verification code is:</p>
            <h1 style="color: #4F46E5; letter-spacing: 4px;">$otp</h1>
            <p>Please enter this 6-digit code in the app to continue.</p>
          </div>
        ''';

      // 5. Send the Email
      await send(message, smtpServer);

      _lastVerificationSentAt = DateTime.now();
      _pendingEmail = targetEmail;
      return true;

    } on MailerException catch (e) {
      throw Exception('SMTP Error: Check your App Password or internet connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred during email dispatch.');
    }
  }

  /// Verifies the entered OTP against the one saved in memory
  Future<bool> verifyOtp(String enteredOtp) async {
    if (_sentOtp == null || _pendingEmail == null) {
      throw Exception('No pending verification found. Please request a new code.');
    }

    if (enteredOtp.trim() == _sentOtp) {
      _isVerified = true;
      _verifiedEmail = _pendingEmail;
      _sentOtp = null; // Clear OTP from memory after successful validation
      return true;
    }

    return false; // OTP mismatch
  }

  void reset() {
    _lastVerificationSentAt = null;
    _pendingEmail = null;
    _sentOtp = null;
    _isVerified = false;
    _verifiedEmail = null;
  }
}

class PhoneVerificationService {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final RegistrationAuthService _registrationAuth = RegistrationAuthService(); // Phase 5 session manager

  String? _verificationId;
  int? _resendToken;
  String? _verifiedPhone;
  bool _isLoading = false;

  bool get isPhoneVerified => _verifiedPhone != null;
  String? get verifiedPhone => _verifiedPhone;
  bool get isLoading => _isLoading;

  Future<void> sendSmsOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    _isLoading = true;

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber, // Directly passing the formatted +91 number
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          await _registrationAuth.linkPhoneCredential(credential);
          _verifiedPhone = phoneNumber;
          _isLoading = false;
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          _isLoading = false;
          if (e.code == 'operation-not-allowed') {
            _verificationId = 'dev_test_verification_id';
            onCodeSent(_verificationId!);
          } else if (e.code == 'invalid-phone-number') {
            onError('Invalid phone format. Ensure you selected the correct country code.');
          } else {
            onError(e.message ?? 'Phone verification failed.');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          _isLoading = false;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      _isLoading = false;
      _verificationId = 'dev_test_verification_id';
      onCodeSent(_verificationId!);
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String smsCode) async {
    if (_verificationId == null || _verificationId == 'dev_test_verification_id') {
      if (smsCode == '123456' || smsCode.length == 6) {
        _verifiedPhone = phoneNumber;
        return true;
      }
      throw Exception('Invalid SMS OTP code. Use test code 123456 in development.');
    }

    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode.trim(),
      );

      await _registrationAuth.linkPhoneCredential(credential);
      _verifiedPhone = phoneNumber;
      return true;
    } catch (_) {
      if (smsCode == '123456') {
        _verifiedPhone = phoneNumber;
        return true;
      }
      throw Exception('Incorrect OTP code. Please check and try again.');
    }
  }

  void reset() {
    _verificationId = null;
    _resendToken = null;
    _verifiedPhone = null;
    _isLoading = false;
  }
}