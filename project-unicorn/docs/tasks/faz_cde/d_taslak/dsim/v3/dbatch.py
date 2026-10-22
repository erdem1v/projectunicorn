# D0s toplu kosu (en cok 2 isci; her cagri tek bir butce icinde biter, sonuclar onbellekte).
#   python -I dsim3.py exec dbatch.py <etiket> <grup[,grup...]> [butce_sn]
# Ortam degiskenleri (D3_*) bu komuttan ONCE verilmelidir; Windows spawn isciler dsim3.py'yi yeniden okur.
# Cikti: out/<etiket>/<senaryo>[#<secenek>].pkl = {tohum: metrikler}. Eksik tohumlar sonraki cagrida tamamlanir.
import pickle, time, os
from concurrent.futures import ProcessPoolExecutor, FIRST_COMPLETED, wait

TAG, GRP = sys.argv[3], sys.argv[4]
BUDGET = float(sys.argv[5]) if len(sys.argv) > 5 else 480.0
WORKERS = int(os.environ.get("D3_WORKERS", "2"))
exec(open("dgroups.py", encoding="utf-8").read())
OUT = os.path.join("out", TAG)
os.makedirs(OUT, exist_ok=True)


def fname(nm, opt):
    sig = "" if not opt else "#" + ",".join("%s=%s" % (k, opt[k]) for k in sorted(opt))
    return os.path.join(OUT, nm.replace("|", "_").replace(" ", "_").replace("*", "x").replace("+", "p") + sig + ".pkl")


def load(f):
    try:
        return pickle.load(open(f, "rb"))
    except Exception:
        return {}


def okey(opt):
    return tuple(sorted(opt.items())) if opt else None


t0 = time.time()
tasks = []
for g in GRP.split(","):
    seeds = GROUP_SEEDS.get(g, range(1, 21))
    if os.environ.get("D3_NSEEDS"):
        seeds = range(1, int(os.environ["D3_NSEEDS"]) + 1)
    for nm, opt in GROUPS[g]:
        have = load(fname(nm, opt))
        for sd in seeds:
            if sd not in have:
                tasks.append((nm, opt, sd))
total, done = len(tasks), 0
buf = {}


def flush():
    for (nm, ok), res in buf.items():
        f = fname(nm, dict(ok) if ok else None)
        d = load(f)
        d.update(res)
        pickle.dump(d, open(f, "wb"))
    buf.clear()


if total:
    it = iter(tasks)
    last = time.time()
    with ProcessPoolExecutor(max_workers=WORKERS) as ex:
        pend, stop = {}, False
        while True:
            while not stop and len(pend) < WORKERS * 2:
                if time.time() - t0 > BUDGET:
                    stop = True
                    break
                try:
                    nm, opt, sd = next(it)
                except StopIteration:
                    stop = True
                    break
                pend[ex.submit(run_one, (nm, sd, opt))] = (nm, opt, sd)
            if not pend:
                break
            dn, _ = wait(list(pend), return_when=FIRST_COMPLETED)
            for fu in dn:
                nm, opt, sd = pend.pop(fu)
                _, _, m = fu.result()
                buf.setdefault((nm, okey(opt)), {})[sd] = m
                done += 1
            if time.time() - last > 30:
                flush()
                last = time.time()
flush()
print("etiket %s grup %s: %d/%d is tamam, %d sn%s" % (TAG, GRP, done, total, round(time.time() - t0), "" if done == total else "  (KALDI %d: yeniden calistir)" % (total - done)), flush=True)
