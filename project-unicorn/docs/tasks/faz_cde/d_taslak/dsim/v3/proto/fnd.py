names=[k for k in SCEN if k.startswith("g_dev_") or k.startswith("g_dev1_") or k.startswith("g_test_")]
R,M=rec_many(names, range(1,21))
for n in names:
    print("%-10s"%n, " ".join("%s=%.2f"%(k, medof(M,n,k)) for k in ["deliv","founder_w","mvp","esc_card","idle_w"]))
