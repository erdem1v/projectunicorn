# D0s kapi hesabi: eski 23 kapi (PRD 4.1 esikleriyle) + yeni kapilar. python -I dsim3.py exec dgates.py [etiket]
# Veri: out/<etiket>/ (varsayilan R). dsim3.py yalniz sabitler (BASES, SEQS ...) ve medof icin gerekli.
exec(open("dan.py", encoding="utf-8").read())
exec(open("dgroups.py", encoding="utf-8").read())
T = sys.argv[3] if len(sys.argv) > 3 else "R"
GATES = []
BASES_ = ["S2", "S3", "S4", "S5", "S6"]
ADD_ = list(ADD)
FOUNDERS_ = list(FOUNDERS)
SEQS_ = list(SEQS)


def gate(no, ad, hedef, ok, deger, kanit=""):
    GATES.append({"no": no, "ad": ad, "hedef": hedef, "gecti": (None if ok is None else bool(ok)), "deger": deger, "kanit": kanit})


def MD(n, k, idx=None, opt=None, tag=None):
    return md(tag or T, n, k, idx, opt)


def need(*names, tag=None, opt=None):
    return all(have(tag or T, n, opt) for n in names)


def hs(n, key="bs_late", tag=None, opt=None):
    return "%d/%d" % (tsum(tag or T, n, key, 0, opt), tsum(tag or T, n, key, 1, opt))


def consec(n, tag=None, opt=None):
    return sum(1 for m in (D(tag or T, n, opt) or {}).values() if m["consec"])


def pooled_asked(n):
    a = b = 0
    for m in (D(T, n) or {}).values():
        for x in m["series"]:
            if x[1] > 20:
                b += 1
                a += 1 if x[8] else 0
    return a / b if b else None


# ----------------------------------------------------------------- 1 ekleme_dusurmez (PRD 4.1 madde 1: tolerans yok)
steps = []      # (fark, ad, grup)
for base in BASES_:
    for a_ in ADD_:
        n = "%s %s" % (base, a_)
        if need(base, n):
            steps.append((MD(n, "deliv") - MD(base, "deliv"), n, "B", base, n))
for n in range(1, 50):
    if need("C%d" % n, "C%d" % (n + 1)):
        steps.append((MD("C%d" % (n + 1), "deliv") - MD("C%d" % n, "deliv"), "egri %d->%d" % (n, n + 1), "C", "C%d" % n, "C%d" % (n + 1)))
for f in FOUNDERS_:
    for s_ in SEQS_:
        for k in range(3):
            a, b = "G|%s|%s|%d" % (f, s_, k), "G|%s|%s|%d" % (f, s_, k + 1)
            if need(a, b):
                steps.append((MD(b, "deliv") - MD(a, "deliv"), "G|%s|%s|+%d" % (f, s_, k + 1), "E", a, b))
rep = []
for n in [k for k in SCEN if k.startswith("REP|")]:
    base = n.split("|")[1]
    if need(base, n):
        rep.append((MD(n, "deliv") - MD(base, "deliv"), n, "REP", base, n))
allst = steps + rep


def grp_summary(lst, g):
    xs = [x for x in lst if x[2] == g]
    if not xs:
        return "-"
    w = min(xs)
    return "%d adim, en kotu %s (%s), eksi adim %d" % (len(xs), f1(w[0]), w[1], sum(1 for x in xs if x[0] < -1e-9))


if allst:
    w1 = min(allst)
    gate(1, "ekleme_dusurmez", "her ekleme ve her daha iyisiyle değiştirme ≥ 0 puan/hf (tolerans yok)", w1[0] >= -1e-9,
         "en kotu %s (%s); eksi adim %d/%d" % (f1(w1[0]), w1[1], sum(1 for x in allst if x[0] < -1e-9), len(allst)),
         " | ".join("%s: %s" % (g, grp_summary(allst, g)) for g in ("B", "C", "E", "REP")))
else:
    gate(1, "ekleme_dusurmez", "tolerans yok", None, "veri yok")
STEPS = allst


def pair_stats(a, b, tag=None):
    """Ayni tohumlarda b - a teslim farki: (ortalama, standart hata, eksi tohum sayisi)."""
    da, db = D(tag or T, a), D(tag or T, b)
    sd = sorted(set(da) & set(db))
    diff = [db[s]["deliv"] - da[s]["deliv"] for s in sd]
    se = statistics.stdev(diff) / math.sqrt(len(diff)) if len(diff) > 1 else 0.0
    return statistics.mean(diff), se, sum(1 for d in diff if d < 0), len(diff)


