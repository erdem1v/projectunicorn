"""Contrast and colour-blind audit for the Menajer Masası tokens.

Reads ../tokens.css (the :root block and the [data-palette="cb"] block), resolves var() references,
composes rgba tokens over their ground, and prints:
  1. every colour token with its hex, role, colour-blind twin and contrast on its grounds;
  2. the category checks (body text 4.5, large text 3, non-text 3, disabled distinguishable 1.6..4.5);
  3. the skill ramp: luminance order and step ratios in both palettes;
  4. Machado 2009 colour-vision simulation: smallest pairwise distance inside each set that must stay apart.

  python contrast.py              print the report
  python contrast.py --write-spec replace the block between the contrast markers in ../SPEC.md
Exit code 1 when a required check fails.
"""
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOKENS = os.path.join(HERE, "..", "..", "..", "..", "system", "tokens.css")
SPEC = os.path.join(HERE, "SPEC_unused.md")  # never write the system SPEC
BEGIN, END = "<!-- contrast:begin -->", "<!-- contrast:end -->"


# ---------------------------------------------------------------- parsing
def parse_blocks(css):
    root = re.search(r":root\s*\{(.*?)\n\}", css, re.S).group(1)
    cb = re.search(r'\[data-palette="cb"\][^{]*\{(.*?)\n\}', css, re.S).group(1)
    return _decls(root), _decls(cb)


def _decls(block):
    out = {}
    for line in block.splitlines():
        for m in re.finditer(r"(--[\w-]+)\s*:\s*([^;]+);\s*(?:/\*\s*(.*?)\s*\*/)?", line):
            out[m.group(1)] = (m.group(2).strip(), (m.group(3) or "").strip())
    return out


def resolve(name, table, depth=0):
    v = table[name][0]
    m = re.fullmatch(r"var\((--[\w-]+)\)", v)
    if m and depth < 8:
        return resolve(m.group(1), table, depth + 1)
    return v


def to_rgba(v):
    v = v.strip()
    if v.startswith("#"):
        h = v[1:]
        return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 1.0)
    m = re.fullmatch(r"rgba\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*\)", v)
    if m:
        return (float(m.group(1)), float(m.group(2)), float(m.group(3)), float(m.group(4)))
    return None


def over(fg, bg):
    """fg rgba over opaque bg rgb, returns opaque rgb."""
    a = fg[3]
    return tuple(fg[i] * a + bg[i] * (1 - a) for i in range(3)) + (1.0,)


def hexs(c):
    return "#%02X%02X%02X" % tuple(int(round(x)) for x in c[:3])


# ---------------------------------------------------------------- colour maths
def _lin(c):
    c /= 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def lum(c):
    return 0.2126 * _lin(c[0]) + 0.7152 * _lin(c[1]) + 0.0722 * _lin(c[2])


def ratio(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


# Machado, Oliveira, Fernandes 2009, severity 1.0, applied in linear RGB.
MACHADO = {
    "protan": ((0.152286, 1.052583, -0.204868), (0.114503, 0.786281, 0.099216), (-0.003882, -0.048116, 1.051998)),
    "deutan": ((0.367322, 0.860646, -0.227968), (0.280085, 0.672501, 0.047413), (-0.011820, 0.042940, 0.968881)),
    "tritan": ((1.255528, -0.076749, -0.178779), (-0.078411, 0.930809, 0.147602), (0.004733, 0.691367, 0.303900)),
}


def _enc(x):
    x = min(1.0, max(0.0, x))
    return 255 * (12.92 * x if x <= 0.0031308 else 1.055 * x ** (1 / 2.4) - 0.055)


def simulate(c, kind):
    if kind == "normal":
        return c
    l = [_lin(c[0]), _lin(c[1]), _lin(c[2])]
    m = MACHADO[kind]
    return tuple(_enc(sum(m[r][k] * l[k] for k in range(3))) for r in range(3)) + (1.0,)


def lab(c):
    r, g, b = (_lin(c[0]), _lin(c[1]), _lin(c[2]))
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = (0.2126 * r + 0.7152 * g + 0.0722 * b)
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    f = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(x), f(y), f(z)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))


