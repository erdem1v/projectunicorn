# Project Unicorn — Agent Session Entry Point

## Project Summary

Project Unicorn is a narrative-strategy startup simulator built in Godot 4 + GDScript. The player
founds a tech startup and plays it from a solo founder's room toward a Series A — managing
Product, Team, R&D, Sales, Finance and Funding while answering reactive events and cinematic
moments (sales meetings, VC pitches, term-sheet tables). The run is goal-terminated with a
730-day soft cap. Tone and depth comparable to CK3 / Frostpunk / Disco Elysium, transposed to a
2020s tech setting. Target platform Steam, TR + EN.

## Design authority (2026-09 — director ruling)

**The GDDs in `GDDs/` are the reference for every design question.** Where this file, an older
spec or an audit disagrees with a GDD, the GDD wins. The chapter set:

- `GDDs/GDD v2 — 01 … 14` (.docx) — the run, founder & people, product lifecycle, operations,
  finance, funding, rivals & world, events & narrative (ch11), UI & ODA, endings, scope (ch14).
- Module GDDs (.docx, rebuilt modules): Ekip (rev 11), Ürün (rev 6.1), Ar-Ge, Satış (rev 6).
- `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` — the event engine's only authority.

`docs/PROJECT_SPEC.md`, `docs/ENDGAME_DESIGN.md`, `docs/VC_PITCH_DESIGN.md` and
`docs/design/EVENT_POOL_DESIGN_v1.md` are **historical**: each carries a "superseded" header and is
kept because audits link to it. Do not design from them. When two GDD chapters disagree with
each other, stop and ask — do not pick one silently.

---

## Governing Design Principles

Before reading the rest of this document or any spec, internalize these principles. They are the design DNA of Project Unicorn and override any specific spec or instruction if a conflict arises.

1. **Project Unicorn is "Software Inc., but the founders are people."** Strategy game, not tycoon. We take Software Inc.'s product development backbone (iteration → development → polish, quality from process, ship trade-offs) and adapt each step as event-driven narrative decisions. Disco Elysium voice + CK3 character weight + Frostpunk pressure layer on top.

2. **Every economic outcome comes from a played decision moment.** No auto-revenue, no auto-progress, no system-event-as-economic-delta. If a change would touch cash, MRR, brand, reputation, customer count, or any other economic field, ask: "what specific player decision earned this?" If no decision moment exists upstream of the delta, no delta. Flag the question rather than introducing auto-progress silently.

   *Revision note (Economy Model v2): B2C revenue is now **derived auto-flow** — MRR updates continuously (hourly) from the player-managed **audience + price** levers, not tycoon spontaneous income, and the audience is **bidirectional** so bad management still erodes it (MRR can fall; runway stays a threat). The principle's intent holds — every delta traces to a played lever — but the literal "no auto-revenue" is relaxed to "no auto-revenue **untethered from player levers**." B2B stays pitch-driven. See GDD v2 ch08 (Finance & Economy).*

3. **Micro-to-macro player evolution is the killer differentiator.** Same player, evolving interaction grammar as the company scales across the three release tiers. Tier 1 = micromanage. Tier 2 = delegate, set policy, intervene on exceptions. Tier 3 = macro decisions only. Plan all Tier 1 systems with Tier 2/3 in mind even when shipping Tier 1 alone — data shapes, save schemas, and event vocabularies should anticipate the trillion-dollar version.

4. **Narrative-strategy means decision over optimization.** When in doubt between a path that creates a story moment and a path that adds a stat, favor the story moment. Numbers serve narrative weight, not the other way around.

5. **Reference points.** When making design judgment calls, anchor on Crusader Kings III (character-driven decisions, event-rich), Frostpunk (recoverable pressure, moral weight, atmosphere of constraint), Disco Elysium (interior life, dialogue as gameplay), Football Manager (readable dense UI, sim depth without action), Software Inc. (product development mechanics adapted from their proven backbone). The first four define our voice; the fifth defines our system reference.

These principles are non-negotiable for design decisions. Implementation can flex; design DNA cannot.

---
## CALIBRATION LAWS (genre research July 2026 — design principles, not numbers)

Genre research across Game Dev Tycoon, Software Inc and Suzerain (90%+) against Startup Company,
The Meter is Running and This Is the President (68-80%) produced five laws. They bind design
decisions; the numbers behind them live in the GDDs and in single tuning surfaces in code.

