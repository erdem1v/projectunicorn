import sys
sys.path.insert(0, sys.argv[1])
import analyze as a
bo=a.econ(a.load_dir(a.B6M/"logs_B_open")); bf=a.econ(a.load_dir(a.B6M/"logs_B_free")); k5=a.econ(a.load_dir(a.B6M/"k5_runs_copy"))
def pct(n,o): return "%+.0f%%"%(100.0*(n-o)/o) if o else "n/a"
print("| koşu | MRR A -> açık (fark) | _free | kasa A -> açık (fark) | çalışan A/açık | hesap(B2B)/kitle(B2C) A -> açık (fark) |")
for n in sorted(bo):
    o,k,f=bo[n],k5[n],bf.get(n)
    b2c="b2c" in n
    sz=lambda d: d["aud"] if b2c else d["cust"]
    print("| %s | %d -> %d (%s) | %s | %d -> %d (%s) | %d/%d | %d -> %d (%s) |"%(n.replace("full_run_",""),k["mrr"],o["mrr"],pct(o["mrr"],k["mrr"]),
        ("%d (%s)"%(f["mrr"],pct(f["mrr"],k["mrr"]))) if f else "-",k["cash"],o["cash"],pct(o["cash"],k["cash"]),k["emp"],o["emp"],sz(k),sz(o),pct(sz(o),sz(k))))