SIG = []     # ortalama farki -2 SE'nin altinda olan (gurultuden ayrilan) adimlar
for x in allst:
    mu, se, nneg, nn = pair_stats(x[3], x[4])
    if mu < -2 * se - 1e-9 and mu < 0:
        SIG.append((x[1], round(mu, 2), round(se, 2), nneg, nn))
if allst:
    GATES[-1]["kanit"] += " | ortalama farki -2 SE'nin altinda olan (gurultuden ayrilan) eksi adim: %d/%d %s" % (len(SIG), len(allst), SIG[:6])

# ----------------------------------------------------------------- 2 kurucu_buyume (esik %12)
def fshare(n):
    st = [MD(n, "founder_st", i) for i in range(4)]
    t = sum(st) or 1
    return [x / t for x in st]


noreason, drops, worst_base, minstep, mvp_late, ngrow = [], 0, (0, None), (99, None), [], 0
REASONS_N = {'asama': 0, 'bolundu': 0, 'hazirlik': 0, 'YOK': 0}
for f in FOUNDERS_:
    for s_ in SEQS_:
        n0 = "G|%s|%s|0" % (f, s_)
        if not have(T, n0):
            continue
        base = MD(n0, "founder_w")
        for k in range(1, 4):
            n, pn_ = "G|%s|%s|%d" % (f, s_, k), "G|%s|%s|%d" % (f, s_, k - 1)
            if not need(n, pn_):
                continue
            ngrow += 1
            fw, pf = MD(n, "founder_w"), MD(pn_, "founder_w")
            if fw / base - 1 < worst_base[0]:
                worst_base = (fw / base - 1, (f, s_, k))
            dd = MD(n, "deliv") - MD(pn_, "deliv")
            if dd < minstep[0]:
                minstep = (dd, (f, s_, k))
            if MD(n, "mvp") > MD(pn_, "mvp"):
                mvp_late.append((f, s_, k))
            if fw < pf * 0.98:
                drops += 1
                a, b_ = fshare(pn_), fshare(n)
                dom = a.index(max(a)) != b_.index(max(b_))
                big = max(abs(x - y) for x, y in zip(a, b_)) >= 0.20
                fa_ = [MD(pn_, "founder_st", i) for i in range(4)]
                fb_ = [MD(n, "founder_st", i) for i in range(4)]
                sa_ = [MD(pn_, "stage_w", i) for i in range(4)]
                sb_ = [MD(n, "stage_w", i) for i in range(4)]
                ss_ = min(range(4), key=lambda i: fb_[i] - fa_[i])
                shared = sb_[ss_] > 0 and sa_[ss_] > 0 and fb_[ss_] / sb_[ss_] < fa_[ss_] / sa_[ss_] - 0.02      # is yeni gelenle bolundu
                prep = SEQS[s_][k - 1][0] == "pm" or (MD(n, "ready") - MD(pn_, "ready")) >= 0.05                # kart hazirlikla kuculdu
                REASONS_N[("asama" if (dom or big) else "bolundu" if shared else "hazirlik" if prep else "YOK")] += 1
                if not (dom or big or shared or prep):
                    noreason.append((f, s_, k, round(100 * (fw / pf - 1), 1)))
g2ok = ngrow > 0 and worst_base[0] >= -0.10 - 1e-9 and not noreason and not mvp_late and minstep[0] > 0   # Opus incelemesi: ERDEM_QCD_CEVAP 2.3 D3 %10 (PRD 4.1 %12 yazar; sahip karari baglayici)
gate(2, "kurucu_buyume", "teslim her alimda artar; MVP gecikmez; kurucunun isi <= %10 duser (QCD D3; PRD 4.1 %12), her dusus nedenli", g2ok if ngrow else None,
     "%d adim: teslim en kucuk artis %s (%s); MVP gecikme %d; kurucu isi tabana gore en cok %s (%s); nedensiz dusus %d/%d" % (
         ngrow, f1(minstep[0]), "/".join(map(str, minstep[1] or ())), len(mvp_late), pc(-worst_base[0]), "/".join(map(str, worst_base[1] or ())), len(noreason), drops),
     "dususlerin nedeni (kurucu isi onceki adima gore >%%2 dustu): %s; nedensiz: %s" % (REASONS_N, noreason))

# ----------------------------------------------------------------- 3 mvp_tek_kurucu
if have(T, "S1"):
    mv = [m["mvp"] for m in D(T, "S1").values()]
    gate(3, "mvp_tek_kurucu", "MVP sprint sonunda: 6. hafta, en gec 8", all(x is not None and x % 2 == 0 and 6 <= x <= 8 for x in mv) and statistics.median(mv) == 6,
         "6. hafta %d tohum, 8. hafta %d tohum, baska %d" % (mv.count(6), mv.count(8), len(mv) - mv.count(6) - mv.count(8)))
