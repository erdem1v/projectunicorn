---
name: godot-lightmap-bake-gotchas
description: "Godot 4.6.2 LightmapGI/offline-render facts measured during the ODA 3D spike (2026-08-19) — owner rule, -e -s driver, cube omni atlas slots, inert bounce_indirect_energy, editor side-effects on project.godot/themes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 120ea357-12e7-4a95-ae14-5afe21188847
  modified: 2026-08-19T09:23:30.224Z
---

Measured on the ODA 3D spike (2026-08-19, o zaman worktree `oda3d-spike`; 2026-08-20'de `main`'e alındı), Godot 4.6.2:

- `LightmapGI._find_meshes_and_lights()` SKIPS children with no owner → runtime-spawned lights must get `owner` in the editor or the bake has no lights (six bakes lost; atlas L0 mean 0.005 vs 0.03 when right).
- `LightmapGI.bake()` has no script binding. Working driver: `godot -e --path . -s <extends SceneTree>.gd` (editor is built into that tree); find the bake via the button's `pressed` connection to `LightmapGIEditorPlugin._bake` (editor UI is Turkish — never by text); pre-assign an external `.lmbake` → no file dialog. Never `--headless` (needs RenderingDevice).
- `bounce_indirect_energy` was inert (0.2 vs 1.6 → byte-identical EXR); `bounces` works (0 → 4 s bake, 4 → ~90 s).
- Custom `Sky` as bake environment bakes BLACK unless its radiance was rendered by a viewport first; forcing the editor 3D viewport from the driver produced RD errors. Use `ENVIRONMENT_MODE_CUSTOM_COLOR`.
- Omni `SHADOW_CUBE` needs TWO atlas slots in one quadrant: `SUBDIV_1` → no shadow at all; 16384×32-bit atlas (1 GB) → all positional shadows vanish silently. 16384×16-bit + subdiv 4 works; `shadow_blur 2` kills the residual 1-px serration at 8K.
- Opening the editor rewrites `project.godot` (MCP runtime plugin `add_autoload_singleton` re-saves, comments stripped) and stamps UIDs into `themes/*.tres` — revert those three files after any `-e` run.
- SubViewport 7680×4320 × scaling_3d_scale 1.5 × MSAA4 renders fine on the RX 9070 XT (~12 s PNG save). three→Godot energy = I/π; Godot ACES runs hotter than three's ACESFilmic (factors 0.90 day / 0.71 night measured).

**Why:** every one of these failed silently (bake "OK", render produced) — only measurement (EXR md5, atlas L0 stats, region means) exposed them.
**How to apply:** before trusting any bake, hash the EXR across a deliberately different setting and read the atlas L0 mean; see `docs/tools/oda3d/README.md` + `docs/audits/AUDIT_2026-08-19_oda3d_render_spike.md` — **2026-08-20'de main'e girdi**, worktree silindi. Related: [[godot-import-cache-gotchas]], [[godot-mcp-runtime-verification]].


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Godot lightmap bake gotchas](godot-lightmap-bake-gotchas.md) — ODA 3D spike 2026-08-19 (worktree `oda3d-spike`, VERDICT better-than-sealed, held for F5): unowned lights are skipped by the baker; bake via `-e -s` SceneTree driver; cube omni needs 2 atlas slots; bounce_indirect_energy inert; editor run rewrites project.godot + theme .tres (revert)
