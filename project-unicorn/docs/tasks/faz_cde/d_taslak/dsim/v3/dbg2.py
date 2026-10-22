import sys
nm = sys.argv[3]
fn, kw = SCEN[nm]
kw = dict(kw); kw["weeks"] = 2
sim = Sim(fn(), 1, **kw)
cell = sim.cells[0]
orig_prune = sim._prune
def pr(cell, base, acc):
    team, sw = cell.team, cell.sw
    print("ACC", len(acc), [(a[0].line, a[0].tier, a[1].remaining()) for a in acc])
    for m in range(len(acc)+1):
        cc = probe_sprint(team, base + [t for _, t, _ in acc[:m]], None, 0, sw, sim.seed)
        print(" m=%d unfinished=%d" % (m, unfinished(cc)), [(c.line, "F" if c.kind=="fix" else c.tier, c.phase(), round(sum(c.prog),1), round(c.remaining(),1)) for c in cc])
    return orig_prune(cell, base, acc)
sim._prune = pr
sim.run()
