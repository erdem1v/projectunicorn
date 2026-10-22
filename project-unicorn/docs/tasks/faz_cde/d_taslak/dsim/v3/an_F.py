exec(open("an_common.py", encoding="utf-8").read())
F = L("F")
print("== politika")
for n in ["S1","S2","S3","S4","S5","S6","S10"]:
    for pol in F:
        R = F[pol]
        print("%-4s %-11s" % (n, pol), " ".join("%s=%.3f" % (k, md(R, n, k)) for k in ["deliv","esc100","open_med","open_max","fix_early","fix_late","tot_fix","K_sp","asked","shipped_k","lead"]), "hs", hs(R, n), "ust", consec(R, n))
