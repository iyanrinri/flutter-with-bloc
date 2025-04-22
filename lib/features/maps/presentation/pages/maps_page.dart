import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/core/widgets/layouts/main.dart';
import 'package:yukngantri/features/maps/data/map_repository.dart';
import 'package:yukngantri/features/maps/data/services/location_service.dart';
import 'package:yukngantri/features/maps/domain/entities/location.dart';
import 'package:yukngantri/features/maps/presentation/bloc/map_bloc.dart';
import 'package:yukngantri/features/maps/presentation/bloc/map_event.dart';
import 'package:yukngantri/features/maps/presentation/bloc/map_state.dart';
import 'package:yukngantri/features/maps/presentation/widgets/marker_popup.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapPlayground extends StatelessWidget {
  static const routeName = '/map-playground';
  const MapPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(MapRepository(LocationService()))
        ..add(LoadCurrentLocation()),
      child: const MapPlaygroundView(),
    );
  }
}

class MapPlaygroundView extends StatefulWidget {
  const MapPlaygroundView({super.key});

  @override
  MapPlaygroundViewState createState() => MapPlaygroundViewState();
}

class MapPlaygroundViewState extends State<MapPlaygroundView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  AnimationController? _animationController;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final currentCenter = _mapController.camera.center;
    final currentZoom = _mapController.camera.zoom;

    final latTween = Tween<double>(
      begin: currentCenter.latitude,
      end: destLocation.latitude,
    );

    final lngTween = Tween<double>(
      begin: currentCenter.longitude,
      end: destLocation.longitude,
    );

    final zoomTween = Tween<double>(begin: currentZoom, end: destZoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _animationController?.dispose();
    _animationController = controller;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      final lat = latTween.evaluate(animation);
      final lng = lngTween.evaluate(animation);
      final zoom = zoomTween.evaluate(animation);

      _mapController.move(LatLng(lat, lng), zoom);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (identical(_animationController, controller)) {
          _animationController = null;
        }
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: MainLayout(
        title: 'Map Playground',
        titleIcon: const Icon(Icons.map),
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            } else if (state.currentLocation != null) {

              final _tileProvider = FMTCTileProvider.allStores(
                allStoresStrategy: BrowseStoreStrategy.readUpdateCreate,
                loadingStrategy: BrowseLoadingStrategy.onlineFirst,
              );
              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        state.currentLocation!.latitude,
                        state.currentLocation!.longitude,
                      ),
                      initialZoom: 15.0,
                      onLongPress: (tapPosition, point) {
                        context.read<MapBloc>().add(
                          AddMarker(
                            Location(
                              latitude: point.latitude,
                              longitude: point.longitude,
                              name: 'Location: ${point.latitude}, ${point.longitude}',
                            ),
                          ),
                        );
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.rotate |
                        InteractiveFlag.flingAnimation, // Add fling animation
                        rotationThreshold: 20.0,
                        enableMultiFingerGestureRace: true,
                      ),
                    ),
                    // options: MapOptions(
                    //   initialCenter: LatLng(
                    //     state.currentLocation!.latitude,
                    //     state.currentLocation!.longitude,
                    //   ),
                    //   initialZoom: 15.0,
                    //   onLongPress: (tapPosition, point) {
                    //     context.read<MapBloc>().add(
                    //       AddMarker(
                    //         Location(
                    //           latitude: point.latitude,
                    //           longitude: point.longitude,
                    //           name:
                    //           'Location: ${point.latitude}, ${point.longitude}',
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   interactionOptions: const InteractionOptions(
                    //     flags: InteractiveFlag.pinchZoom |
                    //     InteractiveFlag.drag |
                    //     InteractiveFlag.rotate,
                    //     rotationThreshold: 20.0,
                    //     enableMultiFingerGestureRace: true,
                    //   ),
                    // ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.yukngantri.yukngantri',
                        // tileProvider: CancellableNetworkTileProvider(),
                        tileProvider: _tileProvider,
                        tileBuilder: (context, widget, tile) {
                          final url = 'https://tile.openstreetmap.org/${tile.coordinates.z}/${tile.coordinates.x}/${tile.coordinates.y}.png';
                          return CachedNetworkImage(
                            imageUrl: url,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          );
                        },
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              state.currentLocation!.latitude,
                              state.currentLocation!.longitude,
                            ),
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => MarkerPopup(
                                    location: state.currentLocation!,
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          ),
                          ...state.markers.map(
                                (marker) => Marker(
                              point: LatLng(
                                marker.latitude,
                                marker.longitude,
                              ),
                              width: 80,
                              height: 80,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => MarkerPopup(
                                      location: marker,
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      heroTag: "btnLocation",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        if (state.currentLocation != null) {
                          context.read<MapBloc>().add(
                            MoveToLocation(state.currentLocation!, 15.0),
                          );
                          _animatedMapMove(
                            LatLng(
                              state.currentLocation!.latitude,
                              state.currentLocation!.longitude,
                            ),
                            15.0,
                          );
                        }
                      },
                      child: const Icon(Icons.my_location, color: Colors.black),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Tidak dapat memuat lokasi.'));
            }
          },
        ),
      ),
    );
  }
}