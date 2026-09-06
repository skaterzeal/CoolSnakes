import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Input Buffering Tests', () {
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

    test('rapid swipes: UP then LEFT executes sequentially across ticks', () {
      // Currently moving RIGHT.
      // Player quickly queues UP, then LEFT before any tick occurs.
      final upQueued = engine.changeDirection(Direction.up);
      final leftQueued = engine.changeDirection(Direction.left);

      expect(upQueued, isTrue);
      expect(leftQueued, isTrue);

      // Tick 1: should turn UP
      engine.tick();
      expect(engine.currentDirection, equals(Direction.up));
      expect(engine.head, equals(const GridPosition(10, 9)));

      // Tick 2: should turn LEFT
      engine.tick();
      expect(engine.currentDirection, equals(Direction.left));
      expect(engine.head, equals(const GridPosition(9, 9)));
    });

    test('buffer prevents queued reversal (e.g. RIGHT -> UP -> DOWN)', () {
      // Moving RIGHT.
      final upQueued = engine.changeDirection(Direction.up);
      // Try to queue DOWN right after UP: must be rejected because it opposes UP
      final downQueued = engine.changeDirection(Direction.down);

      expect(upQueued, isTrue);
      expect(downQueued, isFalse);

      engine.tick();
      expect(engine.currentDirection, equals(Direction.up));
    });

    test('excess inputs beyond buffer limit are safely discarded', () {
      // Queue UP (ok), then LEFT (ok)
      expect(engine.changeDirection(Direction.up), isTrue);
      expect(engine.changeDirection(Direction.left), isTrue);
      // Third input while buffer is at max capacity (2)
      expect(engine.changeDirection(Direction.down), isFalse);
    });
  });
}
