import pickle, statistics
out=pickle.load(open("big.pkl","rb"))
def md(Mx,n,k):
    v=[m[k] for m in Mx[n].values() if m[k] is not None]
    return statistics.median(v) if v else float('nan')
keys=["deliv","esc100","open_med","open_max","fix_late","K_sp","asked","shipped_k","lead","q_qr"]
for pol in out:
    R,M=out[pol]
    for n in ["S1","S3","S4","S5","S6","S10"]:
        a=sum(m["bs_all"][0] for m in M[n].values()); b=sum(m["bs_all"][1] for m in M[n].values())
        print("%-12s %-5s"%(pol,n)," ".join("%s=%.3f"%(k,md(M,n,k)) for k in keys), "hs=%d/%d"%(a,b))
