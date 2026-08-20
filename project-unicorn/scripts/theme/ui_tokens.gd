class_name UiTokens
extends RefCounted

# ============================================================================
# Project Unicorn — UI design tokens (single source of truth).
# ============================================================================
# Visual identity = the "Shiftkod" prototype: a LIGHT warm-cream editorial body
# with DARK charcoal chrome (top bar + news ticker), a single amber accent, and
# color used semantically (green positive / red negative / parchment neutral)
# in small uppercase badges.
#
# Why a GDScript constants file: it is the canonical place colors/sizes are
# defined. `themes/master_theme.tres` is GENERATED from these tokens by
# `scripts/theme/build_theme.gd` (Godot cannot read GDScript consts into .tscn
# literals, so the theme is a build artifact of this file — never hand-drift it).
# Scripts read `UiTokens.*` directly for runtime/state-dependent styling.
#
# CONTEXT RULE — text & state colors depend on the surface they sit on:
#   * On the DARK chrome (top bar, ticker): use CREAM / *_BRIGHT.
#   * On the LIGHT body (cards, panels, modal): use INK / POSITIVE / NEGATIVE.
#
# ============================================================================
# OWNERSHIP — who decides what (Tema Çekirdeği, 2026-08-03)
# ============================================================================
# UiTokens (this file) OWNS the VOCABULARY:
#   * the palette table — every Color in the game, named
#   * the 6-step type scale + the editorial-display exception tier
#   * spacing / radius / border-width / padding-pair tokens
#   * the leading (line_spacing) values per step
#   * runtime color-decision helpers (delta_color, badge_palette, health_color…)
#     and the format/locale helpers — logic a .tres cannot express
#   UiTokens knows NOTHING about Control types. It never names a Button or a Label.
#
# themes/master_theme.tres OWNS the ASSIGNMENT — which Control type / type
# variation gets which token — and it is a GENERATED ARTIFACT. Never hand-edit it.
#   Regenerate:  godot --headless --path . -s res://scripts/theme/build_theme.gd
#   (a clean checkout needs `godot --headless --path . --import` first)
#
# build_theme.gd is the ONLY file allowed to turn a token into a theme item.
#
# WITHIN the theme the split is:
#   * the SCALE owns SIZE + LEADING — a variation never overrides its step's size
#   * the VARIATION owns FACE + COLOR — that is the register axis (light body /
#     dark chrome / cinematic / newsprint) and it is deliberately free
#
# Scenes and scripts own LAYOUT ONLY (anchors, separation, margins, min sizes).
# They must not carry font sizes, colors, or styleboxes — reach for a
# theme_type_variation, or add one. Existing literals are GRANDFATHERED and
# migrate only when the surrounding lines change (the same convention TECH_SPEC's
# Decision Log set for inline Color() literals).
#
# FONT IMPORT STANDARD (documented, not re-decided here): all faces share
# antialiasing=1 (grayscale), hinting=1 (light), subpixel_positioning=4 (auto),
# msdf off, mipmaps off, oversampling=0.
#
# THE RESOLUTION PASS RAN (2026-08-18) AND THE STANDARD STANDS — UNCHANGED.
# This block used to defer the question ("belongs to a resolution pass, not to a
# theme edit"). That pass measured it, so the deferral is retired: under Godot
# 4.6.2 with stretch mode "canvas_items", TEXT IS ALREADY RASTERIZED AT THE
# PHYSICAL RESOLUTION. `oversampling=0.0` means "inherit the viewport", and the
# viewport oversamples on its own — no font import param needed changing.
#
# Proof, so the next session does not re-litigate it by eye: shoot one screen at
# 1920x1080 and at 3840x2160, then compare the 4K frame against a bilinear 2x
# upscale of the 1080p frame. Measured MAE was 3.8 (mono) / 5.5 (sans) / 17.7
# (serif display) — nowhere near an upscale — and the anti-aliased edge fraction
# stayed flat or fell (0.060 -> 0.063, 0.053 -> 0.039, 0.102 -> 0.051), i.e. glyph
# edges still resolve in ~1 PHYSICAL pixel at 4K. An upscaled bitmap does the
# opposite: its edge fraction grows with resolution. The 22 SVG icons DID fail
# that same test (MAE vs bilinear upscale 0.06-0.14, edges 0.21 -> 0.29) and were
# fixed at import (svg/scale 1.0 -> 2.0), which is a texture matter, not a font one.
#
# STILL TRUE, AND STILL A TRAP: these params interact with canvas_items +
# aspect="expand" at non-1080p sizes. Do not change one as part of a theme edit.
#
# KNOWN GAPS (deliberate, not oversights): no base Control focus ring; Tree /
# ItemList / TabContainer are unstyled because the game uses none.
# ============================================================================

## Bump in the SAME commit as any token or build_theme.gd edit, then re-run the
## generator. main.gd warns at boot (debug builds) when the baked stamp differs,
## which is the cheap guard against a stale master_theme.tres shipping silently.
const THEME_STAMP := 6
# ============================================================================

# ============================================================================
# PALETTE TABLE — every color in the game lives here. No file outside this block
# may write a raw Color(...).  Format:  NAME := value   # hex · where it lives
# ============================================================================
# CONTEXT RULE (see header): dark chrome → CREAM / *_BRIGHT · light body → INK /
# POSITIVE / NEGATIVE. Picking the wrong register is the one palette mistake that
# renders text invisible rather than merely off-brand.

# ============================================================================
# TERMINAL REGISTER (2026-08-08) — near-black surfaces, amber as the SINGLE
# accent, green/red reserved for meaning. Values are read from the approved
# mockups (`Unicorn Skins.dc.html`, 4a + 5a-5o), not eyeballed from renders.
#
# The names below are UNCHANGED on purpose: their ROLE is the same, only the
# value moved. That is what lets ~117 theme variations, 383 UiFactory call
# sites and every scene-baked `theme_type_variation` inherit the new skin
# without being touched one by one.
#
# TWO REGISTERS STAY LIGHT and must never be fed from these names:
#   · ODA  → `themes/oda_frozen_theme.tres` + the ODA_* frozen block below
#   · the newspaper ending → the PAPER_* / PAPER_INK_* block below
# Both are deliberate light islands in a dark game; wiring them to INK/CREAM
# would render their text invisible on cream paper.
# ============================================================================

# --- SURFACE · chrome (topbar · rail · page strip · ticker) ---
const BG_TOPBAR := Color(0.027, 0.035, 0.043, 1)   # #07090B · chrome ground
const BG_NEWS := Color(0.027, 0.035, 0.043, 1)     # #07090B · ticker (same ground as chrome)
const BG_ART := Color(0.063, 0.086, 0.110, 1)      # #10161C · deep plate
const BG_AVATAR := Color(0.106, 0.137, 0.169, 1)   # #1B232B · avatar disc + cap-table bar

