import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapsConfig {
  static String get webApiKey {
    final envVal = dotenv.env['GOOGLE_MAPS_WEB_API_KEY']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('GOOGLE_MAPS_WEB_API_KEY', defaultValue: '');
  }

  static String get placesApiKey {
    final envVal = dotenv.env['GOOGLE_MAPS_PLACES_API_KEY']?.replaceAll('"', '').trim();
    if (envVal != null && envVal.isNotEmpty) return envVal;
    return const String.fromEnvironment('GOOGLE_MAPS_PLACES_API_KEY', defaultValue: '');
  }

  static String get apiKey => placesApiKey.isNotEmpty ? placesApiKey : webApiKey;
}
