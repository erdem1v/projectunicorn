"""stage_step: stage only one step's changes of a file that several parallel steps edit.

Usage (from the git root):
  python -I stage_step.py list  <path>                      chunks of HEAD -> worktree, numbered
  python -I stage_step.py stage <path> [--re R]... [--idx 1,4] [--not-re R]...
      stages HEAD + the selected chunks (a chunk is selected when any of its changed lines matches a --re, or its number
      is in --idx; --not-re drops a chunk again) and prints what was left out.
The index entry is written straight from a blob (git hash-object -w + update-index --cacheinfo); the worktree is untouched.
"""
import difflib
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")


def git(*a, data=None):
    return subprocess.run(["git", *a], input=data, capture_output=True, check=True).stdout


def chunks(path):
    head = git("show", f"HEAD:{path}").decode("utf-8").splitlines(keepends=True)
    work = open(path, encoding="utf-8", newline="").read().splitlines(keepends=True)
    sm = difflib.SequenceMatcher(None, head, work, autojunk=False)
    return head, work, [op for op in sm.get_opcodes() if op[0] != "equal"]


def show(n, op, head, work, width=150):
    tag, i1, i2, j1, j2 = op
    print(f"[{n}] {tag} HEAD {i1 + 1}-{i2} -> WORK {j1 + 1}-{j2}")
    for l in head[i1:i2][:4]:
        print("   -", l.rstrip("\n")[:width])
    for l in work[j1:j2][:4]:
        print("   +", l.rstrip("\n")[:width])
    if i2 - i1 > 4 or j2 - j1 > 4:
        print(f"   ... ({i2 - i1} removed, {j2 - j1} added)")


def args(name):
    out, a = [], sys.argv
    for k, v in enumerate(a):
        if v == name and k + 1 < len(a):
            out.append(a[k + 1])
    return out


def main():
    cmd, path = sys.argv[1], sys.argv[2]
    head, work, ops = chunks(path)
    if cmd == "list":
        for n, op in enumerate(ops, 1):
            show(n, op, head, work)
        print(f"{len(ops)} chunk(s)")
        return
    res = [re.compile(r) for r in args("--re")]
    nres = [re.compile(r) for r in args("--not-re")]
    idx = {int(x) for v in args("--idx") for x in v.split(",") if x}
    pick = set()
    for n, (tag, i1, i2, j1, j2) in enumerate(ops, 1):
        lines = head[i1:i2] + work[j1:j2]
        if n in idx or any(r.search(l) for r in res for l in lines):
            if not any(r.search(l) for r in nres for l in lines):
                pick.add(n)
    out, cur = [], 0
    for n, (tag, i1, i2, j1, j2) in enumerate(ops, 1):
        out += head[cur:i1]
        out += work[j1:j2] if n in pick else head[i1:i2]
        cur = i2
    out += head[cur:]
    blob = git("hash-object", "-w", "--stdin", data="".join(out).encode("utf-8")).decode().strip()
    mode = git("ls-files", "-s", "--", path).decode().split()[0] or "100644"
    git("update-index", "--cacheinfo", f"{mode},{blob},{path}")
    print(f"staged {len(pick)}/{len(ops)} chunk(s) of {path}")
    for n, op in enumerate(ops, 1):
        if n not in pick:
            print("LEFT OUT:")
            show(n, op, head, work, 110)


if __name__ == "__main__":
    main()
