import 'package:cool_snake/game/models/control_mode.dart';
import 'package:cool_snake/game/models/game_speed.dart';
import 'package:cool_snake/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageService Persistence Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
    });

    test('defaults are initialized correctly', () {
      expect(storage.highScore, equals(0));
      expect(storage.speed, equals(GameSpeed.normal));
      expect(storage.controlMode, equals(ControlMode.swipe));
      expect(storage.soundEnabled, isTrue);
      expect(storage.hapticsEnabled, isTrue);
      expect(storage.lcdEffectsEnabled, isTrue);
      expect(storage.hasAchievedMaxScore, isFalse);
      expect(storage.paletteIndex, equals(0));
    });

    test('high score only updates when new score is greater', () async {
      await storage.saveHighScore(500);
      expect(storage.highScore, equals(500));

      // Attempt lower score: should not overwrite
      final updated = await storage.saveHighScore(300);
      expect(updated, isTrue); // 300 is stored as 2nd place in top 3
      expect(storage.highScore, equals(500));

      // Higher score: updates
      final updatedHigher = await storage.saveHighScore(1200);
      expect(updatedHigher, isTrue);
      expect(storage.highScore, equals(1200));
    });

    test('top 3 scores are maintained in descending order', () async {
      expect(storage.topScores, equals([0, 0, 0]));

      await storage.saveScore(200);
      expect(storage.topScores, equals([200, 0, 0]));
      expect(storage.highScore, equals(200));

      await storage.saveScore(500);
      expect(storage.topScores, equals([500, 200, 0]));
      expect(storage.highScore, equals(500));

      await storage.saveScore(100);
      expect(storage.topScores, equals([500, 200, 100]));
      expect(storage.highScore, equals(500));

      // 4th score higher than 3rd pushes 100 out
      await storage.saveScore(300);
      expect(storage.topScores, equals([500, 300, 200]));

      // Score lower than 3rd does not enter top 3
      final entered = await storage.saveScore(50);
      expect(entered, isFalse);
      expect(storage.topScores, equals([500, 300, 200]));
    });

    test('speed setting persistence', () async {
      await storage.setSpeed(GameSpeed.fast);
      expect(storage.speed, equals(GameSpeed.fast));

      await storage.setSpeed(GameSpeed.slow);
      expect(storage.speed, equals(GameSpeed.slow));
    });

    test('control mode persistence', () async {
      await storage.setControlMode(ControlMode.buttons);
      expect(storage.controlMode, equals(ControlMode.buttons));
    });

    test('audio, haptics, and lcd effects toggles', () async {
      await storage.setSoundEnabled(false);
      expect(storage.soundEnabled, isFalse);

      await storage.setHapticsEnabled(false);
      expect(storage.hapticsEnabled, isFalse);

      await storage.setLcdEffectsEnabled(false);
      expect(storage.lcdEffectsEnabled, isFalse);
    });

    test('max score achieved flag persistence', () async {
      expect(storage.hasAchievedMaxScore, isFalse);

      await storage.setMaxScoreAchieved(true);
      expect(storage.hasAchievedMaxScore, isTrue);
    });
  });
}
