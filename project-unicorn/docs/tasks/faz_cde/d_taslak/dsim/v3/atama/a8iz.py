# A8 izleri. python -I a8iz.py iz1 [kol,kol]        Erdem'in ornegi: 3 gelistirici, 3 kart (buyuk kart 2 kisiyle 2 sprintte, iki kucuk kart 1 kisiyle haftada birer)
#           python -I a8iz.py iz2 <senaryo> <tohum> [kol,kol]   gercek tohum: MVP'ye giden sprintler, hafta hafta kim hangi kartta
# Iz, atama olaylarindan (her asama bitisi / hafta basi) uretilir: assign_dispatch'e sarmalayici takilir, her olayda "kim hangi kartin hangi asamasinda" kaydedilir.
import os, sys, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
H, A, D, CFG2, P = R8.H, R8.A, R8.D, R8.CFG2, R8.P
R6 = R8.R6

ROWN = ("Tasarim", "Yazilim", "Test")
KOL = {"R": "R (bugünkü kural)", "T": "Tarif (Erdem'in tarifi)", "T_plan": "T_plan (tanı kolu)", "P": "P (yeni planlayıcı)", "P_sabit": "P, ileri oynatmasız", "P_rp": "P, satır seçimi eski kuralla"}
TR = {"on": False, "base": 0.0, "events": []}
_ad = A.assign_dispatch


def ad_wrap(team, cards, st, front, aud, alog):
    r = _ad(team, cards, st, front, aud, alog)
    if TR["on"] and not P.IN_ROLL[0]:                  # ileri oynatmanin (secilmeyen seceneklerin) atamalari ize yazilmaz
        who = {}
        for ci, crew in st.crews.items():
            for pi in crew:
                who[team.ids[pi]] = (cards[ci].id, cards[ci].phase())
        TR["events"].append((TR["base"] + A.CTX[0] + st.t, who, [team.ids[pi] for pi in st.free], {c.id: c.phase() for c in cards}))
    return r


A.assign_dispatch = ad_wrap
_w8 = A.week3                                   # P.week8 (D.week2 ile ayni)


def seg_table(events, ids, t_end):
    """Olay listesinden kisi basina (t0, t1, kart, asama) parcalari; bos = None."""
    segs = {p: [] for p in ids}
    ev = sorted(events, key=lambda e: e[0])
    for i, (t, who, free, ph) in enumerate(ev):
        t1 = ev[i + 1][0] if i + 1 < len(ev) else t_end
        if t1 - t < 1e-9:
            continue
        for p in ids:
            cur = who.get(p)
            key = (cur[0], cur[1]) if cur else None
            if segs[p] and segs[p][-1][2] == key and abs(segs[p][-1][1] - t) < 1e-9:
                segs[p][-1][1] = t1
            else:
                segs[p].append([t, t1, key])
    return segs


def fmt_segs(segs, names, cname):
    out = []
    for p, lst in segs.items():
        row = []
        for t0, t1, key in lst:
            if key is None:
                row.append("h%.2f-h%.2f bosta" % (t0, t1))
            else:
                row.append("h%.2f-h%.2f %s (%s)" % (t0, t1, cname.get(key[0], "kart%d" % key[0]), ROWN[D.ROW[key[1]]] if key[1] < 4 else "-"))
        out.append("  %-8s %s" % (names.get(p, p), "; ".join(row)))
    return chr(10).join(out)


def week_table(segs, names, cname, nweeks):
    """Hafta hafta tablo: kisi satirlari, hafta sutunlari; hucre = o hafta icinde kart (asama) ve harcanan hafta kesri, bosluk 'bosta'."""
    hdr = "| Kişi | " + " | ".join("Hafta %d" % (w + 1) for w in range(nweeks)) + " |"
    out = [hdr, "|---|" + "---|" * nweeks]
    for p, lst in segs.items():
        cells = []
        for w in range(nweeks):
            items = []
            for t0, t1, key in lst:
                a, b = max(t0, w), min(t1, w + 1)
                if b - a < 0.005:
                    continue
                nm = "bosta" if key is None else "%s %s" % (cname.get(key[0], "kart%d" % key[0]), ROWN[D.ROW[key[1]]].lower() if key[1] < 4 else "-")
                if items and items[-1][0] == nm:
                    items[-1][1] += b - a
                else:
                    items.append([nm, b - a])
            cells.append("; ".join("%s %.2f" % (n_, d_) if n_ != "bosta" else "boşta %.2f" % d_ for n_, d_ in items).replace(".", ",") if items else "-")
        out.append("| %s | %s |" % (names.get(p, p), " | ".join(cells)))
    return chr(10).join(out)


