# ODA art pipeline — findings and render record

Two related pieces of work on ODA's art. Part A closes out the stood-down
Layered Asset Integration task; Part B records the Art Migration render round
that replaced it.

---

## Part A — Layered Asset Integration (STOOD DOWN, recorded for the file)

Cancelled by the director before any integration, after intake found the
brief's premise did not hold. Recorded here so the next attempt starts from
measurement rather than from the same assumption.

**What the design export actually is.** The brief described a layered asset
bundle. `desk-assets.html` is not one: it is a live Three.js scene that builds
every prop procedurally in JavaScript (`desk-builders.js` — `buildMonitor`,
`buildKeyboard`, `buildLamp`, `buildMug`, `buildPhone`, `buildFrame`,
`buildCorkboard`). There are no per-object image layers in it to import. This
is §2's stop condition, which is why intake halted.

**The "Download GLB" path.** The page exposes a `GLTFExporter` control that
serialises the assembled scene to a single `.glb` and hands it to the browser,
so it lands in the user's ordinary Chrome download directory
(`C:\Users\erdem\Downloads`) under the name the page assigns at click time.
No GLB was ever exported — the task was stood down first — so no filename is
recorded here rather than a guessed one. Note the export is one combined scene,
not per-object files; splitting it into ODA's five sprites would still be
manual work.

**ObjectLayer / REGIONS finding.** ODA's `ObjectLayer` wants one transparent
sprite per prop, and `OdaLayout.REGIONS` wants each sprite's content box in
source pixels with at least `REGION_PAD = 24` px of transparency around it (the
rim-glow shader takes 8 taps outside the region). The design scene cannot emit
that directly: its `WebGLRenderer` is constructed without `alpha: true`, so its
own 4K export writes opaque black and is physically incapable of producing a
transparent layer. `alpha` is a context-creation flag and cannot be switched on
at runtime, which is why any layer export needs a modified copy of the page
rather than the live one.

---

## Part B — Art Migration, round 2 (the render that replaced it)

Round 1 was rejected at the F5 gate: *"perspektif kötü, placementlar kötü,
gölgeler kötü."* Both causes were measured rather than guessed.

### Cause 1 — contact shadows (a defect, now fixed)

The shadow pass used `ShadowMaterial({opacity: 1})`, so every contact-shadow
layer came out near-opaque: alpha mean **157–237** of 255, p95 **255** — pure
black composited onto lit wood. Set to `0.25` and re-measured across all ten
layers: max **64**, overall mean **49.9**, inside the 40–70 target band.

### Cause 2 — the camera

Round 1 fitted the camera to the director's approved proof PNG (MAE 1.96). That
reproduced the framing that was approved *as a picture*, which fails as a UI
backdrop. Measured against the retired watercolour room — whose normalized
rects in `OdaLayout.RECTS` are the layout contract every card and hotspot was
built against — round 1 collapsed every host:

| anchor | watercolour | round 1 | round 2 |
|---|---|---|---|
| `board_inner` | 0.364 × 0.386 | 0.212 × 0.243 (58%) | **0.346 × 0.399 (95%)** |
| `frames_band` | 0.235 × 0.155 | 0.156 × 0.089 (66%) | 0.273 × 0.152 (116%) |
| `monitor`     | 0.280 × 0.527 | 0.128 × 0.213 (46%) | 0.243 × 0.403 (87%) |

**Round 2 solves the camera instead of fitting a picture.** The objective is the
layout contract itself: reproduce `RECTS`. Scoring projected geometry rather
than pixels needs no GPU, so the search is pure matrix math (~100 ms, six seeds,
all converging to one basin).

Solved camera — **`pos (0.298, 1.35, 1.56)`, `yaw 0.38°`, `pitch −1.91°`,
`fov 44`**, aspect 16:9. It landed back on the design file's own fov by moving
*closer* rather than wider.

Three findings worth keeping:

1. **The watercolour room is a painting, not a projection.** Its mug implies
   2705 px/m while its monitor implies 1481 px/m, which would put the camera at
   z = 0.19 — inside the desk. No camera reproduces both, so hosts are matched
   on size and props only on position. `lamp` (41%) and `phone` (32%) stay small
   by honest 3D proportion and that is correct, not a miss.
2. **The window is a hard constraint, not decoration.** It is a tour stop
   (`RECTS.window`, "tıklanmaz — yalnız tur") and the room's only light source.
   The first solve framed it out entirely — the frustum reaches x = 1.32 at the
   window's depth but the window wall is at x = 1.72 — and the result rendered
   flat and brown. It is now scored on *clipped visible width*, not its AABB.
3. **Frontality must be an angle.** Expressed as `|pos.x − target.x|`, the
   solver zeroed the penalty by pushing the look-at target 494 m away and
   wandered 17k evaluations. Reparameterised to `[x, y, z, yawDeg, pitchDeg,
   fov]` with a derived target, the loophole closes.

### Verified clear

- **Board cards vs monitor.** `BOARD_REL`'s left column ends at 0.389 of frame;
  the monitor top is 0.441 → clear. Board overlap is a 3.3% bottom sliver, the
  same benign overlap the watercolour had.
- **Frame documents** (`FRAME_DOC_INSET`) and the **monitor glass** (projected
  from the `screen` mesh) both land inside their hosts.

### `PAPER_SLOTS` moved (director approved 2026-08-10)

