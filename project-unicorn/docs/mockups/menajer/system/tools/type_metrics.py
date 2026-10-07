"""Type ladder audit: what a Godot Label will measure for every .t-* role in ../tokens.css.

Godot sizes a Label line by the tallest face in the font's fallback chain (Font.get_height takes the
maximum ascent + descent over the chain). FreeType rounds the ascender up and the descender down at
each pixel size. This script repeats that sum from the hhea metrics of the static faces Godot will ship
(read with fontTools from the files; the numbers are below so the script also runs without them) and
compares it with the CSS line-height the mockups use.

  python type_metrics.py              print the table
  python type_metrics.py --write-spec replace the block between the type markers in ../SPEC.md
Exit 1 when a CSS line-height is shorter than the Godot height of the recommended chain.
"""
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOKENS = os.path.join(HERE, "..", "tokens.css")
SPEC = os.path.join(HERE, "..", "SPEC.md")
BEGIN, END = "<!-- type:begin -->", "<!-- type:end -->"

# hhea ascender / descender per 1000 units (fontTools, 2026-10-02). Plex Sans and Plex Sans Condensed
# share metrics; every Plex weight shares them; both Barlow Condensed weights share them.
METRICS = {
    "barlow": (1000, 200, "BarlowCondensed-{w}.ttf"),
    "plex": (1025, 275, "IBMPlexSans-{w}.ttf"),
    "plexc": (1025, 275, "IBMPlexSansCondensed-{w}.ttf"),
    "serif": (1036, 335, "SourceSerif4-{w}.ttf"),
    "noto": (1069, 630, "NotoSansSymbols2-Regular.ttf"),
}
WEIGHT_FILE = {400: "Regular", 500: "Medium", 600: "SemiBold", 700: "Bold"}
SERIF_FILE = {400: "Regular", 600: "Semibold"}
FAMILY = {"--f-cond": "barlow", "--f-sans": "plex", "--f-sansc": "plexc", "--f-serif": "serif"}
# Recommended chains (no Noto Symbols 2 on text roles; see SPEC.md "Satır yüksekliği").
CHAIN = {"barlow": ["barlow", "plex"], "plex": ["plex"], "plexc": ["plexc", "plex"], "serif": ["serif"]}


def height(chain, px):
    asc = max(math.ceil(METRICS[f][0] * px / 1000) for f in chain)
    desc = max(math.ceil(METRICS[f][1] * px / 1000) for f in chain)
    return asc + desc


def var_table(css):
    root = re.search(r":root\s*\{(.*?)\n\}", css, re.S).group(1)
    return {m.group(1): m.group(2).strip() for m in re.finditer(r"(--[\w-]+)\s*:\s*([^;]+);", root)}


def px(v, vars_):
    m = re.fullmatch(r"var\((--[\w-]+)\)", v)
    if m:
        v = vars_[m.group(1)]
    return int(round(float(v.replace("px", ""))))


def roles(css, vars_):
    out = []
    for m in re.finditer(r"^\.(t-[\w-]+)\s*\{([^}]*)\}", css, re.M):
        body = dict((k.strip(), v.strip()) for k, v in (d.split(":", 1) for d in m.group(2).split(";") if ":" in d))
        fam = FAMILY[re.search(r"var\((--f-\w+)\)", body["font-family"]).group(1)]
        out.append({
            "cls": m.group(1), "fam": fam, "weight": int(body["font-weight"]),
            "size": px(body["font-size"], vars_), "lh": px(body["line-height"], vars_),
            "track": px(body["letter-spacing"], vars_) if body["letter-spacing"] != "0" else 0,
            "caps": body.get("text-transform") == "uppercase",
        })
    return out


def face_file(fam, weight):
    if fam == "serif":
        return METRICS[fam][2].format(w=SERIF_FILE[weight])
    return METRICS[fam][2].format(w=WEIGHT_FILE[weight])


def run(write_spec):
    css = open(TOKENS, encoding="utf-8").read()
    vars_ = var_table(css)
    rs = roles(css, vars_)
    lines, fails = [], []
    lines.append("| Class | Face file (Godot) | Size | spacing_glyph | Case | CSS line | Godot line (chain) | With Noto Symbols 2 | Paragraph line_spacing |")
    lines.append("|---|---|---|---|---|---|---|---|---|")
    sizes = set()
    for r in rs:
        sizes.add(r["size"])
        chain = CHAIN[r["fam"]]
        g = height(chain, r["size"])
        n = height(chain + ["noto"], r["size"])
        spacing = r["lh"] - g
        if r["lh"] < g:
            fails.append("%s css %d < godot %d" % (r["cls"], r["lh"], g))
        lines.append("| `.%s` | %s | %d | %d | %s | %d | %d (%s) | %d (+%d) | %s |" % (
            r["cls"], face_file(r["fam"], r["weight"]), r["size"], r["track"], "caps" if r["caps"] else "as typed",
            r["lh"], g, "+".join(chain), n, n - g, ("+%d" % spacing) if spacing > 0 else "0"))
    lines.append("")
    lines.append("Ladder in use: %s (%d steps)." % (" · ".join(str(s) for s in sorted(sizes)), len(sizes)))
    lines.append("Distinct FontVariations needed (face, spacing_glyph): %s." % ", ".join(sorted(
        {"%s %s" % (face_file(r["fam"], r["weight"]).replace(".ttf", ""), "+%d" % r["track"] if r["track"] else "0") for r in rs})))
    report = "\n".join(lines)
    print(report)
    if fails:
        print("\nFAIL: " + "; ".join(fails))
    if write_spec:
        spec = open(SPEC, encoding="utf-8").read()
        a, b = spec.index(BEGIN) + len(BEGIN), spec.index(END)
        spec = spec[:a] + "\n" + report + "\n" + spec[b:]
        open(SPEC, "w", encoding="utf-8", newline="\n").write(spec)
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(run("--write-spec" in sys.argv))
