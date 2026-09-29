"""Checks art/office3d/<id>.glb + <id>.json against the binding contract in tools/office3d/README.md.

usage: python tools/office3d/check_export.py [id ...]     (default: all five offices and the meeting room)
Prints per office: size, glTF counts, named dynamic nodes, the heaviest materials by
vertex/index bytes, and every contract violation. Exit code 1 when any check fails.
"""
import json, os, re, struct, sys
from collections import Counter, defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
OUT = os.path.join(ROOT, "art", "office3d")
IDS = ["home", "ishani", "plaza", "loft", "city", "meet"]
KINDS = {
    "home": ["desk", "bal", "ket", "eat", "wc", "out", "bed", "stairs", "door", "enter"],
    "ishani": ["desk", "visit", "meet", "eat", "coffee", "wc", "out"],
    "plaza": ["desk", "visit", "meet_A", "meet_B", "meet_board", "eat", "coffee", "wc", "booth", "out"],
    "loft": ["desk", "visit", "meet_r1", "meet_r2", "meet_r3", "meet_board", "eat", "coffee", "wc", "booth", "trib", "present", "out"],
    "city": [],
    "meet": ["desk", "guest", "out"],
}
PATTERNS = ["station_", "pane_", "envpane_", "sky_", "fade_", "sconce_", "elev_panel_", "frame_", "car_", "boat_", "keep_", "matlib_"]
COMP = {5120: 1, 5121: 1, 5122: 2, 5123: 2, 5125: 4, 5126: 4}
NCOMP = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4, "MAT4": 16}
errors = []


def fail(office, msg):
    errors.append("%s: %s" % (office, msg))


def is_vec(v, n=3):
    return isinstance(v, list) and len(v) == n and all(isinstance(x, (int, float)) for x in v)


def read_glb(path):
    b = open(path, "rb").read()
    magic, version, length = struct.unpack_from("<4sII", b, 0)
    assert magic == b"glTF" and version == 2 and length == len(b), "bad GLB header"
    jlen, jtype = struct.unpack_from("<II", b, 12)
    assert jtype == 0x4E4F534A, "first chunk is not JSON"
    gltf = json.loads(b[20:20 + jlen])
    blen, btype = struct.unpack_from("<II", b, 20 + jlen)
    assert btype == 0x004E4942, "second chunk is not BIN"
    return gltf, blen, len(b)


def check_glb(office, gltf, blen):
    for i, bv in enumerate(gltf.get("bufferViews", [])):
        if bv.get("byteOffset", 0) + bv["byteLength"] > blen:
            fail(office, "bufferView %d runs past the BIN chunk" % i)
    nodes, mats = gltf.get("nodes", []), gltf.get("materials", [])
    names = [n.get("name", "") for n in nodes]
    dup = [n for n, c in Counter(x for x in names if x).items() if c > 1]
    if dup:
        fail(office, "duplicate node names %s" % dup[:5])
    by_name = {n.get("name"): n for n in nodes if n.get("name")}
    for name, n in by_name.items():
        ex = n.get("extras", {})
        if re.fullmatch(r"pane_\d+", name):
            s = ex.get("sched", {})
            if not all(k in s for k in ("on", "off", "allNight")):
                fail(office, "%s lacks extras.sched" % name)
        if name.startswith("elev_panel_") and not all(k in ex for k in ("p0", "d", "rot", "ax")):
            fail(office, "%s lacks p0/d/rot/ax extras" % name)
        if (name.startswith("frame_") or name in ("pin", "matlib_pane_lit") or name.startswith("sconce_")) and not ex.get("hidden"):
            fail(office, "%s should carry extras.hidden" % name)
        if name.startswith("station_") and not re.fullmatch(r"station_(\d+|f)_(lamp|screen)(_\d+)?", name):
            fail(office, "odd station node name %s" % name)
    for m in mats:
        ex, name = m.get("extras", {}), m.get("name", "")
        if name == "haze" and not re.fullmatch(r"#[0-9a-f]{6}", str(ex.get("base", ""))):
            fail(office, "haze material without extras.base")
        if name == "tower":
            strength = m.get("extensions", {}).get("KHR_materials_emissive_strength", {}).get("emissiveStrength")
            if not ex.get("unlit") or "emissiveTexture" not in m or strength != 0:
                fail(office, "tower material lacks unlit/emissiveTexture/strength 0")
        if name == "facade" and "emissiveUv" not in ex:
            fail(office, "facade material lacks extras.emissiveUv")
    hidden = {n.get("name") for n in nodes if n.get("extras", {}).get("hidden")}
    return names, mats, hidden


