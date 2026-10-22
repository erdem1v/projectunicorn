# Kapi hesabi (D_MODEL_v3.md §6.12). python -I dsim3.py exec gates.py
exec(open("an_common.py", encoding="utf-8").read())
import json
A, B, C, D, E, F, G, H, H2, I, R = (L(x) for x in ("A", "B", "C", "D", "E", "F", "G", "H", "H2", "I", "R"))
GATES = []


def gate(no, ad, hedef, ok, deger, kanit=""):
    GATES.append({"no": no, "ad": ad, "hedef": hedef, "gecti": bool(ok), "deger": deger, "kanit": kanit})


def pct(x): return ("%.1f" % (100 * x)).replace(".", ",") + "%"
def f1(x): return ("%.1f" % x).replace(".", ",")
def f2(x): return ("%.2f" % x).replace(".", ",")


# --- 1 ekleme_dusurmez
steps = []
for base in ("S2", "S3", "S4", "S5", "S6"):
    bd = md(A, base, "deliv")
    for add in ADD:
        n = "%s %s" % (base, add)
        steps.append((md(B, n, "deliv") - bd, n))
curve_steps = [(md(C, "C%d" % (n + 1), "deliv") - md(C, "C%d" % n, "deliv"), "egri %d->%d" % (n, n + 1)) for n in range(1, 50)]
gr_steps = []
for f in FOUNDERS:
    for s in SEQS:
        for k in range(3):
            gr_steps.append((md(E, "G|%s|%s|%d" % (f, s, k + 1), "deliv") - md(E, "G|%s|%s|%d" % (f, s, k), "deliv"), "G|%s|%s|+%d" % (f, s, k + 1)))
allst = steps + curve_steps + gr_steps
w1 = min(allst)
gate(1, "ekleme_dusurmez", "her ekleme >= -1 puan/hf", w1[0] >= -1.0 - 1e-9,
     "en kotu %s (%s); marjinal tablo %s, egri %s, kurucu buyumesi %s adim" % (f1(w1[0]), w1[1], f1(min(steps)[0]), f1(min(curve_steps)[0]), len(gr_steps)))


# --- 2 kurucu_buyume
def fshare(n):
    st = [md(E, n, "founder_st", i) for i in range(4)]
    t = sum(st) or 1
    return [x / t for x in st]


shared = []; worst_base = (0, None); worst_step = (0, None); noreason = []; drops = 0; minstep = (99, None); mvp_late = []
for f in FOUNDERS:
    for s in SEQS:
        n0 = "G|%s|%s|0" % (f, s)
        base = md(E, n0, "founder_w")
        for k in range(1, 4):
            n = "G|%s|%s|%d" % (f, s, k)
            pn_ = "G|%s|%s|%d" % (f, s, k - 1)
            fw, pf = md(E, n, "founder_w"), md(E, pn_, "founder_w")
            d_b, d_s = fw / base - 1, fw / pf - 1
            if d_b < worst_base[0]: worst_base = (d_b, (f, s, k))
            if d_s < worst_step[0]: worst_step = (d_s, (f, s, k))
            dd = md(E, n, "deliv") - md(E, pn_, "deliv")
            if dd < minstep[0]: minstep = (dd, (f, s, k))
            if md(E, n, "mvp") > md(E, pn_, "mvp"): mvp_late.append((f, s, k))
            if fw < pf * 0.98:
                drops += 1
                a, b_ = fshare(pn_), fshare(n)
                dom = a.index(max(a)) != b_.index(max(b_))
                big = max(abs(x - y) for x, y in zip(a, b_)) >= 0.20
                if not (dom or big):
                    noreason.append((f, s, k, round(100 * d_s, 1)))
                    fa = [md(E, pn_, "founder_st", i) for i in range(4)]
                    fb = [md(E, n, "founder_st", i) for i in range(4)]
                    sa = [md(E, pn_, "stage_w", i) for i in range(4)]
                    sb = [md(E, n, "stage_w", i) for i in range(4)]
                    ss = min(range(4), key=lambda i: fb[i] - fa[i])
                    shared.append(sb[ss] > 0 and fb[ss] / sb[ss] < fa[ss] / sa[ss] - 0.02)
