class LocationDataModel {
  final String formattedAddress;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String district;
  final String state;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String placeId;
  final bool isManuallyEdited;

  const LocationDataModel({
    required this.formattedAddress,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.district,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    this.isManuallyEdited = false,
  });

  bool get isValidCoordinates =>
      latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0;

  factory LocationDataModel.fromMap(Map<String, dynamic> map) {
    return LocationDataModel(
      formattedAddress: map['formatted_address'] as String? ?? '',
      addressLine1: map['address_line1'] as String? ?? '',
      addressLine2: map['address_line2'] as String?,
      city: map['city'] as String? ?? '',
      district: map['district'] as String? ?? '',
      state: map['state'] as String? ?? '',
      country: map['country'] as String? ?? 'India',
      postalCode: map['postal_code'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      placeId: map['place_id'] as String? ?? '',
      isManuallyEdited: map['is_manually_edited'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'formatted_address': formattedAddress,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'district': district,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
      'is_manually_edited': isManuallyEdited,
    };
  }

  LocationDataModel copyWith({
    String? formattedAddress,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? district,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? placeId,
    bool? isManuallyEdited,
  }) {
    return LocationDataModel(
      formattedAddress: formattedAddress ?? this.formattedAddress,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      district: district ?? this.district,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
    );
  }
}