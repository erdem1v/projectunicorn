# A6 tablolari: out6/<etiket>/<kal>/<kol>__<senaryo>.pkl -> markdown (stdout). python -I a6tab.py <tablo> [...]
import os, sys, pickle, statistics, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")
SC = ["S1", "S2", "S3", "S4", "S5", "S6"]
PRS = ["PR|" + s for s in SC]
NP = {"S1": 1, "S2": 3, "S3": 6, "S4": 12, "S5": 25, "S6": 50}
NPM = {"S1": 0, "S2": 0, "S3": 1, "S4": 2, "S5": 3, "S6": 6}
LAB = {"R": "R (bugünkü kural)", "T": "Tarif (PM: en basit en zayıf)", "BK": "Kalan kartlar büyükten küçüğe", "T_zor": "Tarif, PM: zor karta en iyi, kalanlar sırayla",
       "T_d": "Tarif, PM (i) + hata azaltması Δ_PM'e bağlı", "T_zord": "Tarif, PM (ii) + Δ_PM", "E": "A3 tarifi (PM: yeten en düşük)", "T_plan": "Tanı kolu T_plan (1. adım plan sırasıyla; tarif değil)"}


def load(tag, cal, arm, scen):
    f = os.path.join(HERE, "out6", tag, str(cal), arm + "__" + scen.replace("|", "_").replace(" ", "_") + ".pkl")
    try:
        return pickle.load(open(f, "rb"))
    except Exception:
        return {}


def idle_nonpm(m, scen):
    base = scen.split("|")[-1]
    d = m.get("detail")
    wk = m["wkwin"]
    if d is None or not wk:
        return None
    n = m["n"] - NPM.get(base, 0)
    return (m["idle_w"] * wk - d.get("pm_bosta", 0.0)) / (n * wk) if n > 0 else None


def promised(m, scen):
    p = m.get("prom")
    if not scen.startswith("PR|") or not p or not p["due"]:
        return None
    return (p["late"] + p["undel"]) / p["due"]


METRICS = {
    "teslim": (lambda m, s: m["deliv"], lambda x: "%.1f" % x),
    "acik": (lambda m, s: m["open_med"], lambda x: "%.1f" % x),
    "dogan": (lambda m, s: m["born"], lambda x: "%.1f" % x),
    "beklenen": (lambda m, s: m["H"], lambda x: "%.1f" % x),
    "kacan": (lambda m, s: m["esc"], lambda x: "%.1f" % x),
    "soz": (promised, lambda x: "%.1f%%" % (100 * x)),
    "mvp": (lambda m, s: m["mvp"], lambda x: "%.1f" % x),
    "bosta": (idle_nonpm, lambda x: "%.1f%%" % (100 * x)),
    "altinda": (lambda m, s: m["wbelow"] / m["wdev"] if m["wdev"] else None, lambda x: "%.1f%%" % (100 * x)),
    "bulunan": (lambda m, s: m["found"], lambda x: "%.1f" % x),
}
DIFFFMT = {"soz": lambda x: "%.1f pp" % (100 * x), "bosta": lambda x: "%.1f pp" % (100 * x), "altinda": lambda x: "%.1f pp" % (100 * x)}


def vals(tag, cal, arm, scen, metric):
    fn = METRICS[metric][0]
    r = load(tag, cal, arm, scen)
    return {sd: fn(m, scen) for sd, m in r.items() if fn(m, scen) is not None}


def mean_se(xs):
    xs = list(xs)
    if not xs:
        return None, None
    if len(xs) < 2:
        return xs[0], None
    m = sum(xs) / len(xs)
    return m, statistics.stdev(xs) / math.sqrt(len(xs))


def cell(tag, cal, arm, scen, metric, se=False):
    v = vals(tag, cal, arm, scen, metric)
    if not v:
        return "-"
    m, s = mean_se(v.values())
    f = METRICS[metric][1]
    return f(m) + (" ± " + f(s) if se and s is not None else "")


def paired(tag, cal, a, b, scen, metric):
    va, vb = vals(tag, cal, a, scen, metric), vals(tag, cal, b, scen, metric)
    d = [va[s] - vb[s] for s in sorted(set(va) & set(vb))]
    m, se = mean_se(d)
    return m, se, sum(1 for x in d if x < 0), len(d)


