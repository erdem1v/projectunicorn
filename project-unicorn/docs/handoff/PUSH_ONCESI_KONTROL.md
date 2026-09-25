> **Kaynak:** cloud session, 2026-09-25. Push öncesi yapılan 10 maddelik kod okuması.
> **Durum:** Belgenin sonundaki "önerdiğim kısa düzeltme turu" `fc58e7c` ile UYGULANDI ve main'e push edildi. Ancak:
> - madde 5 (Anchor/büyüme) sonradan REDDEDİLDİ; geri alınacak.
> - madde 3'te yalnız TR yazıldı; EN yeniden yazılacak.
>
> Ayrıntı: HANDOFF_series_a.md §B.

# Push öncesi kontrol: 10 madde (kod okunarak cevaplandı)

**Durum:**
- Dört commit (`2cbbcd8`, `28d5edc`, `8e49dbd`, `de6ab7f`) yalnız `claude/sharp-dirac-lev32p` dalında.
- `origin/main` hâlâ `fa46a24`'te.
- **`main`'e push'u durdurdum.** Sebep: aşağıda 4 madde "okay" değil (4, 6, 8c, 2). Önce kısa bir düzeltme turu öneriyorum; plan en altta.

## 1. Save şeması

### 1a. Eklenen kalıcı durumlar ⚠️

Kayıt otomatik çalışıyor:
- `SaveCodec.game_state_fields()` GameState'in bütün script değişkenlerini kendisi buluyor (`save_codec.gd:276-290`, `SAVE_EXCLUDE_FIELDS` boş).
- TermSheet'in `@export` alanları da otomatik yazılıyor (`save_codec.gd:99-106`).

| Durum | Save'e yazılıyor mu | Alan |
|---|---|---|
| Görüşme inancı, E'nin tohumu | ✅ | `TermSheet.conviction` (`term_sheet.gd:39`) ve `vc_states[vc].sheet_conviction` (`vc_pitch_system.gd:399`) |
| E'nin kendisi, "diğer teklifi göster" mandalı, son teklif durumu | Hayır, bilerek | Masaya özel static değişkenler (`term_sheet_table_system.gd:144-151`). Masa açıkken kayıt zaten kapalı (`save_manager.gd:137`). |
| İş günü geri sayımı | ✅ | Geri sayım saklanmıyor, her seferinde `expires_day`'den türetiliyor (`TermSheet.business_days_left`, `game_state.gd:800-825`). |
| Bekleyen K10 kararı | ✅ | Ayrı bir bayrak yok. Teklif `active_sheets` içinde kalıyor; `is_decision_due()` her yüklemede yeniden hesaplıyor (`term_sheet.gd`, `vc_pitch_system.gd:593,609`). Kart açıkken kayıt kapalı. |
| Bekleme sırası | ✅ | Zaten vardı: `vc_states[vc].pending_sheet`. |
| K4 cezası | ✅ | `vc_states[vc].move_penalty` (`vc_pitch_system.gd:750`) |
| K4 "bugün iptal edildi" | ✅ | `GameState.vc_meeting_cancel_day` (`game_state.gd:360`) |
| Soğuk çıkış seçimi | ✅ | `vc_last_meeting_rejected`, `vc_frank_cold_shown` (`game_state.gd:361-362`) |
| Yaklaşma satırı mandalları | ✅ | Olay motorunun `one_shot` geçmişinde; `event_engine` bloğu zaten kaydediliyor. |

### 1b. Şema versiyonu ❌ değişmedi
- `SCHEMA_VERSION` 12, `MIN_LOADABLE` 10; `save_manager.gd`'ye dokunulmadı.
- Migration yazılmadı. Bütün alanlar ek; eksik anahtar varsayılanda kalıyor (`save_codec.gd:300-310`: "Applied OVER initialize_run's defaults").

### 1c. Eski save ile varsayılanlar ⚠️

| Alan | Varsayılan |
|---|---|
| `conviction` | −1. Masa Series A'da 70 alır (`E_FALLBACK_CONV_SERIES_A`); seed'de banda göre 80 / 55 / 35. |
| `move_penalty` | 0 |
| `sheet_conviction` | −1 |
| Üç yeni GameState alanı | −1 / false / [] |

