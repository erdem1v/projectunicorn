exec(open("analyze.py",encoding="utf-8").read())
bad=[]
for n,a in A.items():
    if a["n"]<2: continue
    why=[]
    if a["fix_early"] is not None and a["fix_early"]>0.30: why.append("erken pay %s"%pc(a["fix_early"]))
    if a["fix_late"]>0.20: why.append("gec pay %s"%pc(a["fix_late"]))
    t=a["bs_late"]; 
    if t[1] and t[0]/t[1]>0.05: why.append("bs gec %s"%ratio(t))
    t=a["bs_early"]
    if t[1] and t[0]/t[1]>0.05: why.append("bs erken %s"%ratio(t))
    if a["consec"]>0: why.append("ardisik %d tohum"%a["consec"])
    if a["slope"] is not None and a["slope"]>0.2: why.append("egim %.2f"%a["slope"])
    if a["pred"]>1e-6: why.append("pred %g"%a["pred"])
    if a["cviol"]: why.append("cviol")
    if a["mvp"] is None: why.append("MVP YOK")
    if why: bad.append((n,why))
for b in bad: print(b)
print(len(bad))
# S1 detay
a=A["S1"]; print("S1", a["fix_early"], a["fix_late"], ratio(a["bs_early"]), ratio(a["bs_late"]), a["consec"], a["slope"])
print("max slope", max((a["slope"],n) for n,a in A.items() if a["slope"] is not None))
print("idle>10% & yok:", [(n,a["idle_w"]/a["n"]) for n,a in A.items() if a["idle_w"]/a["n"]>0.10 and a["bott"]=="yok"])
print("idle>10%:", [(n,round(a["idle_w"]/a["n"],2),a["bott"]) for n,a in A.items() if a["idle_w"]/a["n"]>0.10])
