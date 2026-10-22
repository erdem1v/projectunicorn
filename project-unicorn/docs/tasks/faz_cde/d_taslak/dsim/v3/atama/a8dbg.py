import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a8run as R8
P = R8.P
scen, seed, arm = sys.argv[1], int(sys.argv[2]), sys.argv[3]
n = int(sys.argv[4]) if len(sys.argv) > 4 else 3
P.LOG = []
R8.set_cfg8(R8.R6.ARMS[arm], seed, "H")
sim = R8.R6.make_sim(scen, seed)
sim.run()
print("mvp", sim.mvp_week)
for k, res, th in P.LOG[:n]:
    print("-- epoch k=%d secilen %s" % (k, th))
    for t_, sc in res:
        print("   %-50s F %.3f idle %.2f prog %.3f pr %.1f" % (t_, sc["F"], sc["idle"], sc["prog"], sc["pr"]))
