class CountryCodeItem {
  final String code; // e.g. '+91'
  final String country; // e.g. 'India'
  final String flag; // e.g. '🇮🇳'
  final int expectedDigits;

  const CountryCodeItem({
    required this.code,
    required this.country,
    required this.flag,
    this.expectedDigits = 10,
  });

  String get displayName => '$flag $code ($country)';
}

class CountryCodes {
  static const List<CountryCodeItem> list = [
    CountryCodeItem(code: '+91', country: 'India', flag: '🇮🇳', expectedDigits: 10),
    CountryCodeItem(code: '+1', country: 'US / Canada', flag: '🇺🇸', expectedDigits: 10),
    CountryCodeItem(code: '+44', country: 'UK', flag: '🇬🇧', expectedDigits: 10),
    CountryCodeItem(code: '+61', country: 'Australia', flag: '🇦🇺', expectedDigits: 9),
    CountryCodeItem(code: '+971', country: 'UAE', flag: '🇦🇪', expectedDigits: 9),
    CountryCodeItem(code: '+65', country: 'Singapore', flag: '🇸🇬', expectedDigits: 8),
    CountryCodeItem(code: '+49', country: 'Germany', flag: '🇩🇪', expectedDigits: 10),
    CountryCodeItem(code: '+33', country: 'France', flag: '🇫🇷', expectedDigits: 9),
    CountryCodeItem(code: '+81', country: 'Japan', flag: '🇯🇵', expectedDigits: 10),
    CountryCodeItem(code: '+86', country: 'China', flag: '🇨🇳', expectedDigits: 11),
  ];

  static CountryCodeItem get defaultCode => list.first;
}

class PhoneValidationResult {
  final bool isValid;
  final String phoneNumber;
  final String? errorMessage;

  const PhoneValidationResult({
    required this.isValid,
    required this.phoneNumber,
    this.errorMessage,
  });
}

class PhoneNumberValidator {
  static PhoneValidationResult validateWithCountryCode(String countryCode, String localPhone) {
    final rawLocal = localPhone.trim();
    if (rawLocal.isEmpty) {
      return const PhoneValidationResult(
        isValid: false,
        phoneNumber: '',
        errorMessage: 'Please enter your office phone number.',
      );
    }

    final cleanedDigits = rawLocal.replaceAll(RegExp(r'[\s\-()]'), '');

    // Digit check: numeric digits only
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(cleanedDigits)) {
      return PhoneValidationResult(
        isValid: false,
        phoneNumber: '$countryCode $cleanedDigits',
        errorMessage: 'Please enter a valid phone number containing numeric digits only.',
      );
    }

    // Match against country code rules
    final countryItem = CountryCodes.list.firstWhere(
      (c) => c.code == countryCode,
      orElse: () => CountryCodes.defaultCode,
    );

    // Exact expected digits check according to country selection
    if (cleanedDigits.length != countryItem.expectedDigits) {
      return PhoneValidationResult(
        isValid: false,
        phoneNumber: '$countryCode $cleanedDigits',
        errorMessage:
            'Please enter a valid ${countryItem.expectedDigits}-digit office phone number for ${countryItem.country} ($countryCode).',
      );
    }

    // For India (+91), check mobile starting digit rules (6, 7, 8, 9)
    if (countryCode == '+91') {
      final indiaRegex = RegExp(r'^[6-9]\d{9}$');
      if (!indiaRegex.hasMatch(cleanedDigits)) {
        return PhoneValidationResult(
          isValid: false,
          phoneNumber: '$countryCode $cleanedDigits',
          errorMessage:
              'Please enter a valid 10-digit Indian office phone number starting with 6, 7, 8, or 9.',
        );
      }
    }

    return PhoneValidationResult(
      isValid: true,
      phoneNumber: '$countryCode $cleanedDigits',
    );
  }

  static PhoneValidationResult validate(String phone) {
    if (phone.contains('+')) {
      final parts = phone.split(' ');
      if (parts.length >= 2) {
        return validateWithCountryCode(parts[0], parts.sublist(1).join());
      }
    }
    return validateWithCountryCode('+91', phone);
  }
}
