"""Assemble docs/tools/oda3d/export_glb.html from the ODA render rig's own source.

Why a generator and not a hand copy: the spike's Phase 0 ruling is that every
placement traces to a line of `tools/oda_render_rig/layers.html`. Slicing that file
by line range makes the copy verbatim BY CONSTRUCTION and re-runnable if the rig
changes. Only the glue (imports, material names, exporter, JSON) is authored here.

Run:  python docs/tools/oda3d/make_export_page.py   (from project-unicorn root)
"""
import os, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SRC = os.path.join(ROOT, "tools", "oda_render_rig", "layers.html")
OUT = os.path.join(ROOT, "docs", "tools", "oda3d", "export_glb.html")

# 1-based inclusive line ranges of layers.html that are copied VERBATIM.
# Each range is guarded by an anchor string that must appear on its first line,
# so a future edit of layers.html that shifts lines fails loudly here instead of
# silently exporting the wrong block.
SEGMENTS = [
    ("log + renderer + scene + camera",     38,  52, "const LOG"),
    ("room materials + geometry + props",   54, 148, "// ---- room materials"),
    ("day/night light rigs",               150, 199, "// ---- lighting rigs"),
    ("setMode",                            201, 219, "// ---- day/night"),
    ("W/H + renderAt",                     230, 236, "const W = 3840"),
    ("projectMesh",                        262, 282, "/** Screen-space rect"),
    ("projectObject",                      430, 456, "/** Projected screen AABB"),
    ("WC (layout contract copy)",          492, 505, "// OdaLayout.RECTS @ HEAD"),
    ("anchorsNorm",                        564, 582, "function anchorsNorm"),
    ("camTarget + applyCam",               620, 637, "// Camera parameters are"),
]

HEAD = """<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="utf-8">
<title>ODA 3D spike — GLB export (generated from layers.html)</title>
<script type="importmap">
{
  "imports": {
    "three": "https://unpkg.com/three@0.184.0/build/three.module.js",
    "three/addons/": "https://unpkg.com/three@0.184.0/examples/jsm/"
  }
}
</script>
<style>html,body{margin:0;height:100%;background:#111;color:#ddd;font:12px ui-monospace,monospace}
canvas{display:block;width:100vw;height:100vh}
#log{position:fixed;left:8px;top:8px;white-space:pre;background:rgba(0,0,0,.6);padding:8px;max-height:96vh;overflow:auto}</style>
</head>
<body>
<div id="log">export rig booting…</div>
<script type="module">
import * as THREE from 'three';
import { GLTFExporter } from 'three/addons/exporters/GLTFExporter.js';
import { box, buildMonitor, buildKeyboard, buildLamp, buildPhone, buildMug, buildFrame, buildCorkboard } from '../../../tools/oda_render_rig/desk-builders.js';

// ============================================================================
// ODA 3D SPIKE — GLB EXPORT PAGE. GENERATED FILE — do not edit by hand; edit
// make_export_page.py and re-run it. Every block marked "VERBATIM layers.html:A-B"
// is sliced from tools/oda_render_rig/layers.html unchanged. Authored glue is
// marked "SPIKE". The scene is therefore the sealed rig's scene by construction.
// ============================================================================
"""

# SPIKE glue inserted right after the room-materials/geometry segment: names on
# the seven room materials that layers.html leaves unnamed (desk-builders.js
# names its own). glTF carries material names; Godot maps materials by name.
# Metadata only — no colour/roughness/transform is touched.
NAMES = """
// SPIKE: material names for glTF (metadata only; the seven room materials are
// unnamed in layers.html; desk-builders.js names its own).
plaster.name = 'plaster'; plasterR.name = 'plaster_r'; floorMat.name = 'floor';
deskWood.name = 'desk_wood'; deskWoodD.name = 'desk_wood_dark'; mullion.name = 'mullion';
skyMat.name = 'sky';
"""

