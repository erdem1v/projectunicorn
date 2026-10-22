#!/usr/bin/env python3
"""Faz A K5 tablo betiği (yalnız stdlib). Repoya girmez.

16 koşunun günlüğünü (iki pazar x dört kol x tohum 7 ve 11) okur ve PRD 4.4-4.5 ile E1 sec. 9 için basar:
  (a) haftada yeni hata        (PROBE BUGS new=)
  (b) açık hata, sprint sonunda (PROBE BUGS pre= o sprintin kapanış haftasında) ve sürüm anında (PROBE SHIP open_bugs=)
  (c) düzeltme payı ve hata sprinti (PROBE FIX), arka arkaya iki hata sprinti
  churn: B2B ayrılan hesap (PROBE STATE lost=), B2C kullanıcı kaybı (PROBE B2C lost=) ve kitle farkı, MRR farkı (fix_off'a göre)
        kayıp yüzdesi = kaybedilen / (kaybedilen + dönem sonunda kalan müşteri)
Dönem: erken = v1.0'dan sonraki ilk 20 hafta, geç = sonrası. 104 haftadan önce biten koşu '*' ile işaretlenir.
Sonunda E1 sec. 9'daki her hedef için PASS/MISS basar.

Kullanım:  python fix_tables.py <günlük klasörü>
Günlük adı: <preset>_<tohum>.log, ör. full_run_fix_due_7.log, full_run_b2c_fix_off_11.log
Komutlar (proje klasöründen, her koşu ayrı APPDATA ile):
  "$GODOT" --headless --path . --lang=tr --run-log=<preset>:104:sim:<tohum> > <klasör>/<preset>_<tohum>.log
"""
import re
import statistics
import sys
from collections import defaultdict
from pathlib import Path

ARMS = ["none", "worst", "due", "off"]
SEEDS = [7, 11]
EARLY_WEEKS = 20
WEEKS = 104
NAME = re.compile(r"^full_run_(b2c_)?fix_(none|worst|due|off)_(\d+)\.log$")


def kv(line):
    return dict(re.findall(r"(\w+)=(\S+)", line))


def parse(path):
    run = {"bugs": [], "fix": [], "ships": [], "sprints": [], "b2c": [], "state": [], "end": None,
           "errors": 0}
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if line.startswith("PROBE ERROR") or line.startswith("ERROR:") and "resources still in use" not in line:
            run["errors"] += 1
        if not line.startswith("PROBE "):
            continue
        tag = line.split()[1]
        f = kv(line)
        if tag == "BUGS":
            run["bugs"].append({k: int(f[k]) for k in ("day", "new", "open", "pre")})
        elif tag == "FIX":
            run["fix"].append({"day": int(f["day"]), "share": float(f["share"]), "load": float(f["fix_load"]),
                               "cap": float(f["capacity"]), "bug": f["bug_sprint"].lower() == "true"})
        elif tag == "SHIP":
            run["ships"].append({"day": int(f["day"]), "version": int(f["version"]), "open": int(f["open_bugs"])})
        elif tag == "SPRINT":
            run["sprints"].append(int(f["day"]))
        elif tag == "B2C":
            run["b2c"].append({"day": int(f["day"]), "aud": float(f["aud"]), "lost": float(f.get("lost", 0))})
        elif tag == "STATE":
            run["state"].append({"day": int(f["day"]), "mrr": int(f["mrr"]), "cust": int(f["cust"]),
                                 "lost": int(f.get("lost", 0))})
        elif tag == "END":
            run["end"] = int(f["day"])
    return run


def v1_day(run):
    first = [s["day"] for s in run["ships"] if s["version"] == 1]
    return first[0] if first else None


def period(run, day):
    v1 = v1_day(run)
    if v1 is None or day < v1:
        return None
    return "early" if day - v1 < EARLY_WEEKS else "late"


def med(xs):
    return statistics.median(xs) if xs else float("nan")


def mean(xs):
    return statistics.fmean(xs) if xs else float("nan")


def load(folder):
    runs = {}
    for p in sorted(Path(folder).glob("*.log")):
        m = NAME.match(p.name)
        if m:
            runs[("b2c" if m.group(1) else "b2b", m.group(2), int(m.group(3)))] = parse(p)
    return runs


def samples(run, kind, per):
    """Per-period samples of one measure of one run."""
    out = defaultdict(list)
    sprint_days = set(run["sprints"])
    if kind == "new":
        for b in run["bugs"]:
            if period(run, b["day"]):
                out[period(run, b["day"])].append(b["new"])
    elif kind == "sprint_end":
        for b in run["bugs"]:
            if b["day"] in sprint_days and period(run, b["day"]):
                out[period(run, b["day"])].append(b["pre"])
    elif kind == "release":
        for s in run["ships"]:
            if period(run, s["day"]):
                out[period(run, s["day"])].append(s["open"])
    elif kind == "share":
        for f in run["fix"]:
            if period(run, f["day"]):
                out[period(run, f["day"])].append(f["share"])
    elif kind == "bug_sprint":
        for f in run["fix"]:
            if period(run, f["day"]):
                out[period(run, f["day"])].append(1.0 if f["bug"] else 0.0)
    elif kind == "bug_pair":
        fixes = [f for f in run["fix"] if period(run, f["day"])]
        for a, b in zip(fixes, fixes[1:]):
            if period(run, b["day"]):
                out[period(run, b["day"])].append(1.0 if a["bug"] and b["bug"] else 0.0)
    return out


