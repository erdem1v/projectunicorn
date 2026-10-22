"""Memnuniyet modelleri: YENI (C_ICERIK_v3 par. 5) ve ESKI (bugunku kod). Yalniz standart kitaplik (python -I).
Her formulun yanindaki [v3 par. N] = C_ICERIK_v3.md paragraf numarasi; [K par. N] = KALITE_v2.md; [kod dosya:satir] = bugunku kod.
Model degistirilmez: bu dosyadaki sayilar belgedeki sayilardir, yorum gereken yerler `# YORUM:` ile isaretli."""
import math, random

# ------------------------------------------------------------------ sabitler (belgeden)
# Ayrilma esigi. ESKI: b2b_constants.gd:35-36,46 (TOLERANCE_BASE 33, PER_SCALE 9, sektor ek: insaat/saglik 5, sigorta 3)
SECTOR_BONUS = {"construction": 5, "health": 5, "insurance": 3}
def tol_old(star, sector):
    return 33 + 9 * (star - 1) + SECTOR_BONUS.get(sector, 0)
# YENI: [v3 par. 5.7] 30 + 3 x (yildiz - 1) + sektor ekinin yarisi (en cok 38). YORUM: yari = tam sayiya yuvarlanir asagi (5 -> 2).
def tol_new(star, sector):
    return 30 + 3 * (star - 1) + SECTOR_BONUS.get(sector, 0) // 2

# Ilk 4 hafta, kayma [kod b2b_constants.gd:13-17,30-31]
ONB_WEEKS = 4; GRACE_MARGIN = 2; SAT_DRIFT_STEP = 3; ONB_AMP = 1.5; DAYS = 7
SIGN_OVER = 10; SIGN_MIN = 50                      # b2b_constants.gd:19-20
BUG_PER_OLD = 0.3; BUG_CAP_OLD = 20               # b2b_constants.gd:58-59
TRUST_DECAY_DAY = 0.4; TRUST_MIN = -25.0; TRUST_MAX = 10.0   # b2b_constants.gd:267-269
PROM_KEPT_SAT = 15; PROM_BROKEN_SAT = -20; PROM_PARTIAL_SAT = -5
PROM_KEPT_OFF = 6.0; PROM_PARTIAL_OFF = -2.0; PROM_BROKEN_OFF = -12.0
PROM_KEPT_TOL = -5; PROM_BROKEN_TOL = 5; PROM_TOL_CEIL = 10
RISK_TRIGGER = 1; RISK_REENTRY = 3; CHURN_CD = 2   # b2b_constants.gd:21-25,26-27 (ticks(w) = w, time_model.gd:23)
CS_DAMPEN_PER_POINT = 0.055; CS_DAMPEN_MIN = 0.4   # b2b_constants.gd:184-190
def cs_dampen(output):
    return min(1.0, max(CS_DAMPEN_MIN, 1.0 - max(output, 0) * CS_DAMPEN_PER_POINT))

# YENI model sayilari [CALISMA]
BUG_K = 3.0; BUG_TERM_CAP = 60.0                   # [v3 par. 5.2]
POS_CAP = 10.0                                      # [v3 par. 5.3] olumlu kalici toplam en cok +10
AGE_FREE = 26; AGE_STEP = 4; AGE_MAX = 12           # [v3 par. 5.5]
GATE_OVER = 10                                      # [v3 par. 5.4] imza kapisi
FIT_BASE = 70.0; CAP_MARGIN = 0.25; R_MAX = 1.5     # [K par. 3.1, 3.4, 2.5]
# Ledger satirlari [v3 par. 5.3]: (tutar, sure hafta, kalici mi)
ROW = {"kept": (6.0, 0, True), "late": (-3.0, 8, False), "broken": (-12.0, 13, False), "request": (4.0, 0, True)}
OUTAGE_DUR = 13; CARD_DUR = 8
# Alan agirliklari [K par. 2.5]: Cekirdek .50, vurgu1 .25, vurgu2 .15, kalan .10
W_CORE, W_V1, W_V2, W_REST = 0.50, 0.25, 0.15, 0.10
# Sektor -> (vurgu1, vurgu2, kalan) [K par. 2.4]; alan kimlikleri: onboarding, integrations, trust (Guven & Olcek)
SECTOR_AREAS = {
    "health": ("trust", "integrations", "onboarding"), "finance": ("trust", "integrations", "onboarding"),
    "insurance": ("integrations", "trust", "onboarding"), "legal": ("integrations", "trust", "onboarding"),
    "logistics": ("integrations", "trust", "onboarding"), "construction": ("onboarding", "trust", "integrations"),
    "ecommerce": ("trust", "integrations", "onboarding"), "retail": ("trust", "integrations", "onboarding"),
    "technology": ("integrations", "trust", "onboarding"), "manufacturing": ("integrations", "trust", "onboarding"),
    "textile": ("integrations", "onboarding", "trust"), "real_estate": ("onboarding", "integrations", "trust"),
    "media": ("trust", "onboarding", "integrations"),
}
NIGHT_SECTORS = ("logistics", "manufacturing", "health")   # sprint.json incident.outage.night_sectors (yalniz bilgi)
AREAS = ["core", "onboarding", "integrations", "trust"]

