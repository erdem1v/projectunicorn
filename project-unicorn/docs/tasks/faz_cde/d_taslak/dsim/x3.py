exec(open("analyze.py",encoding="utf-8").read())
for n in (46,47,48,49,50):
    print(n, [round(R["C%d"%n][s]["deliv"],1) for s in SEEDS], "cards/spr", [round(R["C%d"%n][s]["cards_sprint"],1) for s in SEEDS][:5], "fixes", med("C%d"%n,"fixes"))
