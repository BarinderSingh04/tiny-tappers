"""Packs artist images into the sprite sheets the games load.

    python3 tool/pack_art.py            # every game folder in art/
    python3 tool/pack_art.py carwash    # just one

Reads art/<game>/*.png (and *.svg when cairosvg is installed) and writes:
  assets/images/<game>.png + <game>.atlas   all sprites in one sheet
  assets/images/<game>_bg.png               from art/<game>/bg.png
  assets/images/<game>_layout.json          from art/<game>/layout.json

Art is drawn at 2x the 1280 x 720 game world. Name files after what they
are; a trailing number makes a set the game picks from, e.g. mud_1.png,
mud_2.png. See art/README.md for every name the car wash looks for.
Needs Pillow: python3 -m pip install pillow
"""
import io
import re
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ART = ROOT / "art"
OUT = ROOT / "assets" / "images"
MAX_WIDTH = 4096
PADDING = 4


def load(path):
    if path.suffix.lower() == ".svg":
        try:
            import cairosvg
        except ImportError:
            sys.exit(f"{path.name}: install cairosvg to pack SVGs, or export PNG")
        return Image.open(io.BytesIO(cairosvg.svg2png(url=str(path)))).convert("RGBA")
    return Image.open(path).convert("RGBA")


def shelf_pack(images):
    """Places images left to right in rows, tallest first. Returns positions."""
    order = sorted(images, key=lambda name: -images[name].height)
    x = y = row_height = width = 0
    placed = {}
    for name in order:
        w, h = images[name].size
        if w > MAX_WIDTH:
            sys.exit(f"{name} is {w}px wide; the limit is {MAX_WIDTH}px")
        if x + w > MAX_WIDTH:
            x, y, row_height = 0, y + row_height + PADDING, 0
        placed[name] = (x, y)
        x += w + PADDING
        row_height = max(row_height, h)
        width = max(width, x)
    return placed, width, y + row_height


def region_name(stem):
    """mud_2 -> ("mud", 2); car_body -> ("car_body", -1)."""
    match = re.fullmatch(r"(.+?)_(\d+)", stem)
    return (match.group(1), int(match.group(2))) if match else (stem, -1)


def pack(game_dir):
    game = game_dir.name
    OUT.mkdir(parents=True, exist_ok=True)
    files = sorted(p for p in game_dir.iterdir() if p.suffix.lower() in (".png", ".svg"))

    background = next((p for p in files if p.stem == "bg"), None)
    if background:
        load(background).save(OUT / f"{game}_bg.png", optimize=True)
        print(f"{game}: background {background.name}")

    layout = game_dir / "layout.json"
    if layout.exists():
        (OUT / f"{game}_layout.json").write_text(layout.read_text())
        print(f"{game}: layout.json")

    images = {p.stem: load(p) for p in files if p.stem != "bg"}
    if not images:
        print(f"{game}: no sprites yet")
        return
    placed, width, height = shelf_pack(images)
    sheet = Image.new("RGBA", (width, height))
    lines = [f"{game}.png", f"size:{width},{height}", "format:RGBA8888",
             "filter:Linear,Linear", "repeat:none"]
    for stem in sorted(placed):
        x, y = placed[stem]
        image = images[stem]
        sheet.paste(image, (x, y))
        name, index = region_name(stem)
        lines += [name, f"bounds:{x},{y},{image.width},{image.height}", f"index:{index}"]
    sheet.save(OUT / f"{game}.png", optimize=True)
    (OUT / f"{game}.atlas").write_text("\n".join(lines) + "\n")
    print(f"{game}: {len(images)} sprites in a {width}x{height} sheet")


def main():
    games = sys.argv[1:] or [p.name for p in ART.iterdir() if p.is_dir() and p.name != "templates"]
    for game in games:
        folder = ART / game
        if not folder.is_dir():
            sys.exit(f"No folder art/{game}")
        pack(folder)


if __name__ == "__main__":
    main()
