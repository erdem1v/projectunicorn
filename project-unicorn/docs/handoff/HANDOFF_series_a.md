# DEVİR: Series A kapanışı (cloud session → lokal agent)

**Tarih:** 2026-09-25
**Hazırlayan:** cloud session `session_0146DLacrL6e3fwgmsioUrss`
**Sahip:** Erdem · **Lokal tur (2026-09-25):** yapılanlar, ölçümler ve onay bekleyenler `RAPOR_LOKAL_2026-09-25.md`'de; §D tasarım notu `docs/design/SONLAR_GAZETE_MODLAR.md`.

Bu belge tek başına yeterli olacak şekilde yazıldı. Başlamadan önce `CLAUDE.md`'yi okumalısın, çünkü bu devirle birlikte iki kalıcı kural değişti (bkz. §F). Aynı klasördeki diğer dosyalar:

| Dosya | Ne |
|---|---|
| `ONERI_v3_K1-K32.md` | Onaylanan tasarım önerisi. K1–K12 kararları uygulandı; K13–K32 açık. |
| `PUSH_ONCESI_KONTROL.md` | Push öncesi 10 maddelik kontrol ve bulgular (kod okunarak). |
| `ACIK_KARARLAR_D1-D13.md` | Açık kararlar araştırması ve karar tablosu. **Sahibin yorumunu bekliyor; dokunma.** |
| `runs/RUN_OZET.md` | 5 tohumluk ölçüm özeti: kapı günü, kapıdaki durum, Frank kartları, ay kapanışları. |
| `runs/final_smoke.txt` | Tam smoke çıktısı, 340/342 (cloud). Lokal son durum `runs/lokal_smoke_final2.txt` (§H). |

---

## A. DURUM

### Dal ve commit'ler

- Çalışma yalnız `main`'de (CLAUDE.md DELIVERY LAW). Dal yok.
- Devir commit'i `6edade6`, sahibin "push et" onayıyla `main`'e fast-forward edildi ve push edildi (2026-09-25). Devir dalı `claude/sharp-dirac-lev32p` silindi.
- Bundan sonra `main`'e her push ayrıca "push et" bekler.

| Commit | Özet |
|---|---|
| `fa46a24` | (Öncesi) öneri belgesi `docs/design/TOPLANTI_VE_SERIES_A_ONERI_2026-09.md` |
| `2cbbcd8` | **Masa.** Seed masası artık `levers()` kullanıyor ("DEĞERLEME $0M" hatası düzeldi). K12 isteklilik (E) modeli: sabır 0'a inince fon ya son teklifini koyar ya masadan kalkar. K7 "diğer teklifi göster": fonun cevabı dinamik. |
| `28d5edc` | **Av ve teklif.** K5: 10 iş günü. K6: tahmini aralık. K8: bekleme sırası görünür. K10: süre dolunca kapatılamaz karar kartı (`funding.sheet_decision`). K4: iptal ve erteleme cezası. K11: oyuncunun masadan kalkması zincire sayılmaz. Geri çağrı döngüsü ve temiz sorudaki ihtimal hatası düzeldi. Frank soğuk çıkış satırları. |
| `8e49dbd` | **Kapı.** K1–K2: Series A kapısı yalnız MRR ≥ 120K. K3: çubuk ve "n/3" kalktı. Frank'in 4 yaklaşma kartı (`funding/frank_approach_*`, `frank_door_open`). `gate_series_a`, kapı satırından en az 1 gün sonra gelir. |
| `de6ab7f` | **Satış.** Satış toplantısında iç ses artık ekranda görünüyor. |
| `fc58e7c` | **Push öncesi tur** (bkz. §B). **`main`'e push edildi.** |

### Smoke baseline

- Tam smoke `de6ab7f` üzerinde: **340/342** (`runs/final_smoke.txt`). **Lokal son: 347/347; iki eski vaka sahip onayıyla emekliye ayrıldı (§H).**
- İki kırmızı vaka:
  - `save_migration_v7_to_v8`: v7 fixture'ı `SAVE_ERR_TOO_OLD` ile reddediliyor.
  - `trait_migration_real_load`: v5 fixture'ı `SAVE_ERR_TOO_OLD` ile reddediliyor.
