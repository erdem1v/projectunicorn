names=["C30","C31","C36","C37"]
R,M=rec_many(names, range(1,21))
for n in names: print(n, " ".join("%s=%.2f"%(k, medof(M,n,k)) for k in ["deliv","cards_sprint","wip","idle_w","ready"]))
