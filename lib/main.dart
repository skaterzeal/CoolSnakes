import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer portrait orientation for classic handheld aspect ratio
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storage = await StorageService.init();

  runApp(CoolSnakeApp(storage: storage));
}
