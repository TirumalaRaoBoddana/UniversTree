import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/smtp_server.dart';

class SmtpConfig {
  static String get host {
    final envVal = dotenv.env['SMTP_HOST']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('SMTP_HOST', defaultValue: 'smtp.gmail.com');
  }

  static int get port {
    final envVal = dotenv.env['SMTP_PORT']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) {
      return int.tryParse(envVal) ?? 587;
    }
    return const int.fromEnvironment('SMTP_PORT', defaultValue: 587);
  }

  static String get username {
    final envVal = dotenv.env['SMTP_USERNAME']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('SMTP_USERNAME', defaultValue: 'universtreeapp@gmail.com');
  }

  static String get password {
    final envVal = dotenv.env['SMTP_PASSWORD']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('SMTP_PASSWORD', defaultValue: 'zdcpdingwmcnkkxx');
  }

  static String get fromEmail {
    final envVal = dotenv.env['SMTP_FROM_EMAIL']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('SMTP_FROM_EMAIL', defaultValue: 'universtreeapp@gmail.com');
  }

  static String get fromName {
    final envVal = dotenv.env['SMTP_FROM_NAME']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('SMTP_FROM_NAME', defaultValue: 'Universtree Accreditation');
  }

  static SmtpServer getSmtpServer({
    String? host,
    int? port,
    String? username,
    String? password,
  }) {
    final effectiveHost = (host != null && host.isNotEmpty) ? host : SmtpConfig.host;
    final effectivePort = (port != null && port > 0) ? port : SmtpConfig.port;
    final effectiveUser = (username != null && username.isNotEmpty) ? username : SmtpConfig.username;
    final effectivePass = (password != null && password.isNotEmpty) ? password : SmtpConfig.password;

    if (effectiveHost.contains('gmail.com')) {
      return gmail(effectiveUser, effectivePass);
    }

    return SmtpServer(
      effectiveHost,
      port: effectivePort,
      ssl: effectivePort == 465,
      username: effectiveUser,
      password: effectivePass,
    );
  }
}
