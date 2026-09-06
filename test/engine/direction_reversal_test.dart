import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Direction Reversal Prevention Tests', () {
    late SnakeEngine engine;

    setUp(() {
      engine = SnakeEngine(width: 20, height: 20);
      engine.setSnakeForTesting(
        [
          const GridPosition(10, 10),
          const GridPosition(9, 10),
          const GridPosition(8, 10),
        ],
        direction: Direction.right,
      );
      engine.start();
    });

    test('reversal from RIGHT to LEFT is rejected', () {
      expect(engine.currentDirection, equals(Direction.right));

      final accepted = engine.changeDirection(Direction.left);
      expect(accepted, isFalse);

      engine.tick();
      expect(engine.currentDirection, equals(Direction.right));
      expect(engine.head, equals(const GridPosition(11, 10)));
    });

    test('reversal from LEFT to RIGHT is rejected', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(10, 10),
          const GridPosition(11, 10),
          const GridPosition(12, 10),
        ],
        direction: Direction.left,
      );

      final accepted = engine.changeDirection(Direction.right);
      expect(accepted, isFalse);

      engine.tick();
      expect(engine.currentDirection, equals(Direction.left));
      expect(engine.head, equals(const GridPosition(9, 10)));
    });

    test('reversal from UP to DOWN is rejected', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(10, 10),
          const GridPosition(10, 11),
          const GridPosition(10, 12),
        ],
        direction: Direction.up,
      );

      final accepted = engine.changeDirection(Direction.down);
      expect(accepted, isFalse);

      engine.tick();
      expect(engine.currentDirection, equals(Direction.up));
      expect(engine.head, equals(const GridPosition(10, 9)));
    });

    test('reversal from DOWN to UP is rejected', () {
      engine.setSnakeForTesting(
        [
          const GridPosition(10, 10),
          const GridPosition(10, 9),
          const GridPosition(10, 8),
        ],
        direction: Direction.down,
      );

      final accepted = engine.changeDirection(Direction.up);
      expect(accepted, isFalse);

      engine.tick();
      expect(engine.currentDirection, equals(Direction.down));
      expect(engine.head, equals(const GridPosition(10, 11)));
    });

    test('identical direction is not duplicated in buffer', () {
      final accepted = engine.changeDirection(Direction.right);
      expect(accepted, isFalse);
    });
  });
}
