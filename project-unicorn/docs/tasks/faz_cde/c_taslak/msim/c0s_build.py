"""C0S_SONUC.md'yi sablondan kurar: @@dosya#baslik@@ isaretleri out/ altindaki tablolarla degisir. python -I."""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
TPL = os.path.join(HERE, "c0s_sonuc_template.md")
DST = os.path.normpath(os.path.join(HERE, "..", "C0S_SONUC.md"))


def block(fname, head):
    lines = open(os.path.join(OUT, fname), encoding="utf-8").read().split("\n")
    start = None
    for i, l in enumerate(lines):
        if l.startswith("### ") and l[4:].startswith(head):
            start = i; break
    if start is None:
        raise SystemExit("baslik yok: %s#%s" % (fname, head))
    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("### "):
            end = j; break
    body = lines[start:end]
    body[0] = "#" + body[0]          # ### -> ####
    return "\n".join(body).rstrip() + "\n"


def main():
    t = open(TPL, encoding="utf-8").read()
    t = re.sub(r"@@([^#@]+)#([^@]+)@@", lambda m: block(m.group(1), m.group(2)), t)
    open(DST, "w", encoding="utf-8").write(t)
    print("yazildi:", DST, len(t.split("\n")), "satir")


if __name__ == "__main__":
    main()
