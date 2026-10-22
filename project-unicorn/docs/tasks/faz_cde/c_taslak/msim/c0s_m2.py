"""C0s bolum B: M6, M8, M9, M13 (yenileme), RAPOR_Q 2. madde (satisci kapanis kaybi), M10 duyarlilik ve CORE_2 paneli. python -I.
Cikti: out/c0s_b.json, out/c0s_b.md"""
import sys, os, json, statistics as st, collections, random, zlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_core as C, c0s_data as D, c0s_model as M

ARMS = D.ARMS
SEEDS = D.SEEDS
J = {}
L = []


def w(s=""):
    L.append(s)


def pct(a, b):
    return 100.0 * a / b if b else float("nan")


def fmt(x, d=1):
    return "-" if x is None or x != x else ("%.*f" % (d, x))


def const_world(base, t0, T, touch_all=True, open_area=None):
    lv = base["levels"][t0]; live = base["live"][t0]
    oa = open_area if open_area is not None else base["open_area"][t0]
    return {"T": T, "levels": {t: lv for t in range(1, T + 1)}, "live": {t: live for t in range(1, T + 1)},
            "open_area": {t: oa for t in range(1, T + 1)}, "open_total": {t: sum(oa.values()) for t in range(1, T + 1)},
            "touch": {t: (set(D.AREAS) if touch_all else set()) for t in range(1, T + 1)},
            "phase": {t: 2 for t in range(1, T + 1)}, "reqs": {t: [] for t in range(1, T + 1)}}


# ------------------------------------------------------------------ M6
def m6():
    base = C.get_world("full_run_fix_worst_7")
    fw = const_world(base, 60, 130, True, {"core": 1, "onboarding": 0, "integrations": 0, "trust": 1})
    c = M.cfg()
    w("### M6 Söz (tek hesap, 2★ lojistik, dünya sabit, 20. haftada söz sonuçlanır)")
    w("")
    w("Eşiğe uzaklık 8 ve 20 (söz öncesi sabit memnuniyet - eşik). Sahip: kurucu (`cs_dampen` 1,0) ya da temsilci (Müşteri İlişkileri çıktısı 5, 0,725). "
      "Tutulan söz eşiği 5 indirir, tutulmayan 5 yükseltir (tavan +10) [`on_promise_resolved` kodda kalır, C0_HARITA §7].")
    w("")
    w("| söz | sahip | uzaklık | hf 29 | hf 40 | en düşük | Risk | sonuç | iz kaç haftada sıfırlandı | hf 100 |")
    w("|---|---|---|---|---|---|---|---|---|---|")
    rows = []
    for owner, damp in (("kurucu", 1.0), ("temsilci", 0.725)):
        cc = M.cfg(cs_dampen=damp)
        a0 = M.Acct("m6", 10, 2, "logistics", 1000, tol_override=-100)
        steady = M.simulate(a0, fw, cc, gate=False, renewals=False, risk=False, T=29)["sat"][29]
        for outc in ("broken", "late", "kept"):
            for dist in (8, 20):
                a = M.Acct("m6", 10, 2, "logistics", 1000, tol_override=steady - dist)
                ev = {"promise": {a.id: [(30, outc)]}}
                r = M.simulate(a, fw, cc, events=ev, gate=False, renewals=False, risk=True, T=120)
                ser = r["sat"]
                tr = None
                for t in range(31, 121):
                    if t in r["parts"] and abs(r["parts"][t]["ledger"] - (6.0 if outc == "kept" else 0.0)) < 1e-9:
                        tr = t - 30; break
                mn = min(ser.values())
                rows.append((outc, owner, dist, tr, r["risk_entered"], r["left"]))
                w("| %s | %s | %d | %s | %s | %s | %s | %s | %s | %s |" % (
                    {"broken": "tutulmadı", "late": "geç tutuldu", "kept": "tutuldu"}[outc], owner, dist, ser.get(29), ser.get(40), mn,
                    "Risk" if r["risk_entered"] else "-", ("ayrıldı (hf %d)" % r["left"]) if r["left"] else "-", tr if tr is not None else "-", ser.get(100, "-")))
    J["M6"] = rows
    tb = {(o, ow, d): tr for (o, ow, d, tr, ri, lf) in rows}
    short = 100.0 * (1 - tb[("broken", "temsilci", 20)] / tb[("broken", "kurucu", 20)])
    w("")
    w("Tutulmayan sözün izi: kurucuda %s hafta, temsilcide %s hafta, temsilcide %%%.0f kısa (hedef >= %%20). Uzaklık 8: Risk ve ayrılma; uzaklık 20: Risk yok." % (
        tb[("broken", "kurucu", 20)], tb[("broken", "temsilci", 20)], short))