- İkisinin de sebebi aynı: fixture'lar `MIN_LOADABLE_VERSION` 10'un altında kalıyor. Bu task'tan önce de kırmızıydılar; test eskimiş.
- **Lokal (2026-09-25): `fc58e7c` tam smoke 340/342, cloud'la aynı (bkz. `RAPOR_LOKAL_2026-09-25.md`).** Cloud'da `fc58e7c` tam smoke'la koşulmamıştı. Yalnız 8 hedefli vaka geçmişti: `loc_csv_integrity`, `seed_table_levers_and_final_offer`, `patience_zero_locks_pushes`, `leverage_bonus_applies_and_shows`, `hunt_offer_lifecycle`, `table_walk_not_a_rejection`, `seed_table_walk_is_locked`, `table_sign_closes_series_a`.
- `--event-lint` PASS (43 kart), `loc_residue` temiz.

### 10 maddelik kontrolün özeti

Ayrıntısı ve kanıtları `PUSH_ONCESI_KONTROL.md`'de.

1. **Save.**
   - Yeni alanlar otomatik kaydediliyor: `SaveCodec` GameState değişkenlerini ve TermSheet'in `@export` alanlarını kendisi buluyor.
   - Şema 12'de kaldı, migration yok.
   - Eski save varsayılanları: `TermSheet.conviction` = −1 (masa 70 kullanır), `move_penalty` = 0.
   - **Eski save ile test edilmedi** (§B EK).
2. **Kapı ile görüşme uyumu.** Görüşmenin MRR ölçütü 40K ve 60K'da doyuyor, yani kapıya gelen herkes tavandan başlıyor. Açık karar: D9.
3. **"Kapı açıldı" satırı.** Sıra koşulla zorlanıyor, bir gün önceden tahmin edilmiyor. 5 koşunun 5'inde de görüldü; `gate_series_a` ertesi gün geldi.
4. **Seed board.** Sahte bir seçimdi; `fc58e7c` ile kilitlendi. Kalıcı yapılması açık karar: D7.
5. **Skandal bayrağı.** `unmanaged_major_scandal` bayrağına hiçbir yer yazmıyor (açık karar).
6. **Bütün fonlar kapanınca.** `fc58e7c` bunun için bir bilgi satırı ekledi. Sonun kendisi hâlâ açık: D2 ve D4.
7. **E sabitleri.** `term_sheet_table_system.gd` içindeki EAGERNESS bloğu. Değerler kontrol belgesinin §7'sinde.
8. **Frank satırları.**
   - Yaklaşma satırları arasında asgari aralık yok (D10).
   - Aforizma bütçesine sayılmıyorlar.
   - TR metinler, EN'e çok yakın yazılmış.
9. **Kırmızıyla commit edilen bir şey yok.**
10. **Kapsam dışı bırakılanlar** kontrol belgesinde listeli.

---

## B. PUSH ÖNCESİ TUR (orijinal numaralarla)

> **Dikkat: bu tur büyük ölçüde zaten uygulandı ve `main`'de.** Sahibin "yes go on" onayıyla `fc58e7c`'de yapıldı ve push edildi. Sahip daha sonra madde 5'i reddetti ve madde 3 için yeni bir yazım kuralı koydu. Aşağıdaki "Yapılacak" satırları senin işin; her şey `main`'de yapılır, `main`'e her push ayrıca "push et" bekler.

