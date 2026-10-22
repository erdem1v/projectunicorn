"""C0s bolum D: ekonomi tahmini (M11, M12, runway, acik, Frank sarti, Plaza, cash_spend/hoard, B2C). python -I.
Yontem: K9 (910ad1f) bot kayitlarinin aylik gider dokumu (PROBE MONTH_BURN) ve STATE uzerine muhasebe; bot kararlari sabit (tahmin, oyun kosusu degil).
Yeni kurallar: kurucu maasi yok, arac ve servis yok, maas bantlari x1,5 (maas, ek mesai, ise alim primi), ofis kirasi (Is hani 4.000, Plaza 8.000, Loft 18.000), sunucu fiyati
(B2B 50 koltuk basina 60/120/240; B2C 1.000 kullanici basina 125/250/500), masa tavani. Cikti: out/c0s_d.md, c0s_d.json."""
import sys, os, json, math, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_core as C, c0s_data as D, c0s_model as M

J = {}
L = []


def w(s=""):
    L.append(s)


def pct(a, b):
    return 100.0 * a / b if b else float("nan")


T = 104
RENT = {"home": 0, "ishani": 4000, "plaza": 8000, "loft": 18000}
SAL_MULT = 1.5
OLD_UNIT = {"b2b": 45, "b2c": 55}          # infra_system.gd:26,28 @910ad1f (bulut = Standart)
NEW_UNIT = {"b2b": 120, "b2c": 250}
TIER_F = {"eko": 0.5, "std": 1.0, "kur": 2.0}
UNIT_SIZE = {"b2b": 50, "b2c": 1000}       # koltuk / kullanici
SEAT_PRICE = 50                            # SEAT_PRICE_MIN 30 .. MAX 70, ortasi 50 (sales_ledger.gd:141-144)
GATE_ROWS = 4                              # runway icin ay = 30/7 hafta
Q = 30.0 / 7.0


def weekly(run, market):
    """Aylik dokumu haftalik seriye ceviri: her ay satiri, son `ticks` haftasina esit bolunur."""
    inc = [0.0] * (T + 2); sal = [0.0] * (T + 2); ot = [0.0] * (T + 2); mkt = [0.0] * (T + 2); one = [0.0] * (T + 2)
    srv = [0.0] * (T + 2); tools = [0.0] * (T + 2); svc = [0.0] * (T + 2)
    for m in run["month_burn"]:
        k = int(m["ticks"]); e = int(m["end"])
        if k <= 0:
            continue
        for wk in range(max(1, e - k + 1), min(T, e) + 1):
            sal[wk] += m["salaries"] / k; ot[wk] += m["overtime"] / k; mkt[wk] += m["marketing"] / k
            one[wk] += m["one_time"] / k; srv[wk] += m["servers"] / k; tools[wk] += m["tools"] / k; svc[wk] += m["service"] / k
            inc[wk] += m["income"] / k
    return {"inc": inc, "sal": sal, "ot": ot, "mkt": mkt, "one": one, "srv": srv, "tools": tools, "svc": svc}


def state(run, t, key, default=0):
    d = t
    while d > 0 and d not in run["state"]:
        d -= 1
    return run["state"].get(d, {}).get(key, default)


def mvp_day(run):
    return run["ship"][0] if run["ship"] else 7


def served_units(run, market, t):
    if market == "b2b":
        return state(run, t, "mrr") / SEAT_PRICE / UNIT_SIZE["b2b"]
    d = t
    while d > 0 and d not in run["b2c"]:
        d -= 1
    return run["b2c"].get(d, {}).get("aud", 0.0) / UNIT_SIZE["b2c"]


def capacity_series(run, market, policy, thr=0.80, tgt=0.65):
    """Hafta basina satin alinan birim. policy: lean (pay %5), wide (pay %40), auto (esik %80 -> yuk %65, kucultme yok), recorded (K9)."""
    cap = [0] * (T + 2)
    mv = mvp_day(run)
    cur = 0
    for t in range(1, T + 1):
        if t < mv:
            cap[t] = 0; continue
        need = served_units(run, market, t)
        if policy == "lean":
            cur = max(1, math.ceil(need / 0.95 - 1e-9))
        elif policy == "wide":
            cur = max(1, math.ceil(need / 0.60 - 1e-9))
        elif policy == "auto":
            if cur == 0:
                cur = 1
            if need / cur >= thr:
                cur = max(cur + 1, math.ceil(need / tgt - 1e-9))
        cap[t] = cur
    return cap


