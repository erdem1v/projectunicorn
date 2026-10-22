"""build_review: embed wave JSONs into the review page template.

Usage: python -I build_review.py <template.html> <out.html> <wave.json>[=<review line>] [...]
Each wave gets a check_line from wavecheck (error and warning counts) plus the optional review line, and its JSON goes
in as a <script type="application/json" data-wave="..."> block.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wavecheck  # noqa: E402

TITLES = {"W1": "Acil durumlar", "W2": "Sprint ortası kâğıtları", "W3": "Söz, teşekkür ve sürüm yorumları"}


def main():
    tpl, out, args = sys.argv[1], sys.argv[2], sys.argv[3:]
    blocks = []
    for arg in args:
        path, _, review = arg.partition("=")
        wave = json.load(open(path, encoding="utf-8"))
        _, e, w = wavecheck.check(wave)
        wave.setdefault("title_tr", TITLES.get(wave.get("wave"), "Yazım dalgası"))
        wave["check_line"] = f"Mekanik denetim: {e} hata, {w} uyarı · " + (review or "Opus eleştirisi bekleniyor")
        data = json.dumps(wave, ensure_ascii=False).replace("</", "<\\u002f")
        blocks.append(f'<script type="application/json" data-wave="{wave["wave"]}">{data}</script>')
    html = open(tpl, encoding="utf-8").read().replace("<!--WAVES-->", "\n".join(blocks))
    open(out, "w", encoding="utf-8").write(html)
    print(f"BUILD {out} waves={len(blocks)} bytes={len(html.encode('utf-8'))}")


if __name__ == "__main__":
    main()
