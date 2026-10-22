# A7 inceleme, falsification: gereksinimin altindaki is icin egri uzatmasi (delta < 0) kirpilinca (m = 0,20) R kolunun dogan hatasi.
# Tarifin dogan hata kazanci bu uzatmadan mi geliyor? python -I a7neg.py <senaryo,...> [tohum]
# Sonuc: out6/a7neg/H/R__<senaryo>.pkl (a6run duzeni). Yama modul duzeyinde: ProcessPool iscileri de yukler.
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import a6run as R6
H = R6.H
H.mfun = lambda d: H.CFG2.m0 * 0.5 ** (max(d, 0.0) / H.CFG2.half)
if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    R6.main_run("a7neg", ["R"], sys.argv[1].split(","), "H", 500.0, int(sys.argv[2]) if len(sys.argv) > 2 else 20)
