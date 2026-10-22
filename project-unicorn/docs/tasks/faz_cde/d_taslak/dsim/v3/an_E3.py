exec(open("an_common.py", encoding="utf-8").read())
E = L("E")
FN = ["orta","gel4","gel5","tasarim_test"]
SQ = ["gel-tas-test","tas-gel-test","test-gel-tas","pm-gel-tas","1yildiz","uc-gel"]
# kesin yuzde
for f in ("gel5",):
    for s in ("uc-gel","gel-tas-test","pm-gel-tas"):
        v=[md(E,"G|%s|%s|%d"%(f,s,k),"founder_w") for k in range(4)]
        print(f,s,["%.4f"%x for x in v],["%.2f%%"%(100*(x/v[0]-1)) for x in v])
# gercek zaman: hafta pencerelerinde haftalik teslim (puan/hf); alim 8,14,20
def phase_means(m):
    ser = m["series"]   # (start,end,delivered,n,nocard,cand,ok,idle,asked,share)
    # haftalik teslim: sprint teslimi / sprint haftasi, haftalara yay
    wk = {}
    for (s, e, d, *_r) in ser:
        for w in range(s, e): wk[w] = d / (e - s)
    def avg(a, b):
        xs = [wk[w] for w in range(a, b) if w in wk]
        return sum(xs) / len(xs) if xs else None
    return [avg(0,8), avg(8,14), avg(14,20), avg(20,26), avg(26,40), avg(40,60)]
print("\ngercek zaman (alimlar 8,14,20. hafta): 0-8 | 8-14 | 14-20 | 20-26 | 26-40 | 40-60 teslim/hf medyan; MVP")
worst = []
for f in FN:
    for s in SQ:
        n = "GT|%s|%s|3" % (f, s)
        ph = [statistics.median([phase_means(m)[i] for m in E[n].values()]) for i in range(6)]
        mv = md(E, n, "mvp")
        base_mvp = md(E, "GT|%s|%s|0" % (f, s), "mvp")
        print("%-13s %-13s" % (f, s), " | ".join("%.1f" % x for x in ph), "mvp", mv, "(solo", base_mvp, ")")
        for i in range(1, 6):
            if ph[i] < ph[i-1] - 1e-9 and i >= 2: worst.append((f, s, i, ph[i-1], ph[i]))
print("dusen faz:", len(worst))
for w in worst: print(w)
