"""Bolum 4: kalan kapilar icin ONERI kosulari (model degismez; oneriler ayri kosu, "oneri" diye etiketli). python -I."""
import sys, os, json, random, copy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
import k5, bot, model as M, scen

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
J = {}


def md(rows, head):
    s = "| " + " | ".join(head) + " |\n|" + "---|" * len(head) + "\n"
    for r in rows:
        s += "| " + " | ".join(str(c) for c in r) + " |\n"
    return s


def run_new(gate=True):
    """Her kol ve tohum icin yeni model (mevcut M sabitleriyle). Donus: {(arm, seed): (loss_stats, renew_stats, mean_sat, rejected, signs_n)}"""
    out = {}
    for arm in bot.ARMS:
        for seed in bot.SEEDS:
            run = k5.load(bot.run_name(arm, seed))
            w = bot.build_world(run, arm)
            accts = bot.build_accounts(run, seed)
            signs = {a.id: a.sign for a in accts}
            ev = bot.gen_outages(w, 0.5, 1.0, seed, min(signs.values()))
            res = bot.run_arm(run, w, accts, "new", gate=gate, outages=ev)
            out[(arm, seed)] = (bot.loss_stats(res, signs), bot.renew_stats(res), bot.mean_sat(res), sum(1 for r in res.values() if r.get("rejected")), len(res),
                                bot.nedensiz_total(res)[0])
    return out


def gate_m345(R):
    rows = []
    ok = {"M3": True, "M4": True, "M5": True}
    for seed in bot.SEEDS:
        off = R[("off", seed)][0]; due = R[("due", seed)][0]; worst = R[("worst", seed)][0]; none = R[("none", seed)][0]
        m3 = due["late_pct"] <= off["late_pct"] + 2
        m4 = worst["late_pct"] <= off["late_pct"] + 3 and worst["total_pct"] <= off["total_pct"] + 10
        m5 = none["late_pct"] >= 10 and none["late_pct"] >= 2 * off["late_pct"]
        ok["M3"] &= m3; ok["M4"] &= m4; ok["M5"] &= m5
        rows.append([seed, "%.1f" % off["late_pct"], "%.1f" % due["late_pct"], "%.1f" % worst["late_pct"], "%.1f / %.1f" % (worst["total_pct"], off["total_pct"]),
                     "%.1f" % none["late_pct"], "geçti" if m3 else "kaldı", "geçti" if m4 else "kaldı", "geçti" if m5 else "kaldı"])
    return rows, ok


def cap_what_if():
    rows = []
    res = {}
    for cap in (60.0, 62.0, 64.0, 66.0, 68.0, 70.0, 80.0):
        M.BUG_TERM_CAP = cap
        R = run_new()
        g, ok = gate_m345(R)
        none = [R[("none", s)] for s in bot.SEEDS]; worst = [R[("worst", s)] for s in bot.SEEDS]
        rows.append(["%d" % cap, "; ".join("tohum %d: geç %.1f%% erken %.1f%%" % (s, R[("none", s)][0]["late_pct"], R[("none", s)][0]["early_pct"]) for s in bot.SEEDS),
                     "; ".join("%.1f%%" % R[("worst", s)][0]["late_pct"] for s in bot.SEEDS), "%.1f / %.1f" % (R[("worst", 7)][2], R[("none", 7)][2]),
                     "%s / %s / %s" % ("geçti" if ok["M3"] else "kaldı", "geçti" if ok["M4"] else "kaldı", "geçti" if ok["M5"] else "kaldı"),
                     "%d / %d" % (sum(R[("worst", s)][3] for s in bot.SEEDS), sum(R[("worst", s)][4] for s in bot.SEEDS))])
        res[cap] = {"ok": ok}
    M.BUG_TERM_CAP = 60.0
    J["cap"] = {str(k): v for k, v in res.items()}
    return md(rows, ["hata terimi tavanı", "none kolu kayıp (tohum başına)", "worst kolu geç kayıp", "ort. memnuniyet worst / none (tohum 7)", "M3 / M4 / M5", "worst: kapı reddi / imza"])


