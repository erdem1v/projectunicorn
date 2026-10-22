# A8 tablolari. R, T, T_plan, BK kollari A6'nin kayitlarindan (out6/ana/H), P kollari out8/ana/H'den. python -I a8tab.py <tablo>
import os, sys, pickle, statistics, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")
SC = ["S1", "S2", "S3", "S4", "S5", "S6"]
PRS = ["PR|" + s for s in SC]
NP = {"S1": 1, "S2": 3, "S3": 6, "S4": 12, "S5": 25, "S6": 50}
NPM = {"S1": 0, "S2": 0, "S3": 1, "S4": 2, "S5": 3, "S6": 6}
A6ARMS = ("R", "T", "T_plan", "BK", "E")
LAB = {"R": "R (bugünkü kural)", "T": "Tarif (A6, Erdem'in tarifi)", "T_plan": "T_plan (tanı kolu)", "P": "**P (yeni planlayıcı)**", "P_sabit": "P, ileri oynatma yok (tek seçenek)",
       "P_core5": "P, saklama seçeneği yok", "P_ns": "P, ileri oynatma ve yer değişimi yok", "P_np": "P, \"kalır\" kapalı", "P_gyok": "P, gereksinim kapısı yok, hata modelinin gereksinimi de 0 (tanı)",
       "P_kapi_k9": "P, gereksinim kapısı yok, hata modeli aynı (A9 tanı)", "P_pmZ_k9": "P, PM okuması (ii) (A9)", "P_pmR_k9": "P, PM'i R'nin kuralıyla (A9 tanı)",
       "P_rp": "P, satır seçimi eski kural", "T_plan_np": "T_plan, \"kalır\" kapalı (tanı)", "P_r1": "P, plan puanında her kart eşit (ρ = 1)", "P_r85": "P, ρ = 0,85 (ana kolla aynı ayar)", "P_r5": "P, plan puanı sırası sert (ρ = 0,5)"}


def fname(arm, scen, cal="H", tag="ana"):
    d = "out6" if arm in A6ARMS else ("out9" if arm.endswith("_k9") else "out8")      # *_k9: A9 incelemesinin kollari (a9run.py)
    return os.path.join(HERE, d, tag, str(cal), arm + "__" + scen.replace("|", "_").replace(" ", "_") + ".pkl")


def load(arm, scen, cal="H"):
    try:
        return pickle.load(open(fname(arm, scen, cal), "rb"))
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


def _plan_n(m, scen):
    p = m.get("p8")
    if not p or not p.get("nsprints") or not p.get("rollouts"):
        return None
    return p["rollouts"] / p["nsprints"]


def _plan_s(m, scen):
    p = m.get("p8")
    if not p or not p.get("nsprints") or not p.get("rollouts"):
        return None
    return p["secs"] / p["nsprints"]


METRICS = {
    "teslim": (lambda m, s: m["deliv"], lambda x: "%.1f" % x),
    "acik": (lambda m, s: m["open_med"], lambda x: "%.1f" % x),
    "dogan": (lambda m, s: m["born"], lambda x: "%.1f" % x),
    "kacan": (lambda m, s: m["esc"], lambda x: "%.1f" % x),
    "soz": (promised, lambda x: "%.1f%%" % (100 * x)),
    "mvp": (lambda m, s: m["mvp"], lambda x: "%.1f" % x),
    "bosta": (idle_nonpm, lambda x: "%.1f%%" % (100 * x)),
    "bosta_pm": (lambda m, s: m["idle_pct"], lambda x: "%.1f%%" % (100 * x)),
    "altinda": (lambda m, s: m["wbelow"] / m["wdev"] if m["wdev"] else None, lambda x: "%.1f%%" % (100 * x)),
    "plan_n": (_plan_n, lambda x: "%.1f" % x),
    "plan_s": (_plan_s, lambda x: "%.3f" % x),
}
DIFFFMT = {"soz": lambda x: "%.1f pp" % (100 * x), "bosta": lambda x: "%.1f pp" % (100 * x), "bosta_pm": lambda x: "%.1f pp" % (100 * x), "altinda": lambda x: "%.1f pp" % (100 * x)}


def vals(arm, scen, metric, cal="H"):
    fn = METRICS[metric][0]
    r = load(arm, scen, cal)
    return {sd: fn(m, scen) for sd, m in r.items() if fn(m, scen) is not None}


def mean_se(xs):
    xs = list(xs)
    if not xs:
        return None, None
    if len(xs) < 2:
        return xs[0], None
    m = sum(xs) / len(xs)
    return m, statistics.stdev(xs) / math.sqrt(len(xs))


def mean(arm, scen, metric, cal="H"):
    v = vals(arm, scen, metric, cal)
    return mean_se(v.values())[0] if v else None


def cell(arm, scen, metric, se=False, cal="H"):
    v = vals(arm, scen, metric, cal)
    if not v:
        return "-"
    m, s = mean_se(v.values())
    f = METRICS[metric][1]
    return f(m) + (" ± " + f(s) if se and s is not None else "")


