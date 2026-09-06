import '../../constants/game_config.dart';

/// Fixed selectable game speeds.
///
/// NOTE: The specification mandates that speeds must NEVER be called "levels",
/// and that the selected speed remains constant for the entire run.
enum GameSpeed {
  slow('SLOW', GameConfig.slowIntervalMs),
  normal('NORMAL', GameConfig.normalIntervalMs),
  fast('FAST', GameConfig.fastIntervalMs);

  final String label;
  final int intervalMs;

  const GameSpeed(this.label, this.intervalMs);

  Duration get stepDuration => Duration(milliseconds: intervalMs);
}
