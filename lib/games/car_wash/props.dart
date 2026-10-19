import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../kit/palette.dart';
import '../../kit/rub_grid.dart';

/// Sky, ground and sun behind the car wash.
class Backdrop extends PositionComponent {
  Backdrop() : super(size: Vector2(1280, 720), priority: -10);

  final _sky = Paint()..color = KidColors.sky;
  final _grass = Paint()..color = KidColors.grass;
  final _road = Paint()..color = const Color(0xFFB8B8C8);
  final _sun = Paint()..color = KidColors.sun;
  final _cloud = Paint()..color = KidColors.white;

  @override
  void render(Canvas canvas) {
    canvas
      ..drawRect(const Rect.fromLTWH(0, 0, 1280, 720), _sky)
      ..drawCircle(const Offset(1150, 110), 70, _sun)
      ..drawCircle(const Offset(200, 120), 45, _cloud)
      ..drawCircle(const Offset(255, 105), 55, _cloud)
      ..drawCircle(const Offset(315, 125), 40, _cloud)
      ..drawRect(const Rect.fromLTWH(0, 540, 1280, 180), _grass)
      ..drawRect(const Rect.fromLTWH(0, 530, 1280, 60), _road);
  }
}

/// A row of dots at the top showing how many stages are done.
class StageDots extends PositionComponent {
  StageDots({required this.count, required super.position})
    : super(anchor: Anchor.center, size: Vector2(count * 70.0, 50));

  final int count;
  int done = 0;

  final _empty = Paint()
    ..color = KidColors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6;
  final _full = Paint()..color = KidColors.sun;

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < count; i++) {
      final c = Offset(35 + i * 70.0, 25);
      canvas.drawCircle(c, 20, i < done ? _full : _empty);
    }
  }
}

enum WashTool { sponge, hose, towel }

/// The sponge, hose or towel that follows the child's finger.
class ToolCursor extends PositionComponent {
  ToolCursor() : super(size: Vector2(120, 90), anchor: Anchor.center);

  WashTool tool = WashTool.sponge;
  bool visible = false;

  void showAt(Vector2 at) {
    position = at + Vector2(0, -50);
    visible = true;
  }

  final _sponge = Paint()..color = KidColors.sun;
  final _hole = Paint()..color = const Color(0xFFE0B020);
  final _nozzle = Paint()..color = KidColors.blue;
  final _water = Paint()
    ..color = const Color(0xFF6EC6FF)
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round;
  final _towel = Paint()..color = KidColors.pink;
  final _stripe = Paint()..color = KidColors.white;

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    switch (tool) {
      case WashTool.sponge:
        canvas.drawRRect(
          RRect.fromLTRBR(10, 15, 110, 75, const Radius.circular(18)),
          _sponge,
        );
        for (final o in const [
          Offset(35, 35),
          Offset(70, 50),
          Offset(85, 30),
        ]) {
          canvas.drawCircle(o, 6, _hole);
        }
      case WashTool.hose:
        canvas.drawRRect(
          RRect.fromLTRBR(20, 10, 100, 40, const Radius.circular(12)),
          _nozzle,
        );
        for (var i = -2; i <= 2; i++) {
          canvas.drawLine(
            Offset(60 + i * 6.0, 42),
            Offset(60 + i * 16.0, 88),
            _water,
          );
        }
      case WashTool.towel:
        canvas.drawRRect(
          RRect.fromLTRBR(10, 10, 110, 80, const Radius.circular(10)),
          _towel,
        );
        canvas
          ..drawRect(const Rect.fromLTWH(10, 28, 100, 8), _stripe)
          ..drawRect(const Rect.fromLTWH(10, 54, 100, 8), _stripe);
    }
  }
}

/// How each wash stage's covering layer looks.
abstract final class Grime {
  static final _mud = [
    Paint()..color = const Color(0xFF8B5A2B),
    Paint()..color = const Color(0xFF7A4B22),
    Paint()..color = const Color(0xFF9C6B3A),
  ];
  static final _foam = Paint()..color = KidColors.white;
  static final _foamEdge = Paint()
    ..color = const Color(0xFFB9E3FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  static final _drop = Paint()..color = const Color(0xFF4FB3FF);
  static final _shine = Paint()..color = KidColors.white.withValues(alpha: 0.8);

  static void mud(Canvas canvas, Vector2 c, RubCell cell) {
    canvas.drawCircle(Offset(c.x, c.y), 17 * cell.scale, _mud[cell.variant]);
  }

  static void foam(Canvas canvas, Vector2 c, RubCell cell) {
    final o = Offset(c.x, c.y);
    final r = 15 * cell.scale;
    canvas
      ..drawCircle(o, r, _foam)
      ..drawCircle(o, r, _foamEdge);
  }

  static void drops(Canvas canvas, Vector2 c, RubCell cell) {
    if (cell.variant == 0) return;
    final r = 7 * cell.scale;
    final path = Path()
      ..moveTo(c.x, c.y - r * 2)
      ..quadraticBezierTo(c.x + r, c.y - r * 0.4, c.x + r, c.y)
      ..arcToPoint(Offset(c.x - r, c.y), radius: Radius.circular(r))
      ..quadraticBezierTo(c.x - r, c.y - r * 0.4, c.x, c.y - r * 2)
      ..close();
    canvas
      ..drawPath(path, _drop)
      ..drawCircle(Offset(c.x - r * 0.35, c.y - r * 0.2), r * 0.3, _shine);
  }
}

/// Simple sticker shapes drawn in code, centred in a box of [size].
abstract final class Stickers {
  static void star(Canvas canvas, Vector2 size, Color color) {
    final c = Offset(size.x / 2, size.y / 2);
    final outer = size.x * 0.48;
    final inner = outer * 0.45;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -pi / 2 + i * pi / 5;
      final p = c + Offset(cos(a) * r, sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    _drawWithOutline(canvas, path, color);
  }

  static void heart(Canvas canvas, Vector2 size, Color color) {
    final w = size.x;
    final h = size.y;
    final path = Path()
      ..moveTo(w / 2, h * 0.88)
      ..cubicTo(w * -0.1, h * 0.5, w * 0.15, h * 0.02, w / 2, h * 0.3)
      ..cubicTo(w * 0.85, h * 0.02, w * 1.1, h * 0.5, w / 2, h * 0.88)
      ..close();
    _drawWithOutline(canvas, path, color);
  }

  static void flower(Canvas canvas, Vector2 size, Color color) {
    final c = Offset(size.x / 2, size.y / 2);
    final petal = Paint()..color = color;
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3;
      canvas.drawCircle(
        c + Offset(cos(a), sin(a)) * size.x * 0.25,
        size.x * 0.18,
        petal,
      );
    }
    canvas.drawCircle(c, size.x * 0.17, Paint()..color = KidColors.sun);
  }

  static void _drawWithOutline(Canvas canvas, Path path, Color color) {
    canvas
      ..drawPath(path, Paint()..color = color)
      ..drawPath(
        path,
        Paint()
          ..color = KidColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.round,
      );
  }
}
