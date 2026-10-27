---
name: strings-csv-surgery
description: "strings.csv has no single quoting convention, so edit it by byte-span splice, never by rewrite; plus the token rules the integrity gate enforces"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 954101b2-26e4-4348-828b-cca7aeee9b88
  modified: 2026-08-23T18:00:59.101Z
---

`localization/strings.csv` (1800+ keys, TR canonical) **cannot be safely round-tripped by a CSV
writer.** Its quoting is inconsistent row to row: some rows quote a field that needs no quoting,
some do not quote a sibling that does. A `csv.reader` → `csv.writer` pass with any single
quoting policy rewrites ~126 unrelated physical lines while claiming to change one key.

**Edit it by splicing byte spans.** Parse records with a quote-aware scanner that records each
record's `(start, end, key)`, then replace only the spans you mean to touch and leave every other
byte alone. Apply edits back-to-front so earlier offsets stay valid; an insert-after-anchor at
`end` and a replace of `(start, end)` compose correctly in that order. Verify by re-parsing and
diffing the key→value map: everything you did not name must come back byte-identical.

Format facts: header `keys,tr,en`, exactly 3 columns, UTF-8 **no BOM**, **LF only**, embedded
newlines are literal LF inside a quoted field (24 rows have them), trailing newline present.

**Those 24 embedded-newline rows are also a DELETION trap, measured 2026-08-23.** A sweep that
splits the raw text on newlines and drops lines whose first field matches a prefix removes only
the FIRST physical line of a multi-line record and leaves its continuation lines behind as
orphans. The
parse then breaks from that row onward and the key count collapses silently — 1929 → 939 in the
instance that caught it, while the file lost only 55 lines and `wc -l` looked fine. `loc_residue`
is what screams (`fakekey=17`); `loc_csv_integrity` also fails but *after* the damage. Delete
whole RECORDS with a quote-aware parse, never physical lines — this is the same reason the
memory above says splice spans rather than rewrite.

**What `loc_csv_integrity` enforces** (a smoke case in `endgame_smoke.gd`, not a standalone
script) — the two that bite:

- Placeholder tokens must match `[a-z_]+` and the **TR and EN token sets must be identical**.
  A Turkish-named token like `{yatırımcı}` is not recognised as a token at all, so it trips the
  stray-brace count and would render on screen as literal `{yatırımcı}`. Authors write Turkish
  placeholder names; the build needs the ASCII one in both columns. See
  [[frank-v6-landing-pass]].
- Every key must resolve in both locales (`translate(k) != k`), no duplicates, no positional
  `%s`/`%d`.
- **Exactly 3 columns** — tightened 2026-08-21 after it shipped a bug. A TR value carrying an
  UNQUOTED COMMA splits into four fields: TR keeps only the fragment before the comma, the EN
  column receives TR's *second* fragment, and the real EN falls into a fourth column nobody
  reads. Both columns are non-empty and token-free, so every other assertion passes and an
  English player sees a Turkish sentence on screen. The gate said `row.size() < 3`; it now says
  `!= 3`. **When you author a value containing a comma, quote it** — nothing else will tell you.

The companion gate is `scripts/debug/loc_residue.gd`, run as
`godot --headless --path . -s res://scripts/debug/loc_residue.gd` (exit 0 = clean, prints the
key count). Both are named in CLAUDE.md as "proof is a command, not a claim".

**Windows/Python gotcha:** stdout defaults to cp1254 and will die on `→` or `·`. Set
`PYTHONIOENCODING=utf-8`, and write results to a file with an explicit `encoding="utf-8"`
rather than printing them. MSYS-style `/c/...` paths do not work in Windows Python — pass
`C:/...`.
