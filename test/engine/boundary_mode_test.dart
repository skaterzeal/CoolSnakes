import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/boundary_mode.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/game_state.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundaryMode Tests', () {
    const width = 10;
    const height = 8;
    late SnakeEngine engine;

    group('Border Mode (Solid Walls)', () {
      setUp(() {
        engine = SnakeEngine(
          width: width,
          height: height,
          initialLength: 3,
          boundaryMode: BoundaryMode.border,
        );
        engine.setFoodForTesting(const GridPosition(5, 5));
        engine.start();
      });

      test('hitting right wall triggers game over', () {
        int? finalScore;
        engine.onGameOver = (score) => finalScore = score;

        engine.setSnakeForTesting(
          [
            const GridPosition(9, 3), // Right boundary
            const GridPosition(8, 3),
            const GridPosition(7, 3),
          ],
          direction: Direction.right,
        );

        engine.tick();

        expect(engine.state, equals(GameState.gameOver));
        expect(engine.isGameOver, isTrue);
        expect(finalScore, equals(0));
      });

      test('hitting left wall triggers game over', () {
        engine.setSnakeForTesting(
          [
            const GridPosition(0, 3), // Left boundary
            const GridPosition(1, 3),
            const GridPosition(2, 3),
          ],
          direction: Direction.left,
        );

        engine.tick();

        expect(engine.state, equals(GameState.gameOver));
        expect(engine.isGameOver, isTrue);
      });

      test('hitting top wall triggers game over', () {
        engine.setSnakeForTesting(
          [
            const GridPosition(4, 0), // Top boundary
            const GridPosition(4, 1),
            const GridPosition(4, 2),
          ],
          direction: Direction.up,
        );

        engine.tick();

        expect(engine.state, equals(GameState.gameOver));
        expect(engine.isGameOver, isTrue);
      });

      test('hitting bottom wall triggers game over', () {
        engine.setSnakeForTesting(
          [
            const GridPosition(4, 7), // Bottom boundary
            const GridPosition(4, 6),
            const GridPosition(4, 5),
          ],
          direction: Direction.down,
        );

        engine.tick();

        expect(engine.state, equals(GameState.gameOver));
        expect(engine.isGameOver, isTrue);
      });

      test('moving within borders survives', () {
        engine.setSnakeForTesting(
          [
            const GridPosition(5, 3),
            const GridPosition(4, 3),
            const GridPosition(3, 3),
          ],
          direction: Direction.right,
        );

        engine.tick();

        expect(engine.state, equals(GameState.playing));
        expect(engine.head, equals(const GridPosition(6, 3)));
      });

      test('turning before wall survives', () {
        engine.setSnakeForTesting(
          [
            const GridPosition(9, 3),
            const GridPosition(8, 3),
            const GridPosition(7, 3),
          ],
          direction: Direction.right,
        );

        engine.changeDirection(Direction.down);
        engine.tick();

        expect(engine.state, equals(GameState.playing));
        expect(engine.head, equals(const GridPosition(9, 4)));
      });
    });

    group('Wrap Mode Switch', () {
      test('setBoundaryMode switches mode in ready state', () {
        final eng = SnakeEngine(
          width: width,
          height: height,
          boundaryMode: BoundaryMode.wrap,
        );
        expect(eng.boundaryMode, equals(BoundaryMode.wrap));

        eng.setBoundaryMode(BoundaryMode.border);
        expect(eng.boundaryMode, equals(BoundaryMode.border));
      });
    });
  });
}
