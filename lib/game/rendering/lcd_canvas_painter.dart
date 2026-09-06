import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/game_config.dart';
import '../../constants/lcd_colors.dart';
import '../../constants/pixel_font.dart';
import '../engine/snake_engine.dart';
import '../models/boundary_mode.dart';
import '../models/game_state.dart';
import 'food_renderer.dart';
import 'lcd_effects.dart';
import 'snake_renderer.dart';

/// CustomPainter rendering the logical LCD canvas and upscaling with sharp pixels.
class LcdCanvasPainter extends CustomPainter {
  final SnakeEngine engine;
  final LcdPalette palette;
  final bool lcdEffectsEnabled;

  LcdCanvasPainter({
    required this.engine,
    required this.palette,
    required this.lcdEffectsEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Calculate integer or uniform nearest-neighbor scale factor
    final scaleX = size.width / GameConfig.logicalWidth;
    final scaleY = size.height / GameConfig.logicalTotalHeight;
    final scale = min(scaleX, scaleY);

    final renderedWidth = GameConfig.logicalWidth * scale;
    final renderedHeight = GameConfig.logicalTotalHeight * scale;
    final offsetX = (size.width - renderedWidth) / 2;
    final offsetY = (size.height - renderedHeight) / 2;

    // 1. Fill physical display background
    final bgPaint = Paint()
      ..color = palette.background
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Save canvas state and apply scale & offset for logical coordinate rendering
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Pixel paint setup: STRICTLY non-antialiased for razor-sharp LCD pixels
    final pixelPaint = Paint()
      ..color = palette.pixels
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    final eyePaint = Paint()
      ..color = palette.background
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    // 2. Render LCD HUD
    _renderHud(canvas, pixelPaint);

    // 2b. If Border mode, draw physical retro LCD border around play area
    if (engine.boundaryMode == BoundaryMode.border) {
      final borderPaint = Paint()
        ..color = palette.pixels
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..isAntiAlias = false;

      canvas.drawRect(
        const Rect.fromLTWH(
          0.5,
          GameConfig.logicalHudHeight - 1.5,
          GameConfig.logicalWidth - 1.0,
          GameConfig.logicalPlayHeight + 1.0,
        ),
        borderPaint,
      );
    }

    // 3. Render Food
    FoodRenderer.render(
      canvas: canvas,
      food: engine.food,
      pixelPaint: pixelPaint,
      cellSize: GameConfig.cellPixelSize,
      offsetY: GameConfig.logicalHudHeight.toDouble(),
    );

    // 4. Render Snake with directional head and contrasting eyes
    SnakeRenderer.render(
      canvas: canvas,
      snake: engine.snake,
      direction: engine.currentDirection,
      pixelPaint: pixelPaint,
      eyePaint: eyePaint,
      cellSize: GameConfig.cellPixelSize,
      offsetY: GameConfig.logicalHudHeight.toDouble(),
    );

    // 5. Render LCD matrix grid effect (on logical scale)
    if (lcdEffectsEnabled) {
      LcdEffects.renderMatrixGrid(
        canvas,
        const Size(
          GameConfig.logicalWidth + 0.0,
          GameConfig.logicalTotalHeight + 0.0,
        ),
        palette,
        cellSize: 1.0,
      );
    }

    // 6. Render On-Screen State Banners (Ready, Paused)
    _renderStateBanner(canvas, pixelPaint);

    canvas.restore();

    // 7. Render physical glass reflection & shadow over the screen
    if (lcdEffectsEnabled) {
      LcdEffects.renderScreenGlass(
        canvas,
        Rect.fromLTWH(offsetX, offsetY, renderedWidth, renderedHeight),
      );
    }
  }

  /// Minimal retro HUD: Zero-padded score + divider line.
  /// Example:
  /// 004910
  /// ──────────────────────
  void _renderHud(Canvas canvas, Paint pixelPaint) {
    // Score string: 6 digits zero-padded
    final scoreStr = SnakeEngine.formatScore(engine.score);
    PixelFont.drawText(
      canvas,
      scoreStr,
      2.0,
      3.0,
      pixelPaint,
      pixelSize: 1.0,
      charSpacing: 1.0,
    );

    // Speed and Boundary mode indicator on right of HUD (e.g. "NORM WRAP" or "FAST WALL")
    final modeLabel =
        engine.boundaryMode == BoundaryMode.border ? 'WALL' : 'WRAP';
    final infoLabel = '${engine.speed.label} $modeLabel';
    final infoWidth = PixelFont.measureWidth(infoLabel, pixelSize: 1.0);
    PixelFont.drawText(
      canvas,
      infoLabel,
      GameConfig.logicalWidth - infoWidth - 2.0,
      3.0,
      pixelPaint,
      pixelSize: 1.0,
      charSpacing: 1.0,
    );

    // Horizontal divider line
    final linePaint = Paint()
      ..color = palette.pixels
      ..strokeWidth = 1.0
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(
        0,
        GameConfig.logicalHudHeight - 2.0,
        GameConfig.logicalWidth + 0.0,
        1.0,
      ),
      linePaint,
    );
  }

  /// Banners for in-canvas state indicators (READY, PAUSED).
  void _renderStateBanner(Canvas canvas, Paint pixelPaint) {
    if (engine.state == GameState.ready) {
      const text = 'READY!';
      final textWidth = PixelFont.measureWidth(text, pixelSize: 1.0);
      final x = (GameConfig.logicalWidth - textWidth) / 2;
      const y = GameConfig.logicalHudHeight + 35.0;

      // Small background clearance for text readability
      final bgClear = Paint()
        ..color = palette.background
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(x - 3, y - 2, textWidth + 6, 9),
        bgClear,
      );

      PixelFont.drawText(canvas, text, x, y, pixelPaint, pixelSize: 1.0);
    } else if (engine.state == GameState.paused) {
      const text = 'PAUSED';
      final textWidth = PixelFont.measureWidth(text, pixelSize: 1.0);
      final x = (GameConfig.logicalWidth - textWidth) / 2;
      const y = GameConfig.logicalHudHeight + 35.0;

      final bgClear = Paint()
        ..color = palette.background
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(x - 3, y - 2, textWidth + 6, 9),
        bgClear,
      );

      PixelFont.drawText(canvas, text, x, y, pixelPaint, pixelSize: 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant LcdCanvasPainter oldDelegate) {
    return true; // Continuously repaints as engine ticks
  }
}