The three desk-paper slots sat on open floor to the keyboard's lower left in the
watercolour room. The real 3D desk puts the keyboard exactly there (measured:
`x 0.3029..0.4437`, `y 0.8690..0.9111`), so the first two landed on the keycaps.
They moved to the clear strip between the lamp and the keyboard — lamp right
edge `0.1091`, keyboard left edge `0.3029`. All three now clear the lamp, the
keyboard and the desk's front edge by measurement, and at night they fall inside
the lamp's baked light pool (measured centre `x 0.283, y 0.893`).

*(An earlier note in this file said `paper2` also hung past the desk's front
edge. It did not — the desk surface reaches `y 0.9995` across the full width;
that dark region is the lamp's cast shadow. Only the keyboard collision was
real.)*

## Integration result (2026-08-10)

Installed: plates with contact shadows baked in (5 day / 4 night — the lamp casts
nothing at night), plus nine object layers. Retired art removed. `oda_view.gd`
gained the keyboard sprite, a night texture swap for monitor/lamp, and one fix
the new art forced: evening/dawn tints now reach `ObjectLayer` as well as
`SceneLayer`. Previously only the scene was tinted; watercolour props were
painted with their own light so it passed, but layers rendered from the *same*
light as the plate look like daylight sitting on an orange room.

**Verification**

| gate | result |
|---|---|
| smoke suite (count derived from source: 153 arms == 153 funcs) | **153 / 153** |
| `--theme-audit=oda` vs frozen reference | 122 → 123 lines: **+1 added, 0 removed, 0 modified** |
| 9 ODA shot kinds (day/night/tour/hover/event/tab/milestones/market1/market2) | 0 parse or script errors |
| viewports 3840×1080 · 2560×1080 · 1920×1200 · 1280×720 | all hold; 32:9 keeps every anchor in the `MAX_CROP` band |

The single audit line is `AUDIT|/ObjectLayer/Keyboard|TextureRect|--|-|-|-|-|-` —
all-dashes, i.e. it resolves no theme values at all. So the +1 is the structural
addition of a sprite node, and `oda_frozen_theme.tres` is provably untouched.
**No unfreeze was needed**; the frozen theme stands.

**The smoke suite caught a real defect.** `oda_anchors_stay_in_band` failed on
the first run: my moved `papers_zone` ended at `y 0.984`, outside the visible
band `[0.020, 0.980]` at the shell's 1.851 aspect. The old value ended at exactly
`0.980` — it had been tuned to that edge. Slots and zone shifted up `0.006`.
Worth recording that this leaves things *better* than before: the old third slot
ended at `0.988` and the `MAX_CROP` note in `oda_layout.gd` openly acknowledged
it was being clipped. All three now finish inside the band.

### Phone glass — the constants were stale, and fixing that fixed the size

First pass reported the glass as unreadably small (~59 × 21 px at 1080p, against
~182 × 71 in the watercolour room) and escalated it under D4.3. Re-deriving the
constants instead of escalating turned out to be the answer: all three were
watercolour-era values and **one of them was outright wrong on the new art.**

Derived the same way `MONITOR_GLASS_REL` was — project the four corners of the
phone's `screen` mesh top face, read the angle off the long edge:

| constant | was | derived |
|---|---|---|
| `PHONE_GLASS_ANGLE_DEG` | 31.0 | **6.49** |
| `PHONE_GLASS_SIZE_REL` | 0.72 × 0.34 | **0.8871 × 0.7398** |
| `PHONE_GLASS_CENTER_REL` | 0.50, 0.50 | **0.5336, 0.4300** |

The angle is the real defect: the watercolour phone stood at a steep tilt, this
one lies nearly flat on the desk, so the 31° badge sat visibly skewed across the
screen and off both edges. Overlaying both quads on the render makes it obvious —
the derived quad traces the black screen, the old one cuts diagonally across it.

The size follows from the same cause: `0.34` height was measured against an
upright phone, while this one lies flat and its screen fills most of the visible
silhouette. Corrected, the glass is **72 × 46 px at 1080p — 2.68× the area**,
which comfortably carries the 8 px dot plus a short uppercased first name.
No mesh rescale, no dropped feature, no capped tag.

Residual: a very long mentor first name would still clip, since
`clip_contents = true` truncates rather than shrinking (correct per D4.3). At
72 px that is roughly 7–8 uppercase characters after the dot, so "FRANK" and
ordinary first names fit. Worth a look if a mentor is ever given a long name.

### `lamp_glow` — same class of bug, same fix
> ⚠ **SUPERSEDED (2026-08-18): the `lamp_glow` halo was REMOVED entirely** — it
> was drawn over the black lamp body and made it read half-transparent. The
> derivation below is kept for the *rule* it teaches (port the rule, not the
> number), not because the constant still exists. See "Part C addendum 3".

Also a watercolour-era value carried over by proportion rather than derived, and
also wrong for the same underlying reason: **the watercolour lamp had its bulb
mid-body, this one has it at the top.** Preserving the old lamp→glow ratio put
the halo 82 px right and 156 px below the actual bulb, and stretched it into a
246 × 441 vertical ellipse.

Recovering the original rule rather than the original number: the watercolour
glow was 614 × 613 source px — *square*, i.e. a circular radial gradient — at
1.23× the lamp's width. Applying that rule to the measured bulb projection
(centre `316.7, 1395.8`) gives a 246 × 246 px halo centred on the bulb:

```
lamp_glow := Rect2(0.0505, 0.5893, 0.0641, 0.1139)     # was 0.0719, 0.6164, 0.0641, 0.2043
```

**The lesson worth keeping**: when migrating a layout constant, port the *rule*
that produced it, not the ratio it happened to have. Three constants
(`lamp_glow`, `PHONE_GLASS_*`, `papers_zone`) were wrong in exactly this way, and
each was invisible in the numbers until it was drawn on the render or a smoke
gate caught it.

## The rig

`tools/oda_render_rig/` (`layers.html`, `desk-builders.js`, `serve.py`, `run.sh`,
its own `README.md`, and a `.gdignore` so Godot skips the directory). It runs the
design scene's **own code** so fidelity is by construction; the only deltas are
`alpha: true`, OrbitControls dropped, and the measurement/solve/export additions.
The design scene itself is read-only and was not modified.

**Driving it:** `run.sh "auto=1&solve=1"` launches a dedicated **foreground**
Chrome window on its own profile. This is not incidental — driven through a
background tab, Chrome froze the page and `toBlob()` callbacks and
`fetch().then()` never fired (confirmed with an 8×8 canvas, which also never
fired). Synchronous code still evaluated, which makes the freeze easy to misread
as a slow encode. A foreground window also keeps the real GPU, so output matches
the approved look rather than a software rasteriser.

---

## Part C — Sealed art round (2026-08-17)

The director sealed final day/night renders. The scene had moved on from the one
Part B rendered against, so this round is a re-port plus a re-derivation, not a
re-render of the same thing.

### What the sealed scene changed

| element | Part B rig | sealed source |
|---|---|---|
| corkboard | `(0.42, 1.28, -0.955)` | `(0.62, 1.44, -0.955)` |
| phone | `(0.88, T, -0.18)` yaw `-0.35` | `(0.38, T, -0.05)` yaw `-0.28` |
| lamp head | static pitch `-0.5` | aimed at `poolTarget (-0.45, T, -0.45)`, natural pose |
| shadow map | `PCFSoftShadowMap` | `PCFShadowMap` (harder) |
| sun shadow | 2048, bias -0.0004 | 4096, bias -0.0002, `normalBias 0.02` |
| night rig | cool: hemi `0x39435c` + `0x7d8fb8` moon + monitor glow + keyboard wash | **warm: hemi `0x8a7154` + one shadow-casting tungsten ceiling `PointLight(0xffd2a0, 5, 9, 1.6)` + `mouthGlow`** |
| `lampSpot` | `0xffc678, 14, 3.2, 0.72` | `0xffb866, 9, **1.2**, 0.45` aimed at `poolTarget` |
| monitor screen at night | emissive `0x8fb2cf @ 0.65` | **`0x000000 @ 0` — dark glass in both modes** |

### Two source corrections (director-authorized)

Both were escalated with numbers before any render, because both changed the
*contract*, not the look.

**Corkboard to `(0.4155, 1.2855)`, i.e. left 20.4 cm + down 15.4 cm.** The sealed
position projected `board_inner` to `y = -17` — off the top of the frame — and
`board_inner` hosts all four `BOARD_REL` cards. The director's first instinct was a
vertical drop of 10-15 cm; measurement showed the drop fixes the clipping (15.4 cm
lands `y` exactly on contract) but **cannot** close the horizontal, which stays at
+219.7 px for any drop, because the sealed scene also moved the board +20 cm right.
Only the two-axis move restores the contract at an unchanged camera.

**Phone yaw to -2 deg, a 14 deg reduction.** The sealed yaw (-16.04 deg) projected the
screen quad as a parallelogram sheared **29.2 deg**, and `PHONE_GLASS_*` models a
*rotated rectangle* — so the notification badge no longer sat on the glass. Shear falls
monotonically toward -2 deg, where it is **0.17 deg**. Glass area is nearly flat across
the whole range (1.23-1.27x the shipped value), so rectangularity was essentially free.
The authorized window had been 5-10 deg, which only reaches 9.6-20.3 deg of shear.

### The solver had to be pinned

Re-running `solve=1` walked the camera to `pos (-0.05, 1.637, 1.729) · pitch -9.05 deg`
and left `board_inner` 214 px right of contract — the round-1 failure again. Cause:
the sealed scene moved the phone half a metre, so `RECTS.phone` had become an
unreachable target and the solver traded away the heaviest host chasing it.
`RIG_WEIGHT.phone` is now zeroed and the camera is pinned to Part B's answer.
**Rule for next time:** a prop position target is only valid while the prop has not
moved in the source. Hosts are the contract; props get their `RECTS` rewritten.

### Re-derived constants

