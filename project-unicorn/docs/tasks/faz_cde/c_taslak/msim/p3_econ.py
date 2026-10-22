"""Bolum 3: ekonomi (arac gideri kalkar, servis kalkar, sunucu %8-15, kurucu satiri, kira). python -I.
Cikti: out/p3_tables.md, out/p3.json"""
import sys, os, json, pickle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
import k5, bot, econ

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
J = {}


def md(rows, head):
    s = "| " + " | ".join(head) + " |\n|" + "---|" * len(head) + "\n"
    for r in rows:
        s += "| " + " | ".join(str(c) for c in r) + " |\n"
    return s


def k(x):
    return "-" if x is None else ("%+.0fK" % (x / 1000.0))


def dmrr_months(run, P, seed, arm, scenario="new"):
    """Yeni modelin MRR farki: (yeni modelde ayakta hesaplarin imza MRR'i + yenileme fiyat degisimi) - (K5 gercek ayakta hesaplarin imza MRR'i).
    Ay icindeki her hafta icin fark x 7/30, aya toplanir. YAKLASIM: genisleme (expansion) ve K5'te sonradan degisen MRR iki tarafta da yok sayilir."""
    ps = P[arm]["new"]["res"]
    sign_mrr = {s["id"]: s["mrr"] for s in run["sign"]}
    sign_day = {s["id"]: s["day"] for s in run["sign"]}
    def new_mrr(aid, t):
        r = ps.get((seed, aid))
        if r is None or r.get("rejected") or t < sign_day[aid]: return 0.0
        left = r["left"]
        if left is not None and t >= left: return 0.0
        m = float(sign_mrr[aid])
        for x in r["renew"]:
            eff = sign_day[aid] + 52 * (1 + (x["t"] - sign_day[aid]) // 52)
            if t >= eff and x["result"] != "leave":
                m *= (x["mrr_after"] / x["mrr_before"]) if x["mrr_before"] else 1.0
        return m
    def real_mrr(aid, t):
        c = run["cust"].get(aid)
        if t < sign_day[aid]: return 0.0
        ch = run["churn"].get(aid)
        if ch is not None and t >= ch: return 0.0
        return float(sign_mrr[aid])
    dm = {}
    per_week = {}
    for t in range(1, 105):
        per_week[t] = sum(new_mrr(a, t) - real_mrr(a, t) for a in sign_mrr)
    out = {}
    for m in run["month"]:
        s0, e0 = int(m["start"]), int(m["end"])
        out[m["n"]] = sum(per_week.get(t, 0.0) for t in range(s0 + 1 if s0 > 1 else 1, e0 + 1)) * 7 / 30.0
    return out, per_week


def table_phase(rows_by):
    out = []
    for lab, rows in rows_by:
        s = econ.summarize(rows)
        cells = []
        for ph in (1, 2, 3):
            x = s[ph]
            cells.append("-" if x is None else "%s / %s / %s" % (k(x["burn_rec"]).replace("+", ""), k(x["income"]).replace("+", ""), k(x["net"])))
        out.append([lab] + cells)
    return md(out, ["Varyant", "Evre 1 (burn / gelir / net, aylık)", "Evre 2", "Evre 3"])


def main():
    P = pickle.load(open(os.path.join(OUT, "p1.pkl"), "rb"))
    VARS = [("Eski (kayıt)", None), ("A: araç ve servis yok, sunucu Standart, kurucu, kira", {}), ("C (öneri): A ve maaş bantları x1,5", {"sal_mult": 1.5}),
            ("D (öneri): A ve maaş bantları x2", {"sal_mult": 2.0})]
    parts = []
    summ = {}
    dip_rows = []
    phase_blocks = []
    runway_rows = []
    gate_rows = []
    for mk in ("b2b", "b2c"):
        for seed in (7, 11):
            run = k5.load(bot.run_name("worst", seed, mk == "b2c"))
            rowsets = []
            for lab, v in VARS:
                rows = econ.monthly(run, mk, v)
                rowsets.append((lab, rows))
            phase_blocks.append((mk, seed, rowsets))
            for lab, rows in rowsets:
                s = econ.summarize(rows)
                summ["%s|%d|%s" % (mk, seed, lab)] = s
                dip_rows.append([mk.upper(), seed, lab, "%s (hf %d)" % (k(s["dip"][0]), s["dip"][1]), k(s["c52"]), k(s["c101"]),
                                 s["first_pos"], s["sustained"], " / ".join(("%.1f" % s["min_runway"][ph]) if s["min_runway"][ph] else "açık yok" for ph in (1, 2, 3)),
                                 "%s (hf %d)" % (k(s["mincash"][0]), s["mincash"][1])])
            # gelir etkisi (yalniz B2B): A + memnuniyet modelinin MRR farki
    # ---- sunucu orani
    srv_rows = []
    for mk in ("b2b", "b2c"):
        for seed in (7, 11):
            run = k5.load(bot.run_name("worst", seed, mk == "b2c"))
            for lab, v in (("eski", None), ("Ekonomik", {"tier": "eko"}), ("Standart", {"tier": "std"}), ("Kurumsal", {"tier": "kur"})):
                rows = econ.monthly(run, mk, v)
                sp = econ.share_by_period(rows)
                srv_rows.append([mk.upper(), seed, lab] + ["-" if sp[p] is None else "%.1f" % sp[p] for p in ("MVP sonrasi ilk ay", "15-25. hafta", "26-104. hafta", "Evre 3")])
    # ---- evre 3 ayrisma (B2B tohum 7 ve 11): eski ve yeni kalem kalem aylik ortalama
    dec_rows = []
    for seed in (7, 11):
        run = k5.load(bot.run_name("worst", seed))
        old = [r for r in econ.monthly(run, "b2b", None) if r["phase"] == 3]
        new = [r for r in econ.monthly(run, "b2b", {}) if r["phase"] == 3]
        wk = sum(r["frac"] for r in old)
        def avg(rs, key):
            return sum(r[key] for r in rs) / wk
        inc = avg(old, "income")
        dec_rows.append([seed, "Gelir", k(inc).replace("+", ""), k(inc).replace("+", "")])
        dec_rows.append([seed, "Maaş ve ek mesai", k(avg(old, "salaries")).replace("+", ""), k(avg(new, "salaries")).replace("+", "")])
        dec_rows.append([seed, "Geçim ve araçlar (kalkar)", k(avg(old, "tools")).replace("+", ""), "0"])
        dec_rows.append([seed, "Servis maliyeti (kalkar)", k(avg(old, "service")).replace("+", ""), "0"])
        dec_rows.append([seed, "Sunucular", k(avg(old, "servers")).replace("+", ""), k(avg(new, "servers")).replace("+", "")])
        dec_rows.append([seed, "Kurucu satırı + kira", "0", k((econ.FOUNDER * sum(r["frac"] for r in new) + sum(r["rent"] * r["frac"] for r in new)) / wk).replace("+", "")])
        dec_rows.append([seed, "Tek seferlik", k(avg(old, "one_time")).replace("+", ""), k(avg(new, "one_time")).replace("+", "")])
        dec_rows.append([seed, "Net (aylık)", k(avg(old, "income") - avg(old, "old_exp")), k(avg(new, "income") - avg(new, "expense"))])
    # ---- gelir etkisi (memnuniyet modeli) B2B
    cpl_rows = []
    for seed in (7, 11):
        run = k5.load(bot.run_name("worst", seed))
        dm, pw = dmrr_months(run, P, seed, "worst")
        for lab, v in (("A", {}), ("C", {"sal_mult": 1.5})):
            v2 = dict(v); v2["dinc"] = dm
            rows = econ.monthly(run, "b2b", v2)
            s = econ.summarize(rows)
            base = econ.summarize(econ.monthly(run, "b2b", v))
            cpl_rows.append([seed, lab, "%s (hf %d)" % (k(base["dip"][0]), base["dip"][1]), "%s (hf %d)" % (k(s["dip"][0]), s["dip"][1]), k(base["c52"]), k(s["c52"]),
                             k(base[3]["net"]), k(s[3]["net"]), k(pw[104]) + " MRR"])
            summ["cpl|%d|%s" % (seed, lab)] = {"dip": s["dip"], "c52": s["c52"], "ph3": s[3]["net"], "base_ph3": base[3]["net"]}
    parts.append("### E1 Nakit ve kâra geçiş (fix_worst; B2B ve B2C ayrı)\n\n" + md(dip_rows, ["Pazar", "tohum", "Varyant", "en derin kümülatif açık", "52. hf kümülatif net", "101. hf kümülatif net",
                                                                                  "ilk net>=0 ay sonu (hf)", "3 ay üst üste net>=0 (hf)", "en düşük runway, ay (evre 1 / 2 / 3)", "en düşük nakit (çek dahil)"]))
    for mk, seed, rowsets in phase_blocks:
        parts.append("#### E2 Evre başına aylık burn / gelir / net: %s tohum %d\n\n" % (mk.upper(), seed) + table_phase(rowsets))
    parts.append("### E3 Sunucunun gelire oranı (%, fix_worst)\n\n" + md(srv_rows, ["Pazar", "tohum", "Kademe", "MVP sonrası ilk ay", "15-25. hf", "26-104. hf", "Evre 3"]))
    parts.append("### E4 Evre 3 kalem kalem (B2B, aylık ortalama)\n\n" + md(dec_rows, ["tohum", "Kalem", "Eski", "A (yeni)"]))
    parts.append("### E5 Memnuniyet modelinin gelir etkisi (B2B, tahmin)\n\n" + md(cpl_rows, ["tohum", "Varyant", "açık (etkisiz)", "açık (etkili)", "52. hf kümülatif (etkisiz)", "(etkili)", "evre 3 net (etkisiz)", "(etkili)", "104. hf MRR farkı"]))
    open(os.path.join(OUT, "p3_tables.md"), "w", encoding="utf-8").write("\n\n".join(parts))
    json.dump(summ, open(os.path.join(OUT, "p3.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print("\n\n".join(parts))


if __name__ == "__main__":
    main()
