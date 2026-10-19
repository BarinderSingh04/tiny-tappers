// Renders the drawn car wash art to PNG templates for artists.
//
//   flutter test tool/export_templates_test.dart
//
// Writes art/templates/carwash/: every file the game looks for, at the exact
// size and with the right name. Artists paint over these and save the
// results in art/carwash/, then run tool/pack_art.py.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_tappers/games/car_wash/car_art.dart';
import 'package:tiny_tappers/games/car_wash/props.dart';
import 'package:tiny_tappers/kit/palette.dart';
import 'package:tiny_tappers/kit/rub_grid.dart';

const scale = 2.0;
final out = Directory('art/templates/carwash');

Future<void> save(
  String name,
  double width,
  double height,
  void Function(ui.Canvas canvas) draw,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)..scale(scale);
  draw(canvas);
  final image = await recorder.endRecording().toImage(
    (width * scale).round(),
    (height * scale).round(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('${out.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Draws [draw] shrunk around the middle of a [box]-sized square, leaving
/// room for outlines and shadows that would otherwise be cut off.
void Function(ui.Canvas) inset(double box, void Function(ui.Canvas) draw) =>
    (c) {
      c
        ..translate(box / 2, box / 2)
        ..scale(0.86)
        ..translate(-box / 2, -box / 2);
      draw(c);
    };

RubCell cell(int variant) => RubCell(
  center: Vector2.zero(),
  jitter: Vector2.zero(),
  scale: 1,
  variant: variant,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export car wash templates', () async {
    out.createSync(recursive: true);

    await save(
      'car_body',
      560,
      310,
      (c) =>
          CarArt.paint(c, color: KidColors.red, shadow: false, wheels: false),
    );
    await save(
      'car_wheel',
      104,
      104,
      (c) => CarArt.wheel(c, const ui.Offset(52, 52), 0),
    );

    final looks = {
      'mud': (Grime.mud, [0, 1, 2]),
      'foam': (Grime.foam, [0, 1, 2]),
      'drop': (Grime.drops, [1, 2]),
    };
    for (final MapEntry(key: name, value: (paint, variants)) in looks.entries) {
      for (final (i, variant) in variants.indexed) {
        await save(
          '${name}_${i + 1}',
          34,
          34,
          inset(34, (c) => paint(c, Vector2.all(17), cell(variant))),
        );
      }
    }

    for (final tool in WashTool.values) {
      final cursor = ToolCursor()
        ..tool = tool
        ..visible = true;
      await save('tool_${tool.name}', 130, 110, cursor.render);
    }

    const colors = [
      KidColors.sun,
      KidColors.pink,
      KidColors.purple,
      KidColors.blue,
      KidColors.orange,
    ];
    final shapes = [Stickers.star, Stickers.heart, Stickers.flower];
    for (var i = 0; i < colors.length; i++) {
      await save(
        'sticker_${i + 1}',
        96,
        96,
        inset(
          96,
          (c) => shapes[i % shapes.length](c, Vector2.all(96), colors[i]),
        ),
      );
    }

    await save('bg', 1280, 720, Backdrop().render);
  });
}
