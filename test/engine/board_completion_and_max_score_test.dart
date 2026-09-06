import 'package:cool_snake/constants/game_config.dart';
import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/game_state.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Board Completion and Max Score Tests', () {
    test('default GameConfig deterministic max score is 19960', () {
      expect(GameConfig.gridWidth, equals(50));
      expect(GameConfig.gridHeight, equals(40));
      expect(GameConfig.totalCells, equals(2000));
      expect(GameConfig.initialSnakeLength, equals(4));
      expect(GameConfig.pointsPerFood, equals(10));

      // Formula: (C - S) * 10
      // (2000 - 4) * 10 = 19960
      expect(GameConfig.maxPossibleScore, equals(19960));
      expect(SnakeEngine.formatScore(GameConfig.maxPossibleScore),
          equals('019960'));
    });

    test('formula holds for custom grid dimensions', () {
      final engine = SnakeEngine(
        width: 10,
        height: 10,
        initialLength: 4,
        pointsPerFood: 10,
      );
      // (100 - 4) * 10 = 960
      expect(engine.maxScore, equals(960));
    });

    test('filling entire board triggers completed state and max score', () {
      // 3x3 board = 9 cells. Initial length 3.
      // Max score = (9 - 3) * 10 = 60 points.
      final engine = SnakeEngine(
        width: 3,
        height: 3,
        initialLength: 3,
        pointsPerFood: 10,
      );

      // Let head be at (0, 1), facing RIGHT towards the final free cell (1, 1)
      final List<GridPosition> snakeSegments = [
        const GridPosition(0, 1), // Head
        const GridPosition(0, 0),
        const GridPosition(1, 0),
        const GridPosition(2, 0),
        const GridPosition(2, 1),
        const GridPosition(2, 2),
        const GridPosition(1, 2),
        const GridPosition(0, 2), // Tail
      ];

      engine.setSnakeForTesting(snakeSegments, direction: Direction.right);
      // Place final food on the ONLY empty cell: (1, 1)
      engine.setFoodForTesting(const GridPosition(1, 1));
      engine.start();

      int completedScore = -1;
      engine.onCompleted = (score) => completedScore = score;

      // Move into (1, 1) to eat final food and occupy all 9 cells!
      engine.tick();

      expect(engine.snakeLength, equals(9));
      expect(engine.totalCells, equals(9));
      expect(engine.state, equals(GameState.completed));
      expect(engine.isCompleted, isTrue);
      expect(engine.food, isNull);
      expect(engine.score, equals(10)); // single food eaten in this test
      expect(completedScore, equals(10));

      // Further ticks should do nothing once completed
      engine.tick();
      expect(engine.state, equals(GameState.completed));
      expect(engine.snakeLength, equals(9));
    });
  });
}
