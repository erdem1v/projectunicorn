"""wavecheck: mechanical checks for a Faz B writing-wave JSON (b_taslak/W*_*.json), plus an md render.

Usage:
  python -I wavecheck.py <wave.json>              -> report on stdout, exit 1 if any error
  python -I wavecheck.py <wave.json> --md <out.md> -> also writes a readable md of the wave

Checks (PRD_FAZ_B_OLAYLAR §3, CLAUDE.md §5): no dash, sentence limits per kind, token form and no suffix after a token,
EN/TR parity (both present, same token set), real-name list, hyphen-minus before a number in chips.
Judgment (tone, logic, free exits) is the critic's job, not this script's.
"""
import json
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

DASHES = "‒–—―"
TOKEN_RE = re.compile(r"\{([^{}]*)\}")
SLOT_RE = re.compile(r"^[a-z_]+$")
SEAM_RE = re.compile(r"^seam:[a-z_]+\.[a-z_]+$")
KNOWN_SLOTS = {"customer", "employee", "investor", "candidate", "rival", "contact", "founder", "product"}
REAL_NAMES = [
    "Ekol", "Arkas", "Trendyol", "Hepsiburada", "Getir", "Yemeksepeti", "Google", "Apple", "Microsoft", "Amazon",
    "AWS", "Atlassian", "Slack", "Zendesk", "Shopify", "Stripe", "iyzico", "PayPal", "Visa", "Mastercard", "Coupang",
    "Target", "Costco", "Koç", "Sabancı", "Turkcell", "SAP", "Oracle", "Salesforce", "Netflix", "Instagram", "Twitter",
    "Facebook", "WhatsApp", "TikTok", "LinkedIn", "App Store", "Google Play", "iPhone", "Android", "iOS", "Excel",
    "Jira", "Notion", "Figma", "GitHub", "Logo Yazımı", "Netsis", "Mikro", "Paraşüt", "Cabela", "Reddit",
]
# sentence limits per item kind for the main text (body / text)
BODY_LIMIT = {"incident": 3, "mail": 3, "paper": 3, "promise": 3, "thanks": 2, "review": 2}
NUM_DOT = re.compile(r"(?<=\d)[.,](?=\d)")


def sentences(s):
    s = NUM_DOT.sub("", s)
    s = re.sub(r"[“”\"']", "", s)
    parts = [p for p in re.split(r"[.!?…]+(?:\s+|$)", s.strip()) if p.strip()]
    return len(parts)


def pairs(item):
    """Yield (field_label, kind_of_text, {'en','tr'}) for every player-visible text pair in an item."""
    for key in ("title", "body", "text", "sender"):
        v = item.get(key)
        if isinstance(v, dict) and ("en" in v or "tr" in v):
            yield key, key, v
    for i, v in enumerate(item.get("body_variants") or []):
        yield f"body_variants[{i}] ({v.get('case_tr', '')})", "body", v
    for i, v in enumerate(item.get("reviews") or []):
        yield f"reviews[{i}]", "body", v
    for o in item.get("options") or []:
        oid = o.get("id", "?")
        if isinstance(o.get("label"), dict):
            yield f"option {oid} label", "label", o["label"]
        for j, c in enumerate(o.get("chips") or []):
            yield f"option {oid} chip[{j}]", "chip", c
        if isinstance(o.get("lock"), dict) and ("en" in o["lock"] or "tr" in o["lock"]):
            yield f"option {oid} lock", "lock", o["lock"]
    if isinstance(item.get("expire"), dict):
        yield "expire", "expire", item["expire"]


def check_text(s, kind, item_kind, errors, warns, where):
    for ch in DASHES:
        if ch in s:
            errors.append(f"{where}: tire ({ch!r})")
    if re.search(r"\s-\s", s):
        errors.append(f"{where}: aralıklı tire ' - '")
    for m in TOKEN_RE.finditer(s):
        tok = m.group(1)
        if item_kind == "chip_template":
            if not SLOT_RE.match(tok):
                errors.append(f"{where}: şablon yer tutucusu {{{tok}}} [a-z_]+ değil")
        elif SEAM_RE.match(tok):
            pass
        elif SLOT_RE.match(tok):
            if tok not in KNOWN_SLOTS:
                warns.append(f"{where}: slot {{{tok}}} bilinen slot listesinde değil")
        else:
            errors.append(f"{where}: çözülemeyen belirteç {{{tok}}} (yalnız {{slot}} ya da {{seam:ns.ad}})")
        nxt = s[m.end():m.end() + 1]
        if nxt and (nxt.isalpha() or nxt in "'’"):
            errors.append(f"{where}: belirtecin ardına ek geliyor: …{s[m.start():m.end() + 6]!r}")
    if "{" in TOKEN_RE.sub("", s) or "}" in TOKEN_RE.sub("", s):
        errors.append(f"{where}: çıplak süslü parantez")
    for name in REAL_NAMES:
        if re.search(rf"(?<!\w){re.escape(name)}(?!\w)", s):
            warns.append(f"{where}: gerçek ad olabilir: {name}")
    if kind == "chip" and re.search(r"(?<![\w])-\s?[\$%\d]", s):
        warns.append(f"{where}: eksi için '-' yerine '−' (U+2212)")
    limit = BODY_LIMIT.get(item_kind)
    if kind == "body" and limit and sentences(s) > limit:
        errors.append(f"{where}: {sentences(s)} cümle (sınır {limit})")
    if kind in ("label", "lock", "expire") and sentences(s) > 1:
        warns.append(f"{where}: {sentences(s)} cümle (tek cümle beklenir)")


