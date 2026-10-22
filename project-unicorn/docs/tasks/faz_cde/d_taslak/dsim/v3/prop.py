# Oneri kosulari: modeli degistirmez; sabit/kural degisikligi ortam degiskeniyle, sonuc ayri dosyaya (out/P_*.pkl).
import pickle, time
SEEDS = range(1, 21)
W = 4
def runenv(env, names, tag, opt=None):
    old = {k: os.environ.get(k) for k in env}
    os.environ.update(env)
    try:
        t = time.time()
        R_ = run_many(names, SEEDS, opt=opt, workers=W)
        pickle.dump(R_, open("out/P_%s.pkl" % tag, "wb"))
        print(tag, "tamam", round(time.time() - t), "sn", flush=True)
    finally:
        for k, v in old.items():
            if v is None: os.environ.pop(k, None)
            else: os.environ[k] = v
which = sys.argv[3:]
arz_names = ["A|S5|kaynakli|2", "A|S6|kaynakli|2", "R|S5|330", "R|S6|330", "GC|kaynakli"]
if "p16" in which:
    runenv({"D3_DEPTHMAX": "8"}, arz_names, "p16_d8")
    runenv({"D3_DEPTHMAX": "99"}, arz_names, "p16_dinf")
    runenv({"D3_DEPTHDIV": "5"}, arz_names, "p16_div5")
if "p19" in which:
    runenv({"D3_FILLSKIP": "12"}, ["A|S%d|kaynakli|%d" % (b, sw) for b in range(1, 7) for sw in (1, 2)], "p19_skip12")
if "p11" in which:
    runenv({}, ["PM6_1", "PM6_3", "PM6_5", "PM7_1", "PM7_3", "PM7_5"], "p11")
if "p22" in which:
    names = ["EA0", "EA1", "EA3", "EA7", "EA3_lidersiz", "EA7_lidersiz"] + [k for k in SCEN if k.startswith("EA3 +") or k.startswith("EA7 +")]
    runenv({"D3_TEAMLOSS": "0.01"}, names, "p22_kayip1")
if "p16b" in which:
    runenv({"D3_DEPTHMAX": "8", "D3_FILLSKIP": "12"}, arz_names + ["A|S%d|kaynakli|2" % b for b in range(1, 5)], "p16b_d8skip")
if "p16c" in which:
    runenv({"D3_DEPTHMAX": "8", "D3_DEPTHDIV": "5"}, arz_names, "p16c_d8div5")
if "pfix" in which:
    runenv({"D3_FIXMIN": "2.5"}, ["A|S1|kaynakli|1", "A|S2|kaynakli|1", "A|S3|kaynakli|1"], "pfix_min25")
if "p22b" in which:
    names = ["EA3", "EA7", "EA3_lidersiz", "EA7_lidersiz"] + [k for k in SCEN if k.startswith("EA3 +") or k.startswith("EA7 +")]
    runenv({"D3_TEAMLOSSMODE": "marjinal"}, names, "p22b_marjinal")
if "p16d" in which:
    runenv({"D3_DEPTHMAX": "99", "D3_DEPTHDIV": "5"}, arz_names, "p16d_dinfdiv5")
