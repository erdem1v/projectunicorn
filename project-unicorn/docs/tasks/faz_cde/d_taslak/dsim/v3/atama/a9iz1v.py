# A9 (Opus incelemesi): a8iz.iz1'in buyuk kart puani degistirilebilen kopyasi (sinir vakasi: buyuk kart uc kisiyle bu sprintte bitebiliyorsa).
#   python -I a9iz1v.py <buyuk_puan> [kol,kol]
import os, sys, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8iz as Z
R8, R6, A, D, CFG2, P = Z.R8, Z.R6, Z.A, Z.D, Z.CFG2, Z.P


_roll = P.rollout


def rollout_quiet(*a, **k):
    """Ileri oynatmanin atama olaylari ize yazilmaz (a8iz.iz1'de yaziliyordu: secilmeyen seceneklerin olaylari gercek izin arasina karisir)."""
    on = Z.TR["on"]
    Z.TR["on"] = False
    try:
        return _roll(*a, **k)
    finally:
        Z.TR["on"] = on


def iz(big, arms, quiet=True, big_last=False):
    P.rollout = rollout_quiet if quiet else _roll
    out = []
    for arm in arms:
        R8.set_cfg8(R6.ARMS[arm], 7, "H")
        P.LOG = []
        Dsave = D.H0
        D.H0 = 0.0
        CFG2.hata = "bugun"
        D.Card._n = 0
        ppl = [D.Person(n, "dev", {"eng": 2 * s, "qa": max(0, 2 * s - 1), "design": 0, "product": 0}, ("build", "test")) for n, s in (("A", 4), ("B", 3), ("C", 3))]
        team = D.Team(ppl, 2)
        A.ARZ_L[0] = 12
        spec = [("Buyuk", big, 2), ("Kucuk1", 10.0, 1), ("Kucuk2", 10.0, 1)]
        if big_last:
            spec = spec[1:] + spec[:1]
        cards = []
        for pos, (nm, need, rq) in enumerate(spec):
            c = D.Card("feature", 0, 1, "logic")
            c.base_need = [0.0, need, 0.5, 0.0]
            c.need = list(c.base_need)
            c.size = need + 0.5
            c.fixed = True
            c.kadro = [1, max(1, int(math.ceil(need / D.SLICE))), 1, 1]
            c.t0 = c.need[2]
            c._rq = [0, rq, 0, 0]
            c.pos = pos
            c.enter = 0
            cards.append(c)
        cname = {c.id: nm for c, (nm, _, _) in zip(cards, spec)}
        Z.TR["events"].clear()
        Z.TR["on"] = True
        done = {}
        for sp in range(2):
            Z.TR["base"] = 2.0 * sp
            for k in range(2):
                Z._w8(team, cards, D.WSt(team.n, len(cards)), 7, k, 2, 2 * sp + k, (), (), True, None, True, None, None, False, (False, False), None)
            for c in cards:
                if c.phase() == 4 and c.id not in done:
                    done[c.id] = (c.done_at, sp + 1)
        Z.TR["on"] = False
        D.H0 = Dsave
        segs = Z.seg_table(Z.TR["events"], team.ids, 4.0)
        out.append("**%s** (buyuk kart %.0f puan, %s, ileri oynatma olaylari %s)" % (Z.KOL.get(arm, arm), big, "planda sonda" if big_last else "planda ilk", "ize yazilmadi" if quiet else "ize yazildi (a8iz gibi)"))
        out.append(Z.fmt_segs(segs, {}, cname))
        out.append("Kartlar: " + "; ".join("%s biter h%.2f (sprint %d)" % ((cname[c.id],) + done[c.id]) if c.id in done else "%s bitmedi" % cname[c.id] for c in cards))
        if arm == "P" and P.LOG:
            for k, res, th in P.LOG[:1]:
                out.append("ilk hafta secenek puanlari (F = sprintte biten kartlarin plan sirasi agirligi): " + "; ".join(
                    "%s %s F=%.2f" % (t_.get("mode"), t_.get("beta", t_.get("sec", "")), sc["F"]) for t_, sc in res))
        P.LOG = None
        out.append("")
    return "\n".join(out)


if __name__ == "__main__":
    #   python -I a9iz1v.py <buyuk_puan> [kol,kol] [quiet 1|0] [buyuk_sonda 0|1]
    print(iz(float(sys.argv[1]), sys.argv[2].split(",") if len(sys.argv) > 2 else ["R", "P"], (sys.argv[3] if len(sys.argv) > 3 else "1") == "1",
             (sys.argv[4] if len(sys.argv) > 4 else "0") == "1"))
