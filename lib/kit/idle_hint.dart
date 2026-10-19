import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'palette.dart';

/// A pulsing "finger" that shows what to do after a few idle seconds.
///
/// It glides from [from] to [to] and back. Call [poke] on every
/// interaction to hide it and restart the idle timer.
class IdleHint extends PositionComponent {
  IdleHint({this.idleSeconds = 5})
    : super(size: Vector2.all(70), anchor: Anchor.center);

  final double idleSeconds;

  Vector2? from;
  Vector2? to;

  double _idle = 0;
  double _t = 0;

  final _fill = Paint()..color = KidColors.white.withValues(alpha: 0.75);
  final _ring = Paint()
    ..color = KidColors.ink.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  bool get showing => from != null && to != null && _idle >= idleSeconds;

  /// Points the hint at a new gesture and restarts the idle timer.
  void show(Vector2 start, Vector2 end) {
    from = start;
    to = end;
    poke();
  }

  void hide() {
    from = null;
    to = null;
  }

  void poke() {
    _idle = 0;
    _t = 0;
  }

  @override
  void update(double dt) {
    _idle += dt;
    if (!showing) return;
    _t += dt;
    final s = (sin(_t * 2.2 - pi / 2) + 1) / 2;
    position = from! + (to! - from!) * s;
  }

  @override
  void render(Canvas canvas) {
    if (!showing) return;
    final pulse = 1 + 0.1 * sin(_t * 8);
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(c, 26 * pulse, _fill);
    canvas.drawCircle(c, 30 * pulse, _ring);
  }
}
