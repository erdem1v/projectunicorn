import sys, time
for nm in sys.argv[3:] or ["S1","S3"]:
    t=time.time()
    _,_,m = run_one((nm, 1))
    keys=["n","mvp","deliv","cards_sprint","esc100","open_med","fix_late","bs_late","idle_pct","fillplan","pulls","pred","ready","unfin"] if False else ["n","mvp","deliv","cards_sprint","esc100","open_med","fix_late","bs_late","idle_pct","pred","ready"]
    print(nm, {k: (round(v,3) if isinstance(v,float) else v) for k,v in m.items() if k in keys}, "%.1fs"%(time.time()-t), flush=True)
