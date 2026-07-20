# Ending engravings ("Ekonomi Postası")

One newspaper-style illustration per ending, dropped in here as:

- `series_a_close.png` — signing / handshake (shared by both Series A variants)
- `acquisition.png`
- `bankruptcy.png` — used by faz-2 and faz-3 bankruptcy (faz-1 quiet closure has NO art)
- `brand_collapse.png`
- `vc_rejection_cascade.png`
- `profitable_bootstrap.png`
- `running_on_fumes.png`

The path convention is `res://assets/endings/<ending_id>.png`, emitted by
`EndingsCopy._engraving_path()`. Until a file exists, `scripts/modals/ending_scene.gd`
renders a neutral empty frame + the `GÖRSEL YAKINDA` telegraph (via `ResourceLoader.exists`),
so dropping the real PNG in requires **zero code change** — the engraving simply appears.

Target look: single-tone, engraving-style newsprint illustration, wide aspect (~16:9) so it
fills the frame with `STRETCH_KEEP_ASPECT_COVERED`.
