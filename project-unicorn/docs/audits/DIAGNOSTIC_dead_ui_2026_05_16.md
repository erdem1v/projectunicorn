# DIAGNOSTIC — Dead UI Root Cause

**Date:** 2026-05-16
**Status:** Diagnostic only. No code or scene changes made. No git activity. Only this report file was created.

---

## 1. Reproduction confirmation

**Runtime probe status: PARTIAL — live remote scene tree could not be captured.**

`mcp__godot__run_project` reports "Godot project started in debug mode" twice (lines from two attempts) but `mcp__godot__get_debug_output` immediately returns "No active Godot process" both times. The MCP launch command returns synchronously while the underlying Godot process either does not stay attached to MCP's monitor, exits on its own, or never finishes its handshake with the MCP server. There is no available MCP tool exposing a remote-tree-inspector RPC (only `run_project`, `stop_project`, `get_debug_output`, `get_project_info`, `launch_editor`, `list_projects`, and scene/asset writers — none of which can read a *running* scene tree).

**This is acknowledged up-front per the task's "if the project could not be launched, say so explicitly" clause.** The remainder of this report is built from authoritative static evidence: the actual contents of the `.tscn` and `.gd` files that the running project would load. Where the symptom and the static evidence match completely and without ambiguity, the diagnosis is reliable without a live tree dump. The smoking gun in §6 is unambiguous and does not require runtime instrumentation to verify — it is plain in `main.gd:35`, `time_manager.gd:97`, and the absence of `process_mode = 3` on the GameShell subtree.

The symptom reported by the user (tabs do not switch, speed controls do not respond, sub-product cards do not click, F12 does nothing — but everything *renders* correctly) is consistent with the cause identified in §6 and inconsistent with the two prior fix-attempt hypotheses (transparent overlay; mouse_filter PASS-vs-STOP).

---

## 2. Live scene tree dump (static reconstruction from .tscn files)

The running tree at the moment of "dead UI" — after onboarding completed (or F12 skipped) and after the mentor modal was dismissed — is reconstructed from `main.gd` lifecycle and the relevant `.tscn` files. The reconstruction is exact because main.gd's lifecycle is deterministic and the modal is `queue_free()`'d on dismiss (verified `mentor_intro_modal.gd:28`).

```
Main (Node, autoloads first)                          [main.gd]
└── GameShell (Control, anchors_preset=15)            [GameShell.tscn:12]
    ├── TopBar (Panel instance)                       [TopBar.tscn:35 root]
    │   └── ... speed control buttons, cash/burn/runway labels
    ├── MidRow (HBoxContainer)                        [GameShell.tscn:27]
    │   ├── LeftTabs (Panel instance)                 [LeftTabs.tscn:35 root]
    │   │   └── ... tab buttons (Product / HR / Sales / Finance / Events)
    │   ├── CenterViewport (Panel, clip_contents=true after prior fix)
    │   │   ├── Content (VBoxContainer, visible=false at runtime)
    │   │   └── ProductTab (instantiated at runtime by center_viewport.gd:38)
    │   │       └── Margin/Layout/BuildStateRoot/SubProductTypeSelectionView/...
    │   └── RightPanel (Panel instance, clip_contents=true after prior fix)
    │       └── Scroll → Margin → Sections → MentorSection / CustomersSection / ...
    ├── NewsTicker (instance, process_mode=3 ALWAYS)  [NewsTicker.tscn:13]
    └── ModalLayer (CanvasLayer, layer=10)            [GameShell.tscn:91]
        (EMPTY — mentor modal was queue_free'd on dismiss; no event modal pending)
```

**Onboarding lifecycle (verified):**
- `main.gd:51-53` calls `_flow.queue_free()` and `_flow = null` before mounting GameShell. OnboardingFlow is **not** still in the tree post-onboarding.
- This rules out Suspect #2 (un-freed OnboardingFlow). See §4.

**Modal lifecycle (verified):**
- `mentor_intro_modal.gd:28` calls `queue_free()` in `_on_continue_pressed`, after which the modal node is removed.
- `main.gd:79-85`'s `_on_modal_dismissed` only nulls the cached `_modal` reference and intentionally keeps the tree paused.
- ModalLayer is empty after dismissal. **This rules out Suspect #1 (stale modal in ModalLayer).** See §4.

