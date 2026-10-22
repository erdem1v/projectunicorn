# Faz A · Hatalar ve hata gösterimi · Adım tablosu ve yürütme planı

## Bağlam
- **Görev:** `project-unicorn/docs/tasks/faz_ab/PRD_FAZ_A_HATALAR.md`.
- **Okunan ekler:** `A_PLAN.md`, `A_INCELEME.md`, `ERDEM_TUR2_YORUM.md`, `ERDEM_AB_CEVAP.md`, `ORTAK.md`, `TUR2_SUNUM.md`.
- **Kod durumu:** HEAD `1faeb82`, A_PLAN'ın yazıldığı commit'le aynı. Plandaki dosya:satır başvuruları bugün de geçerli.
  Üç Sonnet keşifçisi bunu yaklaşık 45 başvuruda yokladı; üç kayma buldu, hepsi aşağıdaki yürütücü notunda.
- **Görev belgesinin ilk işi:** adım tablosu ve Erdem'in onayı. Bu belge o tablodur; onaydan sonra A0'dan başlanır.
- **Erdem'e dönülen yerler:** (1) bu tablo, (2) E1, (3) R. Bunların dışında sormadan ilerlenir.
- **Tek istisna:** Bir dilim, bir düzeltme turundan sonra da kapıyı geçemezse.
- **İnceleme:** Tablo, Erdem'e gitmeden önce bir Opus incelemesinden geçti (17 bulgu). Bulguların hepsi aşağıya işlendi.

