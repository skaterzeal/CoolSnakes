import 'package:flutter/material.dart';
import '../app/lcd_bezel.dart';
import '../constants/lcd_colors.dart';
import '../game/models/boundary_mode.dart';
import '../game/models/control_mode.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';

/// Settings screen for configuring audio, haptics, controls mode, LCD effects, and palette.
class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  final AudioService audio;
  final HapticsService haptics;
  final VoidCallback onPaletteChanged;

  const SettingsScreen({
    super.key,
    required this.storage,
    required this.audio,
    required this.haptics,
    required this.onPaletteChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _haptics;
  late ControlMode _controlMode;
  late BoundaryMode _boundaryMode;
  late bool _lcdEffects;
  late int _paletteIndex;

  LcdPalette get _palette => LcdColors.palettes[
      _paletteIndex.clamp(0, LcdColors.palettes.length - 1)];

  @override
  void initState() {
    super.initState();
    _sound = widget.storage.soundEnabled;
    _haptics = widget.storage.hapticsEnabled;
    _controlMode = widget.storage.controlMode;
    _boundaryMode = widget.storage.boundaryMode;
    _lcdEffects = widget.storage.lcdEffectsEnabled;
    _paletteIndex = widget.storage.paletteIndex;
  }

  void _toggleSound() async {
    setState(() => _sound = !_sound);
    await widget.storage.setSoundEnabled(_sound);
    widget.audio.playMenuClick();
    widget.haptics.click();
  }

  void _toggleHaptics() async {
    setState(() => _haptics = !_haptics);
    await widget.storage.setHapticsEnabled(_haptics);
    widget.audio.playMenuClick();
    widget.haptics.click();
  }

  void _toggleControls() async {
    final next = _controlMode == ControlMode.swipe
        ? ControlMode.buttons
        : ControlMode.swipe;
    setState(() => _controlMode = next);
    await widget.storage.setControlMode(next);
    widget.audio.playMenuClick();
    widget.haptics.click();
  }

  void _toggleBoundaryMode() async {
    final next = _boundaryMode == BoundaryMode.wrap
        ? BoundaryMode.border
        : BoundaryMode.wrap;
    setState(() => _boundaryMode = next);
    await widget.storage.setBoundaryMode(next);
    widget.audio.playMenuClick();
    widget.haptics.click();
  }

  void _toggleLcdEffects() async {
    setState(() => _lcdEffects = !_lcdEffects);
    await widget.storage.setLcdEffectsEnabled(_lcdEffects);
    widget.audio.playMenuClick();
    widget.haptics.click();
  }

  void _cyclePalette() async {
    final next = (_paletteIndex + 1) % LcdColors.palettes.length;
    setState(() => _paletteIndex = next);
    await widget.storage.setPaletteIndex(next);
    widget.audio.playMenuClick();
    widget.haptics.click();
    widget.onPaletteChanged();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LcdBezel(
                palette: palette,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SETTINGS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          color: palette.pixels,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(height: 2.0, color: palette.pixels),
                      const SizedBox(height: 10.0),
                      _SettingRow(
                        title: 'SOUND',
                        value: _sound ? 'ON' : 'OFF',
                        onTap: _toggleSound,
                        palette: palette,
                      ),
                      _SettingRow(
                        title: 'HAPTICS',
                        value: _haptics ? 'ON' : 'OFF',
                        onTap: _toggleHaptics,
                        palette: palette,
                      ),
                      _SettingRow(
                        title: 'BOUNDS',
                        value: _boundaryMode.label,
                        onTap: _toggleBoundaryMode,
                        palette: palette,
                      ),
                      _SettingRow(
                        title: 'CONTROLS',
                        value: _controlMode.label,
                        onTap: _toggleControls,
                        palette: palette,
                      ),
                      _SettingRow(
                        title: 'LCD FX',
                        value: _lcdEffects ? 'ON' : 'OFF',
                        onTap: _toggleLcdEffects,
                        palette: palette,
                      ),
                      _SettingRow(
                        title: 'THEME',
                        value: palette.name.toUpperCase(),
                        onTap: _cyclePalette,
                        palette: palette,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: GestureDetector(
                onTap: () {
                  widget.audio.playMenuClick();
                  widget.haptics.click();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: palette.bezel,
                    borderRadius: BorderRadius.circular(24.0),
                    border:
                        Border.all(color: palette.bezelHighlight, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'BACK',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      letterSpacing: 1.5,
                      color: palette.background,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;
  final LcdPalette palette;

  const _SettingRow({
    required this.title,
    required this.value,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: palette.pixels,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                border: Border.all(color: palette.pixels, width: 1.5),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: palette.pixels,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
