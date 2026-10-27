# D0t.2 ek kollar: tipik bir 3★ hesabin ürün uyumu U'sunun Çekirdek derinlik kartlariyla degisimi. Q'nun fit_from_levels'i (910ad1f pq:268-297) birebir.
# Calistirma:  python -I ek_u.py > out/ek_u.md   (Godot yok)
import sys, math
sys.stdout.reconfigure(encoding="utf-8")
CAP, CORE_LEAD, FIT_SCALE = 1.5, 0.25, 70.0                       # pq:13, :15, :12
# 3★ hesap, sektor "technology" (pq:57): vurgu 1 Entegrasyonlar, vurgu 2 Guven & Olcek, kalan Onboarding. Agirlik pq:16-18, beklenti 3★ pq:39-41.
AREAS = ["core", "integrations", "trust", "onboarding"]
W = {"core": 0.50, "integrations": 0.25, "trust": 0.15, "onboarding": 0.10}
E = {"core": 2.0, "integrations": 1.5, "trust": 1.5, "onboarding": 1.0}
STATES = {
    "B": ("Çekirdek geride: 1 hat K3 + 4 hat K2 (2,20), öteki alanlar K2 (2,0)", {"core": 2.2, "integrations": 2.0, "trust": 2.0, "onboarding": 2.0}),
    "E": ("Çekirdek doymuş: 5 hat K3 (3,0), öteki alanlar K1 (1,0)", {"core": 3.0, "integrations": 1.0, "trust": 1.0, "onboarding": 1.0}),
    "F": ("Her alan K3 (3,0)", {a: 3.0 for a in AREAS}),
}


def roundi(x):
    return int(math.floor(x + 0.5))


def U(levels, bonus, mode):
    """mode 'in': kazanc seviyeye eklenir, oran 1,5'te kesilir (Q'nun bugunku kurali). mode 'out': oran tabandan kesilir, kazanc kesikten sonra eklenir."""
    r = {}
    for a in AREAS:
        b = bonus.get(a, 0.0)
        r[a] = min((levels[a] + b) / E[a], CAP) if mode == "in" else min(levels[a] / E[a], CAP) + b / E[a]
    mean = sum(W[a] * r[a] for a in AREAS) / sum(W.values())
    ceil = r["core"] + CORE_LEAD
    return min(100, roundi(FIT_SCALE * min(mean, ceil))), FIT_SCALE * min(mean, ceil)


def gain(g0, q, n):
    return g0 * (1 - q ** n) / (1 - q)


def tr(x, d=1):
    return ("%." + str(d) + "f") % x


def trc(x, d=1):
    return tr(x, d).replace(".", ",")


def table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "|".join(["---"] * len(head)) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c) for c in r) + " |")
    return "\n".join(out)


def sec(name, body):
    print("<!-- T:%s -->" % name)
    print(body)
    print("<!-- /T:%s -->\n" % name)


def nsat(q, share=0.95):
    return math.ceil(math.log(1 - share) / math.log(q) - 1e-9)


ARMS = [("(a)", 0.25, 0.75, "in", None), ("(c)", 0.25, 0.75, "out", None), ("(c')", 0.25, 0.9, "out", None), ("(c') g₀ 0,1", 0.10, 0.9, "out", None)]
NS = [0, 1, 2, 3, 5, 8, 11, 29]
for key in ("B", "E", "F"):
    lab, lv = STATES[key]
    head = ["Çekirdek derinlik kartı sayısı"]
    for nm, g0, q, mode, _ in ARMS:
        head.append("%s: U" % nm)
    rows = []
    for n in NS:
        row = [n]
        for nm, g0, q, mode, _ in ARMS:
            ne = n if mode == "in" else min(n, nsat(q))          # (c) kollarinda alan %95'te kapanir
            u, raw = U(lv, {"core": gain(g0, q, ne)}, mode)
            row.append("%d" % u)
        rows.append(row)
    sec("U_" + key, "**%s**\n\n" % lab + table(head, rows))

# kart basina marjinal U (state B ve E, ilk / 5. kart, doygunluk toplami)
rows = []
for key in ("B", "E"):
    lab, lv = STATES[key]
    for nm, g0, q, mode, _ in ARMS:
        base = U(lv, {}, mode)[1]
        def raw(n):
            ne = n if mode == "in" else min(n, nsat(q))
            return U(lv, {"core": gain(g0, q, ne)}, mode)[1]
        sat = nsat(q) if mode == "out" else 29
        rows.append([key, nm, trc(raw(1) - base), trc(raw(5) - raw(4)), "%d kart" % sat, trc(min(100.0, raw(sat)) - min(100.0, base)), trc(base) + " → " + trc(min(100.0, raw(sat)))])
sec("U_ozet", table(["Durum", "Kol", "İlk kartın ΔU'su (ham)", "5. kartın ΔU'su (ham)", "Doygunluk", "Doygunlukta toplam ΔU (U 100'e kesik)", "U (ham): önce → doygunluk"], rows))
