import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yukngantri/core/utils/double_back_to_exit.dart';
import 'package:yukngantri/core/widgets/layouts/main.dart';

class MapPlayground extends StatefulWidget {
  static const routeName = '/map-playground';
  const MapPlayground({super.key});

  @override
  MapPlaygroundState createState() => MapPlaygroundState();
}

class MapPlaygroundState extends State<MapPlayground>
    with TickerProviderStateMixin {
  LatLng? currentLocation;
  final MapController _mapController = MapController();
  AnimationController? _animationController;
  String placeName = 'Current Location';
  List<Marker> markers = [];
  late Future<LatLng> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = setCurrentLocation();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<LatLng> setCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  void _showMarkerPopup(LatLng latLng) {
    setState(() {
      placeName = 'Location: ${latLng.latitude}, ${latLng.longitude}';
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Marker at $placeName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tapped location: $placeName'),
              ElevatedButton.icon(
                onPressed: () => _openGoogleMaps(latLng),
                icon: const Icon(Icons.directions),
                label: const Text('Directions'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onLongPress(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      markers.add(
        Marker(
          point: latLng,
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showMarkerPopup(latLng),
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        ),
      );
    });
  }

  void animatedMapMove(LatLng destLocation, double destZoom) {
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

  Future<void> moveToCurrentLocation() async {
    await _determinePosition();
    if (!mounted || currentLocation == null) return;
    animatedMapMove(currentLocation!, 15.0);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permission lokasi ditolak permanen.');
    }

    final location = await setCurrentLocation();
    if (!mounted) return;
    setState(() {
      currentLocation = location;
    });
  }

  void _openGoogleMaps(LatLng latLng) async {
    // Primary: Try geo: scheme for direct maps app
    final geoUrl =
        'geo:${latLng.latitude},${latLng.longitude}?q=${latLng.latitude},${latLng.longitude}';
    final httpsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${latLng.latitude},${latLng.longitude}';

    try {
      if (await canLaunchUrl(Uri.parse(geoUrl))) {
        await launchUrl(
          Uri.parse(geoUrl),
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(Uri.parse(httpsUrl))) {
        await launchUrl(
          Uri.parse(httpsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open maps. Please ensure a maps app or browser is installed.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error opening maps: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: MainLayout(
        title: 'Map Playground',
        titleIcon: const Icon(Icons.map),
        child: FutureBuilder<LatLng>(
          future: _locationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              currentLocation = snapshot.data!;
              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLocation!,
                      initialZoom: 15.0,
                      onLongPress: _onLongPress,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.rotate,
                        rotationThreshold: 20.0,
                        enableMultiFingerGestureRace: true,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.yukantri.app',
                        tileProvider: CancellableNetworkTileProvider(),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLocation!,
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(placeName),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed:
                                                () => _openGoogleMaps(
                                              currentLocation!,
                                            ),
                                            icon: const Icon(Icons.directions),
                                            label: const Text('Directions'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          ),
                          ...markers,
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
                      onPressed: moveToCurrentLocation,
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
