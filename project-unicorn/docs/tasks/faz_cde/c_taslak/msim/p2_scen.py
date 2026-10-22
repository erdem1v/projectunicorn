"""Bolum 2: tek hesap senaryolari (R9 sekilleri, M2, M6, M8), kesinti (M7), butce kesintisi (M9), kart izi (M13). python -I."""
import sys, os, json, random, statistics as st, collections, pickle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import k5, bot, model as M, scen

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
os.makedirs(OUT, exist_ok=True)
J = {}
T = []


def md(rows, head):
    s = "| " + " | ".join(head) + " |\n|" + "---|" * len(head) + "\n"
    for r in rows:
        s += "| " + " | ".join(str(c) for c in r) + " |\n"
    return s


# ------------------------------------------------------------------ R9 sekilleri
def r9_tables():
    names = {"A": "A düzenli", "B": "B donmuş (20. haftada durur)", "C": "C hızlı ama özensiz", "D": "D durgun (40'ta durur, 120'de döner)"}
    rows = []
    ned_new = 0; ned_old = 0
    for shape in "ABCD":
        for star in (1, 2, 3):
            for mode in ("old", "new"):
                r = scen.run_shape(shape, star, mode, renewals=True, risk=True)
                ser, below, ned, big = scen.shape_summary(r)
                if mode == "new": ned_new += ned
                else: ned_old += ned
                if star == 2:
                    left = "-" if r["left"] is None else "hf %d (%s)" % (r["left"], {"risk": "Risk", "renew_stance": "yenilemedi", "renew_leave": "bütçe"}[r["left_why"]])
                    rows.append([names[shape], "eski" if mode == "old" else "yeni"] + [("-" if x is None else x) for x in ser] + [left, ned, big])
    rows2 = []
    for shape in "ABCD":
        for mode in ("old", "new"):
            cells = []
            for star in (1, 2, 3):
                r = scen.run_shape(shape, star, mode, renewals=True, risk=True)
                cells.append("-" if r["left"] is None else "hf %d" % r["left"])
            rows2.append([names[shape], "eski" if mode == "old" else "yeni"] + cells)
    J["r9_ned_new"] = ned_new; J["r9_ned_old"] = ned_old
    return (md(rows, ["Oyuncu", "Model", "hf 1", "hf 4", "hf 12", "hf 26", "hf 52", "hf 104", "hf 208", "ayrılma", "nedensiz", "en büyük düşüş"]),
            md(rows2, ["Oyuncu", "Model", "1★ ayrılma", "2★ ayrılma", "3★ ayrılma"]))


# ------------------------------------------------------------------ M2
def m2_tables():
    rows = []
    byband = collections.defaultdict(lambda: collections.defaultdict(list))
    rej = collections.Counter(); tot = collections.Counter()
    ned_new = 0
    for arm, seed in (("worst", 7), ("worst", 11)):
        for (t0, star, sec, mode, rj, s0, mn, s12, marg, nd) in scen.m2_grid(arm, seed):
            band = "7-20" if t0 <= 20 else ("21-40" if t0 <= 40 else "41-100")
            tot[(mode, band)] += 1
            if rj:
                rej[(mode, band)] += 1; continue
            byband[(mode, band)]["dip"].append(mn < s0)
            byband[(mode, band)]["drop12"].append(s12 - s0)
            byband[(mode, band)]["mnminus"].append(mn - s0)
            byband[(mode, band)]["marg"].append(marg)
    out = []
    for mode in ("old", "new"):
        for band in ("7-20", "21-40", "41-100"):
            d = byband[(mode, band)]
            n = len(d["dip"])
            out.append(["eski" if mode == "old" else "yeni", band, tot[(mode, band)], rej[(mode, band)], n, sum(d["dip"]), "%.1f" % (sum(d["drop12"]) / max(1, n)),
                        "%.1f" % (sum(d["mnminus"]) / max(1, n)), min(d["marg"]) if d["marg"] else "-"])
    J["m2"] = [[str(c) for c in r] for r in out]
    return md(out, ["Model", "imza haftası", "aday", "kapı reddi", "imzalayan", "imza değerinin altına inen", "12. haftada ort. değişim", "en düşük nokta - imza (ort.)", "imzada en küçük (memnuniyet - eşik)"])


