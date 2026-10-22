"""Butun hatti sirayla kosar: python -I run_all.py  (Godot yok, yalniz standart kitaplik)."""
import os, sys, subprocess, time

HERE = os.path.dirname(os.path.abspath(__file__))
STEPS = ["p1_bot.py", "p2_scen.py", "p3_econ.py", "p4_prop.py", "p5_gates.py", "build_report.py"]
t0 = time.time()
for s in STEPS:
    r = subprocess.run([sys.executable, "-I", os.path.join(HERE, s)], capture_output=True)
    ok = r.returncode == 0
    print("%-16s %s  (%.0f sn)" % (s, "tamam" if ok else "HATA", time.time() - t0))
    if not ok:
        print(r.stderr.decode("utf-8", "replace")[-1500:])
        sys.exit(1)