# --- SURFACE · page body ---
const BG_BODY := Color(0.051, 0.067, 0.082, 1)     # #0D1115 · page ground
const BG_PANEL := Color(0.027, 0.035, 0.043, 1)    # #07090B · left rail
const CARD_BG := Color(0.063, 0.086, 0.110, 1)     # #10161C · cards / panels / rows
const CARD_ATTENTION_BG := Color(1.0, 0.361, 0.286, 0.06)  # rgba(255,92,73,.06) · attention strip fill
const CARD_FLOATING_BG := Color(CARD_BG, 0.98)     # gövde ÜSTÜNDE yüzen kart (BuildHUD) — %98 alfa (derived, never re-typed)

# --- SURFACE · control states ---
# HOVER, DELIBERATELY: Terminal's hover is EDGE emphasis, never a filled rect
# (locked recipe). SURFACE_HOVER therefore equals the resting card fill — the
# fill does not move and the hover reads on the BORDER. Anything that wants a
# visible hover reaches for BORDER_HOVER, not for a lighter surface.
const SURFACE_INPUT := Color(0.051, 0.067, 0.082, 1)     # #0D1115 · deep input fill
const SURFACE_HOVER := CARD_BG                            # #10161C · hover keeps the resting fill
const SURFACE_PRESSED := Color(0.118, 0.153, 0.188, 1)   # #1E2730 · pressed / active key
const SURFACE_DISABLED := Color(0.118, 0.153, 0.188, 1)  # #1E2730 · disabled button fill
const SURFACE_SUNKEN := Color(0.137, 0.173, 0.204, 1)    # #232C34 · meter track
const SURFACE_FRAME := Color(0.059, 0.078, 0.102, 1)     # #0F141A · inset / chip plate
const SHADE_HOVER := Color(1, 1, 1, 0.03)                # faint lift on chrome
const SHADOW_SOFT := Color(0, 0, 0, 0.50)                # floating-card shadow (popover)

# --- INK · primary text (Terminal is dark throughout, so INK is LIGHT) ---
const INK := Color(0.910, 0.929, 0.949, 1)         # #E8EDF2 · primary text / values / names
const INK_MUTED := Color(0.624, 0.690, 0.749, 1)   # #9FB0BF · secondary / prose
const INK_DIM := Color(0.337, 0.392, 0.439, 1)     # #566470 · column headers, labels, idle
const INK_FAINT := Color(0.275, 0.322, 0.365, 1)   # #46525D · stat captions, units, locked telegraph

# --- CREAM · text on chrome. Terminal collapses the two registers: chrome and
# body share one ground family, so CREAM == INK by design (kept as a name so the
# ~200 chrome call sites keep reading correctly). ---
const CREAM := Color(0.910, 0.929, 0.949, 1)       # #E8EDF2 · values/names on chrome
const CREAM_DIM := Color(0.455, 0.510, 0.561, 1)   # #74828F · captions/labels on chrome
const CREAM_DIM_DISABLED := Color(CREAM_DIM, 0.40) # disabled text on dark (derived, never re-typed)

# --- ACCENT · amber, the single accent ---
const ACCENT := Color(1.0, 0.627, 0.157, 1)        # #FFA028 · active tab, CTA, badge counts
const ACCENT_HOVER := Color(1.0, 0.698, 0.353, 1)      # #FFB25A · CTA hover  # WORKING (mockups show no hover)
const ACCENT_PRESSED := Color(0.878, 0.541, 0.110, 1)  # #E08A1C · CTA pressed # WORKING
const ACCENT_DIM := Color(0.118, 0.153, 0.188, 1)      # #1E2730 · amber-keyed fill ON chrome (active speed btn)
const ACCENT_DEEP := Color(1.0, 0.627, 0.157, 1)       # #FFA028 · amber TEXT (on dark it is just the accent)
const AMBER_BG := Color(1.0, 0.627, 0.157, 0.08)       # rgba(255,160,40,.08) · amber chip fill
const AMBER_WASH := Color(1.0, 0.627, 0.157, 0.05)     # rgba(255,160,40,.05) · selected-card wash
const ACCENT_HEX := "#FFA028"                      # BBCode form of ACCENT (NewsTicker source name)
const ON_ACCENT := Color(0.043, 0.055, 0.067, 1)   # #0B0E11 · text ON the amber fill

# --- STATE · semantic. Green/red carry MEANING ONLY; they are the one pair the
# colourblind toggle swaps, and they route exclusively through the accessors. ---
const POSITIVE := Color(0.247, 0.839, 0.549, 1)          # #3FD68C
const POSITIVE_BG := Color(0.247, 0.839, 0.549, 0.08)    # rgba(63,214,140,.08)
const POSITIVE_RULE := Color(0.247, 0.839, 0.549, 0.35)  # rgba(63,214,140,.35) · chip border
const NEGATIVE := Color(1.0, 0.361, 0.286, 1)            # #FF5C49
const NEGATIVE_BG := Color(1.0, 0.361, 0.286, 0.08)      # rgba(255,92,73,.08)
const NEGATIVE_RULE := Color(1.0, 0.361, 0.286, 0.35)    # rgba(255,92,73,.35) · chip border
const NEGATIVE_RULE_STRONG := Color(1.0, 0.361, 0.286, 0.45)  # attention-strip border
const POSITIVE_BRIGHT := Color(0.247, 0.839, 0.549, 1)   # dark ground already; same value
const NEGATIVE_BRIGHT := Color(1.0, 0.361, 0.286, 1)     # dark ground already; same value
const HEALTH_GREEN := Color(0.247, 0.839, 0.549, 1)      # #3FD68C · status dot
const HEALTH_AMBER := Color(1.0, 0.627, 0.157, 1)        # #FFA028 · status dot
# The price band's MUTED triad (4a). A second semantic set hiding in a data
# graphic — it swaps with the pair or the band lies to a colourblind player.
const BAND_SAFE := Color(0.184, 0.478, 0.333, 1)         # #2F7A55
const BAND_OPTIMAL := Color(0.753, 0.494, 0.122, 1)      # #C07E1F
const BAND_OVER := Color(0.635, 0.220, 0.169, 1)         # #A2382B

