import 'package:flutter/material.dart';
import '../../constants/lcd_colors.dart';

/// Applies authentic early-2000s monochrome LCD physical screen effects.
class LcdEffects {
  /// Renders subtle pixel matrix lines over the canvas.
  static void renderMatrixGrid(
    Canvas canvas,
    Size size,
    LcdPalette palette, {
    double cellSize = 2.0,
  }) {
    final linePaint = Paint()
      ..color = palette.pixels.withValues(alpha: 0.04)
      ..strokeWidth = 0.2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false;

    // Vertical matrix lines
    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Horizontal matrix lines
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  /// Renders subtle physical glass reflection and shadow over the upscaled display.
  static void renderScreenGlass(
    Canvas canvas,
    Rect rect,
  ) {
    // Inset border shadow (LCD screen depth)
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.12),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, shadowPaint);

    // Subtle diagonal top glare
    final glarePath = Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left + rect.width * 0.45, rect.top)
      ..lineTo(rect.left, rect.top + rect.height * 0.5)
      ..close();

    final glarePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(rect);

    canvas.drawPath(glarePath, glarePaint);
  }
}
