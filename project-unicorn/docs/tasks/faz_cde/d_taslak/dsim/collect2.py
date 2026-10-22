import pickle
names=[n for n in SCEN if n.startswith("TS")]
res=run_many(names, range(1,21))
R=pickle.load(open("results.pkl","rb"))
R.update(res)
pickle.dump(R, open("results.pkl","wb"))
print("ek", len(names))
