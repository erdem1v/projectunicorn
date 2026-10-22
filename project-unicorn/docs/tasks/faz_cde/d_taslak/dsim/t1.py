r = run_many(["S1","S2"], range(1,21))
for n,d in r.items():
    print(n, "deliv", sorted(round(m["deliv"],2) for m in d.values()))
    print(n, "mvp", sorted(m["mvp"] for m in d.values()), "esc", statistics.median(m["esc_card"] for m in d.values()), "open", statistics.median(m["open_med"] for m in d.values()), "fixlate",statistics.median(m["fix_late"] for m in d.values()), "bs", sum(m["bs_late"][0] for m in d.values()), sum(m["bs_late"][1] for m in d.values()))