def load_series(run, market, cap):
    return [(served_units(run, market, t) / cap[t]) if cap[t] > 0 else 0.0 for t in range(T + 2)] if False else \
        [(served_units(run, market, t) / cap[t]) if (t <= T and cap[t] > 0) else 0.0 for t in range(T + 2)]


def servers_new(run, market, ser, policy, tier="std"):
    """Haftalik sunucu faturasi (yeni fiyat)."""
    out = [0.0] * (T + 2)
    if policy == "recorded":
        for t in range(1, T + 1):
            out[t] = ser["srv"][t] * NEW_UNIT[market] / OLD_UNIT[market] * TIER_F[tier]
        return out, None
    cap = capacity_series(run, market, policy)
    for t in range(1, T + 1):
        out[t] = cap[t] * NEW_UNIT[market] * TIER_F[tier] / Q
    return out, cap


def first_hire_day(run):
    return run["hires"][0]["day"] if run["hires"] else None


def econ(run, market, srv_policy="recorded", tier="std", rent_policy="bot", d_inc=None, sal_mult=SAL_MULT, move_to=None, label=""):
    """Haftalik yeni gider/gelir, kumulatif net, nakit. rent_policy 'bot': Is hani ilk ise alim varisinda, Plaza (masa 10 dolunca, nakit 45.000, marka 40) kosullar tutunca."""
    ser = weekly(run, market)
    sv, cap = servers_new(run, market, ser, srv_policy, tier)
    h1 = first_hire_day(run)
    # ise alim primi farki
    extra = [0.0] * (T + 2)
    for h in run["hires"]:
        if h["day"] <= T:
            extra[h["day"]] += 0.5 * (sal_mult - 1.0) * h["salary"]
    # kira
    rent = [0.0] * (T + 2); office = ["home"] * (T + 2)
    cash_old = [state(run, t, "cash", 0) for t in range(T + 2)]
    cum_old = [0.0] * (T + 2); cum_new = [0.0] * (T + 2); cash_new = [0.0] * (T + 2)
    exp_new = [0.0] * (T + 2); exp_old = [0.0] * (T + 2); inc = [0.0] * (T + 2)
    cur = "home"; plaza_week = None; full_week = None; plaza_gap = None
    for t in range(1, T + 1):
        exp_old[t] = ser["sal"][t] + ser["ot"][t] + ser["tools"][t] + ser["mkt"][t] + ser["one"][t] + ser["srv"][t] + ser["svc"][t]
        inc[t] = ser["inc"][t] + ((d_inc[t] if d_inc else 0.0))
        cum_old[t] = cum_old[t - 1] + ser["inc"][t] - exp_old[t]
    for t in range(1, T + 1):
        emp = state(run, t, "emp", 0)
        brand = state(run, t, "brand", 0)
        if cur == "home" and h1 is not None and t >= h1:
            cur = "ishani"
        if cur == "ishani" and plaza_week is None:
            if emp + 1 >= 10 and full_week is None:
                full_week = t
            if full_week is not None:
                cash_est = cash_old[t] + (cum_new[t - 1] - cum_old[t - 1])
                if cash_est >= 45000 and brand >= 40:
                    cur = "plaza"; plaza_week = t; plaza_gap = t - full_week
        if full_week is not None and plaza_week is None and plaza_gap is None:
            pass
        office[t] = cur
        rent[t] = RENT[cur] / Q
        exp_new[t] = ser["sal"][t] * sal_mult + ser["ot"][t] * sal_mult + ser["mkt"][t] + ser["one"][t] + extra[t] + sv[t] + rent[t]
        cum_new[t] = cum_new[t - 1] + inc[t] - exp_new[t]
        cash_new[t] = cash_old[t] + (cum_new[t] - cum_old[t])
    # plaza kosullarinin ilk tuttugu hafta (hic donmediyse bos)
    res = {"inc": inc, "exp_new": exp_new, "exp_old": exp_old, "cum_new": cum_new, "cum_old": cum_old, "cash_new": cash_new, "cash_old": cash_old,
           "rent": rent, "office": office, "servers": sv, "cap": cap, "full_week": full_week, "plaza_week": plaza_week, "plaza_gap": plaza_gap, "ser": ser}
    return res