else:
    gate(3, "mvp_tek_kurucu", "6 (en gec 8)", None, "veri yok")

# ----------------------------------------------------------------- 4 kisi_basi_olcek
if need("S3", "S5", "S6"):
    r5, r6 = MD("S5", "per_person") / MD("S3", "per_person"), MD("S6", "per_person") / MD("S3", "per_person")
    gate(4, "kisi_basi_olcek", "S5 ve S6 kisi basi, S3'un %70 ile %150'si", 0.7 <= r5 <= 1.5 and 0.7 <= r6 <= 1.5,
         "S5 %s, S6 %s (kisi basi %s, %s, %s)" % (pc(r5), pc(r6), f1(MD("S3", "per_person")), f1(MD("S5", "per_person")), f1(MD("S6", "per_person"))))

# ----------------------------------------------------------------- 5 darbogaz_rolu
pairs = [("S8 + Test kutulu gelistirici", "S8", "S8_ek_testkutulu_gel"), ("S11 + testci", "S11", "S11_ek_testci"), ("S9a + gelistirici", "S9a", "S9a_ek_gel")]
if all(need(a, b) for _, a, b in pairs):
    gate(5, "darbogaz_rolu", "darbogaz rolune kisi eklemek teslimi artirir", all(MD(b, "deliv") > MD(a, "deliv") for _, a, b in pairs),
         "; ".join("%s %s -> %s" % (t, f1(MD(a, "deliv")), f1(MD(b, "deliv"))) for t, a, b in pairs))

# ----------------------------------------------------------------- 6, 7, 8 duzeltme payi, toplam hata isi, acik hata
scan = []
GR = {"A": [n for n, _ in GROUPS["A"]], "B": [n for n, _ in GROUPS["B"]], "C": [n for n, _ in GROUPS["C"]], "D": [n for n, _ in GROUPS["D"]], "E": [n for n, _ in GROUPS["E"]]}
for g in GR:
    for n in GR[g]:
        if have(T, n):
            scan.append((n, n, None))
for n, o in GROUPS["F"]:
    if have(T, n, o):
        scan.append(("%s/%s" % (n, o["policy"]), n, o))
rows = []
for name, key, opt in scan:
    d = D(T, key, opt)
    mm = next(iter(d.values()))
    n_eff = sum(1 for r_ in mm["roles"][0] if r_ != "pm")
    n_ = 1 if n_eff <= 1 else mm["n"]
    fe, fl = MD(key, "fix_early", opt=opt), MD(key, "fix_late", opt=opt)
    inf = MD(key, "infix", opt=opt)
    rows.append({"ad": name, "n": n_, "fe": fe, "fl": fl, "inf": inf,
                 "hsl": tsum(T, key, "bs_late", 0, opt) / max(1, tsum(T, key, "bs_late", 1, opt)),
                 "hse": tsum(T, key, "bs_early", 0, opt) / max(1, tsum(T, key, "bs_early", 1, opt)),
                 "cons": consec(key, opt=opt), "slope": MD(key, "slope", opt=opt)})
bad6 = []
for r in rows:
    if r["n"] >= 2:
        if (r["fe"] is not None and r["fe"] > 0.30) or r["fl"] > 0.20 or r["hsl"] > 0.05 or r["hse"] > 0.05 or r["cons"]:
            bad6.append(r["ad"])
    else:
        if (r["fe"] is not None and r["fe"] > 0.50) or r["hsl"] > 0.05 or r["cons"]:
            bad6.append(r["ad"])
if rows:
    mx_fe = max((r["fe"] for r in rows if r["n"] >= 2 and r["fe"] is not None), default=0)
    mx_fl = max((r["fl"] for r in rows if r["n"] >= 2), default=0)
    mx_hs = max((max(r["hsl"], r["hse"]) for r in rows if r["n"] >= 2), default=0)
    s1 = [r for r in rows if r["n"] == 1]
    gate(6, "duzeltme_payi", ">=2 kisi: erken <=30%, gec <=20%, hata sprinti <=5%, ust uste yok; tek kurucu erken <=50%, gec hata sprinti <=5%", not bad6,
         "%d senaryo: >=2 kisi en yuksek erken %s, gec %s, hata sprinti %s; tek kurucu erken en cok %s, hata sprinti en cok %s" % (
             len(rows), pc(mx_fe), pc(mx_fl), pc(mx_hs), pc(max((r["fe"] for r in s1 if r["fe"] is not None), default=0)), pc(max((r["hsl"] for r in s1), default=0))), "ihlal: %s" % bad6)
    bad7 = []
    for r in rows:
        tot = r["fl"] + r["inf"]
        if tot > (0.35 if r["n"] == 1 else 0.20):
            bad7.append((r["ad"], round(tot, 3)))
    mx7 = max(((r["fl"] + r["inf"], r["ad"]) for r in rows if r["n"] >= 2), default=(0, "-"))
    mx71 = max(((r["fl"] + r["inf"], r["ad"]) for r in rows if r["n"] == 1), default=(0, "-"))
    gate(7, "toplam_hata_isi", ">=2 kisi <=%20, tek kurucu <=%35", not bad7, ">=2 kisi en cok %s (%s); tek kurucu en cok %s" % (pc(mx7[0]), mx7[1], pc(mx71[0])), "ihlal: %s" % bad7)
    sl_rows = [r for r in rows if "/" not in r["ad"] or r["ad"].endswith("/birak")]
    mxs = max(((r["slope"], r["ad"]) for r in sl_rows if r["slope"] is not None), default=(0, "-"))
    gate(8, "acik_hata_sinirli", "son 20 haftanin egimi <= 0,2 hata/hf", mxs[0] <= 0.2, "en buyuk medyan egim %s (%s)" % (f1(mxs[0], 2), mxs[1]))

