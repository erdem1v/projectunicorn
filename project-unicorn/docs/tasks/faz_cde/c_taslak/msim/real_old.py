"""K5'in GERCEK eski-model kayitlari (kod + gizli eksen) uzerinde olcumler. python -I."""
import sys, os, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import k5, bot

def nedensiz(run):
    """Gercek seride: dusus = sat[d] <= sat[d-1]-1. Adli olay (siki): hesabin kendi acik hata sayisi o gun degisti, soz sonuclandi, istek teslim edildi.
    Genis: + o gun bir surum yayinlandi (PROBE SHIP)."""
    prom = {}
    for d, c, stt in run["promise"]:
        prom.setdefault(c, set()).add(d)
    ps = k5.product_series(run, 104)
    reqd = {}
    for t in range(1, 105):
        for c in ps[t]["reqs"]:
            reqd.setdefault(c, set()).add(t)
    strict = generous = drops = 0
    big_first = []     # imza haftasindan 4. haftaya kadar dusus
    for cid, c in run["cust"].items():
        ds = sorted(c)
        for i in range(1, len(ds)):
            d0, d1 = ds[i - 1], ds[i]
            if d1 != d0 + 1: continue
            if c[d1]["sat"] <= c[d0]["sat"] - 1:
                drops += 1
                named_s = (c[d1]["bugs"] != c[d0]["bugs"]) or (d1 in prom.get(cid, ())) or (d1 in reqd.get(cid, ()))
                if not named_s: strict += 1
                if not (named_s or d1 in run["ship_days"]): generous += 1
    return drops, strict, generous

def first_weeks(run):
    """Imza degeri ile 1., 4. hafta arasindaki fark."""
    d1 = []; d4 = []; first_drop_ge5 = 0; n = 0
    for s in run["sign"]:
        c = run["cust"].get(s["id"])
        if not c: continue
        t0 = s["day"]
        if t0 not in c or t0 + 1 not in c: continue
        n += 1
        d1.append(c[t0 + 1]["sat"] - c[t0]["sat"])
        if t0 + 4 in c: d4.append(c[t0 + 4]["sat"] - c[t0]["sat"])
        if c[t0 + 1]["sat"] - c[t0]["sat"] <= -5: first_drop_ge5 += 1
    return n, d1, d4, first_drop_ge5

def validate(run):
    """Kopya dogrulamasi: kayittaki hedef (target), guven (trust) ve esik (tol) ile ESKI kaymayi yeniden calistir:
    sat[d+1] = sat[d] + clamp(target[d+1] - sat[d], -dn, +up); up/dn = 21 (ilk 4 hafta 35). Sapma yuzdesi."""
    ok = tot = 0; err = []
    signs = {s["id"]: s["day"] for s in run["sign"]}
    for cid, c in run["cust"].items():
        for d in sorted(c):
            if d + 1 not in c or cid not in signs: continue
            if c[d]["phase"] == "churning": continue
            t = d + 1
            step = 5 if t < signs[cid] + 4 else 3
            gap = c[t]["target"] - c[d]["sat"]
            pred = c[d]["sat"] + max(-step * 7, min(step * 7, gap))
            tot += 1
            if pred == c[t]["sat"]: ok += 1
            else: err.append(pred - c[t]["sat"])
    return ok, tot, err

if __name__ == "__main__":
    for arm in bot.ARMS:
        for seed in bot.SEEDS:
            run = k5.load(bot.run_name(arm, seed))
            dr, s, g = nedensiz(run)
            n, d1, d4, fd = first_weeks(run)
            ok, tot, err = validate(run)
            print(arm, seed, "drops", dr, "nedensiz siki", s, "genis", g, "| n", n, "d1 ort", round(sum(d1)/len(d1),1), "d4 ort", round(sum(d4)/max(1,len(d4)),1), "ilk hafta >=5 dusen", fd, "| kopya", ok, tot, round(100*ok/tot,1), "hata ort", round(sum(err)/max(1,len(err)),1) if err else 0)
