class_name UiTokens
extends RefCounted

# ============================================================================
# Project Unicorn — UI design tokens (single source of truth).
# ============================================================================
# UiTokens owns the VOCABULARY: every Color in the game (named), the type scale,
# spacing / radius / border / padding tokens, leading, and the runtime colour
# helpers a .tres cannot express (delta_color, badge_palette, health_color…).
# It knows nothing about Control types.
#
# themes/master_theme.tres owns the ASSIGNMENT (which type / variation gets which
# token) and is GENERATED from this file by scripts/theme/build_theme.gd — the
# only file allowed to turn a token into a theme item. Never hand-edit the .tres:
#   godot --headless --path . -s res://scripts/theme/build_theme.gd
#   (a clean checkout needs `godot --headless --path . --import` first)
#
# Within the theme the SCALE owns size + leading and the VARIATION owns face +
# colour (the register axis: body / chrome / cinematic / newsprint).
# Scenes and scripts own layout only.
#
# CONTEXT RULE — text colour depends on the surface: dark chrome → CREAM /
# *_BRIGHT, body → INK / positive() / negative(). The two light islands (the
# newspaper and ODA) have their own PAPER_* / ODA_* ladders; feeding them INK or
# CREAM prints light text on cream paper.
#
# FONT IMPORT STANDARD: all faces share antialiasing=1 (grayscale), hinting=1
# (light), subpixel_positioning=4 (auto), msdf off, mipmaps off, oversampling=0.
# oversampling=0 inherits the viewport, and under stretch mode "canvas_items"
# text is already rasterized at physical resolution (measured at 4K against a
# bilinear 2x upscale). These params interact with canvas_items + aspect="expand"
# at non-1080p sizes: do not change one as part of a theme edit.
#
# Not styled on purpose: base Control focus ring; Tree / ItemList / TabContainer
# (the game uses none).
# ============================================================================

## Bump in the SAME commit as any token or build_theme.gd edit, then re-run the
## generator. main.gd warns at boot (debug builds) when the baked stamp differs.
const THEME_STAMP := 7

# ============================================================================
# PALETTE — every colour in the game lives here. Format: NAME := value # hex · role
# Terminal register: near-black surfaces, amber as the single accent, green/red
# reserved for meaning.
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
const CARD_FLOATING_BG := Color(CARD_BG, 0.98)     # card floating over the body (BuildHUD)

# --- SURFACE · control states ---
# Hover is EDGE emphasis, never a filled rect: SURFACE_HOVER equals the resting
# card fill and a visible hover reaches for BORDER_HOVER.
const SURFACE_INPUT := Color(0.051, 0.067, 0.082, 1)     # #0D1115 · deep input fill
const SURFACE_HOVER := CARD_BG                            # #10161C · hover keeps the resting fill
const SURFACE_PRESSED := Color(0.118, 0.153, 0.188, 1)   # #1E2730 · pressed / active key
const SURFACE_DISABLED := Color(0.118, 0.153, 0.188, 1)  # #1E2730 · disabled button fill
const SURFACE_SUNKEN := Color(0.137, 0.173, 0.204, 1)    # #232C34 · meter track
## Kadro tablosunda tabanı taşıyan satırın zemini: CARD_BG'nin bir tık üstü, çünkü o satır
## tabloda "üstteki" olarak okunmalı. Runtime token; build_theme.gd okumaz.
const SURFACE_ROW_TINT := Color(0.075, 0.102, 0.129, 1)  # #131A21 · defterin taban satırı
const SURFACE_FRAME := Color(0.059, 0.078, 0.102, 1)     # #0F141A · inset / chip plate
const SHADOW_SOFT := Color(0, 0, 0, 0.50)                # floating-card shadow (popover)

