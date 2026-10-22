#!/usr/bin/env python3
"""B6m toplama betiği (yalnız stdlib). Repoya girmez.
Kullanım: python -X utf8 analyze.py <b6m klasörü> <repo kökü (project-unicorn)>
"""
import json
import re
import statistics
import sys
from collections import Counter, defaultdict
from pathlib import Path

B6M = Path(sys.argv[1])
REPO = Path(sys.argv[2])

EMERG = ["product.incident_outage_b2b", "product.incident_outage_b2c", "customer.incident_month_close",
         "product.incident_checkout", "product.incident_regression", "product.incident_review_storm"]
KINDS = EMERG + ["product.promise_due", "customer.release_thanks"]
ERR_RE = re.compile(r"^(ERROR:|SCRIPT ERROR|Parse Error|Compile Error|PROBE ERROR)")


def kv(line):
    return dict(re.findall(r"(\w+)=(\S+)", line))


def parse(path):
    r = {"events": [], "fires": [], "sprints": [], "picks": [], "stops": [], "end": None, "ends": 0, "errors": [],
         "state": None, "b2c": None, "order": []}
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw.rstrip("\r")
        if ERR_RE.match(line) and "resources still in use" not in line:
            r["errors"].append(line[:160])
        if not line.startswith("PROBE "):
            continue
        tag = line.split()[1]
        f = kv(line)
        if tag == "FIRE":
            e = {"t": "fire", "day": int(f["day"]), "hour": int(f["hour"]), "id": f["id"]}
            r["fires"].append(e)
            r["order"].append(e)
        elif tag == "SPRINT":
            e = {"t": "sprint", "day": int(f["day"]), "n": int(f["n"])}
            r["sprints"].append(e)
            r["order"].append(e)
        elif tag == "PICK":
            m = re.match(r"PROBE PICK day=(\d+) id=(\S+) choice=(\d+) label=(.*)$", line)
            r["picks"].append({"day": int(m.group(1)), "id": m.group(2), "choice": int(m.group(3)), "label": m.group(4)})
        elif tag == "STOP":
            r["stops"].append({"day": int(f["day"]), "id": f["id"]})
        elif tag == "END":
            r["end"] = int(f["day"])
            r["ends"] += 1
            r["endline"] = line
        elif tag == "STATE":
            r["state"] = {k: f.get(k) for k in ("day", "cash", "mrr", "cust", "emp", "aud", "lost", "open_bugs")}
        elif tag == "B2C":
            r["b2c"] = {"aud": float(f["aud"]), "lost": float(f.get("lost", 0)), "paying": f.get("paying")}
    return r


def cards():
    out = {}
    for p in (REPO / "data/events/cards/product").glob("sprint_*.json"):
        d = json.loads(p.read_text(encoding="utf-8"))
        role = d.get("speaker_role")
        out[d["id"]] = {"role": "|".join(role) if isinstance(role, list) else role, "group": d.get("pool_group"),
                        "market": (d.get("guards") or {}).get("market", "both")}
    return out


CARDS = cards()


def load_dir(d, pat="*.log"):
    return {p.stem: parse(p) for p in sorted(Path(d).glob(pat))}


def hdr(s):
    print("\n" + "=" * 8 + " " + s + " " + "=" * 8)


