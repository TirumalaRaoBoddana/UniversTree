import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // <-- Add this import for debugPrint
import 'package:http/http.dart' as http;
import '../core/config/maps_config.dart';
import '../models/institution_location.dart';

class InstitutionSearchResult {
  final String institutionName;
  final String placeId;
  final String secondaryAddress;
  final InstitutionLocation? location;

  const InstitutionSearchResult({
    required this.institutionName,
    required this.placeId,
    required this.secondaryAddress,
    this.location,
  });
}

class InstitutionLocationService {
  /// Queries Google Places Autocomplete API with debounced user query
  Future<List<InstitutionSearchResult>> searchInstitutions(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final apiKey = MapsConfig.apiKey;
    List<InstitutionSearchResult> results = [];

    if (apiKey.isNotEmpty && apiKey != 'your_google_maps_api_key_here') {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(q)}&types=establishment|geocode&key=$apiKey',
      );

      try {
        final response = await http.get(url).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final predictions = data['predictions'] as List? ?? [];

          results = predictions.map((p) {
            final pMap = Map<String, dynamic>.from(p as Map);
            final structured = Map<String, dynamic>.from(pMap['structured_formatting'] ?? {});
            final mainText = structured['main_text'] as String? ?? pMap['description'] as String? ?? '';
            final secondaryText = structured['secondary_text'] as String? ?? '';
            final placeId = pMap['place_id'] as String? ?? '';

            return InstitutionSearchResult(
              institutionName: mainText,
              placeId: placeId,
              secondaryAddress: secondaryText,
            );
          }).toList();
        } else {
          debugPrint('================ GOOGLE PLACES HTTP ERROR ================');
          debugPrint('Status Code: ${response.statusCode}');
          debugPrint('Body: ${response.body}');
          debugPrint('==========================================================');
        }
      } catch (e) {
        debugPrint('================ PLACES EXCEPTION ================');
        debugPrint(e.toString());
        debugPrint('==================================================');
      }
    }

    return results;
  }

  /// Retrieves selected Google Place Details and extracts geocoded address components
  Future<InstitutionLocation?> getPlaceDetails(String placeId) async {
    final apiKey = MapsConfig.apiKey;

    if (apiKey.isEmpty || apiKey == 'your_google_maps_api_key_here') {
      return null;
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_components,formatted_address,geometry,name&key=$apiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = Map<String, dynamic>.from(data['result'] ?? {});
        return parsePlaceResult(result, placeId);
      }
    } catch (e) {
      debugPrint('Place Details Error: ${e.toString()}');
    }

    return null;
  }

  /// Dedicated address-component mapping function strictly mapping Google Places types
  static InstitutionLocation parsePlaceResult(Map<String, dynamic> result, String placeId) {
    final formattedAddress = result['formatted_address'] as String? ?? '';
    final geometry = Map<String, dynamic>.from(result['geometry'] ?? {});
    final location = Map<String, dynamic>.from(geometry['location'] ?? {});
    final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (location['lng'] as num?)?.toDouble() ?? 0.0;

    final components = (result['address_components'] as List? ?? []);

    String city = '';
    String district = '';
    String state = '';
    String country = 'India';
    String postalCode = '';
    String route = '';
    String streetNumber = '';
    String subpremise = '';

    for (final comp in components) {
      final compMap = Map<String, dynamic>.from(comp as Map);
      final types = (compMap['types'] as List? ?? []).cast<String>();
      final longName = compMap['long_name'] as String? ?? '';

      if (types.contains('locality') || types.contains('postal_town')) {
        city = longName;
      } else if (types.contains('administrative_area_level_2')) {
        district = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = longName;
      } else if (types.contains('country')) {
        country = longName;
      } else if (types.contains('postal_code')) {
        postalCode = longName;
      } else if (types.contains('route')) {
        route = longName;
      } else if (types.contains('street_number')) {
        streetNumber = longName;
      } else if (types.contains('subpremise') || types.contains('premise')) {
        subpremise = longName;
      }
    }

    if (city.isEmpty) {
      city = district;
    }

    final addressLine1Parts = [streetNumber, route].where((s) => s.isNotEmpty);
    final addressLine1 = addressLine1Parts.isNotEmpty
        ? addressLine1Parts.join(' ')
        : (result['name'] as String? ?? formattedAddress);

    return InstitutionLocation(
      formattedAddress: formattedAddress,
      addressLine1: addressLine1,
      addressLine2: subpremise.isNotEmpty ? subpremise : null,
      city: city,
      district: district,
      state: state,
      country: country.isNotEmpty ? country : 'India',
      postalCode: postalCode,
      latitude: lat,
      longitude: lng,
      placeId: placeId,
      isConfirmed: true,
    );
  }
}