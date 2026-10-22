"""C0s bolum A: M1, M2, M3-M5 (hata tavani 60/62/64), M10 ve RAPOR_Q 1. madde (CORE_2 1,25 ve 1,5). python -I.
Cikti: out/c0s_a.json, out/c0s_a.md"""
import sys, os, json, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_core as C, c0s_data as D, c0s_model as M

ARMS = D.ARMS
SEEDS = D.SEEDS
J = {}
L = []


def w(s=""):
    L.append(s)


def frozen(world, t0, T=None):
    T = T or t0 + 12
    return {"T": T, "levels": {t: world["levels"][t0] for t in range(1, T + 1)}, "live": {t: world["live"][t0] for t in range(1, T + 1)},
            "open_area": {t: world["open_area"][t0] for t in range(1, T + 1)}, "open_total": {t: world["open_total"][t0] for t in range(1, T + 1)},
            "touch": {t: set() for t in range(1, T + 1)}, "phase": {t: world["phase"][t0] for t in range(1, T + 1)},
            "reqs": {t: [] for t in range(1, T + 1)}}


# ------------------------------------------------------------------ M1
def m1():
    names = [D.run_name(a, s) for a in ARMS for s in SEEDS] + ["full_run_fix_worst_desk_7", "full_run_fix_worst_desk_11",
                                                              "full_run_quality_core_7", "full_run_quality_core_11"]
    c = M.cfg()
    tot_w = drop = unn = 0
    for n in names:
        res, accts, run, wd = C.run_accounts(n, c)
        for r in res.values():
            if r["rejected"]:
                continue
            tot_w += len(r["sat"]); drop += r["drop_weeks"]; unn += r["unnamed"]
    J["M1"] = {"hesap_haftasi": tot_w, "dusus_haftasi": drop, "nedensiz": unn, "kosu": len(names)}
    w("### M1 Nedensiz düşüş")
    w("")
    w("| Kapsam | hesap-haftası | düşüş haftası (hepsi adlı) | nedensiz | Sonuç |")
    w("|---|---|---|---|---|")
    w("| %d koşu (8 düzeltme kolu + masalı fix_worst + quality_core, tohum 7 ve 11) | %d | %d | %d | %s |" % (
        len(names), tot_w, drop, unn, "geçti" if unn == 0 else "kaldı"))


# ------------------------------------------------------------------ M2
def m2():
    c = M.cfg()
    rows = []
    for n in ("full_run_fix_worst_7", "full_run_fix_worst_11"):
        wd = C.get_world(n)
        for t0 in range(7, 101):
            fw = frozen(wd, t0)
            for star in (1, 2, 3):
                for sector in M.SECTORS:
                    a = M.Acct("m2", t0, star, sector, 1000)
                    r = M.simulate(a, fw, c, gate=True, renewals=False, risk=False)
                    if r["rejected"]:
                        rows.append((t0, star, True, None, None)); continue
                    ser = r["sat"]; s0 = ser[t0]
                    rows.append((t0, star, False, min(ser.values()) - s0, s0 - r["tol"][t0]))
    J["M2"] = {}
    w("### M2 İlk 12 hafta (ürün ve hata sabit, olay yok)")
    w("")
    w("`fix_worst` dünyasının her haftası (7-100) donduruldu, 3 yıldız x 13 sektör, iki tohum. 3★ satırında Kurumsal madde (-10, Karar 4) açıktır ve kapı toplamı okur.")
    w("")
    w("| Yıldız | aday | kapı reddi | imzalayan | imza değerinin altına inen | imzada en küçük (memnuniyet - eşik) | Sonuç |")
    w("|---|---|---|---|---|---|---|")
    for star in (1, 2, 3, 0):
        sel = [x for x in rows if (star == 0 or x[1] == star)]
        ok = [x for x in sel if not x[2]]
        rej = len(sel) - len(ok)
        below = sum(1 for x in ok if x[3] < 0)
        mm = min((x[4] for x in ok), default=None)
        J["M2"][str(star)] = {"aday": len(sel), "red": rej, "imza": len(ok), "alti": below, "min_pay": mm}
        w("| %s | %d | %d (%.1f%%) | %d | %d | %s | %s |" % ("hepsi" if star == 0 else "%d★" % star, len(sel), rej, pct(rej, len(sel)), len(ok), below,
                                                              mm, "geçti" if below == 0 and (mm is None or mm >= 10) else "kaldı"))


def pct(a, b):
    return 100.0 * a / b if b else float("nan")


