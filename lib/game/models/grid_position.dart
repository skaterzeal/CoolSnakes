/// Immutable coordinate on the snake game grid.
class GridPosition {
  final int x;
  final int y;

  const GridPosition(this.x, this.y);

  /// Wrap-around calculation for grid boundaries.
  GridPosition wrapped(int width, int height) {
    final wrappedX = (x % width + width) % width;
    final wrappedY = (y % height + height) % height;
    return GridPosition(wrappedX, wrappedY);
  }

  /// Returns a new position translated by [dx] and [dy].
  GridPosition translate(int dx, int dy) {
    return GridPosition(x + dx, y + dy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ (y.hashCode << 16);

  @override
  String toString() => '($x, $y)';
}
