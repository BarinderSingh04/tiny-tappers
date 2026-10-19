import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';

import '../../kit/audio_service.dart';
import '../../kit/confetti.dart';
import '../../kit/draggable_item.dart';
import '../../kit/idle_hint.dart';
import '../../kit/palette.dart';
import '../../kit/rub_surface.dart';
import '../../kit/step_sequencer.dart';
import 'car.dart';
import 'props.dart';

/// Car wash: scrub off the mud, rinse the foam, dry the drops, add stickers.
///
/// When the car is done it drives away and a new colour arrives, so the
/// loop never ends in a menu a toddler can't read.
class CarWashGame extends FlameGame {
  CarWashGame()
    : super(
        camera: CameraComponent.withFixedResolution(width: 1280, height: 720),
      );

  static final carSpot = Vector2(640, 380);
  static const _carColors = [
    KidColors.red,
    KidColors.blue,
    KidColors.orange,
    KidColors.purple,
    KidColors.pink,
  ];
  static const _stickerColors = [
    KidColors.sun,
    KidColors.pink,
    KidColors.purple,
    KidColors.blue,
    KidColors.orange,
  ];

  final audio = AudioService.instance;

  late Car car;
  late final IdleHint hint;
  late final StageDots dots;
  late final ToolCursor toolCursor;
  int round = 0;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    hint = IdleHint()..priority = 200;
    toolCursor = ToolCursor()..priority = 150;
    dots = StageDots(count: 4, position: Vector2(640, 50));
    await world.addAll([Backdrop(), dots, hint, toolCursor]);
    _startRound();
  }

  void _startRound() {
    dots.done = 0;
    car = Car(bodyColor: _carColors[round % _carColors.length])
      ..position = Vector2(-400, carSpot.y);
    world.add(car);
    car.add(
      MoveToEffect(
        carSpot,
        EffectController(duration: 1.4, curve: Curves.easeOutCubic),
        onComplete: () {
          audio.play(AudioService.honk);
          StepSequencer(
            steps: [
              (done) => _rubStep(
                done,
                WashTool.sponge,
                Grime.mud,
                AudioService.scrub,
              ),
              (done) => _rubStep(
                done,
                WashTool.hose,
                Grime.foam,
                AudioService.splash,
              ),
              (done) => _rubStep(
                done,
                WashTool.towel,
                Grime.drops,
                AudioService.squeak,
              ),
              _stickerStep,
            ],
            onFinished: _finishRound,
          ).start();
        },
      ),
    );
  }

  void _rubStep(
    VoidCallback done,
    WashTool tool,
    CellPainter look,
    String sound,
  ) {
    toolCursor.tool = tool;
    late final RubSurface surface;
    surface = RubSurface(
      size: car.size,
      mask: Car.isOnCar,
      paintCell: look,
      seed: round * 10 + tool.index,
      onRub: (point) {
        hint.poke();
        toolCursor.showAt(car.absolutePositionOf(point));
        audio.play(sound, minGap: const Duration(milliseconds: 300));
      },
      onRubEnd: () => toolCursor.visible = false,
      onComplete: () {
        toolCursor.visible = false;
        hint.hide();
        dots.done++;
        audio.play(AudioService.pop);
        surface.removeFromParent();
        done();
      },
    );
    car.add(surface);
    hint.show(
      car.absolutePositionOf(Vector2(120, 180)),
      car.absolutePositionOf(Vector2(440, 180)),
    );
  }

  void _stickerStep(VoidCallback done) {
    const needed = 3;
    final drawers = [Stickers.star, Stickers.heart, Stickers.flower];
    final tray = <DraggableItem>[];
    var placed = 0;

    for (var i = 0; i < 5; i++) {
      final color = _stickerColors[i];
      final draw = drawers[i % drawers.length];
      tray.add(
        DraggableItem(
          size: Vector2.all(96),
          position: Vector2(240 + i * 200.0, 640),
          draw: (canvas, size) => draw(canvas, size, color),
          accepts: (center) => Car.isOnCar(car.absoluteToLocal(center)),
          onPickUp: () {
            hint.poke();
            audio.play(AudioService.squeak);
          },
          onReturned: () => audio.play(AudioService.boing),
          onDropped: (item, center) {
            audio.play(AudioService.pop);
            item
              ..parent = car
              ..position = car.absoluteToLocal(center)
              ..scale = Vector2.all(0.8);
            placed++;
            if (placed == needed) {
              for (final left in tray.where((t) => !t.locked)) {
                left.add(RemoveEffect(delay: 0.1));
              }
              hint.hide();
              dots.done++;
              done();
            }
          },
        ),
      );
    }
    world.addAll(tray);
    hint.show(Vector2(240, 640), carSpot.clone());
  }

  void _finishRound() {
    audio.play(AudioService.cheer);
    world.add(confettiBurst(Vector2(640, 260)));
    car.add(
      SequenceEffect(
        [
          ScaleEffect.to(
            Vector2.all(1.08),
            EffectController(duration: 0.25, alternate: true, repeatCount: 2),
          ),
          MoveToEffect(
            Vector2(1700, carSpot.y),
            EffectController(
              duration: 1.3,
              startDelay: 1.2,
              curve: Curves.easeInCubic,
            ),
            onComplete: () => audio.play(AudioService.honk),
          ),
        ],
        onComplete: () {
          car.removeFromParent();
          round++;
          _startRound();
        },
      ),
    );
  }
}
