"""C0s bolum E: ekonomi kapilarinda tutmayanlar icin olculu oneri taramalari (sabit degistirilip gecti yazilmaz). python -I.
Cikti: out/c0s_e.md, c0s_e.json"""
import sys, os, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_econ as E, c0s_core as C, c0s_data as D, c0s_model as M

L = []
J = {}
w = L.append
T = E.T
pct = E.pct


def net3(run, e, which="new", excl_one=False):
    p3 = [t for t in range(1, T + 1) if E.state(run, t, "phase", 1) == 3]
    if not p3:
        return None
    exp = e["exp_new"] if which == "new" else e["exp_old"]
    s = 0.0
    for t in p3:
        x = exp[t]
        if excl_one:
            x -= e["ser"]["one"][t]
        s += e["inc"][t] - x
    return s / len(p3) * E.Q


def main():
    c = M.cfg()
    names = [D.run_name("worst", s) for s in D.SEEDS]
    # ------------------------------------------------ evre 3 referansi
    w("### Evre 3 aylık net: hangi \"bugün\"")
    w("")
    w("Kapı: evre 3 aylık net <= 2 x bugün. Üç referans: Q0b (eski kod tabanı, `q0b_logs`), K9 (910ad1f, bugünkü kod) ve K9'un tekrarlayan neti (tek seferlik giderler hariç). "
      "K9 `fix_worst`'te evre 3 yalnız 6-16 haftadır ve içinde 48.000 ile 30.000 dolarlık tek seferlik gider (88-101. hf) vardır; bu yüzden K9'un evre 3 neti bugünkü ekonomiyi eksik temsil eder.")
    w("")
    w("| Koşu | evre 3 hafta (K9) | Q0b evre 3 net | K9 evre 3 net | K9 tekrarlayan net | yeni (etkisiz) | yeni tekrarlayan | yeni ÷ Q0b | yeni ÷ K9 | yeni tekrarlayan ÷ K9 tekrarlayan |")
    w("|---|---|---|---|---|---|---|---|---|---|")
    for n in names:
        run = C.get_run(n)
        e = E.econ(run, "b2b", "auto")
        e0 = E.econ(run, "b2b", "recorded", sal_mult=1.0)
        q = D.load(n, D.Q0B)
        eq = E.econ(q, "b2b", "recorded", sal_mult=1.0)
        nq = net3(q, eq, "old"); nk = net3(run, e0, "old"); nkr = net3(run, e0, "old", True)
        nn = net3(run, e, "new"); nnr = net3(run, e, "new", True)
        p3w = sum(1 for t in range(1, T + 1) if E.state(run, t, "phase", 1) == 3)
        w("| %s | %d | %.0fK | %.0fK | %.0fK | %.0fK | %.0fK | x%.2f | x%.2f | x%.2f |" % (n.replace("full_run_", ""), p3w, nq / 1000, nk / 1000, nkr / 1000, nn / 1000, nnr / 1000, nn / nq, nn / nk, nnr / nkr))
        J[n] = [nq, nk, nkr, nn, nnr]
    # ------------------------------------------------ fiyat taramasi (M12)
    w("")
    w("### M12 öneri taraması: Standart birim fiyatı (kapasite politikası oyuncunun)")
    w("")
    w("Hedef: Standart'ta 26-104. hafta sunucu payı %8-12. Fiyat = Standart birim (B2B 50 koltuk, B2C 1.000 kullanıcı); Ekonomik yarısı, Kurumsal iki katı. Hücre: B2B `fix_worst` iki tohum ortalaması; B2C `fix_worst`.")
    w("")
    w("| Pazar | Standart fiyat | lean (pay %5) | auto (80 → 65) | wide (pay %40) | auto Ekonomik | auto Kurumsal | Sonuç (auto ve wide %8-12) |")
    w("|---|---|---|---|---|---|---|---|")
    for mk, prices in (("b2b", (120, 135, 150, 165)), ("b2c", (250, 300, 350, 400))):
        for pr in prices:
            old = dict(E.NEW_UNIT)
            E.NEW_UNIT[mk] = pr
            row = {}
            for pol, tier in (("lean", "std"), ("auto", "std"), ("wide", "std"), ("auto", "eko"), ("auto", "kur")):
                vals = []
                for s in D.SEEDS:
                    n = D.run_name("worst", s, mk == "b2c")
                    run = C.get_run(n)
                    e = E.econ(run, mk, pol, tier=tier)
                    sv = sum(e["servers"][t] for t in range(26, T + 1)); inc = sum(e["inc"][t] for t in range(26, T + 1))
                    vals.append(pct(sv, inc))
                row[(pol, tier)] = sum(vals) / len(vals)
            E.NEW_UNIT.update(old)
            a, wd = row[("auto", "std")], row[("wide", "std")]
            w("| %s | $%d | %.1f%% | %.1f%% | %.1f%% | %.1f%% | %.1f%% | %s |" % (mk, pr, row[("lean", "std")], a, wd, row[("auto", "eko")], row[("auto", "kur")],
                                                                              "geçti" if 8 <= a <= 12 and 8 <= wd <= 12 else ("auto ve lean altında" if a < 8 else "geçti (auto)" if 8 <= a <= 12 else "üstünde")))
            J.setdefault("price", {})["%s|%d" % (mk, pr)] = {"%s_%s" % k: v for k, v in row.items()}
    # ------------------------------------------------ kira x maas taramasi
    w("")
    w("### Bootstrap runway ve ilk 40 hafta öneri taraması: İş hanı kirası x maaş bandı çarpanı")
    w("")
    w("K9 `fix_worst` botunun kendi ilk işe alım haftasında (hf 15, çek sonrası) runway = kasa ÷ (kira + maaş + sunucu); ilk 40 haftada en derin kümülatif açık (etkisiz gelir; ekonomi tahmini). "
      "Hedef runway >= 6,7 ay; açık 25-45K ve hf > 30. Hücre: tohum 7 / tohum 11.")
    w("")
    w("| İş hanı kirası | maaş x | runway (ay) | en derin açık, 40 hf | haftası | 52. hf kümülatif | Sonuç (runway / açık) |")
    w("|---|---|---|---|---|---|---|")
    for rent in (1500, 2000, 3000, 4000):
        for sm in (1.0, 1.25, 1.5):
            old = E.RENT["ishani"]
            E.RENT["ishani"] = rent
            rw, dp, wk, c52 = [], [], [], []
            for n in names:
                run = C.get_run(n)
                e = E.econ(run, "b2b", "auto", sal_mult=sm)
                r = E.first_hire_runway(run, "b2b", e, sal_mult=sm)
                a = E.agg(run, "b2b", e)
                rw.append(r["runway"]); dp.append(a["deep40"]); wk.append(a["deep40_week"]); c52.append(a["c52"])
            E.RENT["ishani"] = old
            ok_r = all(x >= 6.7 for x in rw); ok_d = all(25000 <= -d <= 45000 and k > 30 for d, k in zip(dp, wk))
            w("| $%d | x%.2f | %s | %s | %s | %s | %s / %s |" % (rent, sm, " / ".join("%.1f" % x for x in rw), " / ".join("%.0fK" % (-d / 1000) for d in dp), " / ".join(str(k) for k in wk),
                                                           " / ".join("%.0fK" % (x / 1000) for x in c52), "geçti" if ok_r else "kaldı", "geçti" if ok_d else "kaldı"))
            J.setdefault("scan", {})["%d|%.2f" % (rent, sm)] = [rw, dp, wk, c52]
    # B2C
    w("")
    w("B2C `fix_worst` (en derin açık bugünkü kaydın en çok %50 fazlası; 101. hf net >= %80):")
    w("")
    w("| İş hanı kirası | maaş x | en derin açık (bugün) | yeni | oran | 101. hf net oranı |")
    w("|---|---|---|---|---|---|")
    for rent in (2000, 4000):
        for sm in (1.0, 1.5):
            old = E.RENT["ishani"]
            E.RENT["ishani"] = rent
            cells = []
            for s in D.SEEDS:
                n = D.run_name("worst", s, True)
                run = C.get_run(n)
                e0 = E.econ(run, "b2c", "recorded", sal_mult=1.0)
                e0["exp_new"] = e0["exp_old"]; e0["cum_new"] = e0["cum_old"]; e0["cash_new"] = e0["cash_old"]
                a0 = E.agg(run, "b2c", e0)
                e = E.econ(run, "b2c", "auto", sal_mult=sm)
                a = E.agg(run, "b2c", e)
                cells.append((a0["deep"], a["deep"], a["deep"] / a0["deep"], a["c101"] / a0["c101"]))
            E.RENT["ishani"] = old
            w("| $%d | x%.1f | %s | %s | %s | %s |" % (rent, sm, " / ".join("%.0fK" % (x[0] / 1000) for x in cells), " / ".join("%.0fK" % (x[1] / 1000) for x in cells),
                                                  " / ".join("x%.2f" % x[2] for x in cells), " / ".join("x%.2f" % x[3] for x in cells)))
    open(os.path.join(C.OUT, "c0s_e.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    json.dump(J, open(os.path.join(C.OUT, "c0s_e.json"), "w"), ensure_ascii=False, indent=1, default=str)
    print("\n".join(L))


if __name__ == "__main__":
    main()
