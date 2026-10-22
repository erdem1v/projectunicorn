"""E1 ek olcumu (ana oturum): M10, kapi adayin U'sunu rakip penceresiyle okurken pay 10 / 5 / 0. python -I c0s_e1_extra.py"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_core as C, c0s_data as D, c0s_model as M


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    arms = D.ARMS
    q0b = {a: sum(sum(1 for x in D.load(D.run_name(a, s), D.Q0B)["sign"] if 7 <= x["day"] <= 33) for s in D.SEEDS) for a in arms}
    print("| Kapı biçimi | " + " | ".join(arms) + " |")
    for lab, kw in (("rakip penceresi, pay 10", dict(gate_rivals=True)),
                    ("rakip penceresi, pay 5", dict(gate_rivals=True, gate_over=5)),
                    ("rakip penceresi, pay 0", dict(gate_rivals=True, gate_over=0)),
                    ("hesap U'su, pay 5", dict(gate_over=5))):
        c = M.cfg(**kw)
        row = []
        for a in arms:
            kp = 0
            for s in D.SEEDS:
                res, accts, run, wd = C.run_accounts(D.run_name(a, s), c, gate=True)
                kp += sum(1 for x in accts if 7 <= x.sign <= 33 and not res[x.id]["rejected"])
            row.append("%.1f%%" % (100.0 * kp / q0b[a]))
        print("| %s | %s |" % (lab, " | ".join(row)))


if __name__ == "__main__":
    main()
