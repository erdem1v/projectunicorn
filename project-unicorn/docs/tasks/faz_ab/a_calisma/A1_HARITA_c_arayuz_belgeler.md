# A1c · Bağlantı haritası: arayüz ve belgeler katmanı
HEAD 1faeb82, 2026-10-16. Kapsam: PRD §6 "Arayüz" ve "Belgeler". Salt okuma; her satır açılmış bir dosyaya dayanır.
Karar n = PRD §2 kararı. Dilim = PRD §8 K1..K8 (K1 Görevler matrisi + kurucu · K2 Hotfix/koşu/Kaçırıldı/Hata yığını silinir · K3 tek depo + rastgele dağılım + şema 16 (1) · K4 düzeltme kartı + sürüm notu · K5 etki zinciri, aşınma ve L silinir, itibar, kollar, göç (2) · K6 hat paneli + Destek kartı · K7 sönük düğmeler · K8 ölü kod + belgeler).
"(a)" ve "(b)" öteki iki okuyucunun katmanıdır (sistemler; olay motoru, veri, kayıt, araçlar). Burada yalnız arayüzün okuduğu yerde, o satırın arayüze etkisi için anılırlar.

## 0. Öne çıkan bulgular (ayrıntı aşağıda, risk özeti §15'te)
1. **Görevler matrisinde kurucu satırı yoktur.** `hr_assignments.gd:42` yalnız `get_employees()` çizer (`character_registry.gd:41-46`, kategori "employee"). Oyuncunun kurucuya iş atayabildiği hiçbir arayüz yolu yoktur (`assign_job` çağıranları: `hr_tab.gd:468` yalnız çalışan satırları, `rnd_system.gd:304`, `main.gd` debug, `run_probe.gd`). Karar 13'ün "Yapım ve Destek tutan kurucu" durumu bugün yalnız bot ve debug ile doğar. Ekip GDD §12 de "Kurucu bu matriste bulunmaz" der (docx paragraf 779). Smoke `_case_gorevler_has_no_founder` (`endgame_smoke.gd:13235`) bunu kilitler.
2. **Ofiste kurucu sprint açılışına her zaman yürür.** `office_people.gd:454` `a.founder or team.has(...)`. K0'ın "kurucu `team()`'den çıkınca açılıştan çıkar" notu kodla örtüşmez.
3. **`HR_AREA_MEANING_*` oyuncuya hiç çizilmez.** Tek okuyucu `HRConstants.role_area_meaning` (`hr_constants.gd:1180`); onu yalnız smoke çağırır (`endgame_smoke.gd:7356`). Test işinin "canlı hata aşınması" vaadinin gerçekten çizilen tek yeri `ONB_SKILL_QA_DESC` (onboarding adım 2, `origin_traits_step.gd:259`).
4. **Canlı modelde `customer.tickets` hep 0'dır** (`product_model.gd:190`); `area_panel.gd:234-236` "N ticket" dalı canlıda erişilemez, yalnız fikstürde (`product_fixtures.gd:359`) çizilir.
5. **Ekip GDD'de "canlı aşınma Test alanının işi" cümlesi birebir yok.** `GDD — EKİP MODÜLÜ vson.docx` paragraf taraması "aşınma" bulmadı. En yakın metinler: `GUNCELLEMELER.md:611` ("Test beta keşif hızını ve Kararlılık tabanını oynatır") ve docx §12.0 tablosu (paragraf 787-789 "Test / beta keşif hızı"), paragraf 1039 ("hata oranı · beta keşif hızı").
6. **Çeyrek görünümünün dar sütunu da `AreaPanel`'i kullanır** (`quarter_view.gd:55-60`, `compact=true`); ses çipi (`area_panel.gd:116-124`) ve alan cümlesi orada da çizilir.
7. **Destek kartı sürükleme tutamağıdır.** `build_hud_panel.gd:82-99` kartın her yerindeki basışı sürükleme sayar; "tıklayınca Ürün aç" (PRD §3) tık/sürükle ayrımı ister.
8. **Alan başına acil/uyarı üçgeni** (`area_panel.gd:95-96`) `urgent_tickets` eşiğine bağlı (`sprint_catalog.gd:143-150`); PRD üçgeni anmıyor, Karar 4 eşiği değişince anlamı da değişir.
9. **`hotfix_*` smoke önekleri 2026-08 yama turunun adıdır** (`endgame_smoke.gd:241-248`, HARITA:213); K2 "Hotfix siler" derken bu vakalara dokunmamalı. "hotfix" izinli ödünç kelime olarak CLAUDE.md:53 ve glossary:10'da durur.

## 1. Hat paneli (AreaPanel ve alan modeli)
| Kalem | Dosya:satır | Bugün (okur/yazar, ne yapar) | Yeni karşılığı (PRD kararı no.) | Dilim | Not |
|---|---|---|---|---|---|
| Ses katlaması durumu | area_panel.gd:10, 18, 27 | `ui_changed(open_area, voices_open)` sinyali; `_voices_open` modelden tohumlanır | Kalkar (§3 "Sesler bölümü yoktur"; Karar 12). Sinyal yalnız `open_area` taşır | K6 | `product_tab.gd:212-216` `_on_ui_changed` imzası da değişir |
| Alan satırı ses çipi | area_panel.gd:116-124, 187-198 | `area.voices.n > 0` ise `CountChip` içinde ses simgesi + sayı + "k yeni" | Kalkar. Yerine kapalı satırda "N açık hata" (Karar 1; §3) | K6 | Dar çeyrek sütununda da çizilir (quarter_view.gd:55-60); `CountChip` yalnız burada kullanılır (build_theme.gd:998) |
| Alan uyarı üçgeni | area_panel.gd:95-96 | `area.alert` doğruysa warn glifi | Anlamı Karar 4 acil eşiğine bağlı; PRD üçgeni anmıyor | K5/K6 | Veri: product_model.gd:153 → sprint_catalog.gd:143-150 (`urgent_tickets` ya da sunucu aşımı). Soru §15-7 |
| Alan cümlesi | area_panel.gd:128-130 | `area.sentence` Caption olarak yazılır | "9 açık hata" yanında "sorunsuz yürüyor" yazmaz (§3) | K6 | Cümle kaynağı sprint_catalog.gd:154-171 (alan × durum şablonu + "N açık ticket" + rakip) |
| Açık gövde: YAPILANLAR/YAPILABİLECEKLER | area_panel.gd:136-161 | Kademe kareleri; aday kartlar `SprintCard.Look.LOW` | Aday kartlar arasında düzeltme kartı kalır (Karar 5) | K4 | Hat satırı ile düzeltme kartı aynı bilgiyi iki kez verebilir (§15-4) |
| SESLER bölümü | area_panel.gd:163-183 | Başlık, katlama satırı, açılınca ses cümleleri ("Yeni" damgası) | Kalkar; yerine "yalnız hatası olan hatlar" tek satır `bug_row` (Karar 6; §3) | K6 | B2B: "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı ↑"; B2C: "Eşitleme · 5 açık hata · 300 kullanıcı ↓". Ok anlamı PRD'de yazılı değil |
| Ses sayacı çizici | area_panel.gd:186-198 | `_add_voice_counts` (`SprintUiShared.VOICES` glifi) | Silinir | K6 | `voices.svg` yalnız burada kullanılır (sprint_ui_shared.gd:12) |
| Ses katlama tıkı | area_panel.gd:273-278 | `action.emit("voices_seen", {area})` + `ui_changed` | Silinir | K6 | `product_tab.gd:248` `voices_seen` kolu, `SprintSystem.voices_seen` (sprint_system.gd:376-378, (a)) ve `GameState.product.voices_seen` (sprint_system.gd:83, (a)/(b)) birlikte gider |
| Müşteriler satırı "N ticket" dalı | area_panel.gd:234-236 | `c.request == ""` ise `PRODUCT_CUSTOMER_TICKETS` | Silinir (Karar 1, 12 "N ticket metinleri") | K6 (K8 doğrular) | Canlıda erişilemez: product_model.gd:190 `"tickets": 0` ve yalnız açık talepli müşteri listelenir (:183-194) |
| Başlık yorumu | area_panel.gd:4-7 | "…aday kartları ve sesleri" | Yorum güncellenir | K6 | CLAUDE.md §8 yorum kuralı |
| Model sözleşmesi: alan | product_model.gd:29-33 | `voices: {n,new}`, `voices_list`, `alert` | `voices*` kalkar; hat dökümü eklenir (örn. `bug_lines`) | K6 | Fikstür aynı sözleşmeyi taşır (product_fixtures.gd:519-520, 530-534) |
| Model sözleşmesi: müşteri | product_model.gd:34-36 | `tickets` alanı | Kalkar | K6 | |
| Model: `ui` | product_model.gd:23, 132 | `voices_open` | Kalkar | K6 | product_fixtures.gd:599 aynı |
| Model: alan kurucu | product_model.gd:144-161 | `voices := SprintCatalog.voices(id)` (:146), `voices` sözlüğü (:152), `voices_list` (:155), `sentence` (:151), `alert` (:153) | Hat dökümü (hat, açık hata, hesap, kullanıcı, en büyük hesap) `line_impact` / depodan okunur | K6 (veri K3, K4) | `line_impact` `{accounts, seats, top_id, top_seats}` bugün kodda yok (PRD §2 Karar 6, §14) |
| Katalog: SESLER | sprint_catalog.gd:174-198 | Açık ticket başlıkları + araştırma cümlesi + rakip çıkışı, "yeni" ayrımı (`voices_seen`, `voices_new_weeks`) | `voices()` silinir | K6 | sprint.json:33 `voices_new_weeks` da ölür |
| Katalog: ticket başlığı | sprint_catalog.gd:201-203 | `PRODUCT_TICKET_%d` dinamik anahtar, `content.ticket_titles` (sprint.json:43) | Silinir (Karar 1, 12) | K3 | Dinamik anahtar: grep `PRODUCT_TICKET_0` bulur ama okuyucuyu bulmaz (§11-B) |
| Katalog: hata/ticket dökümü | sprint_catalog.gd:624-630 | `tickets_by_line` (okuyucular: :146, :160, :261, rnd_system.gd:601, sprint_system.gd:1194) | Tek hata deposundan hat dökümü (Karar 1, 3) | K3 | rnd_system.gd:595-603 R&D "talep baskısı" notunu bu oylarla besler; GUNCELLEMELER.md:668 ona dayanır |

