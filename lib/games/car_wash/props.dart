import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../kit/art_book.dart';
import '../../kit/palette.dart';
import '../../kit/rub_grid.dart';
import '../../kit/scenery.dart';

/// Sky, hills and the car wash building behind the car.
///
/// An artist's `carwash_bg.png` replaces all of it when present.
class Backdrop extends PositionComponent {
  Backdrop({this.image}) : super(size: Vector2(1280, 720), priority: -10);

  final Sprite? image;

  double _time = 0;

  static const _size = Size(1280, 720);

  /// Hills, building and floor never change, so they are recorded once
  /// instead of repainting their gradients and blurs every frame.
  late final Picture _static = _record((canvas) {
    Scenery.hills(canvas, _size, 470);
    _building(canvas);
    _floor(canvas);
  });

  Picture _record(void Function(Canvas canvas) draw) {
    final recorder = PictureRecorder();
    draw(Canvas(recorder));
    return recorder.endRecording();
  }

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    final image = this.image;
    if (image != null) {
      image.render(canvas, size: size);
      return;
    }
    Scenery.sky(canvas, _size);
    Scenery.sun(canvas, const Offset(1160, 105), 52);
    final drift = (_time * 12) % 1500;
    Scenery.cloud(canvas, Offset((150 + drift) % 1500 - 110, 150), 0.9);
    Scenery.cloud(canvas, Offset((900 + drift * 0.7) % 1500 - 110, 95), 0.65);
    canvas.drawPicture(_static);
    for (final x in const [318.0, 962.0]) {
      _brush(canvas, x);
    }
  }

  @override
  void onRemove() {
    _static.dispose();
    super.onRemove();
  }

  void _building(Canvas canvas) {
    // Walls with a soft shadow and the open bay the car sits in.
    final walls = RRect.fromLTRBR(
      250,
      170,
      1030,
      560,
      const Radius.circular(36),
    );
    canvas
      ..drawRRect(
        walls.shift(const Offset(0, 10)),
        softShadow(opacity: 0.15, blur: 16),
      )
      ..drawRRect(walls, Paint()..color = KidColors.cream);
    final bay = RRect.fromLTRBAndCorners(
      300,
      215,
      980,
      560,
      topLeft: const Radius.circular(120),
      topRight: const Radius.circular(120),
    );
    canvas.drawRRect(
      bay,
      Paint()
        ..shader = Gradient.linear(const Offset(0, 215), const Offset(0, 560), [
          const Color(0xFFCFE6F7),
          const Color(0xFFE9F4FC),
        ]),
    );

    // Striped awning with a scalloped edge.
    const top = 150.0;
    const bottom = 205.0;
    const left = 230.0;
    const right = 1050.0;
    const stripes = 12;
    const w = (right - left) / stripes;
    for (var i = 0; i < stripes; i++) {
      final x = left + i * w;
      final color = i.isEven ? KidColors.red : KidColors.white;
      canvas
        ..drawRect(Rect.fromLTRB(x, top, x + w, bottom), Paint()..color = color)
        ..drawCircle(Offset(x + w / 2, bottom), w / 2, Paint()..color = color);
    }
    canvas.drawRRect(
      RRect.fromLTRBR(
        left - 6,
        top - 14,
        right + 6,
        top + 6,
        const Radius.circular(10),
      ),
      Paint()..color = shade(KidColors.red, -0.1),
    );
  }

  void _brush(Canvas canvas, double x) {
    final rect = RRect.fromLTRBR(
      x - 26,
      240,
      x + 26,
      540,
      const Radius.circular(26),
    );
    canvas.drawRRect(rect, Paint()..color = KidColors.teal);
    canvas.save();
    canvas.clipRRect(rect);
    final stripe = Paint()
      ..color = shade(KidColors.teal, 0.15)
      ..strokeWidth = 10;
    final offset = (_time * 40) % 36;
    for (var y = 200.0; y < 560; y += 36) {
      canvas.drawLine(
        Offset(x - 30, y + offset),
        Offset(x + 30, y + offset + 18),
        stripe,
      );
    }
    canvas.restore();
    canvas.drawRect(
      Rect.fromLTWH(x - 6, 222, 12, 20),
      Paint()..color = const Color(0xFF9AA4B2),
    );
  }

  void _floor(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTRB(0, 545, 1280, 720),
      Paint()
        ..shader = Gradient.linear(const Offset(0, 545), const Offset(0, 720), [
          const Color(0xFFD9E3EE),
          const Color(0xFFBFCCDB),
        ]),
    );
    canvas.drawRect(
      const Rect.fromLTRB(0, 541, 1280, 551),
      Paint()..color = const Color(0xFFAFBDCC),
    );
    final line = Paint()
      ..color = KidColors.white.withValues(alpha: 0.5)
      ..strokeWidth = 3;
    for (var x = -200.0; x < 1500; x += 120) {
      canvas.drawLine(
        Offset(x + (x - 640) * 0.15, 551),
        Offset(x + (x - 640) * 0.6, 720),
        line,
      );
    }
  }
}