def agg(run, market, e, which="new"):
    exp = e["exp_new"] if which == "new" else e["exp_old"]
    cum = e["cum_new"] if which == "new" else e["cum_old"]
    # en derin kumulatif acik
    arg = min(range(1, T + 1), key=lambda t: cum[t])
    first40 = min(range(1, 41), key=lambda t: cum[t])
    # 30. haftadan sonra en derin (<= 40)
    after30 = min(range(31, 41), key=lambda t: cum[t])
    c52 = cum[52]; c101 = cum[min(101, T)]
    # evre 3 aylik net
    p3 = [t for t in range(1, T + 1) if state(run, t, "phase", 1) == 3]
    p2 = [t for t in range(1, T + 1) if state(run, t, "phase", 1) == 2]
    net3 = (sum(e["inc"][t] - exp[t] for t in p3) / len(p3) * Q) if p3 else None
    # evre 2 en dusuk runway (4 haftalik bloklar)
    mr2 = None
    cash = e["cash_new"] if which == "new" else e["cash_old"]
    for i in range(0, len(p2) - 3, 4):
        blk = p2[i:i + 4]
        gap = sum(exp[t] - e["inc"][t] for t in blk) / 4 * Q
        if gap > 0:
            rw = cash[blk[-1]] / gap
            mr2 = rw if mr2 is None else min(mr2, rw)
    mincash = min(cash[1:T + 1])
    return {"deep": cum[arg], "deep_week": arg, "deep40": cum[first40], "deep40_week": first40, "deep_after30": cum[after30], "deep_after30_week": after30,
            "c52": c52, "c101": c101, "net3": net3, "mr2": mr2, "mincash": mincash, "p3_weeks": len(p3)}


def first_hire_runway(run, market, e, sal_mult=None):
    """Ilk calisanin basladigi hafta: kasa / aylik gider (kira, maas x1,5, sunucu; gelir haric)."""
    h = run["hires"][0] if run["hires"] else None
    if h is None:
        return None
    t = h["day"]
    out_m = RENT["ishani"] + (sal_mult or SAL_MULT) * h["salary"] + e["servers"][t] * Q
    return {"day": t, "cash": e["cash_new"][t], "out": out_m, "runway": e["cash_new"][t] / out_m, "salary": h["salary"],
            "cash_old": e["cash_old"][t], "old_burn_m": run["state"].get(t, {}).get("burn", 0) * 30}


def nohire_cash(run, market, e, upto):
    """Ilk ise alim hic yokmus gibi nakit: gelir - sunucu (kira, maas yok), K9'in ilk ise alimindan sonrasi icin."""
    h1 = first_hire_day(run) or upto
    cash = {}
    base = None
    for t in range(1, upto + 1):
        if t < h1:
            cash[t] = e["cash_new"][t]
        else:
            if base is None:
                base = (t - 1, cash[t - 1])
            cash[t] = cash[t - 1] + e["inc"][t] - e["servers"][t] - e["ser"]["mkt"][t] - e["ser"]["one"][t] * 0.0
        # cheque / seed: K9 nakit sicramalari bu seriye STATE'ten eklenir
        if t >= h1 and t > 1:
            jump = (e["cash_old"][t] - e["cash_old"][t - 1]) - (e["inc"][t] - e["exp_old"][t])
            if abs(jump) > 5000:     # dis fonlama (ceki, seed)
                cash[t] += jump
    return cash


