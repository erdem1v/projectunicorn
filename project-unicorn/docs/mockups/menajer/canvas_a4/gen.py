import json, os, glob
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "project")
os.makedirs(ROOT, exist_ok=True)
ids = {}
for f in sorted(glob.glob(os.path.join(HERE, "ids_*.txt"))):
    for line in open(f, encoding="utf-8"):
        if line.strip():
            k, v = line.split()
            ids[k] = v
frames = json.load(open(os.path.join(HERE, "frames.json"), encoding="utf-8"))
questions = json.load(open(os.path.join(HERE, "questions.json"), encoding="utf-8"))
TPL = """<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<title>{title}</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<style>
body{{margin:0}}
</style>
</helmet>
<div style="width: {w}px; height: {h}px; background: #100E0B">
<img src="/_blob/{blob}" alt="{title}" style="display: block; width: {w}px; height: {h}px">
</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":{w},"height":{h}}}}}'>
class Component extends DCLogic {{
renderVals() {{
return {{}};
}}
}}
</script>
</body>
</html>
"""
COLS = 4
boards, order, notes, pages = {}, [], {}, []
missing = []
first = True
pages.append({"id": "genel", "name": "Genel sorular"})
notes["t_genel"] = {"x": 0, "y": -300, "text": "Menajer Masası · ekran maketleri", "kind": "title1", "maxW": 2400, "page": "genel"}
notes["s_genel"] = {"x": 0, "y": 0, "text": questions["genel"], "w": 1600, "maxH": 4000, "size": "l", "fill": "orange", "page": "genel"}
for g in frames["groups"]:
    pid = g["key"]
    pages.append({"id": pid, "name": g["name"]})
    x = y = 0
    rowh = 0
    col = 0
    maxx = 0
    for fr in g["frames"]:
        stem = os.path.splitext(fr["file"][3:])[0]
        if stem not in ids:
            missing.append(stem)
            continue
        w, h = fr["w"], fr["h"]
        name = "Main.dc.html" if first else stem.replace("/", "_") + ".dc.html"
        first = False
        boards[name] = {"x": x, "y": y, "w": w, "h": h, "title": fr["title"], "page": pid}
        order.append(name)
        with open(os.path.join(ROOT, name), "w", encoding="utf-8", newline="\n") as f:
            f.write(TPL.format(title=fr["title"].replace('"', "&quot;"), blob=ids[stem], w=w, h=h))
        x += w + 80
        rowh = max(rowh, h)
        maxx = max(maxx, x - 80)
        col += 1
        if col == COLS:
            col = 0
            x = 0
            y += rowh + 120
            rowh = 0
    notes[f"t_{pid}"] = {"x": 0, "y": -300, "text": g["name"], "kind": "title1", "maxW": maxx, "page": pid}
    notes[f"s_{pid}"] = {"x": maxx + 160, "y": 0, "text": questions[pid], "w": 1400, "maxH": 4000, "size": "l", "fill": "orange", "page": pid}
canvas = {"v": 3, "createdOnFiles": {"v": 1, "at": "2026-10-03T10:00:00Z"}, "title": "Menajer Masası · Ekranlar",
          "launch": {"view": "canvas", "page": "genel"}, "pages": pages, "boards": boards, "order": order, "notes": notes, "designSystems": []}
with open(os.path.join(ROOT, "canvas.json"), "w", encoding="utf-8", newline="\n") as f:
    json.dump(canvas, f, ensure_ascii=False, indent=1)
print(len(order), "boards; missing:", missing)
