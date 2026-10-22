# D0t.2 ek kollar (E1 icin): sim_g0.py ciktilarindan kol x ekip tablolari. Calistirma:  python -I ozet_ek.py > out/ek_sim.md
# Kollar: (a) kesik yok q=0,75 | (a') kesik yok q=0,9 | (c) bonus kesik disinda, alan %95'te kapanir q=0,75 | (c') ayni q=0,9 | tavan 8 q=0,75.
import os, sys, pickle, statistics, math
sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
TEAMS = [("S1", 1), ("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)]
NAMES = [8, 8, 8, 8, 8, 8, 8, 9, 8]    # sim hatlari: Cekirdek 0-4, Onboarding 5, Entegrasyonlar 6, Guvenlik 7, Dayaniklilik 8; her hatta uc urunun en az adi (Wa_ADLAR.json)
# (etiket, tag, varyant, azalma q)
ARMS = [
    ("(a) D0s tabanı: kesik yok, q 0,75 (dsim3'ün kendi alan eşlemesi)", "main", "orig", 0.75),
    ("(a) kesik yok, q 0,75 (gerçek alan eşlemesi)", "main", "map", 0.75),
    ("(a') kesik yok, q 0,9", "ek09", "map", 0.9),
    ("(c) bonus kesik dışı, alan %95'te kapanır, q 0,75", "main", "sat:0.95", 0.75),
    ("(c') aynısı, q 0,9", "ek09", "sat:0.95", 0.9),
    ("tavan 8/alan, q 0,75", "main", "ser:8", 0.75),
    ("(c) rezerv sayımlı: açılan kart 11/alan, q 0,75", "main", "ser:11", 0.75),
    ("(c') rezerv sayımlı: açılan kart 29/alan, q 0,9", "ek09", "ser:29", 0.9),
    ("Karar 13 olduğu gibi: kesik 3★, g₀ 0,25, q 0,75", "main", "cut3:0.25", 0.75),
]


def load(tag, v, s):
    f = os.path.join(HERE, "out", tag, v.replace(":", "_") + "__DEP_" + s + ".pkl")
    return pickle.load(open(f, "rb"))


def tr(x, d=1):
    return ("%." + str(d) + "f") % x if x is not None else "—"


def trc(x, d=1):
    return tr(x, d).replace(".", ",")


med = statistics.median


def table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "|".join(["---"] * len(head)) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c) for c in r) + " |")
    return "\n".join(out)


def sec(name, body):
    print("<!-- T:%s -->" % name)
    print(body)
    print("<!-- /T:%s -->\n" % name)


def kval(q):                                # g0 x q^(k-1) > g0 / 20  <=>  k <= K
    k = 1
    while q ** k > 0.05:
        k += 1
    return k


def metric(name, fn, fmt):
    rows = []
    for lab, tag, v, q in ARMS:
        row = [lab]
        for s, n in TEAMS:
            d = load(tag, v, s)
            row.append(fmt(med([fn(m, q) for m in d.values()])))
        rows.append(row)
    sec(name, table(["Kol (20 tohum, medyan)"] + ["%d kişi" % n for s, n in TEAMS], rows))


metric("E_teslim", lambda m, q: m["deliv"], lambda x: trc(x))
metric("E_bosta", lambda m, q: 100 * m["idle_pct"], lambda x: "%s%%" % trc(x, 0))
metric("E_acilan", lambda m, q: sum(m["depth_seq"]), lambda x: trc(x, 0))
metric("E_biten", lambda m, q: sum(m["depth_area"]), lambda x: trc(x, 0))
metric("E_deger", lambda m, q: 100 * sum(min(f, kval(q)) for f in m["depth_area"]) / max(1, sum(m["depth_area"])), lambda x: "%s%%" % trc(x, 0))
metric("E_bilesik", lambda m, q: (1 - m["idle_pct"]) * sum(min(f, kval(q)) for f in m["depth_area"]) / max(1, sum(m["depth_area"])), lambda x: trc(x, 2))
metric("E_satir", lambda m, q: max(m["depth_seq"]), lambda x: trc(x, 0))
metric("E_eksik", lambda m, q: sum(max(0, c - nm) for c, nm in zip(m["depth_seq"], NAMES)), lambda x: trc(x, 0))
print("<!-- K: q=0,75 -> %d, q=0,9 -> %d -->" % (kval(0.75), kval(0.9)))