def expect_what_if():
    rows = []
    base = copy.deepcopy(M.EXPECT)
    res = {}
    for f in (1.0, 1.5, 2.0):
        for ph in (2, 3):
            for a in M.AREAS:
                M.EXPECT[ph][a] = base[ph][a] * f
        R = run_new()
        # tutum dagilimi (worst, iki tohum)
        st = [0] * 5
        for s in bot.SEEDS:
            for i, v in enumerate(R[("worst", s)][1]["stances"]):
                st[i] += v
        tot = sum(st)
        rows.append(["x%.1f" % f, "%.1f" % ((R[("worst", 7)][2] + R[("worst", 11)][2]) / 2), "%d%% / %d%% / %d%% / %d%% / %d%%" % tuple(round(100 * x / max(1, tot)) for x in st),
                     "%d / %d" % (sum(R[("worst", s)][3] for s in bot.SEEDS), sum(R[("worst", s)][4] for s in bot.SEEDS)),
                     "%.1f / %.1f" % (R[("worst", 7)][0]["total_pct"], R[("worst", 11)][0]["total_pct"]),
                     "%.1f / %.1f" % (R[("none", 7)][0]["late_pct"], R[("none", 11)][0]["late_pct"])])
        res[f] = {"stances": st}
    for ph in (2, 3):
        for a in M.AREAS:
            M.EXPECT[ph][a] = base[ph][a]
    J["expect"] = {str(k): v for k, v in res.items()}
    return md(rows, ["Traction ve Series A çıtası", "worst: ort. memnuniyet", "worst: yenileme tutumu (Zamma açık / Aynı / İndirim ister / Ayrılmayı düşünüyor / Yenilemeyecek)", "worst: kapı reddi / imza",
                     "worst: toplam kayıp % (tohum 7 / 11)", "none: geç kayıp % (tohum 7 / 11)"])


# ------------------------------------------------------------------ M7 onerileri
def mc_cells(pmax=0.30, tier_after_cap=False, runs=2000, T=104, seed=1):
    res = {}
    for bugs in (2, 6, 12):
        for load in (1.0, 1.5, 2.5):
            v = []
            for tier in (1.0, 0.5, 0.25):
                rng = random.Random(seed); tot = 0
                for _ in range(runs):
                    last = -10 ** 6; n = 0
                    for t in range(1, T + 1):
                        u = rng.random()
                        if t - 7 < 3 or t - last < 4: continue
                        if tier_after_cap:
                            p = min(pmax, 0.10 * load * (1 + min(bugs, 12) / 8.0)) * tier
                        else:
                            p = min(pmax, 0.10 * tier * load * (1 + min(bugs, 12) / 8.0))
                        if u < p: n += 1; last = t
                    tot += n
                v.append(tot / runs)
            res[(bugs, load)] = v
    return res


def m7_eval(res):
    bad = 0; kur_low = None
    for (bugs, load), v in res.items():
        if not (v[1] / v[0] <= 0.75 and v[2] / v[1] <= 0.75): bad += 1
    kur_tavan = res[(12, 1.0)][2]
    az = res[(2, 1.0)]
    load_ratio = res[(2, 1.5)][0] / res[(2, 1.0)][0]
    return bad, kur_tavan, load_ratio, res[(2, 1.0)][2]


def m7_what_if():
    rows = []
    out = {}
    for lab, kw in (("bugünkü kural: p_max 0,30; kademe çarpanı tavandan önce", dict(pmax=0.30)),
                    ("öneri a: p_max 0,45", dict(pmax=0.45)),
                    ("öneri b: p_max 0,65", dict(pmax=0.65)),
                    ("öneri c: p_max 0,30; kademe çarpanı tavandan sonra", dict(pmax=0.30, tier_after_cap=True))):
        r = mc_cells(**kw)
        bad, kt, lr, kaz = m7_eval(r)
        rows.append([lab, "%d / 9" % bad, "%.2f" % kt, "%.2f" % kaz, "%.2f" % lr, "; ".join("%s: %s" % (("%d hata, x%s" % k), "/".join("%.1f" % x for x in v)) for k, v in r.items() if k in ((12, 1.5), (12, 2.5)))])
        out[lab] = {"bad": bad, "kur_tavan": kt, "kur_az": kaz, "load_ratio": lr}
    J["m7"] = out
    return md(rows, ["Kural", "≥%25 koşulunu bozan hücre", "Kurumsal olay (tavanda hata, %70 yük)", "Kurumsal olay (az hata, %70 yük)", "%95 / %70 yük oranı (Ekonomik, az hata)", "tavanda hata, yük x1,5 ve x2,5: Eko/Std/Kur"])


if __name__ == "__main__":
    parts = []
    parts.append("### O1 Hata terimi tavanı (öneri koşusu)\n\n" + cap_what_if())
    parts.append("### O2 Pazar çıtası ölçeği (bilgi koşusu)\n\n" + expect_what_if())
    parts.append("### O3 Kesinti kuralı (öneri koşusu)\n\n" + m7_what_if())
    open(os.path.join(OUT, "p4_tables.md"), "w", encoding="utf-8").write("\n\n".join(parts))
    json.dump(J, open(os.path.join(OUT, "p4.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print("\n\n".join(parts))
