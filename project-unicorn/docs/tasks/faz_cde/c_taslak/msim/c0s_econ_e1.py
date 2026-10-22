"""C0s E1 para olcumu (PLAN_C_E1 §4). python -I c0s_econ_e1.py
Taban: c0s_econ.py (K9 bot kayitlari uzerine muhasebe). Eski betikler degismez; burada yalniz import edilir.
Yeni kurallar (Erdem 2026-10-20): evde kira 0 ve uzaktan calisan siniri yok; ofisin tek sarti para; tasinmanin pesin bedeli
iki aylik kira (Is hani 8.000, Plaza 16.000, Loft 36.000) tek sefer, aylik kira varis haftasindan (4.000 / 8.000 / 18.000);
masa 12 / 38 / 70 (kurucu dahil); Frank cek sarti yok; maas x1,5; sunucu 120 / 250 (auto); kurucu maassiz; arac ve servis yok.
Kollar: home (hic tasinmaz), seed (seed haftasinda kasa >= pesin + 6 ay gider ise Is hani; kadro masayi asinca ve para yetince Plaza, sonra Loft).
Cikti: out/c0s_econ_e1.md ve .json"""
import sys, os, json, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_core as C, c0s_data as D, c0s_econ as E

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

T = E.T
Q = E.Q
SAL = E.SAL_MULT                                   # 1,5
RENT = {"home": 0, "ishani": 4000, "plaza": 8000, "loft": 18000}
UPFRONT = {k: 2 * v for k, v in RENT.items()}      # peşin = 2 aylık kira
DESKS = {"home": 10 ** 9, "ishani": 12, "plaza": 38, "loft": 70}
NEXT = {"home": "ishani", "ishani": "plaza", "plaza": "loft", "loft": None}
HOLD_MONTHS = 6.0
PAY_LAG = 2                                        # K9 kaydi: ise alim gunu + 2 tikten itibaren maas (MONTH_BURN salaries, hf 15 -> 17)
KPOL = (("allin", 1.0), ("spend", 2.0), ("bot", 6.0), ("hoard", 6.7))
J = {}
L = []


def w(s=""):
    L.append(s)


def K(x, d=1):
    return "-" if x is None else ("%.*fK" % (d, x / 1000.0))


def arr():
    return [0.0] * (T + 2)


def payroll_est(run, t):
    """Aylik maas toplami (eski bant): K9 ise alimlari, ise alim gunu + PAY_LAG'den beri."""
    return sum(h["salary"] for h in run["hires"] if h["day"] + PAY_LAG <= t)


def srv_series(run, mk, tier="std", pol="auto"):
    cap = E.capacity_series(run, mk, pol)
    return cap, [cap[t] * E.NEW_UNIT[mk] * E.TIER_F[tier] / Q for t in range(T + 2)]


def first_hire_policy(run, mk, ser, cap):
    """Ilk calisan olmasaydi nakit (K9 nakdi + yeni muhasebe farki; gelir K9 gibi, cek ve seed K9 gunlerinde) ve k kurallarina gore ilk ise alim.
    Kural: kasa >= k x (maas x1,5 + sunucu); kira yok; arama 1 hafta. Don: {ad: {hire, cash, cost, runway}}."""
    h = run["hires"][0]
    s1 = h["salary"]
    srv = [cap[t] * E.NEW_UNIT[mk] / Q for t in range(T + 2)]
    cash_old = [E.state(run, t, "cash", 0) for t in range(T + 2)]
    cum_old = arr(); cum_pre = arr(); cash_pre = arr()
    for t in range(1, T + 1):
        exp_old = ser["sal"][t] + ser["ot"][t] + ser["tools"][t] + ser["mkt"][t] + ser["one"][t] + ser["srv"][t] + ser["svc"][t]
        cum_old[t] = cum_old[t - 1] + ser["inc"][t] - exp_old
        cum_pre[t] = cum_pre[t - 1] + ser["inc"][t] - srv[t] - ser["mkt"][t]
        cash_pre[t] = cash_old[t] + cum_pre[t] - cum_old[t]
    out = {}
    for name, k in KPOL:
        res = None
        for d in range(1, T):
            cost = SAL * s1 + cap[d] * E.NEW_UNIT[mk]
            if cash_pre[d] >= k * cost:
                hd = d + 1
                c2 = SAL * s1 + cap[hd] * E.NEW_UNIT[mk]
                res = {"hire": hd, "cash": cash_pre[hd], "cost": c2, "runway": cash_pre[hd] / c2}
                break
        out[name] = res
    return out, cash_pre


def simulate(run, mk, arm, hd=None, gider_def="kirasiz", retry=False, d_inc=None, tier="std", pol="auto", sal_mult=SAL):
    """Haftalik yeni gider / net / nakit. hd: ilk ise alim haftasi (None: K9 kaydi). arm: home | seed."""
    ser = E.weekly(run, mk)
    cap, srv = srv_series(run, mk, tier, pol)
    hires = run["hires"]
    h1 = hires[0]["day"] if hires else None
    s1 = hires[0]["salary"] if hires else 0
    cash_old = [E.state(run, t, "cash", 0) for t in range(T + 2)]
    cum_old = arr()
    for t in range(1, T + 1):
        eo = ser["sal"][t] + ser["ot"][t] + ser["tools"][t] + ser["mkt"][t] + ser["one"][t] + ser["srv"][t] + ser["svc"][t]
        cum_old[t] = cum_old[t - 1] + ser["inc"][t] - eo
    # tek seferlik: ise alim primi farki, ilk ise alimin kaydirilmasi
    extra = arr(); sal_adj = arr()
    for h in hires:
        if h["day"] <= T:
            extra[h["day"]] += 0.5 * (sal_mult - 1.0) * h["salary"]
    if hd is not None and h1 is not None and hd != h1:
        if h1 <= T:
            extra[h1] -= 0.5 * s1 + 0.5 * (sal_mult - 1.0) * s1
        extra[hd] += 0.5 * s1 * sal_mult
        lo, hi = (hd + PAY_LAG, h1 + PAY_LAG) if hd < h1 else (h1 + PAY_LAG, hd + PAY_LAG)
        sgn = 1.0 if hd < h1 else -1.0
        for t in range(max(1, lo), min(T + 1, hi)):
            sal_adj[t] += sgn * sal_mult * s1 / Q
    inc = arr(); exp = arr(); rec = arr(); one = arr(); cum = arr(); cash = arr(); rent = arr(); upf = arr(); office = ["home"] * (T + 2)
    cur = "home"; pending = None; moves = []; seed_day = run["seed"]["day"] if run.get("seed") else None
    tried = set()
    for t in range(1, T + 1):
        if pending and pending[0] == t:
            cur = pending[1]; pending = None
        office[t] = cur
        rent[t] = RENT[cur] / Q
        inc[t] = ser["inc"][t] + (d_inc[t] if d_inc else 0.0)
        recur = (ser["sal"][t] + ser["ot"][t]) * sal_mult + sal_adj[t] + ser["mkt"][t] + srv[t] + rent[t]
        one[t] = ser["one"][t] + extra[t]
        pre = recur + one[t]
        cash_pre_dec = cash_old[t] + (cum[t - 1] + inc[t] - pre) - cum_old[t]
        emp = E.state(run, t, "emp", 0)
        target = None
        if arm == "seed" and pending is None:
            if cur == "home" and ((t == seed_day) or (retry and seed_day is not None and t > seed_day)):
                target = "ishani"
            elif cur != "home" and emp + 1 > DESKS[cur]:
                target = NEXT[cur]
        if target:
            gider = (payroll_est(run, t) * sal_mult + ser["mkt"][t] * Q + srv[t] * Q + RENT[cur]) + (RENT[target] - RENT[cur] if gider_def == "kirali" else 0)
            need = UPFRONT[target] + HOLD_MONTHS * gider
            rule_ok = cash_pre_dec >= need
            mv = {"week": t, "from": cur, "to": target, "cash": cash_pre_dec, "gider": gider, "need": need, "ok": rule_ok, "heads": emp + 1,
                  "runway_before": cash_pre_dec / gider if gider else None, "gider_after": gider - RENT[cur] + RENT[target]}
            if rule_ok:
                upf[t] = UPFRONT[target]
                pending = (t + 1, target)
                mv["runway_after"] = (cash_pre_dec - upf[t]) / mv["gider_after"]
                mv["arrive"] = t + 1
            if rule_ok or target not in tried:
                moves.append(mv)
            tried.add(target)
        exp[t] = pre + upf[t]
        rec[t] = recur
        cum[t] = cum[t - 1] + inc[t] - exp[t]
        cash[t] = cash_old[t] + cum[t] - cum_old[t]
    return {"inc": inc, "exp_new": exp, "exp_old": [ser["sal"][t] + ser["ot"][t] + ser["tools"][t] + ser["mkt"][t] + ser["one"][t] + ser["srv"][t] + ser["svc"][t] for t in range(T + 2)],
            "cum_new": cum, "cash_new": cash, "cash_old": cash_old, "cum_old": cum_old, "rec": rec, "one": one, "upfront": upf, "rent": rent, "office": office,
            "servers": srv, "cap": cap, "moves": moves, "ser": ser, "h1": h1}


