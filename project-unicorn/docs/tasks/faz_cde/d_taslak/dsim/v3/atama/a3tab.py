# A3 tablolari: out/<etiket>/<kol>__<senaryo>.pkl -> markdown (stdout). python -I a3tab.py <tablo> [...]
import os, sys, pickle, statistics, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")
SC = ["S1", "S2", "S3", "S4", "S5", "S6"]
NP = {"S1": 1, "S2": 3, "S3": 6, "S4": 12, "S5": 25, "S6": 50, "S4_1PM": 11, "S5_1PM": 23, "S6_2PM": 46, "S3_PMsiz1": 10}
NPM = {"S1": 0, "S2": 0, "S3": 1, "S4": 2, "S5": 3, "S6": 6, "S4_1PM": 1, "S5_1PM": 1, "S6_2PM": 2, "S3_PMsiz1": 1}
LAB = {"L": "Eski kural (D3_LEGACY)", "R": "R (D0s önerisi)", "E": "Tarif (ana okuma)", "E_np": "Tarif, kişi hafta başı yeniden", "E_asama": "Tarif, yeten = sprintin tamamı", "E_gsira": "Tarif, kalan kartlar gereksinim sırasıyla", "E_min": "Tarif, en iyiler: yetecek kadar",
       "E_sert": "Tarif, kapılar 1★ sert", "E_gyok": "Tarif, gereksinim yok", "E_pmr": "Tarif atama + R'nin PM'i", "R_pme": "R atama + tarifin PM'i", "E_gate": "Tarif + PM kapısı", "R_gate": "R + PM kapısı",
       "RND": "Rastgele atama", "REV": "Ters atama", "USTA": "Usta oyuncu, net iş ölçüsü", "USTA1": "Usta oyuncu, teslim ölçüsü", "E_uyari": "Tarif + uyarıyı dinleyen", "R_uyari": "R + uyarıyı dinleyen"}


def load(tag, arm, scen):
    f = os.path.join(HERE, "out", tag, arm + "__" + scen.replace("|", "_").replace(" ", "_") + ".pkl")
    try:
        return pickle.load(open(f, "rb"))
    except Exception:
        return {}


def med(xs):
    xs = [x for x in xs if x is not None]
    return statistics.median(xs) if xs else None


def mean_se(xs):
    xs = [x for x in xs if x is not None]
    if len(xs) < 2:
        return (xs[0] if xs else None), None
    m = sum(xs) / len(xs)
    return m, statistics.stdev(xs) / math.sqrt(len(xs))


def f1(x, d=1):
    return "-" if x is None else ("%." + str(d) + "f") % x


def pct(x, d=1):
    return "-" if x is None else ("%." + str(d) + "f%%") % (100 * x)


def cause_share(m, key, scen):
    base = scen.split("|")[-1]
    d = m.get("detail")
    if d is None or not m.get("wkwin"):
        return None
    return d.get(key, 0.0) / (m["n"] * m["wkwin"])


def idle_nonpm(m, scen):
    base = scen.split("|")[-1]
    d = m.get("detail")
    if d is None:
        return None
    wk = m["wkwin"]
    tot = m["idle_w"] * wk
    pmleft = d.get("pm_bosta", 0.0)
    n = m["n"] - NPM.get(base, 0)
    return (tot - pmleft) / (n * wk) if n > 0 else None


def promised(m):
    p = m.get("prom")
    if not p or not p["due"]:
        return None
    return (p["late"] + p["undel"]) / p["due"]


METRICS = {
    "teslim": (lambda m, s: m["deliv"], lambda x: f1(x, 1)),
    "bosta": (lambda m, s: m["idle_pct"], pct),
    "bosta_pmsiz": (lambda m, s: idle_nonpm(m, s), pct),
    "mvp": (lambda m, s: m["mvp"], lambda x: f1(x, 1)),
    "hata": (lambda m, s: m["open_med"], lambda x: f1(x, 1)),
    "doluluk": (lambda m, s: m["fillplan"], pct),
    "cekme": (lambda m, s: m["pulls"], lambda x: f1(x, 2)),
    "kacan_soz": (lambda m, s: promised(m), pct),
    "kacan100": (lambda m, s: m["esc100"], lambda x: f1(x, 2)),
}


def table(tag, arms, metric, scens=SC, title=None, pre="", common=False):
    fn, fm = METRICS[metric]
    hdr = "| Kol | " + " | ".join("%s (%d kişi)" % (s.split("|")[-1], NP[s.split("|")[-1]]) for s in scens) + " |"
    out = [hdr, "|---|" + "---|" * len(scens)]
    seeds = {}
    if common:
        for s in scens:
            ss = None
            for a in arms:
                k = set(load(tag, a, pre + s))
                ss = k if ss is None else ss & k
            seeds[s] = ss
    for a in arms:
        row = []
        for s in scens:
            r = load(tag, a, pre + s)
            if common:
                r = {k: v for k, v in r.items() if k in seeds[s]}
            row.append(fm(med([fn(m, pre + s) for m in r.values()])) + (" (n=%d)" % len(r) if common else "") if r else "-")
        out.append("| %s | %s |" % (LAB.get(a, a), " | ".join(row)))
    return "\n".join(out)


def paired(tag, a, b, scen, metric):
    fn = METRICS[metric][0]
    ra, rb = load(tag, a, scen), load(tag, b, scen)
    seeds = sorted(set(ra) & set(rb))
    d = []
    for sd in seeds:
        x, y = fn(ra[sd], scen), fn(rb[sd], scen)
        if x is not None and y is not None:
            d.append(x - y)
    m, se = mean_se(d)
    return m, se, sum(1 for v in d if v < 0), len(d)


