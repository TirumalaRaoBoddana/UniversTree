class WebsiteValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String normalizedUrl;
  final bool hasHttpWarning;

  const WebsiteValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.normalizedUrl,
    this.hasHttpWarning = false,
  });
}

class WebsiteValidator {
  static final List<String> websiteTypes = [
    'Official College/University Website',
    'Student Management System (SMS)',
    'Learning Management System (LMS)',
    'Online Admission Portal',
    'Examination Portal',
    'Student Information Portal',
    'Library Management System',
    'Research and Innovation Portal',
    'Faculty and Staff Portal',
    'Placement and Career Portal',
    'Alumni Portal',
    'Other'
  ];

  static WebsiteValidationResult validate(String inputUrl, {String? expectedDomain}) {
    final raw = inputUrl.trim();
    if (raw.isEmpty) {
      return const WebsiteValidationResult(
        isValid: false,
        errorMessage: 'Enter a valid website address.',
        normalizedUrl: '',
      );
    }

    // Protocol normalization
    String processed = raw;
    bool hasHttpWarning = false;

    if (!processed.contains('://')) {
      processed = 'https://$processed';
    }

    final uri = Uri.tryParse(processed);
    if (uri == null || uri.host.isEmpty) {
      // Removed 'const' here because 'raw' is a runtime variable
      return WebsiteValidationResult(
        isValid: false,
        errorMessage: 'The website address is invalid. Check the domain and try again.',
        normalizedUrl: raw,
      );
    }

    // Protocol check
    if (uri.scheme == 'http') {
      hasHttpWarning = true;
    } else if (uri.scheme != 'https') {
      // Removed 'const' here because 'raw' is a runtime variable
      return WebsiteValidationResult(
        isValid: false,
        errorMessage: 'Unsupported URL scheme. Please use https:// URLs.',
        normalizedUrl: raw,
      );
    }

    final host = uri.host.toLowerCase();

    // Reject localhost and private-network IPs
    if (host == 'localhost' ||
        host.startsWith('127.') ||
        host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        host == '::1') {
      // Removed 'const' here because 'processed' is a runtime variable
      return WebsiteValidationResult(
        isValid: false,
        errorMessage: 'Localhost and private-network addresses are not permitted for official institutional websites.',
        normalizedUrl: processed,
      );
    }

    // Hostname structure check
    if (!host.contains('.') && host != 'internal') {
      // Removed 'const' here because 'processed' is a runtime variable
      return WebsiteValidationResult(
        isValid: false,
        errorMessage: 'Enter a valid hostname with a plausible domain structure.',
        normalizedUrl: processed,
      );
    }

    return WebsiteValidationResult(
      isValid: true,
      normalizedUrl: processed,
      hasHttpWarning: hasHttpWarning,
    );
  }
}