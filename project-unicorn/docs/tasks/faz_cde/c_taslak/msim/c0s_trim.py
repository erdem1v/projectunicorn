"""C0s girdi hazirligi. python -I (standart kitaplik).
Q'nun kapanis olcumunun (910ad1f) bot kayitlarini (30 kosu, PROBE satirlari) okur; C0s'in ihtiyaci olmayan satirlari (CUST, FIRE, PICK, ...) atar ve
k9_trim/ altina yazar. Kaynak: Q oturumunun scratchpad'i (repo disi); k9_trim/ kopyasi bu klasorde kalir, betikler yalniz onu okur.
Eski taban kayitlari (Q0b, eski kod) repoda: docs/tasks/faz_cde/q_calisma/q0b_logs."""
import os, sys

BASE = "C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/28e6716b-abb6-403c-8121-fda33946d2e1/scratchpad"
JOBS = [("k9_logs", "k9_trim"),            # 910ad1f, CORE_2 1,25 (bugunku)
        ("k9_logs_bd9a5ed", "k9_trim_15")]  # bd9a5ed, CORE_2 1,5
HERE = os.path.dirname(os.path.abspath(__file__))
KEEP = ("STATE", "AREAS", "LINES", "BUGS", "SIGN", "FIT", "LEAD", "MLOSS", "REPLOSS", "SPRINT", "SHIP", "PROMISE", "CHURN", "MONTH",
        "MONTH_BURN", "HR", "GATE", "END", "BEGIN", "B2C", "PLAY", "FIRE", "SAT", "UFLUX", "DISCOUNT")


def main():
    for a, b in JOBS:
        one(os.path.join(BASE, a), os.path.join(HERE, b))


def one(SRC, DST):
    os.makedirs(DST, exist_ok=True)
    n = tot_in = tot_out = 0
    for f in sorted(os.listdir(SRC)):
        if not (f.startswith("full_run") and f.endswith(".log")):
            continue
        out = []
        for l in open(os.path.join(SRC, f), encoding="utf-8", errors="replace"):
            if not l.startswith("PROBE "):
                continue
            t = l.split(" ", 2)[1]
            if t in KEEP:
                if t == "PLAY" and (" meeting " in l or " sprint " in l or "research" in l):
                    continue
                out.append(l.rstrip("\n"))
        data = "\n".join(out) + "\n"
        open(os.path.join(DST, f), "w", encoding="utf-8").write(data)
        n += 1; tot_in += os.path.getsize(os.path.join(SRC, f)); tot_out += len(data.encode("utf-8"))
    print("%s: kosu %d, %.1f MB -> %.1f MB" % (os.path.basename(DST), n, tot_in / 1e6, tot_out / 1e6))


if __name__ == "__main__":
    main()