## 2. Düzeltme kartı (kart, etki parçaları, öngörü)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Aday düzeltme kartı üretimi | sprint_catalog.gd:261-269 | Hat başına açık ticket varsa `fix:<hat>` kartı; `urgent_tickets` ≥ eşikse efor `fix_urgent`; `card.tickets = ids` | Hat başına açık hata varsa kart; efor 1-2 hata 1, 3-5 hata 2, 6+ hata 3 (Karar 7); kademeler `sprint.json`'da tek ayar | K3/K4 | sprint.json:6 `effort.fix`, `fix_urgent`; :36 `urgent_tickets`; :42 `impact.ticket` |
| Acil yüklemi | sprint_catalog.gd:284-285 | `fix` ve `tickets.size() ≥ urgent_tickets` | Eşik ve zorunluluk Karar 4'e göre yeniden ele alınır | K4/K5 | `is_urgent` okuyucuları: sprint_catalog.gd:148 (alan uyarısı), :275 (sıralama), :809 (bot `must`); product_model.gd:417; sprint_card.gd:191 |
| Kart adı | sprint_catalog.gd:312 | `PRODUCT_FIX_CARD` "{capability} düzeltmesi" | "Fatura düzeltmesi" + kartta: hata sayısı, hesap, kullanıcı, B2B'de en büyük hesap adı ve koltuğu (Karar 6) | K4 | `top_star` / `{stars}★` yok sayılır (PRD §0 madde 1) |
| Etki satırı (fix) | sprint_catalog.gd:347-354 | `{k:"tickets", n}` + `alert_clear` | Yeni parça (hat, hata, hesap, kullanıcı, en büyük hesap) | K4 | Sözleşme: product_model.gd:74 |
| Etki parçası çizici | sprint_ui_shared.gd:287-327 (özellikle :309-311) | `"tickets","voices"` kolu `COUNT_KEYS` ile "{n} ticket kapatır/kapanır" | `tickets` kolu yeni `bugs` parçasına çevrilir; `voices` kolu silinir | K4 (voices K6) | `COUNT_KEYS` tablosu sprint_ui_shared.gd:26-29; yalnız fikstür `voices` parçası üretiyor (product_fixtures.gd:500) |
| "Acil" etiketi | sprint_card.gd:191-192 | `PRODUCT_URGENT` "Acil" uyarı üçgenli etiket | B'nin "acil durum" olayıyla karışmayacak ad (Karar 4) [TR/EN onay bekliyor] | K4 | Etiket stilleri HARITA:150 `TagWarnBox`/`TagWarnInk` |
| Kart efor/urgent alanı | product_model.gd:411-419 | `effort = roundi(SprintSystem.total(c))`, `urgent = SprintCatalog.is_urgent(c)` | Planlanmamış kartın efor ve sayıları her çizimde yenilenir; koşan kartın eforu kilitli (§4.6c) | K4 | Aday kart `stored.get(c.id, c)` anlık görüntüsü (sprint_catalog.gd:274) günlük tikle yenilenir (sprint_system.gd:1194-1199, (a)) |
| Düzeltme kartı satırı genişliği | sprint_card.gd:80-94, 126-127 | WIDE'da ad `OVERRUN_TRIM_ELLIPSIS`; öbür görünüşte 2 satır sarar; etki satırı `HFlowContainer` | Uzun hesap adı taşmamalı (§4.12 "uzun hesap adıyla") | K4 | Yeni `--product-shot=edge:<ad>` fikstürü gerekir |
| Öngörü (SPRINT SONUNDA) | sprint_catalog.gd:378-403; sprint_panel.gd:128-130 | Fix kartlarının ticket kimlikleri toplanır, `{k:"tickets", n}`; "!" kalkışı | "6 hata kapanır" (§3); önizleme N = kapanışta silinen (§4.6b) | K4 | Kapanışta gerçek sayı: sprint_system.gd:1011-1012 (`close_tickets`, (a)) |
| Karar 7 eforu | sprint.json:6 | `fix:1, fix_urgent:2` | Tek ayar, kademeli | K4 | E1 cevabı yalnız bu değerleri değiştirir |
| Fiyat/etki puanı | sprint_catalog.gd:715-719 | `w.ticket * tickets.size() + alert` | Hata sayısına göre | K3/K4 | (a) kapsar |
| Düzeltme kartı düğmeleri | product_model.gd:82-89 | `BUTTONS` tablosu | Değişmez | - | K7 yalnız görünümü değiştirir |
| Müşteri kartı "+"/"→" | area_panel.gd:244-247 | `SprintUiShared.key_button` | Karar 14 sönük/parlar | K7 | |

