exec(open("analyze.py",encoding="utf-8").read())
prev=None
roles=R["C50"][1]["role"]
print("n rol teslim spr_cikti marj kisi esc bosta acik fix dar mvp")
for n in range(1,51):
    a=A["C%d"%n]
    m = None if prev is None else a["deliv"]-prev
    prev=a["deliv"]
    print(n, roles[n-1], f(a["deliv"]), f(a["sprint_out"]), f(m), f(a["per_person"],2), f(a["esc_card"],2), f(a["idle_w"]), f(a["open_med"]), pc(a["fix_late"]), a["bott"], f(a["mvp"],0), ratio(a["bs_late"]), a["consec"], "hz%s"%pc(a["ready"]))
