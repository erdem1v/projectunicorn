import pickle, statistics
B = pickle.load(open("results_before.pkl","rb")); Aft = pickle.load(open("results_after.pkl","rb"))
S = range(1,21)
md=lambda R,n,k: statistics.median([R[n][s][k] for s in S])
cb={n:md(B,"C%d"%n,"deliv") for n in range(1,51)}; ca={n:md(Aft,"C%d"%n,"deliv") for n in range(1,51)}
ch=[n for n in range(1,51) if cb[n]!=ca[n]]
print("curve changed", [(n,cb[n],ca[n]) for n in ch])
mb={n:cb[n]-cb[n-1] for n in range(2,51)}; ma={n:ca[n]-ca[n-1] for n in range(2,51)}
print("steps changed", [(n,mb[n],ma[n]) for n in range(2,51) if mb[n]!=ma[n]])
print("min after", min(ma.items(), key=lambda t:t[1]), "neg", [n for n in ma if ma[n]<0], "zero", [n for n in ma if ma[n]==0])
print("C47 C48 lead/wip", [(n, round(md(Aft,n,"lead"),2), round(md(Aft,n,"wip"),1)) for n in ("C47","C48")])
roles = curve_roles(50)
print("role 48", roles[46])
adds = ["+3* gelistirici", "+3* testci", "+3* tasarimci", "+3* PM", "+1* gelistirici"]
for b in ("S2","S3","S4","S5","S6"):
    print(b, [(a, md(B,"%s %s"%(b,a),"deliv")-md(B,b,"deliv"), md(Aft,"%s %s"%(b,a),"deliv")-md(Aft,b,"deliv")) for a in adds])
for n in Aft:
    if n.startswith("M|") and md(B,n,"deliv")!=md(Aft,n,"deliv"):
        print(n, md(B,n,"deliv"), md(Aft,n,"deliv"), "lead", round(md(B,n,"lead") or 0,1), round(md(Aft,n,"lead") or 0,1))
# lead time changes broadly
big=[(n, round(md(B,n,"lead"),1), round(md(Aft,n,"lead"),1), round(md(B,n,"wip"),1), round(md(Aft,n,"wip"),1)) for n in Aft if md(B,n,"lead") is not None and abs(md(B,n,"lead")-md(Aft,n,"lead"))>0.3]
print("lead changes >0.3", big)
# M|ref mix dominance unchanged? ratio to ref
for nn in (12,25,50):
    ref=md(Aft,"M|ref (PM12 Tas16 Gel51 Test20)|%d"%nn,"deliv")
    print(nn, "ref", ref)
