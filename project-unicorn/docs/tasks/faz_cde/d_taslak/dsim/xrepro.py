import pickle
B = pickle.load(open("results_before.pkl","rb"))
names=["S1","C47","C48","S11","S4 +3* tasarimci"]
res=run_many(names, range(1,21))
bad=0
for n in names:
    for s in range(1,21):
        for k in ("deliv","esc_card","open_med","bs_late","lead"):
            if res[n][s][k]!=B[n][s][k]: bad+=1
print("farkli alan sayisi", bad)
