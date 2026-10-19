import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_tappers/kit/rub_grid.dart';
import 'package:tiny_tappers/kit/step_sequencer.dart';

void main() {
  group('RubGrid', () {
    test('starts fully covered and clears where rubbed', () {
      final grid = RubGrid(size: Vector2(200, 100), cellSize: 20);
      expect(grid.progress, 0);
      final cleared = grid.erase(Vector2(10, 10), 15);
      expect(cleared, greaterThan(0));
      expect(grid.progress, greaterThan(0));
    });

    test('only creates cells inside the mask', () {
      final grid = RubGrid(
        size: Vector2(200, 100),
        cellSize: 20,
        mask: (p) => p.x < 100,
      );
      expect(grid.cells.every((c) => c.center.x < 100), isTrue);
      expect(grid.cells.length, 25);
    });

    test('clearAll finishes the layer', () {
      final grid = RubGrid(size: Vector2(100, 100), cellSize: 20)..clearAll();
      expect(grid.progress, 1);
    });
  });

  group('StepSequencer', () {
    test('runs steps in order then finishes', () {
      final log = <String>[];
      final dones = <void Function()>[];
      final seq = StepSequencer(
        steps: [
          (done) {
            log.add('a');
            dones.add(done);
          },
          (done) {
            log.add('b');
            dones.add(done);
          },
        ],
        onFinished: () => log.add('end'),
      )..start();
      expect(log, ['a']);
      dones[0]();
      expect(log, ['a', 'b']);
      dones[1]();
      expect(log, ['a', 'b', 'end']);
      expect(seq.isFinished, isTrue);
    });

    test('ignores a stage finishing twice', () {
      var finished = 0;
      final dones = <void Function()>[];
      StepSequencer(
        steps: [dones.add, dones.add],
        onFinished: () => finished++,
      ).start();
      dones[0]();
      dones[0]();
      expect(dones.length, 2);
      dones[1]();
      expect(finished, 1);
    });
  });
}
