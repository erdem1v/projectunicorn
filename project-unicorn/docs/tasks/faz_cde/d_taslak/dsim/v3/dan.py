# D0s analiz yardimcilari. Kullanim: baska bir betikten exec(open("dan.py", encoding="utf-8").read()); dsim3 gerektirmez.
# Sonuclar out/<etiket>/<senaryo>[#<secenek>].pkl (tohum -> metrikler). Kapi ve tablolar yalniz tohum 1..20'yi okur (hi=100: PM3).
import pickle, os, statistics, math, json, sys
sys.stdout.reconfigure(encoding="utf-8")
OUTD = "out"
_C = {}


def fnam(tag, nm, opt=None):
    sig = "" if not opt else "#" + ",".join("%s=%s" % (k, opt[k]) for k in sorted(opt))
    return os.path.join(OUTD, tag, nm.replace("|", "_").replace(" ", "_").replace("*", "x").replace("+", "p") + sig + ".pkl")


def D(tag, nm, opt=None, hi=20):
    """{tohum: metrikler} (tohum <= hi) ya da None."""
    k = (tag, nm, tuple(sorted(opt.items())) if opt else None, hi)
    if k not in _C:
        f = fnam(tag, nm, opt)
        try:
            d = pickle.load(open(f, "rb"))
            _C[k] = {s: m for s, m in d.items() if s <= hi}
        except Exception:
            _C[k] = None
    return _C[k]


def have(tag, nm, opt=None, n=20):
    d = D(tag, nm, opt)
    return d is not None and len(d) >= n


def vals(tag, nm, key, idx=None, opt=None, hi=20):
    d = D(tag, nm, opt, hi)
    if not d:
        return []
    out = []
    for m in d.values():
        v = m[key]
        if idx is not None and v is not None:
            v = v[idx]
        if v is not None:
            out.append(v)
    return out


def md(tag, nm, key, idx=None, opt=None, hi=20):
    v = vals(tag, nm, key, idx, opt, hi)
    return statistics.median(v) if v else None


def mn(tag, nm, key, idx=None, opt=None, hi=20):
    v = vals(tag, nm, key, idx, opt, hi)
    return statistics.mean(v) if v else None


def tsum(tag, nm, key, idx=None, opt=None, hi=20):
    return sum(vals(tag, nm, key, idx, opt, hi))


def f1(x, nd=1):
    return "-" if x is None else (("%." + str(nd) + "f") % x).replace(".", ",")


def pc(x, nd=1):
    return "-" if x is None else (("%." + str(nd) + "f") % (100 * x)).replace(".", ",") + "%"


def aud(tag, nm, key, opt=None):
    return sum(m["aud"][key] for m in (D(tag, nm, opt) or {}).values())


def table(rows, head, align=None):
    """Markdown tablo (satirlar liste listesi)."""
    out = ["| " + " | ".join(head) + " |", "|" + "|".join(["---"] * len(head)) + "|"]
    for r in rows:
        out.append("| " + " | ".join("" if c is None else str(c) for c in r) + " |")
    return "\n".join(out)