## 3. Sprint planı: ekip listesi, kapasite çubuğu, atananlar, Görevler
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Ekip listesi (avatarlar) | product_model.gd:204, 268; sprint_panel.gd:93-102 | `SprintSystem.team()` (Ar-Ge hariç herkes, kurucu daima) → `_person(...)`: ad, rol metni, yüz | Yalnız Yapım ekibi + Test işini tutan; Destek'teki dışarıda; Yapım+Destek yarım payla (Karar 13; §3) | K1 | Model kişisine pay (0,5) eklenmeli; avatar ipucu sprint_ui_shared.gd:210-215 pay göstermiyor (görünür yeri K1 kararı) |
| Kapasite toplamı | product_model.gd:203, 371; sprint_ui_shared.gd:116-121 | `SprintSystem.capacity()` (= Σ `team().points` × hafta, sprint_system.gd:446-450, (a)) | Aynı çağrı; `team()` payı uygular (Karar 13) | K1 | Çubuk kodu değişmez (`CapacityBar` sprint_ui_shared.gd:55-85); veri değişir. Çeyrek sütunları aynı toplamı kullanır (product_model.gd:371, quarter_view.gd) |
| Boş kadro / kimse çalışamıyor | sprint_panel.gd:119-120, 172-189; product_model.gd:260-263 | Ekip ve kart yoksa `_nobody` (Ar-Ge'ye git / işe al / `PRODUCT_GO_TEAM` Ekip'e git); kart varsa yalnız `start_reason` metni | "Sprintte kimse yoksa plan bunu söyler ve Ekip'e bağlar" (Karar 13; §3) | K1 | Boşluk: ekip boş ama kart doluysa bağ yok (yalnız metin, product_model.gd:263). `PRODUCT_TEAM_NOBODY` metni TR/EN onay bekliyor. Ek yol zaten var: product_tab.gd:249 `"team"` kolu |
| Rol uyarısı | product_model.gd:248-249 | `team` içinde `"test" in t.fits` yoksa `PRODUCT_ROLE_MISSING` | Aşama uyumu bugünkü kuralla kalır (Karar 13 sınır, D) | - | `fits` alanı `SprintSystem._fits` (sprint_system.gd:1272-1276) |
| Boştaki kişi notu | product_model.gd:251-254 | `team` içinde `role_of(id) == ""` sayılır; öneri `PRODUCT_IDLE_FIX` (koşu açılabiliyorsa) ya da `PRODUCT_IDLE_PLAN` | "Boşta" yalnız gerçekten sprintte olan ve kartsız kişiyi sayar; kartı olan kurucu "Boşta" görünmez (Karar 13) | K1; `PRODUCT_IDLE_FIX` K2 | `can_start_fix_run` K2'de gider → öneri hep `PRODUCT_IDLE_PLAN` |
| Kart atananları | product_model.gd:229, 234, 238, 484-488; sprint_card.gd:256-257 | `_people(c.assignees, team)`: atananı `team` kimlikleriyle süzer | `team()` daralınca Destek'e geçen kişi koşan kartın avatarından düşer | K1 | `assignees` yazımı (a) (`_assign`) |
| Araştıran kurucu | product_model.gd:256-259, 263 | Kurucu Ar-Ge işini tutuyorsa `rnd` metni | Değişmez | - | Matris kuralıyla çelişmez (Ar-Ge tek başına tutulur) |
| Kadroda çalışan var mı | product_model.gd:269 | `get_employees().is_empty()` → `_nobody` yolu | Aynı | - | |
| Mesai modalı sprint puanı | work_hours_modal.gd:211-228 (217-218) | `SprintSystem.week_points()` ve taslak | `team()` değişince değerler değişir | K1 | Kurucu tek başınayken de gösterilir (yorum :211) |
| İşe alım dosyası puanı | hr_atlas_modal.gd:343 | `SprintSystem.points_for(role, axes, hours)` (adayın puanı) | Değişmez (aday atanmamış, pay yok) | - | Not: pay gösterilmez, tutarlılık sorusu |
| Görevler matrisi: satırlar | hr_assignments.gd:7-8, 42-48 | Yalnız çalışanlar; başlıkta "KURUCU BURADA YOK… sprint ekibine kendiliğinden girer" | Başlık yorumu doğru olmaktan çıkar (Karar 13); kurucu satırı kararı bekliyor (§15-1) | K1 | Smoke `_case_gorevler_has_no_founder` endgame_smoke.gd:13235-13258 "exactly one job" iddiası; Ekip GDD §12 paragraf 779 |
| Görevler matrisi: kutu | hr_assignments.gd:106-128; hr_tab.gd:464-473 | İş tavanı `MAX_JOBS_PER_PERSON` (kilitli kutu "HR_ASSIGN_JOB_CAP"); tık → `CharacterRegistry.assign_job` | Aynı yazma kapısı; sprint payı bu kutulardan türetilir | K1 | `HRConstants.focus_mult` (hr_constants.gd:184, (a)) |
| Görevler etiketleri | hr_tab.gd:450-459 | `HRSystem.idle_count() + waiting_count()` ve aşırı yük etiketi | "Boşta" tanımı Karar 13 ile uyumlu kalmalı | K1 | `idle_count` sahibi (a) |
| Kurucu görev satırı | hr_system.gd:221-237; tüketiciler personal_tab.gd:92, hr_dossier.gd:143, rnd_assign_panel.gd:182 | Kurucu 2+ işteyse "Yapım · Destek"; Yapım durumunda kart yoksa `OFFICE_ACT_PLAN` (`role_of == ""`, :235) | "Sprintte kartı olan kurucu Boşta görünmez" (Karar 13) | K1 | `founder_task_state` hr_system.gd:240-262 (a) |
| Karar 13 smoke | endgame_smoke.gd (vaka adı `_case_*`) | `_case_gorevler_has_no_founder` :13235; `_case_hotfix_founder_takes_support_desk` (K0:109) | `founder_not_double_counted`, Görevler matrisi vakası | K1 | Falsification şart (CLAUDE.md memory: SMOKE kuralı) |

## 4. Sürüm notu (sprint kapanış görünümü ve modeli)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Çıkan kartlar listesi | product_model.gd:297-313 (304); sprint_panel.gd:238-246 | `shipped` = `_card(c, BITTI)`: tür simgesi, ad, efor kutusu | Düzeltme kartı satırı kapanıştaki gerçek sayıyı yazar: "Fatura düzeltmesi · 6 → 0 açık hata" (§3) | K4 | Kapanıştan sonra kartın hata listesi (sprint_system.gd:1011 `c.tickets = close_tickets(...)`, (a)) önceki sayıyı kaybeder; "6 →" için kapanış öncesi sayı saklanmalı. Sprintte yeni hata düştüyse "9 → 0" |
| Sonuç satırı (gerçekleşen) | sprint_bridges.gd:192-210 (209); product_model.gd:316-321; sprint_panel.gd:264-265 | `PRODUCT_RESULT_TICKETS_ACTUAL` "N ticket kapandı" | "6 hata kapandı" (§3) | K4 | (a) üretir, arayüz yalnız `SprintBridges.resolve` ile okur; CSV 2994-2995 |
| Sonuç satırı (beklenen) | sprint_system.gd:1107-1114 (1113) | `PRODUCT_RESULT_TICKETS_EXPECTED` | "N hata kapanmalı" | K4 | CSV 2992-2993 |
| Basın/hız/lider | sprint_panel.gd:257-286 | Değişmez | - | - | |
| Kapanışın itibar sebebi | (yok) | - | Karar 10: sebep bir yüzeyde görünür (sürüm notu / haftalık özet / Destek kartı ipucu); ajan önerir | K5 | Aday yüzey burası (§7 ile birlikte). Yeni anahtar gerekir |
| Sürüm notu fikstürü | product_fixtures.gd:131-139 (`gate`), 120-130 (`no_release`), 179-187 (`publish`) | c3 tabanlı sürüm notları var | Düzeltme kartı satırlı sürüm notu için yeni `edge:` (§4.12) | K4 | HARITA:157 ada eklenir |

## 5. Destek kartı (BuildBar, BuildBarModel, BuildHUDPanel)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Model: doğrulanmış hata | build_bar_model.gd:30, 50 | `ProductState.bugs_confirmed()` | Tek açık hata sayısı (Karar 1) | K3 (okuma), K6 (yüzey) | 11 okuyucudan biri (K0) |
| Model: gelen bildirim | build_bar_model.gd:31, 51 | `ProductState.reports_incoming()` | Kart "Gelen" göstermez (§3) | K6 | Sayaç hayatta kalıp kalmayacağı (a) kararı (sistem: `support_system.gd:123, 357`) |
| Model: kaçırılan | build_bar_model.gd:32, 52; build_bar.gd:151 | `ProductState.reports_missed()` → `BUILD_SUPPORT_MISSED` | "Kaçırıldı" kalkar (Karar 12) | K2 | CSV 592 |
| Model: düzeltme koşusu | build_bar_model.gd:14-19, 33-34, 53-63, 72-73 | `fix_run_active`, `fixed`, `fill`, `percent`, `decision_key`, `decision_enabled`, `refusal_key`, `REFUSAL_KEYS` | Hepsi kalkar (Karar 12) | K2 | `fingerprint()` (:71-73) yeni alanlarla yeniden kurulur; `smoke` `destek_survives_ship` (:13195-13222), `fix_run_ships_subset` bu modeli çağırır |
| Model: bölünmüş odak notu | build_bar_model.gd:24-26, 63-66; build_bar.gd:147-148 | Masadaki biri aşırı yüklüyse `BUILD_SPLIT_FOCUS` | Muhtemelen kalır (Karar 13 yarım pay) | K6 | PRD §3 "tek satır" ile ilişkisi yazılı değil (§15-6); smoke `split_bars_name_their_cause` :14845-14871 |
| Kart: DESTEK satırı | build_bar.gd:87-102, 149-153 | "DESTEK", Doğrulanmış {n}, Gelen {n} ya da kaçırıldı; yüzde ve ilerleme çubuğu (koşu sürerken) | Tek satır "7 açık hata ›"; düğme, yüzde, Doğrulanmış/Gelen yok (§3) | K6 | `_percent_label`, `_progress`, `PROD_PERCENT` okuyucusu burada düşer (CSV 594 öbür okuyucular: rnd_ui_shared.gd:113, research_bar.gd:150) |
| Kart: eylem düğmesi | build_bar.gd:104-120, 171-178 | `FloatAction` düğmesi `start_fix_run`/`end_fix_run`; gerekçe `_refusal_label` | Kalkar (Karar 12) | K2 | `PLAY_ICON`/`END_ICON` sabitleri build_bar.gd:21-22 |
| Kart: tıklama | build_hud_panel.gd:82-99 | Kartın her yeri sürükleme tutamağı | Tık → Ürün penceresi, en çok hatası olan hattın alanı açık (§3) | K6 | Mekanizma önerisi: `EventBus.tab_changed.emit("product")` + `window_layer.gd:140 get_current_page_body()._set_ui(area_id, "open_area")` (product_tab.gd:207-210); fikstürde aynı kalıp var (main.gd:3187). Tık-sürükle eşiği gerekir; eşitlikte hat seçimi belirsiz |
| Kart: otomatik başlama notu | build_bar.gd:122-127, 164-166 | `PRODUCT_AUTO_STARTED` | PRD sessiz | K6 | Soru §15-6 |
| Kart görünürlüğü | build_bar_model.gd:41-43; build_hud_panel.gd:70-73 | `mvp_shipped` yoksa kart yok | Aynı | - | |
| Kart sinyalleri | build_bar.gd:44-51 | `build_phase_changed`, `day_advanced`, `language_changed`, `assignment_changed`, `build_progress_changed`, `employee_training_changed`, `product_state_changed` | `fix_run_started/finished` EventBus sinyalleri (event_bus.gd:147-148) kartı beslemiyor; K2 siler | K2 | (b) |
| BuildBar sahnesi | scenes/ui/components/BuildBar.tscn; BuildHUDPanel.tscn:32 | Sahne yalnız betik bağlar | Değişmez | - | |
| desk_shut çekimi | main.gd:1289-1294 | Canlı B2C, bildirim bayrakları (`REPORTS_INCOMING`/`REPORTS_WEEK_NET`) 12 | Yeniden kurulur, silinmez (PRD §4.12; YURUTUCU_NOTU 1) | K2 (yeniden kur), K6 (son hâl) | Artık tek açık hata deposuna hata yazmalı (`ProductState.add_bugs`, K3) |
| fix_run çekimi | main.gd:1295-1306 | `BUGS_CONFIRMED`, `FIX_RUN_*` bayrakları | Silinir | K2 | CLAUDE.md §12 yalnız `desk_shut`'ı anar |

