# D0t.2 · sim_g0.py ciktilarindan tablolar. Calistirma:  python -I ozet.py [etiket] > out/ozet.md
import os, sys, pickle, statistics, math
sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
TAG = sys.argv[1] if len(sys.argv) > 1 else "main"
TEAMS = [("S1", 1), ("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)]
AREAS = ["Çekirdek", "Onboarding", "Entegrasyonlar", "Güven & Ölçek"]
LINES_OF = [[0, 1, 2, 3, 4], [5], [6], [7, 8]]


def tr(x, d=1):
    return ("%." + str(d) + "f") % x if x is not None else "—"


def trc(x, d=1):
    return tr(x, d).replace(".", ",")


def load(v, s):
    f = os.path.join(HERE, "out", TAG, v.replace(":", "_") + "__DEP_" + s + ".pkl")
    try:
        return pickle.load(open(f, "rb"))
    except Exception:
        return {}


def med(xs):
    xs = [x for x in xs if x is not None]
    return statistics.median(xs) if xs else None


def table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "|".join(["---"] * len(head)) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c) for c in r) + " |")
    return "\n".join(out)


def sec(name, body):
    print("<!-- T:%s -->" % name)
    print(body)
    print("<!-- /T:%s -->\n" % name)


def ns(d):
    return len(d)


# ---- S1: tuketim (orig = D0s, map = gercek alan eslemesi)
rows = []
for s, n in TEAMS:
    for v in ("orig", "map"):
        d = load(v, s)
        if not d:
            continue
        seq = [m["depth_seq"] for m in d.values()]
        per_line_med = med([statistics.median(x) for x in seq])
        top = med([max(x) for x in seq])
        total = med([sum(x) for x in seq])
        area_fin = med([sum(m["depth_area"]) for m in d.values()])
        late = med([max(0.0, 1 - 4 * 11 / max(1, sum(m["depth_area"]))) for m in d.values()])
        row = [n, "D0s taban" if v == "orig" else "gerçek alan eşlemesi", ns(d), trc(per_line_med), trc(top), trc(total, 0), trc(area_fin, 0), "%s%%" % trc(100 * late, 0)]
        rows.append(row)
sec("S1", table(["Ekip", "Okuma", "Tohum", "Hat başına açılan kart: medyan hat", "en çok kullanılan hat", "Ürün başına açılan (9 hat)", "Ürün başına biten", "Biten kartların 11/alan (%95 serisi) ötesindeki payı"], rows))

# ---- S1b: hat basina dagilim (map)
rows = []
for s, n in TEAMS:
    d = load("map", s)
    if not d:
        continue
    row = [n]
    for a, ls in enumerate(LINES_OF):
        row.append(trc(med([statistics.mean([m["depth_seq"][l] for l in ls]) for m in d.values()]), 0))
    rows.append(row)
sec("S1b", table(["Ekip"] + ["%s (hat başına ortalama açılan)" % a for a in AREAS], rows))

# ---- S2: varyantlar
VARS = [("orig", "D0s taban"), ("map", "taban, gerçek alan"), ("cut2:0.125", "kesik 2★ · g₀ 0,125"), ("cut2:0.25", "kesik 2★ · g₀ 0,25"), ("cut2:0.5", "kesik 2★ · g₀ 0,5"),
        ("cut3:0.125", "kesik 3★ · g₀ 0,125"), ("cut3:0.25", "kesik 3★ · g₀ 0,25"), ("cut3:0.5", "kesik 3★ · g₀ 0,5"),
        ("ser:8", "seri tavanı 8/alan"), ("ser:9", "seri tavanı 9/alan"), ("ser:11", "seri tavanı 11/alan"), ("ser:17", "seri tavanı 17/alan")]
rows = []
for v, lab in VARS:
    row = [lab]
    for s, n in TEAMS:
        d = load(v, s)
        row.append(trc(med([sum(m["depth_seq"]) for m in d.values()]), 0) if d else "—")
    rows.append(row)
sec("S2_acilan", table(["Varyant (ürün başına açılan derinlik kartı, medyan)"] + ["%d kişi" % n for s, n in TEAMS], rows))

rows = []
for v, lab in VARS:
    row = [lab]
    for s, n in TEAMS:
        d = load(v, s)
        row.append(trc(med([m["deliv"] for m in d.values()])) if d else "—")
    rows.append(row)
sec("S2_teslim", table(["Varyant (teslim, puan/hf, 21-104. hafta medyanı)"] + ["%d kişi" % n for s, n in TEAMS], rows))