## Adım tablosu
§8'deki tablo temel alındı. Değişen satırlar "Neden" sütununda **değişti:** ile başlar.

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| A0 | §5 araştırması: en az 6 oyun. Her satırda kaynak bağlantısı ve "arandı / bulunamadı" alanı, kaynaksızlar işaretli. Çıktı: iki ölçünün hedefi, akış sabitleri, Karar 4 mekanizma önerisi, §4.4 hedeflerinin gözden geçirilmesi | Alt ajan | Sonnet | orta | 25 dk (A1 ile paralel) | Akış hedefleri ve Karar 4 buna dayanır |
| A1a–c | Bağlantı haritası (§6), üç paralel okuyucu: (a) sistemler; (b) olay motoru, veri, kayıt, araçlar; (c) arayüz ve belgeler | Alt ajan ×3 | Sonnet | yüksek | 30 dk | **değişti:** tek ajan yerine üç. §6'da 60'a yakın kalem ve dört katman var; tek bağlamda kalem kaçar |
| A1d | Kod öncesi taban: §4.6(a) sprint probe'u ve adlı uyuşmazlık listesi. Ayrıca `full_run` ve `full_run_b2c` 104 hafta: süre ölçülür, bugünkü haftalık yeni ve açık hata serisi çıkarılır | Alt ajan | Haiku | düşük | 25 dk | **değişti:** Komut koşusu Haiku'ya verildi. Tek taban, K1'in ekonomi kaymasına ve K5'in paralel koşu sayısına yarar |
| A2 | Üç haritayı birleştirir, her satırı kodda doğrular, grep süpürmesiyle haritada olmayan okuyucuyu arar. §6'daki "%40 zarı Karar 13 sonrası atılıyor mu" sorusunu kontrol eder. Yürütücü notunu (aşağıda) genişletir | Alt ajan | Opus | yüksek | 25 dk | **değişti:** Birleştirme ve not eklendi. Yürütücü, A_PLAN'ın geçersiz kısımlarını kodlamaz |
| E1 | **Erdem durağı.** A0 özeti, iki ölçünün hedefi, Karar 4 mekanizması, yapılabilirlik hesabı (A1d'nin gerçek akışıyla), düzeltme payı hedefleri (erken dönem dahil), `fix_due` tanımı | Ana | Opus | orta | Erdem'e bağlı | K1–K4 iş akışı arka planda **başlatıldıktan sonra** gönderilir; bekleyiş işi durdurmaz |
| K1 | Görevler matrisi sprinte bağlanır, kurucu dahil (Karar 13; ayrıntı aşağıda) | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | max / düşük / yüksek | 3 sa | **değişti:** K1a ile K1b birleşti. Masa tarafı bugün zaten Karar 13'e uyuyor (`support_system.gd:191-223`, `hr_system.gd:393`). §4.9'un sprint yarısı `team()` iş okumadan geçmez. Ayrı K1a'nın kodu yok; bir inceleme ve bir kapı turu artardı |
| K2 | Hotfix, düzeltme koşusu, "Kaçırıldı", "Hata yığını" kalkar | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 1 sa 50 dk | Olay motoru sözleşmesi |
| K3 | Tek hata deposu, kaynaklar, rastgele dağılım, şema 16 göçünün 1. kısmı | aynı | Sonnet / Haiku / Opus | max / düşük / yüksek | 2 sa 45 dk | En büyük dilim, kayıt riski |
| K4 | Düzeltme kartı: efor, etkilenenler, en büyük hesap, sürüm notu; efor ve acil eşiği `sprint.json`'da tek ayar | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 1 sa 40 dk | Arayüz, tahmin eşliği |
| K5 | (E1 cevabından sonra) Etki zinciri, aşınma ve L silinir, akış ve acil kuralı, dört bot kolu, düzeltme payı ölçümü | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 4 sa 30 dk | Kalibrasyon. Hedef tutmazsa sabit sessizce değişmez, "onay bekliyor" diye R'ye gider. İkinci ölçüm turu yok |
| K6 | Hat paneli ve Destek kartının son hâli | aynı | Sonnet / Haiku / Opus | max / düşük / yüksek | 2 sa 40 dk | UI kanunu, görsel kabul. **değişti:** E1 cevabı gecikirse K5'ten önce koşar |
| K7 | Sönük kart düğmeleri; önce tema yedeği | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 55 dk | Küçük. **değişti:** E1 cevabı gecikirse K5'ten önce koşar |
| K8 | Ölü kod, belgeler, §4.1 tek kaynak grep kapısı, son kapılar | aynı | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 1 sa 30 dk | **değişti:** +10 dk. Tam `run_gate.sh` (3 × 730 hafta) ve plausibility burada koşar |
| R | `RAPOR_A.md`, son K8 commit'inden sonra | Ana | Opus | orta | 20 dk | B'nin başlama tetiğidir; erken görünmemeli |

**Toplam:** yaklaşık 20,5 saat ajan süresi (PRD tahmini 21 saatti). Erdem'in E1'deki bekleyişi dahil değil.

**Sıra:**
- Önce A0 ile A1a–d paralel koşar, sonra A2.
- E1 durağına girmeden K1 → K2 → K3 → K4 arka planda başlar.
- E1 cevabı K4 commit'lenince gelmişse sıra K5 → K6 → K7 → K8 olur. Gelmemişse K6 → K7 → K5 → K8.
- K8 her durumda en sondadır, R ondan sonra gelir.

## Dilim ayrıntıları
Bunlar Sonnet'in istemine girer. A_PLAN'daki dilim içeriği geçerlidir; aşağıdakiler onu düzeltir ya da tamamlar.

### K1 · Görevler matrisi ve kurucu
**Kim sprintte sayılır:**
- `SprintSystem.team()` yalnız Yapım ve Test işini tutanları alır.
- Pay `HRConstants.focus_mult`'tan gelir: tek işte 1,0, iki işte her birinde 0,5. Sprint işlerinin payları toplanır;
  Yapım ve Test tutan kişi sprintte 1,0 sayılır.
- Ar-Ge'deki kişi 0 sayılır. Masa sayımı bugün zaten `effective_skill` ile aynı payı okuyor.

**Matrisi okuyanlar:**
- `capacity`, `plan_outcome`, `assignees`, `role_of`, `week_points`, `pm_plans`, `effects.gd:365` ve
  `office_people.gd:97` bu bağı `team()` üzerinden alır.
- Hafta ortasında değişen atama, kartlara ve kapasiteye bugünkü kuralla, Ekip'in gününde yansır
  (`sprint_system.gd:896-917`).

**Kurucu:**
- Başlangıç işi Test olabilir (`game_state.gd:978-983`, QA en yüksek alansa). Bu durumda da sprintte sayılır.
- `_validate_shape`'in "kurucu tek iş" kuralı silinir (`character_registry.gd:507-510`).
- Kurucu etiketi: sprintte kartı olan kurucu "Boşta" görünmez.
- Sprintte kimse yoksa plan bunu söyler ve Ekip'e bağlar. Metin TR/EN onay bekliyor.
- K1 `_founder_on_build`'e yeni bağımlılık kurmaz. O aile K5'te silinir.

**Bot ve kapılar:**
- B2C bot kolu Destek'i kurucuya ikinci iş olarak verir; `clear_jobs` kullanılmaz (`run_probe.gd:1089-1098`).
- Smoke:
  - `founder_not_double_counted` (§4.9, iki işli kurucunun kayıt ve yükleme turu dahil),
  - matris vakası (§4.10),
  - etkilenen yaklaşık 20 vaka, `_case_gorevler_has_no_founder` ve "tek iş" denetimleri dahil.
- Probe ve kapılar:
  - `--sprint-probe` adsız uyuşmazlık 0,
  - `run_gate.sh`,
  - A1d tabanına karşı `full_run_b2c` ekonomi kayması notu.
- Yeni `edge:` fikstürleri: Destek'teki kişili sprint planı ve sprintte kimsenin olmadığı hâl.
- Boş masanın ofis karesi (§4.9). Kareler TR, EN, renk körü paleti ve 1,25 ölçekte çekilir.

### K2 · Hotfix kalkışı
- **Silinenler:**
  - düzeltme koşusu, `bug_pile` ve `lint_v3_frozen.json:28` satırı,
  - `destek.can_start_fix_run` ve `destek.fix_run_active` seam'leri, `fix_run_*` sinyalleri,
  - Destek kartının düğmesi, botun düzeltme bloğu (`run_probe.gd:1099-1122`), `fix_run` çekimi (`main.gd:1295-1304`).
- Destek kartı K6'ya kadar "Doğrulanmış/Gelen" satırını taşır.
- **`desk_shut` silinmez, yeniden kurulur.** Silinen bir bayrağı yazıyor (`main.gd:1289`).
- **Üretilen dosyalar:** `--event-vocab` ve `gen_signal_manifest.py` koşulur, çıktıları aynı commit'e girer.
- **Kapılar:** `--event-lint`, plausibility, `--run-log` B2B ve B2C 30 hafta.

### K3 · Tek depo
- **Dağılım:** Her hata kendi başına, tohumlu ve eşit olasılıkla yayındaki bir hatta düşer. "Haftanın hattı" ve ×3
  ağırlık yoktur. Yayında hat yokken doğan hata ve yayın öncesi hatalı kapanış `pending_faulty`'de saklanır, v1.0'da
  düşer.
- **B'nin yazma noktaları:** `ProductState.add_bugs`, `line_blocked`, `EventBus.line_bugs_cleared`.
- **Kayıt:** `_migrate_16`'nın 1. kısmı (bilet ve C) ve `save_v15_tickets_become_open_bugs`.
- **Smoke:** hat temizleme (§4.2) ve dağılım (§4.3, çok tohumlu sayım) vakaları falsifikasyonla.
- **Seam:** `urun.bugs_confirmed` → `urun.open_bugs`. Vocab ve manifest yeniden üretilir.
- **Kalanlar:** L (canlı hata sayacı) ve aşınma K5'e kadar kalır. Ara durum bugünkü oyundur.

### K4 · Düzeltme kartı
- **Ayar:** Efor kademeleri ve acil eşiği `sprint.json`'da tek ayardır. E1'e kadar bugünkü değerler (eşik 3) kalır.
- **Acil etiketi:** B'nin "acil durum" olayıyla karışmayacak bir ad alır (TR/EN onay bekliyor).
- **Etkilenenler:**
  - `SalesArchetypes.uses_axis` yüklemi ve `USE_AXIS_MIN` (0,25, onay bekliyor),
  - `line_impact → {accounts, seats, top_id, top_seats}`,
  - hattı kullanan hesapların listesi.
- **B'nin girişleri:** hattın kartını sprinte koyan ya da başa taşıyan giriş, `release.faulty`.
- **Sürüm notu:** "6 → 0".
- **Smoke ve kapılar:** `sprint_fix_preview_matches_close` (§4.6b), §4.6(c), `--sprint-probe`, `glyph_audit`.
- **Görsel:** `edge:` fikstürleri, uzun hesap adlı kart ve sürüm notu.

### K5 · Etki zinciri ve ölçüm
- **Bedeller** (Karar 4'ün E1'de seçilen mekanizmasına uyar):
  - B2B hesap hedefi,
  - B2C kitle kaybı,
  - haftalık itibar düşüşü: `max(0, …)` tabanı yoktur, −10'da durur.
- **İtibar sebebinin yüzeyi:** E1'de önerilir.
- **Karar 8 kesimleri:** satış ve VC okumaları.
- **Silinenler:** aşınma, L, `_is_free` / `_founder_on_build` / `_team_area_avg` ailesi ve
  `endgame_smoke.gd:2581-2590`.
- **Metinler:** `HR_AREA_MEANING_TESTER_QA` ve `ONB_SKILL_QA_DESC` yeniden yazılır (TR/EN onay bekliyor).
- **Kayıt:** `_migrate_16`'nın 2. kısmı (L anahtarları, `bugs_under`) ve `save_v15_callback_bugs_under`.
- **Smoke:** `neglect_reputation_below_zero`, `bugs_leave_sales_and_vc_alone`.
- **Bot:**
  - `RunProbe.PRESETS`'e B2B ve B2C için `fix` kolları eklenir: `fix_none`, `fix_worst`, `fix_due`, `fix_off`.
  - Kollar §4.4'teki sırayla kurulur. Gerekirse kapasite sınırı bot tarafında aşılır.
  - Her sprint başında `PROBE FIX`, her hafta yeni ve açık hata satırı basılır.
  - `fix_off` ayarı statik bir değişkendir; `run()` ve `reset_all_owners` onu sıfırlar.
- **Matris (bir kez):** 16 koşu, paralel, her koşu ayrı APPDATA ile. Koşu sürerken ağaçta kod değişmez.
- **Tablolar:** Tabloyu üreten betik `a_calisma/`'da durur; komutu R'ye yazılır.
- **Kapılar:** plausibility, `--sprint-probe`, `--event-lint`.

### K6 · Hat paneli ve Destek kartı
- **Hat paneli:** Hat satırı tek `ProductModel.bug_row`'dan kurulur. Alan cümlesi açık hatayla çelişmez. Sesler
  bölümü kalkar.
- **Destek kartı:** tek satır "N açık hata ›". Tıklayınca Ürün penceresi, en çok hatası olan hattın alanı açık olarak
  açılır. `desk_shut` son hâline getirilir.
- **Görsel:** `edge:` fikstürleri: B2B ve B2C hat paneli, 1–2 hatalı uzun liste. TR, EN, renk körü, 1,25; sırayla.

### K7 · Sönük düğmeler
**Önce yedek:**
- `git diff -- themes/` çıktısı ve iki `.tres` dosyası `a_calisma/k7_tema_yedek/`'e kopyalanır.
- `project.godot`'a dokunulmaz.

**Sonra:**
- `THEME_STAMP` artar, iki tema yeniden üretilir.
- Yalnız açık yolla sahnelenir: üretilen temalar, `ui_tokens.gd`, `build_theme.gd`, `sprint_card.gd`,
  `sprint_ui_shared.gd`.

**Kapılar:**
- `theme_check.gd`, `--theme-contrast-audit`,
- `live:active` ve `live:plan` hover kareleri.

R raporu, editörün uid satırlarının üretimle silindiğini Erdem'e söyler.

### K8 · Temizlik ve belgeler
- **Ölü kod:** ürün karmaşıklığı, `bug_trend`, `health_state`, `product_bug_risk`.
- **Belgeler:**
  - HARITA, CLAUDE.md §6, §8 ve §12, GUNCELLEMELER, motor md §27, ZAMAN MODELİ, glossary,
  - FRANK_VOICE_INVENTORY, `hr_constants.gd`'deki AREA_QA yorumu,
  - ACIK_KARARLAR 39 ve 45, `b2b_sales_system.gd:446` maddesi,
  - ISLER C-07 ve INT-9, VC takip sorusu notu (Karar 10).
- **§4.1 grep kapısı:** istisnalar ve gerekçeleri listelenir.
- **Son kapılar:** tam `run_gate.sh`, plausibility, lint, loc, glyph.
- **Opus incelemesi:** B'nin dört yazma noktasının adı ve çağıranı yerinde mi, bakar.

## Yürütücü notu: PRD ile A_PLAN çakışmaları
Bu not her Sonnet istemine eklenir; A2 genişletir. Çakışmada PRD geçerlidir.
1. **`desk_shut`:** yeniden kurulur. Yalnız `fix_run` çekimi silinir.
2. **İtibar:** `max(0, …)` tabanı yoktur. `GameState.set_reputation`'ın −10 alt sınırı geçerlidir
   (`game_state.gd:346-348`).
3. **En büyük hesap:** kartta adıyla ve koltuk sayısıyla gösterilir. `top_star` ve `{stars}★` kalkar.
   A_INCELEME §2'deki B ve C ad tablolarında hâlâ `top_star` yazıyor; geçersizdir.
4. **Dağılım:** Her hata bağımsız, eşit olasılıklı ve tohumlu düşer. "Haftanın hattı" ve ×3 ağırlık yoktur.
   Tek istisna, hatalı kapanan kartın hatasının kendi hattına düşmesidir.
5. **K5 kapısı:** "B2B ≤ 12" geçersizdir. Yerine §2.11'deki iki ölçü ve §4.4–4.5 gelir. `USAGE_DIV_B2B` 25 sabit
   değildir; değeri A0 ve E1'den gelir ve onay bekler.
6. **Bot kolları:** `fix_all` geçersizdir. Dört kol vardır; preset anahtarı `fix`'tir. `policy` olay cevabı
   anahtarı olarak kalır.
7. **Şema:** A 16, B 17. "D 17" geçersizdir.
8. **K1:** A_PLAN'ın K1 içeriğinin yerini Karar 13 alır.
9. **Kurucunun sprint payı:** A kimin sprintte olduğunu ve payını kurar. Rol puanı D'nindir.
10. **B2C kayıp yeri:** A_PLAN §5.1 satır 8, `sales_system.gd:184/204`'ü gösteriyor. Orası bugünkü kalite aşınması
    terimidir. Hata terimi onun **yanına eklenir**, onun yerine geçmez.
11. **Bilet defteri:** `SprintBridges.sync_tickets` defteri her gün C'den yeniden kuruyor. Göç, bilet satırlarının
    C'nin gerisinde kalabileceğini hesaba katar.

## Yürütme düzeni
**İş akışları:** Her biri Workflow aracıyla, her `agent()` çağrısında tablodaki model ve düşünme açıkça verilir.
1. **Keşif:** A0, A1a, A1b, A1c ve A1d paralel koşar, sonra A2.
2. **E1:** Ana oturum A0 ve A2 çıktılarını okur. Mekanizmayı ve yapılabilirlik hesabını yazar
   (`a_calisma/E1_SUNUM.md`). K1–K4 iş akışını arka planda başlatır, sonra Erdem'e sunar.
3. **K1 → K4.**
4. **Kalan dilimler:** E1 cevabına göre K5 → K6 → K7 → K8 ya da K6 → K7 → K5 → K8.
5. **R:** ana oturum.

**Her dilimin döngüsü:**
1. **Sonnet kodlar.** Yeni smoke vakasını falsifikasyonla kanıtlar: geçici bozma → koşu → elle geri alma → not.
   Yalnız parse kontrolü yapar.
2. **Haiku kapıları koşar.** Sıra şöyledir:
   - Diff'te `class_name` değiştiyse önce `--headless --import`.
   - `--event-lint` → `loc_residue` → `loc_csv_integrity` → hedefli smoke → probe'lar → kareler.
   - Smoke, kayıt yuvası çakışmasın diye sırayla ya da `xargs -P 2` ve `CASE_TIMEOUT=300` ile koşar.
   - Ekranlı koşular ayrı APPDATA ile ve sırayla yapılır.
   - `git diff` ile falsifikasyon artığı kalmadığı denetlenir.
3. **Opus diff'i, kapı çıktısını ve kareleri inceler.** Düzeltme hakkı vardır. Commit mesajını ve sahnelenecek dosya
   listesini yazar.
4. **En çok bir düzeltme turu.** Düzeltme olduysa Haiku kapıları bir kez daha koşar.
5. **Commit.** Haiku yalnız listedeki yolları sahneler (`git add -A` yok) ve `git diff --cached --stat`'ı listeyle
   karşılaştırır. `project.godot` ve temalar sahnelenmez; K7'de yalnız üretilen temalar girer. Mesaj:
   `Faz A Kn: …`. Metin değiştiyse "TR/EN onay bekliyor" eklenir, ardından attribution satırları gelir.
6. **Kapı geçmezse:** commit yok, iş durur. Erdem'e çıktı ve ekran görüntüsüyle dönülür.

**Çalışma dosyaları:**
- `docs/tasks/faz_ab/a_calisma/` altında durur: A0, A1, A2, E1, dilim notları `Kn.md`, K5 tablo betiği, tema yedeği.
- Klasör izlenmez, B'nin `b_taslak/` ikizidir. Oturum çökse de kaybolmaz.
- `RAPOR_A.md` yalnız R adımında yazılır.

**Ağaç kuralları:**
- Doğrudan `main` üzerinde çalışılır. Worktree açılmaz, push yapılmaz.
- `git checkout -- <yol>` yasaktır.
- Sahipsiz farklara dokunulmaz: `project.godot`, iki tema, izlenmeyen belgeler, `tools/__pycache__`.
- B bu sırada yalnız `docs/tasks/faz_ab/b_taslak/`'a yazar.

## Kabul ölçütü → adım
| Ölçüt | Adım |
|---|---|
| §4.1 tek kaynak | K8 (K3'te kısmi) |
| §4.2 hat temizleme, §4.3 rastgele dağılım | K3 |
| §4.4 churn ve düzeltme payı, §4.5 üç tablo | K5 → R |
| §4.6(a) sprint probe | Taban A1d'de; K1, K3, K4 ve K5'te adsız uyuşmazlık 0 |
| §4.6(b), §4.6(c) | K4 |
| §4.7 kayıt | K3 (bilet), K5 (`bugs_under`) |
| §4.8 itibar | K5 |
| §4.9 kurucu, §4.10 matris | K1 |
| §4.11 olay kapıları | Lint ve loc her dilimde; plausibility K2, K5 ve K8'de; `run_gate.sh` K1 ve K8'de |
| §4.12 görsel kabul | Sprint planı K1; kart ve sürüm notu K4; hat paneli, uzun liste ve `desk_shut` K6; düğmeler K7 |

## Doğrulama
- **Her commit:** Commit'i iddia ettiği kapı yeşilken atılır. Kapı sırası CLAUDE.md §12'dedir.
- **Uçtan uca:** K8'de tam `run_gate.sh` (üç koşu bir sonla biter, sıfır `ERROR`), `plausibility_run.sh` (`fails=0`)
  ve §4.1 grep'i koşar.
- **K5 ölçümü:** 16 koşudan üç tablo çıkar. Bunlar §4.4–4.5 hedefleriyle R'de karşılaştırılır.
- **R:** ✅ / ⚠️ / ❌ listesi kanıtıyla, onay bekleyen sabit ve metinler, commit listesi, B'nin okuma ve yazma
  noktaları, preset adları ve tablo komutları.
