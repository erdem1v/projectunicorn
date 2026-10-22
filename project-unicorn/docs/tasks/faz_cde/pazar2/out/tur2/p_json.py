import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import p_olcu as P

here=os.path.dirname(os.path.abspath(__file__))
G=P.G9
tbl=P.profile_table(G)
ids={"manufacturing":"manufacturing"}
out={"surum":"tur2/P_sektor_profil","tarih":"2026-10-20","uyari":"Hücre değerleri kalibrasyon girdisidir [WORKING]; K = kaynaklı (en az bir Orta+ açılmış kaynak ya da iki bağımsız Düşük kaynak), V = varsayım. Z için K şartı konmadı: V olan Z hücreleri 'sahip kararı' ya da 'taban' notuyla işaretli.",
 "moduller":{m:P.NAME[m] for m in P.MODS},
 "deger":{"Z":"her zaman ister","S":"sık ister (olasılık 40-60% WORKING)","N":"nadir ister (5-15% WORKING)","-":"hiç istemez"},
 "profiller":{p:{"uyeler":G[p][0],"lider_sektor":G[p][1],"moduller":tbl[p]} for p in G},
 "sektor_profil_onerilen":{s:p for p,(mem,_) in G.items() for s in mem},
 "sektor_profil_alternatif_7":{s:p for p,(mem,_) in P.G7.items() for s in mem},
 "sektor_hucreleri":{s:{"moduller":{m:{"v":P.row(s)[m],"e":P.ev(s)[m]} for m in P.MODS},
                        "onemli_modul_adaylari":P.SEC[s][2],"not":P.SEC[s][3]} for s in P.SEC},
 "indirgeme":{
   "7":{"moduller":P.SETS["7"]["mods"],"katlama":{"FIN":"FIN","FAT":"FAT","SAL":"SAL","IK":"IK","STK":"STK","URT":"TED","DEP":"TED","PRJ":"PRJ","MAG":None,"VAR":None},
        "TED_hucre_kurali":"max(URT,DEP) sırası Z>S>N>-","dusenler":["MAG","VAR"]},
   "5":{"moduller":P.SETS["5"]["mods"],"katlama":{"FIN":"FIN","FAT":"FAT","SAL":"SAL","IK":"IK","STK":"STK","URT":None,"DEP":None,"MAG":None,"PRJ":None,"VAR":None},
        "dusenler":["URT","DEP","MAG","PRJ","VAR"]}},
 "indirgenmis_profiller":{},
 "kayip":{},
 "olcu":{}}
for k in ("7","5"):
    S=P.SETS[k]
    red={}; loss={}
    for p in G:
        cells={m:tbl[p][m]["v"] for m in P.MODS}
        red[p]=S["fold"](cells)
        if k=="7":
            lost=[m for m in ("MAG","VAR") if cells[m] in "ZS"]
        else:
            lost=[m for m in ("URT","DEP","MAG","PRJ","VAR") if cells[m] in "ZS"]
        loss[p]=lost
    out["indirgenmis_profiller"][k]=red
    out["kayip"][k]=loss
for gname,GG in (("G9_onerilen",P.G9),("G7_alternatif",P.G7),("G13_sektor",P.G13)):
    out["olcu"][gname]={}
    for k in P.SETS:
        m=P.metrics(GG,k)
        m.pop("tablo")
        m["ozdes_ciftler"]=[list(x) for x in m["ozdes_ciftler"]]
        out["olcu"][gname][k]=m
    out["olcu"][gname]["tutarlilik"]=P.coherence(GG)
    out["olcu"][gname]["tutarlilik"]["ayrinti"]={p:[list(x) for x in v] for p,v in out["olcu"][gname]["tutarlilik"]["ayrinti"].items()}
json.dump(out,open(os.path.join(here,"P_profiles.json"),"w",encoding="utf-8"),ensure_ascii=False,indent=1)
# dogrula
d=json.load(open(os.path.join(here,"P_profiles.json"),encoding="utf-8"))
print("json ok", len(d["profiller"]),"profil", len(d["sektor_profil_onerilen"]),"sektor")
kv={"K":0,"V":0}
for p in tbl:
    for m in P.MODS: kv[tbl[p][m]["e"]]+=1
print("G9 profil hucre K/V",kv)
for p in G:
    print(p,"|"," ".join(f"{m}:{tbl[p][m]['v']}{tbl[p][m]['e']}" for m in P.MODS))
for k in ("7","5"):
    print("kayip",k,out["kayip"][k])
    for p,r in out["indirgenmis_profiller"][k].items(): print("  ",k,p,r)
