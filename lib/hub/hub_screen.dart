import 'package:flutter/material.dart';

import '../games/car_wash/car_wash_screen.dart';
import '../kit/audio_service.dart';
import '../kit/palette.dart';
import '../kit/parent_gate.dart';
import 'parent_settings.dart';

/// One tile on the hub. Games without a [builder] are still being made.
class HubGame {
  const HubGame(this.name, this.icon, this.color, [this.builder]);

  final String name;
  final IconData icon;
  final Color color;
  final WidgetBuilder? builder;
}

final hubGames = [
  HubGame(
    'Car wash',
    Icons.local_car_wash_rounded,
    KidColors.blue,
    (_) => const CarWashScreen(),
  ),
  const HubGame('Cake maker', Icons.cake_rounded, KidColors.pink),
  const HubGame('Pizza kitchen', Icons.local_pizza_rounded, KidColors.orange),
  const HubGame('Shape puzzles', Icons.extension_rounded, KidColors.purple),
];

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.sky,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [for (final game in hubGames) _GameTile(game)],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
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
    );
  }
}

class _GameTile extends StatefulWidget {
  const _GameTile(this.game);

  final HubGame game;

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  double _scale = 1;

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
    final ready = widget.game.builder != null;
    return Semantics(
      label: widget.game.name,
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.92),
        onTapUp: (_) => setState(() => _scale = 1),
        onTapCancel: () => setState(() => _scale = 1),
        onTap: _open,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Opacity(
            opacity: ready ? 1 : 0.45,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: widget.game.color,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: KidColors.white, width: 6),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    color: Color(0x33000000),
                  ),
                ],
              ),
              child: Icon(widget.game.icon, size: 100, color: KidColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
