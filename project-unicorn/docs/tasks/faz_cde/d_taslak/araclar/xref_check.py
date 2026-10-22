"""xref_check: does the STAGED tree hang together? (a commit cut out of a tree several steps write to)

Usage (from the git root): python -I xref_check.py [--save <file> | --base <file>]
--save writes the problems found (run it on a clean index = HEAD); --base reports only problems not in that file.
Reads every staged .gd file and localization/strings.csv from the index (git show :path) and reports:
  - Class.member references (Class = a class_name in the tree) whose member is not declared in that class' file;
  - calls to _private(...) in a file that declares no such function;
  - EFFECT_/MAIL_/FIN_/PRODUCT_/EV_ keys quoted in staged .gd/.json files that the staged CSV lacks.
Heuristic, not a compiler: it catches a hunk that was left out while a caller went in.
"""
import csv
import io
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")
ROOT = "project-unicorn/"
BUILTIN = {"new", "get", "set", "call", "connect", "emit", "has", "free", "duplicate", "instantiate", "keys", "values",
           "size", "append", "erase", "clear", "is_empty", "find", "get_class", "is_connected", "disconnect",
           "get_meta", "set_meta", "has_method", "callv", "bind"}


def git(*a):
    return subprocess.run(["git", *a], capture_output=True, check=True).stdout


def staged(pattern):
    out = git("ls-files", "-s", "--", pattern).decode("utf-8").splitlines()
    return [l.split("\t", 1)[1] for l in out]


def blob(path):
    return git("show", f":{path}").decode("utf-8", errors="replace")


gd = {p: blob(p) for p in staged(ROOT + "*.gd")}
cls = {}
decl = {}
for p, src in gd.items():
    m = re.search(r"^class_name\s+(\w+)", src, re.M)
    names = set(re.findall(r"^\s*(?:static\s+)?(?:func|var|const|signal|enum)\s+(\w+)", src, re.M))
    names |= set(re.findall(r"^\s*@export(?:_\w+)?(?:\([^)]*\))?\s+var\s+(\w+)", src, re.M))
    # enum members: enum X { A, B }
    for body in re.findall(r"enum\s+\w*\s*\{([^}]*)\}", src):
        names |= set(re.findall(r"(\w+)", body))
    decl[p] = names
    if m:
        cls[m.group(1)] = p
# autoload singletons: name -> script path (project.godot is not ours to read from the index; read the worktree)
try:
    for line in open(ROOT + "project.godot", encoding="utf-8"):
        m = re.match(r'(\w+)="\*res://(.+\.gd)"', line.strip())
        if m and ROOT + m.group(2) in gd:
            cls.setdefault(m.group(1), ROOT + m.group(2))
except OSError:
    pass

found = []
def report(line):
    found.append(line)
for p, src in gd.items():
    code = re.sub(r"#.*", "", src)
    code = re.sub(r'"(?:\\.|[^"\\])*"', '""', code)
    for c, member in set(re.findall(r"\b([A-Z]\w+)\.([a-z_]\w*)\b", code)):
        if c in cls and member not in decl[cls[c]] and member not in BUILTIN:
            report(f"MISSING {c}.{member}  (used in {p})")
    own = decl[p]
    for f in set(re.findall(r"(?<![\w.])(_[a-z]\w*)\(", code)):
        if f not in own and not f.startswith("_on_") and f not in ("_init", "_ready", "_process"):
            # inherited from a staged parent?
            ext = re.search(r"^extends\s+(\w+)", src, re.M)
            parent = cls.get(ext.group(1)) if ext else None
            if parent and f in decl.get(parent, set()):
                continue
            report(f"MISSING local {f}()  (in {p})")

keys = set()
for row in csv.reader(io.StringIO(blob(ROOT + "localization/strings.csv"))):
    if row:
        keys.add(row[0])
texts = dict(gd)
for p in staged(ROOT + "data/*.json"):
    texts[p] = blob(p)
for p, src in texts.items():
    for k in set(re.findall(r'"((?:EFFECT|MAIL|FIN|PRODUCT|EV|PAPER|REVIEW)_[A-Z0-9_]+)"', src)):
        if k not in keys and not k.endswith("_"):
            report(f"MISSING key {k}  (in {p})")
# Names, keys and card ids that exist only in the worktree's unstaged changes but that staged code uses.
import glob
import json
import os
DECL = r"^(?:static\s+)?(?:func|var|const|signal)\s+(\w+)|^@export(?:_\w+)?(?:\([^)]*\))?\s+var\s+(\w+)"  # top level only
work_names, staged_names = set(), set()
for p in glob.glob(ROOT + "scripts/**/*.gd", recursive=True):
    for a, b in re.findall(DECL, open(p, encoding="utf-8", errors="replace").read(), re.M):
        work_names.add(a or b)
for src in gd.values():
    for a, b in re.findall(DECL, src, re.M):
        staged_names.add(a or b)
only_work = {n for n in work_names - staged_names if len(n) > 3}
work_keys = {r[0] for r in csv.reader(io.StringIO(open(ROOT + "localization/strings.csv", encoding="utf-8").read())) if r}
only_keys = work_keys - keys
staged_cards = {json.loads(texts[p]).get("id", "") for p in texts if p.endswith(".json") and "/events/cards/" in p}
work_cards = set()
for p in glob.glob(ROOT + "data/events/cards/**/*.json", recursive=True):
    try:
        work_cards.add(json.load(open(p, encoding="utf-8")).get("id", ""))
    except (ValueError, UnicodeDecodeError):
        pass
only_cards = {c for c in work_cards - staged_cards if c}
for p, src in texts.items():
    code = re.sub(r"#.*", "", src) if p.endswith(".gd") else src
    bare = re.sub(r'"(?:\\.|[^"\\])*"', '""', code) if p.endswith(".gd") else ""
    for n in only_work:
        if re.search(r"\b" + re.escape(n) + r"\b", bare):
            report(f"UNSTAGED name {n}  (used in {p})")
    for k in re.findall(r'"([A-Z][A-Z0-9_]{3,})"', code):
        if k in only_keys:
            report(f"UNSTAGED key {k}  (in {p})")
    for c in re.findall(r'"([a-z_]+\.[a-z0-9_]+)"', code):
        if c in only_cards:
            report(f"UNSTAGED card {c}  (in {p})")
args = sys.argv[1:]
if "--save" in args:
    open(args[args.index("--save") + 1], "w", encoding="utf-8").write("\n".join(sorted(found)) + "\n")
    print(f"XREF baseline saved: {len(found)} known problem(s)")
    sys.exit(0)
known = set()
if "--base" in args:
    known = set(open(args[args.index("--base") + 1], encoding="utf-8").read().splitlines())
new = sorted(set(found) - known)
for line in new:
    print(line)
print(f"XREF {'OK' if not new else 'FAIL'} new_problems={len(new)} files={len(gd)}")