def pooled(runs, market, arm, kind):
    out = defaultdict(list)
    for seed in SEEDS:
        run = runs.get((market, arm, seed))
        if run:
            for per, xs in samples(run, kind, None).items():
                out[per].extend(xs)
    return out


def mark(run):
    return "" if run is None or (run["end"] or WEEKS) >= WEEKS else "*"


def flow_table(runs, title, kind, fmt="%.1f"):
    print("\n== %s ==" % title)
    print("%-4s %-6s %-6s | %s" % ("pazar", "dönem", "kol", "  ".join("tohum %-2d med/ort/n" % s for s in SEEDS)))
    for market in ("b2b", "b2c"):
        for per in ("early", "late"):
            for arm in ARMS:
                cells = []
                for seed in SEEDS:
                    run = runs.get((market, arm, seed))
                    xs = samples(run, kind, None).get(per, []) if run else []
                    cells.append(("%s/%s/%d%s" % (fmt % med(xs), fmt % mean(xs), len(xs), mark(run))).ljust(18))
                print("%-4s %-6s %-6s | %s" % (market, per, arm, "  ".join(cells)))


def loss(run, market):
    """(early, late, total) customers lost, and the customers left at the matching points."""
    v1 = v1_day(run)
    if run is None or v1 is None:
        return None
    cut = v1 + EARLY_WEEKS
    if market == "b2b":
        lost_cut = [s["lost"] for s in run["state"] if s["day"] <= cut]
        early = lost_cut[-1] if lost_cut else 0
        total = run["state"][-1]["lost"] if run["state"] else 0
        last = run["state"][-1]["cust"] if run["state"] else 0
        at_cut = [s["cust"] for s in run["state"] if s["day"] <= cut]
        return {"early": early, "late": total - early, "total": total,
                "pct": 100.0 * total / max(1, total + last),
                "early_pct": 100.0 * early / max(1, early + (at_cut[-1] if at_cut else 0)),
                "late_pct": 100.0 * (total - early) / max(1, total - early + last)}
    rows = run["b2c"]
    if not rows:
        return None
    lost_cut = [r["lost"] for r in rows if r["day"] <= cut]
    aud_cut = [r["aud"] for r in rows if r["day"] <= cut]
    early = lost_cut[-1] if lost_cut else 0.0
    total = rows[-1]["lost"]
    return {"early": early, "late": total - early, "total": total, "aud": rows[-1]["aud"],
            "pct": 100.0 * total / max(1.0, total + rows[-1]["aud"]),
            "early_pct": 100.0 * early / max(1.0, early + (aud_cut[-1] if aud_cut else 0.0)),
            "late_pct": 100.0 * (total - early) / max(1.0, total - early + rows[-1]["aud"])}


def churn_table(runs):
    print("\n== churn: kayıp müşteri (B2B ayrılan hesap, B2C kitleden giden kullanıcı), MRR farkı fix_off'a göre ==")
    print("%-4s %-6s %-5s | %-34s | %-34s | %s" % ("pazar", "kol", "tohum", "erken (kayıp, %)", "geç (kayıp, %)", "toplam %  kitle/MRR farkı"))
    for market in ("b2b", "b2c"):
        for arm in ARMS:
            for seed in SEEDS:
                run = runs.get((market, arm, seed))
                lo = loss(run, market)
                if lo is None:
                    print("%-4s %-6s %-5d | (günlük yok ya da ürün yayına girmedi)" % (market, arm, seed))
                    continue
                off = runs.get((market, "off", seed))
                mrr = run["state"][-1]["mrr"] if run["state"] else 0
                mrr_off = off["state"][-1]["mrr"] if off and off["state"] else 0
                extra = "MRR %d (off %+d)" % (mrr, mrr - mrr_off)
                if market == "b2c" and off and off["b2c"]:
                    extra += ", kitle %d (off %+d)" % (lo["aud"], lo["aud"] - off["b2c"][-1]["aud"])
                print("%-4s %-6s %-5d | %-34s | %-34s | %.2f%%  %s%s" % (
                    market, arm, seed, "%.0f, %.2f%%" % (lo["early"], lo["early_pct"]),
                    "%.0f, %.2f%%" % (lo["late"], lo["late_pct"]), lo["pct"], extra, mark(run)))


