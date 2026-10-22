import os
names=["S1","S3","S4"]
res=run_many(names, range(1,6))
for n in names:
    print(n, {k: round(medof(res,n,k),3) for k in ["deliv","esc_card","open_med","idle_w","fix_late","found_sp","K_sp","infix","founder_w","ready"]})
