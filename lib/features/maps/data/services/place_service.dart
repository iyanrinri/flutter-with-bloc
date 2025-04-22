import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceService {

  Future<String?> getPlaceNameByLatLong(double latitude, double longitude) async {
    // Create a cache key for the coordinates
    final cacheKey = 'place_name_${latitude}_$longitude';
    final prefs = await SharedPreferences.getInstance();

    // Check cache first
    final cachedPlaceName = prefs.getString(cacheKey);
    if (cachedPlaceName != null && cachedPlaceName.isNotEmpty) {
      return cachedPlaceName;
    }

    // Retry logic for Nominatim requests
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await setLocaleIdentifier('id_ID');
        final placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        ).timeout(const Duration(seconds: 5));

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final placeName = [
            placemark.street,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          if (placeName.isNotEmpty) {
            // Cache the place name
            await prefs.setString(cacheKey, placeName);
            return placeName;
          }
        }
        break; // Exit loop if we get a response, even if empty
      } catch (e) {
        print('Attempt $attempt failed: $e');
        if (attempt == 3) {
          print('All attempts failed for lat: $latitude, lng: $longitude');
          return null; // Return null after 3 failed attempts
        }
        await Future.delayed(const Duration(milliseconds: 1000)); // Respect rate limit
      }
    }
    return null;
  }
}