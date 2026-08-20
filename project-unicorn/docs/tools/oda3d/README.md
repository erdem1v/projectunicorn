# ODA 3D spike — tooling

Offline plates of the ODA room rendered by Godot 4.6 itself (Forward+, LightmapGI, SSAO/SSIL/SSR,
PCSS shadows, supersampled SubViewport capture), from the **same scene** the sealed procedural render
was made with. Decision input for Erdem — not shipped content. `.gdignore` keeps Godot out of this dir.

Record of what was found and decided: `docs/audits/AUDIT_2026-08-19_oda3d_source.md` (Phase 0) and
`docs/audits/AUDIT_2026-08-19_oda3d_render_spike.md` (result + gate).

## Pipeline (all from the `project-unicorn` root)

| step | command | produces |
|---|---|---|
| 1. assemble export page | `python docs/tools/oda3d/make_export_page.py` | `docs/tools/oda3d/export_glb.html` — a verbatim slice of `tools/oda_render_rig/layers.html` (line ranges are anchored; a shifted rig fails loudly) |
| 2. export GLB + source JSON | `bash docs/tools/oda3d/run_export.sh <status_dir>` | `art/oda3d/oda3d_room.glb`, `art/oda3d/oda3d_source_scene.json` (camera, lights, materials, mesh flags, projected anchors at the pinned camera) |
| 3. import with lightmap UVs | `godot --headless --path . --import` (then set `meshes/light_baking=2`, `meshes/lightmap_texel_size=0.008`, `generate_lods=false`, `create_shadow_meshes=false` in `oda3d_room.glb.import` and `--import` again; run one throwaway scene before any gated run — class-cache gotcha) | `.godot/imported/…scn` with UV2 on all 138 meshes |
| 4. bake lightmaps | `godot -e --path . --windowed -s res://scenes/oda3d/oda3d_bake_driver.gd` | `scenes/oda3d/oda3d_{day,night}.lmbake` + `.exr` atlases, `art/oda3d/oda3d_bake_log.json` |
| 5. capture plates | `godot --path . --windowed --resolution 960x540 res://scenes/oda3d/oda3d_capture.tscn -- --oda3d-mode=day --oda3d-size=7680x4320 --oda3d-scale=1.5 --oda3d-msaa=4 --oda3d-warmup=60 --oda3d-downscale=1` (then `--oda3d-mode=night`) | `art/oda3d/plates/oda_{day,night}_{8k,4k,1080p}.png`, `art/oda3d/oda3d_camera_light.json` |
| 6. compare | `python docs/tools/oda3d/compare_plates.py --sealed tools/oda_render_rig/out/proof-day.png --render art/oda3d/plates/oda_day_4k.png --out art/oda3d/plates/side_by_side_day.png --label day --rects` | side-by-side with contract rects + per-region mean/ratio/clip table |

`godot` = `C:\Users\erdem\Desktop\Godot_v4.6.2-stable_win64_console.exe`. Steps 4 and 5 need a real GPU
(the lightmapper builds its own RenderingDevice; the capture renders) — never `--headless`.

## Why each piece is shaped the way it is

- **Export page generated, not copied.** The spike's Phase 0 ruling is that every placement traces to a
  line of the rig; slicing `layers.html` by anchored line ranges makes that true by construction.
  The only authored deltas are names on the seven unnamed room materials (glTF carries material
  names; Godot maps materials by them) and the exporter/JSON glue.
- **GLB, not primitives.** Three's `GLTFExporter` carries the lathe/extrude/torus geometry and the
  PBR values exactly; Godot's scene importer generates lightmap UV2 (xatlas) at import.
- **Bake driver = `extends SceneTree` run with `-e -s`.** `LightmapGI.bake()` has no script
  binding; `--script` only accepts MainLoop subclasses, but with `-e` Godot still builds the editor
  into that tree, so the script can reach the editor plugin's `_bake` (found through the bake
  button's `pressed` connection — the editor UI on this machine is Turkish, so never by text). A
  pre-assigned external `.lmbake` skips the save-path dialog.
- **Capture = SubViewport + `get_image()`.** Movie Maker captures the window at window size, which
  the OS clamps; a SubViewport renders 7680×4320 (×1.5 supersampling = 11520×6480 internal) behind a
  small window. Warm-up frames let TAA/SSIL/SSR settle.
- **Energy conversion.** three r0.184 physical units → Godot non-physical: `E = I / π` (Godot ×π
  cancels the Lambert /π). Hemisphere ambient → bake environment = uniform sky colour × I/π
  (`ENVIRONMENT_MODE_CUSTOM_COLOR`; the floor's real bounce plays three's ground term) and a
  two-tone `ProceduralSkyMaterial` for the real-time ambient of the non-lightmapped wall
  segments; exposures copied then trimmed by the region table, not by eye.

## After every editor run (step 4)

Opening the editor rewrites `project.godot` (the MCP runtime plugin re-saves settings, comments
stripped) and stamps UIDs into `themes/*.tres`. Those are side-effects, not spike changes — restore
them (`git checkout -- project-unicorn/project.godot project-unicorn/themes/master_theme.tres
project-unicorn/themes/oda_frozen_theme.tres`) before reading `git status`. Bake gotchas that cost
bakes this round are listed in `docs/audits/AUDIT_2026-08-19_oda3d_render_spike.md` ("Things learned").

## Status dir

`run_export.sh` writes `DONE.txt`/logs to the status dir you pass (scratchpad), never into the
repo. Chrome runs as a foreground `--app` window with its own profile (background tabs freeze
`fetch().then()` — see `tools/oda_render_rig/README.md`).
