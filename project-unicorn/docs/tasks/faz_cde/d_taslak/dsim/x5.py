exec(open("analyze.py",encoding="utf-8").read())
for n in R:
    if n.startswith("M|"):
        a=A[n]
        print("%-52s n=%2d teslim %6.1f kisi %5.2f esc %.2f acik %5.1f dz %s bos %.1f dar %s hz %s" % (n,a["n"],a["deliv"],a["per_person"],a["esc_card"],a["open_med"],pc(a["fix_late"]),a["idle_w"],a["bott"],pc(a["ready"])))
for p in ("T3","T4"):
    print(p,[ (k, round(med("%s_%d"%(p,k),"esc_card"),3), round(med("%s_%d"%(p,k),"deliv"),1)) for k in (2,4,6,8,10)])
for b in ("S2","S3","S4","S5","S6"):
    for a in ("+3* gelistirici","+3* testci","+3* tasarimci","+3* PM","+1* gelistirici"):
        n="%s %s"%(b,a)
        print("%-24s d=%+6.1f esc %.2f"%(n, A[n]["deliv"]-A[b]["deliv"], A[n]["esc_card"]))