# Pazar beklentisi [K par. 3.2 oneri]: evre -> alan -> beklenti. Bootstrap'ta Cekirdek = MVP seviyesi (3 hat / 5 hat = 0.6).
MVP_LEVEL = 0.6
EXPECT = {1: {"core": MVP_LEVEL, "onboarding": 0.0, "integrations": 0.0, "trust": 0.0},
          2: {"core": 1.0, "onboarding": 0.5, "integrations": 0.5, "trust": 0.5},
          3: {"core": 1.5, "onboarding": 1.0, "integrations": 1.0, "trust": 1.0}}
RAMP_WEEKS = 8                                      # [K par. 3.2] evre gecisinde aday beklentisi 8 haftada dogrusal


def weights(sector):
    v1, v2, rest = SECTOR_AREAS[sector]
    return {"core": W_CORE, v1: W_V1, v2: W_V2, rest: W_REST}


def watched(sector):
    """[v3 par. 5.5] hesabin baktigi alanlar: Cekirdek ve sektorun iki vurgu alani."""
    v1, v2, _ = SECTOR_AREAS[sector]
    return {"core", v1, v2}


def rnd(x):
    return int(math.floor(x + 0.5))                 # Godot round (yarim yukari)


def fit(levels, ref, sector):
    """[K par. 3.4] m = sum w r / sum w (yalniz beklenen alanlar); uyum = min(m, r_core + .25); U = min(100, round(70 uyum))."""
    w = weights(sector)
    num = den = 0.0
    r = {}
    for a in AREAS:
        e = ref.get(a, 0.0)
        if e <= 0:
            continue
        r[a] = min(levels[a] / e, R_MAX)
        num += w[a] * r[a]; den += w[a]
    if den == 0 or "core" not in r:
        return 0.0
    m = num / den
    return min(100.0, FIT_BASE * min(m, r["core"] + CAP_MARGIN))


def bug_term(open_bugs, live_total, free):
    """[v3 par. 5.2] H = sum w_a (acik_a / canli_hat_a); acik hata alanlara canli hat sayisiyla orantili dagildigi icin
    her alanda acik_a/canli_a = acik/toplam canli hat; agirliklar yeniden olceklenince H = acik / toplam canli hat. min(3H, 60)."""
    if free or live_total <= 0:
        return 0.0
    return min(BUG_K * open_bugs / live_total, BUG_TERM_CAP)


# ------------------------------------------------------------------ dunya
class World:
    """Haftalik girdiler. levels[t][alan], live[t] (toplam canli hat), open[t], touch[t] (set), phase[t], reqs[t] (list)."""
    def __init__(self, T, levels, live, open_, touch, phase, reqs, free=False, acct_bug_ratio=0.6):
        self.T = T; self.levels = levels; self.live = live; self.open = open_; self.touch = touch
        self.phase = phase; self.reqs = reqs; self.free = free; self.ratio = acct_bug_ratio
        self._cand = {}

    def cand_expect(self, t):
        """Aday baglami beklentisi (rakip etkisi yok): evre tablosu + evre gecisinde 8 hafta dogrusal rampa. [K par. 3.2]
        YORUM: yeni beklenen alan (0 -> .5) rampasiz tam degerle girer; sifirdan rampa tanimsiz (alan dahil / haric ikili)."""
        if t in self._cand:
            return self._cand[t]
        t = min(max(t, 1), self.T)
        ph = self.phase[t]
        t0 = t
        while t0 > 1 and self.phase[t0 - 1] == ph:
            t0 -= 1
        out = dict(EXPECT[ph])
        if ph > 1 and t0 > 1:
            prev = EXPECT[ph - 1]
            f = min(1.0, (t - t0) / RAMP_WEEKS)
            for a in AREAS:
                if prev[a] > 0:
                    out[a] = prev[a] + (EXPECT[ph][a] - prev[a]) * f
        self._cand[t] = out
        return out

    def old_bugs(self, t, acct_series=None):
        if acct_series is not None and t in acct_series:
            return acct_series[t]
        return 0 if self.free else rnd(self.ratio * self.open[t])


