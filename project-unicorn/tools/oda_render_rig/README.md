# ODA render rig

Source scene (geometry, camera, lights, materials) for ODA's centre-view art; the shipped layers are
rendered from it by the 3D pipeline in `tools/oda3d/` (see `tools/oda3d/README.md`).
Not shipped content — a tool. `.gdignore` keeps Godot out of this directory.

## Run

```
python serve.py                       # static server + PNG/JSON sink on 127.0.0.1:8732
./run.sh "auto=1&solve=1"             # solve the camera, then export everything
./run.sh "auto=1&solve=1&proofonly=1" # just the day/night proofs — fast framing loop
./run.sh "auto=1&cam=0.298,1.35,1.56,0.38,-1.91,44"   # pinned camera, full export
```

Outputs land in `./out/`. `run.sh` waits for `out/DONE.txt`, then closes the window
and writes downscaled `*_view.jpg` proofs. `&shadow=<opacity>` overrides the contact-shadow
strength.

## Two things that will bite you

**1. Drive it from a FOREGROUND window, never a background tab.** `run.sh` launches
Chrome with its own `--user-data-dir` and `--app`. Driven through a background tab,
Chrome *freezes* the page: `toBlob()` callbacks and `fetch().then()` never fire, while
synchronous code still evaluates, so the tab looks alive and the freeze reads like a slow
4K encode. A foreground window also keeps the real GPU, so output matches the approved look
instead of a software rasteriser. `run.sh` kills only its own Chrome, matched on the
profile path — never the user's browser.

After installing new PNGs, run `godot --headless --path . --import` or the engine keeps
serving the cached `.ctex`, and a shot renders the OLD art with the NEW constants — which
looks like a layout bug. The first Godot run after `--import` can fail on the class cache;
do one warm-up run before a gated shot battery.

**2. The camera is SOLVED against the layout contract, not fitted to a picture.**
Reproducing a good *picture* gives a bad *backdrop*: the hosts shrink and the cards no
longer fit. `solve(seed)` fits the normalized rects in `OdaLayout.RECTS`, which every card
and hotspot was built against. It scores projected geometry, not pixels, so it needs no GPU
and runs in ~100 ms.

```
camera = [x, y, z, yawDeg, pitchDeg, fov]      # look-at target is DERIVED
```
The target is derived on purpose: expressed as `|pos.x − target.x|`, the "frontal" penalty
can be gamed by pushing the target far away, where any offset is angularly nil. Angles
cannot be cheated by distance. `MAX_EVALS` + a wall-clock deadline stop a descent that
would otherwise crawl the lattice forever under the 1e-9 acceptance threshold.

**The camera is PINNED** to `pos (0.298, 1.35, 1.56) · yaw 0.38° · pitch −1.91° · fov 44`
(`PINNED_CAM` in `tools/oda3d/make_export_page.py`). A re-solve walks away from it: the
scene's phone was moved, so `RECTS.phone` holds a physically unreachable target, and props
whose position changed must be zeroed in `WEIGHT` the way the phone is — a prop target only
keeps the camera honest while it is still true. Pinned, all four hosts land on contract:
`board_outer` −4.9/−6.0 px, `board_inner` −5.0/−6.1 px at 100.0% × 100.0% size,
`frames_band` and all three `frame_outer_N` within 0.2 px, `monitor` within 0.6 px.

## Scoring surface

- `WEIGHT` — per-anchor `{p: position, s: size}`. Hosts (board, monitor, frames) are
  weighted on **size**, because their content is laid out in host-relative fractions and
  clips when they shrink. Props (lamp, mug, phone) are weighted on **position** only: the
  watercolour room is a painting, not a projection — its mug implies 2705 px/m and its
  monitor 1481 px/m, which would put the camera inside the desk. No camera satisfies both.
- `COMP` — frontality, pitch allowance, fov band, desk-reaches-frame-bottom, and the window
  terms. The window is scored on **clipped visible width**, not its AABB, because the window
  wall runs toward the camera and its unclipped box is meaningless. It must be on screen: it
  is a tour stop and the room's only light source.
- Contact-shadow strength (`shadowMat.opacity`) is `0.25`: an opaque `1.0` gives
  near-black bars. Target band is roughly 40–70 alpha mean; the current setting measures 49.9.

## Fidelity

The scene is the approved design scene's own code — `desk-builders.js` verbatim, and the
room/light/camera construction copied line for line. Deliberate deltas only, each marked
inline in `layers.html`: `alpha: true` on the renderer (alpha is a context-creation flag, and
without it the export writes opaque black and cannot emit a transparent layer), OrbitControls
dropped, the measurement/solve/export additions, and the director-approved scene deltas.

## Outputs

| File | What |
|---|---|
| `oda-plate-{day,night}.png` | room, desk, window, frames, board — five desk objects hidden |
| `oda-{monitor,keyboard,desk_lamp,mug,phone}-day.png` | isolated object, transparent |
| `oda-desk_lamp-night.png` | night variant — lit bulb. The ONLY shipped night layer |
| `oda-monitor-night.png` | not shipped; the measurement reference for `ODA_NIGHT_TINT` — see below |
| `oda-shadow-<obj>-{day,night}.png` | true contact shadow on the desk top, own alpha layer |
| `proof-{day,night}.png` | whole-room proofs — what the framing is judged on |
| `anchors.json` / `solve.json` | measured REGIONS, projected anchors, glass, solver report |

The night rig's shadow-casting warm ceiling `PointLight` makes every object cast a desk
shadow at night. `oda-shadow-phone-*` is empty in both modes: the phone lies flat, so its
contact shadow is hidden underneath it.

**Which night layers ship, and why only the lamp.** Measured night/day channel ratio over
the shared opaque mask: monitor chassis `(0.906, 0.783, 0.621)` — all below 1, so a single
`modulate` reproduces it exactly, which is what `UiTokens.ODA_NIGHT_TINT` does. The lamp
measures `(1.716, 1.370, 0.889)` — **above 1** on two channels, because the bulb lights
itself. A multiply cannot brighten, so the lamp *must* stay a separate layer. That ratio test
is the rule for any future object.

**Plates carry no wall shadows, by construction.** `showPlate()` hides the five desk
objects and three.js drops hidden objects from the shadow pass too; the contact-shadow
pass then uses the **desk top as the sole catcher**. So a cast shadow on the *wall* cannot
reach a plate by either route. A wall shadow seen elsewhere comes from a proof, which renders
the objects.

Contact shadows are real, not blobs: the object stays in the scene with
`colorWrite = false` (still casts, paints nothing) and the desk top swaps to
`ShadowMaterial`. The floor must **not** be a catcher (the desk's own floor-shadow would
land in every layer), and the desk top must stop *casting* for the pass or it shadows itself.

## Integration

`REGIONS` come from each render's own alpha channel (`alphaBounds`), painted
anchors from projected room geometry, `MONITOR_GLASS_REL` from the `screen`
mesh's eight world corners. Because plate and objects share one camera and one
canvas, `RECTS[id] == REGIONS[id] / ART` — which makes the aspect invariant
(`target aspect == region aspect`) structural rather than arithmetic.
