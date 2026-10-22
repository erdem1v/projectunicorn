import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import k5, bot, econ
for b2c in (False, True):
    mk = "b2c" if b2c else "b2b"
    for seed in (7, 11):
        run = k5.load(bot.run_name("worst", seed, b2c))
        for lab, v in (("eski", None), ("A", {}), ("C maas x1.5", {"sal_mult": 1.5})):
            rows = econ.monthly(run, mk, v)
            s = econ.summarize(rows)
            print(mk, seed, lab, "dip", s["dip"], "c52", s["c52"], "c101", s["c101"], "ilk_pos", s["first_pos"], "surd", s["sustained"],
                  "faz burn", {p: (round(s[p]["burn_rec"]), round(s[p]["net"])) if s[p] else None for p in (1,2,3)},
                  "minrw", {p: (round(x,1) if x else None) for p,x in s["min_runway"].items()}, "mincash", s["mincash"],
                  "sunucu%", {k: (round(x,1) if x else None) for k,x in econ.share_by_period(rows).items()})
