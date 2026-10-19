import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// An animated character made in Rive, optional like all real art.
///
/// The contract with the animator: the artboard's default state machine runs
/// the idle loop, and its view model may expose triggers such as `cheer` and
/// `blink`. Missing triggers are ignored, so a plain idle animation works too.
class RiveCharacter {
  RiveCharacter._(this.artboard, this.stateMachine, this._viewModel);

  /// Set once [RiveNative.init] succeeds at startup. Tests and platforms
  /// where it fails keep using drawn art.
  static bool available = false;

  final Artboard artboard;
  final StateMachine? stateMachine;
  final ViewModelInstance? _viewModel;

  static Future<RiveCharacter?> load(String asset) async {
    if (!available) return null;
    try {
      final file = await File.asset(asset, riveFactory: Factory.flutter);
      if (file == null) return null;
      final artboard = file.defaultArtboard();
      if (artboard == null) return null;
      final stateMachine = artboard.defaultStateMachine();
      ViewModelInstance? viewModel;
      final model = file.defaultArtboardViewModel(artboard);
      if (model != null && stateMachine != null) {
        viewModel = model.createDefaultInstance();
        if (viewModel != null) stateMachine.bindViewModelInstance(viewModel);
      }
      return RiveCharacter._(artboard, stateMachine, viewModel);
    } catch (_) {
      debugPrint('No Rive file at $asset yet, using drawn art.');
      return null;
    }
  }

  /// Fires the view model trigger [name], if the animator added it.
  void fire(String name) => _viewModel?.trigger(name)?.trigger();

  RiveComponent component({required Vector2 size}) =>
      RiveComponent(artboard: artboard, stateMachine: stateMachine, size: size);
}
