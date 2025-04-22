import 'package:yukngantri/features/maps/data/models/location_model.dart';
import 'package:yukngantri/features/maps/data/services/location_service.dart';

class MapRepository {
  final LocationService locationService;

  MapRepository(this.locationService);

  Future<LocationModel> getCurrentLocation() async {
    return await locationService.getCurrentLocation();
  }
}