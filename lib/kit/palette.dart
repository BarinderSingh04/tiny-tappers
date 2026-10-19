import 'package:flutter/painting.dart';

/// The shared bright, high-contrast palette from the style guide.
abstract final class KidColors {
  static const skyTop = Color(0xFF5BBEFF);
  static const sky = Color(0xFF8FD3FF);
  static const skyBottom = Color(0xFFD4F0FF);
  static const grass = Color(0xFF7BD389);
  static const hillBack = Color(0xFFA8E6A1);
  static const hillFront = Color(0xFF6CCB7E);
  static const sun = Color(0xFFFFD23F);
  static const red = Color(0xFFFF5A5F);
  static const orange = Color(0xFFFF9F1C);
  static const blue = Color(0xFF3A86FF);
  static const teal = Color(0xFF2EC4B6);
  static const purple = Color(0xFF9B5DE5);
  static const pink = Color(0xFFF15BB5);
  static const cream = Color(0xFFFFF6E9);
  static const ink = Color(0xFF2B2D42);
  static const white = Color(0xFFFFFFFF);

  static const confetti = [sun, red, orange, blue, purple, pink, grass, teal];
}

/// [color] made lighter (positive [amount]) or darker (negative), in HSL.
Color shade(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// A soft drop shadow paint, blurred by [blur] logical pixels.
Paint softShadow({double opacity = 0.18, double blur = 12}) => Paint()
  ..color = KidColors.ink.withValues(alpha: opacity)
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

/// The rounded display font bundled in assets/fonts (SIL OFL).
const kidFont = 'Fredoka';
