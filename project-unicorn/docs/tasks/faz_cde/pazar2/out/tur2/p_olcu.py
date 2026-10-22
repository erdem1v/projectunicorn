# Sektor profil ayrisma olcusu. Oyun kodunu okumaz; yalniz P_profiles.json yazar ve metrikleri basar.
import json, itertools, statistics, sys, os

MODS = ["FIN","FAT","SAL","IK","STK","URT","DEP","MAG","PRJ","VAR"]
NAME = {"FIN":"Finans ve Muhasebe","FAT":"Fatura ve e-Belge","SAL":"Satın Alma","IK":"İK ve Bordro","STK":"Stok",
        "URT":"Üretim","DEP":"Depo ve Sevkiyat","MAG":"Mağaza ve Kanal","PRJ":"Proje ve Zaman","VAR":"Varlık ve Bakım"}
ORD = {"Z":3,"S":2,"N":1,"-":0}

# sektor: (hucreler FIN..VAR, kanit K/V FIN..VAR, onemli modul adaylari, not)
SEC = {
 "manufacturing":("ZZZZZZSN-S","KKKKKKVVVV",["URT"],"Üretim derinliği: MRP, kalite, izlenebilirlik"),
 "textile":      ("ZZZZZZSS-N","KKKKKKVVVV",["STK","URT"],"Stok kademesi beden-renk varyantı; fason üretim"),
 "logistics":    ("ZZZZZ-ZN-S","KKVKKVKVVV",["DEP","VAR"],"Taşıma yönetimi ve filo bakımı"),
 "retail":       ("ZZZZZ-SZ-N","KKKKKVKKVV",["MAG","STK"],"POS ve çok mağazalı stok"),
 "ecommerce":    ("ZZSZZ-ZZ--","KKVKKVKKVV",["MAG","DEP"],"Kanal, pazaryeri, iade"),
 "technology":   ("ZZSZ----Z-","KKVKVVVVKV",["PRJ","FAT"],"Abonelik faturası, proje ve zaman"),
 "legal":        ("ZZSZ----Z-","KKVKVVVVKV",["PRJ"],"Saat bazlı zaman ve faturalama"),
 "media":        ("ZZSZ----S-","KKVKVVVVVV",["PRJ"],"Proje bazlı iş maliyeti"),
 "finance":      ("ZSSZ----NN","KVVKVKKKVV",["FIN"],"Arka ofis: ERP çekirdek sistem değildir"),
 "insurance":    ("ZSSZ----NN","KVVKVKKKVV",["FIN"],"Arka ofis: poliçe ve hasar başka sistemde"),
 "construction": ("ZZZZS-N-ZZ","KKKKVVVVKK",["PRJ","VAR"],"İş maliyeti, hakediş, ekipman"),
 "real_estate":  ("ZZSZ----SZ","KVVKVVVVVK",["VAR","FAT"],"Mülk ve kira bedeli"),
 "health":       ("ZZZZZ---NS","KKKKVKVVVV",["STK","VAR"],"Tıbbi malzeme, lot ve son kullanma"),
}
for k,(c,e,o,n) in SEC.items():
    assert len(c)==10 and len(e)==10,(k,len(c),len(e))

def row(k): return dict(zip(MODS,SEC[k][0]))
def ev(k): return dict(zip(MODS,SEC[k][1]))

# Gruplamalar: profil adi -> (uyeler, lider sektor)
G7 = {
 "İmalat":(["manufacturing","textile"],"manufacturing"),
 "Dağıtım ve Lojistik":(["logistics"],"logistics"),
 "Perakende":(["retail"],"retail"),
 "E-ticaret":(["ecommerce"],"ecommerce"),
 "Hizmet":(["technology","legal","media","finance","insurance"],"technology"),
 "İnşaat ve Gayrimenkul":(["construction","real_estate"],"construction"),
 "Sağlık":(["health"],"health"),
}
G9 = {
 "İmalat":(["manufacturing","textile"],"manufacturing"),
 "Dağıtım ve Lojistik":(["logistics"],"logistics"),
 "Perakende":(["retail"],"retail"),
 "E-ticaret":(["ecommerce"],"ecommerce"),
 "Hizmet":(["technology","legal","media"],"technology"),
 "Mali Hizmetler":(["finance","insurance"],"finance"),
 "İnşaat":(["construction"],"construction"),
 "Gayrimenkul":(["real_estate"],"real_estate"),
 "Sağlık":(["health"],"health"),
}
G13 = {k:([k],k) for k in SEC}

def profile_table(G):
    t={}
    for p,(mem,lead) in G.items():
        t[p]={m:{"v":row(lead)[m],"e":ev(lead)[m]} for m in MODS}
    return t

# indirgeme
def max_cell(a,b): return a if ORD[a]>=ORD[b] else b
SETS = {
 "10":{"mods":MODS,"fold":lambda r:{m:r[m] for m in MODS}},
 "7":{"mods":["FIN","FAT","SAL","IK","STK","TED","PRJ"],
      "fold":lambda r:{"FIN":r["FIN"],"FAT":r["FAT"],"SAL":r["SAL"],"IK":r["IK"],"STK":r["STK"],
                       "TED":max_cell(r["URT"],r["DEP"]),"PRJ":r["PRJ"]}},
 "5":{"mods":["FIN","FAT","SAL","STK","IK"],
      "fold":lambda r:{m:r[m] for m in ["FIN","FAT","SAL","STK","IK"]}},
}

