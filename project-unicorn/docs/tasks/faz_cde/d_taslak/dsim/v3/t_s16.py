import time, pickle
t=time.time()
R=run_many(["S1","S2","S3","S4","S5","S6"], range(1,21))
pickle.dump(R, open("out/s16.pkl","wb"))
print("sure", round(time.time()-t))
for n in R:
    print(n, " ".join("%s=%.3f"%(k, medof(R,n,k)) for k in ["deliv","per_person","esc_card","esc100","open_med","fix_late","found_sp","K_sp","asked","infix","idle_w","mvp","pred"]),
          "hs", sum(m["bs_late"][0] for m in R[n].values()), "/", sum(m["bs_late"][1] for m in R[n].values()))