# --- INK · primary text (Terminal is dark throughout, so INK is LIGHT) ---
const INK := Color(0.910, 0.929, 0.949, 1)         # #E8EDF2 · primary text / values / names
const INK_MUTED := Color(0.624, 0.690, 0.749, 1)   # #9FB0BF · secondary / prose
const INK_DIM := Color(0.337, 0.392, 0.439, 1)     # #566470 · column headers, labels, idle
const INK_FAINT := Color(0.275, 0.322, 0.365, 1)   # #46525D · stat captions, units, locked telegraph

# --- CREAM · text on chrome. Chrome and body share one ground family, so
# CREAM == INK by design; the name keeps chrome call sites reading correctly. ---
const CREAM := Color(0.910, 0.929, 0.949, 1)       # #E8EDF2 · values/names on chrome
const CREAM_DIM := Color(0.455, 0.510, 0.561, 1)   # #74828F · captions/labels on chrome
const CREAM_DIM_DISABLED := Color(CREAM_DIM, 0.40) # disabled text on dark

# --- ACCENT · amber, the single accent ---
const ACCENT := Color(1.0, 0.627, 0.157, 1)        # #FFA028 · active tab, CTA, badge counts
const ACCENT_HOVER := Color(1.0, 0.698, 0.353, 1)      # #FFB25A · CTA hover  # WORKING (mockups show no hover)
const ACCENT_PRESSED := Color(0.878, 0.541, 0.110, 1)  # #E08A1C · CTA pressed # WORKING
const ACCENT_DIM := Color(0.118, 0.153, 0.188, 1)      # #1E2730 · amber-keyed fill ON chrome (active speed btn)
const ACCENT_DEEP := Color(1.0, 0.627, 0.157, 1)       # #FFA028 · amber TEXT (on dark it is just the accent)
const AMBER_BG := Color(1.0, 0.627, 0.157, 0.08)       # rgba(255,160,40,.08) · amber chip fill
const AMBER_WASH := Color(1.0, 0.627, 0.157, 0.05)     # rgba(255,160,40,.05) · selected-card wash
const ACCENT_HEX := "#FFA028"                      # BBCode form of ACCENT (NewsTicker)
const ON_ACCENT := Color(0.043, 0.055, 0.067, 1)   # #0B0E11 · text ON the amber fill

# --- BUILD BAR · tur rampası ve duraklamış zemin ---
# Tur SAYIYLA değil RENKLE okunur: rakam kartta hiçbir yerde yazmıyor. Dolgu bu
# renklerin düşük alfasıdır; o kadar soluk kaldığı için sayaç dizgisi sınırın iki
# tarafında aynı kontrastta okunur ve kenar çizgisine gerek kalmaz.
# Motorda tur tavanı 4, rampa üç kademe: dördüncü hex tasarımdan bekleniyor; o
# gelene kadar tur 4 rampa 3'ü çizer.
const BUILD_RAMP_1 := ACCENT                             # #FFA028 · tur 1
const BUILD_RAMP_2 := Color(0.851, 0.753, 0.420, 1)      # #D9C06B · tur 2 · kum
const BUILD_RAMP_3 := Color(0.420, 0.686, 0.788, 1)      # #6BAFC9 · tur 3 · soğuk
const BUILD_FILL_ALPHA := 0.13                           # rampa renginin dolgu alfası
const BUILD_FILL_PAUSED := Color(0.078, 0.102, 0.125, 1) # #141A20 · durmuş dolgu, DÜZ
const BUILD_SUPPORT_FILL_ALPHA := 0.10                   # DESTEK koşusu daha da soluk


## Turun rengi. Tur SAYISI hiçbir yerde çizilmez — renk tek göstergedir.
static func build_ramp(round_index: int) -> Color:
	match maxi(1, round_index):
		1: return BUILD_RAMP_1
		2: return BUILD_RAMP_2
		_: return BUILD_RAMP_3


