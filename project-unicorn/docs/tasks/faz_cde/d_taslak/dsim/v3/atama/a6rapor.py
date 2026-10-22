# A6 raporu: a6_metin.md (metin + yer tutucular) -> ../../../ATAMA/A6_HATA_MODELI.md. python -I a6rapor.py
#   <<tbl anahtar>>                         a6tablolar.tables()[anahtar]
#   <<lv metrik kol kal senaryo>>           ortalama (20 tohum), virgullu
#   <<df metrik a b kal senaryo>>           eslik fark: ortalama ± standart hata
#   <<dm metrik a b kal senaryo>>           eslik fark: yalniz ortalama
#   <<pc metrik a b kal senaryo>>           goreli fark yuzde: ortalama(a) / ortalama(b) - 1
#   <<ne metrik a b kal senaryo>>           farkin eksi cikan tohum sayisi "k/20"
#   <<raw anahtar>>                         a6vals.json'dan
import os, re, sys, json, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a6tab as T
import a6tablolar as TT

OUT = os.path.normpath(os.path.join(HERE, "..", "..", "..", "ATAMA", "A6_HATA_MODELI.md"))
TAG = "ana"


def comma(s):
    return s.replace(".", ",").replace("-", "−") if False else s.replace(".", ",")


def fmt(metric, x, signed=False):
    if x is None:
        return "-"
    if metric == "soz":
        return ("%+.1f pp" if signed else "%.1f") % (100 * x)
    if metric in ("bosta", "altinda"):
        return ("%+.1f pp" if signed else "%.1f%%") % (100 * x)
    return ("%+.1f" if signed else "%.1f") % x


def scen_key(s):
    return s.replace("_", "|")


def lv(metric, arm, cal, scen, tag=TAG):
    v = T.vals(tag, cal, arm, scen_key(scen), metric)
    return comma(fmt(metric, statistics.mean(v.values()))) if v else "-"


def dm(metric, a, b, cal, scen, tag=TAG):
    m, se, neg, n = T.paired(tag, cal, a, b, scen_key(scen), metric)
    return comma(fmt(metric, m, True))


def df(metric, a, b, cal, scen, tag=TAG):
    m, se, neg, n = T.paired(tag, cal, a, b, scen_key(scen), metric)
    if m is None:
        return "-"
    pp = " pp" if metric in ("soz", "bosta", "altinda") else ""
    sc = 100 if pp else 1
    return comma("%+.1f ± %.1f%s" % (sc * m, sc * (se or 0.0), pp))


def pc(metric, a, b, cal, scen, tag=TAG):
    va, vb = T.vals(tag, cal, a, scen_key(scen), metric), T.vals(tag, cal, b, scen_key(scen), metric)
    return comma("%+.1f%%" % (100 * (statistics.mean(va.values()) / statistics.mean(vb.values()) - 1)))


def ne(metric, a, b, cal, scen, tag=TAG):
    m, se, neg, n = T.paired(tag, cal, a, b, scen_key(scen), metric)
    return "%d/%d" % (neg, n)


def main():
    txt = open(os.path.join(HERE, "a6_metin.md"), encoding="utf-8").read()
    tabs = TT.tables()
    vals = json.load(open(os.path.join(HERE, "out6", "a6vals.json"), encoding="utf-8")) if os.path.exists(os.path.join(HERE, "out6", "a6vals.json")) else {}
    miss = []

    def sub(m):
        parts = m.group(1).split()
        tag = TAG
        if parts[-1].startswith("@"):
            tag = parts.pop()[1:]
        k = parts[0]
        try:
            if k == "tbl":
                return tabs[parts[1]]
            if k == "lv":
                return lv(parts[1], parts[2], parts[3], parts[4], tag)
            if k == "df":
                return df(parts[1], parts[2], parts[3], parts[4], parts[5], tag)
            if k == "dm":
                return dm(parts[1], parts[2], parts[3], parts[4], parts[5], tag)
            if k == "pc":
                return pc(parts[1], parts[2], parts[3], parts[4], parts[5], tag)
            if k == "ne":
                return ne(parts[1], parts[2], parts[3], parts[4], parts[5], tag)
            if k == "raw":
                return str(vals[parts[1]])
        except Exception as e:
            miss.append((m.group(0), repr(e)))
            return m.group(0)
        miss.append((m.group(0), "bilinmeyen"))
        return m.group(0)
    txt = re.sub(r"<<([^<>]+)>>", sub, txt)
    prev = len(sys.argv) > 1 and sys.argv[1] == "onizleme"
    if miss:
        for x in miss:
            print("EKSIK", x)
        if not prev:
            sys.exit(1)
    out = os.path.join(HERE, "out6", "onizleme.md") if prev else OUT
    open(out, "w", encoding="utf-8", newline="\n").write(txt)
    print(out, len(txt), "bayt")


if __name__ == "__main__":
    main()
