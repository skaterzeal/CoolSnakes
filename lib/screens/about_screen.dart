import 'package:flutter/material.dart';
import '../app/lcd_bezel.dart';
import '../constants/lcd_colors.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';

/// About screen presenting the design principle, rules, and credits.
class AboutScreen extends StatelessWidget {
  final StorageService storage;
  final AudioService audio;
  final HapticsService haptics;

  const AboutScreen({
    super.key,
    required this.storage,
    required this.audio,
    required this.haptics,
  });

  LcdPalette get _palette => LcdColors.palettes[
      storage.paletteIndex.clamp(0, LcdColors.palettes.length - 1)];

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LcdBezel(
                palette: palette,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'COOL SNAKE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: palette.pixels,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(height: 1.0, color: palette.pixels),
                      const SizedBox(height: 10.0),
                      Text(
                        'RULES:\n'
                        '• EAT FOOD (+10)\n'
                        '• GROW LONGER\n'
                        '• WRAP BOUNDARIES\n'
                        '• AVOID SELF HIT\n'
                        '• FILL THE SCREEN\n'
                        '• WIN AT 019960',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: palette.pixels,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '100% ORIGINAL RETRO\n'
                        'MONOCHROME LCD GAME',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: palette.pixels.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: GestureDetector(
                onTap: () {
                  audio.playMenuClick();
                  haptics.click();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: palette.bezel,
                    borderRadius: BorderRadius.circular(24.0),
                    border:
                        Border.all(color: palette.bezelHighlight, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'BACK',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      letterSpacing: 1.5,
                      color: palette.background,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
