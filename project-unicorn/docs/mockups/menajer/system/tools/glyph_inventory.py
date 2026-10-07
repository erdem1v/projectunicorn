"""Glyph inventory for dropping Noto Sans Symbols 2 from the text fallback chains (SPEC §3.1, review finding 13).

Scans every TR and EN value in localization/strings.csv and every string literal in scripts/**/*.gd and
scenes/**/*.tscn (debug scripts excluded) for characters that one of the new text faces lacks:
IBM Plex Sans 400/500/600/700, IBM Plex Sans Condensed 400, Barlow Condensed 600/700. Source Serif 4 and
Noto Sans Symbols 2 coverage is reported for the decision. Faces: the repo's assets/fonts plus the static
files cached in tools/fonts/ (Google Fonts static instances, same metrics as the files Faz B ships).

  python glyph_inventory.py              print the table
  python glyph_inventory.py --write-spec replace the block between the glyph markers in ../SPEC.md
"""
import collections
import csv
import glob
import os
import re
import sys

from fontTools.ttLib import TTFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", ".."))
SPEC = os.path.join(HERE, "..", "SPEC.md")
BEGIN, END = "<!-- glyph:begin -->", "<!-- glyph:end -->"
FONTS = {
    "plex400": os.path.join(ROOT, "assets/fonts/sans/IBMPlexSans-Regular.ttf"),
    "plex600": os.path.join(ROOT, "assets/fonts/sans/IBMPlexSans-SemiBold.ttf"),
    "plex500": os.path.join(HERE, "fonts/IBMPlexSans-Medium.ttf"),
    "plex700": os.path.join(HERE, "fonts/IBMPlexSans-Bold.ttf"),
    "plexc": os.path.join(HERE, "fonts/IBMPlexSansCondensed-Regular.ttf"),
    "barlow600": os.path.join(HERE, "fonts/BarlowCondensed-SemiBold.ttf"),
    "barlow700": os.path.join(HERE, "fonts/BarlowCondensed-Bold.ttf"),
    "serif": os.path.join(ROOT, "assets/fonts/serif/SourceSerif4-Regular.ttf"),
    "noto": os.path.join(ROOT, "assets/fonts/fallback/NotoSansSymbols2-Regular.ttf"),
}
# Decision per character (SPEC §3.1). "icon" = an inline [img] from the A2 family in a RichTextLabel or a
# TextureRect beside the Label; "rewrite" = change the string (TR/EN approval); "symbol" = a symbol-only
# FontVariation (Noto Symbols 2 as the base face) on that one Label, never in a text chain; "keep" = the
# character is in every text face after all (reported for completeness).
DECISION = {
    "★": ("icon", "util/star_full, star_half, star_empty as [img=14] on the text baseline; SALES_BAND_STAR becomes \"{n}\" + icon; star_rating.gd and sprint_catalog STAR draw icons (research_tree.gd hits are validation messages, never drawn)"),
    "☆": ("icon", "util/star_empty"),
    "✦": ("rewrite", "drop the ornament: \"Ayın olayı\" in caps label style is enough (MONTH_EVENT_OF_THE_MONTH, SUMMARY_EVENT_*)"),
    "▲": ("icon", "finance_ozet_view league trend: util/chevron_up at 12 px (dice.gd and sales_meeting_adapter use it as an internal sign token mapped to +/−, never drawn)"),
    "▼": ("icon", "finance_ozet_view league trend: util/chevron_down at 12 px (same internal sign token note)"),
    "▸": ("icon", "util/play at 12 px (BuildHUD action) or drop"),
    "►": ("icon", "util/play at 12 px"),
    "◂": ("icon", "util/chevron_left"),
    "◀": ("icon", "util/chevron_left"),
    "⏎": ("icon", "meeting_panel ENTER_MARK: a key-cap glyph (A2 backlog: util/enter) beside the Devam label"),
    "⇠": ("icon", "RND_CROSS_MARK: util/chevron_left (or an A2 dashed arrow) as [img] before {area}"),
    "✗": ("icon", "sprint_catalog MARK_UNMET and the office map card: util/close at 14 px in neg"),
    "✕": ("icon", "meeting_panel RESULT_GLYPHS negative: util/close at 14 px"),
    "✓": ("keep", "in Plex; Barlow lacks it, so never in a caps label"),
    "⋯": ("rewrite", "three periods or an icon button with util/more (A2 backlog)"),
    "●": ("icon", "a drawn dot (StyleBoxFlat circle), never a font glyph"),
    "○": ("icon", "a drawn ring"),
    "◆": ("icon", "the week-bar diamond is drawn, not typed"),
    "♦": ("icon", "drawn diamond"),
    "→": ("keep", "in Plex"),
    "←": ("keep", "in Plex"),
    "↑": ("keep", "in Plex"),
    "↓": ("keep", "in Plex"),
}