g2ok = (worst_base[0] >= -0.10 - 1e-9) and not noreason and not mvp_late and minstep[0] > 0
gate(2, "kurucu_buyume", "teslim her adimda artar; MVP gecikmez; kurucu isi <= %10 duser, nedeni kayitta", g2ok,
     "teslim en kucuk artis %s (%s); MVP gecikme %d; kurucu isi tabana gore en cok %s (%s), onceki adima gore %s (%s); nedensiz dusus %d/%d" % (
         f1(minstep[0]), "/".join(map(str, minstep[1])), len(mvp_late), pct(-worst_base[0]), "/".join(map(str, worst_base[1])), pct(-worst_step[0]), "/".join(map(str, worst_step[1])), len(noreason), drops),
     "nedensiz (asama degismeden >%%2 dusus): %s; bunlardan 'is bolundu' (kurucunun payi dusen asamada ekip isi arttigi icin) aciklananlar %d/%d" % (noreason, sum(shared), len(shared)))

# --- 3 mvp_tek_kurucu
mv = [m["mvp"] for m in A["S1"].values()]
gate(3, "mvp_tek_kurucu", "6 ile 7. hafta", all(6 <= x <= 7 for x in mv), "6. hafta %d tohum, 7. hafta %d tohum" % (mv.count(6), mv.count(7)))

# --- 4 kisi_basi_olcek
r5, r6 = md(A, "S5", "per_person") / md(A, "S3", "per_person"), md(A, "S6", "per_person") / md(A, "S3", "per_person")
gate(4, "kisi_basi_olcek", "S3'un %70 ile %150'si", 0.7 <= r5 <= 1.5 and 0.7 <= r6 <= 1.5,
     "S5 %s, S6 %s (kisi basi %s, %s, %s)" % (pct(r5), pct(r6), f1(md(A, "S3", "per_person")), f1(md(A, "S5", "per_person")), f1(md(A, "S6", "per_person"))))

# --- 5 darbogaz_rolu
pairs = [("S8 + Test kutulu gelistirici", "S8", "S8_ek_testkutulu_gel"), ("S11 + testci", "S11", "S11_ek_testci"), ("S9a + gelistirici", "S9a", "S9a_ek_gel")]
gate(5, "darbogaz_rolu", "darbogaz rolune kisi eklemek teslimi artirir", all(md(A, b, "deliv") > md(A, a, "deliv") for _, a, b in pairs),
     "; ".join("%s %s -> %s" % (t, f1(md(A, a, "deliv")), f1(md(A, b, "deliv"))) for t, a, b in pairs))

# --- 6 duzeltme_payi, 7 toplam_hata_isi, 8 acik_hata_sinirli
scan = []
for nm, R_ in (("A", A), ("B", B), ("C", C), ("D", D), ("E", E)):
    for n in R_:
        scan.append((n, R_, n))
for pol, R_ in F.items():
    for n in R_:
        scan.append(("%s/%s" % (n, pol), R_, n))
rows = []
for name, R_, key in scan:
    n_ = md(R_, key, "n")
    mm = next(iter(R_[key].values()))
    n_eff = sum(1 for r_ in mm["roles"][0] if r_ != "pm")
    n_ = 1 if n_eff <= 1 else n_
    fe, fl = md(R_, key, "fix_early"), md(R_, key, "fix_late")
    inf = md(R_, key, "infix")
    hsl = tsum(R_, key, "bs_late", 0) / max(1, tsum(R_, key, "bs_late", 1))
    hse = tsum(R_, key, "bs_early", 0) / max(1, tsum(R_, key, "bs_early", 1))
    cons = consec(R_, key)
    sl = md(R_, key, "slope")
    rows.append({"ad": name, "n": n_, "fe": fe, "fl": fl, "inf": inf, "hsl": hsl, "hse": hse, "cons": cons, "slope": sl})
bad6 = []
for r in rows:
    if r["n"] >= 2:
        if (r["fe"] is not None and r["fe"] > 0.30) or r["fl"] > 0.20 or r["hsl"] > 0.05 or r["hse"] > 0.05 or r["cons"]: bad6.append(r["ad"])
    else:
        if (r["fe"] is not None and r["fe"] > 0.50) or r["hsl"] > 0.05 or r["cons"]: bad6.append(r["ad"])
