import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_tappers/kit/alpha_mask.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('follows the solid pixels of a sprite', () async {
    // A 40 × 20 image whose left half is solid and right half transparent.
    final recorder = PictureRecorder();
    Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 20, 20),
      Paint()..color = const Color(0xFF000000),
    );
    final image = await recorder.endRecording().toImage(40, 20);
    final mask = await AlphaMask.fromSprite(Sprite(image), step: 2);

    final box = Vector2(400, 200);
    expect(mask.contains(Vector2(50, 100), box), isTrue);
    expect(mask.contains(Vector2(350, 100), box), isFalse);
    expect(mask.contains(Vector2(-5, 100), box), isFalse);
  });
}