# ------------------------------------------------------------------ M6
def m6_tables():
    rows = []
    res = {}
    for mode in ("old", "new"):
        for owner in (0, 5):
            for outc in ("broken", "late", "kept"):
                for dist in (8, 20):
                    # sabit dunya, kesintisiz: (a) sahne 1: kullanilmaz, mesafe icin tol ayari; sat dunyadan
                    run, ww = scen.base_levels()
                    w = M.Frozen(ww, 22, touch_all=True)     # U ~ 60'lar: +6 tavana carpmasin
                    a0 = M.Acct("m6", 10, 2, "logistics", 1000, owner_output=owner, tol_override=-100)
                    r0 = M.simulate(a0, w, mode, T=19, gate=False, renewals=False, budget_cut=False, risk=False)
                    s19 = r0["sat"][19]
                    tol = s19 - dist
                    a = M.Acct("m6", 10, 2, "logistics", 1000, owner_output=owner, tol_override=tol)
                    r = M.simulate(a, w, mode, T=110, gate=False, events={"promise": [(30, outc)]}, renewals=False, budget_cut=False, risk=True)
                    ser = r["sat"]
                    # iz suresi: yeni = defter satirinin sifirlandigi hafta; eski = sat'in yeniden s19'a (-1) dondugu hafta
                    if mode == "new":
                        led = [(t, r["parts"][t]["ledger"]) for t in sorted(r["parts"]) if t >= 30]
                        base_led = led[-1][1]
                        gone = next((t - 30 for t, v in led if abs(v - base_led) < 1e-9 and t > 30), None)
                    else:
                        gone = next((t - 30 for t in sorted(ser) if t >= 30 and ser[t] >= s19 - 1 and t > 30), None)
                    after = ser.get(60)
                    rows.append(["eski" if mode == "old" else "yeni", "temsilci" if owner else "kurucu", {"broken": "tutulmadı", "late": "geç tutuldu", "kept": "tutuldu"}[outc], dist,
                                 s19, ser.get(30), min(ser[t] for t in range(30, min(110, max(ser)) + 1) if t in ser) if True else "", "Risk" if r["risk_entered"] else "-",
                                 "ayrıldı (hf %d)" % r["left"] if r["left"] else "-", gone if gone is not None else "-", ser.get(80, "-")])
                    res[(mode, owner, outc, dist)] = (r["risk_entered"], r["left"], gone)
    J["m6"] = {"%s|%s|%s|%s" % k: v for k, v in res.items()}
    return md(rows, ["Model", "hesap sahibi", "söz", "eşiğe uzaklık", "memnuniyet hf 19", "hf 30", "en düşük nokta", "Risk", "sonuç", "iz kaç haftada silindi", "hf 80"])


# ------------------------------------------------------------------ M8
def m8_tables():
    rows = []
    res = {}
    for freeze in (30, 20):
        for star in (1, 3):
            r, w = scen.m8_case(freeze, 12, star, "new", T=200)
            act = scen.m8_active(12, star, "new", T=200)
            def age_at(wk):
                t = freeze + wk
                return r["parts"][t]["age"] if t in r["parts"] else None
            ages = [age_at(26), age_at(52), age_at(104)]
            sat26 = r["sat"].get(freeze + 26); sat52 = r["sat"].get(freeze + 52)
            left = r["left"]
            ren = {x["t"]: x for x in r["renew"]}
            ren_a = {x["t"]: x for x in act["renew"]}
            s2 = [(t, ren[t]["stance"], ren_a[t]["stance"], ren[t]["sat"], ren_a[t]["sat"]) for t in sorted(ren) if t in ren_a]
            rows.append([freeze, "%d★" % star, "%s / %s / %s" % tuple("-" if x is None else x for x in ages), "%s / %s" % (sat26, sat52), "-" if left is None else "hf %d" % left,
                         "; ".join("hf %d: %s (etkin %s)" % (t, M.STANCE_NAME[a], M.STANCE_NAME[b]) for t, a, b, _, _ in s2) or "-"])
            res["%d|%d" % (freeze, star)] = {"ages": ages, "left": left, "stances": [(t, a, b) for t, a, b, _, _ in s2]}
    J["m8"] = res
    return md(rows, ["donma haftası", "hesap", "yaş terimi (donmadan 26 / 52 / 104 hafta sonra)", "memnuniyet (26 / 52. hafta)", "ayrılma", "yenileme tutumu: donmuş ürün (etkin ürün)"])