def metrics(G,setkey):
    S=SETS[setkey]; mods=S["mods"]
    tbl={p:S["fold"]({m:profile_table(G)[p][m]["v"] for m in MODS}) for p in G}
    names=list(G)
    zset={p:frozenset(m for m in mods if tbl[p][m]=="Z") for p in names}
    full={p:tuple(tbl[p][m] for m in mods) for p in names}
    distinct_z=len(set(zset.values()))
    distinct_full=len(set(full.values()))
    pairs=list(itertools.combinations(names,2))
    diffs=[sum(1 for m in mods if tbl[a][m]!=tbl[b][m]) for a,b in pairs]
    zdiffs=[len(zset[a]^zset[b]) for a,b in pairs]
    identical_pairs=[(a,b) for (a,b),d in zip(pairs,diffs) if d==0]
    sigZ={};sigZS={}
    for p in names:
        sigZ[p]=[m for m in mods if tbl[p][m]=="Z" and sum(1 for q in names if tbl[q][m]=="Z")<=2]
        sigZS[p]=[m for m in mods if tbl[p][m] in "ZS" and sum(1 for q in names if tbl[q][m] in "ZS")<=2]
    dead_Z=[m for m in mods if not any(tbl[p][m]=="Z" for p in names)]
    dead_ZS=[m for m in mods if not any(tbl[p][m] in "ZS" for p in names)]
    nz={p:len(zset[p]) for p in names}
    return {"profil_sayisi":len(names),"ayirt_edilebilir_Z":distinct_z,"ayirt_edilebilir_tam":distinct_full,
            "ort_cift_fark":round(statistics.mean(diffs),2),"min_cift_fark":min(diffs),
            "ort_cift_Z_fark":round(statistics.mean(zdiffs),2),
            "ozdes_ciftler":identical_pairs,
            "imza_Z":{p:len(v) for p,v in sigZ.items()},"imza_Z_modul":sigZ,
            "imza_ZS":{p:len(v) for p,v in sigZS.items()},
            "imzasiz_profil_Z":[p for p in names if not sigZ[p]],
            "olu_Z":dead_Z,"olu_ZS":dead_ZS,"Z_sayisi":nz,"tablo":tbl}

def coherence(G):
    # profildeki sektorun hucresi profilden ne kadar ayriliyor
    out={}
    tot_any=tot_abs=0
    for p,(mem,lead) in G.items():
        for s in mem:
            if s==lead: continue
            for m in MODS:
                d=abs(ORD[row(s)[m]]-ORD[row(lead)[m]])
                if d>=1:
                    out.setdefault(p,[]).append((s,m,row(s)[m],row(lead)[m],d))
                    tot_any+=1
                    if d>=2: tot_abs+=1
    return {"farkli_hucre":tot_any,"absurt_hucre_fark2plus":tot_abs,"ayrinti":out}

def sector_dist():
    ss=list(SEC)
    res=[]
    for a,b in itertools.combinations(ss,2):
        d=sum(1 for m in MODS if row(a)[m]!=row(b)[m])
        dz=sum(1 for m in MODS if (row(a)[m]=="Z")!=(row(b)[m]=="Z"))
        res.append((a,b,d,dz))
    return res

if __name__=="__main__":
    R={}
    for gname,G in [("G7",G7),("G9",G9),("G13",G13)]:
        R[gname]={k:metrics(G,k) for k in SETS}
        R[gname]["tutarlilik"]=coherence(G)
    sd=sector_dist()
    for g in R:
        for k in SETS:
            m=R[g][k]
            print(g,k,"profil",m["profil_sayisi"],"ayirtZ",m["ayirt_edilebilir_Z"],"ayirtTam",m["ayirt_edilebilir_tam"],
                  "ortfark",m["ort_cift_fark"],"minfark",m["min_cift_fark"],"ortZfark",m["ort_cift_Z_fark"],
                  "olu_Z",m["olu_Z"],"olu_ZS",m["olu_ZS"])
            print("   imzaZ",m["imza_Z"]," imzasiz",m["imzasiz_profil_Z"]," ozdes",m["ozdes_ciftler"])
            print("   imzaZS",m["imza_ZS"])
            print("   Zsayisi",m["Z_sayisi"])
        c=R[g]["tutarlilik"]
        print(g,"tutarlilik farkli",c["farkli_hucre"],"absurt",c["absurt_hucre_fark2plus"])
        for p,l in c["ayrinti"].items(): print("   ",p,l)
    print("SEKTOR CIFTLERI fark<=2:")
    for a,b,d,dz in sorted(sd,key=lambda x:x[2]):
        if d<=3: print("  ",a,b,"tam fark",d,"Z fark",dz)
    print("ort sektor cifti fark",round(statistics.mean(x[2] for x in sd),2),"min",min(x[2] for x in sd))
    pass