| # | Madde | Durum | Yapılacak |
|---|---|---|---|
| 1 | Seed masasında board itilemez; satır kilitli görünür | ✅ `fc58e7c` (`_lever_locked`, `SEED_BOARD_LOCKED`; smoke vakası genişletildi) | Yok. Görsel kontrol: seed masasında board satırı sebebini yazıyor mu? **Lokal: ✅ yazıyor (`--vc-shot=seed_table`, §H).** |
| 2 | Series A yolu kapanınca Av sekmesinde düz bir bilgi satırı | ✅ `fc58e7c` (`VCPitchSystem.series_a_road_closed()`, `HUNT_ROAD_CLOSED`) | **Lokal: ✅ `1695cf9` (`series_a_road_closed_when_all_funds_close`); görsel kontrol ✅ (`--vc-shot=hunt_closed`, §H).** Eski not: smoke vakası yok, bir tane ekle: dört fonu kapat ve canlı teklif bırakma; fonksiyon true dönmeli. Görsel kontrol. |
| 3 | `TERM_INV_*` 15 satır: önce TR yazılır (çeviri değil); EN ondan bağımsız İngilizce yazılır | ⚠️ Yarım. TR `fc58e7c`'de yeniden yazıldı; **EN eski (TR'den önce yazılmış) hâliyle duruyor.** | **Lokal: ✅ EN `8457ce3`; TR sahibin isteğiyle yeniden yazıldı `95bc9ea`; TR/EN onay bekliyor.** Eski not: 15 satırın EN'sini, yeni TR'nin sahnesinden bağımsız, doğal İngilizce olarak yeniden yaz. TR'yi sahibin onayı olmadan değiştirme. Commit mesajına "TR/EN onay bekliyor" yaz. Anahtarlar: `TERM_INV_RELAXED_1/2`, `TERM_INV_TENSE_1/2`, `TERM_INV_OUT_ANCHOR/NEXUS/BOSPHORUS/MERIDIAN/GENERIC`, `TERM_INV_FINAL`, `TERM_INV_WALKOUT`, `TERM_INV_OTHER_MATCH/CONDITION/HOLD/WALK`. |
| 4 | K7 sonrası yanlış Frank satırı engellensin (yeni satır yazılmaz) | ✅ `fc58e7c` (`_frank_line` içinde `OTHER_SHOWN` dalı) | Yok. |
| 5 | Anchor'ın E uyumunu büyümeye çevirmek | ❌ **REDDEDİLDİ ama `fc58e7c`'de uygulanmış.** | **Lokal: ✅ geri alındı, `86e33eb`.** Eski not: geri al. Bu konu D9'da ele alınacak. `term_sheet_table_system.gd`: `E_FIT_METRICS_GROWTH` sabitini ve `_domain_fit` içindeki `"metrics"` dalının ilk satırlarını `de6ab7f` hâline döndür (aşağıdaki kod). Sabitin açıklama yorumu da eski hâline döner. |
| 6 | `presenter.gd:246` ve `tuning.gd:14`'teki "yedi gün" yorumları | ✅ `fc58e7c` | Yok. |

Madde 5 için döndürülecek kod (`de6ab7f` hâli):

```gdscript
const E_FIT_METRICS_MRR := 6        # Anchor: MRR at/above the room's MRR reference (+), below (−)
...
		"metrics":
			var ref: int = SeedConstants.CONV_MRR_REFERENCE if is_seed() else PitchConstants.CONV_MRR_REFERENCE
			fit += E_FIT_METRICS_MRR if GameState.mrr >= ref else -E_FIT_METRICS_MRR
			fit += E_FIT_METRICS_CHURN if GameState.run_customers_lost <= 0 else -E_FIT_METRICS_CHURN
```

İpucu: `git diff de6ab7f fc58e7c -- scripts/systems/term_sheet_table_system.gd` madde 5'in bütün izini gösterir. Aynı dosyadaki madde 1 ve madde 4 değişiklikleri **kalmalı**, bu yüzden dosyanın tamamını geri alma; yalnız madde 5'e ait parçaları döndür.

### EK

