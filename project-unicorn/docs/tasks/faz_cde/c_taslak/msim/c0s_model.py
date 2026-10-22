"""C0s modeli. python -I (standart kitaplik).
(1) Q'nun urun uyumu U: ProductQuality @910ad1f (product_quality.gd:13-60, :260-300, :330-394) satir satir.
(2) C'nin memnuniyeti: PRD Karar 5-9 + PLAN_C "E1'de onaya gelen sabitler"; defter, durum terimleri, yas, kapi, yenileme, kurumsal madde.
Python kodun kopyasi degildir: kodla ayrilan her yer `# AYRIM:` ile isaretli, varsayimlar `# VARSAYIM:`."""
import math, random, zlib

# ------------------------------------------------------------------ (1) Q: urun uyumu
FIT_SCALE = 70.0          # product_quality.gd:16
RATIO_CAP = 1.5           # :17
CORE_LEAD = 0.25          # :19
W_CORE = 0.50             # :20
W_B2B = (0.25, 0.15, 0.10)  # :22
CORE_2_NOW = 1.25         # :44 (K9c, 910ad1f)
EMPHASIS_2 = 1.0          # :45
CORE_3 = 2.0              # :46
EMPHASIS_3 = 1.5          # :47
REST_3 = 1.0              # :48
MVP_LINES = 3             # sprint.json "mvp_lines"
CORE_LINES = 5            # ERP Cekirdek: PROBE AREAS core=.../5/...
RIVAL_BUMP = 0.5          # sprint.json rival_bump
RIVAL_BUMP_MAX = 1.0
USE_AREA_MIN = 0.15       # :41
CLOSE_CURVE = [[40.0, 0.30], [55.0, 0.60], [70.0, 0.85], [80.0, 0.95]]   # :36
AREAS = ["core", "onboarding", "integrations", "trust"]
TABLE = {   # :52-66 (vurgu 1, vurgu 2, kalan)
    "health": ("trust", "integrations", "onboarding"), "finance": ("trust", "integrations", "onboarding"),
    "insurance": ("integrations", "trust", "onboarding"), "legal": ("integrations", "trust", "onboarding"),
    "logistics": ("integrations", "trust", "onboarding"), "construction": ("onboarding", "trust", "integrations"),
    "ecommerce": ("trust", "integrations", "onboarding"), "retail": ("trust", "integrations", "onboarding"),
    "technology": ("integrations", "trust", "onboarding"), "manufacturing": ("integrations", "trust", "onboarding"),
    "real_estate": ("onboarding", "integrations", "trust"), "textile": ("integrations", "onboarding", "trust"),
    "media": ("trust", "onboarding", "integrations"),
}
SECTORS = list(TABLE.keys())


def rnd(x):
    return int(math.floor(x + 0.5))      # Godot roundi (pozitifte yarim yukari)


def row(sector):
    return TABLE.get(sector, TABLE["technology"])


def weights(sector):
    r = row(sector)
    return {"core": W_CORE, r[0]: W_B2B[0], r[1]: W_B2B[1], r[2]: W_B2B[2]}


def emphasis(sector):
    return list(row(sector)[:2])


def used_areas(sector):
    w = weights(sector)
    return [a for a in w if w[a] >= USE_AREA_MIN]


def star_value(star, role, core2):
    """product_quality.gd:_star_value."""
    if star == 1 and role == "core":
        return MVP_LINES / CORE_LINES
    if star == 2 and role == "core":
        return core2
    if star == 3 and role == "core":
        return CORE_3
    if star == 2 and role == "emphasis":
        return EMPHASIS_2
    if star == 3 and role == "emphasis":
        return EMPHASIS_3
    if star == 3 and role == "rest":
        return REST_3
    return 0.0


def role_of(area, sector):
    if area == "core":
        return "core"
    return "emphasis" if row(sector).index(area) < 2 else "rest"


