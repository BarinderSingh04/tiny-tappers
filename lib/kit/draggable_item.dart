import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';

/// Something a toddler can pick up and drop.
///
/// [accepts] decides whether the drop point (in absolute coordinates) is a
/// valid target. A rejected drop floats home again instead of failing.
class DraggableItem extends PositionComponent with DragCallbacks {
  DraggableItem({
    required super.size,
    required super.position,
    required this.draw,
    required this.accepts,
    required this.onDropped,
    this.onPickUp,
    this.onReturned,
  }) : super(anchor: Anchor.center);

  final void Function(Canvas canvas, Vector2 size) draw;
  final bool Function(Vector2 absoluteCenter) accepts;
  final void Function(DraggableItem item, Vector2 absoluteCenter) onDropped;
  final VoidCallback? onPickUp;
  final VoidCallback? onReturned;

  late final Vector2 _home = position.clone();
  bool locked = false;

  @override
  void render(Canvas canvas) => draw(canvas, size);

  @override
  void onDragStart(DragStartEvent event) {
    if (locked) return;
    super.onDragStart(event);
    priority = 100;
    add(ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.1)));
    onPickUp?.call();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (locked) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (locked) return;
    add(ScaleEffect.to(Vector2.all(1), EffectController(duration: 0.1)));
    final center = absoluteCenter;
    if (accepts(center)) {
      locked = true;
      onDropped(this, center);
    } else {
      add(
        MoveToEffect(
          _home,
          EffectController(duration: 0.4, curve: Curves.easeOutBack),
          onComplete: () => onReturned?.call(),
        ),
      );
    }
  }
}