TAIL = r"""
// ============================================================================
// SPIKE — export. Pinned camera (README "do not re-solve"), then: GLB of the
// `room` group (geometry + materials, no lights/camera — those go to Godot via
// the JSON so energies can be converted explicitly), plus a JSON that records
// everything Godot needs and everything the gate compares against.
// ============================================================================
const PINNED_CAM = [0.298, 1.35, 1.56, 0.38, -1.91, 44];
const deskTop = desk.getObjectByName('desk_top');   // SPIKE: same lookup as layers.html:320

async function postBlob(name, blob){
  const r = await fetch('/save/' + name, { method:'POST', body: blob });
  if (!r.ok) throw new Error(name + ' -> HTTP ' + r.status);
}
async function postText(name, text){ await postBlob(name, new Blob([text], {type:'text/plain'})); }

const hex = c => '#' + c.getHexString();
function lightInfo(l){
  const p = new THREE.Vector3(); l.getWorldPosition(p);
  const o = { type: l.type, name: l.name || '', color: hex(l.color), intensity: l.intensity,
              position: [p.x, p.y, p.z], castShadow: !!l.castShadow };
  if (l.isHemisphereLight) { o.skyColor = hex(l.color); o.groundColor = hex(l.groundColor); delete o.position; }
  if (l.target) { const t = new THREE.Vector3(); l.target.getWorldPosition(t); o.target = [t.x, t.y, t.z]; }
  if (l.isPointLight || l.isSpotLight) { o.distance = l.distance; o.decay = l.decay; }
  if (l.isSpotLight) { o.angle = l.angle; o.penumbra = l.penumbra; }
  if (l.shadow) { o.shadow = { mapSize: [l.shadow.mapSize.x, l.shadow.mapSize.y], bias: l.shadow.bias, normalBias: l.shadow.normalBias }; }
  return o;
}
function matInfo(m){
  const o = { type: m.type, name: m.name, color: hex(m.color) };
  if ('roughness' in m) o.roughness = m.roughness;
  if ('metalness' in m) o.metalness = m.metalness;
  if (m.emissive) { o.emissive = hex(m.emissive); o.emissiveIntensity = m.emissiveIntensity; }
  return o;
}
function meshInventory(){
  const out = [];
  room.updateWorldMatrix(true, true);
  room.traverse(m => {
    if (!m.isMesh) return;
    const p = new THREE.Vector3(); m.getWorldPosition(p);
    const path = []; let n = m; while (n && n !== room) { path.unshift(n.name || '?'); n = n.parent; }
    out.push({ path: path.join('/'), material: m.material.name, castShadow: !!m.castShadow,
               receiveShadow: !!m.receiveShadow, world: [+p.x.toFixed(5), +p.y.toFixed(5), +p.z.toFixed(5)] });
  });
  return out;
}

(async function run(){
  try {
    setMode('day'); showAllForExport();
    applyCam(PINNED_CAM);
    renderer.setPixelRatio(1); renderer.setSize(innerWidth, innerHeight, false);
    camera.aspect = W/H; camera.updateProjectionMatrix();
    renderer.render(scene, camera);
    say('camera ' + JSON.stringify(PINNED_CAM));

    // ---- JSON first (cheap, and useful even if the GLB fails) ----
    const mats = {}; room.traverse(m => { if (m.isMesh) mats[m.material.name] = matInfo(m.material); });
    const info = {
      generated_by: 'docs/tools/oda3d/export_glb.html (generated from tools/oda_render_rig/layers.html)',
      three_version: THREE.REVISION,
      art: [W, H],
      camera: { cam: PINNED_CAM, position: PINNED_CAM.slice(0,3), target: camTarget(PINNED_CAM), fov_deg: PINNED_CAM[5],
                aspect: W/H, near: camera.near, far: camera.far, up: [0,1,0], note: 'fov is VERTICAL (three PerspectiveCamera); look-at target DERIVED from yaw/pitch (layers.html camTarget)' },
      renderer: { toneMapping: 'ACESFilmic', toneMappingExposure_day: 1.05, toneMappingExposure_night: 1.0, shadowMap: 'PCFShadowMap' },
      lights: { day: dayRig.children.filter(c => c.isLight).map(lightInfo),
                night: nightRig.children.filter(c => c.isLight).map(lightInfo) },
      setMode: { sky_day: '#ffedc8', sky_night: '#1e2638',
                 screen_emissive: '#000000', screen_emissiveIntensity: 0, screen_roughness: 0.15,
                 bulb_emissive_day: '#ffdda0', bulb_emissive_night: '#ff9d4a', bulb_emissiveIntensity_day: 0.15, bulb_emissiveIntensity_night: 1.2 },
      materials: mats,
      meshes: meshInventory(),
      layout_contract_WC: WC,
      anchors_norm_at_pinned_cam: anchorsNorm(),
      monitor_screen_px: projectMesh(monitor, 'screen'),
      desk_top_px: projectObject(deskTop),
      lamp_bulb_world: (() => { const v = new THREE.Vector3(); lampBulb.getWorldPosition(v); return [v.x, v.y, v.z]; })(),
      lamp_head_world: (() => { const v = new THREE.Vector3(); lampHead.getWorldPosition(v); return [v.x, v.y, v.z]; })(),
      pool_target: [poolTarget.x, poolTarget.y, poolTarget.z]
    };
    await postText('oda3d_source_scene.json', JSON.stringify(info, null, 2));
    say('json ✓');

    // ---- GLB of the room group ----
    const exporter = new GLTFExporter();
    const buf = await exporter.parseAsync(room, { binary: true, onlyVisible: true, trs: false });
    await postBlob('oda3d_room.glb', new Blob([buf], {type:'model/gltf-binary'}));
    say('glb ✓ ' + buf.byteLength + ' bytes');
    await postText('DONE.txt', 'ok');
  } catch (e) {
    say('EXPORT FAILED: ' + e);
    await postText('DONE.txt', 'ERR ' + (e && e.message ? e.message : e));
  }
})();

function showAllForExport(){ room.children.forEach(c => c.visible = true); }
</script>
</body>
</html>
"""


def main():
    with open(SRC, encoding="utf-8") as f:
        lines = f.read().split("\n")
    parts = [HEAD]
    for label, a, b, anchor in SEGMENTS:
        first = lines[a - 1]
        if anchor not in first:
            sys.exit(f"anchor mismatch for '{label}': line {a} is {first!r}, expected to contain {anchor!r}")
        parts.append(f"\n// ---- VERBATIM layers.html:{a}-{b} ({label}) ----\n")
        parts.append("\n".join(lines[a - 1:b]))
        parts.append("\n")
        if label.startswith("room materials"):
            parts.append(NAMES)
    parts.append(TAIL)
    html = "".join(parts)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(html)
    print("wrote", OUT, len(html), "bytes;", len(SEGMENTS), "verbatim segments")


if __name__ == "__main__":
    main()
