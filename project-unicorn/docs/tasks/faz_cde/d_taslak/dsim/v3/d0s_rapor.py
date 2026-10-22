# Rapor birlestirici: rapor_sablon.md icindeki {{T:bolum}} (out/d0s_tablolar.md) ve {{GATES}} yer tutucularini doldurur.
# python -I d0s_rapor.py  -> ../../D0s_SIM.md  (d_taslak/D0s_SIM.md)
import re, json, os
exec(open("trfix.py", encoding="utf-8").read())
tab = open("out/d0s_tablolar.md", encoding="utf-8").read()
secs = {m.group(1): m.group(2) for m in re.finditer(r"<!-- (\w+) -->\n(.*?)\n\n(?=<!--|\Z)", tab, re.S)}
G = json.load(open("out/dgates_R.json", encoding="utf-8"))["gates"]


def gate_table():
    rows = ["| No | Kapı | Hedef (PRD §4.1 okuması) | Sonuç | Değer ve kanıt |", "|---|---|---|---|---|"]
    for g in G:
        st = "ÖLÇÜLMEDİ" if g["gecti"] is None else ("GEÇTİ" if g["gecti"] else "KALDI")
        val = g["deger"] + ((" · " + g["kanit"]) if g["kanit"] else "")
        rows.append("| %s | `%s` | %s | **%s** | %s |" % (g["no"], g["ad"], trfix(g["hedef"]), st, trfix(val).replace("|", "¦")))
    return "\n".join(rows)


tpl = open("rapor_sablon.md", encoding="utf-8").read()


def sub(m):
    k = m.group(1)
    if k == "GATES":
        return gate_table()
    if k.startswith("T:"):
        return trfix(secs.get(k[2:], "(tablo yok: %s)" % k[2:]))
    return m.group(0)


out = re.sub(r"\{\{([^}]+)\}\}", sub, tpl)
dst = os.path.join("..", "..", "D0s_SIM.md")
open(dst, "w", encoding="utf-8").write(out)
print("yazildi", os.path.abspath(dst), len(out))