# --- STATE · semantic, COLOURBLIND-SAFE counterparts (Settings > Erişilebilirlik) ---
# The green/red pair is the ONE place the game encodes meaning in hue alone, so it
# is the one pair that needs a swap. Blue/orange, because blue↔orange survives all
# three dichromacies (deuter-, prot-, tritanopia) while green↔red survives none.
# Anchored on the Okabe-Ito / Paul Tol accessible sets, then darkened per register
# so contrast on the cream body stays ≥4.5:1 (the light values) and legibility on
# the charcoal chrome stays high (the *_BRIGHT values).
#
# Only the pair moves. HEALTH_AMBER and ACCENT are already colourblind-safe (amber
# reads as amber to a dichromat) and stay put in BOTH palettes, which is also what
# keeps the three-state health dot readable: blue / amber / orange.
#
# ALL SEVEN ARE # WORKING — Erdem's F5 eye seals the hues, exactly like the ODA and
# newspaper registers. Consts are the DEFAULT palette; nothing reads these directly,
# everything goes through the accessors below.
# RETUNED for the Terminal ground (2026-08-08). The previous twins (#005b8f /
# #a84300) were darkened for a CREAM body; on #0D1115 they fall under 4.5:1 and
# read as smudges. These are the Okabe-Ito pair at their intended screen
# brightness, which is what a dark ground wants. ALL # WORKING — Erdem's F5 seals.
const POSITIVE_CB := Color(0.337, 0.706, 0.914, 1)        # #56B4E9 · blue
const POSITIVE_BG_CB := Color(0.337, 0.706, 0.914, 0.08)  # rgba(86,180,233,.08)
const POSITIVE_RULE_CB := Color(0.337, 0.706, 0.914, 0.35)
const NEGATIVE_CB := Color(0.902, 0.624, 0.0, 1)          # #E69F00 · orange
const NEGATIVE_BG_CB := Color(0.902, 0.624, 0.0, 0.08)    # rgba(230,159,0,.08)
const NEGATIVE_RULE_CB := Color(0.902, 0.624, 0.0, 0.35)
const NEGATIVE_RULE_STRONG_CB := Color(0.902, 0.624, 0.0, 0.45)
const POSITIVE_BRIGHT_CB := Color(0.337, 0.706, 0.914, 1) # same value on dark
const NEGATIVE_BRIGHT_CB := Color(0.902, 0.624, 0.0, 1)   # same value on dark
const HEALTH_GREEN_CB := Color(0.337, 0.706, 0.914, 1)    # #56B4E9 · status dot (blue twin)
# Price-band twins. Amber sits BETWEEN the pair in both palettes, so the middle
# band keeps its hue and only the outer two move.
const BAND_SAFE_CB := Color(0.157, 0.404, 0.541, 1)       # muted #56B4E9
const BAND_OVER_CB := Color(0.549, 0.376, 0.0, 1)         # muted #E69F00
const DOT_IDLE := Color(0.350, 0.320, 0.270, 1)          # #595245 · unreached phase dot
const AXIS_EXPERIENCE := Color("#5B8FF9")                # ürün ekseni "Deneyim" — Terminal zeminde okunan mavi (eski #3b5b92 koyu gövde içindi)
# Ürün ekseni üçlüsü KATEGORİKTİR (İnovasyon/Kararlılık/Deneyim), semantik değil —
# ama üçlünün iki üyesi semantik token'lardan besleniyor (innovation=ACCENT_DEEP,
# stability=positive()). Renk körü paletinde positive() maviye döndüğü an "Kararlılık"
# ile "Deneyim" İKİ MAVİ olur ve aynı legend'da ayırt edilemez. Deneyim'e bu yüzden
# kendi CB ikizi verildi: üçlü her iki palette de üç ayrı renk kalır
# (varsayılan: kehribar / yeşil / mavi · CB: kehribar / mavi / mor).
const AXIS_EXPERIENCE_CB := Color("#B07AD6")             # CB "Deneyim" — mor; CB mavisinden de kehribardan da ayrı okunur

# --- BADGE / CHIP ---
const BADGE_BG := Color(1.0, 0.627, 0.157, 1)            # #FFA028 · rail count badge (amber pill)
const BADGE_FG := Color(0.043, 0.055, 0.067, 1)          # #0B0E11 · text on the amber badge
const NEUTRAL_BADGE_BG := Color(0.059, 0.078, 0.102, 1)  # #0F141A · neutral chip plate
const NEUTRAL_BADGE_FG := Color(0.624, 0.690, 0.749, 1)  # #9FB0BF · neutral chip text
const TAB_ACTIVE_BG := Color(0.063, 0.086, 0.110, 1)     # #10161C · active rail item fill

# --- EDGE · borders, dividers, hairlines ---
const CARD_BORDER := Color(0.137, 0.173, 0.204, 1)       # #232C34 · 1px card border
const BORDER_HOVER := Color(0.165, 0.204, 0.239, 1)      # #2A343D · hover/ghost edge (hover lives HERE, never in a fill)
const CARD_ATTENTION_BORDER := Color(1.0, 0.361, 0.286, 0.45)  # attention-strip edge
const BORDER_DISABLED := Color(0.165, 0.204, 0.239, 1)   # #2A343D · disabled control edge
const BORDER_DASHED := Color(0.149, 0.188, 0.227, 1)     # #26303A · empty-slot dashed edge
const DIVIDER_LIGHT := Color(0.118, 0.149, 0.180, 1)     # #1E262E · in-card hairline
const SEPARATOR := Color(0.106, 0.137, 0.169, 1)         # #1B232B · chrome hairline
const TICKER_SEP := Color(0.200, 0.243, 0.282, 1)        # #333E48 · ticker item separator

# --- VEIL · translucent whites on dark chrome ---
# Six alpha steps (0.02/0.03/0.04/0.05/0.06/0.09) collapsed to three. Every move
# is ≤0.01 alpha on a charcoal ground — below the perceptual threshold — and the
# one control where both normal AND hover shifted (SpeedButton) ends up with
# slightly MORE contrast between its states, which is the right direction.
const VEIL_FAINT := Color(1, 1, 1, 0.03)    # at-rest / disabled tint
const VEIL_SOFT := Color(1, 1, 1, 0.06)     # normal / pressed
const VEIL_STRONG := Color(1, 1, 1, 0.10)   # hover

# --- Cinematic dialogue register (Spec 5: MeetingScene) ---
# A DARK charcoal register distinct from the light editorial modals — the game's
# cinematic layer. Text on these surfaces uses the CREAM* / *_BRIGHT tones per the
# context rule above. Amber fill/edge reuse ACCENT; danger captions reuse
# NEGATIVE_BRIGHT; monologue (interior voice) text uses CREAM_DIM. Working values
# sampled toward the approved mockups — final hues sealed by Erdem's F5 eye.
const SCRIM_MODAL := Color(0.020, 0.027, 0.035, 0.62)  # rgba(5,7,9,.62) · modal dimmer (mockup value, all four modals)
const SCRIM_ROOM := Color(0, 0, 0, 0.18)              # readability scrim over full-bleed room art
const STAT_STRIP_BG := Color(0.027, 0.035, 0.043, 0.72)  # translucent stat band over art
const DIALOGUE_BG := Color(0.063, 0.086, 0.110, 1)   # #10161C · modal / Frank card ground
const DIALOGUE_COLUMN_BG := Color(0.063, 0.086, 0.110, 0.92)  # floating column (art shows through)
const DIALOGUE_CARD_BG := Color(0.059, 0.078, 0.102, 1)       # #0F141A · choice / quote card (recessed)
const DIALOGUE_CARD_BORDER := Color(0.137, 0.173, 0.204, 1)   # #232C34 · card hairline
const CONVICTION_TRACK_BG := Color(0.137, 0.173, 0.204, 1)    # #232C34 · İKNA gauge groove
const PORTRAIT_FRAME := Color(0.910, 0.929, 0.949, 1)         # #E8EDF2 · portrait rule

