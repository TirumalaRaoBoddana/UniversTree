class InstitutionLocation {
  final String placeId;
  final double? latitude;
  final double? longitude;
  final String formattedAddress;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String district;
  final String state;
  final String country;
  final String postalCode;
  final String? plusCode;
  final String source;
  final bool isConfirmed;

  const InstitutionLocation({
    required this.placeId,
    this.latitude,
    this.longitude,
    required this.formattedAddress,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.district,
    required this.state,
    required this.country,
    required this.postalCode,
    this.plusCode,
    this.source = 'google_places',
    this.isConfirmed = false,
  });

  factory InstitutionLocation.empty() => const InstitutionLocation(
    placeId: '',
    formattedAddress: '',
    addressLine1: '',
    city: '',
    district: '',
    state: '',
    country: 'India',
    postalCode: '',
    source: 'google_places',
    isConfirmed: false,
  );

  factory InstitutionLocation.fromMap(Map<String, dynamic>? map) {
    if (map == null) return InstitutionLocation.empty();
    return InstitutionLocation(
      placeId: map['placeId'] as String? ?? map['place_id'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      formattedAddress: map['formattedAddress'] as String? ?? map['formatted_address'] as String? ?? '',
      addressLine1: map['addressLine1'] as String? ?? map['address_line1'] as String? ?? '',
      addressLine2: map['addressLine2'] as String? ?? map['address_line2'] as String?,
      city: map['city'] as String? ?? '',
      district: map['district'] as String? ?? '',
      state: map['state'] as String? ?? '',
      country: map['country'] as String? ?? 'India',
      postalCode: map['postalCode'] as String? ?? map['postal_code'] as String? ?? '',
      plusCode: map['plusCode'] as String? ?? map['plus_code'] as String?,
      source: map['source'] as String? ?? 'google_places',
      isConfirmed: map['isConfirmed'] as bool? ?? map['is_confirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'placeId': placeId,
    'latitude': latitude,
    'longitude': longitude,
    'formattedAddress': formattedAddress,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'district': district,
    'state': state,
    'country': country,
    'postalCode': postalCode,
    'plusCode': plusCode,
    'source': source,
    'isConfirmed': isConfirmed,
  };

  InstitutionLocation copyWith({
    String? placeId,
    double? latitude,
    double? longitude,
    String? formattedAddress,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? district,
    String? state,
    String? country,
    String? postalCode,
    String? plusCode,
    String? source,
    bool? isConfirmed,
  }) {
    return InstitutionLocation(
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      district: district ?? this.district,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      plusCode: plusCode ?? this.plusCode,
      source: source ?? this.source,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}