# ------------------------------------------------------------------ M8
def m8():
    base = C.get_world("full_run_fix_worst_7")
    w("### M8 Güncellenmeyen ürün (Karar 7: yaş yalnız iki vurgu alanına dokunan yayından sayılır)")
    w("")
    w("Hesap 12. haftada imzalar (3★ ürün hazır olduğu 60. haftada); ürün 30. ya da 20. haftada donar (hiçbir alana dokunulmaz), açık hata 3 (Çekirdek, vurgu 1, vurgu 2'de birer). "
      "Yaş terimi donmadan 26 / 52 / 104 hafta sonra; hedef 0 / -6 / -12, 52 haftada kayıp 0. Yenileme tutumu: yaş terimsiz / yaş terimli.")
    w("")
    w("| Donma haftası | Yıldız | Yaş (26 / 52 / 104 hf) | Memnuniyet (26 / 52 hf) | Ayrılma | 1. yenileme tutumu (yaşsız → yaşlı) |")
    w("|---|---|---|---|---|---|")
    rows = []
    for fz, stars in ((30, (1, 2)), (20, (1, 2)), (60, (1, 2, 3))):
        for star in stars:
            T = 210
            lv = {t: base["levels"][min(t, fz)] for t in range(1, T + 1)}
            live = {t: base["live"][min(t, fz)] for t in range(1, T + 1)}
            oa = {t: {"core": 1, "onboarding": 0, "integrations": 1, "trust": 1} for t in range(1, T + 1)}
            tch = {t: (base["touch"][t] if t <= fz else set()) for t in range(1, T + 1)}
            wd = {"T": T, "levels": lv, "live": live, "open_area": oa, "open_total": {t: 3 for t in range(1, T + 1)}, "touch": tch,
                  "phase": {t: 2 for t in range(1, T + 1)}, "reqs": {t: [] for t in range(1, T + 1)}}
            a = M.Acct("m8", (60 if star == 3 else 12), star, "logistics", 1000)
            c = M.cfg(clause_on=False)
            r = M.simulate(a, wd, c, gate=False, renewals=True, risk=True, T=T)
            # donmadan sonra 26/52/104. hafta
            def at(x, key):
                t = fz + x
                return r["parts"][t][key] if t in r["parts"] else None
            ages = [at(x, "age") for x in (26, 52, 104)]
            sat = [r["sat"].get(fz + x) for x in (26, 52)]
            # tutum yaşsız / yaşlı: 1. yenileme acilisi s+44 = 56
            t56 = a.sign + c["renew_open"]
            if t56 in r["parts"]:
                p = r["parts"][t56]
                tolv = r["tol"][t56]
                with_age = M.stance(r["sat"][t56] - tolv + c["ikna"])
                no_age = M.stance(r["sat"][t56] + p["age"] - tolv + c["ikna"])
                tut = "%s → %s" % (M.STANCE_NAME[no_age], M.STANCE_NAME[with_age])
            else:
                tut = "-"
            rows.append((fz, star, ages, sat, r["left"]))
            w("| %d | %d★ | %s | %s | %s | %s |" % (fz, star, " / ".join(str(x) for x in ages), " / ".join(str(x) for x in sat),
                                                  ("hf %d" % r["left"]) if r["left"] else "-", tut))
    J["M8"] = rows
    # bot kollarinda yas
    w("")
    w("Bot kollarında yaş (52. haftada hayatta olan, 20. haftadan önce imzalamış hesaplar). Hedef (PRD §4.3 Risk 1): yalnız Çekirdek'e yüklenen kolda yaş terimi "
      "<= -3 olan hesapların payı >= %50, dengeli kolda < %10. Sütunlar: hangi yayınlar sayacı sıfırlar (Karar 7: kademe + cila + düzeltme = hepsi).")
    w("")
    w("| Kol | sayaç sıfırlayan yayın | hayatta hesap (52. hf) | yaş <= -3 | pay | yaş <= -1 | pay | Sonuç |")
    w("|---|---|---|---|---|---|---|---|")
    kinds = [("kademe + cila + düzeltme (Karar 7)", None), ("kademe + cila", {"feat", "res"}), ("yalnız kademe", {"feat"})]
    for lab, nm in (("quality_core", "full_run_quality_core"), ("fix_worst", "full_run_fix_worst"), ("fix_due", "full_run_fix_due"),
                    ("quality_core masalı", "full_run_quality_core_desk"), ("fix_worst masalı", "full_run_fix_worst_desk")):
        for klab, kk in kinds:
            n = a3 = a1 = 0
            for s_ in SEEDS:
                res, accts, run, wd = C.run_accounts("%s_%d" % (nm, s_), M.cfg(touch_kinds=kk))
                for a in accts:
                    r = res[a.id]
                    if r["rejected"] or a.sign > 20:
                        continue
                    if 52 in r["parts"] and (r["left"] is None or r["left"] > 52):
                        n += 1
                        ag = r["parts"][52]["age"]
                        a3 += ag >= 3; a1 += ag >= 1
            ok = (pct(a3, n) >= 50) if "quality_core" in lab else (pct(a3, n) < 10)
            w("| %s | %s | %d | %d | %.1f%% | %d | %.1f%% | %s |" % (lab, klab, n, a3, pct(a3, n), a1, pct(a1, n), "geçti" if ok else "kaldı"))
            J.setdefault("M8_bot", {})["%s|%s" % (nm, klab)] = [n, a3, a1]


