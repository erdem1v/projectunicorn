# Y konusu: bitis yili sure hesabi. Calistir: python -I y_sure_hesabi.py
from datetime import date

START = date(2012, 1, 1)
print("2012-01-01 haftanin gunu:", START.strftime("%A"))

def weeks_to(end_incl):
    days = (end_incl - START).days + 1
    return days, days / 7.0

ENDS = {"2025 sonu": date(2025,12,31), "2030 basi (2030-01-01 oncesi, 18 yil)": date(2029,12,31),
        "2030 sonu": date(2030,12,31), "2035 sonu": date(2035,12,31)}
SPEEDS = {"1x (22,5 sn)": 22.5, "2x (11,25 sn)": 11.25, "3x (7,5 sn)": 7.5}
CAL = {"hafta 40 sn, 1x": 40.0, "hafta 50 sn, 1x": 50.0,
       "hafta 40 sn, 3x": 40.0/3, "hafta 50 sn, 3x": 50.0/3}

print("\n== Hafta (tik) sayisi ==")
rows = {}
for k, e in ENDS.items():
    d, w = weeks_to(e)
    n52 = (e.year - 2012 + 1) * 52
    rows[k] = (d, w, n52)
    print(f"{k:42s} gun={d:5d}  takvim hafta={w:7.1f}  52/yil kurali={n52}")

print("\n== Toplam saat (duraklamasiz, takvim hafta) ==")
for k, (d, w, n52) in rows.items():
    out = []
    for sk, s in {**SPEEDS, **CAL}.items():
        out.append(f"{sk}: {w*s/3600:5.1f}s")
    print(k, "|", " | ".join(out))

print("\n== Toplam saat (52 tik/yil kurali) ==")
for k, (d, w, n52) in rows.items():
    out = []
    for sk, s in {**SPEEDS, **CAL}.items():
        out.append(f"{sk}: {n52*s/3600:5.1f}s")
    print(k, "|", " | ".join(out))

print("\n== Yil basina hafta (takvim) ==")
for y in range(2012, 2036):
    d = (date(y,12,31) - date(y,1,1)).days + 1
    print(y, d, round(d/7, 2), end=" ; ")
print()

print("\n== Demo 104 hafta payi ==")
for k in ["2030 sonu", "2035 sonu"]:
    d, w, n52 = rows[k]
    print(k, f"104/{w:.0f} = %{104/w*100:.1f}  (52/yil kurali: %{104/n52*100:.1f})")
print("Demo biter (takvim):", date.fromordinal(START.toordinal() + 104*7 - 1))

print("\n== Ek 5 yil (2031-2035) ==")
d30, w30, _ = rows["2030 sonu"]; d35, w35, _ = rows["2035 sonu"]
ek = w35 - w30
print(f"ek hafta = {ek:.1f}, oran 2035/2030 = {w35/w30:.3f}")
for sk, s in {**SPEEDS, **CAL}.items():
    print(f"  {sk}: ek {ek*s/3600:.2f} saat; 2030 sonu toplam {w30*s/3600:.1f}; 2035 sonu toplam {w35*s/3600:.1f}")

print("\n== Game Dev Tycoon kiyasi: 35 yil ~5 saat (oyuncu beyani B2-S3) ==")
gdt_w = 35*52
print("35 yil =", gdt_w, "tik(52/yil);  5 saat ->", round(5*3600/gdt_w,2), "sn/hafta; yil basina", round(5*60/35,2), "dk")
for k in ["2030 sonu", "2035 sonu"]:
    d, w, n52 = rows[k]
    yr = n52/52
    print(f"  {k}: {yr:.0f} yil; Unicorn 1x saat/yil = {n52*22.5/3600/yr:.2f}; GDT saat/yil = {5/35:.3f}; Unicorn/GDT kat = {(22.5*52/3600)/(5/35):.1f}")
print("  Unicorn 22,5 sn: yil basina", round(52*22.5/60,1), "dk; GDT yil basina", round(5*60/35,1), "dk")

print("\n== YZ penceresi (YZ hatti 2023 acilirsa; 2023-01-01'den bitise) ==")
ai = date(2023,1,1)
for k in ["2030 sonu", "2035 sonu"]:
    e = ENDS[k]
    wk = ((e - ai).days + 1) / 7
    d, w, _ = rows[k]
    print(f"{k}: {(e.year-2023+1)} yil, {wk:.0f} hafta, oyunun %{wk/w*100:.1f}'i; 1x {wk*22.5/3600:.2f} sa; 3x {wk*7.5/3600:.2f} sa; 40sn/1x {wk*40/3600:.2f} sa")
# oyuncunun oyuna 2023'e varma noktasi
d23, w23 = weeks_to(date(2022,12,31))
print(f"2023 basina kadar {w23:.0f} hafta; 1x {w23*22.5/3600:.2f} sa, 40 sn {w23*40/3600:.2f} sa")

print("\n== Modul-kademe formulleri: K3 2012 ... iki yilda bir ==")
def tiers_by(year_end, step=2, start_year=2012, start_tier=3):
    t, y, out = start_tier, start_year, {}
    while y <= year_end:
        out[y] = t; t += 1; y += step
    return out
t30 = tiers_by(2030); print("2030 sonu:", t30, "son kademe:", max(t30.values()))
t35 = tiers_by(2035); print("2035 sonu (2 yilda bir, 2034'e kadar):", t35, "son kademe:", max(t35.values()))

print("\n== Gecmis / gelecek payi (bugun 2026-10-20; 2012-2026 takvim yili gecmis sayilir) ==")
def wk(a, b): return ((b - a).days + 1) / 7
g_end = date(2026,12,31)
for k, e in [("2030 sonu", date(2030,12,31)), ("2035 sonu", date(2035,12,31))]:
    tot = wk(START, e); past = wk(START, g_end); fut = wk(date(2027,1,1), e)
    print(f"{k}: toplam {tot:.0f}; 2012-2026 {past:.0f} ({past/tot*100:.0f}%); 2027-sonrasi {fut:.0f} ({fut/tot*100:.0f}%)")
w2730 = wk(date(2027,1,1), date(2030,12,31)); w3135 = wk(date(2031,1,1), date(2035,12,31))
print(f"2027-2030: {w2730:.0f} hafta; 1x {w2730*22.5/3600:.2f} sa; 40sn {w2730*40/3600:.2f} sa")
print(f"2031-2035: {w3135:.0f} hafta; 1x {w3135*22.5/3600:.2f} sa; 40sn {w3135*40/3600:.2f} sa; 50sn {w3135*50/3600:.2f} sa")
print(f"2012-2026: {wk(START,g_end):.0f} hafta; 1x {wk(START,g_end)*22.5/3600:.2f} sa")

print("\n== Icerik bedeli formulu: ders sayilari ==")
# dizge sayisi = N modul x K kademe x 2 dil x (ad + aciklama)
for N in (5, 7, 10):
    row = []
    for K in (12, 14):
        kad = N * K
        dizge = kad * 2 * 2
        haber = N * (K - 2) * 2   # rakip kademe acilis haberi, 1 anahtar x 2 dil
        row.append(f"K={K}: kademe={kad}, ad+aciklama dizge={dizge}, rakip haber dizge={haber}")
    ek = N * 2
    print(f"N={N}: " + " | ".join(row) + f" | 2035 ek kademe={ek}, ek dizge={ek*4 + N*2*2}")
# donem hatti haber: satir basina duyuru + bitis = 2 anahtar x 2 dil
for rows_ in (14, 20, 26, 30):
    print(f"donem satiri {rows_}: haber dizge = {rows_*2*2}")
