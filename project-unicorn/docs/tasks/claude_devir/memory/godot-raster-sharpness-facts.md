---
name: godot-raster-sharpness-facts
description: "Godot 4.6 raster facts measured 2026-08-18: canvas_items already oversamples text, default canvas filter is LINEAR so mip chains go unsampled, mipmaps OVER-BLUR at 0.3-0.5 draw scale, SVG rasterizes at import"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f87e8c11-2506-40aa-9d41-168711292327
  modified: 2026-08-18T19:13:09.816Z
---

2026-08-18 render-sharpness pass measured five things that are counter-intuitive enough that the next session will otherwise re-guess them. All numbers from Godot **4.6.2** with `window/stretch/mode="canvas_items"`, base 1920×1080.

**1. `canvas_items` ALREADY rasterizes at physical resolution — text included.** The "renders to a 1080p canvas and blits it up" story describes `viewport` stretch mode, NOT `canvas_items`. Fonts imported with `oversampling=0.0` inherit the viewport and are genuinely oversampled; no font import param needed touching. So "4K looks no sharper" is usually NOT a renderer bug.

**2. The falsification test (reusable instrument).** Shoot the same screen at 1920×1080 and 3840×2160, synthesize a **bilinear 2× upscale of the 1080p shot**, take MAE against the real 4K shot. MAE ≈ 0 ⇒ the 4K frame is merely an upscale. Measured: text 3.8/5.5/17.7 (native), SVG icons **0.06–0.14** (upscaled — caught the real defect). Second independent reading: fraction of pixels in an anti-aliased edge transition — native holds flat with resolution, an upscaled bitmap's grows. Do NOT use raw 2×2-block uniformity: flat background dominates it (98% globally) and bilinear upscales are non-uniform anyway, so it answers nothing.

**3. Default canvas texture filter is `LINEAR`, so mip chains are NEVER SAMPLED** unless a node explicitly sets `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`. Proof: icons at `svg/scale=2.0` measured **identical to 4 decimals** with mipmaps on vs off. Enabling `mipmaps/generate` at import is a no-op for ordinary Controls — it only costs memory and import time.

**4. Mipmaps OVER-BLUR at 0.3–0.5 draw scale.** ODA's 3840-wide plates draw at ~0.48 (1080p) / ~0.32 (720p). Measured against ground truth (the 4K render box-filtered down): mip OFF sits within ±0.4% of correct high-frequency energy at 1080p; mip ON is **below** reference in all 8 measurements (−0.6% to −9.8%) = softer. At ~0.5 scale bilinear on the full-size texture already approximates the ideal box filter, while trilinear pulls in an already-halved level. Mipmaps help *below* ~0.25 and against *motion* shimmer — static plates that only cross-fade have no shimmer to fix.

**5. SVG is rasterized to a bitmap AT IMPORT TIME** at `svg/scale`, so a 24×24 source is a 24×24 texture forever and any content scale >1 upscales it. Derive the factor, don't guess: max physical size = logical px × max stretch (24 × 3840/1920 = 48), so `svg/scale=2.0` is exactly sufficient. **Safe only where the consumer ignores natural size** (`expand_mode = EXPAND_IGNORE_SIZE` + `custom_minimum_size`). `HSlider` grabbers and `CheckButton` check icons are theme icons drawn at NATURAL size with no scale item — raising their scale enlarges the control, so they need `build_theme.gd` size pinning (⇒ `THEME_STAMP` bump + regen).

**How to apply:**
- Frame cost / VRAM harness now exists: `--render-probe[=<tab id>]` (+ `--shot-size`) in `main.gd`, registered in `DisplaySettings._is_harness_arg` so it is inert and owns the window; forces vsync off (otherwise every frame measures the 60Hz refresh). Prints FRAME_MS / MEM / DRAW. **Take 3 runs** — single samples were too noisy (medians bounced 0.44–0.58 ms) to support any claim.
- **A re-render rewrites `.import` sidecars at importer DEFAULTS and silently drops previously-set params.** Four ODA plates lost `mipmaps/generate=true` that way between rounds. Check sidecars after every art pass ([[godot-import-cache-gotchas]]).
- An asymmetric `mipmaps`/`svg/scale` state across a sibling asset set is almost always this accident, not a decision — but confirm with the owner before flipping it back.
- **NEVER assume a shot's output filename — read it off the `saved <path>` line.** Localization Faz 2 Step 1a suffixed every shot with the locale (`tab_shot_hr.png` → `tab_shot_hr_en.png`). Copying the old path yields a STALE file instead of an error, and two shots at different settings then hash IDENTICAL — which reads exactly like "the flag does nothing". Cost me a wrong conclusion about `--shot-scale` on 2026-08-18. Hash the outputs AND confirm the saved path before comparing anything.
- **`content_scale_factor` SHRINKS the logical viewport** (1920×1080 @125% → 1536×864, measured via `--render-probe`), and `1080/step` is the logical height on ANY 16:9 window because the stretch is `win.y/1080` — the resolution cancels. That makes the primary resolution the analytic floor for "does a fixed-size modal still fit", not merely an example.
- **`MIN_CHROME_VIEWPORT` is a CHROME gate and is blind to modal content.** It passed at %150 while `SettingsModal`'s fixed 860px panel had its close button off-screen. A ladder/step gate proves nothing about modals — assert those separately (`ui_scale_ladder_fits_settings`).
- `--theme-audit=oda` is BLIND to texture-dimension changes (it resolves theme values and paths, not sizes). It also resolves zero `svg` references, so ODA's frozen theme cannot be affected by an icon import change at all.

İlgili: [[godot-import-cache-gotchas]], [[concurrent-session-hazard]], [[ui-design-system]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Godot raster/sharpness facts](godot-raster-sharpness-facts.md) — canvas_items ZATEN native raster (text oversampled); default filter LINEAR → mipmap hiç örneklenmiyor; mipmap 0.3-0.5 ölçekte AŞIRI BULANIKLAŞTIRIYOR; SVG import'ta raster'lanır; --render-probe harness'ı
