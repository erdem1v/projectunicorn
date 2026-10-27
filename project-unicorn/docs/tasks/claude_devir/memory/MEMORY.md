# Memory Index

Proje klasörü 2026-10-16'da "project steam" → "Project Unicorn" oldu (eski hafıza: C--Users-erdem-Desktop-project-steam).

## Erdem'in çalışma kuralları (feedback / project)
- [Single folder + single remote](single-folder-single-remote-rule.md) — worktree YOK, tek klasör; uzakta yalnız main; push öncesi dal listesi + onay
- [Push without full smoke](feedback-push-without-full-smoke.md) — "push et" = doğrudan push, tam smoke yok; ekran kapıları sürer
- [Alt ajan token kuralı](feedback-subagent-token-budget.md) — model zorluğa göre; commit başına ≤1 inceleme, ≤1 düzeltme, ölçüm turu yok
- [Adım tablosu ve model rolleri](feedback-step-table-model-roles.md) — faz önce adım tablosu + onay; Opus plan incelemesi; Sonnet kod, Haiku mekanik
- [Görünür kararlar Erdem'in](feedback-codirector-visible-rulings.md) — **2026-10-27: oyuncunun gördüğü seçim kare + önerimle Erdem'e; oyundaki adıyla anlat ("kullanıcıyla görüş" ≠ Ar-Ge)**
- [PRD ne diyorsa onu yap](feedback-prd-says-do-it.md) — PRD eylemi yazıyorsa yeniden sorma; yalnız sessiz/çelişkili yerde sor
- [Yalnız tam tanımlı iş koda](feedback-only-fully-specified-work.md) — netleşmeyen park + listelenir; sentez PRD değildir
- [Sözleri kurala çevirme](feedback-remarks-are-situational.md) — her sözü evrensel kural yapma, duruma göre karar
- [Sade karar soruları](feedback-plain-decision-questions.md) — jargonsuz, oyuncu örneğiyle; sonunda ne idi/ne değişti/şimdi ne
- [Soru = araştırma özeti + etki](feedback-question-with-research-summary.md) — soru araştırma özetiyle gelir; stil sorulmaz yapılır; boşta ajan yok
- [Aynı oturumla kurtar, görsel göster](feedback-revive-same-session-show-visuals.md) — `claude -r <id> --remote-control`; kareler görsel; öneriler toplu kabul edilmez
- [Oynanış önce, %90 çıtası](feedback-gameplay-first-90-percent.md) — Steam %90+; her mekanikte "oynanışı nasıl etkiler"
- [Ölçeklenen mekanik + derin araştırma](feedback-scalable-mechanics-deep-research.md) — 1–50 kişide kırılmayan kural; UI koddan önce oyunun kendi arayüzünde maket
- [Adil ekonomi](feedback-fair-economy-no-hidden-costs.md) — görünmeyen/yönetilemeyen gider yok; B2B memnuniyet sebepsiz düşmez
- [Araştırmada başarısızlar da](feedback-research-include-failures.md) — başarısız örnekler de, her iddia kaynaklı
- [Design research first](feedback-design-research-first.md) — görsel iş referans araştırmasıyla başlar, Erdem seçer, sonra üretim
- [Görsel araştırmada tek çift](feedback-visual-research-one-pair.md) — aday başına tek önce/sonra çifti + ms
- [Ekrana her şeyi sokma](feedback-ui-dont-shove-everything.md) — açıklama ipucuna, kısaltma yerine ikon
- [Arayüzde göster, anlatma](feedback-ui-show-dont-tell.md) — açıklayıcı satır slop; durum biçimle
- [Yalnız ton, yeniden tasarım yok](feedback-tone-not-redesign.md) — "bu tona" = font/ikon/renk/portre; yerleşim aynen
- [Sanat yönü dönemsiz](feedback-art-direction-timeless.md) — 2012→2020'ler; döneme kilitlenme, yöntemle kur
- [Bespoke assets over packs](feedback-bespoke-assets-over-packs.md) — paket asetler jenerik; özel asetler kalır
- [No mechanical word bans](feedback-no-mechanical-word-bans.md) — stil notu ≠ kelime kara listesi
- [Olay seçeneği kalitesi](feedback-event-option-quality.md) — somut hamle, bedel öznede, bedava çıkış yok
- [Acil olay ve kâğıt yazımı](feedback-incident-and-card-writing.md) — sıklık rastgele ≥4 hf, bedel ölçekten, doğal cümle
- [Olayda adlar sistemden](feedback-event-names-from-system.md) — sabit ad yok, yuva + seçici; olay imzalatmaz, teklif verir
- [Üretim YZ ile sürer](project-ai-production-decision.md) — kapsül/logo/müzik/metin YZ; hedef "AI slop"tan kaçınmak
- [Platform önceliği](project-platform-priority.md) — ilk sürüm Windows + Mac; Linux/Deck sonra

## Canlı durum
- [Co-director durumu 2026-10-26](codirector-state-2026-10-26.md) — **güncel**: c7 Ürün arayüzü (U6, UE kare turu), d5 Olaylar (7b → adım 8); Erdem'de UK, UM, CLAUDE.md, yeni hedef gösterimi
- [Ürün arayüzü devam 2026-10-26](urun-arayuzu-devam-2026-10-26.md) — c7: UD2, UD1, I01, U2…U5 commit'li
- [Temizlik task 2026-10-26](temizlik-task-2026-10-26.md) — BİTTİ: 1–33, HARITA emekli → kod haritası; Erdem'de 5 karar
- [Co-director durumu 2026-10-23](codirector-state-2026-10-23.md) — önceki durum (eski)
- [Co-director session 2026-10-07](codirector-session-2026-10-07.md) — oturum devirleri; hedef 5.000 satış
- [Co-director Opus 2026-10-11](codirector-session-2026-10-11-opus.md) — playtest kararları, PRD_EKIP_VERIM_DESTEK
- [Sonraki oturumda gözden geçir 2026-10-12](next-session-review-2026-10-12.md) — menü arka planı, jenerik, müzik lisansı, ikon kaynağı

## Strateji
- [Unicorn değerlendirmesi 2026-10-07](unicorn-assessment-2026-10-07.md) — %85 bu build ile olmaz; 4 kırık alan, 6 adımlık sıra
- [Strateji el kitabı 2026-10-19](strateji-el-kitabi-2026-10-19.md) — `docs/strateji/EL_KITABI.md`; Next Fest Haziran 2027 önerisi; K1–K5
- [Ana resim 2026-10-19](ana-resim-2026-10-19.md) — beş basamaklı merdiven; İncil artifact'i; 5 açık karar
- [Steam Coming Soon taslağı](steam-coming-soon-draft-2026-10-19.md) — sayfa metni TR/EN, 3 sanat yönü, 5 karar
- [Sanat yönü 2. tur 2026-10-20](sanat-yonu-ikinci-tur-2026-10-20.md) — 3 yön + ortak taban; 4 karar bekliyor
- [Pazar merdiveni → Pazar 2](pazar-merdiveni-2026-10-20.md) — merdiven reddedildi; ERP araştırması, Erdem'e 11 soru

## Bitmiş görevler ve fazlar
- [Faz A 2026-10-16](faz-a-execution-2026-10-16.md) — K1…K8, RAPOR_A; Erdem'e 10 soru
- [Faz B olaylar](faz-b-olaylar-task-2026-10-16.md) — B1…B9, RAPOR_B; `fc6b392` push edildi
- [Faz C](faz-c-execution-2026-10-18.md) — KAPANDI 10-22; RAPOR_C; C3a/C3b/C5/C6/C8 park
- [Faz Q](faz-q-execution-2026-10-18.md) — 3. tur bitti; RAPOR_Q; 2★ Çekirdek önerisi Erdem'de
- [Faz D ekip/sprint](faz-d-ekip-sprint-task-2026-10-18.md) — KAPANDI 10-24; RAPOR_D; ölçüm tuzakları
- [Sprint/ürün fazları A–E](sprint-urun-phases-2026-10-16.md) — görevler `docs/tasks/faz_ab/`; kümeleme reddedildi
- [Ürün arayüzü task 2026-10-23](urun-arayuzu-task-2026-10-23.md) — U0, U1, U1s
- [Ürün rev 7 sprint döngüsü](urun-rev7-faz-a.md) — SprintSystem/Catalog/Bridges, şema 15
- [Ürün rev 7 kalibrasyon](urun-rev7-calibration-round.md) — Erdem'in 8 kararı, 17/18 kabul
- [UI redesign Menajer Masası](ui-redesign-menajer-2026-10-02.md) — 11 karar, koyu sıcak dil; F1–F7
- [UI Lab task](ui-lab-task-2026-09-30.md) — üç yön reddedildi → MENAJER seçildi
- [Ekip verimi/destek](ekip-verim-destek-task-2026-10-11.md) — G1…G6
- [Ana menü task](ana-menu-task-2026-10-11.md) — 15 commit; makine `amn`
- [SAAT + Onarım 1](saat-onarim1-task-2026-10-10.md) — K1–K10; K7 finans eşiği ❌
- [Açılış task](acilis-task-2026-10-10.md) — PRD_ACILIS; commit makinesi (özel index + CAS)
- [Mahalle task](neighbourhood-task-2026-10-10.md) — `210c2a8`; PNG bayt tuzağı
- [Render + asset lab](render-assetlab-task-2026-10-09.md) — 11 commit; F5 onayları bekliyor
- [Render tavanı araştırması](render-ceiling-research-2026-10-10.md) — MSAA/SSAO/SDFGI/SSAA; push edildi
- [Weekly time model](weekly-time-model-task.md) — oyun günü = hafta; ofis temposu `74d0b8b`
- [Yazar ajanı pilotu](writer-agent-pilot-2026-10-08.md) — 3 commit; seçici-koşul tuzağı
- [Rakip Dünyası yönü](rival-world-prd-2026-10-02.md) — SOS yönü, v6 PRD; I1 Piyasa tamam, sıradaki I2
- [Meeting flow task](meeting-flow-task-2026-09-29.md) — satış ve VC görüşmeleri v3; push edildi
- [Office 3D task](office-3d-task-2026-09-27.md) — izometrik ofis; onay bekleyenler ACIK 60–74
- [Office characters task](office-characters-task-2026-09-28.md) — Quaternius karakterler, rig tuzakları
- [Ekip rev 11 rebuild](ekip-rev11-rebuild.md) — GDD .docx'te; tasarım 467a4852
- [Ekip rev 11 kapanış turu](ekip-rev11-closing-round.md) — push edildi 08-24; HBox asgari-boyut tuzağı
- [Paralel task'lar 2026-08](parallel-tasks-2026-08.md) — ticker rework + Finance bug-fix
- [Localization TR+EN](localization-tr-en-task.md) — Faz 1 teslim; Faz 2 HOLD
- [Event authoring → Frank Voice Pass](event-authoring-batch1.md) — Y-arc durdu; gün 1 = 1 Oca 2026
- [Frank v6 landing pass](frank-v6-landing-pass.md) — 128 string; FRANK_UNWIRED.md
- [Event layer audit 2026-08-21](event-layer-audit-2026-08-21.md) — 28 olay envanteri; ulaşılamayan yaylar
- [B2B Sales System](b2b-sales-system.md) — müşteri yaşam döngüsü motoru (A–E)
- [Product lifecycle consult](product-lifecycle-consult.md) — HALF_SAT=50 sorunu Kalibrasyon A'da
- [Design work lessons](design-work-lessons.md) — kör estetik dispatch başarısız
- [Project Unicorn current stage](project-unicorn-current-stage.md) — 2026-07 → 08-31 kronolojisi
- [GitHub repo](github-repo-projectunicorn.md) — public (Erdem private yapacak); public diye push bekletilmez; docs/tasks + hafıza + kayıt repoda (`docs/tasks/claude_devir/`)

## Teknik tuzaklar ve olgular
- [Shared-tree revert rule](shared-tree-revert-rule.md) — `git checkout -- <path>` YASAK
- [Partial staging](partial-staging-shared-tree.md) — hunk `git apply --cached` + `checkout-index` ile doğrula
- [Concurrent session hazard](concurrent-session-hazard.md) — sahipsiz değişikliği commit etme
- [Smoke verification cadence](smoke-verification-cadence.md) — tam süit yalnız entegrasyonda; parse hatası kapısı
- [Sealed-source port discipline](sealed-source-port-discipline.md) — pose/materyal deltası okunuşu değiştirir
- [Godot import/class-cache](godot-import-cache-gotchas.md) — bayat .ctex; sıra import → ısınma → gate
- [Godot raster/sharpness](godot-raster-sharpness-facts.md) — LINEAR'da mipmap yok; --render-probe
- [Godot MCP runtime](godot-mcp-runtime-verification.md) — inject-mouse-click kırık; get_run_ledger
- [Godot theme engine](godot-theme-engine-facts.md) — ata tema önceliği, CanvasLayer kırığı, has_font
- [Godot lightmap bake](godot-lightmap-bake-gotchas.md) — sahipsiz ışık fırınlanmaz
- [UI design system](ui-design-system.md) — UiTokens → build_theme → master_theme + UiFactory
- [Font Duruşması](font-durusmasi-specimen.md) — koyu yüzler Archivo + Source Serif 4 (`de0182ed`)
- [Build Bar segment grammar](build-bar-segment-grammar.md) — tek BuildBar ×3 ev sahibi
- [Ekip area/job adapter](ekip-area-job-adapter.md) — ALAN = İŞ listesi
- [strings.csv surgery](strings-csv-surgery.md) — byte-span splice, asla rewrite; token'lar iki dilde aynı
- [Card text token rules](card-text-token-rules.md) — {slot} yuva adı, {seam:} CSV'ye girmez
- [Unresolvable card tokens](unresolvable-card-token-class.md) — gate `card_body_tokens_resolve`
- [Sözlükte kolsuz fiiller](vocab-verbs-without-executor.md) — 60 fiilin 49'u uygulanıyor
- [Memnuniyet deltası bir tikte siler](satisfaction-delta-drift.md) — kalıcı iz yalnız trust_offset ile
- [Bash heredoc backslash](bash-heredoc-backslash-hazard.md) — büyük patch Write ile, `od -c`
- [Browser render rig](browser-render-rig-hazards.md) — arka plan sekmesi donar; --app penceresi
- [Claude Design source retrieval](claude-design-source-retrieval.md) — tasarım JS'ini bayt-güvenli alma
- [Artifact page verification](artifact-page-verification.md) — `new Function` + başsız Chrome `--dump-dom`
- [Background shell memory reap](bg-shell-memory-reap.md) — 32 GB'den beri testler paralel; pencereli koşu tek
- [Lost session recovery](lost-session-recovery.md) — cse_ kimliği, journal, elle devam betiği
- [TaskStop yetim alt süreç](taskstop-orphan-child.md) — yetim betik kilidi alır: ps ile bul, kill
- [Workflow ajanına mesaj kopya doğurur](workflow-agent-message-duplicates.md) — koşan ajana SendMessage kopya başlatır
- [WebSearch session budget](websearch-session-budget.md) — oturum başına 200 arama; `searches`/`evidence` alanı
- [Olaylar uygulaması 2026-10-26](olaylar-uygulama-2026-10-26.md) — BİTTİ 2026-10-27: Olaylar 1…7b (son `8fbb189`, push yok), sayfa LaMBoCBjGfiyEht9w5sA9j, devir GOREV_OLAY_UYGULAMA.md sonunda; açık kararlar dosyada
