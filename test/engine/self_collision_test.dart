import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/game_state.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Self-Collision and Moving Tail Tests', () {
    late SnakeEngine engine;

    setUp(() {
      engine = SnakeEngine(width: 20, height: 20, initialLength: 5);
      engine.setFoodForTesting(const GridPosition(0, 0));
      engine.start();
    });

    test('head colliding with body triggers game over immediately', () {
      // Setup snake in a 'C' shape about to close on itself:
      // (5,5) -> (5,6) -> (4,6) -> (4,5) -> (4,4)
      engine.setSnakeForTesting(
        [
          const GridPosition(5, 5), // Head
          const GridPosition(5, 6),
          const GridPosition(4, 6),
          const GridPosition(4, 5),
          const GridPosition(4, 4), // Tail
        ],
        direction: Direction.left,
      );

      int gameOverScore = -1;
      engine.onGameOver = (score) => gameOverScore = score;

      // Moving LEFT moves head to (4, 5) which is occupied by body segment index 3
      engine.tick();

      expect(engine.state, equals(GameState.gameOver));
      expect(engine.isGameOver, isTrue);
      expect(gameOverScore, equals(0));
    });

    test('moving into tail position when food is NOT eaten is SAFE (tail vacates)',
        () {
      // 4-segment loop:
      // Head at (5, 5), body at (6, 5), (6, 6), Tail at (5, 6).
      // Head faces DOWN (dx: 0, dy: 1).
      // Next head position is (5, 6), exactly where the tail currently is!
      engine.setSnakeForTesting(
        [
          const GridPosition(5, 5), // Head
          const GridPosition(6, 5),
          const GridPosition(6, 6),
          const GridPosition(5, 6), // Tail
        ],
        direction: Direction.down,
      );
      // Food is elsewhere
      engine.setFoodForTesting(const GridPosition(0, 0));

      engine.tick();

      // Because food was NOT eaten, tail moved out of (5, 6) in the same tick!
      expect(engine.state, equals(GameState.playing));
      expect(engine.head, equals(const GridPosition(5, 6)));
      expect(engine.snake[1], equals(const GridPosition(5, 5)));
      expect(engine.snake[2], equals(const GridPosition(6, 5)));
      expect(engine.snake[3], equals(const GridPosition(6, 6)));
      expect(engine.snake.length, equals(4));
    });

    test(
        'moving into tail position when food IS eaten COLLIDES (tail does not vacate)',
        () {
      // Same 4-segment loop, but food is placed right at the tail position (5, 6)!
      engine.setSnakeForTesting(
        [
          const GridPosition(5, 5), // Head
          const GridPosition(6, 5),
          const GridPosition(6, 6),
          const GridPosition(5, 6), // Tail
        ],
        direction: Direction.down,
      );
      // Food is placed at (5, 6)
      engine.setFoodForTesting(const GridPosition(5, 6));

      engine.tick();

      // Because food would be eaten, the snake must grow, meaning the tail does
      // NOT vacate. Thus, moving into (5, 6) is a self-collision!
      expect(engine.state, equals(GameState.gameOver));
      expect(engine.isGameOver, isTrue);
    });

    test('wrap-around self collision', () {
      // Long snake wrapped near edge
      engine.setSnakeForTesting(
        [
          const GridPosition(19, 5), // Head on right edge
          const GridPosition(18, 5),
          const GridPosition(17, 5),
          const GridPosition(0, 5), // Body already wrapped onto left edge
          const GridPosition(0, 6),
        ],
        direction: Direction.right,
      );

      // Moving right wraps to (0, 5), where body already is!
      engine.tick();

      expect(engine.state, equals(GameState.gameOver));
    });
  });
}
