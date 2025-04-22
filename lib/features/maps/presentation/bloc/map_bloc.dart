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
  }

  Future<void> _onLoadCurrentLocation(
      LoadCurrentLocation event,
      Emitter<MapState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final location = await mapRepository.getCurrentLocation();
      emit(state.copyWith(
        currentLocation: location,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _onAddMarker(AddMarker event, Emitter<MapState> emit) {
    final updatedMarkers = List<Location>.from(state.markers)..add(event.location);
    emit(state.copyWith(markers: updatedMarkers));
  }

  void _onMoveToLocation(MoveToLocation event, Emitter<MapState> emit) {
    emit(state.copyWith(currentLocation: event.location));
  }
}