# ---------------------------------------------------------------- A: §4.1 ve §4.12 geniş örnek
def section_a(runs):
    hdr("A: acil durum aralığı (§4.1) — %d koşu" % len(runs))
    allgaps = []
    per_market = {"full_run": [], "full_run_b2c": []}
    print("%-16s %-3s %5s %-10s %s" % ("koşu", "end", "sayı", "bitiş", "aralıklar (hafta)"))
    for name, r in runs.items():
        em = [e for e in r["fires"] if e["id"] in EMERG]
        days = [e["day"] for e in em]
        gaps = [b - a for a, b in zip(days, days[1:])]
        allgaps += gaps
        mk = "full_run_b2c" if name.startswith("full_run_b2c") else "full_run"
        per_market[mk].append((name, len(em), gaps))
        print("%-16s %-3d %5d %-10s %s" % (name, r["ends"], len(em), r["end"], gaps))
        if r["errors"]:
            print("   HATA:", r["errors"][:3])
    for mk, rows in per_market.items():
        counts = [c for _, c, _ in rows]
        g = [x for _, _, gs in rows for x in gs]
        out46 = [x for x in g if not 4 <= x <= 6]
        print("\n[%s] koşu=%d olay/koşu min=%d medyan=%s maks=%d ort=%.1f; 4-14 içinde olan koşu=%d/%d; aralık sayısı=%d, en küçük=%s, 4-6 dışı pay=%.1f%% (%d/%d)" % (
            mk, len(rows), min(counts), statistics.median(counts), max(counts), statistics.fmean(counts),
            sum(1 for c in counts if 4 <= c <= 14), len(counts), len(g), min(g) if g else None,
            100.0 * len(out46) / max(1, len(g)), len(out46), len(g)))
        print("   aralık dağılımı:", sorted(Counter(g).items()))
        print("   4-14 dışı koşular:", [(n, c) for n, c, _ in rows if not 4 <= c <= 14])
    og = [x for x in allgaps if not 4 <= x <= 6]
    print("\n[iki pazar] aralık=%d en küçük=%s 4-6 dışı pay=%.1f%%" % (len(allgaps), min(allgaps), 100.0 * len(og) / len(allgaps)))
    ends_bad = [n for n, r in runs.items() if r["ends"] != 1]
    err_bad = [n for n, r in runs.items() if r["errors"]]
    print("PROBE END != 1:", ends_bad, " hata satırı olan koşular:", err_bad)
    # türler
    hdr("A: tür sayıları (104 hafta)")
    counts_by_kind(runs)


def counts_by_kind(runs, label=""):
    rows = []
    print("%-16s " % "koşu" + " ".join("%-9s" % k.split(".")[-1][:9] for k in KINDS) + "  kâğıt")
    tot = Counter()
    for name, r in runs.items():
        c = Counter(e["id"] for e in r["fires"])
        paper = sum(v for k, v in c.items() if k in CARDS)
        tot.update({k: c.get(k, 0) for k in KINDS})
        tot["_paper"] += paper
        print("%-16s " % name + " ".join("%-9d" % c.get(k, 0) for k in KINDS) + "  %d" % paper)
    print("%-16s " % "TOPLAM" + " ".join("%-9d" % tot[k] for k in KINDS) + "  %d" % tot["_paper"])
    return tot


def paper_roles(runs, title):
    hdr("kâğıt dökümü: " + title)
    by_group, by_role, by_card = Counter(), Counter(), Counter()
    for r in runs.values():
        for e in r["fires"]:
            c = CARDS.get(e["id"])
            if c:
                by_group[c["group"]] += 1
                by_role[c["role"]] += 1
                by_card[e["id"]] += 1
    print("pool_group:", dict(by_group.most_common()))
    print("speaker_role:", dict(by_role.most_common()))
    allgroups = sorted({c["group"] for c in CARDS.values()})
    allroles = sorted({c["role"] for c in CARDS.values()})
    print("hiç gelmeyen pool_group:", [g for g in allgroups if by_group[g] == 0])
    print("hiç gelmeyen speaker_role:", [g for g in allroles if by_role[g] == 0])
    print("gelen kart sayısı: %d / %d; hiç gelmeyen kartlar:" % (len(by_card), len(CARDS)))
    print("   ", sorted(k for k in CARDS if by_card[k] == 0))
    return by_card


