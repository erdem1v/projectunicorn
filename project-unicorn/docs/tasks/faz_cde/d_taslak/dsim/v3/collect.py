# Toplu kosu: python -I dsim3.py exec collect.py <parti> [<parti> ...]   -> out/<parti>.pkl
import pickle, time
SEEDS = range(1, 21)
WORKERS = int(os.environ.get("D3_WORKERS", "4"))
TAG = os.environ.get("D3_TAG", "")      # oneri kosulari icin out/<parti><TAG>.pkl


def save(name, obj):
    pickle.dump(obj, open("out/%s%s.pkl" % (name, TAG), "wb"))


def batch(b):
    t = time.time()
    if b == "A":     # ana, uc bilesimler, PM/testci uc durumlari
        names = ["S1", "S2", "S3", "S4", "S5", "S6", "S7", "S7_1test", "S8", "S8_ek_testkutulu_gel", "S8_hepsi_testkutulu", "S9a", "S9a_ek_gel", "S9b",
                 "S10", "S11", "S11_ek_testci", "S11b", "S12", "S3_PMsiz", "S3_PM_testkutulu", "S4_PMsiz", "S4_1PM", "S5_1PM"]
        save("A", run_many(names, SEEDS, workers=WORKERS))
    elif b == "B":   # marjinal getiri
        names = [k for k in SCEN if " +" in k and k.split(" ")[0] in ("S2", "S3", "S4", "S5", "S6")]
        save("B", run_many(names, SEEDS, workers=WORKERS))
    elif b == "C":   # kisi ekleme egrisi
        save("C", run_many(["C%d" % n for n in range(1, 51)], SEEDS, workers=WORKERS))
    elif b == "D":   # testci ve PM yildizi
        names = [k for k in SCEN if k[:2] in ("T3", "T4", "T5", "PM")]
        save("D", run_many(names, SEEDS, workers=WORKERS))
    elif b == "E":   # kurucu buyumesi
        names = [k for k in SCEN if k.startswith("G|") or k.startswith("GT|")]
        save("E", run_many(names, SEEDS, workers=WORKERS))
    elif b == "F":   # politika
        out = {}
        for pol in ("birak", "gonder", "esikli", "hep_gonder"):
            out[pol] = run_many(["S1", "S2", "S3", "S4", "S5", "S6", "S10"], SEEDS, opt={"policy": pol}, workers=WORKERS)
        save("F", out)
    elif b == "G":   # arz kipleri
        names = [k for k in SCEN if k.startswith("A|") or k.startswith("GC|")]
        save("G", run_many(names, SEEDS, workers=WORKERS))
    elif b == "R":   # istek payi
        names = [k for k in SCEN if k.startswith("R|")]
        save("R", run_many(names, SEEDS, workers=WORKERS))
    elif b == "H":   # EA takim
        names = [k for k in SCEN if k.startswith("EA")]
        save("H", run_many(names, SEEDS, workers=WORKERS))
    elif b == "H2":  # EA kisi ekleme (dagitimdan sonra eklenen kisi)
        names = [k for k in SCEN if k.startswith("EA3 +") or k.startswith("EA7 +")] + ["EA3", "EA7"]
        save("H2", run_many(names, SEEDS, workers=WORKERS))
    elif b == "H3":  # EA kisi ekleme, yalniz marjinal ve taban (oneri kosulari icin TAG ile)
        names = [k for k in SCEN if k.startswith("EA3 +") or k.startswith("EA7 +")] + ["EA3", "EA7", "EA0"]
        save("H3", run_many(names, SEEDS, workers=WORKERS))
    elif b == "G2":  # katalog tukenme haftasi (sonlu, 130 hafta)
        names = ["A|%s|sonlu|2" % b_ for b_ in ("S1", "S2", "S3", "S4", "S5", "S6")]
        save("G2", run_many(names, SEEDS, opt={"weeks": 140}, workers=WORKERS))
    elif b == "I":   # D5
        names = [k for k in SCEN if k.startswith("D5|")]
        save("I", run_many(names, SEEDS, workers=WORKERS))
    print("parti", b, "tamam", round(time.time() - t), "sn", flush=True)


for b in sys.argv[3:]:
    batch(b)
