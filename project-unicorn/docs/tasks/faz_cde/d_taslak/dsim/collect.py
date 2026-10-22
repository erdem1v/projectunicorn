import pickle
t0=time.time()
names=list(SCEN.keys())
res=run_many(names, range(1,21))
pickle.dump(res, open("results.pkl","wb"))
print("tamam", len(names), "senaryo", round(time.time()-t0), "sn")