| constant | Part B | sealed round |
|---|---|---|
| `REGIONS.lamp` | `(219, 1308, 200, 494)` | `(181, 1308, 238, 494)` — head aim widened the silhouette LEFT; right edge stayed at 419, so the `PAPER_SLOTS` strip is untouched |
| `REGIONS.phone` | `(2721, 1865, 124, 95)` | `(1976, 1935, 126, 106)` |
| `board_outer` / `board_inner` | `0.3413,0.0420,...` / `0.3563,0.0697,...` | `0.3400,0.0392,...` / `0.3550,0.0669,...` (-5/-6 px) |
| `lamp_glow` | `(0.0505, 0.5893, 0.0641, 0.1139)` 246 sq | `(0.0354, 0.5864, 0.0763, 0.1356)` 293 sq, centre = new bulb projection `(282.3, 1413.1)` |
| `PHONE_GLASS_ANGLE_DEG` | 6.49 | **0.63** |
| `PHONE_GLASS_CENTER_REL` | `(0.5336, 0.4300)` | `(0.5039, 0.4307)` |
| `PHONE_GLASS_SIZE_REL` | `(0.8871, 0.7398)` | `(0.8997, 0.8234)` |
| `MONITOR_GLASS_REL` | `(0.02268, 0.01381, 0.95539, 0.61759)` | **identical to 5 decimals** — monitor and camera both unmoved, which independently proves the derivation reproduces |
| `monitor`/`keyboard`/`mug` REGIONS | — | **byte-identical** — the pinned camera, confirmed |

`board_inner` took the *measured* value rather than the contract value it misses by
5-6 px: the rule is measure-from-the-render, and 6 px sits well inside `BOARD_REL`'s
4% inset (53 px), so no card moves.

### monitor_night retired, and the test that decides it

Measured night/day channel ratio over the shared opaque mask (dark screen excluded,
it carries no tint): monitor chassis **`(0.906, 0.783, 0.621)`**, all below 1, so one
`modulate` reproduces the sealed night rig exactly. The night monitor is therefore the
day layer under `ObjectLayer` modulate, and `monitor_night_3840x2160.png` is deleted.
The lamp measures **`(1.716, 1.370, 0.889)`** — above 1 on two channels because the
bulb lights itself, and a multiply cannot brighten — so the lamp keeps its own layer.
That ratio test is the rule for any future night variant.

`UiTokens.ODA_NIGHT_TINT` was **inverted**: `(0.72, 0.78, 0.92)` is a COOL multiply
(B > G > R) tuned for the retired moonlight rig, against art that is now warm
tungsten. Replaced with the measured `(0.906, 0.783, 0.621)`. Verified in-game: the
night mug samples `(139.3, 107.0, 67.9)` against day's `(153.8, 136.7, 109.4)` —
exactly day x the token, so the whole chain is confirmed. Evening and dawn were
re-checked and **kept**: evening is already a partial step toward the new warm night
(`lerp(WHITE, night, 0.35) = (0.967, 0.924, 0.867)` vs the held `(1.0, 0.93, 0.84)`),
and dawn staying cool is now a *stronger* beat than before, because it is the room's
only cool state now that night has gone warm.

### Hover rim retuned for hard edges

`rim_px` 10.0 to **3.0**. The maths explains why the same uniform behaved differently:
outside the silhouette `tex.a = 0`, so `rim = na`, the max neighbour alpha. Watercolour
edges were soft, so `na` ramped and 10 texels read as a glow. Render edges are hard, so
`na` is 1 for every pixel within `rim_px` — the same uniform now stamps a flat 10-texel
slab (about 4.8 screen px of 55% orange at the shell viewport). 3 texels is about 1.4
screen px at 1080p: edge emphasis, not fill. Filling stays impossible by construction —
`rim` is only added where `tex.a = 0`.

### Two traps, both worth the next person's time

**Godot serves the cached .ctex.** New PNGs installed over old ones are ignored until
`godot --headless --path . --import`. Without it you shoot the OLD art with the NEW
constants, which reads as a layout bug: the phone vanished entirely because its atlas
region had moved to x 1976 while the cached texture still had the phone at x 2721. Nine
shots were taken and thrown away before this was caught by comparing source and `.ctex`
mtimes.

**--import then breaks the next run.** It writes an incomplete
`global_script_class_cache.cfg` (76 entries, missing the alphabetically-first
`AngelRoundSystem`), so the first run afterwards dies with
`Parse Error: Identifier "AngelRoundSystem" not declared` cascading into
`Failed to instantiate an autoload` for `event_manager` and `time_manager`, then Nil
access errors — 34 errors in one run, none of them real. That run repairs the cache on
its way out; runs 2+ are clean, confirmed three consecutive times. So the order is
**--import, then one throwaway warm-up run, and only then a gated battery.** A battery
run inside that window produces frames rendered with dead autoloads: seven of them had
to be re-shot here.

### size_limit truncation removed

`lamp`, `mug` and `phone` still carried watercolour-era sidecars with
`process/size_limit=2048`, so files named `*_3840x2160.png` imported at half
resolution while their night sibling imported at 3840 — making the lamp crossfade a
resolution change. All eight are now `size_limit=0`, `compress/mode=0`. The
`mipmaps/generate` split (true on those three, false on the other five, while
`oda_view.gd` asks for `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` on all of them) is a real
defect but belongs to the resolution pass, which re-takes every baseline anyway.

### Verification

| gate | result |
|---|---|
| `--theme-audit=oda` | **121 AUDIT lines, byte-identical** before/after, so the frozen theme is untouched and **no unfreeze was needed** |
| light states | day/evening/night/dawn distinct on BOTH layers, measured per channel |
| hover | crisp edge-only rim on all objects; no fill, no bloom |
| tour | spotlight on **raw** rects; scrim edge-to-edge over TopBar and left rail |
| aspect battery | 1280x720 / 3440x1440 / 5120x1440 / 3840x2160 — `MAX_CROP` band holds, every anchor inside `[0.020, 0.980]`, ultrawide gutters filled by `Surround` |
| plate cleanliness | night wall behind monitor 84.46/8.16 vs 84.63/7.98 reference; alpha 255 everywhere (no voids) |
| contact-shadow alphas | 44.2-63.1 mean, inside the 40-70 band |
| shot battery log | 0 parse/compile/autoload errors |