mx_fe = max((r["fe"] for r in rows if r["n"] >= 2 and r["fe"] is not None))
mx_fl = max(r["fl"] for r in rows if r["n"] >= 2)
mx_hs = max(max(r["hsl"], r["hse"]) for r in rows if r["n"] >= 2)
s1 = [r for r in rows if r["n"] == 1]
gate(6, "duzeltme_payi", ">=2 kisi: erken <=30%, gec <=20%, hata sprinti <=5%, ust uste yok; tek kurucu erken <=50%, gec hata sprinti <=5%; dort politikada da", not bad6,
     "%d senaryo: >=2 kisi en yuksek erken %s, gec %s, hata sprinti %s; tek kurucu erken en cok %s, hata sprinti en cok %s" % (
         len(rows), pct(mx_fe), pct(mx_fl), pct(mx_hs), pct(max(r["fe"] for r in s1 if r["fe"] is not None)), pct(max(r["hsl"] for r in s1))), "ihlal: %s" % bad6)
bad7 = []
for r in rows:
    tot = r["fl"] + r["inf"]
    lim = 0.35 if r["n"] == 1 else 0.20
    if tot > lim: bad7.append((r["ad"], round(tot, 3)))
mx7 = max((r["fl"] + r["inf"], r["ad"]) for r in rows if r["n"] >= 2)
mx71 = max((r["fl"] + r["inf"], r["ad"]) for r in rows if r["n"] == 1)
gate(7, "toplam_hata_isi", ">=2 kisi <=%20, tek kurucu <=%35", not bad7, ">=2 kisi en cok %s (%s); tek kurucu en cok %s" % (pct(mx7[0]), mx7[1], pct(mx71[0])), "ihlal: %s" % bad7)
sl_rows = [r for r in rows if "/" not in r["ad"] or r["ad"].endswith("/birak")]
mxs = max((r["slope"], r["ad"]) for r in sl_rows if r["slope"] is not None)
p95 = sorted([m["slope"] for n in A for m in A[n].values() if m["slope"] is not None])
gate(8, "acik_hata_sinirli", "son 20 haftanin egimi <= 0,2 hata/hf (fix_due)", mxs[0] <= 0.2,
     "en buyuk medyan egim %s (%s); A tohum dagilimi %%95 %s" % (f2(mxs[0]), mxs[1], f2(p95[int(0.95 * len(p95))])))

# --- 9 testci_yildizi, 10 testci_degeri
t9 = []; ok9 = True
for lab, pre in (("6 kisi", "T3"), ("12 kisi", "T4"), ("25 kisi", "T5")):
    e1, e5 = md(D, pre + "_1", "esc100"), md(D, pre + "_5", "esc100")
    f_1, f_5 = md(D, pre + "_1", "found_sp"), md(D, pre + "_5", "found_sp")
    red, mul = 1 - e5 / e1, f_5 / f_1
    ok9 &= red >= 0.40 and mul >= 2.0
    t9.append("%s kacan/100 %s -> %s (-%s), bulunan %s -> %s (x%s)" % (lab, f2(e1), f2(e5), pct(red), f2(f_1), f2(f_5), f1(mul)))
cv = sum(m["catch_viol"] for R_ in (A, B, C, D, E) for n in R_ for m in R_[n].values())
gate(9, "testci_yildizi", "1->5 yildiz: kacan/100 puan >= %40 azalir, bulunan >= 2 kat; yakalama en iyi testcinin c'sini asmaz", ok9 and cv == 0, "; ".join(t9) + "; yakalama tavani asimi %d kart" % cv)
t10 = []; ok10 = True
for lab, pre in (("6 kisi", "T3"), ("12 kisi", "T4"), ("25 kisi", "T5")):
    d0, d3 = md(D, pre + "_yok", "deliv"), md(D, pre + "_3", "deliv")
    e0, e3 = md(D, pre + "_yok", "esc100"), md(D, pre + "_3", "esc100")
    ok10 &= d3 >= d0 and (1 - e3 / e0) >= 0.20
    t10.append("%s teslim %s -> %s (+%s), kacan/100 %s -> %s (-%s)" % (lab, f1(d0), f1(d3), pct(d3 / d0 - 1), f2(e0), f2(e3), pct(1 - e3 / e0)))
