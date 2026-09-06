import 'package:flutter/material.dart';

/// LCD Color theme representing a two-color monochrome LCD palette.
class LcdPalette {
  final String name;
  final Color background;
  final Color pixels;
  final Color ghosting;
  final Color bezel;
  final Color bezelHighlight;

  const LcdPalette({
    required this.name,
    required this.background,
    required this.pixels,
    required this.ghosting,
    required this.bezel,
    required this.bezelHighlight,
  });
}

/// Collection of monochrome LCD palettes.
class LcdColors {
  /// Classic early-2000s monochrome olive green LCD.
  /// Background: #B5CB38, Pixels: #25320B as requested.
  static const classicOlive = LcdPalette(
    name: 'Classic Olive',
    background: Color(0xFFB5CB38),
    pixels: Color(0xFF25320B),
    ghosting: Color(0x3325320B),
    bezel: Color(0xFF2C3224),
    bezelHighlight: Color(0xFF424A37),
  );

  /// Monochrome pocket grey LCD.
  static const pocketGrey = LcdPalette(
    name: 'Pocket Grey',
    background: Color(0xFF909A87),
    pixels: Color(0xFF1E231D),
    ghosting: Color(0x331E231D),
    bezel: Color(0xFF333830),
    bezelHighlight: Color(0xFF4C5248),
  );

  /// Warm Amber LCD (found in industrial & early handheld devices).
  static const warmAmber = LcdPalette(
    name: 'Warm Amber',
    background: Color(0xFFD39B32),
    pixels: Color(0xFF3D2104),
    ghosting: Color(0x333D2104),
    bezel: Color(0xFF3A2814),
    bezelHighlight: Color(0xFF5A4126),
  );

  /// Cyan Blue-Green matrix LCD.
  static const matrixCyan = LcdPalette(
    name: 'Matrix Cyan',
    background: Color(0xFF72BCA2),
    pixels: Color(0xFF112E24),
    ghosting: Color(0x33112E24),
    bezel: Color(0xFF1D372E),
    bezelHighlight: Color(0xFF2F4F43),
  );

  static const List<LcdPalette> palettes = [
    classicOlive,
    pocketGrey,
    warmAmber,
    matrixCyan,
  ];
}
