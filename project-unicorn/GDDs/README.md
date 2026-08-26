# GDDs — which of these is the authority

These `.docx` files are the director-side design documents. They are the source of truth for
their modules, with one exception recorded below.

## The one exception: the event engine

`GDD — OLAY MOTORU (EVENT ENGINE) rev 2.docx` was converted to
[`../docs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`](GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md) on **2026-08-25**, and
**the markdown is now the live authority.** The `.docx` is kept exactly as written and is not
edited again.

Why this one moved and the others did not: the engine task's §2.2 requires that when the code
makes a GDD instruction wrong, **the GDD file itself is updated to match reality**. A document
that lives in the tree, greps, diffs, and can carry an appended build-notes section is the only
practical form of that. Ürün rev 6.1 set the same precedent from the other direction — its §24
"İNŞA NOTLARI (kod tarafından yazıldı)" is a build-notes section appended after implementation.

Nothing was lost in the conversion: 27 sections, all tables, the 63-row edge-case matrix, and
the schema listings (which were space-aligned plain text in Word and are fenced code blocks in
the markdown). The converter is `docs/tools/` adjacent scratch work, not a shipped tool — the
conversion is a one-off, because the `.docx` will not change again.

## Everything else

Still authoritative in `.docx` form:

| document | module | note |
|---|---|---|
| `GDD v2 — 01 · The Run (spine).docx` … `14 · Scope` | the v2 chapter set | director-approved 2026-08-20 |
| `GDD — ÜRÜN` (chapter 03) | Ürün rev 6.1 | sealed; carries its own §24 build notes |
| `GDD — EKİP MODÜLÜ vson.docx` | Ekip rev 11 | sealed |
| `GDD — AR-GE MODÜLÜ .docx` | Ar-Ge rev 1.4 | sealed |
| `MARKETING MODULE resarch.docx` | research input, not a GDD | |

**`GDD v2 — 11 · Events & Narrative.docx` is not superseded.** It governs event *content* —
volume, voice, arc-to-system binding — where the engine GDD governs the machine. They are
peers and they agree; neither overrides the other in the other's territory.