# --- Newspaper ending register ("Ekonomi Postası") ---
# The cream PAPER is a LIGHT surface (INK text) sitting inside the DARK screen
# (DIALOGUE_BG). It is a touch warmer/brighter than CARD_BG so the page reads as
# newsprint, not a UI card. The second-page edge + shadow give the single-sheet
# depth from the mockup. Working values — Erdem's F5 seals the final hues.
# ⚠ DELIBERATE LIGHT EXCEPTION. The mockup note is explicit: "gazete diegetik
# kağıt olarak kaldı (serif); sağ ray reçeteye geçti." The paper stays cream
# inside a Terminal screen, so it needs its OWN ink ladder — PAPER_RULE used to
# be `:= INK`, and INK is now #E8EDF2, which would have printed white-on-cream.
# That single alias is the trap this block exists to close.
const PAPER_BG := Color(0.937, 0.914, 0.863, 1)     # #EFE9DC · newsprint
const PAPER_EDGE := Color(0.227, 0.204, 0.165, 1)   # #3A342A · sheet border
const PAPER_RULE := Color(0.165, 0.141, 0.110, 1)   # #2A241C · masthead + section rules
const PAPER_SHADOW := Color(0, 0, 0, 0.38)          # page drop shadow on the dark screen
const PAPER_INK := Color(0.149, 0.125, 0.098, 1)      # #262019 · headline
const PAPER_INK_BODY := Color(0.243, 0.212, 0.169, 1) # #3E362B · body copy
const PAPER_INK_DECK := Color(0.420, 0.384, 0.322, 1) # #6B6252 · deck / italic standfirst
const PAPER_INK_MAST := Color(0.290, 0.259, 0.220, 1) # #4A4238 · masthead
const PAPER_INK_META := Color(0.596, 0.557, 0.482, 1) # #988E7B · dateline / captions
const PAPER_PLATE := Color(0.890, 0.859, 0.792, 1)    # #E3DBCA · gazete üstündeki boş gravür plakası

# --- ODA merkez görünümü (masa POV oda sahnesi; ODA rework 2026-08-06) ---
# Sahne çifti (gündüz/gece 3840×2160 sanat) + motor-çizimi bilgi katmanı. Roller:
# gece tint'i obje sprite'larına MULTIPLY biner (objeler gündüz-nötr boyandı),
# gün ışığı eğrisi SceneLayer modulate'ine saat başı adımla biner. Lamba halesi
# (ODA_LAMP_GLOW + LampGlow node) 2026-08-18'de KALDIRILDI: additive hale siyah
# lamba gövdesinin üstüne binip onu yarı saydam gösteriyordu; gece ışığını artık
# yalnız emissive ampul katmanı ve plakaya baked havuz taşıyor.
# Tüm değerler # WORKING — Erdem'in F5 gözü mühürler.
# 2026-08-17 mühürlü sanat turu: bu token TERS YÖNDEYDİ. Eski (0.72, 0.78, 0.92)
# SERİN bir multiply'dı (B > G > R) ve emekli olan serin mehtap rig'ine göre
# ayarlanmıştı (hemi 0x39435c + 0x7d8fb8 mehtap). Mühürlü gece rig'i ILIK TUNGSTEN
# tek tavan lambası (0xffd2a0) — serin tint sanata karşı çalışıyordu.
# Yeni değer GÖZ KARARI DEĞİL, ÖLÇÜM: monitör katmanının gece/gündüz render'ları
# paylaşılan opak maske üzerinde kanal kanal bölündü (ekranın karanlık camı hariç
# tutuldu, çünkü tint bilgisi taşımıyor) → (0.9058, 0.7826, 0.6209). Yani mühürlü
# gece rig'inin bu objeye YAPTIĞI şeyin birebir kendisi; inşası gereği doğru.
# Hepsi < 1 olduğu için multiply ile temsil edilebiliyor — monitörün ayrı gece
# katmanına gerek kalmamasının da sebebi bu (bkz. oda_view._apply_night_textures).
const ODA_NIGHT_TINT := Color(0.906, 0.783, 0.621, 1)   # gece: obje sprite'larına ILIK multiply — ÖLÇÜLDÜ
# Dört-durum ışık makinesi (kalite turu v2 / D6): GÜNDÜZ nötr (WHITE — token
# gerekmez) · AKŞAM 18 ılık · GECE 19-05 (sahne çifti + ODA_NIGHT_TINT) · ŞAFAK 06
# serin. Saatlik adım ÖLDÜ; tint yalnız durum sınırında 1.5 sn tween'lenir.
# 2026-08-17: ikisi de DEĞİŞMEDİ ve bu bir karardır, atlama değil.
# AKŞAM zaten yeni ILIK geceye doğru kısmi bir adım: lerp(WHITE, yeni GECE, 0.35)
# = (0.967, 0.924, 0.867), yani eldeki (1.0, 0.93, 0.84) ölçümle tutarlı.
# ŞAFAK serin kalıyor ve artık DAHA GÜÇLÜ bir vuruş: gece de serinken şafak geceye
# benziyordu; gece ılıklaştığı için şafak odanın TEK serin durumu oldu.
const ODA_TINT_EVENING := Color(1.0, 0.93, 0.84, 1)  # AKŞAM saati (belirgin ılık tek vuruş)
const ODA_TINT_DAWN := Color(0.92, 0.95, 1.0, 1)     # ŞAFAK saati (belirgin serin tek vuruş)
# ⚠ DONDURULDU (Terminal reskin 2026-08-08). Bu üçü eskiden `Color(ACCENT, a)`
# diye TÜRETİLİYORDU. ACCENT artık Terminal amber'ini (#FFA028) taşıyor; türetme
# kalsaydı oda ışığı reskin'le birlikte sessizce kayardı. Değerler eski ACCENT'in
# (#e2a33c = 0.886,0.639,0.235) birebir açılımıdır — ODA'nın kendi register'ı
# olduğu için artık paylaşılan token'ı İZLEMEZ.
const ODA_RIM_GLOW := Color(0.886, 0.639, 0.235, 0.55)          # hover rim shader uniform'u
const ODA_SCREEN_GLOW := Color(0.886, 0.639, 0.235, 0.30)       # gece monitör panelinin gölge-glow'u
const ODA_ANCHOR_GLOW_SHADOW := Color(0.886, 0.639, 0.235, 0.35) # boyalı çapa hover/tur glow gölgesi

