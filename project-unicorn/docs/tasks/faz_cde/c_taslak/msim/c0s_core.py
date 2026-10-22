"""C0s ortak boru hatti: bot kosusu -> dunya -> hesaplar -> C modeli. python -I."""
import sys, os, random, zlib, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_data as D, c0s_model as M

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
os.makedirs(OUT, exist_ok=True)
T_BOT = 104
V1 = 7
EARLY = 20
LABEL = {"none": "hiç düzeltmeyen (none)", "worst": "en kötüsünü düzelten (worst)", "due": "vadesi gelen düzelten (due)", "off": "hata bedeli kapalı (off)"}

_world_cache = {}


def get_run(name, base=D.K9):
    return D.load(name, base)


def get_world(name, base=D.K9):
    k = (name, base)
    if k not in _world_cache:
        _world_cache[k] = D.world(get_run(name, base), T_BOT)
    return _world_cache[k]


def accounts_of(run, seed):
    return [M.Acct(s["id"], s["day"], s["star"], s["sector"], s["mrr"], by=s["by"], seed=seed) for s in run["sign"]]


def events_for(run, seed, three_star_promises=True, accts=None):
    """Gercek olaylar: kesinti (PROBE FIRE, saat 3-8 tekduze VARSAYIM: logda saat yok), soz sonuclari (PROBE PROMISE resolved).
    C-dunyasi: istek karti yalniz 3 yildiz hesaptan gelir (Karar 11), bu yuzden soz olaylari yalniz 3 yildiz hesaplara uygulanir."""
    rng = random.Random(zlib.crc32(("ev|%s|%d" % (run["name"], seed)).encode()))
    ev = {"outage": [], "promise": {}, "card": []}
    for (day, hour, fid) in run["fire"]:
        if fid == "product.incident_outage_b2b":
            ev["outage"].append((day, rng.uniform(3, 8)))
    star = {s["id"]: s["star"] for s in run["sign"]}
    for (day, cust, status) in run["promise"]:
        if three_star_promises and star.get(cust, 0) != 3:
            continue
        ev["promise"].setdefault(cust, []).append((day, "kept" if status == "kept" else "broken"))
    return ev


def run_accounts(name, c, base=D.K9, seed=None, gate=True, three_star_promises=True, policy="best", bugs_free=None, mutate=None):
    """Bir kosunun butun hesaplarini C modeliyle yurutur. Don: (sonuclar {id: sim}, hesaplar, kosu, dunya)."""
    run = get_run(name, base)
    seed = int(name.rsplit("_", 1)[1]) if seed is None else seed
    w = get_world(name, base)
    free = (name.startswith("full_run_fix_off") or name.startswith("full_run_b2c_fix_off")) if bugs_free is None else bugs_free
    accts = accounts_of(run, seed)
    if mutate:
        mutate(accts)
    ev = events_for(run, seed, three_star_promises)
    res = {}
    for a in accts:
        res[a.id] = M.simulate(a, w, c, events=ev, bugs_free=free, gate=gate, policy=policy)
    return res, accts, run, w


def loss_stats(res, accts, v1=V1, T=T_BOT):
    """A'nin tanimi (fix_tables.py:10,26): erken = v1.0'dan sonraki ilk 20 hafta; gec = sonrasi; yuzde = kayip / (kayip + donem sonu ayakta).
    Kayip = ayrilma haftasi (sozlesme sonu dahil) ; reddedilen aday sayilmaz."""
    sign = {a.id: a.sign for a in accts}
    ids = [i for i, r in res.items() if not r["rejected"]]
    cut = v1 + EARLY
    lost_cut = sum(1 for i in ids if res[i]["left"] is not None and res[i]["left"] <= cut)
    alive_cut = sum(1 for i in ids if sign[i] <= cut and not (res[i]["left"] is not None and res[i]["left"] <= cut))
    lost_T = sum(1 for i in ids if res[i]["left"] is not None and res[i]["left"] <= T)
    alive_T = sum(1 for i in ids if not (res[i]["left"] is not None and res[i]["left"] <= T))
    late = lost_T - lost_cut
    return {"n": len(ids), "early": lost_cut, "early_pct": 100.0 * lost_cut / max(1, lost_cut + alive_cut), "late": late,
            "late_pct": 100.0 * late / max(1, late + alive_T), "total": lost_T, "total_pct": 100.0 * lost_T / max(1, len(ids)),
            "risk": sum(1 for i in ids if res[i]["left_why"] == "risk" and res[i]["left"] <= T)}


def pct(a, b):
    return 100.0 * a / b if b else float("nan")


def fmt(x, d=1):
    return "-" if x is None or x != x else ("%.*f" % (d, x))
