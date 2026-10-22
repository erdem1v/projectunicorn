# Secilen seceneklerin dagilimi (hafta basi aramasinda hangi seceneklerin kazandigi). python -I a8sec.py <senaryo,...> [tohum_sayisi]
import os, sys, collections
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
P = R8.P


def name(t):
    if t.get("mode") == "tplan":
        return "T_plan"
    if t.get("mode") == "cap":
        return "kadro tavani" + (" + saklama" if t.get("sec") == "hold" else "")
    return "ufuk payi %.2f%s" % (t.get("beta", 1.0), " + saklama" if t.get("sec") == "hold" else "")


if __name__ == "__main__":
    scens = sys.argv[1].split(",")
    ns = int(sys.argv[2]) if len(sys.argv) > 2 else 3
    for sc in scens:
        cnt = collections.Counter()
        swap0 = tot = 0
        for sd in range(1, ns + 1):
            P.LOG = []
            R8.set_cfg8(R8.R6.ARMS["P"], sd, "H")
            sim = R8.R6.make_sim(sc, sd)
            sim.run()
            for k, res, th in P.LOG:
                cnt[name(th)] += 1
                tot += 1
                swap0 += 1 if th.get("swap") == 0 else 0
        print(sc, "secim sayisi", tot, "| yer degisimsiz secilen", swap0, "|", ", ".join("%s %d (%%%.0f)" % (k, v, 100.0 * v / tot) for k, v in cnt.most_common()))
