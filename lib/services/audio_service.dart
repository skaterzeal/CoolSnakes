import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// Procedural retro electronic buzzer audio synthesizer and player.
///
/// Generates 100% original square-wave buzzer PCM audio in memory.
/// Zero external audio files, zero network, zero copyrighted ringtones.
class AudioService {
  final bool Function() isEnabled;
  late final AudioPlayer _player;

  Uint8List? _menuClickWav;
  Uint8List? _foodEatenWav;
  Uint8List? _gameOverWav;
  Uint8List? _completionWav;

  AudioService({required this.isEnabled}) {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    _pregenerateSounds();
  }

  void dispose() {
    _player.dispose();
  }

  /// Synthesizes all required retro waveforms once into memory.
  void _pregenerateSounds() {
    _menuClickWav = _generateMenuClick();
    _foodEatenWav = _generateFoodEaten();
    _gameOverWav = _generateGameOver();
    _completionWav = _generateCompletion();
  }

  /// Plays menu click tick.
  Future<void> playMenuClick() async {
    if (!isEnabled() || _menuClickWav == null) return;
    await _playWav(_menuClickWav!);
  }

  /// Plays food eaten rising chirp.
  Future<void> playFoodEaten() async {
    if (!isEnabled() || _foodEatenWav == null) return;
    await _playWav(_foodEatenWav!);
  }

  /// Plays game over descending buzz.
  Future<void> playGameOver() async {
    if (!isEnabled() || _gameOverWav == null) return;
    await _playWav(_gameOverWav!);
  }

  /// Plays board completion fanfare.
  Future<void> playCompletion() async {
    if (!isEnabled() || _completionWav == null) return;
    await _playWav(_completionWav!);
  }

  Future<void> _playWav(Uint8List wavBytes) async {
    try {
      await _player.stop();
      await _player.play(BytesSource(wavBytes));
    } catch (_) {
      // Ignored if audio device unavailable (e.g. CI or mock environment)
    }
  }

  // ==================== PROCEDURAL WAV SYNTHESIZERS ====================

  /// Synthesizes a mono 16-bit PCM WAV file header and sample bytes.
  static Uint8List _buildWav({
    required int sampleRate,
    required List<int> samples,
  }) {
    final numSamples = samples.length;
    final subchunk2Size = numSamples * 2; // 16-bit = 2 bytes per sample
    final chunkSize = 36 + subchunk2Size;
    final byteData = ByteData(44 + subchunk2Size);

    // RIFF chunk descriptor
    _writeAscii(byteData, 0, 'RIFF');
    byteData.setUint32(4, chunkSize, Endian.little);
    _writeAscii(byteData, 8, 'WAVE');

    // fmt sub-chunk
    _writeAscii(byteData, 12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little); // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample

    // data sub-chunk
    _writeAscii(byteData, 36, 'data');
    byteData.setUint32(40, subchunk2Size, Endian.little);

    // Write 16-bit signed PCM samples
    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final sample = samples[i].clamp(-32768, 32767);
      byteData.setInt16(offset, sample, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  static void _writeAscii(ByteData data, int offset, String text) {
    for (int i = 0; i < text.length; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  /// Menu click: 25ms 2200Hz square wave with sharp exponential decay.
  static Uint8List _generateMenuClick() {
    const sampleRate = 22050;
    const durationSec = 0.025;
    final totalSamples = (sampleRate * durationSec).toInt();
    const frequency = 2200.0;
    const amplitude = 9000.0;

    final samples = List<int>.filled(totalSamples, 0);
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final decay = (1.0 - (i / totalSamples));
      final square = ((t * frequency * 2).floor() % 2 == 0) ? 1.0 : -1.0;
      samples[i] = (square * amplitude * decay).toInt();
    }

    return _buildWav(sampleRate: sampleRate, samples: samples);
  }

  /// Food eaten: 80ms ascending 2-step chirp (880Hz -> 1760Hz).
  static Uint8List _generateFoodEaten() {
    const sampleRate = 22050;
    const durationSec = 0.080;
    final totalSamples = (sampleRate * durationSec).toInt();
    const amplitude = 11000.0;

    final samples = List<int>.filled(totalSamples, 0);
    final halfSamples = totalSamples ~/ 2;

    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final freq = (i < halfSamples) ? 880.0 : 1760.0;
      final decay = 1.0 - (0.4 * (i / totalSamples));
      final square = ((t * freq * 2).floor() % 2 == 0) ? 1.0 : -1.0;
      samples[i] = (square * amplitude * decay).toInt();
    }

    return _buildWav(sampleRate: sampleRate, samples: samples);
  }

  /// Game over: 260ms descending buzzy tone (360Hz -> 100Hz with buzz modulation).
  static Uint8List _generateGameOver() {
    const sampleRate = 22050;
    const durationSec = 0.260;
    final totalSamples = (sampleRate * durationSec).toInt();
    const amplitude = 12000.0;

    final samples = List<int>.filled(totalSamples, 0);
    double phase = 0.0;

    for (int i = 0; i < totalSamples; i++) {
      final progress = i / totalSamples;
      // Frequency slides down from 360 to 90 Hz
      final freq = 360.0 - (270.0 * progress);
      phase += 2 * pi * freq / sampleRate;

      // Square wave with harmonic buzz
      final square = (sin(phase) >= 0) ? 1.0 : -1.0;
      final subHarmonic = (sin(phase * 0.5) >= 0) ? 0.3 : -0.3;
      final decay = (1.0 - (progress * 0.7));

      samples[i] = ((square + subHarmonic) * amplitude * 0.7 * decay).toInt();
    }

    return _buildWav(sampleRate: sampleRate, samples: samples);
  }

  /// Board completion: 600ms triumphant 4-note ascending fanfare (D5, F#5, A5, D6).
  static Uint8List _generateCompletion() {
    const sampleRate = 22050;
    const durationSec = 0.600;
    final totalSamples = (sampleRate * durationSec).toInt();
    const amplitude = 12000.0;

    final notes = [587.33, 739.99, 880.00, 1174.66];
    final samples = List<int>.filled(totalSamples, 0);
    final samplesPerNote = totalSamples ~/ 4;

    for (int i = 0; i < totalSamples; i++) {
      final noteIndex = (i ~/ samplesPerNote).clamp(0, 3);
      final freq = notes[noteIndex];
      final noteProgress = (i % samplesPerNote) / samplesPerNote;
      final decay = 1.0 - (noteProgress * 0.3);
      final t = i / sampleRate;

      final square = ((t * freq * 2).floor() % 2 == 0) ? 1.0 : -1.0;
      samples[i] = (square * amplitude * decay).toInt();
    }

    return _buildWav(sampleRate: sampleRate, samples: samples);
  }
}
