import 'dart:ui';

import 'package:flame/components.dart';

import '../../kit/alpha_mask.dart';
import '../../kit/art_book.dart';
import '../../kit/palette.dart';
import '../../kit/rive_art.dart';
import 'car_art.dart';

/// The car in the wash. Spins its wheels as it moves and blinks now and then.
///
/// It uses the best art available, in this order:
/// 1. a Rive character (`assets/rive/carwash_car.riv`),
/// 2. sprites `car_body_N` (one per colour), `car_wheel` and
///    `car_eyes_closed` from the car wash atlas,
/// 3. the car drawn in code by [CarArt].
class Car extends PositionComponent {
  Car({required this.bodyColor, required this.art, this.variant = 0, this.rive})
    : super(size: Vector2(560, 310), anchor: Anchor.center);

  Color bodyColor;
  final ArtBook art;
  final int variant;
  final RiveCharacter? rive;

  Sprite? _body;
  Sprite? _wheel;
  Sprite? _eyesClosed;
  AlphaMask? _mask;

  List<Offset> _wheels = [for (final x in CarArt.wheelCenters) Offset(x, 250)];
  double _wheelRadius = CarArt.wheelRadius;

  double _wheelAngle = 0;
  double? _lastX;
  double _time = 0;

  @override
  Future<void> onLoad() async {
    final rive = this.rive;
    if (rive != null) {
      await add(rive.component(size: size));
      return;
    }
    final bodies = art.numbered('car_body');
    _body = bodies.isEmpty
        ? art.sprite('car_body')
        : bodies[variant % bodies.length];
    final body = _body;
    if (body != null) {
      _wheel = art.sprite('car_wheel');
      _eyesClosed = art.sprite('car_eyes_closed');
      _mask = await AlphaMask.fromSprite(body);
      _readLayout();
    }
  }

  /// Wheel centres and size from `art/carwash/layout.json`, for car art
  /// whose proportions differ from the drawn car.
  void _readLayout() {
    final car = art.layout['car'];
    if (car is! Map) return;
    final wheels = car['wheels'];
    if (wheels is List) {
      _wheels = [
        for (final w in wheels)
          Offset((w[0] as num).toDouble(), (w[1] as num).toDouble()),
      ];
    }
    final radius = car['wheelRadius'];
    if (radius is num) _wheelRadius = radius.toDouble();
  }

  /// Whether [point] (local coordinates) is on the car's paintwork.
  bool isOnCar(Vector2 point) =>
      _mask?.contains(point, size) ?? CarArt.contains(Offset(point.x, point.y));

  /// Lets a Rive car celebrate; drawn cars hop instead.
  void cheer() => rive?.fire('cheer');

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
    if (rive != null) return;
    final body = _body;
    if (body == null) {
      CarArt.paint(
        canvas,
        color: bodyColor,
        wheelAngle: _wheelAngle,
        blink: _blink,
      );
      return;
    }
    canvas.drawOval(
      const Rect.fromLTRB(10, 280, 550, 318),
      softShadow(opacity: 0.25, blur: 10),
    );
    body.render(canvas, size: size);
    final eyes = _eyesClosed;
    if (eyes != null && _blink > 0.5) eyes.render(canvas, size: size);
    for (final centre in _wheels) {
      final wheel = _wheel;
      canvas.save();
      canvas.translate(centre.dx, centre.dy);
      if (wheel == null) {
        // The drawn tyre has a radius of 50.
        canvas.scale(_wheelRadius / 50);
        CarArt.wheel(canvas, Offset.zero, _wheelAngle);
      } else {
        canvas.rotate(_wheelAngle);
        wheel.render(
          canvas,
          size: Vector2.all(_wheelRadius * 2),
          anchor: Anchor.center,
        );
      }
      canvas.restore();
    }
  }
}
