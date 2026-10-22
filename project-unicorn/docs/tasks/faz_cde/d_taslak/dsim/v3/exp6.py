import statistics
FOUNDERS_=["orta","gel4","gel5","tasarim_test"]
SEQS_=["gel-tas-test","tas-gel-test","test-gel-tas","pm-gel-tas","1yildiz","uc-gel"]
late = 0; flat = 0; tot = 0
for f in FOUNDERS_:
    for s_ in SEQS_:
        prev = None
        for k in range(4):
            nm = "G|%s|%s|%d" % (f, s_, k)
            ms = []; dv = []
            for sd in range(1, 21):
                _, _, m = run_one((nm, sd)); ms.append(m["mvp"]); dv.append(m["deliv"])
            mv, d = statistics.median(ms), statistics.median(dv)
            if prev is not None:
                tot += 1
                if mv > prev[0]: late += 1; print("MVP gecikme", nm, prev[0], "->", mv)
                if d - prev[1] <= 0: flat += 1; print("teslim artmadi", nm, prev[1], "->", d)
            prev = (mv, d)
print("adim", tot, "MVP gecikme", late, "teslim artmadi", flat)
