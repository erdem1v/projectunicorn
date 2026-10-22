# D0t.2 · g0 analitik tablolari. Godot yok, oyun dosyasi yok; sabitler 910ad1f'ten (satir numaralari D0t_G0.md'de).
# Calistirma:  python -I tablolar.py > out/tablolar.md
import sys, math
sys.stdout.reconfigure(encoding="utf-8")

# --- 910ad1f sabitleri
CORE_2, EMPHASIS_2 = 1.25, 1.0          # product_quality.gd:37-38
CORE_3, EMPHASIS_3, REST_3 = 2.0, 1.5, 1.0   # :39-41
RATIO_CAP = 1.5                         # :13
MARK, SQUARES = 5, 10                   # sprint.json:39 pm.goal_mark, pm.goal_squares
MVP_LINES, CORE_LINES = 3, 5            # sprint.json:5, product_lines.gd:40
TIER_MAX = 3                            # product_lines.gd:20
DECAY = 0.75                            # PRD Karar 13


def tr(x, d=2):
    return ("%." + str(d) + "f") % x if False else (("%." + str(d) + "f") % x).replace(".", ",")


def roundi(x):                          # Godot roundi: .5 sifirdan uzaga
    return int(math.floor(x + 0.5)) if x >= 0 else -int(math.floor(-x + 0.5))


def squares(level, expect):             # product_quality.gd:200
    return min(roundi(level / expect * MARK), SQUARES)


def table(head, rows):
    out = ["| " + " | ".join(head) + " |", "|" + "|".join(["---"] * len(head)) + "|"]
    for r in rows:
        out.append("| " + " | ".join(str(c) for c in r) + " |")
    return "\n".join(out)


def sec(name, body):
    print("<!-- T:%s -->" % name)
    print(body)
    print("<!-- /T:%s -->\n" % name)


# ---------------------------------------------------------------- A1: beklenti ve kare birimi
mvp_core = MVP_LINES / CORE_LINES
rows = [
    ["Çekirdek", tr(mvp_core), tr(CORE_2), tr(CORE_3), tr(mvp_core / MARK, 3), tr(CORE_2 / MARK, 3), tr(CORE_3 / MARK, 3)],
    ["Vurgu alanı (sayfada çekirdek dışı her alan; hesapta sektörün ilk iki alanı)", "—", tr(EMPHASIS_2), tr(EMPHASIS_3), "—", tr(EMPHASIS_2 / MARK, 3), tr(EMPHASIS_3 / MARK, 3)],
    ["Kalan alan (yalnız sektörlü hesap bağlamı; sayfada yok)", "—", "0 (bakmaz)", tr(REST_3), "—", "—", tr(REST_3 / MARK, 3)],
]
sec("A1", table(["Rol", "1★ beklenti", "2★ beklenti", "3★ beklenti", "1 kare = seviye (1★)", "1 kare = seviye (2★)", "1 kare = seviye (3★)"], rows))

# ---------------------------------------------------------------- A2: alan yapisi, K adimi, doyma
areas = [("Çekirdek", 5, "core"), ("Güven & Ölçek (Güvenlik + Dayanıklılık)", 2, "emph"), ("Entegrasyonlar", 1, "emph"), ("Onboarding & Erişim (mobil; gizli hat açılmamış)", 1, "emph")]
rows = []
for nm, n, role in areas:
    e2 = CORE_2 if role == "core" else EMPHASIS_2
    e3 = CORE_3 if role == "core" else EMPHASIS_3
    step = 1.0 / n
    rows.append([nm, n, tr(step), tr(step / (e2 / MARK)), tr(step / (e3 / MARK)),
                 "%d / %d / %d" % tuple(squares(k, e2) for k in (1, 2, 3)),
                 "%d / %d / %d" % tuple(squares(k, e3) for k in (1, 2, 3))])