# ------------------------------------------------------------------ yenileme (M9, M13)
def renewal_tables():
    c = M.cfg()
    names = {}
    for arm in ARMS:
        names[arm] = [D.run_name(arm, s) for s in SEEDS]
    stats = {}
    for arm in ARMS:
        per = []
        for nm in names[arm]:
            res, accts, run, wd = C.run_accounts(nm, c)
            dec = []
            for a in accts:
                for rr in res[a.id]["renew"]:
                    if rr["t"] <= C.T_BOT:
                        dec.append(rr)
            per.append((nm, dec, res, accts))
        stats[arm] = per
    J["ren"] = {}
    w("### Yenileme sonuç dağılımı (Karar 8 ve 9 oranlarıyla; tohum 7 ve 11 birleşik)")
    w("")
    w("Her satır yenileme dönemi açılan hesap (imzadan 44 hafta sonra, <= 104. hafta). Tutum: Zamma açık / Aynı fiyat / İndirim ister / Ayrılmayı düşünüyor / Yenilemeyecek. "
      "Sonuç zarı: bütçe > başka ürüne geçiş > mali azalış > koltuk artışı (sıra varsayım). Politika: satışçı raporunun 1. seçeneği (tutumun en iyi fiyatı).")
    w("")
    w("| Kol | karar | yenileyen | Zamma açık | Aynı | İndirim | Ayrılmayı düşünüyor | Yenilemeyecek | koltuk artışı | mali azalış | başka ürüne geçiş | bütçe: küçülme | bütçe: ayrılma |")
    w("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for arm in ARMS:
        dec = [d for (_, dd, _, _) in stats[arm] for d in dd]
        n = len(dec)
        stn = [sum(1 for d in dec if d["stance"] == i) for i in range(5)]
        ren = sum(1 for d in dec if d["result"] == "renew")
        g = sum(1 for d in dec if d["outcome"] == "growth" and d["result"] == "renew")
        sh = sum(1 for d in dec if d["outcome"] == "shrink" and d["result"] == "renew")
        sw = sum(1 for d in dec if d["outcome"] == "switch")
        bs = sum(1 for d in dec if d["outcome"] == "budget" and d["result"] == "renew")
        bl = sum(1 for d in dec if d["outcome"] == "budget" and d["result"] == "leave")
        J["ren"][arm] = {"n": n, "stance": stn, "renew": ren, "growth": g, "shrink": sh, "switch": sw, "budget_shrink": bs, "budget_leave": bl}
        w("| %s | %d | %d (%.1f%%) | %s | %d | %d | %d | %d | %d | %d | %d | %d | %d |" % (
            C.LABEL[arm], n, ren, pct(ren, n), "%d (%.0f%%)" % (stn[0], pct(stn[0], n)), stn[1], stn[2], stn[3], stn[4], g, sh, sw, bs, bl))
    # M13
    w("")
    w("### M13 Yenileme kapısı (bakımlı kol = worst + due + off)")
    w("")
    w("Hedef: bakımlı üründe yenileyen >= %90; 104 haftalık B2B koşusunda (tohum 7 ve 11 ayrı) koltuk artışı da mali azalış da en az birer kez; her sonucun adlı nedeni var.")
    w("")
    w("| Koşu | karar | yenileyen | koltuk artışı | mali azalış | başka ürüne geçiş | bütçe küçülme | bütçe ayrılma | Zamma açık payı |")
    w("|---|---|---|---|---|---|---|---|---|")
    ok_all = True
    tot_n = tot_r = 0
    for arm in ("worst", "due", "off"):
        for (nm, dec, res, accts) in stats[arm]:
            n = len(dec); ren = sum(1 for d in dec if d["result"] == "renew")
            g = sum(1 for d in dec if d["outcome"] == "growth" and d["result"] == "renew")
            sh = sum(1 for d in dec if d["outcome"] == "shrink" and d["result"] == "renew")
            sw = sum(1 for d in dec if d["outcome"] == "switch")
            bs = sum(1 for d in dec if d["outcome"] == "budget" and d["result"] == "renew")
            bl = sum(1 for d in dec if d["outcome"] == "budget" and d["result"] == "leave")
            z = sum(1 for d in dec if d["stance"] == 0)
            tot_n += n; tot_r += ren
            if g < 1 or sh < 1:
                ok_all = False
            w("| %s | %d | %.1f%% | %d | %d | %d | %d | %d | %.0f%% |" % (nm.replace("full_run_", ""), n, pct(ren, n), g, sh, sw, bs, bl, pct(z, n)))
    J["M13"] = {"karar": tot_n, "yenileyen": tot_r, "pay": pct(tot_r, tot_n), "artis_azalis_hepsinde": ok_all}
    w("")
    w("Toplam: %d karar, yenileyen %.1f%% (hedef >= %%90: %s); koltuk artışı ve mali azalış her koşuda en az birer kez: %s." % (
        tot_n, pct(tot_r, tot_n), "geçti" if pct(tot_r, tot_n) >= 90 else "kaldı", "geçti" if ok_all else "kaldı"))
    # kagit
    w("")
    w("Kâğıt (Karar 8: yalnız satışçı yolunda en az bir hesap \"İndirim ister\" ya da kötüyse, kurucu yolunda Yenilemeyebilir etiketli hesap varsa; ayda en çok 1):")
    w("")
    w("| Kol | yenileme olan ay (4,35 hf) | kâğıtlı ay | kâğıtlı ay, ilk yenileme dahil |")
    w("|---|---|---|---|")
    for arm in ARMS:
        months = collections.defaultdict(list)
        for (nm, dec, res, accts) in stats[arm]:
            for d in dec:
                months[(nm, int(d["t"] / 4.35))].append(d)
        paper = sum(1 for k, v in months.items() if any(x["stance"] >= 2 for x in v))
        firsts = set()
        for (nm, dec, res, accts) in stats[arm]:
            if dec:
                firsts.add((nm, int(min(d["t"] for d in dec) / 4.35)))
        paper_first = sum(1 for k, v in months.items() if any(x["stance"] >= 2 for x in v) or k in firsts)
        w("| %s | %d | %d (%.0f%%) | %d (%.0f%%) |" % (C.LABEL[arm], len(months), paper, pct(paper, len(months)), paper_first, pct(paper_first, len(months))))
        J["ren"][arm]["months"] = [len(months), paper, paper_first]
    # cevapsiz kagit
    w("")
    w("Cevapsız kâğıt (2 hafta, herkese aynı fiyat; tutumun bir basamak üstü gönülsüz kabul -6, iki ve fazlası yenilemez):")
    w("")
    w("| Kol | karar | yenileyen (en iyi fiyat) | yenileyen (aynı fiyat) | gönülsüz yenileme | aynı fiyatta ayrılan |")
    w("|---|---|---|---|---|---|")
    for arm in ARMS:
        n = r1 = r2 = unw = lv = 0
        for nm in names[arm]:
            res1, accts, run, wd = C.run_accounts(nm, c)
            res2, _, _, _ = C.run_accounts(nm, c, policy="same")
            for a in accts:
                for rr in res1[a.id]["renew"]:
                    if rr["t"] <= C.T_BOT:
                        n += 1; r1 += rr["result"] == "renew"
                for rr in res2[a.id]["renew"]:
                    if rr["t"] <= C.T_BOT:
                        r2 += rr["result"] == "renew"
                        if rr["result"] == "renew" and rr["stance"] == 2:
                            unw += 1
                        if rr["result"] == "leave" and rr["why"] == "stance_same":
                            lv += 1
        w("| %s | %d | %.1f%% | %.1f%% | %d | %d |" % (C.LABEL[arm], n, pct(r1, n), pct(r2, n), unw, lv))
    # M9
    w("")
    w("### M9 Ürün dışı kayıp")
    w("")
    w("Hedef (öneri): bütçe kesintisi ve başka ürüne geçişle tam kayıp yılda hesapların <= %2,5'i; bütçe olaylarının >= %50'si küçülme. "
      "Birinci satır bot kollarından gözlenen karar havuzu (iki tohum); ikinci satır 330 hesaplık deftere ölçeklenmiş beklenen değer "
      "(yıldız karışımı ve \"memnun\" payı havuzdan, 1.000 deneme).")
    w("")
    w("| Havuz | karar | bütçe olayı | küçülme payı | başka ürüne geçiş | tam kayıp (bütçe ayrılma + geçiş) | tam kayıp / yıl-hesap | 330 hesap: tam kayıp / yıl | küçülme / yıl | Sonuç |")
    w("|---|---|---|---|---|---|---|---|---|---|")
    pools = {"bakımlı (worst+due+off)": ("worst", "due", "off"), "bakımsız (none)": ("none",)}
    rng = random.Random(9)
    for lab, arms in pools.items():
        dec = [d for a in arms for (_, dd, _, _) in stats[a] for d in dd]
        n = len(dec)
        bud = [d for d in dec if d["outcome"] == "budget"]
        shr = sum(1 for d in bud if d["result"] == "renew")
        sw = sum(1 for d in dec if d["outcome"] == "switch")
        bl = sum(1 for d in dec if d["outcome"] == "budget" and d["result"] == "leave")
        full = bl + sw
        # 330 hesap: her hesap yilda bir karar; havuzdan ornekle, olasiliklari hesapla (zar tekrar atilir)
        tl = tsh = 0.0
        runs = 1000
        for _ in range(runs):
            for _a in range(330):
                d = dec[rng.randrange(n)]
                star = d["star"]
                u = rng.random()
                pb = M.CFG["p_budget"][star]
                if u < pb:
                    if d["memnun"]:
                        tsh += 1
                    else:
                        tl += 1
                elif d["stance"] != 4 and u < pb + M.CFG["p_switch"][star]:
                    tl += 1
        tl /= runs; tsh /= runs
        ok = pct(full, n) <= 2.5 and (len(bud) == 0 or pct(shr, len(bud)) >= 50)
        w("| %s | %d | %d | %s | %d | %d | %.2f%% | %.2f (%.2f%%) | %.2f | %s |" % (lab, n, len(bud), ("%.0f%%" % pct(shr, len(bud))) if bud else "-", sw, full,
                                                                              pct(full, n), tl, 100 * tl / 330, tsh, "geçti" if ok else "kaldı"))
        J.setdefault("M9", {})[lab] = {"n": n, "bud": len(bud), "shrink": shr, "switch": sw, "full": full, "tl330": tl, "tsh330": tsh}


# ------------------------------------------------------------------ RAPOR_Q 2: satisci kapanis kaybi
def gate_at(world, day, star, sector, c):
    d = day
    while d > 0 and d not in world["levels"]:
        d -= 1
    u, bt, tot = M.sign_value(world, d, star, sector, c)
    tol = c["tol"](star, sector)
    base = tot
    if star >= 3 and c["clause_on"] and not c["provider_enterprise"] and c["gate_includes_clause"]:
        base = max(0.0, tot + c["st_clause"])
    return base >= tol + c["gate_over"], u, bt


def rep_attempts(name, base=D.K9):
    run = C.get_run(name, base)
    out = []
    for fid, f in run["fit"].items():
        if f["by"] == "rep":
            out.append({"day": f["day"], "star": f["star"], "sector": f["sector"], "u": f["u"], "loss": f["loss"], "lost": False})
    for r in run["reploss"]:
        out.append({"day": r["day"], "star": r["star"], "sector": r["sector"], "u": r["u"], "loss": r["loss"], "lost": True})
    return out


def exp_loss(att, world, c, floor, use_gate=True):
    """Ex-ante beklenen kayip: kapidan dusen = kesin kayip; gecen = 1 - p, p = max(egri(U), taban) ya da loss_area bossa 1."""
    gl = 0; dl = 0.0
    for a in att:
        ok = True
        if use_gate:
            ok, _, _ = gate_at(world, a["day"], a["star"], a["sector"], c)
        if not ok:
            gl += 1; continue
        loss = "" if a["loss"] == "-" else a["loss"]
        p = M.close_chance(a["u"], loss)
        if loss != "":
            p = max(p, floor)
        dl += 1.0 - p
    n = len(att)
    return gl, dl, n


def reploss():
    w("### RAPOR_Q §1 madde 2 (❌2): satışçı kapanış kaybı oranı")
    w("")
    w("Q kapısı: masalı `fix_worst` kolunda satışçı kapanışlarının %5-15'i kaybedilir (2★+3★ sütunundan okunur); masalı `quality_core` kolunda >= %20. "
      "Kapanış = `PROBE FIT by=rep` (imzalanan) + `PROBE REPLOSS` (zarla kaybedilen). Beklenen kayıp (ex-ante): C kapısından düşen aday = kesin kayıp (zarsız); "
      "geçen aday için kayıp ihtimali 1 - p, p = `CLOSE_CURVE(U)` (kapıda loss_area boşsa 1) ve C ile birlikte p >= zar tabanı. Gerçekleşen REPLOSS yalnız Q'nun zarıdır.")
    w("")
    c = M.cfg()
    data = {}
    for kol in ("full_run_fix_worst_desk", "full_run_quality_core_desk"):
        att, worlds = [], []
        for s in SEEDS:
            nm = "%s_%d" % (kol, s)
            wd = C.get_world(nm)
            for a in rep_attempts(nm):
                a["w"] = wd
                att.append(a)
        data[kol] = att
    w("| Kol | Küme | kapanış | gerçekleşen REPLOSS (Q zarı) | Q zarı ex-ante | yalnız C kapısı | C kapısı + zar (taban 0,60) | C kapısı + Q zarı (taban yok) | Q kapısı |")
    w("|---|---|---|---|---|---|---|---|---|")
    J["Q2"] = {}
    def calc(att, floor, use_gate):
        gl = dl = 0.0
        for a in att:
            ok = True
            if use_gate:
                ok, _, _ = gate_at(a["w"], a["day"], a["star"], a["sector"], c)
            if not ok:
                gl += 1; continue
            loss = "" if a["loss"] == "-" else a["loss"]
            p = M.close_chance(a["u"], loss)
            if loss != "":
                p = max(p, floor)
            dl += 1.0 - p
        return gl, dl
    for kol, att in data.items():
        for lab, sel in (("bütün", att), ("2★+3★", [a for a in att if a["star"] >= 2])):
            n = len(sel)
            real = sum(1 for a in sel if a["lost"])
            _, d0 = calc(sel, 0.0, False)
            g1, _ = calc(sel, 1.0, True)
            g2, d2 = calc(sel, 0.60, True)
            g3, d3 = calc(sel, 0.0, True)
            J["Q2"]["%s|%s" % (kol, lab)] = {"n": n, "real": real, "q_dice": d0, "gate": g1, "gate_floor60": g2 + d2, "gate_qcurve": g3 + d3}
            tgt = "%5-15" if "fix_worst" in kol else ">= %20"
            w("| %s | %s | %d | %d (%.1f%%) | %.1f (%.1f%%) | %d (%.1f%%) | %.1f (%.1f%%) | %.1f (%.1f%%) | %s |" % (
                kol.replace("full_run_", ""), lab, n, real, pct(real, n), d0, pct(d0, n), g1, pct(g1, n), g2 + d2, pct(g2 + d2, n), g3 + d3, pct(g3 + d3, n), tgt))
    w("")
    w("Zarın erişebileceği tavan: kapanışın yalnız müşterinin baktığı bir alan eksikken (loss_area dolu) zar atılır. Bu paylar bir zar eğrisinin ulaşabileceği en çok kayıp oranının üst sınırıdır.")
    w("")
    w("| Kol | CORE_2 | kapanış | loss_area dolu | pay | 2★+3★ kapanış | loss_area dolu | pay |")
    w("|---|---|---|---|---|---|---|---|")
    for lab, base in (("1,25", D.K9), ("1,5", D.K9_15)):
        for kol in ("full_run_fix_worst_desk", "full_run_quality_core_desk"):
            att = []
            for s_ in SEEDS:
                att += rep_attempts("%s_%d" % (kol, s_), base)
            a2 = [a for a in att if a["star"] >= 2]
            f = lambda x: sum(1 for a in x if a["loss"] != "-")
            w("| %s | %s | %d | %d | %.1f%% | %d | %d | %.1f%% |" % (kol.replace("full_run_", ""), lab, len(att), f(att), pct(f(att), len(att)), len(a2), f(a2), pct(f(a2), len(a2))))
            J.setdefault("Q2_weak", {})["%s|%s" % (kol, lab)] = [len(att), f(att), len(a2), f(a2)]
    # oneri taramasi
    w("")
    w("Öneri taraması (masalı `fix_worst`, 2★+3★ ve bütün; beklenen kayıp %): kapı payı (eşik + x) ve zar tabanı. Kırmızı çizgi: hedef %5-15.")
    w("")
    w("| kapı payı x | zar tabanı | fix_worst bütün | fix_worst 2★+3★ | quality_core 2★+3★ (>= %20) |")
    w("|---|---|---|---|---|")
    fw = data["full_run_fix_worst_desk"]; qc = data["full_run_quality_core_desk"]
    for x in (10, 12, 15, 20):
        for fl in (0.60, 0.45, 0.30, 0.0):
            cc = M.cfg(gate_over=x)
            def calc2(att, floor):
                tot = 0.0
                for a in att:
                    ok, _, _ = gate_at(a["w"], a["day"], a["star"], a["sector"], cc)
                    if not ok:
                        tot += 1; continue
                    loss = "" if a["loss"] == "-" else a["loss"]
                    p = M.close_chance(a["u"], loss)
                    if loss != "":
                        p = max(p, floor)
                    tot += 1 - p
                return tot
            a_all = calc2(fw, fl); a23 = calc2([a for a in fw if a["star"] >= 2], fl); q23 = calc2([a for a in qc if a["star"] >= 2], fl)
            n23 = len([a for a in fw if a["star"] >= 2]); nq = len([a for a in qc if a["star"] >= 2])
            w("| %d | %.2f | %.1f%% | %.1f%% (n=%d) | %.1f%% (n=%d) |" % (x, fl, pct(a_all, len(fw)), pct(a23, n23), n23, pct(q23, nq), nq))


def weak_sens():
    w("### Zar için gereken beklenti (❌2'nin tavan sorusu)")
    w("")
    w("Sabit dünya: masalı `fix_worst` (910ad1f) kapanışlarının ürünü; yalnız 2★ beklentisi değiştirilir (`CORE_2`, `EMPHASIS_2`). Satır: kapanışların kaçında baktığı alan eksik (zar atılır) ve "
      "C kapısı + zar (taban 0,60) ile beklenen kayıp. Hedef %5-15 (bütün kapanışlar; 2★+3★ sütunu n küçük).")
    w("")
    w("| CORE_2 | EMPHASIS_2 | kapanış | alan eksik | C kapısı + zar kaybı (bütün) | 2★+3★ kapanış | alan eksik | kayıp (2★+3★) |")
    w("|---|---|---|---|---|---|---|---|")
    att = []
    for s_ in SEEDS:
        nm = "full_run_fix_worst_desk_%d" % s_
        wd = C.get_world(nm); run = C.get_run(nm)
        for a in rep_attempts(nm):
            ar = run["areas"].get(a["day"]) or run["areas"].get(a["day"] - 1)
            a["lv"] = {k: ar[k][0] for k in D.AREAS if k in ar}; a["la"] = {k: ar[k][2] for k in D.AREAS if k in ar}; a["w"] = wd
            att.append(a)
    old_e2 = M.EMPHASIS_2
    for core2 in (1.25, 1.5, 1.75, 2.0):
        for e2 in (1.0, 1.5):
            M.EMPHASIS_2 = e2
            cc = M.cfg(core2=core2)
            def ev(sel):
                weak = 0; loss = 0.0
                for a in sel:
                    ref = M.ref_for(a["star"], a["sector"], core2, launches=a["la"], rivals=True)
                    f = M.fit(a["lv"], ref, a["sector"])
                    ok, _, _ = gate_at(a["w"], a["day"], a["star"], a["sector"], cc)
                    if not ok:
                        loss += 1; weak += 1; continue
                    la = f["loss_area"]
                    if la != "":
                        weak += 1
                        loss += 1 - max(M.close_chance(f["value"], la), cc["floor"])
                return weak, loss
            wk, ls = ev(att)
            a2 = [a for a in att if a["star"] >= 2]
            wk2, ls2 = ev(a2)
            w("| %.2f | %.1f | %d | %d | %.1f%% | %d | %d | %.1f%% |" % (core2, e2, len(att), wk, pct(ls, len(att)), len(a2), wk2, pct(ls2, len(a2))))
    M.EMPHASIS_2 = old_e2


def core2_panel():
    w("### CORE_2 karşılaştırması: 1,25 (bugün, 910ad1f) ve 1,5 (bd9a5ed kayıtları)")
    w("")
    w("Aynı C modeli iki kayıt kümesinde (her biri kendi bot ürün hızıyla). Gate satırları: M3-M5 geç kayıp (tohum 7 / 11), M10, M13.")
    w("")
    w("| Kapı | CORE_2 1,25 | CORE_2 1,5 |")
    w("|---|---|---|")
    out = {}
    for lab, base, core2 in (("1,25", D.K9, 1.25), ("1,5", D.K9_15, 1.5)):
        c = M.cfg(core2=core2)
        late = {}; q = {}
        for arm in ARMS:
            late[arm] = []
            kp = 0; qn = 0
            for s_ in SEEDS:
                res, accts, run, wd = C.run_accounts(D.run_name(arm, s_), c, base=base)
                late[arm].append(C.loss_stats(res, accts)["late_pct"])
                kp += sum(1 for a in accts if 7 <= a.sign <= 33 and not res[a.id]["rejected"])
                qn += sum(1 for x in D.load(D.run_name(arm, s_), D.Q0B)["sign"] if 7 <= x["day"] <= 33)
            q[arm] = pct(kp, qn)
        m3 = all(late["due"][i] <= late["off"][i] + 2 for i in range(2))
        m4 = all(late["worst"][i] <= late["off"][i] + 3 for i in range(2))
        m5 = all(late["none"][i] >= 10 and late["none"][i] >= 2 * late["off"][i] for i in range(2))
        # M13 yenileyen
        n = r_ = g = sh = 0
        for arm in ("worst", "due", "off"):
            for s_ in SEEDS:
                res, accts, run, wd = C.run_accounts(D.run_name(arm, s_), c, base=base)
                for a in accts:
                    for rr in res[a.id]["renew"]:
                        if rr["t"] <= 104:
                            n += 1; r_ += rr["result"] == "renew"
        out[lab] = (late, q, m3, m4, m5, pct(r_, n), n)
    J["core2"] = {k: [v[0], v[1], v[2], v[3], v[4], v[5], v[6]] for k, v in out.items()}
    A, B = out["1,25"], out["1,5"]
    w("| M3 (due geç <= off + 2) | %s | %s |" % ("geçti" if A[2] else "kaldı", "geçti" if B[2] else "kaldı"))
    w("| M4 (worst) | %s | %s |" % ("geçti" if A[3] else "kaldı", "geçti" if B[3] else "kaldı"))
    w("| M5 (none geç kayıp %%, tohum 7 / 11) | %s (%s) | %s (%s) |" % ("geçti" if A[4] else "kaldı", " / ".join("%.1f" % x for x in A[0]["none"]), "geçti" if B[4] else "kaldı", " / ".join("%.1f" % x for x in B[0]["none"])))
    w("| M10 imza ÷ eski kod (worst / none / due / off) | %s | %s |" % (" / ".join("%.1f%%" % A[1][a] for a in ("worst", "none", "due", "off")), " / ".join("%.1f%%" % B[1][a] for a in ("worst", "none", "due", "off"))))
    w("| M13 bakımlı yenileyen | %.1f%% (%d karar) | %.1f%% (%d karar) |" % (A[5], A[6], B[5], B[6]))


# ------------------------------------------------------------------ M10 duyarlilik
def m10_sens():
    w("### M10 duyarlılık (imza ÷ eski kod, MVP sonrası 26 hafta)")
    w("")
    w("Erdem'in hedefi %55-65. Satır: kapının hangi biçimi. Tohum 7 ve 11 birleşik, kol `fix_worst` (ve parantezde `fix_none`, `fix_due`, `fix_off`).")
    w("")
    w("| Kapı biçimi | worst | none | due | off | Sonuç (worst) |")
    w("|---|---|---|---|---|---|")
    q0b = {}
    for arm in ARMS:
        q0b[arm] = sum(sum(1 for x in D.load(D.run_name(arm, s), D.Q0B)["sign"] if 7 <= x["day"] <= 33) for s in SEEDS)
    variants = [("Kapı yok (K9 olduğu gibi)", dict(), False),
                ("C kapısı: U - hata >= eşik + 10 (Karar 6)", dict(), True),
                ("kapı adayın U'sunu okur (rakip penceresi dahil), pay 10", dict(gate_rivals=True), True),
                ("pay 5", dict(gate_over=5), True),
                ("pay 0 (eşiğin altına inmesin)", dict(gate_over=0), True),
                ("kapı hata terimini okumaz, yalnız U >= eşik + 10", dict(bug_k=0.0), True),
                ("eşik v3 (30 / 33 / 36), pay 10", dict(tol=M.tol_v3), True),
                ("eşik v3, pay 10, hata tavanı 60", dict(tol=M.tol_v3), True)]
    for lab, kw, gate in variants[:-1]:
        c = M.cfg(**kw)
        row = []
        for arm in ARMS:
            kp = 0
            for s in SEEDS:
                res, accts, run, wd = C.run_accounts(D.run_name(arm, s), c, gate=gate)
                kp += sum(1 for a in accts if 7 <= a.sign <= 33 and not res[a.id]["rejected"])
            row.append(pct(kp, q0b[arm]))
        ok = 55 <= row[1] <= 65
        w("| %s | %.1f%% | %.1f%% | %.1f%% | %.1f%% | %s |" % (lab, row[1], row[0], row[2], row[3], "geçti" if ok else ("altında" if row[1] < 55 else "üstünde")))
        J.setdefault("M10s", {})[lab] = row


def main():
    m6(); w(); m8(); w(); renewal_tables(); w(); reploss(); w(); weak_sens(); w(); m10_sens(); w(); core2_panel()
    open(os.path.join(C.OUT, "c0s_b.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    json.dump(J, open(os.path.join(C.OUT, "c0s_b.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print("\n".join(L))


if __name__ == "__main__":
    main()
