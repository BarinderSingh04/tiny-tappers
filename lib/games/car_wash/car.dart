import 'dart:ui';

import 'package:flame/components.dart';

import '../../kit/palette.dart';

/// A chunky cartoon car drawn in code, so the prototype needs no art files.
///
/// Swap [render] for a sprite once the real artwork is ready.
class Car extends PositionComponent {
  Car({required this.bodyColor})
    : super(size: Vector2(560, 310), anchor: Anchor.center);

  Color bodyColor;

  static final _body = RRect.fromLTRBR(
    0,
    110,
    560,
    250,
    const Radius.circular(60),
  );
  static final _cabin = RRect.fromLTRBR(
    110,
    20,
    430,
    140,
    const Radius.circular(55),
  );

  /// Whether [point] (local coordinates) is on the car's paintwork.
  static bool isOnCar(Vector2 point) {
    final o = Offset(point.x, point.y);
    return _body.contains(o) || _cabin.contains(o);
  }

  final _ink = Paint()..color = KidColors.ink;
  final _window = Paint()..color = const Color(0xFFCDEBFF);
  final _hubcap = Paint()..color = const Color(0xFFDDDDDD);
  final _light = Paint()..color = KidColors.sun;
  final _outline = Paint()
    ..color = KidColors.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = bodyColor;
    canvas
      ..drawRRect(_cabin, paint)
      ..drawRRect(_cabin, _outline)
      ..drawRRect(_body, paint)
      ..drawRRect(_body, _outline);

    // Windows with a friendly face in the front one.
    final back = RRect.fromLTRBR(145, 45, 260, 115, const Radius.circular(24));
    final front = RRect.fromLTRBR(280, 45, 400, 115, const Radius.circular(24));
    canvas
      ..drawRRect(back, _window)
      ..drawRRect(front, _window)
      ..drawCircle(const Offset(318, 75), 9, _ink)
      ..drawCircle(const Offset(362, 75), 9, _ink);
    final smile = Path()
      ..moveTo(318, 93)
      ..quadraticBezierTo(340, 110, 362, 93);
    canvas.drawPath(
      smile,
      Paint()
        ..color = KidColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Headlight and wheels.
    canvas.drawCircle(const Offset(525, 160), 18, _light);
    for (final x in [140.0, 420.0]) {
      canvas
        ..drawCircle(Offset(x, 250), 52, _ink)
        ..drawCircle(Offset(x, 250), 22, _hubcap);
    }
  }
}