gate(10, "testci_degeri", "testcisiz yerine 3* testci: teslim dusmez, kacan/100 >= %20 azalir", ok10, "; ".join(t10))

# --- 11 pm_yildizi
t11 = []; ok11 = True; fails11 = []
for lab, pre in (("6 kisi", "PM3"), ("11 kisi", "PM4"), ("23 kisi", "PM5")):
    d1, d5 = md(D, pre + "_1", "deliv"), md(D, pre + "_5", "deliv")
    e1, e5 = md(D, pre + "_1", "esc_card"), md(D, pre + "_5", "esc_card")
    okk = (d5 / d1 - 1) >= 0.10 and (1 - e5 / e1) >= 0.25
    ok11 &= okk
    if not okk: fails11.append(lab)
    t11.append("%s teslim %s -> %s (+%s), kacan/kart %s -> %s (-%s)" % (lab, f1(d1), f1(d5), pct(d5 / d1 - 1), f2(e1), f2(e5), pct(1 - e5 / e1)))
pmsiz = [("S3 PM'siz->PM", md(A, "S3_PMsiz", "deliv"), md(A, "S3", "deliv"), md(A, "S3_PMsiz", "esc_card"), md(A, "S3", "esc_card")),
         ("S4 PM'siz->1 PM", md(A, "S4_PMsiz", "deliv"), md(A, "S4_1PM", "deliv"), md(A, "S4_PMsiz", "esc_card"), md(A, "S4_1PM", "esc_card")),
         ("23 kisi PM'siz->PM(3*)", md(D, "PM5_yok", "deliv"), md(D, "PM5_3", "deliv"), md(D, "PM5_yok", "esc_card"), md(D, "PM5_3", "esc_card"))]
okp = all(b > a and d < c for _, a, b, c, d in pmsiz)
ok11 &= okp
t11.append("PM'siz->PM: " + "; ".join("%s %s -> %s, kacan %s -> %s" % (t, f1(a), f1(b), f2(c), f2(d)) for t, a, b, c, d in pmsiz))
gate(11, "pm_yildizi", "tek PM 1->5 yildiz: teslim >= %10, kacan/kart >= %25 azalir; PM'siz->PM iyilesir", ok11, " | ".join(t11), "kalan: %s" % fails11)

# --- 12 soru_sikligi
qs = {n: pooled_asked(A, n) for n in ("S2", "S3", "S4", "S5", "S10")}
ok12 = all(v <= 1 / 3 + 1e-9 for v in qs.values()) and qs["S3"] >= 0.05 and qs["S4"] >= 0.05
gate(12, "soru_sikligi", "S2-S5, S10: soru <= 1/3; 6 ve 12 kisi >= 1/20", ok12, ", ".join("%s %s" % (k, pct(v)) for k, v in qs.items()) + "; iki 5* testcili 12 kisi %s" % pct(pooled_asked(D, "T4_5")))

# --- 13 soru_politikasi
ok13 = True; diffs = []; oh = []
for n in ("S1", "S3", "S4", "S5", "S6", "S10"):
    ds = [md(F[p], n, "deliv") for p in F]
    spread = (max(ds) - min(ds)) / md(F["birak"], n, "deliv")
    diffs.append((spread, n))
    ob, og = md(F["birak"], n, "open_med"), md(F["hep_gonder"], n, "open_med")
    oh.append((og / ob - 1, n))
    hsn = sum(tsum(F[p], n, "bs_late", 0) for p in F)
    ok13 &= spread <= 0.02 + 1e-9 and og / ob - 1 <= 0.20 + 1e-9 and (n == "S1" or hsn == 0)
gate(13, "soru_politikasi", "dort politikada teslim farki <= %2; hep gonder acik hata medyani <= +%20; hata sprinti yok", ok13,
     "teslim farki en cok %s (%s); hep gonder acik hata artisi en cok %s (%s)" % (pct(max(diffs)[0]), max(diffs)[1], pct(max(oh)[0]), max(oh)[1]),
     "S2 (kapsam disi): birak %s, gonder %s" % (f2(md(F["birak"], "S2", "deliv")), f2(md(F["gonder"], "S2", "deliv"))))