### Part C addendum — F5 fix round (2026-08-17, same day)

The contact sheet came back with two defects. Both were diagnosed from pixels and
code before anything was changed.

**The lamp head read as a hooded eye.**
> ⚠ **THE LAMP PART OF THIS SECTION IS SUPERSEDED — see "Part C addendum 2" below.**
> The diagnosis under this heading found three *symptoms* and missed the *cause*.
> The liner and the spline described here were reverted the same day. Kept in the
> ledger because the mistake is the lesson.

Three independent causes, not one:

| cause | evidence | fix |
|---|---|---|
| creased silhouette | the shade is a `LatheGeometry` over a **10-point polyline**; straight segments between sharp turns render as folds | keep the sealed 10 points as **spline control points**, resample 24 per wall (`THREE.SplineCurve`) |
| dead interior | inner wall painted `M.black` (the chassis colour) and lit by almost nothing → a flat grey-brown wedge the eye reads as the object's body | split the shade into **two lathes** (outer = CP[0..5] *including* the rim turn so both share the `(0.058,0.002)` ring and leave no gap; liner = CP[5..9]) and give the liner a warm reflector material, `DoubleSide` so winding cannot cull it |
| blown bulb crescent | sphere `r=0.02` at `y=0.028` sits ~5 mm **above** the mouth plane (`y≈0.003`) so the near rim clips it; night `emissiveIntensity 1.2` on `0xff9d4a` then clips to near-white under ACES | bulb `y` → 0.022; night emissive → 0.6 |

Ruled out by measurement rather than assumed **at the time** (the halo was later
removed outright — see "Part C addendum 3"): the additive `lamp_glow` halo is a
**smooth** gradient. Radial luma along a ray over bare wall falls monotonically
−1.3 → −5.0 per 3 px from r=0 to r=33; the spikes at r=36–51 are the lamp **arm**
crossing the ray, not banding. No change made.

One wrong turn worth recording. The first attempt used a bright liner
(`0xf4e3c4`) with `mouthGlow` raised 0.45 → 0.8, and it overshot badly: 1791 px
clipped ≥248 and the head read as a *white* lamp. The instinct was "the outer
shell is being culled and we're seeing the liner through it" — **wrong, and
sampling settled it**: the shade dome measured RGB(104.2, 67.2, 30.4) against the
lamp arm's RGB(108.5, 70.4, 33.8), a known `M.black` surface. The exterior was
correct all along and simply warm-lit; the liner was just too bright. Final:
liner `0xd9c096` roughness 0.55, `mouthGlow` back to 0.30 → night head max luma
245.3 with **2** px >245.

**A fidelity deviation surfaced while reading the diff.** The rig had
`buildMonitor`'s `screen` at z `0.0148`; the sealed source says `0.017` — the rig
was copied from an older revision. 2.2 mm of depth, which moves the glass ~1 px,
so `MONITOR_GLASS_REL` is now `(0.02144, 0.01339, 0.95672, 0.61844)`. Worth noting
that the earlier "identical to 5 decimals" reproducibility check was therefore
comparing the rig against *itself*, which is still a valid reproducibility proof
but not a fidelity one. Fidelity has to be checked line-by-line against the
source, not inferred from a stable derivation.

`REGIONS.lamp` came back **unchanged** at `(181, 1308, 238, 494)` — the spline
smoothing does not move the alpha bbox — so `RECTS.lamp` and the `PAPER_SLOTS`
strip (lamp right edge 419) needed no re-derivation. `lamp_glow` did move, because
the bulb did: projected centre `(282.3, 1413.1)` → `(289.7, 1417.5)`, so
`Rect2(0.0373, 0.5884, 0.0763, 0.1356)`, still exactly 293 × 293 source px.

**Day mode changed too, deliberately.** The liner is a material, not a night
state, so the daylight lamp went from a formless black blob to a black shade with
a visible cream interior. That is a legibility gain and a departure from the
sealed dark interior in both modes — flagged to the director rather than assumed.

**The board goal card was out of register**, and the root error was structural
rather than cosmetic: the goal *sentence* was sitting in `MetricValueInk`, the
18 px big-figure slot. That slot is for numbers — in the phase-3-closed branch the
same `_goal_value` correctly holds `format_money(...)`. So the card shouted because
a sentence had been put where a figure belongs.

Restyled onto the market/dates pattern exactly: header `HBoxContainer` with
`NewsMeta` label + expand-fill spacer + the counter **right-aligned** on that line
(the `MARKET SHARE … %0,3` grammar), the sentence demoted to `RowMeta` with
`clip_text` + expand-fill, and the progress bar from a 6 px solid amber slab to a
3 px rule. Every variation used already exists in the frozen theme, so **no
unfreeze**; `BuildProgress`'s styleboxes are untouched and height was the only
free variable. Two side benefits: the trailing colon in
`ODA_BOARD_GOAL_P*_LABEL` ("To Traction:") is stripped at the **call site** via a
`_goal_head()` helper — presentation, not content, so `strings.csv` stays with
Localization Phase 2 — and `clip_text` closes a real latent bug, since the goal
card previously had **neither `clip_text` nor autowrap on any label**, so a long
phase-2/3 value was silently cut by the wrapper instead of truncating.

