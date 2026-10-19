import 'dart:math';

import 'package:flutter/material.dart';

import '../games/car_wash/car_wash_screen.dart';
import '../kit/audio_service.dart';
import '../kit/palette.dart';
import '../kit/parent_gate.dart';
import '../kit/scenery.dart';
import 'parent_settings.dart';
import 'tile_art.dart';

/// One tile on the hub. Games without a [builder] are still being made.
class HubGame {
  const HubGame(this.name, this.art, this.color, [this.builder]);

  final String name;
  final void Function(Canvas canvas, Size size) art;
  final Color color;
  final WidgetBuilder? builder;
}

final hubGames = [
  HubGame('Car wash', HubArt.car, KidColors.blue, (_) => const CarWashScreen()),
  const HubGame('Cake maker', HubArt.cake, KidColors.pink),
  const HubGame('Pizza kitchen', HubArt.pizza, KidColors.orange),
  const HubGame('Shape puzzles', HubArt.puzzle, KidColors.purple),
];

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _HubScenery())),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 12),
                    const _Title(),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                for (final game in hubGames)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: _GameTile(game),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 16,
                  child: ParentGate(
                    onOpen: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => const ParentSettings(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubScenery extends CustomPainter {
  const _HubScenery();

  @override
  void paint(Canvas canvas, Size size) {
    Scenery.sky(canvas, size);
    Scenery.sun(canvas, Offset(size.width * 0.9, size.height * 0.16), 46);
    Scenery.cloud(canvas, Offset(size.width * 0.12, size.height * 0.2), 0.8);
    Scenery.cloud(canvas, Offset(size.width * 0.66, size.height * 0.13), 0.55);
    Scenery.hills(canvas, size, size.height * 0.72);
  }

  @override
  bool shouldRepaint(_HubScenery oldDelegate) => false;
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: kidFont,
      fontSize: 64,
      height: 1.1,
      fontVariations: [FontVariation('wght', 650)],
      letterSpacing: 1,
    );
    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(0, 6),
          child: Text(
            'Tiny Tappers',
            style: style.copyWith(color: shade(KidColors.blue, -0.2)),
          ),
        ),
        Text(
          'Tiny Tappers',
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 12
              ..strokeJoin = StrokeJoin.round
              ..color = shade(KidColors.blue, -0.2),
          ),
        ),
        Text('Tiny Tappers', style: style.copyWith(color: KidColors.white)),
      ],
    );
  }
}

class _GameTile extends StatefulWidget {
  const _GameTile(this.game);

  final HubGame game;

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool _pressed = false;

  bool get _ready => widget.game.builder != null;

  @override
  void initState() {
    super.initState();
    if (_ready) _bob.repeat();
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  void _open() {
    final builder = widget.game.builder;
    if (builder == null) {
      AudioService.instance.play(AudioService.boing);
      return;
    }
    AudioService.instance.play(AudioService.pop);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.game.color;
    final edge = shade(color, -0.18);
    final card = Container(
      width: 240,
      height: 272,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: KidColors.white, width: 7),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [shade(color, 0.12), color],
        ),
        boxShadow: [
          BoxShadow(color: edge, offset: Offset(0, _pressed ? 3 : 10)),
          BoxShadow(
            color: KidColors.ink.withValues(alpha: 0.18),
            offset: const Offset(0, 18),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Container(
            width: 186,
            height: 168,
            decoration: BoxDecoration(
              color: KidColors.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(36),
            ),
            alignment: Alignment.center,
            child: TileArt(widget.game.art),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.game.name,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: kidFont,
                  fontSize: 24,
                  fontVariations: [FontVariation('wght', 600)],
                  color: KidColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );

    return Semantics(
      label: widget.game.name,
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _open,
        child: AnimatedBuilder(
          animation: _bob,
          builder: (context, child) {
            final t = _bob.value * 2 * pi;
            return Transform.translate(
              offset: Offset(0, _pressed ? 7 : -6 * sin(t).abs()),
              child: Transform.rotate(angle: 0.025 * sin(t), child: child),
            );
          },
          child: _ready
              ? card
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ColorFiltered(colorFilter: _muted, child: card),
                    const Positioned(top: -10, right: -10, child: _SoonBadge()),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Softens a tile that isn't playable yet without turning it grey.
const _muted = ColorFilter.matrix([
  0.55, 0.3, 0.15, 0, 30, //
  0.2, 0.65, 0.15, 0, 30, //
  0.2, 0.3, 0.5, 0, 30, //
  0, 0, 0, 0.85, 0,
]);

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: KidColors.sun,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KidColors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: KidColors.ink.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 18, color: KidColors.ink),
          SizedBox(width: 4),
          Text(
            'Soon',
            style: TextStyle(
              fontFamily: kidFont,
              fontSize: 16,
              fontVariations: [FontVariation('wght', 600)],
              color: KidColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