# --- STATE · semantic. Green/red carry MEANING ONLY; they are the pair the
# colourblind toggle swaps, so they are read through the accessors below. ---
const POSITIVE := Color(0.247, 0.839, 0.549, 1)          # #3FD68C
const POSITIVE_BG := Color(0.247, 0.839, 0.549, 0.08)    # rgba(63,214,140,.08)
const POSITIVE_RULE := Color(0.247, 0.839, 0.549, 0.35)  # rgba(63,214,140,.35) · chip border
const NEGATIVE := Color(1.0, 0.361, 0.286, 1)            # #FF5C49
const NEGATIVE_BG := Color(1.0, 0.361, 0.286, 0.08)      # rgba(255,92,73,.08)
const NEGATIVE_RULE := Color(1.0, 0.361, 0.286, 0.35)    # rgba(255,92,73,.35) · chip border
const POSITIVE_BRIGHT := Color(0.247, 0.839, 0.549, 1)   # dark ground already; same value
const NEGATIVE_BRIGHT := Color(1.0, 0.361, 0.286, 1)     # dark ground already; same value
const HEALTH_GREEN := Color(0.247, 0.839, 0.549, 1)      # #3FD68C · status dot
const HEALTH_AMBER := Color(1.0, 0.627, 0.157, 1)        # #FFA028 · status dot

# --- STATE · colourblind-safe counterparts (Settings > Erişilebilirlik) ---
# Blue/orange survives all three dichromacies while green/red survives none
# (Okabe-Ito pair at screen brightness, which a dark ground wants). Only the pair
# moves: amber already reads as amber to a dichromat, so HEALTH_AMBER and ACCENT
# stay put and the health dot stays three-state (blue / amber / orange).
# ALL # WORKING — Erdem's F5 seals the hues.
const POSITIVE_CB := Color(0.337, 0.706, 0.914, 1)        # #56B4E9 · blue
const POSITIVE_BG_CB := Color(0.337, 0.706, 0.914, 0.08)  # rgba(86,180,233,.08)
const POSITIVE_RULE_CB := Color(0.337, 0.706, 0.914, 0.35)
const NEGATIVE_CB := Color(0.902, 0.624, 0.0, 1)          # #E69F00 · orange
const NEGATIVE_BG_CB := Color(0.902, 0.624, 0.0, 0.08)    # rgba(230,159,0,.08)
const NEGATIVE_RULE_CB := Color(0.902, 0.624, 0.0, 0.35)
const POSITIVE_BRIGHT_CB := Color(0.337, 0.706, 0.914, 1) # same value on dark
const NEGATIVE_BRIGHT_CB := Color(0.902, 0.624, 0.0, 1)   # same value on dark
const HEALTH_GREEN_CB := Color(0.337, 0.706, 0.914, 1)    # #56B4E9 · status dot (blue twin)
const DOT_IDLE := Color(0.350, 0.320, 0.270, 1)          # #595245 · unreached phase dot
# Ürün ekseni üçlüsü KATEGORİKTİR (İnovasyon/Kararlılık/Deneyim), ama iki üyesi
# semantik token'lardan besleniyor (innovation=ACCENT_DEEP, stability=positive()).
# Renk körü paletinde positive() maviye döndüğünde Kararlılık ile Deneyim aynı
# legend'da ayırt edilemezdi; Deneyim'in bu yüzden kendi CB ikizi var
# (varsayılan: kehribar / yeşil / mavi · CB: kehribar / mavi / mor).
const AXIS_EXPERIENCE := Color("#5B8FF9")                # ürün ekseni "Deneyim"
const AXIS_EXPERIENCE_CB := Color("#B07AD6")             # CB "Deneyim" — mor

# --- BADGE / CHIP ---
const BADGE_BG := Color(1.0, 0.627, 0.157, 1)            # #FFA028 · rail count badge (amber pill)
const BADGE_FG := Color(0.043, 0.055, 0.067, 1)          # #0B0E11 · text on the amber badge
const NEUTRAL_BADGE_BG := Color(0.059, 0.078, 0.102, 1)  # #0F141A · neutral chip plate
const NEUTRAL_BADGE_FG := Color(0.624, 0.690, 0.749, 1)  # #9FB0BF · neutral chip text
const TAB_ACTIVE_BG := Color(0.063, 0.086, 0.110, 1)     # #10161C · active rail item fill

