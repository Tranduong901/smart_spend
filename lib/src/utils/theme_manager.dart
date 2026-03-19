import 'package:flutter/material.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> modeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  static void toggleMode() {
    modeNotifier.value = modeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    useMaterial3: true,
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
