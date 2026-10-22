import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import scen, model as M
print("== R9 sekilleri (yaslar 1/4/12/26/52/104/208), esik-alti hafta, nedensiz, en buyuk dusus")
for shape in "ABCD":
    for star in (1,2,3):
        for mode in ("old","new"):
            r = scen.run_shape(shape, star, mode)
            ser, below, ned, big = scen.shape_summary(r)
            print(shape, star, mode, ser, below, ned, big)
print("== M2")
rows = scen.m2_grid()
import collections
agg = collections.defaultdict(lambda:[0,0,0,0,0.0])
for (t0,star,sec,mode,rej,s0,mn,s12,marg) in rows:
    k=(mode,)
    a=agg[k]; a[0]+=1
    if rej: a[1]+=1; continue
    a[2]+= (mn < s0); a[3]+= (marg < 10 if mode=='new' else 0); a[4]+= (s12 - s0)
for k,a in agg.items(): print(k, "n",a[0],"red",a[1],"imza altina inen",a[2],"imza<esik+10",a[3],"12h ort degisim", round(a[4]/max(1,a[0]-a[1]),1))
print("== M6")
for mode in ("new","old"):
    for owner in (0,5):
        for outc in ("kept","late","broken"):
            for dist in (8,20):
                r,s_,tol = scen.m6_case(mode,2,owner,outc,dist)
                ser=r["sat"]
                print(mode,"sahip",owner,outc,"d",dist,"sat19",ser[19],"tol",tol,"sat30",ser.get(30),"sat31",ser.get(31),"min marj",r["min_margin"],"risk girisi",r["risk_entered"],"ayril",r["left"], "sat60", ser.get(60), "sat100", ser.get(100))
print("== M7")
for bugs in (2,6,12):
    for load in (1.0,1.5,2.5):
        row=[]
        for tier in (1.0,0.5,0.25):
            m,z=scen.m7_mc(tier,load,bugs,runs=600)
            row.append(round(m,2))
        print("bug",bugs,"yuk carpani",load,"eko/std/kur olay",row, "std/eko", round(row[1]/row[0],2), "kur/std", round(row[2]/row[1],2))
