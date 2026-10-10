import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import '../core/config/smtp_config.dart';
import '../core/validators/email_domain_validator.dart';

enum EmailDeliverabilityStatus {
  deliverable,
  rejected,
  temporaryFailure,
  unknown,
}

class EmailDeliverabilityResult {
  final EmailDeliverabilityStatus status;
  final String message;

  const EmailDeliverabilityResult({
    required this.status,
    required this.message,
  });

  bool get isDeliverable =>
      status == EmailDeliverabilityStatus.deliverable ||
      status == EmailDeliverabilityStatus.unknown;

  bool get isRejected => status == EmailDeliverabilityStatus.rejected;
}

class SmtpService {
  /// Synchronously checks domain MX records, disposable providers, and mailbox existence before OTP dispatch.
  static Future<EmailDeliverabilityResult> checkDeliverability(String recipientEmail) async {
    final email = recipientEmail.trim().toLowerCase();

    // 1. Strict Syntax & Personal Provider Check
    final domainValidation = EmailDomainValidator.validate(email);
    if (!domainValidation.isValid) {
      return EmailDeliverabilityResult(
        status: EmailDeliverabilityStatus.rejected,
        message: domainValidation.errorMessage ??
            'Please enter a valid official college/institute email address.',
      );
    }

    final domain = domainValidation.domain;
    String primaryMxHost = '';

    // 2. DNS MX Record Lookup Check via Google Public DNS REST API
    try {
      final dnsUrl = Uri.parse('https://dns.google/resolve?name=${Uri.encodeComponent(domain)}&type=MX');
      final dnsResponse = await http.get(dnsUrl).timeout(const Duration(seconds: 5));

      if (dnsResponse.statusCode == 200) {
        final dnsData = jsonDecode(dnsResponse.body) as Map<String, dynamic>;
        final status = dnsData['Status'] as int? ?? -1;
        final answer = dnsData['Answer'] as List? ?? [];

        if (status != 0 || answer.isEmpty) {
          return EmailDeliverabilityResult(
            status: EmailDeliverabilityStatus.rejected,
            message:
                'The domain "@$domain" has no active mail servers (MX records). Emails cannot be delivered to this address.',
          );
        }

        // Extract primary MX host
        final firstRecord = answer.first as Map? ?? {};
        final rawData = firstRecord['data'] as String? ?? '';
        final parts = rawData.trim().split(RegExp(r'\s+'));
        primaryMxHost = (parts.length >= 2 ? parts.last : rawData).replaceAll(RegExp(r'\.$'), '');
      }
    } catch (_) {
      // Failover to REST probe
    }

    // 3. Real-Time Mailbox Deliverability Check via Open Kickbox Verification API
    try {
      final kickboxUrl = Uri.parse('https://open.kickbox.com/v1/verify?email=${Uri.encodeComponent(email)}');
      final kickboxResponse = await http.get(kickboxUrl).timeout(const Duration(seconds: 5));

      if (kickboxResponse.statusCode == 200) {
        final kickboxData = jsonDecode(kickboxResponse.body) as Map<String, dynamic>;
        final result = kickboxData['result'] as String? ?? '';
        final reason = kickboxData['reason'] as String? ?? '';
        final isDisposable = kickboxData['disposable'] as bool? ?? false;

        if (isDisposable) {
          return EmailDeliverabilityResult(
            status: EmailDeliverabilityStatus.rejected,
            message: 'Disposable or temporary email addresses cannot be used for official college registration.',
          );
        }

        if (result.toLowerCase() == 'undeliverable' || reason.toLowerCase() == 'rejected_email') {
          return EmailDeliverabilityResult(
            status: EmailDeliverabilityStatus.rejected,
            message:
                'The mailbox "$email" does not exist on the institution mail server. Please check for typos in Step 1.',
          );
        }
      }
    } catch (_) {}

    // 4. Secondary Real-Time Mailbox Existence REST Probe (PingUtil API)
    try {
      final evaUrl = Uri.parse('https://api.eva.pingutil.com/email?address=${Uri.encodeComponent(email)}');
      final evaResponse = await http.get(evaUrl).timeout(const Duration(seconds: 5));

      if (evaResponse.statusCode == 200) {
        final evaData = jsonDecode(evaResponse.body) as Map<String, dynamic>;
        final data = evaData['data'] as Map? ?? {};
        final isDeliverable = data['deliverable'] as bool? ?? true;
        final isDisposable = data['disposable'] as bool? ?? false;

        if (isDisposable) {
          return EmailDeliverabilityResult(
            status: EmailDeliverabilityStatus.rejected,
            message: 'Disposable or temporary email addresses cannot be used for official college registration.',
          );
        }

        if (!isDeliverable) {
          return EmailDeliverabilityResult(
            status: EmailDeliverabilityStatus.rejected,
            message:
                'The mailbox "$email" does not exist or cannot accept emails. Please check for typos in Step 1.',
          );
        }
      }
    } catch (_) {}

    // 5. Socket Direct SMTP Handshake Probe (RCPT TO) for Native Platforms
    if (primaryMxHost.isNotEmpty) {
      try {
        final socketProbe = await _probeSmtpRcptTo(primaryMxHost, email);
        if (socketProbe != null && socketProbe.isRejected) {
          return socketProbe;
        }
      } catch (_) {}
    }

    return const EmailDeliverabilityResult(
      status: EmailDeliverabilityStatus.deliverable,
      message: 'Recipient domain and mail server accepted.',
    );
  }

