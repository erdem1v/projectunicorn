# Rapor degerleri: out6/a6vals.json (a6hata.json, a6soz.json, a6tani.json ve ana sonuclardan). python -I a6vals.py
import os, sys, json, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a6tab as T

O = os.path.join(HERE, "out6")
ld = lambda f: json.load(open(os.path.join(O, f), encoding="utf-8")) if os.path.exists(os.path.join(O, f)) else {}
hata, soz, tani = ld("a6hata.json"), ld("a6soz.json"), ld("a6tani.json")
V = {}
c1 = lambda x: ("%.1f" % x).replace(".", ",")
c2 = lambda x: ("%.2f" % x).replace(".", ",")
c0 = lambda x: ("%.0f" % x)


def mean(tag, cal, arm, scen, metric):
    v = T.vals(tag, cal, arm, scen, metric)
    return statistics.mean(v.values()) if v else None


for sc in ("S3", "S6"):
    a, b = mean("ana", "E", "R", sc, "dogan"), mean("ana", "0", "R", sc, "dogan")
    if a and b:
        V["oran_E_" + sc] = c1(a / b)
    a = mean("ana", "H", "R", sc, "dogan")
    if a and b:
        V["oran_H_" + sc] = c2(a / b)
for sc in ("S3", "S4", "S5", "S6"):
    w = mean("ana", "H", "R", sc, "altinda")
    if w is not None:
        V["altinda_R_" + sc] = c1(100 * w)
for arm, key in (("T_np", "np"), ("T_min", "min"), ("T_np_min", "npmin"), ("T_plan", "plan"), ("T_plan_np", "plannp")):
    t = tani.get("H|" + arm)
    if t:
        V["tani_mvp_" + key] = c1(t["mvp"])
        V["tani_acik_" + key] = c1(t["acik"])
        V["tani_soz_" + key] = c1(t["soz"])
for arm in ("R", "T", "BK"):
    h = hata.get("H|PR|S2|" + arm)
    if h:
        V["hata_%s_PRS2_dogan100" % arm] = c2(h["dogan100"])
        V["hata_%s_PRS2_kacan" % arm] = c1(h["esc"])
        V["hata_%s_PRS2_fixn" % arm] = c1(h["fixn"])
        V["hata_%s_PRS2_fixwait" % arm] = c1(h["fixwait"])
        V["hata_%s_PRS2_found" % arm] = c1(h["found"])
for arm in ("R", "T", "BK"):
    s = soz.get("H|PR|S3|" + arm)
    if s:
        V["soz_%s_bulgu" % arm] = "%%%s" % c0(s["fix_late"])
        V["soz_%s_bulgu_ok" % arm] = "%%%s" % c0(s["fix_ok"])
        V["soz_%s_twait" % arm] = c1(s["twait_late"])
        V["soz_%s_twait_ok" % arm] = c1(s["twait_ok"])
        V["soz_%s_crew" % arm] = c1(s["crew_late"])
        V["soz_%s_crew_ok" % arm] = c1(s["crew_ok"])
for sc in ("S3", "S4", "S5"):
    for arm in ("R", "T"):
        h = hata.get("H|%s|%s" % (sc, arm))
        if h:
            V["fixwait_%s_%s" % (arm, sc)] = c1(h["fixwait"])
json.dump(V, open(os.path.join(O, "a6vals.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(json.dumps(V, ensure_ascii=False, indent=1))
