# Dumps every non-fixture event card with its text resolved from strings.csv (read only).
#   python dump_cards.py [card_id ...]   > cards_dump.txt
import csv, json, os, re, subprocess, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../../../.."))
CARDS = os.path.join(ROOT, "data/events/cards")
CSV = os.path.join(ROOT, "localization/strings.csv")

S = {}
with open(CSV, encoding="utf-8") as f:
    for row in csv.reader(f):
        if len(row) >= 3:
            S[row[0]] = (row[1], row[2])

def res(v, lang):
    if isinstance(v, dict):
        return " | ".join("%s=%s" % (k, res(x, lang)) for k, x in v.items())
    if isinstance(v, list):
        return " + ".join(res(x, lang) for x in v)
    if v in S:
        return S[v][0 if lang == "tr" else 1]
    return v

tracked = set(subprocess.run(["git", "ls-files", "data/events/cards"], cwd=ROOT, capture_output=True,
                             text=True).stdout.split())

def cards():
    for d in sorted(os.listdir(CARDS)):
        if d.startswith("_"):
            continue
        p = os.path.join(CARDS, d)
        if not os.path.isdir(p):
            continue
        for fn in sorted(os.listdir(p)):
            if fn.endswith(".json"):
                rel = "data/events/cards/%s/%s" % (d, fn)
                with open(os.path.join(p, fn), encoding="utf-8") as f:
                    yield rel, json.load(f)

want = set(sys.argv[1:])
for rel, c in cards():
    if want and c["id"] not in want:
        continue
    print("=" * 100)
    print("%s  [%s]  %s" % (c["id"], "tracked" if rel in tracked else "UNTRACKED", rel))
    print("scope=%s cat=%s tick=%s class=%s speaker=%s tags=%s expires=%s trigger=%s" % (
        c.get("version_scope"), c.get("category"), c.get("tick"), c.get("class"), c.get("speaker"),
        c.get("tags"), c.get("expires_weeks"), json.dumps(c.get("trigger"))))
    if c.get("scope"):
        print("slots:", json.dumps(c["scope"], ensure_ascii=False))
    for o in c.get("options", []):
        print("  OPT %s  effects=%s" % (o["id"], json.dumps(o.get("effects"), ensure_ascii=False)))
        if o.get("requires"):
            print("      requires=%s" % json.dumps(o["requires"], ensure_ascii=False))
    if c.get("on_expire"):
        print("  ON_EXPIRE", json.dumps(c["on_expire"], ensure_ascii=False))
    for lang in ("tr", "en"):
        t = c.get("text", {}).get(lang, {})
        print("  --- %s" % lang)
        for k in ("title", "body", "speaker_line", "kicker"):
            if k in t:
                print("  %s: %s" % (k, res(t[k], lang).replace("\n", " / ")))
        for oid, v in t.get("options", {}).items():
            print("  opt %s: %s" % (oid, res(v, lang)))
        for oid, v in t.get("locked_reasons", {}).items():
            print("  lock %s: %s" % (oid, res(v, lang)))
        for oid, v in t.get("outcomes", {}).items() if isinstance(t.get("outcomes"), dict) else []:
            print("  outcome %s: %s" % (oid, res(v, lang) if isinstance(v, str) else v))
        extra = [k for k in t if k not in ("title", "body", "options", "locked_reasons", "outcomes", "speaker_line", "kicker")]
        for k in extra:
            v = t[k]
            print("  %s: %s" % (k, res(v, lang).replace("\n", " / ") if isinstance(v, str) else json.dumps(v, ensure_ascii=False)))
