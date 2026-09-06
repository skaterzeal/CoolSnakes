import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../constants/lcd_colors.dart';
import '../engine/snake_engine.dart';
import '../models/direction.dart';
import '../rendering/lcd_canvas_painter.dart';

/// Flame game coordinating tick intervals, user input, and LCD canvas rendering.
class CoolSnakeGame extends FlameGame with KeyboardEvents {
  final SnakeEngine engine;
  LcdPalette palette;
  bool lcdEffectsEnabled;

  double _tickAccumulator = 0.0;

  CoolSnakeGame({
    required this.engine,
    required this.palette,
    required this.lcdEffectsEnabled,
  });

  @override
  Color backgroundColor() => palette.background;

  @override
  void update(double dt) {
    super.update(dt);

    if (!engine.isPlaying) {
      _tickAccumulator = 0.0;
      return;
    }

    final tickIntervalSec = engine.speed.intervalMs / 1000.0;
    _tickAccumulator += dt;

    // Prevent multi-tick cascade if app was backgrounded or experienced a frame hitch
    if (_tickAccumulator > tickIntervalSec * 2) {
      _tickAccumulator = tickIntervalSec * 2;
    }

    while (_tickAccumulator >= tickIntervalSec) {
      engine.tick();
      _tickAccumulator -= tickIntervalSec;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final painter = LcdCanvasPainter(
      engine: engine,
      palette: palette,
      lcdEffectsEnabled: lcdEffectsEnabled,
    );

    painter.paint(canvas, size.toSize());
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      engine.changeDirection(Direction.up);
      return KeyEventResult.handled;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      engine.changeDirection(Direction.down);
      return KeyEventResult.handled;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      engine.changeDirection(Direction.left);
      return KeyEventResult.handled;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      engine.changeDirection(Direction.right);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
