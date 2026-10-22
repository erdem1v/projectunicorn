import collections
c=collections.Counter(); ex=[]
for s in range(1,21):
    sim=Sim(SCEN["S1"](), s, check_pred=False); sim.run()
    for x in sim.rec:
        if x["end"]>20 and x["share"]>0.5:
            c[round(x["share"],2)]+=1
print(sorted(c.items()))
print("seed paired C48<C47:", sum(1 for s in range(1,21)))
