exec(open("mkreport.py",encoding="utf-8").read())
for v in V: print(v)
print(KIR); print(OBS); print("dom", dom)
for n in ("S1","S2","S3","S4","S5","S6","C12","C25","C47","C48","C50","S8","S11","S10"):
    a=A[n]; print(n,"wip",f(a["wip"]),"lead",f(a["lead"],2),"open_max",a["open_max"],"cards/spr",f(a["cards_sprint"]),"fixes",f(a["fixes"]),"mvp",a["mvp"])
for n in R:
    if n.startswith("TS") or n.startswith("T3") or n.startswith("T4"):
        a=A[n]; print(n,"esc",f(a["esc_card"],3),"deliv",f(a["deliv"]),"open",f(a["open_med"]),"openmax",a["open_max"],"fix",pc(a["fix_late"]),"fixes",f(a["fixes"]))
print("PM morale", [ (R["S3_PM_testkutulu"][s]["morale"]) for s in SEEDS[:3]])