## 6. Gelen kutusu şikâyet maili ve Satış'taki Risk rozeti
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Risk sebebi | inbox.gd:208-213 | `ProductSystem.live_bug_count() > B2BConstants.COMPLAINT_BUG_GATE` ise `SALES_REASON_OUTAGE`; yoksa `trust_offset ≥ 0` → `SALES_REASON_STABILITY`, aksi `SALES_REASON_SATISFACTION` | Hesabın kullandığı hatlardaki açık hata memnuniyet hedefini düşürür (Karar 9); sebep bu hata sayısına bakar (L ve `COMPLAINT_BUG_GATE` kalkar) | K5 | ACIK_KARARLAR 39 bu satırın çelişkisidir; `B2BSalesSystem.risk_voice` ayrı sayaç okur (b2b_sales_system.gd:504, (a)). `SalesArchetypes.uses_axis` gerekir (kodda yok) |
| Gelen kutusu Risk hatırlatması | inbox.gd:108-121 (118) | Risk'teki B2B hesap için `INBOX_SUBJ_RISK`, "Sebep: {reason}" | Aynı sebep satırı yeni kuralla | K5 | `Inbox.desk()`; konu CSV 3212 |
| Satış hesap kartı Risk rozeti | sales_tab.gd:22-24, 529-551 (542) | `PHASE_TAGS` `SALES_CHIP_RISK`; Risk'te `INBOX.risk_reason(c)` satırı | Sebep satırı yeni kuralla | K5 | Rozet kodu değişmez |
| Sektör şikâyet metni | b2b_constants.gd:56, 78, 111 | `COMPLAINT_BUG_GATE` 6; `B2B_COMPLAINT_<SEKTÖR>` türetilmiş | Kapı kalkar | K5 | (a) kapsar; CSV 702-723 |
| Risk fikstürleri | main.gd:1044, 1113-1116, 1177 | `mvp_live_bug_count` bayrağı 12 / `COMPLAINT_BUG_GATE` | Yeni hata deposu fikstürü | K5 | `--sales-shot` kareleri (`edge`, `risk_stability`, `deals`) |
| Satış toplantısı sorusu | sales_probes.gd:62, 135, 143-152; sales_meeting_system.gd:409, 426 | `confirmed_bugs` olgusu; "probe_stability_bugs" ve a_strength kapısı `confirmed_bugs ≤ 2` | Soru ve cevapları silinir; kapı kalkar (Karar 8) | K5 | (a)/(b) kapsar; CSV 2489, 2519-2521 ve 2516 aşağıda §11 |

## 7. TopBar itibar değeri
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Değer etiketi | top_bar.gd:220; TopBar.tscn:113-121 | `$RepValue.text = str(GameState.reputation)`; anahtar `FIN_CAP_REPUTATION` (CSV 562); ipucu yok | İtibar sıfırın altına inebilir, taban −10 (Karar 10) | K5 | Negatif ("-10") yerleşimi ve TR/EN, 1,25 ölçek denenmemiş; runway'in ipucu kalıbı mevcut (top_bar.gd:215-216) |
| Güncelleme | top_bar.gd:104 | `reputation_changed` → yenile | Aynı | - | |
| Alt sınır | game_state.gd:346-349 | `clampi(value, -10, 100)` | Zaten −10 (YURUTUCU_NOTU 2) | - | `max(0, …)` taban yazılmaz |
| Sebep yüzeyi | (yok) | Hata yüzünden itibar düşünce sebep görünmez | Sebep bir yerde görünür (Karar 10) | K5 | Adaylar: TopBar ipucu, sürüm notu (§4), Destek kartı ipucu |
| Okuyan yüzeyler (arayüz dışı) | vc_pitch_system.gd:1193; sales_system.gd:188 | VC itibar sorusu (`VC_Q_REPUTATION`, CSV 1323-1324) ve B2C kitle | Kalır | - | (a)/(b); anlatı fonu toplantı ihtimali de kalır (Karar 10) |

## 8. Ekip iş anlamı, onboarding becerisi (aşınma vaadi), Test alanı
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| İş anlamı satırı | hr_constants.gd:1178-1183 (`role_area_meaning`), :349-354 (`_derived`); CSV 470 | Okuyucu yok (yalnız smoke endgame_smoke.gd:7356); "Beta keşif hızı ve canlı hata aşınması" | Vaat kalkar (Karar 12): "Beta keşif hızı" | K5 | Dinamik anahtar `HR_AREA_MEANING_<ROL>_<ALAN>`. Satırı silmek smoke :7356'yı düşürür |
| Onboarding beceri açıklaması | founder_constants.gd:111-116 (113); origin_traits_step.gd:259; CSV 482 | `ONB_SKILL_QA_DESC` "…canlı ürünün aşınma hızı." onboarding adım 2'de çizilir | Vaat kalkar (Karar 12) | K5 | TR/EN onay bekliyor. Görsel: `--onboard-shot=2:random` |
| AREA_QA yorumu | hr_constants.gd:15 | "Test - beta keşif hızı, canlı bug aşınması" | Yorum güncellenir (PRD §6) | K8 (K5 ile aynı commit olabilir) | hr_constants.gd:14 ("bug oranı") ve :17 ("bilet") ayrıca bakılır |
| Yazılım/Test "hata oranı" metinleri | CSV 468, 471 | `HR_AREA_MEANING_DEVELOPER_ENGINEERING`, `..._TESTER_ENGINEERING`: "Geliştirme hızı ve hata oranı" | A'da dokunulmaz (Test'in etkisi D'dedir) | - | Soru §15-9 |
| "Bilet çözümü" | CSV 473 (`HR_AREA_MEANING_CUSTOMER_REP_CUSTOMER_SUCCESS`); hr_constants.gd:17 | "Bilet çözümü ve churn" | Karar 12 "N ticket metinleri" kapsamında mı? | K5/K8 | Soru §15-9 |
| Titiz huyu | CSV 866 (`HR_TRAIT_DOUBLE_CHECKER_EFFECT`) | "Geliştirmede çok daha az hata çıkarır" | D'nin konusu | - | Dokunma |

## 9. Ofis (3B kişiler)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Sprint açılışına kim yürür | office_people.gd:93-98, 177, 451-454 | `sprint_started` → `_kickoff = team().map(id)`; toplantı odasına `a.founder or team.has(id)` | `team()` Karar 13'e göre daralır; kurucu hâlâ `a.founder or` ile her zaman katılır | K1 | Karar gerekir (§15-2). Oda yoksa `_kickoff` boş |
| Atama değişiminde yenileme | office_people.gd:85, 93-95 | `assignment_changed` ve sprint başında `_on_assignment_changed` | Aynı | - | |
| Rol animasyonu | office_people.gd:30-41, 666-672 | `_work_of`: `role_of` doluysa `SPRINT_WORK`; kurucu `founder_passive_care` → "phone" yoksa "plan"; çalışan `JOB_WORK[assigned_job_ids[0]]` | `role_of` (a) takımla uyumlu; masa payı değişince kurucu "phone" kuralı K1'de yeniden doğrulanır | K1 | `JOB_WORK` Test → "coffee" (kartsız tester); Destek → "phone" |
| Destek kartı ofiste | (BuildHUDPanel, sağ üst) | §5 | §5 | K6 | Ofis karesi `--office-shot=<ofis>:<saat>:desk_shut` |

