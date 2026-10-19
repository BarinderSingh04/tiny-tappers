"""Generates the placeholder sound effects in assets/audio.

Run with: python3 tool/make_sounds.py
Replace these with recorded or licensed sounds before release.
"""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / "assets" / "audio"


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b"".join(
            struct.pack("<h", int(max(-1, min(1, s)) * 26000)) for s in samples))


def env(i, n, attack=0.01):
    t = i / n
    a = min(1, t / attack) if attack else 1
    return a * (1 - t) ** 2


def tone(freq_fn, seconds, wave_fn=math.sin, attack=0.01):
    n = int(RATE * seconds)
    phase = 0.0
    out = []
    for i in range(n):
        phase += 2 * math.pi * freq_fn(i / n) / RATE
        out.append(wave_fn(phase) * env(i, n, attack))
    return out


def noise(seconds, smooth=0.0, amp=0.6):
    n = int(RATE * seconds)
    last = 0.0
    out = []
    for i in range(n):
        last = last * smooth + random.uniform(-1, 1) * (1 - smooth)
        out.append(last * amp * env(i, n, 0.05))
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] if i < len(t) else 0 for t in tracks) / len(tracks) for i in range(n)]


def notes(freqs, each):
    out = []
    for f in freqs:
        out += tone(lambda t, f=f: f, each)
    return out


random.seed(4)
write("pop.wav", tone(lambda t: 900 - 600 * t, 0.12))
write("boing.wav", tone(lambda t: 220 + 120 * math.sin(t * 30) * (1 - t), 0.45))
write("squeak.wav", tone(lambda t: 1200 + 800 * t, 0.15))
write("scrub.wav", noise(0.25, smooth=0.6))
write("splash.wav", noise(0.4, smooth=0.3, amp=0.8))
write("honk.wav", mix(
    tone(lambda t: 392, 0.35, lambda p: 1 if math.sin(p) > 0 else -1, 0.05),
    tone(lambda t: 494, 0.35, lambda p: 1 if math.sin(p) > 0 else -1, 0.05),
))
# Pentatonic arpeggio: C D E G A C.
write("cheer.wav", notes([523, 587, 659, 784, 880, 1047], 0.13))