def de2000(c1, c2):
    L1, a1, b1 = lab(c1)
    L2, a2, b2 = lab(c2)
    C1, C2 = math.hypot(a1, b1), math.hypot(a2, b2)
    Cb = (C1 + C2) / 2
    G = 0.5 * (1 - math.sqrt(Cb ** 7 / (Cb ** 7 + 25 ** 7)))
    a1p, a2p = (1 + G) * a1, (1 + G) * a2
    C1p, C2p = math.hypot(a1p, b1), math.hypot(a2p, b2)
    h1p = math.degrees(math.atan2(b1, a1p)) % 360
    h2p = math.degrees(math.atan2(b2, a2p)) % 360
    dLp, dCp = L2 - L1, C2p - C1p
    dh = h2p - h1p
    if C1p * C2p == 0:
        dh = 0
    elif dh > 180:
        dh -= 360
    elif dh < -180:
        dh += 360
    dHp = 2 * math.sqrt(C1p * C2p) * math.sin(math.radians(dh / 2))
    Lbp, Cbp = (L1 + L2) / 2, (C1p + C2p) / 2
    if C1p * C2p == 0:
        hbp = h1p + h2p
    elif abs(h1p - h2p) > 180:
        hbp = (h1p + h2p + 360) / 2 if h1p + h2p < 360 else (h1p + h2p - 360) / 2
    else:
        hbp = (h1p + h2p) / 2
    T = (1 - 0.17 * math.cos(math.radians(hbp - 30)) + 0.24 * math.cos(math.radians(2 * hbp))
         + 0.32 * math.cos(math.radians(3 * hbp + 6)) - 0.20 * math.cos(math.radians(4 * hbp - 63)))
    dth = 30 * math.exp(-(((hbp - 275) / 25) ** 2))
    Rc = 2 * math.sqrt(Cbp ** 7 / (Cbp ** 7 + 25 ** 7))
    Sl = 1 + 0.015 * (Lbp - 50) ** 2 / math.sqrt(20 + (Lbp - 50) ** 2)
    Sc, Sh = 1 + 0.045 * Cbp, 1 + 0.015 * Cbp * T
    Rt = -math.sin(math.radians(2 * dth)) * Rc
    return math.sqrt((dLp / Sl) ** 2 + (dCp / Sc) ** 2 + (dHp / Sh) ** 2 + Rt * (dCp / Sc) * (dHp / Sh))


