import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hub/hub_screen.dart';
import 'kit/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await AudioService.instance.preload();
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
        useMaterial3: true,
      ),
      home: const HubScreen(),
    );
  }
}