/// The pill at the top showing the four wash stages.
class StageHud extends PositionComponent {
  StageHud({required super.position})
    : super(anchor: Anchor.center, size: Vector2(_slots * 84.0 + 20, 92));

  static const _slots = 4;
  static const _colors = [
    KidColors.orange,
    KidColors.blue,
    KidColors.pink,
    KidColors.purple,
  ];

  int done = 0;
  double _time = 0;

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    final pill = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(46),
    );
    canvas
      ..drawRRect(
        pill.shift(const Offset(0, 6)),
        softShadow(opacity: 0.18, blur: 10),
      )
      ..drawRRect(
        pill,
        Paint()..color = KidColors.white.withValues(alpha: 0.92),
      );
    for (var i = 0; i < _slots; i++) {
      final c = Offset(52 + i * 84.0, size.y / 2);
      final color = _colors[i];
      if (i < done) {
        canvas
          ..drawCircle(
            c + const Offset(0, 4),
            32,
            Paint()..color = shade(color, -0.15),
          )
          ..drawCircle(c, 32, Paint()..color = color);
        _icon(canvas, i, c, KidColors.white);
      } else if (i == done) {
        final pulse = 1 + 0.06 * sin(_time * 5);
        canvas
          ..drawCircle(
            c,
            32 * pulse,
            Paint()..color = color.withValues(alpha: 0.15),
          )
          ..drawCircle(
            c,
            32 * pulse,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5,
          );
        _icon(canvas, i, c, color);
      } else {
        canvas.drawCircle(c, 32, Paint()..color = const Color(0xFFEDF1F6));
        _icon(canvas, i, c, const Color(0xFFC3CCD8));
      }
    }
  }

  void _icon(Canvas canvas, int i, Offset c, Color color) {
    final p = Paint()..color = color;
    switch (i) {
      case 0: // sponge
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: 34, height: 24),
            const Radius.circular(7),
          ),
          p,
        );
      case 1: // drop
        canvas.drawPath(dropPath(c, 13), p);
      case 2: // towel
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: 30, height: 32),
            const Radius.circular(5),
          ),
          p,
        );
      default: // star
        canvas.drawPath(starPath(c, 18, 8), p);
    }
  }
}

Path dropPath(Offset c, double r) => Path()
  ..moveTo(c.dx, c.dy - r * 1.7)
  ..quadraticBezierTo(c.dx + r, c.dy - r * 0.3, c.dx + r, c.dy + r * 0.2)
  ..arcToPoint(Offset(c.dx - r, c.dy + r * 0.2), radius: Radius.circular(r))
  ..quadraticBezierTo(c.dx - r, c.dy - r * 0.3, c.dx, c.dy - r * 1.7)
  ..close();

Path starPath(Offset c, double outer, double inner) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outer : inner;
    final a = -pi / 2 + i * pi / 5;
    final p = c + Offset(cos(a) * r, sin(a) * r);
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

/// The frosted shelf the stickers wait on.
class StickerShelf extends PositionComponent {
  StickerShelf()
    : super(position: Vector2(140, 585), size: Vector2(1000, 115), priority: 5);

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(40));
    canvas
      ..drawRRect(
        r.shift(const Offset(0, 6)),
        softShadow(opacity: 0.16, blur: 12),
      )
      ..drawRRect(r, Paint()..color = KidColors.white.withValues(alpha: 0.8));
  }
}

enum WashTool { sponge, hose, towel }

/// The sponge, hose or towel that follows the child's finger.
class ToolCursor extends PositionComponent {
  ToolCursor() : super(size: Vector2(130, 110), anchor: Anchor.center);

  WashTool tool = WashTool.sponge;
  bool visible = false;
  double _time = 0;