**E1. Eski v12 save smoke vakası.** **Lokal: ✅ `1695cf9` (`legacy_v12_save_opens_live_table`).**
- Yeni bir smoke vakası ekle: yeni alanları taşımayan bir v12 save yüklensin. Bu alanlar: `TermSheet.conviction`, `vc_states[*].sheet_conviction`, `vc_states[*].move_penalty`, `vc_meeting_cancel_day`, `vc_last_meeting_rejected`, `vc_frank_cold_shown`.
- Save'de canlı bir Series A teklifi olsun; masa açılsın.
- Beklenenler:
  - `conviction` −1 olmalı ve masa E'yi 70 (`E_FALLBACK_CONV_SERIES_A`) + uyumdan başlatmalı;
  - `move_penalty` yokken ceza 0 olmalı;
  - teklifin `expires_day`'i (eski 14 takvim günü) iş günü sayacıyla okunmalı ve negatif çıkmamalı.
- Fixture'ı elle yazmak yerine: kaydet, JSON'dan bu anahtarları sil, yükle.

**E2. İki eskimiş fixture testi.** **Lokal: sahip onayladı; iki vaka `409d9e1` ile emekliye ayrıldı.**
- Önce öneri yaz, **uygulamadan önce sahibe sor.**
- Cloud önerisi: emekliye ayır. v5 ve v7 save'leri bilinçli olarak ölü (`MIN_LOADABLE_VERSION` 10, bilinçli bir karar). Yerine tek bir vaka: "`MIN_LOADABLE` altı bir save `SAVE_ERR_TOO_OLD` ile reddedilir ve yarım yüklenmez." Bu davranış zaten `engine_probe.gd:450` civarında sabitli; yenisi oraya ya da smoke'a gider.
- Alternatif: fixture'ları v10+ olarak yeniden üretmek. Ama o zaman test, adındaki göçü (v7→v8) artık test etmez.

### B'nin doğrulaması

1. `--event-lint` PASS, `loc_residue` exit 0, `loc_csv_integrity` PASS.
2. İlgili smoke vakaları, ardından **tam smoke**. Beklenen: 340+yeni / 342+yeni; kırmızı yalnız o iki eski vaka.
3. Görsel kontrol:
   - seed masası (board satırı kilitli, oran satırı sebebini yazıyor);
   - Series A masası (yatırımcı satırı, "diğer teklifi göster", son teklif ve kalkma);
   - Av sekmesi (tahmini aralık, iş günü, bekleme sırası, iptal ve erteleme, "yol kapandı" satırı);
   - K10 karar kartı.
   - Cloud'da bunların **hiçbiri görsel olarak kontrol edilmedi.** **Lokal: dördü de `--vc-shot` ile çekildi ve incelendi (§H).**
4. Sonra dur. `main`'e push için sahibin **"push et"** demesini bekle.

---

## C. İLK ÖLÇÜM (lokalde): B2 sorusu

**Soru:** Kapı açıldığında şirketler aşırı kârlı görünüyor: marj yaklaşık %70–76, kârlı ay serisi 7–11. Sebep ekonomi mi, yoksa botun gerçek bir oyuncu gibi işe almaması mı? **Sahip notu (2026-09-25): kadronun satış ağırlığı bir kalibrasyon adayı, §H.3.**

**Cloud verisi** (`runs/RUN_OZET.md`, `de6ab7f`, `full_run:700`):

| Tohum | Kapı günü | Çalışan | Günlük burn | Müşteri | Kârlı ay serisi |
|---|---|---|---|---|---|
| 1 | 305 | 7 | 709 | 156 | 10 |
| 2 | 357 | 12 | 1078 | 176 | 11 |
| 3 | 287 | 10 | 1008 | 162 | 8 |
| 4 | 442 | 13 | 1226 | 186 | 10 |
| 5 | 261 | 12 | 1079 | 172 | 7 |

- Aylık gider yaklaşık 28–37K, gelir yaklaşık 117–145K.
- **Ofis:** Oyunda ofis ya da kira mekaniği yok. `finance_system.gd:39`'da `"office": 0` ve bir TODO var. Yani ofis maliyeti tasarım gereği sıfır. Rapor bunu ayrıca belirtmeli.
- **Bot ve VC:** `run_probe.gd` içinde VC görüşmesi oynayan bir politika yok. Bot hiçbir koşuda Series A teklifi almadı.

