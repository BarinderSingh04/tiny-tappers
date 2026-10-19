# Tiny Tappers

Playful, wordless mini-games for toddlers aged 2 to 5, built with Flutter and Flame.

## What's here

- **Hub** (`lib/hub/`): big game tiles and a hold-for-3-seconds parent gate in front of settings.
- **Car wash** (`lib/games/car_wash/`): scrub off the mud, rinse the foam, dry the drops, then drag on three stickers. The clean car drives away and a new colour arrives, so the loop never ends in a menu.
- **Shared kit** (`lib/kit/`), reused by every future game:
  - `RubSurface` / `RubGrid`: a layer cleared by rubbing (mud, icing, sauce, steam). It completes at 85% so toddlers never hunt for the last speck.
  - `DraggableItem`: drag and drop that floats home on a miss instead of failing.
  - `StepSequencer`: runs an activity as a recipe of stages.
  - `IdleHint`: a pulsing finger that shows what to do after 5 idle seconds.
  - `confettiBurst`, `AudioService` (with a parent mute), `ParentGate`, `HomeButton`, `KidColors`.

All art is drawn in code and the sounds in `assets/audio/` are synthesized placeholders (`python3 tool/make_sounds.py`). Swap both for real assets before release.

## Run

```sh
flutter pub get
flutter run            # phone or tablet, locked to landscape
flutter test
```

## Next games

Cake maker, pizza kitchen and shape puzzles are on the hub as "coming soon" tiles. Each can be built from the same kit: icing and sauce use `RubSurface`, toppings and puzzle pieces use `DraggableItem`, and recipes run through `StepSequencer`.