  /// Artist sprites (`tool_sponge`, `tool_hose`, `tool_towel`) by tool.
  final Map<WashTool, Sprite> sprites = {};

  void showAt(Vector2 at) {
    position = at + Vector2(0, -40);
    visible = true;
  }

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    canvas.save();
    canvas.translate(65, 55);
    canvas.rotate(sin(_time * 18) * 0.08);
    final sprite = sprites[tool];
    if (sprite != null) {
      sprite.render(canvas, size: gameSize(sprite), anchor: Anchor.center);
      canvas.restore();
      return;
    }
    switch (tool) {
      case WashTool.sponge:
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 110, height: 66),
          const Radius.circular(20),
        );
        canvas
          ..drawRRect(
            r.shift(const Offset(0, 6)),
            Paint()..color = const Color(0xFFE0A800),
          )
          ..drawRRect(
            r,
            Paint()
              ..shader = Gradient.linear(
                const Offset(0, -33),
                const Offset(0, 33),
                [const Color(0xFFFFE680), KidColors.sun],
              ),
          )
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(-55, 14, 110, 19),
              const Radius.circular(10),
            ),
            Paint()..color = KidColors.teal,
          );
        final hole = Paint()..color = const Color(0xFFE8B820);
        for (final o in const [
          Offset(-28, -12),
          Offset(6, -2),
          Offset(30, -16),
          Offset(-6, -18),
        ]) {
          canvas.drawCircle(o, 6, hole);
        }
      case WashTool.hose:
        final body = RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, -20), width: 96, height: 38),
          const Radius.circular(19),
        );
        canvas
          ..drawRRect(
            body.shift(const Offset(0, 5)),
            Paint()..color = shade(KidColors.blue, -0.18),
          )
          ..drawRRect(body, Paint()..color = KidColors.blue)
          ..drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: const Offset(0, 4),
                width: 34,
                height: 18,
              ),
              const Radius.circular(6),
            ),
            Paint()..color = const Color(0xFF9AA4B2),
          );
        final water = Paint()
          ..color = const Color(0xFF6EC6FF).withValues(alpha: 0.85)
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round;
        for (var i = -2; i <= 2; i++) {
          final wobble = sin(_time * 30 + i) * 3;
          canvas.drawLine(
            Offset(i * 5.0, 14),
            Offset(i * 16.0 + wobble, 58),
            water,
          );
        }
      case WashTool.towel:
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 110, height: 80),
          const Radius.circular(14),
        );
        canvas
          ..drawRRect(
            r.shift(const Offset(0, 6)),
            Paint()..color = shade(KidColors.pink, -0.15),
          )
          ..drawRRect(r, Paint()..color = KidColors.pink);
        final stripe = Paint()..color = KidColors.white.withValues(alpha: 0.9);
        canvas
          ..drawRect(const Rect.fromLTWH(-55, -20, 110, 9), stripe)
          ..drawRect(const Rect.fromLTWH(-55, 12, 110, 9), stripe);
    }
    canvas.restore();
  }
}

/// How each wash stage's covering layer looks.
abstract final class Grime {
  /// Draws artist sprites (`mud_1`, `mud_2`, …) instead of the coded blobs,
  /// each about [radius] × 2 game units across before random scaling.
  static void Function(Canvas, Vector2, RubCell) sprites(
    List<Sprite> variants, {
    double radius = 17,
  }) {
    return (canvas, c, cell) {
      final sprite = variants[cell.variant % variants.length];
      sprite.render(
        canvas,
        position: c,
        size: Vector2.all(radius * 2 * cell.scale),
        anchor: Anchor.center,
      );
    };
  }

  static final _mud = [
    const Color(0xFF8B5A2B),
    const Color(0xFF7A4B22),
    const Color(0xFF9C6B3A),
  ];

  static void mud(Canvas canvas, Vector2 c, RubCell cell) {
    final base = _mud[cell.variant];
    final o = Offset(c.x, c.y);
    final r = 17 * cell.scale;
    canvas
      ..drawCircle(
        o + const Offset(0, 3),
        r,
        Paint()..color = shade(base, -0.1),
      )
      ..drawCircle(o, r, Paint()..color = base)
      ..drawCircle(
        o - Offset(r * 0.35, r * 0.35),
        r * 0.28,
        Paint()..color = shade(base, 0.1),
      );
    if (cell.variant == 1) {
      canvas.drawCircle(
        o + Offset(r * 1.1, -r * 0.6),
        r * 0.25,
        Paint()..color = base,
      );
    }
  }

