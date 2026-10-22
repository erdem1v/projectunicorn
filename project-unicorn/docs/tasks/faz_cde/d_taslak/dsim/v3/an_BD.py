exec(open("an_common.py", encoding="utf-8").read())
A = L("A"); B = L("B"); D = L("D")
print("== marjinal")
for base in ("S2","S3","S4","S5","S6"):
    bd = md(A, base, "deliv")
    row=[]
    for add in ("+3* gelistirici","+3* testci","+3* tasarimci","+3* PM","+1* gelistirici"):
        n = "%s %s" % (base, add)
        row.append("%+.1f(esc%.2f)" % (md(B, n, "deliv") - bd, md(B, n, "esc_card")))
    print(base, "%.1f" % bd, " ".join(row))
print("== testci/PM")
table(D, list(D.keys()), ["deliv","per_person","esc_card","esc100","found_sp","K_sp","asked","open_med","fix_late","ready"])