# --- EDGE · borders, dividers, hairlines ---
const CARD_BORDER := Color(0.137, 0.173, 0.204, 1)       # #232C34 · 1px card border
const BORDER_HOVER := Color(0.165, 0.204, 0.239, 1)      # #2A343D · hover/ghost edge
const CARD_ATTENTION_BORDER := Color(1.0, 0.361, 0.286, 0.45)  # attention-strip edge
const BORDER_DISABLED := Color(0.165, 0.204, 0.239, 1)   # #2A343D · disabled control edge
const BORDER_DASHED := Color(0.149, 0.188, 0.227, 1)     # #26303A · empty-slot edge
## KARAR VEREN ama nötr kalan bir kontrolün kenarı: aynı satırda DEVRALAN kutunun
## sönük kenarından ayrılsın diye BORDER_HOVER'dan bir adım açık. Runtime token.
const BORDER_STEPPER_OWN := Color(0.231, 0.275, 0.314, 1)  # #3B4650 · karar veren nötr kutu
const DIVIDER_LIGHT := Color(0.118, 0.149, 0.180, 1)     # #1E262E · in-card hairline
const SEPARATOR := Color(0.106, 0.137, 0.169, 1)         # #1B232B · chrome hairline

# --- VEIL · translucent whites on dark chrome ---
const VEIL_FAINT := Color(1, 1, 1, 0.03)    # at-rest / disabled tint
const VEIL_SOFT := Color(1, 1, 1, 0.06)     # normal / pressed
const VEIL_STRONG := Color(1, 1, 1, 0.10)   # hover

# --- Cinematic dialogue register (MeetingScene) ---
# Text on these surfaces uses CREAM* / *_BRIGHT. # WORKING — Erdem's F5 seals.
const SCRIM_MODAL := Color(0.020, 0.027, 0.035, 0.62)  # rgba(5,7,9,.62) · modal dimmer
const SCRIM_ROOM := Color(0, 0, 0, 0.18)              # readability scrim over full-bleed room art
const STAT_STRIP_BG := Color(0.027, 0.035, 0.043, 0.72)  # translucent stat band over art
const DIALOGUE_BG := Color(0.063, 0.086, 0.110, 1)   # #10161C · modal / Frank card ground
const DIALOGUE_COLUMN_BG := Color(0.063, 0.086, 0.110, 0.92)  # floating column (art shows through)
const DIALOGUE_CARD_BG := Color(0.059, 0.078, 0.102, 1)       # #0F141A · choice / quote card (recessed)
const DIALOGUE_CARD_BORDER := Color(0.137, 0.173, 0.204, 1)   # #232C34 · card hairline
const CONVICTION_TRACK_BG := Color(0.137, 0.173, 0.204, 1)    # #232C34 · İKNA gauge groove
const PORTRAIT_FRAME := Color(0.910, 0.929, 0.949, 1)         # #E8EDF2 · portrait rule

# --- Newspaper ending register ("Ekonomi Postası") ---
# DELIBERATE LIGHT ISLAND: the paper stays cream newsprint inside the dark screen,
# so it carries its OWN ink ladder (INK is light and would print white on cream).
# # WORKING — Erdem's F5 seals the final hues.
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

