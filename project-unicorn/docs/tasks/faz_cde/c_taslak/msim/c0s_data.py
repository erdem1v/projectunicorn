"""C0s veri katmani: k9_trim/ (Q'nun 910ad1f kapanis olcumu) ve eski taban (q0b_logs) kayitlarini kosu sozlugune cevirir. python -I.
Bir kayit = bir bot kosusu; tik = hafta (log'daki day). Model burada degil, girdi burada kurulur."""
import os, re, pickle

HERE = os.path.dirname(os.path.abspath(__file__))
K9 = os.path.join(HERE, "k9_trim")
K9_15 = os.path.join(HERE, "k9_trim_15")
Q0B = os.path.normpath(os.path.join(HERE, "..", "..", "q_calisma", "q0b_logs"))
CACHE = os.path.join(HERE, "cache")
KV = re.compile(r"(\w+)=([^\s]+)")

AREAS = ["core", "onboarding", "integrations", "trust"]
# ERP urunu: alan -> hat. PROBE AREAS'in hat sayilariyla tutar (core 5, onboarding 1, integrations 1, trust 2) [k5.py, sprint.json "areas"]
AREA_LINES = {
    "core": ["line_erp_cashflow", "line_erp_intake", "line_erp_ledger", "line_erp_stock", "line_erp_invoicing"],
    "onboarding": ["line_shared_mobile", "line_hidden_self_serve"],
    "integrations": ["line_shared_integrations"],
    "trust": ["line_shared_security", "line_shared_durability"],
}
LINE_AREA = {l: a for a, ls in AREA_LINES.items() for l in ls}
ARMS = ["none", "worst", "due", "off"]
SEEDS = [7, 11]


def kv(line):
    return {k: v for k, v in KV.findall(line)}


def _num(v):
    try:
        return int(v)
    except ValueError:
        try:
            return float(v)
        except ValueError:
            return v


def run_name(arm, seed, b2c=False):
    return "full_run_%sfix_%s_%d" % ("b2c_" if b2c else "", arm, seed)