**Yapılacak:**
1. Lokalde `--run-log=full_run:700:sim:<seed>` koş, tohum 1–5. Cloud rakamlarını yeniden üret.
2. Kapının açıldığı gün için şunları raporla:
   - çalışan sayısı ve rol dağılımı (`PROBE HR` / `PROBE STATE`);
   - aylık gider kırılımı (maaş, sunucu, marketing);
   - marj;
   - müşteri başına MRR.
3. **Karşılaştırma ölçütü:** Ekip GDD'si (rev 11) ve ch07'ye göre bu MRR ve müşteri sayısındaki bir şirketin gerçekçi kadrosu ve maaş yükü. Aynı soruyu `run_probe.gd`'nin işe alım merdivenine de sor: bir oyuncu bu noktada kaç kişi alırdı?
4. **Karar kuralı:**
   - Bot gerçek bir oyuncudan belirgin biçimde az işe alıyorsa B2 bir **harness** sorunudur. Önce botun işe alım politikası düzeltilir, ölçüm yeniden koşulur.
   - Bot makul işe alıyorsa B2 bir **ekonomi** sorunudur ve D13 olarak sahibe gider.
5. **Kalibrasyon sabitlerine dokunma.** Yalnız raporla. Bot düzeltmesi bir harness değişikliğidir ve serbesttir; raporda ayrıca belirt.

---

## D. YENİ KARAR: SONLAR VE GAZETE (sahibin kararı, önce tasarım notu)

**Karar (sahip, 2026-09-25):**
- Series A ve bootstrap sonları gazete ekranıyla gösterilmeye devam eder. **Tek bileşen iki modda** çalışır:
  - **Son modu (demo build):** Series A burada bir sondur. Wishlist ve mağaza öğeleri görünür.
  - **Kilometre taşı modu (EA / tam build):** Wishlist öğeleri gizlidir. İki buton olur: "Devam et" ve "Ana menü" (kayıt korunur).
- Mod, **build bayrağı + son türü** ile belirlenir. İki ayrı ekran yok.
- Kayıp sonları (iflas, kovulma vb.) her build'de son olarak kalır.
- **Series A'nın kilometre taşı modu, Perde 3 oynanabilir olana kadar kapalı.** O zamana kadar Series A her build'de bir sondur.
- Manşet, imzalanan şartları okur. Bu, K17 ile birleşir: şartlara göre manşet ve Frank'in hüküm satırı. (Sahip, 2026-09-25: Frank gazetede konuşmasın; şerit demo'da kalır, EA / tam'da yok. §H.2)
- **Seed gazete değil, ticker haberidir.**
- **Bootstrap kilometre taşından sonra devam eden bir koşuda 730. gün sınırı kayıp olarak işlememeli.** Nasıl ele alınacağını öner.
- **Önce tasarım notu** (`docs/design/SONLAR_GAZETE_MODLAR.md` önerilir). **Uygulama sahibin onayıyla.** **Lokal: sahip onayladı, uygulandı `f50d481` (§H.2).**

**Tasarım notunda bulunması gerekenler:**

1. **Bugünkü yapı:**
   - `EndingsSystem.trigger_ending()` tek terminal seam; `ENDINGS` tablosu yalnız ton tutuyor.
   - Sonun verisi `EventBus.run_ended` ile gidiyor.
   - Gazete sahnesi ve Frank'in şeridi `7946ff3`'te eklendi. (Düzeltme: gazete `3ee3963`, Frank şeridi `7946ff3`; tasarım notu §1.4.)
   - Build kapsamı: `scripts/events/core/tuning.gd` içindeki `SHIPPED_SCOPES` ve kartlardaki `version_scope`. Başka bir build bayrağı var mı, kontrol et.