# ----------------------------------------------------------------- 9, 10 testci
t9, ok9, t10, ok10, any9 = [], True, [], True, False
for lab, pre in (("6 kisi", "T3"), ("12 kisi", "T4"), ("25 kisi", "T5")):
    if need(pre + "_1", pre + "_5", pre + "_3", pre + "_yok"):
        any9 = True
        e1, e5 = MD(pre + "_1", "esc100"), MD(pre + "_5", "esc100")
        f_1, f_5 = MD(pre + "_1", "found_sp"), MD(pre + "_5", "found_sp")
        red, mul = 1 - e5 / e1, f_5 / f_1
        ok9 &= red >= 0.40 and mul >= 2.0
        t9.append("%s kacan/100 %s -> %s (-%s), bulunan %s -> %s (x%s)" % (lab, f1(e1, 2), f1(e5, 2), pc(red), f1(f_1, 2), f1(f_5, 2), f1(mul)))
        d0, d3 = MD(pre + "_yok", "deliv"), MD(pre + "_3", "deliv")
        e0, e3 = MD(pre + "_yok", "esc100"), MD(pre + "_3", "esc100")
        ok10 &= d3 >= d0 and (1 - e3 / e0) >= 0.20
        t10.append("%s teslim %s -> %s (%s%s), kacan/100 %s -> %s (-%s)" % (lab, f1(d0), f1(d3), "+" if d3 >= d0 else "", pc(d3 / d0 - 1), f1(e0, 2), f1(e3, 2), pc(1 - e3 / e0)))
cv = 0
for g in GR:
    for n in GR[g]:
        if have(T, n):
            cv += sum(m["catch_viol"] for m in D(T, n).values())
if any9:
    gate(9, "testci_yildizi", "1->5 yildiz: kacan/100 >= %40 azalir, bulunan >= 2 kat; yakalama en iyi testcinin c'sini asmaz", ok9 and cv == 0, "; ".join(t9) + "; tavan asimi %d kart" % cv)
    gate(10, "testci_degeri", "testcisiz yerine 3* testci: teslim dusmez, kacan/100 >= %20 azalir", ok10, "; ".join(t10))

# ----------------------------------------------------------------- 11 pm_yildizi (besleyen PM sayisiyla)
t11, ok11, fails11 = [], True, []
for lab, pre in (("6 kisi, 1 PM", "PM3"), ("11 kisi, 1 PM", "PM4"), ("24 kisi, 2 PM", "PM7"), ("25 kisi, 3 PM", "PM6")):
    if need(pre + "_1", pre + "_5"):
        d1, d5 = MD(pre + "_1", "deliv"), MD(pre + "_5", "deliv")
        e1, e5 = MD(pre + "_1", "esc_card"), MD(pre + "_5", "esc_card")
        okk = (d5 / d1 - 1) >= 0.10 and (1 - e5 / e1) >= 0.25
        ok11 &= okk
        if not okk:
            fails11.append(lab)
        t11.append("%s teslim %s -> %s (+%s), kacan/kart %s -> %s (-%s)" % (lab, f1(d1), f1(d5), pc(d5 / d1 - 1), f1(e1, 2), f1(e5, 2), pc(1 - e5 / e1)))
info23 = ""
if need("PM5_1", "PM5_5"):
    d1, d5 = MD("PM5_1", "deliv"), MD("PM5_5", "deliv")
    e1, e5 = MD("PM5_1", "esc_card"), MD("PM5_5", "esc_card")
    info23 = "bilgi (kapi disi): 23 kisi, 1 PM teslim +%s, kacan/kart -%s" % (pc(d5 / d1 - 1), pc(1 - e5 / e1))
