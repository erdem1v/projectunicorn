# A6 dogrulamalari: tohum sayisi, tahmin = sonuc, dogan >= bulunan, tarif kolunda gereksinim alti is = 0, PM'siz ekipte PM kollari ayni. python -I a6dogrula.py
import os, sys, glob, pickle
HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")
files = sorted(glob.glob(os.path.join(HERE, "out6", "ana", "*", "*.pkl")))
bad_n = bad_pred = bad_born = 0
maxpred = 0.0
n_runs = 0
below = {}
for f in files:
    d = pickle.load(open(f, "rb"))
    cal = f.split(os.sep)[-2]
    arm = os.path.basename(f).split("__")[0]
    if len(d) != 20:
        bad_n += 1
        print("TOHUM EKSIK", f, len(d))
    for sd, m in d.items():
        n_runs += 1
        maxpred = max(maxpred, m["pred"])
        if m["pred"] > 1e-6:
            bad_pred += 1
        if m["found"] > m["born"] + 1e-9:
            bad_born += 1
        below.setdefault((cal, arm), []).append(m["wbelow"])
print("dosya %d, kosu %d, tohumu 20'den az dosya %d" % (len(files), n_runs, bad_n))
print("tahmin = sonuc: en buyuk fark %.2e, 1e-6 ustu %d" % (maxpred, bad_pred))
print("bulunan > dogan olan kosu: %d" % bad_born)
for k in sorted(below):
    print("gereksinim alti Yazilim isi toplami", k, "%.1f" % sum(below[k]))