  static final _foamFill = Paint()
    ..color = KidColors.white.withValues(alpha: 0.95);
  static final _foamEdge = Paint()
    ..color = const Color(0xFF9FD3F5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  static final _foamShine = Paint()
    ..color = const Color(0xFFB9E3FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  static final _tint = [
    const Color(0xFFFFD6F0),
    const Color(0xFFD6ECFF),
    const Color(0xFFE6DCFF),
  ];

  static void foam(Canvas canvas, Vector2 c, RubCell cell) {
    final o = Offset(c.x, c.y);
    final r = 16 * cell.scale;
    canvas
      ..drawCircle(o, r, _foamFill)
      ..drawCircle(
        o + Offset(r * 0.25, r * 0.25),
        r * 0.6,
        Paint()..color = _tint[cell.variant].withValues(alpha: 0.5),
      )
      ..drawCircle(o, r, _foamEdge)
      ..drawArc(
        Rect.fromCircle(center: o, radius: r * 0.65),
        pi * 1.1,
        pi * 0.5,
        false,
        _foamShine,
      );
  }

  static final _drop = Paint()..color = const Color(0xFF4FB3FF);
  static final _dropEdge = Paint()
    ..color = const Color(0xFF2E8FE0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final _shine = Paint()
    ..color = KidColors.white.withValues(alpha: 0.85);

  static void drops(Canvas canvas, Vector2 c, RubCell cell) {
    if (cell.variant == 0) return;
    final o = Offset(c.x, c.y);
    final r = 7.5 * cell.scale;
    final path = dropPath(o, r);
    canvas
      ..drawPath(path, _drop)
      ..drawPath(path, _dropEdge)
      ..drawCircle(o + Offset(-r * 0.35, -r * 0.1), r * 0.3, _shine);
  }
}

/// Sticker shapes drawn in code, centred in a box of [size].
abstract final class Stickers {
  static void star(Canvas canvas, Vector2 size, Color color) => _sticker(
    canvas,
    starPath(Offset(size.x / 2, size.y / 2), size.x * 0.47, size.x * 0.22),
    color,
  );

  static void heart(Canvas canvas, Vector2 size, Color color) {
    final w = size.x;
    final h = size.y;
    final path = Path()
      ..moveTo(w / 2, h * 0.9)
      ..cubicTo(w * -0.12, h * 0.5, w * 0.12, h * 0.0, w / 2, h * 0.3)
      ..cubicTo(w * 0.88, h * 0.0, w * 1.12, h * 0.5, w / 2, h * 0.9)
      ..close();
    _sticker(canvas, path, color);
  }

  static void flower(Canvas canvas, Vector2 size, Color color) {
    final c = Offset(size.x / 2, size.y / 2);
    var path = Path();
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3;
      path = Path.combine(
        PathOperation.union,
        path,
        Path()..addOval(
          Rect.fromCircle(
            center: c + Offset(cos(a), sin(a)) * size.x * 0.24,
            radius: size.x * 0.19,
          ),
        ),
      );
    }
    _sticker(canvas, path, color);
    canvas.drawCircle(c, size.x * 0.16, Paint()..color = KidColors.sun);
    canvas.drawCircle(
      c - Offset(size.x * 0.05, size.x * 0.05),
      size.x * 0.05,
      Paint()..color = KidColors.white.withValues(alpha: 0.7),
    );
  }

  static void _sticker(Canvas canvas, Path path, Color color) {
    final bounds = path.getBounds();
    canvas
      ..drawPath(
        path.shift(const Offset(0, 5)),
        softShadow(opacity: 0.25, blur: 4),
      )
      ..drawPath(
        path,
        Paint()
          ..color = KidColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawPath(
        path,
        Paint()
          ..shader = Gradient.linear(bounds.topCenter, bounds.bottomCenter, [
            shade(color, 0.12),
            shade(color, -0.06),
          ]),
      );
    canvas.save();
    canvas.clipPath(path);
    canvas.drawOval(
      Rect.fromLTWH(
        bounds.left + bounds.width * 0.15,
        bounds.top + bounds.height * 0.08,
        bounds.width * 0.45,
        bounds.height * 0.28,
      ),
      Paint()..color = KidColors.white.withValues(alpha: 0.35),
    );
    canvas.restore();
  }
}