def net3(run, inc, exp_series, exclude=None):
    p3 = [t for t in range(1, T + 1) if E.state(run, t, "phase", 1) == 3]
    if not p3:
        return None
    s = 0.0
    for t in p3:
        x = exp_series[t] - (exclude[t] if exclude else 0.0)
        s += inc[t] - x
    return s / len(p3) * Q


def metrics(run, mk, e):
    """E.agg ile ayni tanimlar (ayni islev cagrilir)."""
    a = E.agg(run, mk, e, "new")
    a["net3_rec"] = net3(run, e["inc"], e["exp_new"], [e["one"][t] + e["upfront"][t] for t in range(T + 2)])
    p2 = [t for t in range(1, T + 1) if E.state(run, t, "phase", 1) == 2]
    best = None
    for i in range(0, len(p2) - 3, 4):
        blk = p2[i:i + 4]
        gap = sum(e["exp_new"][t] - e["inc"][t] for t in blk) / 4 * Q
        if gap > 0:
            rw = e["cash_new"][blk[-1]] / gap
            if best is None or rw < best[0]:
                best = (rw, blk[0], blk[-1], e["cash_new"][blk[-1]], gap)
    a["mr2_blk"] = best
    return a


def first_move(e, to):
    for m in e["moves"]:
        if m["ok"] and m["to"] == to:
            return m
    return None


def a_day(run):
    return E.a_day(run, 120000)


def pick(ms, to, ok):
    return next((m for m in ms if m["to"] == to and (m["ok"] or not ok)), None)


def move_text(mf, mo):
    """Plaza / Loft: kadro masayi asti mi, para ne zaman yetti."""
    if mf is None:
        return "kadro masayı aşmadı"
    if mo:
        return "kadro hf %d aştı; para hf %d'de yetti (kasa %s, gerekli %s), varış hf %d, runway %.1f → %.1f ay" % (mf["week"], mo["week"], K(mo["cash"]), K(mo["need"]), mo["arrive"], mo["runway_before"], mo["runway_after"])
    return "kadro hf %d aştı (kasa %s, gerekli %s); 104. hf'ye kadar para yetmedi" % (mf["week"], K(mf["cash"]), K(mf["need"]))


