import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/game_speed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Speed and Difficulty Invariance Tests', () {
    test('speed intervals match specifications exactly', () {
      expect(GameSpeed.slow.intervalMs, equals(180));
      expect(GameSpeed.normal.intervalMs, equals(130));
      expect(GameSpeed.fast.intervalMs, equals(90));

      expect(GameSpeed.slow.stepDuration,
          equals(const Duration(milliseconds: 180)));
      expect(GameSpeed.normal.stepDuration,
          equals(const Duration(milliseconds: 130)));
      expect(GameSpeed.fast.stepDuration,
          equals(const Duration(milliseconds: 90)));
    });

    test('speed is selectable before start', () {
      final engine = SnakeEngine();
      expect(engine.speed, equals(GameSpeed.normal));

      engine.setSpeed(GameSpeed.fast);
      expect(engine.speed, equals(GameSpeed.fast));

      engine.setSpeed(GameSpeed.slow);
      expect(engine.speed, equals(GameSpeed.slow));
    });

    test('speed remains strictly constant as score increases', () {
      final engine = SnakeEngine(speed: GameSpeed.slow);
      engine.start();

      // Eat 10 food items
      for (int i = 0; i < 10; i++) {
        engine.setFoodForTesting(engine.head.translate(1, 0).wrapped(50, 40));
        engine.tick();
        // Speed must remain strictly SLOW with 180ms interval
        expect(engine.speed, equals(GameSpeed.slow));
        expect(engine.speed.intervalMs, equals(180));
      }

      expect(engine.score, equals(100));
    });

    test('mid-run speed modifications are ignored while playing', () {
      final engine = SnakeEngine(speed: GameSpeed.normal);
      engine.start();

      // Attempt to change speed while playing
      engine.setSpeed(GameSpeed.fast);
      expect(engine.speed, equals(GameSpeed.normal));
    });
  });
}
