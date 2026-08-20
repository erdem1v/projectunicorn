# AUDIT 2026-08-19 — ODA 3D render spike: result, gate, verdict

## Report to Fable (≤30 lines)

1. **Source finding: (a).** The sealed render is a Three.js scene in-repo (`tools/oda_render_rig/layers.html` + `desk-builders.js`). Exported to GLB with Three's own `GLTFExporter` from a generated verbatim slice of that file (`docs/tools/oda3d/export_glb.html`); the export page's projected anchors equal the rig's `anchors.json` to **0.000 px** on all 11 keys. Details: `AUDIT_2026-08-19_oda3d_source.md`.
2. **Engine:** Godot `4.6.2.stable.official`, Forward+, D3D12 driver, AMD RX 9070 XT. Worktree off `main` (`3c8e4cb`); `project.godot` untouched.
3. **GI method: LightmapGI**, Ultra, 4 bounces, directional, denoised, 2× supersampled, texel 0.8 cm → one 2048²×4 atlas per mode. **Bake time: day 93.3 s, night 93.4 s** (editor-side driver `scenes/oda3d/oda3d_bake_driver.gd`, run with `godot -e -s`). SDFGI fallback not needed.
4. **Plates:** `art/oda3d/plates/oda_{day,night}_8k.png` (7680×4320, rendered 1.5× supersampled = 11520×6480 internal, MSAA 4×, TAA, debanding, 60 warm-up frames) + `_4k` + `_1080p` downscales (Lanczos). Tonemap pair: `tonemap_{aces,agx}_{day,night}_1080p.png`.
5. **Side-by-side:** `art/oda3d/plates/side_by_side_{day,night}.png` (sealed proof | Godot, contract rects drawn on both) + region tables `stats_{day,night}.json`.
6. **JSON:** `art/oda3d/oda3d_camera_light.json` (camera transform/fov, every light's transform/colour/energy/range/attenuation/shadow, environment, LightmapGI settings, viewport/AA, engine, GI method, bake seconds); source values in `art/oda3d/oda3d_source_scene.json`.
7. **Reusable scene:** `scenes/oda3d/oda3d.tscn` + `@tool` `oda3d.gd` (materials by glTF material name, `set_mode(day|night)`, `project_anchors()`), `oda3d_capture.tscn/.gd` (SubViewport offline capture), `oda3d_{day,night}.lmbake` + `.exr`.
8. **Tonemap kept: ACES** (exposure 0.945 day / 0.71 night = source 1.05/1.0 × measured factors). AgX at the same exposure flattened the warm palette (frame contrast std 34.8 vs sealed 44.6; desk drifted 0.85/0.82/0.79 R/G/B) — rejected.
9. **Light design = sealed logic (Erdem ruling A):** all positions/colours from the source, energies ÷π; the source's wall cheat (window wall does not block the sun) kept via `cast_shadow OFF` + `gi_mode DYNAMIC` on the four `rw_*` segments. No ceiling/front wall/chair added (none in source or contract); papers zone = desk strip.
10. **Screens dark glass** (sealed contract) with real SSR/probe reflections. **Physical light units OFF** (startup project setting; not flipped). **No HDRI.**
11. **Match to sealed (4K, region means, Godot/sealed):** day — sun-lit desk 1.02–1.05, desk shadow 1.00, wall shadow 1.08, window 0.99 (0 % clip), cork 1.10, **open walls 1.15–1.25** (real floor bounce — the one tonal deviation); night — walls/desk 1.02–1.11, lamp pool 0.97, window 1.00, mug 1.24. Shadow/lit ratios match (desk 0.76 vs 0.72; wall 0.39 vs 0.36).
12. **Gate: 6/6 pass** (table below), after two fixes found by reading the 8K plates: omni shadow sawtooth on the board edge (cube shadows + 16384/16-bit atlas, subdiv 4, blur 2) and a night window slab too dark (own emission energy).
13. **Verdict (agent): better than the sealed art** — same composition to the pixel, and the light is physically coherent where the sealed is painted: baked bounce fills shadows with warm light, PCSS penumbrae replace hard PCF edges, contact occlusion under objects, reflections in the glass, micro-relief in plaster/wood/cork — with no artefact at 8K/4K. The one reason for doubt: the day back wall runs 15–25 % brighter than sealed (floor bounce); if F5 reads that as lost tan, `ambient_scale`/`exposure_scale_day` are one-line knobs. **Held for Erdem's F5; nothing sealed.**

## Visual acceptance gate (read by the agent on both plates)

| # | item | evidence | result |
|---|---|---|---|
| 1 | Composition within contract tolerance | Godot `project_anchors()` vs rig `anchors.json`: all 11 keys equal to ≤1e-6 normalized (<0.01 px @3840); side-by-sides with rects overlay | PASS |
| 2 | No light leaks, acne, banding | 12 1:1 crops per mode at 8K (wall/floor/desk seams, board edge, window mullion, glass corner, bulb, keys, frame, mug/phone, cork, wall top, desk edge): none; omni sawtooth fixed and re-read at 8K and 4K | PASS |
| 3 | No clipping; readable at 4K | window 0.99 (day) / 1.00 (night) of sealed, clip 0 %; screens are dark glass by contract (emissive N/A), 1.4× sealed glass luminance = reflections, max <40; bulb 0.4–1.3 % clip inside the filament only | PASS |
| 4 | No lightmap seams/blockiness | texel 0.8 cm, 2× supersampled, denoised; crops show smooth bounce gradients, no texel blocks | PASS |
| 5 | Night = same room | printed anchors identical day/night; only rig/sky/bulb/exposure change (`set_mode`) | PASS |
| 6 | Nothing unnamed in frame | visible set = room shell + window/mullions/sky slab + board/notes/pins + 3 frames + desk + monitor + keyboard + lamp + mug + phone, all in source/contract | PASS |

## Things learned (binding for the next person)

- `LightmapGI._find_meshes_and_lights()` **skips children without an owner** — runtime-spawned lights/meshes must be owned in the editor or the bake silently contains no lights (six bakes lost to this).
- `LightmapGI.bake()` has no script binding; `godot -e --path . -s <SceneTree script>` runs inside the editor and can call the plugin's `_bake` through the button's `pressed` connection (editor UI is Turkish here — never match by text). External `.lmbake` pre-assigned = no file dialog.
- `bounce_indirect_energy` changed nothing between 0.2 and 1.6 in 4.6.2 (byte-identical EXR); `bounces` does.
- A custom `Sky` as bake environment needs its radiance cubemap rendered first; from the headless-ish driver it baked black → use `ENVIRONMENT_MODE_CUSTOM_COLOR`.
- Omni `SHADOW_CUBE` needs **two** atlas slots in one quadrant: `SUBDIV_1` gives it none (shadows vanish); 16384×32-bit atlas (1 GB) also fails silently. 16384×16-bit, subdiv 4 works.
- Opening the editor in a fresh worktree rewrites `project.godot` (MCP plugin's `add_autoload_singleton` re-saves settings, comments stripped) and stamps UIDs into `themes/*.tres` — revert those three files after every editor run (done here; `git status` shows only the four spike dirs).
- Three→Godot: energy = intensity/π; Godot's ACES runs hotter than three's ACESFilmic (factors 0.90 day / 0.71 night measured); `NoiseTexture2D` images are ready from frame 1.
- `all_scripts_load` does not exist on `main`; an equivalent replica (detached compile of all 124 `.gd` under scripts/+scenes/) passes.
