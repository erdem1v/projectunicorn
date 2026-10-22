"""Ekonomi muhasebesi: K5 aylik gider dokumu uzerinde eski / yeni gider listesi. python -I.
Bot kararlari ESKI ekonomiyle verildi; yeni satirlar muhasebe karsiligidir (tahmin)."""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import k5, bot

# ---- sabitler (kod kaynaklari)
FOUNDER = 1500                                   # kurucu satiri, aylik [v3 par. 3.4 CALISMA]; eski karsiligi finance_system.gd:13 TOOLS_BASE_MONTHLY[1]
RENT = {"home": 0, "ishani": 1500, "plaza": 8000, "loft": 18000}          # [v3 par. 3.4 CALISMA]
OFFICE_REQ = {"ishani": dict(cash=6500), "plaza": dict(team=12, cash=45000, brand=40), "loft": dict(team=35, cash=110000, brand=70)}   # office_constants.gd:26-57
DESKS = {"home": 1, "ishani": 10, "plaza": 36, "loft": 64}                # office_constants.gd:22-52
# sunucu birim fiyati: ESKI infra_system.gd:26,28 (B2C 35/55/85 bin kullanici, B2B 30/45/70 50 koltuk); YENI v3 par. 3.2
OLD_STD = {"b2b": 45, "b2c": 55}
NEW_STD = {"b2b": 120, "b2c": 250}
TIER_FACTOR = {"eko": 0.5, "std": 1.0, "kur": 2.0}   # 1 : 2 : 4 (v3 par. 3.2)
START_CASH = 10000                                # PROBE STATE day=1 cash=10000


def office_for(emp, phase, brand, cash, prev):
    """Oyuncu, kosullari saglanan en ust ofise tasinir ve inmez. YORUM: Frank'in ceki (ishani kosulu) icin faz >= 2 vekil alinir."""
    order = ["home", "ishani", "plaza", "loft"]
    cur = prev
    for o in order[1:]:
        q = OFFICE_REQ[o]
        ok = True
        if o == "ishani" and phase < 2: ok = False
        if "team" in q and emp < q["team"]: ok = False
        if "cash" in q and cash < q["cash"]: ok = False
        if "brand" in q and brand < q["brand"]: ok = False
        if ok and order.index(o) > order.index(cur): cur = o
    return cur


def state_at(run, day):
    d = day
    while d > 0 and d not in run["state"]:
        d -= 1
    return run["state"].get(d, {})


def monthly(run, market, variant, dmrr=None):
    """Ay ay gelir/gider. variant: dict(tools=False, service=False, srv_k, sal_mult, tier). dmrr: {hafta: aylik MRR farki} (B2B, gelir etkisi)."""
    rows = []
    prev_office = "home"
    cum_old = cum_new = 0
    for m in run["month"]:
        end = int(m["end"]); ticks = int(m["ticks"])
        st = state_at(run, end)
        emp = int(st.get("emp", 0)); ph = int(st.get("phase", 1)); brand = int(st.get("brand", 0)); cash = int(st.get("cash", 0))
        frac = ticks * 7 / 30.0
        inc = int(m["income"])
        old_exp = int(m["expense"])
        if variant is None:
            exp = old_exp; office = None
            rent = 0
        else:
            office = office_for(emp, ph, brand, cash, prev_office); prev_office = office
            rent = RENT[office]
            k = NEW_STD[market] / OLD_STD[market] * TIER_FACTOR[variant.get("tier", "std")]
            exp = (int(m["salaries"]) + int(m["overtime"])) * variant.get("sal_mult", 1.0) + int(m["marketing"]) + int(m["one_time"]) \
                + int(m["servers"]) * k + (FOUNDER + rent) * frac
            if variant.get("keep_old", False):
                exp = old_exp
            inc = inc + (variant.get("dinc", {}).get(m["n"], 0))
        rec_exp = exp - int(m["one_time"])
        net = inc - exp
        cum_new += net; cum_old += int(m["income"]) - old_exp
        rows.append({"n": m["n"], "end": end, "ticks": ticks, "phase": ph, "emp": emp, "income": inc, "expense": exp, "rec_exp": rec_exp,
                     "net": net, "cum": cum_new, "cum_old": cum_old, "servers": int(m["servers"]) * (1.0 if variant is None else NEW_STD[market] / OLD_STD[market] * TIER_FACTOR[variant.get("tier", "std")]),
                     "service": int(m["service"]), "tools": int(m["tools"]), "salaries": int(m["salaries"]) + int(m["overtime"]),
                     "office": office, "rent": rent, "frac": frac, "cash_old": cash, "one_time": int(m["one_time"]), "old_income": int(m["income"]), "old_exp": old_exp})
    return rows