sec("A2", table(["Alan (B2B)", "Hat sayısı", "Bir kademe adımı = alan seviyesi", "= kare (2★ sayfa)", "= kare (3★)", "Tüm hatlar K1 / K2 / K3: kare (2★ sayfa)", "aynı, 3★"], rows))

# ---------------------------------------------------------------- B: g0 adaylari
CANDS = [("G1", "yarım kare", 0.125), ("G2", "bir kare", 0.25), ("G3", "iki kare", 0.5), ("G4", "bir Çekirdek kademe adımı", 0.2)]
CTX = [("2★ Çekirdek", CORE_2 / MARK), ("2★ diğer", EMPHASIS_2 / MARK), ("3★ Çekirdek", CORE_3 / MARK), ("3★ diğer", EMPHASIS_3 / MARK)]
KS = [1, 2, 3, 4, 5, 6, 7, 8, 12, 20]


def label(gain, unit, k):
    n = int(math.floor(gain / unit + 1e-9))
    if n >= 1:
        return "+%d" % n + ("~" if k >= 2 else "")
    return "<"


for key, nm, g0 in CANDS:
    rows = []
    for k in KS:
        g = g0 * DECAY ** (k - 1)
        cum = g0 * (1 - DECAY ** k) / (1 - DECAY)
        row = [k, tr(g, 4), tr(cum, 3)]
        for cn, unit in CTX:
            row.append("%s (%s)" % (tr(g / unit), label(g, unit, k)))
        rows.append(row)
    sec("B_" + key, table(["k", "Kazanç (seviye)", "Birikmiş (seviye)"] + ["%s: kare (etiket)" % c[0] for c in CTX], rows))

# kazancin bir karenin altina indigi ilk k
rows = []
for key, nm, g0 in CANDS:
    row = ["%s · %s · %s seviye" % (key, nm, tr(g0, 3))]
    for cn, unit in CTX:
        k = 1
        while g0 * DECAY ** (k - 1) / unit >= 1 - 1e-9:
            k += 1
        row.append("ilk kartta zaten altında" if k == 1 else str(k))
    row.append(tr(4 * g0, 2))
    row.append(tr(4 * g0 / (CORE_2 / MARK), 1))
    rows.append(row)
sec("B_alt", table(["Aday"] + ["1 karenin altına inen ilk k: %s" % c[0] for c in CTX] + ["Sonsuzdaki tavan 4·g₀ (seviye)", "= kare (2★ Çekirdek)"], rows))

# ---------------------------------------------------------------- C1: kesik seviyeleri
rows = []
for nm, n, role in areas:
    e2 = CORE_2 if role == "core" else EMPHASIS_2
    e3 = CORE_3 if role == "core" else EMPHASIS_3
    cut2, cut3 = RATIO_CAP * e2, RATIO_CAP * e3
    k3 = float(TIER_MAX)
    rows.append([nm, tr(e2), tr(cut2, 3), tr(e3), tr(cut3, 3), tr(k3 / e2), tr(k3 / e3),
                 "evet" if k3 / e2 >= RATIO_CAP and k3 / e3 >= RATIO_CAP else "hayır"])
sec("C1", table(["Alan", "2★ beklenti", "2★ kesik seviyesi (1,5×)", "3★ beklenti", "3★ kesik seviyesi (1,5×)", "Tüm hatlar K3: oran 2★", "oran 3★", "K3 bitince iki yıldızda da kesikte mi"], rows))

# ---------------------------------------------------------------- C2: kesige kac kartta varilir (kapali form)


def cards_to_cut(base, cut, g0):
    if base >= cut - 1e-9:
        return "0 (kesikte)"
    room = cut - base
    if 4 * g0 <= room + 1e-9:
        return "hiç"
    # base + 4 g0 (1-0.75^k) >= cut
    x = 1 - room / (4 * g0)
    k = math.ceil(math.log(x) / math.log(DECAY) - 1e-12)
    return str(max(1, k))


