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
