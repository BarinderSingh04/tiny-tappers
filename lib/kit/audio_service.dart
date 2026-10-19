import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Sound effects shared by every game, with a parent-controlled mute.
///
/// Missing files or a missing audio plugin (as in tests) never crash play.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const pop = 'pop.wav';
  static const scrub = 'scrub.wav';
  static const splash = 'splash.wav';
  static const squeak = 'squeak.wav';
  static const boing = 'boing.wav';
  static const honk = 'honk.wav';
  static const cheer = 'cheer.wav';

  static const all = [pop, scrub, splash, squeak, boing, honk, cheer];

  final ValueNotifier<bool> soundOn = ValueNotifier(true);

  /// Turned off in tests, where no audio plugin is registered.
  bool enabled = true;

  final Map<String, DateTime> _lastPlayed = {};

  Future<void> preload() async {
    if (!enabled) return;
    try {
      await FlameAudio.audioCache.loadAll(all);
    } catch (e) {
      debugPrint('Audio preload failed: $e');
    }
  }

  /// Plays [file], skipping it if it already played within [minGap].
  void play(String file, {double volume = 1, Duration minGap = Duration.zero}) {
    if (!enabled || !soundOn.value) return;
    final now = DateTime.now();
    final last = _lastPlayed[file];
    if (last != null && now.difference(last) < minGap) return;
    _lastPlayed[file] = now;
    unawaited(
      FlameAudio.play(file, volume: volume).then(
        (_) {},
        onError: (Object e) => debugPrint('Audio play failed: $e'),
      ),
    );
  }
}