2. **Mod seçim tablosu:** son türü × build → mod. Series A kilometre taşı bayrağı "Perde 3 hazır" olana kadar kapalı.
3. **"Devam et" akışı:**
   - Koşu nasıl sürer? `run_active` son anında false oluyor, saat donuyor ve kuyruk boşaltılıyor.
   - Kilometre taşı için ayrı bir seam gerekebilir: `trigger_milestone()` ya da `trigger_ending(..., milestone=true)`.
4. **730. gün, kilometre taşından sonra.** Cloud'un taslak önerisi, sahip seçecek:
   - (a) Bootstrap kilometre taşı alınmış bir koşuda sınır kalkar; koşu yalnız kayıp sonları ya da oyuncunun "Ana menü" seçimiyle biter. **Sahip (a)'yı seçti; uygulandı. Kodda Series A imzası ve satış da koşuyu bitirir.**
   - (b) Sınır kalır, ama `running_on_fumes` yerine nötr bir "şirket yaşıyor" kapanışı olur (kayıp değil, kilometre taşı modunda).
   - (c) Sınır kilometre taşından itibaren yeniden başlar (+N ay).
   - Cloud tercihi (a). Sebep: ch13 §5'te `running_on_fumes` "kazanmadın" demek, oysa bootstrap kilometre taşı zaten kazanılmış.
5. **K17:** manşet ve Frank satırı imzalanan şartları okur. Hangi alanlar okunur (değerleme, pay, koltuk, veto), hangi eşikler "kurucu dostu" ya da "agresif" sayılır? Frank'in satırlarını sahip yazar ya da onaylar.
6. **Seed ticker haberi:** mevcut ticker sistemi (`TICKER_CAPACITY`), hangi metin, hangi anda.
7. **D5 ile ilişkisi:** "yüzleşme" tanımı bu karara bağlı (bkz. `ACIK_KARARLAR_D1-D13.md`).

---

## E. AÇIK KARARLAR (D1–D13)

`ACIK_KARARLAR_D1-D13.md`. Karar tablosunda **"İnceleme notu"** ve **"Sahip yorumu"** sütunları var.

- **Açık maddelere dokunma.**
- Sahip yorum yazdıkça, onaylanan maddeler ayrı ayrı uygulanır.

Sahip incelemesinden gelen notlar (dosyaya da yazıldı):
- **D1:** öneri "satın alma v1'de VAR". ch13'teki CUT kararı 31 Ağustos kapsam değişikliğinden önceydi.
- **D5:** §D'deki gazete ve son kararına bağlı.
- **D9, eksikler:**
  - Ekip girdisinin −1/0/+1 tanımı yok.
  - Ürün girdisinin 0 değeri tanımsız.
  - Marj bugün hep +1, bilgi taşımıyor.
  - `CONV_BASE` ayarı §C ölçümünden sonra yapılır.
- **D11, Frank satırları:**
  - Hepsi önce TR olarak yeniden yazılacak.
  - F4 satırları E modelinden türetilmeli. F4c Bosphorus'a kendi kaldıracı olan board'u zorlatıyor, yani en pahalı hamleyi. F4a Anchor'ı kontrol odaklı anlatıyor, ama K7'de Anchor değerlemeye bakıyor. Ya satır ya model değişecek.
  - F5 "bu yıl" diyerek dönüş vaat ediyor; D2'de ise yol kalıcı kapanıyor.
  - F2 suçlayıcı; kısaltılacak.
- **E modeli ölçümü:**
  - Sorun: E=70 başlangıçta, sabrı 2 olan fonlar (eşik 55) iki başarısız itişte masadan kalkıyor.
  - Hedef: saf bir oyuncuda masaların en fazla yaklaşık %25'i kalkmayla bitsin.
  - **Ölç ve raporla; sabitleri değiştirme.**
  - Nasıl ölçülür: bot VC oynamadığı için ya smoke içinde "saf oyuncu" politikasıyla N masa simüle eden bir ölçüm vakası yazılır (örneğin her masada en çok kaldıraç ilk sırada, sabır bitene kadar it, sonra imzala), ya da `run_probe`'a bir VC politikası eklenir. İkisi de harness işi.

