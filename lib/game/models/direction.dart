/// Cardinal directions supported by the snake engine.
enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  final int dx;
  final int dy;

  const Direction(this.dx, this.dy);

  /// Checks whether [other] is the exact opposite of this direction (180-degree reversal).
  bool isOpposite(Direction other) {
    return (dx == -other.dx && dy == 0 && other.dy == 0) ||
        (dy == -other.dy && dx == 0 && other.dx == 0);
  }

  /// Returns the opposite direction.
  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }
}