def dcell(tag, cal, a, b, scen, metric):
    m, se, neg, n = paired(tag, cal, a, b, scen, metric)
    if m is None:
        return "-"
    f = DIFFFMT.get(metric, lambda x: "%+.1f" % x)
    g = DIFFFMT.get(metric, lambda x: "%.1f" % x)
    return "%s ± %s (%d/%d)" % (f(m), g(se) if se is not None else "-", neg, n)


def label(s):
    return ("kaynaklı " if s.startswith("PR|") else "") + "%d kişi" % NP[s.split("|")[-1]]


def main_table(tag, cal, arms=("T", "R", "BK")):
    """Ana tablo: satir = ekip buyuklugu (sinirsiz arz ve kaynakli arz), sutun = kol x (teslim, acik hata, kacan soz)."""
    hdr = "| Ekip | Arz | " + " | ".join("%s: teslim | acik | söz" % a for a in arms) + " |"
    hdr = "| Ekip | Arz | " + " | ".join(("**%s** teslim | açık | söz" % {"T": "Tarif", "R": "R", "BK": "Kalan b→k"}[a]) for a in arms) + " |"
    cols = "| Ekip | Arz |" + "".join(" %s teslim | %s açık | %s söz |" % ((n,) * 3) for n in [{"T": "Tarif", "R": "R", "BK": "BK"}[a] for a in arms])
    out = [cols, "|---|---|" + "---|---|---|" * len(arms)]
    for sc in SC:
        row = "| %d | sınırsız |" % NP[sc]
        for a in arms:
            row += " %s | %s | - |" % (cell(tag, cal, a, sc, "teslim"), cell(tag, cal, a, sc, "acik"))
        out.append(row)
    for sc in SC:
        row = "| %d | kaynaklı |" % NP[sc]
        for a in arms:
            ps = "PR|" + sc
            row += " %s | %s | %s |" % (cell(tag, cal, a, ps, "teslim"), cell(tag, cal, a, ps, "acik"), cell(tag, cal, a, ps, "soz"))
        out.append(row)
    return "\n".join(out)


def metric_table(tag, cal, arms, metric, scens=None, title="Kol"):
    scens = scens or (SC + PRS)
    out = ["| %s | " % title + " | ".join(label(s) for s in scens) + " |", "|---|" + "---|" * len(scens)]
    for a in arms:
        out.append("| %s | %s |" % (LAB.get(a, a), " | ".join(cell(tag, cal, a, s, metric) for s in scens)))
    return "\n".join(out)


def diff_table(tag, cal, pairs, metric, scens=None):
    scens = scens or (SC + PRS)
    out = ["| Fark (a − b) | " + " | ".join(label(s) for s in scens) + " |", "|---|" + "---|" * len(scens)]
    for a, b in pairs:
        out.append("| %s − %s | %s |" % (a, b, " | ".join(dcell(tag, cal, a, b, s, metric) for s in scens)))
    return "\n".join(out)


def ratio_table(tag, arm="R", cals=("H", "0")):
    """Yeni modelin doguran hata hacmi / bugunku, ekip buyuklugune gore (hacim notrluk yalniz 6 kisiyle kalibre)."""
    out = ["| Ayar | " + " | ".join(label(s) for s in SC + PRS) + " |", "|---|" + "---|" * 12]
    for cal in ("H", "E"):
        row = []
        for s in SC + PRS:
            a, b = vals(tag, cal, arm, s, "dogan"), vals(tag, "0", arm, s, "dogan")
            row.append("-" if not a or not b else "%.2f" % (statistics.mean(a.values()) / statistics.mean(b.values())))
        out.append("| %s (yeni ÷ bugünkü doğan hata) | %s |" % ({"H": "K-H", "E": "K-E"}[cal], " | ".join(row)))
    return "\n".join(out)


if __name__ == "__main__":
    tag = "ana"
    c = sys.argv[1]
    cal = sys.argv[2] if len(sys.argv) > 2 else "H"
    if c == "main":
        print(main_table(tag, cal))
    elif c in METRICS:
        print(metric_table(tag, cal, sys.argv[3].split(",") if len(sys.argv) > 3 else ["R", "T", "BK"], c))
    elif c == "ratio":
        print(ratio_table(tag))
