/// Constants and default configuration for Cool Snake.
class GameConfig {
  /// Playable grid width in cells.
  static const int gridWidth = 50;

  /// Playable grid height in cells.
  static const int gridHeight = 40;

  /// Total playable cells on the board: 50 * 40 = 2000.
  static int get totalCells => gridWidth * gridHeight;

  /// Initial snake length in segments (Head + 3 body segments).
  static const int initialSnakeLength = 4;

  /// Points awarded per food item eaten.
  static const int pointsPerFood = 10;

  /// Deterministic maximum possible score: (C - S) * 10.
  /// (2000 - 4) * 10 = 19960.
  static int get maxPossibleScore =>
      (totalCells - initialSnakeLength) * pointsPerFood;

  /// Logical LCD canvas width in pixels.
  /// 50 cells * 2 pixels per cell = 100 logical pixels.
  static const int logicalWidth = 100;

  /// Logical LCD play area height in pixels.
  /// 40 cells * 2 pixels per cell = 80 logical pixels.
  static const int logicalPlayHeight = 80;

  /// Logical LCD HUD height in pixels.
  static const int logicalHudHeight = 14;

  /// Total logical LCD canvas height in pixels (HUD + Play Area).
  static const int logicalTotalHeight = logicalHudHeight + logicalPlayHeight; // 94px

  /// Pixel size per cell on the logical canvas.
  static const double cellPixelSize = 2.0;

  /// Movement tick intervals in milliseconds for each speed.
  static const int slowIntervalMs = 180;
  static const int normalIntervalMs = 130;
  static const int fastIntervalMs = 90;
}
