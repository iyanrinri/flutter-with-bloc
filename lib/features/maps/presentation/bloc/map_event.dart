import 'package:equatable/equatable.dart';
import 'package:yukngantri/features/maps/domain/entities/location.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentLocation extends MapEvent {}

class AddMarker extends MapEvent {
  final Location location;

  const AddMarker(this.location);

  @override
  List<Object?> get props => [location];
}

class MoveToLocation extends MapEvent {
  final Location location;
  final double zoom;

  const MoveToLocation(this.location, this.zoom);

  @override
  List<Object?> get props => [location, zoom];
}