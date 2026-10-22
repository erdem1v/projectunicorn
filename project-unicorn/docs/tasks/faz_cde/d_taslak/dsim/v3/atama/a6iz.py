# A6 iz: bir koşuyu (senaryo, tohum, kol, kalibrasyon) kart kart kaydeder ve okunur metin basar.
#   python -I a6iz.py mvp <senaryo> <tohum> <kol[,kol]> <kal>      MVP kartlari: kim, hangi asama, hangi hafta, ne bekledi
#   python -I a6iz.py hata <senaryo> <tohum> <kol[,kol]> <kal>     kart basina dogan/bulunan/kacan hata, kimin yaptigi
#   python -I a6iz.py soz <senaryo> <tohum> <kol[,kol]> <kal>      soz kartlari: plandaki sira, kim, ne zaman bitti, vade
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a6run as R6
H, A, D = R6.H, R6.A, R6.D

_w3 = A.week3
WEEKS = []          # (hafta, {kart: (asama, [ilerleme])}) gercek oynatma


def wrapped(team, cards, st, seed, k, sw, off, ahead=(), prepq=(), logit=True, watch=None, track=False, puller=None, aud=None,
            probe=False, front=(False, False), alog=None):
    if alog is not None:
        alog.append(("W", off, k))
    r = _w3(team, cards, st, seed, k, sw, off, ahead, prepq, logit, watch, track, puller, aud, probe, front, alog)
    if alog is not None:
        WEEKS.append((off, {c.id: (c.phase(), [round(x, 1) for x in c.prog]) for c in cards}))
    return r


D.week2 = wrapped


def run_trace(scen, seed, arm, cal):
    R6.set_cfg6(R6.ARMS[arm], seed, cal)
    fn, kw = D.SCEN[scen]
    kw = dict(kw)
    kw.setdefault("weeks", 60)
    del WEEKS[:]
    alog = []
    sim = H.A6Sim(fn(), seed, trace=True, alog=alog, **kw)
    sim.run()
    return sim, alog, list(WEEKS)


def placements(alog):
    """kart -> [(mutlak an, satir, (kisiler))]"""
    out = {}
    wk = 0
    for e in alog:
        if e[0] == "W":
            wk = e[1]
            continue
        t, r, pl = e
        by = {}
        for pid, cid in pl:
            by.setdefault(cid, []).append(pid)
        for cid, ps in by.items():
            out.setdefault(cid, []).append((wk + t, r, tuple(sorted(ps))))
    return out


def stars_of(sim):
    team = sim.cells[0].team
    st = A.tinfo(team)["stars"]
    return {team.ids[i]: tuple(st[i]) for i in range(team.n)}


ROWN = ("Tasarim", "Yazilim", "Test")


def fmt_pl(pls, stars):
    segs = []
    last = None
    for t, r, ps in pls:
        key = (r, ps)
        if key != last:
            segs.append("h%.1f %s: %s" % (t, ROWN[r], "+".join("%s(%.1f*)" % (p, stars[p][r]) for p in ps)))
            last = key
    return "; ".join(segs)


def story_mvp(scen, seed, arms, cal):
    for arm in arms:
        sim, alog, weeks = run_trace(scen, seed, arm, cal)
        stars = stars_of(sim)
        pls = placements(alog)
        print("=== %s %s tohum %d kal %s: MVP haftasi %s, teslim %.1f, acik hata (medyan) %s" % (arm, scen, seed, cal, sim.mvp_week,
              D.metrics(sim, A.LO)["deliv"], D.metrics(sim, A.LO)["open_med"]))
        print("kisiler:", {p: tuple(round(x, 1) for x in s) for p, s in stars.items()})
        mvp = sorted([r for r in sim.cardrec if r["id"] in sim.mvp_ids], key=lambda r: r["id"])
        for r in mvp:
            ph_by_week = [(off, d[r["id"]][0]) for off, d in weeks if r["id"] in d]
            first_ph = {}
            for off, ph in ph_by_week:
                first_ph.setdefault(ph, off)
            print(" kart %d hat %d (%s) %d puan, kapi %s, girdi h%s, teslim h%s (sprint %d); hazirlayan %s hazirlik %.2f; hata dogan %d bulunan %d; sonraki asamaya gecis haftalari %s" % (
                r["id"], r["line"], sim.prof[r["line"]], r["size"], r["req"], r["enter"], r["done_w"], r["sprint"], r["preparer"], r["ready"], r["nbugs"], r["found"], first_ph))
            print("   yerlesim:", fmt_pl(pls.get(r["id"], []), stars))
        others = [r for r in sim.cardrec if r["id"] not in sim.mvp_ids and r["done_w"] <= (sim.mvp_week or 99)]
        print(" MVP'ye kadar biten diger kartlar:", [(r["id"], r["kind"], r["size"], "h%s" % r["done_w"]) for r in others])