The header mapping holds across all phases: P1 → `TO TRACTİON` + `3/3`; P2 →
`TO SERIES A` + the brand line; P3 → right slot empty.

### Verification (F5 round)

| gate | result |
|---|---|
| `--theme-audit=oda` | 121 → **123** lines. After normalising Godot's auto `@Class@NN` counters, **0** lines outside `/GoalWrap/` changed — the two outlier variations (`NewsDeckSerif|15|serif_it`, `MetricValueInk|18|sans_sb`) left and the mono register arrived. Frozen theme still untouched. |
| `oda_anchors_stay_in_band` | PASS with the new `lamp_glow`; still square in source px |
| night head blowout | max luma 245.3, 2 px >245 (was max 248 with 1791 px ≥248 on the first attempt) |
| contact-shadow alphas | 44.3–63.1 mean, inside the 40–70 band; plates alpha 255 (no voids) |
| shot battery | day/evening/night/dawn/hover/tour/market1/market2/event + 5120×1440 + 1280×720, **0** parse/compile/autoload errors |

`CLAUDE.md`'s documented count is updated to 123, with the rule stated explicitly:
a changing line count is not itself a violation — the proof is that after
normalising the auto counters, the diff stays inside the subtree you meant to
touch.

### Part C addendum 2 — the lamp revert, and why the lamp changed three times

The director stopped this one with the right question: *why does the lamp keep
changing, and why can't it just be flat black like the first asset, with only the
lighting changing and the bulb coming on at night?*

Answer: the churn was self-inflicted, and the addendum above fixed the wrong end
of it. Three generations in one session:

| generation | head pose | shade | day read | night read |
|---|---|---|---|---|
| 2026-08-10 (first asset) | fixed pitch, mouth points down-away | one black lathe | **flat black lamp** | flat black + glowing bulb + desk pool |
| sealed-source port | **aimed at `poolTarget`** → mouth toward camera | one black lathe | unlit interior dominates → "hooded eye" | + a rim-clipped white crescent |
| the F5 "fix" | still aimed at camera | black outer + **cream liner** | pale dome — no longer a black lamp | warm glowing interior |

**Root cause: the head-aim block, ported in generation 2.** The sealed
`office-room.html` contains `lampHead.quaternion.setFromUnitVectors(...)` toward
`poolTarget`, commented *"what it looks at IS where the light lands, no twist."*
Porting it rotated the mouth toward the camera, which made the **unlit interior the
object's largest visible surface**. Generation 3 then brightened that interior —
treating the symptom — which is exactly why the lamp stopped being black.

Diagnosis was settled by evidence, not argument: compositing the 2026-08-10 lamp
layer over the 2026-08-10 plate and lining all three generations up beside the
director's screenshots showed the screenshots *were* generation 3, and that
generation 1 already had the flat-black read being asked for.

**The revert.** Both of the F5 lamp changes were my inventions — the sealed source
never had a liner or a spline — so undoing them returns `buildLamp()` to the sealed
source **exactly**: the 10-point polyline, one `LatheGeometry` with `M.black`, bulb
`r 0.02` at `y 0.028`, `headG.rotation.set(-0.6, 0, 0)`. `M.shadeLiner` deleted.
Night bulb emissive back to the sealed `1.2` and `mouthGlow` to the sealed `0.45`
— both had only been lowered to stop the liner blowing out, and at `1.2` the bulb
is what reads as *on*.

The single remaining deviation is one **documented override**: the head-aim block
is deliberately not ported. `lampHead` and `poolTarget` stay declared because
`lampSpot.target` and `mouthGlow`'s position both use them; only the quaternion
assignment goes. To mirror: delete that block from `office-room.html`.

**Contract, stated so it stops drifting:** the lamp body is flat black in *both*
modes. The only thing that changes between day and night is the lighting — at night
the bulb glows (emissive), the desk carries the baked pool, and the game adds the
additive `lamp_glow` halo.

**Measured result.** `REGIONS.lamp` came back **byte-identical to the first
asset** at `(219, 1308, 200, 494)`, so `RECTS.lamp` returned to
`Rect2(0.05703, 0.60556, 0.05208, 0.22870)` and the lamp's right edge to 419 px —
the `PAPER_SLOTS` strip between lamp and keyboard is untouched. `lamp_glow`
returned to 246 × 246 px at `Rect2(0.0505, 0.5912, 0.0641, 0.1139)`; its centre
sits 4 px below the first asset's because the sealed bulb is `r 0.02 @ y 0.028`
where the original rig had `r 0.022 @ y 0.03`, and the sealed value was kept.
Shade body in daylight measures RGB(58.6, 50.2, 36.2) against the F5 version's
RGB(193.9, 162.4, 110.8) — 3.3× darker, i.e. black again.

### The lesson, which is worth more than the constants

1. **A sealed-source delta that changes an object's pose, orientation or material
   changes how the object *reads*.** That is a design change. It must be flagged
   when ported, not applied silently alongside the geometry. "Integrate the sealed
   art" is not a licence to import a re-pose without saying so.