# ------------------------------------------------------------------ M3-M5
def m345():
    out = {}
    rows = []
    for cap in (60, 62, 64):
        c = M.cfg(bug_cap=float(cap))
        per = {}
        for arm in ARMS:
            per[arm] = {}
            for s in SEEDS:
                res, accts, run, wd = C.run_accounts(D.run_name(arm, s), c)
                per[arm][s] = C.loss_stats(res, accts)
                per[arm][s]["rej"] = sum(1 for r in res.values() if r["rejected"])
                per[arm][s]["sign"] = len(accts)
        out[cap] = per
    J["M345"] = {str(k): v for k, v in out.items()}
    w("### M3, M4, M5 Kayıp (A'nın tanımı: erken = v1.0'dan sonra 20 hafta, geç = sonrası)")
    w("")
    w("Hata terimi tavanı 60 (hükmün sayısı), 62 ve 64. Her hücre: tohum 7 / tohum 11, kayıp % (adet). Kapı reddi: imza kapısının geri çevirdiği aday (kayıp sayılmaz).")
    w("")
    w("| Tavan | Kol | Erken kayıp | Geç kayıp | Toplam kayıp | İmza (kapı reddi) |")
    w("|---|---|---|---|---|---|")
    for cap in (60, 62, 64):
        for arm in ARMS:
            p = out[cap][arm]
            w("| %d | %s | %s | %s | %s | %s |" % (cap, C.LABEL[arm],
                " / ".join("%.1f (%d)" % (p[s]["early_pct"], p[s]["early"]) for s in SEEDS),
                " / ".join("%.1f (%d)" % (p[s]["late_pct"], p[s]["late"]) for s in SEEDS),
                " / ".join("%.1f (%d)" % (p[s]["total_pct"], p[s]["total"]) for s in SEEDS),
                " / ".join("%d (%d)" % (p[s]["sign"] - p[s]["rej"], p[s]["rej"]) for s in SEEDS)))
    w("")
    w("| Tavan | M3 `fix_due` geç <= off + 2 | M4 `fix_worst` geç <= off + 3 ve toplam <= off + 10 | M5 `fix_none` geç >= %10 ve >= 2 x off |")
    w("|---|---|---|---|")
    for cap in (60, 62, 64):
        o = out[cap]
        def late(arm, s): return o[arm][s]["late_pct"]
        def tot(arm, s): return o[arm][s]["total_pct"]
        m3 = all(late("due", s) <= late("off", s) + 2 for s in SEEDS)
        m4 = all(late("worst", s) <= late("off", s) + 3 and tot("worst", s) <= tot("off", s) + 10 for s in SEEDS)
        m5 = all(late("none", s) >= 10 and late("none", s) >= 2 * late("off", s) for s in SEEDS)
        J["M345"][str(cap)]["gate"] = {"M3": m3, "M4": m4, "M5": m5}
        w("| %d | %s | %s | %s (none geç: %s) |" % (cap, "geçti" if m3 else "kaldı", "geçti" if m4 else "kaldı", "geçti" if m5 else "kaldı",
                                               " / ".join("%.1f" % late("none", s) for s in SEEDS)))


# ------------------------------------------------------------------ M10, RAPOR_Q 1
def gate_pass_tables():
    """K9 imzalari uzerinde C kapisi: kapidan gecen pay. Pencere: MVP sonrasi 26 hafta (hf 7-33)."""
    c = M.cfg()
    rows = []
    q0b_counts = {}
    for arm in ARMS:
        for s in SEEDS:
            q = D.load(D.run_name(arm, s), D.Q0B)
            q0b_counts[(arm, s)] = sum(1 for x in q["sign"] if 7 <= x["day"] <= 33)
    w("### M10 İmza kapısı (MVP sonrası 26 hafta, hf 7-33)")
    w("")
    w("K9 (910ad1f) imzaları, C kapısından geçirildi: imza değeri = U - hata terimi >= eşik + 10. Dönen aday sonradan imzalayabilir: oran alt sınırdır. "
      "\"Eski kod\" = Q0b taban kolu (`q_calisma/q0b_logs`) aynı penceredeki imza sayısı; Erdem'in hedefi MVP sonrası imza düşüşü eski kodun %55-65'i (E1).")
    w("")
    w("| Kol | K9 imza | kapıdan dönen | kapıdan geçen | C ile imza ÷ eski kod | K9 (kapısız) ÷ eski kod | Sonuç (%55-65) |")
    w("|---|---|---|---|---|---|---|")
    tab = {}
    for arm in ARMS:
        kn = kp = qn = 0
        for s in SEEDS:
            res, accts, run, wd = C.run_accounts(D.run_name(arm, s), c)
            for a in accts:
                if 7 <= a.sign <= 33:
                    kn += 1
                    if not res[a.id]["rejected"]:
                        kp += 1
            qn += q0b_counts[(arm, s)]
        tab[arm] = (kn, kp, qn)
        r_c = pct(kp, qn); r_k = pct(kn, qn)
        w("| %s | %d | %d | %d (%.1f%%) | %.1f%% | %.1f%% | %s |" % (C.LABEL[arm], kn, kn - kp, kp, pct(kp, kn), r_c, r_k,
                                                                   "geçti" if 55 <= r_c <= 65 else ("altında" if r_c < 55 else "üstünde")))
    J["M10"] = {k: list(v) for k, v in tab.items()}
    # masali kollar ve quality_core
    w("")
    w("| Kol (bilgi) | K9 imza | kapıdan geçen | geçen pay |")
    w("|---|---|---|---|")
    for n in ("full_run_fix_worst_desk", "full_run_quality_core", "full_run_quality_core_desk"):
        kn = kp = 0
        for s in SEEDS:
            res, accts, run, wd = C.run_accounts("%s_%d" % (n, s), c)
            for a in accts:
                if 7 <= a.sign <= 33:
                    kn += 1
                    if not res[a.id]["rejected"]:
                        kp += 1
        w("| %s | %d | %d | %.1f%% |" % (n, kn, kp, pct(kp, kn)))
    # kapi reddinin dagilimi
    w("")
    w("Kapı reddinin dağılımı (`fix_worst`, iki tohum, bütün 104 hafta): yıldıza göre ve reddin nedeniyle (U mu, hata terimi mi).")
    w("")
    w("| Yıldız | imza | kapıdan dönen | dönen pay | U < eşik + 10 (hata terimi 0 olsa da döner) | yalnız hata terimi yüzünden döner |")
    w("|---|---|---|---|---|---|")
    for star in (1, 2, 3):
        n = rej = u_only = bug_only = 0
        for s in SEEDS:
            res, accts, run, wd = C.run_accounts(D.run_name("worst", s), c)
            for a in accts:
                if a.star != star:
                    continue
                n += 1
                r = res[a.id]
                if r["rejected"]:
                    rej += 1
                    tol = c["tol"](a.star, a.sector)
                    if r["U0"] < tol + 10:
                        u_only += 1
                    else:
                        bug_only += 1
        w("| %d★ | %d | %d | %.1f%% | %d | %d |" % (star, n, rej, pct(rej, n), u_only, bug_only))