- Eski bir teklifin `expires_day` değeri 14 takvim günüyle yazılmıştı. Yükleyince aynı tarihe kadar iş günü sayılır.
- **Eski save'le ayrıca test edilmedi.** Yeni alanlar için yükleme testi yok. Mevcut v12 kayıt ve yükleme vakaları tam smoke'ta geçti (340/342).

### 1d. İki kırmızı vaka ✅ etkilenmedi
- Durum hâlâ kırmızı: `save_migration_v7_to_v8` ve `trait_migration_real_load` `SAVE_ERR_TOO_OLD` veriyor (`scratchpad/final_smoke.txt`).
- Sebep: v5 ve v7 fixture'ları, `MIN_LOADABLE_VERSION` 10'un altında.
- `save_manager.gd` bu task'ta değişmedi (diff stat'ta yok). Baseline'da da aynı iki vaka kırmızıydı.

## 2. Kapı ↔ görüşme uyumu ❌ ele alınmadı
- `CONV_MRR_REFERENCE := 40_000` (`pitch_constants.gd:31`).
- Oran 1.5'te kırpılıyor (`vc_pitch_system.gd:166`), yani terim 60K$'da doyuyor.
- 120K$'daki kapıya ulaşan her oyuncu MRR teriminde tavanda başlıyor: +20.
- Aynı sebeple:
  - Anchor'ın E uyumundaki MRR ölçütü (`E_FIT_METRICS_MRR`) her zaman +6 veriyor.
  - `growth_flat` sorusu erişilemez (`vc_pitch_system.gd:1126`).
- Bunu K24'e bıraktım, ama E modeli bu eski ölçütü okuyarak sorunu büyüttü.

## 3. "Kapı açıldı" Frank satırı ✅
- Satır bir gün önceden tahmin edilmiyor. Sıra zorlanıyor:
  - `frank_door_open`, ratchet açıldığı gün geliyor (`phase.gate_ready == true`).
  - `gate_series_a`'ya yeni bir koşul eklendi: `{"history":"days_since","event":"funding.frank_door_open",">=",1}` (`gate_series_a.json` condition).
  - Böylece karar kartı en erken ertesi gün geliyor.
- Görünüyor mu? Evet. Ölçüm logları:

| Tohum | Kapı satırı günü | `gate_series_a` günü |
|---|---|---|
| 1 | 305 | 306 |
| 2 | 357 | — |
| 3 | 287 | — |
| 4 | 442 | — |
| 5 | 261 | — |

  - Kaynak: `scratchpad/runs/final_*.log`, `PROBE FIRE`.
  - Kapı satırı 5 tohumun beşinde de göründü. `gate_series_a`'nın günü yalnız tohum 1'de kontrol edildi; diğer dört koşunun karar kartı günü log'dan çıkarılmadı.
- Smoke vakası: `frank_approach_lines_once`.

## 4. Seed masasındaki yönetim kurulu kaldıracı ❌ hâlâ sahte, üstelik daha görünür
- `levers()` seed'de board'u döndürüyor (`term_sheet_table_system.gd:160-161`). `can_push("board")` true dönüyor (`:246-251`).
- `SeedRoundSystem.accept` yalnız `raise` ve `dilution_pct` okuyor (`seed_round_system.gd:181-182`).
- Sonuç: board artık seçilip itilebiliyor, sabır ve E harcıyor, ama imzada hiçbir şey kalmıyor. Eski hatanın yeni bir yüzü.
- K21 (kaldır ya da kalıcı yap) açık karar.

## 5. Skandal bayrağı ❌ değişmedi (bilerek)
- `unmanaged_major_scandal` bayrağına hâlâ yalnız sıfırlama yazıyor (`game_state.gd:993`).
- `scandal_resolved` koşulu hâlâ hep karşılanmış dönüyor (`vc_pitch_system.gd:1261`).
- §4.4'te karar bekliyor.

## 6. Bütün fonlar kapanınca ❌ sessiz
- Oyuncuya "Series A yolu kapandı" diyen bir yüzey yok. Av sekmesi yalnız fon rozetlerini gösteriyor.
- `road_over()` yalnız `faced_series_a_by in ["declined","walked"]` durumunda true (`endings_system.gd:347`). Yani:
  - dört red, K10 reddi ve fonun kalkması satın alınma yolunu açmıyor;
  - zincir, MRR ≥ `PIVOT_MRR_MIN` olduğu için pivot mandalında takılıyor (`endings_system.gd:203-212`).
