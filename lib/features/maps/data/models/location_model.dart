import 'package:yukngantri/features/maps/domain/entities/location.dart';

class LocationModel extends Location {
  const LocationModel({
    required double latitude,
    required double longitude,
    String? name,
  }) : super(latitude: latitude, longitude: longitude, name: name);

  factory LocationModel.fromPosition(dynamic position) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      name: 'Current Location',
    );
  }
}