import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

import 'palette.dart';

/// A one-shot burst of confetti for finishing an activity.
ParticleSystemComponent confettiBurst(Vector2 at, {int count = 80}) {
  final random = Random();
  return ParticleSystemComponent(
    position: at,
    particle: Particle.generate(
      count: count,
      lifespan: 2.2,
      generator: (i) {
        final angle = random.nextDouble() * 2 * pi;
        final speed = 250 + random.nextDouble() * 450;
        return AcceleratedParticle(
          speed: Vector2(cos(angle), sin(angle) - 0.8) * speed,
          acceleration: Vector2(0, 600),
          child: CircleParticle(
            radius: 6 + random.nextDouble() * 8,
            paint: Paint()
              ..color = KidColors.confetti[i % KidColors.confetti.length],
          ),
        );
      },
    ),
  );
}

/// A few soft particles that fade as they drift, for touch feedback.
///
/// [velocity] sets the general direction; [gravity] pulls them down (or up
/// when negative, like rising bubbles).
ParticleSystemComponent puff(
  Vector2 at, {
  required List<Color> colors,
  int count = 4,
  double radius = 9,
  Vector2? velocity,
  double gravity = 0,
  double spread = 120,
  bool ring = false,
}) {
  final random = Random();
  final base = velocity ?? Vector2.zero();
  return ParticleSystemComponent(
    position: at,
    priority: 160,
    particle: Particle.generate(
      count: count,
      lifespan: 0.9,
      generator: (i) {
        final r = radius * (0.6 + random.nextDouble() * 0.8);
        final color = colors[random.nextInt(colors.length)];
        return AcceleratedParticle(
          speed:
              base +
              Vector2(
                (random.nextDouble() - 0.5) * spread,
                (random.nextDouble() - 0.5) * spread,
              ),
          acceleration: Vector2(0, gravity),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final fade = 1 - particle.progress;
              final paint = Paint()..color = color.withValues(alpha: fade);
              if (ring) {
                paint
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3;
                canvas.drawCircle(
                  Offset.zero,
                  r,
                  Paint()..color = color.withValues(alpha: fade * 0.35),
                );
              }
              canvas.drawCircle(Offset.zero, r, paint);
            },
          ),
        );
      },
    ),
  );
}
