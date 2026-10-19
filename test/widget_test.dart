import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_tappers/hub/hub_screen.dart';
import 'package:tiny_tappers/kit/audio_service.dart';
import 'package:tiny_tappers/main.dart';

void main() {
  setUp(() => AudioService.instance.enabled = false);

  testWidgets('hub shows a tile for every planned game', (tester) async {
    await tester.pumpWidget(const TinyTappersApp());
    for (final game in hubGames) {
      expect(find.bySemanticsLabel(game.name), findsOneWidget);
    }
  });

  testWidgets('settings stay closed after a quick tap on the gate', (
    tester,
  ) async {
    await tester.pumpWidget(const TinyTappersApp());
    await tester.tap(
      find.bySemanticsLabel('Grown-ups: press and hold for settings'),
    );
    // The playable tile bobs forever, so settle by time instead.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('For grown-ups'), findsNothing);
  });

  testWidgets('settings open after holding the gate', (tester) async {
    await tester.pumpWidget(const TinyTappersApp());
    final gesture = await tester.startGesture(
      tester.getCenter(
        find.bySemanticsLabel('Grown-ups: press and hold for settings'),
      ),
    );
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await gesture.up();
    // The playable tile bobs forever, so settle by time instead.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('For grown-ups'), findsOneWidget);
  });
}