2. **When a defect appears immediately after a port, suspect the port first.** The
   hooded-eye look arrived in the same change that re-aimed the head; that
   coincidence was the clue and it was missed. Reaching for a material fix before
   checking the transform cost two extra rounds.
3. **Anchor "before" to an artifact, not to memory.** The rollback snapshot of the
   2026-08-10 art is what made the diagnosis provable in minutes. Keep taking it.

### Verification (revert round)

| gate | result |
|---|---|
| `--theme-audit=oda` | **123 lines, byte-identical** to the F5 baseline after normalising auto `@Class@NN` counters — 0 diff, correct because this round touched no `Control` |
| `oda_anchors_stay_in_band` | PASS; `lamp_glow` square in source px (246 × 246) |
| `REGIONS.lamp` | byte-identical to the 2026-08-10 first asset |
| lamp right edge | 419 px → `PAPER_SLOTS` strip unaffected |
| contact-shadow alphas | 43.2–63.1 mean, inside the 40–70 band; plates alpha 255 (no voids) |
| shot battery | day/evening/night/dawn/hover/tour + 5120×1440, **0** parse/compile/autoload errors |
| goal card, night rig, tints, hover rim | untouched — this round was the lamp only |

### Part C addendum 3 — halo removed, lamp aimed at its own light (2026-08-18)

Two defects from the director's review of the reverted lamp, both fixed here.

**1. The additive halo made the black lamp look transparent.** `LampGlow` — a
runtime 246 × 246 radial `GradientTexture2D` in `FXLayer` with
`BLEND_MODE_ADD`, tweened to `LAMP_GLOW_NIGHT_A = 0.55` at night — was drawn *on
top of* the lamp sprite, so the flat black shade rendered milky and half
transparent, as if the lamp body itself were emitting.

Proven game-side before touching anything: both lamp PNGs have **zero**
faint-alpha pixels (`alpha 1..39` count = 0) with the alpha bbox tight to the
silhouette. A baked bloom would leave a wide low-alpha skirt, so nothing in the
art glowed — the halo was entirely that node.

Removed in full: the node and its builder block, `LAMP_GLOW_NIGHT_A`, the
`_relayout` placement, the three `_eval_light` sites, the `RECTS["lamp_glow"]`
entry, and the now-orphaned `UiTokens.ODA_LAMP_GLOW`. `_place()` went with it —
the lamp glow was its **only** caller (everything else in `_relayout` calls
`OdaLayoutRef.place(...)` directly or `_place_clamped`), so it would have been
left as dead code. `FXLayer` stays because `PhoneDot` lives there; deleting the
layer would have changed PhoneDot's audit path and cost two lines instead of one.

Measured effect: wall luma immediately beside the lamp head at night drops from
RGB(127.7, 85.2, 41.6) to RGB(118.3, 77.9, 38.3) — the additive lift is gone.
The bulb still reads as lit; that job belongs to the night layer's emissive bulb
and the pool baked into the night plate, neither of which paints the body.

**2. The lamp pointed 66° away from its own light.** Measured: mouth azimuth
28.6°, light-pool azimuth 95°. `yaw 85.156°` aims the mouth exactly at the pool
centre (residual error 0.000°).

Rotating alone was not enough, and the second-order effect is the part worth
recording. Turning the lamp to face its light puts it **side-on**, so the arm's
depth becomes screen width and the silhouette grows 200 → 338 px. The right edge
would have moved 0.1092 → 0.1402 while `PAPER_SLOTS` start at 0.120 — the lamp
would have sat on the desk papers. Rather than narrow the `# WORKING`-sealed
paper placement by 4%, the director chose to move the lamp **12 cm left**
(`x −0.92 → −1.04`), which puts the right edge at 0.1005 and the gap to the
papers at **0.0195 — wider than the 0.0108 it had before.** The strip improved.

Predicted from a projection model and then confirmed by the render's own alpha
bounds, exactly: left 48 px / right 386 px both times. The model had been
validated first by reproducing the then-current `REGIONS.lamp` `(219, 1308, 200,
494)` byte-for-byte.

`REGIONS.lamp` is now `(48, 1297, 338, 506)`. **Left edge 48 px is the tight
gate**: `padded_region` grows by `REGION_PAD = 24`, so the atlas origin lands at
exactly 24 — valid, but moving the lamp any further left breaks it. Noted in
`oda_layout.gd` for whoever touches this next.

Three deliberate overrides of the sealed scene now live on this lamp, all to be
mirrored into `office-room.html`: the dropped head-aim block, `position
(-1.04, T, -0.5)`, and `rotation.y = 1.48625`.

### Verification (halo + aim round)

| gate | result |
|---|---|
| `--theme-audit=oda` | 123 → **122**. Normalised diff is **−1 / +0**: the single `/FXLayer/LampGlow` line. `/FXLayer` and `/FXLayer/PhoneDot` both survive. |
| `oda_anchors_stay_in_band` | PASS. The case does `for id in OdaLayout.RECTS`, so dropping the key just removes an iteration — no edit needed. |
| lamp left edge | 48 px ≥ `REGION_PAD` 24 — OK, at the limit |
| lamp right edge | 0.1005 < 0.120 — gap 0.0195, wider than before |
| night pool vs papers | centroid x 0.176, papers span 0.120..0.290 — still lit |
| contact-shadow alphas | 43.7–63.1 mean, inside the 40–70 band; plates alpha 255 |
| shot battery | day/evening/night/dawn/hover/tour + 5120×1440, **0** parse/compile/autoload errors |
| other REGIONS | monitor / keyboard / mug / phone byte-identical — camera still pinned |

