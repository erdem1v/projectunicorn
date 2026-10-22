"""C0s bolum F: RAPOR_Q ❌1 icin CORE_2 taramasi (sabit dunya: K9 910ad1f botunun urunu; yalniz beklenti degeri degisir). python -I.
Cikti: out/c0s_f.md"""
import sys, os, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import c0s_core as C, c0s_data as D, c0s_model as M
from c0s_check import prospect_u

L = []
w = L.append


def pct(a, b):
    return 100.0 * a / b if b else float("nan")


def main():
    w("### ❌1 taraması: CORE_2 değeri (sabit dünya)")
    w("")
    w("Bot ürünü 1,25 koşusundan (910ad1f) sabit; yalnız 2★ Çekirdek beklentisi değişir. 2★+3★ imzaların U'su (aday bağlamı, rakip penceresi dahil) yeniden hesaplanır; "
      "C kapısı hesabın kendi referansıyla (rakipsiz). Hedef (Q kapısı): U = 100 payı <= %25 (`fix_worst`), Traction ortanca U 70-85; Erdem'in M10 hedefi %55-65. "
      "\"Kapısız\" = Q'nun ölçümü, \"kapılı\" = C kapısından geçenler.")
    w("")
    w("| CORE_2 | 2★+3★ imza (worst) | U=100 payı kapısız | U=100 payı kapılı | Traction ortanca U kapısız → kapılı | M10 imza ÷ eski kod (worst, kapılı) | M5 none geç kayıp (7 / 11) |")
    w("|---|---|---|---|---|---|---|")
    q0b = sum(sum(1 for x in D.load(D.run_name("worst", s), D.Q0B)["sign"] if 7 <= x["day"] <= 33) for s in D.SEEDS)
    for core2 in (1.25, 1.30, 1.35, 1.40, 1.45, 1.46, 1.47, 1.48, 1.49, 1.50):
        c = M.cfg(core2=core2)
        n = n100 = np_ = n100p = 0
        tr_a, tr_p = [], []
        kp = 0
        for s in D.SEEDS:
            nm = D.run_name("worst", s)
            res, accts, run, wd = C.run_accounts(nm, c)
            for a in accts:
                if 7 <= a.sign <= 33 and not res[a.id]["rejected"]:
                    kp += 1
                if a.star < 2:
                    continue
                f = prospect_u(run, a.sign, a.star, a.sector, core2)
                u = f["value"]
                ok = not res[a.id]["rejected"]
                n += 1; n100 += (u == 100)
                if ok:
                    np_ += 1; n100p += (u == 100)
                if int(run["state"][a.sign]["phase"]) == 2 if a.sign in run["state"] else False:
                    tr_a.append(u)
                    if ok:
                        tr_p.append(u)
        late = []
        for s in D.SEEDS:
            res, accts, run, wd = C.run_accounts(D.run_name("none", s), c)
            late.append(C.loss_stats(res, accts)["late_pct"])
        w("| %.2f | %d | %.1f%% | %.1f%% | %d → %d | %.1f%% | %s |" % (core2, n, pct(n100, n), pct(n100p, np_), st.median(tr_a), st.median(tr_p), pct(kp, q0b),
                                                                       " / ".join("%.1f" % x for x in late)))
    open(os.path.join(C.OUT, "c0s_f.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    print("\n".join(L))


if __name__ == "__main__":
    main()
