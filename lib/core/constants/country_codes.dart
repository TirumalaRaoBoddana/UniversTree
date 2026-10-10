class CountryCode {
  final String code;
  final String flag;
  final String name;

  const CountryCode(this.code, this.flag, this.name);
}

class CountryCodes {
  // A curated list of common country dial codes.
  // You can easily add more countries here as needed!
  static const List<CountryCode> list = [
    CountryCode('+91', '🇮🇳', 'India'),
    CountryCode('+1', '🇺🇸', 'United States'),
    CountryCode('+1', '🇨🇦', 'Canada'),
    CountryCode('+44', '🇬🇧', 'United Kingdom'),
    CountryCode('+61', '🇦🇺', 'Australia'),
    CountryCode('+81', '🇯🇵', 'Japan'),
    CountryCode('+49', '🇩🇪', 'Germany'),
    CountryCode('+33', '🇫🇷', 'France'),
    CountryCode('+39', '🇮🇹', 'Italy'),
    CountryCode('+86', '🇨🇳', 'China'),
    CountryCode('+971', '🇦🇪', 'United Arab Emirates'),
    CountryCode('+65', '🇸🇬', 'Singapore'),
    CountryCode('+60', '🇲🇾', 'Malaysia'),
    CountryCode('+94', '🇱🇰', 'Sri Lanka'),
    CountryCode('+880', '🇧🇩', 'Bangladesh'),
    CountryCode('+977', '🇳🇵', 'Nepal'),
    CountryCode('+55', '🇧🇷', 'Brazil'),
    CountryCode('+52', '🇲🇽', 'Mexico'),
    CountryCode('+27', '🇿🇦', 'South Africa'),
    CountryCode('+7', '🇷🇺', 'Russia'),
  ];
}