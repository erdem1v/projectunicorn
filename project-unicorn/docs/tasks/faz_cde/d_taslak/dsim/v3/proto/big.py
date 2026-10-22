import pickle, time
t=time.time()
SEEDS=range(1,21)
main=["S1","S2","S3","S4","S5","S6","S7","S7_1test","S8","S8_hepsi_testkutulu","S9a","S9b","S10","S11","S11b","S12",
      "S3_PMsiz","S4_PMsiz","S4_1PM","S5_1PM"]
tst=[k for k in SCEN if k[:2] in ("T3","T4","T5")]
pm=[k for k in SCEN if k.startswith("PM")]
gr=[k for k in SCEN if k.startswith("g_")]
marg=[k for k in SCEN if " +" in k]
R,M = rec_many(main+tst+pm+gr+marg, SEEDS)
out={"hold":(R,M)}
for pol,ans in (("ship","ship"),("ask","ship"),("ask","heavy"),("ask","hold")):
    os.environ["D3_ASKANS"]=ans
    import importlib
    globals()["ASK_ANS"]=ans
    R2,M2=rec_many(["S1","S3","S4","S5","S6","S10"], SEEDS, pol)
    out[pol+"_"+ans]=(R2,M2)
print("main", time.time()-t)
pickle.dump(out, open("big.pkl","wb"))
