"""C0s dogrulama: Python U'su, PROBE FIT / PROBE LEAD satirlarindaki oyun U'suyla ayni mi? python -I.
Aday U'su rakip penceresi dahil (PROBE AREAS'in ucuncu sayisi = alanin launches'i)."""
import sys, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_data as D, c0s_model as M

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass


def prospect_u(run, day, star, sector, core2=M.CORE_2_NOW):
    """Aday U'su: AREAS satirindaki seviye ve launches ile; gun icinde son AREAS satiri (day) ya da onceki."""
    d = day
    while d > 0 and d not in run["areas"]:
        d -= 1
    ar = run["areas"].get(d)
    if ar is None:
        return None
    lv = {a: ar[a][0] for a in D.AREAS if a in ar}
    la = {a: ar[a][2] for a in D.AREAS if a in ar}
    ref = M.ref_for(star, sector, core2, launches=la, rivals=True)
    return M.fit(lv, ref, sector)


def main():
    tot = ok = 0
    bad = collections.Counter()
    ex = []
    names = [D.run_name(a, s) for a in D.ARMS for s in D.SEEDS] + ["full_run_fix_worst_desk_7", "full_run_quality_core_7"]
    for n in names:
        r = D.load(n)
        for l in r["lead"]:
            if l["u"] is None:
                continue
            f = prospect_u(r, l["day"], l["star"], l["sector"])
            if f is None:
                continue
            tot += 1
            if f["value"] == l["u"] and (l["loss"] == "-" or f["loss_area"] == l["loss"]) and (l["loss"] != "-" or f["loss_area"] == ""):
                ok += 1
            else:
                bad[(l["star"], l["day"] <= 12)] += 1
                if len(ex) < 12:
                    ex.append((n, l["day"], l["star"], l["sector"], l["u"], l["loss"], f["value"], f["loss_area"]))
    print("PROBE LEAD: %d / %d ayni (u ve loss)" % (ok, tot))
    print("tutmayan:", dict(bad))
    for e in ex:
        print(e)
    # imza anindaki FIT (hesap U'su, kosu adaylarinin U'su)
    tot = ok = 0; ex = []
    for n in names:
        r = D.load(n)
        for s in r["sign"]:
            fr = r["fit"].get(s["id"])
            if not fr:
                continue
            f = prospect_u(r, s["day"], s["star"], s["sector"])
            tot += 1
            if f["value"] == fr["u"]:
                ok += 1
            elif len(ex) < 8:
                ex.append((n, s["day"], s["star"], s["sector"], fr["u"], f["value"]))
    print("PROBE FIT: %d / %d ayni" % (ok, tot))
    for e in ex:
        print(e)
    # SIGN areas ile AREAS ayni mi
    d = 0; k = 0
    for n in names[:2]:
        r = D.load(n)
        for s in r["sign"]:
            ar = r["areas"].get(s["day"])
            if ar:
                k += 1
                if all(abs(ar[a][0] - s["areas"].get(a, -1)) < 0.0015 for a in D.AREAS if a in ar):
                    d += 1
    print("SIGN.areas == AREAS: %d / %d" % (d, k))


if __name__ == "__main__":
    main()
