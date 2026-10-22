"""C0s bolum C: M7 kesinti kademesi ve C1'in yuk basamaklari (<= %90 1,0; %90-100 1,5; > %100 2,5). python -I.
Formul: incident_system.gd:75-78 @910ad1f: hazard = min(base x load_mult x (1 + min(acik,12)/8), p_max) x tier. Yuk carpani C1'de load_mult()'a girer
(PRD Karar 1) yani KIRPMANIN ICINDE. Duzeltme onerileri C0v E1 soru 1 ve 2.
Cikti: out/c0s_c.md, c0s_c.json"""
import sys, os, json, random, zlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_core as C

BASE = 0.10; P_MAX = 0.30; BUG_DIV = 8.0; BUG_CAP = 12
TIERS = {"Ekonomik (yerel)": 1.0, "Standart (bulut)": 0.5, "Kurumsal": 0.25}
# NOT: sprint.json incident.tier: local 1.0, cloud 0.5, enterprise 0.25. Sunucu kademesi: Ekonomik = yerel, Standart = bulut, Kurumsal = enterprise.
OUTAGE_SHARE_B2B = None   # asagida hesaplanir


def month_end_share():
    """B2B'de haftanin turu: outage 1,0 her hafta, month_close 1,5 yalniz ay sonu tikinde (haftalarin ~1/4,35'i). Kesinti payi s."""
    f = 1 / 4.35
    return (1 - f) * 1.0 + f * (1.0 / 2.5)


def prob(variant, bugs, load, tier, s):
    b = BASE * (1 + min(bugs, BUG_CAP) / BUG_DIV)
    if variant == "a":      # C1 PRD'nin yazdigi: yuk kirpmanin icinde
        return min(BASE * load * (1 + min(bugs, BUG_CAP) / BUG_DIV), P_MAX) * tier
    if variant == "b":      # yuk kirpmadan sonra (E1 soru 2)
        return min(b, P_MAX) * load * tier
    if variant == "c":      # yuk yalniz kesinti turunun payina (E1 soru 1 + 2): p x (1 + s (L-1))
        return min(min(b, P_MAX) * (1 + s * (load - 1)) * tier, 1.0)
    raise ValueError(variant)


def mc(p, runs=2000, T=104, seed=1, v1=7):
    rng = random.Random(seed)
    tot = 0
    for _ in range(runs):
        last = -10 ** 6
        for t in range(1, T + 1):
            u = rng.random()
            if t - v1 < 3 or t - last < 4:
                continue
            if u < p:
                tot += 1; last = t
    return tot / runs


def policies(w):
    import c0s_econ as E, c0s_data as D
    w("")
    w("### Sunucu politikaları: kesinti ve fatura (server_lean / server_wide / server_auto)")
    w("")
    w("K9 `fix_worst` dünyası (gerçek haftalık açık hata ve MRR ÷ $50 koltuk), kademe Standart (bulut, x0,5), v1.0 sonrası. Yük = hizmet edilen birim ÷ satın alınan birim. "
      "Kesinti sayısı: haftalık ihtimal biçim (a) (yük kırpmanın içinde) ve (b) (yük kırpmadan sonra) ile 2.000 koşuda beklenen acil durum sayısı (tür seçimi dışında). "
      "Fatura: Standart $120 / 50 koltuk, 26-104. hafta toplamı; net fark: lean'e göre.")
    w("")
    w("| Tohum | Politika | ortalama yük | yük > %90 hafta | beklenen kesinti (a) | beklenen kesinti (b) | sunucu faturası 26-104. hf | lean'e göre fark |")
    w("|---|---|---|---|---|---|---|---|")
    for sd in D.SEEDS:
        n = D.run_name("worst", sd)
        run = C.get_run(n)
        base_bill = None
        rows = []
        for pol in ("lean", "auto", "wide"):
            cap = E.capacity_series(run, "b2b", pol)
            lo = []
            for t in range(1, 105):
                if cap[t] > 0:
                    lo.append((t, E.served_units(run, "b2b", t) / cap[t]))
            avg = sum(x for _, x in lo) / len(lo)
            over = sum(1 for _, x in lo if x > 0.90)
            bill = sum(cap[t] * E.NEW_UNIT["b2b"] / E.Q for t in range(26, 105))
            ev = {}
            for var in ("a", "b"):
                rng = random.Random(zlib.crc32(("pol|%s|%d" % (var, sd)).encode()))
                tot = 0
                ps = {}
                for t in range(1, 105):
                    ld = dict(lo).get(t, 0.0)
                    lm = 1.0 if ld <= 0.90 else (1.5 if ld <= 1.0 else 2.5)
                    bugs = run["bugs"].get(t, {"open": 0})["open"]
                    ps[t] = prob(var, bugs, lm, 0.5, 0.86)
                for _ in range(2000):
                    last = -10 ** 6
                    for t in range(1, 105):
                        u = rng.random()
                        if t - 7 < 3 or t - last < 4 or cap[t] == 0:
                            continue
                        if u < ps[t]:
                            tot += 1; last = t
                ev[var] = tot / 2000
            rows.append((pol, avg, over, ev["a"], ev["b"], bill))
            if pol == "lean":
                base_bill = bill
        for (pol, avg, over, ea, eb, bill) in rows:
            w("| %d | %s | %%%.0f | %d | %.2f | %.2f | $%.0f | $%+.0f |" % (sd, pol, 100 * avg, over, ea, eb, bill, bill - base_bill))