# --- 14 tahmin_sonuc
allp = 0.0; nrun = 0
for R_ in (A, B, C, D, E, G, H, H2, I, R) + tuple(F.values()):
    for n in R_:
        for m in R_[n].values():
            allp = max(allp, m["pred"]); nrun += 1
gate(14, "tahmin_sonuc", "plan-kapanis farki <= 1e-6", allp <= 1e-6, "en buyuk fark %.1e (%d kosu; kart basina asama ilerlemesi, bitis, n, F, duzeltme isi)" % (allp, nrun))


# --- 15 a_sinirlari_oranli
def d5_hit(m, nl=None):
    openw, delw, livew, mvp = m["openw"], m["delw"], m["livew"], m["mvp"]
    for i in range(len(openw)):
        wk = i + 1
        if mvp is None or wk <= mvp: continue
        d8 = statistics.mean(delw[max(0, i - 7):i + 1])
        lv = livew[i] if nl is None else min(nl, livew[i])
        k = max(1.0, lv / 9.0, math.sqrt(d8 / 55.0))
        if openw[i] >= 30 * k: return wk - mvp
    return None


t15 = []; ok15 = True
for b in BASES:
    hit = [d5_hit(m) for m in I["D5|%s|nofix" % b].values()]
    hit9 = [d5_hit(m, 9) for m in I["D5|%s|nofix" % b].values()]
    okh = [h for h in hit if h is not None]
    okh9 = [h for h in hit9 if h is not None]
    fixhit = sum(1 for m in I["D5|%s|fix" % b].values() if d5_hit(m) is not None)
    med = statistics.median(okh) if len(okh) == 20 else None
    med9 = statistics.median(okh9) if len(okh9) == 20 else None
    ok15 &= med is not None and 10 <= med <= 26 and med9 is not None and 10 <= med9 <= 26 and fixhit == 0
    t15.append("%s %s hf (9 hat: %s), fix_due %d/20" % (b, f1(med) if med else "-", f1(med9) if med9 else "-", fixhit))
gate(15, "a_sinirlari_oranli", "hic duzeltmeyen 10-26 haftada k x 30'a varir; fix_due varmaz", ok15, "; ".join(t15))

# --- 16 arz_havuzu
pools = {n: md(G, n, "pool_ok") for n in G if n.startswith("A|") and "kaynakli" in n}
lowp = {n: v for n, v in pools.items() if v < 0.90}
gc = md(G, "GC|kaynakli", "pool_ok")
gate(16, "arz_havuzu", "kaynakli arzda sprintlerin >= %90'inda acik aday >= 0,75 x ekip (8 kisi altinda >= ekip)", not lowp and gc >= 0.9,
     "buyume egrisi %s; sabit ekipler (2 hf sprint): " % pct(gc) + ", ".join("%s %s" % (n.split("|")[1], pct(pools[n])) for n in sorted(pools) if n.endswith("|2")) +
     "; 330 hesapta S5 %s, S6 %s" % (pct(md(R, "R|S5|330", "pool_ok")), pct(md(R, "R|S6|330", "pool_ok"))),
     "altinda: %s" % {k: round(v, 2) for k, v in lowp.items()})

# --- 17 bosta_nedenli
tot = nne = 0; hi = []
for R_ in (A, B, C, D, E, G, H, I, R):
    for n in R_:
        for m in R_[n].values():
            tot += 1
            if m["idle_pct"] > 0.10:
                hi.append(n)
                if abs(sum(m["why"].values()) - m["idle_w"]) > 1e-6: nne += 1
gate(17, "bosta_nedenli", "bosta <= %10; degilse her sprintte neden yazili", nne == 0, "%d kosunun %d'inde bosta > %%10; hepsinde neden var (nedensiz: %d)" % (tot, len(hi), nne))

# --- 18 kart_yok_sprinti
nc = md(G, "GC|kaynakli", "nocard")
ncs = md(G, "GC|sonlu", "nocard")
gate(18, "kart_yok_sprinti", "buyume egrisi 130 hf: 'planlanacak kart kalmadi' sprinti <= %5", nc <= 0.05, "kaynakli %s (sonlu katalog: %s)" % (pct(nc), pct(ncs)))

