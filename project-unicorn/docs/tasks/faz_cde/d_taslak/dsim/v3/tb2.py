# Rapor tablolari 2: kurucu, arz, EA, D5. python -I dsim3.py exec tb2.py
exec(open("an_common.py", encoding="utf-8").read())
import json
E, G, H, H2, I, R, A = (L(x) for x in ("E", "G", "H", "H2", "I", "R", "A"))


def tr(x, d=1):
    return (("%." + str(d) + "f") % x).replace(".", ",") if x is not None else "-"


def pc(x, d=0):
    return "%" + tr(100 * x, d)


def sp(x, d=0):
    v = 100 * x
    return ("+%" if v >= 0 else "−%") + tr(abs(v), d)


OUT = {}
FN = {"orta": "Orta (ürün 4, yazılım 4)", "gel4": "Güçlü yazılım 4★ (8)", "gel5": "Güçlü yazılım 5★ (10)", "tasarim_test": "Tasarım ve test bilen (4, 6, 4, 6)"}
SQ = {"gel-tas-test": "geliştirici → tasarımcı → testçi", "tas-gel-test": "tasarımcı → geliştirici → testçi", "test-gel-tas": "testçi → geliştirici → tasarımcı",
      "pm-gel-tas": "PM → geliştirici → tasarımcı", "1yildiz": "1★ geliştirici → 1★ tasarımcı → 1★ testçi", "uc-gel": "üç geliştirici"}
rows = ["| Kurucu | Alım sırası | Tek | +1 | +2 | +3 |", "|---|---|---|---|---|---|"]
for f in FN:
    for s in SQ:
        cells = []
        for k in range(4):
            n = "G|%s|%s|%d" % (f, s, k)
            cells.append("%s / %s / %d" % (tr(md(E, n, "deliv")), tr(md(E, n, "founder_w")), md(E, n, "mvp")))
        rows.append("| %s | %s | %s |" % (FN[f], SQ[s], " | ".join(cells)))
OUT["founder"] = "\n".join(rows)

# gercek zaman: alimlar 8, 14, 20. hafta


def phase_means(m):
    wk = {}
    for (s, e, d, *_r) in m["series"]:
        for w in range(s, e):
            wk[w] = d / (e - s)

    def avg(a, b):
        xs = [wk[w] for w in range(a, b) if w in wk]
        return sum(xs) / len(xs) if xs else None
    return [avg(0, 8), avg(8, 14), avg(14, 20), avg(20, 26), avg(26, 40), avg(40, 60)]


rows = ["| Kurucu | Alım sırası | 0-8 hf | 8-14 hf | 14-20 hf | 20-26 hf | 26-40 hf | 40-60 hf | MVP | Alım penceresinde düşen aralık |", "|---|---|---|---|---|---|---|---|---|---|"]
dips = []
for f in FN:
    for s in SQ:
        n = "GT|%s|%s|3" % (f, s)
        ph = [statistics.median([phase_means(m)[i] for m in E[n].values()]) for i in range(6)]
        dip = [("%d-%d" % ((0, 8, 14, 20, 26, 40, 60)[i], (0, 8, 14, 20, 26, 40, 60)[i + 1])) for i in range(1, 4) if ph[i] < ph[i - 1] * 0.97]
        if dip: dips.append((f, s, dip))
        rows.append("| %s | %s | %s | %d | %s |" % (FN[f], SQ[s], " | ".join(tr(x) for x in ph), md(E, n, "mvp"), ", ".join(dip) if dip else "yok"))
OUT["founder_rt"] = "\n".join(rows)
OUT["founder_rt_n"] = "%d / 24 dizide en az bir alım penceresinde (8-14, 14-20, 20-26 hf) teslim önceki pencerenin %%3'ünden fazla düşer" % len(dips)

