import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yukngantri/features/maps/data/map_repository.dart';
import 'package:yukngantri/features/maps/domain/entities/location.dart';
import 'package:yukngantri/features/maps/presentation/bloc/map_event.dart';
import 'package:yukngantri/features/maps/presentation/bloc/map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapRepository mapRepository;

  MapBloc(this.mapRepository) : super(const MapState()) {
    on<LoadCurrentLocation>(_onLoadCurrentLocation);
    on<AddMarker>(_onAddMarker);
    on<MoveToLocation>(_onMoveToLocation);
    on<UpdateMarkerPlaceNames>(_onUpdateMarkerPlaceNames);
    on<LoadSavedMarkers>(_onLoadSavedMarkers);
  }
  Future<void> _onLoadSavedMarkers(
      LoadSavedMarkers event,
      Emitter<MapState> emit,
      ) async {
    try {
      final savedMarkers = await mapRepository.loadSavedMarkers();
      emit(state.copyWith(markers: savedMarkers));
      add(UpdateMarkerPlaceNames()); // Ensure place names are fetched
    } catch (e) {
      print('Error loading saved markers: $e');
    }
  }

  Future<void> _onLoadCurrentLocation(
      LoadCurrentLocation event,
      Emitter<MapState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final location = await mapRepository.getCurrentLocation();
      final placeName = await mapRepository.getPlaceName(
        location.latitude,
        location.longitude,
      );
      // Update place names for existing markers
      add(UpdateMarkerPlaceNames());
      emit(state.copyWith(
        currentLocation: location,
        isLoading: false,
        name: placeName ?? 'Current Location',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

// Update _onAddMarker to save markers
  Future<void> _onAddMarker(AddMarker event, Emitter<MapState> emit) async {
    try {
      final placeName = await mapRepository.getPlaceName(
        event.location.latitude,
        event.location.longitude,
      );
      final newMarker = Location(
        latitude: event.location.latitude,
        longitude: event.location.longitude,
        name: placeName ?? 'Location: ${event.location.latitude}, ${event.location.longitude}',
      );
      await mapRepository.saveMarker(newMarker); // Save to storage
      final updatedMarkers = List<Location>.from(state.markers)..add(newMarker);
      emit(state.copyWith(markers: updatedMarkers));
    } catch (e) {
      final newMarker = Location(
        latitude: event.location.latitude,
        longitude: event.location.longitude,
        name: 'Location: ${event.location.latitude}, ${event.location.longitude}',
      );
      await mapRepository.saveMarker(newMarker);
      final updatedMarkers = List<Location>.from(state.markers)..add(newMarker);
      emit(state.copyWith(markers: updatedMarkers));
    }
  }

  void _onMoveToLocation(MoveToLocation event, Emitter<MapState> emit) {
    emit(state.copyWith(currentLocation: event.location));
  }

  Future<void> _onUpdateMarkerPlaceNames(
      UpdateMarkerPlaceNames event,
      Emitter<MapState> emit,
      ) async {
    final updatedMarkers = <Location>[];
    for (final marker in state.markers) {
      if (marker.name == null ||
          marker.name!.startsWith('Location:') ||
          marker.name!.isEmpty) {
        final placeName = await mapRepository.getPlaceName(
          marker.latitude,
          marker.longitude,
        );
        updatedMarkers.add(Location(
          latitude: marker.latitude,
          longitude: marker.longitude,
          name: placeName ?? 'Location: ${marker.latitude}, ${marker.longitude}',
        ));
      } else {
        updatedMarkers.add(marker);
      }
    }
    emit(state.copyWith(markers: updatedMarkers));
  }
}