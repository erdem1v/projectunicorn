"""stage_csv: stage one step's rows of localization/strings.csv, key by key, whatever else the worktree holds.

Usage (from the git root): python -I stage_csv.py <key regex> [--dry]
Starts from the INDEX version of the CSV (so steps stage one after another) and, for every key matching the regex:
  - a row the worktree changed replaces the index row in place;
  - a row the worktree added goes in right after the nearest preceding worktree row the index already has;
  - a row the worktree deleted leaves the index.
Rows are kept byte-exact (the file has no single quoting convention: never re-serialise it).
"""
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")
PATH = "project-unicorn/localization/strings.csv"


def key(line):
    return line.split(",", 1)[0]


def rows(text):
    # A logical row runs until its quotes balance: some values are quoted and span lines. Raw bytes are kept.
    out, cur = [], ""
    for line in text.splitlines(keepends=True):
        cur += line
        if cur.count('"') % 2 == 0:
            out.append(cur)
            cur = ""
    if cur:
        out.append(cur)
    return out


def main():
    rx = re.compile(sys.argv[1])
    idx = rows(subprocess.run(["git", "show", f":{PATH}"], capture_output=True, check=True).stdout.decode("utf-8"))
    work = rows(open(PATH, encoding="utf-8", newline="").read())
    wk = {key(l): l for l in work}
    out = list(idx)
    changed = added = deleted = 0
    for i, l in enumerate(out):
        k = key(l)
        if rx.search(k):
            if k not in wk:
                out[i] = None
                deleted += 1
            elif wk[k] != l:
                out[i] = wk[k]
                changed += 1
    out = [l for l in out if l is not None]
    have = {key(l) for l in out}
    for j, l in enumerate(work):
        k = key(l)
        if rx.search(k) and k not in have:
            anchor = next((key(work[a]) for a in range(j - 1, -1, -1) if key(work[a]) in have), None)
            pos = next((n + 1 for n, x in enumerate(out) if key(x) == anchor), len(out)) if anchor else 1
            out.insert(pos, l)
            have.add(k)
            added += 1
    print(f"csv: {added} added, {changed} changed, {deleted} deleted for /{sys.argv[1]}/")
    if "--dry" in sys.argv:
        return
    blob = subprocess.run(["git", "hash-object", "-w", "--stdin"], input="".join(out).encode("utf-8"),
                          capture_output=True, check=True).stdout.decode().strip()
    subprocess.run(["git", "update-index", "--cacheinfo", f"100644,{blob},{PATH}"], check=True)


if __name__ == "__main__":
    main()
