import 'package:flutter/material.dart';

import '../kit/audio_service.dart';

/// Grown-ups only: reached through the parent gate.
class ParentSettings extends StatelessWidget {
  const ParentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final soundOn = AudioService.instance.soundOn;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For grown-ups',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: soundOn,
              builder: (context, on, _) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sounds'),
                value: on,
                onChanged: (value) => soundOn.value = value,
              ),
            ),
            const Text(
              'Tiny Tappers collects no data, shows no ads and needs no account.',
            ),
          ],
        ),
      ),
    );
  }
}