class Frozen:
    """Bir haftanin dunyasini sonsuza dek tutan sarmalayici (M2: urun ve hata sabit)."""
    def __init__(self, w, t0, touch_all=False):
        self.w = w; self.t0 = t0; self.T = 10 ** 6; self.free = w.free; self.ratio = w.ratio
        self.levels = _Const(w.levels[t0]); self.live = _Const(w.live[t0]); self.open = _Const(w.open[t0])
        self.touch = _Const(set(AREAS) if touch_all else set()); self.phase = _Const(w.phase[t0]); self.reqs = _Const([])
        self._ce = w.cand_expect(t0)
    def cand_expect(self, t): return self._ce
    def old_bugs(self, t, acct_series=None): return 0 if self.free else rnd(self.ratio * self.open[t])


class _Const:
    def __init__(self, v): self.v = v
    def __getitem__(self, t): return self.v


# ------------------------------------------------------------------ hesap simulasyonu
class Acct:
    def __init__(self, aid, sign, star, sector, mrr, owner_output=0, persuasion=2, tol_override=None,
                 acct_bugs=None, rng_seed=0):
        self.id = aid; self.sign = sign; self.star = star; self.sector = sector; self.mrr = mrr
        self.damp = cs_dampen(owner_output); self.persuasion = persuasion
        self.tol_override = tol_override; self.acct_bugs = acct_bugs; self.seed = rng_seed


# Yenileme tutumu [C_ICERIK_v2 par. 2.6.1 tablo]: fark = memnuniyet - esik + ikna
def stance(diff):
    if diff >= 25: return 0       # Zamma acik (%8 zam)
    if diff >= 12: return 1       # Ayni fiyat ister
    if diff >= 5: return 2        # Indirim ister (%10)
    if diff >= 0: return 3        # Ayrilmayi dusunuyor (%15)
    return 4                      # Yenilemeyecek
STANCE_NAME = ["Zamma açık", "Aynı fiyat", "İndirim ister", "Ayrılmayı düşünüyor", "Yenilemeyecek"]
RENEW_OPEN = 44; CONTRACT = 52                      # [v3 par. 6 -> v2 par. 2.6] bitise 8 hafta kala donem acilir
BUDGET_P = {1: 0.02, 2: 0.015, 3: 0.01}             # [v3 par. 4] 1 yildiz %2, 2 yildiz %1,5, 3 yildiz %1
SHRINK_MARGIN = 12                                  # [v3 par. 4] memnun hesap: memnuniyet >= esik + 12
TERM_ZAM = -2; TERM_DISCOUNT = 8                    # [v3 par. 5.2 durum terimleri]


def clamp_trust(x):
    return max(TRUST_MIN, min(TRUST_MAX, x))


