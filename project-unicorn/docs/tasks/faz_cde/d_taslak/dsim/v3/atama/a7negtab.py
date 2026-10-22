# A7: delta < 0 kirpilmis R kolu (out6/a7neg) ile ana R ve tarif kiyasi. python -I a7negtab.py
import os, sys, pickle, math
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
def ld(tag, arm, sc):
    try:
        return pickle.load(open(os.path.join(HERE, "out6", tag, "H", arm + "__" + sc.replace("|", "_") + ".pkl"), "rb"))
    except Exception:
        return {}
def pair(a, b, k):
    s = sorted(set(a) & set(b)); d = [a[x][k] - b[x][k] for x in s]; n = len(d)
    if n < 2: return None
    m = sum(d) / n; se = math.sqrt(sum((x - m) ** 2 for x in d) / (n - 1) / n)
    return "%+.1f ± %.1f (%d/%d)" % (m, se, sum(1 for x in d if x < 0), n)
for sc in ("S3", "S4", "S5", "S6", "PR|S3", "PR|S4", "PR|S5", "PR|S6"):
    rc, r, t = ld("a7neg", "R", sc), ld("ana", "R", sc), ld("ana", "T", sc)
    if not rc: continue
    mr = sum(r[s]["born"] for s in rc) / len(rc); mc = sum(rc[s]["born"] for s in rc) / len(rc)
    print("%-6s n=%d  R dogan %.1f, R kirpik %.1f (%+.1f%%) | T-R %s | T-Rkirpik %s | kacan T-R %s, T-Rkirpik %s | acik T-Rkirpik %s, teslim T-Rkirpik %s" % (
        sc, len(rc), mr, mc, 100 * (mc / mr - 1), pair(t, r, "born"), pair(t, rc, "born"), pair(t, r, "esc"), pair(t, rc, "esc"), pair(t, rc, "open_med"), pair(t, rc, "deliv")))