# --- ODA DONDURULMUŞ RENK REGISTER'I (Terminal reskin 2026-08-08) ---
# ODA'nın TEMA'sı `themes/oda_frozen_theme.tres` ile donduruldu (OdaView.tscn +
# oda_tour.gd), ama oda_view.gd bazı renkleri temadan değil DOĞRUDAN token'dan
# okuyup `add_theme_color_override` / runtime StyleBoxFlat olarak basıyor
# (make_label'ın color argümanı, make_dot). Kanonik adlar (ACCENT, INK, CREAM…)
# bu reskin'le Terminal değerlerine geçtiği için o okumalar odayı da boyardı.
# Aşağıdakiler o okumaların dondurulmuş ikizidir: eski paletin BİREBİR literalleri.
# Kanıt: --theme-audit=oda dökümü reskin öncesi ve sonrası aynı kalır. (Satır SAYISI
# burada kasıtlı olarak yazılmıyor: düğüm ekleyen/silen her yerleşim turu onu meşru
# biçimde değiştiriyor ve bu satır iki kez bayatladı. Güncel sayı tek bir yerde,
# CLAUDE.md'nin UI/STYLE LAW bölümünde tutuluyor. Kanıt zaten sayı değil, dökümün
# otomatik @Sınıf@NN sayaçları normalize edildikten sonra BAYT-AYNI çıkması.)
const ODA_ACCENT := Color(0.886, 0.639, 0.235, 1)       # eski ACCENT #e2a33c
const ODA_ACCENT_DEEP := Color(0.541, 0.353, 0.071, 1)  # eski ACCENT_DEEP #8a5a12
const ODA_INK := Color(0.169, 0.149, 0.125, 1)          # eski INK #2b2620
const ODA_INK_MUTED := Color(0.431, 0.400, 0.337, 1)    # eski INK_MUTED #6e6656
const ODA_INK_DIM := Color(0.576, 0.545, 0.471, 1)      # eski INK_DIM #938b78
const ODA_CREAM := Color(0.941, 0.918, 0.851, 1)        # eski CREAM #f0ead9
const ODA_BADGE_BG := Color(0.620, 0.169, 0.145, 1)     # eski BADGE_BG #9e2b25
const ODA_HEALTH_AMBER := Color(0.788, 0.588, 0.180, 1) # eski HEALTH_AMBER #c9962e
const ODA_VEIL_SOFT := Color(1, 1, 1, 0.06)             # eski VEIL_SOFT
const ODA_SCRIM := Color(0, 0, 0, 0.55)                 # eski SCRIM_MODAL (tur karartması)
# Sağlık noktası ODA'da da renk körü moduna UYMAYA devam eder — dondurulan şey
# varsayılan paletteki piksel, erişilebilirlik davranışı değil.
const ODA_HEALTH_GREEN := Color(0.369, 0.541, 0.275, 1)     # eski HEALTH_GREEN #5e8a46
const ODA_HEALTH_GREEN_CB := Color(0.184, 0.475, 0.671, 1)  # eski HEALTH_GREEN_CB #3079ab

# ============================================================================
# TYPE SCALE — six steps, and the ONLY sizes new UI may reach for.
# ============================================================================
# THE RULE: the SCALE owns SIZE and LEADING; the VARIATION owns FACE and COLOR.
# This split is forced by the data — BodySerif (serif/INK), ChromeValue
# (sans_sb/CREAM) and SubtitleSerifCream (serif_it/CREAM_DIM) all legitimately
# sit at 13. The theme's ~43 label variations differ by REGISTER (light body /
# dark chrome / cinematic / newsprint), not by size. A scale that also owned the
# typeface would need 43 steps and would stop being a scale.
#
# Sizes measured from docs/design/mockups/ at 1080p; the ratio lands at ~1.19
# (a minor third) throughout. Five of the six already existed in the theme —
# because those values were themselves derived from these same frames in an
# earlier pass. See docs/design/mockups/README.md for the per-step trace.
#
# "default face" below is the face the plurality of that step's members use; a
# variation MAY choose another face, but it may NEVER override its step's size.
#
#   token          px   default face   voice
#   SIZE_MICRO      9   mono_label     uppercase meta, badges, stat captions
#   SIZE_SMALL     11   mono_reg       data, secondary meta, tab labels
#   SIZE_BODY      13   serif_reg      reading prose
#   SIZE_LEAD      15   sans_sb        names, choices, figures, controls
#   SIZE_TITLE     18   sans_sb        stat figures, sub-heads
#   SIZE_DISPLAY   22   serif_sb       modal / screen titles
# TERMINAL LADDER (2026-08-08). The mockups are authored in half-steps
# (8.5 / 9.5 / 10.5 / 11.5 / 12.5 / 13.5) that Godot's INTEGER font sizes cannot
# carry. Rule applied: ROUND HALF-UP, and verify the ORDERING survives — it does,
# so nothing that was visually smaller becomes larger. Two steps are new (META,
# DATA); TITLE moved 18→16 to match the mockup's card/context serif.
#
#   token         px   voice (measured site)
#   SIZE_MICRO     9   [PROPOSAL] chip 8.5, phase caption 9
#   SIZE_META     10   column headers 9.5, rail labels 10, chips 10
#   SIZE_SMALL    11   section headers 10.5, ticker 11, title-row summary 11
#   SIZE_DATA     12   primary CTA 11.5, empty rows 12, clock 12, inputs
#   SIZE_BODY     13   prose 12.5-13, card names 13
#   SIZE_LEAD     15   TopBar + month-summary figures 15
#   SIZE_TITLE    16   card / context serif titles
#   SIZE_DISPLAY  22   Ayarlar + secondary page titles
const SIZE_MICRO := 9
const SIZE_META := 10
const SIZE_SMALL := 11
const SIZE_DATA := 12
const SIZE_BODY := 13
const SIZE_LEAD := 15
const SIZE_TITLE := 16
const SIZE_DISPLAY := 22

# --- Editorial display tier — a documented EXCEPTION, not extra scale steps ---
# A 54px masthead and a 9px badge cannot both be governed well by one interface
# scale: these are typographic set pieces composed against a fixed page, not part
# of the reading rhythm. RULE: any size above SIZE_DISPLAY must be named here, and
# may appear ONLY in the newspaper ("Ekonomi Postası") or ceremony registers.
const SIZE_ED_MODAL := 24       # modal titles (event · Atlas · month summary)
const SIZE_ED_CEREMONY := 26    # PAGE titles (Ekip / Portföy / Finans / Sales …); onboarding
const SIZE_ED_HEADLINE := 32    # newspaper headline (mockup 5l); path-card display 30 rounds here
const SIZE_ED_FIGURE := 44      # newspaper stat figures "$1.2M"
const SIZE_ED_MASTHEAD := 52    # "EKONOMİ POSTASI" (mockup 5l)

