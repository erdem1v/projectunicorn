"""After render_pages.sh: the 1280x720 legibility checks and the round copies.
  10a: the 1920x1080 shell at 100 % in a 1280x720 window (x 2/3)
  10b: the 1536x864 shell at 125 % in a 1280x720 window (x 5/6), what the corrected scale gate allows (SPEC §8)
  python split_pages.py <pages_dir> <round_tag or ""> <rounds_dir>
"""
import glob
import os
import shutil
import sys

from PIL import Image

pages, tag, rounds = sys.argv[1], sys.argv[2], sys.argv[3]
Image.open(os.path.join(pages, "s1_ekran_1920.png")).convert("RGB").resize((1280, 720), Image.LANCZOS).save(
    os.path.join(pages, "l1_okunurluk_1280x720_yuzde100.png"), optimize=True)
Image.open(os.path.join(pages, "s2_ekran_1536.png")).convert("RGB").resize((1280, 720), Image.LANCZOS).save(
    os.path.join(pages, "l2_okunurluk_1280x720_yuzde125.png"), optimize=True)
if tag:
    d = os.path.join(rounds, tag)
    os.makedirs(d, exist_ok=True)
    for p in glob.glob(os.path.join(pages, "*.png")):
        shutil.copy(p, d)
print("pages written:", pages)
