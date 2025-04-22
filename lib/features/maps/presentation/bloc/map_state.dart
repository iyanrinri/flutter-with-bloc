import 'package:equatable/equatable.dart';
import 'package:yukngantri/features/maps/domain/entities/location.dart';

class MapState extends Equatable {
  final Location? currentLocation;
  final List<Location> markers;
  final bool isLoading;
  final String? error;

  const MapState({
    this.currentLocation,
    this.markers = const [],
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    Location? currentLocation,
    List<Location>? markers,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [currentLocation, markers, isLoading, error];
}