def ref_for(star, sector, core2=CORE_2_NOW, launches=None, rivals=False, top=3):
    """{alan: beklenti} (beklentisi 0 olan alan yok). rivals=True aday baglami (rakip penceresi dahil), False hesabin market_ref'i."""
    ref = {}
    for a in weights(sector):
        v = star_value(star, role_of(a, sector), core2)
        if rivals and v > 0.0:
            v += min(RIVAL_BUMP * (launches or {}).get(a, 0), RIVAL_BUMP_MAX)
        v = min(v, top)
        if v > 0.0:
            ref[a] = v
    return ref


def _ratio(lvl, expect):
    return min(lvl / expect, RATIO_CAP)


def fit(levels, ref, sector, areas=None):
    """product_quality.gd:fit_from_levels (B2B). {value, match, capped, weakest_emphasis, loss_area, ratios}."""
    w = weights(sector)
    ratios = {}
    weighted = total = 0.0
    for a in (areas or list(w.keys())):
        e = ref.get(a, 0.0)
        if e > 0.0:
            ratios[a] = _ratio(levels.get(a, 0.0), e)
            weighted += w[a] * ratios[a]
            total += w[a]
    mean = weighted / total
    ceiling = ratios["core"] + CORE_LEAD
    capped = mean > ceiling
    uyum = min(mean, ceiling)
    weakest = _lowest(emphasis(sector), ratios)
    lowest = _lowest(list(ratios.keys()), ratios)
    return {"value": min(100, rnd(FIT_SCALE * uyum)), "match": uyum, "capped": capped, "weakest_emphasis": weakest,
            "loss_area": "core" if capped else (lowest if ratios[lowest] < 1.0 else ""), "ratios": ratios}


def _lowest(areas, ratios):
    out = ""
    for a in areas:
        if a in ratios and (out == "" or ratios[a] < ratios[out]):
            out = a
    return out


def close_chance(u, loss_area):
    """product_quality.gd:close_chance; loss_area bos ise 1."""
    if loss_area == "":
        return 1.0
    u = min(max(u, CLOSE_CURVE[0][0]), CLOSE_CURVE[-1][0])
    for i in range(1, len(CLOSE_CURVE)):
        if u <= CLOSE_CURVE[i][0]:
            x0, y0 = CLOSE_CURVE[i - 1]; x1, y1 = CLOSE_CURVE[i]
            return y0 + (y1 - y0) * (u - x0) / (x1 - x0)
    return CLOSE_CURVE[-1][1]


def word_for(lvl, expect):
    if lvl <= 0.0:
        return "none"
    if lvl < expect:
        return "weak"
    return "enough" if lvl < expect + 1.0 else "strong"


# ------------------------------------------------------------------ (2) C: memnuniyet
# Esik: kodda TOLERANCE_BASE 33 + 9 x (yildiz-1) + sektor eki (b2b_constants.gd:39-45 @910ad1f; PRD Karar 5 "ayrilma esigi formulu kalir").
SECTOR_TOL_BONUS = {"construction": 5, "health": 5, "insurance": 3}


def tol_code(star, sector):
    return 33 + 9 * (star - 1) + SECTOR_TOL_BONUS.get(sector, 0)


def tol_v3(star, sector):
    """C_ICERIK_v3 par. 5.7: 30 + 3 x (yildiz-1) + sektor ekinin yarisi (asagi). AYRIM: kodda yok; duyarlilik kolu."""
    return 30 + 3 * (star - 1) + SECTOR_TOL_BONUS.get(sector, 0) // 2


# Sektor egilimi onerisi (13 sektor). Olcut: sektorun gercek dunya buyume hizi; >= %6 buyuyen, %3-6 istikrarli, < %3 duragan. Kaynaklar C0S_SONUC.md par. 4.
SECTOR_TREND = {"health": "growing", "ecommerce": "growing", "technology": "growing",
                "logistics": "steady", "construction": "steady", "finance": "steady", "legal": "steady", "retail": "steady",
                "textile": "steady", "real_estate": "steady",
                "insurance": "stagnant", "manufacturing": "stagnant", "media": "stagnant"}