def story_hata(scen, seed, arms, cal, lo=20):
    for arm in arms:
        sim, alog, weeks = run_trace(scen, seed, arm, cal)
        stars = stars_of(sim)
        m = D.metrics(sim, A.LO)
        print("=== %s %s tohum %d kal %s: acik hata medyan %s, teslim %.1f, MVP h%s" % (arm, scen, seed, cal, m["open_med"], m["deliv"], sim.mvp_week))
        print("kisiler:", {p: tuple(round(x, 1) for x in s) for p, s in stars.items()})
        feat = [r for r in sim.cardrec if r["kind"] == "feature" and r["done_w"] > lo]
        tot = {"n": 0, "H": 0.0, "born": 0, "found": 0, "size": 0}
        for r in feat:
            tot["n"] += 1
            tot["H"] += r["H"]
            tot["born"] += r["nbugs"]
            tot["found"] += r["found"]
            tot["size"] += r["size"]
        print(" teslim edilen ozellik karti (h>%d): %d, puan %d, beklenen dogan %.1f, dogan %d, test yakaladi %d, kacan %d" % (lo, tot["n"], tot["size"], tot["H"], tot["born"], tot["found"], tot["born"] - tot["found"]))
        byp = {}
        for r in feat:
            w = sum(v[0] for v in r["dev"].values()) or 1.0
            for p, (wk_, st_) in r["dev"].items():
                e = byp.setdefault(p, [0.0, 0.0, 0.0])
                e[0] += wk_
                e[1] += r["H"] * wk_ / w
                e[2] += r["nbugs"] * wk_ / w

        fx = [r for r in sim.cardrec if r["kind"] == "fix"]
        print(" duzeltme karti: %d adet, toplam %d puan; girdiğinden teslime ortalama %.1f hafta; acik hata (hafta 10,20,..): %s" % (
            len(fx), sum(r["size"] for r in fx), (sum(r["done_w"] - r["enter"] for r in fx) / len(fx)) if fx else 0, [sim.openw[i] for i in range(9, len(sim.openw), 10)]))
        print(" duzeltme isi / kapasite %.3f, tum duzeltme payi %.3f, sprintte duzeltme payi (medyan) %.3f" % (m["infix"], m["tot_fix"], m["fix_late"] or 0))
        print(" Yazilim isi (puan) ve ona dusen beklenen hata, kisi basina:")
        for p, (wk_, hh, bb) in sorted(byp.items(), key=lambda x: -x[1][0]):
            print("   %-6s %.1f* : %6.1f puan, beklenen %5.1f, dogan %5.1f" % (p, stars[p][1], wk_, hh, bb))
        big = sorted(feat, key=lambda r: -r["H"])[:8]
        for r in big:
            print("   kart %d hat %d %dp kapi R=%s H=%.2f dogan %d bulunan %d C=%.2f hazirlik h=%.2f yazilim:%s test:%s" % (
                r["id"], r["line"], r["size"], r["R"], r["H"], r["nbugs"], r["found"], r["C"], r["hcut"],
                {p: "%.0fp/%.1f*" % v for p, v in r["dev"].items()}, {p: "%.0fp/%.1f*" % v for p, v in r["test"].items()}))


def story_soz(scen, seed, arms, cal):
    for arm in arms:
        sim, alog, weeks = run_trace(scen, seed, arm, cal)
        stars = stars_of(sim)
        pls = placements(alog)
        pr = D._prom(sim)
        print("=== %s %s tohum %d kal %s: soz %s" % (arm, scen, seed, cal, pr))
        made = {m[0]: m for m in sim.prom_made}
        done = {i: (sz, due, ds) for i, sz, due, ds in sim.prom_log}
        byid = {r["id"]: r for r in sim.cardrec}
        for cid, m in sorted(made.items()):
            d = done.get(cid)
            late = d is not None and d[2] > m[2]
            if d is None or late:
                r = byid.get(cid)
                print(" soz karti %d: %s; vade sprint %s, %s" % (cid, "puan %s" % m[1], m[2], "teslim sprint %s" % d[2] if d else "TESLIM EDILMEDI (kosu sonunda)"))
                if r:
                    print("   girdi h%s, plan sirasi %s, kapi %s, yazilim %s, test %s, tasarim %s, hazirlayan %s" % (r["enter"], r["pos"], r["req"], r["dev"], r["test"], r["des"], r["preparer"]))
                    print("   yerlesim:", fmt_pl(pls.get(cid, []), stars))


if __name__ == "__main__":
    cmd, scen, seed, arms, cal = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4].split(","), sys.argv[5]
    {"mvp": story_mvp, "hata": story_hata, "soz": story_soz}[cmd](scen, seed, arms, cal)
