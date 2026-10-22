import pickle, statistics
for tag in ("before","after"):
    R = pickle.load(open("results_%s.pkl" % tag, "rb"))
    for a,b in (("S4","S4 +3* tasarimci"),("C47","C48"),("S3","S3 +3* tasarimci")):
        d=[R[b][s]["deliv"]-R[a][s]["deliv"] for s in range(1,21)]
        print(tag, a,"->",b, "lower", sum(1 for x in d if x<-1e-9), "equal", sum(1 for x in d if abs(x)<1e-9), "higher", sum(1 for x in d if x>1e-9), "med", statistics.median(d), "mean", round(statistics.mean(d),2),
              "wip", round(statistics.median(R[a][s]["wip"] for s in range(1,21)),1), round(statistics.median(R[b][s]["wip"] for s in range(1,21)),1),
              "lead", round(statistics.median(R[a][s]["lead"] for s in range(1,21)),2), round(statistics.median(R[b][s]["lead"] for s in range(1,21)),2))