- Koşu sessizce 730'a gidiyor.
- **Bu task durumu kötüleştirdi.** K11 ile oyuncunun kalkması, K10 ile de reddetme artık zincire sayılmıyor.

## 7. E modeli sabitleri (hepsi `term_sheet_table_system.gd:39-118`, onayına)

**Başlangıç:**
- E = sınırla(inanç + uyum, 0, 100).
- Damga yoksa inanç yerine Series A'da 70 (`WON_MIN`), seed'de 80 / 55 / 35 kullanılır.

**Uyum (toplam ±12 ile kırpılır):**

| Fon | Ölçüt | Puan |
|---|---|---|
| Anchor | MRR ≥ 40K | ±6 |
| Anchor | hiç müşteri kaybı yok | ±6 |
| Nexus | en az 1 geliştirici | ±6 |
| Nexus | kadro ≥ 4 | +4 |
| Bosphorus | marka ≥ 50 | ±6 |
| Bosphorus | sıcak tanıştırma | +4 |
| Meridian | MVP çıktı | ±4 |
| Meridian | canlı hata yok | ±6 |
| Meridian | hiçbir kalite ekseni 40'ın altında değil | +4 |

**İtiş:**
- Başarısız itiş: −(6 + 4 × adım), ayrıca 1 sabır. Adım = o kaldıraçta kazanılan itiş + 1.
- Başarılı itiş: −3.
- Fonun kendi kaldıracında her iki bedele +3 eklenir.

**Masadan kalkma eşiği:** 75 − 10 × sabır.
- Bosphorus ve Meridian: 55.
- Anchor: 45.
- Nexus: 35.

**Bant:**
- Rahat: E ≥ eşik + 20.
- Gergin: E ≥ eşik.
- Altında: "sabrı tükeniyor".

**Son teklif:**
- pay = sınırla((E − eşik) / 30, 0, 1).
- Fon son istenen yönde bir adımın pay × 0,5'i kadar esner.
- Yönetim kurulu isteği yalnız pay ≥ 0,75 olduğunda kabul edilir.

**K7 (diğer teklifi göster):**
- çekim = E + 5 × kalan sabır − 12 × fark (adım cinsinden).
- ≥ 70: eşler; farkın %50–100'ünü kapatır, E −4. Tam kapatma için çekim 90 gerekir.
- 50–69: şartla eşler; tam kapatır, bir başka kaldıraçta bir adım geri alır, E −4. Board geri alma en fazla 2 koltuk.
- < 50: yerinde durur, E −10.
- Kalkma: fark ≥ 2 adım ve E eşiğin altında.
- Fonun baktığı kaldıraç: Anchor ve Meridian değerleme, Nexus pay, Bosphorus yönetim kurulu.
- Geri aldığı kaldıraç: Anchor yönetim kurulu, Nexus değerleme, Bosphorus ve Meridian pay.

**Av:**
- 10 iş günü, uyarı 3 iş günü kala.
- İptal −3, erteleme −2.
- Aralık genişliği: değerlemede %25 (en az 2M$), payda %30 (en az 4 puan).
- Gerçek değer aralığın bir kenarından %15–40 içeride durur.

## 8. Frank satırları

### 8a. Asgari aralık ❌ yok
- Her satır kendi bandında, günde bir kontrolle geliyor. Yani ardışık günlerde gelebilirler. Bir günde iki eşik aşılırsa aradaki satır atlanıyor.
- Kapı satırı ile karar kartı arasında en az 1 gün var.
- Ölçülen en kısa aralık 14 gün (tohum 5: 247 → 261). Hızlı bir koşuda 1 güne kadar düşebilir.

### 8b. Aforizma bütçesi ✅ sayılmıyor
- Yeni kartların hiçbirinde `spend_budget` yok (`frank_*.json`, `vc_pitch_system.gd`).
- `frank_aphorism: 2` bütçesine (`tuning.gd:110`) dokunulmuyor.

### 8c. Önce EN mi yazıldı ⚠️
- Frank'in 10 satırı: plan §6'da EN ve TR'yi aynı turda ben yazdım. Bazı TR satırları EN'den serbest (Nexus, Bosphorus), bazıları neredeyse çeviri.
- Masa satırlarında durum daha kötü: TR metinleri uygulayıcı ajan yazdı ve çoğu düz çeviri.
  - `TERM_INV_OUT_ANCHOR`: "Devam ettikçe şartlarımız kötüleşir."
  - `TERM_INV_OUT_NEXUS`: "Ortaklarım sayıyor." Anlam kayıyor.