def raporq1():
    """RAPOR_Q §1 madde 1: 2★+3★ imzalarda U = 100 payi, CORE_2 1,25 (bugun) ve 1,5; C'nin kapisiyla."""
    w("### RAPOR_Q §1 madde 1 (❌1): 2★+3★ imzalarda U = 100 payı, `CORE_2` 1,25 ve 1,5")
    w("")
    w("Hedef (Q kapısı): `fix_worst` 2★+3★ imzalarında U = 100 payı en çok %25; Traction (evre 2) 2★+3★ imza U ortancası 70-85. "
      "Her satır kendi bot kayıtlarından: 1,25 = `910ad1f` (k9_trim), 1,5 = `bd9a5ed` (k9_trim_15). U, oyunun `PROBE FIT u=` değeridir (imza anında); "
      "\"C kapısıyla\" = kapıdan geçen imzalar (U - hata terimi >= eşik + 10) üzerinde pay.")
    w("")
    w("| CORE_2 | Kol | 2★+3★ imza | U = 100 | pay (kapısız, Q'nun ölçümü) | kapıdan geçen 2★+3★ | U = 100 / geçen (C kapısıyla) | Traction ortanca U (kapısız → C kapısıyla) |")
    w("|---|---|---|---|---|---|---|---|")
    c = M.cfg()
    out = {}
    for lab, base, core2 in (("1,25", D.K9, 1.25), ("1,5", D.K9_15, 1.5)):
        cc = M.cfg(core2=core2)
        for arm in ("worst", "none", "due"):
            n23 = n100 = npass = n100p = 0
            tr_all, tr_pass = [], []
            for s in SEEDS:
                nm = D.run_name(arm, s)
                res, accts, run, wd = C.run_accounts(nm, cc, base=base)
                for a in accts:
                    if a.star < 2:
                        continue
                    fr = run["fit"].get(a.id)
                    u = fr["u"] if fr else res[a.id].get("U0")
                    n23 += 1
                    ok = not res[a.id]["rejected"]
                    if u == 100:
                        n100 += 1
                    if ok:
                        npass += 1
                        if u == 100:
                            n100p += 1
                    if run["state"].get(a.sign, {}).get("phase", 1) == 2 or (a.sign in run["state"] and int(run["state"][a.sign]["phase"]) == 2):
                        tr_all.append(u)
                        if ok:
                            tr_pass.append(u)
            out[(lab, arm)] = (n23, n100, npass, n100p, st.median(tr_all) if tr_all else None, st.median(tr_pass) if tr_pass else None)
            w("| %s | %s | %d | %d | %.1f%% | %d | %.1f%% | %s → %s |" % (lab, C.LABEL[arm], n23, n100, pct(n100, n23), npass, pct(n100p, npass),
                                                                      fmt(out[(lab, arm)][4], 0), fmt(out[(lab, arm)][5], 0)))
    J["Q1"] = {"%s|%s" % k: list(v) for k, v in out.items()}


def fmt(x, d=1):
    return "-" if x is None or x != x else ("%.*f" % (d, x))


def main():
    m1(); w(); m2(); w(); m345(); w(); gate_pass_tables(); w(); raporq1()
    open(os.path.join(C.OUT, "c0s_a.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    json.dump(J, open(os.path.join(C.OUT, "c0s_a.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print("\n".join(L))


if __name__ == "__main__":
    main()