pmsiz = []
for lab, a, b in (("S3 PM'siz->PM", "S3_PMsiz", "S3"), ("S4 PM'siz->1 PM", "S4_PMsiz", "S4_1PM"), ("23 kisi PM'siz->PM(3*)", "PM5_yok", "PM5_3")):
    if need(a, b):
        pmsiz.append((lab, MD(a, "deliv"), MD(b, "deliv"), MD(a, "esc_card"), MD(b, "esc_card")))
okp = all(b > a and d < c for _, a, b, c, d in pmsiz)
ok11 &= okp
t11.append("PM'siz->PM: " + "; ".join("%s %s -> %s, kacan %s -> %s" % (t, f1(a), f1(b), f1(c, 2), f1(d, 2)) for t, a, b, c, d in pmsiz))
if len(t11) > 1:
    gate(11, "pm_yildizi", "besleyen PM sayisiyla 1->5 yildiz: teslim >= %10, kacan/kart >= %25 iyi; PM'siz->PM iyilesir", ok11, " | ".join(t11), "kalan: %s %s" % (fails11, info23))

# ----------------------------------------------------------------- 12 soru_sikligi (esikli kip: karsilastirma) ve bagli kip
qs = {n: pooled_asked(n) for n in ("S2", "S3", "S4", "S5", "S10") if have(T, n)}
if qs:
    ok12 = all(v <= 1 / 3 + 1e-9 for v in qs.values()) and qs.get("S3", 1) >= 0.05 and qs.get("S4", 1) >= 0.05
    lq = []
    for b in S6L:
        if have(T, "PR|%s" % b):
            lq.append((b, statistics.mean(m["linked_q"] for m in D(T, "PR|%s" % b).values())))
    gate(12, "soru_sikligi", "bagli kip: soru sprintlerin <= %10'unda; esikli kip (karsilastirma): S2-S5, S10 <= 1/3, 6 ve 12 kisi >= 1/20",
         all(v <= 0.10 for _, v in lq) if lq else None,      # Opus incelemesi: esikli kip PRD 4.1 madde 5 geregi yalniz karsilastirma, kapiya girmez
         "esikli: " + ", ".join("%s %s" % (k, pc(v)) for k, v in qs.items()) + "; bagli kip (soz verilen kartta, PR senaryolari): " + ", ".join("%s %s" % (k, pc(v)) for k, v in lq))

# ----------------------------------------------------------------- 13 soru_politikasi
pols = ("birak", "gonder", "esikli", "hep_gonder")
ok13, diffs, oh, any13 = True, [], [], False
for n in ("S1", "S3", "S4", "S5", "S6", "S10"):
    if all(have(T, n, {"policy": p}) for p in pols):
        any13 = True
        ds = [MD(n, "deliv", opt={"policy": p}) for p in pols]
        spread = (max(ds) - min(ds)) / MD(n, "deliv", opt={"policy": "birak"})
        diffs.append((spread, n))
        ob, og = MD(n, "open_med", opt={"policy": "birak"}), MD(n, "open_med", opt={"policy": "hep_gonder"})
        oh.append((og / ob - 1 if ob else 0, n))
        hsn = sum(tsum(T, n, "bs_late", 0, {"policy": p}) for p in pols)
        ok13 &= spread <= 0.02 + 1e-9 and (og / ob - 1 if ob else 0) <= 0.20 + 1e-9 and (n == "S1" or hsn == 0)
if any13:
    gate(13, "soru_politikasi", "dort politikada teslim farki <= %2; hep gonder acik hata medyani <= +%20; hata sprinti yok", ok13,
         "teslim farki en cok %s (%s); hep gonder acik hata artisi en cok %s (%s)" % (pc(max(diffs)[0]), max(diffs)[1], pc(max(oh)[0]), max(oh)[1]))

# ----------------------------------------------------------------- 14 tahmin_sonuc, ve 6 early_closed
allp, nrun, early = 0.0, 0, 0
for g in ("A", "B", "C", "D", "E", "G", "R", "I", "REP", "PR", "DEP", "HUY", "UF", "PMC", "S", "SK"):
    for n, o in GROUPS[g]:
        d = D(T, n, o)
        if d:
            for m in d.values():
                allp = max(allp, m["pred"])
                nrun += 1
                early += m["early_closed"]
for n, o in GROUPS["F"]:
    d = D(T, n, o)
    if d:
        for m in d.values():
            allp = max(allp, m["pred"])
            nrun += 1
            early += m["early_closed"]