STATES = [
    ("Çekirdek", 5, CORE_2, CORE_3, [("1 hat K3, 4 hat K1", [3, 1, 1, 1, 1]), ("2 hat K3, 3 hat K1", [3, 3, 1, 1, 1]),
                                       ("1 hat K3, 4 hat K2", [3, 2, 2, 2, 2]), ("3 hat K3, 2 hat K1", [3, 3, 3, 1, 1]),
                                       ("3 hat K3, 2 hat K2", [3, 3, 3, 2, 2]), ("4 hat K3, 1 hat K2", [3, 3, 3, 3, 2]),
                                       ("4 hat K3, 1 hat K1", [3, 3, 3, 3, 1]), ("5 hat K3", [3, 3, 3, 3, 3])]),
    ("Güven & Ölçek", 2, EMPHASIS_2, EMPHASIS_3, [("1 hat K3, 1 hat boş", [3, 0]), ("1 hat K3, 1 hat K1", [3, 1]),
                                                   ("1 hat K3, 1 hat K2", [3, 2]), ("2 hat K3", [3, 3])]),
    ("Entegrasyonlar", 1, EMPHASIS_2, EMPHASIS_3, [("hat K3", [3])]),
]
for key, nm, g0 in CANDS:
    rows = []
    for an, n, e2, e3, sts in STATES:
        for sn, tiers in sts:
            b = sum(tiers) / len(tiers)
            rows.append([an, sn, tr(b), tr(b / e2), cards_to_cut(b, RATIO_CAP * e2, g0), tr(b / e3), cards_to_cut(b, RATIO_CAP * e3, g0)])
    sec("C2_" + key, table(["Alan", "Durum", "Taban seviye", "Oran 2★", "Kesiğe kaç kart (2★)", "Oran 3★", "Kesiğe kaç kart (3★)"], rows))

# ---------------------------------------------------------------- C3: serinin kendi kesigi
rows = []
for k in (1, 2, 3, 5, 8, 11, 15, 20, 30, 50, 100, 177):
    rows.append([k, "%s%%" % tr(100 * DECAY ** (k - 1), 1), "%s%%" % tr(100 * (1 - DECAY ** k), 1),
                 tr(0.25 * DECAY ** (k - 1) / (CORE_2 / MARK), 3)])
sec("C3", table(["k. kart", "Kazancı g₀'ın yüzdesi", "Birikmiş (tavan 4·g₀'ın yüzdesi)", "G2'de kazanç (2★ Çekirdek kare)"], rows))

# k* tablosu: birikmis payin esikleri
rows = []
for share in (0.80, 0.90, 0.95, 0.99):
    k = math.ceil(math.log(1 - share) / math.log(DECAY))
    rows.append(["%d%%" % int(share * 100), k])
sec("C3b", table(["Tavanın payı", "Gereken kart sayısı (alan başına)"], rows))

# kare yuvarlama ornegi
b0 = 2.0
e = CORE_2
ex = []
lvl = b0
for k in range(1, 6):
    g = 0.25 * DECAY ** (k - 1)
    before = squares(lvl, e)
    lvl += g
    after = squares(lvl, e)
    ex.append([k, tr(g, 4), tr(g / (e / MARK)), before, after, after - before])
sec("YUVARLAMA", table(["k", "Kazanç (seviye)", "Kazanç (kare)", "area_row kare önce", "sonra", "fark"], ex))