---

## F. KALICI KURALLAR (`CLAUDE.md`'ye de işlendi)

1. **TR canonical.** Her oyuncu metni önce Türkçe yazılır. EN, TR'nin çevirisi değildir; aynı sahnenin İngilizce yazılmış yerelleştirmesidir. Bu, eski "EN önce" kuralının yerini aldı.
2. **`main`'e push yalnız sahip "push et" dediğinde.** Çalışma yalnız `main`'de (DELIVERY LAW); dal açılmaz.
3. **Tasarım sabiti değiştiren her şey** (tuning değerleri, eşikler, E modeli sabitleri, kapı ve görüşme ağırlıkları) raporda **"onay bekliyor"** diye listelenir.

Frank'in korpusu sahibindir. Yeni Frank satırları yalnız taslak olarak önerilir, onaysız ekrana çıkmaz. Bu kural, bu turda sahibin açıkça istediği yaklaşma ve soğuk çıkış satırları dışında hep geçerli.

---

## G. BAŞLA

1. **`main`'de çalış.** `git pull origin main` ile güncelle. Dal açılmaz (DELIVERY LAW).
2. **Smoke baseline'ı lokalde koş.** Sonucu `runs/final_smoke.txt` (340/342) ile karşılaştır.
   - Lokalde: `tools/smoke_run.sh --all`. Paralel koşmak istersen cloud'un sarmalayıcısı `xargs -P 3` ile `smoke_run.sh <case>` çağırıyordu.
   - Fark çıkarsa önce onu açıkla; özellikle `fc58e7c`'nin tam smoke'la koşulmadığını unutma.
3. **§B'yi uygula ve doğrula:** madde 5'in geri alınması, madde 3'ün EN'si, E1 ve madde 2'nin smoke vakası. E2 için önce öneri yaz ve sor. `main`'e commit et; push için "push et" bekle.
4. **§C ölçümünü koş ve raporla.** Kalibrasyona dokunma.
5. **§D uygulandı (`f50d481`, sahip onayı); K17, seed ticker ve D5 onay bekler. §E (D1–D13) sahibin onayını bekler.**

Rapor biçimi (sahip tercih ediyor):
- madde madde **durum** (✅ / ⚠️ / ❌) ve **kanıt** (dosya:satır, commit, test adı);
- tahmin yok;
- tasarım sabiti değişiklikleri "onay bekliyor" başlığı altında.

---

## H. LOKAL TUR 2 (2026-09-25, sahibin ikinci mesajı)

Ayrıntı ve kanıt: `RAPOR_LOKAL_2026-09-25.md`, "Tur 2".

### H.1 Commit'ler

| Commit | Özet |
|---|---|
| `95bc9ea` | `TERM_INV_*` TR yeniden yazıldı: EN beğenildi, TR aynı anlamı taşımıyordu. TR/EN onay bekliyor. |
| `409d9e1` | E2: iki eski fixture vakası emekliye ayrıldı (sahip onayı). |
| `b43745a` | Tarihsel belgelerdeki silinmiş dal anmaları temizlendi (sahip onayı). |
| `78d159d` | Sahibin commit'i: Godot MCP (gopeak 2.4.0) addon'u ve `.mcp.json`. Sahip tutulmasını istedi. |
| `f50d481` | §D uygulandı: EA / tam build'de pozitif son koşuyu bitirmez. |
| `8df1d83` | Debug `--vc-shot` harness'ı (görsel kontrol). |

### H.2 Sonlar ve gazete (§D)

Sahibin kararları:
- Demo olduğu gibi kalır.
- EA / tam'da kötü sonlar koşuyu bitirir, pozitif durumlar bitirmez.
- Series A, Perde 3'e kadar son olarak kalır.
- Frank şeridi demo'da kalır, EA / tam'da kalkar.
- 730: (a), sınır kalkar.
- ANA MENÜ: "sanki varmış gibi".