gate(14, "tahmin_sonuc", "plan-kapanis farki <= 1e-6", allp <= 1e-6 if nrun else None, "en buyuk fark %.1e (%d kosu; asama ilerlemesi, bitis, n, F, duzeltme isi, cekilen kart)" % (allp, nrun))
gate("N4", "early_closed", "erken kapanan sprint = 0 (PRD 4.3 madde 1)", (early == 0) if nrun else None, "%d kosuda erken kapanan sprint %d" % (nrun, early))


# ----------------------------------------------------------------- 15 a_sinirlari_oranli
def d5_hit(m, nl=None):
    openw, delw, livew, mvp = m["openw"], m["delw"], m["livew"], m["mvp"]
    for i in range(len(openw)):
        wk = i + 1
        if mvp is None or wk <= mvp:
            continue
        d8 = statistics.mean(delw[max(0, i - 7):i + 1])
        lv = livew[i] if nl is None else min(nl, livew[i])
        k = max(1.0, lv / 9.0, math.sqrt(d8 / 55.0))
        if openw[i] >= 30 * k:
            return wk - mvp
    return None


t15, ok15, n15 = [], True, 0
for b in S6L:
    if need("D5|%s|nofix" % b, "D5|%s|fix" % b):
        n15 += 1
        hit = [d5_hit(m) for m in D(T, "D5|%s|nofix" % b).values()]
        hit9 = [d5_hit(m, 9) for m in D(T, "D5|%s|nofix" % b).values()]
        okh, okh9 = [h for h in hit if h is not None], [h for h in hit9 if h is not None]
        fixhit = sum(1 for m in D(T, "D5|%s|fix" % b).values() if d5_hit(m) is not None)
        med = statistics.median(okh) if len(okh) == 20 else None
        med9 = statistics.median(okh9) if len(okh9) == 20 else None
        ok15 &= med is not None and 10 <= med <= 26 and med9 is not None and 10 <= med9 <= 26 and fixhit == 0
        t15.append("%s %s hf (9 hat: %s), fix_due %d/20" % (b, f1(med) if med else "-", f1(med9) if med9 else "-", fixhit))
if n15:
    gate(15, "a_sinirlari_oranli", "hic duzeltmeyen 10-26 haftada k x 30'a varir; fix_due varmaz", ok15, "; ".join(t15))

# ----------------------------------------------------------------- 16 arz_havuzu, 18, 19, 20, 21
kay = ["A|%s|kaynakli|2" % b for b in S6L]
if all(have(T, n) for n in kay) and have(T, "GC|kaynakli"):
    pools = {n: MD(n, "pool_ok") for n in kay}
    lowp = {n: v for n, v in pools.items() if v < 0.90}
    gc = MD("GC|kaynakli", "pool_ok")
    r330 = ", ".join("%s %s" % (b, pc(MD("R|%s|330" % b, "pool_ok"))) for b in ("S5", "S6") if have(T, "R|%s|330" % b))
    gate(16, "arz_havuzu", "buyume egrisinde sprintlerin >= %90'inda acik aday >= 0,75 x ekip (8 kisi altinda >= ekip) (PRD 4.1 madde 6; sabit ekipler bilgi)", gc >= 0.9,
         "buyume egrisi %s; sabit ekipler: " % pc(gc) + ", ".join("%s %s" % (n.split("|")[1], pc(pools[n])) for n in kay) + "; 330 hesapta " + r330,
         "altinda: %s" % {k: round(v, 2) for k, v in lowp.items()})
    nc, ncs = MD("GC|kaynakli", "nocard"), (MD("GC|sonlu", "nocard") if have(T, "GC|sonlu") else None)
    gate(18, "kart_yok_sprinti", "buyume egrisi 130 hf: 'planlanacak kart kalmadi' sprinti <= %5", nc <= 0.05, "kaynakli %s (sonlu katalog: %s)" % (pc(nc), pc(ncs)))
    fills = {n: MD(n, "fill_ratio") for n in kay + ["GC|kaynakli"] + [k for k in ("R|S5|330", "R|S6|330", "R|S3|330", "R|S4|330") if have(T, k)]}
    fills = {k: v for k, v in fills.items() if v is not None}
    lowf = {n: round(v, 3) for n, v in fills.items() if v < 0.94}
    gate(19, "oneri_dolulugu", "onerinin aldigi is / planin alabilecegi >= %94; bot = oneri", not lowf,
         "en dusuk %s (%s)" % (pc(min(fills.values())), min(fills, key=fills.get)), "altinda: %s" % lowf)
    ratio = DEPTH_GAIN ** 4
    areas5 = sum(1 for m in D(T, "A|S6|kaynakli|2").values() for a in m["depth_area"] if a >= 5)
    gate(20, "derinlik_kazanci", "5. kartin kazanci ilkinin <= 1/3'u", ratio <= 1 / 3 + 1e-9,
         "5. kart ilkinin %s'i (0,75^4); S6 kaynakli 20 tohumun 80 alanindan %d'inde >=5 derinlik karti bitti" % (pc(ratio), areas5))