def summarize(rows):
    out = {}
    # evre basina aylik burn (30 gune normalize), net
    for ph in (1, 2, 3):
        rs = [r for r in rows if r["phase"] == ph]
        if not rs:
            out[ph] = None; continue
        wk = sum(r["frac"] for r in rs)
        out[ph] = {"months": len(rs), "burn_rec": sum(r["rec_exp"] for r in rs) / wk, "burn_all": sum(r["expense"] for r in rs) / wk,
                   "income": sum(r["income"] for r in rs) / wk, "net": sum(r["net"] for r in rs) / wk}
    # en derin kumulatif acik
    dip = min(rows, key=lambda r: r["cum"])
    out["dip"] = (dip["cum"], dip["end"])
    c52 = next((r["cum"] for r in rows if r["end"] >= 52), None)
    c101 = next((r["cum"] for r in rows if r["end"] >= 101), rows[-1]["cum"])
    out["c52"] = c52; out["c101"] = c101
    # kara gecis haftasi: ilk net<0 ay sonrasi, art arda 3 ay net >= 0
    neg_seen = False; first_pos = None; sustained = None
    for i, r in enumerate(rows):
        if r["end"] < 8: continue
        if r["net"] < 0: neg_seen = True
        if r["net"] >= 0 and first_pos is None and neg_seen:
            first_pos = r["end"]
        if sustained is None and i + 2 < len(rows) and all(rows[j]["net"] >= 0 for j in (i, i + 1, i + 2)) and r["end"] >= 8:
            sustained = r["end"]
    out["first_pos"] = first_pos; out["sustained"] = sustained
    # runway (ay): nakit / (aylik acik); nakit = eski nakit + (yeni kum - eski kum)
    run_by_ph = {1: [], 2: [], 3: []}
    mincash = (10 ** 12, 0)
    for r in rows:
        cash = r["cash_old"] + (r["cum"] - r["cum_old"])
        if cash < mincash[0]: mincash = (cash, r["end"])
        gap = -r["net"] / r["frac"] if r["frac"] else 0       # aylik acik
        if gap > 0:
            run_by_ph[r["phase"]].append(cash / gap)
    out["min_runway"] = {ph: (min(v) if v else None) for ph, v in run_by_ph.items()}
    out["mincash"] = mincash
    return out


def server_share(rows, lo=26, hi=104):
    inc = sum(r["income"] for r in rows if lo <= r["end"] <= hi)
    srv = sum(r["servers"] for r in rows if lo <= r["end"] <= hi)
    return 100.0 * srv / inc if inc else float("nan")


def share_by_period(rows):
    out = {}
    for lab, lo, hi in (("MVP sonrasi ilk ay", 0, 0), ("15-25. hafta", 15, 25), ("26-104. hafta", 26, 104), ("Evre 3", None, None)):
        if lab == "Evre 3":
            sel = [r for r in rows if r["phase"] == 3]
        elif lab == "MVP sonrasi ilk ay":
            sel = [r for r in rows if 8 <= r["end"] <= 14][:1]
        else:
            sel = [r for r in rows if lo <= r["end"] <= hi]
        inc = sum(r["income"] for r in sel); srv = sum(r["servers"] for r in sel)
        out[lab] = (100.0 * srv / inc) if inc else None
    return out