CFG = {
    "core2": CORE_2_NOW,
    "bug_k": 3.0, "bug_cap": 60.0,               # PRD Karar 5; M5 icin 60/62/64
    "gate_over": 10,                              # PRD Karar 6
    "tol": tol_code,
    "pos_cap": 10.0,                              # PRD Karar 5 (b2b_constants.gd:267)
    "kept": (6.0, 0), "late": (-3.0, 8), "broken": (-12.0, 13),   # PLAN_C K5: tutar, sure (hafta; 0 = kalici)
    "request": (4.0, 0),                          # istek yayina girdi, yalniz 3 yildiz (Karar 11)
    "outage_dur": 13, "card_dur": 8,
    "st_discount": 8, "st_zam": -2, "st_unwilling": -6, "st_clause": -10,
    "age_free": 26, "age_step": 4, "age_max": 12,
    "touch_kinds": None,                          # None = her kart (Karar 7); {"feat"} vb. duyarlilik
    "age_areas": "emph",                          # Karar 7: yalniz iki vurgu alani; "core+emph" karsilastirma
    "clause_weeks": 8, "clause_margin": 20, "clause_notice": 4, "clause_on": True, "provider_enterprise": False,
    "gate_includes_clause": True,                  # VARSAYIM: kapi toplami okur (Karar 5 formulu durum terimlerini icerir); False = duyarlilik kolu
    "floor": 0.60,                                # PLAN_C K6: kapiyi gecen anlasmada zar tabani
    "contract": 52, "renew_open": 44,
    "ikna": 2,
    "memnun_margin": 12,                          # K8 ve K9: memnun hesap = esik + 12
    "p_growth": {1: 0.25, 2: 0.20, 3: 0.15}, "growth_boost_margin": 25, "growth_boost": 1.5, "growth_range": (0.10, 0.30),
    "p_shrink": {1: 0.05, 2: 0.04, 3: 0.03}, "shrink_range": (0.10, 0.25),
    "p_switch": {1: 0.015, 2: 0.010, 3: 0.005}, "switch_weak": 2.0, "switch_strong": 0.5,
    "p_budget": {1: 0.02, 2: 0.015, 3: 0.01},
    "sector_trend": SECTOR_TREND,                         # sektor -> growing | steady | stagnant (SECTOR_TREND)
    "growth_mult": {"growing": 1.25, "steady": 1.0, "stagnant": 0.75}, "shrink_mult": {"growing": 1.0, "steady": 1.0, "stagnant": 1.5},
    "tol_kept": -5, "tol_broken": 5, "tol_ceil": 10,
    "risk_trigger": 1, "risk_reentry": 3, "churn_cd": 2,
    "cs_dampen": 1.0,                             # VARSAYIM: sahip kurucu (cs_dampen 1,0); temsilcide 0,4-1,0
}


def cfg(**kw):
    c = dict(CFG)
    c.update(kw)
    return c


def bug_term(world, t, sector, c):
    """PRD Karar 5: min(3 H, tavan); H = hesabin kullandigi alanlarda (Cekirdek + iki vurgu) alan agirligiyla (alandaki acik hata / alandaki
    canli hat); canli hatti olmayan alan atlanir, agirliklar yeniden olceklenir (C_ICERIK_v3 par. 5.2)."""
    w = weights(sector)
    num = den = 0.0
    for a in used_areas(sector):
        live = world["live"][t].get(a, 0)
        if live <= 0:
            continue
        num += w[a] * world["open_area"][t].get(a, 0) / live
        den += w[a]
    if den == 0:
        return 0.0
    return min(c["bug_k"] * num / den, c["bug_cap"])


def sign_value(world, t, star, sector, c, bugs_free=False):
    """Hesabin imza degeri: ayni formul, defter bos, yas 0 (Karar 6). Don: (U, hata terimi, toplam)."""
    ref = ref_for(star, sector, c["core2"])
    u = fit(world["levels"][t], ref, sector)["value"]
    bt = 0.0 if bugs_free else bug_term(world, t, sector, c)
    return u, bt, max(0.0, min(100.0, u - bt))