def targets(runs):
    rows = []

    def check(name, value, ok, note=""):
        rows.append((name, value, ok, note))

    flow = {("b2b", "early"): (1.5, 4, 8), ("b2b", "late"): (4, 8, 16),
            ("b2c", "early"): (1.5, 4, 8), ("b2c", "late"): (3, 8, 16)}
    for (market, per), (new_max, rel_max, end_max) in flow.items():
        for kind, limit, label in (("new", new_max, "haftada yeni hata (medyan)"),
                                   ("release", rel_max, "açık hata, sürüm anında (medyan)"),
                                   ("sprint_end", end_max, "açık hata, sprint sonu (medyan)")):
            xs = pooled(runs, market, "due", kind).get(per, [])
            v = med(xs)
            check("fix_due %s %s %s <= %s" % (market, per, label, limit), v, bool(xs) and v <= limit, "n=%d" % len(xs))
    for arm, late_max, early_max in (("worst", 0.15, 0.30), ("due", 0.20, 0.30)):
        for market in ("b2b", "b2c"):
            for per, limit in (("late", late_max), ("early", early_max)):
                xs = pooled(runs, market, arm, "share").get(per, [])
                check("fix_%s %s %s düzeltme payı medyanı <= %.0f%%" % (arm, market, per, 100 * limit),
                      100 * med(xs), bool(xs) and med(xs) <= limit, "n=%d" % len(xs))
    for market in ("b2b", "b2c"):
        for per, limit in (("late", 0.05), ("early", 0.15)):
            xs = pooled(runs, market, "due", "bug_sprint").get(per, [])
            check("fix_due %s %s hata sprinti oranı <= %.0f%%" % (market, per, 100 * limit),
                  100 * mean(xs), bool(xs) and mean(xs) <= limit, "n=%d" % len(xs))
    for arm in ("worst", "due"):
        for market in ("b2b", "b2c"):
            for per, limit in (("late", 0.0), ("early", 0.01)):
                xs = pooled(runs, market, arm, "bug_pair").get(per, [])
                check("fix_%s %s %s üst üste iki hata sprinti oranı <= %.0f%%" % (arm, market, per, 100 * limit),
                      100 * mean(xs), bool(xs) and mean(xs) <= limit, "n=%d" % len(xs))
    for market in ("b2b", "b2c"):
        for seed in SEEDS:
            lo = {a: loss(runs.get((market, a, seed)), market) for a in ARMS}
            if any(v is None for v in lo.values()):
                check("churn %s tohum %d" % (market, seed), float("nan"), False, "günlük eksik")
                continue
            check("churn %s tohum %d: fix_worst kaybı <= fix_off + 10 puan" % (market, seed),
                  lo["worst"]["pct"] - lo["off"]["pct"], lo["worst"]["pct"] <= lo["off"]["pct"] + 10.0,
                  "worst %.2f%% off %.2f%%" % (lo["worst"]["pct"], lo["off"]["pct"]))
            check("churn %s tohum %d: fix_none kaybı >= 2 x fix_off" % (market, seed),
                  lo["none"]["pct"], lo["none"]["pct"] >= 2.0 * lo["off"]["pct"] and lo["none"]["pct"] > lo["off"]["pct"],
                  "none %.2f%% off %.2f%%" % (lo["none"]["pct"], lo["off"]["pct"]))
    print("\n== E1 sec. 9 hedefleri ==")
    miss = 0
    for name, value, ok, note in rows:
        miss += 0 if ok else 1
        print("%-4s %-92s %8.2f  %s" % ("PASS" if ok else "MISS", name, value, note))
    print("\nÖZET: %d hedef, %d MISS" % (len(rows), miss))


def info(runs):
    print("\n== bilgi: fix_worst açık hata (geç dönem, sprint sonu ve sürüm anı medyanı) ==")
    for market in ("b2b", "b2c"):
        end = pooled(runs, market, "worst", "sprint_end").get("late", [])
        rel = pooled(runs, market, "worst", "release").get("late", [])
        print("%-4s sprint sonu %.1f (n=%d), sürüm anı %.1f (n=%d)" % (market, med(end), len(end), med(rel), len(rel)))
    print("\n== koşular ==")
    for key in sorted(runs):
        r = runs[key]
        print("%-4s %-6s tohum %-2d bitiş %s v1.0 %s hata satırı %d%s" % (
            key[0], key[1], key[2], r["end"], v1_day(r), r["errors"], " (104 haftadan önce bitti)" if mark(r) else ""))


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    runs = load(sys.argv[1])
    if not runs:
        raise SystemExit("günlük bulunamadı: %s" % sys.argv[1])
    info(runs)
    flow_table(runs, "(a) haftada yeni hata", "new")
    flow_table(runs, "(b1) açık hata, sprint sonunda (kapanıştan hemen önce)", "sprint_end")
    flow_table(runs, "(b2) açık hata, sürüm anında (kapanıştan sonra)", "release")
    flow_table(runs, "(c1) düzeltme payı (sprint başında düzeltme yükü / kapasite)", "share", "%.3f")
    flow_table(runs, "(c2) hata sprinti oranı (pay > %50)", "bug_sprint", "%.3f")
    flow_table(runs, "(c3) arka arkaya iki hata sprinti oranı", "bug_pair", "%.3f")
    churn_table(runs)
    targets(runs)


if __name__ == "__main__":
    main()