# ------------------------------------------------------------------ iz 1
def iz1(arms, big_first=True):
    stars = [("A", 4), ("B", 3), ("C", 3)]
    lines = []
    for arm in arms:
        R8.set_cfg8(R6.ARMS[arm], 7, "H")
        Dsave = D.H0
        D.H0 = 0.0                                          # hata zari kapali: ornek yalniz atamayi gosteriyor
        CFG2.hata = "bugun"
        D.Card._n = 0
        ppl = [D.Person(n, "dev", {"eng": 2 * s, "qa": max(0, 2 * s - 1), "design": 0, "product": 0}, ("build", "test")) for n, s in stars]
        team = D.Team(ppl, 2)
        A.ARZ_L[0] = 12
        spec = [("Buyuk", 100.0, 2), ("Kucuk1", 10.0, 1), ("Kucuk2", 10.0, 1)]
        if not big_first:
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
        TR["events"].clear()
        TR["on"] = True
        done = {}
        for sp in range(2):
            TR["base"] = 2.0 * sp
            for k in range(2):
                _w8(team, cards, D.WSt(team.n, len(cards)), 7, k, 2, 2 * sp + k, (), (), True, None, True, None, None, False, (False, False), None)
            for c in cards:
                if c.phase() == 4 and c.id not in done:
                    done[c.id] = (c.done_at, sp + 1)
        TR["on"] = False
        D.H0 = Dsave
        segs = seg_table(TR["events"], team.ids, 4.0)
        lines.append("**%s**" % KOL.get(arm, arm))
        lines.append("")
        lines.append(week_table(segs, {}, cname, 4))
        lines.append("")
        lines.append("Kartlar: " + "; ".join("%s %s" % (cname[c.id], ("biter h%.2f (sprint %d)" % done[c.id]).replace(".", ",") if c.id in done else ("bitmedi, kalan %.1f puan" % c.remaining()).replace(".", ",")) for c in cards))
        lines.append("")
    return "\n".join(lines)


# ------------------------------------------------------------------ iz 2
def iz2(scen, seed, arms, sprints=3):
    out = []
    for arm in arms:
        R8.set_cfg8(R6.ARMS[arm], seed, "H")
        fn, kw = D.SCEN[scen]
        kw = dict(kw)
        kw.setdefault("weeks", 60)
        sim = H.A6Sim(fn(), seed, trace=True, **kw)
        TR["events"].clear()
        TR["on"] = True
        TR["base"] = 0.0
        w8 = A.week3

        def wrap(team, cards, st, seed_, k, sw, off, ahead=(), prepq=(), logit=True, watch=None, track=False, puller=None, aud=None, probe=False, front=(False, False), alog=None):
            TR["on"] = bool(track) and off < 2 * sprints
            TR["base"] = off - k
            return w8(team, cards, st, seed_, k, sw, off, ahead, prepq, logit, watch, track, puller, aud, probe, front, alog)
        D.week2 = wrap
        try:
            sim.run()
        finally:
            D.week2 = w8
            TR["on"] = False
        team = sim.cells[0].team
        names = {p.id: "%s(%s)" % (p.id, "/".join("%.1f*" % (A.tinfo(team)["stars"][i][r]) for r in range(3))) for i, p in enumerate(team.p)}
        cname = {}
        m = D.metrics(sim, A.LO)
        out.append("**%s** · %s, tohum %d · MVP haftası %s · teslim %.1f puan/hf · açık hata (medyan) %s" % (KOL.get(arm, arm), scen, seed, sim.mvp_week, m["deliv"], m["open_med"]))
        out.append("")
        segs = seg_table([e for e in TR["events"] if e[0] < 2 * sprints], team.ids, 2.0 * sprints)
        recs = {r["id"]: r for r in sim.cardrec}
        for cid in sorted({c for e in TR["events"] for c in e[3]}):
            r = recs.get(cid)
            cname[cid] = ("kart%d" % cid) + ("*" if cid in sim.mvp_ids else "") + (" (%dp)" % r["size"] if r else "")
        nshow = max(4, int(sim.mvp_week or 4))
        out.append(week_table(segs, names, cname, nshow))
        out.append("")
        done = sorted((r["done_w"], r["id"], r["size"]) for r in sim.cardrec if r["done_w"] <= 2 * sprints and r["kind"] == "feature")
        out.append("Biten kartlar (sprint sonu haftası, kart, puan; * = MVP kartı): " + ", ".join("h%s %s%s %dp" % (w, "kart%d" % i, "*" if i in sim.mvp_ids else "", sz) for w, i, sz in done))
        out.append("")
    return "\n".join(out)


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "iz1":
        print(iz1(sys.argv[2].split(",") if len(sys.argv) > 2 else ["R", "T", "T_plan", "P"]))
    elif cmd == "iz1b":
        print(iz1(sys.argv[2].split(",") if len(sys.argv) > 2 else ["R", "T", "T_plan", "P"], big_first=False))
    elif cmd == "iz2":
        print(iz2(sys.argv[2], int(sys.argv[3]), sys.argv[4].split(",") if len(sys.argv) > 4 else ["R", "T", "T_plan", "P"]))
