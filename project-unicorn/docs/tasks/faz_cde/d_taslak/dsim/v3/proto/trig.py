names=["S1","S2","S3","S4","S5","S6","S7","S8_hepsi_testkutulu","S10","S11b"]
res=run_many(names, range(1,11))
for n in names:
    print("%-22s"%n, " ".join("%s=%s"%(k, round(medof(res,n,k),3)) for k in ["deliv","esc_card","esc100","open_med","open_max","found_sp","K_sp","nfix_sp","q_any","q_heavy","q_ratio","q_s10","q_s15","q_s25","infix","fix_late","mvp"]))
