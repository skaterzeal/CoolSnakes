import 'package:flutter/material.dart';
import '../constants/lcd_colors.dart';
import '../screens/main_menu_screen.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';

/// Root application widget for Cool Snake.
class CoolSnakeApp extends StatefulWidget {
  final StorageService storage;

  const CoolSnakeApp({super.key, required this.storage});

  @override
  State<CoolSnakeApp> createState() => _CoolSnakeAppState();
}

class _CoolSnakeAppState extends State<CoolSnakeApp> {
  late final AudioService _audio;
  late final HapticsService _haptics;

  @override
  void initState() {
    super.initState();
    _audio = AudioService(isEnabled: () => widget.storage.soundEnabled);
    _haptics = HapticsService(isEnabled: () => widget.storage.hapticsEnabled);
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  LcdPalette get _palette => LcdColors.palettes[
      widget.storage.paletteIndex.clamp(0, LcdColors.palettes.length - 1)];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cool Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: _palette.background,
        fontFamily: 'Courier',
      ),
      home: MainMenuScreen(
        storage: widget.storage,
        audio: _audio,
        haptics: _haptics,
        onConfigChanged: () => setState(() {}),
      ),
    );
  }
}