# --- ODA merkez görünümü (masa POV oda sahnesi) ---
# Gece tint'i obje sprite'larına MULTIPLY biner (objeler gündüz-nötr boyandı).
# Değer ölçümdür: monitör katmanının gece/gündüz render'ları paylaşılan opak maske
# üzerinde kanal kanal bölündü, yani ılık tungsten gece rig'inin bu objeye yaptığı
# şeyin kendisi. Hepsi < 1 olduğu için multiply ile temsil edilebiliyor ve monitörün
# ayrı bir gece katmanına gerek kalmıyor. # WORKING — Erdem'in F5 gözü mühürler.
const ODA_NIGHT_TINT := Color(0.906, 0.783, 0.621, 1)   # gece: obje sprite'larına ılık multiply
# Dört-durum ışık makinesi: GÜNDÜZ nötr (WHITE) · AKŞAM 18 ılık · GECE 19-05 (sahne
# çifti + ODA_NIGHT_TINT) · ŞAFAK 06 serin. Tint yalnız durum sınırında tween'lenir.
# Gece ılık olduğu için şafak odanın tek serin durumudur.
const ODA_TINT_EVENING := Color(1.0, 0.93, 0.84, 1)  # AKŞAM saati (belirgin ılık tek vuruş)
const ODA_TINT_DAWN := Color(0.92, 0.95, 1.0, 1)     # ŞAFAK saati (belirgin serin tek vuruş)
# ODA'nın kendi register'ı var: bu üçü paylaşılan ACCENT'i izlemez, yoksa oda ışığı
# her reskin'le sessizce kayar.
const ODA_RIM_GLOW := Color(0.886, 0.639, 0.235, 0.55)          # hover rim shader uniform'u
const ODA_SCREEN_GLOW := Color(0.886, 0.639, 0.235, 0.30)       # gece monitör panelinin gölge-glow'u
const ODA_ANCHOR_GLOW_SHADOW := Color(0.886, 0.639, 0.235, 0.35) # boyalı çapa hover/tur glow gölgesi

# --- ODA DONDURULMUŞ RENK REGISTER'I ---
# ODA'nın teması `themes/oda_frozen_theme.tres` ile dondurulmuş, ama oda_view.gd bazı
# renkleri doğrudan token'dan okuyup override / runtime StyleBoxFlat olarak basıyor.
# Kanonik adlar (ACCENT, INK, CREAM…) Terminal değerlerini taşıdığı için o okumalar
# buradaki dondurulmuş ikizlerden yapılır. Kanıt: --theme-audit=oda dökümü, sayaçlar
# normalize edildikten sonra bayt-aynı kalır.
const ODA_ACCENT := Color(0.886, 0.639, 0.235, 1)       # #e2a33c
const ODA_ACCENT_DEEP := Color(0.541, 0.353, 0.071, 1)  # #8a5a12
const ODA_INK := Color(0.169, 0.149, 0.125, 1)          # #2b2620
const ODA_INK_MUTED := Color(0.431, 0.400, 0.337, 1)    # #6e6656
const ODA_INK_DIM := Color(0.576, 0.545, 0.471, 1)      # #938b78
const ODA_CREAM := Color(0.941, 0.918, 0.851, 1)        # #f0ead9
const ODA_BADGE_BG := Color(0.620, 0.169, 0.145, 1)     # #9e2b25
const ODA_HEALTH_AMBER := Color(0.788, 0.588, 0.180, 1) # #c9962e
const ODA_SCRIM := Color(0, 0, 0, 0.55)                 # tur karartması
# Sağlık noktası ODA'da da renk körü moduna uyar: dondurulan şey varsayılan paletteki
# piksel, erişilebilirlik davranışı değil.
const ODA_HEALTH_GREEN := Color(0.369, 0.541, 0.275, 1)     # #5e8a46
const ODA_HEALTH_GREEN_CB := Color(0.184, 0.475, 0.671, 1)  # #3079ab

# ============================================================================
# TYPE SCALE — the ONLY sizes new UI may reach for.
# ============================================================================
# The SCALE owns size and leading; the VARIATION owns face and colour. Label
# variations differ by register, not by size, so a scale that also owned the
# typeface would stop being a scale. A variation MAY choose another face but may
# NEVER override its step's size. Mockup half-steps (8.5 / 9.5 / 10.5 …) are
# rounded half-up; the ordering survives the rounding.
#
#   token         px   voice (measured site)
#   SIZE_MICRO     9   chip 8.5, phase caption 9
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
# Typographic set pieces composed against a fixed page, not part of the reading
# rhythm. Any size above SIZE_DISPLAY must be named here.
const SIZE_ED_MODAL := 24       # modal titles (event · Atlas · month summary)
const SIZE_ED_CEREMONY := 26    # PAGE titles (Ekip / Portföy / Finans / Sales …); onboarding
const SIZE_ED_HEADLINE := 32    # newspaper headline; path-card display
const SIZE_ED_FIGURE := 44      # newspaper stat figures "$1.2M"
const SIZE_ED_MASTHEAD := 52    # "EKONOMİ POSTASI"

