import 'dart:convert';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rive_art.dart';

/// The real artwork for one game, when it has been added.
///
/// Art is optional: every lookup returns null or an empty list when a piece
/// is missing, and each game falls back to its drawn-in-code version. So
/// artists' files can be dropped in one at a time without code changes.
///
/// Files, all made by `tool/pack_art.py` from `art/<game>/`:
/// - `assets/images/<game>.atlas` + `.png`: sprites, drawn at 2x game units.
/// - `assets/images/<game>_bg.png`: the full background, 2560 × 1440.
/// - `assets/images/<game>_layout.json`: where things sit on the art, such
///   as wheel centres, in game units.
/// - `assets/rive/<game>_<name>.riv`: animated characters.
class ArtBook {
  ArtBook._(this.game, this._atlas, this.background, this.layout);

  /// A book with no art, so everything uses the drawn fallback.
  ArtBook.empty(this.game)
    : _atlas = null,
      background = null,
      layout = const {};

  static Future<ArtBook> load(String game, Images images) async {
    TexturePackerAtlas? atlas;
    Sprite? background;
    try {
      atlas = await TexturePackerAtlas.load('$game.atlas', images: images);
    } catch (_) {
      debugPrint('No sprite atlas for $game yet, using drawn art.');
    }
    try {
      background = Sprite(await images.load('${game}_bg.png'));
    } catch (_) {
      debugPrint('No background for $game yet, using drawn scenery.');
    }
    var layout = const <String, dynamic>{};
    try {
      final text = await rootBundle.loadString(
        'assets/images/${game}_layout.json',
      );
      layout = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      // No layout: the art matches the drawn version's proportions.
    }
    return ArtBook._(game, atlas, background, layout);
  }

  final String game;
  final TexturePackerAtlas? _atlas;

  /// The full-screen background, or null to draw the scenery.
  final Sprite? background;

  /// Positions on the art from `layout.json`, keyed by piece name.
  final Map<String, dynamic> layout;

  /// The sprite exported as `<name>.png`, if any.
  Sprite? sprite(String name) => _atlas?.findSpriteByName(name);

  /// Every sprite exported as `<name>_1.png`, `<name>_2.png`, … in order.
  List<Sprite> numbered(String name) =>
      _atlas?.findSpritesByName(name) ?? const [];

  /// The Rive character exported as `assets/rive/<game>_<name>.riv`.
  Future<RiveCharacter?> character(String name) =>
      RiveCharacter.load('assets/rive/${game}_$name.riv');
}

/// Sprites are exported at twice the game's 1280 × 720 units, so they stay
/// sharp on large tablets. This is their size in game units.
Vector2 gameSize(Sprite sprite) => sprite.srcSize / 2;