def paired(a, b, scen, metric, cal="H"):
    va, vb = vals(a, scen, metric, cal), vals(b, scen, metric, cal)
    d = [va[s] - vb[s] for s in sorted(set(va) & set(vb))]
    m, se = mean_se(d)
    return m, se, sum(1 for x in d if x < 0), len(d)


def dcell(a, b, scen, metric, cal="H"):
    m, se, neg, n = paired(a, b, scen, metric, cal)
    if m is None:
        return "-"
    f = DIFFFMT.get(metric, lambda x: "%+.1f" % x)
    g = DIFFFMT.get(metric, lambda x: "%.1f" % x)
    return "%s ± %s (%d/%d)" % (f(m), g(se) if se is not None else "-", neg, n)


def label(s):
    return ("kaynaklı " if s.startswith("PR|") else "") + "%d kişi" % NP[s.split("|")[-1]]


def both_idle(arm, scen):
    a, b = cell(arm, scen, "bosta"), cell(arm, scen, "bosta_pm")
    return a if a == b else "%s / %s" % (a, b)


def single_table(arms=("P", "R", "T")):
    """TEK TABLO: satir = ekip buyuklugu, sutun = kol x (MVP, acik hata, kacan soz, bosta PM haric / PM dahil, teslim). Kaynakli arz, altinda sinirsiz arz."""
    nm = {"P": "P", "R": "R", "T": "Tarif", "T_plan": "T_plan"}
    hdr = "| Ekip |" + "".join(" %s MVP | %s açık | %s söz | %s boşta | %s teslim |" % ((nm[a],) * 5) for a in arms)
    sep = "|---|" + "---|" * (5 * len(arms))
    out = ["**Kaynaklı arz** (80 hafta, pencere 21-80; söz kartları açık)", "", hdr, sep]
    for sc in SC:
        row = "| %d |" % NP[sc]
        for a in arms:
            ps = "PR|" + sc
            row += " %s | %s | %s | %s | %s |" % (cell(a, ps, "mvp"), cell(a, ps, "acik"), cell(a, ps, "soz"), both_idle(a, ps), cell(a, ps, "teslim"))
        out.append(row)
    out += ["", "**Sınırsız arz** (60 hafta, pencere 21-60; söz kartı yok)", "", "| Ekip |" + "".join(" %s MVP | %s açık | %s boşta | %s teslim |" % ((nm[a],) * 4) for a in arms),
            "|---|" + "---|" * (4 * len(arms))]
    for sc in SC:
        row = "| %d |" % NP[sc]
        for a in arms:
            row += " %s | %s | %s | %s |" % (cell(a, sc, "mvp"), cell(a, sc, "acik"), both_idle(a, sc), cell(a, sc, "teslim"))
        out.append(row)
    return "\n".join(out)


def metric_table(arms, metric, scens=None, se=False):
    scens = scens or (SC + PRS)
    out = ["| Kol | " + " | ".join(label(s) for s in scens) + " |", "|---|" + "---|" * len(scens)]
    for a in arms:
        out.append("| %s | %s |" % (LAB.get(a, a), " | ".join(cell(a, s, metric, se) for s in scens)))
    return "\n".join(out)


def diff_table(pairs, metric, scens=None):
    scens = scens or (SC + PRS)
    out = ["| Fark (a − b) | " + " | ".join(label(s) for s in scens) + " |", "|---|" + "---|" * len(scens)]
    for a, b in pairs:
        out.append("| %s − %s | %s |" % (a, b, " | ".join(dcell(a, b, s, metric) for s in scens)))
    return "\n".join(out)


def plan_time_table():
    """P'nin sprint basina plan maliyeti: oynatma sayisi ve bu makinede saniye (cache kacirilan hafta basi aramalari)."""
    out = ["| Ekip | Arz | oynatma / sprint | plan süresi (sn / sprint) | tek oynatma (ms) |", "|---|---|---|---|---|"]
    for sc in SC:
        for s in (sc, "PR|" + sc):
            r = load("P", s)
            if not r:
                continue
            n = sum(m["p8"]["rollouts"] for m in r.values())
            ns = sum(m["p8"]["nsprints"] for m in r.values())
            sec = sum(m["p8"]["secs"] for m in r.values())
            out.append("| %d | %s | %.1f | %.3f | %.1f |" % (NP[sc], "kaynaklı" if s.startswith("PR|") else "sınırsız", n / ns, sec / ns, 1000.0 * sec / max(1, n)))
    return "\n".join(out)


if __name__ == "__main__":
    c = sys.argv[1]
    if c == "tek":
        print(single_table())
    elif c in METRICS:
        print(metric_table(sys.argv[2].split(",") if len(sys.argv) > 2 else ["P", "R", "T", "T_plan"], c))
    elif c == "plan":
        print(plan_time_table())
