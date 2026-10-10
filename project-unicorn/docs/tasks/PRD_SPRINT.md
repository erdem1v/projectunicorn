# PRD · Sprint: dürüst plan, sürüm anı, oyuncunun onayı, B2C okuması

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_SPRINT.md dosyasını
oku ve uygula."
**Durum:** yardımcı yönetmen taslağı, 2026-10-10. Sahip kararları (B1–B10), hükümler (B-D1…B-B9, A11), çapraz denetim
(U1, U3, U5, U7, U8, U12) ve son hükümler (F2–F5, F8; hepsi bağlayıcı) ile senaryo pürüzleri (§0b) işlendi; dosya:satır
atıfları HEAD `0fe77fc`'ye göredir (`main.gd`, CSV ve HARITA atıfları F8 ile yeniden doğrulandı).
**Tek cümle:** sprint ekranı motorun yapacağını söyler, sürüm koşulu ve sürüm anı görünür olur, sprint oyuncunun onayı
olmadan başlamaz, B2C ürün yayınlandıktan sonra okunur.
**Çıktı:** §5'teki commit dizisi; `--sprint-probe` tablosu (§3'ün her satırı); 1920×1080 TR ve EN ekran görüntüleri;
✅/⚠️/❌ raporu.

## 0. Sahip kararları ve bulgu → gereksinim

| # | Karar (2026-10-10, onaylı) | Gereksinim |
|---|---|---|
| B1 | Artık puan akar; kapasite yuvarlaması kalkar; ölçüm aracı repoya girer | S1, S10 |
| B2 | Plan tahmini `_play_out`'tan; "başlamaz" etiketi; gerçek %125 tavanı; SPRİNT SONUNDA yalnız bitenler | S2 |
| B3 | Sürüm koşulu plan, aktif ve sürüm notu kiplerinde tek satır; MVP öncesi not "kart kaldı"; beta satırı | S4 |
| B4 | MVP'de sürüm kapısı: Yayınla / Bir sprint daha; v1.1+ otomatik; bot Yayınla seçer | S5 |
| B5 | Yayın sonrası B2C okuması: Ürün başlığı, Satış B2C sayfası, sürüm notunda ilk kullanıcılar, evreye göre boş hâller | S8 |
| B6 | Koşan sprint okunur: "Sırada", faz puanı, sayaç, tek kartlı sprintte devret uyarısı | S6 |
| B7 | Sprint oyuncunun onayı olmadan başlamaz; plan tutuşu; PM'e devir | S7 |
| B8 | Lider önerisi yalnız bitecek kartlardan; lider kurucuysa "Kendi notun" | S3 |
| B9 | Mesai modalinde sprint puanı etkisi; "kurucu + N çalışan" | S9 |
| B10 | Belgeler | S11 |

| Bulgu (kanıt) | Gereksinim |
|---|---|
| Kişi hafta başına tek kart alır: `_assign` kişiyi `free`'den kart başına düşürür (`scripts/systems/sprint_system.gd:512-529`), `_work` yalnız verilen kartta harcar (`:534-545`); 15 saatte haftada 2,75 puan boşa gider, ikinci kart hiç işçi almaz (araştırma R2: dört kapanışın dördü "HIZ 3/6") | S1 |
| `capacity()` 5,75'i 6'ya yuvarlar (`sprint_system.gd:341`); "devreder" düz toplam testi (`scripts/tabs/product/product_model.gd:203`); SPRİNT SONUNDA bütün kartları bitmiş sayar (`scripts/systems/sprint_catalog.gd:374-402`); oynamada çubuk "6/6", uyarı yok, tahmin "Çekirdek Yok → Zayıf" (FINDINGS S2-6) | S1, S2 |
| `can_add` yükü ekleme ÖNCESİ denetler (`sprint_system.gd:406-408`): kapasite 6'da üçüncü kart girer, yük %150 | S2 |
| Lider 15 saatte iki kart önerir (FINDINGS S2-5): doldurma `used + load <= capacity` (`sprint_catalog.gd:804-808`) | S3 |
| "N kart kaldı" yalnız aktif kipte çizilir (`scripts/tabs/product/sprint_panel.gd:106,122-139`); MVP öncesi kapanış "Bu sprint sürüm çıkmadı" der (`:193-194`); MVP'nin ne istediğini ve kendiliğinden çıktığını söyleyen metin yok | S4, S5 |
| Sürüm eylemsiz (`sprint_system.gd:745-766`); tek sürüm gibi görünen denetim Beta anahtarı (`sprint_panel.gd:332-341`) | S5 |
| Kuyruktaki kart "sürüyor" sayılır ve fazı "etkin" çizilir (`product_model.gd:207-211,390-392`) | S6 |
| Planlamada tutuş yok; bir gün geçince sprint liderin planıyla kendiliğinden başlar (`sprint_system.gd:34-39,673-684`; R1 E5/E6) | S7 |
| B2C kitlesinin hiçbir yüzeyi yok (yalnız son ekranı); Satış B2C'de "Canlı B2B ürün yok." der (`scripts/tabs/sales_tab.gd:218-232`; FINDINGS S1-2); Ürün başlığı tür seçilmeden "MVP · yayında değil" yazar (`scripts/tabs/product_tab.gd:162-168`, FINDINGS S2-1) | S8 |
| Mesai modali verim etkisini yazmaz, kurucu "0 çalışan"da sayılmaz (FINDINGS S2-4); kurucunun mesaisi bedel bloğunu hiç açmaz: `counts_in` ve `daily_overtime_in` yalnız çalışanları sayar (`scripts/systems/work_hours_system.gd:222-241`) | S9 |

## 0b · Senaryo pürüzleri

Kaynak `play/SCENARIO_SNAGS.md` (görev SPRINT); Onarım 1'in S02, S14, S17, S18, S32, S33, S44'ü yok. "A/C payı" = hükümle
A'ya (F2) ya da C'ye (F5) verilen, B'nin dayandığı iş; "Onarım 1" = F4'ün Ürün/Ar-Ge artıkları. İkisi §6'da; B dokunmaz.