# ------------------------------------------------------------------ M7
def m7_tables(pmax=0.30, runs=2000):
    old = scen.m7_mc
    import random as _r
    def mc(tier, load, bugs, runs=runs, T=104, seed=1):
        rng = _r.Random(seed); tot = 0
        for _ in range(runs):
            last = -10 ** 6; n = 0
            for t in range(1, T + 1):
                u = rng.random()
                if t - 7 < 3 or t - last < 4: continue
                p = min(pmax, 0.10 * tier * load * (1 + min(bugs, 12) / 8.0))
                if u < p: n += 1; last = t
            tot += n
        return tot / runs
    rows = []
    res = {}
    for bugs, bn in ((2, "az hata (2)"), (6, "orta (6)"), (12, "tavanda hata (12+)")):
        for load, ln in ((1.0, "%70 (x1,0)"), (1.5, "%95 (x1,5)"), (2.5, "%105 (x2,5)")):
            v = [mc(t, load, bugs) for t in (1.0, 0.5, 0.25)]
            r1 = v[1] / v[0]; r2 = v[2] / v[1]
            res["%d|%s" % (bugs, load)] = v
            rows.append([bn, ln, "%.2f" % v[0], "%.2f" % v[1], "%.2f" % v[2], "%.2f" % r1, "%.2f" % r2, "evet" if (r1 <= 0.75 and r2 <= 0.75) else "hayır"])
    return md(rows, ["açık hata", "yük", "Ekonomik olay/104 hf", "Standart", "Kurumsal", "Std/Eko", "Kur/Std", "her basamak ≥ %25 az"]), res


# ------------------------------------------------------------------ M9
def m9_tables(P, trials=1000, cap_unused=None):
    """330 hesap, 3 yil. Fark (memnuniyet - esik) dagilimi, bot kollarinin yeni-model yenileme kararlarindan ornekleme.
    Tohumlu Monte Carlo; yildiz karisimi botun imza karisimi."""
    import pickle
    pops = {}
    for arm in ("worst", "due", "off", "none"):
        d = []
        for r in P[arm]["new"]["res"].values():
            if r.get("rejected"): continue
            for x in r["renew"]:
                d.append(x["sat"] - x["tol"])
        pops[arm] = d
    stars = [1] * 193 + [2] * 147 + [3] * 8
    rows = []
    res = {}
    for label, pop in (("bakımlı ürün (worst+due+off havuzu)", pops["worst"] + pops["due"] + pops["off"]), ("bakımsız ürün (none)", pops["none"])):
        rng = random.Random(5)
        full = shrink = 0
        for _ in range(trials):
            for y in range(3):
                for i in range(330):
                    p = M.BUDGET_P[rng.choice(stars)]
                    if rng.random() < p:
                        marg = rng.choice(pop)
                        if marg >= M.SHRINK_MARGIN: shrink += 1
                        else: full += 1
        yearly_full = full / trials / 3; yearly_shrink = shrink / trials / 3
        rows.append([label, len(pop), "%.1f" % (sum(pop) / len(pop)), "%.2f" % (yearly_full + yearly_shrink), "%.2f" % yearly_full, "%.2f%%" % (100 * yearly_full / 330),
                     "%.2f" % yearly_shrink, "%.0f%%" % (100 * yearly_shrink / max(1e-9, yearly_full + yearly_shrink))])
        res[label] = (yearly_full, yearly_shrink)
    J["m9"] = {k: v for k, v in res.items()}
    return md(rows, ["hesap havuzu", "örneklem (yenileme kararı)", "ort. (memnuniyet - eşik)", "olay/yıl", "tam kayıp/yıl", "tam kayıp (hesapların %'si)", "küçülme/yıl", "olayın küçülmeyle kalan payı"])


