import 'package:flutter/material.dart';

import 'palette.dart';

/// A small button that only opens after being held for [holdFor].
///
/// Toddlers tap; they rarely hold still for three seconds. Use it in front
/// of settings, purchases and anything that leaves the app.
class ParentGate extends StatefulWidget {
  const ParentGate({
    super.key,
    required this.onOpen,
    this.holdFor = const Duration(seconds: 3),
  });

  final VoidCallback onOpen;
  final Duration holdFor;

  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold =
      AnimationController(vsync: this, duration: widget.holdFor)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _hold.reset();
            widget.onOpen();
          }
        });

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Grown-ups: press and hold for settings',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _hold.forward(),
        onTapUp: (_) => _hold.reverse(),
        onTapCancel: () => _hold.reverse(),
        child: SizedBox(
          width: 56,
          height: 56,
          child: AnimatedBuilder(
            animation: _hold,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _hold.value,
                  strokeWidth: 5,
                  color: KidColors.white,
                ),
                Icon(
                  Icons.settings_rounded,
                  color: KidColors.white.withValues(alpha: 0.7),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