# ------------------------------------------------------------------ ana
def main():
    B2B = {s: D.run_name("worst", s) for s in D.SEEDS}
    B2C = {s: D.run_name("worst", s, True) for s in D.SEEDS}
    ALL_B2B = [D.run_name(a, s) for a in D.ARMS for s in D.SEEDS]
    ALL_B2C = [D.run_name(a, s, True) for a in ("worst", "none") for s in D.SEEDS]
    R = {}      # (isim, kol, k_politikasi, gider_def, retry) -> sim
    FH = {}     # isim -> first_hire_policy

    def sim(n, arm, pol="rec", gd="kirasiz", retry=False, dinc=None):
        key = (n, arm, pol, gd, retry, dinc is not None)
        if key in R:
            return R[key]
        run = C.get_run(n)
        mk = "b2c" if "b2c" in n else "b2b"
        hd = None
        if pol != "rec":
            fh = fhp(n)[0]
            hd = fh[pol]["hire"]
        e = simulate(run, mk, arm, hd=hd, gider_def=gd, retry=retry, d_inc=dinc)
        R[key] = e
        return e

    def fhp(n):
        if n not in FH:
            run = C.get_run(n)
            mk = "b2c" if "b2c" in n else "b2b"
            ser = E.weekly(run, mk)
            cap, _ = srv_series(run, mk)
            FH[n] = first_hire_policy(run, mk, ser, cap)
        return FH[n]

    # ---------- referanslar (bugun)
    REF = {}
    for s in D.SEEDS:
        n = B2B[s]
        run = C.get_run(n)
        q = D.load(n, D.Q0B)
        e0 = E.econ(run, "b2b", "recorded", sal_mult=1.0)
        eq = E.econ(q, "b2b", "recorded", sal_mult=1.0)
        r = {"q0b_net3": net3(q, eq["inc"], eq["exp_old"]), "k9_net3": net3(run, e0["inc"], e0["exp_old"]),
             "k9_net3_rec": net3(run, e0["inc"], e0["exp_old"], e0["ser"]["one"])}
        e0["exp_new"] = e0["exp_old"]; e0["cum_new"] = e0["cum_old"]; e0["cash_new"] = e0["cash_old"]
        a = E.agg(run, "b2b", e0, "new")
        r.update({"deep40": a["deep40"], "deep40_week": a["deep40_week"], "c52": a["c52"], "mr2": a["mr2"], "p3weeks": a["p3_weeks"]})
        REF[n] = r
    REFC = {}
    for s in D.SEEDS:
        n = B2C[s]
        run = C.get_run(n)
        e0 = E.econ(run, "b2c", "recorded", sal_mult=1.0)
        e0["exp_new"] = e0["exp_old"]; e0["cum_new"] = e0["cum_old"]; e0["cash_new"] = e0["cash_old"]
        REFC[n] = E.agg(run, "b2c", e0, "new")

    # ================================================================ 1. ilk isle alim
    w("## 1. İlk işe alım: kasa, kural, runway")
    w("")
    w("Ev kirasız. Kural: kasa >= k x (maaş x1,5 + sunucu), kira yok; arama 1 hafta. Nakit = K9 nakdi + yeni muhasebe farkı; gelir, Frank'in çeki ve seed K9'daki günlerinde (ekibin getirisi sayılmaz: iyimser). "
      "Hücre: işe alım haftası / o haftanın runway'i (ay, gelir hariç). `K9 kaydı` = botun kendi işe alımı (hf 15 / 21), aynı kasa ve giderle.")
    w("")
    w("| Koşu | ilk işe alım maaşı (eski bant) | K9 kaydı | allin (k=1) | cash_spend (k=2) | bot (k=6) | cash_hoard (k=6,7) |")
    w("|---|---|---|---|---|---|---|")
    fh_json = {}
    for n in ALL_B2B[:0] + [B2B[7], B2B[11], B2C[7], B2C[11]] + [x for x in ALL_B2B if "worst" not in x] + [x for x in ALL_B2C if "none" in x]:
        run = C.get_run(n)
        mk = "b2c" if "b2c" in n else "b2b"
        fh, cash_pre = fhp(n)
        h1 = run["hires"][0]["day"]; s1 = run["hires"][0]["salary"]
        ser = E.weekly(run, mk)
        cap, _ = srv_series(run, mk)
        cost = SAL * s1 + cap[h1] * E.NEW_UNIT[mk]
        rec = "hf %d / %.1f" % (h1, cash_pre[h1] / cost)
        cells = [("hf %d / %.1f" % (fh[p]["hire"], fh[p]["runway"])) if fh[p] else "yok" for p, _ in KPOL]
        w("| %s | %d | %s | %s |" % (n.replace("full_run_", ""), s1, rec, " | ".join(cells)))
        fh_json[n] = {"k9": {"hire": h1, "runway": cash_pre[h1] / cost, "cash": cash_pre[h1], "cost": cost}, **{p: fh[p] for p, _ in KPOL}}
    J["first_hire"] = fh_json
    w("")
    w("Kayıtların seed haftası: " + ", ".join("%s hf %d" % (B2B[s].replace("full_run_", ""), C.get_run(B2B[s])["seed"]["day"]) for s in D.SEEDS) + "; B2C " +
      ", ".join("%s hf %d" % (B2C[s].replace("full_run_", ""), C.get_run(B2C[s])["seed"]["day"]) for s in D.SEEDS) +
      ". İlk işe alım her k için seed'den önce olduğu için `home` ve `seed` kolunda aynıdır (kol yalnız seed haftasından sonra ayrılır).")

    # ================================================================ 2. ana kapi tablosu (K9 ise alimi aynen)
    w("")
    w("## 2. Ana ölçüm: B2B `fix_worst`, K9 işe alımları aynen")
    w("")
    w("Bot kararları K9 kaydındaki gibi (ilk çalışan hf 15), gelir K9'un geliri (etkisiz). Sunucu `auto`, Standart. Net = gelir - gider, dış fonlama (Frank'in çeki, seed) hariç; "
      "peşin kira gider sayılır. Hücre: tohum 7 / tohum 11.")
    w("")
    ME = {}
    for n in B2B.values():
        run = C.get_run(n)
        for arm in ("home", "seed"):
            e = sim(n, arm)
            ME[(n, arm)] = (e, metrics(run, "b2b", e))
    seeds = D.SEEDS

    def cell(arm, f):
        return " / ".join(f(ME[(B2B[s], arm)], B2B[s]) for s in seeds)

    w("| Ölçü | tohum | home | seed |")
    w("|---|---|---|---|")
    rows = [
        ("en derin kümülatif açık, ilk 40 hf (haftası)", lambda m, n: "%s (hf %d)" % (K(-m[1]["deep40"]), m[1]["deep40_week"])),
        ("en derin kümülatif açık, tüm koşu (haftası)", lambda m, n: "%s (hf %d)" % (K(-m[1]["deep"]), m[1]["deep_week"])),
        ("52. hf kümülatif net", lambda m, n: K(m[1]["c52"])),
        ("evre 3 aylık net", lambda m, n: K(m[1]["net3"])),
        ("evre 3 aylık net, tekrarlayan", lambda m, n: K(m[1]["net3_rec"])),
        ("evre 2 en düşük runway (ay; blok hafta aralığı)", lambda m, n: ("%.1f (hf %d-%d)" % (m[1]["mr2"], m[1]["mr2_blk"][1], m[1]["mr2_blk"][2])) if m[1]["mr2"] is not None else "açık yok"),
        ("en düşük nakit", lambda m, n: K(m[1]["mincash"])),
        ("101. hf kümülatif", lambda m, n: K(m[1]["c101"])),
    ]
    for lab, f in rows:
        w("| %s | 7 / 11 | %s | %s |" % (lab, cell("home", f), cell("seed", f)))
    w("")
    w("Bugünkü kod referansı (K9 kaydı, 910ad1f): " + "; ".join("tohum %d: derin %s (hf %d), 52. hf %s, evre 3 net %s, tekrarlayan %s, evre 2 runway %s" % (
        s, K(-REF[B2B[s]]["deep40"]), REF[B2B[s]]["deep40_week"], K(REF[B2B[s]]["c52"]), K(REF[B2B[s]]["k9_net3"]), K(REF[B2B[s]]["k9_net3_rec"]),
        ("%.1f" % REF[B2B[s]]["mr2"]) if REF[B2B[s]]["mr2"] else "-") for s in seeds) + ". Q0b evre 3 net: " + ", ".join("%d: %s" % (s, K(REF[B2B[s]]["q0b_net3"])) for s in seeds) + ".")
    J["main"] = {"%s|%s" % (n, arm): {k: v for k, v in m.items()} for (n, arm), (e, m) in ME.items()}
    J["ref"] = REF

    # ---------- taşınma
    w("")
    w("### `seed` kolu: taşınma kararı")
    w("")
    w("Kural: seed haftasında kasa >= peşin + 6 x aylık gider. Gider = o haftanın maaşı (x1,5, K9 ise alımlarından) + sunucu + pazarlama + geçerli kira (kirasız tanım); `kiralı` tanım varış ofisinin kirasını giderin yerine koyar. "
      "Plaza / Loft: kadro (çalışan + kurucu) masayı aşınca, aynı kuralla.")
    w("")
    w("| Koşu | tanım | seed haftası | kasa o hafta | gerekli (peşin + 6 ay) | taşındı mı | varış | runway (karardan önce / peşinden sonra, yeni gider) | Plaza | Loft |")
    w("|---|---|---|---|---|---|---|---|---|---|")
    MV = {}
    for n in list(B2B.values()) + list(B2C.values()):
        run = C.get_run(n)
        for gd in ("kirasiz", "kirali"):
            for retry in (False, True):
                e = sim(n, "seed", gd=gd, retry=retry)
                ms = e["moves"]
                first = ms[0] if ms else None
                mv = {"first": first, "ishani": pick(ms, "ishani", True), "plaza_first": pick(ms, "plaza", False), "plaza_ok": pick(ms, "plaza", True),
                      "loft_first": pick(ms, "loft", False), "loft_ok": pick(ms, "loft", True)}
                MV[(n, gd, retry)] = mv
                lab = gd + (" + her hafta yeniden dene" if retry else "")
                mi = mv["ishani"]
                if mi:
                    w("| %s | %s | %d | %s | %s | evet (hf %d karar) | hf %d | %.1f / %.1f ay | %s | %s |" % (
                        n.replace("full_run_", ""), lab, run["seed"]["day"], K(mi["cash"]), K(mi["need"]), mi["week"], mi["arrive"], mi["runway_before"], mi["runway_after"],
                        move_text(mv["plaza_first"], mv["plaza_ok"]), move_text(mv["loft_first"], mv["loft_ok"])))
                else:
                    w("| %s | %s | %d | %s | %s | hayır | - | %.1f ay (karar anı, gider %s) | - | - |" % (n.replace("full_run_", ""), lab, run["seed"]["day"], K(first["cash"]), K(first["need"]),
                                                                                         first["runway_before"], K(first["gider"])))
    J["moves"] = {"%s|%s|%s" % k: v for k, v in MV.items()}

    # ================================================================ 3. cash_spend / cash_hoard
    w("")
    w("## 3. cash_spend ve cash_hoard")
    w("")
    w("İlk işe alım haftası (bölüm 1) ve Series A Avı (MRR >= $120.000, K9 kaydında hf %s). Kaydırma tahmini: ilk işe alımın gecikmesi kadar (f = 1) ya da yarısı kadar (f = 0,5) sonraki akış kayar; bu bir varsayım, bot koşusu değil." % (
        " / ".join(str(a_day(C.get_run(B2B[s]))) for s in seeds)))
    w("")
    w("| Koşu | spend: ilk işe alım (hf) | hoard: ilk işe alım (hf) | fark (hf) | Series A Avı K9 | Series A farkı f=1 | Series A farkı f=0,5 |")
    w("|---|---|---|---|---|---|---|")
    GAP = {}
    for n in list(B2B.values()) + list(B2C.values()) + [x for x in ALL_B2B if "worst" not in x]:
        fh = fhp(n)[0]
        sp, ho = fh["spend"]["hire"], fh["hoard"]["hire"]
        run = C.get_run(n)
        ad = a_day(run)
        diff = ho - sp
        GAP[n] = {"spend": sp, "hoard": ho, "diff": diff, "sa_k9": ad, "sa_f1": diff, "sa_f05": diff * 0.5}
        w("| %s | %d | %d | %d | %s | %d | %.1f |" % (n.replace("full_run_", ""), sp, ho, diff, ad if ad else "yok", diff, diff * 0.5))
    J["gap"] = GAP
    w("")
    w("Her iki kolun ana ölçümü (ilk çalışan `spend`te hf, `hoard`ta hf'ye çekilir; sonraki işe alımlar K9 kaydındaki gibi; erken ilk çalışanın maaşı eklenir, gelir değişmez). Hücre: tohum 7 / tohum 11.")
    w("")
    w("| Politika | kol | derin açık, ilk 40 hf (haftası) | 52. hf net | evre 2 en düşük runway | en düşük nakit |")
    w("|---|---|---|---|---|---|")
    PM = {}
    for pol in ("spend", "hoard"):
        for arm in ("home", "seed"):
            cells = {"d": [], "c": [], "r": [], "m": []}
            for s in seeds:
                n = B2B[s]
                run = C.get_run(n)
                e = sim(n, arm, pol=pol)
                m = metrics(run, "b2b", e)
                PM[(pol, arm, s)] = m
                cells["d"].append("%s (hf %d)" % (K(-m["deep40"]), m["deep40_week"])); cells["c"].append(K(m["c52"]))
                cells["r"].append(("%.1f" % m["mr2"]) if m["mr2"] is not None else "açık yok"); cells["m"].append(K(m["mincash"]))
            w("| %s | %s | %s | %s | %s | %s |" % (pol, arm, " / ".join(cells["d"]), " / ".join(cells["c"]), " / ".join(cells["r"]), " / ".join(cells["m"])))
    J["policy_main"] = {"%s|%s|%d" % k: v for k, v in PM.items()}

    # ================================================================ 4. etkili gelir (bilgi)
    w("")
    w("## 4. Etkili gelir (bilgi): C kapısı ve yenileme sonuçlarıyla")
    w("")
    w("C0s'in `income_delta`'sı (C modeli kapısı, yenileme, kayıplar) K9 gelirine eklenir; aynı yeni gider ve ofis kuralı. Bu ölçüm PLAN_C_E1 §4'ün girdisi değildir, yalnız duyarlılıktır "
      "(C0S_SONUC §3.4: tohum 7 için 91K, tohum 11 için 107K açık).")
    w("")
    w("| Kol | derin açık, ilk 40 hf (haftası) | 52. hf net | evre 3 aylık net | evre 2 en düşük runway |")
    w("|---|---|---|---|---|")
    import c0s_model as M
    cfg = M.cfg()
    EF = {}
    for arm in ("home", "seed"):
        cells = {"d": [], "c": [], "n3": [], "r": []}
        for s in seeds:
            n = B2B[s]
            run = C.get_run(n)
            dinc = E.income_delta(n, cfg)
            e = sim(n, arm, dinc=dinc)
            m = metrics(run, "b2b", e)
            EF[(arm, s)] = m
            cells["d"].append("%s (hf %d)" % (K(-m["deep40"]), m["deep40_week"])); cells["c"].append(K(m["c52"])); cells["n3"].append(K(m["net3"]))
            cells["r"].append(("%.1f" % m["mr2"]) if m["mr2"] is not None else "açık yok")
        w("| %s | %s | %s | %s | %s |" % (arm, " / ".join(cells["d"]), " / ".join(cells["c"]), " / ".join(cells["n3"]), " / ".join(cells["r"])))
    J["etkili"] = {"%s|%d" % k: v for k, v in EF.items()}

    # ================================================================ 5. B2C
    w("")
    w("## 5. B2C `fix_worst`")
    w("")
    w("Hedef: en derin açık bugünkünün en çok x1,5 ve 101. hf kümülatif net bugünün en az %80'i; mutlak sayı da yazılır. Hücre: tohum 7 / tohum 11.")
    w("")
    w("| Kol | en derin açık (haftası) | bugün (K9 kaydı) | oran | 101. hf net | bugün | oran | en düşük nakit |")
    w("|---|---|---|---|---|---|---|---|")
    CM = {}
    for arm in ("home", "seed"):
        c = {"d": [], "d0": [], "dr": [], "n": [], "n0": [], "nr": [], "m": []}
        for s in seeds:
            n = B2C[s]
            run = C.get_run(n)
            e = sim(n, arm)
            m = E.agg(run, "b2c", e, "new")
            CM[(arm, s)] = m
            r0 = REFC[n]
            c["d"].append("%s (hf %d)" % (K(-m["deep"]), m["deep_week"])); c["d0"].append(K(-r0["deep"])); c["dr"].append("x%.2f" % (m["deep"] / r0["deep"]))
            c["n"].append(K(m["c101"], 0)); c["n0"].append(K(r0["c101"], 0)); c["nr"].append("%.0f%%" % (100.0 * m["c101"] / r0["c101"])); c["m"].append(K(m["mincash"]))
        w("| %s | %s | %s | %s | %s | %s | %s | %s |" % (arm, " / ".join(c["d"]), " / ".join(c["d0"]), " / ".join(c["dr"]), " / ".join(c["n"]), " / ".join(c["n0"]), " / ".join(c["nr"]), " / ".join(c["m"])))
    J["b2c"] = {"%s|%d" % k: v for k, v in CM.items()}
    J["b2c_ref"] = REFC

    # ================================================================ 6. M12
    w("")
    w("## 6. M12 sunucu payı (rapor, kapı değil)")
    w("")
    w("Standart fiyat B2B $120 / 50 koltuk, B2C $250 / 1.000 kullanıcı (Karar 2). Pay = 26-104. hf sunucu faturası ÷ gelir. Politikalar: `lean` pay %5, `auto` anahtar açık, `wide` pay %40; Ekonomik ve Kurumsal `auto` ile.")
    w("")
    w("| Koşu | lean | auto (Standart) | wide | auto Ekonomik | auto Kurumsal |")
    w("|---|---|---|---|---|---|")
    M12 = {}
    for n in list(B2B.values()) + list(B2C.values()) + [D.run_name("none", s, True) for s in seeds]:
        run = C.get_run(n)
        mk = "b2c" if "b2c" in n else "b2b"
        ser = E.weekly(run, mk)
        inc = sum(ser["inc"][t] for t in range(26, T + 1))
        row = []
        for pol, tier in (("lean", "std"), ("auto", "std"), ("wide", "std"), ("auto", "eko"), ("auto", "kur")):
            _, sv = srv_series(run, mk, tier, pol)
            row.append(100.0 * sum(sv[t] for t in range(26, T + 1)) / inc)
        M12[n] = row
        w("| %s | %s |" % (n.replace("full_run_", ""), " | ".join("%.1f%%" % x for x in row)))
    J["m12"] = M12

    # ================================================================ 7. kapi tablosu (ozet)
    global G_M12, P3
    G_M12 = M12
    P3 = {}
    for s_ in seeds:
        n_ = B2B[s_]
        run_ = C.get_run(n_)
        ser_ = E.weekly(run_, "b2b")
        e_ = ME[(n_, "home")][0]
        p3_ = [t for t in range(1, T + 1) if E.state(run_, t, "phase", 1) == 3]
        av = lambda a_: sum(a_[t] for t in p3_) / len(p3_) * Q
        P3[n_] = {"tools": av(ser_["tools"]), "svc": av(ser_["svc"]), "added": av(e_["servers"]) - av(ser_["srv"]) + av(ser_["sal"]) * (SAL - 1.0)}
    J["p3_components"] = P3
    gate_rows = build_gates(B2B, B2C, ME, REF, REFC, CM, GAP, fh_json, MV, PM, M12)
    summary = build_summary(gate_rows, B2B, B2C, ME, REF, GAP, fh_json, MV, CM, REFC, PM, run_of=C.get_run)
    # sonuc dosyasi: ozet + kapi tablosu + gerisi
    head = []
    head.append("# C2 ön ölçümü: para (PLAN_C_E1 §4) · 2026-10-20")
    head.append("")
    head.append("## Özet (6 satır)")
    head.extend(summary)
    head.append("")
    head.append("## Kapı tablosu")
    head.append("")
    head.append("Her satır: hedef | home | seed | durum | kanıt (bölümler bu dosyada, ham sayılar `out/c0s_econ_e1.json`). Hücre: tohum 7 / tohum 11. Durum yalnız her iki tohum ve ilgili kolda tutarsa `geçti`. Sabit değiştirilmedi.")
    head.append("")
    head.append("| # | Ölçü | Hedef | home | seed | Durum | Kanıt |")
    head.append("|---|---|---|---|---|---|---|")
    for g in gate_rows:
        head.append("| %s | %s | %s | %s | %s | %s | %s |" % (g["id"], g["name"], g["target"], g["home"], g["seed"], g["status"], g["evidence"]))
    head.append("")
    head.append("### Tutmayan kapılar: tek cümle neden")
    head.append("")
    for g in gate_rows:
        if g["status"].startswith("kaldı") and g.get("why"):
            head.append("- **%s %s:** %s" % (g["id"], g["name"], g["why"]))
    head.append("")
    J["gates"] = gate_rows
    tail = ["", "## Varsayımlar ve C0s'ten farklar", ""]
    tail.extend(ASSUMPTIONS)
    out = "\n".join(head + [""] + L + tail) + "\n"
    open(os.path.join(C.OUT, "c0s_econ_e1.md"), "w", encoding="utf-8").write(out)
    json.dump(J, open(os.path.join(C.OUT, "c0s_econ_e1.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print(out)


ASSUMPTIONS = [
    "1. **Yöntem C0s'inki:** K9 (910ad1f) bot kayıtlarının aylık gider dökümü (`PROBE MONTH_BURN`) ve `STATE` üzerine muhasebe; bot kararları kayıttaki gibi (tahmin, oyun koşusu değil). Gelir K9'un geliri; C kapısı ve yenileme ana ölçümde yok (bölüm 4 yalnız duyarlılık).",
    "2. **Kurucu maaşsız, araç ve servis yok:** `MONTH_BURN`'ün `salaries` alanı yalnız çalışan maaşıdır (kurucu satırı `tools` tabanındaydı); `tools` ve `service` düşer. Maaş, ek mesai ve işe alım primi x1,5 (prim farkı işe alım gününde, prim = maaşın yarısı).",
    "3. **Sunucu:** Standart (bulut) $120 / 50 koltuk, B2C $250 / 1.000 kullanıcı, `auto` politikası (yük %80'e varınca yük %65'e inecek kadar büyür, küçültmez); hizmet edilen koltuk = MRR ÷ $50 (koltuk fiyat bandının ortası); sunucu MVP haftasından başlar. Aylık = 30/7 hafta.",
    "4. **Ev:** kira 0, uzaktan çalışan sınırı yok (K9 işe alımları aynen). **Ofis kirası** İş hanı $4.000, Plaza $8.000, Loft $18.000; peşin = 2 x kira, karar haftasında bir kez gider yazılır ve nakit düşer; kira varış haftasından (karar + 1) başlar. Masa 12 / 38 / 70, kadro = çalışan + kurucu. Peşin kümülatif nete girer (gerçek nakit çıkışı).",
    "5. **`seed` kolu:** seed haftasında (`PROBE PLAY seed signed` günü) kasa >= peşin + 6 x aylık gider ise İş hanı'na karar; tutmazsa taşınmaz (kural seed haftasında bir kez bakar). Ek duyarlılık: her hafta yeniden dene. Gider tanımı iki türlü (kirasız: geçerli ofisin kirası dahil, varış kirası hariç; kiralı: varış kirası dahil). Plaza / Loft: kadro masayı aşınca aynı kuralla. Aylık maaş toplamı K9 işe alımlarının maaşlarından (ise alım günü + 2'den beri; `payroll_monthly` 87. haftada tutuyor: 28.500), terfi ve ayrılmalar hesapta yok.",
    "6. **Nakit** = K9 nakdi + (yeni kümülatif net - eski kümülatif net); Frank'in çeki ve seed K9'daki günlerinde kalır. Çek şartı yok ama çekin kendisi (MRR eşiği, tek karar) kalır.",
    "7. **İlk işe alım kuralı** (`first_hire_policy`): ilk çalışan olmasaydı nakit = K9 nakdi + (yalnız sunucu ve pazarlama giderli kümülatif - eski kümülatif); gelir K9 gibi; tek seferlik gider (hf 10'daki $300 gibi, ise alım primi dışında) hesapta yok (C0s'in `nohire_cash`'iyle aynı, iyimser). Tetik: kasa >= k x (ilk çalışanın maaşı x1,5 + sunucu); işe alım tetikten 1 hafta sonra. İlk çalışan K9'un ilk çalışanı (geliştirici, eski bant 2.450).",
    "8. **İlk çalışanı kaydırma (spend / hoard ana ölçümü):** ilk çalışanın maaşı K9'daki başlangıcı (işe alım + 2) ile yeni başlangıç arasındaki haftalara eklenir ya da çıkar; sonraki işe alımlar kayıttaki günlerinde, gelir değişmez. Series A Avı kayması f = 1 ve 0,5 ile iki uç tahmin; ölçülmüş değil.",
    "9. **Evre 3** K9 `fix_worst`'te yalnız 17 ve 9 hafta ve tek seferlik giderler (48.000, 30.000) içeriyor; \"bugün\" üç referansla (Q0b, K9, K9 tekrarlayan net) yazılır. Yeni tekrarlayan net, tek seferlik gider, peşin kira ve işe alım primi hariç.",
    "10. **Evre 2 en düşük runway:** C0s'in `agg` işlevi (4 haftalık bloklar, gider - gelir > 0 olan bloklarda kasa ÷ aylık net açık, en küçüğü). Net açık yoksa `açık yok`.",
    "11. **C0s'ten farklar:** (a) V1 / V2 (Frank şartı) ayrımı kalktı; (b) ev kirasız, İş hanı ilk çalışanla gelmez, seed haftasında ve parayla gelir; (c) Plaza şartı yalnız kadro + para (10 kişi / marka / $45.000 yok); (d) peşin kira eklendi; (e) masa 12 / 38 / 70; (f) `bot` ve `allin` kolları korundu, kapı kararı `spend` ve `hoard` ile; (g) İş hanı runway'i kira içermez (ev); (h) 40 haftalık açık ve 52. hf net peşin kirayı içerir.",
    "12. **Ölçülmeyenler:** masa tavanı yok, uzaktan debuff yok (C9b'ye açık iş); kredi yok; kasa eksiye düşünce kepenk/iflas hesaba girmedi (en düşük nakit yazılır); erken işe alımın ürün hızına etkisi yok.",
]


def lower_is_better(x):
    return x


def build_gates(B2B, B2C, ME, REF, REFC, CM, GAP, FH, MV, PM, M12):
    seeds = D.SEEDS
    G = []

    def ms(arm, f):
        return [f(ME[(B2B[s], arm)][1]) for s in seeds]

    def both(vals, test):
        return all(test(v) for v in vals)

    # 1 ilk islem runway
    rw = [FH[B2B[s]]["k9"]["runway"] for s in seeds]
    hw = [FH[B2B[s]]["k9"]["hire"] for s in seeds]
    rwh = [FH[B2B[s]]["hoard"]["runway"] for s in seeds]
    hwh = [FH[B2B[s]]["hoard"]["hire"] for s in seeds]
    rws = [FH[B2B[s]]["spend"]["runway"] for s in seeds]
    hws = [FH[B2B[s]]["spend"]["hire"] for s in seeds]
    c1 = " / ".join("hf %d: %.1f ay" % (h, r) for h, r in zip(hw, rw))
    ok1 = all(r >= 6.7 for r in rw)
    G.append({"id": "1a", "name": "ilk işe alım haftasında runway (K9 botunun işe alımı)", "target": ">= 6,7 ay", "home": c1, "seed": c1 + " (seed'den önce, aynı)",
              "status": "geçti" if ok1 else "kaldı", "evidence": "bölüm 1, `first_hire.k9`",
              "why": "" if ok1 else "K9 botu ilk çalışanı kasa 6,7 aylık giderin altındayken alıyor (%s)." % c1})
    c1b = " / ".join("hf %d: %.1f ay" % (h, r) for h, r in zip(hwh, rwh))
    ok1b = all(r >= 6.7 for r in rwh)
    c1c = " / ".join("hf %d: %.1f ay" % (h, r) for h, r in zip(hws, rws))
    G.append({"id": "1b", "name": "ilk işe alım runway, cash_hoard (k=6,7)", "target": ">= 6,7 ay", "home": c1b, "seed": c1b + " (aynı)", "status": "geçti" if ok1b else "kaldı", "evidence": "bölüm 1 (kural gereği: k=6,7 eşiği runway kapısının kendisi)",
              "why": "" if ok1b else "kasa ancak %s'de eşiğe varıyor." % c1b})
    G.append({"id": "1c", "name": "ilk işe alım runway, cash_spend (k=2)", "target": ">= 6,7 ay", "home": c1c, "seed": c1c + " (aynı)", "status": "kaldı (kural gereği)", "evidence": "bölüm 1",
              "why": "cash_spend kasa 2 aylık gider olunca işe aldığı için runway kapısını tanım gereği taşımaz; kapı yalnız cash_hoard'a uygulanır."})
    # 2 ilk 40 hf en derin acik
    def d40(m):
        return "%s (hf %d)" % (K(-m["deep40"]), m["deep40_week"])
    ok = lambda m: 25000 <= -m["deep40"] <= 45000 and m["deep40_week"] > 30
    h_ok = both([ME[(B2B[s], "home")][1] for s in seeds], ok); s_ok = both([ME[(B2B[s], "seed")][1] for s in seeds], ok)
    ch = " / ".join(ms("home", d40)); cs = " / ".join(ms("seed", d40))
    st = "geçti" if (h_ok and s_ok) else ("kaldı (home)" if (not h_ok and s_ok) else "kaldı (seed)" if (h_ok and not s_ok) else "kaldı")
    why = ""
    if st != "geçti":
        pa = lambda arm: " / ".join(K(-ME[(B2B[s_], arm)][1]["deep40"]) for s_ in seeds)
        why = "home kolunda açık %s: araç ve servis gideri kalkıp evde kira olmadığı için ilk yıl 25 binin %s altında kalıyor (hafif fazla kolay, Risk 2); seed kolunda İş hanı peşini ve kirası açığı %s'a çıkarıyor, bant içinde." % (
            pa("home"), " / ".join(K(25000 + ME[(B2B[s_], "home")][1]["deep40"]) for s_ in seeds), pa("seed"))
    G.append({"id": "2", "name": "ilk 40 haftada en derin kümülatif açık (hf > 30)", "target": "25 ile 45 bin, hf > 30", "home": ch, "seed": cs, "status": st, "evidence": "bölüm 2, `main.*.deep40`", "why": why})
    # 3 52. hf
    ok = lambda m: m["c52"] <= 80000
    c3h = " / ".join(ms("home", lambda m: K(m["c52"]))); c3s = " / ".join(ms("seed", lambda m: K(m["c52"])))
    h_ok = both([ME[(B2B[s], "home")][1] for s in seeds], ok); s_ok = both([ME[(B2B[s], "seed")][1] for s in seeds], ok)
    G.append({"id": "3", "name": "52. hafta kümülatif net", "target": "<= 80 bin", "home": c3h, "seed": c3s, "status": "geçti" if (h_ok and s_ok) else "kaldı", "evidence": "bölüm 2, `main.*.c52`",
              "why": "" if (h_ok and s_ok) else "52. haftada kümülatif net %s ile %s, 80 binin üstü." % (c3h, c3s)})
    # 4 evre 3 aylik net, uc referans
    for tag, lab, key, getref in (("4a", "Q0b (eski kod tabanı)", "net3", lambda n: REF[n]["q0b_net3"]), ("4b", "K9 (bugünkü kod)", "net3", lambda n: REF[n]["k9_net3"]),
                                  ("4c", "K9 tekrarlayan net (tek seferlik hariç)", "net3_rec", lambda n: REF[n]["k9_net3_rec"])):
        def ratio(arm):
            return [ME[(B2B[s], arm)][1][key] / getref(B2B[s]) for s in seeds]
        rh, rs = ratio("home"), ratio("seed")
        okk = all(x <= 2.0 for x in rh + rs)
        fmt = lambda arm, rr: " / ".join("%s (x%.2f)" % (K(ME[(B2B[s], arm)][1][key]), r) for s, r in zip(seeds, rr))
        G.append({"id": tag, "name": "evre 3 aylık net, referans: " + lab, "target": "<= 2 x bugün (" + " / ".join(K(getref(B2B[s])) for s in seeds) + ")", "home": fmt("home", rh), "seed": fmt("seed", rs),
                  "status": "geçti" if okk else "kaldı", "evidence": "bölüm 2, `ref`",
                  "why": "" if okk else "yeni evre 3 neti %s, referansın 2 katını (%s) aşıyor: araç (%s) ve servis (%s) gideri kalkınca evre 3 gideri aylık %s düşüyor, maaş x1,5 ve yeni sunucu fiyatı yalnız %s ekliyor; gelir aynı kaldığı için net bugünkünün çok üstünde." % (
                      fmt("home", rh), " / ".join(K(2 * getref(B2B[s])) for s in seeds), " / ".join(K(P3[B2B[s]]["tools"]) for s in seeds), " / ".join(K(P3[B2B[s]]["svc"]) for s in seeds),
                      " / ".join(K(P3[B2B[s]]["tools"] + P3[B2B[s]]["svc"] - P3[B2B[s]]["added"]) for s in seeds), " / ".join(K(P3[B2B[s]]["added"]) for s in seeds))})
    # 5 evre 2 runway
    def r2(m):
        return ("%.1f ay (hf %d-%d)" % (m["mr2"], m["mr2_blk"][1], m["mr2_blk"][2])) if m["mr2"] is not None else "açık yok"
    ok = lambda m: m["mr2"] is not None and m["mr2"] < 4
    h_ok = both([ME[(B2B[s], "home")][1] for s in seeds], ok); s_ok = both([ME[(B2B[s], "seed")][1] for s in seeds], ok)
    c5h = " / ".join(ms("home", r2)); c5s = " / ".join(ms("seed", r2))
    det = " / ".join("kasa %s, aylık net açık %s" % (K(ME[(B2B[s], "home")][1]["mr2_blk"][3]), K(ME[(B2B[s], "home")][1]["mr2_blk"][4])) for s in seeds)
    G.append({"id": "5", "name": "evre 2'de en düşük runway (en az bir kez < 4 ay)", "target": "< 4 ay", "home": c5h, "seed": c5s, "status": "geçti" if (h_ok and s_ok) else "kaldı",
              "evidence": "bölüm 2, `main.*.mr2_blk`",
              "why": "" if (h_ok and s_ok) else "en sıkı 4 haftalık blokta (home: %s) kasa net açığın en az 6 katı kalıyor: araç ve servis gideri kalkınca gelir seed'den önce gideri yakalıyor, seed parası da kasayı tamponluyor (K9 kaydında bu değer %s / %s)." % (
                  det, ("%.1f" % REF[B2B[7]]["mr2"]).replace(".", ","), ("%.1f" % REF[B2B[11]]["mr2"]).replace(".", ","))})
    # 6 spend/hoard
    gs = [GAP[B2B[s]] for s in seeds]
    c6 = " / ".join("hf %d vs %d: %d hf" % (g["spend"], g["hoard"], g["diff"]) for g in gs)
    ok6 = all(g["diff"] >= 6 for g in gs)
    G.append({"id": "6a", "name": "cash_spend ile cash_hoard: ilk işe alım farkı", "target": ">= 6 hf", "home": c6, "seed": c6 + " (aynı)", "status": "geçti" if ok6 else "kaldı", "evidence": "bölüm 3",
              "why": "" if ok6 else "iki kural aynı haftalarda işe alıyor: kasa karar doğurmuyor (Risk 2)."})
    c6b = " / ".join("f=1: %d, f=0,5: %.1f hf" % (g["sa_f1"], g["sa_f05"]) for g in gs)
    ok6b = all(g["sa_f05"] >= 6 for g in gs)
    G.append({"id": "6b", "name": "cash_spend ile cash_hoard: Series A Avı farkı (tahmin)", "target": ">= 6 hf", "home": c6b, "seed": c6b + " (aynı)", "status": "geçti" if ok6b else "kaldı", "evidence": "bölüm 3 (kayma f varsayımı)",
              "why": "" if ok6b else "ilk işe alım farkı %s hafta ama Series A Avı'na yalnız yarısı yansırsa (f = 0,5) fark %s hafta, tohum 11'de 6'nın altı; f = 1 ile %s hafta: sonuç ölçülmemiş kayma varsayımına bağlı." % (" / ".join(str(g_["diff"]) for g_ in gs), " / ".join("%.1f" % g_["sa_f05"] for g_ in gs), " / ".join(str(g_["sa_f1"]) for g_ in gs))})
    # 7 seed kolu rapor
    parts = []
    for s in seeds:
        mv = MV[(B2B[s], "kirasiz", False)]
        mi = mv["ishani"]
        if mi:
            parts.append("hf %d: İş hanı kararı hf %d, varış hf %d, runway %.1f → %.1f ay; Plaza: %s" % (s and C.get_run(B2B[s])["seed"]["day"], mi["week"], mi["arrive"], mi["runway_before"], mi["runway_after"],
                                                                                           move_text(mv["plaza_first"], mv["plaza_ok"])))
        else:
            f0 = mv["first"]
            parts.append("taşınmadı (kasa %s, gerekli %s)" % (K(f0["cash"]), K(f0["need"])))
    G.append({"id": "7", "name": "seed kolunda taşınma haftası, o haftanın runway'i, Plaza'ya varış", "target": "rapor", "home": "taşınmaz", "seed": " // ".join("tohum %d, seed %s" % (sd, p_) for sd, p_ in zip(seeds, parts)),
              "status": "rapor", "evidence": "bölüm 2, taşınma tablosu", "why": ""})
    # 8 b2c
    def b2c_ok(arm):
        return all(CM[(arm, s)]["deep"] >= 1.5 * REFC[B2C[s]]["deep"] and CM[(arm, s)]["c101"] >= 0.8 * REFC[B2C[s]]["c101"] for s in seeds)
    fd = lambda arm: " / ".join("%s (x%.2f)" % (K(-CM[(arm, s)]["deep"]), CM[(arm, s)]["deep"] / REFC[B2C[s]]["deep"]) for s in seeds)
    fn = lambda arm: " / ".join("%s (%.0f%%)" % (K(CM[(arm, s)]["c101"], 0), 100.0 * CM[(arm, s)]["c101"] / REFC[B2C[s]]["c101"]) for s in seeds)
    tgt = " / ".join("%s ve %s" % (K(-1.5 * REFC[B2C[s]]["deep"]), K(0.8 * REFC[B2C[s]]["c101"], 0)) for s in seeds)
    for tag, nm, fz, okf in (("8a", "B2C en derin açık", fd, lambda arm: all(CM[(arm, s)]["deep"] >= 1.5 * REFC[B2C[s]]["deep"] for s in seeds)),
                             ("8b", "B2C 101. hf net", fn, lambda arm: all(CM[(arm, s)]["c101"] >= 0.8 * REFC[B2C[s]]["c101"] for s in seeds))):
        hk, sk = okf("home"), okf("seed")
        G.append({"id": tag, "name": nm, "target": "bugünkünün <= x1,5 (%s)" % " / ".join(K(-1.5 * REFC[B2C[s]]["deep"]) for s in seeds) if tag == "8a" else "bugünkünün >= %%80 (%s)" % " / ".join(K(0.8 * REFC[B2C[s]]["c101"], 0) for s in seeds),
                  "home": fz("home"), "seed": fz("seed"), "status": "geçti" if (hk and sk) else "kaldı" if not (hk or sk) else ("kaldı (home)" if not hk else "kaldı (seed)"),
                  "evidence": "bölüm 5",
                  "why": "" if (hk and sk) else ("bugünkü kayıt çok küçük bir açıkla başlıyor (%s); göreli kapı bu tabanda kırılgan, mutlak açık %s." % (" / ".join(K(-REFC[B2C[s]]["deep"]) for s in seeds), fz("home")) if tag == "8a"
                                                  else "101. hf net bugünün altında: %s." % fn("home"))})
    # 9 M12
    m12s = " / ".join("%.1f%%" % M12[B2B[s]][1] for s in seeds) + " (B2B auto); B2C " + " / ".join("%.1f%%" % M12[B2C[s]][1] for s in seeds)
    G.append({"id": "9", "name": "M12 sunucu payı (Standart, auto)", "target": "rapor (kapı değil, Karar 2)", "home": m12s, "seed": m12s + " (aynı)", "status": "rapor", "evidence": "bölüm 6", "why": ""})
    return G


def kc(x):
    """K biçimi, virgüllü ve tiresiz: 23,2 bin ya da eksi 18,0 bin."""
    v = x / 1000.0
    return ("eksi %.1f bin" % -v if v < 0 else "%.1f bin" % v).replace(".", ",")


def build_summary(G, B2B, B2C, ME, REF, GAP, FH, MV, CM, REFC, PM, run_of):
    seeds = D.SEEDS
    g = {x["id"]: x for x in G}
    c = lambda x: ("%s" % x).replace(".", ",")
    m = lambda arm, key: [ME[(B2B[s], arm)][1][key] for s in seeds]
    k9 = [FH[B2B[s]]["k9"] for s in seeds]
    spend = [GAP[B2B[s]]["spend"] for s in seeds]
    hoard = [GAP[B2B[s]]["hoard"] for s in seeds]
    ratio = lambda key, ref: [ME[(B2B[s], "home")][1][key] / ref(B2B[s]) for s in seeds]
    r_k9 = ratio("net3", lambda n: REF[n]["k9_net3"]); r_q = ratio("net3", lambda n: REF[n]["q0b_net3"]); r_kr = ratio("net3_rec", lambda n: REF[n]["k9_net3_rec"])
    mv = [MV[(B2B[s], "kirasiz", False)] for s in seeds]
    mvk = [MV[(B2B[s], "kirali", False)] for s in seeds]
    pl = []
    for x in mv:
        pl.append("hf %d" % x["plaza_ok"]["arrive"] if x["plaza_ok"] else "104. haftaya kadar yok")
    f1 = lambda x: ("%.1f" % x).replace(".", ",")
    L1 = "1. İlk çalışan: botun kendi işe alımında runway %s ve %s ay (hedef 6,7 ve üstü: %s). cash_spend hf %s ve %s'te alıyor ve kasası %s ile %s bine iniyor, cash_hoard hf %s ve %s'te alıyor; fark %s ve %s hafta (hedef 6 ve üstü: %s), Series A Avı farkı f=0,5 ile %s ve %s hafta (%s)." % (
        f1(k9[0]["runway"]), f1(k9[1]["runway"]), g["1a"]["status"], spend[0], spend[1], f1(PM[("spend", "home", 7)]["mincash"] / 1000), f1(PM[("spend", "home", 11)]["mincash"] / 1000),
        hoard[0], hoard[1], hoard[0] - spend[0], hoard[1] - spend[1], g["6a"]["status"], f1(GAP[B2B[7]]["sa_f05"]), f1(GAP[B2B[11]]["sa_f05"]), g["6b"]["status"])
    L2 = "2. İlk 40 haftada en derin açık: home %s ve %s (hedef 25 ile 45 bin; home bandın altında%s: %s), seed %s ve %s (hafta %s ve %s, bant içinde); 52. hafta net home %s ve %s, seed %s ve %s (hedef 80 bin ve altı: %s)." % (
        kc(-m("home", "deep40")[0]), kc(-m("home", "deep40")[1]), "" if g["2"]["status"] != "geçti" else " değil", "geçmedi" if g["2"]["status"] != "geçti" else "geçti", kc(-m("seed", "deep40")[0]), kc(-m("seed", "deep40")[1]),
        ME[(B2B[7], "seed")][1]["deep40_week"], ME[(B2B[11], "seed")][1]["deep40_week"],
        kc(m("home", "c52")[0]), kc(m("home", "c52")[1]), kc(m("seed", "c52")[0]), kc(m("seed", "c52")[1]), g["3"]["status"])
    L3 = "3. Evre 3 aylık net home %s ve %s: Q0b referansının x%s ve x%s katı (%s), K9 referansının x%s ve x%s katı (%s), K9 tekrarlayan referansın x%s ve x%s katı (%s); neden: araç ve servis giderinin kalkması evre 3'te aylık %s ve %s siler, maaş x1,5 ile yeni sunucu fiyatı ancak %s ve %s ekler." % (
        kc(m("home", "net3")[0]), kc(m("home", "net3")[1]), c("%.2f" % r_q[0]), c("%.2f" % r_q[1]), g["4a"]["status"], c("%.2f" % r_k9[0]), c("%.2f" % r_k9[1]), g["4b"]["status"],
        c("%.2f" % r_kr[0]), c("%.2f" % r_kr[1]), g["4c"]["status"],
        kc(P3[B2B[7]]["tools"] + P3[B2B[7]]["svc"]), kc(P3[B2B[11]]["tools"] + P3[B2B[11]]["svc"]), kc(P3[B2B[7]]["added"]), kc(P3[B2B[11]]["added"]))
    L4 = "4. Evre 2'de en düşük runway home %s ve %s ay, seed %s ve %s ay; hedef en az bir kez 4 ayın altına inmek: %s (kasa net açığın en az 6 katı kalıyor)." % (
        *[f1(x) for x in m("home", "mr2")], *[f1(x) for x in m("seed", "mr2")], g["5"]["status"])
    L5 = "5. Seed kolu (kirasız gider tanımı): tohum 7 seed hf %s'de kasa %s, gereken %s; hf %s'de karar, hf %s'de varış, runway %s aya iniyor. Tohum 11 seed hf %s'de kasa %s, gereken %s; varış hf %s, runway %s ay. Kiralı gider tanımında tohum 7 seed haftasında taşınamıyor (kasa %s, gereken %s). Kadro masayı hf %s ve %s'de aşıyor, Plaza'ya varış hf %s ve %s (6 aylık tutma kuralı Plaza'da %s ve %s ister)." % (
        C.get_run(B2B[7])["seed"]["day"], kc(mv[0]["ishani"]["cash"]), kc(mv[0]["ishani"]["need"]), mv[0]["ishani"]["week"], mv[0]["ishani"]["arrive"], f1(mv[0]["ishani"]["runway_after"]),
        C.get_run(B2B[11])["seed"]["day"], kc(mv[1]["ishani"]["cash"]), kc(mv[1]["ishani"]["need"]), mv[1]["ishani"]["arrive"], f1(mv[1]["ishani"]["runway_after"]),
        kc(mvk[0]["first"]["cash"]), kc(mvk[0]["first"]["need"]), mv[0]["plaza_first"]["week"], mv[1]["plaza_first"]["week"],
        mv[0]["plaza_ok"]["arrive"] if mv[0]["plaza_ok"] else "yok", mv[1]["plaza_ok"]["arrive"] if mv[1]["plaza_ok"] else "yok", kc(mv[0]["plaza_ok"]["need"]), kc(mv[1]["plaza_ok"]["need"]))
    L6 = "6. B2C en derin açık home %s ve %s, seed %s ve %s (bugünkünün x%s ve x%s katı, hedef 1,5 ve altı: %s); 101. hafta net bugünün %%%s ve %%%s'i (hedef %%80 ve üstü: %s). M12 sunucu payı Standart auto B2B %%%s, B2C %%%s (rapor)." % (
        kc(-CM[("home", 7)]["deep"]), kc(-CM[("home", 11)]["deep"]), kc(-CM[("seed", 7)]["deep"]), kc(-CM[("seed", 11)]["deep"]),
        c("%.2f" % (CM[("seed", 7)]["deep"] / REFC[B2C[7]]["deep"])), c("%.2f" % (CM[("seed", 11)]["deep"] / REFC[B2C[11]]["deep"])), g["8a"]["status"],
        c("%.0f" % (100 * CM[("seed", 7)]["c101"] / REFC[B2C[7]]["c101"])), c("%.0f" % (100 * CM[("seed", 11)]["c101"] / REFC[B2C[11]]["c101"])), g["8b"]["status"],
        f1((G_M12[B2B[7]][1] + G_M12[B2B[11]][1]) / 2), f1((G_M12[B2C[7]][1] + G_M12[B2C[11]][1]) / 2))
    return [L1, L2, L3, L4, L5, L6]


if __name__ == "__main__":
    main()
