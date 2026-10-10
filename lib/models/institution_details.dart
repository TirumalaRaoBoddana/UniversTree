import 'institution_website.dart';

class InstitutionDetails {
  final String name;
  final String shortName;
  final String website;
  final String officialDomain;
  final List<InstitutionWebsite> websites;

  const InstitutionDetails({
    required this.name,
    required this.shortName,
    required this.website,
    required this.officialDomain,
    this.websites = const [],
  });

  factory InstitutionDetails.empty() => const InstitutionDetails(
    name: '',
    shortName: '',
    website: '',
    officialDomain: '',
    websites: [],
  );

  factory InstitutionDetails.fromMap(Map<String, dynamic>? map) {
    if (map == null) return InstitutionDetails.empty();

    final name = map['name'] as String? ?? map['full_name'] as String? ?? '';
    final shortName = map['shortName'] as String? ?? map['short_name'] as String? ?? '';
    final website = map['website'] as String? ?? map['official_website'] as String? ?? '';
    final officialDomain = map['officialDomain'] as String? ?? map['official_domain'] as String? ?? '';

    // Explicitly cast each entry to Map<String, dynamic> before parsing
    List<InstitutionWebsite> rawWebsites = [];
    if (map['websites'] != null) {
      rawWebsites = (map['websites'] as List)
          .map((w) => InstitutionWebsite.fromMap(Map<String, dynamic>.from(w as Map)))
          .toList();
    }

    if (rawWebsites.isEmpty && website.isNotEmpty) {
      rawWebsites = [
        InstitutionWebsite(
          id: 'website_primary',
          type: 'Official College/University Website',
          url: website,
          description: 'Main institutional website',
          isPrimary: true,
        ),
      ];
    } else {
      rawWebsites = rawWebsites.map((w) {
        if (w.isPrimary) {
          return w.copyWith(url: website.isNotEmpty ? website : w.url);
        }
        return w;
      }).toList();
    }

    return InstitutionDetails(
      name: name,
      shortName: shortName,
      website: website,
      officialDomain: officialDomain,
      websites: rawWebsites,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'shortName': shortName,
    'website': website,
    'officialWebsite': website,
    'officialDomain': officialDomain,
    'websites': websites.map((w) => w.toMap()).toList(),
  };

  InstitutionDetails copyWith({
    String? name,
    String? shortName,
    String? website,
    String? officialDomain,
    List<InstitutionWebsite>? websites,
  }) {
    return InstitutionDetails(
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      website: website ?? this.website,
      officialDomain: officialDomain ?? this.officialDomain,
      websites: websites ?? this.websites,
    );
  }
}