# ------------------------------------------------------------------ M13: kart izi
CARD_AMOUNTS = [6, -5, -20, -3, -30, 10, -5, 3, -5, 3, -4, -5, 4, -2, 10, 4, -12, -10, 3, -2, -2, 4, 6, 10, -8, -5, -5, -8, 6, 6, 4, -6, 5, 8, -5, -6, -6, -8]


def m13_cards():
    """satisfaction_delta kartlarinin izi (nokta-hafta): ayni dunya, kart 20. hafta, taban seriye gore fark toplami (60 hafta)."""
    run, ww = scen.base_levels()
    w = M.Frozen(ww, 22, touch_all=True)
    def ser(mode, ev):
        a = M.Acct("c", 10, 2, "logistics", 1000, tol_override=-100)
        r = M.simulate(a, w, mode, T=90, gate=False, events=ev, renewals=False, budget_cut=False, risk=False)
        return r["sat"]
    out = {}
    for mode in ("old", "new"):
        base = ser(mode, {})
        tn = []; tp = []
        for amt in CARD_AMOUNTS:
            s = ser(mode, {"card": [(30, amt)]})
            tr = sum(base[t] - s[t] for t in range(30, 90) if t in s)
            (tn if amt < 0 else tp).append((amt, tr))
        out[mode] = (tn, tp)
    rows = []
    for mode in ("old", "new"):
        tn, tp = out[mode]
        rows.append(["eski" if mode == "old" else "yeni", len(tn), "%.1f" % (sum(-a for a, _ in tn) / len(tn)), "%.1f" % (sum(t for _, t in tn) / len(tn)),
                     "%.1f" % (sum(t for _, t in tn) / sum(-a for a, _ in tn)), len(tp), "%.1f" % (sum(a for a, _ in tp) / len(tp)),
                     "%.1f" % (-sum(t for _, t in tp) / sum(a for a, _ in tp))])
    J["m13_cards"] = {m: {"neg_ratio": sum(t for _, t in out[m][0]) / sum(-a for a, _ in out[m][0])} for m in out}
    return md(rows, ["Model", "olumsuz delta (adet)", "ort. büyüklük", "ort. iz (puan-hafta)", "iz / büyüklük (hafta)", "olumlu delta (adet)", "ort. büyüklük", "olumlu: iz / büyüklük (hafta, pencere 60)"])


if __name__ == "__main__":
    P = pickle.load(open(os.path.join(OUT, "p1.pkl"), "rb"))
    parts = []
    t1, t2 = r9_tables()
    parts.append("### S4 R9 oyuncu şekilleri, 2★ hesap, imza hf 10, 270 hafta\n\n" + t1 + "\n" + t2)
    parts.append("### M2 İlk 12 hafta (ürün ve hata sabit)\n\n" + m2_tables())
    parts.append("### M6 Söz\n\n" + m6_tables())
    parts.append("### M8 Güncellenmeyen ürün\n\n" + m8_tables())
    t7, r7 = m7_tables(0.30)
    J["m7"] = r7
    parts.append("### M7 Kesinti kademesi (p_max 0,30; 2000 koşu x 104 hafta)\n\n" + t7)
    parts.append("### M9 Bütçe kesintisi\n\n" + m9_tables(P))
    parts.append("### M13 satisfaction_delta kartı izi\n\n" + m13_cards())
    open(os.path.join(OUT, "p2_tables.md"), "w", encoding="utf-8").write("\n\n".join(parts))
    json.dump(J, open(os.path.join(OUT, "p2.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print("\n\n".join(parts))
