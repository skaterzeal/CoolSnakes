import 'dart:collection';
import '../models/direction.dart';

/// FIFO input buffer for snake directional inputs.
///
/// Prevents illegal 180-degree reversals and handles rapid swipes/key presses
/// by queuing up to [maxBufferSize] valid subsequent directions.
class InputBuffer {
  final int maxBufferSize;
  final Queue<Direction> _queue = Queue<Direction>();

  InputBuffer({this.maxBufferSize = 2});

  /// The number of directions currently queued.
  int get length => _queue.length;

  /// Checks if the buffer has any queued directions.
  bool get isNotEmpty => _queue.isNotEmpty;

  /// Clears all buffered inputs.
  void clear() {
    _queue.clear();
  }

  /// Attempts to queue [direction] based on the current movement direction [currentDirection].
  ///
  /// Returns `true` if the direction was successfully queued, or `false` if it was
  /// rejected (e.g. 180-degree reversal, identical to latest queued direction, or buffer full).
  bool addInput(Direction direction, Direction currentDirection) {
    if (_queue.length >= maxBufferSize) {
      return false;
    }

    // The reference direction to check against is the last queued direction,
    // or the current movement direction if the queue is empty.
    final referenceDirection =
        _queue.isNotEmpty ? _queue.last : currentDirection;

    // Reject if identical or 180-degree opposite
    if (direction == referenceDirection ||
        direction.isOpposite(referenceDirection)) {
      return false;
    }

    _queue.addLast(direction);
    return true;
  }

  /// Pops the next direction from the buffer, or returns [currentDirection] if empty.
  Direction popNext(Direction currentDirection) {
    if (_queue.isNotEmpty) {
      return _queue.removeFirst();
    }
    return currentDirection;
  }
}