ist = []
for b in ("S3", "S4", "S5", "S6"):
    for acc in (100, 330):
        n = "R|%s|%d" % (b, acc)
        if have(T, n):
            ps = [MD(n, "pts_src", i) for i in range(3)]
            ist.append("%s/%d hesap: %s" % (b, acc, pc(ps[0] / sum(ps))))
if ist:
    gate(21, "istek_payi", "raporlanir (hedef yok); istegi yalniz 3* ve ustu hesap yapar", True, "teslim puaninda istek payi " + "; ".join(ist))

# ----------------------------------------------------------------- 17 bosta_nedenli ve 50 kisi boslugu
tot = nne = 0
hi_ = []
for g in ("A", "B", "C", "D", "E", "G", "R", "I", "REP", "PR", "DEP", "S", "SK"):
    for n, o in GROUPS[g]:
        d = D(T, n, o)
        if d:
            for m in d.values():
                tot += 1
                if m["idle_pct"] > 0.10:
                    hi_.append(n)
                    if abs(sum(m["why"].values()) - m["idle_w"]) > 1e-6:
                        nne += 1
i50 = {n: MD(n, "idle_pct") for n in ("S6", "A|S6|kaynakli|2", "R|S6|330") if have(T, n)}
if tot:
    gate("4.3/7", "bosta_50", "50 kisi bosta <= %15 (PRD 4.3 madde 7)", all(v <= 0.15 for v in i50.values()), ", ".join("%s %s" % (k, pc(v)) for k, v in i50.items()))
    gate(17, "bosta_nedenli", "nedensiz bosta 0 (PRD 4.1 madde 6); bosta > %10 olan kosu bilgi", nne == 0,
         "%d kosunun %d'inde bosta > %%10; nedensiz %d; 50 kisi bosta: %s" % (tot, len(hi_), nne, ", ".join("%s %s" % (k, pc(v)) for k, v in i50.items())))

# ----------------------------------------------------------------- 22 takim_bolme: kapsam disi
gate(22, "takim_bolme (EA)", "EA takimi ertelendi (PRD 7, QCD D5)", None, "OLCULMEDI: kapsam disi")

# ----------------------------------------------------------------- 23 uymayan_moral (atama kosuluyla ve kosulsuz)
if have(T, "S3_PM_testkutulu"):
    mr = [m["morale"][0][m["roles"][0].index("pm")] for m in D(T, "S3_PM_testkutulu").values()]
    txt = "atama kosuluyla PM medyan %d (en az %d, en cok %d)" % (statistics.median(mr), max(mr), min(mr))
    c0 = ""
    if have("R_unfit0", "S3_PM_testkutulu"):
        mr0 = [m["morale"][0][m["roles"][0].index("pm")] for m in D("R_unfit0", "S3_PM_testkutulu").values()]
        c0 = "; kosulsuz (UNFITCOND=0) medyan %d (en az %d, en cok %d)" % (statistics.median(mr0), max(mr0), min(mr0))
    gate(23, "uymayan_moral", "S3 + PM'in Test kutusu: 60 haftada PM 60 ile 90 moral kaybeder (kosulsuz olcum); atama kosuluyla ayrica olculur", (60 <= -statistics.median(mr0) <= 90) if c0 else None, txt + c0,
         "kosulla PM'in hazirlayacak karti oldugu haftalarda Test'e girmez: kosullu deger kosulsuzdan kucuk olmali")

