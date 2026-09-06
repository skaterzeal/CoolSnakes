import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/lcd_bezel.dart';
import '../constants/lcd_colors.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import '../services/storage_service.dart';
import 'about_screen.dart';
import 'game_screen.dart';
import 'high_score_screen.dart';
import 'settings_screen.dart';
import 'speed_screen.dart';

/// Main Menu Screen
///
/// COOL SNAKE
/// > PLAY
///   SPEED
///   HIGH SCORE
///   SETTINGS
///   ABOUT
class MainMenuScreen extends StatefulWidget {
  final StorageService storage;
  final AudioService audio;
  final HapticsService haptics;
  final VoidCallback onConfigChanged;

  const MainMenuScreen({
    super.key,
    required this.storage,
    required this.audio,
    required this.haptics,
    required this.onConfigChanged,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;

  final List<String> _menuOptions = [
    'PLAY',
    'SPEED',
    'HIGH SCORE',
    'SETTINGS',
    'ABOUT',
  ];

  LcdPalette get _palette => LcdColors.palettes[
      widget.storage.paletteIndex.clamp(0, LcdColors.palettes.length - 1)];

  void _moveSelection(int delta) {
    widget.audio.playMenuClick();
    widget.haptics.click();
    setState(() {
      _selectedIndex =
          (_selectedIndex + delta + _menuOptions.length) % _menuOptions.length;
    });
  }

  void _selectOption(int index) {
    widget.audio.playMenuClick();
    widget.haptics.click();
    setState(() {
      _selectedIndex = index;
    });
    _executeSelected();
  }

  void _executeSelected() {
    switch (_selectedIndex) {
      case 0: // PLAY
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameScreen(
              storage: widget.storage,
              audio: widget.audio,
              haptics: widget.haptics,
            ),
          ),
        ).then((_) {
          setState(() {});
          widget.onConfigChanged();
        });
        break;
      case 1: // SPEED
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SpeedScreen(
              storage: widget.storage,
              audio: widget.audio,
              haptics: widget.haptics,
            ),
          ),
        ).then((_) {
          setState(() {});
          widget.onConfigChanged();
        });
        break;
      case 2: // HIGH SCORE
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HighScoreScreen(
              storage: widget.storage,
              audio: widget.audio,
              haptics: widget.haptics,
            ),
          ),
        ).then((_) {
          setState(() {});
          widget.onConfigChanged();
        });
        break;
      case 3: // SETTINGS
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              storage: widget.storage,
              audio: widget.audio,
              haptics: widget.haptics,
              onPaletteChanged: () {
                setState(() {});
                widget.onConfigChanged();
              },
            ),
          ),
        )
            .then((_) {
          setState(() {});
          widget.onConfigChanged();
        });
        break;
      case 4: // ABOUT
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AboutScreen(
              storage: widget.storage,
              audio: widget.audio,
              haptics: widget.haptics,
            ),
          ),
        );
        break;
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
              _executeSelected();
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
                        // Title
                        Text(
                          'COOL SNAKE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 24.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            color: palette.pixels,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        // Divider
                        Container(
                          height: 2.0,
                          color: palette.pixels,
                        ),
                        const SizedBox(height: 16.0),
                        // Menu Options
                        for (int i = 0; i < _menuOptions.length; i++)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _selectOption(i),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
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
                                    _menuOptions[i],
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
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Directional keypad navigation for touch devices
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NavButton(
                      icon: Icons.keyboard_arrow_up,
                      onPressed: () => _moveSelection(-1),
                      palette: palette,
                    ),
                    const SizedBox(width: 16.0),
                    _NavButton(
                      icon: Icons.check,
                      label: 'OK',
                      onPressed: _executeSelected,
                      palette: palette,
                    ),
                    const SizedBox(width: 16.0),
                    _NavButton(
                      icon: Icons.keyboard_arrow_down,
                      onPressed: () => _moveSelection(1),
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

class _NavButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;
  final LcdPalette palette;

  const _NavButton({
    this.icon,
    this.label,
    required this.onPressed,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          color: palette.bezel,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(color: palette.bezelHighlight, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: palette.background,
                  ),
                )
              : Icon(icon, color: palette.background, size: 28.0),
        ),
      ),
    );
  }
}
