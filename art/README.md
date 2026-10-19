# Art for Tiny Tappers

Every game runs on art drawn in code, so it is always playable. Real art
replaces it piece by piece: drop files into `art/<game>/`, pack them, and the
game picks them up on the next run. Anything missing keeps its drawn version.

## Workflow

1. Start from the templates in `art/templates/<game>/`. They show every file
   the game looks for, at the exact size, named correctly. Regenerate them
   with `flutter test tool/export_templates_test.dart`.
2. Paint or generate each piece (Gemini, an illustrator, or both) at the same
   size and with a transparent background, then save it in `art/<game>/` with
   the same name. SVG works too if `cairosvg` is installed.
3. Run `python3 tool/pack_art.py` (needs `python3 -m pip install pillow`). It
   writes the sprite sheet and background into `assets/images/`.
4. Run the app. Record each file's source and licence in `assets/CREDITS.md`.

## Rules

- Everything is drawn at **2x** the 1280 × 720 game world, so a sprite shown
  100 units wide is 200 px.
- A trailing number makes a set the game picks from: `mud_1.png`, `mud_2.png`.
- Keep the outline inside the canvas; transparent pixels decide where mud can
  go and where stickers can land.
- Moving parts are separate files (the wheels are not part of the car body).

## Car wash (`art/carwash/`)

| File | Size (px) | What it is |
| --- | --- | --- |
| `bg.png` | 2560 × 1440 | The whole scene behind the car: sky, building, floor |
| `car_body.png` or `car_body_1.png` … | 1120 × 620 | The car without wheels; numbered versions are used in turn, one per round |
| `car_wheel.png` | 208 × 208 | One wheel, centred; the game spins it |
| `car_eyes_closed.png` | 1120 × 620 | Optional overlay shown while the car blinks |
| `mud_1.png` … | 68 × 68 | Mud blobs, scrubbed off first |
| `foam_1.png` … | 68 × 68 | Foam bubbles, rinsed off second |
| `drop_1.png` … | 68 × 68 | Water drops, dried off last |
| `tool_sponge.png`, `tool_hose.png`, `tool_towel.png` | 260 × 220 | The tool under the child's finger, centred |
| `sticker_1.png` … | 192 × 192 | Stickers on the shelf, any number |

## Animated characters (Rive)

Save a Rive file as `assets/rive/<game>_<name>.riv`, for example
`assets/rive/carwash_car.riv`. It replaces the car entirely. The artboard's
default state machine should play the idle loop, and its view model can add
a `cheer` trigger, fired after each wash stage. If Rive can't start (on the
web it downloads its engine), the drawn car is used.
