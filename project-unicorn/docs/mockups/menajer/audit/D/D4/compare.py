"""compare.py <base_dir> <new_dir> [--shell]: AUDIT lines keyed by path (auto names lose their counter).
Shell = the toast layer (new in D4) and the office overlay (its two old toasts gone); every other line (TopBar, LeftTabs, NewsTicker, the
window frames, pages and modals) must be byte-identical."""
import re, sys, pathlib
base_dir, new_dir = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
SHELL = ('/ToastLayer', '/CenterViewport/OfficeView/Overlay')
def load(path):
    rows, counts = {}, {}
    for line in path.read_text(encoding='utf-8').splitlines():
        if not line.startswith('AUDIT|'):
            continue
        parts = line.split('|')
        p = re.sub(r'@(\w+)@\d+', r'@\1@N', parts[1])
        k = counts.get(p, 0); counts[p] = k + 1
        rows[(p, k)] = '|'.join(parts[2:])
    return rows
total = 0
for bf in sorted(base_dir.glob('*.txt')):
    nf = new_dir / bf.name
    if not nf.exists():
        print('MISSING', bf.name); total += 1; continue
    b, n = load(bf), load(nf)
    same, page, shell = 0, [], []
    for key in sorted(set(b) | set(n)):
        bv, nv = b.get(key), n.get(key)
        if bv == nv:
            same += 1
        elif key[0].startswith(SHELL):
            shell.append((key, bv, nv))
        else:
            page.append((key, bv, nv))
    print(f'{bf.stem}: identical={same} page_changed={len(page)} shell_changed={len(shell)}')
    for key, bv, nv in page[:12]:
        print(f'   PAGE {key[0]}#{key[1]}\n      base: {bv}\n      new:  {nv}')
    total += len(page)
    if '--shell' in sys.argv:
        for key, bv, nv in shell:
            print(f'   SHELL {key[0]}#{key[1]}\n      base: {bv}\n      new:  {nv}')
print(f'TOTAL page lines changed: {total}')
