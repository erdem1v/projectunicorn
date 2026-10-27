"""8. adım sayfasının verisi: page/data.json + page/img/*.webp.

Önce = Erdem'in okuduğu revize.json. Sonra = oyundaki kart JSON'u (kopya) + revize3 özet satırları.
Kareler 7. adımın çekiminden (SHOTS/<kart>/{A,B}_{tr,en}.png); kart paneline kırpılır, WebP'ye sıkıştırılır.
Kullanım: python build_data.py <shots_dir>
"""
import os as _os
_HERE = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__)))
import glob
import json
import os
import re
import sys

from PIL import Image

S = _os.environ.get("OLAY_S", _HERE)
W = _os.environ.get("OLAY_PROJ", _os.path.abspath(_HERE + "/../../.."))
SRC = S + "/revize.json"
OUT = S + "/page"
SHOTS = sys.argv[1] if len(sys.argv) > 1 else S + "/kareler"

before = {r["id"]: r for r in json.load(open(SRC, encoding="utf-8"))}
after3 = {r["id"]: r for r in json.load(open(S + "/cards/revize3.json", encoding="utf-8"))}
mp = json.load(open(OUT + "/map.json", encoding="utf-8"))

cards_by_id = {}
for p in glob.glob(W + "/data/events/cards/**/*.json", recursive=True):
    p = p.replace(os.sep, "/")
    try:
        c = json.load(open(p, encoding="utf-8"))
    except Exception:
        continue
    if isinstance(c, dict) and "id" in c:
        cards_by_id[c["id"]] = (c, p)

FIELDS = ["gonderen", "gonderen_en", "konu", "konu_en", "metin", "metin_en"]


def changed(rid):
    b, r = before.get(rid), after3.get(rid)
    if b is None:
        return True
    if any(b.get(f) != r.get(f) for f in FIELDS):
        return True
    bo, ro = b.get("secenekler", []), r.get("secenekler", [])
    if len(bo) != len(ro):
        return True
    for x, y in zip(bo, ro):
        for f in ["etiket", "etiket_en", "sonuc", "sonuc_en"]:
            if x.get(f) != y.get(f):
                return True
    return False


def before_block(rid):
    b = before.get(rid)
    if b is None:
        return None
    return before_block_from(b)


def before_block_from(b):
    out = {}
    for lang, sfx in (("tr", ""), ("en", "_en")):
        out[lang] = {
            "gonderen": b.get("gonderen" + sfx, ""),
            "konu": b.get("konu" + sfx, ""),
            "metin": b.get("metin" + sfx, ""),
            "secenekler": [{"etiket": o.get("etiket" + sfx, ""), "sonuc": o.get("sonuc" + sfx, "")}
                           for o in b.get("secenekler", [])],
        }
    return out


def after_block(rid, cid):
    r = after3[rid]
    c = cards_by_id[cid][0]
    if "text" not in c:
        # park kartı: dosyada yalnız _draft durur, metin revize3'te
        out = before_block_from(r)
        out["taslak"] = c.get("_draft", "")
        return out
    out = {}
    # karar 16: özet satırlarındaki örnek adlar yuva adına döner (oyunda seçici doldurur)
    scope_types = {k: (v.get("type") if isinstance(v, dict) else v) for k, v in c.get("scope", {}).items()}
    pairs = []
    for y in r.get("yuvalar") or []:
        slot = y.get("slot")
        if not slot:
            # revize3'te yuva adı boşsa kapsamda o türden tek yuva varsa odur
            same = [k for k, t in scope_types.items() if t == y.get("tur")]
            slot = same[0] if len(same) == 1 else None
        if slot and y.get("ornek") and not y["ornek"].startswith("("):
            pairs.append((y["ornek"], slot))
    names = sorted(pairs, key=lambda t: -len(t[0]))

    def slotted(s):
        for ornek, slot in names:
            s = s.replace(ornek, "{%s}" % slot)
        return s

    for lang, sfx in (("tr", ""), ("en", "_en")):
        t = c["text"][lang]
        opts = []
        r_opts = r.get("secenekler", [])
        for i, o in enumerate(c.get("options", [])):
            oid = o["id"]
            ro = r_opts[i] if i < len(r_opts) else {}
            opts.append({
                "id": oid,
                "etiket": t.get("options", {}).get(oid, ""),
                "kilit": t.get("locked_reasons", {}).get(oid, ""),
                "sonuc": slotted(ro.get("sonuc" + sfx, "")),
            })
        out[lang] = {
            "gonderen": r.get("gonderen_yuva" + sfx) or slotted(r.get("gonderen" + sfx, "")),
            "konu": t.get("title", ""),
            "metin": t.get("body", ""),
            "secenekler": opts,
            "cevapsiz": t.get("expire_note", ""),
        }
    return out


