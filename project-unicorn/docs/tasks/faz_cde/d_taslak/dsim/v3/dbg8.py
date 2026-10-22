exec(open("dan.py", encoding="utf-8").read())
for n in ("C40", "C41", "C42", "C43"):
    print(n, "roles", {r: m for r, m in sorted({r: sum(1 for x in next(iter(D("R", n).values()))["roles"][0] if x == r) for r in ("pm","des","dev","test","founder")}.items())},
          "deliv %.1f esc100 %.2f found_sp %.2f fix_late %.3f infix %.3f cards/sprint %.1f idle %.3f ratio %s open %.1f lead %.2f" % (md("R", n, "deliv"), md("R", n, "esc100"), md("R", n, "found_sp"), md("R", n, "fix_late"), md("R", n, "infix"), md("R", n, "cards_sprint"), md("R", n, "idle_pct"),
          [round(md("R", n, "ratio", i), 2) for i in range(3)], md("R", n, "open_med"), md("R", n, "lead")))