def parse(path, name):
    r = {"name": name, "state": {}, "areas": {}, "lines_open": {}, "bugs": {}, "sign": [], "fit": {}, "lead": [], "mloss": [],
         "reploss": [], "sprint": {}, "ship": [], "promise": [], "churn": {}, "month": [], "month_burn": [], "hires": [],
         "search": [], "seed": None, "end": {}, "b2c": {}, "gate": {}, "fire": []}
    for l in open(path, encoding="utf-8", errors="replace"):
        if not l.startswith("PROBE "):
            continue
        t = l.split(" ", 2)[1]
        if t == "STATE":
            d = {k: _num(v) for k, v in kv(l).items()}
            r["state"][d["day"]] = d
        elif t == "AREAS":
            d = kv(l); day = int(d["day"])
            m = re.search(r"market=\w+ (.*)$", l.strip())
            row = {}
            for part in m.group(1).split(","):
                a, _, rest = part.partition("=")
                lv, ln, la = rest.split("/")
                row[a] = (float(lv), int(ln), int(la))
            r["areas"][day] = row
        elif t == "LINES":
            day = int(kv(l)["day"])
            row = {}
            parts = l.strip().split(" ", 3)
            body = parts[3] if len(parts) > 3 else "-"
            if body != "-":
                for part in body.split(","):
                    a, _, n = part.partition("=")
                    row[a] = int(n)
            r["lines_open"][day] = row
        elif t == "BUGS":
            d = kv(l); r["bugs"][int(d["day"])] = {"new": int(d["new"]), "open": int(d["open"]), "pre": int(d.get("pre", 0))}
        elif t == "SIGN":
            d = kv(l)
            ar = {}
            for part in d.get("areas", "").split(","):
                if ":" in part:
                    a, v = part.split(":"); ar[a] = float(v)
            r["sign"].append({"day": int(d["day"]), "hour": int(d.get("hour", 12)), "id": d["id"], "by": d.get("by", "founder"),
                              "star": int(d["star"]), "weeks": float(d.get("weeks", 0)), "mrr": int(d["mrr"]), "sector": d["sector"],
                              "arch": d.get("arch", "-"), "tol": int(d["tol"]), "phase": int(d["phase"]), "areas": ar})
        elif t == "FIT":
            d = kv(l)
            r["fit"][d["id"]] = {"day": int(d["day"]), "u": int(d["u"]), "capped": d["capped"] == "true", "loss": d["loss"], "by": d.get("by"),
                                 "star": int(d["star"]), "sector": d["sector"], "tol": int(d.get("tol", 0))}
        elif t == "LEAD":
            d = kv(l)
            r["lead"].append({"day": int(d["day"]), "id": d["id"], "arch": d["arch"], "sector": d["sector"], "star": int(d["star"]),
                              "phase": int(d["phase"]), "u": None if d.get("u", "-") == "-" else int(d["u"]), "loss": d.get("loss", "-")})
        elif t == "MLOSS":
            d = kv(l)
            r["mloss"].append({"day": int(d["day"]), "id": d["id"], "sector": d["sector"], "star": int(d["star"]), "reason": d["reason"],
                               "target": d["target"], "u": None if d["u"] == "-" else int(d["u"]), "loss": d["loss"]})
        elif t == "REPLOSS":
            d = kv(l)
            r["reploss"].append({"day": int(d["day"]), "id": d["id"], "sector": d["sector"], "star": int(d["star"]), "u": int(d["u"]),
                                 "loss": d["loss"]})
        elif t == "SPRINT":
            d = kv(l); m = re.search(r"shipped=(\S*)", l)
            r["sprint"][int(d["day"])] = [x for x in (m.group(1).split(",") if m else []) if x]
        elif t == "SHIP":
            r["ship"].append(int(kv(l)["day"]))
        elif t == "PROMISE":
            d = kv(l)
            if d.get("stage") == "resolved":
                r["promise"].append((int(d["day"]), d["cust"], d["status"]))
        elif t == "CHURN":
            d = kv(l); r["churn"][d["id"]] = int(d["day"])
        elif t == "MONTH":
            r["month"].append({k: _num(v) for k, v in kv(l).items()})
        elif t == "MONTH_BURN":
            r["month_burn"].append({k: _num(v) for k, v in kv(l).items()})
        elif t == "B2C":
            d = {k: _num(v) for k, v in kv(l).items()}
            r["b2c"][d["day"]] = d
        elif t == "GATE":
            r["gate"] = {k: _num(v) for k, v in kv(l).items()}
        elif t == "END":
            r["end"] = {k: _num(v) for k, v in kv(l).items()}
        elif t == "FIRE":
            d = kv(l); r["fire"].append((int(d["day"]), int(d.get("hour", 0)), d["id"]))
        elif t == "PLAY":
            m = re.match(r"PROBE PLAY day=(\d+) (.*)$", l.strip())
            if not m:
                continue
            day = int(m.group(1)); rest = m.group(2)
            if rest.startswith("hire "):
                mm = re.match(r"hire (\w+) salary=(\d+) burn=(\d+)", rest)
                r["hires"].append({"day": day, "role": mm.group(1), "salary": int(mm.group(2)), "burn": int(mm.group(3))})
            elif rest.startswith("start_search"):
                r["search"].append((day, rest.split()[1]))
            elif rest.startswith("seed signed"):
                d = kv(rest); r["seed"] = {"day": day, "raise": int(d.get("raise", 0)), "cash": int(d.get("cash", 0))}
    return r


def load(name, base=K9):
    os.makedirs(CACHE, exist_ok=True)
    cp = os.path.join(CACHE, "c0s_%s_%s.pkl" % (os.path.basename(base), name))
    src = os.path.join(base, name + ".log")
    if os.path.exists(cp) and os.path.getmtime(cp) >= os.path.getmtime(src):
        return pickle.load(open(cp, "rb"))
    r = parse(src, name)
    pickle.dump(r, open(cp, "wb"))
    return r


