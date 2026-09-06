import 'package:flutter/material.dart';
import '../app/lcd_bezel.dart';
import '../constants/game_config.dart';
import '../constants/lcd_colors.dart';
import '../game/engine/snake_engine.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';

/// High Score Screen displaying current record, theoretical maximum possible score,
/// and completion achievement badge.
class HighScoreScreen extends StatelessWidget {
  final StorageService storage;
  final AudioService audio;
  final HapticsService haptics;

  const HighScoreScreen({
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
    final topScores = storage.topScores;
    final maxPossibleStr =
        SnakeEngine.formatScore(GameConfig.maxPossibleScore);
    final hasAchievedMax = storage.hasAchievedMaxScore ||
        (storage.highScore >= GameConfig.maxPossibleScore);

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
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'HIGH SCORES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: palette.pixels,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(height: 2.0, color: palette.pixels),
                      const SizedBox(height: 8.0),
                      ...List.generate(3, (index) {
                        final rank = index + 1;
                        final score = topScores.length > index ? topScores[index] : 0;
                        final scoreFormatted = SnakeEngine.formatScore(score);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$rank.',
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w900,
                                  color: palette.pixels,
                                ),
                              ),
                              Text(
                                scoreFormatted,
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.5,
                                  color: palette.pixels,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8.0),
                      Container(height: 1.0, color: palette.pixels),
                      const SizedBox(height: 8.0),
                      Text(
                        'MAX POSSIBLE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: palette.pixels.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        maxPossibleStr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: palette.pixels,
                        ),
                      ),
                      if (hasAchievedMax) ...[
                        const SizedBox(height: 16.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: palette.pixels, width: 2.0),
                          ),
                          child: Text(
                            '* MAX SCORE ACHIEVED *',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 13.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: palette.pixels,
                            ),
                          ),
                        ),
                      ],
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
