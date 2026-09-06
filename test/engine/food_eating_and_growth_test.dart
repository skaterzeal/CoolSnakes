import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Food Eating and Growth Tests', () {
    late SnakeEngine engine;

    setUp(() {
      engine = SnakeEngine(width: 20, height: 20, initialLength: 3);
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

    test('eating food increases length by exactly one and keeps tail', () {
      // Place food right in front of head
      engine.setFoodForTesting(const GridPosition(6, 5));
      expect(engine.snakeLength, equals(3));

      int callbackScore = -1;
      engine.onFoodEaten = (score) => callbackScore = score;

      engine.tick();

      // Snake should now have length 4
      expect(engine.snakeLength, equals(4));
      expect(engine.head, equals(const GridPosition(6, 5)));
      // Tail at (3, 5) should have been preserved
      expect(engine.snake.last, equals(const GridPosition(3, 5)));
      expect(callbackScore, equals(10));
      // Food should be respawned at a new location
      expect(engine.food, isNotNull);
      expect(engine.food, isNot(equals(const GridPosition(6, 5))));
      expect(engine.snake.contains(engine.food!), isFalse);
    });

    test('eating food multiple times grows snake incrementally', () {
      // First food
      engine.setFoodForTesting(const GridPosition(6, 5));
      engine.tick();
      expect(engine.snakeLength, equals(4));

      // Second food
      engine.setFoodForTesting(const GridPosition(7, 5));
      engine.tick();
      expect(engine.snakeLength, equals(5));

      // Third food
      engine.setFoodForTesting(const GridPosition(8, 5));
      engine.tick();
      expect(engine.snakeLength, equals(6));
    });
  });
}