# --- Leading (line-height) ---
# Godot's Label has NO line_height property. The line box is the font's own
# ascent+descent at that size PLUS the theme constant `constants/line_spacing`
# (engine default 3); RichTextLabel uses `constants/line_separation` (default 0).
# So leading here = px tokens fed to those two constants.
#
# ⚠ Raising a LEADING_* value changes the pixel HEIGHT of every wrapping Label —
# that is a LAYOUT change. Theme Core therefore ships them at exactly the engine
# defaults: zero pixel delta today, but the values are now OURS and can no longer
# drift when Godot changes its default theme. Raising them is a separate, gated job.
const LEADING_MICRO := 2
const LEADING_SMALL := 2
const LEADING_BODY := 3         # == engine default
const LEADING_LEAD := 3
const LEADING_TITLE := 2
const LEADING_DISPLAY := 0
const LEADING_RICH := 0         # RichTextLabel line_separation; == engine default

# --- Grandfathered display sizes (screen code, NOT on the scale) ---
# These predate the scale and were deliberately LEFT ALONE by Theme Core: moving
# them is 2-4px of visible motion, which is an aesthetic call belonging to the
# polish wave, not to a foundation task. Listed here so that wave knows where they
# live. Do NOT add to this list — new code picks a scale step.
#   creation_flow.gd:214 (34) · origin_traits_step.gd:350 (30) · :320 (20)
#   month_summary_modal.gd:168 (26) · term_sheet_table_scene.gd:264 (24)
#   pricing_panel.gd:70 (24) · detail_view.gd:141 (20)

# ============================================================================
# SPACING + SHAPE
# ============================================================================
# 4-based; 6 is the one sanctioned half-step (dense data rows). NEW separation /
# margin / gap values come from here. The ~466 existing literals in scenes and
# scripts are GRANDFATHERED and migrate only when the surrounding lines change —
# the same convention TECH_SPEC's Decision Log already set for inline Color()
# literals. Theme Core deliberately did NOT sweep them: that is layout churn.
const SPACE_0 := 0
const SPACE_XXS := 2
const SPACE_XS := 4
const SPACE_S := 6
const SPACE_M := 8
const SPACE_L := 12
const SPACE_XL := 16
const SPACE_XXL := 20
const SPACE_3XL := 24
const SPACE_4XL := 32

# --- Corner radii ---
# StyleBoxFlat clamps a radius to half the box, so RADIUS_PILL is a true circle
# or pill at ANY size — which is why make_avatar no longer needs its old
# "keep the diameter at or below 36" caveat.
# TERMINAL: the mockups use radius 2 for EVERYTHING that is not a pill. The
# named steps are kept (call sites keep reading the name that describes their
# role) but they all resolve to 2 — a rounded-corner ladder is a light-editorial
# idea, and Terminal simply does not have one. The pill exceptions are real and
# stay: toggle track/knob, rail badge, avatar.
const RADIUS_NONE := 0          # full-bleed chrome bands, rails, sunken tracks, focus killers
const RADIUS_XS := 2            # dots, cap bars, the paper sheet
const RADIUS_S := 2             # chips, progress bars, speed buttons, sliders
const RADIUS_M := 2             # DEFAULT — cards, buttons, inputs
const RADIUS_L := 2             # modals, portrait cells
const RADIUS_XL := 2            # dialogue choice cards, tab badge
const RADIUS_XXL := 2           # dialogue column, portrait frame
const RADIUS_PILL := 999        # fully rounded at any size
# The two light-editorial shape exceptions are RETIRED by Terminal: the recipe
# has one non-pill radius and these were the only survivors of the old ladder.
const RADIUS_PORTRAIT := 2      # PortraitFrame (was 10)
const RADIUS_CARD_LG := 2       # DialogueCard (was 16)

# --- Border widths ---
const BORDER_HAIRLINE := 1      # cards, inputs, chips, tooltip
const BORDER_FOCUS := 2         # selection rings (SelectedBorder, PortraitCellSelected)
const BORDER_ACCENT := 3        # left accent bar (QuoteBox, TabButtonActive)

# --- StyleBox content-margin pairs (h, v) ---
# Named 1:1 against the pairs already in use, so adopting them was a pure rename
# with zero pixel change. These govern build_theme.gd ONLY — container margins and
# separations inside scenes are layout and are not in scope here.
const PAD_CHIP := Vector2i(6, 2)          # UiFactory chip
const PAD_BTN_XS := Vector2i(8, 3)        # SpeedButton
const PAD_BTN_S := Vector2i(10, 4)        # DialogueStepper
const PAD_BTN_GHOST := Vector2i(10, 5)    # DialogueGhost
const PAD_INPUT := Vector2i(10, 6)        # LineEdit
const PAD_BTN := Vector2i(12, 6)          # base Button
const PAD_CHOICE := Vector2i(12, 8)       # ChoiceCard family
const PAD_INPUT_LG := Vector2i(12, 9)     # DialogueInput (ceremony-scale field)
const PAD_CARD_TIGHT := Vector2i(10, 8)   # CardPanelTight
const PAD_CARD := Vector2i(12, 10)        # CardPanel / CardCta / CardAttention
const PAD_STRIP := Vector2i(12, 6)        # StatStrip (same value as PAD_BTN, kept apart by role)
const PAD_BAND := Vector2i(14, 8)         # HeaderBand
const PAD_ROW := Vector2i(14, 10)         # QuoteBox / DialogueChoice
const PAD_CARD_RAIL := Vector2i(14, 12)   # RailCard
const PAD_CTA := Vector2i(16, 10)         # CommitButton
const PAD_TOOLTIP := Vector2i(8, 4)       # tooltip panel
const PAD_RAIL := Vector2i(20, 20)        # RailPanel
const PAD_PAGE := Vector2i(28, 22)        # PaperModal
const PAD_SHEET := Vector2i(44, 36)       # PaperPanel
const PAD_FRAME := Vector2i(4, 4)         # PortraitFrame / PortraitCell hairline inset
const PAD_CELL := Vector2i(3, 3)          # PortraitCell

# --- Tab glyphs (fallback only; SVG icons are primary — see TABS.icon) ---
const TAB_GLYPH_PRODUCT := "▣"
const TAB_GLYPH_HR := "◉"
const TAB_GLYPH_FINANCE := "$"
const TAB_GLYPH_SALES := "↗"
const TAB_GLYPH_MARKETING := "◇"
const TAB_GLYPH_RND := "⚡"
const TAB_GLYPH_PERSONAL := "★"
const TAB_GLYPH_EVENTS := "●"