def repeat_stats(runs):
    hdr("kâğıt tekrarı (aynı kimlik, bir koşuda)")
    worst = []
    for name, r in runs.items():
        c = Counter(e["id"] for e in r["fires"] if e["id"] in CARDS)
        if c:
            top = c.most_common(1)[0]
            worst.append((top[1], name, top[0]))
    worst.sort(reverse=True)
    print("en çok tekrar eden (adet, koşu, kart) ilk 8:", worst[:8])
    dist = Counter(w[0] for w in worst)
    print("koşu başına en çok tekrar dağılımı:", sorted(dist.items()))
    # aynı kâğıdın ardışık gelişleri arası hafta (52 hafta kuralı)
    gaps = []
    for r in runs.values():
        last = {}
        for e in r["fires"]:
            if e["id"] in CARDS:
                if e["id"] in last:
                    gaps.append((e["day"] - last[e["id"]], e["id"]))
                last[e["id"]] = e["day"]
    print("aynı kartın iki gelişi arası en küçük hafta:", sorted(gaps)[:5] if gaps else None)


# ---------------------------------------------------------------- D: sprint başına kesinti
def per_sprint(runs, title):
    hdr("D: sprint başına kesinti — " + title)
    total_sprints = 0
    total_empty_paper = 0
    comp_all = Counter()
    multi_runs = defaultdict(list)
    len_dist = Counter()
    papers_by_len = defaultdict(lambda: [0, 0])  # weeks -> [sprints, with paper]
    for name, r in runs.items():
        prev_day = 0
        bucket = []
        for e in r["order"]:
            if e["t"] == "fire":
                bucket.append(e["id"])
            else:
                weeks = e["day"] - prev_day
                len_dist[weeks] += 1
                prev_day = e["day"]
                kinds = []
                for i in bucket:
                    if i in CARDS:
                        kinds.append("paper")
                    elif i == "product.promise_due":
                        kinds.append("promise")
                    elif i in EMERG:
                        kinds.append("emerg:" + i.split(".")[-1].replace("incident_", ""))
                total_sprints += 1
                has_paper = "paper" in kinds
                total_empty_paper += 0 if has_paper else 1
                papers_by_len[min(weeks, 3)][0] += 1
                papers_by_len[min(weeks, 3)][1] += 1 if has_paper else 0
                if len(kinds) > 1:
                    key = "+".join(sorted(kinds))
                    comp_all[key] += 1
                    multi_runs[key].append((name, e["n"], e["day"]))
                bucket = []
        # artık: son SPRINT satırından sonrası sayılmaz
    print("PROBE SPRINT sprint sayısı (kapanan):", total_sprints, " sprint uzunluğu (tik) dağılımı:", sorted(len_dist.items()))
    print("kâğıtsız sprint oranı: %.1f%% (%d/%d)" % (100.0 * total_empty_paper / total_sprints, total_empty_paper, total_sprints))
    for w, (n, p) in sorted(papers_by_len.items()):
        print("   uzunluk %s tik: sprint=%d kâğıtlı=%d kâğıtsız oranı=%.1f%%" % (w, n, p, 100.0 * (n - p) / n))
    print("birden çok kesintili sprint:", sum(comp_all.values()), "bileşimler:")
    for k, v in comp_all.most_common():
        print("   %-40s %d  örn: %s" % (k, v, multi_runs[k][:3]))
    return comp_all


