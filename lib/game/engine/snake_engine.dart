// ignore_for_file: prefer_initializing_formals

import 'dart:math';
import '../../constants/game_config.dart';
import '../models/boundary_mode.dart';
import '../models/direction.dart';
import '../models/game_speed.dart';
import '../models/game_state.dart';
import '../models/grid_position.dart';
import 'input_buffer.dart';

/// Callback signatures for engine events.
typedef EngineFoodCallback = void Function(int newScore);
typedef EngineGameOverCallback = void Function(int finalScore);
typedef EngineCompletedCallback = void Function(int finalScore);

/// Pure Dart Snake Engine.
///
/// Contains NO Flutter widget logic. Fully deterministic and testable.
class SnakeEngine {
  final int width;
  final int height;
  final int initialLength;
  final int pointsPerFood;
  final Random _random;

  GameSpeed _speed;
  BoundaryMode _boundaryMode;
  late GameState _state;
  late Direction _currentDirection;
  final InputBuffer _inputBuffer = InputBuffer();

  final List<GridPosition> _snake = [];
  GridPosition? _food;
  int _score = 0;

  // Event callbacks
  EngineFoodCallback? onFoodEaten;
  EngineGameOverCallback? onGameOver;
  EngineCompletedCallback? onCompleted;

  SnakeEngine({
    this.width = GameConfig.gridWidth,
    this.height = GameConfig.gridHeight,
    this.initialLength = GameConfig.initialSnakeLength,
    this.pointsPerFood = GameConfig.pointsPerFood,
    GameSpeed speed = GameSpeed.normal,
    BoundaryMode boundaryMode = BoundaryMode.wrap,
    Random? random,
  })  : _speed = speed,
        _boundaryMode = boundaryMode,
        _random = random ?? Random() {
    reset();
  }

  // Getters
  int get totalCells => width * height;
  int get maxScore => (totalCells - initialLength) * pointsPerFood;
  GameSpeed get speed => _speed;
  BoundaryMode get boundaryMode => _boundaryMode;
  GameState get state => _state;
  Direction get currentDirection => _currentDirection;
  int get score => _score;
  List<GridPosition> get snake => List.unmodifiable(_snake);
  GridPosition get head => _snake.first;
  GridPosition? get food => _food;
  int get snakeLength => _snake.length;
  bool get isPlaying => _state == GameState.playing;
  bool get isGameOver => _state == GameState.gameOver;
  bool get isCompleted => _state == GameState.completed;

  /// Resets the game to initial ready state.
  void reset() {
    _state = GameState.ready;
    _score = 0;
    _currentDirection = Direction.right;
    _inputBuffer.clear();
    _snake.clear();

    // Place initial snake horizontally near center, facing RIGHT
    final startX = width ~/ 2;
    final startY = height ~/ 2;

    for (int i = 0; i < initialLength; i++) {
      _snake.add(GridPosition(startX - i, startY));
    }

    _spawnFood();
  }

  /// Sets the game speed before starting a run.
  ///
  /// Speed remains strictly constant for the duration of the run.
  void setSpeed(GameSpeed speed) {
    if (_state == GameState.ready || _state == GameState.menu) {
      _speed = speed;
    }
  }

  /// Sets the boundary mode (wrap or border) before or between runs.
  void setBoundaryMode(BoundaryMode mode) {
    if (_state == GameState.ready || _state == GameState.menu) {
      _boundaryMode = mode;
    }
  }

  /// Starts the game run.
  void start() {
    if (_state == GameState.ready || _state == GameState.paused) {
      _state = GameState.playing;
    }
  }

