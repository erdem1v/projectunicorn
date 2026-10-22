"""SIM3 bağımsız kontrol: sim.py'nin kullandığı yoldan farklı bir yolla yeniden türetilen sayılar (yalnız okuma).
Kullanım: python -I sim3_kontrol.py <tam_ad> <fiyat_önek>
 1. Önerilen fiyat formülü: ham örneklerden (modül, r) çiftlerinden SENTEZ §5.6'nın formülü yeniden hesaplanır; SENTEZ'in 6 örneği elle.
 2. Tempo: büyüyen takımın 104 haftada toplam etkin puanı, sim'e bakmadan takım takvimi ve hata yükünden.
 3. G1 dev doygunluğu: yıl satırlarındaki dev_tavanda / dev_hat oranından.
 4. G2 geç: üç botun hücrelerinden ağırlıklı ortalama (n=20 her biri).
 5. Fiyat kapısı: ham MRR dizilerinden tohum başına en iyi duruşun yeniden sayımı (başka döngü sırasıyla)."""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")


def J(ad):
    return json.load(open(os.path.join(HERE, f"sim3_{ad}.json"), encoding="utf-8"))


W = {"FIN": .2, "FAT": .3, "SAL": .2, "IK": .3, "STK": .2, "URT": .3, "DEP": .2, "MAG": .1, "PRJ": .1, "VAR": .2, "TED": .2}


def fiyat(mods, rs, stance=1.0):
    num = den = 0.0
    for m, r in zip(mods, rs):
        k = min(1.25, max(0.75, 1 + 0.5 * (r - 1)))
        num += W[m] * k
        den += W[m]
    return 30 * (1 + den) * (num / den) * stance


def main(tam, pre):
    print("1) fiyat formülü")
    # SENTEZ §5.6 örnekleri (hafif .1, orta .2, ağır .3): 2 modül (1 hafif 1 orta) 39; 5 modül (2h 2o 1a) 57; ağır zayıf 52; hepsi zayıf 43; hepsi iyi 71; 10 modül (4h 4o 2a) 84
    ex = {
        "2 modül standart": (["MAG", "FIN"], [1, 1], 39),
        "5 modül standart": (["MAG", "PRJ", "FIN", "SAL", "URT"], [1] * 5, 57),
        "5 modül, ağır zayıf": (["MAG", "PRJ", "FIN", "SAL", "URT"], [1, 1, 1, 1, 0.5], 52),
        "5 modül hepsi zayıf": (["MAG", "PRJ", "FIN", "SAL", "URT"], [0.5] * 5, 43),
        "5 modül hepsi iyi": (["MAG", "PRJ", "FIN", "SAL", "URT"], [1.5] * 5, 71),
    }
    for k, (m, r, beklenen) in ex.items():
        print(f"   {k}: bu betik {fiyat(m, r):.1f} · SENTEZ {beklenen}")
    h = J(tam)["ham"]
    n = ok = 0
    worst = 0.0
    for key, runs in h.items():
        for run in runs[:1]:
            for m, r, cp in run.get("ornek", []):
                n += 1
                d = abs(fiyat(m, r, 1.0) - cp)
                worst = max(worst, d)
                ok += d < 1e-6
    print(f"   sim örneği {n}, betikle eşleşen {ok}, en büyük fark {worst:.2e}")

    print("2) tempo: büyüyen takım 104 hafta toplam etkin puan")
    ppw, ovh, bug, div, newk = 2.0, 0.25, 7 * 0.1 * 0.4, 80, 1 + 0.09 * 0.4
    tot = 0.0
    for t in range(104):
        team = 1 if t < 52 else 3
        devs = team * max(0.5, 1 - 0.1 * math.log2(team))
        tot += (devs * ppw * (1 - ovh) - bug) / newk
    d = J(tam)
    print(f"   hesap (aktif hesap 0 varsayımıyla üst sınır): {tot:.0f} puan · sim odaklı büyüyen medyanı {d['tempo']['10|odakli|buyuyen']['puan104']:.0f}"
          f" · K1+K2+K3 = {5.5 * (1 + 4.5 + 4.5 ** 2):.1f} → kapasite {tot / (5.5 * (1 + 4.5 + 4.5 ** 2)):.2f} modül")

    print("3) G1 dev doygunluğu (N=10)")
    yy = d["g1"]["10"]["yillar"]
    print("   dev_tavanda/dev_hat 2015:", yy["2015"]["dev_tavanda"], "/", yy["2015"]["dev_hat"], "=", round(yy["2015"]["dev_tavanda"] / yy["2015"]["dev_hat"], 3),
          "· dev_pay", round(yy["2015"]["dev_pay"], 3))

    print("4) G2 geç (büyüyen, 2030)")
    g = d["g2"]["10|2030|buyuyen|A"]
    ws = sum(c["gec_golge_son"] * c["n"] for c in g["bot"].values()) / sum(c["n"] for c in g["bot"].values())
    print(f"   botlardan ağırlıklı {ws:.3f} · sim güçlü {g['guclu']['gec_golge_son']:.3f}")

    print("5) fiyat kapısı yeniden sayım")
    H = {s: J(f"{pre}_{s}")["ham"] for s in ("ucuz", "standart", "pahali")}
    win = {"ucuz": 0, "standart": 0, "pahali": 0}
    N = 0
    for key in H["standart"]:
        if not key.endswith("|330"):
            continue
        for i in range(len(H["standart"][key])):
            vals = sorted(((H[s][key][i]["mrr"]["2030"][4], s) for s in H), reverse=True)
            win[vals[0][1]] += 1
            N += 1
    print("   ", {k: round(v / N, 3) for k, v in win.items()}, "n", N)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
