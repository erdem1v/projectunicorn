"""K5 bot kayitlarini (docs/tasks/faz_ab/a_calisma/K5_runs/*.log) okur. Yalniz standart kitaplik (python -I).
Bir kayit = bir bot kosusu: 104 hafta, tik = hafta (log'daki `day`). Bu modul modeli degil, GIRDIYI kurar."""
import os, re, pickle

K5 = "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_ab/a_calisma/K5_runs"
CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cache")
KV = re.compile(r"(\w+)=([^\s]+)")

# ERP urunu: alan -> hat (data/product/lines/erp.json, shared.json; sprint.json:55-62 "areas")
CORE = ["line_erp_cashflow", "line_erp_intake", "line_erp_ledger", "line_erp_stock", "line_erp_invoicing"]
AREA_LINES = {
    "core": CORE,
    "onboarding": ["line_shared_mobile"],          # line_hidden_self_serve ilk yayinlandiginda eklenir (sprint_catalog.gd:62-71)
    "integrations": ["line_shared_integrations"],
    "trust": ["line_shared_security", "line_shared_durability"],
}
HIDDEN = "line_hidden_self_serve"
AREAS = ["core", "onboarding", "integrations", "trust"]


def kv(line):
    return {k: v for k, v in KV.findall(line)}


def line_area(line_id):
    for a, ls in AREA_LINES.items():
        if line_id in ls:
            return a
    if line_id == HIDDEN:
        return "onboarding"
    return None


def parse(name):
    p = os.path.join(K5, name + ".log")
    r = {"name": name, "state": {}, "sign": [], "cust": {}, "churn": {}, "sprint": {}, "month": [], "ship": {},
         "b2c": {}, "bugs": {}, "promise": [], "ship_days": set()}
    for l in open(p, encoding="utf-8", errors="replace"):
        if not l.startswith("PROBE "):
            continue
        t = l.split(" ", 2)[1]
        if t == "STATE":
            d = kv(l); r["state"][int(d["day"])] = d
        elif t == "SIGN":
            d = kv(l); r["sign"].append({"day": int(d["day"]), "id": d["id"], "star": int(d["star"]), "mrr": int(d["mrr"])})
        elif t == "CUST":
            d = kv(l)
            r["cust"].setdefault(d["id"], {})[int(d["day"])] = {
                "sat": int(d["sat"]), "tol": int(d["tol"]), "target": int(d["target"]), "trust": float(d["trust"]),
                "phase": d["phase"], "streak": int(d["streak"]), "cd": int(d["cd"]), "mrr": int(d["mrr"]), "bugs": int(d["bugs"])}
        elif t == "CHURN":
            d = kv(l); r["churn"][d["id"]] = int(d["day"])
        elif t == "SPRINT":
            m = re.search(r"shipped=(\S*)", l)
            d = kv(l)
            r["sprint"][int(d["day"])] = [x for x in (m.group(1).split(",") if m else []) if x]
        elif t == "MONTH_BURN":
            d = kv(l); r["month"].append({k: (int(v) if re.fullmatch(r"-?\d+", v) else v) for k, v in d.items()})
        elif t == "PROMISE":
            d = kv(l)
            if d.get("stage") == "resolved":
                r["promise"].append((int(d["day"]), d["cust"], d["status"]))
        elif t == "SHIP":
            d = kv(l); r["ship_days"].add(int(d["day"]))
        elif t == "BUGS":
            d = kv(l); r["bugs"][int(d["day"])] = {"new": int(d["new"]), "open": int(d["open"])}
        elif t == "B2C":
            d = kv(l); r["b2c"][int(d["day"])] = d
    return r


def load(name):
    os.makedirs(CACHE, exist_ok=True)
    cp = os.path.join(CACHE, name + ".pkl")
    if os.path.exists(cp):
        return pickle.load(open(cp, "rb"))
    r = parse(name)
    pickle.dump(r, open(cp, "wb"))
    return r


def product_series(r, weeks=104):
    """Botun yayinladigi kartlardan hafta hafta alan seviyesi, hat sayisi, dokunus ve istek teslimi.
    Seviye = alandaki hatlarin (kademe + cila) ortalamasi (sprint_catalog.gd:644-651; hat <= 3).
    Cila: `res:<alan>` bir hatta +0.5 (polish_step), hat basina en cok 1.0 (sprint.json:"polish_step/polish_max");
    hangi hat oldugu logda yok, alanin hatlarina sirayla dagitilir [YAKLASIM]."""
    tier = {}
    polish = {}
    rr = {a: 0 for a in AREAS}
    hidden_on = False
    out = {}
    for t in range(1, weeks + 1):
        touch = set()
        reqs = []
        for it in r["sprint"].get(t, []):
            kind, _, rest = it.partition(":")
            if kind == "feat":
                m = re.match(r"(line_[a-z_]+?)_k(\d)(?:@erp)?$", rest)
                if m:
                    lid, k = m.group(1), int(m.group(2))
                    tier[lid] = max(tier.get(lid, 0), k)
                    a = line_area(lid)
                    if a:
                        touch.add(a)
                    if lid == HIDDEN:
                        hidden_on = True
            elif kind == "fix":
                lid = rest.split("@")[0]
                a = line_area(lid)
                if a:
                    touch.add(a)
            elif kind == "res":
                a = rest
                if a in AREA_LINES:
                    ls = AREA_LINES[a] + ([HIDDEN] if (a == "onboarding" and hidden_on) else [])
                    for _ in range(len(ls)):
                        lid = ls[rr[a] % len(ls)]; rr[a] += 1
                        if polish.get(lid, 0.0) < 1.0:
                            polish[lid] = min(1.0, polish.get(lid, 0.0) + 0.5)
                            break
                    touch.add(a)
            elif kind == "req":
                reqs.append(rest.split(".")[0])
        lv = {}
        live = {}
        for a in AREAS:
            ls = AREA_LINES[a] + ([HIDDEN] if (a == "onboarding" and hidden_on) else [])
            lv[a] = sum(min(tier.get(l, 0) + polish.get(l, 0.0), 3.0) for l in ls) / len(ls)
            live[a] = sum(1 for l in ls if tier.get(l, 0) >= 1)
        out[t] = {"level": lv, "live": live, "touch": touch, "reqs": reqs}
    return out


def mvp_week(r):
    for t in sorted(r["ship"]) if r["ship"] else []:
        return t
    # v1.0: ilk PROBE SHIP; STATE'te open_bugs>... yerine ilk sprint kapanisi 3 cekirdek hat
    return 7


if __name__ == "__main__":
    import sys
    n = sys.argv[1] if len(sys.argv) > 1 else "full_run_fix_worst_7"
    r = load(n)
    ps = product_series(r)
    print(n, "signs", len(r["sign"]), "churn", len(r["churn"]), "ticks", len(r["state"]))
    for t in (7, 10, 15, 20, 25, 30, 40, 60, 100):
        s = ps[t]
        print(t, {a: round(s["level"][a], 2) for a in AREAS}, s["live"], sorted(s["touch"]), "open", r["state"][t]["open_bugs"], "phase", r["state"][t]["phase"])
