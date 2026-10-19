import 'dart:math';
import 'dart:ui';

import '../../kit/palette.dart';

/// Draws the cartoon car in a 560 × 310 box. Pure painting, so the hub
/// tile and the game share one look.
abstract final class CarArt {
  static const size = Size(560, 310);

  static final body = RRect.fromLTRBR(
    0,
    110,
    560,
    250,
    const Radius.circular(60),
  );
  static final cabin = RRect.fromLTRBR(
    110,
    20,
    430,
    140,
    const Radius.circular(55),
  );
  static final _silhouette = Path.combine(
    PathOperation.union,
    Path()..addRRect(body),
    Path()..addRRect(cabin),
  );

  static bool contains(Offset point) =>
      body.contains(point) || cabin.contains(point);

  /// [wheelAngle] spins the rims; [blink] goes from 0 (open) to 1 (shut).
  static void paint(
    Canvas canvas, {
    required Color color,
    double wheelAngle = 0,
    double blink = 0,
    bool shadow = true,
  }) {
    final outline = shade(color, -0.25);

    if (shadow) {
      canvas.drawOval(
        const Rect.fromLTRB(10, 280, 550, 318),
        softShadow(opacity: 0.25, blur: 10),
      );
    }

    // Wheel wells sit behind the body.
    final well = Paint()..color = shade(color, -0.32);
    for (final x in const [140.0, 420.0]) {
      canvas.drawCircle(Offset(x, 240), 62, well);
    }

    // Body with a top-lit gradient and a darker outline.
    canvas
      ..drawPath(
        _silhouette,
        Paint()
          ..shader = Gradient.linear(
            const Offset(0, 20),
            const Offset(0, 250),
            [shade(color, 0.14), color, shade(color, -0.1)],
            const [0, 0.5, 1],
          ),
      )
      ..drawPath(
        _silhouette,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeJoin = StrokeJoin.round,
      );

    // Glossy highlight along the roof and shoulder line.
    final gloss = Paint()..color = KidColors.white.withValues(alpha: 0.35);
    canvas
      ..drawRRect(
        RRect.fromLTRBR(40, 126, 250, 140, const Radius.circular(7)),
        gloss,
      )
      ..drawRRect(
        RRect.fromLTRBR(150, 30, 330, 40, const Radius.circular(5)),
        gloss,
      );

    // Door seam and handle.
    final seam = Paint()
      ..color = outline.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas
      ..drawLine(const Offset(270, 140), const Offset(270, 232), seam)
      ..drawRRect(
        RRect.fromLTRBR(222, 158, 252, 168, const Radius.circular(5)),
        Paint()..color = outline.withValues(alpha: 0.7),
      );

    _window(
      canvas,
      RRect.fromLTRBR(145, 45, 260, 118, const Radius.circular(26)),
      outline,
    );
    _window(
      canvas,
      RRect.fromLTRBR(280, 45, 402, 118, const Radius.circular(26)),
      outline,
    );
    _face(canvas, blink);

    // Lights and bumpers.
    canvas
      ..drawCircle(
        const Offset(530, 162),
        26,
        Paint()..color = KidColors.sun.withValues(alpha: 0.35),
      )
      ..drawCircle(
        const Offset(530, 162),
        15,
        Paint()..color = const Color(0xFFFFF3B0),
      )
      ..drawCircle(const Offset(530, 162), 15, seam)
      ..drawRRect(
        RRect.fromLTRBR(8, 146, 26, 178, const Radius.circular(8)),
        Paint()..color = const Color(0xFFFF3B3B),
      );
    final chrome = Paint()
      ..shader = Gradient.linear(const Offset(0, 205), const Offset(0, 228), [
        const Color(0xFFF4F6FA),
        const Color(0xFFB4BCC8),
      ]);
    canvas
      ..drawRRect(
        RRect.fromLTRBR(500, 205, 566, 228, const Radius.circular(11)),
        chrome,
      )
      ..drawRRect(
        RRect.fromLTRBR(-6, 205, 52, 228, const Radius.circular(11)),
        chrome,
      );

    for (final x in const [140.0, 420.0]) {
      _wheel(canvas, Offset(x, 250), wheelAngle);
    }
  }

  static void _window(Canvas canvas, RRect r, Color frame) {
    canvas.save();
    canvas.clipRRect(r);
    canvas.drawRect(
      r.outerRect,
      Paint()
        ..shader = Gradient.linear(
          r.outerRect.topCenter,
          r.outerRect.bottomCenter,
          [const Color(0xFFE9F7FF), const Color(0xFFAEDCFA)],
        ),
    );
    final shine = Path()
      ..moveTo(r.left + 18, r.bottom)
      ..lineTo(r.left + 58, r.top)
      ..lineTo(r.left + 78, r.top)
      ..lineTo(r.left + 38, r.bottom)
      ..close();
    canvas
      ..drawPath(
        shine,
        Paint()..color = KidColors.white.withValues(alpha: 0.55),
      )
      ..restore()
      ..drawRRect(
        r,
        Paint()
          ..color = frame
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
  }

  static void _face(Canvas canvas, double blink) {
    final ink = Paint()..color = KidColors.ink;
    final white = Paint()..color = KidColors.white;
    for (final x in const [322.0, 364.0]) {
      final eye = Rect.fromCenter(
        center: Offset(x, 76),
        width: 22,
        height: max(3, 26 * (1 - blink)),
      );
      canvas.drawOval(eye, ink);
      if (blink < 0.5) canvas.drawCircle(Offset(x + 4, 70), 4, white);
    }
    final cheek = Paint()..color = KidColors.pink.withValues(alpha: 0.35);
    canvas
      ..drawCircle(const Offset(304, 98), 9, cheek)
      ..drawCircle(const Offset(384, 98), 9, cheek)
      ..drawPath(
        Path()
          ..moveTo(327, 96)
          ..quadraticBezierTo(343, 110, 359, 96),
        Paint()
          ..color = KidColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
  }

  static void _wheel(Canvas canvas, Offset c, double angle) {
    canvas
      ..drawCircle(c, 50, Paint()..color = const Color(0xFF26283A))
      ..drawCircle(
        c,
        42,
        Paint()
          ..color = const Color(0xFF3A3D55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      )
      ..drawCircle(
        c,
        28,
        Paint()
          ..shader = Gradient.radial(c - const Offset(8, 8), 34, [
            const Color(0xFFFFFFFF),
            const Color(0xFFB8C0CC),
          ]),
      );
    final spoke = Paint()
      ..color = const Color(0xFF8C95A3)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 5; i++) {
      final a = angle + i * 2 * pi / 5;
      canvas.drawLine(c, c + Offset(cos(a), sin(a)) * 22, spoke);
    }
    canvas.drawCircle(c, 8, Paint()..color = const Color(0xFF5B6475));
  }
}
