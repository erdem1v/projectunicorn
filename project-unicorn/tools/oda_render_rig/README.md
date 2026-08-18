# ODA render rig

Produces the room plates and per-object transparent layers for ODA's centre view.
Not shipped content — a tool. `.gdignore` keeps Godot out of this directory.

Full record of what it produced and why: `docs/design/oda_art_pipeline.md`.

## Run

```
python serve.py                       # static server + PNG/JSON sink on 127.0.0.1:8732
./run.sh "auto=1&solve=1"             # solve the camera, then export everything
./run.sh "auto=1&solve=1&proofonly=1" # just the day/night proofs — fast framing loop
./run.sh "auto=1&cam=0.298,1.35,1.56,0.38,-1.91,44"   # pinned camera, full export
```

Outputs land in `./out/`. `run.sh` waits for `out/DONE.txt`, then closes the window
and writes downscaled `*_view.jpg` proofs.

## Two things that will bite you

**1. Drive it from a FOREGROUND window, never a background tab.** `run.sh` launches
Chrome with its own `--user-data-dir` and `--app`. This is not cosmetic. Driven
through a background tab, Chrome *freezes* the page: `toBlob()` callbacks and
`fetch().then()` never fire — verified with an 8×8 canvas, which never fired
either. Synchronous code still evaluates, so the tab looks alive and the freeze
reads like a slow 4K encode. A foreground window also keeps the real GPU, so
output matches the approved look instead of a software rasteriser.
`run.sh` kills only its own Chrome, matched on the profile path — never the
user's browser. (That filter was fixed on 2026-08-17: it matched `*oda_rig*chrome-profile*`
while the profile it launches is `oda_render_rig/chrome-profile`, and `oda_rig` is not a
substring of `oda_render_rig` — so the self-kill was a silent no-op and windows piled up
across runs. Harmless direction, but it made repeated runs fight for the port.)

**One more trap, on the Godot side of the same loop.** After you install new PNGs you must
run `godot --headless --path . --import` or the engine keeps serving the cached `.ctex` and
you will shoot the OLD art with the NEW constants — which looks like a layout bug, not a
stale cache. It bit this round: the phone vanished because its atlas region had moved to
x 1976 while the cached texture still had the phone at x 2721. Then `--import` itself
writes an incomplete `global_script_class_cache.cfg`, so the FIRST run after it dies with
`Parse Error: Identifier "AngelRoundSystem" not declared` cascading into failed autoloads,
and repairs the cache on its way out. Runs 2+ are clean. So: `--import`, then one throwaway
warm-up run, and only then a gated shot battery — otherwise the battery log's error gate
fires on a transient and any frames it produced were rendered with dead autoloads.

**2. The camera is SOLVED, not fitted to a picture.** Round 1 fitted it to the
director's approved proof PNG (MAE 1.96) and was rejected at F5: reproducing a
good *picture* gave a bad *backdrop* — board_inner collapsed to 58% of the
watercolour room's width and the cards no longer fit.

`RIG_SOLVE(seed)` instead fits the **layout contract**: the normalized rects in
`OdaLayout.RECTS`, which every card and hotspot was built against. It scores
projected geometry, not pixels, so it needs no GPU and runs in ~100 ms.

```
camera = [x, y, z, yawDeg, pitchDeg, fov]      # look-at target is DERIVED
```
The target is derived on purpose. Expressed as `|pos.x − target.x|`, the
"frontal" penalty was gamed by pushing the target 494 m away, where any offset is
angularly nil — the solver did exactly that and wandered 17k evaluations. Angles
cannot be cheated by distance. `MAX_EVALS` + a wall-clock deadline are also
there: with a 1e-9 acceptance threshold a descent can crawl the lattice forever.

Current answer (six seeds, one basin):
`pos (0.298, 1.35, 1.56) · yaw 0.38° · pitch −1.91° · fov 44`

**The camera is now PINNED to that answer — do not re-solve without reading this.**
The sealed-art round (2026-08-17) re-ran `solve=1` and it walked to
`pos (−0.05, 1.637, 1.729) · pitch −9.05°`, leaving `board_inner` 214 px right of
contract — the round-1 failure all over again. Cause measured, not guessed: the sealed
scene MOVED the phone half a metre left, so `RECTS.phone` (which still holds the *old*
projection) became a physically unreachable target, and the solver sacrificed the
heaviest host chasing it. `RIG_WEIGHT.phone` is now `{p:0, s:0}` and props whose source
position the director has changed must be zeroed the same way — a prop target only keeps
the camera honest while it is still true. Pinned, all four hosts land on contract:
`board_outer` −4.9/−6.0 px, `board_inner` −5.0/−6.1 px at 100.0% × 100.0% size,
`frames_band` and all three `frame_outer_N` within 0.2 px, `monitor` within 0.6 px.