def heaviest(gltf, top=8):
    acc, mats = gltf.get("accessors", []), gltf.get("materials", [])
    size = lambda i: acc[i]["count"] * COMP[acc[i]["componentType"]] * NCOMP[acc[i]["type"]]
    counted, per = set(), defaultdict(lambda: [0, 0])
    for mesh in gltf.get("meshes", []):
        for p in mesh["primitives"]:
            idx = list(p["attributes"].values()) + ([p["indices"]] if "indices" in p else [])
            key = p.get("material", -1)
            tris = (acc[p["indices"]]["count"] if "indices" in p else acc[p["attributes"]["POSITION"]]["count"]) // 3
            per[key][1] += tris
            for i in idx:
                if i not in counted:
                    counted.add(i)
                    per[key][0] += size(i)
    rows = []
    for key, (bytes_, tris) in sorted(per.items(), key=lambda kv: -kv[1][0])[:top]:
        m = mats[key] if key >= 0 else {}
        color = m.get("pbrMetallicRoughness", {}).get("baseColorFactor")
        label = m.get("name") or ("rgb(%s)" % ",".join("%.2f" % c for c in color[:3]) if color else "white/textured")
        rows.append("%7.2f MB %8d tris  mat#%d %s" % (bytes_ / 1048576, tris, key, label))
    return rows