def check(wave):
    report = []
    total_e = total_w = 0
    for item in wave.get("items", []):
        iid = item.get("id", "?")
        ik = item.get("kind", "?")
        errors, warns = [], []
        declared = {t.get("token") for t in item.get("tokens") or []}
        for label, kind, pair in pairs(item):
            en, tr = pair.get("en", ""), pair.get("tr", "")
            if not en or not tr:
                errors.append(f"{label}: EN ya da TR eksik")
            for lang, s in (("en", en), ("tr", tr)):
                if s:
                    check_text(s, kind, ik, errors, warns, f"{label} [{lang}]")
            te = {m.group(0) for m in TOKEN_RE.finditer(en)}
            tt = {m.group(0) for m in TOKEN_RE.finditer(tr)}
            if te != tt:
                errors.append(f"{label}: EN ve TR belirteçleri farklı: EN {sorted(te)} · TR {sorted(tt)}")
            for t in te | tt:
                if t.startswith("{seam:") and t not in declared:
                    warns.append(f"{label}: {t} belirteç tablosunda yok")
        if ik in ("incident", "paper", "promise"):
            opts = item.get("options") or []
            open_opts = [o for o in opts if not o.get("lock")]
            if len(opts) < 2:
                errors.append(f"{len(opts)} seçenek (en az 2)")
            if len(opts) - sum(1 for o in opts if o.get("lock") and not o["lock"].get("when_tr")) < 2:
                warns.append("koşulsuz kilitli seçenek sayılınca 2'den az açık seçenek kalıyor")
            for o in opts:
                if not o.get("best_when_tr"):
                    warns.append(f"option {o.get('id', '?')}: best_when_tr boş")
            _ = open_opts
        total_e += len(errors)
        total_w += len(warns)
        report.append((iid, ik, errors, warns))
    return report, total_e, total_w


def fmt_pair(p):
    return f"EN: {p.get('en', '')}\n  TR: {p.get('tr', '')}"


def render_md(wave):
    out = [f"# {wave.get('wave', '')}", "", wave.get("summary_tr", ""), ""]
    if wave.get("constants"):
        out += ["## Onay bekleyen sabitler (dalga)", ""]
        out += [f"- **{c.get('name')}** = {c.get('value')} · {c.get('why_tr', '')}" for c in wave["constants"]]
        out.append("")
    for item in wave.get("items", []):
        out += [f"## {item.get('title_tr') or item.get('id')}", f"`{item.get('id')}` · {item.get('kind')}"
                + (f" · {item.get('market')}" if item.get("market") else "")
                + (f" · {item.get('severity')}" if item.get("severity") else ""), ""]
        if item.get("when_tr"):
            out.append(f"**Ne zaman:** {item['when_tr']}" + (f" (damga {item['stamp']}, kart {item['opens']})"
                                                           if item.get("stamp") else ""))
        if item.get("sender"):
            out.append(f"**Gönderen:** {item['sender'].get('tr', '')} / {item['sender'].get('en', '')}")
        if item.get("text_tr"):
            out.append(item["text_tr"])
        out.append("")
        for key in ("title", "body", "text"):
            if isinstance(item.get(key), dict):
                out += [f"**{key}**", f"  {fmt_pair(item[key])}", ""]
        for v in item.get("body_variants") or []:
            out += [f"**gövde · {v.get('case_tr', '')}**", f"  {fmt_pair(v)}", ""]
        for o in item.get("options") or []:
            out.append(f"- **[{o.get('id')}]** {o['label'].get('tr', '')} / {o['label'].get('en', '')}")
            for c in o.get("chips") or []:
                out.append(f"  - çip: {c.get('tr', '')} / {c.get('en', '')}")
            if o.get("lock"):
                out.append(f"  - kilit ({o['lock'].get('when_tr', '')}): {o['lock'].get('tr', '')} / "
                           f"{o['lock'].get('en', '')}")
            out.append(f"  - ne yapar: {o.get('does_tr', '')} · en iyi: {o.get('best_when_tr', '')}")
        if item.get("expire"):
            out += ["", f"**Süre doldu:** {item['expire'].get('tr', '')} / {item['expire'].get('en', '')}"]
        if item.get("tokens"):
            out += ["", "| Belirteç | Taşıdığı | Örnek | Kaynak |", "|---|---|---|---|"]
            out += [f"| `{t.get('token')}` | {t.get('carries_tr', '')} | {t.get('example', '')} | "
                    f"{t.get('source_tr', '')} |" for t in item["tokens"]]
        if item.get("constants"):
            out += ["", "**Onay bekleyen:** " + "; ".join(f"{c.get('name')} = {c.get('value')}"
                                                        for c in item["constants"])]
        if item.get("notes_tr"):
            out += ["", f"_Not:_ {item['notes_tr']}"]
        out.append("")
    return "\n".join(out)


def main():
    path = sys.argv[1]
    wave = json.load(open(path, encoding="utf-8"))
    report, e, w = check(wave)
    for iid, ik, errors, warns in report:
        if errors or warns:
            print(f"== {iid} ({ik})")
            for x in errors:
                print(f"  HATA  {x}")
            for x in warns:
                print(f"  UYARI {x}")
    print(f"WAVECHECK {wave.get('wave')} items={len(report)} errors={e} warnings={w}")
    if "--md" in sys.argv:
        out = sys.argv[sys.argv.index("--md") + 1]
        open(out, "w", encoding="utf-8").write(render_md(wave))
    sys.exit(1 if e else 0)


if __name__ == "__main__":
    main()
