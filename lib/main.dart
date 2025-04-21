import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

final modApp = "prod";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (modApp == "prod") {
    await dotenv.load(fileName: ".env.prod");
  } else {
    await dotenv.load(fileName: ".env");
  }
  runApp(const MyApp());
}
