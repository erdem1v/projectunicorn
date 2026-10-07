"""1:1 (or 2x) crops of a rendered frame for review: python crop.py <png> <x> <y> <w> <h> [scale] [out]"""
import os
import sys
from PIL import Image

p, x, y, w, h = sys.argv[1], *map(int, sys.argv[2:6])
k = float(sys.argv[6]) if len(sys.argv) > 6 else 1.0
out = sys.argv[7] if len(sys.argv) > 7 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "rounds", "crops",
                                                        "%s_%d_%d.png" % (os.path.splitext(os.path.basename(p))[0], x, y))
im = Image.open(p).crop((x, y, x + w, y + h))
if k != 1:
    im = im.resize((int(w * k), int(h * k)), Image.NEAREST)
im.save(out)
print(os.path.normpath(out))
