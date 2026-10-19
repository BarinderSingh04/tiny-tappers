import 'package:flutter/material.dart';

import 'audio_service.dart';
import 'palette.dart';

/// A big round button back to the game hub.
class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KidColors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AudioService.instance.play(AudioService.pop);
          Navigator.of(context).maybePop();
        },
        child: const SizedBox(
          width: 80,
          height: 80,
          child: Icon(Icons.home_rounded, size: 48, color: KidColors.blue),
        ),
      ),
    );
  }
}
