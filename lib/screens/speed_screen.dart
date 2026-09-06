import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/lcd_bezel.dart';
import '../constants/lcd_colors.dart';
import '../game/models/game_speed.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';

/// Speed selection screen.
///
/// NOTE: The specification strictly forbids calling speeds "levels".
/// Speeds remain constant for the entire run.
class SpeedScreen extends StatefulWidget {
  final StorageService storage;
  final AudioService audio;
  final HapticsService haptics;

  const SpeedScreen({
    super.key,
    required this.storage,
    required this.audio,
    required this.haptics,
  });

  @override
  State<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {
  late int _selectedIndex;

  final List<GameSpeed> _speeds = GameSpeed.values;

  LcdPalette get _palette => LcdColors.palettes[
      widget.storage.paletteIndex.clamp(0, LcdColors.palettes.length - 1)];

  @override
  void initState() {
    super.initState();
    final current = widget.storage.speed;
    _selectedIndex = _speeds.indexOf(current);
    if (_selectedIndex < 0) _selectedIndex = 1; // NORMAL
  }

  void _moveSelection(int delta) {
    widget.audio.playMenuClick();
    widget.haptics.click();
    setState(() {
      _selectedIndex =
          (_selectedIndex + delta + _speeds.length) % _speeds.length;
    });
  }

  void _selectSpeed(int index) {
    widget.audio.playMenuClick();
    widget.haptics.click();
    setState(() {
      _selectedIndex = index;
    });
    _saveAndBack();
  }

  void _saveAndBack() async {
    final selected = _speeds[_selectedIndex];
    await widget.storage.setSpeed(selected);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.keyW) {
              _moveSelection(-1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.keyS) {
              _moveSelection(1);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              _saveAndBack();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            children: [
              Expanded(
                child: LcdBezel(
                  palette: palette,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SPEED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            color: palette.pixels,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(height: 2.0, color: palette.pixels),
                        const SizedBox(height: 20.0),
                        for (int i = 0; i < _speeds.length; i++)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _selectSpeed(i),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedIndex == i ? '> ' : '  ',
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: palette.pixels,
                                    ),
                                  ),
                                  Text(
                                    _speeds[i].label,
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 18.0,
                                      fontWeight: _selectedIndex == i
                                          ? FontWeight.w900
                                          : FontWeight.w500,
                                      letterSpacing: 1.5,
                                      color: palette.pixels,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_speeds[i].intervalMs}ms',
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 14.0,
                                      color: palette.pixels.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundBtn(
                      label: 'BACK',
                      onPressed: () => Navigator.of(context).pop(),
                      palette: palette,
                    ),
                    const SizedBox(width: 24.0),
                    _RoundBtn(
                      label: 'SELECT',
                      onPressed: _saveAndBack,
                      palette: palette,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final LcdPalette palette;

  const _RoundBtn({
    required this.label,
    required this.onPressed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: palette.bezel,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: palette.bezelHighlight, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
            letterSpacing: 1.2,
            color: palette.background,
          ),
        ),
      ),
    );
  }
}
