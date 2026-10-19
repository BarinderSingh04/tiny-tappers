import 'dart:ui';

import 'package:flame/components.dart';

import 'car_art.dart';

/// The car in the wash. Spins its wheels as it moves and blinks now and then.
class Car extends PositionComponent {
  Car({required this.bodyColor})
    : super(size: Vector2(560, 310), anchor: Anchor.center);

  Color bodyColor;

  /// Whether [point] (local coordinates) is on the car's paintwork.
  static bool isOnCar(Vector2 point) =>
      CarArt.contains(Offset(point.x, point.y));

  double _wheelAngle = 0;
  double? _lastX;
  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    final last = _lastX;
    if (last != null) _wheelAngle += (position.x - last) / 50;
    _lastX = position.x;
  }

  double get _blink {
    // A quick blink roughly every 3.5 seconds.
    final t = _time % 3.5;
    if (t > 0.18) return 0;
    return 1 - (t / 0.09 - 1).abs();
  }

  @override
  void render(Canvas canvas) {
    CarArt.paint(
      canvas,
      color: bodyColor,
      wheelAngle: _wheelAngle,
      blink: _blink,
    );
  }
}
