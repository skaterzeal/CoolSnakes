import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/game_state.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wrap-around Boundary Tests', () {
    const width = 10;
    const height = 8;
    late SnakeEngine engine;

    setUp(() {
      engine = SnakeEngine(width: width, height: height, initialLength: 3);
      engine.setFoodForTesting(const GridPosition(5, 5));
      engine.start();
    });

    test('exiting right edge enters from left edge', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(9, 3), // Rightmost edge
          const GridPosition(8, 3),
          const GridPosition(7, 3),
        ],
        direction: Direction.right,
      );

      engine.tick();

      expect(engine.head, equals(const GridPosition(0, 3)));
      expect(engine.state, equals(GameState.playing));
    });

    test('exiting left edge enters from right edge', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(0, 3), // Leftmost edge
          const GridPosition(1, 3),
          const GridPosition(2, 3),
        ],
        direction: Direction.left,
      );

      engine.tick();

      expect(engine.head, equals(const GridPosition(9, 3)));
      expect(engine.state, equals(GameState.playing));
    });

    test('exiting top edge enters from bottom edge', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(4, 0), // Topmost edge
          const GridPosition(4, 1),
          const GridPosition(4, 2),
        ],
        direction: Direction.up,
      );

      engine.tick();

      expect(engine.head, equals(const GridPosition(4, 7)));
      expect(engine.state, equals(GameState.playing));
    });

    test('exiting bottom edge enters from top edge', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(4, 7), // Bottommost edge
          const GridPosition(4, 6),
          const GridPosition(4, 5),
        ],
        direction: Direction.down,
      );

      engine.tick();

      expect(engine.head, equals(const GridPosition(4, 0)));
      expect(engine.state, equals(GameState.playing));
    });

    test('continuous circular wrap around whole board', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(8, 2),
          const GridPosition(7, 2),
          const GridPosition(6, 2),
        ],
        direction: Direction.right,
      );

      // Advance 10 steps horizontally: should complete a full wrap
      for (int i = 0; i < 10; i++) {
        engine.tick();
      }

      expect(engine.head, equals(const GridPosition(8, 2)));
      expect(engine.state, equals(GameState.playing));
    });
  });
}