def cmaps():
    out = {}
    for k, p in FONTS.items():
        out[k] = set(TTFont(p).getBestCmap().keys()) if os.path.exists(p) else set()
    return out


def uses():
    u = collections.defaultdict(set)
    with open(os.path.join(ROOT, "localization/strings.csv"), encoding="utf-8") as f:
        for row in csv.reader(f):
            if len(row) < 3 or row[0] == "keys":
                continue
            for txt in (row[1], row[2]):
                for ch in txt:
                    if ord(ch) > 127:
                        u[ch].add(("csv", row[0]))
    files = glob.glob(os.path.join(ROOT, "scripts/**/*.gd"), recursive=True) + glob.glob(os.path.join(ROOT, "scenes/**/*.tscn"), recursive=True)
    for fp in files:
        rel = os.path.relpath(fp, ROOT).replace("\\", "/")
        if "/debug/" in "/" + rel:
            continue
        txt = open(fp, encoding="utf-8", errors="replace").read()
        for ln, line in enumerate(txt.splitlines(), 1):
            if line.lstrip().startswith("#"):
                continue
            for m in re.finditer(r'"((?:[^"\\\n]|\\.)*)"', line):
                for ch in m.group(1):
                    if ord(ch) > 127:
                        u[ch].add(("code", "%s:%d" % (rel, ln)))
    return u


def run(write_spec):
    cm = cmaps()
    plex = cm["plex400"] & cm["plex500"] & cm["plex600"] & cm["plex700"]
    barlow = cm["barlow600"] & cm["barlow700"]
    rows = []
    for ch, where in sorted(uses().items(), key=lambda t: ord(t[0])):
        o = ord(ch)
        if o in plex and o in barlow and o in cm["plexc"]:
            continue
        keys = sorted(w for k, w in where if k == "csv")
        code = sorted(w for k, w in where if k == "code")
        dec = DECISION.get(ch, ("icon" if o not in plex else "keep", "in Plex; keep out of Barlow caps roles" if o in plex else "icon (A2 backlog)"))
        rows.append((ch, o in plex, o in cm["plexc"], o in barlow, o in cm["serif"], o in cm["noto"], keys, code, dec))
    lines = ["| Char | Plex | Plex C | Barlow | Serif | Noto S2 | CSV keys | Code literals | Decision |",
             "|---|---|---|---|---|---|---|---|---|"]
    yn = lambda b: "yes" if b else "**no**"
    for ch, p, pc, b, s, n, keys, code, dec in rows:
        ks = ", ".join("`%s`" % k for k in keys[:8]) + (" (+%d)" % (len(keys) - 8) if len(keys) > 8 else "")
        cs = ", ".join("`%s`" % c for c in code[:4]) + (" (+%d)" % (len(code) - 4) if len(code) > 4 else "")
        lines.append("| %s U+%04X | %s | %s | %s | %s | %s | %s | %s | %s: %s |" % (
            ch, ord(ch), yn(p), yn(pc), yn(b), yn(s), "yes" if n else "no", ks or "", cs or "", dec[0], dec[1]))
    report = "\n".join(lines)
    print(report)
    if write_spec:
        spec = open(SPEC, encoding="utf-8").read()
        a, b = spec.index(BEGIN) + len(BEGIN), spec.index(END)
        spec = spec[:a] + "\n" + report + "\n" + spec[b:]
        open(SPEC, "w", encoding="utf-8", newline="\n").write(spec)
    return 0


if __name__ == "__main__":
    sys.exit(run("--write-spec" in sys.argv))
