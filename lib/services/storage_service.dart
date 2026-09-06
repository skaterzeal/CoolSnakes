import 'package:shared_preferences/shared_preferences.dart';
import '../game/models/boundary_mode.dart';
import '../game/models/control_mode.dart';
import '../game/models/game_speed.dart';

/// Local storage service managing persistence via SharedPreferences.
class StorageService {
  static const String _keyHighScore = 'cool_snake_high_score';
  static const String _keyTopScores = 'cool_snake_top_scores';
  static const String _keySpeed = 'cool_snake_speed';
  static const String _keyControlMode = 'cool_snake_control_mode';
  static const String _keyBoundaryMode = 'cool_snake_boundary_mode';
  static const String _keySoundEnabled = 'cool_snake_sound_enabled';
  static const String _keyHapticsEnabled = 'cool_snake_haptics_enabled';
  static const String _keyLcdEffectsEnabled = 'cool_snake_lcd_effects_enabled';
  static const String _keyMaxScoreAchieved = 'cool_snake_max_score_achieved';
  static const String _keyPaletteIndex = 'cool_snake_palette_index';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // High Score & Top 3 Leaderboard
  int get highScore => topScores.isNotEmpty ? topScores.first : 0;

  List<int> get topScores {
    final rawList = _prefs.getStringList(_keyTopScores);
    if (rawList != null && rawList.isNotEmpty) {
      final parsed = rawList.map((e) => int.tryParse(e) ?? 0).toList();
      while (parsed.length < 3) {
        parsed.add(0);
      }
      return parsed.take(3).toList();
    }
    final oldHigh = _prefs.getInt(_keyHighScore) ?? 0;
    return [oldHigh, 0, 0];
  }

  Future<bool> saveScore(int score) async {
    if (score <= 0) return false;
    final current = List<int>.from(topScores);
    current.add(score);
    current.sort((a, b) => b.compareTo(a));
    final top3 = current.take(3).toList();

    await _prefs.setStringList(
      _keyTopScores,
      top3.map((s) => s.toString()).toList(),
    );
    await _prefs.setInt(_keyHighScore, top3.first);
    return top3.contains(score);
  }

  Future<bool> saveHighScore(int score) async {
    return await saveScore(score);
  }

  // Selected Speed
  GameSpeed get speed {
    final val = _prefs.getString(_keySpeed) ?? GameSpeed.normal.name;
    return GameSpeed.values.firstWhere(
      (s) => s.name == val,
      orElse: () => GameSpeed.normal,
    );
  }

  Future<bool> setSpeed(GameSpeed speed) async {
    return await _prefs.setString(_keySpeed, speed.name);
  }

  // Control Mode
  ControlMode get controlMode {
    final val = _prefs.getString(_keyControlMode) ?? ControlMode.swipe.name;
    return ControlMode.values.firstWhere(
      (c) => c.name == val,
      orElse: () => ControlMode.swipe,
    );
  }

  Future<bool> setControlMode(ControlMode mode) async {
    return await _prefs.setString(_keyControlMode, mode.name);
  }

  // Boundary Mode (WRAP / BORDER)
  BoundaryMode get boundaryMode {
    final val = _prefs.getString(_keyBoundaryMode) ?? BoundaryMode.wrap.name;
    return BoundaryMode.values.firstWhere(
      (b) => b.name == val,
      orElse: () => BoundaryMode.wrap,
    );
  }

  Future<bool> setBoundaryMode(BoundaryMode mode) async {
    return await _prefs.setString(_keyBoundaryMode, mode.name);
  }

  // Sound Setting
  bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;

  Future<bool> setSoundEnabled(bool enabled) async {
    return await _prefs.setBool(_keySoundEnabled, enabled);
  }

  // Haptics Setting
  bool get hapticsEnabled => _prefs.getBool(_keyHapticsEnabled) ?? true;

  Future<bool> setHapticsEnabled(bool enabled) async {
    return await _prefs.setBool(_keyHapticsEnabled, enabled);
  }

  // LCD Effects Setting
  bool get lcdEffectsEnabled => _prefs.getBool(_keyLcdEffectsEnabled) ?? true;

  Future<bool> setLcdEffectsEnabled(bool enabled) async {
    return await _prefs.setBool(_keyLcdEffectsEnabled, enabled);
  }

  // Max Score Achieved Flag
  bool get hasAchievedMaxScore =>
      _prefs.getBool(_keyMaxScoreAchieved) ?? false;

  Future<bool> setMaxScoreAchieved(bool achieved) async {
    return await _prefs.setBool(_keyMaxScoreAchieved, achieved);
  }

  // Palette Index
  int get paletteIndex => _prefs.getInt(_keyPaletteIndex) ?? 0;

  Future<bool> setPaletteIndex(int index) async {
    return await _prefs.setInt(_keyPaletteIndex, index);
  }
}