# --- Leading ---
# Label has no line_height: its line box is the font's ascent+descent plus the
# theme constant `line_spacing`; RichTextLabel uses `line_separation`. Both are
# pinned at the engine defaults so they cannot drift with Godot's default theme.
# Raising one changes the height of every wrapping Label — a layout change.
const LEADING_BODY := 3         # == engine default
const LEADING_RICH := 0         # RichTextLabel line_separation; == engine default

# Display sizes written in screen code that predate the scale are left in place;
# new code picks a scale step.

# ============================================================================
# SPACING + SHAPE
# ============================================================================
# 4-based; 6 is the one sanctioned half-step (dense data rows). Existing literals in
# scenes and scripts migrate only when the surrounding lines change.
const SPACE_XXS := 2
const SPACE_XS := 4
const SPACE_S := 6
const SPACE_M := 8
const SPACE_L := 12
const SPACE_XL := 16
const SPACE_XXL := 20
const SPACE_3XL := 24

# --- Corner radii ---
# Terminal uses radius 2 for everything that is not a pill; the named steps are
# kept so call sites keep reading their role. StyleBoxFlat clamps a radius to half
# the box, so RADIUS_PILL is a true circle or pill at any size.
const RADIUS_NONE := 0          # full-bleed chrome bands, rails, sunken tracks, focus killers
const RADIUS_XS := 2            # dots, cap bars
const RADIUS_S := 2             # chips, progress bars, speed buttons, sliders
const RADIUS_M := 2             # DEFAULT — cards, buttons, inputs
const RADIUS_L := 2             # modals, portrait cells
const RADIUS_XL := 2            # dialogue choice cards, tab badge
const RADIUS_XXL := 2           # dialogue column
const RADIUS_PILL := 999        # toggle, rail badge, avatar
const RADIUS_PORTRAIT := 2      # PortraitFrame
const RADIUS_CARD_LG := 2       # DialogueCard

# --- Border widths ---
const BORDER_HAIRLINE := 1      # cards, inputs, chips, tooltip
const BORDER_FOCUS := 2         # selection rings (SelectedBorder, PortraitCellSelected)
const BORDER_ACCENT := 3        # left accent bar (QuoteBox)

# --- StyleBox content-margin pairs (h, v) — build_theme.gd only ---
const PAD_CHIP := Vector2i(6, 2)          # UiFactory chip
const PAD_BTN_XS := Vector2i(8, 3)        # SpeedButton
const PAD_BTN_S := Vector2i(10, 4)        # DialogueStepper
const PAD_BTN_GHOST := Vector2i(10, 5)    # DialogueGhost / ChromeGhost
const PAD_INPUT := Vector2i(10, 6)        # LineEdit
const PAD_BTN := Vector2i(12, 6)          # base Button
const PAD_CHOICE := Vector2i(12, 8)       # ChoiceCard family
const PAD_INPUT_LG := Vector2i(12, 9)     # DialogueInput (ceremony-scale field)
const PAD_CARD_TIGHT := Vector2i(10, 8)   # CardPanelTight
const PAD_CARD := Vector2i(12, 10)        # CardPanel / CardCta / CardAttention
const PAD_STRIP := Vector2i(12, 6)        # StatStrip (same value as PAD_BTN, kept apart by role)
const PAD_BAND := Vector2i(14, 8)         # AttentionStrip
const PAD_ROW := Vector2i(14, 10)         # QuoteBox / DialogueChoice
const PAD_CARD_RAIL := Vector2i(14, 12)   # RailCard
const PAD_CTA := Vector2i(16, 10)         # CommitButton
const PAD_TOOLTIP := Vector2i(8, 4)       # tooltip panel
const PAD_RAIL := Vector2i(20, 20)        # RailPanel
const PAD_PAGE := Vector2i(28, 22)        # ModalCard
const PAD_SHEET := Vector2i(44, 36)       # PaperPanel
const PAD_FRAME := Vector2i(4, 4)         # PortraitFrame hairline inset
const PAD_CELL := Vector2i(3, 3)          # PortraitCell

