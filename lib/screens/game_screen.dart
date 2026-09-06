import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/lcd_bezel.dart';
import '../constants/game_config.dart';
import '../constants/lcd_colors.dart';
import '../game/engine/snake_engine.dart';
import '../game/flame/cool_snake_game.dart';
import '../game/models/control_mode.dart';
import '../game/models/direction.dart';
import '../game/models/game_state.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';

/// Gameplay Screen housing the LCD screen, swipe / retro D-pad controls,
/// Game Over modal, and Perfect Max Score completion modal.
class GameScreen extends StatefulWidget {
  final StorageService storage;
  final AudioService audio;
  final HapticsService haptics;

  const GameScreen({
    super.key,
    required this.storage,
    required this.audio,
    required this.haptics,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeEngine _engine;
  late CoolSnakeGame _game;
  Offset? _dragStart;
  bool _dragHandled = false;

  LcdPalette get _palette => LcdColors.palettes[
      widget.storage.paletteIndex.clamp(0, LcdColors.palettes.length - 1)];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _engine = SnakeEngine(
      width: GameConfig.gridWidth,
      height: GameConfig.gridHeight,
      initialLength: GameConfig.initialSnakeLength,
      pointsPerFood: GameConfig.pointsPerFood,
      speed: widget.storage.speed,
      boundaryMode: widget.storage.boundaryMode,
    );

    _engine.onFoodEaten = (score) {
      widget.audio.playFoodEaten();
      widget.haptics.foodEaten();
      if (score > widget.storage.highScore) {
        widget.storage.saveHighScore(score);
      }
      if (mounted) setState(() {});
    };

    _engine.onGameOver = (finalScore) async {
      widget.audio.playGameOver();
      widget.haptics.gameOver();
      await widget.storage.saveHighScore(finalScore);
      if (mounted) setState(() {});
    };

    _engine.onCompleted = (finalScore) async {
      widget.audio.playCompletion();
      widget.haptics.completed();
      await widget.storage.saveHighScore(finalScore);
      await widget.storage.setMaxScoreAchieved(true);
      if (mounted) setState(() {});
    };

    _game = CoolSnakeGame(
      engine: _engine,
      palette: _palette,
      lcdEffectsEnabled: widget.storage.lcdEffectsEnabled,
    );
  }

  void _onDirectionInput(Direction direction) {
    widget.haptics.click();
    _engine.changeDirection(direction);
    if (mounted) setState(() {});
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    _dragHandled = false;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dragHandled || _dragStart == null) return;

    final currentPos = details.localPosition;
    final dx = currentPos.dx - _dragStart!.dx;
    final dy = currentPos.dy - _dragStart!.dy;

    const threshold = 18.0;

    if (dx.abs() > threshold || dy.abs() > threshold) {
      if (dx.abs() > dy.abs()) {
        if (dx > 0) {
          _onDirectionInput(Direction.right);
        } else {
          _onDirectionInput(Direction.left);
        }
      } else {
        if (dy > 0) {
          _onDirectionInput(Direction.down);
        } else {
          _onDirectionInput(Direction.up);
        }
      }
      _dragHandled = true;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStart = null;
    _dragHandled = false;
  }

  void _restartGame() {
    widget.audio.playMenuClick();
    widget.haptics.click();
    setState(() {
      _engine.reset();
      _engine.start();
    });
  }

  void _returnToMenu() {
    widget.audio.playMenuClick();
    widget.haptics.click();
    Navigator.of(context).pop();
  }

  void _togglePause() {
    widget.audio.playMenuClick();
    widget.haptics.click();
    setState(() {
      if (_engine.state == GameState.playing) {
        _engine.pause();
      } else if (_engine.state == GameState.paused) {
        _engine.resume();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final isButtonsMode = widget.storage.controlMode == ControlMode.buttons;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;

            if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.keyW ||
                event.logicalKey == LogicalKeyboardKey.digit2 ||
                event.logicalKey == LogicalKeyboardKey.numpad2) {
              _onDirectionInput(Direction.up);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.keyS ||
                event.logicalKey == LogicalKeyboardKey.digit8 ||
                event.logicalKey == LogicalKeyboardKey.numpad8) {
              _onDirectionInput(Direction.down);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.keyA ||
                event.logicalKey == LogicalKeyboardKey.digit4 ||
                event.logicalKey == LogicalKeyboardKey.numpad4) {
              _onDirectionInput(Direction.left);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.keyD ||
                event.logicalKey == LogicalKeyboardKey.digit6 ||
                event.logicalKey == LogicalKeyboardKey.numpad6) {
              _onDirectionInput(Direction.right);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.keyP ||
                event.logicalKey == LogicalKeyboardKey.digit5 ||
                event.logicalKey == LogicalKeyboardKey.numpad5) {
              _togglePause();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                event.logicalKey == LogicalKeyboardKey.numpad1 ||
                event.logicalKey == LogicalKeyboardKey.digit3 ||
                event.logicalKey == LogicalKeyboardKey.numpad3 ||
                event.logicalKey == LogicalKeyboardKey.digit7 ||
                event.logicalKey == LogicalKeyboardKey.numpad7 ||
                event.logicalKey == LogicalKeyboardKey.digit9 ||
                event.logicalKey == LogicalKeyboardKey.numpad9) {
              widget.audio.playMenuClick();
              widget.haptics.click();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              _returnToMenu();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            children: [
              // Top control bar: Pause & Exit
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SmallBtn(
                      label: 'MENU',
                      onPressed: _returnToMenu,
                      palette: palette,
                    ),
                    Text(
                      'COOL SNAKE',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        letterSpacing: 2.0,
                        color: palette.background.withValues(alpha: 0.6),
                      ),
                    ),
                    _SmallBtn(
                      label: _engine.state == GameState.paused
                          ? 'RESUME'
                          : 'PAUSE',
                      onPressed: _togglePause,
                      palette: palette,
                    ),
                  ],
                ),
              ),

              // LCD Display with Bezel & Game canvas
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _handlePanStart,
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  onTap: () {
                    if (_engine.state == GameState.ready) {
                      _engine.start();
                      setState(() {});
                    } else if (_engine.state == GameState.paused) {
                      _engine.resume();
                      setState(() {});
                    }
                  },
                  child: LcdBezel(
                    palette: palette,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GameWidget(game: _game),
                        ),
                        // Tap prompt when ready
                        if (_engine.state == GameState.ready)
                          Positioned(
                            bottom: 12.0,
                            left: 0,
                            right: 0,
                            child: Text(
                              isButtonsMode
                                  ? 'PRESS 2,4,6,8 TO START'
                                  : 'SWIPE TO START',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: palette.pixels.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        // Game Over Overlay
                        if (_engine.isGameOver)
                          _GameOverOverlay(
                            score: _engine.score,
                            best: widget.storage.highScore,
                            palette: palette,
                            onPlayAgain: _restartGame,
                            onMenu: _returnToMenu,
                          ),
                        // Perfect Completion Overlay
                        if (_engine.isCompleted)
                          _CompletedOverlay(
                            score: _engine.score,
                            palette: palette,
                            onPlayAgain: _restartGame,
                            onMenu: _returnToMenu,
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Controls Area
              if (isButtonsMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _PhoneKeypad(
                    onDirection: _onDirectionInput,
                    onAction: _togglePause,
                    onKeyClick: () {
                      widget.audio.playMenuClick();
                      widget.haptics.click();
                    },
                    palette: palette,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'SWIPE ANYWHERE TO TURN',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: palette.background.withValues(alpha: 0.4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Game Over Overlay matching exact specification:
/// GAME OVER
/// SCORE xxxxxx
/// BEST xxxxxx
/// > AGAIN
///   MENU
class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int best;
  final LcdPalette palette;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  const _GameOverOverlay({
    required this.score,
    required this.best,
    required this.palette,
    required this.onPlayAgain,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background.withValues(alpha: 0.94),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 22.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                color: palette.pixels,
              ),
            ),
            const SizedBox(height: 8.0),
            Container(height: 2.0, color: palette.pixels),
            const SizedBox(height: 10.0),
            Text(
              'SCORE\n${SnakeEngine.formatScore(score)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: palette.pixels,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'BEST\n${SnakeEngine.formatScore(best)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: palette.pixels.withValues(alpha: 0.8),
              ),
            ),
            if (score >= best && score > 0) ...[
              const SizedBox(height: 4.0),
              Text(
                '* NEW BEST! *',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: palette.pixels,
                ),
              ),
            ],
            const SizedBox(height: 14.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModalBtn(
                  label: 'AGAIN',
                  onPressed: onPlayAgain,
                  palette: palette,
                ),
                const SizedBox(width: 16.0),
                _ModalBtn(
                  label: 'MENU',
                  onPressed: onMenu,
                  palette: palette,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Completion Overlay matching exact specification:
/// PERFECT!
/// MAX SCORE
/// 019960
/// > AGAIN
///   MENU
class _CompletedOverlay extends StatelessWidget {
  final int score;
  final LcdPalette palette;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  const _CompletedOverlay({
    required this.score,
    required this.palette,
    required this.onPlayAgain,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PERFECT!',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 24.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.5,
                color: palette.pixels,
              ),
            ),
            const SizedBox(height: 8.0),
            Container(height: 2.0, color: palette.pixels),
            const SizedBox(height: 10.0),
            Text(
              'MAX SCORE\n${SnakeEngine.formatScore(score)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 18.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: palette.pixels,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              '* BOARD COMPLETED *',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: palette.pixels,
              ),
            ),
            const SizedBox(height: 14.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModalBtn(
                  label: 'AGAIN',
                  onPressed: onPlayAgain,
                  palette: palette,
                ),
                const SizedBox(width: 16.0),
                _ModalBtn(
                  label: 'MENU',
                  onPressed: onMenu,
                  palette: palette,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final LcdPalette palette;

  const _ModalBtn({
    required this.label,
    required this.onPressed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: palette.pixels,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
            letterSpacing: 1.5,
            color: palette.background,
          ),
        ),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final LcdPalette palette;

  const _SmallBtn({
    required this.label,
    required this.onPressed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: palette.bezel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: palette.bezelHighlight, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            fontSize: 11.0,
            letterSpacing: 1.2,
            color: palette.background,
          ),
        ),
      ),
    );
  }
}

/// Retro Early-2000s Numeric Phone Keypad (3x3 grid: 1 to 9).
///
/// Keys 2 (UP), 4 (LEFT), 6 (RIGHT), 8 (DOWN) navigate the snake.
/// Key 5 triggers action / pause.
/// Keys 1, 3, 7, 9 produce authentic keypad click feedback.
class _PhoneKeypad extends StatelessWidget {
  final ValueChanged<Direction> onDirection;
  final VoidCallback onAction;
  final VoidCallback onKeyClick;
  final LcdPalette palette;

  const _PhoneKeypad({
    required this.onDirection,
    required this.onAction,
    required this.onKeyClick,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhoneKey(
              digit: '1',
              letters: ' . _ @ ',
              onPressed: onKeyClick,
              palette: palette,
            ),
            const SizedBox(width: 8.0),
            _PhoneKey(
              digit: '2 ▲',
              letters: 'ABC',
              isDirectional: true,
              onPressed: () => onDirection(Direction.up),
              palette: palette,
            ),
            const SizedBox(width: 8.0),
            _PhoneKey(
              digit: '3',
              letters: 'DEF',
              onPressed: onKeyClick,
              palette: palette,
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhoneKey(
              digit: '◄ 4',
              letters: 'GHI',
              isDirectional: true,
              onPressed: () => onDirection(Direction.left),
              palette: palette,
            ),
            const SizedBox(width: 8.0),
            _PhoneKey(
              digit: '5',
              letters: 'PAUSE',
              isDirectional: true,
              onPressed: onAction,
              palette: palette,
            ),
            const SizedBox(width: 8.0),
            _PhoneKey(
              digit: '6 ►',
              letters: 'MNO',
              isDirectional: true,
              onPressed: () => onDirection(Direction.right),
              palette: palette,
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PhoneKey(
              digit: '7',
              letters: 'PQRS',
              onPressed: onKeyClick,
              palette: palette,
            ),
            const SizedBox(width: 8.0),
            _PhoneKey(
              digit: '8 ▼',
              letters: 'TUV',
              isDirectional: true,
              onPressed: () => onDirection(Direction.down),
              palette: palette,
            ),
            const SizedBox(width: 8.0),
            _PhoneKey(
              digit: '9',
              letters: 'WXYZ',
              onPressed: onKeyClick,
              palette: palette,
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneKey extends StatefulWidget {
  final String digit;
  final String letters;
  final bool isDirectional;
  final VoidCallback onPressed;
  final LcdPalette palette;

  const _PhoneKey({
    required this.digit,
    required this.letters,
    this.isDirectional = false,
    required this.onPressed,
    required this.palette,
  });

  @override
  State<_PhoneKey> createState() => _PhoneKeyState();
}

class _PhoneKeyState extends State<_PhoneKey> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final isDir = widget.isDirectional;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: 68.0,
        height: 42.0,
        decoration: BoxDecoration(
          color: _isPressed
              ? palette.bezelHighlight.withValues(alpha: 0.9)
              : palette.bezel,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isDir
                ? palette.bezelHighlight
                : palette.bezelHighlight.withValues(alpha: 0.5),
            width: isDir ? 1.8 : 1.0,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 1.0,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 3.0,
                    offset: const Offset(0, 2.5),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.digit,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 15.0,
                fontWeight: isDir ? FontWeight.w900 : FontWeight.bold,
                color: palette.background,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              widget.letters,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 8.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: palette.background.withValues(alpha: isDir ? 0.8 : 0.55),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
