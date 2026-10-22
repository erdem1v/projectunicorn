"""w1parity: W1 metinlerinin oyuna bayt bayt girdiğini kanıtlar.

python -I w1parity.py <project-unicorn dizini> --w1 <W1_METINLER.json> [--override <W1_E1.json> [--override <W2_METINLER.json>]] --ids id1,id2,...
Her id'nin TR ve EN metni strings.csv değerleri ya da data/**/*.json içindeki dizeler arasında bayt bayt aranır.
--override dosyasındaki öğe (aynı id) W1'dekinin yerine geçer; "drop": true taşıyan öğe denetlenmez.
Yer tutuculu metinler ({ad}) olduğu gibi aranır. FOUND/MISSING satırları ve PARITY satırı basar; eksik varsa 1 ile çıkar.
"""
import csv
import glob
import io
import json
import os
import sys


def arg(name, default=None):
    return sys.argv[sys.argv.index(name) + 1] if name in sys.argv else default


def walk(node, out):
    if isinstance(node, str):
        out.add(node)
    elif isinstance(node, dict):
        for v in node.values():
            walk(v, out)
    elif isinstance(node, list):
        for v in node:
            walk(v, out)


def game_strings(root):
    found = set()
    with open(os.path.join(root, "localization", "strings.csv"), encoding="utf-8", newline="") as f:
        for row in csv.reader(io.StringIO(f.read())):
            found.update(row[1:])
    for path in glob.glob(os.path.join(root, "data", "**", "*.json"), recursive=True):
        try:
            with open(path, encoding="utf-8") as f:
                walk(json.load(f), found)
        except (ValueError, OSError):
            pass
    return found


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    root = sys.argv[1]
    with open(arg("--w1"), encoding="utf-8") as f:
        items = {it["id"]: it for it in json.load(f)["items"]}
    # Each --override in order: a later file's item (same id) replaces the earlier one (W1 -> W1_E1 -> W2).
    for k, a in enumerate(sys.argv):
        ov = sys.argv[k + 1] if a == "--override" and k + 1 < len(sys.argv) else ""
        if ov and os.path.exists(ov):
            with open(ov, encoding="utf-8") as f:
                for it in json.load(f)["items"]:
                    items[it["id"]] = it
    ids = [i for i in (arg("--ids") or "").split(",") if i]
    found = game_strings(root)
    missing = checked = 0
    for iid in ids:
        it = items.get(iid)
        if it is None:
            print("UNKNOWN", iid)
            missing += 1
            continue
        if it.get("drop"):
            print("DROPPED", iid)
            continue
        for lang in ("tr", "en"):
            checked += 1
            s = it.get(lang, "")
            if s in found:
                print("FOUND", iid, lang)
            else:
                missing += 1
                print("MISSING", iid, lang, repr(s))
    print(f"PARITY checked={checked} missing={missing}")
    sys.exit(1 if missing else 0)


if __name__ == "__main__":
    main()