def check_json(office, info, names, hidden):
    need = ["id", "bounds", "sunOff", "fog", "maxN", "spd", "env", "spots", "stations", "founderStation", "elevNear", "mapHits", "lanes", "thumbTargets"]
    for k in need:
        if k not in info:
            fail(office, "json lacks %s" % k)
    if not (is_vec(info["bounds"]["min"]) and is_vec(info["bounds"]["max"]) and is_vec(info["sunOff"])):
        fail(office, "bounds/sunOff are not 3-vectors")
    if set(info["spots"]) != set(KINDS[office]):
        fail(office, "spot kinds %s != %s" % (sorted(info["spots"]), sorted(KINDS[office])))
    for kind, spots in info["spots"].items():
        if not spots:
            fail(office, "spot kind %s is empty" % kind)
        for s in spots:
            if not (is_vec(s["pos"]) and isinstance(s["face"], (int, float)) and isinstance(s["pose"], str)
                    and all(is_vec(c) for c in s["chain"]) and isinstance(s["floor"], (int, float)) and isinstance(s["zone"], str)):
                fail(office, "malformed %s spot %s" % (kind, s))
                break
    node_set = set(names)
    for st in info["stations"] + ([info["founderStation"]] if info["founderStation"] else []):
        if not (is_vec(st["lampPos"]) and is_vec(st["screenPos"])):
            fail(office, "station %s positions are not 3-vectors" % st["node"])
        for part in ("lamp", "screen"):
            if "%s_%s" % (st["node"], part) not in node_set:
                fail(office, "GLB lacks %s_%s" % (st["node"], part))
    if office != "city" and len(info["spots"]["desk"]) != len(info["stations"]) + 1:
        fail(office, "desk spots %d != stations %d + founder" % (len(info["spots"]["desk"]), len(info["stations"])))
    for key in ("panes", "elevPanels"):
        for p in info.get(key, []):
            if p["node"] not in node_set:
                fail(office, "GLB lacks %s" % p["node"])
    if set(info.get("hidden", [])) != hidden:
        fail(office, "json hidden %s != GLB extras.hidden %s" % (sorted(info.get("hidden", [])), sorted(hidden)))
    if info["elevNear"] and not (is_vec(info["elevNear"]["center"]) and is_vec(info["elevNear"]["half"])):
        fail(office, "elevNear malformed")
    if office == "city":
        if not info["mapHits"] or not info["lanes"]:
            fail(office, "city needs mapHits and lanes")
        for h in info["mapHits"]:
            if not (h["office"] and is_vec(h["box"]["min"]) and is_vec(h["anchor"])):
                fail(office, "mapHit %s malformed" % h["id"])
            if "frame_" + h["id"] not in node_set:
                fail(office, "GLB lacks frame_%s" % h["id"])
        for ln in info["lanes"]:
            if ln["carNode"] not in node_set or not (is_vec(ln["a"], 2) and is_vec(ln["b"], 2)):
                fail(office, "lane of %s malformed" % ln["carNode"])
        hit = info.get("meetHit")
        if not (hit and is_vec(hit["box"]["min"]) and is_vec(hit["box"]["max"]) and is_vec(hit["anchor"])):
            fail(office, "city needs the meetings' tower (meetHit)")
        if "crown" not in info["materials"]:
            fail(office, "city lacks the tower's crown material")
    if office == "meet":
        if len(info["spots"]["guest"]) != 3:
            fail(office, "meet needs 3 guest seats, has %d" % len(info["spots"]["guest"]))
        pen = info.get("pen")
        if not (is_vec(info.get("table")) and pen and is_vec(pen["pos"]) and is_vec(pen["rot"])):
            fail(office, "meet needs the table and the pen's place on it")
        if "pen" not in node_set:
            fail(office, "GLB lacks pen")


for office in sys.argv[1:] or IDS:
    glb, js = os.path.join(OUT, office + ".glb"), os.path.join(OUT, office + ".json")
    if not (os.path.exists(glb) and os.path.exists(js)):
        fail(office, "missing GLB or JSON")
        continue
    gltf, blen, total = read_glb(glb)
    names, mats, hidden = check_glb(office, gltf, blen)
    info = json.load(open(js, encoding="utf-8"))
    check_json(office, info, names, hidden)
    count = lambda pre: sum(1 for n in names if n.startswith(pre))
    print("== %s  glb %.2f MB  json %.1f KB" % (office, total / 1048576, os.path.getsize(js) / 1024))
    print("   nodes %d  meshes %d  materials %d  textures %d  images %d  extensionsUsed %s" % (
        len(gltf.get("nodes", [])), len(gltf.get("meshes", [])), len(mats), len(gltf.get("textures", [])),
        len(gltf.get("images", [])), ",".join(gltf.get("extensionsUsed", []))))
    print("   named: " + "  ".join("%s*=%d" % (p, count(p)) for p in PATTERNS if count(p)) +
          "".join("  %s" % n for n in ("pin", "ferry") if n in names))
    print("   extras: %d nodes, %d materials" % (sum(1 for n in gltf["nodes"] if "extras" in n), sum(1 for m in mats if "extras" in m)))
    print("   shared materials: " + ", ".join(sorted({m.get("name") for m in mats if m.get("name")})))
    print("   spots: " + ", ".join("%s=%d" % (k, len(v)) for k, v in info["spots"].items()) +
          "  stations=%d founder=%s" % (len(info["stations"]), bool(info["founderStation"])))
    print("   heaviest:")
    for row in heaviest(gltf):
        print("     " + row)

print("\n%d problem(s)" % len(errors))
for e in errors:
    print("  - " + e)
sys.exit(1 if errors else 0)
