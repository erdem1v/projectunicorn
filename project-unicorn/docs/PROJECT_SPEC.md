# Project Unicorn — Project Spec (Game Design Master)

Game design master document. Captures vision, mechanics, content, and systems extracted from the GDD. The agent reads this at the start of every session, alongside `TECH_SPEC.md`.

> **Source:** GDD mind-map (9 images) + Onboarding flow text provided by the designer.
> **Status:** Initial extraction. TBD sections are flagged inline and must be resolved by the designer before implementation.
> **Language:** Source content is mixed Turkish / English; this document preserves the source language for each section rather than translating.

---

## Table of Contents

1. [Vision & Design Pillars](#1-vision--design-pillars)
   - 1.5 [Tier Interaction Model](#15-tier-interaction-model)
2. [Difficulty Philosophy](#2-difficulty-philosophy)
   - 2.1 [Core Principle](#21-core-principle)
   - 2.2 [The Target — 70% Win Rate](#22-the-target--70-win-rate)
   - 2.3 [What Difficulty Is NOT](#23-what-difficulty-is-not)
   - 2.4 [What Difficulty IS](#24-what-difficulty-is)
   - 2.5 [The Model in Practice](#25-the-model-in-practice)
   - 2.6 [How Difficulty Is Built and Tuned](#26-how-difficulty-is-built-and-tuned)
   - 2.7 [Summary](#27-summary)
3. [Player Experience](#3-player-experience)
   - 3.1 [Onboarding](#31-onboarding)
   - 3.2 [Core Loop](#32-core-loop)
   - 3.3 [Session Flow](#33-session-flow)
   - 3.4 [Kazanma Koşulları (Win Conditions)](#34-kazanma-koşulları-win-conditions)
   - 3.5 [Kaybetme Koşulları (Lose Conditions)](#35-kaybetme-koşulları-lose-conditions)
   - 3.6 [Bitiş Senaryoları (Ending Scenarios)](#36-bitiş-senaryoları-ending-scenarios)
4. [Character & Setup](#4-character--setup)
   - 4.1 [Karakter Orijinleri (Origins)](#41-karakter-orijinleri-origins)
   - 4.2 [Trait Havuzu](#42-trait-havuzu)
   - 4.3 [Skill Points](#43-skill-points)
   - 4.4 [Subgenre](#44-subgenre)
   - 4.5 [Start State Matrix](#45-start-state-matrix)
5. [Company Systems](#5-company-systems)
   - 5.1 [Product](#51-product)
   - 5.2 [HR](#52-hr)
   - 5.3 [Finance](#53-finance)
   - 5.4 [Sales](#54-sales)
   - 5.5 [Operations](#55-operations)
   - 5.6 [Dashboard](#56-dashboard)
   - 5.7 [External Services](#57-external-services)
6. [World & Drama](#6-world--drama)
7. [Endgame & Progression](#7-endgame--progression)
8. [Build Spec](#8-build-spec)
   - 8.1 [Visual Identity](#81-visual-identity)
   - 8.2 [UI/UX Wireframes](#82-uiux-wireframes)
   - 8.3 [Audio](#83-audio)
9. [Open Questions & Inconsistencies](#9-open-questions--inconsistencies)
10. [Economic Outcome Principle](#10-economic-outcome-principle)

---

## 1. Vision & Design Pillars

Project Unicorn is a narrative-strategy startup simulator. The player founds a tech company, navigates 150 in-game days (~60-90 minutes real time) split into three phases — Bootstrap → Traction → Series A Hunt — and attempts to reach one of several win endings (Series A close, acqui-hire, profitable bootstrap) while avoiding bankruptcy, brand collapse, VC rejection cascade, or time-out.

**Positioning:** *"Software Inc., but the founders are people."* Project Unicorn is a strategy game, not a tycoon. It takes the product development backbone that strategy sims like Software Inc. have proven works — design document → iteration → development → polish, quality emerging from process, ship-or-polish trade-offs — and adapts each step as an event-driven narrative decision rather than a bar-filling optimization. Where Software Inc. asks the player to fill design bars and optimize team composition, Project Unicorn asks the player to live through the same product cycle as a founder with skin in the game, making judgment calls under uncertainty and writing their own story. The result is a strategy game whose decisions feel like Disco Elysium's interior monologues and CK3's character moments, not like a spreadsheet.

**Design pillars (derived from GDD + TECH_SPEC §1):**

- **Narrative-strategy.** Tone and depth comparable to CK3, Frostpunk, Disco Elysium — transposed to a 2020s tech startup setting.
- **Text-heavy, event-driven.** No real-time action. Continuous time at adjustable speed (pause/1x/2x/4x).
- **Progressive disclosure.** UI defaults to summary; detail surfaces on hover/click. Strategy depth accessible, not overwhelming.
- **Founder modes yok.** Tek bir oyuncu durumu var. Founder olarak şirketi yönetiyor; atadığı kişiler arka planda iş yapıyor, oyuncu trigger ettiği action'ları başlatıyor, gelen event'lere cevap veriyor. Arka planda sürekli işleyen sistemler.
- **Replay value.** 3 origins × 3 subgenres × trait combinations.
- **Micro-to-macro player evolution — the killer differentiator.** Same player, evolving interaction grammar as the company scales across the three release tiers. **Tier 1 (Startup):** the player micromanages — picks each feature, responds to each event, names each customer, decides each hire. **Tier 2 (Mid-Level Business):** the player delegates to team leads, sets policy, intervenes only on exceptions. Many decisions happen "off-screen" via your appointed leadership; you weigh in on the strategic ones. **Tier 3 (Tech Giant):** the player makes only macro decisions — regulatory responses, public statements, acquisitions, board politics, strategic direction. Same UI shell, same EventManager pipeline, different action vocabularies per tier. This is what Software Inc. doesn't do (its trillion-dollar gameplay is identical to its garage gameplay) and what we use to differentiate at every scale.

---

## 1.5 Tier Interaction Model

The micro-to-macro pillar manifests concretely in the action vocabulary available to the player at each tier. The same UI shell carries different verbs depending on company scale.

| Action surface | Tier 1 (Startup) | Tier 2 (Mid-Level Business) | Tier 3 (Tech Giant) |
|---|---|---|---|
| Product | Build Feature / Iterate / Ship | Approve Roadmap / Allocate Engineers / Set Quality Bar | Set Product Direction / Authorize Major Pivot |
| HR | Hire Candidate / Fire / 1:1 | Approve Headcount / Set Comp Bands / Promote VP | Approve Exec Hire / Restructure / M&A Integration |
| Sales | Find Prospects / Pitch / Close | Set Quota / Approve Enterprise Deal | Authorize Strategic Partnership / Public Pricing |
| Finance | Track Cash / Take Loan | Set Budget / Approve Capex | Approve Acquisition / Buyback / Dividend |
| Public | Respond to Press / Mentor 1:1 | Comms Strategy / Investor Update | Public Statement / Congressional Testimony / Board Politics |

The EventManager pipeline is identical across tiers; only the event pools and the available choice modifiers shift. A Tier 1 event might be "an engineer wants to quit"; the same player at Tier 3 sees "your VP of Engineering's resignation could leak to the press." Same pattern, different scale, different weight.

This table is design intent, not yet implementation scope. Tier 1 actions ship in the demo; Tier 2/3 actions ship in post-launch updates. Reference this table when designing Tier 1 systems to make sure data shapes and event vocabularies can extend cleanly to Tier 2/3 without retrofit.

---

## 2. Difficulty Philosophy

This module defines how difficulty works in Project Unicorn. It belongs in `PROJECT_SPEC.md`, under Vision & Design Pillars or as its own top-level section. It is a locked design decision.

---

### 2.1 Core Principle

Difficulty in Project Unicorn does not come from harder math, tighter dice rolls, or punishing core mechanics. The core systems — charisma rolls, financial calculations, build mechanics, time system — stay fair and consistent at all times.

Difficulty comes from two sources working **together**, never independently:

1. **Player choices** — the primary determinant of success or failure. Which subgenre, which features to build, which hires to make, which events to accept or decline, how to spend training time.
2. **Event pressure** — events create situational pressure and challenge, never arbitrary punishment.

A player who makes good strategic decisions can win even under heavy event pressure. A player who makes nonsense decisions will lose, and the events will compound those mistakes. A player who does everything right but still hits a hard run will struggle through events — but every position remains recoverable through good decisions.

---

### 2.2 The Target — 70% Win Rate

The Normal (and currently only) difficulty is tuned so that **roughly 70% of players win their runs, and 30% lose.**

This is a deliberately forgiving, player-friendly target. But the design intent is not "easy." The intent is:

- When the player wins, the win feels **earned** — relief and genuine satisfaction, not a trivial outcome handed to them. The player should think *"yes, I did it"* — not *"well, that was easy."*
- When the player loses, the loss feels **fair** — the player should think *"this game isn't unfairly hard; I didn't manage this round; let me try again"* — never *"the events screwed me, this is unfair."*

The emotional goal: a player who fails wants to immediately try again, not quit in frustration.

---

### 2.3 What Difficulty Is NOT

Difficulty must never come from:

- **Punishing core mechanics** — charisma roll success thresholds, financial formulas, and build mechanics are consistent and fair, never tuned to feel unfair.
- **Arbitrary event punishment** — a player who did everything right must never be able to honestly say *"the events were garbage and I lost through no fault of my own."*
- **Cascading negative events that make the game unplayable** — negative events put the player in a bad position to recover from, but never spiral into an unwinnable state.
- **RNG chaos** — outcomes are driven by player decisions and event sequencing, not by random misfortune the player could not influence.

---

### 2.4 What Difficulty IS

Difficulty comes from:

#### 2.4.1 Player decision quality

The player's strategic choices are the main driver of their run's difficulty:

- **Subgenre choice** sets the run's risk profile (e.g. SaaS = steady MRR, AI = higher risk and higher ceiling).
- **Feature decisions** matter — building features customers actually want versus building unnecessary features. The game surfaces customer demand signals: customers may want a specific feature, may threaten to leave without one, or may require a feature to close a sale. A player who builds the wrong things will struggle; a player who reads demand correctly will not.
- **Hire decisions** — the right people for the right roles versus poor hires.
- **Event responses** — accepting or declining events, timing commitments, managing trade-offs.
- **Training decisions** — when and whether to take the founder offline for skill growth.

If the player does the right things, they can win even with event pressure. If the player does nonsense, they lose — and that loss is earned.

#### 2.4.2 Event pressure — challenge, not punishment

Events create *situational pressure*, not arbitrary damage:

- **Every bad position must be recoverable.** Events put the player in a difficult spot, but good subsequent decisions can always pull them out. There is no "you are now dead" event with no recovery path.
- **Every choice has pros and cons.** Event choices are trade-offs, not traps. Declining a customer's feature request loses that customer but preserves runway; accepting it delays the roadmap but keeps the customer. Neither is "failure" — both are valid strategic positions.
- **Negative events do not cascade into unplayable states.** A scandal damages brand but does not chain into an automatic death spiral. The player always has room to respond.

#### 2.4.3 Difficulty as recovery-decision count

The practical measure of difficulty is **how many recovery decisions the player needs to make**, not whether they *can* make them. A hard run demands near-perfect play across many recovery decisions. An easy run demands fewer. But in all cases the recovery decisions exist and are available.

---

### 2.5 The Model in Practice

A worked example of how player choice and event pressure combine:

> The player picks the AI subgenre. They build an "inference speed" feature — a good choice for AI. An event fires: a customer wants Multi-Modal support. The player now has two options: build Multi-Modal (delays the rest of the roadmap by two weeks) or decline and keep focus on current features (loses this customer but preserves runway). Both are valid. Both have pros and cons. Neither is "failure." The player's decision here *is* the difficulty.

The event did not punish the player. It created a pressured decision. The quality of the player's response — informed by whether they read the customer demand signal correctly — determines the outcome.

---

### 2.6 How Difficulty Is Built and Tuned

Difficulty is not pre-designed in a spreadsheet. It is discovered and calibrated through playtesting.

#### 2.6.1 Single difficulty for now

There is one difficulty level — Normal. No Easy / Hard / Extreme selector at this stage. A difficulty selector may be added later; if it is, it will adjust event pool selection, event timing, and event severity — never the core mechanics. For now, the focus is making the single Normal experience correctly balanced.

#### 2.6.2 Calibration through play

The build-and-tune process:

1. **Baseline** — build the game with all events and mechanics at neutral settings. Play multiple full runs. Record win/loss ratio, where the run feels trivial, where it feels unfairly hard, where it feels tense but fair.
2. **Identify pressure points** — note which events cascade too hard, which choices feel meaningless, which moments feel perfectly balanced.
3. **Tune event design and pacing** — adjust event severity, event frequency, event sequencing, and recovery windows. Core mechanics are not touched.
4. **Blind playtesting** — external players run the game; track win/loss, "felt fair?", "felt earned?", and quit points.
5. **Iterate** — adjust until the Normal difficulty reliably produces the ~70% win rate with earned wins and fair losses.

#### 2.6.3 Tuning levers

When difficulty needs adjustment, these are the levers — all in event and pacing design, never core mechanics:

- Event severity (how much a scandal damages brand)
- Event frequency (how often crises fire per phase)
- Event sequencing and timing (when events fire relative to the player's runway and phase)
- Recovery windows (how much room and time the player has to respond)
- VC pickiness, prospect quality distribution, competitor aggression — all of which are situational pressure, not core mechanics

The core charisma/financial/build mechanics stay fair and constant throughout.

#### 2.6.4 Ongoing

Fine-tuning continues throughout development. The 70% target, earned-win feel, and fair-loss feel are validated through repeated playtesting, not assumed.

---

### 2.7 Summary

- Difficulty = player choices + event pressure, working together, never independently.
- Target: ~70% win rate. Wins feel earned, losses feel fair.
- Core mechanics (rolls, finance, build) are always fair and consistent — difficulty never comes from them.
- Events create pressure and challenge, never arbitrary punishment. Every bad position is recoverable.
- Negative events never cascade into unplayable states.
- A player who plays well wins even under pressure; a player who plays badly loses, and that loss is earned.
- Difficulty is tuned through playtesting — event design, severity, frequency, sequencing, recovery windows — not through punishing core mechanics.

---

## 3. Player Experience

### 3.1 Onboarding

Total target: ~3-4 minutes from launch to first in-game day.

**1. Origin selection**

3 origin options (see §4.1).

**2. Skill + trait allocation (~60 sn)**

- **Skill points:** Drag-drop, 4 eksen (Tech / Markets / Charisma / Politics), max 3/eksen. Hover'da eksenin etkisi açıklanır (örn. "Charisma: pitch'lerde, scandal recovery'sinde, brand check'lerinde aktif").
- **Trait seçimi:** 1 positive + 1 negative zorunlu. Her trait kart formatında, mekanik etkisi tooltip'te.

**3. Subgenre seçimi (~30 sn)**

3 kart: **AI / SaaS / Social**.

**4. Company creation (~60 sn)**

- **Name:** Free text input. Örnekler: "Synaptik" / "Brevit" / "Ledger" / etc.
- **Logo style:** 4 preset — Minimalist / Tech / Playful / Serious. Şirket logosunda ve UI'da kullanılır.
- **Slogan:** Optional free text (örn: "AI for legal precision").
- Confirm → loading → spawn.

---

### 3.2 Core Loop

#### Zaman akışı

- **1x = 1 saat / saniye.** 1 in-game gün = 24 saniye.
- **Hızlar:** pause / 1x / 2x / 4x.
- **MVP arc:** ~150 in-game gün ≈ 60-90 dk gerçek gameplay.

#### Founder modes yok

Oyuncu mod değiştirmiyor. Tek bir oyuncu durumu var. Founder olarak şirketi yönetiyor. Atadığı kişiler arka planda iş yapıyor, oyuncu trigger ettiği action'ları başlatıyor, gelen event'lere cevap veriyor. Arka planda sürekli işleyen sistemler.

#### Time advance (player'ın hızına göre)

- Atanmış kişiler dev veya R&D contribute ediyor (allocation: **dev VEYA R&D**, ikisi aynı anda değil).
- Sales rep (varsa) skill seviyesine göre auto-pipeline kapatıyor.
- News ticker continuous.
- Reactive event'ler her 1-7 günde bir fire ediyor.

#### Player discrete action'ları (trigger eder, sonuç gelir)

| Action | Mekanik | Cooldown / süre |
|---|---|---|
| 🎯 Feature build | Component + engineer assign + ship date | Ship date'e kadar |
| 🎯 Find prospects | Anlık 2-4 prospect spawn + seç + instant pitch dialogue | Pitch sonrası 3-4 gün cooldown |
| 🎯 R&D research | Tech tree node + person assign | Node-specific süre (5-15 gün) |
| 🎯 Founder training | Course seç + 2 hafta tam offline | Sabit 2 hafta, tüm meeting/event'lerden uzak |
| 🎯 Industry event attend | Event aktif olduğunda RSVP + event günü encounter chain | Event-specific süre |
| 🎯 Hire decision | 4 candidate spawn + seç + onboarding | İhtiyaç doğdukça |
| 🎯 VC pitch schedule | Phase 3'te VC outreach + pitch | Phase 3 only |

#### Sales mekaniği detayı

- **Founder:** "Find prospects" tıklar + anlık spawn + bir prospect seç + instant pitch dialogue scene. 3-4 gün cooldown.
- **Sales rep (1-5 star):** Skill star'ı + altındaki tier deal'ları otomatik kapatır. Üzeri founder'a escalate.

---

### 3.3 Session Flow

MVP boyunca ~150 in-game gün, gerçek 60-90 dk. **3 faza** bölünüyor.

#### Faz 1 — Bootstrap (Day 1-30, ~12-15 dk)

- **Tonu:** Scrappy, fragile, hopeful. Solo founder, garage vibe.
- **Oyuncu durumu:**
  - $50K cash, ~2y runway hissi
  - Sadece founder
  - MVP yapım sürecindesin (Day 1-12 iteration + development + polish phase'leri)
  - Reputasyon ~0, network ~5 contact
- **Yoğunluk:**
  - Reactive event her 2-3 günde minor
  - Prospect spawn 1-3 kart, çoğu small ($500-$3K MRR)
  - Industry events 1-2 tane (free / ucuz)
  - Decision density yüksek (her şey ilk defa)
- **Phase climax:** İlk hire kararı (Day ~25-30). Solo devam et veya engineer al.
- **Exit trigger'lar:**
  - İlk engineer hire
  - $15K+ MRR
  - Day 30 geçti

#### Faz 2 — Traction (Day 31-90, ~25-30 dk)

- **Tonu:** Building momentum, enemies appear. Sahnedesin.
- **Oyuncu durumu:**
  - 1-3 employee
  - 5-10 aktif prospect pipeline
  - Reputasyon 20-40, network 10-15
  - Cash $40-100K dalgalı
- **Yoğunluk:**
  - Reactive event her 1-2 günde minor, 2 hafta içinde 1 mid-tier scandal olasılığı
  - Prospect 3-5 kart, mid-tier ($3-15K MRR)
  - Industry events 2-3 tane, daha pahalı (TC Disrupt $8K, AI Summit, Founders Brunch)
  - Competitor moves aktif (PromptPilot fiyat kırma, InkflowAI feature lansmanı)
- **Faza özel mekanikler:**
  - R&D ilk research bu fazın ortasında tamamlanır
  - Sales rep tier sistemi belirginleşir
  - Founder training penceresi (2 hafta offline) için ideal zaman
- **Phase climax:** İlk major scandal event'i (Day ~70-85). Outcome shape diferansiyasyonu burada test ediliyor.
- **Exit trigger'lar:**
  - Brand 60+ ve $25K+ MRR
  - Day 90 geçti
  - VC outreach event tetiklendi

#### Faz 3 — Series A Hunt (Day 91-180, ~25-30 dk)

- **Tonu:** High stakes, exposed. Cinematic. Succession tonu.
- **Oyuncu durumu:**
  - 3-7 employee
  - Pipeline güçlü, $25-50K MRR
  - Reputasyon 50-70
  - Cash $80-200K, runway 6+ ay
- **Yoğunluk:**
  - Reactive event her 1-2 günde major
  - Prospect 4-7 kart, premium deal'lar ($10-50K MRR)
  - Industry events 1-2 tane (YC Demo Day, awards ceremony)
  - Competitor moves doğrudan hedef alıyor (talent poaching, anti-narrative)
- **Faza özel mekanikler:**
  - VC pitch sekansı (3 firma sırayla)
  - Term sheet negotiation cinematic
  - Customer reference event'leri (VC due diligence sırasında müşteri aranıyor)
- **Phase climax:** VC pitch sahnesi (Day ~150-170). Tüm phase bu hazırlık. 3 farklı VC, 3 farklı term sheet.
- **Demo end trigger'lar:**
  - Series A close başarılı → win cinematic
  - 3 VC rejection → fail / recovery branch
  - Day 180 geçti, henüz funded değil → time-out ending

#### Faz geçişleri

Yumuşak geçişler. Loading screen yok. Şu yumuşak kayışlar fazları ayırır:

- Event pool'u kayar (Phase 1 event'leri rare, Phase 2 event'leri active)
- Prospect quality distribution kayar
- Competitor aggression artar
- News ticker manşetleri sektörün size verdiği önemi yansıtır

**Phase indicator UI:** Üst panelde küçük progress strip — "Bootstrap → Traction → Series A Hunt". Mentor karakter de phase geçişlerinde organik diyalog veriyor.

**Player'ın evrimi (micro-to-macro pillar uygulaması):**

- **Phase 1:** Operatör — her şeyi kendin yaparsın
- **Phase 2:** Manager — bazı işleri delege ederken bazılarına müdahale edersin
- **Phase 3:** Executive — sadece big moves, küçük şeyler ekibe emanet

#### Pacing özet tablosu

| Faz | In-game gün | Real-time (dk) | Decision yoğunluğu | Major event sayısı | Tonu |
|---|---|---|---|---|---|
| Bootstrap | 30 | 12-15 | dk başına 2-3 | 5-8 | Scrappy, hopeful |
| Traction | 60 | 25-30 | dk başına 1.5-2 | 15-20 | Building / pressured |
| Series A Hunt | 90 | 25-30 | dk başına 1.5 | 12-15 | High stakes / exposed |

**Toplam:** ~30-45 major reactive event + ~5-7 industry event + ~120-180 active player decision.

---

### 3.4 Kazanma Koşulları (Win Conditions)

#### Hard Win — Series A Close

- **Yol:** Phase 3'te 3 VC pitch'inden en az 1'i başarılı + term sheet imzalandı.
- **Koşullar:**
  - Brand health 50+
  - $20K+ MRR
  - En az 1 VC karşısı tamamlanmış
  - Charisma roll + dialogue başarılı
- **Cinematic outcome:** Newspaper ending screen ($X valuation, dilution X%, runway extends to X months) + share-to-X butonu + Tier 2 unlock teaser.
- **Variants:**
  - **"The Founder-Friendly Close"** — lower valuation, more control kept.
  - **"The Aggressive Close"** — high valuation, more dilution, board control kaybı.

#### Soft Win — Acqui-Hire

- **Yol:** Phase 2 sonu / Phase 3 ortasında, eğer struggling but not failing iseniz, bir rakip ya da büyük şirket acquisition teklifi yapar.
- **Koşullar:**
  - Brand health 30-50 arası
  - $15K+ MRR ya da güçlü product reputation
  - Phase 3'e girilmiş ama VC'ler reddetmiş
- **Decision modal:** "PromptPilot offers $4M to absorb your team and IP. Reject and continue Series A hunt, or accept?"
- **Cinematic outcome:** Bittersweet — "you sold but you didn't quite win."

#### Profitable Bootstrap (rare)

- **Yol:** $50K+ MRR + 3 ay üst üste profitable + hiç VC almamış.
- **Koşullar:**
  - Cash 0'a hiç düşmemiş
  - Day 180'i ulaşılmış
  - Net positive cash flow 90+ gün
  - Hiç major scandal yaşamamış
- **Cinematic outcome:** Indie hero ending. "You don't need them. You built something real."

---

### 3.5 Kaybetme Koşulları (Lose Conditions)

#### Bankruptcy

- **Yol:** Cash 0 + kredi tableleri tüketildi + revenue gelmiyorsa.
- **Cinematic outcome (~30 sn):** Kepenk kapatma. Ofis ışık, kutuları paketleniyor, founder son kez kapıyı kilitliyor. Sessiz, kasvetli ama dramatik.
- **Retry screen:** "What you'd do differently next time?" + 2-3 specific learning moment ("Pivot earlier?", "Hire sales reps before solo grinding?") + "Try again" button.
- **Trigger conditions:**
  - Cash < 0 + tüm credit sources reddedildi
  - Day 90+'da revenue $5K MRR altında ve buhran içinde

#### Brand Collapse — "Radioactive"

- **Yol:** Major scandal yanlış yönetildi, brand health 15 altı.
- **Cinematic outcome:** Empty conference room. Twitter trend "#YourCompanyGate." Mentor karakter bir veda mesajı bırakıp gidiyor. Press inquiries unanswered going to voicemail.
- **Why specific:** Para hâlâ olabilir, ama kimse seninle çalışmıyor. Müşteriler churning, çalışanlar istifa ediyor, VC'ler email return etmiyor. Fonu olmayan ölüm değil — fonu olan ama yapayalnız ölüm.
- **Trigger conditions:**
  - Brand health < 15 + 30 gün toparlanma yok
  - Active scandal + 2+ key employee resignation cascade

#### VC Rejection Cascade

- **Yol:** Phase 3'te 3 VC sırayla pitch'i reddetti.
- **Cinematic outcome:** Founder alone in office at 11pm, son VC reddetme emaili ekranda. Mentor: "Belki bu yıl değil. Belki bu şirket değil. Ama sen bitmedin." Soft loss tonu.
- **Recovery alternatif:** Eğer revenue $30K+ MRR ve cash positive ise, "profitable bootstrap" path'ine pivot edebilirsin. Yoksa runway tükenir + bankruptcy.
- **Trigger conditions:**
  - 3 VC pitch failed
  - Day 165+ ve hâlâ funded değil

#### Time-Out — "Running on Fumes"

- **Yol:** Day 180'e ulaşıldı, hiçbir terminal state tetiklenmedi ama hâlâ sustainable değil.
- **Cinematic outcome:** Calendar Day 180+ gösterip durmadan akıyor, founder başını masaya koyuyor. Soft fade-out. Açık ending — "What happens next? You decide."
- **Retry screen:** Bu daha çok bittersweet tonda — sen kaybetmedin tam olarak, sadece kazanmadın.
- **Trigger conditions:**
  - Day 180+ + henüz funded değil + hâlâ profitable değil ama bankruptcy de yok

---

### 3.6 Bitiş Senaryoları (Ending Scenarios)

#### Win + Retry akışı

Her win cinematic'inin sonunda:

**Cinematic outcome (~30-45 sn):** Newspaper-style ending screen, win variant'ına göre değişen başlık ve detay. Background'da subtle celebration audio, mentor karakter portresi sağ alt köşede.

**Run summary (4-5 satır):**

- "12 customers signed, 2 lost"
- "1 scandal survived, 2 mishandled"
- "Hire decisions: 3 (1 retained..."
- "Series A: $4M @ $22M valuation, 18% dilution"
- "Net worth: $50K → $4.05M in 156 days"

**Mentor reflection (1-2 cümle, NPC voice):**

- "PromptPilot kompromat'ı yerine VC favori'na çevirsen olabilirdi. Ya da olmazdı. Bil…"

**Win variant'ına göre değişiyor:**

- **Founder-Friendly Close:** "Kontrolü korudun. İleride board savaşı olabilir. Akıllı."
- **Aggressive Close:** "Yüksek valuation + board seat verdin. Marcus seninle iyi anlaşıyor, ama bunu hatırla."
- **Acqui-Hire:** "Tam istediğin değildi ama temiz çıkış. PromptPilot'ta tech'in iyi yaşar."
- **Profitable Bootstrap:** "Hiç dilution yok. Hiç board yok. Sen kazandın — ama Tier 2'nin oyununu farklı oynayacaksın."

**Tier 2 teaser:**

- "Tier 2'de açılan: Series B chase, IPO path, lobby system, public market manipulation, Tier 2-4 mega-corp rakipler, M&A kararları."

**Retry options:**

- "Try a different origin or subgenre" (replay variety)
- "Hard mode unlock" (Series A close başarısı sonrası unlocked — daha az starting capital, daha agresif rakipler)
- "Share your run to X" (auto-tweet draft with run stats)
- "Wishlist Tier 2" (full release pre-order CTA — primary marketing call)

#### Failure + Retry akışı

Her lose state cinematic'in sonunda variant-specific bir ending + retry akışı (yukarıda kayıp koşullarında detaylanmış: Bankruptcy, Brand Collapse, VC Rejection Cascade, Time-Out).

**Retry options:**

- "Try again, same origin/subgenre" (öğrendiklerini test et)
- "New origin/subgenre" (tazele variety)
- "Wishlist Tier 2" (full release CTA)

---

## 4. Character & Setup

### 4.1 Karakter Orijinleri (Origins)

#### 🚀 Self-Made Founder

- "Apartmanında 18 ay kod yazdın. Şimdi MVP'n hazır."
- **+:** Founder cred (VC pitch +%30), basın seninle iyi
- **-:** Sıfır finans erişimi, sıfır politik ağ
- **Skill puanı:** 6

#### 💰 Heir

- "Babanın trust fonu hesabında. Aile 'gerçek bir iş' istiyor."
- **+:** $20M sermaye, üst-tabaka network anında erişim
- **-:** Nepo baby reputasyonu (Public -3), çalışan loyalty -1
- **Skill puanı:** 4

#### 🏢 Corporate Refugee

- **Skill puanı:** 6 (Skill Points panelinden)

> **TBD — Corporate Refugee detayı:** GDD'nin Karakter Orijini panelinde Self-Made ve Heir için tagline + / − modifier'lar verilmiş; **Corporate Refugee için yalnızca skill puanı (6) geçiyor**. Tagline, +/− modifier'lar, starting state ayrıntıları designer tarafından doldurulacak.

---

### 4.2 Trait Havuzu

- **Format:** 1 positive + 1 negative trait zorunlu, char creation'da seçilir.
- **Görünürlük:** Tüm trait'ler oyuncuya açık (kendi karakterinde).
- **Mekanik etki:** Her trait spesifik bir sistem üstünde modifier (skill check, dialogue option, event trigger).
- **MVP havuzu:** ~12 positive + ~12 negative trait.
- **Örnekler:**
  - **Positive:** Charismatic / Pragmatic / Technical Visionary
  - **Negative:** Imposter Syndrome / Conflict Avoidant / Burnt-Out
- **Detay catalog ayrı dökümantasyonda** (`CONTENT_GUIDE.md` — content phase'de eklenecek; TECH_SPEC §1).

---

### 4.3 Skill Points

- **4 eksen:** Tech / Markets / Charisma / Politics
- **Allocation:** Drag-drop, max 3/eksen
- **Origin'e göre toplam puan:**
  - Self-Made Founder: 6
  - Heir: 4
  - Corporate Refugee: 6

**Etki tooltip'leri hover'da:**

- **Tech:** ürün build kalitesi, R&D hızı
- **Markets:** prospect quality, deal close oranı
- **Charisma:** pitch, scandal recovery, brand check
- **Politics:** VC negotiation, network leverage, media management

---

### 4.4 Subgenre

3 seçenek:

- **AI**
- **SaaS**
- **Social**

> **Note:** GDD'nin Subgenre kolu yalnızca "AI" ve "SaaS"ı isim olarak listeliyor; üçüncü kart "Social" Onboarding metninde ("3 kart: AI / SaaS / Social") teyit ediliyor. Sosyal subgenre için tam component palette §5.1'de tanımlı.

---

### 4.5 Start State Matrix

| Faktör | Belirleyici |
|---|---|
| Starting cash | Origin |
| Starting MVP quality | Subgenre + Skills |
| Starting network | Origin (kim ile başlıyor) |
| Starting reputation | Origin (Heir public -3, Self-Made baseline 0) |
| First mentor dialogue | Origin'e göre değişir |
| First prospect quality | Subgenre + Markets skill |

---

## 5. Company Systems

### 5.1 Product

Product development is the player's core creative agency in Tier 1. It is also the system most directly inspired by Software Inc., reframed as event-driven narrative decisions rather than bar-filling optimization.

#### Pain-point framing

Bir ürün gerçek bir problemi çözmek için var olur. Onboarding'in mentor introduction'ı player'a explicitly **MVP'nin ne olduğunu öğretir** — minimum viable product solving a real pain point — ve player'ın ilk gerçek tasarım kararı şudur: "what pain point are you solving?" Bu pain point, alt-ürün tipi seçimi olarak ifade edilir.

Mentor cheesy olmadan founder vocabulary'sini player'a aktarır. Disco Elysium'un "you don't know what a centrist is, here's what it means" pattern'ine paralel — oyun kendi vocabulary'sini player'a öğretir, jargon'la üstüne çıkmaz.

#### Three-level product hierarchy

Flat component palette (önceki tasarım) yerine 3 katmanlı bir karar ağacı:

| Level | Decision moment | Examples |
|---|---|---|
| **Subgenre** | Onboarding | AI / SaaS / Social |
| **Sub-product type** | MVP start | AI: assistant / photo editor / code copilot / multi-modal app / vector search service |
| **Features** | MVP iteration | Player 2-4 feature seçer, sub-type-spesifik 5-7 feature pool'undan |

Her sub-product type kendi feature palette'ini, market davranışını, customer archetype affinity'sini ve event trigger'larını taşır. Bir AI photo editor founder vs bir AI code copilot founder farklı ekosistemlerde yaşar — ikisi de "AI subgenre" olsa bile.

**Sub-product type catalog (working — refine during content phase):**

| Subgenre | Sub-product types |
|---|---|
| AI | AI assistant / photo editor / code copilot / multi-modal app / vector search service |
| SaaS | project management / CRM / analytics dashboard / billing platform / dev tools |
| Social | (Tier 2 unlock — Coming Soon in demo) |

Her sub-type için 5-7 feature'lık pool. Feature listesi content phase'inde doldurulur; mekanik etkileri (event trigger'ları, customer affinity bonus'ları, scandal sensitivity) per-feature wired olur.

#### Build phases

MVP build üç phase'e ayrılır, her biri kendi tonuna ve karar momentine sahip:

**Iteration phase (player-controlled duration).** Player feature'ları seçtikten sonra bir duration commit eder. Game player'a feature scope'una göre **minimum estimation** verir (örn. "scope'una göre bu MVP minimum 8 gün sürer"). Player bunu kısaltabilir veya uzatabilir:

- **Kısaltma:** customer'a daha hızlı, ama quality ceiling düşer + bug oranı artar
- **Uzatma:** quality ceiling yüksek, ama runway burn'i derinleşir + ilk customer geç gelir

Bu Software Inc.'in design-caps-quality mantığıdır, ama **deliberate player decision olarak** — bar-fill mini-game değil. $50K starting runway dikkate alındığında, iteration süresinin runway'e maliyeti player'a görünür olmalı: "12-day iteration = $X cash burn" formunda. Trade-off real felt pressure.

**Development phase (duration locked at iteration commit).** Time advances. Founder'ın onboarding'de allocate ettiği skill stat'ları daily output'a feed eder:

- **Tech skill:** primary driver — daily quality growth rate + bug accumulation rate (high Tech = +quality, -bugs)
- **Markets skill:** market relevance (downstream pitch difficulty modifier)
- **Charisma skill:** event choice unlock'ları (örn. "co-founder'ı convince et longer hours" Charisma roll gerektirir)
- **Politics skill:** legal/compliance event resilience

Reactive event'ler bu phase'de phase-appropriate ton ile fire eder: tactical bugs, scope creep, 3am moments, exhaustion. Spec #2 event pack'i bu phase'i doldurur.

**Polish phase (default 2-3 days, optional).** Development sonunda bug-fix / QA mode. Player'a **explicit ship-early decision modal** sunulur:

- **"Ship now"** (rushed): bugs go live, customer churn risk, ama +N day runway saved
- **"Complete polish"**: cleaner ship, slower start, daha stable customer base

Bu **THE archetypal startup decision**. Randomized event içine sıkıştırılmamalı — kendi dedicated modal moment'i hak ediyor. Player'ın oyun boyunca tekrarlayacağı bir karar pattern'i.

#### Ship moment is narrative-only

Per the governing principle (§10 Economic Outcome Principle): MVP shipping does NOT generate revenue.

Ship moment yapar:
- `GameState.flags["mvp_shipped"] = true` (world-state shift, unlocks sales/hire actions)
- `GameState.flags["product_quality"] = quality` (persistent product quality memory; future Sales/Pitch systems read)
- Ship cinematic'i mentor reaction'ı + "şimdi müşteri bulma zamanı" framing
- `active_build.status = "shipped"`, `active_build = null`

Ship moment yapmaz:
- MRR delta
- Cash delta (positive delta)
- Brand delta
- Reputation delta
- Customer add

Revenue, hire, customer growth — hepsi **played decision moments** ile gelir (pitch dialogue, hire flow, scandal response). Ship sadece dünyayı "ürün hayatta" state'ine geçirir.

#### Product Quality dimensions (future — Tier 1 v2)

Mevcut implementasyon tek `product_quality` int (0-100). Future expansion'da bu üç boyuta ayrılabilir (Software Inc. pattern'i):

- **Innovation:** distinctiveness, press attention magnet, customer acquisition driver
- **Stability:** bug-freeness, churn resistance, support cost
- **Usability:** ease of use, onboarding conversion, customer satisfaction

Bu üç boyut farklı player choice'larından beslenir ve sonraki sistemlere differential modifier verir. Şimdilik single quality field; Spec #3'te multi-dimensional expansion açılır.

---

### 5.2 HR

- **Hire decision:** İhtiyaç doğunca 4 candidate spawn. Her candidate: name, role, salary, equity expectation, 4 stat, 1 visible trait, hidden trait potansiyeli (hire'dan sonra ortaya çıkar).
- **Roster yönetimi:** Çalışan kartı — Morale, role-spesifik stat, equity, salary, attention badge (`FLIGHT RISK` / `BURNING OUT` / `OVERLOADED` / `PROMO ELIGIBLE` / `CO-FOUNDER TRACK`).
- **Morale tick:** Her gün morale değişir. Etkenler: workload, comp fairness, ship success, scandal exposure, mentor relationship, peer dynamics.
- **Churn risk:** Morale < 30 + competitor outreach event'i = flight risk. Player respond eder (raise teklifi, equity refresh, role değiştir, ya da bırak gitsin).
- **Trait reveal:** Hidden traits (örn. "secretly looking", "burnout-prone") event'lerle ortaya çıkar. Mira lunch event tipi karşılaşmalar.
- **Comp cycle:** Çeyrekte bir comp review event'i — raises, equity refresh, promotions. Bütçeyle dengelenmesi gerekir.
- **MVP scope:** ~6-8 unique employee archetype, ~12 trait.

---

### 5.3 Finance

- **Cash flow:** MRR (gelir) − Burn (maaş + ops + tools) = günlük net. Cash dashboard'da real-time görünür.
- **Credit ladder (3 tier):**
  - **Friends & Family:** $10-25K, soft equity
  - **Bank Credit:** $30-80K, 8-12% APR
  - **Bridge Loan:** $100-250K, 15-25% APR + warrants
  - Her tier eligibility ve risk profili farklı.
- **Runway hesaplama:** Cash + (daily burn − daily revenue). Negatif net'te ay cinsinden, pozitif net'te "infinite" görünür.
- **Burn breakdown:** Salaries / Tools (SaaS subscriptions) / Office (rent, utilities) / Marketing / Legal & accounting / Misc.
- **Cash threshold alerts:** Mentor uyarıları —
  - $30K (warning)
  - $15K (critical)
  - $5K (emergency)
  - Credit ladder önerileri otomatik.
- **Scenario projection:** Hover'da "if you hire X, runway drops to Y months" preview. Hire / spend decision'ları informed.
- **Quarterly summary:** Q1 / Q2 / Q3 sonu özet — revenue trend, burn trend, runway change, key wins / losses.

---

### 5.4 Sales

- **🎯 Find prospects action:** Click + anlık 2-4 prospect spawn + seç + instant pitch dialogue. Cooldown 1 Week (GDD'nin başka yerinde "3-4 gün" da geçti — bkz. §9 Open Questions).
- **Prospect kartı:** Company name + industry + size + estimated MRR + difficulty stars (1-5) + warning flags (slow payer / picky / kompromat opportunity).
- **Pitch dialogue scene:** Charisma roll + dialogue choices (3-4 option). Outcome: `SIGNED` / `LOST` / `CALLBACK` (pipeline'da kalır, retry).
- **Sales rep tier sistemi:** 1-5 star. Her tier'in kapatabildiği max deal MRR'ı var. Founder her zaman max tier (5 star) eşdeğeri.
- **Auto-pipeline:** Hire edilen rep, kendi tier'i + altındaki deal'ları otomatik kapatır (success rate skill'e bağlı). Üzeri founder'a escalate.
- **Pipeline view:** Active prospects, callbacks, won deals (last 30 days), lost deals (with reason). Customer health durum dashboard.
- **Customer health:** Healthy (green) / At Risk (yellow) / Churning (red). Renewal event'leri çeyrekte fire.

---

### 5.5 Operations

> **TBD:** GDD mind-map'inde Company Systems → Operations dalı yalnızca başlık olarak verildi; alt mekanik detayı yok. Designer tarafından doldurulacak.

---

### 5.6 Dashboard

> **TBD:** GDD mind-map'inde Company Systems → Dashboard dalı yalnızca başlık olarak verildi; alt mekanik detayı yok. Bu büyük olasılıkla TECH_SPEC §5.2'deki "center viewport + tab" yapısının game-design tarafı — spec içeriği UI tab tasarımıyla birlikte netleşecek.

---

### 5.7 External Services

- **PR Agency:** Monthly retainer ($3-8K). Scandal severity damper. Without contract, scandal recovery options limited.
- **Legal counsel:** Monthly retainer ($2-5K). Lawsuit / dispute event'lerde damper. KVKK compliance. Contract review.
- **Recruiting agency:** Per-hire fee veya monthly retainer. Hire pool genişler, candidate quality artar.
- **Cloud infrastructure provider:** Aylık değişken cost, scale ile büyür. Outage event'lerinde response speed servis seviyesine bağlı.

---

## 6. World & Drama

GDD mind-map'inde yalnızca başlık seviyesinde verilmiş alt başlıklar:

- **Haber akışı** — TBD
- **Event Pool** — TBD (TECH_SPEC §9'da teknik şema mevcut: `data/events/reactive/`, `industry/`, `scandals/` klasörleri + event JSON şeması)
- **Skandallar** — TBD (Brand Collapse trigger ile bağlantılı; §3.5)
- **Competitor AI** — TBD (PromptPilot, InkflowAI gibi örnekler §3.3 Faz 2'de geçiyor; mekanik detayı yok)
- **Network** — TBD (Origin'le bağlantılı; §4.5 Start State Matrix'te "Starting network: Origin")
- **Compromat** — TBD ("kompromat opportunity" §5.4 Sales prospect warning flag'i olarak geçiyor; tam mekanik tanımı yok)

> Tüm alt başlıklar **content phase**'de doldurulacak. Designer tarafı için.

---

## 7. Endgame & Progression

GDD mind-map'inde yalnızca başlık seviyesinde verilmiş alt başlıklar:

- **Phase Pacing** — §3.3 Session Flow'da detaylı (Bootstrap → Traction → Series A Hunt).
- **Quarter Summary** — §5.3 Finance'te kısaca geçiyor (Q1 / Q2 / Q3 sonu özet); ayrı bir UI surface olarak nasıl çalıştığı TBD.
- **VC Pitch System** — §3.3 Faz 3 + §3.4 Hard Win'de bazı detaylar (3 firma sırayla, term sheet, charisma roll); tam dialogue / outcome ağacı TBD.
- **Term Sheet Pazarlığı** — TBD. Negotiation cinematic'inde hangi değişkenler pazarlık konusu (valuation, dilution, board seat, liquidation preferences, etc.) ve oyuncu mekaniği nasıl çalışıyor — designer netleştirecek.
- **Demo End Screen** — §3.6 Bitiş Senaryoları'nda variant cinematic'leri var; demo "end screen" flow'unun teknik düzeni (newspaper layout, share-to-X, Tier 2 teaser, retry button konumları, vb.) TBD.

---

## 8. Build Spec

### 8.1 Visual Identity

> **TBD:** GDD mind-map'inde yalnızca başlık olarak verildi.
>
> **TECH_SPEC §11.2'den bilinen:** warm sepia ve amber palette, editorial serif + grotesk sans typography. Master theme resource'unda design token olarak tanımlanacak.

---

### 8.2 UI/UX Wireframes

> **TBD:** GDD mind-map'inde yalnızca başlık olarak verildi.
>
> **TECH_SPEC §5.2 ve §11.3'ten bilinen layout regions:** top stat bar / left tab column / center viewport / right actor panel / bottom news ticker + modal CanvasLayer.

---

### 8.3 Audio

- 🔊 **Ambient music:** lo-fi editorial, phase-spesifik
  - Bootstrap = sparse acoustic
  - Traction = building tension
  - Series A Hunt = cinematic stakes
- 🔊 **UI sounds:**
  - paper-flip (button hover)
  - typewriter strike (button click)
  - distant click (news ticker headline)
  - subtle chime (stat değişimi)
- 🔊 **Modal events:** per-event ambient bed
  - Mira lunch = restaurant murmur
  - Crisis = empty office hum
- 🔊 **Phase transition:** jazz-influenced cinematic stinger (3-5 saniye).
- 🔊 **Format:** OGG Vorbis 192 kbps (music), WAV / short OGG <100 KB (SFX).
- 🔊 **Library (GDD original):** Howler.js + use-sound (React hook wrapper).

> ⚠️ **Tech mismatch:** GDD'nin audio library satırı web stack (Howler.js + use-sound React hook wrapper) belirtiyor. Hedef engine Godot 4 + GDScript olduğu için (TECH_SPEC §2 LOCKED), audio Godot'un native `AudioStreamPlayer` + `AudioStreamOggVorbis` / `AudioStreamMP3` node'larıyla implement edilecek. Format spec'i (OGG Vorbis 192 kbps, WAV / short OGG) Godot ile uyumlu — değiştirilmesi gerekmiyor.

---

## 9. Open Questions & Inconsistencies

GDD ekstrakte edilirken tespit edilen ve designer tarafından çözülmesi gereken noktalar:

1. **Corporate Refugee origin detayı eksik (§4.1).** Karakter Orijini panelinde yalnızca skill puanı (6) verilmiş; tagline, + / − modifier'lar, starting state yok. Self-Made ve Heir formatına paralel doldurulması gerekiyor.

2. **Find prospects cooldown tutarsızlığı (§3.2 vs §5.4).** Core Loop tablosu "pitch sonrası 3-4 gün cooldown" diyor; Sales panelinde "Cooldown 1 Week" geçiyor. Tek bir değer kilitlenmeli.

3. **Audio library mismatch (§8.3).** GDD Howler.js + React hook wrapper diyor; hedef Godot 4. Native AudioStream node'larıyla replace edileceği TECH_SPEC tarafında zaten kesin — designer tarafı için bilgi notu.

4. **World & Drama mekanikleri (§6).** Haber akışı, Event Pool, Skandallar, Competitor AI, Network, Compromat — hepsi başlık. Content phase önce mekanik kuralları gerekli.

5. **Endgame Term Sheet Pazarlığı (§7).** Negotiation cinematic'inin pazarlık değişkenleri ve oyuncu mekaniği netleşmemiş.

6. **Operations ve Dashboard sistemleri (§5.5, §5.6).** Mekanik detayı yok.

7. **Visual Identity ve UI/UX Wireframes (§8.1, §8.2).** Görsel mockup ve wireframe yok. TECH_SPEC layout regions + design tokens mevcut; designer tarafı görsel teslim hazırlandığında doldurulacak.

8. **"Hire decisions: 3 (1 retained..." gibi run summary satırları (§3.6).** Tam metinler trunc'lı görünüyor; final wording designer tarafından netleştirilecek.

9. **Reputation clamp range undefined (§4.5).** Spec yalnız spesifik değer noktaları veriyor: Heir start -3, Self-Made baseline 0 (§4.5), Phase 1 ~0 / Phase 2 20-40 / Phase 3 50-70 (§3.3). Üst sınır veya alt floor açıkça spec'd değil. Mevcut kod `clampi(value, -10, 100)` placeholder olarak kalıyor (`scripts/autoload/game_state.gd` `set_reputation`). Designer kararı: Brand 0-100 ile eşle mi (sadece 0-100)? Negative range genişletilsin mi (-20, -50)? Yoksa unbounded mı (±∞, no clamp)? Bu karar VC pitch / brand check formüllerinde threshold hesaplarını etkileyecek.

10. **Demo scope — Heir, Corporate Refugee origins ve Social subgenre.** Tam sürüm için designed scope; demo onboarding'inde "Coming Soon" disabled card olarak görünür — full-release content'i telegraph etmek (Steam wishlist conversion) ve item #1'in mekanik boşluklarını invent etmek zorunda kalmamak için. Mekanik, start state, content bu turn implement edilmedi. Heir tamamen spec'd (§4.1) — disabled olması scope kararı; Corporate Refugee hem scope hem item #1 boşluğu (tagline / modifiers TBD); Social yalnız scope. Onboarding scenes: `scenes/onboarding/steps/OriginStep.tscn`, `SubgenreStep.tscn` — card-grid recipe `mouse_filter=IGNORE` + `focus_mode=NONE` + `modulate(α=0.45)`.

---

## 10. Economic Outcome Principle

Every economic outcome in Project Unicorn — cash change, MRR change, brand change, reputation change — comes from a played decision moment: a pitch dialogue, an event choice, a customer interaction, a scandal response, a hire negotiation. The game does NOT auto-generate economic progress from system events.

Specifically:

- Shipping an MVP **unlocks** the ability to seek customers; it does not create them or generate revenue.
- Hiring an employee **adds capacity**; it does not automatically generate output or MRR.
- Closing a Series A round **changes runway**; it does not change MRR.
- Phase transitions **shift event pools**; they do not deliver economic windfalls.
- Time passing **burns cash via salaries and ops**; it does not generate cash.

This is the line between Project Unicorn and tycoon games. Tycoon games auto-generate revenue from system events (build factory → factory produces income; hire worker → worker produces output). Project Unicorn requires the player to ACT into each economic outcome through played decision moments.

This principle governs all system design. When designing any new system, ask: "is the player making a decision that earns this delta?" If the answer is no decision moment, no delta. Surface the question to the chat-side directors rather than introducing an auto-progress path silently.

---

*End of Project Spec. For technical architecture, see `TECH_SPEC.md`. For session entry and agentic workflow, see `CLAUDE.md`.*
