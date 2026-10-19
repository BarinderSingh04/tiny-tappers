import 'package:flame_rive/flame_rive.dart' show RiveNative;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hub/hub_screen.dart';
import 'kit/audio_service.dart';
import 'kit/palette.dart';
import 'kit/rive_art.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await AudioService.instance.preload();
  try {
    // On the web Rive fetches its engine from a CDN, so never let a slow or
    // offline network hold up a toddler's game: fall back to drawn art.
    await RiveNative.init().timeout(const Duration(seconds: 3));
    RiveCharacter.available = true;
  } catch (e) {
    debugPrint('Rive unavailable, using drawn characters: $e');
  }
  runApp(const TinyTappersApp());
}

class TinyTappersApp extends StatelessWidget {
  const TinyTappersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Tappers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3A86FF),
        fontFamily: kidFont,
        useMaterial3: true,
      ),
      home: const HubScreen(),
    );
  }
}