# --- Rail tabs — canonical 8-tab list ---
# No `label` field: the rail caption is the key TAB_ + ID.to_upper(), shared by
# LeftTabs.tscn and center_viewport. LeftTabs.tscn's button order must match this
# array position-for-position (smoke `rail_tabs_match_scene_order`).
# `lock` names a gate for a visible-but-unreachable tab, resolved in
# LeftTabs._is_locked so UiTokens stays free of game state. The rail shows it
# dimmed with a YAKINDA pill. "ea" = Early Access scope, never opens in the demo;
# YAKINDA means only "not in this build", so Ar-Ge (built, gated on its own page)
# carries no lock.
const TABS := [
	{"id": "product", "icon": "res://assets/icons/tabs/product.svg"},
	{"id": "sales", "icon": "res://assets/icons/tabs/sales.svg"},
	{"id": "hr", "icon": "res://assets/icons/tabs/hr.svg"},
	{"id": "finance", "icon": "res://assets/icons/tabs/finance.svg"},
	{"id": "personal", "icon": "res://assets/icons/tabs/personal.svg"},
	{"id": "marketing", "icon": "res://assets/icons/tabs/marketing.svg", "lock": "ea"},
	{"id": "rnd", "icon": "res://assets/icons/tabs/rnd.svg"},
	{"id": "events", "icon": "res://assets/icons/tabs/events.svg"},
]

# ============================================================================
# SEMANTIC PALETTE SWITCH — the accessibility swap (Settings > Erişilebilirlik).
# ============================================================================
# Semantic colour is never baked into master_theme.tres, so switching palettes is
# a pure runtime re-read. Read semantic colour through the ACCESSOR
# (`UiTokens.positive()`), never the const: a site that reaches for the const is
# invisible to the toggle. Live surfaces repaint on EventBus.palette_changed.
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

## Çip kenarları da semantiktir: dolgu takas olup kenar sabit kalsaydı renk körü
## modunda çip iki paletten karışık okunurdu.
static func positive_rule() -> Color:
	return POSITIVE_RULE_CB if _cb_palette else POSITIVE_RULE

static func negative_rule() -> Color:
	return NEGATIVE_RULE_CB if _cb_palette else NEGATIVE_RULE

## ODA'nın dondurulmuş sağlık yeşili: health_green() ile aynı CB davranışı,
## varsayılan pikseli ODA register'ına pinli.
static func oda_health_green() -> Color:
	return ODA_HEALTH_GREEN_CB if _cb_palette else ODA_HEALTH_GREEN

## Ürün ekseni "Deneyim" (bkz. AXIS_EXPERIENCE_CB).
static func axis_experience() -> Color:
	return AXIS_EXPERIENCE_CB if _cb_palette else AXIS_EXPERIENCE

# ============================================================================
# Runtime colour-decision helpers — the single home for sign/kind → colour.
# All route through the accessors, so they inherit the palette swap.
# ============================================================================

## Delta color for body surfaces.
static func delta_color(value: int) -> Color:
	if value > 0: return positive()
	if value < 0: return negative()
	return INK_MUTED

## Delta color for the dark chrome (top-bar metric deltas).
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
		&"warn": return HEALTH_AMBER   # amber is already colourblind-safe
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


# Formatting delegates kept for their existing call sites; the bodies live in Fmt,
# which owns the locale's separators. New code may call Fmt directly.
static func format_money(amount: int) -> String:
	return Fmt.money(amount)