  /// Performs a direct SMTP TCP socket handshake (EHLO -> MAIL FROM -> RCPT TO) against the MX server.
  static Future<EmailDeliverabilityResult?> _probeSmtpRcptTo(String mxHost, String recipientEmail) async {
    Socket? socket;
    try {
      socket = await Socket.connect(mxHost, 25, timeout: const Duration(seconds: 4));
      
      final completer = Completer<String>();
      socket.listen((List<int> data) {
        final response = String.fromCharCodes(data);
        if (!completer.isCompleted) completer.complete(response);
      });

      // 1. Read Banner (220)
      final banner = await completer.future.timeout(const Duration(seconds: 3));
      if (!banner.startsWith('220')) {
        await socket.close();
        return null;
      }

      // 2. Send EHLO
      socket.write('EHLO universtree.app\r\n');
      await Future.delayed(const Duration(milliseconds: 300));

      // 3. Send MAIL FROM
      socket.write('MAIL FROM:<noreply@universtree.app>\r\n');
      await Future.delayed(const Duration(milliseconds: 300));

      // 4. Send RCPT TO
      final rcptCompleter = Completer<String>();
      socket.listen((List<int> data) {
        final response = String.fromCharCodes(data);
        if (!rcptCompleter.isCompleted) rcptCompleter.complete(response);
      });

      socket.write('RCPT TO:<$recipientEmail>\r\n');
      final rcptResponse = await rcptCompleter.future.timeout(const Duration(seconds: 3));

      await socket.close();

      // Check for SMTP 550/551/552/553 (User unknown / Mailbox does not exist)
      if (rcptResponse.startsWith('550') ||
          rcptResponse.startsWith('551') ||
          rcptResponse.startsWith('552') ||
          rcptResponse.startsWith('553') ||
          rcptResponse.contains('5.1.1') ||
          rcptResponse.toLowerCase().contains('user unknown') ||
          rcptResponse.toLowerCase().contains('no such user')) {
        return EmailDeliverabilityResult(
          status: EmailDeliverabilityStatus.rejected,
          message:
              'The mailbox "$recipientEmail" does not exist on the institution mail server. Please check for typos and enter your correct email in Step 1.',
        );
      }
    } catch (_) {
      try {
        await socket?.close();
      } catch (_) {}
    }
    return null;
  }

  /// Sends an official HTML OTP verification email over TLS/SSL SMTP connection.
  static Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String recipientName,
    required String otpCode,
    String? customHost,
    int? customPort,
    String? customUsername,
    String? customPassword,
  }) async {
    final deliverability = await checkDeliverability(recipientEmail);
    if (deliverability.isRejected) {
      return false;
    }

    final smtpServer = SmtpConfig.getSmtpServer(
      host: customHost ?? SmtpConfig.host,
      port: customPort ?? SmtpConfig.port,
      username: customUsername ?? SmtpConfig.username,
      password: customPassword ?? SmtpConfig.password,
    );

    final htmlBody = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Universtree Verification</title>
</head>
<body style="font-family: Arial, Helvetica, sans-serif; background-color: #f4f6f9; margin: 0; padding: 24px;">
  <div style="max-width: 560px; margin: 0 auto; background-color: #ffffff; padding: 32px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
    <h2 style="color: #0f172a; margin-top: 0; font-size: 22px; font-weight: bold;">Universtree</h2>
    <p style="color: #64748b; font-size: 13px; margin-top: -8px;">Where Campus Comes Together.</p>
    <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 20px 0;" />
    
    <p style="font-size: 15px; color: #334155;">Dear <strong>$recipientName</strong>,</p>
    <p style="font-size: 14px; color: #334155; line-height: 1.5;">
      Your official 6-digit verification code for institution registration on Universtree is:
    </p>
    
    <div style="background-color: #f1f5f9; padding: 18px; border-radius: 8px; text-align: center; margin: 24px 0;">
      <span style="font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #2563eb;">$otpCode</span>
    </div>
    
    <p style="font-size: 13px; color: #64748b; line-height: 1.5;">
      This code expires in <strong>10 minutes</strong>. For security reasons, please do not share this code with anyone.
    </p>
    
    <hr style="border: 0; border-top: 1px solid #f1f5f9; margin: 24px 0;" />
    
    <p style="font-size: 12px; color: #94a3b8; margin: 0;">
      If you did not initiate this institution registration request, you can safely ignore this email.
    </p>
  </div>
</body>
</html>
''';

    final message = Message()
      ..from = Address(SmtpConfig.fromEmail, SmtpConfig.fromName)
      ..recipients.add(recipientEmail)
      ..subject = '[UNIVERSTREE] Official Institution Registration Verification Code'
      ..html = htmlBody;

    try {
      final sendReport = await send(message, smtpServer);
      return sendReport.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