def paired_table(tag, pairs, metric, scens=SC, pre="", fmt=lambda x: f1(x, 1)):
    out = ["| Fark (a − b) | " + " | ".join("%s" % s.split("|")[-1] for s in scens) + " |", "|---|" + "---|" * len(scens)]
    for a, b in pairs:
        row = []
        for s in scens:
            m, se, neg, n = paired(tag, a, b, pre + s, metric)
            row.append("-" if m is None else ("%s ± %s (%d/%d)" % (fmt(m), fmt(se) if se is not None else "-", neg, n)))
        out.append("| %s − %s | %s |" % (a, b, " | ".join(row)))
    return "\n".join(out)


CAUSES = [("uyan_is_yok", "(a) uyan iş yok"), ("kart_yok", "(a) kart bitti"), ("hazirlik", "(b) PM hazırlığı"), ("gereksinim", "(c) gereksinim"),
          ("kadro", "(d) kadro tavanı"), ("kural", "(e) kural/diğer"), ("pm_bosta", "PM'in kendi boş zamanı")]


def cause_table(tag, arm, scens=SC, pre=""):
    out = ["| Neden (kişi-hafta payı) | " + " | ".join(s.split("|")[-1] for s in scens) + " |", "|---|" + "---|" * len(scens)]
    rs = {s: load(tag, arm, pre + s) for s in scens}
    for key, lab in CAUSES:
        row = []
        for s in scens:
            r = rs[s]
            row.append(pct(med([cause_share(m, key, pre + s) for m in r.values()]), 2) if r else "-")
        out.append("| %s | %s |" % (lab, " | ".join(row)))
    return "\n".join(out)


def warn_eval(tag, arm, scen, thetas=(1.0, 1.1, 1.25, 1.4, 1.6), x=0.25, which="plan"):
    """Plan aninda satir yuku / kapasite > teta  ->  'bu asama tasacak'; gercek: sprint sonunda satirda kalan is / kapasite >= x."""
    r = load(tag, arm, scen)
    res = []
    for th in thetas:
        tp = fp = fn = tn = 0
        sp_w = sp_n = 0
        for m in r.values():
            for row in m.get("rows", ()):
                pr = row[which]
                tr = row["true"]
                anyw = False
                for j in range(3):
                    p, t = pr[j] > th, tr[j] >= x
                    tp += p and t
                    fp += p and not t
                    fn += (not p) and t
                    tn += (not p) and (not t)
                    anyw = anyw or p
                sp_w += 1 if anyw else 0
                sp_n += 1
        res.append((th, tp, fp, fn, tn, sp_w, sp_n))
    return res


def warn_table(tag, arm, scens=SC, pre="", which="plan", thetas=(1.0, 1.1, 1.25, 1.4, 1.6)):
    out = ["| Ölçek | Eşik (yük ÷ kapasite) | İsabet (precision) | Yakalama (recall) | Uyarı çıkan sprint | Gerçek taşma olan satır payı |", "|---|---|---|---|---|---|"]
    for s in scens:
        for (th, tp, fp, fn, tn, sw_, sn) in warn_eval(tag, arm, pre + s, thetas, which=which):
            if sn == 0:
                continue
            P = tp / (tp + fp) if tp + fp else None
            Rr = tp / (tp + fn) if tp + fn else None
            out.append("| %s | > %.2f | %s | %s | %s | %s |" % (s, th, pct(P, 0), pct(Rr, 0), pct(sw_ / sn, 0), pct((tp + fn) / (tp + fp + fn + tn), 0)))
    return "\n".join(out)


def stab_table(tag, arms, scens=SC):
    out = ["| Kol | " + " | ".join(s for s in scens) + " |", "|---|" + "---|" * len(scens)]
    for a in arms:
        row = []
        for s in scens:
            r = load(tag, a, s)
            tot = sum(m["stab"]["in_total"] + m["stab"]["bd_total"] for m in r.values()) if r else 0
            ch = sum(m["stab"]["in_ch"] + m["stab"]["bd_ch"] for m in r.values()) if r else 0
            tin = sum(m["stab"]["in_total"] for m in r.values()) if r else 0
            cin = sum(m["stab"]["in_ch"] for m in r.values()) if r else 0
            tbd = sum(m["stab"]["bd_total"] for m in r.values()) if r else 0
            cbd = sum(m["stab"]["bd_ch"] for m in r.values()) if r else 0
            row.append("-" if not tot else "%s / %s" % (pct(cin / tin if tin else None, 0), pct(cbd / tbd if tbd else None, 0)))
        out.append("| %s | %s |" % (LAB.get(a, a), " | ".join(row)))
    return "\n".join(out)


def decisions(m, scen):
    """Sprint basinda oyuncunun yeniden karar vermesi gereken kisi sayisi (kartinda devam edenler haric), ortalama."""
    st = m.get("stab")
    if not st or not m.get("wkwin"):
        return None
    nb = len([o for o in range(21, 20 + m["wkwin"]) if o % 2 == 0])
    if nb <= 0:
        return None
    cont = (st["bd_total"] - st["bd_ch"]) / nb
    return m["n"] - cont


METRICS["karar"] = (lambda m, s: decisions(m, s), lambda x: f1(x, 1))


if __name__ == "__main__":
    tag = sys.argv[2] if len(sys.argv) > 2 else "main"
    c = sys.argv[1]
    arms = sys.argv[3].split(",") if len(sys.argv) > 3 else ["L", "R", "E"]
    if c in METRICS:
        print(table(tag, arms, c))
    elif c == "cause":
        print(cause_table(tag, arms[0]))
    elif c == "stab":
        print(stab_table(tag, arms))
    elif c == "warn":
        print(warn_table(tag, arms[0]))