rows = []
for v, lab in VARS:
    row = [lab]
    for s, n in TEAMS:
        d = load(v, s)
        row.append("%s%%" % trc(100 * med([m["idle_pct"] for m in d.values()]), 0) if d else "—")
    rows.append(row)
sec("S2_bosta", table(["Varyant (boşta payı)"] + ["%d kişi" % n for s, n in TEAMS], rows))

rows = []
for v, lab in VARS:
    row = [lab]
    for s, n in TEAMS:
        d = load(v, s)
        row.append("%s%%" % trc(100 * med([m["nocard"] for m in d.values()]), 0) if d else "—")
    rows.append(row)
sec("S2_nocard", table(["Varyant (planlanacak kart kalmayan sprint payı)"] + ["%d kişi" % n for s, n in TEAMS], rows))

# ---- S3: zamanlama (sprint = 2 hafta, 0'dan sayilir)
rows = []
for s, n in TEAMS:
    row = [n]
    d = load("map", s)
    row.append(trc(med([min(x for x in m["k3_sprint"] if x is not None) if any(x is not None for x in m["k3_sprint"]) else None for m in d.values()]), 0))
    row.append(trc(med([max(m["k3_sprint"]) if all(x is not None for x in m["k3_sprint"]) else None for m in d.values()]), 0))
    row.append(trc(med([m["first_depth"][0] for m in d.values()]), 0))
    for v in ("cut2:0.25", "cut3:0.25"):
        d = load(v, s)
        row.append(trc(med([m["cut_sprint"][0] for m in d.values()]), 0))
        row.append(trc(med([m["first_depth"][0] for m in d.values()]), 0))
    rows.append(row)
sec("S3", table(["Ekip", "İlk hat K3 (sprint)", "Dokuz hat da K3 (sprint)", "Kesiksiz: Çekirdek'te ilk derinlik kartı", "2★ kesik: Çekirdek kesiğe varış", "2★ kesik: ilk derinlik kartı", "3★ kesik (g₀ 0,25): Çekirdek kesiğe varış", "3★ kesik: ilk derinlik kartı"], rows))

# ---- S4: bitis seviyesi (kesik varyantlarinda alan seviyesi)
rows = []
for v in ("cut2:0.25", "cut3:0.25", "cut3:0.5", "ser:9"):
    for s, n in TEAMS:
        d = load(v, s)
        if not d:
            continue
        rows.append([v, n] + [trc(med([m["lvl_end"][a] for m in d.values()]), 2) for a in range(4)] + [trc(med([sum(m["depth_area"]) for m in d.values()]), 0)])
sec("S4", table(["Varyant", "Ekip", "Bitiş seviyesi: Çekirdek", "Onboarding", "Entegrasyonlar", "Güven & Ölçek", "Biten derinlik kartı (ürün)"], rows))

# ---- S5: ad yeter mi: hat basina en cok kart vs ad sayisi (min 8)
rows = []
for v, lab in VARS:
    row = [lab]
    for s, n in TEAMS:
        d = load(v, s)
        if not d:
            row.append("—")
            continue
        top = med([max(m["depth_seq"]) for m in d.values()])
        over8 = med([sum(1 for x in m["depth_seq"] if x > 8) for m in d.values()])
        over6 = med([sum(1 for x in m["depth_seq"] if x > 6) for m in d.values()])
        row.append("%s · >6: %s · >8: %s" % (trc(top, 0), trc(over6, 0), trc(over8, 0)))
    rows.append(row)
sec("S5", table(["Varyant (en kullanılan hattaki kart · 6'yı aşan hat sayısı · 8'i aşan hat sayısı, medyan, 9 hat)"] + ["%d kişi" % n for s, n in TEAMS], rows))

# ---- S6: teslim puaninin kaynagi (D0s taban, kesiksiz)
rows = []
for s, n in TEAMS:
    d = load("orig", s)
    if not d:
        continue
    t = [sum(m["pts_src"]) for m in d.values()]
    r = med([m["pts_src"][0] for m in d.values()])
    dp = med([m["pts_src"][1] for m in d.values()])
    tp = med([m["pts_src"][2] for m in d.values()])
    rows.append([n, trc(tp, 0), trc(r, 0), trc(dp, 0), "%s%%" % trc(100 * med([m["pts_src"][1] / sum(m["pts_src"]) for m in d.values()]), 0)])
sec("S6", table(["Ekip", "Kademe kartı puanı (27 kart)", "İstek kartı puanı", "Derinlik kartı puanı", "Derinlik payı (teslim puanı)"], rows))
