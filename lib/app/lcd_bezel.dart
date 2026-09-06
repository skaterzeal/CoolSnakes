import 'package:flutter/material.dart';
import '../constants/lcd_colors.dart';

/// Authentic retro handheld casing bezel framing the monochrome LCD screen.
///
/// Features an inset screen bezel, beveled inner border, and zero copied branding.
class LcdBezel extends StatelessWidget {
  final Widget child;
  final LcdPalette palette;
  final double aspectRatio;

  const LcdBezel({
    super.key,
    required this.child,
    required this.palette,
    this.aspectRatio = 100 / 94,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: palette.bezel,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16.0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: palette.bezelHighlight.withValues(alpha: 0.3),
                blurRadius: 2.0,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border.all(
              color: palette.bezelHighlight,
              width: 3.0,
            ),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.6),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4.0,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ),
    );
  }
}