# ---------------------------------------------------------------- DU: bir kartin uyuma (U) etkisi, kesik ve CORE_LEAD tavani devrede degilken
FIT_SCALE, W_CORE, W_B2B = 70.0, 0.50, [0.25, 0.15, 0.10]       # product_quality.gd:12, :16, :18
roles = [("Çekirdek", W_CORE, CORE_2, CORE_3), ("Vurgu 1", W_B2B[0], EMPHASIS_2, EMPHASIS_3), ("Vurgu 2", W_B2B[1], EMPHASIS_2, EMPHASIS_3), ("Kalan", W_B2B[2], 0.0, REST_3)]
tot2 = W_CORE + W_B2B[0] + W_B2B[1]          # 2★ bir hesapta kalan alana bakmaz (beklenti 0): ağırlık toplamı 0,90
tot3 = W_CORE + sum(W_B2B)                   # 3★: 1,00
rows = []
for nm, w, e2, e3 in roles:
    c2 = FIT_SCALE * w / tot2 / e2 if e2 > 0 else None
    c3 = FIT_SCALE * w / tot3 / e3
    row = [nm, tr(w), tr(c2, 1) if c2 else "—", tr(c3, 1)]
    for g in (0.125, 0.25, 0.5, 0.2):
        row.append("%s / %s" % (tr(c2 * g, 1) if c2 else "—", tr(c3 * g, 1)))
    rows.append(row)
sec("DU", table(["Rol", "Ağırlık", "ΔU / seviye (2★ hesap)", "ΔU / seviye (3★ hesap)", "İlk kart G1 (2★ / 3★)", "G2", "G3", "G4"], rows))
rows = []
for nm, n in (("Çekirdek (5 hat)", 5), ("Güven & Ölçek (2 hat)", 2), ("Tek hatlı alan", 1)):
    step = 1.0 / n
    if nm.startswith("Çek"):
        c2, c3 = FIT_SCALE * W_CORE / tot2 / CORE_2, FIT_SCALE * W_CORE / tot3 / CORE_3
    else:
        c2, c3 = FIT_SCALE * W_B2B[0] / tot2 / EMPHASIS_2, FIT_SCALE * W_B2B[0] / tot3 / EMPHASIS_3
    rows.append([nm + (" · vurgu 1" if not nm.startswith("Çek") else ""), tr(step), tr(c2 * step, 1), tr(c3 * step, 1)])
sec("DU_K", table(["Alan", "Bir kademe adımı (seviye)", "ΔU (2★ hesap)", "ΔU (3★ hesap)"], rows))

# ---------------------------------------------------------------- C2x: durum x aday ozeti (hepsi tek tabloda)
rows = []
for an, n, e2, e3, sts in STATES:
    for sn, tiers in sts:
        b = sum(tiers) / len(tiers)
        row = [an, sn, tr(b)]
        for key, nm, g0 in CANDS:
            row.append("%s / %s" % (cards_to_cut(b, RATIO_CAP * e2, g0).replace(" (kesikte)", "·K"), cards_to_cut(b, RATIO_CAP * e3, g0).replace(" (kesikte)", "·K")))
        rows.append(row)
sec("C2x", table(["Alan", "Durum", "Taban seviye"] + ["%s: 2★ / 3★ kesik" % c[0] for c in CANDS], rows))

# ---------------------------------------------------------------- C4: ad sayilari (Wa_ADLAR.json)
import json, os
here = os.path.dirname(os.path.abspath(__file__))
wa = json.load(open(os.path.join(here, "..", "..", "..", "W", "Wa_ADLAR.json"), encoding="utf-8"))
names = {l["line_id"]: len(l["names"]) for l in wa["lines"]}
shared = {k: v for k, v in names.items() if k.startswith("line_shared_")}
rows = []
for prod in ("erp", "note_tool", "video_clip"):
    ident = [v for k, v in names.items() if k.startswith("line_" + prod + "_")]
    sh = list(shared.values())
    rows.append([prod, len(ident), sum(ident), "%d-%d" % (min(ident), max(ident)), shared["line_shared_mobile"], shared["line_shared_integrations"],
                 shared["line_shared_security"] + shared["line_shared_durability"], sum(ident) + sum(sh)])
sec("C4", table(["Ürün", "Kimlik hattı", "Çekirdek adları", "Hat başına", "Mobil (Onboarding)", "Entegrasyonlar", "Güven & Ölçek (2 hat)", "Ürün toplamı (9 hat)"], rows))
print("<!-- toplam ad: %d, hat: %d -->" % (sum(names.values()), len(names)))