# ------------------------------------------------------------------ turetilmis haftalik dunya
def tiers_from_sprints(run, T=104):
    """Haftalik canli hat sayisi (alan basina) ve alana dokunan yayin: SPRINT shipped= kartlarindan.
    feat:<hat>_k<n> hatta kademe, fix:<hat> duzeltme, res:<alan> cila, req:<hesap>.<n> istek (hangi hatta oldugu logda yok: dokunus saymaz)."""
    tier = {}
    live_by_week, touch_by_week, req_by_week, tk_by_week = {}, {}, {}, {}
    for t in range(1, T + 1):
        touch = set(); reqs = []; tk = set()
        for it in run["sprint"].get(t, []):
            kind, _, rest = it.partition(":")
            if kind == "feat":
                m = re.match(r"(line_[a-z_]+?)_k(\d)(?:@\w+)?$", rest)
                if m:
                    lid, k = m.group(1), int(m.group(2))
                    tier[lid] = max(tier.get(lid, 0), k)
                    a = LINE_AREA.get(lid)
                    if a:
                        touch.add(a); tk.add((a, "feat"))
            elif kind == "fix":
                lid = rest.split("@")[0]
                a = LINE_AREA.get(lid)
                if a:
                    touch.add(a); tk.add((a, "fix"))
            elif kind == "res":
                if rest in AREA_LINES:
                    touch.add(rest); tk.add((rest, "res"))
            elif kind == "req":
                reqs.append(rest.split(".")[0])
        live = {a: sum(1 for l in AREA_LINES[a] if tier.get(l, 0) >= 1) for a in AREAS}
        live_by_week[t] = live; touch_by_week[t] = touch; req_by_week[t] = reqs; tk_by_week[t] = tk
    return live_by_week, touch_by_week, req_by_week, tk_by_week


def world(run, T=104):
    """Model girdisi: levels[t][alan], live[t][alan], open_area[t][alan], open_total[t], touch[t], phase[t]. Eksik haftada son deger tasinir."""
    live_w, touch_w, req_w, tk_w = tiers_from_sprints(run, T)
    levels, live, open_area, open_total, touch, phase, reqs, touch_k = {}, {}, {}, {}, {}, {}, {}, {}
    last_lv = {a: 0.0 for a in AREAS}; last_la = {a: 0 for a in AREAS}; launch = {}; last_open = {}; last_tot = 0; last_ph = 1
    for t in range(1, T + 1):
        if t in run["areas"]:
            last_lv = {a: run["areas"][t][a][0] for a in AREAS if a in run["areas"][t]}
            last_la = {a: run["areas"][t][a][2] for a in AREAS if a in run["areas"][t]}
        if t in run["lines_open"]:
            last_open = run["lines_open"][t]
        if t in run["bugs"]:
            last_tot = run["bugs"][t]["open"]
        if t in run["state"]:
            last_ph = int(run["state"][t]["phase"])
        levels[t] = dict(last_lv)
        launch[t] = dict(last_la)
        live[t] = live_w[t]
        oa = {a: 0 for a in AREAS}
        for line, n in last_open.items():
            a = LINE_AREA.get(line.split("@")[0])
            if a:
                oa[a] += n
        open_area[t] = oa
        open_total[t] = last_tot
        touch[t] = touch_w[t]
        touch_k[t] = tk_w[t]
        reqs[t] = req_w[t]
        phase[t] = last_ph
    return {"T": T, "levels": levels, "live": live, "open_area": open_area, "open_total": open_total, "touch": touch,
            "phase": phase, "reqs": reqs, "touch_k": touch_k, "launch": launch}


if __name__ == "__main__":
    import sys
    n = sys.argv[1] if len(sys.argv) > 1 else "full_run_fix_worst_7"
    r = load(n)
    w = world(r)
    print(n, "sign", len(r["sign"]), "lead", len(r["lead"]), "mloss", len(r["mloss"]), "reploss", len(r["reploss"]), "hires", len(r["hires"]),
          "promise", len(r["promise"]), "seed", r["seed"], "end", r["end"])
    for t in (7, 10, 20, 40, 60, 100):
        print(t, {a: round(w["levels"][t][a], 2) for a in AREAS}, w["live"][t], w["open_area"][t], w["open_total"][t], sorted(w["touch"][t]))
