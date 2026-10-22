# K-H kalibrasyonu: 6 kisilik ekip (S3), R kolu, sinirsiz arz, 21-60. hafta, 20 tohum. Hedef: bugunku modelin toplam dogan hatasi (ortalama).
#   python -I a6cal.py <c> [c ...]     her c icin yeni model ortalamasini basar (onbellekli); python -I a6cal.py hedef
import os, sys, pickle, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a6run as R6


def stat(cal):
    R6.main_run("kal", ["R"], ["S3"], cal, 400.0, 20)
    d = pickle.load(open(R6.fname("kal", cal, "R", "S3"), "rb"))
    return {k: statistics.mean(d[s][k] for s in d) for k in ("born", "H", "esc", "deliv", "open_med", "wbelow", "wdev")}


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    if sys.argv[1] == "hedef":
        print("bugun", stat("0"))
    else:
        for c in sys.argv[1:]:
            print("c=%s" % c, stat(c), flush=True)
