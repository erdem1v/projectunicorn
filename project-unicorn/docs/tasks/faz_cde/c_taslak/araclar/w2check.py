"""W2 mekanik kapısı: python -I w2check.py <W2_METINLER.json> [<W2_METINLER.md>]
W1 öğesini düşüren kayıt: {"id": <W1 id>, "step": <adım>, "drop": true, "why": <neden>} (metin denetlenmez).
Hata varsa 1 ile çıkar; md'yi JSON'dan üretir."""
import json
import re
import sys
from collections import defaultdict

TOKEN = re.compile(r"\{([^{}]*)\}")
SLOT = re.compile(r"^[a-z_]+$")
ID = re.compile(r"^[a-z0-9_.]+$")
DASHES = ("\u2014", "\u2013", " - ")
EN_LEAK = re.compile(r"\b(seat|seats|load|server|servers|renewal|request|requests|account|accounts|enterprise|standard|"
                     r"tier|support|ticket|feature|capacity|expense|expenses|rent)\b", re.I)
STEP = re.compile(r"^C\d+[a-z]?(-\d+[a-z]?)?$")


def check(items):
    errors, warns, seen = [], [], set()
    for it in items:
        iid = it.get("id", "?")
        if not ID.match(iid):
            errors.append(f"{iid}: id biçimi")
        if iid in seen:
            errors.append(f"{iid}: id tekrar")
        seen.add(iid)
        if not STEP.match(str(it.get("step", ""))):
            errors.append(f"{iid}: step {it.get('step')!r}")
        if it.get("drop"):
            if not str(it.get("why", "")).strip():
                errors.append(f"{iid}: drop gerekçesiz")
            continue
        toks = {}
        for lang in ("en", "tr"):
            s = it.get(lang)
            if not isinstance(s, str) or not s.strip():
                errors.append(f"{iid}: {lang} boş")
                continue
            for d in DASHES:
                if d in s:
                    errors.append(f"{iid}: {lang} tire {d!r}")
            if "%s" in s or "%d" in s:
                errors.append(f"{iid}: {lang} %s/%d")
            if s.count("{") != s.count("}"):
                errors.append(f"{iid}: {lang} dengesiz süslü parantez")
            names = TOKEN.findall(s)
            for n in names:
                if not SLOT.match(n):
                    errors.append(f"{iid}: {lang} yer tutucu {{{n}}}")
            toks[lang] = set(names)
        if "en" in toks and "tr" in toks and toks["en"] != toks["tr"]:
            errors.append(f"{iid}: yer tutucular farklı en={sorted(toks['en'])} tr={sorted(toks['tr'])}")
        slots = it.get("slots")
        if slots is not None and "tr" in toks and set(slots) != toks["tr"]:
            errors.append(f"{iid}: slots alanı metinle uyuşmuyor {sorted(slots)} / {sorted(toks['tr'])}")
        tr = it.get("tr") or ""
        if re.search(r"\}['\u2019]?[a-zçğıöşü]", tr):
            errors.append(f"{iid}: tr yer tutucudan sonra ek")
        m = EN_LEAK.search(tr)
        if m:
            warns.append(f"{iid}: tr içinde İngilizce sözcük? {m.group(0)!r}")
    return errors, warns


def render(data):
    by = defaultdict(list)
    for it in data["items"]:
        by[it["step"]].append(it)
    out = ["# W2 · Faz C Pazar 2 yazım dalgası", "", "Kaynak `W2_METINLER.json`; bu dosya `w2check.py` ile üretilir, elle düzenlenmez.", ""]
    for step in sorted(by, key=lambda s: (len(s), s)):
        out += [f"## {step}", "", "| id | Yer | EN | TR |", "|---|---|---|---|"]
        for it in by[step]:
            cell = lambda s: (s or "").replace("|", "\\|").replace("\n", "<br>")
            if it.get("drop"):
                out.append(f"| `{it['id']}` | DÜŞTÜ | {cell(it.get('why'))} | |")
                continue
            out.append(f"| `{it['id']}` | {cell(it.get('where'))} | {cell(it.get('en'))} | {cell(it.get('tr'))} |")
        out.append("")
    return "\n".join(out)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
    errors, warns = check(data["items"])
    for w in warns:
        print("WARN", w)
    for e in errors:
        print("FAIL", e)
    print(f"W2CHECK items={len(data['items'])} fail={len(errors)} warn={len(warns)}")
    if len(sys.argv) > 2:
        with open(sys.argv[2], "w", encoding="utf-8", newline="\n") as f:
            f.write(render(data))
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
