import pickle
names=["C%d"%n for n in range(1,51)]
R,M=rec_many(names, range(1,11))
pickle.dump(M, open("curve.pkl","wb"))
prev=None; worst=(0,None)
for n in names:
    d=medof(M,n,"deliv")
    mg = None if prev is None else d-prev
    if mg is not None and mg < worst[0]: worst=(mg,n)
    prev=d
print("worst", worst)
for n in ["C1","C2","C3","C6","C12","C25","C50"]:
    print(n, " ".join("%s=%.2f"%(k, medof(M,n,k)) for k in ["deliv","per_person","esc_card","open_med","open_max","fix_late","found_sp","K_sp","q_qr","idle_w","ready"]))
