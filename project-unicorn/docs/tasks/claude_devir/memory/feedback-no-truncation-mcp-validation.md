---
name: feedback-no-truncation-mcp-validation
description: "Erdem 2026-10-28: 'abuk subuk kısıtlama veya … kabul edilemez' — UI must not truncate or hide content; agents must validate their own work visually via Godot MCP"
metadata:
  type: feedback
---

**Rule:** the game's UI never cuts text with "…", never hides an element because it does not fit, and never adds an
arbitrary width or line limit to make a layout work. Text that does not fit wraps and the row grows. Every agent checks
its own visible work in the running game through Godot MCP (gopeak on the Mac) before committing, and also takes the
game's own TR/EN frames.

**Why:** On 2026-10-28 Erdem reviewed the UE frames. He wrote that "abuk subuk kısıtlama vs veya … kabul edilemez" and
that agents must validate their work visually with MCP. What triggered it:
- c7's finding that the left column "can only shrink to 280 px because a long name breaks";
- card names cut with "…" after two lines.

**How to apply:**
- Brief every UI agent with N4 read strictly: no `…`, no clipping, no hidden overflow.
- Have every UI agent run a sweep for `text_overrun_behavior`, `clip_text`, `max_lines`, `visible_characters` and
  fixed-width cuts.
- Count-collapsing displays such as "+{n} kart" are a design choice. They go to Erdem as frames, and nobody removes them
  on their own.
- Before forwarding any frame to Erdem, check it for truncation myself.

Related: [[feedback-codirector-visible-rulings]], [[feedback-ui-show-dont-tell]].