# ---------------------------------------------------------------- the audit
# (fg token, [ground tokens], category). Category minimums: body 4.5, large 3.0 (>= 24 px regular or
# >= 19 px bold), ui 3.0 (non-text: focus ring, track fill that carries the value), off = disabled label
# (exempt, but must stay 1.6..4.5 so it reads as off yet is still seen), deco = report only.
BAND3 = ("--role-band", "--surface-3")      # composite ground: band over the window body
BAND4 = ("--role-band", "--surface-4")      # band under a selected row
PILL2 = ("pill", "--surface-2")             # pill fill (hue at --pill-fill) over the inbox column
CHECKS = [
    ("--ink-1", ["--surface-1", "--surface-3", "--surface-4"], "body"),
    ("--ink-2", ["--surface-0", "--surface-1", "--surface-2", "--surface-3", "--surface-4", "--surface-5"], "body"),
    ("--ink-3", ["--surface-0", "--surface-1", "--surface-2", "--surface-3", "--surface-4", "--surface-5"], "body"),
    ("--ink-4", ["--surface-1", "--surface-2", "--surface-3", "--surface-4"], "body"),
    ("--ink-off", ["--surface-1", "--surface-3", "--surface-4"], "off"),
    ("--accent", ["--surface-1", "--surface-4"], "body"),
    ("--on-accent", ["--accent", "--accent-hover", "--accent-pressed"], "body"),
    ("--pos", ["--surface-1", "--surface-2", "--surface-3", "--surface-4"], "body"),
    ("--neg", ["--surface-1", "--surface-2", "--surface-3", "--surface-4", "--neg-bg"], "body"),
    ("--warn", ["--surface-1", "--surface-2", "--surface-3", "--surface-4"], "body"),
    ("--info", ["--surface-2", "--surface-3"], "ui"),
    ("--neg-ink", ["--neg-bg", ("--neg-tag-bg", "--surface-3"), ("--neg-tag-bg", "--surface-2")], "body"),
    ("--pos-ink", [("--pos-tag-bg", "--surface-3")], "body"),
    ("--skill-1", ["--surface-3", "--surface-4", BAND3, BAND4], "body"),
    ("--skill-2", ["--surface-3", BAND3, BAND4], "body"),
    ("--skill-3", ["--surface-3", BAND3, BAND4], "body"),
    ("--skill-4", ["--surface-3", BAND3, BAND4], "body"),
    ("--skill-5", ["--surface-3", BAND3, BAND4], "body"),
    ("--topic-mentor", ["--surface-2", "--surface-4", PILL2], "body"),
    ("--topic-customer", ["--surface-2", "--surface-4", PILL2], "body"),
    ("--topic-team", ["--surface-2", "--surface-4", PILL2], "body"),
    ("--topic-product", ["--surface-2", "--surface-4", PILL2], "body"),
    ("--topic-funding", ["--surface-2", "--surface-4", PILL2], "body"),
    ("--topic-market", ["--surface-2", "--surface-4", PILL2], "body"),
    ("--topic-agenda", ["--surface-2", "--surface-4", PILL2], "body"),
    ("--outlet-sektor", ["--surface-0"], "body"),
    ("--outlet-ekonomi", ["--surface-0"], "body"),
    ("--outlet-teknogundem", ["--surface-0"], "body"),
    ("--outlet-girisim", ["--surface-0"], "body"),
    ("--focus", ["--surface-1", "--surface-3", "--surface-4", "--surface-5"], "ui"),
    ("--stamp", ["--surface-2", "--surface-3", "--surface-4"], "body"),
    ("--chart-line", ["--surface-3"], "ui"),
    ("--chart-proj", ["--surface-3"], "ui"),
    ("--bar-fill", ["--surface-3", "--surface-4"], "ui"),
    ("--bar-emph", ["--surface-3"], "ui"),
    ("--chart-axis", ["--surface-3"], "deco"),
    ("--chart-grid", ["--surface-3"], "deco"),
    ("--bar-track", ["--surface-3"], "deco"),
    ("--av-rim", ["--surface-3"], "deco"),
    ("--portrait-lit", ["hair"], "sil"),
    ("--line-hover", ["--surface-3", "--surface-4"], "ui"),
    ("--line-3", ["--surface-3"], "deco"),
    ("--line-2", ["--surface-3"], "deco"),
    ("--line-1", ["--surface-3"], "deco"),
    ("--paper-ink", ["--paper-bg"], "body"),
    ("--paper-ink-body", ["--paper-bg"], "body"),
    ("--paper-ink-deck", ["--paper-bg"], "body"),
    ("--paper-ink-mast", ["--paper-bg"], "body"),
    ("--paper-ink-meta", ["--paper-bg"], "body"),
]
MINIMUM = {"body": 4.5, "large": 3.0, "ui": 3.0, "sil": 2.0}
# "sil": the lit portrait ground against the darkest hair the 3D characters wear (#060100, Burak), so an
# ink-outlined head keeps its silhouette on charcoal (review finding 10). The ground sits behind, the hair in front.
HAIR = (6, 1, 0, 1.0)

# Sets whose members must stay apart under every colour-vision type (CIEDE2000 between simulated colours).
SETS = {
    "meaning (pos, warn, neg)": ["--pos", "--warn", "--neg"],
    "dots (unread ink-2, info, pos, warn, neg)": ["--ink-2", "--info", "--pos", "--warn", "--neg"],
    "topic-product against skill-3..5 and pos": ["--topic-product", "--skill-3", "--skill-4", "--skill-5", "--pos"],
    "meaning + accent": ["--pos", "--warn", "--neg", "--accent"],
    "topics": ["--topic-mentor", "--topic-customer", "--topic-team", "--topic-product", "--topic-funding",
               "--topic-market", "--topic-agenda"],
    "outlets": ["--outlet-sektor", "--outlet-ekonomi", "--outlet-teknogundem", "--outlet-girisim"],
}
SET_FLOOR = {"meaning (pos, warn, neg)": 12.0, "meaning + accent": 8.0, "topics": 6.0, "outlets": 8.0,
             "dots (unread ink-2, info, pos, warn, neg)": 8.0, "topic-product against skill-3..5 and pos": 10.0}
