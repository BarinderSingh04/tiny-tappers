import 'dart:math';
import 'dart:ui';

import 'palette.dart';

/// Scenery pieces shared by the Flutter hub and the Flame game scenes, so
/// every screen looks like the same world.
abstract final class Scenery {
  static void sky(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          const [KidColors.skyTop, KidColors.sky, KidColors.skyBottom],
          const [0, 0.55, 1],
        ),
    );
  }

  static void sun(Canvas canvas, Offset c, double r) {
    for (var i = 3; i >= 1; i--) {
      canvas.drawCircle(
        c,
        r + i * r * 0.28,
        Paint()..color = KidColors.sun.withValues(alpha: 0.12),
      );
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = Gradient.radial(c - Offset(r * 0.3, r * 0.3), r * 1.3, [
          const Color(0xFFFFF1A8),
          KidColors.sun,
        ]),
    );
  }

  /// A puffy cloud whose flat bottom sits on [c], about 220 × [scale] wide.
  static void cloud(Canvas canvas, Offset c, double scale) {
    final puffs = [
      (const Offset(-70, -22), 38.0),
      (const Offset(-20, -48), 52.0),
      (const Offset(40, -36), 44.0),
      (const Offset(80, -16), 30.0),
    ];
    final shape = Path();
    for (final (o, r) in puffs) {
      shape.addOval(Rect.fromCircle(center: c + o * scale, radius: r * scale));
    }
    shape.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          c.dx - 100 * scale,
          c.dy - 30 * scale,
          c.dx + 105 * scale,
          c.dy,
        ),
        Radius.circular(30 * scale),
      ),
    );
    canvas
      ..drawPath(
        shape.shift(Offset(0, 6 * scale)),
        Paint()..color = const Color(0xFF9CCBEA).withValues(alpha: 0.6),
      )
      ..drawPath(shape, Paint()..color = KidColors.white);
  }

  /// Two layers of rolling hills with their tops near [horizon].
  static void hills(Canvas canvas, Size size, double horizon) {
    Path wave(double base, double amp, double phase, double waves) {
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width; x += 8) {
        final y =
            base -
            amp * (0.5 + 0.5 * sin(x / size.width * waves * 2 * pi + phase));
        path.lineTo(x, y);
      }
      return path
        ..lineTo(size.width, size.height)
        ..close();
    }

    canvas
      ..drawPath(
        wave(horizon, 70, 1.2, 1.6),
        Paint()
          ..shader = Gradient.linear(
            Offset(0, horizon - 70),
            Offset(0, horizon + 80),
            [KidColors.hillBack, shade(KidColors.hillBack, -0.08)],
          ),
      )
      ..drawPath(
        wave(horizon + 50, 50, 3.4, 1.1),
        Paint()
          ..shader = Gradient.linear(
            Offset(0, horizon),
            Offset(0, horizon + 140),
            [KidColors.hillFront, shade(KidColors.hillFront, -0.1)],
          ),
      );
  }
}
