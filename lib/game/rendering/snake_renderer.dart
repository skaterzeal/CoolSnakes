import 'dart:ui';
import '../models/direction.dart';
import '../models/grid_position.dart';

/// Renders the snake onto the logical LCD canvas using original geometric pixel art,
/// with an authentic retro directional snake head, contrasting eyes, articulated body scales,
/// and a tapering tail.
class SnakeRenderer {
  /// Renders all snake segments onto [canvas] with [pixelPaint].
  ///
  /// [offsetY] offsets the play area below the HUD.
  /// [eyePaint] draws contrasting retro LCD eyes on the head.
  static void render({
    required Canvas canvas,
    required List<GridPosition> snake,
    required Direction direction,
    required Paint pixelPaint,
    Paint? eyePaint,
    double cellSize = 2.0,
    double offsetY = 14.0,
  }) {
    if (snake.isEmpty) return;

    final eye = eyePaint ??
        (Paint()
          ..color = const Color(0xFFB5CB38)
          ..style = PaintingStyle.fill
          ..isAntiAlias = false);

    // 1. Draw body and tail segments
    for (int i = snake.length - 1; i >= 1; i--) {
      final pos = snake[i];
      final isTail = (i == snake.length - 1);
      final left = pos.x * cellSize;
      final top = offsetY + (pos.y * cellSize);

      if (isTail && snake.length > 2) {
        // Tapered tail: slightly smaller centered pixel block
        canvas.drawRect(
          Rect.fromLTWH(left + 0.3, top + 0.3, cellSize - 0.6, cellSize - 0.6),
          pixelPaint,
        );
      } else {
        // Articulated body segment with subtle retro scale texture
        canvas.drawRect(
          Rect.fromLTWH(left, top, cellSize, cellSize),
          pixelPaint,
        );
        // Subtle center scale dot to give articulated vertebra appearance
        canvas.drawRect(
          Rect.fromLTWH(left + 0.5, top + 0.5, 1.0, 1.0),
          pixelPaint,
        );
      }
    }

    // 2. Draw head segment with directional morphology and eyes
    final head = snake.first;
    final headLeft = head.x * cellSize;
    final headTop = offsetY + (head.y * cellSize);

    // Main head block
    canvas.drawRect(
      Rect.fromLTWH(headLeft, headTop, cellSize, cellSize),
      pixelPaint,
    );

    // Directional snout & contrasting eyes
    switch (direction) {
      case Direction.right:
        // Snout extension
        canvas.drawRect(
          Rect.fromLTWH(headLeft + cellSize, headTop + 0.4, 0.7, 1.2),
          pixelPaint,
        );
        // Top and bottom eyes
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.8, headTop + 0.2, 0.6, 0.6),
          eye,
        );
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.8, headTop + 1.2, 0.6, 0.6),
          eye,
        );
        break;

      case Direction.left:
        // Snout extension
        canvas.drawRect(
          Rect.fromLTWH(headLeft - 0.7, headTop + 0.4, 0.7, 1.2),
          pixelPaint,
        );
        // Top and bottom eyes
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.6, headTop + 0.2, 0.6, 0.6),
          eye,
        );
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.6, headTop + 1.2, 0.6, 0.6),
          eye,
        );
        break;

      case Direction.up:
        // Snout extension
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.4, headTop - 0.7, 1.2, 0.7),
          pixelPaint,
        );
        // Left and right eyes
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.2, headTop + 0.6, 0.6, 0.6),
          eye,
        );
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 1.2, headTop + 0.6, 0.6, 0.6),
          eye,
        );
        break;

      case Direction.down:
        // Snout extension
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.4, headTop + cellSize, 1.2, 0.7),
          pixelPaint,
        );
        // Left and right eyes
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 0.2, headTop + 0.8, 0.6, 0.6),
          eye,
        );
        canvas.drawRect(
          Rect.fromLTWH(headLeft + 1.2, headTop + 0.8, 0.6, 0.6),
          eye,
        );
        break;
    }
  }
}
