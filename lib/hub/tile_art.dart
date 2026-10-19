import 'dart:math';

import 'package:flutter/material.dart';

import '../games/car_wash/car_art.dart';
import '../kit/palette.dart';

/// The illustration on each hub tile, drawn in a square canvas.
class TileArt extends StatelessWidget {
  const TileArt(this.paint, {super.key});

  final void Function(Canvas canvas, Size size) paint;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ArtPainter(paint), size: const Size.square(156));
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.art);

  final void Function(Canvas canvas, Size size) art;

  @override
  void paint(Canvas canvas, Size size) => art(canvas, size);

  @override
  bool shouldRepaint(_ArtPainter oldDelegate) => false;
}

abstract final class HubArt {
  static void car(Canvas canvas, Size size) {
    final s = size.width / CarArt.size.width;
    canvas.save();
    canvas.translate(0, size.height / 2 - CarArt.size.height * s / 2 + 6);
    canvas.scale(s);
    CarArt.paint(canvas, color: KidColors.red);
    canvas.restore();
    // A few bubbles to say "wash".
    final bubble = Paint()..color = KidColors.white.withValues(alpha: 0.9);
    final ring = Paint()
      ..color = const Color(0xFF9FD3F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final (o, r) in [
      (const Offset(0.18, 0.18), 10.0),
      (const Offset(0.32, 0.08), 7.0),
      (const Offset(0.82, 0.14), 12.0),
    ]) {
      final c = Offset(o.dx * size.width, o.dy * size.height);
      canvas
        ..drawCircle(c, r, bubble)
        ..drawCircle(c, r, ring);
    }
  }

  static void cake(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.9),
        width: w * 0.85,
        height: h * 0.1,
      ),
      Paint()..color = KidColors.white,
    );
    void layer(double top, double bottom, double inset, Color color) {
      final r = RRect.fromLTRBR(
        w * inset,
        h * top,
        w * (1 - inset),
        h * bottom,
        const Radius.circular(14),
      );
      canvas
        ..drawRRect(r, Paint()..color = shade(color, -0.08))
        ..drawRRect(
          r.deflate(0).shift(const Offset(0, -4)),
          Paint()..color = color,
        );
    }

    layer(0.6, 0.88, 0.12, const Color(0xFFB5764A));
    layer(0.4, 0.62, 0.2, const Color(0xFFFFB3D9));
    // Icing drips.
    final icing = Paint()..color = KidColors.white;
    final drips = Path()..moveTo(w * 0.2, h * 0.42);
    for (var i = 0; i <= 6; i++) {
      final x = w * (0.2 + i * 0.1);
      drips.quadraticBezierTo(
        x + w * 0.05,
        h * (i.isEven ? 0.55 : 0.5),
        x + w * 0.1,
        h * 0.42,
      );
    }
    drips
      ..lineTo(w * 0.8, h * 0.38)
      ..lineTo(w * 0.2, h * 0.38)
      ..close();
    canvas.drawPath(drips, icing);
    // Sprinkles.
    final random = Random(3);
    for (var i = 0; i < 9; i++) {
      canvas.drawCircle(
        Offset(
          w * (0.18 + random.nextDouble() * 0.64),
          h * (0.66 + random.nextDouble() * 0.18),
        ),
        3,
        Paint()..color = KidColors.confetti[i % KidColors.confetti.length],
      );
    }
    // Candle and flame.
    canvas
      ..drawRRect(
        RRect.fromLTRBR(
          w * 0.46,
          h * 0.18,
          w * 0.54,
          h * 0.4,
          const Radius.circular(4),
        ),
        Paint()..color = KidColors.blue,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w / 2, h * 0.12),
          width: w * 0.1,
          height: h * 0.14,
        ),
        Paint()..color = KidColors.orange,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w / 2, h * 0.135),
          width: w * 0.05,
          height: h * 0.07,
        ),
        Paint()..color = KidColors.sun,
      );
  }

  static void pizza(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 4);
    final r = size.width * 0.42;
    canvas
      ..drawCircle(
        c + const Offset(0, 5),
        r,
        Paint()..color = const Color(0xFFC77D3A),
      )
      ..drawCircle(c, r, Paint()..color = const Color(0xFFF0B36B))
      ..drawCircle(c, r * 0.84, Paint()..color = const Color(0xFFE63946))
      ..drawCircle(c, r * 0.78, Paint()..color = const Color(0xFFFFD166));
    final pepperoni = Paint()..color = const Color(0xFFC1121F);
    final basil = Paint()..color = const Color(0xFF2A9D55);
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3 + 0.3;
      canvas.drawCircle(
        c + Offset(cos(a), sin(a)) * r * 0.48,
        r * 0.13,
        pepperoni,
      );
    }
    canvas.drawCircle(c, r * 0.13, pepperoni);
    for (var i = 0; i < 3; i++) {
      final a = i * 2 * pi / 3 + 0.9;
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(cos(a), sin(a)) * r * 0.3,
          width: r * 0.18,
          height: r * 0.1,
        ),
        basil,
      );
    }
    final cut = Paint()
      ..color = const Color(0xFFE0A050)
      ..strokeWidth = 2.5;
    for (var i = 0; i < 4; i++) {
      final a = i * pi / 4;
      canvas.drawLine(
        c - Offset(cos(a), sin(a)) * r * 0.8,
        c + Offset(cos(a), sin(a)) * r * 0.8,
        cut,
      );
    }
  }

  static void puzzle(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    void piece(Path path, Color color) {
      canvas
        ..drawPath(
          path.shift(const Offset(0, 5)),
          Paint()..color = shade(color, -0.15),
        )
        ..drawPath(path, Paint()..color = color);
    }

    piece(
      Path()..addOval(
        Rect.fromCircle(center: Offset(w * 0.3, h * 0.32), radius: w * 0.17),
      ),
      KidColors.sun,
    );
    piece(
      Path()
        ..moveTo(w * 0.72, h * 0.14)
        ..lineTo(w * 0.9, h * 0.48)
        ..lineTo(w * 0.54, h * 0.48)
        ..close(),
      KidColors.teal,
    );
    piece(
      Path()..addRRect(
        RRect.fromLTRBR(
          w * 0.14,
          h * 0.58,
          w * 0.46,
          h * 0.88,
          const Radius.circular(10),
        ),
      ),
      KidColors.red,
    );
    // A dashed outline waiting for the last piece.
    final slot = Paint()
      ..color = KidColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final star = Path();
    final c = Offset(w * 0.72, h * 0.73);
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? w * 0.17 : w * 0.08;
      final a = -pi / 2 + i * pi / 5;
      final p = c + Offset(cos(a), sin(a)) * r;
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    canvas.drawPath(star, slot);
  }
}
