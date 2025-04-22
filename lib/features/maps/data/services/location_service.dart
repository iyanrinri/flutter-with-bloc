import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yukngantri/features/maps/data/models/location_model.dart';
import 'package:yukngantri/features/maps/domain/entities/location.dart';
import 'place_service.dart';

class LocationService {

  final PlaceService placeService;

  LocationService(this.placeService);

  Future<LocationModel> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    final position = await Geolocator.getCurrentPosition();
    return LocationModel.fromPosition(position);
  }

  Future<String?> getPlaceName(double latitude, double longitude) async {
    return placeService.getPlaceNameByLatLong(latitude, longitude);
  }

  Future<List<Location>> loadSavedMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final markerData = prefs.getStringList('saved_markers') ?? [];
    final markers = <Location>[];
    for (final data in markerData) {
      final parts = data.split('|');
      if (parts.length >= 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          final placeName = await getPlaceName(lat, lng);
          markers.add(Location(
            latitude: lat,
            longitude: lng,
            name: placeName
          ));
        }
      }
    }
    return markers;
  }

  Future<void> saveMarker(Location marker) async {
    final prefs = await SharedPreferences.getInstance();
    final markerData = prefs.getStringList('saved_markers') ?? [];
    markerData.add('${marker.latitude}|${marker.longitude}');
    await prefs.setStringList('saved_markers', markerData);
  }
}