Uygulama ve açık kalanlar: `docs/design/SONLAR_GAZETE_MODLAR.md` §U.

### H.3 Kalibrasyon adayı: kadronun satış ağırlığı (sahip notu)

**Sahibin gözlemi:** Kapıda çalışanların yaklaşık %60–70'i satış tarafında. Oyuncu ürünü çok geliştirmeden Series A alabiliyor mu? İleride kalibre edilmesi gerekir mi?

**Rakamlar** (§C ölçümü, 5 tohum, kapı günü; `runs/LOKAL_OLCUM_2026-09-25.md` §1):

| Tohum | Çalışan | Satış | Müşteri temsilcisi | Satış + müşteri | Geliştirici |
|---|---|---|---|---|---|
| 1 | 7 | 6 | 0 | 6 (%86) | 0 |
| 2 | 12 | 5 | 5 | 10 (%83) | 2 |
| 3 | 10 | 6 | 2 | 8 (%80) | 1 |
| 4 | 13 | 4 | 2 | 6 (%46) | 3 |
| 5 | 12 | 4 | 3 | 7 (%58) | 3 |
| **Toplam** | **54** | **25 (%46)** | **12 (%22)** | **37 (%68,5)** | **9 (%17)** |

Kalan 8 kişi: 7 ürün yöneticisi, 1 test.

**Neyden geliyor** (olgu, yorum yok):
- Kadroyu botun merdiveni kuruyor (`run_probe.gd` `STAFF_LADDER`, 13 basamak). Merdivende 5 satış, 3 müşteri temsilcisi, 3 geliştirici, 1 test ve 1 ürün yöneticisi var. Yani tasarımı gereği %62'si satış ve müşteri.
- Basamak, mevcut çalışan sayısına göre seçiliyor. Biri ayrılınca yerine başka bir basamaktan alım geliyor. Tohum 1'deki sıfır geliştirici bundan kaynaklanıyor.
- Kapı yalnız MRR okuyor (K1+K2, `8e49dbd`: MRR ≥ 120K). Ürün tarafında bir kapı şartı yok. Görüşmedeki ürün girdisi D9'da açık.
- Geliştiricisiz bir kadroda ürünün nasıl ilerlediği bu ölçümde ayrıca incelenmedi.

**Açık soru (sahip):** Bu, harness merdiveninin bir etkisi mi, yoksa Series A için ürün tarafında bir şart mı gerekiyor?

Ayırmak için ölçülebilecekler (yapılmadı):
- geliştirici ağırlıklı bir merdivenle aynı ölçüm: kapı günü ve MRR değişiyor mu?
- geliştiricisiz bir merdiven: kapıya yine ulaşılıyor mu?
- `PROBE GATE` satırına kapıdaki ürün durumunun (sürüm, kalite) eklenmesi.

Kalibrasyona dokunulmadı. B2 ve D9 ile birlikte ele alınabilir.

### H.4 Görsel kontrol (sahip maddesi 6)

- Godot MCP araçları bu oturumda yüklü değildi: `.mcp.json` oturum başladıktan sonra geldi. Görsel kontrol debug harness'larıyla yapıldı: `--vc-shot=<tür>` (`8df1d83`) ve `--ending-shot=<tür>`. Kareler `user://` klasöründe (Windows: `%APPDATA%\Godot\app_userdata\Project Unicorn\`).
- **Series A:** `hunt`, `hunt_closed`, `table`, `table_final`, `table_walk`, `table_other`, `seed_table`, `k10`.
- **Sonlar:** `bootstrap_milestone` (EA), `bankruptcy` (EA), `series_a_close` (demo).
- HANDOFF §B'nin dört yüzeyi beklendiği gibi görünüyor. Gözlemler raporda.

### H.5 Smoke

- Tam smoke `8df1d83`'te: **347/347** (`runs/lokal_smoke_final2.txt`).
