exec(open("an_common.py", encoding="utf-8").read())
A = L("A")
vals = []
for s, m in A["S3_PM_testkutulu"].items():
    roles = m["roles"][0]; mor = m["morale"][0]
    vals.append(mor[roles.index("pm")])
print("PM moral (60 hf):", sorted(vals), "medyan", statistics.median(vals))
vals2 = [sum(m["morale"][0]) for m in A["S3"].values()]
print("S3 normal toplam moral", set(vals2))
# S1 MVP dagilimi
from collections import Counter
print("S1 MVP:", Counter(m["mvp"] for m in A["S1"].values()))
print("S3 PM testkutulu teslim", md(A,"S3_PM_testkutulu","deliv"), "S3", md(A,"S3","deliv"), "ready", md(A,"S3_PM_testkutulu","ready"))
