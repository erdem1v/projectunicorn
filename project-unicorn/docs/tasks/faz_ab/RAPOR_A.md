# RAPOR A · Hatalar ve hata gösterimi
Faz A bitti. Bütün işler `main`'de commit'li (push yok). Görev: `PRD_FAZ_A_HATALAR.md`. Çalışma dosyaları ve kanıtlar
`docs/tasks/faz_ab/a_calisma/` altında (izlenmiyor). Bu rapor B'nin koda başlama tetiğidir (§9).

Erdem gece "bütün sorular ön onaylı" dedi. Bu yüzden aşağıdaki her karar uygulandı ve commit'lendi, ama hepsi **onay
bekliyor**. Revize gerekirse sabah konuşulur. Bölüm 1 "önce bakılacaklar"dır: cevabı oyunu değiştiren sorular.

---

## 1. Önce bakılacaklar (cevabın oyunu değiştirdiği sorular)
1. **B2C ekonomisi büyük kaydı.** Açık hata artık satış dönüşümünü, memnuniyeti ve kalite okumasını bastırmıyor
   (Karar 8). Bot oynayan `full_run_b2c` (tohum 7, 104 hafta):
   - MRR 159.104 → **1.127.944**
   - kitle 57.148 → **234.988**
   - memnuniyet 3 → 56

   B2B neredeyse aynı: MRR 186.993 → 192.010. B2C, Series A eşiğini çok aşıyor. Hiçbir sabit oynatılmadı; bu bir
   kalibrasyon girdisi.
   - Öneri: B2C'nin yeni dengesi D/E fazlarının işi. A'da sabit değişmedi.
   - Hızlı bir fren gerekirse ilk aday `B2C_BUG_CHURN_COEF` (1e-6). Bunu bir ölçüm turuyla birlikte değiştirmek gerekir.
