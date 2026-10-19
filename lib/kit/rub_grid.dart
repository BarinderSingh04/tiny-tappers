import 'dart:math';

import 'package:flame/components.dart';

/// Tracks which cells of a rubbable layer are still covered.
///
/// Pure logic with no rendering, so the clean-up rules can be unit tested.
class RubGrid {
  RubGrid({
    required this.size,
    required this.cellSize,
    bool Function(Vector2 point)? mask,
    int seed = 1,
  }) {
    final random = Random(seed);
    final cols = (size.x / cellSize).ceil();
    final rows = (size.y / cellSize).ceil();
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final center = Vector2((col + 0.5) * cellSize, (row + 0.5) * cellSize);
        if (mask == null || mask(center)) {
          cells.add(
            RubCell(
              center: center,
              jitter: Vector2(
                (random.nextDouble() - 0.5) * cellSize * 0.6,
                (random.nextDouble() - 0.5) * cellSize * 0.6,
              ),
              scale: 0.7 + random.nextDouble() * 0.6,
              variant: random.nextInt(3),
            ),
          );
        }
      }
    }
  }

  final Vector2 size;
  final double cellSize;
  final List<RubCell> cells = [];

  int get coveredCount => cells.where((c) => c.covered).length;

  /// Share of cells cleared so far, from 0 to 1.
  double get progress => cells.isEmpty ? 1 : 1 - coveredCount / cells.length;

  /// Clears every cell within [radius] of [point]. Returns how many cleared.
  int erase(Vector2 point, double radius) {
    var cleared = 0;
    final r2 = radius * radius;
    for (final cell in cells) {
      if (cell.covered && cell.center.distanceToSquared(point) <= r2) {
        cell.covered = false;
        cleared++;
      }
    }
    return cleared;
  }

  void clearAll() {
    for (final cell in cells) {
      cell.covered = false;
    }
  }
}

class RubCell {
  RubCell({
    required this.center,
    required this.jitter,
    required this.scale,
    required this.variant,
  });

  final Vector2 center;
  final Vector2 jitter;
  final double scale;
  final int variant;
  bool covered = true;
}
