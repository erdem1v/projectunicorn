"""C0s: butun hatti sirayla kosar. python -I c0s_run_all.py  (Godot yok, standart kitaplik). Girdi: k9_trim/, k9_trim_15/ (c0s_trim.py ile hazirlanir; kaynak repo disi),
../../q_calisma/q0b_logs. Cikti: out/c0s_*.md ve .json. Sure ~30 sn."""
import os, sys, subprocess, time

HERE = os.path.dirname(os.path.abspath(__file__))
STEPS = ["c0s_check.py", "c0s_m1.py", "c0s_m2.py", "c0s_load.py", "c0s_econ.py", "c0s_econ2.py", "c0s_core2.py"]
t0 = time.time()
os.makedirs(os.path.join(HERE, "out"), exist_ok=True)
for s in STEPS:
    r = subprocess.run([sys.executable, "-I", os.path.join(HERE, s)], capture_output=True)
    ok = r.returncode == 0
    open(os.path.join(HERE, "out", s.replace(".py", "_stdout.txt")), "wb").write(r.stdout)
    print("%-16s %s  (%.0f sn)" % (s, "tamam" if ok else "HATA", time.time() - t0))
    if not ok:
        print(r.stderr.decode("utf-8", "replace")[-1500:])
        sys.exit(1)
