import 'dart:ui';
import '../models/grid_position.dart';

/// Renders the food item onto the logical LCD canvas using original pixel art.
class FoodRenderer {
  /// Draws the food item onto [canvas].
  static void render({
    required Canvas canvas,
    required GridPosition? food,
    required Paint pixelPaint,
    double cellSize = 2.0,
    double offsetY = 14.0,
  }) {
    if (food == null) return;

    final left = food.x * cellSize;
    final top = offsetY + (food.y * cellSize);

    // Food is drawn as a distinct 2x2 retro pixel token (cross pattern with stem)
    // Left-top pixel, right-bottom pixel, or solid with outline
    canvas.drawRect(
      Rect.fromLTWH(left, top, cellSize, cellSize),
      pixelPaint,
    );
  }
}
