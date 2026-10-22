# D0s: ayni girdi ayni atama - tum kosu duzeyinde. Kisi listesi ters ve karisik verilir; atama kaydi (alog) ve sonuc ayni olmali.
import json, random
OUT = []
for nm in ("S3", "S4", "HUY|S3", "HUY|S4", "A|S3|kaynakli|2", "S5"):
    fn, kw = SCEN[nm]
    kw = dict(kw); kw["weeks"] = 16
    res = []
    for mode in ("orijinal", "ters", "karisik"):
        ppl = fn()
        Sim._uniq(ppl)
        if mode == "ters":
            ppl = list(reversed(ppl))
        elif mode == "karisik":
            ppl = random.Random(11).sample(ppl, len(ppl))
        al = []
        k2 = dict(kw); k2["alog"] = al
        s = Sim(ppl, 3, **k2); s.run()
        m = metrics(s)
        res.append((al, round(m["deliv"], 9), m["mvp"], round(m["idle_w"], 9), s.pred_maxdiff))
    same = res[0][0] == res[1][0] == res[2][0] and res[0][1:4] == res[1][1:4] == res[2][1:4]
    OUT.append({"senaryo": nm, "atama_kaydi": len(res[0][0]), "ayni": same, "deliv": res[0][1], "pred": max(r[4] for r in res)})
    print("%-18s atama kaydi %5d satir | ters ve karisik listede ayni: %s | deliv %s | tahmin farki %.1e" % (nm, len(res[0][0]), same, res[0][1], max(r[4] for r in res)), flush=True)
json.dump(OUT, open("out/ddet.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
