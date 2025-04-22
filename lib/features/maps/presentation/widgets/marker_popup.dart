import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yukngantri/features/maps/domain/entities/location.dart';

class MarkerPopup extends StatelessWidget {
  final Location location;

  const MarkerPopup({super.key, required this.location});

  Future<void> _openGoogleMaps(BuildContext context) async {
    final geoUrl =
        'geo:${location.latitude},${location.longitude}?q=${location.latitude},${location.longitude}';
    final httpsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';

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
            content: Text('Could not open maps.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening maps: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(location.name ?? 'Location'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Lat: ${location.latitude}, Lng: ${location.longitude}'),
          ElevatedButton.icon(
            onPressed: () => _openGoogleMaps(context),
            icon: const Icon(Icons.directions),
            label: const Text('Directions'),
          ),
        ],
      ),
    );
  }
}