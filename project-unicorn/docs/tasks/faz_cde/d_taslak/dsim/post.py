import re
def post(t):
    for k in sorted([k for k in LBL if "_" in k], key=len, reverse=True):
        t = t.replace(k, LBL[k])
    t = re.sub(r"TS(\d+)_(\d+)", lambda m: "%s kişi, testçiler %g★" % (m.group(1), int(m.group(2)) / 2), t)
    t = re.sub(r"\bC(\d+)\b", lambda m: "eğri %s kişi" % m.group(1), t)
    t = re.sub(r"(\d)\*", r"\1★", t)
    for a, b in (("gelistirici", "geliştirici"), ("tasarimci", "tasarımcı"), ("testcisiz", "testçisiz"), ("testci", "testçi"), ("Yapim", "Yapım"),
                 ("cok testçi", "çok testçi"), ("cok tasarımcı", "çok tasarımcı"), ("cok PM", "çok PM"), ("esit dort rol", "eşit dört rol"),
                 ("Gelistirme", "Geliştirme"), ("Tasarim", "Tasarım")):
        t = t.replace(a, b)
    out, fence = [], False
    for ln in t.split(chr(10)):
        if ln.startswith("```"):
            fence = not fence
        elif not fence and not ln.startswith("#"):
            ln = re.sub(r"(?<![§\d.])(\d+)\.(\d+)", r"\1,\2", ln)
        out.append(ln)
    return chr(10).join(out)