One documentation habit changed as a result: `ui_tokens.gd` used to assert the
audit's line **count** as its freeze proof, and that number went stale twice. The
count now lives in exactly one place (CLAUDE.md's UI/STYLE LAW), and the proof is
stated as what it actually is — the dump being byte-identical after normalising
Godot's auto `@Class@NN` counters, not any particular integer.

---

## Part C — 3D bake migration (2026-08-20)

The eight sealed layers were **re-rendered from the Godot 3D scene** (`scenes/oda3d/`) and
overwritten in place, so `oda_view.gd` and the eight `.import` sidecars were not touched at all.
Erdem approved the 3D plates on sight; this round is how they became the game's art without
losing what the layered architecture buys.

**Why layers and not the plate.** The approved plates are single opaque images. ODA's hover glow
is `oda_rim_glow.gdshader`, which computes `rim = clamp(na - tex.a, 0, 1)` from the sprite's own
alpha. On an opaque plate `tex.a == 1` everywhere, so the rim is **zero at every pixel** — hover
would have died silently, with no error, on monitor and phone. The phone's event buzz translates
`_sprites["phone"]` and dies with it too. Godot can render a transparent-background pass, which is
exactly what the Three.js rig could not do (Part A: `WebGLRenderer` built without `alpha: true`)
— so the move to 3D is what made the layer export possible in the first place.

**Two findings worth keeping.**

1. **TAA destroys the alpha channel on a transparent background.** With `use_taa = true` the
   960×540 phone pass came back fully opaque — 518,400 / 518,400 px at alpha 255. With TAA off,
   alpha bbox `(494,484)-(526,511)`, i.e. `REGIONS.phone` once scaled. TAA resolves into an opaque
   history buffer. `oda3d_capture.gd` now forces `use_taa = false` for prop passes rather than
   trusting the caller; spatial AA is covered by MSAA 4× plus `--oda3d-scale=1.5` supersampling.

2. **Hiding a prop also removes its cast shadow — use `SHADOWS_ONLY`, not `visible = false`.**
   The first room pass hid the five props and the mug's and phone's shadows vanished from the desk:
   the sun is a real-time `DirectionalLight3D` and the lightmap bakes only *indirect*. Setting
   `cast_shadow = SHADOW_CASTING_SETTING_SHADOWS_ONLY` keeps each prop in the shadow map while
   removing it from the colour pass, so the background carries the shadows and the sprite going
   back on top does not double-draw them.

**Gate 0 — the decomposition reassembles.** `room + lamp + monitor + keyboard + mug + phone`
composited in OdaView's order, against a same-settings single-pass reference: mean abs error
**1.61 / 255** (day) and **2.11 / 255** (night). The residual is screen-space AO/IL around the
props, which is view-dependent and cannot survive decomposition — the same trade the sealed art
already made, and the baked contact shadows are present.

**The contract did not move.** Alpha bounds measured from the new sprites against `REGIONS`:
lamp, monitor and phone **byte-identical**; keyboard `-1` x / `+1` w; mug `+1` w. Both are 1 px,
well inside `REGION_PAD = 24`, and neither object is clickable. `REGIONS` and `RECTS` were left
untouched, so `RECTS[id] == REGIONS[id] / ART` still holds by construction.

**Night stays a two-layer problem.** Measured night/day channel ratios on the new art: monitor
`(0.943, 0.842, 0.686)`, keyboard `(0.730, 0.616, 0.481)`, mug `(0.708, 0.575, 0.419)`, phone
`(0.688, 0.564, 0.447)` — all below 1, so `ObjectLayer.modulate` reproduces them. The lamp is
`(1.307, 1.079, 0.732)`: two channels **above 1**, which a multiply cannot reach. `lamp_night`
therefore stays a separate layer for exactly the reason `oda_view.gd:889-897` records, and
`monitor_night` stays retired. `ODA_NIGHT_TINT` was left at its sealed-art value.

**Gates.** `--theme-audit=oda` **121 lines, byte-identical** after `@Class@NN` normalization —
textures and coordinates are not theme items, so the freeze held and `THEME_STAMP` stayed at 6
(the 2026-08-17 precedent, CLAUDE.md:152-162). Smoke **212/212** from source. Twelve
`--oda-shot` kinds read by eye, 0 script errors; the `hover` frame diffed against `day` shows the
rim tracing the monitor's real silhouette (bezel + neck + trapezoidal foot), which is the direct
proof the new alpha is load-bearing.

**Cost.** `assets/art/center_view/` 2.28 MiB → 12.7 MiB on disk: a baked GI render carries
per-pixel detail that flat painted regions did not. VRAM is unchanged — same dimensions, same
`compress/mode=0`, same RGB8/RGBA8.

**Reproduce:** `--oda3d-layer=room|monitor|keyboard|lamp|mug|phone` (plus `full` for the Gate 0
reference) on `oda3d_capture.tscn`, at `--oda3d-size=3840x2160 --oda3d-scale=1.5 --oda3d-msaa=4
--oda3d-warmup=60`; `lamp_night` is the `lamp` layer in `--oda3d-mode=night`.