| id | sev | başlık | kanıt | karşılayan gereksinim |
|---|---|---|---|---|
| S03 | major | Kapanış gecesi kart sürüm notunun yerini alır, sonraki sprint görünmeden başlar | `_open_after_gate` yalnız goto_tab ve dönüm kâğıdını açar (`main.gd:2922-2931`); sürüm kipinde ertesi tik liderin planıyla başlar (`sprint_system.gd:37-39,673-684`) | S7 (tutuş moddan, B-K2; kendiliğinden başlama yalnız devirde); B'nin dayandığı A/C payı: Ürün'ü yeniden açma A'nın (`_open_after_gate`, F2), ölen sayfayı atlama C'nin (`Inbox.show`, F5) → §6 |
| S04 | major | "Sprint yetişmeyecek" her yolda kurucunun haftasını yakar | karar bekleyen kart atanmaz ama "sürüyor" sayılır (`sprint_system.gd:488,516`; `product_model.gd:207-211`); `decision_carry` yeniden atamaz (`:233-247`) | YENİ → S6.b (`crunch_finishes()` dahil, F5); tek kart uyarısı S6 (B-D4); crunch kilidi/gövdesi C'nin (`sprint_late.json`, F5) → §6 |
| S05 | major | Plan ve aktif sayıları çelişir | aşım notu ve `PRODUCT_ADD_CLOSED` aktif kipte de çizilir (`sprint_panel.gd:89-97`); `can_add` ekleme öncesi yük (`sprint_system.gd:406-408`); tahmin devredeni sayar (`product_model.gd:233`) | S2 + YENİ → S2.b |
| S06 | major | Sürüm notunun lider satırı yanlış alanı anar; "lider" oyuncunun kendisi | `release_lead_sentence` `_suggest`'in MVP ve alan süzgecini atlar (`sprint_catalog.gd:431-436` ↔ `:775-785`); lider kurucuya düşer (`product_model.gd:410-418`) | S3 + YENİ → S3.b |
| S07 | major | Kendiliğinden başlama oyuncunun yarım planına liderin kartlarını ekler | `_auto_start` koşulsuz `apply_lead()` (`sprint_system.gd:673-684`) | S7 (yalnız devirde ya da planlanacak kart yokken; devirde PM'in planı tasarımdır) |
| S08 | major | Koşan kartta "Çıkar" kurucuyu haftanın kalanında boşta bırakır | `remove()` `_restaff` çağırmaz (`sprint_system.gd:95-107`; tek çağıranlar `:626,639`) | YENİ → S6.b |
| S09 | major | Beta anahtarı plan dışında ölü; MVP öncesi gelmeyecek v1.0'ı vaat eder | `_foot_row` üç kipte açık (`sprint_panel.gd:121,139,252`), `set_beta` yalnız planda (`sprint_system.gd:180-184`); MVP öncesi not `version()+1` basar (`product_model.gd:252-253`) | S4 (`PRODUCT_BETA_RULE`) + YENİ → S4.b |
| S15 | major | Frank "Fiyatı belirle" der; fiyat denetimi yok, satır koşu boyu kalır | `FRANK_ADVISORY_PAID_TIER` (`strings.csv:2677`); fiyatı yalnız `open_paid_plan` yazar (`sprint_bridges.gd:183-184`); satırı yalnız `initialize_run` siler (`game_state.gd:315-317,874`) | S8 (fiyat, ödeyen) + YENİ → S8.b (satır düşer); `paid_tier.json` kopya ve koşulu C'nin (F5) → §6 |
| S16 | major | DESTEK masa kapalıyken "hata yok" der | `REFUSAL_NO_BUGS` `DESK_SHUT`'tan önce (`support_system.gd:296-299`); GELEN bilerek çizilmez (`build_bar.gd:145`) | → Onarım 1 (F4, §6) |
| S22 | major | Kurucu Ar-Ge'ye geçince sprint sessizce durur; Ürün "kimse yok" der, işe alım önerir | `team()` araştırmadakini düşer (`sprint_system.gd:398`); gerekçe `PRODUCT_TEAM_NOBODY` (`product_model.gd:226`); `_nobody` (`sprint_panel.gd:143-159`) | YENİ → S12; atama paneli uyarısı → Onarım 1 (F4, §6) |
| S34 | major | Donmuş araştırma kalıcı Ar-Ge rozeti bırakır, vazgeç yok | `is_frozen` rozete +1 (`rnd_system.gd:661-662`); `_displace_job` hep "Ekip yapımda" (`character_registry.gd:239-245`) | → Onarım 1 (F4, §6) |
| S37 | minor | v1.0 notu "değişiklik beklenmiyor" der; Ar-Ge sessiz açılır | `_expected` MVP'yi bilmez (`sprint_system.gd:810-816`) → `strings.csv:2856`; ağaç v1'de açılır (`rnd_system.gd:63-64`) | YENİ → S5.b; v1 Ar-Ge ray rozeti C'nin (`left_tabs.gd`, F5) → §6 |
| S38 | minor | Satış boş hâli MVP öncesi B2B'de yol göstermez, B2C'de çıkmaz | `_paint_empty` yalnız `SALES_LOCKED_NO_B2B` + `SALES_B2C_NOTE` (`sales_tab.gd:220-232`) | S8 (B2C sayfası, evre boş hâlleri) + YENİ → S8.b |
| S48 | minor | Ar-Ge kilitleri yol göstermez; Ürün'ün araştırma kilidi düz etiket | kilit satırı `Caption` (`sprint_card.gd:129-130`); üründen `rnd_node_requested` yayan yok (`research_bar.gd:178-179` tek desen) | YENİ → S12; işe alım işareti → Onarım 1 (F4, §6) |
| S49 | minor | Keşif postası olmayan tasarımcıyı anar; tahmin toplantı payını saymaz | `strings.csv:2160`; tahmin yalnız kurucu, toplantısız (`rnd_system.gd:189-204`) | → Onarım 1 (F4, §6) |
| S53 | minor | Dil ya da palet değişimi (ya da gelen kutusu) hafta 1 tür seçimini siler | `language_changed`/`palette_changed` → `_rebuild` sayfayı yeniden kurar (`window_layer.gd:66-67,156-162`); seçim yalnız örnekte (`type_picker.gd:12-15`) | YENİ → S13 |

## 1. Bu oturumun kuralları

- Repo `C:\Users\erdem\Desktop\project steam\project-unicorn` (git kökü bir üstte). `CLAUDE.md` bağlayıcı (§3, §5, §7,
  §8–§12: `main`'e commit, push yok, "TR/EN onay bekliyor", her commit öncesi ayrı ajan incelemesi, fikstürle görsel kabul).
- **Sıra kesin: A → B → C.** B, SAAT'in (A) commit'leri `main`'e indikten sonra başlar; C'nin içerik/veri işi paralel
  sürebilir. A'nın dosyalarındaki satırlar A sonrası kayar: numaralar `0fe77fc`'ye göre, işlev adıyla yeniden bul.
  `git status --short` ile başla; kirli dosyada yalnız kendi hunk'ını `git apply --cached` ile stage et, kapıları
  `git checkout-index` ağacında koştur; `git checkout -- <yol>`, `reset --hard`, `stash`, `clean` yasak.
- **Canlı ağaç.** Ağaç bu taslakta temizdi: grafik ayarı işi HEAD `0fe77fc` olarak commit'lendi, yabancı commit'siz iş yoktu. Kural
  kalır: işe `git status --short` ile başla; başka oturumun kirli dosyasında yalnız kendi hunk'ın `git apply --cached` ile.
- Alt ajanlar Opus ya da Sonnet. OS düzeyinde fare/klavye yok; pencereli koşular sırayla (önce `tasklist | grep -i
  godot`), her biri kendi `APPDATA`'sında; ekransız her koşu `--headless`.
- **Dosya sahipliği (B).** `scripts/systems/sprint_system.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`;
  `scripts/tabs/product/*.gd`, `scenes/tabs/product/*.tscn`, `scenes/tabs/ProductTab.tscn`;
  `scripts/tabs/product_tab.gd`; `scripts/tabs/sales_tab.gd` (B2C ve boş hâl dalları);
  `scripts/modals/work_hours_modal.gd` (etki satırı ve kurucu sayısı); `scripts/debug/run_probe.gd` (yalnız
  `_plan_the_sprint`, brief; `_run_sim`, `_seed_b2c_world` ve onların çağırdığı yeni `_start_on_lead()`, B-D1; öbürü §6
  SAHİBE), `product_fixtures.gd`, `sprint_probe.gd` (yeni); `scripts/debug/endgame_smoke.gd` (yalnız şu vakalar,
  güncellenen: `sprint_carry_keeps_progress`, `sprint_capacity_from_team`, `sprint_mvp_three_identity_k1`,
  `sprint_solo_mvp_by_week_six`, `sprint_auto_start_after_a_day` → `sprint_starts_only_with_consent`,
  `sprint_never_stalls_in_plan`, `sprint_late_only_when_behind`, `sprint_decision_blocks_progress`,
  `sprint_ceiling_125_blocks_add`, `quiet_cards_fill_empty_floor`, `sprint_paid_plan_opens_paid_tier` (S8.b); float
  kapasite yakalayan `prep_bonus_and_capacity` (`:2547`), `hr_leave_cycle` (`:6532`), `hr_raise_and_leave` (`:6712`),
  `promise_row_locked_when_no_room` (`:17203`); yeniden koşulan `sprint_departure_restaffs_card`; B'nin değişikliği
  A'nın ya da C'nin bir vakasını kırarsa B düzeltir ve raporlar); `data/product/sprint.json`; `localization/strings.csv`
  (yalnız bu PRD'nin anahtarları, bayt-span ekleme); PRD rev 7, GUNCELLEMELER "Ürün rev 7", ACIK_KARARLAR yeni madde,
  HARITA Ürün/Satış; `docs/content/events_draft/_vocabulary.md` (`--event-vocab` çıktısı, KEEP bloğu kalır; hükümsüz, §6
  SAHİBE). Hükümle verilen hunk'lar: `CLAUDE.md` §12 (yalnız B'nin bayrak satırları, A'dan sonra, hunk bazlı; F3);
  `scripts/systems/sales_system.gd` (yalnız `daily_tick` kitle örneği, B-K9); `scripts/events/seams/seams_product.gd`
  (yalnız `urun.sprint_single_card`, B-D4, ve `urun.crunch_finishes`, F5); `scripts/main/main.gd` (yalnız B-D1
  harness kolları, ayrı hunk; saat, hız ve tutuş yollarına dokunulmaz; listede olmayan `live:solo15_tip` ve
  `live:delegate` da harness işidir, raporda anılır); `scripts/main/game_shell.gd` (`_ready`'ye tek satır, B-D2);
  `scripts/autoload/time_manager.gd` (yalnız `HOLD_LABELS`'a `sprint_plan` satırı, `PRD_SAAT.md` §4.1);
  `scripts/debug/tick_probe.gd` (yalnız tutuş kolu, A'nın K2'sinden sonra tek hunk, `PRD_SAAT.md` §9.1, U2). §0b ekleri
  (S2.b–S8.b, S12, S13) de yalnız bu listeye dokunur; dışarısı §6'da.
- **`product_tab.gd`'de A'nın olan:** `_hold_clock` (`:247-258`), `on_page_closing` (`:111-114`), `_held_speed` (`:22`).
  `_rebuild`'teki `:147` çağrısı değişmez, iki PRD de dokunmaz (`PRD_SAAT.md` §3.3): plan tutuşu pencerede değil
  `SprintSystem.sync_plan_hold`'da alınır, pencere kapalıyken de tutar; kapı `release` kipindedir, not tutuşu aynı kalır.

## 2. Değişen kurallar ve sabitler

| Kural / sabit | Önce | Sonra | Durum |
|---|---|---|---|
| Kişinin haftalık puanı | Tek karta; kart bitince artan düşer | Sprint sırasıyla sonraki karta akar | onaylı 2026-10-10 (B1) |
| `capacity()` | `roundi(puan × 2)` | float; ekranda `Fmt.number(x, 2)` ("5,75", "4") | onaylı (B1, "ondalık gösterir" seçeneği) |
| "+" tavanı (`cap_ceiling` 1.25 aynı) | ekleme öncesi yük ≤ %125 | ekleme SONRASI yük ≤ %125; boş sprint tavanı aşan kartı da alır (bugünkü lider kuralı, `sprint_catalog.gd:800`; yoksa tek kurucu K3'ü hiç alamaz: 8 > 7,19) | onaylı (B2) |
| "+" boş puan koşulu | yok | yeni kart bu sprintte puan alamayacaksa kapalı; alacaksa "devreder · 2,75/3" etiketiyle girer | onaylı (B-K1) |
| MVP kapanışı | kendiliğinden v1.0 | kapı: Yayınla / Bir sprint daha | onaylı (B4) |
| Plan kipi | bir gün sonra kendiliğinden başlar | `sprint_plan` tutuşu, yalnız "Sprinti başlat" bırakır | onaylı (B7) |
| Tutuşun sürüm notu kipinde de alınması | — | `release` kipinde de (not penceresi kapalıyken) | onaylı (B-K2) |
| Planlanacak kart hiç yokken | boş sprint kendiliğinden başlar | aynı kalır, tutuş alınmaz, panelde "boş sprint" notu | onaylı (B-K3) |
| Boş geçirme | yok | "Bu sprinti boş geçir" ikinci sınıf düğme + onay satırı (oyuncunun açık onayı) | onaylı (B-K4) |
| "Sprinti başlat" | sprinti başlatır | tutuşu kaldırır, saati akıtmaz (Model S); TopBar "DURDU · Boşluk ile sürdür" | onaylı (B-K10) |
| Devir | yok | aktif PM varken anahtar; devirde sprint `plan_next`'te ya da saat sürdürülünce başlar | onaylı (B7, B-K5) |
| Kapıda devir | — | kapı devirde de oyuncuyu bekler | onaylı (B-K6) |
| Lider doldurması | toplam ≤ kapasite | play-out'ta bitenler + "+" yüklemini geçen bir devreden kart (etiketli); PM planları toplamla kalır | onaylı (B8, B-K7) |
| Haftalık kitle örneği | yok | `SalesSystem.daily_tick` → `GameState` bayrağı `b2c_audience_history`, son 26 hafta | onaylı (B-K9) |
| Kurucunun mesai bedeli | yok | değişmez; ACIK_KARARLAR'a açık madde | SAHİBE, bilgi (B-K8, §6) |
| `mvp_eta` ufku | — | 24 hafta | iç sınır, ekranda görünmez |

`data/product/sprint.json`'da sayı değişmez.

## 3. Aritmetik: yeni kural MVP'yi nereye koyar

Tek kurucu, B2C `note_tool`, karar oranı 0, olay yok, her sprint en az bir yeni Çekirdek K1 kartıyla dolu, kapı açılınca
Yayınla. Kart 3 puan (0,6 / 1,8 / 0,6; `sprint.json:5,7`). Kurucu dört rolün hepsine uyar (`sprint.json:21-22`), yarım hız
yok. Haftalık puan P = 2 × `hours_output_mult(h)` = 2 × (min(h,8) + max(h−8,0) × 0,5) / 8. Artık puan aktığı için kart
k, birikim 3k'yı geçtiği hafta biter; MVP üç kart = birikim ≥ 9'un ilk geçtiği sprintin kapanışıdır. Sprint 1 1. tikte
başlar, kapanışlar 3., 5., 7. tik ("Hafta" = kapanış tiki − 1: 7. tik = Hafta 6 sonu).

| Mesai (başlangıç) | P | Kapasite bugün → yeni | S1 / S2 / S3 sonu birikim | MVP bugün | MVP yeni, 2 kart ("+" alırsa) | MVP yeni, lideri izleyen |
|---|---|---|---|---|---|---|
| 8 s (09:00, varsayılan) | 2,000 | 4 → 4 | 4 / 8 / 12 | 7 (ölçüm) | **7** (ikinci kart girmez: 6 > 5) | 7 |
| 9 s | 2,125 | 4 → 4,25 | 4,25 / 8,5 / 12,75 | 7 (hesap) | 7 (6 > 5,31) | 7 |
| 10 s | 2,250 | 5 → 4,5 | 4,5 / 9,0 / 13,5 | 7 (hesap) | 7 (6 > 5,63) | 7 |
| 12 s | 2,500 | 5 → 5 | 5 / 10 | 7 (hesap) | 5 | 5 |
| 14 s | 2,750 | 6 → 5,5 | 5,5 / 11 | 7 (ölçüm) | 5 | 5 |
| 15 s (09:00, modalin tavanı) | 2,875 | 6 → 5,75 | 5,75 / 11,5 | 7 (ölçüm) | **5** | **5** |
| 16 s (08:00) | 3,000 | 6 → 6 | 6 / 12 | 5 (ölçüm, düşüşsüz) | **5**, iki kart S1'de biter | 5 |
| 15 s + Beta açık | 2,875 | — | — | 9 (ölçüm) | 7 | 7 |
| 8 s + Beta açık | 2,000 | — | — | 9 (hesap) | 9 | 9 |
| 15 s, S1'de karar kâğıdı "devret" | 2,875 | — | B S1'de 0 alır | 7 | 7 | 7 |

Kanıt: "+" ve lider ekleme SONRASI tavanı (B-K1) uyguladığı için iki taze K1 (6 puan) ancak tavan ≥ 6 iken girer
(11 s: 4,75 × 1,25 = 5,94; 12 s: 6,25); 12 saatten önce sprint tek karttır. 8 s: A hafta 2'de biter, artan 1,0 boşa
gider; S2'de B, S3'te C → 7. tik, bugünkü gibi (`GDDs/GUNCELLEMELER.md:223` (9) korunur). 15 s S1: A biter, B 2,75/3
devreder; S2: B 0,25 ile, C hafta 2'de biter → 5. tik. 16 s/08:00: A hafta 1'de, B hafta 2'de. "Ölçüm" = araştırma R2
(20 tohum × {8, 15} saat 40/40'ta 7; 15 s Beta 9; 16 s/08:00 5). "Lideri izleyen" (S3, B-K7) 2 kart sütunuyla aynı. "2
kart" yeni "+" ile (commit 3) ölçülür; commit 2'de eski "+" 10 ve 11 s'de ikinci kartı alır, orada 5 çıkar (§5).

## 4. Gereksinimler

### S1 · Artık puan akar (motor)
- **Ne:** kişi kartını bitirince haftanın kalan puanı sprint sırasındaki sonraki karta geçer.
- **Nasıl:**
  - `_work(c, person, budget: float) -> float` (`sprint_system.gd:534-545`): `person.points` yerine `budget` harcar,
    harcanmayanı döndürür.
  - `_assign` (`:512-529`): `free` kişilerin `left = points` taşıyan kopyası; sıralama rolden sonra `left`'e göre;
    `_work(probe, person, person.left)` sonrası `left > EPS` ise kart bitmiştir, kişi `free`'ye geri döner.
  - `_end_week` (`:482-507`): kişi başı bütçe sözlüğü; kartlar sprint sırasıyla, her atanan için
    `budget[id] = _work(c, people[id], budget[id])`. Atama ve döküm aynı sırayı izler: ekip hafta içinde değişmediyse
    sonuç önizlemeyle aynıdır.
  - `_play_out(cards, weeks := -1)` (`:550-563`): aynı bütçe döngüsü; `weeks` verilmezse sprintin kalan haftaları
    (S4 çok haftalık oynatır). `decision_progress` (`:216-229`) `_work(c, {"fits": ...}, float(amount))` çağırır.
  - `capacity()` (`:336-341`) float döner; `sprint.capacity`, `velocity.total` float. Çağıranlar: `sprint_catalog.gd:409,
    478,766` (`_suggest(capacity: int` → float), `product_model.gd:183-184,320,326-331,435`, `sprint_ui_shared.gd:67,73`
    (CapacityBar `int(cap.total)`: 5,75'lik sınır 5'te çizilirdi) ve `:103`, `sprint_panel.gd:225-227` (`"%d/%d"`,
    `{total}` → `Fmt.number`), `run_probe.gd:270` (`%.2f`, `_on_sprint_closed`; §6 SAHİBE), `:811-814`, `product_fixtures.gd:222-226`,
    `sprint_system.gd:458` `fits_plannable` (söz kilidi 0,25 puan daralabilir, fark raporuna), smoke `int` yakalamaları.
- **Kabul:** §3 tablosu `--sprint-probe` ile birebir (S10); `sprint_*` ve `product_*` smoke yeşil. Kırılanlar
  güncellenir (8 s tek kurucuda ikinci K1 `add()`'den geçmez, 6 > 5): `sprint_carry_keeps_progress` (`:16451`; B-B1:
  araştırmasız iki K1, `GameState.company_work_hours = 12`, kapasite 5, tavan 6,25: ilk K1 S1'de biter, ikincisi 2/3
  ile devreder, vaka onu izler), `sprint_capacity_from_team` (`:16315`, `roundi` → float),
  `sprint_decision_blocks_progress` (`:16775`; kurucu + bir geliştirici ya da 12 s ile kurulur),
  `sprint_late_only_when_behind` (`:17261`; ilk sprintte "ikinci kart ilk hafta yalnız artık puan alır", ikinci sprint
  12 s). `sprint_departure_restaffs_card` (`:16863`) yeniden koşulur. `run_gate.sh` 3/3 ve fark raporu (MVP tiki, v1.x
  tikleri, 52. hafta MRR): "önce" commit 2'nin ebeveyni, "sonra" commit 2, `git checkout-index` ağaçlarında.

### S2 · Dürüst plan tahmini
- **Ne:** "kim, kaç hafta" ipucu, "devreder", "başlamaz", "+" ve SPRİNT SONUNDA aynı oynatmadan gelir.
- **Nasıl:**
  - Yeni `SprintSystem.plan_outcome(ids: Array = []) -> Dictionary`: tek `_play_out`; boş `ids` bu sprintin kartlarıdır,
    dolu `ids` varsayımsal listedir (S3), kartlar verilen sırayla oynar. Döner: `{cards: {id: {split, done,
    finishes}}, spare}` (`done`: bu sprintte yapılacak puan, `spare`: hiçbir karta gitmeyen puan).
    `SprintSystem.effort_split` silinir; tek çağıranı `product_model.gd:202`.
  - Model plan kipinde (`product_model.gd:199-203`): model alanı `effort_split` (sözleşme `:53`, `sprint_card.gd:288`,
    `product_fixtures.gd:473`) adını korur, değeri `split`'ten; `spills` ← `not finishes and done > EPS`;
    yeni `no_start` ← `done <= EPS`; yeni `planned_done` (gösterim). `SprintCard._tags` (`sprint_card.gd:174-184`):
    `PRODUCT_CARD_SPILLS_PTS` "devreder · 2,75/3", `PRODUCT_CARD_NO_START` "Bu sprint başlamaz → Sprint 2".
    Aşım notu (`sprint_panel.gd:89-97`) aynı bayraklardan sayar, yalnız plan kipinde (bugün aktifte "0 kart devreder").
  - `can_add(card_id := "")` (`sprint_system.gd:406-408`), B-K1: plan kipi, kapasite > 0 ve ya sprint boş
    (`used() <= EPS`; tavanı aşan kart da girer, §2) ya da `plan_outcome().spare > EPS` (kart bu sprintte puan alır) ve
    ekleme SONRASI yük ≤ kapasite × `cap_ceiling`; bitmeyecek kart "devreder · 2,75/3" etiketiyle girer (§3). Model aday
    başına `addable` verir; `center.can_add` okuyanları aday başına okur (`area_panel.gd:164,249`,
    `sprint_panel.gd:62,102,271`, `sprint_card.gd:113`). Kapalılık notu: boş puan yoksa `PRODUCT_ADD_CLOSED_FULL`,
    tavansa mevcut `PRODUCT_ADD_CLOSED` (`sprint_panel.gd:94-96`). `add()` (`:78-82`) aynı yüklemi çağırır.
  - SPRİNT SONUNDA (`product_model.gd:233`): `SprintCatalog.forecast` yalnız `finishes` kartlarla çağrılır.
  - Smoke `sprint_ceiling_125_blocks_add` (`:16425`, bugün ekleme ÖNCESİ yükü denetler, `:16434`) yeni yükleme çevrilir:
    `open == (used ≈ 0 or (spare > EPS and used + remaining(c) <= ceiling))`.
- **Kabul:** probe `PRED` = `CLOSE` 20 tohum × ({8, 15, 16/08:00} × 1 kart + {15, 16/08:00} × 2 kart) (events=0) %100;
  hiçbir sprint planda "sığıyor" deyip devretmez. `--product-shot=live:plan` ve `live:solo15` TR+EN; kart üstü döküm
  zorlanmış hover'da görünür (FINDINGS S2-6). `live:solo15`: `_seed_hr_roster` çağrılmaz (tek kurucu), şirket 09:00 +
  15 saat, `apply_lead()` uygulanmış; iki kart, ikincisi "devreder · 2,75/3", çubuk "6/5,75". `live:solo15_tip`: aynı
  kurulum, öneri uygulanmamış (öneri satırı ancak `lead_applied` yanlışken çizilir, `product_model.gd:219,242`).
- **S2.b (S05):** aşım bloğunun tamamı, `PRODUCT_ADD_CLOSED` dahil (`sprint_panel.gd:89-97`), yalnız plan kipinde.
  Kabul: `live:active` aşımlı kurulumda (2 kart, 6/5) blok yok, `live:solo15`'te var.

### S3 · Lider önerisi dürüst
- **Nasıl:** `_suggest` doldurma döngüsü (`sprint_catalog.gd:804-808`), `lead_suggestion` (`:408-409`) çağırdığında,
  kartı `SprintSystem.plan_outcome(GameState.product.sprint.cards + picks + [c.id])` (sprintte duranlar önde;
  `_open_cards` onları havuza almaz, `:749-753`) içinde önceki seçilenlerin hepsi bitiyor, yeni kart puan alıyor ve yük
  ≤ kapasite × `cap_ceiling` ise alır (B8 + B-K7; "+" ile aynı yüklem). Bitmeyecek kartı aldıktan sonra doldurma durur:
  en çok bir devreden kart, "devreder · 2,75/3" (S2). Zorunlu kartlar (`:798-802`) ve PM planları (`:468-490`) değişmez.
  Lider kurucuysa (`product_model.gd:410-418`) `lead_tip.self = true`; `_lead_row` başlığı `PRODUCT_LEAD_TIP_SELF`
  "Kendi notun", ad yazılmaz. "Uygula" yalnız doldurur (`apply_lead`, `sprint_system.gd:188-194`), başlatmaz.
  - Brief C2 ("tür seçilince liderin planı hazır, Başlat tek tık"; AÇILIŞ §9 madde 5): tür seçicinin işleyicisi
    (`product_tab.gd:85-86`) `choose_type` ardından `apply_lead()` çağırır; motorun `choose_type`'ı boş açmaya devam
    eder (smoke `_seed_sprint` vakaları kartlarını kendisi koyar). `live:plan` `apply_lead()`'i kendisi çağırdığından
    (`main.gd:2422`) bunu kanıtlamaz; AÇILIŞ §9 madde 5 doğrular.
- **S3.b · Sürüm notunun lider satırı (S06).** `_suggest`'in alan seçimi (`sprint_catalog.gd:775-785`) `_lead_area(pool,
  capacity)` olur; `_suggest` ve `release_lead_sentence` (`:431-436`, bugün `_weakest(area_ids(), …)`) onu çağırır.
  Kurucu lider ise not satırı (`sprint_panel.gd:247`) da `PRODUCT_LEAD_TIP_SELF` alır (`lead.self`, `product_model.gd:263`).
  Kabul: MVP öncesi her notta satır Çekirdek'i anar, kilitli alanı anmaz; tek kurucuda başlık "KENDİ NOTUN".
- **Kabul:** 15 s tek kurucu: öneri iki kart, ikincisi "devreder · 2,75/3"; 8 s: tek kart (ikinci K1 tavanı aşar, 6 > 5);
  16 s/08:00: iki kart, ikisi biter; probe `lead=1` satırları §3'ün son sütununa eşit; `live:solo15_tip` öneri satırı
  "KENDİ NOTUN" ve iki kart adı; tür seçici yolunda seçim sonrası sprint dolu, `mode()=="plan"`, `can_start()` doğru.

### S4 · Sürüm koşulu her kipte ve MVP tahmini
- **Nasıl:**
  - Yeni `SprintSystem.mvp_eta() -> Dictionary` (`{sprint, week}` ya da `{}`): canlı değil, kapasite > 0. Kopyalar: bu
    sprintin kartları, sonraki sütun, sonra Çekirdek kimlik hatlarının bitmemiş K1 adayları efor sırasıyla; her sprinte
    yalnız `can_add` yüklemini (S2) geçecek kartlar konur (10 s'de tek kart: Sprint 3). `_play_out(cards, 1)` hafta hafta,
    `mvp_cards_left()` kadar K1 bitene dek, en çok 24 hafta. Bitiş haftasını içeren sprintin kapanışı; Beta açıksa +1
    sprint; `week` = kapanış tiki − 1. Varsayım: oyuncu sprinti dolu tutar ve açıldığı gün başlatır.
  - Model `center.mvp_line: {need, done, sprint, week} | null` (canlıda null). Panel plan ve aktif kipte kapasite
    satırının altına, sürüm notunda başlığın altına çizer (`sprint_panel.gd:65-139,185-191`). Anahtarlar
    `PRODUCT_MVP_RULE`, tahmin yoksa `PRODUCT_MVP_RULE_NO_ETA`; alan adı `SprintCatalog.area_short("core")`. Aktif
    kipteki "N kart kaldı"nın yerini alır: `next_version.cards_left` (`product_model.gd:238`, `:39`,
    `product_fixtures.gd:138,268`), `sprint_panel.gd:132-133` ve tek okuyanlı `PRODUCT_CARDS_LEFT(_ONE)` silinir.
  - MVP öncesi kapanış notunda `PRODUCT_NO_RELEASE` (`:193-194`) yerine `PRODUCT_MVP_LEFT` ("v1.0 için 2 kart kaldı");
    canlıda sürüm çıkarmayan kapanış `PRODUCT_NO_RELEASE` ile kalır.
  - Beta anahtarının altına plan kipinde `PRODUCT_BETA_RULE` (`_foot_row`, `:332-341`).
  - **S4.b (S09):** `_foot_row` anahtarı plan dışında `D_seg_pick(..., off = true)` (`ui_factory.gd:465`); MVP öncesi
    notta sürüm etiketi boş (`product_model.gd:252-253`), `PRODUCT_RELEASE_BETA` yok, yerine `PRODUCT_MVP_LEFT` ya da kapı.
- **Kabul:** probe: cards=2 koşularında Sprint 1 başındaki `mvp_eta` gerçek MVP tikine eşit (20 tohum × §3 saatleri).
  `live:plan`, `live:active`, `live:solo15` ve MVP öncesi sürüm notu (`--product-shot=edge:no_release` fikstürü
  güncellenir) karelerinde satır var, TR ve EN taşmasız. S4.b: `live:active` ve not karesinde anahtar sönük;
  `edge:no_release` beta varyantında sürüm etiketi yok, "v1.0 için N kart kaldı" var.

### S5 · Sürüm bir an olur (MVP kapısı)
- **Nasıl:**
  - `_close` (`sprint_system.gd:692-806`): kamu bloğu (`:748-769`) ve yayımlar (`:803-805`) `_go_public(n, new_code,
    faulty)` olarak ayrılır. `mvp` doğruysa (`:745`) `_go_public` çağrılmaz; `release.gate = true`, `number = 0`; o
    kapanışın hatalı hatları `p.gate_faulty`'ye eklenir. Canlı sürümler kapanışta `_go_public`'i bugünkü gibi çağırır.
  - Yeni `SprintSystem.publish()`: yalnız `mode() == "release"` ve `release.gate`; `_go_public(1, _shipped_code(),
    p.gate_faulty)`, `gate_faulty` boşalır, `release.number = 1`, sonra `release.press = SprintBridges.press_line(release)`
    (kapanışta `number` 0 iken `{}` döndü, manşet de oradan: `sprint_bridges.gd:141-143,162`), `gate = false`;
    `p.releases`'in son kaydına `number` ve `press` yazılır; `build_phase_changed("shipped")`, `version_shipped(1)` bir kez.
  - "Bir sprint daha" mevcut `plan_next()`'tir (`:154-177`); sonraki kapanışta `mvp` yine doğru, aynı kapı. Kademeler
    MVP öncesinde de kapanışta yazıldığı için (`:727-735`) "beklemek" ürünün kapalı kalmasıdır, kart durumu değişmez.
    Beta açıkken bitmiş kart bir sprint `beta`'da bekler (`:703-704`), kapı da bir sprint sonra gelir.
  - Panel (`sprint_panel.gd:185-253`): `release.gate` iken başlık `PRODUCT_GATE_TITLE`, gövde `PRODUCT_GATE_BODY`, alt
    şeritte birincil "Yayınla" (mevcut `PROD_SHIP_PUBLISH`, eylem `publish`) ve ikincil "Bir sprint daha"
    (`PRODUCT_GATE_ONE_MORE`, eylem `plan_next`). `product_tab.gd` `_act` (`:216-234`) ve `product_fixtures.gd` eylem
    tablosuna `publish`.
  - Bot: `_plan_the_sprint` (`run_probe.gd:781-814`) kapıda önce `publish()` ve `PROBE PLAY day=%d publish`; `b2c`
    preset'inde S7'nin `_start_on_lead()`'i. `main.gd` `_seed_product_live` (`:2406-2441`, B-D1) kapıda `publish`
    çağırır; yoksa `live:b2c_mvp` ve `live:b2b_requests` canlıya çıkmaz.
  - Smoke: `sprint_mvp_three_identity_k1` (`:16481`) kapıyı, `plan_next` sonrası ikinci kapıyı, `publish` sonrası tek
    `version_shipped([1])`'i ve Beta açıkken kapının bir sprint gecikmesini denetler; `sprint_solo_mvp_by_week_six`
    (`:17018-17033`) kapıda `publish` çağırır.
  - **S5.b (S37):** `publish()` `release.expected = {"key": "PRODUCT_RESULT_MVP_EXPECTED"}` yazar, `p.releases`'in son
    kaydına da (`_expected`, `sprint_system.gd:810-816`, MVP'yi bilmez). Ağaç v1'de açılır (`rnd_system.gd:63-64`):
    `_release` modeli `rnd_open: int(r.number) == 1`, sonuç bloğunun altına `PRODUCT_RELEASE_RND_OPEN` (düğmesi S12'de).
- **Kabul:** `full_run_b2c` MVP 7. tikte `PROBE PLAY ... publish` ve `SHIP day=7`; run_gate 3/3;
  `--product-shot=live:gate` (tek kurucu, 8 s, sprintler lider planıyla, Sprint 3 kapanışında kapı açık) TR+EN; S5.b:
  `live:gate` + `publish` karesinde beklenen satırı `PRODUCT_RESULT_MVP_EXPECTED` ve "Ar-Ge açıldı" satırı.

### S6 · Koşan sprint okunur
- **Nasıl:** aktif kipte işçisi olmayan, karar beklemeyen, bitmemiş kart `queued`: fazları üçü de "waiting", etiket
  `PRODUCT_QUEUED` "Sırada" (`product_model.gd:207-211,390-392`). Kart `phase_pts = {done, total}` etkin fazın;
  `_phase_row` (`sprint_card.gd:219-248`) etkin fazın etiketine "1,4/1,8" ekler. Sayaç (`sprint_panel.gd:163-181`)
  `running` yalnız işçili kartları sayar, `queued` ayrı parça (`PRODUCT_STATUS_QUEUED`).
- **Tek kartlı sprintte devret uyarısı (B6, B-D4):** B `seams_product.gd`'ye (`:32-53` sprint/karar bloğu)
  `urun.sprint_single_card` (TYPE_BOOL) ekler; okuma yeni `SprintSystem.sprint_card_count()` üzerinden (seam katmanı
  `_` önekli işleve uzanmaz). `product.sprint_late`'in metni ve varyantı C'nindir (TR/EN onay); B'nin seam commit'i
  C'nin kart commit'inden önce iner. Kart gövdesi koşullu olamaz (CLAUDE §5).
- **S6.b · Karar bekleyen, devreden, çıkarılan kart (S04, S08).** Kural aynı (karar bekleyen kart ilerlemez). Karar
  bekleyen kartın fazları "waiting", etiketi `PRODUCT_DECISION_HALTED`; sayaçta yalnız `decisions` (`product_model.gd:207-211`).
  `decision_carry` (`sprint_system.gd:233-247`) ve aktif `remove` (`:95-107`) sonunda `_restaff()` (`:625-626` deseni).
  F5 (karar): yeni `crunch_finishes() -> bool`: `decision_card_late`'in (`:425-433`) bekçileri (karar yoksa yanlış) ve
  oynatması, ekip puanı `hours_after(1.25)` ile (kartın crunch `mult`'u); kart sprintte biterse doğru. Seam
  `urun.crunch_finishes` (TYPE_BOOL) aynı bloğa (`seams_product.gd:32-53`); C'nin `sprint_late.json` kilidi onu okur (§6).
  Aynı hunk'ta `urun.paid_plan_set` (TYPE_BOOL: `SprintCatalog.tier(PAID_PLAN) > 0` ya da kart koşan/planlanan sprintte);
  C'nin `paid_tier.json` koşulu onu okur (AÇILIŞ R17 S15). İki seam de B'nin, C eklemez.
  Kabul: `sprint_decision_blocks_progress`'e iki assert (devret ve aktif `remove` sonrası boşalan kişi kalan kartın
  `assignees`'inde) ve `crunch_finishes()` için yetiştiren ve yetiştirmeyen birer kurulum; `live:active` karar kâğıdıyla
  "İş durdu · karar bekliyor".
- **Kabul:** `--product-shot=live:active` (kuyruktaki kart "Sırada", etkin fazda puan); sayaç "1 kart bitti · 1 sürüyor
  · 1 sırada"; `--event-lint` temiz; `--event-vocab` farkı yalnız `urun.sprint_single_card` ve `urun.crunch_finishes`
  satırları (dosya onaylıysa commit 6'ya, §6).

### S7 · Sprint oyuncunun onayı olmadan başlamaz; devir
- **Nasıl:**
  - `HOLD_PLAN := "sprint_plan"`. Yeni `SprintSystem.awaits_plan() -> bool`: tür seçili, `mode() != "active"` ve
    (`release.gate` ya da (`capacity() > 0`, planlanacak kart var (sprint ya da sonraki sütunda kapısı açık kart ya da
    açık aday; `SprintCatalog._open_cards` deseni) ve `not delegated()`)). Kapı kart ve devirden bağımsız tutar (B-K6;
    yoksa `_auto_start` kapıda bir şey yapmaz, günler akar, ürün kapalı kalır). Release kipi dahildir: sürüm notu
    penceresi kapanınca `product_release_note` düşer, plan tutuşu kalır (B-K2).
  - Yeni `sync_plan_hold()`: `TimeManager.is_batching()` ise, `EventBus.clock_batch_ended.is_connected(sync_plan_hold)`
    değilse `CONNECT_ONE_SHOT` ile bağlanıp döner (`_run_batch` tutuşta adım atmaz, `time_manager.gd:142-143,171-181`:
    00:00 kapanışında alınan tutuş saati gecede bırakırdı; aynı adımda birçok `_changed()` olur, ikinci `connect` ERROR);
    sonra bekçi (U1) `if awaits_plan() == TimeManager.holds().has(HOLD_PLAN): return` (bekçisiz her `_changed()` ağacı
    yeniden durdururdu, `time_manager.gd:299-309`; A `hold_clock`'u ayrıca sessiz yapar); `awaits_plan()` doğruysa
    `TimeManager.hold_clock(HOLD_PLAN)`, değilse `release_clock(HOLD_PLAN)`. Tek çağrı yeri `_changed()` (`:846-847`).
  - Sözleşme (AÇILIŞ C-10): tutuş tür seçiminin `_changed()`'inde alınır. Oyuncuya Boşluk'u öneren her yüzey
    `not TimeManager.is_clock_held()` ile kapılanır; AÇILIŞ R4 koşulunda bu terim zaten var (U5).
  - Yükleme (B-D2): `TimeManager.reset` tutuşları siler (`time_manager.gd:253`). `game_shell.gd` `_ready`'sine (`:25-29`):
    `EventBus.game_loaded.connect(func(_id: String) -> void: SprintSystem.sync_plan_hold())`; lambda kabukla düşer
    (`main.gd:3314-3331`; statik Callable ikinci yüklemede "already connected" ERROR). `HOLD_LABELS`'a (`PRD_SAAT.md`
    §4.1) `"sprint_plan": "CLOCK_HOLD_SPRINT_PLAN"`.
  - "Sprinti başlat" (`start()`, `:111-117`) tutuşu `_changed()` → `sync_plan_hold` ile kaldırır, hızı değiştirmez
    (B-K10, Model S, istisna yok): TopBar A'nın "DURDU · Boşluk ile sürdür" satırını gösterir, oyuncu Space ile sürdürür.
  - `daily_tick` (`:34-39`): plan ve release kipinde gün geçmişse `_auto_start()` yalnız `delegated()` ya da planlanacak
    kart yokken (B-K3). `sprint_never_stalls_in_plan` (`:16894`) ilk yarısı (boş sprint kendiliğinden başlar) korunur;
    ikinci yarısı: Sprint 3 planında araştırma yeniden aday, `awaits_plan()` doğru, sprint başlamamış; `apply_lead()` +
    `start()` sonrası araştırmayla koşar. `_auto_start` (`:673-684`) `release.gate` varken bir şey yapmaz; release
    kolunda `plan_next()`'ten sonra `if mode() != "plan": return` (devirde `plan_next` başlattı; yoksa `_begin` iki kez).
    Boş başlayan sprintte `p.empty_sprint`; model `center.empty`, panelde `PRODUCT_EMPTY_SPRINT` (`sprint_panel.gd:77-78`).
  - Boş geçirme (B-K4): plan kipinde alt şeritte ikinci sınıf `PRODUCT_SKIP_SPRINT`; tık önce onay satırı açar
    (`PRODUCT_SKIP_CONFIRM` + mevcut `UI_CONFIRM` "Onayla", `strings.csv:1611`), ikinci tık oyuncunun açık onayıdır.
    Yeni `SprintSystem.skip()`: yalnız `mode() == "plan"`; sprint kartları `send_next` (`:86-91`) ile sonraki sütuna,
    `_begin()`, `p.empty_sprint = sprint_number()`; saat akmaz (B-K10 aynı).
  - Devir: `GameState.product.delegate` (`new_state` `:62-72`'ye `false`; eski kayıt `.get("delegate", false)`).
    `delegated()` = `delegate` ve `SprintCatalog.quarter_pm() != null` (`sprint_catalog.gd:449-453`). Eylem
    `set_delegate(on)`. Devirde başlangıç (B-K5): `plan_next()` sonunda ve `TimeManager.speed_changed(>0)` plan ya da
    release kipindeyken (`_watch_team` bağlantı deseni, `:631-634`) `_auto_start()`; hafta kaybolmaz. Gece tiki yedek.
  - UI: denetim şeridinde (`product_tab.gd:171-188`) PM varken `PRODUCT_DELEGATE` + `CheckButton` (Geçmiş anahtarı
    deseni, `focus_mode` NONE); devirle başlayan sprintte `PRODUCT_PM_STARTED` (`sprint_panel.gd:77-78`;
    `PRODUCT_AUTO_STARTED` `build_bar.gd:159` için kalır); plan kipinde alt şeritte `PRODUCT_PLAN_HOLD` (`:249-251` deseni).
  - Bot (B-D1): plan tutuşu hata değildir. `_run_sim` (`run_probe.gd:631-645`) `is_clock_held()` denetiminden önce,
    `awaits_plan()` ise: `_full_run` → `_plan_the_sprint()` (sözler, ücretli plan, `_keep_building` dahil); değilse
    (`b2c` preset'i, `:1504-1505`) yeni `_start_on_lead()`: kapıdaysa `publish()`, sonra `plan_next()`, `apply_lead()`,
    `start()`. Başlatamazsa `PROBE ERROR day=%d plan unstartable`; başka tutuşlar bugünkü gibi hata (`:637-639`).
    `_seed_b2c_world` (`:1553-1559`) yalnız Sprint 1'i başlatır. Sahip onaylarsa (§6) `_run_realtime` (`:680-699`):
    tutuşta `hour_changed` almaz, aynı kol `clock_batch_ended`'de koşar, başlatınca `speed_change_requested(speed_idx)`.
  - Harness (B-D1, `main.gd`, A'dan sonra ayrı hunk): A'nın `_seed_tempo_state()`'inde (HEAD'de `_run_tempo_probe`
    `main.gd:414,422-423`; tempo ve tick paylaşır, `PRD_SAAT.md` §1, §9.1) `choose_type` ardından `apply_lead()` +
    `start()`; tempo 3. tikte durur (`main.gd:393`). `tick_probe.gd` tutuş kolunda `awaits_plan()` doğruysa kapıda
    `publish()`, release'te `plan_next()`, sonra `apply_lead()` + `start()` ve hız yeniden basılır; `TICK|stall` yalnız
    başlatılamayan planda. `choose_type` çağıran öbür shot'lar (`main.gd:658,895,933`) tutuşla açılır: TopBar tutuş
    satırı görsel kabulde beklenen farktır, raporda anılır.
  - Smoke: `sprint_auto_start_after_a_day` (`:16632`, dağıtım `:443`) `sprint_starts_only_with_consent` olur: PM'siz bir
    gün → plan kipi, tutuş var; `start()` → tutuş yok, hız 0; `skip()` → aktif, kart yok, `empty_sprint`; PM ve devir →
    başlar, `auto_started`, `plan_next` sonrası `sprint_started` tam bir kez; release'te `skip_night` sonrası tutuş
    08:00'de; kaydet → `apply_loaded_state` → `sync_plan_hold()` (kabuk satırının çağırdığı) → `holds()` `sprint_plan`
    içerir, `_on_speed_change_requested(1)` sonrası `current_speed == 0`.
- **Kabul:** `--run-log=full_run_b2c:16:sim` ve `b2c:52:sim` sıfır `ERROR`, MVP 7. tik; `--tempo-probe=1` ±%2;
  `--tick-probe=1` 5 hafta `TICK|stall` yok, `TICK END` var, `TICK|hour` p95 ≤ 3 ms, A'nın K10 değeriyle yan yana (U7);
  görsel: `live:plan` (PM'li kadro, `main.gd:2217-2220`): tutuş notu, TopBar `CLOCK_HOLD_SPRINT_PLAN`, boş geçir ve onay
  satırı, "Sprinti başlat" sonrası "DURDU", devir anahtarı; `live:delegate` (`set_delegate(true)`, `plan_next` sonrası
  aktif sprint, `PRODUCT_PM_STARTED`); plan tutuşunda "Görüşmeye git" tostla reddedilir (A11, A'nın işi; B gözler).

### S8 · Yayın sonrası B2C okuması
- **Nasıl:**
  - Ürün başlığı (`product_tab.gd:157-168`): canlı B2C'de `PRODUCT_KPI_USERS` (`SalesSystem.b2c_audience()`,
    `sales_system.gd:265-266`, `Fmt.group`) ve `PRODUCT_KPI_PAYING` (`b2c_paying_users()`, `:274-276`); tür seçilmeden
    sürüm ölçüsü çizilmez. Model `header.users`, `header.paying` (-1 = yok); pencere `day_advanced`'de kurulur (`:95`).
  - Haftalık örnek (B-K9): `SalesSystem.daily_tick` (`sales_system.gd:123-130`) `mvp_shipped` ve B2C iken
    `GameState.set_flag("b2c_audience_history", …)`'e `{day, users, paying}` ekler, son 26 satır (`append` +
    `slice(-26)`). `FLAG_TYPES`'a girmez (kayıtsız bayrak `save_codec.gd:218-234` ile döner, okuyan `int()` ile okur).
  - Satış (`sales_tab.gd:166-185,218-232`): canlı B2C'de boş hâl yerine sayfa: Kullanıcı · Ödeyen · Dönüşüm
    (`SalesSystem.conversion_rate(price)`, `Fmt.percent`) · Ücretli plan (açık: fiyat/ay; kapalı:
    `SALES_B2C_PLAN_CLOSED`); altında haftalık kullanıcı sütunları (sayfanın içinde tek `draw` Control, renk `D_*`
    token); plan kapalıyken `SALES_B2C_PLAN_HINT` ve `SALES_GO_PRODUCT` düğmesi (`EventBus.tab_changed.emit("product")`).
    Boş hâller: tür yok → `SALES_EMPTY_UNTYPED`; B2C MVP öncesi → `SALES_EMPTY_B2C_PRE`; B2B canlı değil → mevcut
    `SALES_LOCKED_NO_B2B`. `SALES_B2C_NOTE` (`:229`) başka okuyanı yoksa silinir. Sayfa `_empty`'nin kardeşi yeni bir
    VBox'tır, kodla kurulur (`SalesTab.tscn` değişmez); grafik ölçüleri mevcut `D_*` boyut token'larından, yeni token
    gerekirse dur ve sor (CLAUDE §7.1-2, THEME_STAMP).
  - Sürüm notu: kitle yayından sonra saat saat birikir (`sales_system.gd:160-166`). `_fill_actual`
    (`sprint_system.gd:820-827`) MVP sürümünün ertesi tikinde `r.users`'ı yazar (B-B5): "Gerçekleşen" satırı
    (`PRODUCT_RESULT_ACTUAL`), Geçmiş satırı ve açıksa not, `PRODUCT_RELEASE_USERS` "İlk hafta 181 kullanıcı". Yalnız
    `int(r.number) > 0` kayda: `_fill_actual` yalnız `day == r.day + 1` ve dolu `shipped`'e bakar, kapıdaki kapanış atlanır.
  - **S8.b (S38, S15):** B2B MVP öncesi boş hâlde `SALES_LOCKED_NO_B2B` altına `SALES_EMPTY_B2B_PRE` + `SALES_GO_PRODUCT`
    (`sales_tab.gd:220-232`). `SprintBridges.open_paid_plan` (`sprint_bridges.gd:183-184`), satır `FRANK_ADVISORY_PAID_TIER`
    ise `EventBus.mentor_advisory_changed.emit("", {})` (sahibin sinyali, `game_state.gd:315-317`). Kart metni C'nin (§6).
- **Kabul:** `--sales-shot=untyped`, `--sales-shot=b2c` (mevcut, `main.gd:893-899`), yeni `--sales-shot=b2c_live`
  (`--tab-shot=sales` B2C durumu kurmaz) ve `--product-shot=live:b2c_live` (B-D1) TR+EN taşmasız. `b2c_live` kurulumu:
  `_seed_product_live` yolu + kapıda `publish`, sonra 4 tik; kitle saatlik aktığı için (`sales_system.gd:143-146,
  160-166`) her tik `SalesSystem.hourly_tick` × 24 + `advance_day` + `SprintSystem.daily_tick` + `SalesSystem.daily_tick`.
  Koşu `SHOT|b2c users=<b2c_audience()> paying=<b2c_paying_users()>` basar; ekrandaki sayılar bu satırla eşit
  (shot dünyası `full_run_b2c`'nin dünyası değildir). S8.b: yeni `--sales-shot=b2b_pre` TR+EN; `sprint_paid_plan_opens_paid_tier`
  (`endgame_smoke.gd:16703`) satırı `FRANK_ADVISORY_PAID_TIER` ile başlatır, plan çıkınca `mentor_line_key == ""` ister.

### S9 · Mesai modali dürüst
- **Nasıl:** şirket satırının hemen altına tek satır (B-B9; solo kurucuda `_cost_block` null döner,
  `work_hours_modal.gd:381-385`, §0): tür seçiliyken `HR_HOURS_SPRINT_POINTS` "Haftalık sprint puanı 2 → 2,9" (önce
  canlı, sonra taslak; eşitse `HR_HOURS_SPRINT_POINTS_NOW`). Değerler yeni `SprintSystem.week_points(draft := {})`:
  `team()` kişileri, saat taslakta `WorkHoursSystem.hours_in` (`work_hours_system.gd:185-194`); `_points` saati
  parametre alır (`sprint_system.gd:940-948`). Şirket saati 8'i aşarsa altında `HR_HOURS_RULE_OVERTIME_OUTPUT`.
  `HR_HOURS_COMPANY_SUB` (`work_hours_modal.gd:196`) "Kurucu + {n} çalışan". Sayılar `Fmt.number(x, 1)`.
- **Kabul:** `--hr-shot=saatler-sprint` (B-D1: tek kurucu, tür seçili, taslak 15 saat; tür `_run_hr_shot`'un kadro
  kurmayan türlerine eklenir, `main.gd:2043`) TR+EN; satır "2 → 2,9", "Kurucu + 0 çalışan".

### S10 · Ölçüm aracı `--sprint-probe`
- **Nasıl:** `scripts/debug/sprint_probe.gd`, `extends RefCounted`, `class_name` yok, `static func run(spec, payload)`;
  `main.gd`'ye bir `preload` sabiti (`:30` `OFFICE_PAN` deseni) ve `valued` tablosuna (HEAD'de `:190-219`) bir
  satır, `--product-shot=` satırının yanında, A'nın `--tick-probe=` satırından ayrı hunk (B-D1). Spec
  `hours=<h>:cards=<1|2>:ticks=<t>[:start=9][:seeds=1][:seed=N]
  [:events=0|1][:rate=0][:beta=0|1][:lead=0|1][:gate=publish|more]`. Kurulum `EndgameSmoke` deseni:
  `GameState.initialize_run(payload + tohum)`, `ProductLines.reload()`, events=0'da karar oranı 0 (`endgame_smoke.gd:16237-16241`),
  `choose_type("note_tool", ...)`, `GameState.company_work_hours/start_hour`. events=0: `GameState.advance_day()` +
  `SprintSystem.daily_tick()` (`main.gd:2412-2414` deseni); events=1: `TimeManager.advance_hours`/`skip_night` ve masa
  kâğıtları RunProbe'un cevap yoluyla (kopyalanmaz, çağrılır). Satırlar: `SPRINTPROBE PRED|tohum|sprint|kart|split|
  done|finishes|no_start|mvp_eta`, `SPRINTPROBE CLOSE|tohum|sprint|kart|shipped|carried_done|MATCH|MISMATCH[|cause=<olay>]`,
  `SPRINTPROBE MVP|tohum|day`, `SPRINTPROBE SUMMARY|match=n/n|mvp_days=...`.
  - `cards=N`: her planlamada sprint önce devreden kartlarla, sonra Çekirdek kimlik hatlarının açık K1 adaylarıyla
    (efor sırası) N karta tamamlanır, `SprintSystem.add()` ile; `add` reddederse kart konmaz,
    `SPRINTPROBE SKIP|tohum|sprint|kart|reason` basılır. `lead=1`'de kartları `apply_lead()` koyar.
  - Alanlar commit'le gelir (olmayan API'ye statik çağrı parse hatası): commit 1 `CLOSE`/`MVP`/`SUMMARY`, commit 3
    `PRED`, commit 4 `mvp_eta`, commit 5 `gate=`.
  - Neden: `event_resolved` kartı `hours_mult`'u ya da eforu değiştirdiyse `cause=<kart id>`; `hr_day_processed`/
    `character_removed` ile ekip değiştiyse `cause=team`. events=1'de `rate` yoksa `decision.rate` (0,35).
- **Kabul:** §3'ün her satırı tek komutla üretilir; aynı tohum iki koşu bayt-eş; events=1'de adsız uyuşmazlık 0.

### S11 · Belgeler
PRD rev 7 (`docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md`) §3.5 (artık puan; "Kurucu Ürün ve Yazılım'da 0.75" bayat,
kod 1.0), §3.6 (MVP kapısı), §3.8 (lider yalnız bitenleri önerir), §3.9 (Yayınla), §3.11 (otomatik başlama yalnız
devirde, plan tutuşu). GUNCELLEMELER "Ürün rev 7" (`:173`) yeni madde; `:223` (9) "1 puan pay kalır" değişir.
ACIK_KARARLAR yeni madde **106** (son madde 104, `:1507`; A 105'i alır, C eklemez; U8): B-K8 açık maddesi (12 saat ve
üstü MVP'yi 2 tik öne alır, §3) ve GDD'ye işlenmemiş kararlar (B1–B10, B-K1…B-K10).
HARITA Ürün (`:114-132`; `:120` "Okumalar"da `effort_split` → `plan_outcome`; `mvp_eta`, `publish`, `awaits_plan`,
`sync_plan_hold`, `skip`, `week_points`, `set_type_draft`, `crunch_finishes`, `--sprint-probe`, `live:solo15|solo15_tip|
gate|b2c_live|delegate|rnd|pick_relang`) ve Satış (`:180,185`; `--sales-shot=b2c_live|b2b_pre`). `CLAUDE.md` §12 (F3):
yalnız B'nin bayrak satırları (`--product-shot=live:` listesine yedi tür, `--sales-shot=b2c_live|b2b_pre`, `--sprint-probe`),
A'nın metni üstüne ayrı hunk. Kabul: `grep -rn "SprintSystem.effort_split\|func effort_split" docs scripts` boş (model
alanı `effort_split` kalır, S2).

### S12 · Ürün'den Ar-Ge'ye yol (S22, S48)
- **Ne / neden:** kurucu Ar-Ge'deyken Ürün bunu adıyla söyler; araştırma kilidi ve v1.0 notu Ar-Ge'ye götürür (§0b).
- **Nasıl:** model `center.rnd_node` = kurucu `JOB_RESEARCH` taşıyorsa `RnDSystem.active()` (`rnd_system.gd:674`);
  doluyken plan gerekçesi `PRODUCT_TEAM_IN_RND` (`ResearchSeam.node_name`); ekip boşken ekip satırı çizilmediği için
  (`sprint_panel.gd:81-88`) aktif kipte aynı satır `_note` olarak, `_nobody`'de düğme `PRODUCT_GO_RND`. Kart modeline `locked_rnd` (`LineGates.unmet_parts`'ın ilk `KIND_RESEARCH` düğümü,
  `sprint_catalog.gd:326-328`); `sprint_card.gd:129-130` doluyken bağlantı çizer. Üçü tek eylem: `_act` "rnd"
  (`product_tab.gd:216-234`) → `tab_changed.emit("rnd")`, sonra `rnd_node_requested.emit(node, false)` (sıra
  `research_bar.gd:176-179`); fikstür eylem tablosuna da.
- **Kabul:** yeni `--product-shot=live:rnd` (tek kurucu Ar-Ge'de, plan kipi) "Kurucu Ar-Ge'de: …" + "Ar-Ge'ye git", sonra
  `_act("rnd", …)` karesi düğüm seçili Ar-Ge; `--product-shot=cards` kilitli araştırma kartında bağlantı.

### S13 · Tür seçici taslağı korunur (S53)
- **Ne / neden:** sayfa yeniden kurulunca (dil, palet, gelen kutusu; §0b S53) seçilen pazar, tür ve ad kalır.
- **Nasıl:** `SprintSystem.set_type_draft(d)` → `GameState.product.type_draft` (`{market, subtype, name}`, sinyalsiz);
  `choose_type` (`sprint_system.gd:46-57`) siler; yeni koşuda `product.clear()` (`game_state.gd:869`). `TypePicker`
  `setup`'ta okur, `_pick_market`/`_pick_type`/ad girişinde yazar.
- **Kabul:** yeni `--product-shot=live:pick_relang` (`pick_named` + `language_changed`): ikinci karede seçim duruyor, EN.

### Metinler (TR/EN onay bekliyor; EN önce yazılır)

| Anahtar | EN | TR |
|---|---|---|
| `PRODUCT_CARD_SPILLS_PTS` / `PRODUCT_CARD_NO_START` | carries over · {done}/{total} / Won't start this sprint → Sprint {n} | devreder · {done}/{total} / Bu sprint başlamaz → Sprint {n} |
| `PRODUCT_ADD_CLOSED_FULL` / `PRODUCT_LEAD_TIP_SELF` | No spare points left this sprint / Your own note | Bu sprintte boş puan kalmadı / Kendi notun |
| `PRODUCT_MVP_RULE` | {version} = {need} {area} cards · {done}/{need} done · forecast end of Sprint {sprint} (Week {week}) | {version} = {need} {area} kartı · {done}/{need} bitti · tahmin Sprint {sprint} sonu (Hafta {week}) |
| `PRODUCT_MVP_RULE_NO_ETA` | {version} = {need} {area} cards · {done}/{need} done | {version} = {need} {area} kartı · {done}/{need} bitti |
| `PRODUCT_MVP_LEFT` / `_ONE` | {n} cards left for {version} / {n} card left for {version} | {version} için {n} kart kaldı (ikisinde de) |
| `PRODUCT_BETA_RULE` | Done cards wait one sprint; the chance of a faulty card halves | Biten kartlar bir sprint bekler, hatalı çıkma ihtimali yarıya iner |
| `PRODUCT_GATE_TITLE` / `PRODUCT_GATE_ONE_MORE` | {version} is ready / One more sprint | {version} hazır / Bir sprint daha |
| `PRODUCT_GATE_BODY` | The {area} cards are done. Ship now and users start arriving this week. Wait one more sprint and the product stays closed until the next close. | {area} kartları bitti. Yayınlarsan kullanıcılar bu hafta gelmeye başlar. Bir sprint daha beklersen ürün sonraki kapanışa kadar kapalı kalır. |
| `PRODUCT_PLAN_HOLD` / `CLOCK_HOLD_SPRINT_PLAN` | Paused until the sprint starts / Sprint plan waiting | Sprint başlayana kadar oyun durur / Sprint planı bekliyor |
| `PRODUCT_EMPTY_SPRINT` / `PRODUCT_QUEUED` / `PRODUCT_STATUS_QUEUED` | Empty sprint · no one is working on a card / Queued / queued | Boş sprint · kimse kart üstünde çalışmıyor / Sırada / sırada |
| `PRODUCT_SKIP_SPRINT` / `PRODUCT_SKIP_CONFIRM` | Skip this sprint / No one works on a card this sprint. | Bu sprinti boş geçir / Bu sprint kimse kart üstünde çalışmaz. |
| `PRODUCT_DELEGATE` / `PRODUCT_PM_STARTED` | Delegate planning: {name} / {name} started the sprint | Planlamayı devret: {name} / Sprint {name} tarafından başlatıldı |
| `PRODUCT_KPI_USERS` / `PRODUCT_KPI_PAYING` | Users / Paying | Kullanıcı / Ödeyen |
| `PRODUCT_RELEASE_USERS` / `_ONE` | {n} users in the first week / {n} user in the first week | İlk hafta {n} kullanıcı (ikisinde de) |
| `SALES_EMPTY_UNTYPED` / `SALES_EMPTY_B2C_PRE` | Pick your path in Product first. / Your users show up here once {version} ships. | Önce Ürün'de yolunu seç. / {version} yayınlanınca kullanıcıların burada görünür. |
| `SALES_B2C_CONVERSION` / `SALES_B2C_PLAN` / `SALES_B2C_PLAN_CLOSED` / `SALES_B2C_CURVE` / `SALES_GO_PRODUCT` | Conversion / Paid plan / Closed / Weekly users / Go to Product | Dönüşüm / Ücretli plan / Kapalı / Haftalık kullanıcı / Ürün'e git |
| `SALES_B2C_PLAN_HINT` | Revenue starts with the Paid plan card in Product's Revenue area. | Gelir, Ürün'de Gelir alanındaki Ücretli plan kartıyla başlar. |
| `HR_HOURS_SPRINT_POINTS` / `_NOW` | Weekly sprint points {before} → {after} / Weekly sprint points {n} | Haftalık sprint puanı {before} → {after} / Haftalık sprint puanı {n} |
| `HR_HOURS_RULE_OVERTIME_OUTPUT` / `HR_HOURS_COMPANY_SUB` (değişir) | Hours past eight count at half output / Founder + {n} employees | Sekiz saatin üstündeki saatler yarım verimle sayılır / Kurucu + {n} çalışan |
| `PRODUCT_DECISION_HALTED` / `SALES_EMPTY_B2B_PRE` | Work stopped · decision waiting / Leads arrive once {version} ships. | İş durdu · karar bekliyor / {version} yayınlanınca adaylar gelir. |
| `PRODUCT_RESULT_MVP_EXPECTED` / `PRODUCT_RELEASE_RND_OPEN` / `PRODUCT_TEAM_IN_RND` / `PRODUCT_GO_RND` | The product is live · first users arrive this week / R&D is open / The founder is in R&D: {node} / Go to R&D | Ürün yayında · ilk kullanıcılar bu hafta gelir / Ar-Ge açıldı / Kurucu Ar-Ge'de: {node} / Ar-Ge'ye git |

Brief'in "v1.0'a 2 kart kaldı" ve "Planlamayı <PM>'e devret" hâlleri yer tutucuya ek bindirir (CLAUDE §5, ortak hüküm
0); yukarıdakiler onların yerine. "Yayınla" yeni anahtar değil: `PROD_SHIP_PUBLISH` (`strings.csv:1122`), bugün yalnız
bağsız `data/events/cards/unwired/first_ship.json` okur. Aynı metni taşıyan anahtar varsa yenisi açılmaz: Satış
etiketleri `PRODUCT_KPI_USERS/PAYING`'i, fiyat `SALES_PER_MONTH`'u (`strings.csv:102`) okur. `PRODUCT_CARD_SPILLS`
(`:2710`, tek okuyanı `sprint_card.gd:177`) `_SPILLS_PTS`'e yer bırakıp silinir.

## 5. Commit dizisi ve kapılar

Her commit: lint → `loc_residue` → `loc_csv_integrity` → dokunulan vakalar (tam smoke yok); diff ayrı ajanca (§9); görsel §11.

| # | Commit | Kapı |
|---|---|---|
| 1 | Araç: `sprint_probe.gd` + `main.gd` `preload` ve bayrak satırı (B-D1, ayrı hunk) | Bugünkü motorla §3'ün "bugün" sütunu (8 s → 7, 15 s → 7, 16 s/08:00 → 5, 15 s Beta → 9) |
| 2 | Motor: artık puan, float kapasite, smoke güncellemeleri | §3 "2 kart" sütunu probe'la (eski "+": 10 ve 11 s 5 çıkar, commit 3'ten sonra yeniden ölçülür); `sprint_*`/`product_*` ve §1'in float kapasite vakaları yeşil; run_gate 3/3 + fark raporu. Mesaj: "sahip kararı 2026-10-10 B1" |
| 3 | Ürün: `plan_outcome`, devreder/başlamaz, "+", SPRİNT SONUNDA, lider, tür seçicide `apply_lead`, aktifte plan notu yok, sürüm notu lider satırı (S2, S2.b, S3, S3.b) | probe PRED=CLOSE %100; §3 "2 kart" ve "lideri izleyen" (`lead=1`) sütunları; `sprint_ceiling_125_blocks_add`; `live:plan`, `live:solo15`, `live:solo15_tip`, `live:active` (aşım bloğu yok) TR+EN; "TR/EN onay bekliyor" |
| 4 | Ürün: sürüm koşulu satırı, `mvp_eta`, MVP öncesi not, beta satırı, beta yalnız planda (S4, S4.b) | probe eta = MVP; plan/aktif/not kareleri; `edge:no_release` beta varyantı |
| 5 | Ürün: sürüm kapısı, `publish`, bot, `_seed_product_live` publish (`main.gd` `:2406-2441`), smoke, v1.0 beklenen ve Ar-Ge satırı (S5, S5.b) | run_gate 3/3; `full_run_b2c` publish 7. tik; `live:gate`; `live:b2c_mvp`, `live:b2b_requests` canlıya çıkıyor; A'nın `--clock-shot=held` yeniden çekilir (not `publish` sonrası açık); C1 B'den önce indiyse `cheque_read_steps` yeşil (U12) |
| 6 | Ürün: Sırada, faz puanı, sayaç; karar bekleyen kart, devret/çıkar sonrası yeniden atama; `crunch_finishes()`, `urun.sprint_single_card` ve `urun.crunch_finishes` seam'leri, onaylıysa `_vocabulary.md` (S6, S6.b) | `live:active`; `sprint_decision_blocks_progress` (`crunch_finishes` kurulumları dahil); lint; `--event-vocab` farkı iki satır; C'nin `sprint_late` commit'inden önce |
| 7 | Ürün: onay kuralı, plan tutuşu, boş sprint ve boş geçirme, devir, bot ve harness başlatma, `tick_probe.gd` tutuş kolu, `HOLD_LABELS` satırı, `game_shell.gd` yükleme kancası (S7) | `full_run_b2c:16:sim`, `b2c:52:sim` sıfır ERROR; `sprint_starts_only_with_consent`, `sprint_never_stalls_in_plan`, `quiet_cards_fill_empty_floor` (döngü planda `apply_lead()`+`start()`, kapıda `publish()`), `sprint_late_only_when_behind`, `sprint_decision_blocks_progress`; `--tempo-probe=1` ±%2; `--tick-probe=1` `TICK|stall` yok, saatlik adım p95 ≤ 3 ms, A'nın K10 değeriyle yan yana (U7); `live:delegate`; A'nın `--clock-shot=released` yeniden çekilir: B sonrası da "DURDU" (kol `start()` çağırır, sprint aktif, `awaits_plan()` yanlış), A'nın tabanıyla fark yok (U3, `PRD_SAAT.md` §9.2) |
| 8 | Ürün ve Satış: B2C okuması, `sales_system.gd` kitle örneği, B2B MVP öncesi işaret, Frank satırı düşer (S8, S8.b) | `sales-shot=untyped|b2c|b2c_live|b2b_pre`, `live:b2c_live`; `sprint_paid_plan_opens_paid_tier`; C3'ün Satış yönlendirmesi bu commit'i bekler (U6) |
| 9 | Ekip: mesai modali satırı (S9) | `hr-shot=saatler-sprint` |
| 10 | Ürün: Ar-Ge yolu, tür seçici taslağı (S12, S13) | `live:rnd`, `live:pick_relang` TR+EN; kilitli araştırma kartında bağlantı |
| 11 | Belgeler (S11) | grep kontrolü |

## 6. Sahibe bırakılan kararlar

Hükümle kapanan sorular gövdede kodlarıyla işli. Sahibe giden yalnız şunlar:
- **B-K8 · Kurucunun mesaisi bedelsiz (bilgi).** Ücret ve moral yazmıyor (`work_hours_system.gd:63-66,222-241`); artık
  puanla 12 saat ve üstü MVP'yi 2 tik öne alır (§3), bedelsiz baskın strateji. Bu turda değişmez; ACIK 106 (S11).
- **TR/EN metin tablosu (§4 Metinler).** Hepsi taslak; commit mesajında "TR/EN onay bekliyor".
- **Onarım 1 (Ürün/Ar-Ge artıkları).** S16, S22 atama paneli uyarısı, S34, S48 işe alım işareti, S49 (F4); B dokunmaz.
- **SAHİBE · hükümsüz dokunuşlar (onaysız yapılmaz, raporda ⚠️).** `run_probe.gd`'de brief'in ve B-D1'in dışı:
  `_on_sprint_closed` hız satırı (`:270`; onaysız `int()` 5,75'i 5 basar) ve `_run_realtime` (`:680-699`) tutuş kolu
  (onaysız gerçek saat kipi plan tutuşunda bekler; run_gate sim'dir). `_vocabulary.md`: B-D4 ve F5 seam'lerinin
  `--event-vocab` çıktısı; onaysız commit 6'ya girmez, fark raporda.

**B'nin dayandığı A/C payları** (hükümle verildi; B dokunmaz, sahibe gitmez):
- S03 · A (F2): `_open_after_gate` (`main.gd:2922-2931`) kapı çözülünce `SprintSystem.mode()` `release` ya da `plan` ise
  Ürün'ü yeniden açar; kapanış gecesi gelen karttan sonra sürüm notu ve plan tutuşu (S7) bu yolla görünür. A önce iner
  (§1); B onu yazmaz, varsayar.
- S03 · C (F5): `Inbox.show` (`inbox.gd:29-33`) silinen sayfayı atlar.
- S04 · C (F5): `sprint_late.json` crunch seçeneği ×1,25 kartı yetiştirmiyorsa kilit ya da yeni gövde; B'nin
  `urun.crunch_finishes` seam'ini okur (S6.b; B'nin commit 6'sı C'nin kart commit'inden önce).
- S15 · C (F5): `paid_tier.json` kopya ve koşulu: Ücretli plan kartını adıyla anar, plan sprintte ya da çıkmışsa gelmez.
- S37 · C (F5): v1'de Ar-Ge ray rozeti (`left_tabs.gd:295`).

## 7. Erdem'in bakacakları
- 15 saat: ikinci kart "devreder · 2,75/3", çubuk "6/5,75"; lider önerisi iki kart, "KENDİ NOTUN".
- "Sprint başlayana kadar oyun durur", Space akıtmaz; "Sprinti başlat" sonrası "DURDU · Boşluk ile sürdür"; boş geçir onayı.
- 8 saat, Sprint 3 kapanışı "v1.0 hazır"; "Bir sprint daha" ürünü kapalı tutar, "Yayınla" CANLI yapar; tahmin "Hafta 6".
- Yayından bir hafta sonra Ürün başlığında KULLANICI ve ÖDEYEN; Satış'ta kitle sütunları ve Ücretli plan satırı.
- "Kurucu + 0 çalışan", "2 → 2,9"; devir anahtarı; "İş durdu · karar bekliyor"; "Kurucu Ar-Ge'de: …"; "Ar-Ge açıldı".

## 8. Doğrulama listesi
S1–S13 (S2.b–S8.b dahil) Kabul satırları ve §5 kapıları; run_gate 3/3; `loc_residue`, `loc_csv_integrity` temiz. Görsel
TR ve EN, taşmasız, logda hata yok: `live:plan|solo15|solo15_tip|active|gate|b2c_live|delegate|rnd|pick_relang`, MVP
öncesi not (beta dahil), `sales-shot=untyped|b2c|b2c_live|b2b_pre`, `hr-shot=saatler-sprint`, A'nın
`--clock-shot=held|released`. Ölü kod yok: `SprintSystem.effort_split`, `PRODUCT_CARDS_LEFT(_ONE)`,
`PRODUCT_CARD_SPILLS`, okuyanı kalmadıysa `SALES_B2C_NOTE`.

## 9. Done mesajı
Madde madde ✅/⚠️/❌ (S1–S13, S2.b–S8.b, §8) kanıtla (commit, test, probe satırı, ekran yolu); ölçülmüş §3; run_gate
farkı; TR/EN onay bekleyenler; ACIK 106; §6 SAHİBE onaylarının durumu; commit listesi; push yapılmadı.

## 10. Öğretici notlar
- **SENKRON KURALI.** Ürün durumu yalnız günlük tikte ve oyuncu eyleminde yazılır (A otomatik kaydı iş parçacığına
  alıyor, yakalama 00:00 adımında); `GameState.product`'a iş parçacığından ya da ertelenmiş çağrıdan yazma.
- **Atama ile döküm aynı sırayı izler.** `_end_week`, `_play_out` ve `plan_outcome` `_assign` + bütçe döngüsünü çağırır,
  kopyalamaz. Ekip hafta içinde değişirse (`_restaff`, `:644-652`) önizleme ayrışabilir; probe events=1 adlandırır.
- **Statik metin.** Statik sistemlerde `tr()` değil `TranslationServer.translate` (`_t`). `sprint_probe.gd` `class_name`
  almaz (öbür oturumların ekransız koşularını düşürür, `scripts/ui/components/bar_kit.gd:6-8`).
- **Sözlükte yeni alan.** `GameState.product` bir sözlüktür; `SaveCodec` yalnız değişkenleri bulur. Yeni anahtarlar
  (`delegate`, `empty_sprint`, `gate_faulty`, `release.gate`, `release.users`) `new_state`'e girer (tür öncesi
  `type_draft` girmez) ve `.get(..., varsayılan)` ile okunur; şema sürümü değişmez.
- **Fikstür sözleşmesi.** `ProductModel` sözlüğüne giren her yeni alan (`mvp_line`, `gate`, `no_start`, `planned_done`,
  `addable`, `queued`, `phase_pts`, `lead_tip.self`, `center.empty`, `center.delegate {on, name}`, `center.pm_started`,
  `center.plan_hold`, `header.users/paying`, `release.users`, `release.rnd_open`, `center.rnd_node`, `locked_rnd`) ve
  silinen `next_version.cards_left` `product_model.gd` başındaki sözleşmeye ve `product_fixtures.gd`'ye aynı commit'te
  girer; yoksa `c1..c5` çöker.