# Compared only in the standard palette and only as pairs with the first member (the review found topic-product
# 4.3 from skill-4; the ramp steps themselves are ordered by luminance, not kept apart by hue).
STANDARD_ONLY = {"topic-product against skill-3..5 and pos"}
ANCHORED = {"topic-product against skill-3..5 and pos"}
KINDS = ["normal", "deutan", "protan", "tritan"]


class Palette:
    def __init__(self, root, cb, use_cb):
        self.table = dict(root)
        if use_cb:
            self.table.update(cb)
        self.cb_names = set(cb) if use_cb else set()

    def colour(self, name):
        return to_rgba(resolve(name, self.table))

    def ground(self, g):
        if isinstance(g, tuple):
            top, base = g
            base_c = self.colour(base)
            if top == "pill":
                return None, base_c   # resolved per fg
            return over(self.colour(top), base_c), None
        return self.colour(g), None

    def pair(self, fg, g):
        fgc = self.colour(fg)
        if g == "hair":
            return fgc, HAIR
        if isinstance(g, tuple) and g[0] == "pill":
            alpha = float(resolve("--pill-fill", self.table))
            bg = over((fgc[0], fgc[1], fgc[2], alpha), self.colour(g[1]))
        else:
            bg, _ = self.ground(g)
        if fgc[3] < 1:
            fgc = over(fgc, bg)
        return fgc, bg


def gname(g):
    if g == "hair":
        return "darkest hair #060100"
    if isinstance(g, tuple):
        return ("pill fill on " if g[0] == "pill" else g[0][2:] + " on ") + g[1][2:]
    return g[2:]