## 10. Ürün sekmesi kabuğu, varlıklar ve tema
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| Sekme yerel durumu | product_tab.gd:7-8, 212-216 | "ses katlaması" sekmenin yerel durumu; `_on_ui_changed(open_area, voices_open)` | `voices_open` kalkar | K6 | Üst yorum satırı 7-8 da güncellenir |
| Sekme eylem tablosu | product_tab.gd:231-256 (248, 249) | `"voices_seen"` → `SprintSystem.voices_seen`; `"team"` → Ekip | `voices_seen` kolu silinir; `"team"` K1'in boş-ekip bağı için kalır | K6, K1 | |
| Kaynak yokken eylemler | product_tab.gd:229-231 | Fikstür tablosuyla "aynı türler" | Fikstür de güncellenir | K6 | product_fixtures.gd:202-206 `voices_seen` kolu |
| Yeniden kurma sinyalleri | product_tab.gd:95-97 | `product_state_changed`, `day_advanced`, `desk_changed` | Hata düşünce de `product_state_changed` yayınlanmalı (hat paneli bayat kalmasın) | K3 | (a) yayın noktası |
| ses simgesi | assets/icons/product/voices.svg (+ .import); sprint_ui_shared.gd:12 | Yalnız `SprintUiShared.VOICES` kullanır | Silinir | K6/K8 | |
| `bug.svg` | sprint_ui_shared.gd:13; sprint_panel.gd:99 | Rol uyarısı notunda | Kalır; hat satırı simgesi olabilir | - | |
| `CountChip` tema varyasyonu | build_theme.gd:997-998; HARITA:150 | Yalnız area_panel.gd:118 | Hat satırı yeniden kullanmazsa ölü | K6/K8 | Tema yeniden üretimi ve `THEME_STAMP` (ui_tokens.gd:44) yalnız stil değişirse |
| Kart düğmeleri: sönük/parlak | sprint_card.gd:17-19, 108-113, 142-144, 219-232, 315-320; build_theme.gd:974, 995-996, 1017-1020 | `BUTTONS_ALWAYS` = ADAY, KİLİTLİ; `BUTTONS_ON_HOVER` = SPRINT_PLAN, SPRINT_AKTIF, PLANLANAN, DEVREDEN (hover'da `_hover_bar.visible`); düğme varyasyonları `IconKey`, `CardKeyText`, `CardKeys(+Planned)` | Hepsi her zaman görünür ve sönük, kart üstüne gelince parlar (Karar 14) | K7 | Tema üretimi iki `.tres` yeniden yazar: önce `git diff -- themes/` ve kopya scratchpad'e (PRD §8); `project.godot`'a dokunulmaz |
| Kart anahtar düğmesi | sprint_ui_shared.gd:31-32, 234-247 | `key_button`: glif düğme / "çıkar" metni | Sönük görünüm tema üzerinden | K7 | |
| Çeyrek görünümü | quarter_view.gd:43-60, 172 | `AreaPanel(compact)` + MINI kartlar | MINI kartta düğme yok | K6 doğrular | §0 madde 6 |

## 11. localization/strings.csv: silinecek / yeniden yazılacak anahtarlar
CSV satır numaraları fiziksel satırdır (`grep -n`). Okuyucu sütunu: kod dosyası:satır. "Dinamik" = anahtar kod içinde birleştirilerek kurulur (düz arama kaçırır, ayrıca §11-B).

### 11-A. Anahtar tablosu
| Kalem | Dosya:satır | Bugün (okuyucu) | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| PRODUCT_VOICES, _COUNT, _COUNT_ONE | CSV 2809-2811; area_panel.gd:166, 193 | SESLER başlığı, "n ses" | Sil (§3) | K6 | `_COUNT*` `Fmt.count_key` ile (dinamik sonek) |
| PRODUCT_NEW_COUNT, PRODUCT_NEW_STAMP | CSV 2812-2813; area_panel.gd:181, 197 | "k yeni", "Yeni" | Sil | K6 | |
| PRODUCT_RESEARCH_VOICE_CORE/ONBOARDING/GROWTH/INTEGRATIONS/TRUST/REVENUE | CSV 2977-2982; sprint_catalog.gd:192 | Dinamik `"…VOICE_" + area.to_upper()` | Sil (`voices()` ölür) | K6 | Araştırma bilgisi başka yüzeyde yok; `research_done` kartlar için kalır |
| PRODUCT_RIVAL_VOICE | CSV 2983; sprint_catalog.gd:196 | Rakip çıkışı sesi | Sil | K6 | Rakip bilgisi `PRODUCT_AREA_RIVAL` (CSV 2968) ve alan bayrağında kalır |
| PRODUCT_CUSTOMER_TICKETS, _ONE | CSV 2826-2827; area_panel.gd:236 | Canlıda erişilemez dal | Sil | K6/K8 | Dinamik sonek `count_key` |
| PRODUCT_AREA_TICKETS, _ONE | CSV 2966-2967; sprint_catalog.gd:165 | "{n} açık ticket" alan cümlesinde | "N açık hata" (§3 alan satırı) | K6 | Metin TR/EN onay bekliyor |
| PRODUCT_TICKET_0..2 | CSV 2974-2976; sprint_catalog.gd:203 | Dinamik `"PRODUCT_TICKET_%d"` | Sil (Karar 1) | K3 | + sprint.json:43 `ticket_titles` |
| PRODUCT_FX_TICKETS_CLOSE, _CLOSE_ONE, _CLOSED, _CLOSED_ONE | CSV 2854-2857; sprint_ui_shared.gd:27, 311 | Kart/öngörü etki parçası | "{n} hata kapatır/kapanır" | K4 | `COUNT_KEYS` tablosu |
| PRODUCT_FX_VOICES_CLOSE(+_ONE), _CLOSED(+_ONE) | CSV 2858-2859, 2929-2930; sprint_ui_shared.gd:28, 311 | Yalnız fikstür parçası üretir | Sil | K6 | product_fixtures.gd:500 |
| PRODUCT_RESULT_TICKETS_EXPECTED(+_ONE), _ACTUAL(+_ONE) | CSV 2992-2995; sprint_system.gd:1113; sprint_bridges.gd:209 | Sürüm sonucu cümleleri | "N hata kapanmalı / kapandı" | K4 | Dinamik sonek `count_key` |
| PRODUCT_IDLE_FIX | CSV 2840; product_model.gd:254 | Boşta notunun önerisi, koşu açılabiliyorsa | Sil | K2 | `PRODUCT_IDLE`, `_ONE`, `PRODUCT_IDLE_PLAN` kalır |
| PRODUCT_URGENT | CSV 2847; sprint_card.gd:192 | "Acil" | Yeni ad (B ile karışmaz) | K4 | TR/EN onay bekliyor |
| PRODUCT_FIX_CARD | CSV 2971; sprint_catalog.gd:312 | "{capability} düzeltmesi" | Hat, hata, hesap, kullanıcı, en büyük hesap | K4 | |
| PRODUCT_AREA_CORE_ENOUGH, _STRONG; PRODUCT_AREA_TRUST_ENOUGH, _STRONG | CSV 2944-2945, 2960-2961; sprint_catalog.gd:159 | Dinamik `"PRODUCT_AREA_%s_%s"`; "Temel iş sorunsuz yürüyor", "Ürün güvenilir çalışıyor" | Açık hata varken çelişmez (§3) | K6 | PRD adıyla anar CORE_ENOUGH ve TRUST_ENOUGH; STRONG da hata varken çelişebilir |
| PROD_FIX_RUN_START, PROD_FIX_RUN_END | CSV 1262-1263; build_bar_model.gd:59 | Düğme metinleri ("Hotfix yayınla · {n} düzeltildi") | Sil | K2 | |
| FIX_RUN_REFUSED_NO_BUGS | CSV 593; build_bar_model.gd:17 | Düğme gerekçesi | Sil | K2 | |
| BUILD_SUPPORT_MISSED | CSV 592; build_bar.gd:151 | "Gelen n · bu hafta m kaçırıldı" | Sil | K2 | |
| BUILD_SUPPORT_CONFIRMED, BUILD_SUPPORT_INCOMING | CSV 590-591; build_bar.gd:150-151 | "Doğrulanmış n", "Gelen n" | Sil; yerine "N açık hata ›" anahtarı | K6 | K0: K2'de kartta kalır |
| BUILD_BUSY_NOBODY | CSV 565; build_bar_model.gd:18; rnd_system.gd:352 | Düğme gerekçesi + Ar-Ge okuyucusu | Anahtar kalır (rnd_system) | K2 | Yalnız build_bar_model okuyucusu düşer |
| BUILD_SPLIT_FOCUS, BUILD_PHASE_SUPPORT | CSV 566, 589; build_bar_model.gd:65; build_bar.gd:149 | Bölünmüş odak notu, "DESTEK" | Kalır | - | §15-6 |
| PROD_PERCENT | CSV 594 | Okuyucular: rnd_ui_shared.gd:113, research_bar.gd:150, build_bar.gd:155 | Kalır | - | build_bar okuyucusu K2/K6'da düşer |
| EFFECT_FIX_RUN_STARTS | CSV 3054; chips.gd:44 | Çip | Sil | K2 | (b); lint.gd:323, 341 `fix_run_start` fiili de gider |
| EV_PRODUCT_BUG_PILE_TITLE/FIX/LATER/LOCK_FIX/EXPIRED | CSV 3094-3098; bug_pile.json | Hata yığını kartı | Sil | K2 | (b) |
| PROD_TIP_BUGS | CSV 1239; okuyucu yok | Ölü anahtar (detail_view.gd yok) | Sil | K8 | FRANK_VOICE_INVENTORY.md:66 satırı ve ALL_SCENES_DRAFT.md:463 |
| VC_Q_BUGS, VC_Q_BUGS_MONO | CSV 1325-1326; vc_pitch_system.gd:1200 | "Ürünün hata kaynıyor" sorgusu | Sil (Karar 8) | K5 | VC itibar sorusu (CSV 1323-1324) kalır |
| HUNT_CB_BUGS | CSV 834; vc_pitch_system.gd:503, 1291 | `bugs_under` geri dönüş koşulu "Aktif hata < n" | Yeni koşul "En zayıf eksen > 40"; göçle `bugs_under` kalmaz (§4.7) | K5 | Yeni anahtar gerekir |
| SALES_PROBE_PROBE_STABILITY_BUGS | CSV 2489; sales_meeting_system.gd:409 | Dinamik `"SALES_PROBE_%s"` | Sil (Karar 8) | K5 | |
| SALES_ANS_PROBE_STABILITY_BUGS_A_ADMIT / _A_PROMISE / _A_REFERENCE | CSV 2519-2521; sales_meeting_system.gd:426 | Dinamik `"SALES_ANS_%s_%s"` | Sil | K5 | |
| SALES_ANS_PROBE_STABILITY_RECORD_A_STRENGTH | CSV 2516 | "…açık hata listesi kısa." | Hatayı anmaz; kapı `confirmed_bugs ≤ 2` (sales_probes.gd:135) kalkar | K5 | |
| SALES_REASON_OUTAGE | CSV 144; inbox.gd:212 | "sık kesinti şikayeti" | Hesabın kullandığı hatlardaki açık hata sebebi | K5 | TR/EN onay bekliyor |
| SALES_REASON_STABILITY, SALES_REASON_SATISFACTION | CSV 145-146; inbox.gd:213 | Risk sebepleri | Kural gözden geçirilir (ACIK_KARARLAR 39) | K5 | |
| HR_AREA_MEANING_TESTER_QA | CSV 470 | §8 | "Beta keşif hızı" | K5 | |
| ONB_SKILL_QA_DESC | CSV 482 | §8 | Vaat kalkar | K5 | |
| HR_AREA_MEANING_CUSTOMER_REP_CUSTOMER_SUCCESS | CSV 473 | "Bilet çözümü ve churn" | Belirsiz (§15-9) | K5/K8 | |
| EV_PRODUCT_SUPPORT_OVERFLOW_KNOWN_BUGS | CSV 3471 | `support_overflow` seçeneği "Bilinen hataların listesini yayınla" | (b) kart incelemesi | K2/K5 | Kart `urun.bugs_unconfirmed` okur (support_overflow.json:123) |
| Yeni anahtarlar | (CSV'de yok) | `PRODUCT_BUGS_TIP*` 0 satır | Hat satırı, kart satırı, en büyük hesap, "N açık hata ›", itibar sebebi, boş ekip bağı, yeni "Acil" adı | K1, K4, K5, K6 | Önce İngilizce doğar; tire yok; TR/EN onay bekliyor (CLAUDE.md §5) |

### 11-B. Dinamik anahtar kurucuları (düz grep kaçırır)
| Kalem | Dosya:satır | Bugün | Etkilenen anahtarlar | Dilim | Not |
|---|---|---|---|---|---|
| Alan × durum cümlesi | sprint_catalog.gd:159 | `"PRODUCT_AREA_%s_%s" % [area.to_upper(), word.to_upper()]` | PRODUCT_AREA_*_NONE/WEAK/ENOUGH/STRONG (CSV 2943-2961 bandı) | K6 | CORE_ENOUGH ve TRUST_ENOUGH'u düz grep hiç bulmaz |
| Ticket başlığı | sprint_catalog.gd:203 | `"PRODUCT_TICKET_%d" % variant` | PRODUCT_TICKET_0..2 | K3 | |
| Araştırma sesi | sprint_catalog.gd:192 | `"PRODUCT_RESEARCH_VOICE_" + area.to_upper()` | PRODUCT_RESEARCH_VOICE_* | K6 | |
| Çoğul sonek | util/fmt.gd:51-52 (`count_key`) | `key + "_ONE"` | PRODUCT_VOICES_COUNT, PRODUCT_CUSTOMER_TICKETS, PRODUCT_IDLE, PRODUCT_AREA_TICKETS, PRODUCT_FX_*, PRODUCT_RESULT_TICKETS_* | K2-K6 | `_ONE` ikizleri düz grep'te okuyucusuz görünür |
| Etki parçası tablosu | sprint_ui_shared.gd:26-29, 311 | `COUNT_KEYS[part.k][int(forecast)]` | PRODUCT_FX_TICKETS_*, PRODUCT_FX_VOICES_* | K4/K6 | |
| Sonuç cümlesi saklanır | sprint_bridges.gd:209; sprint_system.gd:1113; product_model.gd:318-321 | `{key, args}` olarak kayda yazılır, `resolve` okur | PRODUCT_RESULT_TICKETS_* | K4 | Kayıtta eski anahtar adı kalabilir: eski sürüm kaydı yüklenince `resolve` bilinmeyen anahtar okur; (a)/(b) göç sorusu |
| İş anlamı | hr_constants.gd:1183, 349-354 | `_derived("HR_AREA_MEANING_", role + "_" + area)` | HR_AREA_MEANING_* | K5 | Eksikse kimliği döner (`out if out != key else id`) |
| Beceri açıklaması | founder_constants.gd:111-116 | Sabit tablo (düz grep bulur) | ONB_SKILL_*_DESC | K5 | |
| Satış sorusu/cevabı | sales_meeting_system.gd:409, 426, 438 | `"SALES_PROBE_%s"`, `"SALES_ANS_%s_%s"`, `"SALES_LOCK_%s"` | SALES_PROBE_PROBE_STABILITY_BUGS, SALES_ANS_PROBE_STABILITY_*, SALES_LOCK_* | K5 | |
| Hedef cümlesi | product_model.gd:406 | `"PRODUCT_GOAL_" + area.to_upper()` | PRODUCT_GOAL_* | - | Dokunulmaz; örnek olarak listelendi |

## 12. Belgeler (K8 ve ilgili dilimler)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| HARITA.md Kayıt | docs/HARITA.md:39 | `SCHEMA_VERSION (15)`; `_migrate_15` anlatılır | 16, `_migrate_16` cümlesi | K3, K5, K8 | Bölüm "Kayıt" (27-44); `_migrate_16` iki dilimde yazılır |
| HARITA.md Ofis | docs/HARITA.md:137 | `desk_shut` ve `--office-shot` ek listesi | `desk_shut` yeni karta göre; `fix_run` ekli değil | K6, K8 | |
| HARITA.md Ürün (yer/sahip) | docs/HARITA.md:142, 144, 145, 147, 148 | `SprintBridges` "tickets, ticket_seq"; `gate_faulty`; "ticket eşitleme"; `sync_tickets`/`close_tickets`/`add_faulty_ticket`; `bugs_confirmed`, aşınma, `live_bug_count`, `product_bug_risk` | Tek hata deposu, hat temizleme, `add_bugs` vb. yazma noktaları | K3, K5, K8 | |
| HARITA.md Ürün (arayüz) | docs/HARITA.md:150, 151, 152 | CountChip, glifli ACİL etiketi, `idle_text` "hata düzeltmeyi başlat", DESTEK kartı (Doğrulanmış, Gelen, kaçırılan, Hotfix düğmesi, `REFUSAL_KEYS`) | Yeni kart, yeni etiket, tek satırlı Destek kartı | K2, K4, K6, K8 | |
| HARITA.md Ürün (smoke/probe/görsel) | docs/HARITA.md:155, 156, 157, 158 | `fix_run_ships_subset`, `support_desk_rates_stack`; `SHIP` hata/ticket; `_run_the_company` düzeltme koşusu; `edge:voices_open`; sprint-probe | Yeni vaka adları, `PROBE FIX`, yeni `edge:` adları (§4.12) | K1-K6, K8 | |
| HARITA.md Satış | docs/HARITA.md:210, 211, 213 | `Inbox.risk_reason` canlı hata sayısı kuralı; `destek.can_start_fix_run`/`fix_run_active`; `hotfix_*`, `conversion_bug_penalty` önekleri | Yeni Risk sebebi; seam'ler silinir; `hotfix_*` 2026-08 turu adı olarak kalır | K2, K5, K8 | |
| HARITA.md Olay motoru | docs/HARITA.md:308 | `fix_run_start` fiili ve çipi | Silinir | K2 | Bölüm "Olay motoru" (295-314) |
| HARITA.md Araçlar | docs/HARITA.md:359 | Probe preset aileleri | `fix_*` kolları, `PROBE FIX` | K5 | |
| HARITA.md Ekip | docs/HARITA.md:176-194 (özellikle 185, 192) | Görevler matrisi (kurucu satırı anılmaz), `--hr-shot` türleri | Kurucu sprint payı; yeni hr-shot türü | K1 | Matrise kurucu satırı kararına bağlı |
| CLAUDE.md §6 | CLAUDE.md:95-96 | WRITE-THROUGH: köprü "yalnız `tickets`, `ticket_seq`, `requests`, `rival_hits`'i yazar" | Yeni yazma noktaları | K3, K8 | |
| CLAUDE.md §6 | CLAUDE.md:107 | `SCHEMA_VERSION` 15 | 16 | K3, K8 | |
| CLAUDE.md §8 | CLAUDE.md:145 | "var olan evi ara (… `ProductSystem.live_bug_count` …)" | `live_bug_count` kalkar; örnek değişir | K5, K8 | |
| CLAUDE.md §12 | CLAUDE.md:220, 226 | `desk_shut` "canlı B2C, DESTEK masası boş, 12 gelen bildirim" | Yeni karta göre yeniden anlatılır | K6, K8 | PRD §6 CLAUDE.md §6, §8, §12 |
| CLAUDE.md §5 | CLAUDE.md:53 | İzinli ödünç kelimelerde "hotfix" | Kullanım kalmazsa liste kararı | K8 | glossary:10 ile birlikte (§15-8) |
| GUNCELLEMELER.md (eski girişler) | GDDs/GUNCELLEMELER.md:128, 133, 138-141, 143 | Ürün rev 6.1 §8.2-§8.4 ve §9 satırları (doğrulama oranı, DESTEK kartı gelen satırı, Hotfix düğmesi, akış formülü) | Yeni giriş "Hatalar ve hata gösterimi (Faz A)" ve eski girişlere "yerine" notu (eski girişler arama dışı, PRD §4.1) | K8 | |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:204-207, 219-222 | Sprint motoru, ticket defteri kayıtta | Tek hata deposu, şema 16 | K8 | |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:283-286 | Ekip §1.2 Destek yükü: "iki sayaçla çalışır" | Güncellenir | K8 | |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:611 | "…Test beta keşif hızını ve Kararlılık tabanını oynatır" | Ekip GDD "canlı aşınma Test alanının işi" cümlesinin dayanağı (PRD §6); birebir cümle bulunamadı | K8 | Bölüm "EKİP MODÜLÜ (rev 11)" (492-628); docx §12.0 satırı da bakılacak |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:668 | Ar-Ge §6.3 "açık ticket'lar" oyu | Hata deposu oyu | K3, K8 | rnd_system.gd:595-603 |
| GUNCELLEMELER.md | GDDs/GUNCELLEMELER.md:748-751 | Risk sebebi, `COMPLAINT_BUG_GATE` | Yeni kural | K5, K8 | |
| Ekip GDD (docx) | GDD — EKİP MODÜLÜ vson.docx paragraf 779, 787-792, 257, 1039 | "Kurucu bu matriste bulunmaz"; Destek işi "bilet çözümü, yanıt süresi"; "bilet → hata düzeltme hattı" | Kurucu kararına göre; "bilet" sözcüğü | K1, K8 | docx'te satır yok; paragraf indeksi verildi |
| Motor md §27 | GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md:2004-2016 (§27.11), 2196-2204 (§27.15 `team`), 2486-2506 (§27.25) | `destek.can_start_fix_run`; `fix_run_start` fiili; `destek.fix_run_active`; "koşu sürerken susan hata yığını"; `productivity_mod` `team` kapsamı | Kaldırma/değişiklik notları: silinen seam/fiil/kart; yeni §27.n "Faz A" | K2, K8 | Kod md'den ayrılırsa ayrılık §27'ye yazılır (CLAUDE.md §2) |
| ZAMAN MODELİ | GDDs/GDD — ZAMAN MODELİ.md:163, 209, 212, 268, 366 | `INFLOW_TAU` §3.5; `BUG_HISTORY_*` satırı; B2C memnuniyet "canlı hata 5'i aşınca"; `product.bug_pile` bekleme satırı | `bug_pile` satırı silinir; öbürleri L ve aşınma kalkınca | K2, K5, K8 | PRD: "bug_pile satırı"; :268 ve :209 K5 |
| Glossary | docs/design/localization_glossary.md:10, 68, 72, 78, 79, 80 | hotfix izinli kelime; ticket; ses (kullanıcı); düzeltme koşusu; hata düzeltme/hotfix; kaçırılan bildirim | Satırlar silinir/yeniden yazılır; yeni terim satırları (açık hata, hat) | K8 | |
| ACIK_KARARLAR 39 | docs/ACIK_ISLER/ACIK_KARARLAR.md:466-484 | Risk sebebi ile elde tutma sesi farklı sayaç okur | Karar 9 ile çözülür | K5, K8 | |
| ACIK_KARARLAR 45 | docs/ACIK_ISLER/ACIK_KARARLAR.md:567-586 | Canlı aşınma ve devir sayacı | Karar 2 ile kapanır | K5, K8 | 43 (karmaşıklık ve aşınma, :531-547) de aynı yolda; 38 (:447) "bilet çözümü" ve Destek işini anar |
| ISLER C-07 | docs/ACIK_ISLER/ISLER.md:98 | Planlanmış düzeltme kartı eforu eşik geçince güncellenmiyor | Karar 7 / §4.6c ile kapanır | K4, K8 | |
| ISLER INT-9 | docs/ACIK_ISLER/ISLER.md:107 | Göç sonrası bilet defteri boş | Defter kalkar | K3, K8 | |
| ISLER (yeni not) | docs/ACIK_ISLER/ISLER.md | - | VC takip sorusu ve anlaşma düşmesi (Karar 10) | K8 | PRD §2 Karar 10 |
| FRANK_VOICE_INVENTORY | docs/writing/FRANK_VOICE_INVENTORY.md:66, 114 | Satır 15 `PROD_TIP_BUGS`; `[COND?]` "live bug count at ship" | Satır 15 `PROD_TIP_BUGS` çıkar; 114 güncellenir | K8 | |
| Üretilen belgeler | docs/content/events_draft/_vocabulary.md:54, 147, 149, 357, 572; docs/EVENT_SIGNAL_MANIFEST.md:161-162 | `fix_run_start`, `destek.can_start_fix_run`, `destek.fix_run_active`, `urun.bugs_confirmed`; `fix_run_started/finished` | Elle düzenlenmez: `--event-vocab` ve `python tools/gen_signal_manifest.py` | K2, K3 | (b) kapsar |
| hr_constants AREA_QA yorumu | scripts/systems/hr_constants.gd:15 | "…canlı bug aşınması" | Güncellenir | K8 | §8 |

## 13. Görsel kabul için mevcut shot türleri (K-adım kabulünde yeniden kullanılabilir)
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `--product-shot=c1..c5`, `cards`, `flow` | main.gd:3139-3191; product_fixtures.gd:12, 70-167 | Fikstür kaynağıyla sprint ekranı; `cards` tüm kart durumları (:87-101), `flow` başlat/ilerlet/plan | Hat paneli (alan satırı), düzeltme kartı (`kesinti` :473), sürüm notu (c3) için temel | K4, K6 | `c2` aktif sprint, `c3` sürüm notu |
| `--product-shot=edge:cap_zero` | product_fixtures.gd:106-112 | Ekip ve kart yok, kapasite 0 (`_nobody` yolu) | "Sprintte kimse yok" karesinin temeli | K1 | Kart dolu + ekip boş hâli yok; yeni fikstür |
| `--product-shot=edge:over_100`, `over_125`, `empty_start`, `no_release`, `gate`, `history`, `history_empty`, `mvp`, `locked_k3`, `replan`, `pm_started`, `quarter_no_pm`, `goal_menu`, `approved`, `no_candidates`, `b2b_no_requests` | product_fixtures.gd:78-166; HARITA:157 | Uç durumlar | Kapasite çubuğu aşımı, sürüm notu, çeyrek | K1, K4 | |
| `--product-shot=edge:voices_open` | product_fixtures.gd:165-166; main.gd:3192-3198 | Açık alan + ses katlaması | Silinir; yerine hat paneli fikstürleri | K6 | HARITA:157 listesinden de çıkar |
| Yeni `edge:` fikstürleri | - | Yok | Hat paneli B2B, hat paneli B2C, 1-2 hatalı çok hatlı uzun liste, uzun hesap adlı düzeltme kartı, sürüm notu, Destek'teki kişili ekip + kapasite çubuğu, boş ekip | K1, K4, K6 | Adları HARITA:157'ye eklenir (PRD §4.12) |
| `--product-shot=live:plan` | main.gd:3174, 3274-3277 | Plan, `_skip`, `_start` kareleri | Sönük düğmeler kabulü (§4.12) | K7 | |
| `--product-shot=live:active` | main.gd:3278-3284 | Aktif sprint, ikinci hafta | Sönük düğmeler + ekip listesi | K7, K1 | |
| `--product-shot=live:week1`, `gate`, `b2c_mvp`, `b2c_live`, `b2b_requests`, `delegate`, `rnd` | main.gd:3229-3318 | Sprint motoruyla gerçek koşular; `week1` sürüm notuna kapanır (`_close`) | Gerçek sürüm notu, B2B talep kartları, kurucu Ar-Ge (ekip dışı) | K4, K1 | `b2c_live` Geçmiş açık (:3185-3187) |
| `--product-shot=live:solo15`, `solo15_tip`, `solo12_active` | main.gd:3250-3256 | Kurucu tek başına, mesai 15/12 saat | Kurucu tek ekip üyesi (Yapım) hâli | K1 | |
| `--hr-shot=gorevler`, `gorevler-bos`, `gorevler-arge`, `urunsuz`, `urunsuz_tur`, `saatler-sprint`, `dosya-kurucu`, `verim`, `kalabalik` | main.gd:2718-2740 | Görevler matrisi, boş kadro, kurucu dosyası, mesai paneli sprint puanı | Matris/sprint bağı; `saatler-sprint` kapasite etkisi | K1 | |
| `--office-shot=<ofis>:<saat>:desk_shut` | main.gd:1220-1223, 1289-1294 | Destek kartı, 12 gelen bildirim | Yeniden kurulur, "N açık hata ›" karesi, boş masa karesi | K2, K6 | PRD §4.9: boş masa ofis karesi rapora konur |
| `--office-shot=<ofis>:<saat>:fix_run` | main.gd:1295-1306 | Düzeltme koşusu karesi | Silinir | K2 | |
| `--office-shot=<ofis>:<saat>:full`, `crowd40`, `<sekme>`, `hr_dossier`, `cheque`, `v1` | main.gd:1203-1223 | Ofis ve pencereler | Sprint açılışına yürüme ve rol animasyonu için ofis; `<sekme>` ekip/ürün penceresi | K1 | Açılış yürüyüşünü doğrudan çeken tür yok; `--day-shot=<ofis>:<hız>` bir haftayı oynar (denenmedi) |
| `--clock-shot=<durum>` ve TopBar'ı kapsayan her kare | main.gd:1649-1653 | TopBar'ın saat durumları (itibar değeri görünür) | Negatif itibar karesi için yeni fikstür gerekir | K5 | `--tab-shot`, `--office-shot` kareleri TopBar taşır |
| `--onboard-shot=2:random` | main.gd:2308-2315 | Onboarding adım 2 (beceri sütunları ve açıklamaları) | `ONB_SKILL_QA_DESC` yeni metin karesi | K5 | `origin_traits_step.gd:259` |
| `--sales-shot=edge`, `risk_stability`, `deals` | main.gd:1015-1022, 1044, 1113-1116, 1177 | Risk'teki hesap ve sebep satırı | Yeni Risk sebebi | K5 | Fikstür `mvp_live_bug_count` yazıyor; hata deposuna çevrilmeli |
| `--inbox-shot=attention`, `rnd_note_demand` | main.gd:735-744, 858, 764-768 | Gelen kutusunda Risk hatırlatması; ticket açılmış R&D notu | Risk hatırlatması yeni sebep; `rnd_note_demand` `add_faulty_ticket` (main.gd:768) çağırır | K3, K5 | Fikstür çağrısı K3'te değişmeli |
| `--tab-shot=product` | main.gd:1785 | Ürün penceresi (canlı model) | Genel kabul | K4, K6 | |

## 14. PRD listesinde olup kodda bulunmayanlar / farklı bulunanlar
| Kalem | Dosya:satır | Bugün | Yeni karşılığı | Dilim | Not |
|---|---|---|---|---|---|
| `SalesArchetypes.uses_axis`, `USE_AXIS_MIN` | scripts/systems/sales_archetypes.gd (grep: yok) | Bu yüklem yok | Karar 6, eşik 0,25 [onay bekliyor] | K4 | Kullanım: hat satırındaki hesap sayısı ve Risk sebebi |
| `ProductState.add_bugs`, `open_bugs`, `line_impact`, `line_blocked`, `line_bugs_cleared`, `_migrate_16` | scripts, data, tools (grep: yok) | Yok | PRD §9 adlı yazma/okuma noktaları | K3, K4, K5 | Arayüz `line_impact` alanlarını okuyacak |
| `PRODUCT_BUGS_TIP*` | localization/strings.csv (grep: 0 satır) | Yok | Yeni anahtar | K4 | PRD §0 madde 1 |
| `HR_AREA_MEANING_*` arayüz okuyucusu | grep: yalnız smoke | Çizilmez | Karar 12 yine de metni düzeltir | K5 | §0 madde 3 |
| Ekip GDD "canlı aşınma Test alanının işi" cümlesi | docx paragraf taraması | Birebir yok | GUNCELLEMELER.md:611 ve docx §12.0 satırları | K8 | §0 madde 5 |
| `PRODUCT_AREA_CORE_ENOUGH` / `TRUST_ENOUGH` literal okuyucusu | grep: yok | Dinamik (sprint_catalog.gd:159) | Metin çelişkisi | K6 | §11-B |
| `reset_all_owners` içinde SprintSystem/ProductState girişi | (a)/(b) | Yok (K0) | PRD §6 satırı | K3 | Arayüz değil |

## 15. Açık sorular / riskler (en çok 10)
1. **Görevler matrisinde kurucu yok.** Kurucuya iş atamanın oyuncu yolu bulunmuyor (§0-1); Ekip GDD §12 ve `_case_gorevler_has_no_founder` bunu bilerek kilitler. Karar 13'ün "Yapım ve Destek tutan kurucu" durumu oyuncuda doğmaz. A'da yalnız motor bağı mı kurulacak, matrise kurucu satırı eklenecek mi? İkincisi GDD'yi değiştirir (ACIK_KARARLAR yolu).
2. **Ofiste kurucu açılışa her zaman yürür** (`office_people.gd:454`). `team()` kurucuyu dışarıda bırakınca da yürür; PRD "kimin yürüdüğü" arayüz bağını sayıyor. Hangisi istenir?
3. **`HR_AREA_MEANING_TESTER_QA` çizilmiyor, `ONB_SKILL_QA_DESC` çiziliyor.** Anahtarı silmek smoke :7356'yı düşürür; yeniden yazmak yeter. Hangisi?
4. **Hat satırı ile düzeltme kartı çifte bilgi** (§3: satır "Fatura · 6 açık hata · 3 hesap · 140 kullanıcı ↑" ve kart "Fatura düzeltmesi · 6 hata · 3 hesap · 140 kullanıcı · en büyüğü ..."). Aynı alanın açık gövdesinde ikisi alt alta gelir. Oklar (↑ ↓) PRD'de tanımlı değil.
5. **Çeyrek görünümünde `AreaPanel(compact)`** hat paneli nasıl davranacak? Bugün ses çipi ve cümle orada da çiziliyor (`quarter_view.gd:55-60`).
6. **Destek kartı:** `BUILD_SPLIT_FOCUS` ve `PRODUCT_AUTO_STARTED` satırları "tek satır" ile nasıl bir arada? Gerekçe satırı kalkınca boş masa (`BUILD_BUSY_NOBODY`) bilgisi kartta görünmez. Tık/sürükle ayrımı ve eşit hatlarda "en çok hatalı" seçimi tanımsız.
7. **Alan uyarı üçgeni ve "alert_clear"** `urgent_tickets` eşiğine bağlı (`sprint_catalog.gd:143-150, 378-403`); Karar 4 eşiği ve acil zorunluluğu değişince bu uyarının anlamı ve öngörü çipi ne olacak?
8. **"hotfix" izinli ödünç kelime listesinde** (CLAUDE.md:53, glossary:10); kullanım kalmayınca listeden çıkar mı? Ayrıca K2 `hotfix_*` smoke önekine (2026-08 yama turu) dokunmamalı.
9. **"Bilet / ticket" kapsamı:** `HR_AREA_MEANING_CUSTOMER_REP_CUSTOMER_SUCCESS` ("Bilet çözümü"), `hr_constants.gd:17`, Ekip GDD §12.0 ve paragraf 257 Karar 12 "N ticket metinleri" kapsamında mı? Aynı soru "hata oranı" metinleri (CSV 468, 471) ve `HR_TRAIT_DOUBLE_CHECKER_EFFECT` (D'nin).
10. **Kayıtta saklanan sonuç cümleleri:** `release.expected/actual` `{key, args}` olarak yazılıyor (`sprint_bridges.gd:209`, `sprint_system.gd:1113`); eski anahtar `PRODUCT_RESULT_TICKETS_*` silinirse eski kayıttaki sürüm notu bilinmeyen anahtar gösterir. Göç (a)/(b) bunu bilmeli; ayrıca negatif itibarın TopBar'daki yerleşimi ve itibar sebebi yüzeyi (Karar 10) henüz seçilmedi.