1. **Money must never stop mattering.** Every phase re-tightens the runway, and the rising bar is
   legible — never an opaque hidden score.
2. **Match run length to content depth; kill dead time.** No stretch of play runs >60-90 seconds
   without a meaningful decision. The speed ladder is 1×/2×/3× (`TimeManager.SECONDS_PER_DAY`).
3. **Choices must visibly change game state.** Every major outcome is traceable to visible state.
4. **Systems must be load-bearing.** A subsystem the player can ignore and still win is either
   integrated (its neglect cascades) or cut.
5. **Replayability is structural, not padding.**

Measurement: `--run-log=<preset>:<days>:sim[:<seed>]` drives a whole run headless. The
`full_run` presets (`full_run`, `full_run_naive`, `full_run_discount`) play the line-model erp
product with a staffing ladder, capacity, fix passes, research and morale care — see
`docs/reports/EVENT_REVISION_2026-09.md` for what they measure and why the old probe could not.

---

## Content & Language Laws (LOCKED — Editorial Package 4, 2026-07-14 · Bilingual Birth 2026-08-08)

These govern all player-facing text and event authoring. They are enforcement rules, not suggestions.

**AUTHORING ORDER FOR AGENTS (director ruling 2026-09-25 — REPLACES the earlier "English first"
ruling).** Turkish is canonical: agents write every player-facing line in **Turkish first**. The
English is **not a translation** of the Turkish sentence; it is a separate localisation of the same
scene, written as natural English. Erdem edits both. The two locales still ship in the same commit
(Bilingual Birth below). Frank's corpus is Erdem's own: agents may only propose Frank lines as
drafts, and a draft does not reach the screen without his approval.

**HANDOFF RULES (director ruling 2026-09-25).**
- `main` is pushed ONLY when Erdem says **"push et"**.
- Any change to a design constant (tuning values, thresholds, the eagerness model, gate or meeting
  weights) is listed in the agent's report under **"onay bekliyor"** (awaiting approval).
- Live handoff state for the Series A work: `docs/handoff/HANDOFF_series_a.md`.