# --- Tab definition (id, glyph, icon, locked) — canonical 8-tab list ---
# NO `label` FIELD, deliberately (S2-34, 2026-08-18). The rail's caption is a localization
# key derived from the id — TAB_ + ID.to_upper() — so LeftTabs.tscn carries the key and
# center_viewport derives the same one. An English `label` here was the SECOND source of
# those captions, which is exactly why the rail stayed English-only in Turkish.
# `locked` = visible-but-unreachable (RELEASE SCOPE: Marketing and R&D are EARLY ACCESS
# systems). The rail shows them dimmed with a YAKINDA pill and never connects `pressed` —
# the strongest Coming-Soon telegraph the shell has, and the same recipe the origin cards
# use. LeftTabs.tscn's button order must match this array position-for-position; the
# `rail_tabs_match_scene_order` smoke case is what guards that.
const TABS := [
	{"id": "product", "glyph": TAB_GLYPH_PRODUCT,  "icon": "res://assets/icons/tabs/product.svg"},
	{"id": "sales", "glyph": TAB_GLYPH_SALES,    "icon": "res://assets/icons/tabs/sales.svg"},
	{"id": "hr", "glyph": TAB_GLYPH_HR,       "icon": "res://assets/icons/tabs/hr.svg"},
	{"id": "finance", "glyph": TAB_GLYPH_FINANCE,  "icon": "res://assets/icons/tabs/finance.svg"},
	{"id": "personal", "glyph": TAB_GLYPH_PERSONAL, "icon": "res://assets/icons/tabs/personal.svg"},
	{"id": "marketing", "glyph": TAB_GLYPH_MARKETING, "icon": "res://assets/icons/tabs/marketing.svg", "locked": true},
	{"id": "rnd", "glyph": TAB_GLYPH_RND,      "icon": "res://assets/icons/tabs/rnd.svg", "locked": true},
	{"id": "events", "glyph": TAB_GLYPH_EVENTS,   "icon": "res://assets/icons/tabs/events.svg"},
	# Spec 6 — the standalone "Yatırım" rail tab was relocated INTO the Finance tab as a
	# sub-page (Finance>Yatırım); the 9th rail entry is gone. The `ops` entry left on
	# 2026-08-20: GDD v2 ch. 12 has no Operations tab, nothing in the codebase emitted,
	# matched or preloaded the id, and Marketing took its slot in the icon set.
]

# ============================================================================
# SEMANTIC PALETTE SWITCH — the accessibility swap (Settings > Erişilebilirlik).
# ============================================================================
# Semantic colour is never baked into master_theme.tres (build_theme.gd holds
# zero POSITIVE/NEGATIVE references — verified), so switching palettes is a pure
# RUNTIME re-read: no theme regeneration, no stamp bump, no .tres rewrite.
#
# THE RULE that makes this cheap: read semantic colour through the ACCESSOR
# (`UiTokens.positive()`), never through the const (`UiTokens.POSITIVE`). The
# consts remain the default-palette VALUES; the accessors are the only sanctioned
# door. A new site that reaches for the const is invisible to the toggle.
#
# Live surfaces repaint on EventBus.palette_changed — the same self-healing
# grammar as language_changed (resident shell children repaint in place, the open
# tab page rebuilds via a tab_changed re-emit).
static var _cb_palette: bool = false

## Settings applies this at boot and on every toggle. It does NOT emit the signal —
## the caller owns that, exactly as Localization owns language_changed.
static func set_colorblind(on: bool) -> void:
	_cb_palette = on

static func is_colorblind() -> bool:
	return _cb_palette

static func positive() -> Color:
	return POSITIVE_CB if _cb_palette else POSITIVE

static func negative() -> Color:
	return NEGATIVE_CB if _cb_palette else NEGATIVE

static func positive_bg() -> Color:
	return POSITIVE_BG_CB if _cb_palette else POSITIVE_BG

static func negative_bg() -> Color:
	return NEGATIVE_BG_CB if _cb_palette else NEGATIVE_BG

static func positive_bright() -> Color:
	return POSITIVE_BRIGHT_CB if _cb_palette else POSITIVE_BRIGHT

static func negative_bright() -> Color:
	return NEGATIVE_BRIGHT_CB if _cb_palette else NEGATIVE_BRIGHT

static func health_green() -> Color:
	return HEALTH_GREEN_CB if _cb_palette else HEALTH_GREEN


## Çip KENARLARI da semantiktir. Dolgu/metin takas olup kenar sabit kalsaydı
## renk körü modunda çip iki paletten karışık okunurdu.
static func positive_rule() -> Color:
	return POSITIVE_RULE_CB if _cb_palette else POSITIVE_RULE


static func negative_rule() -> Color:
	return NEGATIVE_RULE_CB if _cb_palette else NEGATIVE_RULE


static func negative_rule_strong() -> Color:
	return NEGATIVE_RULE_STRONG_CB if _cb_palette else NEGATIVE_RULE_STRONG


## Fiyat bandının MAT üçlüsü (4a). Bir veri grafiğinin içine saklanmış İKİNCİ bir
## semantik küme; kaçırılsaydı renk körü modunda bant oyuncuya yalan söylerdi.
## Orta bant kehribardır ve iki palette de yerinde kalır — yalnız uçlar takas olur.
static func band_safe() -> Color:
	return BAND_SAFE_CB if _cb_palette else BAND_SAFE


static func band_over() -> Color:
	return BAND_OVER_CB if _cb_palette else BAND_OVER


## ODA'nın dondurulmuş sağlık yeşili. health_green()'in ikizi: aynı erişilebilirlik
## davranışı (CB modunda maviye döner), ama varsayılan piksel eski palete pinlenmiş
## — bkz. ODA DONDURULMUŞ RENK REGISTER'I.
static func oda_health_green() -> Color:
	return ODA_HEALTH_GREEN_CB if _cb_palette else ODA_HEALTH_GREEN

## Ürün ekseni "Deneyim". Semantik DEĞİL — palete bağlı olmasının tek sebebi,
## CB modunda "Kararlılık"ın maviye dönüp bu eksenle çakışması (bkz. AXIS_EXPERIENCE_CB).
static func axis_experience() -> Color:
	return AXIS_EXPERIENCE_CB if _cb_palette else AXIS_EXPERIENCE

# ============================================================================
# Runtime color-decision helpers — centralize sign/kind -> color logic so it
# isn't re-implemented across top_bar / event_modal / product_tab.
# ============================================================================
# All five route through the accessors above, so every consumer that already
# obeys the "never re-invent sign→colour" law inherits the palette swap for free.

## Delta color for LIGHT surfaces (rationale rows, etc.).
static func delta_color(value: int) -> Color:
	if value > 0: return positive()
	if value < 0: return negative()
	return INK_MUTED

## Delta color for the DARK chrome (top-bar metric deltas).
static func delta_color_bright(value: int) -> Color:
	if value > 0: return positive_bright()
	if value < 0: return negative_bright()
	return CREAM_DIM

## {bg, fg} for a tinted chip. kind: "positive" | "negative" | "neutral" | "accent" | "attention".
static func badge_palette(kind: StringName) -> Dictionary:
	match kind:
		&"positive": return {"bg": positive_bg(), "fg": positive()}
		&"negative": return {"bg": negative_bg(), "fg": negative()}
		&"accent":   return {"bg": AMBER_BG, "fg": ACCENT_DEEP}
		&"attention": return {"bg": BADGE_BG, "fg": BADGE_FG}
		_: return {"bg": NEUTRAL_BADGE_BG, "fg": NEUTRAL_BADGE_FG}