LINE = re.compile(r"^EVENTSHOT\|([^|]+)\|(.*)$")


SPEC = re.compile(r"event_shot_(\S+?)\.png")


def bindings(log):
    """EVENTSHOT satırından yuva → (id, ad, iğneli mi) listesi; çekimin spec'i PNG adından (iğneler, long=1), where."""
    if not os.path.exists(log):
        return None
    text = open(log, encoding="utf-8", errors="replace").read()
    pins, long_names = set(), False
    ms = SPEC.search(text)
    if ms:
        for tok in ms.group(1).split("_"):
            pass
        # spec "kart_slot=id_slot=id_long=1": "=" taşıyan parçalar iğnedir; slot adı "=" öncesindeki son "_" sonrası değil,
        # bilinen yuva adlarıyla eşleşir (acct_1 gibi alt çizgili yuvalar da)
        spec = ms.group(1)
        long_names = spec.endswith("long=1")
        for mm in re.finditer(r"(?:^|_)((?:acct_\d)|[a-z]+)=", spec):
            if mm.group(1) != "long":
                pins.add(mm.group(1))
    for ln in text.splitlines():
        m = LINE.match(ln.strip())
        if not m:
            continue
        out, where = [], ""
        for part in m.group(2).split("|"):
            if "=" not in part:
                continue
            k, v = part.split("=", 1)
            if k == "where":
                where = v
            if k in ("where", "week", "long"):
                continue
            mm = re.match(r"^(\S+) \((.*)\)$", v)
            out.append({"yuva": k, "id": mm.group(1) if mm else v, "ad": mm.group(2) if mm else "", "igne": k in pins})
        return {"yuvalar": out, "where": where, "long": long_names}
    return None


def panel_crop(src, dst):
    im = Image.open(src).convert("RGB")
    w, h = im.size
    bg = im.getpixel((40, h - 60))
    px = im.load()
    # panelin sağ kenarı: alt satırda panel zemininin bittiği yer (panel içerikle genişler; uzun adlı EN karede 1100 px'i bulur)
    edge = next((x for x in range(40, w) if sum(abs(a - b) for a, b in zip(px[x, h - 60], bg)) > 12), w - 8)
    x0, x1 = 20, min(w, edge + 8)
    last = 120
    for y in range(40, h - 40):
        for x in range(40, x1 - 30, 3):
            p = px[x, y]
            if abs(p[0] - bg[0]) + abs(p[1] - bg[1]) + abs(p[2] - bg[2]) > 36:
                last = y
                break
    crop = im.crop((x0, 20, x1, min(h, last + 28)))
    crop.save(dst, "WEBP", quality=82, method=6)
    return crop.size


os.makedirs(OUT + "/img", exist_ok=True)
rows = []
for e in mp["kartlar"]:
    rid, cid, durum = e["revize"], e["kart"], e["durum"]
    row = dict(e)
    row["kategori"] = after3.get(rid, {}).get("kategori", "")
    row["degisti"] = changed(rid)
    row["onay"] = "bekliyor" if after3.get(rid, {}).get("tr_en_onay_bekliyor") else "onaylı"
    row["neden"] = [after3[rid].get(k) for k in ("degisen", "degisen_2", "degisen_3") if after3[rid].get(k)]
    row["once"] = before_block(rid)
    if cid and cid in cards_by_id:
        row["sonra"] = after_block(rid, cid)
        row["dosya"] = cards_by_id[cid][1].split("/project-unicorn/")[-1]
    row["kareler"] = {}
    row["baglar"] = {}
    if durum == "bagli":
        d = SHOTS + "/" + cid
        for frame in ("A", "B"):
            for lang in ("tr", "en"):
                png = "%s/%s_%s.png" % (d, frame, lang)
                if os.path.exists(png):
                    name = "%s_%s_%s.webp" % (cid.replace(".", "_"), frame, lang)
                    size = panel_crop(png, OUT + "/img/" + name)
                    row["kareler"]["%s_%s" % (frame, lang)] = {"yol": "img/" + name, "w": size[0], "h": size[1]}
            row["baglar"][frame] = bindings("%s/%s_tr.log" % (d, frame))
    rows.append(row)

json.dump({"kartlar": rows, "park_gerekce": mp["park_gerekce"]},
          open(OUT + "/data.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
eksik = [r["kart"] for r in rows if r["durum"] == "bagli" and len(r["kareler"]) < 4]
print("kart", len(rows), "değişen", sum(1 for r in rows if r["degisti"]), "eksik kare", eksik)
print("img MB", round(sum(os.path.getsize(f) for f in glob.glob(OUT + "/img/*.webp")) / 1e6, 2))