def simulate(a, w, mode, T=None, gate=True, events=None, risk=True, renewals=True, budget_cut=True):
    """Tek hesabin haftalik serisi. mode: 'new' | 'old'.
    events: {'outage': [(t, saat)], 'promise': [(t_sonuc, 'kept'|'late'|'broken')], 'card': [(t, tutar)]}.
    Donus: dict. Ayrilis: out['left'] = hesabin kayip sayildigi hafta, out['left_why'] = 'risk' | 'renew_stance' | 'renew_leave'."""
    T = T or w.T
    events = events or {}
    s = a.sign
    tol_seed = tol_new(a.star, a.sector) if mode == "new" else tol_old(a.star, a.sector)
    tol = a.tol_override if a.tol_override is not None else tol_seed
    tol_ceiling = tol + PROM_TOL_CEIL
    rng = random.Random(a.seed)
    phase_r = "active"; cd = -1; last_exit = -10 ** 6; streak = 0
    ref = dict(w.cand_expect(s))
    rows = []                 # yeni defter: [tutar, baslangic, sure(hafta; 0 = kalici), ad]
    status = {}               # durum terimleri (bir sonraki yenilemeye kadar)
    last_touch = s
    trust = 0.0               # eski model: tek sayili guven defteri
    sat = None; prev_sat = None; prev_parts = None
    mrr = a.mrr
    watch = watched(a.sector)
    out = {"sat": {}, "named": {}, "nedensiz": 0, "drop_weeks": 0, "left": None, "left_why": None, "rejected": False,
           "renew": [], "min_margin": None, "risk_weeks": 0, "risk_entered": 0, "tol": {}, "parts": {}}
    pend = None
    for t in range(s, T + 1):
        named = False
        lv = w.levels[t]; live_tot = w.live[t]; opn = w.open[t]
        renew_open = renewals and t > s and (t - s) % CONTRACT == RENEW_OPEN
        if renew_open:
            ref = dict(w.cand_expect(t)); named = True       # [v3 par. 5.6] yenileme donemi acilinca referans guncellenir
            for k in ("zam", "indirim"):
                status.pop(k, None)
        if mode == "new":
            if t > s and (w.touch[t] & watch):
                last_touch = t
            if t > s:
                for rid in w.reqs[t]:
                    if rid == a.id:
                        rows.append([ROW["request"][0], t, 0, "request"]); named = True
                for (tt, hrs) in events.get("outage", []):
                    if tt == t:
                        amt = -float(rnd(min(8.0, 0.6 * hrs)))
                        if amt != 0:
                            rows.append([amt, t, OUTAGE_DUR, "outage"]); named = True
                for (tt, outc) in events.get("promise", []):
                    if tt == t:
                        amt, dur, _ = ROW[outc]
                        rows.append([amt, t, dur, outc]); named = True
                        if outc == "kept": tol += PROM_KEPT_TOL
                        elif outc == "broken": tol = min(tol + PROM_BROKEN_TOL, tol_ceiling)
                for (tt, amt) in events.get("card", []):
                    if tt == t:
                        rows.append([amt, t, (0 if amt > 0 else CARD_DUR), "card"]); named = True
            U = fit(lv, ref, a.sector)
            bt = bug_term(opn, live_tot, w.free)
            neg = 0.0; pos = 0.0
            for amt, st0, dur, nm in rows:
                if dur == 0:
                    if amt > 0: pos += amt
                    else: neg += amt
                else:
                    neg += amt * max(0.0, 1.0 - (t - st0) / (dur * a.damp))
            led = neg + min(POS_CAP, pos)
            stat = sum(status.values())
            wk = t - last_touch
            age = 0 if wk <= AGE_FREE else min(AGE_MAX, (wk - AGE_FREE) // AGE_STEP)
            total = max(0.0, min(100.0, U - bt + led + stat - age))
            sat = rnd(total)
            parts = (rnd(U), round(bt, 4), tuple(sorted(status.items())), age)
            if prev_parts is not None and parts != prev_parts:
                named = True
            prev_parts = parts
            out["parts"][t] = {"U": rnd(U), "bug": bt, "ledger": led, "status": stat, "age": age, "wk": wk}
            if t == s:
                out["sat0"] = sat; out["U0"] = rnd(U); named = True
                if gate and sat < tol + GATE_OVER:       # [v3 par. 5.4] imza kapisi
                    out["rejected"] = True
                    return out
        else:
            # ---------------- ESKI model [kod b2b_sales_system.gd:48-157; sales_system.gd:364-368]
            U = fit(lv, ref, a.sector)
            bugs_n = w.old_bugs(t, a.acct_bugs)
            if t == s:
                sat = max(tol + SIGN_OVER, SIGN_MIN)
                out["sat0"] = sat; out["U0"] = rnd(U); named = True
            else:
                if abs(trust) > 1e-9:
                    trust = math.copysign(max(0.0, abs(trust) - TRUST_DECAY_DAY * DAYS), trust)
                for rid in w.reqs[t]:
                    if rid == a.id: named = True
                for (tt, hrs) in events.get("outage", []):
                    if tt == t:
                        trust = clamp_trust(trust - float(rnd(min(8.0, 0.6 * hrs)))); named = True
                for (tt, outc) in events.get("promise", []):
                    if tt == t:
                        named = True
                        if outc == "kept":
                            tol += PROM_KEPT_TOL; trust = clamp_trust(trust + PROM_KEPT_OFF)
                            sat = min(100, sat + PROM_KEPT_SAT)
                            if phase_r == "risk": phase_r = "active"; cd = -1; last_exit = t
                            streak = 0
                        elif outc == "late":
                            sat = max(0, sat + PROM_PARTIAL_SAT); trust = clamp_trust(trust + PROM_PARTIAL_OFF)
                        else:
                            sat = max(0, sat + PROM_BROKEN_SAT); tol = min(tol + PROM_BROKEN_TOL, tol_ceiling)
                            trust = clamp_trust(trust + PROM_BROKEN_OFF)
                health = U - min(BUG_PER_OLD * bugs_n, BUG_CAP_OLD)
                if t < s + ONB_WEEKS:
                    health = max(health, tol + GRACE_MARGIN)
                target = max(0, min(100, rnd(health + trust)))
                step = SAT_DRIFT_STEP
                if t < s + ONB_WEEKS:
                    step = int(math.ceil(step * ONB_AMP))
                down = int(step * a.damp)
                gap = target - sat
                sat = sat + max(-down * DAYS, min(step * DAYS, gap))
                sat = int(max(0, min(100, sat)))
                # olay karti (EventGate, slot 6) surucuden SONRA calisir: tik sonunda delta gorunur, sonraki tik siler [kod time_manager.gd:383-416]
                for (tt, amt) in events.get("card", []):
                    if tt == t:
                        sat = max(0, min(100, sat + amt)); named = True
                out["parts"][t] = {"U": rnd(U), "bug": min(BUG_PER_OLD * bugs_n, BUG_CAP_OLD), "target": target, "trust": trust}
            parts = (rnd(U), min(BUG_PER_OLD * bugs_n, BUG_CAP_OLD))
            if prev_parts is not None and parts != prev_parts:
                named = True
            prev_parts = parts
        # ---------------- seri ve nedensiz dusus
        out["sat"][t] = sat; out["named"][t] = named; out["tol"][t] = tol
        if prev_sat is not None and sat <= prev_sat - 1:
            out["drop_weeks"] += 1
            if not named:
                out["nedensiz"] += 1
        prev_sat = sat
        m = sat - tol
        out["min_margin"] = m if out["min_margin"] is None else min(out["min_margin"], m)
        # ---------------- yenileme tutumu (referans guncellendigi tik)
        if renew_open:
            diff = sat - tol + a.persuasion
            pend = {"t": t, "sat": sat, "tol": tol, "diff": diff, "stance": stance(diff)}
        # ---------------- risk makinesi [kod b2b_sales_system.gd:66-69, 211-234, 250-269]
        if risk:
            if sat < tol:
                streak += 1; out["risk_weeks"] += 1
                if phase_r != "risk":
                    if streak >= RISK_TRIGGER and not (last_exit >= 0 and t - last_exit < RISK_REENTRY):
                        phase_r = "risk"; cd = CHURN_CD; out["risk_entered"] += 1
                else:
                    cd -= 1
                    if cd <= 0:
                        out["left"] = t; out["left_why"] = "risk"
                        break
            else:
                streak = 0
                if phase_r == "risk":
                    phase_r = "active"; cd = -1; last_exit = t
        # ---------------- yenileme sonucu [v2 par. 2.6.3 (1. secenek), v3 par. 4]
        if renew_open and pend is not None and pend["t"] == t:
            res = dict(pend); res["budget"] = None; res["mrr_before"] = mrr
            bc = None
            if budget_cut and rng.random() < BUDGET_P.get(a.star, 0.01):
                bc = "shrink" if pend["sat"] >= pend["tol"] + SHRINK_MARGIN else "leave"
            res["budget"] = bc
            if bc == "leave" or (bc is None and pend["stance"] == 4):
                res["result"] = "leave"
            elif bc == "shrink":
                res["result"] = "shrink"; mrr *= 0.5
            else:
                st = pend["stance"]
                if st == 0: mrr *= 1.08; status["zam"] = TERM_ZAM
                elif st == 2: mrr *= 0.90; status["indirim"] = TERM_DISCOUNT
                elif st == 3: mrr *= 0.85; status["indirim"] = TERM_DISCOUNT
                res["result"] = "renew"
            res["mrr_after"] = mrr
            out["renew"].append(res)
            if res["result"] == "leave":
                # bitise kadar oder, sozlesme sonunda ayrilir (v2 par. 2.6.1 takvim)
                out["left"] = s + (((t - s) // CONTRACT) + 1) * CONTRACT
                out["left_why"] = "renew_leave" if bc == "leave" else "renew_stance"
                out["decided"] = t
                break
            if mode == "old":
                # eski modelde durum terimi yok: yalniz fiyat degisir
                status.clear()
    out["mrr_end"] = mrr if out["left"] is None else 0
    return out