## {bg, fg} chip palette chosen from a signed delta.
static func badge_palette_for_delta(value: int) -> Dictionary:
	if value > 0: return badge_palette(&"positive")
	if value < 0: return badge_palette(&"negative")
	return badge_palette(&"neutral")

## Health dot color. state: "healthy" | "warn" | "bad".
static func health_color(state: StringName) -> Color:
	match state:
		&"healthy": return health_green()
		&"warn": return HEALTH_AMBER   # amber is already colourblind-safe — same in both palettes
		&"bad": return negative()
		_: return INK_DIM

## {bg, fg} chip palette for a relationship tier (event character strip).
static func relationship_palette(rel: String) -> Dictionary:
	match rel:
		"ally", "friendly": return badge_palette(&"positive")
		"wary": return badge_palette(&"accent")
		"hostile": return badge_palette(&"negative")
		_: return badge_palette(&"neutral")

## {bg, fg} chip palette for a bug count (product build indicator).
static func bug_severity(bug_count: int) -> Dictionary:
	if bug_count <= 0: return badge_palette(&"positive")
	if bug_count <= 2: return badge_palette(&"accent")
	return badge_palette(&"negative")


## Game-wide money format (Spec 3 §6 — the single convention going forward).
## < $1K → "$800" · ≥ $1K → one-decimal K ("$2.1K", "$10.0K") · ≥ $1M →
## one-decimal M ("$4.0M") · ≥ $10M drops a .0 decimal ("$22M"). Negative →
## leading "-". TopBar's variants moved here (format_money_chip/exact, 2026-07-21
## sweep); remaining local formatters are deliberate: ProductUiShared.money_tr
## (Rev3 exact dot-grouping), EventModal._fmt_money_delta. NEW code must use this.
##
## LOCALIZATION (2026-08-18): the BODY moved to Fmt, which is where the locale's
## numeric separators live — these three are now one-line delegates kept for their
## ~40 call sites. The theme file owning money formatting was always a category
## error (its own OWNERSHIP law says UiTokens is the visual vocabulary); a locale
## flip is the natural moment to evict it. New code may call either name.
static func format_money(amount: int) -> String:
	return Fmt.money(amount)


## TopBar finance-chip format (moved verbatim from top_bar.gd — 2026-07-21 sweep).
## MRR/BURN/NET stay abbreviated (K/M) so they can't widen FinanceGroup and shove the speed
## controls. One decimal below $10K keeps MRR precise ("$3.5K"), no decimal above ("$50K",
## "$350K"), M above a million ("$1.2M"). NOTE: thresholds deliberately diverge from
## format_money (the ≥$10K no-decimal branch) — merge decision belongs to the curve session.
## Negative → leading "-", exactly like format_money.
static func format_money_chip(value: int) -> String:
	return Fmt.money_chip(value)


## Exact money, thousands-grouped ("$12.340"/"$12,340", "$1.234.567"/"$1,234,567").
## CASH is shown in FULL because money management is precise (Erdem). The StatCol_Cash
## width bound (+ clip_text) keeps even 7-digit values from shoving the chrome.
static func format_money_exact(value: int) -> String:
	return Fmt.money_exact(value)


## Turkish-aware uppercase. DEPRECATED IN FAVOUR OF Fmt.upper — this name now delegates.
## The reason is a bug, not tidiness: 15 sites called tr_upper on ALREADY-TRANSLATED text,
## so under English the Turkish i→İ rule mangled real words (Display→DİSPLAY,
## Audio→AUDİO, Accessibility→ACCESSİBİLİTY). Fmt.upper branches on the locale, so the
## Turkish rule applies only to Turkish. Existing callers are correct as they stand; new
## code should say Fmt.upper.
static func tr_upper(s: String) -> String:
	return Fmt.upper(s)


## Net-runway display (Package 5): revenue-aware runway. INF (net_burn ≤ 0) → the
## "default alive" status word ("Artıda"); finite → whole months. Uses TranslationServer
## because statics can't call tr(). The single home for the months-vs-status +
## localization decision, feeding every net-runway surface (TopBar, Finance tab,
## HR previews, Month-End summary) — one edit here flips them all.
## `positive` lets a caller color the status green; `note` is the hover/sub-line
## explaining why no month figure is shown (never render infinity or a fake number).
## Two sub-month truths the month figure alone cannot tell, in branch order:
## cash below zero → NO runway (zero days, never the status word), and a finite
## runway shorter than a month → whole DAYS, because "0 ay" would read as insolvency.
static func net_runway_parts(months: float) -> Dictionary:
	# The empty treasury is asked about FIRST, before INF: GameState.runway_months_for()
	# answers INF for any non-negative daily net without ever looking at the cash, so a
	# company that committed a build it could not afford sits at cash < 0 and still gets
	# painted a green "Artıda" — two TopBar cells from a red bankruptcy countdown. Below
	# zero there is no runway, said with the vocabulary this function already owns.
	if GameState.cash < 0:
		return {"value": "0", "unit": TranslationServer.translate("RUNWAY_UNIT_DAYS"),
				"positive": false, "note": ""}
	if months == INF:
		return {"value": TranslationServer.translate("RUNWAY_PROFITABLE"), "unit": "",
				"positive": true, "note": TranslationServer.translate("RUNWAY_PROFITABLE_NOTE")}
	if months < 1.0:
		# Under a month the month figure rounds to a bare "0 ay" — insolvency, printed at a
		# company that still pays its bills for most of a week. Same runway, said in days.
		# floor(), not round(): a countdown must never promise a day the cash cannot cover.
		return {"value": str(int(floor(months * GameState.DAYS_PER_MONTH))),
				"unit": TranslationServer.translate("RUNWAY_UNIT_DAYS"),
				"positive": false, "note": ""}
	return {"value": str(int(round(months))), "unit": TranslationServer.translate("RUNWAY_UNIT_MONTHS"),
			"positive": false, "note": ""}


static func net_runway_text(months: float) -> String:
	var p: Dictionary = net_runway_parts(months)
	return String(p.value) if String(p.unit) == "" else "%s %s" % [p.value, p.unit]


## Build progress (ProductSystem.build_progress(), 0.0-1.0) as the WHOLE percent every
## surface prints — the single home for that rounding, the same way net_runway_parts is
## the single home for the months decision. The floating build card lives over the tab
## pages, so the portfolio badge and the card render the SAME build in one frame: one
## site rounding and the other flooring turns 0.4761 into "%48" beside "%47".
## Bars take build_percent(p) / 100.0 (or the int as a 0-100 value), never the raw
## fraction — a bar fed the unrounded number disagrees with the figure next to it.
static func build_percent(progress: float) -> int:
	return int(round(clampf(progress, 0.0, 1.0) * 100.0))
