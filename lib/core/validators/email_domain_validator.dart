class EmailDomainValidationResult {
  final bool isValid;
  final bool isPersonalProvider;
  final bool isInstitutional;
  final String domain;
  final String? errorMessage;

  const EmailDomainValidationResult({
    required this.isValid,
    required this.isPersonalProvider,
    required this.isInstitutional,
    required this.domain,
    this.errorMessage,
  });
}

class EmailDomainValidator {
  static const Set<String> blockedPersonalProviders = {
    'gmail.com',
    'yahoo.com',
    'ymail.com',
    'yahoo.co.in',
    'yahoo.co.uk',
    'hotmail.com',
    'outlook.com',
    'live.com',
    'msn.com',
    'icloud.com',
    'me.com',
    'mac.com',
    'proton.me',
    'protonmail.com',
    'mail.com',
    'gmx.com',
    'aol.com',
    'zoho.com',
    'rediffmail.com',
    'yandex.com',
    'inbox.com',
    'fastmail.com',
    'duck.com',
  };

  static const List<String> institutionalTLDs = [
    '.edu',
    '.ac.in',
    '.edu.in',
    '.res.in',
    '.school.in',
    '.ac.uk',
    '.edu.au',
    '.edu.sg',
    '.ac.jp',
    '.edu.cn',
    '.ac.za',
    '.edu.ng',
    '.edu.pk',
    '.edu.ph',
  ];

  static const List<String> institutionalKeywords = [
    'univ',
    'college',
    'inst',
    'academy',
    'campus',
    'polytechnic',
    'education',
    'school',
  ];

  static EmailDomainValidationResult validate(String email) {
    final normalized = email.trim().toLowerCase();

    if (normalized.isEmpty) {
      return const EmailDomainValidationResult(
        isValid: false,
        isPersonalProvider: false,
        isInstitutional: false,
        domain: '',
        errorMessage: 'Please enter official college/institute email address.',
      );
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(normalized)) {
      return const EmailDomainValidationResult(
        isValid: false,
        isPersonalProvider: false,
        isInstitutional: false,
        domain: '',
        errorMessage: 'Please enter a valid email address format (e.g. name@college.edu).',
      );
    }

    final parts = normalized.split('@');
    if (parts.length != 2) {
      return const EmailDomainValidationResult(
        isValid: false,
        isPersonalProvider: false,
        isInstitutional: false,
        domain: '',
        errorMessage: 'Invalid email format.',
      );
    }

    final domain = parts[1];

    if (blockedPersonalProviders.contains(domain)) {
      return EmailDomainValidationResult(
        isValid: false,
        isPersonalProvider: true,
        isInstitutional: false,
        domain: domain,
        errorMessage:
            'Please enter a valid official college/institute email address. Personal email addresses (@$domain) are strictly prohibited.',
      );
    }

    bool hasInstitutionalTLD = false;
    for (final tld in institutionalTLDs) {
      if (domain.endsWith(tld)) {
        hasInstitutionalTLD = true;
        break;
      }
    }

    bool hasInstitutionalKeyword = false;
    for (final kw in institutionalKeywords) {
      if (domain.contains(kw)) {
        hasInstitutionalKeyword = true;
        break;
      }
    }

    if (!hasInstitutionalTLD && !hasInstitutionalKeyword) {
      return EmailDomainValidationResult(
        isValid: false,
        isPersonalProvider: false,
        isInstitutional: false,
        domain: domain,
        errorMessage:
            'Please enter a valid official college/institute email address (ending in .edu, .ac.in, or institutional domain).',
      );
    }

    return EmailDomainValidationResult(
      isValid: true,
      isPersonalProvider: false,
      isInstitutional: true,
      domain: domain,
    );
  }
}