# ----------------------------------------------------------------- yeni kapilar: pm_ekleme, atama_sirasi, kendi_karti, plan_fill
pmx = {}
for arm, tg in (("karar4h", "R"), ("karar4", "R_pm4w"), ("best", "R_pmbest"), ("preparer", "R_pmpreparer")):
    lst = []
    for i in range(len(PMSTEP) // 2):
        a, b = PMSTEP[2 * i], PMSTEP[2 * i + 1]
        if need(a, b, tag=tg):
            lst.append((md(tg, b, "deliv") - md(tg, a, "deliv"), "%s->%s" % (a, b)))
    for base, withpm in (("S2", "S2 +3* PM"), ("S3", "S3 +3* PM"), ("S4", "S4 +3* PM"), ("S5", "S5 +3* PM"), ("S6", "S6 +3* PM"), ("G|orta|pm-gel-tas|0", "G|orta|pm-gel-tas|1")):
        if need(base, withpm, tag=tg):
            lst.append((md(tg, withpm, "deliv") - md(tg, base, "deliv"), "%s->%s" % (base, withpm)))
    pmx[arm] = lst
if pmx["karar4h"]:
    w = min(pmx["karar4h"])
    gate("N1", "pm_ekleme", "PM eklemek teslimi hicbir senaryoda dusurmez (tolerans yok); kartin hazirlayani kurali Karar 4 ile yeniden olculur", w[0] >= -1e-9,
         "; ".join("%s: en kotu %s (%s), eksi adim %d/%d" % (a, f1(min(l)[0]), min(l)[1], sum(1 for x in l if x[0] < -1e-9), len(l)) for a, l in pmx.items() if l))
A_ = {k: sum(m["aud"].get(k, 0) for n, _ in GROUPS["A"] + GROUPS["S"] + GROUPS["SK"] + GROUPS["HUY"] if have(T, n) for m in D(T, n).values()) for k in ("rows", "inv", "stale", "wk_rows", "wk_inv", "unfit", "unfit_front", "unfit_fit")}
ddet = json.load(open("out/ddet.json", encoding="utf-8")) if os.path.exists("out/ddet.json") else []
dchk = json.load(open("out/dcheck.json", encoding="utf-8")) if os.path.exists("out/dcheck.json") else []
if A_["rows"]:
    ok_det = bool(ddet) and all(x["ayni"] for x in ddet)
    gate("N2", "atama_sirasi", "her atama aninda ve asamada daha buyuk isde daha yavas kisi yok; ayni girdi ayni atama; uymayan is yalniz bosta kalacaga", A_["inv"] == 0 and A_["wk_inv"] == 0 and A_["unfit_front"] == 0 and A_["unfit_fit"] == 0 and ok_det,
         "%d atama satiri: yeni atananlar arasinda ters %d, hafta basi tam eslemede ters %d, uymayan is %d (onden isi varken %d, uydugu satirda bos yer varken %d); ayni girdi ayni atama %d/%d kosuda" % (
             A_["rows"], A_["inv"], A_["wk_inv"], A_["unfit"], A_["unfit_front"], A_["unfit_fit"], sum(1 for x in ddet if x["ayni"]), len(ddet)),
         "bilgi: surerken kartinda kalan (yapisal) yavas kisi sayisi %d (kisi aşama ya da hafta bitene dek kartinda kalir)" % A_["stale"])
selft = {k: sum(aud(T, n, k) for n, _ in GROUPS["A"] + GROUPS["S"] if have(T, n)) for k in ("tested", "selft", "selft_founder")}
s1d = D(T, "S1")
s1_all = bool(s1d) and all(m["aud"]["selft"] == m["aud"]["tested"] and m["aud"]["tested"] > 0 for m in s1d.values())
okc = bool(dchk) and all(x["gecti"] for x in dchk if "Kendi karti" in x["ad"])
gate("N3", "kendi_karti", "kendi gelistirdigi karti test eden x0,6 bulur, kurucu dahil", okc and s1_all and selft["selft_founder"] > 0,
     "mikro test: %s; tek kurucuda (S1) her test edilen kart kendi karti: %s; A+S kosularinda %d test edilen kartin %d'i kendi karti, %d'i kurucu" % ("gecti" if okc else "KALDI", s1_all, selft["tested"], selft["selft"], selft["selft_founder"]))
pf = {}
for b in S6L:
    if have(T, b):
        pf[b] = MD(b, "fillplan")
gc_ = MD("GC|kaynakli", "fillplan") if have(T, "GC|kaynakli") else None
if pf:
    gate("N5", "plan_fill", "plan anindaki doluluk medyani >= %90 (1, 3, 6, 12, 25, 50 kisi ve buyume egrisi)", all(v >= 0.9 for v in pf.values()) and (gc_ is None or gc_ >= 0.9),
         ", ".join("%s (%d kisi) %s" % (b, [1, 3, 6, 12, 25, 50][i], pc(v)) for i, (b, v) in enumerate(pf.items())) + ("; buyume egrisi %s" % pc(gc_) if gc_ is not None else ""))

GATES.sort(key=lambda g: (isinstance(g["no"], str), g["no"] if not isinstance(g["no"], str) else 0, str(g["no"])))
for g in GATES:
    st = "OLCULMEDI" if g["gecti"] is None else ("GECTI" if g["gecti"] else "KALDI")
    print("%3s %-18s %-9s %s" % (g["no"], g["ad"], st, g["deger"]))
    if g["kanit"]:
        print("      kanit:", g["kanit"])
json.dump({"gates": GATES, "steps": [(x[0], x[1], x[2]) for x in STEPS], "sig": SIG, "pmx": pmx, "etiket": T}, open("out/dgates_%s.json" % T, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
