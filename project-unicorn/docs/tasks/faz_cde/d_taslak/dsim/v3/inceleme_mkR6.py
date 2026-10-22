import shutil, os
exec(open("dgroups.py", encoding="utf-8").read())
def fn(nm): return nm.replace("|", "_").replace(" ", "_").replace("*", "x").replace("+", "p") + ".pkl"
skip = {fn(n) for g in ("A", "S", "SK", "HUY") for n, _ in GROUPS[g]}
os.makedirs("out/R6", exist_ok=True)
k = 0
for f in os.listdir("out/R5"):
    if f not in skip:
        shutil.copy2("out/R5/" + f, "out/R6/" + f); k += 1
print("kopya", k, "atlanan", len(skip), "R5", len(os.listdir("out/R5")))