  /// Pauses the game.
  void pause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
    }
  }

  /// Resumes the game from pause.
  void resume() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
    }
  }

  /// Handles direction inputs from swipe, buttons, or keyboard.
  ///
  /// Feeds the input into the FIFO input buffer, preventing 180-degree reversals.
  bool changeDirection(Direction newDirection) {
    if (_state == GameState.ready) {
      _state = GameState.playing;
    }
    if (_state != GameState.playing) {
      return false;
    }
    return _inputBuffer.addInput(newDirection, _currentDirection);
  }

  /// Executes one discrete movement tick.
  ///
  /// 1. Read buffered direction
  /// 2. Calculate next head position
  /// 3. Apply boundary rules (wrap-around or border collision)
  /// 4. Test self collision (taking moving tail vacancy into account)
  /// 5. Insert new head
  /// 6. Check food
  /// 7. If food eaten: keep tail, increase score, generate next food;
  ///    otherwise: remove tail
  /// 8. Check board completion
  /// 9. Update game state
  void tick() {
    if (_state != GameState.playing) return;

    // 1. Read next buffered direction
    _currentDirection = _inputBuffer.popNext(_currentDirection);

    // 2. Calculate next head position
    final rawNextHead = _snake.first.translate(
      _currentDirection.dx,
      _currentDirection.dy,
    );

    // 3. Apply boundary rules
    final GridPosition nextHead;
    if (_boundaryMode == BoundaryMode.border) {
      if (rawNextHead.x < 0 ||
          rawNextHead.x >= width ||
          rawNextHead.y < 0 ||
          rawNextHead.y >= height) {
        _state = GameState.gameOver;
        onGameOver?.call(_score);
        return;
      }
      nextHead = rawNextHead;
    } else {
      nextHead = rawNextHead.wrapped(width, height);
    }

    // 6. Check if food would be eaten at nextHead
    final bool willEatFood = (_food != null && nextHead == _food);

    // 4. Test self collision
    // If food is eaten, snake grows -> tail does NOT vacate.
    // If food is NOT eaten, tail will be removed on this tick -> tail vacates!
    final int obstacleCount = willEatFood ? _snake.length : _snake.length - 1;
    bool selfCollision = false;

    for (int i = 0; i < obstacleCount; i++) {
      if (_snake[i] == nextHead) {
        selfCollision = true;
        break;
      }
    }

    if (selfCollision) {
      _state = GameState.gameOver;
      onGameOver?.call(_score);
      return;
    }

    // 5. Insert new head
    _snake.insert(0, nextHead);

    if (willEatFood) {
      // 7. Food eaten: keep tail, increment score, generate next food
      _score += pointsPerFood;
      _food = null;
      onFoodEaten?.call(_score);

      // 8. Check board completion (all cells occupied)
      if (_snake.length >= totalCells) {
        _state = GameState.completed;
        onCompleted?.call(_score);
        return;
      }

      _spawnFood();
    } else {
      // 7. Food not eaten: remove tail
      _snake.removeLast();
    }
  }

  /// Generates food on an empty cell.
  ///
  /// When free cells are scarce, explicitly computes available cells
  /// to ensure reliable and fast placement.
  /// If no empty cells remain, triggers the completed state.
  void _spawnFood() {
    final occupied = _snake.toSet();
    final freeCellCount = totalCells - occupied.length;

    if (freeCellCount <= 0) {
      _food = null;
      _state = GameState.completed;
      onCompleted?.call(_score);
      return;
    }

    // If board is mostly empty (> 25% free cells), try random sampling first for speed
    if (freeCellCount > (totalCells * 0.25)) {
      for (int i = 0; i < 64; i++) {
        final candidate = GridPosition(
          _random.nextInt(width),
          _random.nextInt(height),
        );
        if (!occupied.contains(candidate)) {
          _food = candidate;
          return;
        }
      }
    }

    // Otherwise, collect all empty cells and choose one uniformly at random
    final List<GridPosition> availableCells = [];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pos = GridPosition(x, y);
        if (!occupied.contains(pos)) {
          availableCells.add(pos);
        }
      }
    }

    if (availableCells.isEmpty) {
      _food = null;
      _state = GameState.completed;
      onCompleted?.call(_score);
      return;
    }

    _food = availableCells[_random.nextInt(availableCells.length)];
  }

  /// Manually force a food position (useful for unit tests).
  void setFoodForTesting(GridPosition pos) {
    _food = pos;
  }

  /// Manually set the snake body (useful for unit tests).
  void setSnakeForTesting(List<GridPosition> newSnake, {Direction? direction}) {
    _snake.clear();
    _snake.addAll(newSnake);
    if (direction != null) {
      _currentDirection = direction;
    }
  }

  /// Formats the score with zero-padding (e.g. 004910, 019960).
  static String formatScore(int score, {int digits = 6}) {
    return score.toString().padLeft(digits, '0');
  }
}
