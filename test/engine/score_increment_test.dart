import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Score Increment and Formatting Tests', () {
    late SnakeEngine engine;

    setUp(() {
      engine = SnakeEngine(width: 20, height: 20);
      engine.setSnakeForTesting(
        [
          const GridPosition(5, 5),
          const GridPosition(4, 5),
          const GridPosition(3, 5),
        ],
        direction: Direction.right,
      );
      engine.start();
    });

    test('initial score is 0 and formats as 000000', () {
      expect(engine.score, equals(0));
      expect(SnakeEngine.formatScore(engine.score), equals('000000'));
    });

    test('score increases by 10 per food eaten', () {
      engine.setFoodForTesting(const GridPosition(6, 5));
      engine.tick();
      expect(engine.score, equals(10));
      expect(SnakeEngine.formatScore(engine.score), equals('000010'));

      engine.setFoodForTesting(const GridPosition(7, 5));
      engine.tick();
      expect(engine.score, equals(20));
      expect(SnakeEngine.formatScore(engine.score), equals('000020'));
    });

    test('formatScore zero pads numbers correctly', () {
      expect(SnakeEngine.formatScore(0), equals('000000'));
      expect(SnakeEngine.formatScore(10), equals('000010'));
      expect(SnakeEngine.formatScore(470), equals('000470'));
      expect(SnakeEngine.formatScore(12350), equals('012350'));
      expect(SnakeEngine.formatScore(19960), equals('019960'));
    });
  });
}
