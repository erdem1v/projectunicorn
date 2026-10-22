# D0s kosu gruplari. dbatch.py tarafindan exec edilir (dsim3.py'nin globalleriyle). GROUPS: ad -> [(senaryo, secenekler | None)].
# Tohumlar: varsayilan 1..20; GROUP_SEEDS ile degisir. Sonuclar out/<etiket>/<senaryo>[#<secenek>].pkl (tohum -> metrikler).
S6L = ["S1", "S2", "S3", "S4", "S5", "S6"]


def _n(names, opt=None):
    return [(n, opt) for n in names]


GROUPS = {}
GROUP_SEEDS = {}

# --- eski gruplar (collect.py), yeni oynatmayla; sinirsiz arz, 60 hafta
GROUPS["A"] = _n(["S1", "S2", "S3", "S4", "S5", "S6", "S7", "S7_1test", "S8", "S8_ek_testkutulu_gel", "S8_hepsi_testkutulu", "S9a", "S9a_ek_gel", "S9b",
                  "S10", "S11", "S11_ek_testci", "S11b", "S12", "S3_PMsiz", "S3_PM_testkutulu", "S4_PMsiz", "S4_1PM", "S5_1PM"])
GROUPS["B"] = _n([k for k in SCEN if " +" in k and k.split(" ")[0] in ("S2", "S3", "S4", "S5", "S6")])
GROUPS["C"] = _n(["C%d" % n for n in range(1, 51)])
GROUPS["D"] = _n([k for k in SCEN if k[:2] in ("T3", "T4", "T5") or k.startswith("PM")])
GROUPS["E"] = _n([k for k in SCEN if k.startswith("G|") or k.startswith("GT|")])
GROUPS["F"] = [(n, {"policy": pol}) for pol in ("birak", "gonder", "esikli", "hep_gonder") for n in ("S1", "S2", "S3", "S4", "S5", "S6", "S10")]
GROUPS["G"] = _n(["A|%s|%s|2" % (b, a) for b in S6L for a in ("sonlu", "kaynakli")] + ["GC|sonlu", "GC|kaynakli"])
GROUPS["R"] = _n([k for k in SCEN if k.startswith("R|")])
GROUPS["I"] = _n([k for k in SCEN if k.startswith("D5|")])
GROUPS["G2"] = [("A|%s|sonlu|2" % b, {"weeks": 140}) for b in S6L]

# --- D0s yeni gruplar
GROUPS["REP"] = _n([k for k in SCEN if k.startswith("REP|")])
GROUPS["PR"] = _n(["PR|%s" % b for b in S6L])
GROUPS["DEP"] = _n(["DEP|%s" % b for b in S6L] + ["GC|kaynakli"])
GROUPS["HUY"] = _n(["HUY|S3", "HUY|S4"])
GROUPS["SK"] = _n(["A|%s|kaynakli|2" % b for b in S6L] + ["GC|kaynakli"])          # arz kipi (kaynakli) + buyume egrisi
GROUPS["S"] = _n(S6L)                                                                # olcek 1, 3, 6, 12, 25, 50
GROUPS["S16"] = _n(["S1", "S2", "S3", "S4", "S5", "S6", "S10"])
GROUPS["TST"] = _n(S6L + ["S7", "S9b", "S10"] + [k for k in SCEN if k[:2] in ("T3", "T4", "T5")])      # testci kolu


# PM adimlari: kisi ekleme egrisinde eklenen kisinin PM oldugu adimlar (n-1 -> n) ve tabanlara +PM
def _pm_steps():
    out = []
    for n in range(2, 51):
        if curve_roles(n)[-1] == "pm":
            out += ["C%d" % (n - 1), "C%d" % n]
    return out


PMSTEP = _pm_steps()
GROUPS["PMC"] = _n(PMSTEP + ["S2", "S2 +3* PM", "S3", "S3 +3* PM", "S4", "S4 +3* PM", "S5", "S5 +3* PM", "S6", "S6 +3* PM",
                             "G|orta|pm-gel-tas|0", "G|orta|pm-gel-tas|1", "G|orta|pm-gel-tas|2", "G|orta|pm-gel-tas|3"])
GROUPS["PM3"] = _n(["C36", "C37"])               # PRD'nin "-2,5" adimi
GROUP_SEEDS["PM3"] = range(1, 101)
GROUP_SEEDS["PMC"] = range(1, 21)
GROUP_SEEDS["PMC60"] = range(1, 61)
GROUPS["PMC60"] = GROUPS["PMC"]
GROUPS["UF"] = _n(["S3", "S3_PM_testkutulu"])        # uymayan is kosulu (kapi uymayan_moral) acik ve kapali
GROUPS["PMC60"] = []                                  # kullanilmiyor (PM3: C36/C37 icin 100 tohum)
