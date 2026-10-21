"""Make a closed-eyes overlay from a car body sprite.

Paints over each open eye with a smooth fill taken from the surrounding
body (a harmonic fill, so there are no seams), then draws a sleepy arc.

  python3 tool/blink_layer.py art/carwash/car_body.png art/carwash/car_eyes_closed.png \
      --eye 592,168,27 --eye 679,167,27
"""
import argparse

import numpy as np
from PIL import Image, ImageDraw

LID = (58, 26, 32, 255)


def fill_disk(rgb, cx, cy, r, iterations=4000):
    pad = r + 3
    x0, y0, x1, y1 = cx - pad, cy - pad, cx + pad + 1, cy + pad + 1
    patch = rgb[y0:y1, x0:x1].astype(np.float64)
    yy, xx = np.mgrid[y0:y1, x0:x1]
    hole = (xx - cx) ** 2 + (yy - cy) ** 2 <= r * r
    # Start from the mean of the ring so convergence is quick.
    patch[hole] = patch[~hole].mean(axis=0)
    for _ in range(iterations):
        avg = (np.roll(patch, 1, 0) + np.roll(patch, -1, 0) +
               np.roll(patch, 1, 1) + np.roll(patch, -1, 1)) / 4
        patch[hole] = avg[hole]
    rgb[y0:y1, x0:x1] = patch
    return hole, (x0, y0)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('body')
    p.add_argument('out')
    p.add_argument('--eye', action='append', required=True,
                   help='cx,cy,r of the white of each eye, in sprite pixels')
    a = p.parse_args()

    body = Image.open(a.body).convert('RGBA')
    rgba = np.array(body).astype(np.float64)
    out = np.zeros_like(rgba)
    eyes = [tuple(int(v) for v in e.split(',')) for e in a.eye]
    for cx, cy, r in eyes:
        hole, (x0, y0) = fill_disk(rgba[..., :3], cx, cy, r + 4)
        h, w = hole.shape
        out[y0:y0 + h, x0:x0 + w, :3][hole] = rgba[y0:y0 + h, x0:x0 + w, :3][hole]
        out[y0:y0 + h, x0:x0 + w, 3][hole] = 255

    layer = Image.fromarray(out.clip(0, 255).astype(np.uint8), 'RGBA')
    ss = 4
    lids = Image.new('RGBA', (body.width * ss, body.height * ss))
    d = ImageDraw.Draw(lids)
    for cx, cy, r in eyes:
        box = [(cx - .8 * r) * ss, (cy - .9 * r) * ss,
               (cx + .8 * r) * ss, (cy + .5 * r) * ss]
        d.arc(box, 25, 155, fill=LID, width=7 * ss)
    lids = lids.resize(body.size, Image.LANCZOS)
    Image.alpha_composite(layer, lids).save(a.out)


if __name__ == '__main__':
    main()
