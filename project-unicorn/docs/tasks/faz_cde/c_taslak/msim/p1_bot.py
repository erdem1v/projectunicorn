"""Bolum 1: bot kollari (K5, B2B, 4 kol x 2 tohum) uzerinde eski / yeni memnuniyet. python -I.
Cikti: out/p1.json (sayilar), out/p1_tables.md (tablolar)."""
import sys, os, json, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import k5, bot, model as M, real_old

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
os.makedirs(OUT, exist_ok=True)

LABEL = {"none": "hiç düzeltmeyen (none)", "worst": "en kötüsünü düzelten (worst)", "due": "vadesi gelen düzelten (due)", "off": "hata bedeli kapalı (off)"}
MODELS = ["real", "old", "old_nt", "new", "new_ng"]
MNAME = {"real": "K5 gerçek (eski kod, gizli eksen)", "old": "Eski mekanizma, aynı U", "old_nt": "Eski mekanizma, aynı U, yeni eşik",
         "new": "Yeni (imza kapısı açık)", "new_ng": "Yeni (kapı kapalı)"}


def real_results(run):
    res = {}
    rs = bot.real_series(run)
    for aid, r in rs.items():
        res[aid] = {"sat": r["sat"], "left": r["left"], "left_why": "risk" if r["left"] else None, "rejected": False, "renew": [],
                    "nedensiz": 0, "drop_weeks": 0}
    return res


def collect():
    P = {}
    for arm in bot.ARMS:
        P[arm] = {m: {"res": {}, "signs": {}} for m in MODELS}
        for seed in bot.SEEDS:
            run = k5.load(bot.run_name(arm, seed))
            w = bot.build_world(run, arm)
            accts = bot.build_accounts(run, seed)
            signs = {(seed, a.id): a.sign for a in accts}
            out = bot.gen_outages(w, 0.5, 1.0, seed, min(a.sign for a in accts))
            allres = {
                "real": real_results(run),
                "old": bot.run_arm(run, w, accts, "old", outages=out),
                "old_nt": bot.run_arm(run, w, accts, "old", outages=out, tol_new_for_old=True),
                "new": bot.run_arm(run, w, accts, "new", outages=out),
                "new_ng": bot.run_arm(run, w, accts, "new", gate=False, outages=out),
            }
            for m in MODELS:
                for aid, r in allres[m].items():
                    P[arm][m]["res"][(seed, aid)] = r
                    P[arm][m]["signs"][(seed, aid)] = signs.get((seed, aid), r.get("sign"))
            # her tohum icin ayri kayip istatistigi (A'nin kapilari tohum basina)
            P[arm].setdefault("per_seed", {})[seed] = {m: bot.loss_stats({a: r for a, r in allres[m].items()}, {a.id: a.sign for a in accts}) for m in MODELS}
            P[arm].setdefault("outages", {})[seed] = out
            P[arm].setdefault("real_ned", {})[seed] = real_old.nedensiz(run)
            P[arm].setdefault("first", {})[seed] = real_old.first_weeks(run)[0:1] + (real_old.first_weeks(run)[3],)
    return P


def fmt(x, d=1):
    return "-" if x is None else ("%.*f" % (d, x))


def age_table(P):
    lines = ["| Kol | Model | " + " | ".join("hafta %d" % a for a in bot.AGES) + " |", "|---|---|" + "---|" * len(bot.AGES)]
    for arm in bot.ARMS:
        for m in ("real", "old", "new"):
            S = bot.age_summary(P[arm][m]["res"], P[arm][m]["signs"])
            cells = []
            for a in bot.AGES:
                n, mean, med, p10, p90 = S[a]
                cells.append("-" if n == 0 else "%d (%d)" % (round(mean), p10))
            lines.append("| %s | %s | %s |" % (LABEL[arm] if m == "real" else "", MNAME[m], " | ".join(cells)))
    return "\n".join(lines)


def loss_table(P):
    lines = ["| Kol | Model | Erken kayıp (adet, %) | Geç kayıp (adet, %) | Toplam % | Yenileme kararı | Yenilememe % | Bütçe kesintisi olayı | İmza kapısı reddi |",
             "|---|---|---|---|---|---|---|---|---|"]
    for arm in bot.ARMS:
        for m in ("real", "old", "new"):
            ps = P[arm]["per_seed"]
            e = sum(ps[s][m]["early"] for s in bot.SEEDS); l = sum(ps[s][m]["late"] for s in bot.SEEDS)
            ep = [ps[s][m]["early_pct"] for s in bot.SEEDS]; lp = [ps[s][m]["late_pct"] for s in bot.SEEDS]; tp = [ps[s][m]["total_pct"] for s in bot.SEEDS]
            rs = bot.renew_stats(P[arm][m]["res"])
            rej = sum(1 for r in P[arm][m]["res"].values() if r.get("rejected"))
            n = len(P[arm][m]["res"])
            lines.append("| %s | %s | %d (%.1f / %.1f) | %d (%.1f / %.1f) | %.1f / %.1f | %s | %s | %s | %s |" % (
                LABEL[arm] if m == "real" else "", MNAME[m], e, ep[0], ep[1], l, lp[0], lp[1], tp[0], tp[1],
                "-" if m == "real" else rs["decisions"], "-" if m == "real" else "%.1f" % rs["leave_pct"],
                "-" if m == "real" else rs["budget_events"], "-" if m != "new" else "%d / %d" % (rej, n)))
    return "\n".join(lines)


def ned_table(P):
    lines = ["| Kol | K5 gerçek: düşüş haftası | K5 gerçek: nedensiz (dar) | K5 gerçek: nedensiz (geniş) | Eski, aynı U: nedensiz | Yeni: nedensiz | Yeni: düşüş haftası (hepsi adlı) |", "|---|---|---|---|---|---|---|"]
    for arm in bot.ARMS:
        rn = P[arm]["real_ned"]
        d = sum(rn[s][0] for s in bot.SEEDS); s1 = sum(rn[s][1] for s in bot.SEEDS); s2 = sum(rn[s][2] for s in bot.SEEDS)
        o = bot.nedensiz_total(P[arm]["old"]["res"]); n = bot.nedensiz_total(P[arm]["new"]["res"]); ng = bot.nedensiz_total(P[arm]["new_ng"]["res"])
        lines.append("| %s | %d | %d | %d | %d | %d | %d |" % (LABEL[arm], d, s1, s2, o[0], n[0] + ng[0], n[1]))
    return "\n".join(lines)


if __name__ == "__main__":
    P = collect()
    open(os.path.join(OUT, "p1_tables.md"), "w", encoding="utf-8").write(
        "### S1 Zaman serisi (ortalama, parantezde p10; iki tohum birleşik)\n\n" + age_table(P) + "\n\n### S2 Kayıp ve yenileme\n\n" + loss_table(P)
        + "\n\n### S3 Nedensiz düşüş\n\n" + ned_table(P) + "\n")
    import pickle
    pickle.dump(P, open(os.path.join(OUT, "p1.pkl"), "wb"))
    print(open(os.path.join(OUT, "p1_tables.md"), encoding="utf-8").read())
