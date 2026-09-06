import 'dart:math';
import 'package:cool_snake/game/engine/snake_engine.dart';
import 'package:cool_snake/game/models/direction.dart';
import 'package:cool_snake/game/models/grid_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Food Placement Tests', () {
    test('food is never spawned on the snake body or outside grid', () {
      for (int trial = 0; trial < 50; trial++) {
        final engine = SnakeEngine(
          width: 10,
          height: 10,
          initialLength: 5,
          random: Random(trial),
        );
        expect(engine.food, isNotNull);
        expect(engine.food!.x, inInclusiveRange(0, 9));
        expect(engine.food!.y, inInclusiveRange(0, 9));
        expect(engine.snake.contains(engine.food!), isFalse);
      }
    });

    test('scarce cells: spawns exactly on the remaining empty cell', () {
      // 4x4 grid = 16 cells.
      // We will place 14 snake segments.
      // Target food is at (3, 2).
      // The remaining empty cell will be (3, 3).
      final engine = SnakeEngine(width: 4, height: 4, initialLength: 3);

      // Construct a valid snake path ending with head at (2, 2) facing RIGHT
      final List<GridPosition> snakeSegments = [
        const GridPosition(2, 2), // Head, facing right towards food at (3, 2)
        const GridPosition(1, 2),
        const GridPosition(0, 2),
        const GridPosition(0, 1),
        const GridPosition(1, 1),
        const GridPosition(2, 1),
        const GridPosition(3, 1),
        const GridPosition(3, 0),
        const GridPosition(2, 0),
        const GridPosition(1, 0),
        const GridPosition(0, 0),
        const GridPosition(0, 3),
        const GridPosition(1, 3),
        const GridPosition(2, 3), // Tail
      ];

      // Total snake segments = 14.
      // Total grid cells = 16.
      // Empty cells: (3, 2) and (3, 3).
      expect(snakeSegments.length, equals(14));

      engine.setSnakeForTesting(snakeSegments, direction: Direction.right);
      // Place food at (3, 2) right in front of head
      engine.setFoodForTesting(const GridPosition(3, 2));
      engine.start();

      // Head moves into (3, 2), eats food, snake length becomes 15
      engine.tick();

      expect(engine.head, equals(const GridPosition(3, 2)));
      expect(engine.snakeLength, equals(15));
      // Food must now spawn on the ONLY remaining empty cell: (3, 3)
      expect(engine.food, equals(const GridPosition(3, 3)));
      expect(engine.snake.contains(engine.food!), isFalse);
    });
  });
}
