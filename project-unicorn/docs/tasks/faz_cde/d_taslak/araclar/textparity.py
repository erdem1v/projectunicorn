"""textparity: prove that approved wave texts reached the game byte-exact.

Usage: python -I textparity.py <project-unicorn dir> [--ids <prefix,prefix,...>] [--wave W1,W2,W3]

Collects every player text in the wave JSONs (title, body, body_variants, reviews, option labels, lock reasons, expire
notes, chip templates; NOT the example-filled option chips) and looks for each EN and TR string, byte-exact, among the
values of localization/strings.csv and every string inside data/events/cards/**/*.json. Only items whose id starts with
one of --ids are checked (default: all). Prints FOUND/MISSING per string and a PARITY line; exit 1 if anything is missing.
"""
import csv
import glob
import io
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
WAVES = {"W1": "W1_OLAYLAR.json", "W2": "W2_KAGITLAR.json", "W3": "W3_SOZ_SURUM.json"}


def arg(name, default=None):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default


def walk_strings(node, out):
    if isinstance(node, str):
        out.add(node)
    elif isinstance(node, dict):
        for v in node.values():
            walk_strings(v, out)
    elif isinstance(node, list):
        for v in node:
            walk_strings(v, out)


def game_strings(root):
    found = set()
    with open(os.path.join(root, "localization", "strings.csv"), encoding="utf-8", newline="") as f:
        for row in csv.reader(io.StringIO(f.read())):
            found.update(row[1:])
    for path in glob.glob(os.path.join(root, "data", "events", "cards", "**", "*.json"), recursive=True):
        try:
            walk_strings(json.load(open(path, encoding="utf-8")), found)
        except (json.JSONDecodeError, UnicodeDecodeError):
            pass
    return found


def wave_texts(item):
    pairs = []
    for key in ("title", "body", "text"):
        v = item.get(key)
        if isinstance(v, dict) and ("en" in v or "tr" in v):
            pairs.append((key, v))
    for i, v in enumerate(item.get("body_variants") or []):
        pairs.append((f"body_variants[{i}]", v))
    for i, v in enumerate(item.get("reviews") or []):
        pairs.append((f"reviews[{i}]", v))
    for o in item.get("options") or []:
        if isinstance(o.get("label"), dict):
            pairs.append((f"{o.get('id')}.label", o["label"]))
        if isinstance(o.get("lock"), dict) and o["lock"].get("en"):
            pairs.append((f"{o.get('id')}.lock", o["lock"]))
    if isinstance(item.get("expire"), dict):
        pairs.append(("expire", item["expire"]))
    return pairs


def main():
    root = sys.argv[1]
    prefixes = [p for p in (arg("--ids", "") or "").split(",") if p]
    waves = (arg("--wave", "W1,W2,W3")).split(",")
    have = game_strings(root)
    missing = checked = 0
    for w in waves:
        path = os.path.join(root, "docs", "tasks", "faz_ab", "b_taslak", WAVES[w])
        for item in json.load(open(path, encoding="utf-8")).get("items", []):
            if item.get("kind") == "rule":
                continue
            iid = item.get("id", "")
            if prefixes and not any(iid.startswith(p) for p in prefixes):
                continue
            for label, pair in wave_texts(item):
                for lang in ("en", "tr"):
                    s = pair.get(lang)
                    if not s:
                        continue
                    checked += 1
                    if s in have:
                        continue
                    missing += 1
                    print(f"MISSING {w} {iid} {label} [{lang}]: {s}")
    print(f"PARITY checked={checked} missing={missing}")
    sys.exit(1 if missing else 0)


if __name__ == "__main__":
    main()
