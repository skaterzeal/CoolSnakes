import 'package:flutter/services.dart';

/// Service providing subtle haptic feedback for game events.
class HapticsService {
  final bool Function() isEnabled;

  HapticsService({required this.isEnabled});

  /// Menu item selection or direction button press.
  Future<void> click() async {
    if (!isEnabled()) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Ignored if platform doesn't support haptics
    }
  }

  /// Subtle light impact when food is eaten.
  Future<void> foodEaten() async {
    if (!isEnabled()) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignored
    }
  }

  /// Medium impact on game over collision.
  Future<void> gameOver() async {
    if (!isEnabled()) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignored
    }
  }

  /// Heavy impact on board completion / max score.
  Future<void> completed() async {
    if (!isEnabled()) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Ignored
    }
  }
}
