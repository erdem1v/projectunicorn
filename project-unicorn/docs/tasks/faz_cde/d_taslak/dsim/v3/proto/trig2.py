import math
def _unused(task):
    name, seed = task
    s = Sim(SCEN[name](), seed); s.run()
    return name, [x for x in s.rec if x["end"] > 20]
names=["S2","S3","S4","S5","S6","S7","S10","S11b","C9","C18","C35"]
R, M = rec_many(names, range(1,21))

trigs = {
 "K>=1": lambda x: x["K"]>=1,
 "K>=max(1,.25F)": lambda x: x["K"]>=max(1, math.ceil(0.25*x["found"])),
 "K>=max(2,.25F)": lambda x: x["K"]>=max(2, 0.25*x["found"]),
 "K>=max(1,.34F)": lambda x: x["K"]>=max(1, math.ceil(0.34*x["found"])),
 "K>=max(1,.4F)": lambda x: x["K"]>=max(1, math.ceil(0.4*x["found"])),
 "held>=.2cap": lambda x: x["held"]>=0.2*x["cap"],
 "held>=.2cap|K>=.25F": lambda x: x["K"]>=1 and (x["held"]>=0.2*x["cap"] or x["K"]>=0.25*x["found"]),
}
print("%-20s"%"", " ".join("%7s"%n for n in names))
for t,f in trigs.items():
    print("%-20s"%t, " ".join("%7.2f"%(sum(1 for x in R[n] if f(x))/len(R[n])) for n in names))
print("%-20s"%"F/sprint", " ".join("%7.1f"%(sum(x["found"] for x in R[n])/len(R[n])) for n in names))
print("%-20s"%"K/sprint", " ".join("%7.2f"%(sum(x["K"] for x in R[n])/len(R[n])) for n in names))
