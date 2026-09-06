import 'dart:ui';

/// 100% original 3x5 and 4x5 1-bit monochrome LCD bitmap font.
/// Zero external fonts or copyrighted typography.
class PixelFont {
  /// 3x5 font glyph definitions.
  /// Each glyph is a list of 5 binary integers (rows), width is 3 bits.
  static const Map<String, List<int>> _glyphs3x5 = {
    '0': [7, 5, 5, 5, 7], // 111, 101, 101, 101, 111
    '1': [2, 6, 2, 2, 7], // 010, 110, 010, 010, 111
    '2': [7, 1, 7, 4, 7], // 111, 001, 111, 100, 111
    '3': [7, 1, 7, 1, 7], // 111, 001, 111, 001, 111
    '4': [5, 5, 7, 1, 1], // 101, 101, 111, 001, 001
    '5': [7, 4, 7, 1, 7], // 111, 100, 111, 001, 111
    '6': [7, 4, 7, 5, 7], // 111, 100, 111, 101, 111
    '7': [7, 1, 2, 2, 2], // 111, 001, 010, 010, 010
    '8': [7, 5, 7, 5, 7], // 111, 101, 111, 101, 111
    '9': [7, 5, 7, 1, 7], // 111, 101, 111, 001, 111
    'A': [2, 5, 7, 5, 5],
    'B': [6, 5, 6, 5, 6],
    'C': [7, 4, 4, 4, 7],
    'D': [6, 5, 5, 5, 6],
    'E': [7, 4, 7, 4, 7],
    'F': [7, 4, 6, 4, 4],
    'G': [7, 4, 5, 5, 7],
    'H': [5, 5, 7, 5, 5],
    'I': [7, 2, 2, 2, 7],
    'J': [1, 1, 1, 5, 7],
    'K': [5, 5, 6, 5, 5],
    'L': [4, 4, 4, 4, 7],
    'M': [5, 7, 5, 5, 5],
    'N': [6, 5, 5, 5, 5],
    'O': [7, 5, 5, 5, 7],
    'P': [7, 5, 7, 4, 4],
    'Q': [7, 5, 5, 7, 1],
    'R': [7, 5, 6, 5, 5],
    'S': [7, 4, 7, 1, 7],
    'T': [7, 2, 2, 2, 2],
    'U': [5, 5, 5, 5, 7],
    'V': [5, 5, 5, 5, 2],
    'W': [5, 5, 5, 7, 5],
    'X': [5, 5, 2, 5, 5],
    'Y': [5, 5, 2, 2, 2],
    'Z': [7, 1, 2, 4, 7],
    ':': [0, 2, 0, 2, 0],
    '!': [2, 2, 2, 0, 2],
    '?': [7, 1, 2, 0, 2],
    '-': [0, 0, 7, 0, 0],
    '>': [4, 2, 1, 2, 4],
    '<': [1, 2, 4, 2, 1],
    '/': [1, 1, 2, 4, 4],
    '.': [0, 0, 0, 0, 2],
    ' ': [0, 0, 0, 0, 0],
  };

  /// Draws a text string onto a [canvas] at the specified ([startX], [startY])
  /// with integer pixel scaling [pixelSize].
  static void drawText(
    Canvas canvas,
    String text,
    double startX,
    double startY,
    Paint paint, {
    double pixelSize = 1.0,
    double charSpacing = 1.0,
  }) {
    final upper = text.toUpperCase();
    double currentX = startX;

    for (int i = 0; i < upper.length; i++) {
      final char = upper[i];
      final glyph = _glyphs3x5[char] ?? _glyphs3x5[' ']!;

      for (int row = 0; row < 5; row++) {
        final rowBits = glyph[row];
        for (int col = 0; col < 3; col++) {
          final bit = (rowBits >> (2 - col)) & 1;
          if (bit == 1) {
            canvas.drawRect(
              Rect.fromLTWH(
                currentX + col * pixelSize,
                startY + row * pixelSize,
                pixelSize,
                pixelSize,
              ),
              paint,
            );
          }
        }
      }
      currentX += (3 * pixelSize) + (charSpacing * pixelSize);
    }
  }

  /// Measures the rendered width of a string in logical pixels.
  static double measureWidth(
    String text, {
    double pixelSize = 1.0,
    double charSpacing = 1.0,
  }) {
    if (text.isEmpty) return 0.0;
    return (text.length * 3 * pixelSize) +
        ((text.length - 1) * charSpacing * pixelSize);
  }
}
