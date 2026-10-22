import time
for nm in ["GT|orta|gel-tas-test|3","G|gel4|1yildiz|3","A|S4|kaynakli|2","A|S4|sonlu|1","R|S4|100","D5|S3|nofix","GC|kaynakli","EA3","EA7"]:
    t=time.time()
    _,_,m = run_one((nm,1))
    print(nm, "%.1fs"%(time.time()-t), {k:(round(v,3) if isinstance(v,float) else v) for k,v in m.items() if k in ("n","mvp","deliv","idle_pct","pool_ok","nocard","fill_ratio","req","pts_src","stops","asked","pred","cell_n","cell_mult","cell_deliv","bott")})
