import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/game_state.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movement Tests', () {
    late SnakeEngine engine;

    setUp(() {
      engine = SnakeEngine(width: 20, height: 20, initialLength: 3);
      engine.setSnakeForTesting(
        [
          const GridPosition(10, 10), // Head
          const GridPosition(9, 10),
          const GridPosition(8, 10), // Tail
        ],
        direction: Direction.right,
      );
      engine.setFoodForTesting(const GridPosition(0, 0));
      engine.start();
    });

    test('step right advances head and shifts tail', () {
      engine.tick();
      expect(engine.head, equals(const GridPosition(11, 10)));
      expect(engine.snake[1], equals(const GridPosition(10, 10)));
      expect(engine.snake[2], equals(const GridPosition(9, 10)));
      expect(engine.snake.length, equals(3));
      expect(engine.state, equals(GameState.playing));
    });

    test('step up advances head upwards', () {
      engine.changeDirection(Direction.up);
      engine.tick();
      expect(engine.head, equals(const GridPosition(10, 9)));
      expect(engine.snake[1], equals(const GridPosition(10, 10)));
      expect(engine.snake[2], equals(const GridPosition(9, 10)));
    });

    test('step down advances head downwards', () {
      engine.changeDirection(Direction.down);
      engine.tick();
      expect(engine.head, equals(const GridPosition(10, 11)));
      expect(engine.snake[1], equals(const GridPosition(10, 10)));
      expect(engine.snake[2], equals(const GridPosition(9, 10)));
    });

    test('step left after vertical turn', () {
      engine.changeDirection(Direction.up);
      engine.tick(); // now at (10, 9), moving UP
      engine.changeDirection(Direction.left);
      engine.tick(); // now at (9, 9), moving LEFT
      expect(engine.head, equals(const GridPosition(9, 9)));
      expect(engine.currentDirection, equals(Direction.left));
    });
  });
}