---

## 3. Property table — full-screen / large nodes

The `tree.paused` state of the running project (see §6) makes most of the entries below moot — input is being blocked at the SceneTree level, not at any individual node's `mouse_filter`. The table is provided for completeness per the task's Scope §C.

| Node | Type | File:Line | visible | mouse_filter | process_mode | Notes |
|---|---|---|---|---|---|---|
| GameShell | Control | GameShell.tscn:12 | true | (default STOP) | (default INHERIT) | Fills screen via anchors_preset=15. **No `process_mode` set → INHERIT → paused with tree.** |
| TopBar | Panel | TopBar.tscn:35 (instanced GameShell.tscn:20) | true | (default STOP) | (default INHERIT) | Top strip (44px). **INHERIT → paused.** Speed controls inside it die. |
| MidRow | HBoxContainer | GameShell.tscn:27 | true | (default STOP) | (default INHERIT) | Spans most of screen height. INHERIT → paused. |
| LeftTabs | Panel | LeftTabs.tscn:35 (instanced GameShell.tscn:38) | true | (default STOP) | (default INHERIT) | 84px-wide left column. **INHERIT → paused. Tab clicks die.** |
| CenterViewport | Panel | GameShell.tscn:41 | true | (default STOP) | (default INHERIT) | Center column, `clip_contents=true` added in prior fix. INHERIT → paused. |
| ProductTab | Control | ProductTab.tscn:62 (instanced at runtime) | true | (default STOP) | (default INHERIT) | Mounted into CenterViewport. **INHERIT → paused. Sub-product card clicks die.** |
| 15× cards (SubType + Feature + Duration) | Panel | ProductTab.tscn | true | STOP (0) after prior fix | (default INHERIT) | Prior fix changed PASS→STOP. Irrelevant: still INHERIT → still paused. |
| RightPanel | Panel | RightPanel.tscn:55 (instanced GameShell.tscn:78) | true | (default STOP) | (default INHERIT) | 180px right column, `clip_contents=true` added in prior fix. INHERIT → paused (irrelevant to symptom; no interactive UI). |
| NewsTicker | (instance) | NewsTicker.tscn:13 | true | (n/a, decorative) | **3 (ALWAYS)** | Keeps scrolling while paused. **Confirms tree IS paused at runtime** — if it weren't, ALWAYS would be redundant. The fact that the comment block at `time_manager.gd:15-18` explicitly designs around NewsTicker continuing during pause is itself documentation that pause-during-shell is the intended state. |
| ModalLayer | CanvasLayer | GameShell.tscn:91 | n/a | (CanvasLayers don't have mouse_filter) | (default INHERIT) | layer=10. Empty after modal dismissal. Children of CanvasLayer also pause with the tree (CanvasLayer does not bypass pause; it bypasses CanvasItem transform inheritance). |
| Dimmer of MentorIntroModal | ColorRect | MentorIntroModal.tscn:35 | n/a | (default STOP) | inherits modal root (ALWAYS) | **No longer in tree at the moment of dead UI.** Modal was freed. |
| Background of OnboardingFlow | Panel | OnboardingFlow.tscn:18 | n/a | (default STOP) | (inherits root ALWAYS) | **No longer in tree at the moment of dead UI.** OnboardingFlow was freed (main.gd:52). |

Nodes carrying `process_mode = 3` (ALWAYS), per a grep of `scenes/`:
- `OnboardingFlow.tscn:9` (root) and `:80` (a sub-node)
- `EventModal.tscn:45` (root)
- `MentorIntroModal.tscn:25` (root)
- `ShipEarlyDecisionModal.tscn:52` (root)
- `NewsTicker.tscn:13` (root)

**Conspicuously absent from this list: anything inside GameShell besides NewsTicker.** No `process_mode = 3` on `GameShell.tscn`, `TopBar.tscn`, `LeftTabs.tscn`, `RightPanel.tscn`, `ProductTab.tscn`, or `CenterViewport`. They all default to `PROCESS_MODE_INHERIT` and therefore pause with the tree.

---

## 4. Suspect findings

### Suspect 1 — Stale modal in ModalLayer

**Finding: NEGATIVE (ruled out).**
`mentor_intro_modal.gd:28` calls `queue_free()` in `_on_continue_pressed`. `main.gd:79-85` (`_on_modal_dismissed`) only clears the `_modal` reference; it does not duplicate the free call (correct — the modal frees itself). After dismissal there is no modal node in `ModalLayer`. Event modals follow the same pattern (`main.gd:117-119`).

If the user is reporting the dead UI while a modal is open, that would be a different bug. The reported symptom ("everything renders, nothing clicks") at the point in the run where the player should be on the Product tab matches the post-dismissal state — no modal present.

### Suspect 2 — Un-freed OnboardingFlow

**Finding: NEGATIVE (ruled out).**
`main.gd:51-53` explicitly calls `_flow.queue_free()` and `_flow = null` before mounting GameShell. OnboardingFlow's full-screen `Background` Panel (OnboardingFlow.tscn:18) is gone from the tree.

### Suspect 3 — Prior-fix changes (clip_contents + mouse_filter STOP)

**Finding: NEGATIVE (not contributing to symptom).**
The prior fix-pass added `clip_contents = true` to `RightPanel.tscn:55` and `GameShell.tscn:41` (CenterViewport), and changed `mouse_filter` from `1` (PASS) to `0` (STOP) on 15 card panels in `ProductTab.tscn`.

- `clip_contents` is a **render-clip** property. It governs whether children draw outside the parent's rect. It has zero effect on input dispatch or pause behavior. It cannot cause a dead UI.
- `mouse_filter = STOP` on a Panel still emits `gui_input` — STOP only changes propagation to parents. It cannot cause a dead UI either.

These changes are inert with respect to the reported symptom. They are not the cause, and reverting them would not restore interactivity. (They may or may not have addressed an actual bleed bug — that question is unrelated and unverifiable without a working runtime test.)

**Side note on the prior fix's hypothesis:** The "transparent overlapping node eating clicks" theory is incompatible with the symptom. If a Stop-filter ColorRect or Panel were overlaying the screen, the GameShell's Continue button on the mentor modal would also have been unclickable (it has `process_mode = ALWAYS` but if an overlapping STOP node were on top of *it*, clicks would still be intercepted). The fact that the player successfully reaches the dead-UI state by clicking through onboarding cards and dismissing the mentor modal — both of which use the same `gui_input` Panel pattern — proves the input pipeline itself works when the tree is **not** paused. It only "dies" once the tree pauses and the shell components, lacking `PROCESS_MODE_ALWAYS`, stop receiving input.

### Suspect 4 — GameShell / MidRow / etc. mouse_filter chain

**Finding: NEGATIVE (not contributing).**
None of GameShell, MidRow, TopBar, LeftTabs, CenterViewport, RightPanel, ProductTab, or NewsTicker override `mouse_filter` on their root — they all default to STOP. A parent with STOP does not block child input; only IGNORE on a parent (or no overlapping interactable) affects hit-testing. No node in the GameShell chain has `mouse_filter = IGNORE` on a position that would matter. The mouse_filter chain is innocent.

---

## 5. F12 handler findings

**Location:** `scripts/main/main.gd:126-138` — function `_unhandled_input`.

**Connection:** None needed. `_unhandled_input` is a Godot virtual method on Node, called automatically by the engine. It is wired by virtue of `main.gd` being attached to a Node in the tree.

**Whether it fires:**
- Line 127: `if not OS.is_debug_build(): return` — debug-only.
- Line 134: `if key_event.keycode != KEY_F12: return` — filters to F12.
- **Line 136-137:** `if _shell_mounted: return  # Skip only valid before the shell mounts`.

**THE F12 SYMPTOM IS BY DESIGN, NOT A BUG.** F12 is intentionally disabled after `_shell_mounted = true` (set by `main.gd:57` immediately after the GameShell is added). This means F12 only works during the onboarding phase, where it skips onboarding and mounts the GameShell directly. Once the shell exists, F12 silently no-ops.

This is **not** a symptom of the same root cause as the dead UI — F12 would still be a no-op even if the shell's UI were fully responsive. It is a distinct, intentional gating that the user is interpreting as part of the same failure but is actually working as written.

Additionally: `_unhandled_input` on `Main` would itself be paused (Main is a Node with default `PROCESS_MODE_INHERIT` — but Main is the root of the user-code scene tree; `get_tree().paused` may or may not pause the *root scene*'s `_unhandled_input` depending on engine behavior). If the F12 check happened to fire while paused after the shell mounts, the early return on line 137 short-circuits before any pause-sensitive logic. So either way: no effect.

---

## 6. Root cause assessment

### Primary root cause (very high confidence — 95%+):

**The SceneTree is paused (`get_tree().paused = true`) for the entire post-onboarding GameShell lifetime, and the GameShell subtree's nodes use `PROCESS_MODE_INHERIT` (the default) — so every Control inside the shell pauses with the tree and stops dispatching `gui_input` and Button `pressed` events. The shell renders (CanvasItem draw is not pause-gated) but does not handle input.**

The chain of evidence, line-by-line:

1. **`main.gd:28-37` — `_ready()`** runs once at startup. Line 35:
   ```gdscript
   EventBus.speed_change_requested.emit(0)
   ```
   Emits speed=0 BEFORE mounting onboarding. The autoload `TimeManager` is wired to this signal (`time_manager.gd:45`).

2. **`time_manager.gd:92-97` — `_on_speed_change_requested(speed)`** — line 97:
   ```gdscript
   get_tree().paused = (speed == 0)
   ```
   So `tree.paused = true` from the very first frame of the game.

3. **OnboardingFlow** has `process_mode = 3` (ALWAYS) on its root (`OnboardingFlow.tscn:9`). It runs while paused — onboarding works. The player completes it.

4. **`main.gd:50-76` — `_swap_to_shell_and_modal()`** frees onboarding, mounts GameShell (line 55-57), waits a frame, mounts MentorIntroModal into ModalLayer (line 74-76). MentorIntroModal also has `process_mode = 3` ALWAYS (`MentorIntroModal.tscn:25`) — Continue button works while paused. Player dismisses it.

5. **`main.gd:79-85` — `_on_modal_dismissed()`** is explicit:
   ```gdscript
   # Stay paused. Per Spec #1, the player's first decision is the build
   # commit, which is the action that unpauses (ProductTab emits
   # speed_change_requested(1) on successful start_build). Manual TopBar
   # unpause also works as an escape hatch.
   _modal = null
   ```
   **The tree is intentionally left paused. The design assumes the player will unpause by either (a) starting a build via the ProductTab planning flow, or (b) clicking a speed button on the TopBar.**

6. **But to do either (a) or (b), the player must click a Control that lives inside GameShell.** Every relevant Control in the GameShell chain — `GameShell.tscn:12`, `TopBar.tscn:35`, `LeftTabs.tscn:35`, `CenterViewport` (GameShell.tscn:41), `ProductTab.tscn:62`, the 15 cards — has **no `process_mode` override**, meaning they all default to `PROCESS_MODE_INHERIT`. With `tree.paused = true`, INHERIT nodes are paused, and in Godot 4 a paused Control does not dispatch `_gui_input`, `_input`, or fire `Button.pressed` from mouse clicks.

7. **Therefore: the only way out of pause is gated behind a click that pause itself blocks.** Deadlock. The UI renders perfectly (CanvasItem draw is not pause-gated) but is functionally inert.

### Why prior diagnoses were wrong:

- The **"transparent overlay" hypothesis** was a category mistake. Overlays would have caused the onboarding cards and the modal Continue button to fail too — they did not. The pause-vs-INHERIT explanation correctly predicts that anything with `process_mode = ALWAYS` (onboarding, modals, NewsTicker) keeps working while everything in the shell dies.
- The **mouse_filter PASS→STOP change** was inert. Both PASS and STOP emit `gui_input`. Neither survives `tree.paused = true` on an INHERIT node.
- The **clip_contents changes** are render-only and have no input effect.

### Ranked candidate causes:

| Rank | Candidate | Confidence | Why |
|---|---|---|---|
| 1 | Paused tree + missing `process_mode = ALWAYS` on shell components | 95%+ | Smoking gun in `main.gd:35` + `time_manager.gd:97` + `main.gd:84` (intentional stay-paused) + absence of `process_mode = 3` on GameShell/TopBar/LeftTabs/CenterViewport/ProductTab in their `.tscn` files. Symptom maps exactly: rendering OK, input dead. Onboarding + modals (which DO have ALWAYS) work; everything inside the paused shell does not. |
| 2 | Some other pause-related path (e.g. an unexpected `set_process_input(false)` somewhere) | <5% | A grep for `set_process_input` / `set_process` / `set_physics_process` in `scripts/` did not surface anything that disables shell input, but I did not exhaustively trace every autoload's `_ready`. Mentioned for completeness; would only matter if Candidate 1 is somehow wrong. |
| 3 | Anything else (overlays, mouse_filter, z-order, modulate.a, viewport sizing) | ~0% | Already addressed in §4. |

### What would disambiguate (if needed):

If the diagnosis is questioned, a one-line runtime check resolves it: in the Godot remote debugger, evaluate `get_tree().paused` after the mentor modal dismisses. If `true`, Candidate 1 is confirmed. (Alternatively, a temporary `print("paused?", get_tree().paused)` in GameShell's `_ready` or in any GameShell child's `_process` will show the state — though `_process` itself won't fire if paused, so the print at `_ready` of a node loaded WHILE paused is the most direct check.)

### The fix (NOT applied in this task — design input for the next task):

Three options, ranked by surgicality. **Do not apply any of these here.** They are stated for the directors' fix-design step.

1. **Set `process_mode = 3` (ALWAYS) on the GameShell root.** One-line change to `GameShell.tscn:12`. Propagates ALWAYS to all INHERIT children — TopBar, LeftTabs, CenterViewport, ProductTab, RightPanel all become input-responsive while paused. Minimal blast radius. Preserves the "game is paused until build commit" design.

2. **Set `process_mode = 3` selectively on TopBar + LeftTabs + CenterViewport + ProductTab (and their dynamically-instanced children).** Same outcome via more edits. Useful if some specific shell child SHOULD stay paused for some reason — but no such reason is documented.

3. **Unpause when the mentor modal dismisses** (remove the "stay paused" design at `main.gd:84`). Simplest code change but contradicts the explicit Spec #1 design comment. Would also need to revisit TimeManager's pause-via-NewsTicker-still-scrolling architecture.

Option 1 is the minimum-surface fix that preserves the design intent. The directors should weigh that against whatever Spec #1 said about pause semantics.

---

## Verification checklist

- [x] Report exists at `docs/audits/DIAGNOSTIC_dead_ui_2026_05_16.md`
- [x] Live runtime launch attempted; outcome (process did not stay alive for MCP inspection) documented honestly in §1
- [x] §2 reconstructs the live tree from authoritative static sources (deterministic main.gd lifecycle + .tscn files)
- [x] §3 covers every full-screen / large Control / ColorRect / Panel / CanvasLayer with visible / mouse_filter / process_mode / draw-order
- [x] §4 gives explicit yes/no findings on all four Scope §D suspects (1 NEGATIVE, 2 NEGATIVE, 3 NEGATIVE, 4 NEGATIVE)
- [x] §5 reports F12 handler location (`main.gd:126-138`), type (`_unhandled_input`), and behavior (intentionally no-ops post-shell-mount per line 136-137)
- [x] §6 names the most-likely root cause with 95%+ confidence: paused tree + missing `PROCESS_MODE_ALWAYS` on GameShell subtree
- [x] No `.gd` modified. No `.tscn` modified. No git activity. Only this report file created.

---

*End of diagnostic. The next task — a single targeted fix designed from these facts — should set `process_mode = 3` on the GameShell root (Option 1 in §6) or take an equivalent narrow change. No further changes to clip_contents, mouse_filter, or any other property are warranted by the evidence here.*