## Scoring surface

- `RIG_WEIGHT` — per-anchor `{p: position, s: size}`. Hosts (board, monitor,
  frames) are weighted on **size**, because their content is laid out in
  host-relative fractions and clips when they shrink. Props (lamp, mug, phone)
  are weighted on **position** only: the watercolour room is a painting, not a
  projection — its mug implies 2705 px/m and its monitor 1481 px/m, which would
  put the camera inside the desk. No camera satisfies both.
- `RIG_COMP` — frontality, pitch allowance, fov band, desk-reaches-frame-bottom,
  and the window terms. The window is scored on **clipped visible width**, not
  its AABB, because the window wall runs toward the camera and its unclipped box
  is meaningless. It must be on screen: it is a tour stop and the room's only
  light source. The first solve framed it out and rendered flat and brown.
- `RIG_SHADOW_OPACITY(v)` — contact-shadow strength, currently `0.25`. Round 1
  shipped `1.0` and produced near-opaque black bars (alpha mean 157–237, p95 255).
  Target band is roughly 40–70 mean; the current setting measures 49.9.

## Fidelity

The scene is the design scene's **own code** — `desk-builders.js` verbatim, and
the room/light/camera construction copied line-for-line from `office-room.html`.
Deliberate deltas only: `alpha: true` on the renderer (the source omits it, so
its own export writes opaque black and cannot emit a transparent layer, and
alpha is a context-creation flag that cannot be toggled at runtime), OrbitControls
dropped, plus the measurement/solve/export additions. The design scene itself is
read-only and was not modified.

## Outputs

| File | What |
|---|---|
| `oda-plate-{day,night}.png` | room, desk, window, frames, board — five desk objects hidden |
| `oda-{monitor,keyboard,desk_lamp,mug,phone}-day.png` | isolated object, transparent |
| `oda-desk_lamp-night.png` | night variant — lit bulb. The ONLY shipped night layer |
| `oda-monitor-night.png` | NOT shipped since 2026-08-17. Kept as the measurement reference for `ODA_NIGHT_TINT` — see below |
| `oda-shadow-<obj>-{day,night}.png` | true contact shadow on the desk top, own alpha layer |
| `proof-{day,night}.png` | whole-room proofs — what the F5 gate is judged on |
| `anchors.json` / `solve.json` | measured REGIONS, projected anchors, glass, solver report |

~~`oda-shadow-desk_lamp-night.png` is legitimately empty: at night the spot
originates at the lamp's own bulb, so the lamp casts nothing onto the desk.~~
**No longer true (2026-08-17).** The sealed night rig added a shadow-casting warm
ceiling `PointLight`, so at night every object casts a desk shadow — the lamp's measures
9036 px at alpha mean 59.9. What IS still empty is `oda-shadow-phone-*` in both modes:
the phone lies flat, so its contact shadow is hidden underneath it.

**Which night layers ship, and why only the lamp.** Measured night/day channel ratio over
the shared opaque mask: monitor chassis `(0.906, 0.783, 0.621)` — all below 1, so a single
`modulate` reproduces it exactly, which is what retired `monitor_night_3840x2160.png` and
set `UiTokens.ODA_NIGHT_TINT`. The lamp measures `(1.716, 1.370, 0.889)` — **above 1** on
two channels, because the bulb lights itself. A multiply cannot brighten, so the lamp
*must* stay a separate layer. That ratio test is the rule for any future object.

**Plates carry no wall shadows, by construction.** `showPlate()` hides the five desk
objects and three.js drops hidden objects from the shadow pass too; the contact-shadow
pass then uses the **desk top as the sole catcher**. So a cast shadow on the *wall* cannot
reach a plate by either route. Verified 2026-08-17 on the sealed night render: the wall
behind the monitor measures mean 84.46 / std 8.16 in the plate against 84.63 / 7.98 for
never-shadowed reference wall, while the whole-room proof measures 42.86 / 41.37 with
min 0. If a director reports a wall shadow, they are looking at a proof or at the design
page's own `render4k()` — both of which render the objects.

Contact shadows are real, not blobs: the object stays in the scene with
`colorWrite = false` (still casts, paints nothing) and the desk top swaps to
`ShadowMaterial`. Two traps found while building it — the floor must **not** be a
catcher (the desk's own floor-shadow otherwise lands in every layer; measured,
all five returned the same 2505×656 box), and the desk top must stop *casting*
for the pass or it shadows itself.

## Integration

`REGIONS` come from each render's own alpha channel (`alphaBounds`), painted
anchors from projected room geometry, `MONITOR_GLASS_REL` from the `screen`
mesh's eight world corners. Because plate and objects share one camera and one
canvas, `RECTS[id] == REGIONS[id] / ART` — which makes the aspect invariant
(`target aspect == region aspect`) structural rather than arithmetic.
