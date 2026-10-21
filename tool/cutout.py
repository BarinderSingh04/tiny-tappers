"""Cuts an AI-generated image out of its plain white background.

    python3 tool/cutout.py input.png art/carwash/car_body.png --size 1120x620

Removes the white that touches the image border (white inside the subject,
like eye shines, is kept), softens the edge, crops to the subject and
centres it on a transparent canvas of --size, scaled to fit.
Needs Pillow: python3 -m pip install pillow
"""
import argparse
from collections import deque

from PIL import Image


def remove_background(image, threshold=225):
    """Clears near-white pixels connected to the border, then feathers edges."""
    image = image.convert("RGBA")
    w, h = image.size
    px = image.load()

    def is_white(x, y):
        r, g, b, _ = px[x, y]
        return min(r, g, b) >= threshold

    background = bytearray(w * h)
    queue = deque()
    for x in range(w):
        queue.extend([(x, 0), (x, h - 1)])
    for y in range(h):
        queue.extend([(0, y), (w - 1, y)])
    while queue:
        x, y = queue.popleft()
        i = y * w + x
        if background[i] or not is_white(x, y):
            continue
        background[i] = 1
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and not background[ny * w + nx]:
                queue.append((nx, ny))

    for y in range(h):
        for x in range(w):
            i = y * w + x
            if background[i]:
                px[x, y] = (0, 0, 0, 0)
                continue
            # Edge pixels next to the background are part white: unmix them.
            near = any(
                0 <= x + dx < w and 0 <= y + dy < h and background[(y + dy) * w + x + dx]
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
            )
            if near:
                r, g, b, _ = px[x, y]
                alpha = max(0.0, min(1.0, (255 - min(r, g, b)) / (255 - threshold * 0.4)))
                if alpha <= 0.02:
                    px[x, y] = (0, 0, 0, 0)
                else:
                    un = lambda c: int(max(0, min(255, (c - 255 * (1 - alpha)) / alpha)))
                    px[x, y] = (un(r), un(g), un(b), int(alpha * 255))
    return image


def fit(image, size, pad_bottom=0):
    """Crops to the subject and centres it on a transparent canvas of size,
    keeping pad_bottom pixels free underneath (room for wheels, say)."""
    image = image.crop(image.getbbox())
    room = (size[0], size[1] - pad_bottom)
    scale = min(room[0] / image.width, room[1] / image.height)
    image = image.resize((round(image.width * scale), round(image.height * scale)), Image.LANCZOS)
    canvas = Image.new("RGBA", size)
    canvas.paste(image, ((room[0] - image.width) // 2, (room[1] - image.height) // 2))
    return canvas, scale


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--size", help="canvas size, e.g. 1120x620")
    parser.add_argument("--pad-bottom", type=int, default=0, help="pixels left empty below")
    args = parser.parse_args()
    image = remove_background(Image.open(args.input))
    if args.size:
        image, _ = fit(image, tuple(int(v) for v in args.size.split("x")), args.pad_bottom)
    else:
        image = image.crop(image.getbbox())
    image.save(args.output, optimize=True)
    print(f"Saved {args.output} ({image.width}x{image.height})")


if __name__ == "__main__":
    main()
