import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

final modApp = "prod";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  if (modApp == "prod") {
    await dotenv.load(fileName: ".env.prod");
  } else {
    await dotenv.load(fileName: ".env");
  }
  await FMTCStore('mapStore').manage.create();
  runApp(const MyApp());
  // runApp(const GeolocatorWidget());
}