- Kurala uymuyor. Senin düzeltmen gerekiyor, ya da ben yeniden yazayım.

## 9. Düzeltme turları ✅ kırmızıyla commit yok
- Dört kümede de kapılar ilk koşuda yeşildi: lint, loc, `loc_csv_integrity`, ilgili smoke ve kapı kümesinde `--event-probe`.
- İncelemede engelleyici bulgu çıkmadı, bu yüzden düzeltme turu da olmadı (journal `wf_3ae56f81-8e1`).
- Uygulanmayan tek bulgu küçük bir bulgu: `_frank_line()` K7'nin `OTHER_SHOWN` durumunu ayrıca ele almıyor, genel sabır satırına düşüyor (`term_sheet_table_system.gd:792`).

## 10. Kapsam dışı bırakılanlar (§2 ✅ listesi)

| Madde | Durum | Neden |
|---|---|---|
| #3 seed'de 1. vuruşta çekilmek hakkı yakıyor | ❌ | Bilerek bırakıldı (K20). |
| #4 seed board kaldıracı sahte | ❌ | Bilerek bırakıldı (K21). Madde 4'e göre artık daha görünür. |
| #6 skandal bayrağı | ❌ | Bilerek bırakıldı (§4.4). |
| #7 zincir ve pivot mandalı | ❌ | Bilerek bırakıldı (K14). |
| #8 `faced_series_a` | ⚠️ | Yalnız yeni `"fund_walked"` değeri eklendi. `"door_open"` hâlâ hiç yazılmıyor (K16). |
| #10 hakaret, tekrar teklif, SON RAKAM | ❌ | Bilerek bırakıldı (K25–K27). |
| #10 54 `PH:` satırı | ❌ | Yazım turuna bırakıldı. |
| #10 iç ses | ✅ | `de6ab7f`, smoke `sales_inner_voice_reaches_view`. |
| #11 Frank'in çeki | ❌ | Bilerek bırakıldı (K23). |
| `END_META_BANKRUPTCY_FRANK` "yedi gün" | ✅ | Bu task'tan önce düzeltilmişti (`7946ff3`, şimdi "Otuz gün"). Ama sayı hâlâ elle yazılmış, seam'den okunmuyor. `presenter.gd:246` ve `tuning.gd:14` yorumları hâlâ "yedi gün" diyor; bu atlandı. |
| 🔎 maddeler | ❌ | Kapsam dışı; hiçbiri doğrulanmadı. |

---

## Push öncesi önerdiğim kısa düzeltme turu (onayınla)

1. **Madde 4, en küçük güvenli değişiklik:** Seed masasında board itilemez olsun. Satır görünür kalsın ama kilitli ("seed'de pazarlığa açık değil"). Kalıcı yapmak K21'in işi. Böylece sahte bir seçim sabır ve E yakmaz.
2. **Madde 6:** Series A yolu kapandığında (açık fon, canlı ya da bekleyen teklif, ayarlanmış görüşme kalmadığında) oyuncu bir kez bilgilendirilsin. Frank'in sesi gerekeceği için bu K32'ye değiyor. Önerim: şimdilik Av sekmesinde düz bir bilgi satırı ("Series A için açık fon kalmadı"). Sonun kendisi K14/K16'da.
3. **Madde 8c:** Masadaki `TERM_INV_*` satırlarının (15 satır) TR'sini lokalizasyon olarak yeniden yaz.
4. **Madde 9'daki küçük bulgu:** K7 sonrası Frank satırı. Frank'e ait olduğu için yeni satır yazılmaz; yalnız yanlış satırın çıkması engellenir.
5. **Madde 2:** Anchor'ın E uyumu MRR yerine son 3 ayın büyümesini okusun (`finance.growth_streak_months` zaten var). Görüşmenin kendi MRR ölçütü K24'te kalır.
6. **Yorumlar:** `presenter.gd:246` ve `tuning.gd:14`'teki "yedi gün" yorumları düzeltilsin.

**Doğrulama:**
- lint, loc ve ilgili smoke vakaları (haiku).
- Bir yeni smoke vakası: seed'de board itilemez.
- Sonra `git push origin claude/sharp-dirac-lev32p:main`. Önce `origin/main`'in ata olduğu doğrulanır; fast-forward olur.

