import 'package:yukngantri/features/maps/data/models/location_model.dart';
import 'package:yukngantri/features/maps/data/services/location_service.dart';
import 'package:yukngantri/features/maps/domain/entities/location.dart';

class MapRepository {
  final LocationService locationService;

  MapRepository(this.locationService);

  Future<LocationModel> getCurrentLocation() async {
    return await locationService.getCurrentLocation();
  }

  Future<String?> getPlaceName(double latitude, double longitude) async {
    return await locationService.getPlaceName(latitude, longitude);
  }

  Future<List<Location>> loadSavedMarkers() async {
    return await locationService.loadSavedMarkers();
  }

  Future<void> saveMarker(Location marker) async {
    await locationService.saveMarker(marker);
  }
}