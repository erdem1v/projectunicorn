# Çakışan hunk'ları satır içinde, sözcük düzeyinde üç yollu birleştirir: taban satırı, onların satırı (HEAD), bizim satırımız.
# Her çakışmada iki tarafın satır sayısı tabandakiyle eşleşmeli; sözcük düzeyinde değişiklikler çakışmazsa birleştirir, çakışırsa
# dosyayı yazmaz ve çakışan satırı gösterir. Usage: python linemerge.py <birleşik dosya> <taban dosya> <onlar> <biz>
import difflib
import re
import sys

merged_p, base_p, theirs_p, ours_p = sys.argv[1:5]
rd = lambda p: open(p, encoding='utf-8', newline='').read()
merged, base, theirs, ours = rd(merged_p), rd(base_p).split('\n'), rd(theirs_p).split('\n'), rd(ours_p).split('\n')
TOK = re.compile(r'\s+|[^\s]+')


def merge_line(b, t, o):
    if t == o:
        return t
    if t == b:
        return o
    if o == b:
        return t
    bt, tt, ot = TOK.findall(b), TOK.findall(t), TOK.findall(o)
    def edits(x):
        return [op for op in difflib.SequenceMatcher(None, bt, x, autojunk=False).get_opcodes() if op[0] != 'equal']
    et, eo = edits(tt), edits(ot)
    for _, i1, i2, _, _ in et:
        for _, k1, k2, _, _ in eo:
            if max(i1, k1) < min(i2, k2) or (i1 == i2 == k1 == k2):
                return None
    out, i = [], 0
    allops = sorted([(i1, i2, tt[j1:j2]) for _, i1, i2, j1, j2 in et] + [(i1, i2, ot[j1:j2]) for _, i1, i2, j1, j2 in eo])
    for i1, i2, rep in allops:
        out += bt[i:i1] + rep
        i = i2
    return ''.join(out + bt[i:])


def find_block(lines, block):
    for s in range(len(lines) - len(block) + 1):
        if lines[s:s + len(block)] == block:
            return s
    return -1


pat = re.compile(r'^<<<<<<< [^\n]*\n(.*?)^=======\n(.*?)^>>>>>>> [^\n]*\n', re.S | re.M)
out, pos, ok = [], 0, True
for m in pat.finditer(merged):
    t_lines, o_lines = m.group(1).split('\n')[:-1], m.group(2).split('\n')[:-1]
    ts, os_ = find_block(theirs, t_lines), find_block(ours, o_lines)
    # Taban satırları: bizim taraftaki hunk'ın tabandaki karşılığı, aynı uzunlukta ve sözcük benzerliği en yüksek pencere.
    best, bs = -1.0, -1
    for s in range(len(base) - len(o_lines) + 1):
        r = sum(difflib.SequenceMatcher(None, base[s + k], o_lines[k]).quick_ratio() for k in range(len(o_lines)))
        if r > best:
            best, bs = r, s
    if len(t_lines) != len(o_lines) or ts < 0 or os_ < 0 or bs < 0:
        print('SHAPE', len(t_lines), len(o_lines)); ok = False; break
    res = []
    for k in range(len(o_lines)):
        line = merge_line(base[bs + k], t_lines[k], o_lines[k])
        if line is None:
            print('WORD-CONFLICT line', k, '\n  base:', base[bs + k][:200], '\n  them:', t_lines[k][:200], '\n  ours:', o_lines[k][:200])
            ok = False
            break
        res.append(line)
    if not ok:
        break
    out.append(merged[pos:m.start()] + '\n'.join(res) + '\n')
    pos = m.end()
if ok:
    open(merged_p, 'w', encoding='utf-8', newline='').write(''.join(out) + merged[pos:])
    print('merged', len(out), 'hunks')
else:
    sys.exit(1)