class Acct:
    def __init__(self, aid, sign, star, sector, mrr, by="founder", seed=0, tol_override=None):
        self.tol_override = tol_override; self.id = aid; self.sign = sign; self.star = star; self.sector = sector; self.mrr = mrr; self.by = by
        self.seed = zlib.crc32(("%s|%d" % (aid, seed)).encode())


def stance(diff):
    if diff >= 25: return 0
    if diff >= 12: return 1
    if diff >= 5: return 2
    if diff >= 0: return 3
    return 4


STANCE_NAME = ["Zamma açık", "Aynı fiyat", "İndirim ister", "Ayrılmayı düşünüyor", "Yenilemeyecek"]
STANCE_PRICE = [1.08, 1.0, 0.90, 0.85]


def simulate(a, world, c, events=None, T=None, bugs_free=False, gate=True, renewals=True, risk=True, policy="best", probe=None):
    """Tek hesabin haftalik serisi. events: {'outage': [(t, saat)], 'promise': {cust: [(t, 'kept'|'late'|'broken')]},
    'card': [(t, tutar)], 'request': set(t)}. policy: yenileme raporunda secim ('best' = tutumun en iyi fiyati; 'same' = cevapsiz, aynı fiyat).
    Don: dict (sat, parts, left, left_why, rejected, renew, ...)."""
    T = T or world["T"]
    events = events or {}
    s = a.sign
    tol = a.tol_override if a.tol_override is not None else c["tol"](a.star, a.sector)
    tol_ceiling = tol + c["tol_ceil"]
    ref = ref_for(a.star, a.sector, c["core2"])
    watch = emphasis(a.sector) if c["age_areas"] == "emph" else ["core"] + emphasis(a.sector)
    rng = random.Random(a.seed)
    rows = []                    # [tutar, baslangic, sure(0 = kalici), ad]
    status = {}
    last_touch = s
    phase_r = "active"; cd = -1; last_exit = -10 ** 6; streak = 0
    mrr = float(a.mrr)
    out = {"sat": {}, "parts": {}, "left": None, "left_why": None, "rejected": False, "renew": [], "tol": {}, "named": {}, "drop_weeks": 0,
           "unnamed": 0, "risk_weeks": 0, "risk_entered": 0, "mrr": {}, "sat0": None, "notice": None, "clause": None}
    prev_sat = None; prev_parts = None
    clause_open = (a.star >= 3 and c["clause_on"] and not c["provider_enterprise"])
    clause_start = s; notice_end = None
    pend = None
    for t in range(s, T + 1):
        named = False
        # ---- olaylar -> defter
        if t > s:
            tch = world["touch"][t] if c.get("touch_kinds") is None else {ar for (ar, kd) in world.get("touch_k", {}).get(t, ()) if kd in c["touch_kinds"]}
            if (tch & set(watch)):
                if t - last_touch > c["age_free"]:
                    named = True
                last_touch = t
            for rid in world["reqs"][t]:
                if rid == a.id and a.star >= 3:
                    rows.append([c["request"][0], t, c["request"][1], "request"]); named = True
            for (tt, hrs) in events.get("outage", []):
                if tt == t:
                    amt = -float(rnd(min(8.0, 0.6 * hrs)))
                    if amt != 0:
                        rows.append([amt, t, c["outage_dur"], "outage"]); named = True
            for (tt, outc) in events.get("promise", {}).get(a.id, []):
                if tt == t:
                    amt, dur = c[outc]
                    rows.append([amt, t, dur, outc]); named = True
                    if outc == "kept": tol += c["tol_kept"]
                    elif outc == "broken": tol = min(tol + c["tol_broken"], tol_ceiling)
            for (tt, amt) in events.get("card", []):
                if tt == t:
                    rows.append([amt, t, (0 if amt > 0 else c["card_dur"]), "card"]); named = True
        renew_open = renewals and t > s and (t - s) % c["contract"] == c["renew_open"]
        if renew_open:
            ref = ref_for(a.star, a.sector, c["core2"]); named = True      # market_ref tazelenir (rakipsiz: sabit)
            for k in ("zam", "indirim", "unwilling"):
                status.pop(k, None)
        # ---- terimler
        u = fit(world["levels"][t], ref, a.sector)["value"]
        bt = 0.0 if bugs_free else bug_term(world, t, a.sector, c)
        neg = pos = 0.0
        for amt, st0, dur, nm in rows:
            if dur == 0:
                if amt > 0: pos += amt
                else: neg += amt
            else:
                neg += amt * max(0.0, 1.0 - (t - st0) / (dur * c["cs_dampen"]))
        led = neg + min(c["pos_cap"], pos)
        if clause_open and notice_end is None:
            status["clause"] = c["st_clause"]
        else:
            status.pop("clause", None)
        stat = sum(status.values())
        wk = t - last_touch
        age = 0 if wk <= c["age_free"] else min(c["age_max"], (wk - c["age_free"]) // c["age_step"])
        total = max(0.0, min(100.0, u - bt + led + stat - age))
        sat = rnd(total)
        parts = (u, round(bt, 6), tuple(sorted(status.items())), age)
        if prev_parts is not None and parts != prev_parts:
            named = True
        prev_parts = parts
        out["parts"][t] = {"U": u, "bug": bt, "ledger": led, "status": stat, "age": age, "wk": wk}
        if t == s:
            named = True
            base = sat if c["gate_includes_clause"] else rnd(max(0.0, min(100.0, u - bt)))
            if c.get("gate_rivals"):      # kapi adayin U'sunu okur (rakip penceresi dahil): VARSAYIM duyarlilik kolu
                ug = fit(world["levels"][t], ref_for(a.star, a.sector, c["core2"], launches=world["launch"][t], rivals=True), a.sector)["value"]
                base = rnd(max(0.0, min(100.0, ug - bt + (c["st_clause"] if (clause_open and c["gate_includes_clause"]) else 0))))
            out["sat0"] = base; out["U0"] = u; out["bug0"] = bt
            if gate and base < tol + c["gate_over"]:
                out["rejected"] = True
                return out
        # ---- Kurumsal madde takvimi (C4): sure dolunca zarsiz kural
        if clause_open and t > s and notice_end is None and (t - clause_start) >= c["clause_weeks"]:
            if (t - clause_start) == c["clause_weeks"] or (t - clause_start - c["clause_weeks"]) % 4 == 0:   # ay basi ~ 4 hafta
                if sat - tol < c["clause_margin"]:
                    notice_end = t + c["clause_notice"]; out["notice"] = t
        if notice_end is not None and t >= notice_end:
            out["left"] = t; out["left_why"] = "clause"
            out["sat"][t] = sat; out["named"][t] = True; out["tol"][t] = tol; out["mrr"][t] = mrr
            break
        out["sat"][t] = sat; out["named"][t] = named; out["tol"][t] = tol; out["mrr"][t] = mrr
        if prev_sat is not None and sat <= prev_sat - 1:
            out["drop_weeks"] += 1
            if not named:
                out["unnamed"] += 1
        prev_sat = sat
        if renew_open:
            diff = sat - tol + c["ikna"]
            fr = fit(world["levels"][t], ref, a.sector)
            wa = fr["weakest_emphasis"]
            wd = word_for(world["levels"][t].get(wa, 0.0), ref[wa]) if wa in ref else "enough"
            pend = {"t": t, "sat": sat, "tol": tol, "diff": diff, "stance": stance(diff), "seats_mrr": mrr, "weak_word": wd,
                    "switch_mult": {"none": c["switch_weak"], "weak": c["switch_weak"], "enough": 1.0, "strong": c["switch_strong"]}[wd]}
        # ---- risk makinesi (b2b_sales_system.gd _tick_at_risk; sabitler b2b_constants.gd:21-27)
        if risk:
            if sat < tol:
                streak += 1; out["risk_weeks"] += 1
                if phase_r != "risk":
                    if streak >= c["risk_trigger"] and not (last_exit >= 0 and t - last_exit < c["risk_reentry"]):
                        phase_r = "risk"; cd = c["churn_cd"]; out["risk_entered"] += 1
                else:
                    cd -= 1
                    if cd <= 0:
                        out["left"] = t; out["left_why"] = "risk"
                        break
            else:
                streak = 0
                if phase_r == "risk":
                    phase_r = "active"; cd = -1; last_exit = t
        # ---- yenileme sonucu (Karar 8 ve 9): tek zar
        if renew_open and pend is not None and pend["t"] == t:
            res = _renew(a, pend, mrr, c, rng, policy, status)
            out["renew"].append(res)
            mrr = res["mrr_after"]
            if res["result"] == "leave":
                out["left"] = a.sign + (((t - a.sign) // c["contract"]) + 1) * c["contract"]
                out["left_why"] = res["why"]
                out["decided"] = t
                break
    out["mrr_end"] = mrr if out["left"] is None else 0
    return out


def _renew(a, p, mrr, c, rng, policy, status):
    """Tek zar: butce > baska urune gecis > mali azalis > koltuk artisi (siralama VARSAYIM: nadirden yaygina; PRD sirayi yazmiyor)."""
    star = a.star
    sat, tol = p["sat"], p["tol"]
    st = p["stance"]
    memnun = sat >= tol + c["memnun_margin"]
    trend = (c["sector_trend"] or {}).get(a.sector, "steady")
    u = rng.random()
    res = {"t": p["t"], "star": star, "stance": st, "diff": p["diff"], "mrr_before": mrr, "sector": a.sector, "memnun": memnun,
           "outcome": "none", "result": "renew", "why": None, "seats_factor": 1.0, "price_factor": 1.0, "trend": trend}
    acc = c["p_budget"][star]
    out = "none"
    if u < acc:
        out = "budget"
    else:
        if st != 4:
            acc += c["p_switch"][star] * p.get("switch_mult", 1.0)
            if u < acc:
                out = "switch"
        if out == "none" and memnun:
            acc += c["p_shrink"][star] * c["shrink_mult"][trend]
            if u < acc:
                out = "shrink"
            else:
                pg = c["p_growth"][star] * c["growth_mult"][trend]
                if sat >= tol + c["growth_boost_margin"]:
                    pg *= c["growth_boost"]
                acc += pg
                if u < acc:
                    out = "growth"
    res["outcome"] = out
    if out == "budget":
        if memnun:
            res["seats_factor"] = 0.5
        else:
            res["result"] = "leave"; res["why"] = "budget"
    elif out == "switch":
        res["result"] = "leave"; res["why"] = "switch"
    elif st == 4:
        res["result"] = "leave"; res["why"] = "stance"
    if res["result"] == "renew":
        price = STANCE_PRICE[st] if st <= 3 else 1.0
        if policy == "same":
            # cevapsiz kagit: herkese ayni fiyat (basamak 1). Tutumun bir basamak ustu gonulsuz kabul, iki ve fazlasi yenilemez (v2 par. 2.6.1)
            if st >= 3:
                res["result"] = "leave"; res["why"] = "stance_same"
            elif st == 2:
                status["unwilling"] = c["st_unwilling"]; price = 1.0
            else:
                price = 1.0
        else:
            if st == 0:
                status["zam"] = c["st_zam"]
            elif st in (2, 3):
                status["indirim"] = c["st_discount"]
        if res["result"] == "renew":
            if out == "growth":
                lo, hi = c["growth_range"]
                res["seats_factor"] = 1.0 + lo + (hi - lo) * rng.random()
            elif out == "shrink":
                lo, hi = c["shrink_range"]
                res["seats_factor"] = 1.0 - (lo + (hi - lo) * rng.random())
            res["price_factor"] = price
    res["mrr_after"] = mrr * res["seats_factor"] * res["price_factor"] if res["result"] == "renew" else mrr
    return res