## TopBar finance-chip format: abbreviated so MRR/BURN/NET cannot widen FinanceGroup.
## Its thresholds deliberately diverge from format_money.
static func format_money_chip(value: int) -> String:
	return Fmt.money_chip(value)


## Exact, thousands-grouped money. CASH is shown in full because money management is precise.
static func format_money_exact(value: int) -> String:
	return Fmt.money_exact(value)


## Locale-aware uppercase: the Turkish i→İ rule applies only under Turkish.
static func tr_upper(s: String) -> String:
	return Fmt.upper(s)


## Net-runway display parts {value, unit, positive, note} — the single home for the
## months-vs-status decision (TopBar, Finance tab, HR previews, month-end summary).
## Uses TranslationServer because statics can't call tr(). `positive` lets a caller
## colour the status green; `note` explains why no month figure is shown.
static func net_runway_parts(months: float) -> Dictionary:
	# Empty treasury first: runway_months_for() answers INF for any non-negative daily
	# net without looking at cash, so a company at cash < 0 would otherwise be painted
	# a green "Artıda" next to a red bankruptcy countdown.
	if GameState.cash < 0:
		return {"value": "0", "unit": TranslationServer.translate("RUNWAY_UNIT_DAYS"),
				"positive": false, "note": ""}
	if months == INF:
		return {"value": TranslationServer.translate("RUNWAY_PROFITABLE"), "unit": "",
				"positive": true, "note": TranslationServer.translate("RUNWAY_PROFITABLE_NOTE")}
	if months < 1.0:
		# Under a month a bare "0 ay" reads as insolvency; say it in days. floor(), not
		# round(): a countdown must never promise a day the cash cannot cover.
		return {"value": str(int(floor(months * GameState.DAYS_PER_MONTH))),
				"unit": TranslationServer.translate("RUNWAY_UNIT_DAYS"),
				"positive": false, "note": ""}
	return {"value": str(int(round(months))), "unit": TranslationServer.translate("RUNWAY_UNIT_MONTHS"),
			"positive": false, "note": ""}


static func net_runway_text(months: float) -> String:
	var p: Dictionary = net_runway_parts(months)
	return String(p.value) if String(p.unit) == "" else "%s %s" % [p.value, p.unit]


## İki runway değeri yan yana ("önce → sonra" şeritleri). net_runway_text tam aya
## yuvarlar; iki sayı yan yana konduğunda bu, kırmızı bir kutuda "5 ay → 5 ay" yazan bir
## yalan üretir. İki metin aynı çıkıp düşüş gerçekten anlamlıysa ikisi de GÜN'de yazılır.
## `changed` yalnız sonlu sayılarda ve epsilon'lu karar verir: INF→INF kırmızıya boyanmaz,
## kayan-nokta gürültüsü düşüş sayılmaz.
const RUNWAY_PAIR_EPSILON := 0.05


static func net_runway_pair(before: float, after: float) -> Dictionary:
	var before_text: String = net_runway_text(before)
	var after_text: String = net_runway_text(after)
	var worse: bool = is_finite(before) and is_finite(after) \
			and (before - after) > RUNWAY_PAIR_EPSILON
	if worse and before_text == after_text and GameState.cash >= 0:
		before_text = _runway_days_text(before)
		after_text = _runway_days_text(after)
	return {"before": before_text, "after": after_text, "changed": worse}


static func _runway_days_text(months: float) -> String:
	# floor(): net_runway_parts'ın ay-altı dalıyla aynı gerekçe.
	return "%d %s" % [int(floor(maxf(months, 0.0) * GameState.DAYS_PER_MONTH)),
		TranslationServer.translate("RUNWAY_UNIT_DAYS")]


## Build progress (0.0-1.0) as the whole percent every surface prints — the single
## home for that rounding, so the portfolio badge and the floating build card never
## disagree in one frame. Bars take build_percent(p) / 100.0, never the raw fraction.
static func build_percent(progress: float) -> int:
	return int(round(clampf(progress, 0.0, 1.0) * 100.0))