2. **İki ölçüm hedefi tutmadı** (40 hedefin 38'i tuttu). Tutmayanlar B2C erken dönemde düzeltme payının medyanı:
   `fix_worst` %50 ve `fix_due` %50, hedef ≤ %30.
   - Sebep yapısal: erken B2C'de kapasite haftalık 2 puan ve 1 puanlık bir düzeltme kartı bunun yarısı.
   - Hata sprinti oranı (pay > %50) yine 0.
   - Seçenekler:
     - (a) erken B2C hedefini ≤ %50 yap;
     - (b) 1 puanın altında bir düzeltme kademesi (0,5 puan) ekle. Bu, E1 §3'ün "1–4 hata 1 puan" kararını değiştirir.
   - Öneri: (a).
3. **VC geri dönüş penceresi kayıpla dolarsa yenilenir** (K5 kararı, E1'de yoktu). Yenilenmezse kötü bir çeyrekten
   sonra Meridian kapısı sonsuza dek kapalı kalır ve `series_a_road_closed` yolu hiç kapanmaz. Onay mı?
4. **Sprint probe adları.**
   - PRD §4.6(a) der ki: "adlı uyuşmazlıklar bu listeden artmaz".
     - "Liste" ad listesi olarak okundu: yeni ad çıkmaz.
     - Sayılar arttı. Taban 245/251 eşleşmeydi, adlar `sprint_late` ×3 ve `team` ×3.
     - Bugün 216/225 eşleşme var:
       - `product.sprint_late` ×4,
       - `team` ×4,
       - `product.sprint_two_paths` ×1.
   - `product.sprint_two_paths` K4'te çıktı. Bu yeni bir tahmin açığı değil: "Kısa yola geç" kararının kartın eforunu
     düşürmesidir. K4'ün kurtarma turu adın tabanda da bulunduğunu `team` adı altında kanıtladı (`K4.md` "Kurtarma
     turu"). Ad tabanın listesine eklendi.
   - Soru: "artmaz" sayı mı demekti? Sayı demekse K3'teki kayma (düzeltme kartları bir sprint erken çıkıyor) ve K4'teki
     karar kâğıdı kayması bu kuralı çiğner.
5. **B2B hesabın "kullandığı hat" tanımı:** alıcı tipi hattın eksenine ≥ 0,25 ağırlık veriyorsa hesap o hattı kullanır
   (`USE_AXIS_MIN`).
   - Bedel ve "etkilenen hesaplar" bu tanımdan okunur.
   - Hiçbir alıcı tipinin sahiplenmediği sektör `ops_cautious` gibi okunur.
6. **Meridian'ın uyum toplamı daraldı.** `E_FIT_PRODUCT_BUGS` (±6) silindi, çünkü VC artık hatayı okumuyor (Karar 8).
   Toplam −10..+14 iken −4..+8 oldu, yani hatasız ürün Meridian uyumunda 6 puan kaybeder.
7. **Müşteri talep kartının düğmeleri** (alan panelindeki "+" ve "→") K7'de sönük yapılmadı. PRD Karar 14 yalnız
   sprint, sonraki sprint ve devreden kartı sayıyor. Onlar da sönük olsun mu?
8. **Tema uid satırları (K7).** Tema yeniden üretilince editörün sonradan eklediği uid satırları düştü:
   - etkilenen dosyalar `themes/master_theme.tres` ve `menajer_theme.tres`;
   - düşenler başlık uid'i ve altı Texture2D uid'i.

   Editör bir sonraki açılışta bunları yeniden ekler. Yedek ve yama: `a_calisma/k7_tema_yedek/`.

   `project.godot`'taki sahipsiz fark (satır sırası) duruyor, hiç dokunulmadı.

9. **Karar bekleyen, A'nın değiştirmediği konular** (K8'in bulduğu, kısa cevap yeter):
   - `ACIK_KARARLAR` yeni madde **110**: `b2b_sales_system.gd` `pick_pain_feature`'ın düz havuz yolu
     `mvp_components` okur. Bu yüzden söz zaten çıkmış bir yeteneği anabilir. Bugün oynanabilir türlerde bu yol
     kullanılmıyor, ama düz havuzlu bir tür oynanabilir olursa çıkar. Seçenekler: (A) yolu sil, (B) `is_feature_live`
     ile süz, (C) kalsın.
   - **`hotfix` izinli ödünç kelimesi** (CLAUDE.md §5 ve glossary başı) oyuncu metninde artık hiç geçmiyor. Listeden
     çıkarılsın mı?
   - `HR_AREA_MEANING_DEVELOPER_ENGINEERING` ve `TESTER_ENGINEERING` ("hata oranı") ile `DEVELOPER_QA` ("Beta keşif
     hızı") var olmayan bir etkiyi vaat ediyor. Ar-Ge `cicd` ve `test_automation` düğüm metinleri de öyle. Bunlar
     Faz A'dan önce kalmış; satırlar bugün ekranda görünmüyor.
   - `ISLER.md` C-07, INT-9 ve "hata trendi zinciri" (56–58) silinmedi; "Faz A notu" eklendi. Onaylarsan silinirler.
   - Glossary 57. satırı ("TASARIM / GELİŞTİRME / TEST / BETA") hâlâ beta kanalını anıyor. Beta, A'dan önce
     kalkmıştı.
10. **Tam smoke süiti yarıda kaldı.** Her dilim kendi hedefli vakalarını koştu ve hepsi geçti:

    | Dilim | Vaka |
    |---|---|
    | K1 | 65/65 |
    | K2 | 17/17 |
    | K3 | 98/98 |
    | K4 | 14/14 |
    | K5 | 42/42 |
    | K6 | 24/24 |
    | K7 | 2/2 |
    | K8 | 15/15 |

    A'nın sonunda bir entegrasyon kontrolü olarak 405 vakalık tam süiti 4 paralel başlattım. 29 vaka koştu, 29'u da
    geçti. Sonra Claude Code süiti bellek baskısı yüzünden durdurdu: League of Legends açıktı, boş bellek yaklaşık
    1 GB'tı. Yetim kalan Godot süreçlerini kapattım. Süiti kendiliğinden yeniden başlatmadım. İstersen oyunun
    bitince 2 paralel koştururum, yaklaşık 1,5 saat sürer. PRD'nin istediği son kapıların hepsi yeşil: `run_gate`,
    plausibility, lint, loc, glyph ve sprint probe.

---

## 2. Kabul ölçütleri (§4)
| # | Ölçüt | Durum | Kanıt |
|---|---|---|---|
| 4.1 | Tek kaynak | ✅ | K8 grep'i (komut `a_calisma/K8.md` §3, ham çıktı `K8_smoke/gate41_all.log`): 52 eşleşmenin hepsi izinli yerde. `save_manager.gd` `_migrate_15`/`_migrate_16` (12), eski şema (v13/v14/v15) göç fikstürleri `endgame_smoke.gd` (38), `strings.csv`'de bilet defteri olmayan iki EN içerik cümlesi ("support tickets", konferans bileti). `data/` ve `tools/` temiz. Desen dışı not: `EventBus.bug_confirmed`, `unconfirmed_threshold_crossed` ve seam `urun.bugs_unconfirmed` eski adları taşır ama canlıdır (toplam açık hata ve GELEN eşikleri); yeniden adlandırma olay kartlarını etkiler, kapsam dışı bırakıldı |
| 4.2 | Hattı temizleme | ✅ | `sprint_fix_card_clears_its_line`, `open_bugs_store_reads_and_writes` (K3; falsifikasyon `K3.md`). Düzeltme kartı kapanınca yalnız kendi hattı sıfırlanır |
| 4.3 | Rastgele dağılım | ✅ | `bugs_land_on_random_live_lines` (çok tohumlu sayım, aynı haftada birden çok hat), `sprint_faulty_bug_on_card_line`, `sprint_faulty_pre_launch_lands_at_v1` (K3, K4) |
| 4.4 | Churn ve düzeltme payı, bot kolları | ⚠️ | 16 koşu (K5). Churn hedeflerinin dördü de tuttu. Düzeltme payında iki hedef tutmadı (B2C erken; §1 madde 2). Tablolar §4'te |
| 4.5 | Üç akış tablosu | ✅ | `a_calisma/K5_tablolar.txt`, `K5_OLCUM.md`; komut §7 |
| 4.6a | Sprint probe | ⚠️ | Her dilimde adsız uyuşmazlık 0 ve çıkış kodu 0. Ad sayıları arttı, bir ad eklendi (§1 madde 4) |
| 4.6b | `sprint_fix_preview_matches_close` | ✅ | K4. Önizleme N der; sprint içinde hata düşerse kapanış o anki sayıyı siler, sürüm notu gerçek sayıyı yazar |
| 4.6c | Başlamamış kart yenilenir, koşan kilitli | ✅ | `sprint_fix_card_refreshes_until_it_runs`. K4 incelemesi `fix_first`'te bir açık buldu ve kapattı (olay aynı tikte hata ekleyip kartı başa alırsa kart bayat sayıyla kilitleniyordu). Kanıt `sprint_fix_first_puts_the_card_on_top` |
| 4.7 | Kayıt | ✅ | `save_v15_tickets_become_open_bugs` (K3), `save_v15_callback_bugs_under` (K5). E1 §7 gereği bekleyen `bugs_under` "En zayıf eksen > 40"a değil, müşteri kaybı penceresine (`churn_under`) çevrilir. Göçten sonra kayıtta `bugs_under` kalmaz |
| 4.8 | İtibar | ✅ | `neglect_reputation_below_zero` (K5): 4 haftalık tik üst üste ≥ 30 açık hata olunca itibar −1 düşer, −10'da durur, düzeltme gelince düşüş biter, itibar 0'ın altındayken VC itibar sorusu açılır. Sebep TopBar ve Destek kartı ipucunda |
| 4.9 | Kurucu | ✅ | `founder_not_double_counted` (K1, kayıt ve yükleme turu dahil). Boş masa karesi `shots/K1/21-home-11-desk_shut-*.png`. K6'da yeni kartla yeniden çekildi: `shots/K6/` |
| 4.10 | Görevler matrisi | ✅ | `sprint_team_follows_job_matrix` (K1): yalnız Destek'teki kişi 0, Yapım ile Destek 0,5, atama geri alınınca kapasite eski değerine döner, tahmin üç durumda da kapanışla eşleşir |
| 4.11 | Olay kapıları | ✅ | Her dilimde `--event-lint` ve `loc_residue` temiz geçti. Plausibility K2 ve K5'te `fails=0`. `run_gate.sh` K1'de 3/3 RUN OK. K8: `run_gate.sh` 3/3 RUN OK (full_run 104. hafta, full_run_b2c 104. hafta, full_run_vc_cautious 68. haftada `series_a_close`), plausibility `runs=40 fires=482 fails=0`, lint 0 hata 0 uyarı, `loc_residue` CLEAN (3318 anahtar), sprint probe adsız 0. Ayrıca A sonunda tam smoke süiti: yarıda kaldı (aşağıda §1 madde 10) |
| 4.12 | Görsel kabul | ✅ | Her kare TR, EN, renk körü ve 1,25'te çekildi: sprint planı (K1), düzeltme kartı ve sürüm notu (K4), hat paneli ve uzun liste (K6), `desk_shut` (K6), sönük düğmeler (K7). Taşma ve kesilme yok, loglarda `ERROR` yok. Kareler `a_calisma/shots/K1…K7/` |

---

## 3. Onay bekleyenler

### 3.1 Sabitler
| Sabit | Değer | Nerede | Kaynak |
|---|---|---|---|
| Düzeltme eforu | 1–4 hata 1 puan, 5+ hata 2 puan (`fix_effort.steps [4]`, `points [1,2]`) | `data/product/sprint.json` | E1 §3 |
| Öncelikli kart eşiği | 5 açık hata (`fix_effort.priority`). Öncelikli etiket, alan uyarısı "!" ve liderin zorunlu listesi | `sprint.json` | E1 §4 |
| `impact.bug` | 0,5 (eski `impact.ticket`; değer aynı, ad yeni) | `sprint.json` | K4 |
| `research_sentence_weeks` | 2 (eski `voices_new_weeks`; değer aynı, anlam yeni: araştırmadan sonra kullanıcıların sözü alan cümlesinde kaç hafta kalır) | `sprint.json` | K6 |
| Akış tabanı | `INFLOW_BASE` 0,1; araştırılmış hâli 0,07 | `SupportSystem` | E1 §2 |
| Kullanım bölenleri | `USAGE_DIV_B2B` 80, `USAGE_DIV_B2C` 10000 | `SupportSystem` | E1 §2 |
| İtibar kuralı | `NEGLECT_BUGS` 30, `NEGLECT_WEEKS` 4: eşikte üst üste 4 haftalık tik, sonra her hafta −1, taban −10 | `SupportSystem` | E1 §5 |
| B2B bedeli | `B2B_BUG_SAT_PER` 0,3, `B2B_BUG_SAT_CAP` 20 | `B2BConstants` | E1 §5 |
| Şikâyet eşiği | `COMPLAINT_BUG_GATE` 6 (artık hesap başına; değer aynı) | `B2BConstants` | K5 |
| B2C bedeli | `B2C_BUG_CHURN_COEF` 1e-6/saat, `B2C_BUG_CHURN_CAP` 40; kalite erozyonunun yanına eklenir | `SalesSystem` | K5 analitik seçim (`K5.md` §4) |
| VC geri dönüşü | `CALLBACK_CHURN_WEEKS` 12, `CALLBACK_CHURN_PCT_B2B` %5, `CALLBACK_CHURN_PCT_B2C` %15; pencere dolmadan karşılanmaz, kayıpla dolan pencere yenilenir | `PitchConstants` | E1 §7, yenilenme K5 |
| Hesabın hattı kullanması | `USE_AXIS_MIN` 0,25 | `SalesArchetypes` | K4 |
| Silinen E modeli sabiti | `E_FIT_PRODUCT_BUGS` (±6) | `TermSheetTableSystem` | K5, Karar 8 |
| Sönük düğme | kenar `D_LINE_1`, ikon ve "Çıkar" `D_INK_4`; parlak hâli eski hover görünüşü; düğmenin kendi hover'ı `D_LINE_HOVER`/`D_INK_1` | `build_theme.gd` | K7 |
| Düğmenin yeri | Düğmeler kartın üstüne binmez, yer tutar. Geniş kartta son satırın sağ ucunda (kart ≈ +9 px), dar kartta kendi satırında sağa yaslı (+36 px) | `sprint_card.gd` | K7 |
| Hat satırı oku | artış uyarı renginde yukarı üçgen, azalış olumlu renkte aşağı üçgen, değişmediyse ok yok | K6 | PRD renk vermiyor |
| Harness | `RunProbe.DUE_BUGS` 2, `SLIP_BUGS` 24; `ProductState.bugs_free` (`fix_off`) | `run_probe.gd` | K5 |

### 3.2 Kurallar
- **Sprint payı (K1):** Yapım ya da Test tutan kişi sprintte sayılır. Pay = sprint işi sayısı × `focus_mult`:
  - tek iş 1,
  - Yapım ve Test 1,
  - Yapım ve Destek 0,5,
  - yalnız Destek ya da Ar-Ge 0.

  Ekip satırında payı tam olmayan kişinin yanında "%50" yazar.
- **Düzeltme kartı (K3):** Kart kapanınca hattın bütün açık hatası düşer.
- **Hatalı kart (K3):** Hatalı kartın hatası v1.0'dan önce `pending_faulty`'de bekler ve sürüm çıkarmayan kapanışta da
  kaybolmaz. Eskiden sessizce kayboluyordu.
- **Kabul edilen sapma (K3):** Hatsız canlı üründe (yalnız fikstürde var) bildirimler GELEN'de bekler.
- **Etkilenen kullanıcılar (K4):**
  - B2C'de kitle × hattın payı. Pay, canlı kademenin `(1 + kullanım ağırlığı)` değerinin bütün canlı hatlardaki
    toplama oranıdır.
  - B2B'de en büyük hesap koltuk sayısıyla seçilir; eşitlikte MRR, sonra kimlik.
- **Sürüm notu (K4):** Kapanışta hattın gerçek sayısını yazar ("n → 0"). Hatalı hata düştüyse sonraki sayıyı yazar
  ("6 → 1").
- **En çok hatalı hat (K6):** Eşitlikte en çok kullanıcıyı etkileyen hat seçilir, o da eşitse küçük hat kimliği.
  A_PLAN'ın kuralıdır, PRD bu konuda bir şey söylemiyor.
- **Destek kartı (K6):**
  - 0 açık hatada sönük, şevronsuz ve tıklanmaz.
  - Hata varken bütün DESTEK satırı tıklanır ve Ürün penceresini sprint görünümünde, en çok hatalı hattın alanı açık
    olarak açar.
  - Alan sütunun alt yarısındaysa sütun oraya kaydırılır.
- **İpuçları (K6):**
  - Hat satırında "Geçen hafta: N açık hata"; B2B'de ayrıca "En büyük hesap: ad (n kullanıcı)".
  - Destek kartında "En çok açık hata: {hat}"; hata yüzünden itibar düştüyse sebebi de yazar.
- **İtibar sebebi (K5):** İtibar ancak gerçekten düştüyse yazılır; −10 tabanında düşüş olmaz. Yazar
  `SupportSystem.daily_tick`'te sprint kapanışından sonra çalışır, yani o hafta düzelten oyuncu sayılmaz.
- **Kayıp ölçüsü (K5):**
  - B2B'de `run_customers_lost`.
  - B2C'de `b2c_users_lost`: erozyon ve hata terimi. Fiyat zammı ve olay kayıpları sayılmaz.
  - Göçte pencere başı yalnız aktif hesapları sayar.
- **Karar 8 (K5):** Satış ve VC hatayı okumaz. `urun.axis_stability` okuyan olay kartları hata duyarlılığını kaybetti:
  `launch_leak`, `password_rule`, `b2c_floor_*`, `shutdown_notice`, `b2c_creator_feature`.
- **Test işinin metni (K5):** Artık "sprint kartlarının test aşaması" der.
- **Sönük düğmeler (K7):** Sprint, sonraki sprint ve devreden kartta düğmeler hep görünür. Aday ve kilitli kart
  değişmedi.

### 3.3 Metinler (TR/EN onay bekliyor)
| Anahtar | EN | TR |
|---|---|---|
| `PRODUCT_TEAM_NOBODY_JOBS` | Nobody on the Build team or Test can work | Yapım ekibinde ya da Test'te çalışabilecek kimse yok |
| `PRODUCT_PERSON_SHARE` | {name} · {role} · {share} on the sprint | {name} · {role} · sprintte {share} |
| `PRODUCT_PRIORITY` | Priority | Öncelikli |
| `PRODUCT_FX_BUGS` (+`_ONE`) | {n} bugs / {n} bug | {n} hata |
| `PRODUCT_ACCOUNT_COUNT` (+`_ONE`) | {n} accounts / {n} account | {n} hesap |
| `PRODUCT_USER_COUNT` (+`_ONE`) | {n} users / {n} user | {n} kullanıcı |
| `PRODUCT_FX_TOP` | largest: {account} ({users}) | en büyüğü {account} ({users}) |
| `PRODUCT_FX_BUGS_CLOSED` (+`_ONE`) | {n} bugs close / {n} bug closes | {n} hata kapanır |
| `PRODUCT_FX_BUGS_FIXED` (+`_ONE`) | {from} → {to} open bugs / open bug | {from} → {to} açık hata |
| `PRODUCT_RESULT_BUGS_EXPECTED` (+`_ONE`) | {n} bugs should close / bug | {n} hata kapanmalı |
| `PRODUCT_RESULT_BUGS_ACTUAL` (+`_ONE`) | {n} bugs closed / bug | {n} hata kapandı |
| `PRODUCT_BUGS` | Open bugs | Açık hatalar |
| `PRODUCT_BUG_COUNT` (+`_ONE`) | {n} open bugs / open bug | {n} açık hata |
| `PRODUCT_BUGS_TIP_PREV` | Last week: {bugs} | Geçen hafta: {bugs} |
| `PRODUCT_BUGS_TIP_TOP` | Largest account: {account} ({users}) | En büyük hesap: {account} ({users}) |
| `BUILD_SUPPORT_TIP` | Most open bugs: {capability} | En çok açık hata: {capability} |
| `PRODUCT_AREA_CORE_ENOUGH` (yeniden) | Users can get the basic job done | Kullanıcılar temel işi yapabiliyor |
| `PRODUCT_AREA_TRUST_ENOUGH` (yeniden) | Backups and access control are in place | Yedek ve yetki yerinde |
| `HUNT_CB_CHURN` | Customer churn under {target} in {weeks} ({current} so far) | {weeks} içinde müşteri kaybı {target} altında (şu an {current}) |
| `REP_DROP_BUGS` | Bugs left open for weeks cost reputation. Last drop: {date}. | Haftalardır açık kalan hatalar itibarı düşürdü. Son düşüş: {date}. |
| `HR_AREA_MEANING_TESTER_QA` (yeniden) | Speed of the test phase on sprint cards | Sprint kartlarında test aşamasının hızı |
| `ONB_SKILL_QA_DESC` (yeniden) | Test-star tiers, and how fast the test phase of sprint cards runs. | Test yıldızı isteyen kademeler ve sprint kartlarının test aşamasının hızı. |
| `SALES_REASON_OUTAGE` (yeniden) | open bugs on the lines they use | kullandığı hatlardaki açık hatalar |
| `SALES_ANS_PROBE_STABILITY_RECORD_A_STRENGTH` (yeniden) | Stability holds. I can show you the record. | Kararlılık yerinde. Kaydı gösterebilirim. |
| `HR_AREA_MEANING_CUSTOMER_REP_CUSTOMER_SUCCESS` (yeniden, K8; bugün hiçbir ekranda çizilmiyor) | Support speed and account satisfaction | Destek hızı ve hesapların memnuniyeti |

**Silinen oyuncu metinleri:**
- **K2:** "Hata düzeltmeyi başlat", "Hotfix yayınla · {n} düzeltildi", "Doğrulanmış hata yok.", "Gelen {n} · bu hafta {m}
  kaçırıldı", "Düzeltme başlar", boşta önerisi, "Hata yığını" kartı.
- **K3:** `PRODUCT_TICKET_0..2`.
- **K4:**
  - `PRODUCT_URGENT` (Acil / Urgent),
  - `PRODUCT_FX_TICKETS_CLOSE/CLOSED` (+`_ONE`),
  - `PRODUCT_RESULT_TICKETS_*`.
- **K5:** `HUNT_CB_BUGS`, `VC_Q_BUGS`, `VC_Q_BUGS_MONO`, `SALES_PROBE_PROBE_STABILITY_BUGS`,
  `SALES_ANS_PROBE_STABILITY_BUGS_A_ADMIT/_A_PROMISE/_A_REFERENCE`.
- **K6, 16 anahtar:**
  - Sesler: `PRODUCT_VOICES`, `PRODUCT_VOICES_COUNT` (+`_ONE`), `PRODUCT_NEW_COUNT`, `PRODUCT_NEW_STAMP`,
    `PRODUCT_FX_VOICES_CLOSE` (+`_ONE`), `PRODUCT_FX_VOICES_CLOSED` (+`_ONE`), `PRODUCT_RIVAL_VOICE`;
  - biletler: `PRODUCT_CUSTOMER_TICKETS` (+`_ONE`), `PRODUCT_AREA_TICKETS` (+`_ONE`);
  - Destek kartı: `BUILD_SUPPORT_CONFIRMED`, `BUILD_SUPPORT_INCOMING`.

K8: okuyucusuz 8 anahtar `PROD_RISK_LOW/MID/HIGH`, `PROD_HEALTHY`, `PROD_RISKY`, `PROD_FLAT`, `PROD_TREND_FALLING/RISING` (onay gerekmez, hiçbir yer okumuyordu).

---

## 4. Ölçüm (§4.4, §4.5)
16 koşu: 2 pazar × 4 kol × tohum 7 ve 11, her biri 104 hafta. Hepsi 104. haftayı bitirdi (`running_on_fumes`); sıfır
`ERROR`, erken biten koşu yok. Tam tablolar `a_calisma/K5_tablolar.txt` (ayrıca `K5_OLCUM.md`) dosyasında. Erken dönem
v1.0'dan sonraki ilk 20 haftadır.

| Ölçü (medyan, iki tohum birlikte) | B2B erken | B2B geç | B2C erken | B2C geç |
|---|---|---|---|---|
| `fix_due` haftada yeni hata (hedef ≤1,5 / ≤4 / ≤1,5 / ≤3) | 1,0 | 3,0 | 1,0 | 3,0 |
| `fix_due` sürüm anında açık hata (≤4 / ≤8) | 2 | 5 | 2 | 6 |
| `fix_due` sprint sonu açık hata (≤8 / ≤16) | 4 | 8 | 4 | 9 |
| `fix_worst` düzeltme payı (erken ≤%30, geç ≤%15) | %8,2 | %4,8 | **%50** | %10,2 |
| `fix_due` düzeltme payı (erken ≤%30, geç ≤%20) | %0 | %4,9 | **%50** | %10,6 |
| Hata sprinti oranı / üst üste iki hata sprinti | 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0 |
| `fix_worst` açık hata, sprint sonu (bilgi; beklenen 10–20) | | 10 | | 17 |

| Toplam kayıp % (tohum 7 / 11) | `fix_none` | `fix_worst` | `fix_due` | `fix_off` |
|---|---|---|---|---|
| B2B ayrılan hesap | 17,6 / 22,5 | 4,6 / 6,8 | 3,8 / 4,6 | 3,8 / 4,3 |
| B2C kitleden giden | 18,8 / 21,1 | 7,7 / 8,0 | 3,9 / 4,2 | 0,56 / 0,78 |

Churn hedefleri tuttu: `fix_worst` ≤ `fix_off` + 10 puan ve `fix_none` ≥ 2 × `fix_off`. MRR farkları
`K5_tablolar.txt`'te.

**Ekonomi kaymaları** (bot planlı koşular, tohum 7, A1d tabanına karşı):
- **K1, sprint payı:**
  - `full_run` neredeyse aynı: son MRR 186.993 → 188.784, çalışan 13 → 11.
  - `full_run_b2c`:
    - seed günü 39 → 49,
    - çek günü 17 → 21,
    - son MRR 159.104 → 121.920,
    - kitle 57.148 → 36.285,
    - çalışan 10 → 7.

    Sebep: B2C bot kolunda kurucu Destek'i ikinci iş olarak alır ve sprintte 0,5 sayılır (Karar 13'ün bilinen etkisi).
- **K5, hata bedeli satıştan çekildi:**
  - B2B: MRR 192.010, müşteri 340 (taban 320).
  - B2C: MRR 1.127.944, kitle 234.988 (§1 madde 1).
- K6, K7, K8 oyun davranışını değiştirmedi (arayüz, tema, ölü kod ve belge). K8 sonunda `run_gate` koşuları 104 haftayı bitirir.

---

## 5. Commit listesi
| Dilim | Commit | Özet |
|---|---|---|
| K1 | `e33caac` | Görevler matrisi sprinte bağlanır, kurucu dahil |
| K2 | `c6b19c8` | Hotfix, düzeltme koşusu, "Kaçırıldı" ve "Hata yığını" kalkar |
| K3 | `9359f7b` | Tek hata deposu, hatalar canlı hatlara rastgele düşer, şema 16 göçünün 1. kısmı |
| K4 | `87b478f` | Düzeltme kartı: efor hata sayısından, etkilenen hesaplar ve en büyük hesap, sürüm notu "6 → 0" |
| K5 | `d52f199` | Aşınma ve canlı hata sayacı silinir, açık hatanın bedeli müşteride, bot kolları ve ölçüm |
| K6 | `496e229` | Hat paneli açık hataları yazar, Destek kartı tek satır "N açık hata ›", Sesler kalkar |
| K7 | `d9c0928` | Sprint kartlarının düğmeleri hep görünür ve sönük, kartın üstüne gelince parlar |
| K8 | `26b60da` | Ölü etiket anahtarları ve bayat yorumlar silinir, belgeler tek hata sayısına göre güncellenir |

A'nın son kod commit'i: **`26b60da`**.

---

## 6. Diğer fazlar için adlı okuma noktaları
| Ne | Nokta |
|---|---|
| Açık hata (toplam) | `ProductState.open_bugs()`; olay motorunda seam `urun.open_bugs` (`ProductRead.open_bugs()`) |
| Hat dökümü | `ProductState.open_bugs_by_line()` (`{hat: n}`, kopya), `line_bugs(line)`, `worst_bug_line()` (eşitlik kuralı §3.2), `open_bugs_delta(line)` (son haftalık tike göre), seam `urun.worst_line_bugs` |
| Hattı kullanan hesaplar, etkilenen sayılar | `SprintCatalog.line_accounts(line)` (hesap listesi), `SprintCatalog.line_impact(line)` → `{accounts, seats, top_id, top_seats}`, `SprintCatalog.line_users(line)` (B2B koltuk, B2C kitle payı), hesabın hatası `B2BSalesSystem.account_bugs(c)`, yüklem `SalesArchetypes.uses_axis(sector, axis)` |
| Hatalı sürüm | sürüm kaydında `faulty` (o kapanışta hatalı çıkan kartların hatları); v1.0 öncesi bekleyenler sprint durumunda `pending_faulty` |
| Görevler matrisi okuması | `SprintSystem.team()` → `[{id, name, points, share, fits, founder, ahead}]` (`share` = sprint payı); `SprintSystem.role_of(id)`, `SprintSystem.capacity()` |
| Öncelikli kart | `SprintCatalog.is_priority(card)` (eşik `sprint.json` `fix_effort.priority`) |
| İtibar sebebi | `SupportSystem.neglect_drop()` → `{day, reason}`, `SupportSystem.neglect_note()` |
| VC geri dönüşü | `VCPitchSystem.churn_callback(b2b, from_day, from_base, from_lost)` |
| Bayraklar | `mvp_open_bugs`, `mvp_open_bugs_prev`, `mvp_bug_streak`, `mvp_bug_drop_day`, `b2c_users_lost` |

**Not (K1 R notu):** `hr.job` seam'i yalnız ilk işi okur. Destek'i ilk, Yapım'ı ikinci işi olan geliştirici sprintte
0,5 sayılır ama `hr.job == build` seçicisinden geçmez. B'nin seçicileri için önemli.

## 7. B'nin adlı yazma noktaları ve sinyaller
| Ne | Nokta |
|---|---|
| Hatta hata ekleme | `ProductState.add_bugs(line, n)`; `build_progress_changed` yayar |
| Hattı temizleme | `ProductState.clear_line_bugs(line) -> int` (düşen sayı) |
| Hattı yeni hataya kapatma | `ProductState.line_blocked(line) -> bool`. Hata kaynağı kapalı hattı seçmez; A'da hep `false`, B kuralı doldurur |
| "Hat temizlendi" sinyali | `EventBus.line_bugs_cleared(line, n)` |
| Düzeltme kartını sprinte koyma ya da başa taşıma | `SprintSystem.fix_first(line)`: kart sprintteyse başa taşınır, sonraki sütundaysa ya da aday ise sprinte alınır; koşan sprintte hemen koşar ve haftanın ataması baştan yapılır; sürüm notundayken sonraki sprintin başına girer. Kart kilitlenmeden önce depodan tazelenir: olay aynı tikte hata ekleyip çağırabilir |
| Bugünkü çağıranlar | `add_bugs`: `SupportSystem.hourly_tick` (rastgele hat) ve `SprintSystem._land_faulty` (hatalı kapanış); `line_blocked`'ı yalnız `SupportSystem.hourly_tick` okur; `line_bugs_cleared`'ı `run_probe.gd` dinler; `fix_first`'ü bugün yalnız smoke çağırır |
| **B için not** | `line_blocked` yalnız Destek'in rastgele çekilişini süzer. Hatalı kapanan kartın hatası (`_land_faulty`) yüklemi okumaz, kapalı hatta da düşer. "Hattı kapatma" kuralı hatalı kapanışı da kapsayacaksa B bunu `_land_faulty`'de karar verir |
| Düzeltme yükü ölçüsü | bot `PROBE FIX` satırı her sprint başında. B'nin acil durum kartı da düzeltme yükü sayılır (PRD §4.4) |

## 8. Bot kolları ve tablo komutları
- Presetler (`scripts/debug/run_probe.gd` `PRESETS`):
  - B2B: `full_run_fix_none`, `full_run_fix_worst`, `full_run_fix_due`, `full_run_fix_off`;
  - B2C: `full_run_b2c_fix_none`, `full_run_b2c_fix_worst`, `full_run_b2c_fix_due`, `full_run_b2c_fix_off`.
  - Anahtar `fix`; `policy` olay cevabının anahtarı olarak kalır.
- Acil durum kartında kolun seçimi B'nindir (PRD §4.4).
- Koşu, proje klasöründen. Her koşu ayrı ve boşluksuz `APPDATA`/`HOME` ister; 4 paralel koşu yaklaşık 3 dakika sürer:
  ```
  "$GODOT" --headless --path . --lang=tr --run-log=<preset>:104:sim:<tohum> > <klasör>/<preset>_<tohum>.log
  ```
- Tablolar:
  ```
  python -X utf8 docs/tasks/faz_ab/a_calisma/fix_tables.py <klasör> > K5_tablolar.txt
  ```
  Betik yalnız stdlib kullanır ve repoda değildir. (a), (b) ve (c) tablolarını ve churn tablosunu basar, E1 §9'un 40
  hedefi için PASS/MISS verir.
- Probe satırları:
  - `PROBE FIX`: sprint başında kolun aldığı kartlar ve düzeltme payı;
  - `PROBE BUGS`: haftalık yeni, açık ve `pre=` (kapanıştan hemen önce);
  - `PROBE SHIP open_bugs=`: sürüm anı;
  - `PROBE STATE`'te ve `PROBE B2C`'de `lost=`.

---

## 9. Süreç notları
- **Kırmızı kapılar ve kurtarmalar.** Hiçbir dilimde gerçek bir kod hatası yüzünden kapı kırmızı kalmadı. Kırmızıların
  üçü kapı sürecinin kendisindendi:
  - **K3:** Haiku kapı ajanı smoke'u arka planda bırakıp erken döndü. Ana oturum kapıyı elle tamamladı: 98/98 smoke,
    probe, koşular.
  - **K4:** Sprint probe'ta yeni ad `product.sprint_two_paths` çıktı. Opus kurtarma turu adın tabanda da `team` adı
    altında bulunduğunu kanıtladı (A1d commit'i repo dışına `git archive` ile çıkarılıp tanı satırıyla koşuldu).
  - **K7:** Opus incelemesi yalnız arayüzü sınayan smoke vakasını CLAUDE.md §10 gereği sildi, ama yeniden kapı listesi o
    vakayı aramaya devam etti. Haiku ayrıca kareleri başsız çekmeye çalıştı. Ana oturum kapıyı tamamladı: 16/16 pencereli
    kare, 0 hata.

  İş akışı betiği her seferinde düzeltildi.
- **Opus incelemelerinin düzelttiği gerçek kusurlar:**
  - **K3:** Göç hatası.
  - **K4:** `fix_first` bayat sayıyla kilitliyordu.
  - **K5:** Göç deneme hesaplarını sayıyordu.
  - **K6:** Fikstürde YAPILANLAR'da olmayan hat vardı.
- **Commit mesajlarının düzeltilmesi.** Haiku commit ajanı K2, K4, K5, K6 ve K8'de attribution satırını "Claude Haiku 5.5" diye değiştirmişti. Ana oturum yedi commit'in (K2–K8) mesajını `git commit-tree` zinciriyle düzeltti: ağaçlar, yazar ve tarihler aynı, yalnız mesaj ve hash değişti. Eski → yeni: K2 `2d4b1d1`→`c6b19c8`, K3 `08ab54a`→`9359f7b`, K4 `b2d3272`→`87b478f`, K5 `0a62e06`→`d52f199`, K6 `3d8aa7a`→`496e229`, K7 `1d5ad5f`→`d9c0928`, K8 `35ae90f`→`26b60da`. Notlardaki (`a_calisma/K*.md`) eski hash'ler bu eşlemeyle okunur.
- **Fikstür notu (K4 sonrası).** `--product-shot=cards` fikstürü "ÖNCELİKLİ" etiketini bir araştırma kartına zorla basıyor (`product_fixtures.gd:89`). Oyunda bu etiket artık yalnız ≥ 5 hatalı düzeltme kartında çıkar (`SprintCatalog.is_priority`). Yalnız karede görünen bir tutarsızlık, düzeltilmedi.
- **APPDATA.** Klasör adındaki boşluk ("Project Unicorn") Godot'u rc 139 ile düşürdü. Bütün koşular
  `C:\Users\erdem\AppData\Local\Temp\fazA\…` altında yapıldı.
- **K2 dışı bulgu.** TR `live:active` karesinde iki kart avatarı boş halka gibi görünüyordu: portre yükleme zamanlaması.
  Faz A'nın işi değil.
- **K1 R notları:**
  - Yalnız tasarımcı ya da PM'den oluşan ekip kapasite > 0 verir ama geliştirme fazını yürütemez. Bu D'nin alanı.
  - `team_split` ve `team_none` fikstürlerinde kart ipucu ekipte olmayan Kaan'ı anıyor. Yalnız fikstürde.
