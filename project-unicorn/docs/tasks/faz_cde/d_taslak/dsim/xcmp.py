import pickle, statistics
B = pickle.load(open("results_before.pkl","rb")); Aft = pickle.load(open("results_after.pkl","rb"))
S = range(1,21)
def md(R,n,k): 
    v=[R[n][s][k] for s in S if R[n][s][k] is not None]; return statistics.median(v) if v else None
def bs(R,n,w): return (sum(R[n][s]["bs_"+w][0] for s in S), sum(R[n][s]["bs_"+w][1] for s in S))
def bott(R,n):
    left=[statistics.median(R[n][s]["left"][i] for s in S) for i in range(3)]
    return ["Tasarim","Gelistirme","Test"][max(range(3),key=lambda i:left[i])] if max(left)>1 else "yok"
names=["S1","S2","S3","S4","S5","S6","S7","S8","S8_ek_testkutulu_gel","S9a","S9b","S10","S11","S11_ek_testci","S11b","S12","S3_PM_testkutulu","C47","C48"]
for n in names:
    row=[n]
    for R in (B,Aft):
        row.append("deliv %.1f lead %.2f wip %.1f idle %.1f esc %.2f open %.1f omax %s fixL %.3f bsL %s bsE %s cons %d slope %.3f bott %s" % (
            md(R,n,"deliv"), md(R,n,"lead") or 0, md(R,n,"wip"), md(R,n,"idle_w"), md(R,n,"esc_card"), md(R,n,"open_med") or 0, md(R,n,"open_max"),
            md(R,n,"fix_late") or 0, bs(R,n,"late"), bs(R,n,"early"), sum(1 for s in S if R[n][s]["consec"]), md(R,n,"slope") or 0, bott(R,n)))
    print(row[0]); print("  ONCE ", row[1]); print("  SONRA", row[2])
    if "stop_phase" in Aft[n][1]:
        print("  stop", [sum(Aft[n][s]["stop_phase"][i] for s in S) for i in range(3)], "fix_deferred", sum(Aft[n][s]["fix_deferred"] for s in S))
# genel
binds=[(n,[sum(Aft[n][s]["stop_phase"][i] for s in S) for i in range(3)]) for n in Aft if sum(sum(Aft[n][s]["stop_phase"]) for s in S)>0]
print("ceiling binds in", len(binds), "of", len(Aft)); print(binds)
dfr=[(n,sum(Aft[n][s]["fix_deferred"] for s in S)) for n in Aft if sum(Aft[n][s]["fix_deferred"] for s in S)>0]
print("fix deferred", dfr)
# en buyuk teslim farki
diffs=sorted(((md(Aft,n,"deliv")-md(B,n,"deliv"))/md(B,n,"deliv"), n, md(B,n,"deliv"), md(Aft,n,"deliv")) for n in Aft)
print("en dusuk", diffs[:6]); print("en yuksek", diffs[-6:])
print("changed count", sum(1 for d in diffs if abs(d[0])>1e-9))
# S1 tohum bazinda
print("S1 seeds over 5% late", sum(1 for s in S if Aft["S1"][s]["bs_late"][0]/max(1,Aft["S1"][s]["bs_late"][1])>0.05))
print("S1 open med per seed before", sorted(B["S1"][s]["open_med"] for s in S)); print("after", sorted(Aft["S1"][s]["open_med"] for s in S))
print("S1 openmax before", sorted(B["S1"][s]["open_max"] for s in S)); print("after", sorted(Aft["S1"][s]["open_max"] for s in S))
print("S1 fix_early", md(B,"S1","fix_early"), md(Aft,"S1","fix_early"))
