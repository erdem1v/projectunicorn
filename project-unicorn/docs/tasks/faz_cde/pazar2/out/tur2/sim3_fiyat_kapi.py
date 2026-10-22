"""Fiyat kapısı (SENTEZ §13.2): hiçbir duruş tohumların %80'inden fazlasında en yüksek MRR'yi vermez.
Üç koşu (ucuz / standart / pahalı) aynı tohum ve ayarla koşulmuş olmalı; her hücrede (N, bot, takım, ölçek) tohum başına
beşinci fiyat kolunun (önerilen fiyat) 2030 sonu MRR'si üç duruş arasında karşılaştırılır.
Kullanım: python -I sim3_fiyat_kapi.py <önek> [<yıl>]   (dosyalar sim3_<önek>_ucuz.json, _standart.json, _pahali.json)"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")
pre = sys.argv[1]
yil = sys.argv[2] if len(sys.argv) > 2 else "2030"
DUR = ("ucuz", "standart", "pahali")
D = {d: json.load(open(os.path.join(HERE, f"sim3_{pre}_{d}.json"), encoding="utf-8"))["ham"] for d in DUR}
rows, tot = [], {d: 0 for d in DUR}
n_all = 0
for key in sorted(D["standart"]):
    parts = key.split("|")
    if parts[3] != "330":
        continue
    sd = {d: D[d][key] for d in DUR}
    n = len(sd["standart"])
    win = {d: 0 for d in DUR}
    for i in range(n):
        v = {d: sd[d][i]["mrr"][yil][4] for d in DUR}
        w = max(v, key=lambda d: v[d])
        win[w] += 1
    for d in DUR:
        tot[d] += win[d]
    n_all += n
    med = {d: sorted(sd[d][i]["mrr"][yil][4] for i in range(n))[n // 2] for d in DUR}
    dol = {d: sum(x["dolum"] for x in sd[d]) / n for d in DUR}
    rows.append((key, n, win, med, dol))
print(f"yıl {yil}; hücre başına en yüksek MRR veren duruş payı (tohum); medyan MRR; ortalama portföy doluluğu")
mx = 0.0
for key, n, win, med, dol in rows:
    pay = {d: win[d] / n for d in DUR}
    mx = max(mx, max(pay.values()))
    print(f"{key:24s} ucuz {pay['ucuz']:.2f} standart {pay['standart']:.2f} pahalı {pay['pahali']:.2f} | medyan MRR "
          f"{med['ucuz']:.0f} / {med['standart']:.0f} / {med['pahali']:.0f} | doluluk {dol['ucuz']:.2f} / {dol['standart']:.2f} / {dol['pahali']:.2f}")
print("havuzlanmış:", {d: round(tot[d] / n_all, 3) for d in DUR}, "n", n_all, "| en kötü hücre payı", round(mx, 2),
      "| kapı:", "✅" if max(tot[d] / n_all for d in DUR) <= 0.8 and mx <= 0.8 else "❌")