def run(write_spec):
    css = open(TOKENS, encoding="utf-8").read()
    root, cb = parse_blocks(css)
    std, alt = Palette(root, cb, False), Palette(root, cb, True)
    lines, fails = [], []

    # 1. token table ---------------------------------------------------------------------------
    lines.append("### Token tablosu (hesaplanmış)\n")
    lines.append("Contrast is WCAG 2.x. \"cb\" is the colour-blind twin (`[data-palette=cb]`); a dash-free \"=\" means the twin keeps the value.\n")
    lines.append("| Token | Hex | cb | Role | Grounds and ratio (standard / cb) |")
    lines.append("|---|---|---|---|---|")
    checked = {c[0]: c for c in CHECKS}
    for name, (val, note) in root.items():
        c = to_rgba(resolve(name, root)) if to_rgba(resolve(name, root)) else None
        if c is None:
            continue
        hx = hexs(c) + ("" if c[3] == 1 else " @%.2f" % c[3])
        twin = "="
        tc = to_rgba(resolve(name, alt.table))
        if name in cb and tc != c:
            twin = hexs(tc) + ("" if tc[3] == 1 else " @%.2f" % tc[3])
        cells = []
        if name in checked:
            for g in checked[name][1]:
                f1, b1 = std.pair(name, g)
                f2, b2 = alt.pair(name, g)
                r1, r2 = ratio(f1, b1), ratio(f2, b2)
                cells.append("%s %.2f%s" % (gname(g), r1, "" if abs(r1 - r2) < 0.005 else " / %.2f" % r2))
        lines.append("| `%s` | %s | %s | %s | %s |" % (name, hx, twin, note.replace("|", "/"), "; ".join(cells)))

    # 2. category checks ----------------------------------------------------------------------
    lines.append("\n### Kategori denetimi\n")
    lines.append("Minimums: body text 4.5, large text 3.0, non-text UI 3.0, disabled label 1.6 to 4.5 (exempt, must still be seen and must read as off), decorative not checked.\n")
    lines.append("| Check | Palette | Worst pair | Ratio | Result |")
    lines.append("|---|---|---|---|---|")
    for fg, grounds, cat in CHECKS:
        if cat == "deco":
            continue
        for label, pal in (("standard", std), ("cb", alt)):
            worst = min(((ratio(*pal.pair(fg, g)), g) for g in grounds), key=lambda t: t[0])
            r, g = worst
            if cat == "off":
                ok = 1.6 <= r <= 4.5
                need = "1.6..4.5"
            else:
                ok = r >= MINIMUM[cat]
                need = ">= %.1f" % MINIMUM[cat]
            if not ok:
                fails.append("%s on %s (%s) %.2f, need %s" % (fg, gname(g), label, r, need))
            lines.append("| `%s` %s | %s | %s | %.2f | %s |" % (fg, cat, label, gname(g), r, "pass" if ok else "**FAIL** " + need))

    # 3. skill ramp ---------------------------------------------------------------------------
    lines.append("\n### Beceri rampası: parlaklık sırası\n")
    lines.append("Relative luminance Y must rise from 1-2 to 9-10 in both palettes, so the order survives greyscale and every colour-vision type. Step = (Y[n+1]+0.05)/(Y[n]+0.05).\n")
    lines.append("| Palette | 1-2 | 3-4 | 5-6 | 7-8 | 9-10 | Steps | Monotonic in all simulations |")
    lines.append("|---|---|---|---|---|---|---|---|")
    for label, pal in (("standard", std), ("cb", alt)):
        cs = [pal.colour("--skill-%d" % i) for i in range(1, 6)]
        ys = [lum(c) for c in cs]
        steps = ["%.2f" % ((ys[i + 1] + 0.05) / (ys[i] + 0.05)) for i in range(4)]
        mono = []
        for k in KINDS:
            yk = [lum(simulate(c, k)) for c in cs]
            mono.append(all(yk[i + 1] > yk[i] for i in range(4)))
        ok = all(mono) and min(float(s) for s in steps) >= 1.10
        if not ok:
            fails.append("skill ramp (%s) not monotonic or a step under 1.10" % label)
        mono_txt = "yes" if all(mono) else "**no** " + ",".join(k for k, m in zip(KINDS, mono) if not m)
        cells = " | ".join("%s Y%.3f" % (hexs(c), y) for c, y in zip(cs, ys))
        lines.append("| %s | %s | %s | %s |" % (label, cells, " ".join(steps), mono_txt))

    # 4. simulation sets ------------------------------------------------------------------------
    lines.append("\n### Renk görüşü simülasyonu (Machado 2009, şiddet 1.0)\n")
    lines.append("Smallest CIEDE2000 distance between any two members of a set after simulation. Floors: meaning 12, meaning+accent 8, outlets 8, topics 6 (topic pills always carry their word, so hue is the second channel).\n")
    lines.append("| Set | Palette | " + " | ".join(KINDS) + " | Closest pair (worst view) |")
    lines.append("|---|---|" + "---|" * len(KINDS) + "---|")
    for sname, members in SETS.items():
        for label, pal in (("standard", std), ("cb", alt)):
            if sname in STANDARD_ONLY and label == "cb":
                continue
            row, worst = [], (999, "", "")
            for k in KINDS:
                sims = {m: simulate(pal.colour(m), k) for m in members}
                best = (999, "", "")
                for i, a in enumerate(members):
                    if sname in ANCHORED and i > 0:
                        break
                    for b in members[i + 1:]:
                        d = de2000(sims[a], sims[b])
                        if d < best[0]:
                            best = (d, a, b)
                row.append("%.1f" % best[0])
                if best[0] < worst[0]:
                    worst = (best[0], best[1], best[2], k)
            floor = SET_FLOOR[sname]
            # The standard palette is only required to hold for normal vision; cb must hold everywhere.
            need = [float(row[0])] if label == "standard" else [float(x) for x in row]
            ok = min(need) >= floor
            if not ok:
                fails.append("%s (%s) min %.1f < %.1f" % (sname, label, min(need), floor))
            lines.append("| %s | %s | %s | %s/%s in %s%s |" % (
                sname, label, " | ".join(row), worst[1][2:], worst[2][2:], worst[3], "" if ok else " **FAIL**"))
    lines.append("\nThe standard palette is required to hold only for normal vision (its row is informative for the other views); the cb palette must hold in every view.\n")

    lines.append("\n**Result:** " + ("all required checks pass." if not fails else "%d failing: %s" % (len(fails), "; ".join(fails))))
    report = "\n".join(lines)
    print(report)
    if write_spec:
        spec = open(SPEC, encoding="utf-8").read()
        a, b = spec.index(BEGIN) + len(BEGIN), spec.index(END)
        spec = spec[:a] + "\n" + report + "\n" + spec[b:]
        open(SPEC, "w", encoding="utf-8", newline="\n").write(spec)
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(run("--write-spec" in sys.argv))