# --- 19 oneri_dolulugu
fills = {n: md(G, n, "fill_ratio") for n in G if n.startswith("A|") and "kaynakli" in n}
lowf = {n: round(v, 3) for n, v in fills.items() if v < 0.95}
gate(19, "oneri_dolulugu", "onerinin aldigi is / planin alabilecegi >= %95; bot = oneri", not lowf,
     "en dusuk %s (%s); bot onerinin ayni kodunu kullanir (ayri bot yolu yok)" % (pct(min(fills.values())), min(fills, key=fills.get).replace("A|", "")), "altinda: %s" % lowf)

# --- 20 derinlik_kazanci
ratio = DEPTH_GAIN ** 4
areas5 = sum(1 for m in G["A|S6|kaynakli|2"].values() for a in m["depth_area"] if a >= 5)
gate(20, "derinlik_kazanci", "5. kartin kazanci ilkinin <= 1/3'u", ratio <= 1 / 3 + 1e-9,
     "5. kart ilkinin %s'i (0,75^4); S6 kaynakli kosusunda 20 tohumun 80 alanindan %d'inde >=5 derinlik karti bitti" % (pct(ratio), areas5))

# --- 21 istek_payi
ist = []
for b in ("S3", "S4", "S5", "S6"):
    for acc in (100, 330):
        n = "R|%s|%d" % (b, acc)
        ps = [md(R, n, "pts_src", i) for i in range(3)]
        ist.append("%s/%d hesap: %s" % (b, acc, pct(ps[0] / sum(ps))))
gate(21, "istek_payi", "raporlanir (hedef yok)", True, "teslim puaninda istek payi " + "; ".join(ist))


# --- 22 takim_bolme
def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk


def wmed(R_, n, a, b): return statistics.median([win(m, a, b) for m in R_[n].values()])


e0 = (wmed(H, "EA0", 20, 60), wmed(H, "EA0", 66, 130))
res22 = {n: (wmed(H, n, 20, 60), wmed(H, n, 66, 130)) for n in ("EA3", "EA7", "EA3_lidersiz", "EA7_lidersiz", "EA1")}
marg = []
for tn in ("EA3", "EA7"):
    for ak in EA_ADD:
        n = "%s %s" % (tn, ak)
        marg.append((wmed(H2, n, 20, 60) - wmed(H2, tn, 20, 60), n + " (21-60)"))
        marg.append((wmed(H2, n, 66, 130) - wmed(H2, tn, 66, 130), n + " (67-130)"))
wm = min(marg)
c1 = all(res22[n][1] >= e0[1] for n in ("EA3", "EA7"))
c2 = res22["EA7_lidersiz"][1] < e0[1]
c3 = wm[0] >= -1.0
gate(22, "takim_bolme", "liderli 3 ve 7 takim takimsizdan geri kalmaz ya da fark takim satirinda yazili; lidersiz 7 takim takimsizdan yavas; kisi eklemek dusurmez (-1)", c1 and c2 and c3,
     "67-130. hf teslim: takimsiz %s, 1 takim %s, 3 takim %s, 7 takim %s, lidersiz 3 %s, lidersiz 7 %s; kisi eklemede en kotu %s (%s)" % (
         f1(e0[1]), f1(res22["EA1"][1]), f1(res22["EA3"][1]), f1(res22["EA7"][1]), f1(res22["EA3_lidersiz"][1]), f1(res22["EA7_lidersiz"][1]), f1(wm[0]), wm[1]),
     "c1 (geri kalmaz) %s, c2 (lidersiz yavas) %s, c3 (ekleme) %s" % (c1, c2, c3))

# --- 23 uymayan_moral
mr = [m["morale"][0][m["roles"][0].index("pm")] for m in A["S3_PM_testkutulu"].values()]
gate(23, "uymayan_moral", "S3 + PM'in Test kutusu: 60 haftada 60 ile 90 moral kaybi", 60 <= -statistics.median(mr) <= 90,
     "PM medyan %d (en az %d, en cok %d)" % (statistics.median(mr), max(mr), min(mr)))

for g in GATES:
    print("%2d %-18s %-6s %s" % (g["no"], g["ad"], "GECTI" if g["gecti"] else "KALDI", g["deger"]))
    if g["kanit"]: print("     kanit:", g["kanit"])
json.dump(GATES, open("out/gates.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
