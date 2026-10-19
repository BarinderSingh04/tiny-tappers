import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';

/// Which parts of an image are solid, sampled on a coarse grid.
///
/// Used to make rub layers follow the real outline of an artist's sprite.
class AlphaMask {
  AlphaMask(this.width, this.height, this._solid);

  final int width;
  final int height;
  final Uint8List _solid;

  /// Samples [sprite] every [step] source pixels; alpha above half is solid.
  static Future<AlphaMask> fromSprite(Sprite sprite, {int step = 4}) async {
    final data = await sprite.image.toByteData(format: ImageByteFormat.rawRgba);
    final imageWidth = sprite.image.width;
    final src = sprite.src;
    final w = (src.width / step).ceil();
    final h = (src.height / step).ceil();
    final solid = Uint8List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final px = (src.left + x * step).toInt();
        final py = (src.top + y * step).toInt();
        final alpha = data!.getUint8((py * imageWidth + px) * 4 + 3);
        solid[y * w + x] = alpha > 127 ? 1 : 0;
      }
    }
    return AlphaMask(w, h, solid);
  }

  /// Whether [point], given in a box of [size], lands on a solid pixel.
  bool contains(Vector2 point, Vector2 size) {
    final x = (point.x / size.x * width).floor();
    final y = (point.y / size.y * height).floor();
    if (x < 0 || y < 0 || x >= width || y >= height) return false;
    return _solid[y * width + x] == 1;
  }
}
