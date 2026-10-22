"""Pazar 2 SIM1 + SIM2: ERP modül pazarının biçim simülasyonu (soyut modüller, uydurma dünya).

Oyun kodunu okumaz. Kodun bugünkü sabitleri constants.json'da kaynağıyla elle aktarıldı.
Yalnız standart kütüphane; tohumlu ve deterministik. Koşu ve dosyalar: README.md.
SIM1 (--mod tam, g1) yalnız constants.json'u okur; SIM2 (--mod sim2) üstüne sim2.json katmanını yükler
(satış zarı, fiyat defteri, kohort, sıralama, bilinen yol kolu). SIM2 alanları SIM1 koşusunda rng çağırmaz.
"""
import argparse
import datetime as dt
import heapq
import json
import math
import os
import random
import statistics
import sys
import time
import zlib
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "out", "tur2"))
START = dt.date(2012, 1, 1)
BOTS = ["durgun", "daginik", "odakli", "oncu", "satici", "verimli"]
FOCUS_BOTS = ("odakli", "verimli", "oncu")
NS = [5, 7, 10]


# ---------------------------------------------------------------- veri

def crc(s):
    return zlib.crc32(s.encode("utf-8"))


def load(name):
    with open(os.path.join(HERE, name), encoding="utf-8") as f:
        return json.load(f)


def _set(D, C, k, v):
    path = k.split(".")
    node = D if len(path) > 1 else C
    for part in path[:-1]:
        node = node[int(part)] if isinstance(node, list) else node[part]
    last = int(path[-1]) if isinstance(node, list) else path[-1]
    if not isinstance(node, list) and last not in node:
        raise SystemExit(f"bilinmeyen ayar: {k}")
    node[last] = v


def load_all(overrides, overlay=None):
    """Veriyi okur. Ezme anahtarı ya bir sabit adıdır ya da noktalı yol (ör. rivals.rakipler.0.tavan).
    overlay (ör. sim2.json) aynı biçimde {ad: değer} taşır ve komut satırı ezmelerinden önce uygulanır."""
    raw = load("constants.json")
    C = {k: v["v"] for k, v in raw.items() if not k.startswith("_")}
    D = {"C": C, "mods": load("modules.json"), "eras": load("eras.json"),
         "profs": load(C["profil_dosyasi"]), "rivals": load("rivals.json")}
    for ov in ([overlay] if isinstance(overlay, str) else overlay or []):
        for k, v in load(ov).items():
            if not k.startswith("_"):
                _set(D, C, k, v)
    for k, v in overrides.items():
        _set(D, C, k, v)
    return D


def week_of(iso):
    return (dt.date.fromisoformat(iso) - START).days // 7


def weeks_to_end(year):
    return (dt.date(year, 12, 31) - START).days // 7 + 1


def pct(xs, p):
    if not xs:
        return float("nan")
    s = sorted(xs)
    return s[max(0, min(len(s) - 1, math.ceil(p / 100 * len(s)) - 1))]


def med(xs):
    return statistics.median(xs) if xs else float("nan")


class Spec:
    """N'ye bağlı hat listesi ve sektör profillerinin o kümeye indirgenmesi; dünya ve oyuncu aynısını okur.
    Profil verisinin tek evi P_profiles.json'dır: sektör hücreleri (Z her zaman, S sık, N nadir, - hiç),
    önemli modül adayları ve 7/5 modül için katlama (Tedarik = Üretim ile Depo'nun yükseği)."""

    RANK = {"-": 0, "N": 1, "S": 2, "Z": 3}

    def __init__(self, N, D):
        C, mods, eras, P = D["C"], D["mods"], D["eras"], D["profs"]
        self.N = N
        self.ids, self.names, self.kind, self.era_info = [], [], [], {}
        for mid, ad in mods["kumeler"][str(N)].items():
            self.ids.append(mid); self.names.append(ad); self.kind.append("mod")
        for pid, ad in mods["platform"].items():
            self.ids.append(pid); self.names.append(ad); self.kind.append("plat")
        for e in eras["donem_hatlari"]:
            self.era_info[len(self.ids)] = e
            self.ids.append(e["id"]); self.names.append(e["ad"]); self.kind.append("era")
        self.n = len(self.ids)
        self.idx = {i: k for k, i in enumerate(self.ids)}
        self.mod = [i for i in range(self.n) if self.kind[i] == "mod"]
        self.plat = [i for i in range(self.n) if self.kind[i] == "plat"]
        self.era = [i for i in range(self.n) if self.kind[i] == "era"]
        fold = P["indirgeme"][str(N)]["katlama"] if str(N) in P["indirgeme"] else {m: m for m in P["moduller"]}

        def reduce(cells):
            out = {}
            for m, c in cells.items():
                t = fold.get(m)
                if t is not None and self.RANK[c["v"]] > self.RANK[out.get(t, "-")]:
                    out[t] = c["v"]
            return out

        def pick(red, v):
            return [self.idx[m] for m, x in red.items() if x == v]

        self.core = [self.idx[fold[m]] for m in mods["temel"]]
        self.fin, self.ik = self.idx["FIN"], self.idx["IK"]
        self.ik_star, self.p_s, self.p_n = C["ik_yildiz"], C["sik_olasilik"], C["nadir_olasilik"]
        self.prof_ids = list(P["profiller"])
        self.prof, self.sector = {}, {}
        for pname, p in P["profiller"].items():
            for sec in p["uyeler"]:
                sh = P["sektor_hucreleri"].get(sec, {})
                red = reduce(sh.get("moduller", p["moduller"]))
                Z, S = pick(red, "Z"), pick(red, "S")
                imps = []
                for m in sh.get("onemli_modul_adaylari", []):
                    t = fold.get(m)
                    if t is not None and self.idx[t] in Z + S and self.idx[t] not in imps:
                        imps.append(self.idx[t])
                if not imps:
                    imps = [next((li for li in Z if li not in self.core), self.fin)]
                self.sector[sec] = {"prof": pname, "Z": Z, "S": S, "N": pick(red, "N"), "imps": imps}
            red = reduce(p["moduller"])
            lider = self.sector[p["lider_sektor"]]
            mandate = {}
            for li in self.era:
                e = self.era_info[li]
                if e["tur"] == "mevzuat":
                    over = e.get("profil_istisna", {}).get(pname)
                    mandate[li] = [week_of(over) if over else week_of(e["zorunlu"][str(s)]) for s in range(1, 6)]
            self.prof[pname] = {"sectors": p["uyeler"], "Z": pick(red, "Z"), "ZS": pick(red, "Z") + pick(red, "S"),
                                "narrow": lider["Z"], "head": [lider["imps"][0], self.fin], "mandate": mandate,
                                "w": C["profil_agirlik"][pname]}

    def modules_for(self, sec, star, k, imp, rng):
        """Hesabın modülleri: önemli modül, Finans, sektör imzası (temel dışı Z), temel Z; sonra S ve N olasılıkla."""
        s = self.sector[sec]
        order = [imp, self.fin] + [z for z in s["Z"] if z not in self.core] + [z for z in s["Z"] if z in self.core]
        order += [x for x in s["S"] if rng.random() < self.p_s] + [x for x in s["N"] if rng.random() < self.p_n]
        out = []
        for x in order:
            if x not in out and (x != self.ik or star >= self.ik_star):
                out.append(x)
        return out[:k]

    def wants(self, sec):
        s = self.sector[sec]
        w = {li: self.p_n for li in s["N"]}
        w.update({li: self.p_s for li in s["S"]})
        w.update({li: 1.0 for li in s["Z"]})
        return w

    def prof_weights(self, y):
        f = min(1.0, max(0.0, (y - 2012) / 18))
        w = [self.prof[p]["w"][0] + (self.prof[p]["w"][1] - self.prof[p]["w"][0]) * f for p in self.prof_ids]
        s = sum(w)
        return [x / s for x in w]


def effort_table(C):
    """Kademe eforu (puan). 'geometrik': taban*g^(k-1) (görev modeli); 'kuvvet' ve 'iki_parca' KURAL adayıdır."""
    b = C["efor_taban"] * C["efor_carpani"]
    if C["efor_bicim"] == "kuvvet":
        return [0.0] + [b * k ** C["efor_us"] for k in range(1, 40)]
    if C["efor_bicim"] == "iki_parca":
        kb, g1 = C["efor_kirilim"], C["efor_g_giris"]
        return [0.0] + [b * g1 ** (min(k, kb) - 1) * C["efor_g"] ** max(0, k - kb) for k in range(1, 40)]
    return [0.0] + [b * C["efor_g"] ** (k - 1) for k in range(1, 40)]


def work(lv, prog, order, pts, room, capw, t, E, changed, when=None, cost=None, capera=None, prem=1.0):
    """Puanı öncelik sırasıyla dağıtır; bir hatta haftada en çok 'room' puan (kart başına kişi sınırı).
    when: kademenin yayın haftası (sıralamada eşitliği ilk yayımlayan bozar); cost(li, k): kademe eforu
    (bilinen yol kolu), yoksa E[k]. SIM3: room çağrılabilirse hattın sıradaki kademesi için puan sınırını verir
    (kadro_kurali 'd'); capw etkin tavan, capera dönem tavanı ise onun üstündeki kademe 'prem' kat pahalıdır (Ar-Ge)."""
    used = {}
    rf = room if callable(room) else None
    for li, tgt in order:
        if pts <= 1e-9:
            break
        c = capw[li][t]
        if tgt > c:
            tgt = c
        r0 = rf(lv[li] + 1) if rf else room
        r = r0 - used.get(li, 0.0)
        r_start = r
        while r > 1e-9 and pts > 1e-9 and lv[li] < tgt:
            nxt = lv[li] + 1
            need = E[nxt] if cost is None else cost(li, nxt)
            if capera is not None and nxt > capera[li][t]:
                need *= prem
            put = need - prog[li]
            if put < 0.0:
                put = 0.0
            if put > r:
                put = r
            if put > pts:
                put = pts
            prog[li] += put
            r -= put
            pts -= put
            if prog[li] >= need - 1e-9:
                lv[li] = nxt
                prog[li] = 0.0
                changed.add(li)
                if when is not None:
                    when[li] = t
        used[li] = used.get(li, 0.0) + (r_start - r) if rf else room - r
    return pts


def room_of(C, E, eff=None):
    """Hatta haftada en çok puan: sabit kişi sınırı ya da (kadro_kurali 'd') kademe eforuna göre kadro tavanı."""
    ppw, ovh = C["kisi_puan_hafta"], C["ek_yuk"]
    if C["kadro_kurali"] != "d":
        r = C["kart_en_cok_kisi"] * ppw * (1 - ovh)
        return r if eff is None else r * eff
    sh, dl = C["kadro_asama_payi"], C["kadro_dilim"]
    return lambda k: max(1, math.ceil(E[k] * sh / dl - 1e-9)) * ppw * (1 - ovh) * (1.0 if eff is None else eff)


def player_target(C, scale, t):
    return scale * min(1.0, t / C["portfoy_rampa_hafta"])


# ---------------------------------------------------------------- rakip dünyası

class Rival:
    __slots__ = ("id", "ad", "tur", "devs", "growth", "tavan", "share", "acc", "acc_prev", "lv", "prog",
                 "offer", "focus", "order", "active", "low_years", "wait", "when", "profs")


# 2012 başında elde olan kademelerin yayın sırası: dev en eski (1988), sonra yerleşik, sonra girişim
FIRST_PUB = {"dev": -3000, "yerlesik": -2000, "girisim": -1000}


