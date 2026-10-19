import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'rub_grid.dart';

/// How a covered cell is drawn, e.g. a mud blob, a bubble or a water drop.
typedef CellPainter = void Function(
  Canvas canvas,
  Vector2 center,
  RubCell cell,
);

/// A layer the child clears by rubbing a finger over it.
///
/// Once [completeAt] of the cells are cleared, the rest vanish and
/// [onComplete] fires, so toddlers never have to hunt for the last speck.
class RubSurface extends PositionComponent with DragCallbacks {
  RubSurface({
    required super.size,
    required this.paintCell,
    required this.onComplete,
    this.mask,
    this.onRub,
    this.onRubEnd,
    this.cellSize = 22,
    this.eraseRadius = 48,
    this.completeAt = 0.85,
    this.seed = 1,
    super.position,
  });

  final CellPainter paintCell;
  final VoidCallback onComplete;
  final bool Function(Vector2 point)? mask;

  /// Called on every rub with the finger position in local coordinates.
  final void Function(Vector2 point)? onRub;

  /// Called when the finger lifts.
  final VoidCallback? onRubEnd;
  final double cellSize;
  final double eraseRadius;
  final double completeAt;
  final int seed;

  late final RubGrid grid;
  bool _completed = false;

  @override
  Future<void> onLoad() async {
    grid = RubGrid(size: size, cellSize: cellSize, mask: mask, seed: seed);
  }

  @override
  void render(Canvas canvas) {
    for (final cell in grid.cells) {
      if (cell.covered) paintCell(canvas, cell.center + cell.jitter, cell);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _rubAt(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _rubAt(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    onRubEnd?.call();
  }

  void _rubAt(Vector2 point) {
    if (_completed) return;
    onRub?.call(point);
    grid.erase(point, eraseRadius);
    if (grid.progress >= completeAt) {
      _completed = true;
      grid.clearAll();
      onComplete();
    }
  }
}