# arz kipleri
rows = ["| Ekip | Sprint | Arz | Teslim | Boşta payı | Boşta nedenleri (kart yok / aşama dolu / rol uymuyor / hazırlanacak kart yok; kişi-hf / hf) | Açık aday ≥ hedef | Kart yok sprinti | Sprintte kart | Öneri doluluğu |", "|---|---|---|---|---|---|---|---|---|---|"]
for b, k in (("S1", 1), ("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)):
    for sw in (1, 2):
        for arz in ("sonlu", "kaynakli"):
            n = "A|%s|%s|%d" % (b, arz, sw)
            why = [statistics.median([m["why"][kk] for m in G[n].values()]) for kk in ("kart_yok", "asama_dolu", "rol_uymuyor", "hazirlik_yok")]
            fr_ = md(G, n, "fill_ratio")
            rows.append("| %s · %d | %d hf | %s | %s | %s | %s | %s | %s | %s | %s |" % (b, k, sw, "sonlu" if arz == "sonlu" else "kaynaklı", tr(md(G, n, "deliv")), pc(md(G, n, "idle_pct")), " / ".join(tr(x) for x in why),
                                                                                  pc(md(G, n, "pool_ok")), pc(md(G, n, "nocard")), tr(md(G, n, "wip")), pc(fr_) if arz == "kaynakli" else "-"))
OUT["supply"] = "\n".join(rows)

rows = ["| Eğri | Teslim (21-130 hf) | Boşta payı | Açık aday ≥ hedef | Kart yok sprinti | Kart kaynağı (oluşan kart: kademe / derinlik / istek) | Teslim puanında istek / derinlik / kademe | İstek: yapıldı / düştü / kademeye bağlandı |", "|---|---|---|---|---|---|---|---|"]
for n, lab in (("GC|sonlu", "sonlu katalog"), ("GC|kaynakli", "kaynaklı")):
    rq = [md(G, n, "req", i) for i in range(7)]
    ps = [md(G, n, "pts_src", i) for i in range(3)]
    tot = sum(ps)
    rows.append("| %s (1 → 3 → 6 → 10 kişi) | %s | %s | %s | %s | %s / %s / %s | %s / %s / %s | %s / %s / %s |" % (lab, tr(md(G, n, "deliv")), pc(md(G, n, "idle_pct")), pc(md(G, n, "pool_ok")), pc(md(G, n, "nocard"), 1),
                                                                                              tr(rq[6], 0), tr(rq[5], 0), tr(rq[4], 0), pc(ps[0] / tot) if tot else "-", pc(ps[1] / tot) if tot else "-", pc(ps[2] / tot) if tot else "-", tr(rq[3], 0), tr(rq[2], 0), tr(rq[1], 0)))
OUT["growth"] = "\n".join(rows)

rows = ["| Ekip | Hesap | Teslim | İstek kartı payı (oluşan kartlarda) | İstek payı (teslim puanında) | İstek: yapıldı / düştü | Boşta payı | Açık aday ≥ hedef |", "|---|---|---|---|---|---|---|---|"]
for b, k in (("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)):
    for acc in (100, 330):
        n = "R|%s|%d" % (b, acc)
        rq = [md(R, n, "req", i) for i in range(7)]
        ps = [md(R, n, "pts_src", i) for i in range(3)]
        rows.append("| %s · %d | %d | %s | %s | %s | %s / %s | %s | %s |" % (b, k, acc, tr(md(R, n, "deliv")), pc(rq[4] / (rq[4] + rq[5] + rq[6])), pc(ps[0] / sum(ps)), tr(rq[3], 0), tr(rq[2], 0), pc(md(R, n, "idle_pct")), pc(md(R, n, "pool_ok"))))
OUT["istek"] = "\n".join(rows)

# EA


def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk, sum(x[7] * (x[1] - x[0]) for x in ser) / wk, sum(1 for x in ser if x[4]) / len(ser)


def wm(R_, n, a, b, i):
    return statistics.median([win(m, a, b)[i] for m in R_[n].values()])


rows = ["| Düzen | Takım (kişi · hız çarpanı) | Teslim 21-60 hf | Teslim 67-130 hf | Takımsıza göre (67-130) | Boşta payı (67-130) | Kart yok sprinti (21-60) |", "|---|---|---|---|---|---|---|"]
e0 = wm(H, "EA0", 66, 130, 0)
for n, lab in (("EA0", "takımsız (50 kişi)"), ("EA1", "1 takım, lider 6"), ("EA3", "3 takım, liderler 4, 6, 8"), ("EA3_lidersiz", "3 takım, lidersiz"), ("EA7", "7 takım, liderler 2 ile 8"), ("EA7_lidersiz", "7 takım, lidersiz")):
    m = next(iter(H[n].values()))
    tk = ", ".join("%d · ×%s" % (c, tr(x, 2)) for c, x in zip(m["cell_n"], m["cell_mult"]))
    rows.append("| %s | %s | %s | %s | %s | %s | %s |" % (lab, tk, tr(wm(H, n, 20, 60, 0)), tr(wm(H, n, 66, 130, 0)), sp(wm(H, n, 66, 130, 0) / e0 - 1), pc(wm(H, n, 66, 130, 1)), pc(wm(H, n, 20, 60, 2))))
OUT["ea"] = "\n".join(rows)
rows = ["| Eklenen (takım 0'a) | 3 takım: 21-60 / 67-130 hf | 7 takım: 21-60 / 67-130 hf |", "|---|---|---|"]
for ak in EA_ADD:
    cells = []
    for tn in ("EA3", "EA7"):
        n = "%s %s" % (tn, ak)
        d1 = wm(H2, n, 20, 60, 0) - wm(H2, tn, 20, 60, 0)
        d2 = wm(H2, n, 66, 130, 0) - wm(H2, tn, 66, 130, 0)
        cells.append("%s / %s" % (("%+.1f" % d1).replace(".", ","), ("%+.1f" % d2).replace(".", ",")))
    rows.append("| %s | %s |" % (ak.replace("* ", "★ ").replace("gelistirici", "geliştirici").replace("testci", "testçi").replace("tasarimci", "tasarımcı"), " | ".join(cells)))
OUT["ea_marg"] = "\n".join(rows)

# D5


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
            return wk - mvp, 30 * k
    return None, None


def abs30(m):
    for i, v in enumerate(m["openw"]):
        if m["mvp"] is not None and i + 1 > m["mvp"] and v >= 30:
            return i + 1 - m["mvp"]
    return None


rows = ["| Ekip | k × 30 eşiği (sondaki) | Hiç düzeltmeyen: eşiğe varış (MVP'den sonra hf, medyan; en az-en çok) | 9 hat varsayımıyla | Mutlak 30 ile | Düzenli düzelten: tepe (medyan) | Düzenli düzelten eşiğe vardı |", "|---|---|---|---|---|---|---|"]
for b, k in (("S1", 1), ("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)):
    nf, fx = I["D5|%s|nofix" % b], I["D5|%s|fix" % b]
    h = [d5_hit(m)[0] for m in nf.values()]
    h9 = [d5_hit(m, 9)[0] for m in nf.values()]
    ha = [abs30(m) for m in nf.values()]
    thr = statistics.median([d5_hit(m)[1] or 0 for m in nf.values()])
    ok = [x for x in h if x is not None]
    ok9 = [x for x in h9 if x is not None]
    oka = [x for x in ha if x is not None]
    rows.append("| %s · %d | %s | %s (%d-%d) | %s | %s | %s | %d/20 |" % (b, k, tr(thr, 0), tr(statistics.median(ok), 1), min(ok), max(ok), tr(statistics.median(ok9), 1), tr(statistics.median(oka), 1),
                                                                      tr(statistics.median([max(m["openw"]) for m in fx.values()]), 1), sum(1 for m in fx.values() if d5_hit(m)[0] is not None)))
OUT["d5"] = "\n".join(rows)
json.dump(OUT, open("out/tb2.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
for k, v in OUT.items():
    print("##", k)
    print(v)
