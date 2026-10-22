exec(open("analyze.py",encoding="utf-8").read())
for n in ("S5","S6","S10","M|ref (PM12 Tas16 Gel51 Test20)|50"):
    print(n, sorted(R[n][s]["open_max"] for s in SEEDS))
# birkac tohumda acik hata >=30 hafta sayisi
def run_open(nn, seed):
    sim = Sim(SCEN[nn](), seed, check_pred=False); sim.run()
    return [x["open"] for x in sim.rec if x["end"]>20]
for nn in ("S6","S5"):
    allv=[]
    for s in range(1,21):
        allv+=run_open(nn,s)
    print(nn, "kapanis sayisi", len(allv), ">=30:", sum(1 for v in allv if v>=30), ">=25:", sum(1 for v in allv if v>=25), "max", max(allv))