def variants(run, market, e):
    """Frank sarti (V1 ceki sart / V2 kasada 6.500 yeter) x cash_spend (k=2) / cash_hoard (k=6.7) / bot (k=6, K9 kurali). Don: ilk ise alim haftasi ve runway."""
    h = run["hires"][0] if run["hires"] else None
    if h is None:
        return None
    ch = run["end"].get("cheque_day", -1)
    nh = nohire_cash(run, market, e, T)
    out = {}
    for vname in ("V1", "V2"):
        for pname, k in (("allin", 1.0), ("spend", 2.0), ("bot", 6.0), ("hoard", 6.7)):
            hd = None
            for d in range(1, T):
                cash = nh[d]
                if vname == "V1" and not (ch > 0 and d >= ch):
                    continue
                if vname == "V2" and cash < 6500:
                    continue
                if market == "b2b" and state(run, d, "mrr") <= 0 and False:
                    continue
                out_m = RENT["ishani"] + SAL_MULT * h["salary"] + e["servers"][d] * Q
                if cash >= k * out_m:
                    hd = d + 1          # arama 1 hafta; tasinma ayni anda
                    break
            if hd is None:
                out[(vname, pname)] = None
            else:
                out_m = RENT["ishani"] + SAL_MULT * h["salary"] + e["servers"][hd] * Q
                out[(vname, pname)] = {"hire": hd, "cash": nh[hd], "runway": nh[hd] / out_m}
    return out


def a_day(run, thr=120000):
    for t in range(1, T + 1):
        if state(run, t, "mrr") >= thr:
            return t
    return None


# ------------------------------------------------------------------ gelir etkisi (C modeli)
def income_delta(name, c):
    res, accts, run, wd = C.run_accounts(name, c)
    d = [0.0] * (T + 2)
    churn = run["churn"]
    for a in accts:
        r = res[a.id]
        k9_end = churn.get(a.id, T + 1)
        for t in range(a.sign, T + 1):
            k9 = a.mrr if t < k9_end else 0.0
            if r["rejected"]:
                cm = 0.0
            else:
                cm = r["mrr"].get(t, 0.0) if (r["left"] is None or t < r["left"]) else 0.0
                if t not in r["mrr"] and r["left"] is None:
                    cm = r["mrr"].get(max(r["mrr"]), 0.0) if r["mrr"] else 0.0
            d[t] += (cm - k9) / Q
    return d


