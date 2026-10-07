"""Spacing lint for ../base.css (review finding 16): every padding, margin and gap uses the spacing scale.

Allowed: var(--sp-*), 0, auto, negative scale tokens, and the values in ALLOW (each with its reason).
Positions, sizes and offsets (left, top, width, height, inset) are layout and are not checked.

  python lint_spacing.py      exit 1 and list the offending lines
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.join(HERE, "..", "base.css")
SCALE = {0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48}
PROPS = ("padding", "padding-top", "padding-right", "padding-bottom", "padding-left", "margin", "margin-top",
         "margin-right", "margin-bottom", "margin-left", "gap", "row-gap", "column-gap")
# raw values that are not spacing: hairline offsets that keep a 1 px rule or a 2 px underline on its edge
ALLOW = {
    ("margin-top", "-2px"): "two-line name cell: the role line sits 2 px into the name line's descent (VBox separation -2)",
    ("margin-left", "1px"): "input caret hairline",
    ("margin-left", "-3px"): "week-bar diamond centred on its hour",
    ("margin-left", "-1px"): "week-bar now marker centred on its hour",
    ("margin-left", "-6px"): "lever grip centred on its value",
    ("margin-left", "-8px"): "main-skill underline centred",
    ("margin-left", "-10px"): "slider grabber centred",
    ("margin-right", "-12px"): "list header spans the scrollbar gutter",
    ("margin-top", "-1px"): "hairline overlap",
    ("gap", "1px"): "stacked bar: 1 px separator between shares",
}


def run():
    css = open(BASE, encoding="utf-8").read()
    bad = []
    for ln, line in enumerate(css.splitlines(), 1):
        for m in re.finditer(r"(?<![\w-])(%s)\s*:\s*([^;}]+)" % "|".join(re.escape(p) for p in PROPS), line):
            prop, val = m.group(1), m.group(2).strip()
            for tok in val.split():
                if tok.startswith("var(--sp-") or tok in ("0", "auto") or tok.startswith("calc("):
                    continue
                if tok.startswith("var(") or tok.startswith("-var("):
                    continue
                num = re.fullmatch(r"(-?\d+(?:\.\d+)?)px", tok)
                if num and abs(float(num.group(1))) in SCALE:
                    continue
                if (prop, tok) in ALLOW:
                    continue
                bad.append("%d: %s: %s  (%s)" % (ln, prop, val, tok))
    if bad:
        print("spacing lint: %d off-scale values" % len(bad))
        print("\n".join(bad))
        return 1
    print("spacing lint: clean (%d allowed hairline offsets)" % len(ALLOW))
    return 0


if __name__ == "__main__":
    sys.exit(run())
