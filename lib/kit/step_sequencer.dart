import 'package:flutter/foundation.dart';

/// One stage of an activity. Call [done] once the child has finished it.
typedef GameStep = void Function(VoidCallback done);

/// Runs a recipe of stages in order, then calls [onFinished].
///
/// A stage's `done` callback only advances once, so a stray second call
/// (for example two fingers finishing at the same time) is ignored.
class StepSequencer {
  StepSequencer({required this.steps, required this.onFinished});

  final List<GameStep> steps;
  final VoidCallback onFinished;

  int _index = -1;

  /// The stage currently running, or -1 before [start].
  int get index => _index;

  bool get isFinished => _index >= steps.length;

  void start() {
    _index = -1;
    _advance();
  }

  void _advance() {
    _index++;
    if (_index >= steps.length) {
      onFinished();
      return;
    }
    final current = _index;
    steps[current](() {
      if (_index == current) _advance();
    });
  }
}