def main():
    names = [D.run_name(a, s) for a in D.ARMS for s in D.SEEDS]
    c = M.cfg()
    # ---------------------------------------------------- M12: sunucu payi, politikaya gore
    w("### M12 Sunucu faturasının gelire payı (Standart, 26-104. hafta)")
    w("")
    w("Hedef: Standart'ta %8-12; Ekonomik yaklaşık yarısı, Kurumsal yaklaşık iki katı. Fiyat B2B 50 koltuk başına $120 (yeni), B2C 1.000 kullanıcı başına $250. "
      "Kapasite politikası artık oyuncunun: `recorded` = K9 botunun eski otomatik büyümesi (bugünkü kod), `lean` = elle, pay %5; `wide` = elle, pay %40; `auto` = anahtar açık "
      "(yük %80'e varınca yük %65'e inecek kadar büyür, küçültmez). Hizmet edilen koltuk = MRR ÷ $50 (koltuk fiyatı bandının ortası; varsayım).")
    w("")
    w("| Pazar | Kayıt | recorded | lean | wide | auto | auto Ekonomik | auto Kurumsal |")
    w("|---|---|---|---|---|---|---|---|")
    m12 = {}
    mk_names = [(n, "b2b") for n in names] + [(D.run_name("worst", s, True), "b2c") for s in D.SEEDS] + [(D.run_name("none", s, True), "b2c") for s in D.SEEDS]
    for n, mk in mk_names:
        run = C.get_run(n)
        row = []
        for pol, tier in (("recorded", "std"), ("lean", "std"), ("wide", "std"), ("auto", "std"), ("auto", "eko"), ("auto", "kur")):
            e = econ(run, mk, srv_policy=pol, tier=tier)
            sv = sum(e["servers"][t] for t in range(26, T + 1)); inc = sum(e["inc"][t] for t in range(26, T + 1))
            row.append(pct(sv, inc))
        m12[n] = row
        w("| %s | %s | %s |" % (mk, n.replace("full_run_", ""), " | ".join("%.1f%%" % x for x in row)))
    J["M12"] = m12
    # ---------------------------------------------------- M11: B2B
    w("")
    w("### M11 Gider ve runway, B2B (K9 `fix_worst` ve diğer kollar, tahmin)")
    w("")
    w("\"Bugün\" = K9 kaydı olduğu gibi (910ad1f koduyla, araç ve servis var, kurucu araç tabanı $1.500). \"Yeni\" = C'nin giderleriyle muhasebe, sunucu `auto` politikasıyla (anahtar açık), kira botun taşınmasıyla. "
      "Gelir yeni satırda iki hâlli: etkisiz (K9 geliri) ve etkili (C kapısı, yenileme sonuçları, kayıplar: ΔMRR). Net: gelir - gider; dış fonlama (Frank'in çeki, seed) hariç.")
    w("")
    w("| Koşu | Varyant | en derin kümülatif açık (hf) | 52. hf kümülatif | 101. hf kümülatif | evre 3 aylık net | evre 2 en düşük runway (ay) | en düşük nakit |")
    w("|---|---|---|---|---|---|---|---|")
    eco = {}
    for n in names:
        run = C.get_run(n)
        dinc = income_delta(n, c)
        for lab, pol, di in (("bugün (K9 kaydı)", None, None), ("yeni, etkisiz gelir", "auto", None), ("yeni, etkili gelir", "auto", dinc), ("yeni, recorded sunucu", "recorded", None)):
            if pol is None:
                e = econ(run, "b2b", "recorded", sal_mult=1.0)
                # bugun: gider = eski gider
                e["exp_new"] = e["exp_old"]; e["cum_new"] = e["cum_old"]; e["cash_new"] = e["cash_old"]
                a = agg(run, "b2b", e, "new")
            else:
                e = econ(run, "b2b", pol, d_inc=di)
                a = agg(run, "b2b", e)
            eco[(n, lab)] = a
            w("| %s | %s | %s (%d) | %s | %s | %s | %s | %s |" % (n.replace("full_run_", ""), lab, "%.0fK" % (a["deep"] / 1000), a["deep_week"], "%.0fK" % (a["c52"] / 1000),
                                                                "%.0fK" % (a["c101"] / 1000), ("%.0fK" % (a["net3"] / 1000)) if a["net3"] is not None else "-",
                                                                ("%.1f" % a["mr2"]) if a["mr2"] is not None else "açık yok", "%.0fK" % (a["mincash"] / 1000)))
    J["eco"] = {"%s|%s" % k: v for k, v in eco.items()}
    # kapi okumasi
    w("")
    w("Kapı okuması (B2B `fix_worst`, tohum 7 / 11; \"yeni, etkili gelir\" ve \"yeni, etkisiz gelir\" ayrı):")
    w("")
    w("| Kapı | hedef | tohum 7 etkisiz | tohum 11 etkisiz | tohum 7 etkili | tohum 11 etkili | Sonuç |")
    w("|---|---|---|---|---|---|---|")
    def g(sd, lab, key):
        return eco[("full_run_fix_worst_%d" % sd, lab)][key]
    rows = []
    # en derin acik (ilk 40 hafta)
    def deep40(sd, lab):
        run = C.get_run("full_run_fix_worst_%d" % sd)
        di = income_delta("full_run_fix_worst_%d" % sd, c) if "etkili" in lab else None
        e = econ(run, "b2b", "auto", d_inc=di)
        a = agg(run, "b2b", e)
        return a["deep40"], a["deep40_week"]
    d40 = {(sd, lab): deep40(sd, lab) for sd in D.SEEDS for lab in ("etkisiz", "etkili")}
    ok40 = all(25000 <= -d40[(sd, lab)][0] <= 45000 and d40[(sd, lab)][1] > 30 for sd in D.SEEDS for lab in ("etkisiz", "etkili"))
    w("| ilk 40 haftada en derin kümülatif açık, hf > 30 | 25-45K | %s | %s | %s | %s | %s |" % (
        *["%.0fK (hf %d)" % (-d40[(sd, lab)][0] / 1000, d40[(sd, lab)][1]) for lab in ("etkisiz", "etkili") for sd in D.SEEDS], "geçti" if ok40 else "kaldı"))
    c52ok = all(g(sd, lab, "c52") <= 80000 for sd in D.SEEDS for lab in ("yeni, etkisiz gelir", "yeni, etkili gelir"))
    w("| 52. hafta kümülatif net | <= 80K | %s | %s | %s | %s | %s |" % (*["%.0fK" % (g(sd, lab, "c52") / 1000) for lab in ("yeni, etkisiz gelir", "yeni, etkili gelir") for sd in D.SEEDS], "geçti" if c52ok else "kaldı"))
    n3 = {}
    ok3 = True
    cells = []
    for lab in ("yeni, etkisiz gelir", "yeni, etkili gelir"):
        for sd in D.SEEDS:
            now = g(sd, "bugün (K9 kaydı)", "net3"); new = g(sd, lab, "net3")
            cells.append("%.0fK / %.0fK (x%.2f)" % (new / 1000, now / 1000, new / now))
            ok3 = ok3 and new <= 2 * now
    w("| evre 3 aylık net (yeni / bugün) | <= 2 x bugün | %s | %s | %s | %s | %s |" % (*cells, "geçti" if ok3 else "kaldı"))
    mr = [g(sd, lab, "mr2") for lab in ("yeni, etkisiz gelir", "yeni, etkili gelir") for sd in D.SEEDS]
    okr = any((x is not None and x < 4) for x in mr)
    w("| evre 2'de en düşük runway < 4 ay en az bir kez | < 4 ay | %s | %s | %s | %s | %s |" % (*[("%.1f ay" % x) if x is not None else "açık yok" for x in mr], "geçti" if okr else "kaldı"))
    # ilk calisan runway
    w("")
    w("### Bootstrap runway: ilk çalışanın başladığı hafta")
    w("")
    w("Kasa ÷ aylık gider (kira $4.000 + ilk çalışanın maaşı x1,5 + sunucu; gelir hariç), hedef >= 6,7 ay. Kasa = K9 kasası + yeni giderlerin farkı (Frank'in çeki dahil). K9 botunun kendi ilk işe alımı:")
    w("")
    w("| Koşu | işe alım haftası | maaş (eski bant) | kasa | aylık gider (yeni) | runway (ay) | bugünkü aylık gider (K9, hesapta) |")
    w("|---|---|---|---|---|---|---|")
    fh = {}
    for n, mk in [(n, "b2b") for n in names if n.endswith("worst_7") or n.endswith("worst_11") or n.endswith("none_7")] + [(D.run_name("worst", s, True), "b2c") for s in D.SEEDS]:
        run = C.get_run(n)
        e = econ(run, mk, "auto")
        r = first_hire_runway(run, mk, e)
        fh[n] = r
        if r:
            w("| %s | %d | %d | %.0f | %.0f | %.1f | %.0f |" % (n.replace("full_run_", ""), r["day"], r["salary"], r["cash"], r["out"], r["runway"], r["old_burn_m"]))
    J["first_hire"] = fh
    # varyantlar
    w("")
    w("### İş hanı'nın Frank şartı iki hâliyle ve cash_spend / cash_hoard")
    w("")
    w("V1 = şart kalır (Frank'in çeki alınmış ve kasa >= $6.500); V2 = yalnız kasada $6.500 yeter. İlk işe alım kuralı: kasa >= k x aylık gider (kira + maaş x1,5 + sunucu), k = 1 (`allin`: eldeki kasayla bir aylık gider), 2 (`cash_spend`), 6 (botun bugünkü kuralı, `bot`), 6,7 (`cash_hoard`, runway kapısının kendisi). "
      "Hücre: işe alım haftası / o haftanın runway'i (ay). Kasa, ilk işe alımdan sonraki K9 gelir akışının işe alım olmadan sürdüğü varsayımıyla (iyimser: ekibin getirisi sayılmaz). "
      "Series A Avı = MRR >= $120.000 (`SalesSystem.TRACTION_MRR_TARGET`); K9 kaydında varış haftası ve kaydırma tahmini: tüm sonraki akış işe alımın gecikmesi kadar kayar (f = 1) ya da yarısı kadar (f = 0,5).")
    w("")
    w("| Koşu | Frank şartı | allin (k=1) | spend | bot | hoard | spend → hoard fark (hf) | Series A Avı K9 | Series A farkı f=1 / f=0,5 |")
    w("|---|---|---|---|---|---|---|---|---|")
    var = {}
    for n, mk in [(n, "b2b") for n in names if "worst" in n or "none" in n] + [(D.run_name("worst", s, True), "b2c") for s in D.SEEDS]:
        run = C.get_run(n)
        e = econ(run, mk, "auto")
        v = variants(run, mk, e)
        if v is None:
            continue
        ad = a_day(run, 120000)
        for vn in ("V1", "V2"):
            cells = []
            for pn in ("allin", "spend", "bot", "hoard"):
                x = v[(vn, pn)]
                cells.append("-" if x is None else "%d / %.1f" % (x["hire"], x["runway"]))
            sp, ho = v[(vn, "spend")], v[(vn, "hoard")]
            diff = (ho["hire"] - sp["hire"]) if (sp and ho) else None
            var[(n, vn)] = {k[1]: x for k, x in v.items() if k[0] == vn}
            w("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (n.replace("full_run_", ""), vn, cells[0], cells[1], cells[2], cells[3], diff if diff is not None else "-", ad if ad else "yok",
                                                              ("%d / %.1f" % (diff, diff * 0.5)) if diff is not None else "-"))
    J["variants"] = {"%s|%s" % k: v for k, v in var.items()}
    # Plaza
    w("")
    w("### Plaza'nın şartları (10 kişi sen dahil, nakit $45.000, marka 40)")
    w("")
    w("İş hanı dolu = K9'daki çalışan sayısı + kurucu >= 10 (9. çalışan). Plaza koşulları: nakit (yeni giderlerle) >= $45.000 ve marka >= 40. Bot tavan yüzünden 10. çalışanı Plaza'ya taşınana kadar bekletir. "
      "Bekleme = İş hanı dolduktan sonra şartların tuttuğu ilk hafta - dolduğu hafta.")
    w("")
    w("| Koşu | 9. çalışan (İş hanı dolu) | marka o hafta | kasa o hafta (yeni) | Plaza şartları tuttu | bekleme (hf) | engelleyen şart |")
    w("|---|---|---|---|---|---|---|")
    plz = {}
    for n in names + ["full_run_fix_worst_desk_7", "full_run_fix_worst_desk_11", "full_run_quality_core_7"]:
        run = C.get_run(n)
        e = econ(run, "b2b", "auto")
        fw_ = e["full_week"]
        if fw_ is None:
            w("| %s | yok (çalışan < 9) | - | - | - | - | - |" % n.replace("full_run_", "")); continue
        cash_f = e["cash_new"][fw_]
        brand_f = state(run, fw_, "brand")
        pw = e["plaza_week"]
        why = []
        if cash_f < 45000: why.append("nakit")
        if brand_f < 40: why.append("marka")
        plz[n] = (fw_, pw)
        w("| %s | %d | %d | %.0f | %s | %s | %s |" % (n.replace("full_run_", ""), fw_, brand_f, cash_f, pw if pw else "tutmadı", (pw - fw_) if pw else "-", "/".join(why) if why else "-"))
    J["plaza"] = {k: v for k, v in plz.items()}
    # B2C
    w("")
    w("### M11 B2C (`fix_worst`)")
    w("")
    w("Hedef (PRD Risk 2, öneri): en derin açık bugünkünden en çok %50 derin; 101. hafta net bugünün %80'inden az değil; 20 koşuda iflas sayısı ve nedeni (bu muhasebe iflası ölçmez: kasanın en düşüğü yazılır).")
    w("")
    w("| Koşu | Varyant | en derin kümülatif açık (hf) | 52. hf | 101. hf | en düşük nakit |")
    w("|---|---|---|---|---|---|")
    for s in D.SEEDS:
        n = D.run_name("worst", s, True)
        run = C.get_run(n)
        res = {}
        for lab, pol in (("bugün (K9 kaydı)", None), ("yeni, auto", "auto"), ("yeni, lean", "lean"), ("yeni, wide", "wide")):
            if pol is None:
                e = econ(run, "b2c", "recorded", sal_mult=1.0)
                e["exp_new"] = e["exp_old"]; e["cum_new"] = e["cum_old"]; e["cash_new"] = e["cash_old"]
                a = agg(run, "b2c", e)
            else:
                e = econ(run, "b2c", pol)
                a = agg(run, "b2c", e)
            res[lab] = a
            w("| %s | %s | %.0fK (%d) | %.0fK | %.0fK | %.0fK |" % (n.replace("full_run_", ""), lab, a["deep"] / 1000, a["deep_week"], a["c52"] / 1000, a["c101"] / 1000, a["mincash"] / 1000))
        J.setdefault("b2c", {})[n] = res
    open(os.path.join(C.OUT, "c0s_d.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    json.dump(J, open(os.path.join(C.OUT, "c0s_d.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print("\n".join(L))


if __name__ == "__main__":
    main()