def main():
    s = month_end_share()
    L = []
    w = L.append
    w("### M7 Kesinti kademesi ve yük basamakları")
    w("")
    w("104 hafta x 2.000 koşu; iki olay arası >= 4 hafta, v1.0'dan sonra ilk 3 hafta yok (`sprint.json` incident: base 0,1, p_max 0,3, min_gap 4, launch_quiet 3). Sayı: koşu başına olay (yalnız hazard, tür seçimi dışında). "
      "Kademe: Ekonomik 1,0 / Standart 0,5 / Kurumsal 0,25 (B'nin çarpanı). Yük basamakları C1: <= %90 1,0; %90-100 1,5; > %100 2,5. "
      "Üç biçim: **(a)** PRD'nin yazdığı (yük `load_mult()` olarak kırpmanın içinde, `incident_system.gd:75-78` bugünkü kod yapısı); **(b)** yük kırpmadan sonra (C0v E1 soru 2); "
      "**(c)** (b) + yük yalnız kesinti türünün payına (E1 soru 1; B2B'de kesintinin tür payı s = {S}).".replace("{S}", "%.2f" % s))
    w("")
    res = {}
    cells = [(2, 70, 1.0), (2, 95, 1.5), (2, 105, 2.5), (6, 70, 1.0), (6, 95, 1.5), (6, 105, 2.5), (12, 70, 1.0), (12, 95, 1.5), (12, 105, 2.5)]
    for variant in ("a", "b", "c"):
        w("**Biçim (%s)**" % variant)
        w("")
        w("| açık hata | yük | haftalık ihtimal (Eko) | Ekonomik | Standart | Kurumsal | Std / Eko | Kur / Std | her basamak >= %25 az |")
        w("|---|---|---|---|---|---|---|---|---|")
        bad = 0
        for (bugs, ld, lm) in cells:
            ev = {}
            for nm, tm in TIERS.items():
                ev[nm] = mc(prob(variant, bugs, lm, tm, s), seed=zlib.crc32(("%s|%d|%d|%s" % (variant, bugs, ld, nm)).encode()))
            e, st, k = ev["Ekonomik (yerel)"], ev["Standart (bulut)"], ev["Kurumsal"]
            ok = (st / e <= 0.75) and (k / st <= 0.75)
            bad += (not ok)
            res[(variant, bugs, ld)] = (e, st, k)
            w("| %d | %%%d (x%.1f) | %.3f | %.2f | %.2f | %.2f | %.2f | %.2f | %s |" % (bugs, ld, lm, prob(variant, bugs, lm, 1.0, s), e, st, k, st / e, k / st, "evet" if ok else "hayır"))
        e70 = res[(variant, 2, 70)][0]; e95 = res[(variant, 2, 95)][0]
        kur_tavan = res[(variant, 12, 70)][2]
        w("")
        w("Hücre sonucu: basamak koşulu bozuk hücre %d / 9. Yük %%95 ÷ %%70 (Ekonomik, az hata) = %.2f (hedef >= 1,3: %s). Kurumsal olay, tavanda hata, %%70 yük: %.2f (hedef >= 4: %s)." % (
            bad, e95 / e70, "geçti" if e95 / e70 >= 1.3 else "kaldı", kur_tavan, "geçti" if kur_tavan >= 4 else "kaldı"))
        w("")
    # carpan yutma: ihtimalin kirpilma esikleri
    w("**Haftalık ihtimalin yük ile gerçek artışı** (ipucu metni \"kesinti ihtimali 1,5 / 2,5 katına çıkar\" der; hücre: ihtimal(yük) ÷ ihtimal(yük <= %90), Ekonomik):")
    w("")
    w("| açık hata | biçim (a) %90-100 | biçim (a) > %100 | biçim (b) %90-100 | biçim (b) > %100 |")
    w("|---|---|---|---|---|")
    for bugs in (0, 2, 6, 8, 12):
        ra = [prob("a", bugs, lm, 1.0, s) / prob("a", bugs, 1.0, 1.0, s) for lm in (1.5, 2.5)]
        rb = [prob("b", bugs, lm, 1.0, s) / prob("b", bugs, 1.0, 1.0, s) for lm in (1.5, 2.5)]
        w("| %d | x%.2f | x%.2f | x%.2f | x%.2f |" % (bugs, ra[0], ra[1], rb[0], rb[1]))
    w("")
    w("**Kırpma yük çarpanını ne zaman yutar (biçim a):** ham ihtimal 0,1 x L x (1 + hata/8) 0,30'u aşınca L etkisiz. L = 1,5 için açık hata > 8; L = 2,5 için açık hata > 1. "
      "Botun `fix_worst` kolunda açık hata (haftalık, iki tohum) ortancası ve payı:")
    w("")
    w("| Kol | ortanca açık hata | hata > 1 olan hafta | hata > 8 olan hafta |")
    w("|---|---|---|---|")
    import c0s_data as D
    import statistics as st_
    for arm in D.ARMS:
        v = []
        for sd in D.SEEDS:
            r = C.get_run(D.run_name(arm, sd))
            v += [r["bugs"][d]["open"] for d in sorted(r["bugs"]) if d >= 8]
        w("| %s | %d | %.0f%% | %.0f%% |" % (C.LABEL[arm], st_.median(v), 100.0 * sum(1 for x in v if x > 1) / len(v), 100.0 * sum(1 for x in v if x > 8) / len(v)))
    policies(w)
    open(os.path.join(C.OUT, "c0s_c.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    json.dump({"%s|%d|%d" % k: v for k, v in res.items()}, open(os.path.join(C.OUT, "c0s_c.json"), "w"), indent=1)
    print("\n".join(L))


if __name__ == "__main__":
    main()