class World:
    """Rakiplerin haftalık yarışı. Standart S = yayımlayan rakiplerin seviyesinin üst medyanı (oyuncu hariç),
    L = en iyi ikinci. Oyuncu bu dünyayı yalnız okur; dünyayı oyuncu portföyünün hedef boyu etkiler (havuz).
    coupled=True (bilinen yol kolu): dünya kurulurken koşmaz, oyuncu koşusu her hafta step(t) çağırır; oyuncunun
    yayımladığı kademe rakibin 'en az iki şirket' sayımına girer (player_lv)."""

    def __init__(self, spec, D, seed, scale, coupled=False):
        C, eras, R = D["C"], D["eras"], D["rivals"]
        self.spec, self.C, self.seed, self.scale = spec, C, seed, scale
        rng = random.Random(crc(f"dunya|{spec.N}|{seed}"))
        n = spec.n
        self.W = W = weeks_to_end(max(C["bitis_yillari"]))
        self.YEAR = YEAR = [(START + dt.timedelta(weeks=t)).year for t in range(W)]
        shift = eras["teknoloji_kaymasi_hafta"]
        self.open_w = open_w = [0] * n
        for li in spec.era:
            e = spec.era_info[li]
            w0 = week_of(e["acilis"])
            if e["tur"] == "teknoloji":
                w0 = max(0, w0 + rng.randint(-shift, shift))
            open_w[li] = w0
        capY = {}
        for y in range(2012, max(C["bitis_yillari"]) + 1):
            capY[y] = max(k for yy, k in eras["tavan"] if yy <= y)
        self.capY = capY
        poff, est = eras["platform_tavan_farki"], eras["donem_ilk_tavan"]
        self.capw = capw = []
        for li in range(n):
            row = [0] * W
            k = spec.kind[li]
            for t in range(W):
                y = YEAR[t]
                if k == "mod":
                    row[t] = capY[y]
                elif k == "plat":
                    row[t] = capY[y] + poff
                elif t >= open_w[li]:
                    row[t] = min(capY[y], est + (y - YEAR[open_w[li]]) // 2)
            capw.append(row)
        self.capb = capw
        if C["arge_tavan"]:
            ay = C["arge_baslangic_yili"]
            self.capb = [[c + C["arge_tavan"] if c > 0 and YEAR[t] >= ay else c for t, c in enumerate(row)] for row in capw]
        self.E = E = effort_table(C)

        T = R["turler"]
        self.rivals = rivals = []
        cap0, capp0 = capw[spec.mod[0]][0], capw[spec.plat[0]][0]
        ent = spec.idx["ent"]
        for rd in R["rakipler"]:
            r = Rival()
            r.id, r.ad, r.tur = rd["id"], rd["ad"], rd["tur"]
            j = C["rakip_jitter"]
            r.devs = rd["gelistirici"] * (1 + rng.uniform(-j, j))
            r.growth, r.tavan, r.share = rd["buyume"], rd["tavan"], rd["pay"]
            r.lv, r.prog = [0] * n, [0.0] * n
            r.active, r.low_years, r.order = True, 0, []
            tt = T[r.tur]
            if r.tur == "dev":
                focus = set(spec.mod + spec.plat)
                offer = set(range(n))
                for li in spec.mod:
                    r.lv[li] = cap0 if rng.random() < tt["modul_tavanda_olasilik"] else cap0 - 1
                for li in spec.plat:
                    r.lv[li] = capp0 if rng.random() < tt["platform_tavanda_olasilik"] else capp0 - 1
            elif r.tur == "yerlesik":
                fm = set()
                for p in rd["profiller"]:
                    fm |= set(spec.prof[p]["ZS"])
                focus = fm | set(spec.plat)
                offer = focus | set(spec.core) | set(spec.era)
                for li in spec.mod:
                    if li in fm:
                        r.lv[li] = tt["odak_modul_k"]
                    elif li in offer:
                        r.lv[li] = tt["diger_modul_k"]
                for li in spec.plat:
                    r.lv[li] = tt["platform_k"]
            else:
                focus = set(spec.prof[rd["profiller"][0]]["narrow"])
                offer = focus | {ent} | set(spec.era)
                for li in focus:
                    r.lv[li] = tt["odak_modul_k"]
                r.lv[ent] = tt["platform_k"]["ent"]
            r.focus, r.offer = focus, sorted(offer)
            r.wait = tt["teknoloji_bekleme_hafta"]
            r.profs = list(rd["profiller"])
            r.when = [FIRST_PUB[r.tur] if x >= 1 else 0 for x in r.lv]
            rivals.append(r)
        self.giant = next(r for r in rivals if r.tur == "dev")
        self.dev_backup = T["dev"]["teknoloji_bekleme_yedek_hafta"]
        total = C["havuz_2012"] * C["hizmet_payi"]
        for r in rivals:
            r.acc = r.acc_prev = r.share * total
        self.kasa = C["rakip_kasa"]
        self.tavan0 = {r.id: r.tavan for r in rivals}
        if self.kasa:
            for r in rivals:
                r.tavan = max(r.devs, self._gelir_tavan(r))

        self.S, self.L = [0] * n, [0] * n
        for li in range(n):
            self._recalc(li)
        self.Sh = [[0] * W for _ in range(n)]
        self.Lh = [[0] * W for _ in range(n)]
        self.first_k1 = [None] * n
        self.first_who = [None] * n
        self.snaps, self.events, self.g8 = {}, [], []
        self.ops = 0
        self.rng, self.coupled, self.player_lv = rng, coupled, None
        self.known = C["bilinen_yol"]
        self.ppw, self.ovh = C["kisi_puan_hafta"], C["ek_yuk"]
        self.room = room_of(C, E)
        self.bugmul = C["tik_gun"] * C["hata_gun_taban"] * C["hata_duzeltme_puan"]
        self.div = C["hata_hesap_bolen"]
        self.newk = 1 + C["yeni_kod_hata_puan_basi"] * C["hata_duzeltme_puan"]
        self.reprio = C["rakip_oncelik_hafta"]
        self.arge, self.arge_prem = C["arge_tavan"], C["arge_carpan"]
        if not coupled:
            for t in range(W):
                self.step(t)

    def _gelir_tavan(self, r):
        """rakip_kasa true: ekip tavanı yalnız gelire bağlı; 'yukari': rivals.json tavanı alt sınır kalır, gelir onu yalnız yükseltir."""
        C = self.C
        g = max(1.0, r.acc * C["rakip_hesap_gelir_ay"] * 12 * C["rakip_gelir_orani"] / C["rakip_dev_maliyet_yil"])
        return max(g, self.tavan0[r.id]) if self.kasa == "yukari" else g

    def _recalc(self, li):
        vals = sorted((r.lv[li] for r in self.rivals if r.active and r.lv[li] >= 1), reverse=True)
        if vals:
            self.S[li] = vals[(len(vals) - 1) // 2]
            self.L[li] = vals[1] if len(vals) > 1 else vals[0]
        else:
            self.S[li] = self.L[li] = 0

    def _order(self, r, t):
        spec, S, L, capw = self.spec, self.S, self.L, self.capb
        items = []
        for li in r.offer:
            c = capw[li][t]
            lv = r.lv[li]
            if lv >= c:
                continue
            if spec.kind[li] == "era":
                if spec.era_info[li]["tur"] == "mevzuat":
                    items.append((0, lv, li, max(1, S[li])))
                    items.append((4, lv, li, L[li] + 1))
                else:
                    if r.tur == "dev":
                        fk = self.first_k1[li]
                        start = fk + r.wait if fk is not None else self.open_w[li] + self.dev_backup
                    else:
                        start = self.open_w[li] + r.wait
                    if t < start:
                        continue
                    items.append((2 if r.tur == "girisim" else 4, lv, li, max(1, L[li] + 1)))
            elif li in r.focus:
                if lv < S[li]:
                    items.append((1, lv - S[li], li, S[li]))
                items.append((3, lv, li, L[li] + 1))
            elif lv < S[li] - 1:
                items.append((5, lv, li, S[li] - 1))
            items.append((6, lv, li, c))
        items.sort()
        self.ops += len(items)
        return [(li, tgt) for _, _, li, tgt in items]

    def _cost(self, r):
        """Bilinen yol: kademeyi kendisi hariç en az iki şirket (oyuncu dahil) yayımlamışsa efor x bilinen_yol."""
        E, m, rivals, pl = self.E, self.known, self.rivals, self.player_lv

        def cost(li, k):
            c = 1 if pl is not None and pl[li] >= k else 0
            for o in rivals:
                if o is not r and o.active and o.lv[li] >= k:
                    c += 1
            return E[k] * m if c >= 2 else E[k]
        return cost

    def step(self, t):
        spec, n, W, YEAR = self.spec, self.spec.n, self.W, self.YEAR
        if t % self.reprio == 0:
            for r in self.rivals:
                if r.active:
                    r.order = self._order(r, t)
        changed = set()
        for r in self.rivals:
            if not r.active:
                continue
            pts = (r.devs * self.ppw * (1 - self.ovh) - self.bugmul * (1 + r.acc / self.div)) / self.newk
            if pts > 0:
                work(r.lv, r.prog, r.order, pts, self.room, self.capb, t, self.E, changed, r.when,
                     self._cost(r) if self.known < 1.0 else None, self.capw if self.arge else None, self.arge_prem)
            self.ops += 1
        for li in changed:
            self._recalc(li)
            if spec.kind[li] == "era" and self.first_k1[li] is None and self.S[li] >= 1:
                self.first_k1[li] = t
                self.first_who[li] = next(r.id for r in self.rivals if r.active and r.lv[li] >= 1)
        for li in range(n):
            self.Sh[li][t] = self.S[li]
            self.Lh[li][t] = self.L[li]
        if t == W - 1 or YEAR[t + 1] != YEAR[t]:
            self._year_end(YEAR[t], t, self.rng)

    def pool(self, y):
        return self.C["havuz_2012"] * (1 + self.C["havuz_buyume"]) ** (y - 2012)

    def _year_end(self, y, t, rng):
        C, spec = self.C, self.spec
        act = [r for r in self.rivals if r.active]
        g = self.giant
        open_lines = [li for li in range(spec.n) if self.capw[li][t] > 0]
        self.snaps[y] = {
            "S": self.S[:], "L": self.L[:], "cap": [self.capw[li][t] for li in range(spec.n)],
            "capb": [self.capb[li][t] for li in range(spec.n)],
            "dev": g.lv[:], "open": open_lines,
            "devs": {r.id: r.devs for r in act}, "acc": {r.id: r.acc for r in act},
            "havuz": self.pool(y), "oyuncu_hedef": player_target(C, self.scale, t),
            "lv_all": {r.id: r.lv[:] for r in act}, "when_all": {r.id: r.when[:] for r in act},
            "share": {r.id: r.share for r in act}, "tur": {r.id: r.tur for r in act},
            "profs": {r.id: r.profs[:] for r in act},
        }
        snap = self.snaps[y]
        if sum(snap["acc"].values()) + snap["oyuncu_hedef"] > snap["havuz"] + 1e-6:
            self.g8.append(f"{y}: Σ hesap > havuz")
        for r in act:
            if not (1 - 1e-9 <= r.devs <= r.tavan + 1e-9):
                self.g8.append(f"{y}: {r.id} ekip {r.devs:.2f} sınır dışı")
            if r.acc < 0 or min(r.lv) < 0 or min(r.prog) < -1e-9:
                self.g8.append(f"{y}: {r.id} negatif değer")
        if y > 2012 and snap["havuz"] <= self.snaps[y - 1]["havuz"]:
            self.g8.append(f"{y}: havuz büyümedi")
        if t == self.W - 1:
            return
        # hesap payı: çekim = ortalama (seviye - standart) + genişlik
        ws = []
        for r in act:
            om = [li for li in spec.mod if r.lv[li] >= 1]
            a = (sum(r.lv[li] - self.S[li] for li in om) / len(om) if om else -3.0) \
                + C["pay_genislik_agirlik"] * len(om) / len(spec.mod)
            ws.append(math.exp(C["pay_beta"] * a))
        sw, c = sum(ws), C["pay_devri"]
        for r, w in zip(act, ws):
            r.share = (1 - c) * r.share + c * w / sw
        if y == C["dev_ihale_yili"]:
            # devin eski çekirdeğinin desteği biter: hesaplarının bir payı çekime göre yeniden ihaleye çıkar (S §9.1)
            moved = g.share * C["dev_ihale_payi"]
            g.share -= moved
            for r, w in zip(act, ws):
                r.share += moved * w / sw
        for r in act:
            if r.tur == "girisim":
                r.low_years = r.low_years + 1 if r.acc < C["girisim_cikis_hesap"] else 0
                if r.low_years >= C["girisim_cikis_yil"]:
                    r.active = False
                    g.share += r.share
                    r.share = 0.0
                    self.events.append((y, f"{r.ad} satın alındı"))
                    for li in range(spec.n):
                        self._recalc(li)
        y1 = y + 1
        opening = y1 in self.capY and self.capY[y1] != self.capY.get(y) \
            or any(self.YEAR[min(self.open_w[li], self.W - 1)] == y1 for li in spec.era)
        if opening:
            for r in self.rivals:
                if r.active or r.tur != "girisim" or rng.random() >= C["girisim_giris_olasilik"]:
                    continue
                pid = rng.choice(spec.prof_ids)
                r.active, r.low_years = True, 0
                r.ad = r.ad.split(" ")[0] + " (yeni)"
                r.devs = 1.5
                r.lv, r.prog = [0] * spec.n, [0.0] * spec.n
                r.focus = set(spec.prof[pid]["narrow"])
                r.offer = sorted(r.focus | {spec.idx["ent"]} | set(spec.era))
                r.profs, r.when = [pid], [0] * spec.n
                for li in spec.prof[pid]["head"][:2]:
                    r.lv[li] = 1
                    r.when[li] = t + 1
                r.share = C["girisim_giris_pay"]
                g.share -= r.share
                r.acc = r.acc_prev = 0.0
                self.events.append((y1, f"{r.ad} kuruldu ({pid})"))
                for li in range(spec.n):
                    self._recalc(li)
        act = [r for r in self.rivals if r.active]
        tot = sum(r.share for r in act)
        total = max(0.0, self.pool(y1) * C["hizmet_payi"] - player_target(C, self.scale, t + 1))
        for r in act:
            r.share /= tot
            r.acc_prev, r.acc = r.acc, r.share * total
            ratio = (r.acc / r.acc_prev) ** 0.5 if r.acc_prev > 0 else 1.0
            ratio = min(1.25, max(0.8, ratio))
            if self.kasa:
                r.tavan = self._gelir_tavan(r)
            r.devs = min(r.tavan, max(1.0, r.devs * (1 + r.growth) * ratio))

    def g1_rows(self):
        """Yıl sonu başına G1 ölçüleri."""
        spec, rows = self.spec, {}
        for y, s in sorted(self.snaps.items()):
            capm = s["cap"][spec.mod[0]]
            ms = med([s["S"][li] for li in spec.mod])
            ps = med([s["S"][li] for li in spec.plat])
            opn = s["open"]
            atcap = sum(1 for li in opn if s["dev"][li] >= s["capb"][li])
            rows[y] = {"tavan": capm, "S_med": ms, "L_med": med([s["L"][li] for li in spec.mod]),
                       "fark": capm - ms, "fark_plat": s["cap"][spec.plat[0]] - ps,
                       "dev_tavanda": atcap, "dev_hat": len(opn), "dev_tavanda_pay": atcap / len(opn),
                       "dev_mod_tavanda": sum(1 for li in spec.mod if s["dev"][li] >= s["capb"][li]),
                       "fark_etkin": s["capb"][spec.mod[0]] - ms,
                       "S_mod": [s["S"][li] for li in spec.mod],
                       "rakip_gelistirici": sum(s["devs"].values()), "dev_gelistirici": s["devs"][self.giant.id],
                       "dev_hesap": s["acc"][self.giant.id], "havuz": s["havuz"],
                       "aktif_rakip": len(s["devs"])}
        return rows


# ---------------------------------------------------------------- oyuncu botu ve hesaplar

class Acct:
    __slots__ = ("prof", "sec", "star", "ostar", "seats", "emp", "traj", "mods", "era", "imp", "sat",
                 "active", "leave", "cond", "pend", "arr", "pv", "coh", "wli", "erat", "cp", "cws")


PRICE_KINDS = ("yeni", "gen_koltuk", "gen_modul", "daralma", "kayip")
SEGMENTS = ((0, 1), (2,), (3, 4))  # küçük 1-2★, orta 3★, büyük 4-5★
SEL_YEARS = (2013, 2015, 2020, 2025, 2030, 2035)


def run_player(world, D, bot, team_arm, scale):
    """Oyuncu botu: ekip kolu x hesap ölçeği. Portföy ölçeğe rampayla çıkar ve orada tutulur; ölçülen
    hesap başına ses (istek, şart, adlı ayrılma), açık kart, şartlı yenileme ve koltuk hareketidir.
    SIM2 (satis_modeli 'zar'): imza süzgeç değil satış zarıdır (aday akışı, satıcı yıldızı, süre, bayatlama);
    ayrıca fiyat defteri (4 fiyat kolu), yıldız başına tutma, 2015 kohortu (G4), demo, sıralama ve gölge pay."""
    spec, C, W, YEAR = world.spec, world.C, world.W, world.YEAR
    Sh, Lh, capw, E = world.Sh, world.Lh, world.capb, world.E
    capera, prem = (world.capw, C["arge_carpan"]) if C["arge_tavan"] else (None, 1.0)
    n, seed = spec.n, world.seed
    rng = random.Random(crc(f"oyuncu|{spec.N}|{seed}|{scale}|{bot}|{team_arm}"))
    s2 = C["satis_modeli"] == "zar"
    lv, prog, when_p = [0] * n, [0.0] * n, [0] * n
    if world.coupled:
        world.player_lv = lv
    pcost = None
    if C["bilinen_yol"] < 1.0:
        known, rivals_all = C["bilinen_yol"], world.rivals

        def pcost(li, k):
            c = 0
            for o in rivals_all:
                if o.active and o.lv[li] >= k:
                    c += 1
            return E[k] * known if c >= 2 else E[k]
    eff = C["verimli_carpan"] if bot == "verimli" else 1.0
    fp = spec.prof_ids[seed % len(spec.prof_ids)] if bot in FOCUS_BOTS else None
    focus = (set(spec.prof[fp]["ZS"]) | set(spec.plat)) if fp else set()
    ppw, ovh = C["kisi_puan_hafta"], C["ek_yuk"]
    room = room_of(C, E, eff)
    bugmul = C["tik_gun"] * C["hata_gun_taban"] * C["hata_duzeltme_puan"]
    div = C["hata_hesap_bolen"]
    newk = 1 + C["yeni_kod_hata_puan_basi"] * C["hata_duzeltme_puan"]
    ga, gb = C["gelistirici_orani"]
    grow = C["buyuyen_takim"]
    y0 = C["olcum_baslangic_yili"]
    stop = C["durgun_durma_yili"]
    chk, cond_w = C["yenileme_kontrol_hafta"], C["sart_sure_hafta"]
    memnun, dusuk = C["memnun_esik"], C["dusuk_esik"]
    p_req = C["istek_olasilik"]
    p_low_cond = C["dusuk_yildiz_sart"]
    p_silent = C["dusuk_yildiz_sessiz_gider"]
    adopt = D["eras"]["benimseme_yil"]
    bands = C["koltuk_bantlari"]
    mix = list(C["olcek_yildiz_karisimi"][str(scale)])
    if s2:
        mix = list(C["aday_yildiz_karisimi"])
    elif bot == "satici":
        mix = [m * (C["satici_yildiz_carpani"] if i >= 2 else 1.0) for i, m in enumerate(mix)]
    pool_star = C["havuz_yildiz"]
    sat_mu, sat_sd = C["memnuniyet_ilk"]
    traj_p, traj_r = C["gidis_olasilik"], C["gidis_yillik"]
    seat_abs, seat_rel = C["koltuk_esik"]
    max_gap = C["imza_en_cok_acik"]
    ud, eskime = C["urun_disi_ayrilma"], C["eskime_memnuniyet"]
    w0 = next(t for t in range(W) if YEAR[t] >= y0)
    w_stop = next(t for t in range(W) if YEAR[t] >= stop)
    win = C["g4_pencere_hafta"]

    def team_at(y):
        if team_arm == "buyuyen":
            return max(v for yy, v in grow if yy <= y)
        return team_arm

    geri = C["istek_geri"]
    en_cok = C["istek_en_cok"]

    def req(li, t, o):
        s = Sh[li][t]
        if o == 1:
            r = s - geri[0]
        elif o == 2:
            r = s - geri[1]
        elif o == 3:
            r = s
        elif o == 4:
            r = min(s + 1, Lh[li][t])
        else:
            r = Lh[li][t]
        r = min(r, en_cok[o - 1])
        return r if r > 1 else 1

    def star_of(seats):
        for i, (lo, hi) in enumerate(bands):
            if seats < hi:
                return i + 1
        return 5

    def update_era(a, t):
        for li in spec.era:
            if li in a.era:
                continue
            mand = spec.prof[a.prof]["mandate"].get(li)
            if mand is not None:
                if t >= mand[a.star - 1]:
                    a.era.append(li)
                    a.erat[li] = t
            elif t >= world.open_w[li] + adopt[a.star - 1] * 52 and Sh[li][t] >= 1:
                a.era.append(li)
                a.erat[li] = t

    def lines(a):
        return a.mods + spec.plat + a.era

    grace = C["donem_ilk_yil_sart"]

    def worst_gap(a, t):
        mg, mli, mr = 0, None, 0
        for li in lines(a):
            r = req(li, t, a.ostar)
            if grace and li in a.erat and t - a.erat[li] < 52 and r > lv[li] + 1:
                r = lv[li] + 1  # yeni benimsenen dönem hattı ilk yıl en çok bir adım (şart) olarak konuşur
            g = r - lv[li]
            if g > mg:
                mg, mli, mr = g, li, r
        return mg, mli, mr

    # durum
    accts, heap = [], []
    seq = [0]
    pend = [[] for _ in range(n)]
    conds = [[] for _ in range(n)]
    cell = {}
    active = [0]
    wk = {"req": 0, "cond": 0, "named": 0}
    mail, wreq, wcond, actw = [0] * W, [0] * W, [0] * W, [0] * W
    cards = []
    years = range(2012, YEAR[-1] + 1)
    Y = {k: {y: 0 for y in years} for k in ("req", "cond", "condren", "ren", "named", "silent", "saved",
                                              "seat_up", "seat_down", "star_ch", "one_star_ren", "one_star_up",
                                              "over1000", "rej_fit", "rej_cell", "signed", "fulfil", "expired")}
    beats, beats_mod, g8 = {}, {}, []
    first_k1 = {}
    # SIM2 durumu (SIM1 koşusunda yalnız boş kalır)
    nstar = [0] * 5
    ayw = {y: [0] * 5 for y in years}
    lostY = {y: [0] * 5 for y in years}
    whyY = {y: {} for y in years}
    dealY = {y: {} for y in years}
    leadY = {y: [0] * 5 for y in years}  # ulaşılan aday, çalışılan, bayat çalışılan, bekleyip soğuyan, pas
    unreachY = {y: [0] * 5 for y in years}
    lossY = {y: {} for y in years}
    imY = {y: 0.0 for y in years}
    NP = 5 if C["fiyat_formul"] else 4
    ledY = {y: {k: [0.0] * NP for k in PRICE_KINDS} for y in years}
    mrrY, starY, fiveY, rk = {}, {}, {}, {}
    tot = [0.0] * NP
    coh = {"n0": [0] * 5, "lost": [0] * 5, "m0": 0.0, "m1": None, "why": {}, "whym": {}, "tot0": None,
           "tot1": None, "im": 0.0, "signed": 0, "hat": {}}
    first45 = [None, None]
    g9Y = {y: [[0, 0, 0, 0], [0, 0, 0, 0]] for y in years}  # 1★ ve 2★: gelen aday, p >= eşik, p >= 0,5, imzalanan
    g9p = C["g9_kazanilabilir_p"]
    rg9 = random.Random(crc(f"g9|{spec.N}|{seed}|{scale}|{bot}|{team_arm}"))
    firstk, snap_t, cum_pts = [None] * 8, {}, [0.0]
    pmax = [0.0]
    last_rel = [-10 ** 6]
    shadow, prevU = {}, {}
    queue, deals, slots = [], [], []

    def push(t, kind, a):
        if t < W:
            seq[0] += 1
            heapq.heappush(heap, (t, seq[0], kind, a))

    def remove(a, t, why):
        wl = a.cond[0] if a.cond is not None else a.wli
        hat = why if wl is None or why == "urun_disi" else (
            f"{why}:{spec.ids[wl] if spec.kind[wl] == 'era' else spec.kind[wl]}")
        a.active = False
        active[0] -= 1
        cell[(a.prof, a.star)] -= 1
        for it in a.pend:
            pend[it[4]].remove(it)
        a.pend = []
        if a.cond is not None:
            conds[a.cond[0]].remove(a)
            a.cond = None
        y = YEAR[t]
        if why == "silent":
            Y["silent"][y] += 1
        elif why in ("named", "sart"):
            Y["named"][y] += 1
            if a.star >= 3:
                wk["named"] += 1
        if s2:
            nstar[a.star - 1] -= 1
            lostY[y][a.star - 1] += 1
            whyY[y][hat] = whyY[y].get(hat, 0) + 1
            if a.coh and t < w_stop + win:
                coh["lost"][a.star - 1] += 1
                coh["why"][why] = coh["why"].get(why, 0) + 1
                coh["whym"][why] = coh["whym"].get(why, 0.0) + a.pv[0]
                coh["hat"][hat] = coh["hat"].get(hat, 0) + 1
            book(a, "kayip", t)

    def issue_request(a, li, target, t, newmod):
        if any(it[4] == li for it in a.pend):
            return
        it = [target, a, t, newmod, li]
        a.pend.append(it)
        pend[li].append(it)
        wk["req"] += 1
        Y["req"][YEAR[t]] += 1

    def issue_condition(a, li, target, t):
        if a.cond is not None:
            return
        a.cond = (li, target)
        conds[li].append(a)
        wk["cond"] += 1
        Y["cond"][YEAR[t]] += 1

    def resolve(changed, t):
        for li in changed:
            l = lv[li]
            if pend[li]:
                keep = []
                for it in pend[li]:
                    if it[0] <= l:
                        a = it[1]
                        a.pend.remove(it)
                        a.sat = min(100.0, a.sat + C["istek_karsilama_odul"])
                        if it[3] and li not in a.mods:
                            a.mods.append(li)
                            if s2:
                                book(a, "gen_modul", t)
                        Y["fulfil"][YEAR[t]] += 1
                    else:
                        keep.append(it)
                pend[li] = keep
            if conds[li]:
                keep = []
                for a in conds[li]:
                    if a.cond[1] <= l:
                        a.cond = None
                    else:
                        keep.append(a)
                conds[li] = keep
            if spec.kind[li] == "era" and li not in first_k1 and lv[li] >= 1:
                first_k1[li] = t

    def sample(t, rg=None):
        rg = rg or rng
        y = YEAR[t]
        pid = fp or rg.choices(spec.prof_ids, spec.prof_weights(y))[0]
        star = rg.choices(range(1, 6), mix)[0]
        a = Acct()
        a.prof, a.star, a.ostar = pid, star, star
        lo, hi = bands[star - 1]
        a.seats = max(lo, min(hi - 1, int(round(math.exp(rg.uniform(math.log(lo), math.log(hi)))))))
        a.emp = a.seats / C["koltuk_calisan_orani"]
        a.traj = rg.choices((0, 1, 2), traj_p[star - 1])[0]
        a.sec = rg.choice(spec.prof[pid]["sectors"])
        a.imp = rg.choice(spec.sector[a.sec]["imps"])
        a.mods = spec.modules_for(a.sec, star, rg.randint(*C["yildiz_modul_sayisi"][star - 1]), a.imp, rg)
        a.era, a.erat, a.pend, a.cond, a.leave, a.active = [], {}, [], None, None, False
        a.sat = min(100.0, max(0.0, rg.gauss(sat_mu, sat_sd)))
        a.arr, a.pv, a.coh, a.wli = t, (0.0,) * NP, False, None
        a.cp = a.cws = 0.0
        update_era(a, t)
        return a

    def fits(a, t):
        for li in lines(a):
            g = req(li, t, a.ostar) - lv[li]
            if g > max_gap or (li == a.imp and g > 0):
                return False
        return True

    def cell_cap(pid, star, y):
        w = spec.prof_weights(y)[spec.prof_ids.index(pid)]
        return world.pool(y) * w * pool_star[star - 1]

    oncu_erken = C["oncu_politika"] == "erken"

    def order_for(t):
        items = []
        for li in range(n):
            if conds[li]:
                items.append((0, -len(conds[li]), li, max(a.cond[1] for a in conds[li])))
            if pend[li]:
                items.append((1, -len(pend[li]), li, max(it[0] for it in pend[li])))
        if bot == "durgun" and YEAR[t] >= stop:
            return []
        for li in range(n):
            c = capw[li][t]
            l = lv[li]
            if l >= c:
                continue
            s, L = Sh[li][t], Lh[li][t]
            if bot in ("daginik", "satici", "durgun"):
                if l < s:
                    items.append((2, l - s, li, s))
                items.append((3, l, li, L + 1))
                items.append((4, l, li, c))
            elif spec.kind[li] == "era":
                if bot == "oncu" and l == 0 and oncu_erken:
                    items.append((0, -10 ** 6, li, 1))
                items.append((3, l, li, max(1, L + 1)) if bot == "oncu" else (4, l - s, li, max(1, s)))
                items.append((6, l, li, c))
            elif li in focus:
                if l < s:
                    items.append((2, l - s, li, s))
                items.append((3 if bot != "oncu" else 4, l, li, L + 1))
                items.append((6, l, li, c))
            elif l < s - 1:
                items.append((5, l, li, s - 1))
        items.sort()
        return [(li, tgt) for _, _, li, tgt in items]

    # ---- SIM2: fiyat defteri (A koltuk, A + hacim, B modül eki, B + hacim)
    sp, me, tiers, core = C["koltuk_fiyat"], C["modul_eki"], C["hacim_indirimi"], set(spec.core)

    def vcost(s):
        v, lo = 0.0, 0
        for hi, dsc in tiers:
            if s > lo:
                v += (min(s, hi) - lo) * sp * (1 - dsc)
            lo = hi
        return v

    # SIM3 madde 6: beşinci kol, önerilen fiyat (SENTEZ §5.6): standart = P0 (1 + Σw) K̄; duruş çarpanı imzada damgalanır,
    # genişlemede koltuk fiyatı yalnız yeni modülün ağırlığı kadar artar, yenilemede değişmez
    fx = C["fiyat_formul"]
    if fx:
        di = ("ucuz", "standart", "pahali").index(C["fiyat_durus"])
        kq, wmod = C["fiyat_kalite_katsayi"], C["modul_agirlik"]
        dmul = C["fiyat_durus_carpan"][di]
        fx_ornek = []

        def wsum(a):
            return sum(wmod[spec.ids[li]] for li in a.mods)

        def stamp(a, t):
            num = den = 0.0
            for li in a.mods:
                w = wmod[spec.ids[li]]
                r = lv[li] / max(1, Sh[li][t])
                num += w * min(kq[2], max(kq[1], 1 + kq[0] * (r - 1)))
                den += w
            a.cws = wsum(a)
            a.cp = C["fiyat_p0"] * (1 + a.cws) * (num / den if den else 1.0) * dmul
            if len(fx_ornek) < 6:
                fx_ornek.append([[spec.ids[li] for li in a.mods], [lv[li] / max(1, Sh[li][t]) for li in a.mods], a.cp])

    def price(a, t, kind):
        base, vb = a.seats * sp, vcost(a.seats)
        k = 1 + me * sum(1 for li in a.mods if li not in core)
        if not fx:
            return (base, vb, base * k, vb * k)
        if kind == "yeni":
            stamp(a, t)
        elif kind == "gen_modul":
            ws = wsum(a)
            a.cp *= (1 + ws) / (1 + a.cws)
            a.cws = ws
        return (base, vb, base * k, vb * k, a.seats * a.cp)

    def book(a, kind, t):
        new = price(a, t, kind) if a.active else (0.0,) * NP
        old, a.pv = a.pv, new
        L = ledY[YEAR[t]]
        for i in range(NP):
            dl = new[i] - old[i]
            tot[i] += dl
            if kind == "kayip":
                L["kayip"][i] -= dl
            elif kind == "yeni":
                L["yeni"][i] += dl
            elif dl > 0:
                L[kind][i] += dl
            else:
                L["daralma"][i] -= dl

    # ---- SIM2: satış zarı (SENTEZ §5.2-5.3; Erdem 7: satıcı en çok bir yıldız üste gider)
    kadro = C["satici_kadro_satisci"] if bot == "satici" else C["satici_kadro"]
    taban = C["satis_taban"]
    u_b, u_bi, u_c, u_ci = C["satis_uyum"]
    s_up, s_cap, s_dn = C["satis_satici"]
    p_lo, p_hi = C["satis_kirpma"]
    p_fiyat, p_stale = C["satis_fiyat"], C["satis_bayat_olasilik"]
    if C["fiyat_formul"]:
        p_fiyat = C["fiyat_durus_kapanis"][("ucuz", "standart", "pahali").index(C["fiyat_durus"])]
    dbase, d_up, d_dn = C["satis_sure_hafta"], C["satis_sure_ust"], C["satis_sure_alt"]
    slot_max, lead_rate, bot_min = C["satici_eszamanli"], C["aday_satici_hafta"], C["bot_aday_esik"]
    i_lo, i_hi = C["ilgi_carpan"]
    i_half, i_code = C["ilgi_yari_omur_hafta"], C["ilgi_kurali"] == "kod"
    hucre = C["portfoy_hucre_tavani"]

    def chance(a, ss, t):
        """P = taban(yıldız) x uyum x satıcı x fiyat, [p_lo, p_hi] kırpma. Uyum adayın söylediği modüllere ve
        ona şart olan dönem hatlarına bakar (S §5.2 'her istenen modül'); platform hatları yenilemede okunur."""
        f, impbad, gap = 1.0, False, False
        for li in a.mods + a.era:
            g = req(li, t, a.ostar) - lv[li]
            if g <= 0:
                continue
            gap = True
            imp = li == a.imp
            if lv[li] == 0 or g >= 2:
                f *= u_ci if imp else u_c
                impbad = impbad or imp
            else:
                f *= u_bi if imp else u_b
        d = ss - a.star
        m = min(s_cap, 1 + s_up * d) if d >= 0 else s_dn
        return min(p_hi, max(p_lo, taban[a.star - 1] * f * m * p_fiyat)), f, impbad, gap

    def deal_weeks(a, ss):
        b, d = dbase[a.star - 1], ss - a.star
        return max(1.0, b - d_up * d) if d > 0 else b * (1 + d_dn) if d < 0 else b

    def imult(t):
        return i_lo + (i_hi - i_lo) * 0.5 ** ((t - last_rel[0]) / i_half)

    def sign(a, t, key):
        a.active = True
        accts.append(a)
        active[0] += 1
        cell[key] = cell.get(key, 0) + 1
        Y["signed"][YEAR[t]] += 1
        if a.star <= 2:
            g9Y[YEAR[t]][a.star - 1][3] += 1
        push(t + 52 - chk, "k", a)
        push(t + 52, "y", a)
        push(t + rng.randint(1, 52), "i", a)
        nstar[a.star - 1] += 1
        book(a, "yeni", t)
        if a.star >= 4 and first45[a.star - 4] is None:
            first45[a.star - 4] = t
        if w_stop <= t < w_stop + win:
            coh["signed"] += 1

    def sales_step(t):
        y = YEAR[t]
        sellers = kadro[str(team_at(y))]
        while len(slots) < len(sellers):
            slots.append(0)
        top = max(sellers)
        # G9 gölge aday akışı: portföy doluluğundan bağımsız, ayrı rastgele akış (ana akışı tüketmez)
        lam9 = len(sellers) * lead_rate * imult(t)
        for _ in range(int(lam9) + (rg9.random() < lam9 - int(lam9))):
            a9 = sample(t, rg9)
            if a9.star <= 2:
                pb = max((chance(a9, ss, t)[0] for ss in sellers if ss >= a9.star - 1), default=0.0)
                gy = g9Y[y][a9.star - 1]
                gy[0] += 1
                gy[1] += pb >= g9p
                gy[2] += pb >= 0.5
        while deals and deals[0][0] <= t:
            _, _, a, si, stale = heapq.heappop(deals)
            slots[si] -= 1
            update_era(a, t)
            p, f, impbad, gap = chance(a, sellers[si], t)
            if stale:
                p = p_stale
            d = sellers[si] - a.star
            k = f"{a.star}|{max(-1, min(2, d))}|{int(f >= 1.0)}"
            st = dealY[y].get(k)
            if st is None:
                st = dealY[y][k] = [0, 0, 0.0]
            st[0] += 1
            st[2] += p
            if p > pmax[0]:
                pmax[0] = p
            if rng.random() < p:
                st[1] += 1
                key = (a.prof, a.star)
                if cell.get(key, 0) + 1 > hucre * cell_cap(a.prof, a.star, y):
                    Y["rej_cell"][y] += 1
                else:
                    sign(a, t, key)
            else:
                why = ("onemli_modul" if impbad else "modul_eksik" if gap else "satici" if d < 0
                       else "sogudu" if stale else "rakip")
                lossY[y][why] = lossY[y].get(why, 0) + 1
        room_ = int(player_target(C, scale, t) * C["satis_hedef_carpan"]) - active[0] - len(deals) - len(queue)
        if room_ > 0:
            lam = len(sellers) * lead_rate * imult(t)
            k = int(lam)
            if rng.random() < lam - k:
                k += 1
            for _ in range(min(k, room_)):
                a = sample(t)
                if cell.get((a.prof, a.star), 0) + 1 > hucre * cell_cap(a.prof, a.star, y):
                    Y["rej_cell"][y] += 1
                    continue
                if a.star > top + 1:
                    unreachY[y][a.star - 1] += 1
                    continue
                queue.append(a)
                leadY[y][0] += 1
        if not queue:
            return
        keep = []
        for a in queue:
            if t - a.arr >= dbase[a.star - 1]:
                leadY[y][3] += 1
            else:
                keep.append(a)
        if all(slots[i] >= slot_max for i in range(len(sellers))):
            queue[:] = keep
            return
        keep.sort(key=lambda a: -chance(a, top, t)[0] * a.seats)
        rest = []
        for a in keep:
            best = None
            for i in reversed(range(len(sellers))):
                ss = sellers[i]
                if slots[i] >= slot_max or ss < a.star - 1:
                    continue
                p = chance(a, ss, t)[0]
                if best is None or p > best[0]:
                    best = (p, i)
            if best is None:
                rest.append(a)
                continue
            p, i = best
            if p < bot_min:
                leadY[y][4] += 1
                continue
            dw = deal_weeks(a, sellers[i])
            stale = t - a.arr > dw
            slots[i] += 1
            seq[0] += 1
            heapq.heappush(deals, (t + math.ceil(dw), seq[0], a, i, stale))
            leadY[y][1] += 1
            if stale:
                leadY[y][2] += 1
        queue[:] = rest

    # ---- SIM2: yıl sonu (MRR anlık görüntüsü, sıralama listeleri, gölge pay)
    keep_years = {2013, *C["bitis_yillari"]}
    msz = [(hi - lo) / math.log(hi / lo) for lo, hi in bands]
    rmix, rodak, yuk_esik = C["rakip_yildiz_karisimi"], C["rakip_profil_odak"], C["yukselen_esik_kullanici"]
    beta, gw, cdev = C["pay_beta"], C["pay_genislik_agirlik"], C["pay_devri"]

    def attract(levels, S):
        om = [li for li in spec.mod if levels[li] >= 1]
        a_ = (sum(levels[li] - S[li] for li in om) / len(om) if om else -3.0) + gw * len(om) / len(spec.mod)
        return math.exp(beta * a_)

    def year_end_s2(y, t):
        mrrY[y] = tot[:]
        bys = [[0.0] * 5 for _ in range(NP)]
        fives, pstar, pprof = [], [0] * 5, {}
        for a in accts:
            if a.active:
                for i in range(NP):
                    bys[i][a.star - 1] += a.pv[i]
                if a.star == 5:
                    fives.append(a.pv)
                pstar[a.star - 1] += a.seats
                pprof[a.prof] = pprof.get(a.prof, 0) + a.seats
        starY[y] = bys
        if y in keep_years:
            fiveY[y] = fives
        sn = world.snaps[y]
        ids, gid = list(sn["lv_all"]), world.giant.id
        LV, WH = sn["lv_all"], sn["when_all"]
        mt3 = ml = mt3g = mlg = 0
        for li in spec.mod:
            if lv[li] < 1:
                continue
            mine = (-lv[li], when_p[li])
            ahead = sum(1 for r in ids if LV[r][li] >= 1 and (-LV[r][li], WH[r][li]) < mine)
            mt3 += ahead < 3
            ml += ahead == 0
            if sum(1 for r in ids if LV[r][li] >= 1) >= C["kalabalik_liste"]:
                mt3g += ahead < 3
                mlg += ahead == 0
        pw = spec.prof_weights(y)
        users, seg, prof = {}, {}, {}
        for r in ids:
            acc, tur = sn["acc"][r], sn["tur"][r]
            byst = [acc * rmix[tur][s] * msz[s] for s in range(5)]
            users[r] = sum(byst)
            seg[r] = [sum(byst[s] for s in sg) for sg in SEGMENTS]
            F = set(sn["profs"][r]) if tur != "dev" else set()
            fw = sum(pw[i] for i, p in enumerate(spec.prof_ids) if p in F)
            o = rodak.get(tur, 0.0) if F else 0.0
            prof[r] = {p: users[r] * (o * pw[i] / fw if p in F else (1 - o) * pw[i] / (1 - fw))
                       for i, p in enumerate(spec.prof_ids)}
        pu = sum(pstar)
        pseg = [sum(pstar[s] for s in sg) for sg in SEGMENTS]
        ur = 1 + sum(1 for r in ids if users[r] > pu)
        st3 = sum(1 for k in range(3) if pseg[k] > 0 and sum(1 for r in ids if seg[r][k] > pseg[k]) < 3)
        pt3 = sum(1 for p, u in pprof.items() if u > 0 and sum(1 for r in ids if prof[r][p] > u) < 3)
        cur = dict(users)
        cur["P"] = pu
        yr = None
        if prevU.get("P", 0) >= yuk_esik:
            gp = pu / prevU["P"] - 1
            yr = 1 + sum(1 for r in ids if prevU.get(r, 0) >= yuk_esik and cur[r] / prevU[r] - 1 > gp)
        prevU.clear()
        prevU.update(cur)
        if not shadow:
            shadow.update(sn["share"])
            shadow["P"] = 0.0
        for r in [r for r in shadow if r != "P" and r not in LV]:
            shadow[gid] += shadow.pop(r)
        for r in ids:
            shadow.setdefault(r, 0.0)
        if t != W - 1:
            ws = {r: attract(LV[r], sn["S"]) for r in ids}
            ws["P"] = attract(lv, sn["S"])
            sw = sum(ws.values())
            for r in shadow:
                shadow[r] = (1 - cdev) * shadow[r] + cdev * ws[r] / sw
            tt = sum(shadow.values())
            for r in shadow:
                shadow[r] /= tt
            if y == C["dev_ihale_yili"]:
                moved = shadow[gid] * C["dev_ihale_payi"]
                shadow[gid] -= moved
                for r in shadow:
                    shadow[r] += moved * ws[r] / sw
        # gölge kullanıcı sırası: herkesin hesabı aynı çekim kuralıyla (gölge pay x hizmet edilen havuz)
        served = world.pool(y) * C["hizmet_payi"]
        pms = pu / max(1, sum(1 for a in accts if a.active))
        gu_p = shadow["P"] * served * pms
        urg = 1 + sum(1 for r in ids if shadow[r] * served * users[r] / max(1e-9, sn["acc"][r]) > gu_p)
        rk[y] = {"mt3": mt3, "ml": ml, "mt3g": mt3g, "mlg": mlg, "bgm": sum(1 for li in spec.mod if lv[li] > sn["dev"][li]),
                 "bgl": sum(1 for li in sn["open"] if lv[li] > sn["dev"][li]), "nl": len(sn["open"]),
                 "ur": ur, "u": pu, "gu": users[gid], "st3": st3, "pt3": pt3, "yr": yr,
                 "sh": shadow["P"], "shg": shadow[gid], "urg": urg}

    def g3_of(end):
        """Dönem hatlarında ilk K1: oyuncu dünyadan önce (sıkı), aynı hafta (eşit), sonra ya da hiç; hat başına ayrıntı."""
        w1, rows, onc, esit, acik = weeks_to_end(end), {}, 0, 0, 0
        for li in spec.era:
            if world.open_w[li] >= w1:
                continue
            acik += 1
            pw = first_k1.get(li)
            ww = world.first_k1[li]
            pw = pw if pw is not None and pw < w1 else None
            ww = ww if ww is not None and ww < w1 else None
            rows[spec.ids[li]] = [pw, ww, world.first_who[li] if ww is not None else None, world.open_w[li]]
            if pw is not None and (ww is None or pw < ww):
                onc += 1
            elif pw is not None and pw == ww:
                esit += 1
        return {"ilk": onc, "esit": esit, "acik": acik, "hat": rows}

    def s2_out(end):
        ya = [yy for yy in years if yy <= end]
        yw = [yy for yy in ya if yy >= y0]

        def total(d, ys):
            out_ = {}
            for yy in ys:
                for k, v in d[yy].items():
                    if isinstance(v, list):
                        x = out_.setdefault(k, [0] * len(v))
                        for i, vi in enumerate(v):
                            x[i] += vi
                    else:
                        out_[k] = out_.get(k, 0) + v
            return out_

        def first(pred):
            return next((yy for yy in ya if pred(rk[yy])), None)

        e = C["g2_erken_son_yil"]
        g2 = {"ilk_dev_modul": first(lambda r: r["bgm"] > 0), "ilk_lider_modul": first(lambda r: r["ml"] > 0),
              "ilk_golge_pay": first(lambda r: r["sh"] > r["shg"]),
              "erken_lider": any(rk[yy]["ml"] > 0 for yy in ya if yy <= e),
              "erken_dev_modul": any(rk[yy]["bgm"] > 0 for yy in ya if yy <= e),
              "gec_golge_son": rk[end]["sh"] > rk[end]["shg"],
              "gec_golge_herhangi": any(rk[yy]["sh"] > rk[yy]["shg"] for yy in ya if yy >= C["g2_gec_ilk_yil"]),
              "gec_urun_son": rk[end]["bgl"] >= 0.5 * rk[end]["nl"],
              "son_golge": rk[end]["sh"], "son_golge_dev": rk[end]["shg"], "son_bgl": rk[end]["bgl"],
              "son_nl": rk[end]["nl"], "son_ml": rk[end]["ml"], "son_mt3": rk[end]["mt3"]}
        yr_ = [yy for yy in ya if yy >= 2013]

        def cnt(pred):
            return sum(1 for yy in yr_ if pred(rk[yy]))

        def top3y(r):
            return r["yr"] is not None and r["yr"] <= 3
        rank = {"yil": len(yr_), "mod_top3": cnt(lambda r: r["mt3"] > 0), "mod_odul": cnt(lambda r: r["ml"] > 0),
                "mod_top3_kalabalik": cnt(lambda r: r["mt3g"] > 0), "mod_odul_kalabalik": cnt(lambda r: r["mlg"] > 0),
                "kul_top3": cnt(lambda r: r["ur"] <= 3), "seg_top3": cnt(lambda r: r["st3"] > 0),
                "prof_top3": cnt(lambda r: r["pt3"] > 0), "yuk_top3": cnt(top3y),
                "iyi_haber_genel": cnt(lambda r: r["mt3"] > 0 or r["ur"] <= 3),
                "iyi_haber": cnt(lambda r: r["mt3"] > 0 or r["ur"] <= 3 or r["st3"] > 0 or r["pt3"] > 0 or top3y(r)),
                "kul_sira": {yy: rk[yy]["ur"] for yy in SEL_YEARS if yy <= end},
                "kul_sira_golge": {yy: rk[yy]["urg"] for yy in SEL_YEARS if yy <= end},
                "kul_golge_top3": cnt(lambda r: r["urg"] <= 3),
                "kul": {yy: rk[yy]["u"] for yy in SEL_YEARS if yy <= end},
                "dev_kul": {yy: rk[yy]["gu"] for yy in SEL_YEARS if yy <= end},
                "mod_top3_son": rk[end]["mt3"]}
        fs = []
        for i in range(NP):
            vals = sorted(x[i] for x in fiveY.get(end, []))
            fs.append({"n": len(vals), "med": med(vals), "max": vals[-1] if vals else float("nan"),
                       "seed_ustu": sum(1 for v in vals if v > C["seed_kapisi"])})
        ay = [sum(ayw[yy][s] for yy in yw) / 52 for s in range(5)]
        return {
            "hesap_yil_yildiz": ay, "kayip_yildiz": [sum(lostY[yy][s] for yy in yw) for s in range(5)],
            "kayip_neden": total(whyY, yw),
            "anlasma": total(dealY, ya), "aday": [sum(leadY[yy][i] for yy in ya) for i in range(5)],
            "ulasilamadi": [sum(unreachY[yy][s] for yy in ya) for s in range(5)], "kaybedilen": total(lossY, ya),
            "p_en_cok": pmax[0], "ilk_4_5": first45[:],
            "kohort": coh, "ilgi_ort": sum(imY[yy] for yy in yw) / (52 * len(yw)),
            "imza_yil": {yy: Y["signed"][yy] for yy in yw},
            "fiyat": {"mrr": {yy: mrrY[yy] for yy in SEL_YEARS if yy <= end},
                      "defter": {k: [sum(ledY[yy][k][i] for yy in yw) for i in range(NP)] for k in PRICE_KINDS},
                      "bes": fs, "yildiz": starY[end],
                      "demo_bes": len(fiveY.get(2013, [])), "demo_mrr": mrrY[2013],
                      "ornek": fx_ornek if fx else []},
            "g2": g2, "sira": rank, "g3": g3_of(end), "g9": {yy: g9Y[yy] for yy in ya},
            "tempo": {"k_hafta": firstk[1:4], "an": snap_t},
        }

    order = []
    for t in range(W):
        y = YEAR[t]
        if world.coupled:
            world.step(t)
        if s2 and t == w_stop:
            for a in accts:
                if a.active:
                    a.coh = True
                    coh["n0"][a.star - 1] += 1
                    coh["m0"] += a.pv[0]
            coh["tot0"] = tot[0]
        elif s2 and t == w_stop + win:
            coh["m1"] = sum(a.pv[0] for a in accts if a.active and a.coh)
            coh["tot1"] = tot[0]
        if t % C["sprint_hafta"] == 0:
            for li in range(n):
                for it in [it for it in pend[li] if t - it[2] >= C["istek_omur_hafta"]]:
                    pend[li].remove(it)
                    it[1].pend.remove(it)
                    Y["expired"][y] += 1
            order = order_for(t)
            cards.append((y, sum(1 for li in range(n) if pend[li] or conds[li]),
                          sum(1 for li in range(n) if conds[li]), sum(len(x) for x in pend)))
            if i_code and active[0] > 0:
                last_rel[0] = t
        team = team_at(y)
        devs = team * max(ga, 1 - gb * math.log2(team))
        pts = (devs * ppw * eff * (1 - ovh) - bugmul * (1 + active[0] / div)) / newk
        if pts > 0:
            cum_pts[0] += pts
        if pts > 0 and order:
            changed = set()
            work(lv, prog, order, pts, room, capw, t, E, changed, when_p, pcost, capera, prem)
            if changed:
                resolve(changed, t)
                last_rel[0] = t
                for li in changed:
                    if spec.kind[li] == "mod":
                        for k in range(1, min(lv[li], 7) + 1):
                            if firstk[k] is None:
                                firstk[k] = t
        while heap and heap[0][0] <= t:
            _, _, kind, a = heapq.heappop(heap)
            if not a.active:
                continue
            if kind == "k":
                update_era(a, t)
                for it in a.pend:
                    if t - it[2] >= C["istek_bekleme_hafta"]:
                        a.sat = max(0.0, a.sat - C["istek_bekleme_ceza"])
                if eskime > 0:
                    for li in lines(a):
                        g = req(li, t, a.ostar) - lv[li]
                        if g > 0:
                            a.sat = max(0.0, a.sat - eskime * g)
                mg, mli, mr = worst_gap(a, t)
                if mg <= 0:
                    continue
                a.wli = mli
                if a.star >= 3:
                    if mg == 1 and a.sat >= memnun:
                        issue_request(a, mli, mr, t, False)
                    elif mg == 1 and a.sat >= dusuk:
                        issue_condition(a, mli, mr, t)
                    else:
                        a.leave = "named"
                else:
                    u = rng.random()
                    if mg == 1:
                        if u < p_low_cond:
                            issue_condition(a, mli, mr, t)
                        elif u < p_low_cond + p_silent[0]:
                            a.leave = "silent"
                    elif u < p_silent[1]:
                        a.leave = "silent"
            elif kind == "y":
                if ud[a.star - 1] > 0 and rng.random() < ud[a.star - 1]:
                    remove(a, t, "urun_disi")
                    continue
                if a.leave:
                    if worst_gap(a, t)[0] <= 0:
                        a.leave = None
                        Y["saved"][y] += 1
                    else:
                        remove(a, t, a.leave)
                        continue
                Y["ren"][y] += 1
                if a.cond is not None:
                    Y["condren"][y] += 1
                    push(t + cond_w, "s", a)
                if rng.random() < C["gidis_yeniden_cek"]:
                    a.traj = rng.choices((0, 1, 2), traj_p[a.star - 1])[0]
                lo, hi = traj_r[a.traj]
                a.emp *= 1 + rng.uniform(lo, hi)
                need = a.emp * C["koltuk_calisan_orani"]
                thr = max(seat_abs, seat_rel * a.seats)
                if a.star == 1:
                    Y["one_star_ren"][y] += 1
                if need >= a.seats + thr and a.sat >= dusuk:
                    if need > 1000:
                        Y["over1000"][y] += 1
                    a.seats = min(1000, int(round(need)))
                    Y["seat_up"][y] += 1
                    if a.star == 1:
                        Y["one_star_up"][y] += 1
                elif need <= a.seats - thr:
                    a.seats = max(1, int(round(need)))
                    Y["seat_down"][y] += 1
                if s2:
                    book(a, "gen_koltuk", t)
                ns = star_of(a.seats)
                if ns != a.star:
                    cell[(a.prof, a.star)] -= 1
                    cell[(a.prof, ns)] = cell.get((a.prof, ns), 0) + 1
                    if s2:
                        nstar[a.star - 1] -= 1
                        nstar[ns - 1] += 1
                    a.star = ns
                    Y["star_ch"][y] += 1
                push(t + 52 - chk, "k", a)
                push(t + 52, "y", a)
            elif kind == "i":
                push(t + 52, "i", a)
                p = p_req[a.star - 1]
                if p <= 0 or rng.random() >= p:
                    continue
                if a.traj == 0 and rng.random() < C["istek_yeni_modul_payi"]:
                    w = spec.wants(a.sec)
                    cands = sorted(li for li in w if li not in a.mods)
                    if cands:
                        li = rng.choices(cands, [w[x] for x in cands])[0]
                        r = req(li, t, a.ostar)
                        if lv[li] >= r:
                            a.mods.append(li)
                            if s2:
                                book(a, "gen_modul", t)
                            wk["req"] += 1
                            Y["req"][y] += 1
                            Y["fulfil"][y] += 1
                        else:
                            issue_request(a, li, r, t, True)
                        continue
                cands = [li for li in a.mods + a.era if lv[li] < capw[li][t]]
                if C["istek_derinlik_hedefi"] == "piyasa":
                    cands = [li for li in cands if lv[li] < max(req(li, t, a.ostar), Lh[li][t])]
                if cands:
                    li = a.imp if a.imp in cands and rng.random() < C["istek_onemli_modul_payi"] else rng.choice(cands)
                    issue_request(a, li, min(capw[li][t], max(req(li, t, a.ostar), lv[li] + 1)), t, False)
            elif kind == "s":
                if a.cond is not None:
                    remove(a, t, "sart")
        if s2:
            sales_step(t)
        else:
            tgt = int(player_target(C, scale, t))
            if active[0] < tgt:
                for _ in range(min(tgt - active[0], max(1, math.ceil(scale * C["portfoy_dolum"])))):
                    a = sample(t)
                    key = (a.prof, a.star)
                    if cell.get(key, 0) + 1 > C["portfoy_hucre_tavani"] * cell_cap(a.prof, a.star, y):
                        Y["rej_cell"][y] += 1
                        continue
                    if not fits(a, t):
                        Y["rej_fit"][y] += 1
                        continue
                    a.active = True
                    accts.append(a)
                    active[0] += 1
                    cell[key] = cell.get(key, 0) + 1
                    Y["signed"][y] += 1
                    push(t + 52 - chk, "k", a)
                    push(t + 52, "y", a)
                    push(t + rng.randint(1, 52), "i", a)
        mail[t] = wk["req"] + wk["cond"] + wk["named"]
        wreq[t], wcond[t] = wk["req"], wk["cond"]
        wk["req"] = wk["cond"] = wk["named"] = 0
        actw[t] = active[0]
        if t in (51, 103):
            ml = [lv[li] for li in spec.mod]
            snap_t[t + 1] = {"k1": sum(x >= 1 for x in ml), "k2": sum(x >= 2 for x in ml), "k3": sum(x >= 3 for x in ml),
                             "en_ust": max(ml), "puan": cum_pts[0], "ekip": team_at(y)}
        if s2:
            for s in range(5):
                ayw[y][s] += nstar[s]
            im = imult(t)
            imY[y] += im
            if w_stop <= t < w_stop + win:
                coh["im"] += im / win
        if t == W - 1 or YEAR[t + 1] != y:
            gl = world.snaps[y]["dev"]
            opn = world.snaps[y]["open"]
            beats[y] = sum(1 for li in opn if lv[li] > gl[li])
            beats_mod[y] = sum(1 for li in spec.mod if lv[li] > gl[li])
            for (pid, st), c in cell.items():
                if c > cell_cap(pid, st, y) + 1e-9:
                    g8.append(f"{y}: oyuncu {pid} {st}★ hücresi havuzu aşıyor ({c})")
            if active[0] > world.pool(y) or active[0] < 0:
                g8.append(f"{y}: oyuncu hesap sayısı sınır dışı")
            if min(lv) < 0 or any(a.seats < 1 or not 0 <= a.sat <= 100 for a in accts if a.active):
                g8.append(f"{y}: oyuncu negatif ya da sınır dışı değer")
            if s2:
                year_end_s2(y, t)

    # ölçüler (bitiş yılı başına pencere)
    out = {}
    for end in C["bitis_yillari"]:
        w1 = weeks_to_end(end)
        yrs = range(y0, end + 1)
        acc_years = {yy: sum(actw[t] for t in range(W) if YEAR[t] == yy) / 52 for yy in yrs}
        ay = sum(acc_years.values()) or 1e-9
        m = mail[w0:w1]
        cw = [c for yy, c, _, _ in cards if y0 <= yy <= end]
        cs = [c for yy, _, c, _ in cards if y0 <= yy <= end]
        cp = [c for yy, _, _, c in cards if y0 <= yy <= end]
        condren = [Y["condren"][yy] / acc_years[yy] for yy in yrs if acc_years[yy] > 0]
        ren = sum(Y["ren"][yy] for yy in yrs) or 1e-9
        one_ren = sum(Y["one_star_ren"][yy] for yy in yrs) or 1e-9
        out[end] = {
            "mail_med": med(m), "mail_p99": pct(m, 99), "mail_max": max(m), "mail_ort": sum(m) / len(m),
            "mail_butce_asim": sum(max(0, x - C["mail_butcesi"]) for x in m) / len(m),
            "istek_hafta": sum(wreq[w0:w1]) / len(m), "sart_hafta": sum(wcond[w0:w1]) / len(m),
            "kart_med": med(cw), "kart_p95": pct(cw, 95), "kart_max": max(cw) if cw else 0,
            "kart_sartli_ort": sum(cs) / len(cs), "bekleyen_istek_ort": sum(cp) / len(cp),
            "sartli_yillik": condren, "sartli_med": med(condren),
            "istek_oran": sum(Y["req"][yy] for yy in yrs) / ay,
            "sart_oran": sum(Y["cond"][yy] for yy in yrs) / ay,
            "adli_gidis_oran": sum(Y["named"][yy] for yy in yrs) / ay,
            "sessiz_gidis_oran": sum(Y["silent"][yy] for yy in yrs) / ay,
            "hesap_ort": sum(actw[w0:w1]) / len(m), "dolum": sum(actw[w0:w1]) / len(m) / scale,
            "ust_yildiz_pay": sum(1 for a in accts if a.active and a.star >= 3) / max(1, active[0]),
            "koltuk_degisim": sum(Y["seat_up"][yy] + Y["seat_down"][yy] for yy in yrs) / ren,
            "yildiz_degisim": sum(Y["star_ch"][yy] for yy in yrs) / ren,
            "bir_yildiz_buyume": sum(Y["one_star_up"][yy] for yy in yrs) / one_ren,
            "bin_ustu": sum(Y["over1000"][yy] for yy in yrs),
            "devi_gecen": {yy: beats[yy] for yy in (2018, 2022, 2026, 2030, 2035) if yy <= end},
            "devi_gecen_mod": {yy: beats_mod[yy] for yy in (2018, 2022, 2026, 2030, 2035) if yy <= end},
            "oncu_ilk": sum(1 for li in spec.era if li in first_k1 and world.open_w[li] < w1
                            and (world.first_k1[li] is None or first_k1[li] <= world.first_k1[li])),
            "donem_acik": sum(1 for li in spec.era if world.open_w[li] < w1),
            "g8": [x for x in g8 if int(x[:4]) <= end],
        }
        if s2:
            out[end]["s2"] = s2_out(end)
    return out


# ---------------------------------------------------------------- koşu düzeni

B_BOTS = ("odakli", "verimli", "oncu", "daginik")
B_TEAMS = ("buyuyen", 50)


def task_list(C, mode, seeds, flt=None):
    """Görev: (N, tohum, ölçek, kombinasyonlar, kol). Kol 'A' bir dünyayı bütün botlara okutur; kol 'B'
    (yalnız sim2, bilinen yol) her bot için oyuncuyla birlikte adım adım yürüyen ayrı bir dünya kurar."""
    teams = C["takim_kollari"]
    tasks = []
    flt = flt or {}
    for N in flt.get("N") or NS:
        for s in range(seeds):
            if mode == "g1":
                tasks.append((N, s, 330, [], "A"))
                continue
            if mode == "sim2" and not flt.get("bkolu_yok"):
                tasks.append((N, s, 330, [(b, tm) for b in B_BOTS for tm in B_TEAMS], "B"))
            for scale in flt.get("olcek") or C["olcekler"]:
                bots = flt.get("bot") or BOTS
                tms = flt.get("takim") or teams
                combos = [(b, tm) for b in bots for tm in tms] if (N == 10 or scale == 330) else []
                tasks.append((N, s, scale, combos, "A"))
    return tasks


def worker(args):
    N, seed, scale, combos, arm, overrides, overlay = args
    if arm == "B":
        D = load_all(overrides, overlay)
        D["C"]["bilinen_yol"] = D["C"]["bilinen_yol_kolu"]
        spec = Spec(N, D)
        res, g1s, g8 = [], [], []
        for bot, team in combos:
            w = World(spec, D, seed, scale, coupled=True)
            res.append((bot, team, run_player(w, D, bot, team, scale)))
            g1s.append((bot, team, w.g1_rows()))
            g8 += [f"B {bot} {team}: {x}" for x in w.g8]
        return {"N": N, "seed": seed, "scale": scale, "arm": "B", "players": res, "g1B": g1s, "g8": g8}
    D = load_all(overrides, overlay)
    spec = Spec(N, D)
    t0 = time.perf_counter()
    w = World(spec, D, seed, scale)
    tw = time.perf_counter() - t0
    res = []
    for bot, team in combos:
        res.append((bot, team, run_player(w, D, bot, team, scale)))
    return {"N": N, "seed": seed, "scale": scale, "arm": "A", "g1": w.g1_rows(), "g8": w.g8, "events": w.events,
            "first_k1": {spec.ids[li]: (w.first_k1[li], w.first_who[li], w.open_w[li]) for li in spec.era},
            "ops_per_week": w.ops / w.W, "world_s": tw, "players": res}


def aggregate(results, C):
    agg = {"g1": {}, "players": {}, "g8": [], "first_k1": {}, "events": {}, "ops_per_week": [], "world_s": [],
           "B": {}, "g1B": {}}
    for r in results:
        if r["arm"] == "B":
            agg["g8"] += [f"N={r['N']} tohum={r['seed']}: {x}" for x in r["g8"]]
            for bot, team, m in r["players"]:
                agg["B"].setdefault((r["N"], bot, str(team), r["scale"]), []).append(m)
                agg["g8"] += [f"N={r['N']} B {bot} takım={team} tohum={r['seed']}: {x}"
                              for x in m[max(C["bitis_yillari"])]["g8"]]
            for bot, team, rows in r["g1B"]:
                agg["g1B"].setdefault(r["N"], []).append(rows)
            continue
        agg["g8"] += [f"N={r['N']} tohum={r['seed']} ölçek={r['scale']}: {x}" for x in r["g8"]]
        agg["ops_per_week"].append(r["ops_per_week"])
        agg["world_s"].append(r["world_s"])
        if r["scale"] == 330:
            agg["g1"].setdefault(r["N"], []).append(r["g1"])
            agg["first_k1"].setdefault(r["N"], []).append(r["first_k1"])
            agg["events"].setdefault(r["N"], []).append(r["events"])
        for bot, team, m in r["players"]:
            key = (r["N"], bot, str(team), r["scale"])
            agg["players"].setdefault(key, []).append(m)
            agg["g8"] += [f"N={r['N']} {bot} takım={team} ölçek={r['scale']} tohum={r['seed']}: {x}"
                          for x in m[max(C["bitis_yillari"])]["g8"]]
    return agg


# ---------------------------------------------------------------- rapor tabloları

def g1_summary(agg, C):
    """N ve bitiş başına G1: yıl başına tohum medyanı."""
    out = {}
    y0, lim, devcap = C["olcum_baslangic_yili"], C["g1_tavan_alti"], C["g1_dev_tavanda_en_cok"]
    for N, runs in sorted(agg["g1"].items()):
        years = sorted(runs[0])
        per_year = {}
        for y in years:
            rows = [r[y] for r in runs]
            per_year[y] = {
                "tavan": rows[0]["tavan"],
                "S_med": med([r["S_med"] for r in rows]),
                "L_med": med([r["L_med"] for r in rows]),
                "fark": med([r["fark"] for r in rows]),
                "fark_etkin": med([r["fark_etkin"] for r in rows]),
                "fark_min": min(r["fark"] for r in rows),
                "fark_plat": med([r["fark_plat"] for r in rows]),
                "dev_tavanda": med([r["dev_tavanda"] for r in rows]),
                "dev_hat": rows[0]["dev_hat"],
                "dev_pay": med([r["dev_tavanda_pay"] for r in rows]),
                "dev_mod_tavanda": med([r["dev_mod_tavanda"] for r in rows]),
                "rakip_gel": med([r["rakip_gelistirici"] for r in rows]),
                "dev_gel": med([r["dev_gelistirici"] for r in rows]),
                "dev_hesap": med([r["dev_hesap"] for r in rows]),
                "aktif_rakip": med([r["aktif_rakip"] for r in rows]),
                "tohum_fail": sum(1 for r in rows if r["fark"] < lim),
            }
        out[N] = {}
        for end in C["bitis_yillari"]:
            ys = [y for y in years if y0 <= y <= end]
            fails = [y for y in ys if per_year[y]["fark"] < lim]
            devf = [y for y in ys if per_year[y]["dev_pay"] > devcap]
            at_cap = [y for y in ys if per_year[y]["fark"] <= 0]
            first_cap = next((y for y in years if y <= end and per_year[y]["fark"] <= 0), None)
            first_cap15 = next((y for y in ys if per_year[y]["fark"] <= 0), None)
            s_rise = (per_year[end]["S_med"] - per_year[y0 - 1]["S_med"]) / (end - y0 + 1)
            out[N][end] = {"fail_years": fails, "dev_fail_years": devf, "at_cap_years": at_cap,
                           "tavan_yili": first_cap, "tavan_yili_2015": first_cap15,
                           "ok": not fails and not devf, "S_yillik_artis": s_rise,
                           "son_fark": per_year[end]["fark"], "son_dev_pay": per_year[end]["dev_pay"],
                           "seed_year_fail": sum(per_year[y]["tohum_fail"] for y in ys),
                           "seed_years": len(ys) * len(runs)}
        out[N]["yillar"] = per_year
    return out


def player_summary(agg, C):
    out = {}
    for key, runs in agg["players"].items():
        out[key] = {}
        for end in C["bitis_yillari"]:
            ms = [r[end] for r in runs]
            d = {}
            for f in ("mail_med", "mail_p99", "mail_max", "mail_ort", "mail_butce_asim", "istek_hafta",
                      "sart_hafta", "kart_med", "kart_p95", "kart_max", "sartli_med", "istek_oran", "sart_oran",
                      "adli_gidis_oran", "sessiz_gidis_oran", "hesap_ort", "dolum", "ust_yildiz_pay",
                      "koltuk_degisim", "yildiz_degisim", "bir_yildiz_buyume", "bin_ustu", "oncu_ilk", "donem_acik",
                      "kart_sartli_ort", "bekleyen_istek_ort"):
                vals = [m[f] for m in ms]
                d[f] = med(vals)
                d[f + "_max"] = max(vals)
            d["sartli_bant_ici"] = med([sum(1 for x in m["sartli_yillik"]
                                            if C["g5_sartli_bant"][0] <= x <= C["g5_sartli_bant"][1])
                                        / max(1, len(m["sartli_yillik"])) for m in ms])
            d["devi_gecen"] = {y: med([m["devi_gecen"][y] for m in ms]) for y in ms[0]["devi_gecen"]}
            d["devi_gecen_mod"] = {y: med([m["devi_gecen_mod"][y] for m in ms]) for y in ms[0]["devi_gecen_mod"]}
            out[key][end] = d
    return out


def fmt(x, d=2):
    if isinstance(x, float):
        if math.isnan(x):
            return "-"
        return f"{x:.{d}f}".replace(".", ",")
    return str(x)


GATE_TEAMS = ("25", "50", "buyuyen")
GATE_BOTS = [b for b in BOTS if b != "durgun"]
DIAGONAL = ((1, 10), (3, 10), (6, 100), (12, 100), (25, 330), (50, 600))


def g5_gate(ps, C, N, end):
    """G5 alt kapıları: ölçek 330, takım 25/50/büyüyen, durgun dışı botlar; hücre başına tohum medyanı, en kötü hücre."""
    cells = [ps[(N, b, t, 330)][end] for b in GATE_BOTS for t in GATE_TEAMS if (N, b, t, 330) in ps]
    if not cells:
        return None
    lo, hi = C["g5_sartli_bant"]
    r = {"mail_med": max(c["mail_med"] for c in cells), "mail_p99": max(c["mail_p99_max"] for c in cells),
         "mail_max": max(c["mail_max_max"] for c in cells), "kart_p95": max(c["kart_p95"] for c in cells),
         "kart_p95_enkotu": max(c["kart_p95_max"] for c in cells), "kart_med": max(c["kart_med"] for c in cells),
         "sartli_min": min(c["sartli_med"] for c in cells), "sartli_max": max(c["sartli_med"] for c in cells)}
    r["ok_mail"] = r["mail_med"] <= C["g5_mail_medyan"] and r["mail_p99"] <= C["g5_mail_tepe"]
    r["ok_kart"] = r["kart_p95"] <= C["g5_kart"]
    r["ok_sartli"] = lo <= r["sartli_min"] and r["sartli_max"] <= hi
    return r


def g10_rows(ps, C, N=10, end=2030):
    """Hesap başına istek ve şart oranı: ölçekler arası (büyüyen takım), takım kolları arası (330), köşegen."""
    band = C["g10_bant"]
    rows = []
    for label, keys in (
            ("ölçekler 10/100/330/600 (büyüyen takım)", [("buyuyen", sc) for sc in C["olcekler"]]),
            ("takım kolları 1/3/6/12/25/50/büyüyen (ölçek 330)", [(str(t), 330) for t in C["takim_kollari"]]),
            ("köşegen 1-10, 3-10, 6-100, 12-100, 25-330, 50-600", [(str(t), sc) for t, sc in DIAGONAL])):
        for f in ("istek_oran", "sart_oran"):
            vals = [med([ps[(N, b, t, sc)][end][f] for b in GATE_BOTS if (N, b, t, sc) in ps]) for t, sc in keys]
            vals = [v for v in vals if not math.isnan(v)]
            m = sum(vals) / len(vals) if vals else float("nan")
            dev = max(abs(v / m - 1) for v in vals) if vals and m > 0 else float("nan")
            rows.append({"kol": label, "olcu": f, "degerler": vals, "ortalama": m, "sapma": dev,
                         "ok": not math.isnan(dev) and dev <= band})
    return rows


def soru23(g1, ps, C, D):
    """Soru 2 (modül sayısı) ve Soru 3 (bitiş yılı) için N x bitiş özet satırları."""
    out = {}
    eras = D["eras"]
    for N in NS:
        if N not in g1:
            continue
        spec = Spec(N, D)
        avail = [len(spec.prof[p]["ZS"]) for p in spec.prof_ids]
        sets = {tuple(sorted(spec.prof[p]["Z"])) for p in spec.prof_ids}
        for end in C["bitis_yillari"]:
            capE = max(k for yy, k in eras["tavan"] if yy <= end)
            era_open = [spec.era_info[li] for li in spec.era if int(spec.era_info[li]["acilis"][:4]) <= end]
            era_tiers = sum(min(capE, eras["donem_ilk_tavan"] + (end - int(e["acilis"][:4])) // 2) for e in era_open)
            g = g1[N][end]
            yrs = [y for y in g1[N]["yillar"] if C["olcum_baslangic_yili"] <= y <= end]
            row = {"hat": N + len(spec.plat) + len(era_open), "donem_hatti": len(era_open),
                   "kademe_adi": N * capE + len(spec.plat) * (capE + eras["platform_tavan_farki"]) + era_tiers,
                   "profil_ayri_kume": len(sets), "profil_modul_ort": sum(avail) / len(avail),
                   "g1_ok": g["ok"], "g1_dusen_yil": len(g["fail_years"]), "dev_fazla_yil": len(g["dev_fail_years"]),
                   "son_fark": g["son_fark"], "S_artis": g["S_yillik_artis"], "tavan_end": capE,
                   "S_end": g1[N]["yillar"][end]["S_med"],
                   "dev_tavanda_en_cok": max(g1[N]["yillar"][y]["dev_pay"] for y in yrs),
                   "dev_tavanda_son": g1[N]["yillar"][end]["dev_pay"],
                   "hafta": weeks_to_end(end), "saat_22": weeks_to_end(end) * 22.5 / 3600,
                   "saat_45": weeks_to_end(end) * 45 / 3600}
            for bot in ("odakli", "verimli", "oncu", "daginik"):
                d = ps.get((N, bot, "buyuyen", 330), {}).get(end)
                if d:
                    row[bot] = {"devi_gecen": d["devi_gecen"], "devi_gecen_mod": d["devi_gecen_mod"],
                                "oncu_ilk": d["oncu_ilk"], "donem_acik": d["donem_acik"], "hesap": d["hesap_ort"],
                                "istek": d["istek_oran"], "sart": d["sart_oran"], "kart_p95": d["kart_p95"],
                                "sartli": d["sartli_med"]}
            g5 = g5_gate(ps, C, N, end)
            if g5:
                row["g5"] = g5
            out[(N, end)] = row
    return out


def print_tables(g1, ps, C, D, elapsed):
    ok = lambda b: "✅" if b else "❌"
    nan = float("nan")
    lines = []
    P = lines.append
    y0 = C["olcum_baslangic_yili"]
    P(f"## G1 · doygunluk (ölçek 330, tohum medyanı; {y0} ve sonrası)\n")
    P("| N | bitiş | kapı | modül medyanı tavana <1 olan yıl | dev hatlarının >%60'ı tavanda olan yıl | medyanın tavana eşitlendiği ilk yıl (tümü / 2015+) | tavanda yıl | S yıllık artış (ort.) | son yıl tavana kalan | son yıl dev tavanda pay | düşen tohum-yıl |")
    P("|---|---|---|---|---|---|---|---|---|---|---|")
    for N in NS:
        if N not in g1:
            continue
        for end in C["bitis_yillari"]:
            r = g1[N][end]
            P(f"| {N} | {end} | {ok(r['ok'])} | {len(r['fail_years'])}: {span(r['fail_years'])} | "
              f"{len(r['dev_fail_years'])}: {span(r['dev_fail_years'])} | {r['tavan_yili'] or '-'} / {r['tavan_yili_2015'] or 'yok'} | "
              f"{len(r['at_cap_years'])} | {fmt(r['S_yillik_artis'])} | {fmt(r['son_fark'])} | "
              f"{fmt(r['son_dev_pay'])} | {r['seed_year_fail']}/{r['seed_years']} |")
    for N in NS:
        if N not in g1:
            continue
        P(f"\n### N={N}: yıl sonu (tohum medyanı)\n")
        P("| yıl | tavan | modül S medyanı | L medyanı | tavana kalan (medyan / en kötü tohum) | platform tavana kalan | dev tavanda hat | dev tavanda modül | rakip geliştirici (dev) | dev hesap | aktif rakip |")
        P("|---|---|---|---|---|---|---|---|---|---|---|")
        for y, r in g1[N]["yillar"].items():
            if y <= 2020 or y % 2 == 0 or y in (2031, 2033, 2035):
                P(f"| {y} | K{r['tavan']} | {fmt(r['S_med'], 1)} | {fmt(r['L_med'], 1)} | {fmt(r['fark'], 1)} / {fmt(r['fark_min'], 1)} | "
                  f"{fmt(r['fark_plat'], 1)} | {fmt(r['dev_tavanda'], 0)}/{r['dev_hat']} | {fmt(r['dev_mod_tavanda'], 0)}/{N} | "
                  f"{fmt(r['rakip_gel'], 0)} ({fmt(r['dev_gel'], 0)}) | {fmt(r['dev_hesap'], 0)} | {fmt(r['aktif_rakip'], 0)} |")
    if not ps:
        lines.append(f"\n(çalışma süresi {elapsed:.0f} sn)")
        return "\n".join(lines)
    P("\n## G5 · kapı hücreleri (ölçek 330; takım 25, 50, büyüyen; durgun dışı 5 bot; en kötü hücre)\n")
    P("| N | bitiş | mail/hafta medyan | mail p99 (en kötü tohum) | mail en çok | kapı mail | açık kart medyan | kart p95 (en kötü tohum) | kapı kart | şartlı yenilenen/yıl (hücre aralığı) | kapı şartlı |")
    P("|---|---|---|---|---|---|---|---|---|---|---|")
    for N in NS:
        for end in C["bitis_yillari"]:
            r = g5_gate(ps, C, N, end)
            if r:
                P(f"| {N} | {end} | {fmt(r['mail_med'], 1)} | {fmt(r['mail_p99'], 0)} | {fmt(r['mail_max'], 0)} | {ok(r['ok_mail'])} | "
                  f"{fmt(r['kart_med'], 1)} | {fmt(r['kart_p95'], 0)} ({fmt(r['kart_p95_enkotu'], 0)}) | {ok(r['ok_kart'])} | "
                  f"%{fmt(r['sartli_min'] * 100, 1)} - %{fmt(r['sartli_max'] * 100, 1)} | {ok(r['ok_sartli'])} |")
    P("\n## G10 ön okuma · hesap başına istek ve şart oranı (N=10, 2030, durgun dışı botların medyanı)\n")
    P("| kol | ölçü | değerler | ortalama | en büyük sapma | ±%30 |")
    P("|---|---|---|---|---|---|")
    for r in g10_rows(ps, C):
        P(f"| {r['kol']} | {r['olcu']} | {' / '.join(fmt(v, 3) for v in r['degerler'])} | {fmt(r['ortalama'], 3)} | "
          f"%{fmt(r['sapma'] * 100, 0)} | {ok(r['ok'])} |")
    for end in C["bitis_yillari"]:
        P(f"\n## G5 ayrıntı · N=10, ölçek 330, bitiş {end} (tohum medyanı; parantezde en kötü tohum)\n")
        P("| bot | takım | mail/hafta medyan | mail p99 (en kötü) | mail en çok | özete kalan/hafta | açık kart medyan | kart p95 (en kötü) | şartlı yenilenen/yıl | bantta yıl payı | istek/hesap-yıl | şart/hesap-yıl | adlı gidiş/hesap-yıl | sessiz gidiş/hesap-yıl | ortalama hesap | 3★+ payı |")
        P("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for bot in BOTS:
            for team in C["takim_kollari"]:
                d = ps.get((10, bot, str(team), 330), {}).get(end)
                if not d:
                    continue
                P(f"| {bot} | {team} | {fmt(d['mail_med'], 1)} | {fmt(d['mail_p99'], 0)} ({fmt(d['mail_p99_max'], 0)}) | {fmt(d['mail_max_max'], 0)} | "
                  f"{fmt(d['mail_butce_asim'])} | {fmt(d['kart_med'], 1)} | {fmt(d['kart_p95'], 0)} ({fmt(d['kart_p95_max'], 0)}) | "
                  f"%{fmt(d['sartli_med'] * 100, 1)} | %{fmt(d['sartli_bant_ici'] * 100, 0)} | {fmt(d['istek_oran'], 3)} | {fmt(d['sart_oran'], 3)} | "
                  f"{fmt(d['adli_gidis_oran'], 3)} | {fmt(d['sessiz_gidis_oran'], 3)} | {fmt(d['hesap_ort'], 0)} | %{fmt(d['ust_yildiz_pay'] * 100, 0)} |")
    P("\n## Soru 2 ve Soru 3 · N x bitiş özeti (oyuncu kolları: büyüyen takım, ölçek 330)\n")
    P("| N | bitiş | hat (modül+platform+dönem) | yazılacak kademe adı | profil: ayrı modül kümesi / profil başına modül | G1 | S son yıl / tavan | S artış/yıl | dev tavanda en çok / son yıl | odaklı devi geçen hat 2022 / 2030 / 2035 | verimli devi geçen 2030 | öncü ilk K1 / açılan dönem hattı | dağınık: kart p95, şartlı, şart/hesap-yıl | hafta; saat (22,5 sn / 45 sn) |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    for (N, end), r in soru23(g1, ps, C, D).items():
        od, vr, oc, dg = r.get("odakli", {}), r.get("verimli", {}), r.get("oncu", {}), r.get("daginik", {})
        odg = od.get("devi_gecen", {})
        P(f"| {N} | {end} | {r['hat']} | {r['kademe_adi']} | {r['profil_ayri_kume']} / {fmt(r['profil_modul_ort'], 1)} | {ok(r['g1_ok'])} | "
          f"{fmt(r['S_end'], 1)} / K{r['tavan_end']} | {fmt(r['S_artis'])} | {fmt(r['dev_tavanda_en_cok'])} / {fmt(r['dev_tavanda_son'])} | "
          f"{' / '.join(fmt(odg.get(y, nan), 0) for y in (2022, 2030, 2035) if y <= end)} | {fmt(vr.get('devi_gecen', {}).get(2030, nan), 0)} | "
          f"{fmt(oc.get('oncu_ilk', nan), 0)} / {fmt(oc.get('donem_acik', nan), 0)} | "
          f"{fmt(dg.get('kart_p95', nan), 0)}, %{fmt(dg.get('sartli', nan) * 100, 1)}, {fmt(dg.get('sart', nan), 3)} | "
          f"{r['hafta']}; {fmt(r['saat_22'], 1)} / {fmt(r['saat_45'], 1)} |")
    P("\n## Durgun kol (G4 ön okuma; N=10, ölçek 330, 2030)\n")
    P("| takım | şart/hesap-yıl | adlı gidiş/hesap-yıl | sessiz gidiş/hesap-yıl | ortalama hesap |")
    P("|---|---|---|---|---|")
    for team in C["takim_kollari"]:
        d = ps.get((10, "durgun", str(team), 330), {}).get(2030)
        if d:
            P(f"| {team} | {fmt(d['sart_oran'], 3)} | {fmt(d['adli_gidis_oran'], 3)} | {fmt(d['sessiz_gidis_oran'], 3)} | {fmt(d['hesap_ort'], 0)} |")
    lines.append(f"\n(çalışma süresi {elapsed:.0f} sn)")
    return "\n".join(lines)


# ---------------------------------------------------------------- SIM2 tabloları

STRONG = ("odakli", "verimli", "oncu")
G4_TEAMS = ("buyuyen", 25, 50)
MODULE_NAMED = ("named", "sart", "silent", "urun_disi")  # adı taşıyan ayrılmalar: modül, rakip ve (SENTEZ §13.2 tanımı) ürün dışı neden


def _rate(xs):
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs) if xs else float("nan")


def _in(x, band):
    return not math.isnan(x) and band[0] <= x <= band[1]


def g6_cells(PS, C, N, end):
    cells = []
    for b in GATE_BOTS:
        for tm in GATE_TEAMS:
            runs = PS.get((N, b, tm, 330))
            if not runs:
                continue
            m = [r[end] for r in runs]
            lost = [sum(x["s2"]["kayip_yildiz"][s] for x in m) for s in range(5)]
            ay = [sum(x["s2"]["hesap_yil_yildiz"][s] for x in m) for s in range(5)]
            cells.append({"bot": b, "takim": tm, "koltuk": med([x["koltuk_degisim"] for x in m]),
                          "yildiz": med([x["yildiz_degisim"] for x in m]),
                          "bir_buyume": med([x["bir_yildiz_buyume"] for x in m]),
                          "bin_ustu_isteyen": sum(x["bin_ustu"] for x in m),
                          "tutma": [1 - lost[s] / ay[s] if ay[s] >= 1 else float("nan") for s in range(5)],
                          "hesap_yil": ay})
    if not cells:
        return None
    c5 = [c["tutma"][4] for c in cells if c["hesap_yil"][4] >= C["g6_bes_en_az_hesap_yil"]]
    r = {"hucre": cells,
         "koltuk": [min(c["koltuk"] for c in cells), max(c["koltuk"] for c in cells)],
         "yildiz": max(c["yildiz"] for c in cells), "bir_buyume": max(c["bir_buyume"] for c in cells),
         "bin_ustu_isteyen": sum(c["bin_ustu_isteyen"] for c in cells),
         "tutma1": [min(c["tutma"][0] for c in cells), max(c["tutma"][0] for c in cells)],
         "tutma5": [min(c5), max(c5)] if c5 else [float("nan")] * 2, "tutma5_hucre": len(c5)}
    r["ok"] = {"koltuk": all(_in(c["koltuk"], C["g6_koltuk_bant"]) for c in cells),
               "yildiz": r["yildiz"] <= C["g6_yildiz_degisim"], "bir_buyume": r["bir_buyume"] <= C["g6_bir_yildiz_buyume"],
               "bin": True, "tutma1": all(_in(c["tutma"][0], C["g6_tutma_1"]) for c in cells),
               "tutma5": bool(c5) and all(_in(x, C["g6_tutma_5"]) for x in c5)}
    r["ok"]["hepsi"] = all(r["ok"].values())
    return r


def g7_pool(PS, C, N, end):
    dl, lead, unre, loss, pm = {}, [0] * 5, [0] * 5, {}, 0.0
    cell_stale = []
    for key, runs in PS.items():
        if key[0] != N:
            continue
        cl = [0] * 5
        for r in runs:
            s = r[end]["s2"]
            for k, v in s["anlasma"].items():
                x = dl.setdefault(k, [0, 0, 0.0])
                for i in range(3):
                    x[i] += v[i]
            for i in range(5):
                lead[i] += s["aday"][i]
                cl[i] += s["aday"][i]
                unre[i] += s["ulasilamadi"][i]
            for k, v in s["kaybedilen"].items():
                loss[k] = loss.get(k, 0) + v
            pm = max(pm, s["p_en_cok"])
        if cl[0] >= 50:
            cell_stale.append(((cl[2] + cl[3]) / cl[0], key))

    def rate_of(s, ds, f):
        x = [sum(dl.get(f"{s}|{d}|{f}", [0, 0, 0.0])[i] for d in ds) for i in range(3)]
        return (x[1] / x[0] if x[0] else float("nan")), x[0], (x[2] / x[0] if x[0] else float("nan"))
    stars = []
    for s in range(1, 6):
        # 'eşleşen' = satıcı hesabın yıldızında ya da üstünde (1★ satıcı yok: kurucu 2★)
        m, mn, mp = rate_of(s, (0, 1, 2), 1)
        b, bn, bp = rate_of(s, (-1,), 1)
        alln = sum(v[0] for k, v in dl.items() if k.startswith(f"{s}|"))
        allw = sum(v[1] for k, v in dl.items() if k.startswith(f"{s}|"))
        full = sum(v[0] for k, v in dl.items() if k.startswith(f"{s}|") and k.endswith("|1"))
        stars.append({"yildiz": s, "esles_tam": m, "esles_tam_n": mn, "esles_tam_p": mp, "alt_tam": b, "alt_tam_n": bn,
                      "alt_tam_p": bp, "oran": b / m if mn and bn and m > 0 else float("nan"),
                      "hepsi": allw / alln if alln else float("nan"), "hepsi_n": alln,
                      "tam_uyum_pay": full / alln if alln else float("nan"),
                      "ulasilamadi": unre[s - 1]})
    stale = (lead[2] + lead[3]) / lead[0] if lead[0] else float("nan")
    worst = max(cell_stale) if cell_stale else (float("nan"), None)
    minn = C["g7_en_az_ornek"]
    ok = {"1yildiz": stars[0]["esles_tam_n"] < minn or _in(stars[0]["esles_tam"], C["g7_1yildiz"]),
          "5yildiz": stars[4]["esles_tam_n"] < minn or _in(stars[4]["esles_tam"], C["g7_5yildiz"]),
          "alt_oran": all(_in(x["oran"], C["g7_alt_oran"]) for x in stars
                          if x["esles_tam_n"] >= minn and x["alt_tam_n"] >= minn),
          "yuzde_yuz_yok": pm < 1.0, "bayat": stale <= C["g7_bayat_en_cok"],
          "bayat_en_kotu_hucre": worst[0] <= C["g7_bayat_en_cok"]}
    ok["hepsi"] = all(ok.values())
    return {"yildiz": stars, "aday": lead, "ulasilamadi": unre, "kayip_nedeni": loss, "p_en_cok": pm,
            "bayat": stale, "bayat_en_kotu": worst[0], "bayat_en_kotu_hucre": list(worst[1]) if worst[1] else None,
            "ok": ok}


def g4_cell(runs, end):
    ks = [r[end]["s2"]["kohort"] for r in runs]
    loss = [1 - k["m1"] / k["m0"] for k in ks if k["m0"] > 0]
    lost = sum(sum(k["lost"]) for k in ks)
    why, whym, hat = {}, {}, {}
    for k in ks:
        for w, v in k["why"].items():
            why[w] = why.get(w, 0) + v
        for w, v in k["whym"].items():
            whym[w] = whym.get(w, 0.0) + v
        for w, v in k["hat"].items():
            hat[w] = hat.get(w, 0) + v
    named = sum(v for w, v in why.items() if w in MODULE_NAMED)
    lostm = sum(whym.values())
    namedm = sum(v for w, v in whym.items() if w in MODULE_NAMED)
    kanal = {}
    for w, v in hat.items():
        line = w.split(":")[1] if ":" in w else w
        ch = {"mod": "modul", "plat": "platform", "urun_disi": "urun_disi"}.get(
            line, "mevzuat" if line in ("ebelge", "kvkk") else "donem_hatti")
        kanal[ch] = kanal.get(ch, 0) + v
    tot0 = [k["tot0"] for k in ks]
    tot1 = [k["tot1"] for k in ks]
    return {"kayip_mrr_med": med(loss), "kayip_mrr_min": min(loss) if loss else float("nan"),
            "kayip_mrr_max": max(loss) if loss else float("nan"),
            "adli_pay": named / lost if lost else float("nan"),
            "adli_pay_urun_disi_haric": (named - why.get("urun_disi", 0)) / lost if lost else float("nan"),
            "adli_pay_mrr": namedm / lostm if lostm else float("nan"), "kanal": kanal,
            "bir_yildiz_kayip": sum(k["lost"][0] for k in ks) / max(1, sum(k["n0"][0] for k in ks)),
            "neden": why, "neden_mrr": whym, "neden_hat": hat, "kohort_hesap_med": med([sum(k["n0"]) for k in ks]),
            "kohort_mrr_med": med([k["m0"] for k in ks]),
            "toplam_mrr_degisim_med": med([b / a - 1 for a, b in zip(tot0, tot1) if a]),
            "ilgi_med": med([k["im"] for k in ks]), "yeni_imza_med": med([k["signed"] for k in ks]),
            "yildiz_kohort": [sum(k["n0"][s] for k in ks) for s in range(5)],
            "yildiz_kayip": [sum(k["lost"][s] for k in ks) for s in range(5)]}


def g2_cell(runs, end, C):
    g = [r[end]["s2"]["g2"] for r in runs]

    def firsts(k):
        xs = [x[k] for x in g if x[k] is not None]
        return med(xs), len(xs)
    return {"n": len(g), "erken_lider": _rate([x["erken_lider"] for x in g]),
            "erken_dev_modul": _rate([x["erken_dev_modul"] for x in g]),
            "gec_golge_son": _rate([x["gec_golge_son"] for x in g]),
            "gec_golge_herhangi": _rate([x["gec_golge_herhangi"] for x in g]),
            "gec_urun_son": _rate([x["gec_urun_son"] for x in g]),
            "ilk_dev_modul": firsts("ilk_dev_modul"), "ilk_lider_modul": firsts("ilk_lider_modul"),
            "ilk_golge_pay": firsts("ilk_golge_pay"),
            "son_golge_med": med([x["son_golge"] for x in g]), "son_golge_dev_med": med([x["son_golge_dev"] for x in g]),
            "son_bgl_med": med([x["son_bgl"] for x in g]), "son_nl": g[0]["son_nl"] if g else None,
            "son_ml_med": med([x["son_ml"] for x in g])}


def g2_gate(src, C, N, end, team):
    cells = {b: g2_cell(src[(N, b, str(team), 330)], end, C) for b in STRONG if (N, b, str(team), 330) in src}
    if not cells:
        return None
    runs = [r for b in STRONG for r in src.get((N, b, str(team), 330), [])]
    allc = g2_cell(runs, end, C)
    ok = {"erken": allc["erken_lider"] <= C["g2_erken_en_cok"], "gec": allc["gec_golge_son"] >= C["g2_gec_en_az"]}
    ok["hepsi"] = ok["erken"] and ok["gec"]
    return {"bot": cells, "guclu": allc, "ok": ok}


def price_cell(runs, end):
    f = [r[end]["s2"]["fiyat"] for r in runs]
    NP = len(f[0]["demo_mrr"])
    out = {"mrr_son": [med([x["mrr"][end][i] for x in f]) for i in range(NP)],
           "mrr_2020": [med([x["mrr"][2020][i] for x in f]) for i in range(NP)] if 2020 <= end else None,
           "demo_mrr": [med([x["demo_mrr"][i] for x in f]) for i in range(NP)]}
    exp, modx = [], []
    for i in range(NP):
        e, mo = [], []
        for x in f:
            d = x["defter"]
            base = d["yeni"][i] + d["gen_koltuk"][i] + d["gen_modul"][i]
            if base > 0:
                e.append((d["gen_koltuk"][i] + d["gen_modul"][i]) / base)
                mo.append(d["gen_modul"][i] / base)
        exp.append(med(e))
        modx.append(med(mo))
    out["genisleme_pay"], out["modul_genisleme_pay"] = exp, modx
    out["bes_n"] = sum(x["bes"][0]["n"] for x in f)
    out["bes_med"] = [med([x["bes"][i]["med"] for x in f if x["bes"][i]["n"]]) for i in range(NP)]
    out["bes_max"] = [max([x["bes"][i]["max"] for x in f if x["bes"][i]["n"]], default=float("nan")) for i in range(NP)]
    out["bes_seed_ustu_pay"] = [sum(x["bes"][i]["seed_ustu"] for x in f) / out["bes_n"] if out["bes_n"] else
                                float("nan") for i in range(NP)]
    shares = []
    for i in range(NP):
        per = []
        for x in f:
            tt = sum(x["yildiz"][i])
            if tt > 0:
                per.append([v / tt for v in x["yildiz"][i]])
        shares.append([med([p[s] for p in per]) for s in range(5)] if per else [float("nan")] * 5)
    out["yildiz_pay"] = shares
    return out


def rank_cell(runs, end):
    s = [r[end]["s2"]["sira"] for r in runs]
    yrs = s[0]["yil"]
    keys = ("mod_top3", "mod_odul", "mod_top3_kalabalik", "mod_odul_kalabalik", "kul_top3", "seg_top3", "prof_top3", "yuk_top3", "iyi_haber_genel", "iyi_haber",
            "kul_golge_top3")
    out = {k: med([x[k] for x in s]) / yrs for k in keys}
    out["kul_sira"] = {y: med([x["kul_sira"][y] for x in s]) for y in s[0]["kul_sira"]}
    out["kul_sira_golge"] = {y: med([x["kul_sira_golge"][y] for x in s]) for y in s[0]["kul_sira_golge"]}
    out["kul"] = {y: med([x["kul"][y] for x in s]) for y in s[0]["kul"]}
    out["dev_kul"] = {y: med([x["dev_kul"][y] for x in s]) for y in s[0]["dev_kul"]}
    out["yil"] = yrs
    return out


def sim2_report(agg, g1, C):
    """SIM2 kapıları ve probları: (ekran metni, JSON sözlüğü)."""
    PS, PB = agg["players"], agg["B"]
    ok = lambda b: "✅" if b else "❌"
    nan = float("nan")
    lines, data = [], {}
    P = lines.append
    ends = C["bitis_yillari"]

    data["g6"] = {f"{N}|{e}": g6_cells(PS, C, N, e) for N in NS for e in ends}
    P("\n## G6 · koltuk ve yıldız (ölçek 330; takım 25, 50, büyüyen; durgun dışı 5 bot; hücre aralığı)\n")
    P("| N | bitiş | koltuk değişen yenileme | yıldız değişimi en çok | 1★ büyüme en çok | 1.000'e dayanan yenileme | 1★ tutma | 5★ tutma (hücre) | kapı |")
    P("|---|---|---|---|---|---|---|---|---|")
    for N in NS:
        for e in ends:
            r = data["g6"][f"{N}|{e}"]
            if r:
                P(f"| {N} | {e} | %{fmt(r['koltuk'][0] * 100, 0)}-%{fmt(r['koltuk'][1] * 100, 0)} {ok(r['ok']['koltuk'])} | "
                  f"%{fmt(r['yildiz'] * 100, 1)} {ok(r['ok']['yildiz'])} | %{fmt(r['bir_buyume'] * 100, 1)} {ok(r['ok']['bir_buyume'])} | "
                  f"{r['bin_ustu_isteyen']} | %{fmt(r['tutma1'][0] * 100, 0)}-%{fmt(r['tutma1'][1] * 100, 0)} {ok(r['ok']['tutma1'])} | "
                  f"%{fmt(r['tutma5'][0] * 100, 0)}-%{fmt(r['tutma5'][1] * 100, 0)} ({r['tutma5_hucre']}) {ok(r['ok']['tutma5'])} | {ok(r['ok']['hepsi'])} |")

    data["g7"] = {f"{N}|{e}": g7_pool(PS, C, N, e) for N in NS for e in ends}
    P("\n## G7 · satış zarı (bütün kollar havuzlanmış; 'tam' = tam uyum)\n")
    P("| N | bitiş | yıldız | eşleşen ya da üstte satıcı (d≥0), tam uyum: gerçekleşen (n) | bir alt satıcı (d=-1) tam uyum (n) | alt / eşleşen | bütün anlaşmalar | tam uyum payı | ulaşılamayan aday |")
    P("|---|---|---|---|---|---|---|---|---|")
    for N in NS:
        for e in ends:
            g = data["g7"][f"{N}|{e}"]
            for x in g["yildiz"]:
                P(f"| {N} | {e} | {x['yildiz']}★ | %{fmt(x['esles_tam'] * 100, 1)} ({x['esles_tam_n']}) | "
                  f"%{fmt(x['alt_tam'] * 100, 1)} ({x['alt_tam_n']}) | {fmt(x['oran'], 2)} | %{fmt(x['hepsi'] * 100, 1)} ({x['hepsi_n']}) | "
                  f"%{fmt(x['tam_uyum_pay'] * 100, 0)} | {x['ulasilamadi']} |")
            P(f"| {N} | {e} | kapı | 1★ {ok(g['ok']['1yildiz'])}, 5★ {ok(g['ok']['5yildiz'])} | P en çok %{fmt(g['p_en_cok'] * 100, 0)} {ok(g['ok']['yuzde_yuz_yok'])} | "
              f"oran {ok(g['ok']['alt_oran'])} | bayat %{fmt(g['bayat'] * 100, 1)} {ok(g['ok']['bayat'])} (en kötü hücre %{fmt(g['bayat_en_kotu'] * 100, 1)}) | "
              f"kayıp: {', '.join(f'{k} {v}' for k, v in sorted(g['kayip_nedeni'].items(), key=lambda kv: -kv[1]))} | {ok(g['ok']['hepsi'])} |")

    P("\n## G4 · durgunluk (2015 başındaki portföy kohortu, 104 hafta; fiyat A)\n")
    P("| N | bot | takım | ölçek | MRR kaybı medyan (en az-en çok) | adlı (modül/rakip) pay: sayı / MRR | 1★ kaybı | kohort hesap / MRR | kanal (sayı) | toplam MRR değişimi | ilgi çarpanı | yeni imza | kapı |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    data["g4"] = {}
    for N in NS:
        for bot in ("durgun", "daginik", "odakli"):
            for tm in ("buyuyen", 1, 3, 6, 12, 25, 50):
                runs = PS.get((N, bot, str(tm), 330))
                if not runs or (bot != "durgun" and tm not in ("buyuyen", 50)):
                    continue
                c = g4_cell(runs, ends[0])
                gate = (c["kayip_mrr_med"] >= C["g4_kayip_en_az"] and c["adli_pay"] >= C["g4_adli_en_az"]
                        and c["bir_yildiz_kayip"] <= C["g4_bir_yildiz_en_cok"])
                c["ok"] = gate
                data["g4"][f"{N}|{bot}|{tm}"] = c
                P(f"| {N} | {bot} | {tm} | 330 | %{fmt(c['kayip_mrr_med'] * 100, 0)} (%{fmt(c['kayip_mrr_min'] * 100, 0)}-%{fmt(c['kayip_mrr_max'] * 100, 0)}) | "
                  f"%{fmt(c['adli_pay'] * 100, 0)} / %{fmt(c['adli_pay_mrr'] * 100, 0)} | %{fmt(c['bir_yildiz_kayip'] * 100, 0)} | {fmt(c['kohort_hesap_med'], 0)} / {fmt(c['kohort_mrr_med'], 0)} $ | "
                  f"{', '.join(f'{k} {v}' for k, v in sorted(c['kanal'].items(), key=lambda kv: -kv[1]))} | %{fmt(c['toplam_mrr_degisim_med'] * 100, 0)} | "
                  f"{fmt(c['ilgi_med'], 2)} | {fmt(c['yeni_imza_med'], 0)} | {ok(gate) if bot == 'durgun' else '(kontrol)'} |")
    data["g4_kapi"] = {}
    for N in NS:
        cells = [data["g4"].get(f"{N}|durgun|{tm}") for tm in G4_TEAMS]
        cells = [c for c in cells if c]
        data["g4_kapi"][N] = {
            "kayip": all(c["kayip_mrr_med"] >= C["g4_kayip_en_az"] for c in cells),
            "adli_sayi": all(c["adli_pay"] >= C["g4_adli_en_az"] for c in cells),
            "adli_mrr": all(c["adli_pay_mrr"] >= C["g4_adli_en_az"] for c in cells),
            "bir_yildiz": all(c["bir_yildiz_kayip"] <= C["g4_bir_yildiz_en_cok"] for c in cells)}
        k = data["g4_kapi"][N]
        k["hepsi"] = k["kayip"] and k["adli_sayi"] and k["bir_yildiz"]
        P(f"- G4 kapısı N={N} (durgun; takım {', '.join(map(str, G4_TEAMS))}): kayıp {ok(k['kayip'])}, adlı (sayı) {ok(k['adli_sayi'])}, "
          f"adlı (MRR) {ok(k['adli_mrr'])}, 1★ {ok(k['bir_yildiz'])} → {ok(k['hepsi'])}")

    P("\n## Demo (ilk 104 hafta): en az bir 4★ / 5★ hesap kapatan tohum payı (ölçek 330)\n")
    P("| N | bot | büyüyen | 1 | 3 | 6 | 12 | 25 | 50 |")
    P("|---|---|---|---|---|---|---|---|---|")
    data["demo"] = {}
    dw = C["demo_hafta"]
    for N in NS:
        for bot in BOTS:
            cells = []
            for tm in ("buyuyen", 1, 3, 6, 12, 25, 50):
                runs = PS.get((N, bot, str(tm), 330), [])
                f = [r[ends[0]]["s2"]["ilk_4_5"] for r in runs]
                v4 = _rate([x[0] is not None and x[0] < dw for x in f])
                v5 = _rate([x[1] is not None and x[1] < dw for x in f])
                cells.append(f"%{fmt(v4 * 100, 0)} / %{fmt(v5 * 100, 0)}")
                data["demo"][f"{N}|{bot}|{tm}"] = {"4": v4, "5": v5,
                                                    "ilk4_med": med([x[0] for x in f if x[0] is not None]),
                                                    "ilk5_med": med([x[1] for x in f if x[1] is not None])}
            P(f"| {N} | {bot} | " + " | ".join(cells) + " |")

    P("\n## Fiyat probu (Soru 8): A koltuk 50 $ · A+h hacim indirimi · B modül eki %15 · B+h (N, büyüyen takım ölçek 330; 50 kişi ölçek 600)\n")
    P("| N | bot | takım | ölçek | bitiş | son MRR A / A+h / B / B+h | genişleme payı A / B | modül genişlemesi B | 5★ hesap (n) MRR medyan A / A+h / B / B+h | 5★ en çok A / B+h | 5★ seed kapısını aşan A / A+h / B / B+h | MRR'de 1★-5★ payı (A) |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|")
    data["fiyat"] = {}
    for N in NS:
        for bot in GATE_BOTS:
            for tm, sc in (("buyuyen", 330), ("50", 600)):
                runs = PS.get((N, bot, tm, sc))
                if not runs:
                    continue
                for e in ends:
                    c = price_cell(runs, e)
                    data["fiyat"][f"{N}|{bot}|{tm}|{sc}|{e}"] = c
                    P(f"| {N} | {bot} | {tm} | {sc} | {e} | {' / '.join(fmt(v, 0) for v in c['mrr_son'])} | "
                      f"%{fmt(c['genisleme_pay'][0] * 100, 0)} / %{fmt(c['genisleme_pay'][2] * 100, 0)} | %{fmt(c['modul_genisleme_pay'][2] * 100, 0)} | "
                      f"({c['bes_n']}) {' / '.join(fmt(v, 0) for v in c['bes_med'])} | {fmt(c['bes_max'][0], 0)} / {fmt(c['bes_max'][3], 0)} | "
                      f"{' / '.join('%' + fmt(v * 100, 0) for v in c['bes_seed_ustu_pay'])} | "
                      f"{' · '.join('%' + fmt(v * 100, 0) for v in c['yildiz_pay'][0])} |")

    P("\n## G2 · dev geçilebilir ama geç; Soru 10 kolları (A: bilinen yol yok, B: bilinen yol ×0,8); güçlü botlar = odaklı, verimli, öncü; ölçek 330\n")
    P("| N | bitiş | takım | kol | erken (≤2017) modül lideri olan koşu | erken devi bir modülde geçen | sonda gölge payda devin önünde | 2022+ herhangi bir yıl önünde | sonda hatların ≥yarısında devin önünde | ilk dev-geçen modül yılı (koşu) | ilk modül liderliği yılı | ilk gölge pay liderliği yılı | sonda gölge pay oyuncu / dev | kapı |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    data["g2"] = {}
    for N in NS:
        for e in ends:
            for tm in B_TEAMS:
                for arm, src in (("A", PS), ("B", PB)):
                    gg = g2_gate(src, C, N, e, tm)
                    if not gg:
                        continue
                    data["g2"][f"{N}|{e}|{tm}|{arm}"] = gg
                    c = gg["guclu"]
                    P(f"| {N} | {e} | {tm} | {arm} | %{fmt(c['erken_lider'] * 100, 0)} | %{fmt(c['erken_dev_modul'] * 100, 0)} | "
                      f"%{fmt(c['gec_golge_son'] * 100, 0)} | %{fmt(c['gec_golge_herhangi'] * 100, 0)} | %{fmt(c['gec_urun_son'] * 100, 0)} | "
                      f"{fmt(c['ilk_dev_modul'][0], 0)} ({c['ilk_dev_modul'][1]}/{c['n']}) | {fmt(c['ilk_lider_modul'][0], 0)} ({c['ilk_lider_modul'][1]}) | "
                      f"{fmt(c['ilk_golge_pay'][0], 0)} ({c['ilk_golge_pay'][1]}) | %{fmt(c['son_golge_med'] * 100, 0)} / %{fmt(c['son_golge_dev_med'] * 100, 0)} | "
                      f"{ok(gg['ok']['hepsi'])} |")
    P("\nBot ayrıntısı (büyüyen takım, N=10): erken lider / sonda gölge önde / ilk gölge yılı")
    for e in ends:
        for arm in ("A", "B"):
            gg = data["g2"].get(f"10|{e}|buyuyen|{arm}")
            if gg:
                P(f"- {e} {arm}: " + "; ".join(f"{b} %{fmt(c['erken_lider'] * 100, 0)} / %{fmt(c['gec_golge_son'] * 100, 0)} / "
                                              f"{fmt(c['ilk_golge_pay'][0], 0)}" for b, c in gg["bot"].items()))

    if agg["g1B"]:
        g1b = g1_summary({"g1": agg["g1B"]}, C)
        data["g1_B"] = g1b
        P("\n## G1 bilinen yol kolunda (B dünyaları: oyuncuyla birlikte yürüyen 8 bot x takım dünyası, medyan)\n")
        P("| N | bitiş | kapı | modül medyanı tavana <1 yıl | dev >%60 tavanda yıl | S artış/yıl | son yıl tavana kalan | (A kolu: S artış/yıl, son yıl tavana kalan) |")
        P("|---|---|---|---|---|---|---|---|")
        for N in NS:
            if N not in g1b:
                continue
            for e in ends:
                r, ra = g1b[N][e], g1[N][e]
                P(f"| {N} | {e} | {ok(r['ok'])} | {len(r['fail_years'])}: {span(r['fail_years'])} | {len(r['dev_fail_years'])}: "
                  f"{span(r['dev_fail_years'])} | {fmt(r['S_yillik_artis'])} | {fmt(r['son_fark'])} | {fmt(ra['S_yillik_artis'])}, {fmt(ra['son_fark'])} |")

    P("\n## Sıralama probu (Soru 4): yılların payı (2013-bitiş), büyüyen takım, ölçek 330\n")
    P("| N | bitiş | bot | modül top-3 (kalabalık liste) | modül ödülü (kalabalık) | kullanıcı top-3 | büyüklük sınıfı top-3 | profil top-3 | yükselen top-3 | iyi haber: modül + genel liste | iyi haber: + kategoriler | kullanıcı sırası 2015 / 2020 / 2025 / 2030 / 2035 | oyuncu / dev kullanıcı (son yıl) | gölge kullanıcı sırası (aynı yıllar) · top-3 yıl payı |")
    P("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
    data["siralama"] = {}
    for N in NS:
        for e in ends:
            for bot in BOTS:
                runs = PS.get((N, bot, "buyuyen", 330))
                if not runs:
                    continue
                c = rank_cell(runs, e)
                data["siralama"][f"{N}|{e}|{bot}"] = c
                P(f"| {N} | {e} | {bot} | %{fmt(c['mod_top3'] * 100, 0)} (%{fmt(c['mod_top3_kalabalik'] * 100, 0)}) | "
                  f"%{fmt(c['mod_odul'] * 100, 0)} (%{fmt(c['mod_odul_kalabalik'] * 100, 0)}) | %{fmt(c['kul_top3'] * 100, 0)} | "
                  f"%{fmt(c['seg_top3'] * 100, 0)} | %{fmt(c['prof_top3'] * 100, 0)} | %{fmt(c['yuk_top3'] * 100, 0)} | "
                  f"%{fmt(c['iyi_haber_genel'] * 100, 0)} | %{fmt(c['iyi_haber'] * 100, 0)} | "
                  f"{' / '.join(fmt(c['kul_sira'].get(y, nan), 0) for y in (2015, 2020, 2025, 2030, 2035) if y <= e)} | "
                  f"{fmt(c['kul'][e], 0)} / {fmt(c['dev_kul'][e], 0)} | "
                  f"{' / '.join(fmt(c['kul_sira_golge'].get(y, nan), 0) for y in (2015, 2020, 2025, 2030, 2035) if y <= e)}"
                  f" · %{fmt(c['kul_golge_top3'] * 100, 0)} |")
    return "\n".join(lines), data


def sim3_report(agg, C, ham=False):
    """SIM3 ölçüleri: G3 öncülük, G9 ölü bölge, demo temposu (ve isteğe bağlı tohum başına ham fiyat/MRR)."""
    PS = agg["players"]
    nan = float("nan")
    lines, data = [], {"g3": {}, "g9": {}, "tempo": {}}
    P = lines.append
    ends = C["bitis_yillari"]
    Etab = effort_table(C)
    e3 = sum(Etab[1:4])
    giant = "datenwald"

    mev = {e["id"] for e in load("eras.json")["donem_hatlari"] if e["tur"] == "mevzuat"}
    P("\n## G3 · öncülük: dönem hatlarında ilk K1 (ölçek 330; oyuncu dünyadan SIKI önce; tohum medyanı); hepsi / yalnız teknoloji hatları (mevzuat hariç)\n")
    P("| N | bitiş | bot | takım | açık hat (hepsi / teknoloji) | oyuncu önce (hepsi / teknoloji) | aynı hafta (hepsi / teknoloji) | önce payı (hepsi / teknoloji) | devin ilk olduğu hat payı, dünya (hepsi / teknoloji) |")
    P("|---|---|---|---|---|---|---|---|---|")
    for N in NS:
        for e in ends:
            w1 = weeks_to_end(e)
            opn = devf = opt = devt = 0
            for fk in agg["first_k1"].get(N, []):
                for _id, (wk, who, ow) in fk.items():
                    if ow < w1:
                        isd = wk is not None and wk < w1 and who == giant
                        opn += 1
                        devf += isd
                        if _id not in mev:
                            opt += 1
                            devt += isd
            dshare = devf / opn if opn else nan
            dsh_t = devt / opt if opt else nan
            for bot in BOTS:
                for tm in ("buyuyen", 50):
                    runs = PS.get((N, bot, str(tm), 330))
                    if not runs:
                        continue
                    g = [r[e]["s2"]["g3"] for r in runs]

                    def cnt(x, tech):
                        rows = [v for k, v in x["hat"].items() if (k not in mev) or not tech]
                        pw = [r_[0] for r_ in rows]
                        ww = [r_[1] for r_ in rows]
                        onc = sum(1 for p_, w_ in zip(pw, ww) if p_ is not None and (w_ is None or p_ < w_))
                        es = sum(1 for p_, w_ in zip(pw, ww) if p_ is not None and p_ == w_)
                        return len(rows), onc, es
                    allc = [cnt(x, False) for x in g]
                    tec = [cnt(x, True) for x in g]
                    sh = med([c[1] / c[0] for c in allc if c[0]])
                    sht = med([c[1] / c[0] for c in tec if c[0]])
                    data["g3"][f"{N}|{e}|{bot}|{tm}"] = {
                        "acik": med([c[0] for c in allc]), "ilk": med([c[1] for c in allc]), "esit": med([c[2] for c in allc]),
                        "pay": sh, "dev_pay": dshare, "acik_tek": med([c[0] for c in tec]), "ilk_tek": med([c[1] for c in tec]),
                        "esit_tek": med([c[2] for c in tec]), "pay_tek": sht, "dev_pay_tek": dsh_t}
                    P(f"| {N} | {e} | {bot} | {tm} | {fmt(med([c[0] for c in allc]), 0)} / {fmt(med([c[0] for c in tec]), 0)} | "
                      f"{fmt(med([c[1] for c in allc]), 0)} / {fmt(med([c[1] for c in tec]), 0)} | "
                      f"{fmt(med([c[2] for c in allc]), 0)} / {fmt(med([c[2] for c in tec]), 0)} | "
                      f"%{fmt(sh * 100, 0)} / %{fmt(sht * 100, 0)} | %{fmt(dshare * 100, 0)} / %{fmt(dsh_t * 100, 0)} |")

    P("\n## G9 · ölü bölge: yılda 1★-2★ aday (kazanılabilir = en iyi satıcıyla kapanış >= eşik) ve imzalanan; ölçek 330, 2016-bitiş yılı arası en düşük yıl (tohum medyanı)\n")
    P("| N | bitiş | bot | takım | gelen 1★-2★ aday/yıl (en düşük yıl) | kazanılabilir/yıl (en düşük yıl) | p>=0,5/yıl (en düşük yıl) | imzalanan 1★-2★/yıl (en düşük yıl) |")
    P("|---|---|---|---|---|---|---|---|")
    for N in NS:
        for e in ends:
            for bot in ("durgun", "daginik", "odakli"):
                for tm in ("buyuyen", 1, 25, 50):
                    runs = PS.get((N, bot, str(tm), 330))
                    if not runs:
                        continue
                    yrs = [y for y in range(2016, e + 1)]
                    per = {}
                    for y in yrs:
                        vals = [[sum(r[e]["s2"]["g9"][y][st][i] for st in (0, 1)) for i in range(4)] for r in runs]
                        per[y] = [med([v[i] for v in vals]) for i in range(4)]
                    mn = [min(per[y][i] for y in yrs) for i in range(4)]
                    data["g9"][f"{N}|{e}|{bot}|{tm}"] = {"min": mn, "yil": per}
                    P(f"| {N} | {e} | {bot} | {tm} | {fmt(mn[0], 0)} | {fmt(mn[1], 0)} | {fmt(mn[2], 0)} | {fmt(mn[3], 0)} |")

    P("\n## Tempo: demo temposu (ilk 52 ve 104 hafta; ölçek 330; tohum medyanı; K3 kapasitesi = toplam etkin puan / (K1+K2+K3 eforu))\n")
    P(f"(K1+K2+K3 eforu = {fmt(e3, 1)} puan)\n")
    P("| N | bot | takım | ilk K1 hafta | ilk K2 hafta | ilk K3 hafta | 52. hafta: modül K1 / K2 / K3 | 104. hafta: modül K1 / K2 / K3 (en üst kademe) | 104. hafta etkin puan | K3 kapasitesi (modül) |")
    P("|---|---|---|---|---|---|---|---|---|---|")
    for N in NS:
        for bot in BOTS:
            for tm in (1, 3, 6, "buyuyen", 50):
                runs = PS.get((N, bot, str(tm), 330))
                if not runs:
                    continue
                t_ = [r[ends[0]]["s2"]["tempo"] for r in runs]

                def fk(k):
                    xs = [x["k_hafta"][k] for x in t_ if x["k_hafta"][k] is not None]
                    return (med(xs), len(xs))

                def an(w, f):
                    return med([x["an"][w][f] for x in t_ if w in x["an"]])
                row = {"k1": fk(0), "k2": fk(1), "k3": fk(2),
                       "a52": [an(52, "k1"), an(52, "k2"), an(52, "k3")],
                       "a104": [an(104, "k1"), an(104, "k2"), an(104, "k3"), an(104, "en_ust")],
                       "puan104": an(104, "puan"), "puan52": an(52, "puan")}
                row["k3_kapasite"] = row["puan104"] / e3
                data["tempo"][f"{N}|{bot}|{tm}"] = row
                P(f"| {N} | {bot} | {tm} | {fmt(row['k1'][0], 0)} ({row['k1'][1]}/{len(t_)}) | {fmt(row['k2'][0], 0)} ({row['k2'][1]}) | "
                  f"{fmt(row['k3'][0], 0)} ({row['k3'][1]}) | {fmt(row['a52'][0], 0)} / {fmt(row['a52'][1], 0)} / {fmt(row['a52'][2], 0)} | "
                  f"{fmt(row['a104'][0], 0)} / {fmt(row['a104'][1], 0)} / {fmt(row['a104'][2], 0)} (K{fmt(row['a104'][3], 0)}) | "
                  f"{fmt(row['puan104'], 0)} | {fmt(row['k3_kapasite'], 1)} |")
    if ham:
        e0 = ends[0]
        data["ham"] = {"|".join(map(str, k)): [{"mrr": {str(y): r[e0]["s2"]["fiyat"]["mrr"][y] for y in (2020, e0) if y <= e0},
                                                 "hesap": r[e0]["hesap_ort"], "dolum": r[e0]["dolum"],
                                                 "imza": r[e0]["s2"]["imza_yil"].get(e0),
                                                 "ornek": r[e0]["s2"]["fiyat"]["ornek"][:3]} for r in runs]
                       for k, runs in PS.items() if k[3] in (330, 600)}
    return "\n".join(lines), data


def span(ys):
    if not ys:
        return "-"
    parts, a, b = [], ys[0], ys[0]
    for y in ys[1:]:
        if y == b + 1:
            b = y
        else:
            parts.append(f"{a}" if a == b else f"{a}-{b}")
            a = b = y
    parts.append(f"{a}" if a == b else f"{a}-{b}")
    return ", ".join(parts)


def jsonable(o):
    if isinstance(o, dict):
        return {(k if isinstance(k, str) else "|".join(map(str, k)) if isinstance(k, tuple) else str(k)): jsonable(v)
                for k, v in o.items()}
    if isinstance(o, (list, tuple)):
        return [jsonable(x) for x in o]
    if isinstance(o, float) and math.isnan(o):
        return None
    return o


def main():
    ap = argparse.ArgumentParser(description="Pazar 2 SIM1 + SIM2")
    ap.add_argument("--mod", choices=["g1", "tam", "sim2"], default="tam")
    ap.add_argument("--tohum", type=int)
    ap.add_argument("--isci", type=int, default=max(1, min(6, (os.cpu_count() or 2) - 2)))
    ap.add_argument("--ayar", action="append", default=[], help="sabit=deger (JSON değer)")
    ap.add_argument("--ek", default="", help="SIM3: sim2.json'un üstüne uygulanacak ek katman dosyaları (virgüllü, ör. sim3.json)")
    ap.add_argument("--N", default=None, help="SIM3: virgüllü N listesi (varsayılan 5,7,10)")
    ap.add_argument("--olcek", default=None, help="SIM3: virgüllü hesap ölçekleri (varsayılan hepsi)")
    ap.add_argument("--bot", default=None, help="SIM3: virgüllü bot listesi (varsayılan hepsi)")
    ap.add_argument("--takim", default=None, help="SIM3: virgüllü takım kolları (ör. buyuyen,25,50)")
    ap.add_argument("--bkolu-yok", action="store_true", help="SIM3: bilinen yol B kolunu koşma (Erdem 31 ile düştü)")
    ap.add_argument("--ham", action="store_true", help="SIM3: tohum başına ham ölçüleri JSON'a yaz (fiyat kapısı, tempo)")
    ap.add_argument("--cikti", default=None, help="sonuç JSON'u (varsayılan out/tur2/sim1_sonuc.json ya da sim2_sonuc.json)")
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8")
    overrides = {}
    for kv in a.ayar:
        k, v = kv.split("=", 1)
        overrides[k] = json.loads(v)
    overlay = (["sim2.json"] + a.ek.split(",")) if a.mod == "sim2" else None
    D = load_all(overrides, overlay)
    C = D["C"]
    seeds = a.tohum or C["tohum"]
    t0 = time.perf_counter()
    flt = {"N": [int(x) for x in a.N.split(",")] if a.N else None,
           "olcek": [int(x) for x in a.olcek.split(",")] if a.olcek else None,
           "bot": a.bot.split(",") if a.bot else None,
           "takim": [x if x == "buyuyen" else int(x) for x in a.takim.split(",")] if a.takim else None,
           "bkolu_yok": a.bkolu_yok}
    tasks = [(N, s, sc, combos, arm, overrides, overlay) for N, s, sc, combos, arm in task_list(C, a.mod, seeds, flt)]
    tasks.sort(key=lambda x: x[4] != "B")
    with Pool(a.isci) as pool:
        results = list(pool.imap_unordered(worker, tasks))
    results.sort(key=lambda r: (r["N"], r["seed"], r["scale"], r["arm"]))
    agg = aggregate(results, C)
    g1 = g1_summary(agg, C)
    ps = player_summary(agg, C)
    elapsed = time.perf_counter() - t0
    print(print_tables(g1, ps, C, D, elapsed))
    print(f"\nG8 ihlali: {len(agg['g8'])}" + ("".join("\n  " + x for x in agg["g8"][:20])))
    print(f"rakip adımı: hafta başına işlem medyanı {med(agg['ops_per_week']):.0f}, dünya süresi medyanı {med(agg['world_s']):.2f} sn")
    if a.mod == "sim2":
        text, data = sim2_report(agg, g1, C)
        print(text)
        t3, d3 = sim3_report(agg, C, a.ham)
        print(t3)
        data.update(d3)
        path = a.cikti or os.path.join(OUT, "sim2_sonuc.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(jsonable({"ayar": overrides, "katman": {k: v for ov in overlay for k, v in load(ov).items()}, "tohum": seeds, "sure_sn": elapsed,
                                "g1": g1, "g5_kapi": {f"{N}|{e}": g5_gate(ps, C, N, e) for N in NS
                                                     for e in C["bitis_yillari"]},
                                "g10": g10_rows(ps, C), "g8": agg["g8"], **data}), f, ensure_ascii=False, indent=1)
        print(f"yazıldı: {path}")
    if a.mod == "tam":
        path = a.cikti or os.path.join(OUT, "sim1_sonuc.json")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(jsonable({"ayar": overrides, "tohum": seeds, "sure_sn": elapsed, "g1": g1,
                                "g5_kapi": {f"{N}|{e}": g5_gate(ps, C, N, e) for N in NS for e in C["bitis_yillari"]},
                                "g10": g10_rows(ps, C), "soru23": soru23(g1, ps, C, D),
                                "oyuncu": {"|".join(map(str, k)): v for k, v in ps.items()},
                                "g8": agg["g8"], "ilk_k1": agg["first_k1"], "olaylar": agg["events"],
                                "rakip_islem_hafta": med(agg["ops_per_week"])}), f, ensure_ascii=False, indent=1)
        print(f"yazıldı: {path}")


if __name__ == "__main__":
    main()
