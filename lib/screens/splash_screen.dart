import 'dart:async';
import 'package:flutter/material.dart';
import '../app/lcd_bezel.dart';
import '../constants/lcd_colors.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';
import 'main_menu_screen.dart';

/// Retro handheld console bootup splash and loading screen.
class SplashScreen extends StatefulWidget {
  final StorageService storage;
  final AudioService audio;
  final HapticsService haptics;
  final VoidCallback onConfigChanged;

  const SplashScreen({
    super.key,
    required this.storage,
    required this.audio,
    required this.haptics,
    required this.onConfigChanged,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  Timer? _progressTimer;

  LcdPalette get _palette => LcdColors.palettes[
      widget.storage.paletteIndex.clamp(0, LcdColors.palettes.length - 1)];

  @override
  void initState() {
    super.initState();
    _startBootSequence();
  }

  void _startBootSequence() {
    // Play subtle startup click
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        widget.audio.playMenuClick();
        widget.haptics.click();
      }
    });

    const totalDurationMs = 1600;
    const intervalMs = 50;
    const steps = totalDurationMs / intervalMs;
    int currentStep = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      currentStep++;
      if (mounted) {
        setState(() {
          _progress = (currentStep / steps).clamp(0.0, 1.0);
        });
      }
      if (currentStep >= steps) {
        timer.cancel();
        _navigateToMenu();
      }
    });
  }

  void _navigateToMenu() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: MainMenuScreen(
            storage: widget.storage,
            audio: widget.audio,
            haptics: widget.haptics,
            onConfigChanged: widget.onConfigChanged,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final percent = (_progress * 100).toInt();

    // Segmented block bar: 10 segments total
    final totalSegments = 10;
    final filledSegments = (_progress * totalSegments).floor();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LcdBezel(
                palette: palette,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Badge
                      Container(
                        width: 130.0,
                        height: 130.0,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: palette.pixels,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: palette.pixels.withValues(alpha: 0.3),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13.5),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      Text(
                        'COOL SNAKES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.5,
                          color: palette.pixels,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'ORIGINAL RETRO LCD',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: palette.pixels.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Segmented Retro Progress Bar
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: palette.pixels, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(totalSegments, (index) {
                            final isFilled = index < filledSegments;
                            return Container(
                              width: 14.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              color: isFilled ? palette.pixels : Colors.transparent,
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'LOADING... $percent%',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: palette.pixels,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
