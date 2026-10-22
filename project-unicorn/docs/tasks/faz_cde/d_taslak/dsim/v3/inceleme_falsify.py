import os
SRC = open("dsim3.py", encoding="utf-8").read().split('\nif __name__ == "__main__":')[0]
def run(src, name, seed=1, weeks=30):
    g = {"__name__": "x"}
    exec(compile(src, "dsim3_variant", "exec"), g)
    fn, kw = g["SCEN"][name]
    kw = dict(kw); kw["weeks"] = weeks
    s = g["Sim"](fn(), seed, **kw); s.run()
    return s.aud
A = 'es.sort(key=lambda pi: (-team.rate[pi][r], team.ids[pi]))'
B = """            if UNFITCOND and hasfront:
                continue
"""
assert SRC.count(A) == 1 and SRC.count(B) == 1
for nm in ("S5", "HUY|S4"):
    print(nm, "dogru kod:", {k: v for k, v in run(SRC, nm).items() if k in ("rows", "inv", "wk_inv")},
          "| kisi sirasi ters (FAIL beklenir):", {k: v for k, v in run(SRC.replace(A, A.replace("-team.rate", "team.rate")), nm).items() if k in ("rows", "inv", "wk_inv")})
nm = "S3_PM_testkutulu"
print(nm, "dogru kod:", {k: v for k, v in run(SRC, nm).items() if k.startswith("unfit")},
      "| kosul kapali (FAIL beklenir):", {k: v for k, v in run(SRC.replace(B, ""), nm).items() if k.startswith("unfit")})