**LANGUAGE INTEGRITY LAW.** Turkish is canonical; English is a localisation written in English (not a sentence-by-sentence translation), delivered via the localization layer (`localization/strings.csv`, parsed at runtime by the `Localization` autoload into Godot's `TranslationServer`; language toggle in Settings — Package 5). **No MIXED TR/EN inside a single player-facing string** (that original intent stands) — full-language EN via the locale switch is correct. Within the Turkish canonical text, English tech terms appear only where they are genuine Turkish-tech loanwords founders actually say — the ruled accepted set is: `pitch, startup, demo, momentum, MRR, runway, churn, burn` (`burn` added by gate ruling 2026-08-08; plus proper nouns and the established loanwords `laptop, mail, VC`). Everything else translates to its clean Turkish form (e.g. bug→hata, feature→özellik, feedback→geri bildirim, roadmap→yol haritası, deadline→son tarih, build→geliştirme, push→gönder/yayınla, launch→çıkış/lansman). English lives only in code and specs, never on screen.

**BILINGUAL BIRTH LAW.** Every player-visible string is born as a localization key with **both TR and EN
filled in the same commit** — TR canonical, EN written natively (never machine-translation register), the
glossary (`docs/design/localization_glossary.md`) binding on every term it rules. No player-visible literal
lives in a script or scene: static scene text carries the KEY itself (auto-translate renders it — probe-verified);
composed text goes through `tr(KEY).format({...})` with **named placeholders only** — positional `%s`/`%d`
are banned from player-visible strings, an interpolated value never takes a suffix or grammatical agreement
(restructure the sentence: `Sözleşme: {company}`, never `{company}'nin sözleşmesi`), and no literal braces in
CSV values. Proper nouns do not localize. Localized text is never written into state — store ids, render at
display time. A task that adds a player-visible string without both locales is **incomplete — reviewers reject
it**; agent done-messages list every key they added. Event cards carry a `text.tr` and a `text.en` block with identical id sets (engine GDD §3.2,
lint §17.8); each value is a CSV key or inline prose. A card without both blocks is not done.
**Proof is a command, not a claim:** `loc_residue.gd` exits zero, `loc_csv_integrity` passes, and both stay
green in every commit that touches strings.

**EVENT AUTHORING LAW.** No fake choices. No choice pre-labels its own wisdom (don't tell the player which path is "mantıklı"/"pratik"/right). Effects are shown in readable Turkish, never as internal codes. No event implies an unbuilt system. Time-of-day fiction must match a real firing window — or omit the clock entirely (deterministic beats fire at the day boundary, so they must not assert a specific `· HH:MM`). NPC register stays short and dry; monologue stays coherent. Never name an internal UI node or tab in fiction — a mentor guides as a person ("satış tarafına bak"), not as a UI manual ("Sales sekmesine tıkla").

**EFFECT-VISIBILITY RULE.** Modifiers are shown to the player in readable Turkish labels via `event_modal._describe_modifier` (`scripts/modals/event_modal.gd`), never as internal codes. It is the single place effect badges are built. For choices carrying 2+ effects, prefer a future hover/tooltip reveal over cramming inline (EU4/CK3 grammar) — the tooltip pattern is a pending follow-up (badge chips currently use `mouse_filter = MOUSE_FILTER_IGNORE`).

---

## State Coherence — WRITE-THROUGH LAW (LOCKED — 2026-07-14)

No event, modal, or UI may mutate another domain's state directly. Every domain change goes
through the owning system's **seam** — a method on the system that owns that state — and the
seam **emits a signal** wherever the UI reacts to it. If a needed seam doesn't exist, **build
it**; never write the field directly "just this once." And **every event choice's narrative
claim must match its modifiers** — if the copy says "koltuk ekle," the modifiers add seats.

Owning seams (write through these, never the raw field):
- Customers → `CustomerRegistry.set_mrr / set_seats / set_satisfaction / add / remove` (each emits).
- Aggregate MRR → `SalesSystem.reflect_mrr()` (the single customer-MRR→GameState bridge).
- Cash / brand / reputation / burn / phase → `GameState.set_*` setters.
- Characters → `CharacterRegistry.*`. Product / build → `ProductSystem.*`.

**Worked cautionary example (the disease this law cures).** An event titled *"Koltuk artırımı"*
promised the customer more seats, but its modifier only bumped MRR by a flat number — the seat
count never moved, because **no seat seam existed** and the code poked the field (or a cached
mirror) directly. The fix was not to poke harder; it was to build `CustomerRegistry.set_seats`
(emitting `customer_seats_changed`) and route a `seats` modifier through it, so the seat display
finally moves and the fiction matches the state. Raw cross-domain writes also create **stale
mirrors** — e.g. a raw `mrr` write is silently reverted by the next MRR-bridge tick — another
reason the seam, not the field, is the only sanctioned write. Future specs must name their
seams; future events must match claims to modifiers.

---

## UI / STYLE LAW (LOCKED — Tema Çekirdeği 2026-08-06 · Terminal reskin 2026-08-08)

Görsel kimliğin tek kaynağı vardır ve mülkiyet dörde bölünmüştür. Bu hükümler
`scripts/theme/ui_tokens.gd` başlığındaki OWNERSHIP bloğunun yasalaşmış halidir.

**1. Vokabüler `UiTokens`'ındır.** Oyundaki her renk `ui_tokens.gd` palet tablosunda adlıdır;
her yazı boyutu TERMINAL MERDİVENİNDEN — `SIZE_MICRO 9 · SIZE_META 10 · SIZE_SMALL 11 ·
SIZE_DATA 12 · SIZE_BODY 13 · SIZE_LEAD 15 · SIZE_TITLE 16 · SIZE_DISPLAY 22` — ya da belgeli
editorial-display istisnasından (`SIZE_ED_MODAL 24 · SIZE_ED_CEREMONY 26 · SIZE_ED_HEADLINE 32 ·
SIZE_ED_FIGURE 44 · SIZE_ED_MASTHEAD 52`) gelir. Merdiven Terminal reskin'inde 6 adımdan 8'e
çıktı: onaylı mockup'lar yarım adımlarla (9,5 / 10,5 / 11,5) çizildi, Godot'un tam sayı font
boyutu bunu taşıyamıyor, YUKARI YUVARLANDI ve sıralamanın korunduğu ölçüldü. Palet tablosu dışına ham `Color(...)`,
skala dışına ham font boyutu YAZILMAZ. Runtime/state'e bağlı stil `UiTokens` helper'larından
okunur (`delta_color`, `badge_palette`, `health_color`, …) — sign→renk mantığı bir daha
icat edilmez.

**2. `themes/master_theme.tres` ÜRETİLMİŞ artefakttır — elle düzenlenmez.** Üretici:
`godot --headless --path . -s res://scripts/theme/build_theme.gd`
(temiz checkout önce `--import` ister). Token ya da `build_theme.gd` değişikliği AYNI
commit'te `UiTokens.THEME_STAMP`'i artırır ve regen koşar; `main.gd` debug boot'ta bayat
`.tres`'e `push_warning` ile bağırır.

**2b. `themes/oda_frozen_theme.tres` DONDURULMUŞ artefakttır — YENİDEN ÜRETİLMEZ.**
Terminal reskin'i (2026-08-08) ODA'yı kendi temasına aldı: dosya, reskin'den HEMEN ÖNCE
`68ec579`'daki `master_theme.tres`'in birebir kopyasıdır ve `OdaView.tscn` ile `oda_tour.gd`
tarafından `theme` olarak takılır. Godot temayı en yakın ata `theme`'inden çözer, yani bu tek
özellik bütün ODA alt ağacını yalıtır. Sebep ölçümdü: ODA 15 PAYLAŞILAN varyasyon
(`MicroLabel` ×8, `NewsMeta` ×5, `ChromeBadgeLabel` ×3, `ChromeChip`, `RowMeta`,
`MetricValueInk`, `BodySerif`, `QuoteSerif`, `EngravingFrame`, `DialogueName`, `ChromeSerif`,
`ChromeButton`, `ChromeGhost`, `BuildProgress`, `OdaTourCard`) ve 11 paylaşılan token okuyordu;
"token'ları boya, ODA'ya dokunma" mümkün DEĞİLDİ. ODA'nın doğrudan okuduğu renkler ayrıca
`UiTokens`'ın `ODA_*` DONDURULMUŞ REGISTER'ına pinlendi. Bir sonraki ODA tasarım turu bu
dosyayı emekliye ayırana kadar: **kopyalanmaz, düzenlenmez, regen edilmez.**

MÜHÜRLÜ SANAT TURU (2026-08-17) — UNFREEZE GEREKMEDİ. Görev şartnamesi "yaptırımlı
unfreeze" öngörüyordu; ölçüm gerekmediğini gösterdi. Plakalar ve katmanlar değişti,
`REGIONS`/`RECTS`/cam sabitleri yeniden türetildi, `monitor_night` emekli edildi, hover
rim'i yeniden ayarlandı — ve `--theme-audit=oda` **121 satırda BAYT-AYNI** kaldı. Sebep
yapısal: bu turun dokunduğu her şey DOKU, KOORDİNAT ya da `ODA_*` register'ıdır; hiçbiri
tema öğesi değil. Dolayısıyla dosya donmuş kalır.

**GÖMÜLÜ DAMGA 5'TE DONDURULMUŞTUR VE ARA AÇILMASI BEKLENEN DAVRANIŞTIR.** Bu satır uzun
süre "`UiTokens.THEME_STAMP` 6'nın BİR GERİSİ" diyordu; o cümle yazıldığı gün (2026-08-17)
doğruydu ve THEME_STAMP 7'ye çıktığında (2026-08-24, `9a8ecb5`) sessizce YANLIŞ oldu — bugün
5, 7'nin İKİ gerisinde. Sayı bir ilişki DEĞİL: madde 2b dosyanın asla regen edilmemesini
söylüyor, o yüzden gömülü damga 5'te KALIR ve her THEME_STAMP artışında ara bir birim daha
açılır. **Bu arayı KAPATMAYA ÇALIŞMAK madde 2b'nin yasakladığı şeyin ta kendisidir:** damgayı
elle yükseltmek ya da dosyayı yeniden üretmek, "tutarlılık" adına donmuş artefaktı bozar.
Ara ne kadar büyürse büyüsün doğrudur; kapatılmaz.

ODA tint token'ları (`ODA_NIGHT_TINT`, `ODA_TINT_EVENING`, `ODA_TINT_DAWN`) yalnız
`oda_view.gd` tarafından runtime'da okunur; `build_theme.gd` bunlardan HİÇBİRİNİ okumaz
(yalnız `ODA_ANCHOR_GLOW_SHADOW`), o yüzden değerlerini değiştirmek `master_theme.tres`'i
etkilemez ve THEME_STAMP artırımı gerektirmez.

**3. `build_theme.gd`, token'ı tema öğesine çeviren TEK dosyadır.** Tema içinde: SKALA
boyut+leading'in sahibidir (bir varyasyon adımının boyutunu ASLA override etmez); VARYASYON
yüz+rengin sahibidir (register ekseni: açık gövde / koyu kabuk / sinematik / gazete).

**4. Sahneler ve script'ler yalnız YERLEŞİM'in sahibidir** (anchor, separation, margin,
min-size). Font boyutu, renk ya da stylebox taşımazlar — bir `theme_type_variation`'a uzanır
ya da bir yenisini `build_theme.gd`'ye eklerler. Mevcut literaller GRANDFATHERED'dır: çevresi
değişen satırla birlikte taşınır (TECH_SPEC Decision Log'un inline-Color konvansiyonu).
Envanter ve bilinçli istisnalar: `docs/design/theme_sweep_ledger.md`.

**Chrome kuralı (ODA rework ile revize 2026-08-06; Terminal reskin ile daraltıldı 2026-08-08).** `Chrome*` varyasyonları (koyu
kabuk ailesi) artık tanımlı-VE-YAŞAYAN'dır, ama yalnız şu yüzeylerde: **TopBar ·
MonthSummary bandı · sol sekme rayı (LeftTabs) · sayfa-üstü chrome şeridi
(TabPageChrome) · OdaView'un koyu bilgi yüzeyleri (monitör ekranı, mesai çipi vb.) ·
tooltip kabuğu.** Bu liste dışında `Chrome` deseni eşleşmesi = ihlal; listeye yeni
yüzey eklemek yine ayrı, gate'li bir karardır.

TERMINAL REVİZYONU (2026-08-08) İKİ MADDEYİ DEĞİŞTİRDİ:
· **"Sekme sayfa içeriği krem gövdede kalır" HÜKMÜ DÜŞTÜ.** Terminal'de krem gövde YOK;
  sayfa zemini `#0D1115`, kabuk `#07090B`. Kabuk ile gövde artık tek register'dır ve bu
  yüzden `CREAM == INK` (ikisi de `#E8EDF2`) — adlar çağrı yerleri için korundu.
· **OdaView bu listeden ÇIKTI.** ODA `Chrome*`'u artık `master_theme`'den DEĞİL, kendi
  dondurulmuş temasından çözüyor (madde 2b). Listedeki "OdaView koyu bilgi yüzeyleri"
  ifadesi tarihsel; ODA'nın Chrome tüketimi bu dosyayı ilgilendirmiyor.
· Krem KALAN tek ada gazetedir (`PaperPanel` + `PAPER_INK_*`) ve o bilinçli bir
  istisnadır (mockup 5l: "gazete diegetik kağıt olarak kaldı").
NewsTicker görsel kimliğini korur (`NewsPanel`/`NewsRich` kendi adlarıyla kalır).

**Doğrulama yüzeyleri** (debug build, main.gd): `--tab-shot=<id>` · `--modal-shot=<kind>` ·
`--onboard-shot=<1|2|3>` · `--probe-shot` (sıfır-stil kontrol sahnesi) ·
`--theme-audit=<id>` (çözümlenmiş tema değerleri + yüz + panel stylebox parmak izi +
S/C/P override bayrakları) · **`--theme-audit=oda` ODA'NIN KAPISIDIR**: yalnız OdaView alt
ağacını gezer, **147 `AUDIT|` satırı** (AUDIT_BEGIN/END dahil 149 satırlık blok) basar ve
öncesi/sonrası BAYT-AYNI çıkmak zorundadır. Sayının tarihi: 2026-08-10 sanat
migrasyonunda 120→121 (eklenen TEK satır `AUDIT|/ObjectLayer/Keyboard|TextureRect|--|…`,
tamamı tire — hiçbir tema değeri çözmüyor, sprite düğümünün yapısal eklenmesi), sonra
2026-08-17 F5 turunda 121→123 (pano hedef kartı diğer kartların register'ına alındı:
başlık HBox'ı + boşluk Control'ü eklendi), sonra 2026-08-18'de 123→122 (lamba halesi
`/FXLayer/LampGlow` kaldırıldı — siyah lamba gövdesini yarı saydam gösteriyordu).
Sonra 2026-08-19'da 122→**121**: Build Bar, monitörün iki runtime Panel'ini (track +
fill) tek `BuildBar` örneğiyle değiştirdi — iki düğüm gitti, biri geldi. Normalize
edilmiş diff YALNIZ `/InfoLayer/MonitorWrap/MonitorScreen` alt ağacındaydı.
Bu belge uzun süre "122 satır" diyordu; o sayı blok toplamıydı ve migrasyondan sonra
güncellenmemişti — bugün aynı sayıya BAŞKA bir sebeple geri gelindi, tesadüf.
**Sayının DEĞİŞMESİ tek başına ihlal değildir — ihlal, DEĞİŞMEMESİ gerekirken
değişmesidir.** Düğüm ekleyen bir yerleşim işi satır sayısını meşru biçimde artırır;
kanıt, otomatik `@Sınıf@NN` sayaçları normalize edildikten sonra diff'in YALNIZ hedeflenen
alt ağaçta kalmasıdır. F5 turunda ölçülen: `@…@NN`→`@…@N` normalizasyonundan sonra
GoalWrap dışında **0** satır değişti.

2026-08-21'de sayı **121 → 147**. Sebep yapısal ve beklenen: Build Bar bir ÇİZGİ-ÇUBUK
olmaktan çıkıp onaylı ÜÇ SATIRLIK KARTA dönüştü (R6: monitör aynı kartı alır,
varyantını değil). Eskiden `_draw` ile tek düğüm olarak çiziliyordu, şimdi gerçek
Control ağacı — kapak çizgisi, üç satır, dolgu, glifler. **Kanıt sayı değil DIFF:**
`@Sınıf@NN` normalizasyonundan sonra değişen her satır
`/InfoLayer/MonitorWrap/MonitorScreen` altında; o alt ağacın DIŞINDA **0** satır
kıpırdadı. `themes/oda_frozen_theme.tres` açılmadı, `master_theme.tres` regen sonrası
bayt-aynı kaldı ve THEME_STAMP 6'da durdu — kartın üç yeni rengi runtime token'ıdır,
`build_theme.gd` onları okumaz (ODA tint'lerinin precedent'i).
Piksel karşılaştırması ODA için kullanılamaz — ölçüldü: `--oda-shot` kareleri
`night/market1/market2/event/tab/tour` için iki değer arasında gidip geliyor (tween fazı /
kare yarışı), yani hash eşitsizliği tema değişikliğinin kanıtı DEĞİL. Tema
değişikliği iddiası bu yüzeylerin before/after'ıyla kanıtlanır — hash eşitliği "hiçbir şey
kımıldamadı"nın, bbox raporu "yalnız hedef kımıldadı"nın kanıtıdır.

---
## Document References

- **Design:** `GDDs/` (see Design authority above).
- **Technical constitution:** [`docs/TECH_SPEC.md`](docs/TECH_SPEC.md) — architecture, conventions, decisions.
- **Event engine:** [`GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`](GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md) — its §27 carries the build notes.
  - Read surface: [`docs/SEAM_REGISTRY.md`](docs/SEAM_REGISTRY.md) — every named query content may ask.
  - Write surface: [`docs/EVENT_SIGNAL_MANIFEST.md`](docs/EVENT_SIGNAL_MANIFEST.md) — **generated**, `python tools/gen_signal_manifest.py`.
  - Content design: GDD v2 ch11 (Events & Narrative) — arcs, cost law, voice.
- **Latest event/economy pass:** [`docs/reports/EVENT_REVISION_2026-09.md`](docs/reports/EVENT_REVISION_2026-09.md).

---
## Agentic Workflow Rule

At the start of every session, read this file, `docs/TECH_SPEC.md`, and the GDD chapter(s) the task
touches before writing gameplay code. If a GDD is missing, contradictory, or ambiguous on the point
at hand, **stop and ask** — never guess.

---

## DELIVERY LAW — ONE FOLDER, ONE BRANCH (LOCKED — director ruling 2026-08-20, TECH_SPEC §19.7)

Work lands in the working tree and Erdem looks at it. That is the whole review loop. It
replaces the branch-and-merge practice used through 2026-08-19, which left three finished
sessions outside the game Erdem was actually playing.

**1. One folder.** `Desktop/project steam` is the only checkout. **No git worktree is ever
created** — not for a spike, not for a baseline, not "temporarily". The 2026-08-19 recipe of
`git worktree add --detach` to re-take a theme baseline is **retired**: take the baseline dump
in this tree *before* you edit, which is what the ODA gate needs anyway.

**2. One branch.** All work is committed directly to `main`. **No feature branch, no merge
commit, no rebase.** The remote carries `main` and nothing else — GitHub exists so the work is
reachable from the laptop, not as a second build repository. Whatever is local is what is on
GitHub.

**3. If a branch or a second folder genuinely seems necessary, STOP AND ASK** — same grammar as
the spec rule above. Do not open one and report it afterwards.

**4. The review loop is two words.** The agent changes files; Erdem opens the game and looks.
**"Geri al"** → revert the change. **"Push et"** → push to GitHub. Nothing is pushed unasked,
and nothing waits on a branch for an approval that a revert would have handled.

**The observable, since a law needs one:** `git branch` prints exactly `* main`, `git worktree
list` prints exactly one line, and `git ls-remote --heads origin` prints exactly
`refs/heads/main`. If any of the three prints more, this law has been broken.

Per-commit discipline is unchanged and still applies: TR+EN strings born together,
`THEME_STAMP` bumped in the same commit as its token change, gates green before the commit
that claims them.

---

## Tech Stack (LOCKED — TECH_SPEC §2)

- **Engine:** Godot 4.x (latest stable; current `project.godot` config_version=5, features `4.6 Forward Plus`)
- **Language:** GDScript only (no C#, no visual scripting)
- **UI:** Control nodes + Scene hybrid (layout in `.tscn`, logic in `.gd` scripts attached to scenes)
- **State:** Autoload singletons + EventBus signal hub
  - Planned singletons: `GameState`, `CharacterRegistry`, `TimeManager`, `SaveManager`, `Settings`, `EventBus`. (`EventManager` was here and is gone: the event engine is a set of static classes behind the `EventGate` facade, not an autoload — nothing about it needs a node in the tree.)
- **Persistence:** JSON via FileAccess, schema-versioned, seeded RNG (deterministic replay)
- **Steam:** GodotSteam plugin — achievements, Cloud Save, Rich Presence; isolated behind `SaveManager` so dev runs work without Steam
- **Localization:** Godot CSV-based — TR canonical (written first), EN a localisation written in English

---

## Teaching Mode (ACTIVE — TECH_SPEC §3.2)

The developer is learning Godot. The agent owns Godot-side work fully but operates as a teacher, not a black box. For every meaningful operation or logical batch, the agent explains four things — concisely (2-4 sentences, batched):

1. **What** is being created or changed
2. **Why** this approach / node type / pattern was chosen
3. The underlying **Godot concept** (e.g. "Autoload singleton", "Control anchor", "scene instancing") with a one-line explanation
4. If there was a meaningful choice, what **alternatives** were considered and why this one won

---
## Scope Discipline

The agent stays within the GDDs. **It does not invent mechanics, content, or architecture.** If
something is underspecified, flag it; do not fill it independently. A [ÇALIŞMA]/[K] number in a
GDD is a working value that lives in one tuning constant and may be retuned by measurement.

---
## Current Project State

Built and playable: 13 game autoloads, the tab set, ODA, onboarding, save/load (schema v12,
`MIN_LOADABLE_VERSION` 10), the event engine behind `EventGate`, and a smoke suite
(`tools/smoke_run.sh --all`). Rebuilt against sealed GDDs: Ürün rev 6.1, Ekip rev 11, Satış rev 6,
the event engine, Ar-Ge, and the funding ladder (savings → Frank → seed → Series A).

The event engine in one paragraph: **one way in** (`EventGate.request(<card id>, <context>)`; a
system names a card, never builds one); **a card is a JSON file** (`data/events/cards/<category>/`);
**every read is a named seam** (`docs/SEAM_REGISTRY.md`); tools are `--event-lint`,
`--why-fire=<id>`, `--event-harness=random|guided`, `--event-probe`. No CI: every gate is run by
hand and must be green before the commit that claims it.