# ---------------------------------------------------------------- B
def section_b(open_runs, free_runs):
    hdr("B: PROBE STOP ve PICK (kol başına)")
    for tag, runs in (("AÇIK", open_runs), ("_free", free_runs)):
        print("\n--", tag)
        print("%-24s %-5s %-5s %-7s %-6s %s" % ("koşu", "STOP", "acil", "end/err", "bitiş", "emergency picks (id: etiket x adet)"))
        for name, r in runs.items():
            em = [p for p in r["picks"] if p["id"] in EMERG]
            c = Counter((p["id"].split(".")[-1], p["label"]) for p in em)
            print("%-24s %-5d %-5d %d/%d   %-6s %s" % (name, len(r["stops"]), len([e for e in r["fires"] if e["id"] in EMERG]),
                  r["ends"], len(r["errors"]), r["end"], "; ".join("%s: %s x%d" % (k[0], k[1], v) for k, v in sorted(c.items()))))
    hdr("B: acil durum kartlarında seçilen etiketler, kol başına birleşik")
    for tag, runs in (("AÇIK", open_runs), ("_free", free_runs)):
        agg = defaultdict(Counter)
        for name, r in runs.items():
            m = re.match(r"full_run_(b2c_)?fix_(none|worst|due|off)_", name)
            arm = ("b2c " if m.group(1) else "b2b ") + m.group(2)
            for p in r["picks"]:
                if p["id"] in EMERG:
                    agg[arm][(p["id"].split(".")[-1], p["label"])] += 1
        print("\n--", tag)
        for arm in sorted(agg):
            print("  %-10s %s" % (arm, "; ".join("%s: %s x%d" % (k[0], k[1], v) for k, v in sorted(agg[arm].items()))))


def econ(runs):
    out = {}
    for name, r in runs.items():
        s = r["state"] or {}
        b2c = r["b2c"] or {}
        out[name] = {"mrr": int(s.get("mrr", 0) or 0), "cash": int(s.get("cash", 0) or 0), "emp": int(s.get("emp", 0) or 0),
                     "cust": int(s.get("cust", 0) or 0), "aud": b2c.get("aud"), "day": s.get("day"), "end": r["end"]}
    return out


def section_econ(open_runs, free_runs, k5):
    hdr("B: ekonomi (son MRR / kasa / çalışan / B2B hesap / B2C kitle) — A K5 | olaylı açık | olaylı _free")
    eo, ef, ek = econ(open_runs), econ(free_runs), econ(k5)
    print("%-26s | %-44s | %-44s | %s" % ("koşu", "K5 (A, olaysız)", "olaylar açık", "olaylar açık, durdurmasız (_free)"))
    for name in sorted(eo):
        def fmt(d):
            if d is None:
                return "-"
            return "mrr=%d cash=%d emp=%d cust=%d aud=%s" % (d["mrr"], d["cash"], d["emp"], d["cust"], "%d" % d["aud"] if d["aud"] else "-")
        print("%-26s | %-44s | %-44s | %s" % (name, fmt(ek.get(name)), fmt(eo[name]), fmt(ef.get(name))))


def main():
    a = load_dir(B6M / "logs_A")
    section_a(a)
    paper_roles(a, "A'nın 20 koşusu (iki pazar birlikte)")
    for mk in ("full_run", "full_run_b2c"):
        sub = {n: r for n, r in a.items() if (n.startswith("full_run_b2c") if mk == "full_run_b2c" else not n.startswith("full_run_b2c"))}
        paper_roles(sub, "A " + mk + " (10 koşu)")
        repeat_stats(sub)
    per_sprint(a, "A'nın 20 koşusu")
    per_sprint({n: r for n, r in a.items() if not n.startswith("full_run_b2c")}, "A full_run (B2B) 10 koşu")
    per_sprint({n: r for n, r in a.items() if n.startswith("full_run_b2c")}, "A full_run_b2c 10 koşu")
    bo = load_dir(B6M / "logs_B_open")
    bf = load_dir(B6M / "logs_B_free")
    # §4.12 fix_worst koşuları
    worst = {n: r for n, r in bo.items() if "_fix_worst_" in n}
    hdr("C: B'nin fix_worst koşuları (olaylar açık): tür sayıları")
    counts_by_kind(worst)
    paper_roles(worst, "fix_worst 4 koşu")
    per_sprint(worst, "fix_worst 4 koşu")
    per_sprint(bo, "B olaylar açık 16 koşu")
    section_b(bo, bf)
    k5 = load_dir(REPO / "docs/tasks/faz_ab/a_calisma/K5_runs", "full_run*_fix_*_*.log")
    section_econ(bo, bf, k5)


if __name__ == "__main__":
    main()
