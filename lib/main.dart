import 'package:flutter/material.dart';
import 'src/demo_app.dart';
import 'src/local/local_service.dart';
export 'src/demo_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalService.init();
  await LocalService.migrateIfNeeded(1);
  runApp(const DemoApp());
}

// Keep this file minimal: the demo app lives in src/demo_app.dart
