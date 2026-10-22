# B6m: Faz B tek seferlik ölçüm (PRD §4.1 raporu, §4.5, §4.11, §4.12)

Kod: HEAD `ea3c20c`. Hiçbir kod, sabit, kart, CSV ya da belge değişmedi; commit ve `git add` yok. Bu dosya ölçümün tek çıktısıdır.
Ölçüm turu bir kez koşuldu; eksik kalanlar §6'da ⚠️.

Log klasörü (hepsi aynı kök):
`C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad/b6m/`

| Alt klasör / dosya | İçerik |
|---|---|
| `logs_A/` | A: `full_run_<tohum>.log`, `full_run_b2c_<tohum>.log`, tohum 1–10 (20 koşu) |
| `logs_B_open/` | B: olaylar açık 16 koşu (`full_run[_b2c]_fix_{none,worst,due,off}_{7,11}.log`) |
| `logs_B_free/` | B: `_free` ikizleri 12 koşu (adlar `fix_tables.py` regex'ine uysun diye `_free` soneki atılmış, ör. `full_run_fix_worst_7.log` = preset `full_run_fix_worst_free`) |
| `tables_free/` | `logs_B_free` + 4 `fix_none` logu (açık kümeden kopya, aşağıda neden) |
| `k5_runs_copy/` | A'nın `a_calisma/K5_runs` loglarının kopyası (yalnız karşılaştırma) |
| `logs_D/` | sprint probe: `b2b_w2`, `b2b_w1`, `b2c_w2`, `b2c_w1` (kısa ad = kısa tam spec) ve `fill_*` (ek, §5.3) |
| `tables_open.txt`, `tables_free.txt` | `fix_tables.py` çıktısı, harfiyen |
| `fixed_k5.txt`, `fixed_open.txt`, `fixed_free.txt` | aynı betiğin bir satırı düzeltilmiş kopyasıyla çıktı (§3.1) |
| `analysis.txt` | A/B/C/D toplama betiğinin ham çıktısı; betikler `analyze.py`, `probe_sum.py`, `fix_tables_fixed.py`, `inter.py`, `came.py`, `econ2.py`, `join_targets.py`, koşucular `runset.sh`, `sprintprobe.sh` |

## 0. Sonuç

| Madde | Durum | Ana sayılar |
|---|---|---|
| §4.1 olay aralığı | ⚠️ | 20 koşu da 104. haftada `running_on_fumes` ile bitti, 0 `ERROR`/`PROBE ERROR`. 84 acil durum, koşu başına 1–7 (medyan 4,5). En küçük aralık 4 hafta (B2B 5, B2C 4), 4–6 dışı aralık payı %75 (48/64). Önerilen 4–14 hedefine 13/20 koşu uyuyor; 7 koşu altta (1, 1, 2, 2, 3, 3, 3 olay) |
| §4.5 kâğıt sıklığı | ⚠️ | Hedefler tutuyor: sprint başına en çok 1 kâğıt (1.506 sprintte 0 ihlal), kâğıtsız sprint %90,2 (hedef ≥ %33), aynı kâğıt en çok 2 kez (iki kez gelişler arası ≥ 53 hafta), adsız uyuşmazlık 0, çıkış kodu 0. ⚠️: komuttaki tam spec 104 haftayı ölçmüyor (tohum başına 3–4 sprint), `team=3` testçi içermiyor |
| §4.11 A'nın hedefi | ❌ | `fix_tables.py` harfiyen 40 hedefte 2 MISS (A ile aynı iki). Betik `bug_sprint=true` logunu `"True"` ile karşılaştırdığı için hata sprinti satırları hep 0 çıkıyor; düzeltilince A'nın tabanı 4 MISS, olaylar açık 6 MISS (`_free` da 6). `fix_none` B2C'de 5 `PROBE STOP` (0 beklenirdi) |
| §4.12 her tür gelir mi | ⚠️ | `regression` 0, `promise_due` 0, `sprint_late`/`sprint_late_solo` 0, `review_storm` 1, `month_close` 2; tasarımcı kâğıdı 0, PM 1, testçi 5, yazılımcı 99, kurucu 34 (A'nın 20 koşusu) |

## 1. Yöntem ve sapmalar

- Hepsi `--headless --lang=tr`, aynı anda en çok bir Godot, ön planda, süreç öldürme yok; her koşu kendi boşluksuz `APPDATA`/`HOME` dizininde (koşudan sonra silinen `scratchpad/b6m/ad_*`). Koşu başına 22–47 sn. Toplam 56 Godot koşusu: 20 (A) + 28 (B) + 8 (sprint probe).
- Loglar `stdout+stderr` birlikte alındı (`> log 2>&1`). Sayılan hata satırları: `^ERROR:` (motorun kapanış sızıntı satırı `resources still in use at exit` hariç, `run_gate.sh`'taki ERR_IGNORE), `SCRIPT ERROR`, `Parse Error`, `Compile Error`, `PROBE ERROR`. Hepsi sıfır. `WARNING: [EvEngine] the floor has found nothing N times running` satırı çok var (1.333, gerçek `ERROR` değil); A'nın K5 loglarında da aynı uyarı var (ör. B2C `fix_due_7`: 54, şimdi 51), yeni değil.
- `_free` kümesinde `fix_none` yoktur (`fix_none` zaten hiç durdurmaz). `fix_tables.py`'nin `fix_none` sütunu için `tables_free/`e dört açık küme `fix_none` logu kopyalandı: o kolun `_free` ikizi aynı koşudur. Rapordaki "`_free`" `fix_none` satırları bu yüzden açık kümeyle özdeştir.
- `fix_tables.py` iki hedefli kullanıldı: harfiyen (`tables_open.txt`, `tables_free.txt`) ve bir satırı düzeltilmiş kopyayla (§3.1).

## 2. §4.1: olay aralığı (A'nın 20 koşusu, `full_run` + `full_run_b2c`, tohum 1–10, 104 hafta)

Acil durum kimlikleri: `product.incident_outage_b2b`, `product.incident_outage_b2c`, `customer.incident_month_close`, `product.incident_checkout`, `product.incident_regression`, `product.incident_review_storm`. Aralık: ardışık iki `PROBE FIRE` arasındaki hafta (`day`).

| Koşu | Olay | Aralıklar (hafta) |
|---|---|---|
| full_run_1 | 1 | |
| full_run_2 | 6 | 5, 13, 15, 31, 13 |
| full_run_3 | 6 | 6, 50, 10, 7, 5 |
| full_run_4 | 5 | 19, 12, 7, 5 |
| full_run_5 | 6 | 8, 23, 11, 34, 5 |
| full_run_6 | 4 | 9, 14, 8 |
| full_run_7 | 6 | 8, 16, 6, 37, 8 |
| full_run_8 | 4 | 13, 31, 15 |
| full_run_9 | 3 | 20, 6 |
| full_run_10 | 3 | 31, 39 |
| full_run_b2c_1 | 1 | |
| full_run_b2c_2 | 5 | 10, 5, 31, 13 |
| full_run_b2c_3 | 7 | 12, 9, 4, 8, 7, 5 |
| full_run_b2c_4 | 5 | 4, 8, 7, 5 |
| full_run_b2c_5 | 4 | 11, 34, 5 |
| full_run_b2c_6 | 6 | 9, 14, 8, 6, 10 |
| full_run_b2c_7 | 5 | 11, 6, 37, 8 |
| full_run_b2c_8 | 3 | 31, 15 |
| full_run_b2c_9 | 2 | 6 |
| full_run_b2c_10 | 2 | 41 |

| Ölçü | B2B (10) | B2C (10) | İkisi |
|---|---|---|---|
| Olay / koşu (min, medyan, maks, ort) | 1, 4,5, 6, 4,4 | 1, 4,5, 7, 4,0 | 84 olay |
| En küçük aralık | 5 | 4 | 4 (smoke ölçütü ≥ 4 ✅) |
| 4–6 dışı aralık payı | %79,4 (27/34) | %70,0 (21/30) | %75,0 (48/64) (smoke ölçütü ≥ %30 ✅) |
| 4–14 olay hedefine uyan koşu | 7/10 | 6/10 | 13/20 |
| Hedefin altındaki koşular | full_run_1 (1), _10 (3), _9 (3) | b2c_1 (1), b2c_10 (2), b2c_8 (3), b2c_9 (2) | |

- Sonla bitiş: 20/20 koşuda tam bir `PROBE END day=104 run_active=false ending=running_on_fumes` (yumuşak tavan); `PROBE ERROR` ve `ERROR` yok.
- Hedefin üstünde koşu yok (maks 7). Önerilen "koşu başına 4–14" [onay bekliyor] hedefinin alt ucu 7/20 koşuda tutmadı. Altta kalan koşuların aralıkları: full_run_1 yok, _10: 31 ve 39, _9: 20 ve 6, b2c_1 yok, b2c_10: 41, b2c_8: 31 ve 15, b2c_9: 6. Kök neden bu ölçümde araştırılmadı.
- Ek (B kümesi, olaylar açık 16 koşu): koşu başına 4–9 olay, en küçük aralık 4 (`full_run_b2c_fix_none_7`).

## 3. §4.11: A'nın hedefi (16 olaylar açık + 12 `_free` koşu)

### 3.1 `fix_tables.py`'nin bir sapması (A'nın raporunu da etkiler)
Betik `PROBE FIX ... bug_sprint=` alanını `== "True"` ile karşılaştırır; probe `str(share > 0.5)` yazar ve Godot 4'te `true` (küçük harf) çıkar. Sonuç: hata sprinti oranı ve "üst üste iki hata sprinti" her tablo ve her koşuda 0 çıkar, ilgili 12 hedef boşuna PASS olur. A'nın RAPOR_A §4 satırı "Hata sprinti oranı / üst üste: 0 / 0 | 0 / 0 | 0 / 0 | 0 / 0" bu yüzden boştur. Kanıt: `K5_runs/full_run_b2c_fix_due_7.log` 4 satır `bug_sprint=true`, 0 satır `bug_sprint=True`. Betik repoda dosya olarak izlenmediğinden düzeltilmedi; `scratchpad/b6m/fix_tables_fixed.py` aynı betiğin tek satır farkıyla kopyasıdır (`.lower() == "true"`). Orijinal betik A'nın K5 loglarında `K5_tablolar.txt`'in PASS/MISS satırlarını birebir yeniden üretir; kopya yalnız hata sprinti satırlarını değiştirir ve A'nın tabanında iki hedefi PASS'ten MISS'e çevirir (`fix_due` B2C erken hata sprinti %26,09, üst üste iki hata sprinti %9,52). Aşağıda iki okuma da var.

### 3.2 A'nın hedefleri: A taban | olaylar açık | `_free`

| | A, betiğin harfiyen çıktısı | Olaylar açık, harfiyen | `_free`, harfiyen |
|---|---|---|---|
| 40 hedef | 2 MISS | 2 MISS | 2 MISS |
| MISS'ler | `fix_worst` B2C erken pay %50 > %30; `fix_due` B2C erken pay %50 > %30 | aynı iki: `fix_worst` B2C erken %50; `fix_due` B2C erken **%75** | aynı: %50 ve %75 |

| | A taban, düzeltilmiş ayrıştırma | Olaylar açık, düzeltilmiş | `_free`, düzeltilmiş |
|---|---|---|---|
| 40 hedef | **4 MISS** | **6 MISS** | **6 MISS** |

Hedefleri tutmayanlar (düzeltilmiş okuma), sayılarıyla:

| Hedef | Hedef | A taban | Olaylar açık | `_free` |
|---|---|---|---|---|
| `fix_worst` B2C erken düzeltme payı medyanı | ≤ %30 | %50 | %50 | %50 |
| `fix_due` B2C erken düzeltme payı medyanı | ≤ %30 | %50 | %75 | %75 |
| `fix_due` B2C erken hata sprinti oranı | ≤ %15 | %26,09 (6/23) | %52,38 (11/21) | %52,38 |
| `fix_due` B2C erken üst üste iki hata sprinti | ≤ %1 | %9,52 (2/21) | %31,58 (6/19) | %31,58 |
| `fix_due` B2B erken hata sprinti oranı | ≤ %15 | %8,70 (PASS) | **%19,05 (4/21)** | %19,05 |
| `fix_due` B2B erken üst üste iki hata sprinti | ≤ %1 | %0 (PASS) | **%10,53 (2/19)** | %10,53 |

Yani olaylarla iki B2B erken hedef yeni MISS oldu (A'da PASS idi) ve iki B2C erken hedef A'nın zaten tutmayan düzeyinden daha da uzaklaştı. `_free` ikizi aynı sayıları verdiği için neden "Sprinti durdur" seçimi değildir; farkın kaynağı (A'nın K5'inden bu yana B1–B9) bu ölçümde araştırılmadı. Örneklem küçük (iki tohum, erken dönem 19–21 sprint). Geç dönemde hata sprinti oranı `fix_due` B2B %0, B2C %1,80 (`_free` %2,73) ile ≤ %5'in içinde, `fix_worst` üst üste iki hata sprinti her yerde %0.

Düzeltme payı, medyan, % (harfiyen betik, iki tohum birlikte):

| | B2B erken | B2B geç | B2C erken | B2C geç |
|---|---|---|---|---|
| `fix_worst` A / açık / `_free` | 8,2 / 12,5 / 12,5 | 4,8 / 5,0 / 5,0 | 50 / 50 / 50 | 10,2 / 10,6 / 11,0 |
| `fix_due` A / açık / `_free` | 0 / 3,7 / 3,7 | 4,9 / 6,3 / 6,3 | 50 / **75** / **75** | 10,6 / 14,3 / 14,1 |

Hedefler (erken ≤ %30; geç `worst` ≤ %15, `due` ≤ %20): tutmayan yalnız iki B2C erken satırı (üstte).

Geri kalan 34 hedef (haftada yeni hata, sürüm anı ve sprint sonu açık hata, geç dönem pay ve hata sprinti, churn) olaylar açıkta ve `_free`'de PASS. Dar kalanlar: `fix_due` B2B erken sürüm anında açık hata 4 (hedef ≤ 4; A'da 2), sprint sonu 7 (≤ 8; A'da 4), B2C erken sürüm anında 3,5 (≤ 4; A'da 2).

### 3.3 Churn (toplam kayıp %, tohum 7 / 11)

| | `fix_none` | `fix_worst` | `fix_due` | `fix_off` |
|---|---|---|---|---|
| B2B ayrılan hesap, A | 17,61 / 22,51 | 4,62 / 6,78 | 3,75 / 4,55 | 3,76 / 4,27 |
| B2B, olaylar açık | 11,93 / 16,10 | 3,70 / 2,86 | 2,24 / 2,26 | 2,00 / 2,01 |
| B2B, `_free` | 11,93 / 16,10 (açık kümeyle özdeş) | 3,70 / 2,86 | 2,24 / 2,26 | 2,00 / 2,01 |
| B2C kitleden giden, A | 18,82 / 21,06 | 7,73 / 8,01 | 3,88 / 4,16 | 0,56 / 0,78 |
| B2C, olaylar açık | 31,84 / 21,23 | 7,59 / 8,33 | 5,37 / 5,05 | 0,71 / 1,01 |
| B2C, `_free` | 31,84 / 21,23 (özdeş) | 7,75 / 8,60 | 5,18 / 5,13 | 0,66 / 1,01 |

Churn hedefleri sekizi de PASS (`fix_worst` ≤ `fix_off` + 10 puan: B2B 1,70 ve 0,85, B2C 6,89 ve 7,32 puan; `fix_none` ≥ 2 × `fix_off`).

### 3.4 `PROBE STOP` (Sprinti durdur), kol başına, tohum 7 / 11

| | `fix_none` | `fix_worst` | `fix_due` | `fix_off` |
|---|---|---|---|---|
| B2B açık | 0 / 0 | 0 / 1 | 0 / 0 | 0 / 0 |
| B2C açık | **1 / 4** | 4 / 2 | 3 / 1 | 3 / 0 |
| `_free` (hepsi) | | 0 / 0 | 0 / 0 | 0 / 0 |

- `_free` kolları hepsi 0 ✅.
- `fix_none` B2B 0 ✅. **`fix_none` B2C 5 STOP ❌** (beklenti 0). Hepsi `product.incident_checkout` üzerinde ve nedeni kartın kendisinde: `defer` ("Sonraki sprinte bırak") seçeneği `requires: olay.service_up == true` taşır; ödeme çöktüğü sürece servis kapalı olduğundan kilitlidir ve botun `_pick_emergency` yedek kuralı (PRD §4.11: kilitliyse ilk açık seçenek) ilk açık satır olan "Sprinti durdur, şimdi düzelt"i seçer. Yani bot PRD'ye uyuyor, ama brief'in "0 olmalı"sı kilit gerçeğiyle çelişiyor. Karar Erdem'in.
- Ayrıca `defer` satırının `effects` listesi boş; botun `defers` yüklemi `incident` fiili ve `defer*` eylemi arar, bu satırı hiçbir koşulda tanımaz.

### 3.5 Botun seçimi (`PROBE PICK`, acil durum kartlarında; kol toplamları, iki tohum)

| Kart | `fix_none` | `fix_worst` / `fix_due` / `fix_off` | `_free` kolları |
|---|---|---|---|
| `outage_b2b` (kartın "Sprinti durdur" satırı yoktur) | "Ekip şimdi düzeltsin" 15, "Kendin düzelt" 1 | "Ekip şimdi düzeltsin" 33 (13+12+8), "Kendin düzelt" 3 | aynı |
| `outage_b2c` (aynı) | "Ekip şimdi düzeltsin" 6 | 21 (8+8+5) | aynı |
| `month_close` | "Sonraki sprinte bırak" 1 ✅ | `worst`: "Sabah düzelt" 1 (kartın `sprint_stop` satırı, STOP 1 ✅) | `worst`: "Ekip şimdi düzeltsin" 1 |
| `checkout` | **"Sprinti durdur, şimdi düzelt" 5** (defer kilitli, §3.4) | "Sprinti durdur, şimdi düzelt" 5 + 4 + 3 ✅ | "Ekip bu akşam kalsın" 10, "Kendin düzelt" 3 |
| `review_storm` | "Bir ay ücretsiz ver, sonraki sprinte bırak" 4 ✅ | `worst`: "Sprinti durdur, şimdi düzelt" 1 ✅ | |

Sprinti durduran satırı olan her kartta (`checkout`, `month_close`, `review_storm`) `worst`/`due`/`off` durdurmayı, `fix_none` ertelemeyi seçti. `outage_b2b` ve `outage_b2c` kartlarında "Sprinti durdur" satırı hiç yoktur. B2B'nin açık kümesinde (8 koşu) 54 acil durum kartından 52'si `outage_b2b`, 2'si `month_close` olduğundan B2B'de durdurma yalnız `month_close`'ta mümkündü. Sonuç: B2B `due`, `off` ve `worst_7` için açık küme ile `_free`, `PROBE BEGIN` satırı dışında satır satır aynıdır (`diff` 0 satır); `worst_11` 56 satır ayrılır (ay sonu kartı durduruldu); B2C'de iki küme `checkout` ve `review_storm` yüzünden ayrılır.

### 3.6 Ekonomi kayması (son `PROBE STATE`, gün 103; A = K5 logları)

| Koşu | MRR A → açık (fark), `_free` | Kasa A → açık | Çalışan A/açık | B2B hesap / B2C kitle A → açık |
|---|---|---|---|---|
| B2B `none` 7 | 157.844 → 155.054 (−2%) | 302.734 → 366.806 (+21%) | 13/13 | 290 → 310 |
| B2B `none` 11 | 171.812 → 161.184 (−6%) | 372.144 → 429.655 (+15%) | 13/13 | 272 → 297 |
| B2B `worst` 7 | 206.248 → 190.316 (−8%), `_free` aynı | 504.568 → 534.153 (+6%) | 13/13 | 330 → 338 |
| B2B `worst` 11 | 265.728 → 201.455 (−24%), `_free` aynı | 747.322 → 605.232 (−19%) | 13/13 | 330 → 340 |
| B2B `due` 7 | 191.481 → 202.407 (+6%), aynı | 551.765 → 560.990 (+2%) | 13/13 | 334 → 349 |
| B2B `due` 11 | 241.125 → 222.868 (−8%), aynı | 754.172 → 760.724 (+1%) | 13/13 | 336 → 346 |
| B2B `off` 7 | 208.627 → 194.071 (−7%), aynı | 505.942 → 560.539 (+11%) | 13/13 | 333 → 343 |
| B2B `off` 11 | 201.159 → 200.358 (0%), aynı | 563.800 → 571.760 (+1%) | 12/13 | 336 → 342 |
| B2C `none` 7 | 269.944 → **63.056 (−77%)** | 1.263.662 → 463.552 (−63%) | 5/5 | 56.239 → 13.136 (−77%) |
| B2C `none` 11 | 240.176 → 218.816 (−9%) | 1.318.346 → 1.129.431 (−14%) | 5/5 | 50.037 → 45.587 (−9%) |
| B2C `worst` 7 | 969.800 → 1.008.824 (+4%), `_free` 884.808 (−9%) | 2.118.562 → 2.208.172 (+4%) | 5/5 | 202.042 → 210.171 |
| B2C `worst` 11 | 755.648 → 684.608 (−9%), `_free` 668.464 (−12%) | 2.002.709 → 1.803.410 (−10%) | 5/5 | 157.427 → 142.627 |
| B2C `due` 7 | 1.063.528 → 728.896 (−31%), `_free` 726.720 | 2.250.696 → 1.809.879 (−20%) | 6/6 | 221.568 → 151.853 (−31%) |
| B2C `due` 11 | 1.044.720 → 826.232 (−21%), `_free` 822.448 | 2.277.045 → 2.034.965 (−11%) | 6/5 | 217.651 → 172.131 (−21%) |
| B2C `off` 7 | 1.330.392 → 1.023.880 (−23%), `_free` 1.096.840 (−18%) | 2.591.074 → 2.472.136 (−5%) | 5/5 | 277.165 → 213.309 (−23%) |
| B2C `off` 11 | 1.014.568 → 886.680 (−13%), aynı | 2.310.809 → 2.098.372 (−9%) | 5/5 | 211.368 → 184.725 (−13%) |

B2B ekonomisi A'nın yakınında (MRR çoğunlukla ±8%, `worst_11` −24%; hesap sayısı her kolda +%2 ile +%9). B2C'de sekiz koşunun yedisinde MRR %9–31 geride, `fix_none` tohum 7'de %77 geride (kitle 56.239 → 13.136); yalnız `worst` 7 %4 önde. Çalışan sayısı iki koşuda değişti (B2B `off` 11: 12 → 13, B2C `due` 11: 6 → 5), öbürlerinde aynı.

## 4. §4.12: her tür ve rol gerçekten geliyor mu

### 4.1 Acil durum ve söz/teşekkür türleri, 104 haftada (kaç kez)

Pazara özgü olanlar kartların `guards.market` alanına göre (HARITA `IncidentSystem` ile uyumlu): `outage_b2b`, `month_close`, `promise_due`, `release_thanks` yalnız B2B; `outage_b2c`, `checkout`, `review_storm` yalnız B2C; `regression` iki pazar. Yanlış pazarda hiç gelmedi (B2B koşularında B2C'ye özgü 0, B2C'de B2B'ye özgü 0).

| Tür | A, B2B (10 koşu) | A, B2C (10 koşu) | `fix_worst` B2B (7, 11) | `fix_worst` B2C (7, 11) | Durum |
|---|---|---|---|---|---|
| `product.incident_outage_b2b` | 42 | pazar dışı | 7, 7 | pazar dışı | ✅ |
| `customer.incident_month_close` | 2 | pazar dışı | 0, 1 | pazar dışı | ⚠️ seyrek (2 koşuda) |
| `product.incident_outage_b2c` | pazar dışı | 24 | pazar dışı | 2, 6 | ✅ |
| `product.incident_checkout` | pazar dışı | 15 | pazar dışı | 3, 2 | ✅ |
| `product.incident_review_storm` | pazar dışı | 1 | pazar dışı | 1, 0 | ⚠️ 20 koşuda 1 |
| `product.incident_regression` (iki pazar) | **0** | **0** | 0, 0 | 0, 0 | ⚠️ hiç gelmedi (24 koşu) |
| `product.promise_due` | **0** | pazar dışı | 0, 0 | pazar dışı | ⚠️ hiç gelmedi (12 B2B koşu) |
| `customer.release_thanks` | 276 | pazar dışı | 28, 33 | pazar dışı | ✅ (koşu başına 24–33) |

### 4.2 Kâğıt (sprint kâğıtları), role göre

Rol `speaker_role`, grup `pool_group` (`data/events/cards/product/sprint_*.json`, 46 kart). `sprint_late` kartında `speaker_role` listedir (yazılımcı, tasarımcı ya da testçi), `sprint_untested_old_screens`'de yazılımcı ya da kurucu.

| | A, 20 koşu | A B2B (10) | A B2C (10) | `fix_worst` 4 koşu | Durum |
|---|---|---|---|---|---|
| Toplam kâğıt | 147 | 44 | 103 | 29 | |
| `pool_group` developer | 91 | 23 | 68 | 15 | ✅ |
| `pool_group` solo (kurucu tek) | 34 | 12 | 22 | 8 | ✅ |
| `pool_group` no_tester | 16 | 5 | 11 | 3 | ✅ |
| `pool_group` tester | 5 | 3 | 2 | 3 | ⚠️ az |
| `pool_group` pm | 1 | 1 | 0 | 0 | ⚠️ 1 (B2B), B2C'de hiç |
| `pool_group` designer | **0** | 0 | 0 | 0 | ⚠️ hiç gelmedi |
| `pool_group` system (`sprint_late`, `sprint_late_solo`) | **0** | 0 | 0 | 0 | ⚠️ hiç gelmedi |
| `speaker_role` developer / founder / developer|founder / tester / product_manager | 99 / 34 / 8 / 5 / 1 | 26 / 12 / 2 / 3 / 1 | 73 / 22 / 6 / 2 / 0 | 16 / 8 / 2 / 3 / 0 | |

- Bot kadrosu (PROBE GATE `roles=`): B2B'de tasarımcı yok (PM 1, yazılımcı 3, testçi 1), B2C'de tasarımcı var (PM 1, tasarımcı 1, yazılımcı 2, testçi 1). B2C'de tasarımcı olmasına rağmen 10 koşuda tasarımcı kâğıdı yok; neden bu ölçümde araştırılmadı.
- Gelen kart 19/46. Hiç gelmeyen 27 kart: tasarım 8/8 (`color_blind`, `customer_colors`, `drawings_late`, `empty_state`, `empty_state_b2c`, `first_screen`, `gloves`, `notifications`); PM 6/7 (`core_first`, `phone_too`, `phone_too_b2c`, `renewal`, `scope_grew`, `spec_unclear_b2c`, `two_accounts`; yalnız `spec_unclear` B2B 1 kez geldi); testçi 6/9 (`coupon`, `devices`, `readonly_delete`, `stock_transfer`, `their_data`, `too_much`); `sprint_late`, `sprint_late_solo`; `sprint_dev_multi_currency`; `sprint_founder_test_pile`; `sprint_solo_license`, `sprint_solo_signup_code`.
- `fix_worst` 4 koşuda 15/46 kart geldi, aynı roller boş (designer, pm, system).
- Aynı sprint probe'u `team=3` ile (kurucu + yazılımcı + tasarımcı) tasarımcı kâğıdı üretiyor (`SPRINTPROBE PAPER` konuşan `char_probe_1`; ör. `sprint_design_empty_state`, `sprint_design_color_blind`), yani tasarımcı yolu çalışıyor; bot koşusunda tetikleyici durum oluşmuyor.

## 5. §4.5: kâğıt sıklığı

### 5.1 Gerçek koşulardan (A'nın 20 koşusu; 1.506 kapanan sprint)

`PROBE SPRINT` satırlarına göre gruplanmış, hedef "kâğıtsız sprint ≥ 1/3" [onay bekliyor]. Botun sprint ayarı hep 2 hafta (1.510 `PROBE FIX` satırı `weeks=2`); sprint, kartlar erken biterse 1 tikte de kapanıyor, o yüzden gerçekleşen uzunluğa göre ayrıldı:

| Gerçekleşen uzunluk | Sprint | Kâğıtlı | Kâğıtsız oran | Hedef |
|---|---|---|---|---|
| 1 tik | 956 | 0 | %100 | ✅ (kâğıt zarı sprintin ilk haftasının sonunda atıldığından 1 tikte kapanan sprintte hiç gelmiyor) |
| 2 tik | 530 | 147 | %72,3 (B2B %75,0, B2C %70,9) | ✅ |
| 3 tik | 20 | 0 | %100 | ✅ |
| Hepsi | 1.506 | 147 | %90,2 (B2B %94,8, B2C %84,4) | ✅ |

- Sprint başına en çok bir kâğıt: kâğıtlı 147 sprintte tek kâğıt (`paper+paper` bileşimi yok) ✅. B'nin açık 16 koşusunda da aynı (1.271 sprint, `paper+paper` yok).
- Aynı kâğıt bir koşuda: A'da en çok 2 (B2C'de 7/10 koşuda bir kâğıt iki kez; B2B'de en çok 1). Aynı kartın iki gelişi arası en küçük 53 hafta (52 haftalık mandalın içinde değil, 3. gelişe hiç varılmadı). B'nin 28 koşusunda da en çok 2 ✅ (hedef ≤ 2).
- Gerçek ihtimal: yapılandırılmış `sprint_chance` 2 haftalıkta 0,5; 2 tikte kapanan sprintlerde gerçekleşen kâğıt oranı %27,7 (147/530) ve tüm sprintlerde %9,8. Farkın nedeni (aday kart süzgeci ve kapanışla çakışma) ölçülmedi.

### 5.2 Sprint başına toplam kesinti (kâğıt + söz + acil durum)

A'nın 20 koşusunda `PROBE FIRE` satırları `PROBE SPRINT` kapanışlarına göre (kapanış satırından önceki tüm kesintiler o sprinte) gruplandı. Son kapanıştan sonra kalan kesinti yok.

| Bileşim | Sprint | Karar 12'ye göre |
|---|---|---|
| Kesinti yok | 1.291 | |
| Yalnız kâğıt | 131 | ✅ |
| Yalnız acil durum | 68 (outage_b2b 35, outage_b2c 18, checkout 12, month_close 2, review_storm 1) | ✅ |
| Kâğıt + `outage_b2b` | 7 | ✅ izinli bileşim (servis çöktü) |
| Kâğıt + `outage_b2c` | 6 | ✅ izinli |
| Kâğıt + `checkout` | 3 | ✅ izinli |
| Kâğıt + `month_close`/`storm`/`regression`, söz + herhangi, iki acil durum | 0 | ✅ ❌ adayı yok |

Birden çok kesintili sprint 16/1.506 (%1,1), hepsi izinli bileşim (`kâğıt + outage_b2b|outage_b2c|checkout`). B'nin açık kümesinde (16 koşu, 1.271 sprint) 15 sprint, hepsi aynı izinli bileşim (kâğıt + outage_b2b 9, kâğıt + outage_b2c 6). `promise_due` hiç gelmediği için söz bileşimi bu ölçümde sınanmadı (⚠️, §4.1).

### 5.3 Sprint probe (`--sprint-probe`)

Komutlar: `hours=8:cards=2:ticks=104:events=1:market=<b2b|b2c>:team=3:seeds=10` ve `:weeks=1` eklenmişi (tohum alanı `seeds`, ilk tohum varsayılan `seed=424242`; HARITA Ürün satırı ve `sprint_probe.gd` başındaki bildirimle doğrulandı). Hepsi çıkış kodu 0, ERROR yok.

| Pazar / uzunluk | Sprint (10 tohum) | Kâğıt | Boş oran (`PAPERSUM`) | Plan eşleşmesi | Adsız uyuşmazlık |
|---|---|---|---|---|---|
| B2B, 2 hafta | 30 | 0 | 1,00 | 50/50 | 0 |
| B2B, 1 hafta | 41 | 4 | 0,90 | 68/71 (3 adlı) | 0 |
| B2C, 2 hafta | 30 | 0 | 1,00 | 50/50 | 0 |
| B2C, 1 hafta | 40 | 2 | 0,95 | 68/70 (2 adlı) | 0 |

- ⚠️ Bu spec'le her tohum 3–5 sprintte bitiyor (her koşuda 10 `SPRINTPROBE SKIP|<tohum>|4|-|empty`: başlatılacak kart kalmayınca tohum biter; `LOADSUM limits=cards:20,pool:10`), yani 104 haftayı oynamıyor; "boş oran" ve "aynı kâğıt kaç kez" bu koşulardan anlamlı çıkmaz (bütün tohumlarda 0 ya da 1 kâğıt). Hedef rakamlarının asıl kanıtı §5.1'dir.
- Ek, brief dışı (komutta `fill=1`, HARITA'daki belgeli mod, aynı komutun dört hâli; `logs_D/fill_*`): B2B 2 hafta 877 sprint, 46 kâğıt, boş 0,95; B2B 1 hafta 1.030 sprint, 56 kâğıt, boş 0,95; B2C 2 hafta 103 sprint, 41 kâğıt, boş 0,60; B2C 1 hafta 219 sprint, 27 kâğıt, boş 0,88. Hepsinde sprint başına en çok 1 kâğıt (`PAPER` satırlarında bir sprintte iki kez yok), aynı kâğıt bir tohumda en çok 2 (B2B 1 hafta; öbürlerinde 1), adsız uyuşmazlık 0 (adlı uyuşmazlıklar 33–93 satır, hepsi `cause=` taşıyor), çıkış kodu 0. `fill_b2b_w2` logunda kâğıt ilk 11 sprintten sonra neredeyse hiç gelmiyor (tohum 424246'da sprint 55'te bir kez).
- Probe'un sprint sayımı ve kâğıt oranları botun gerçek akışıyla uyuşmuyor (ör. `fill=1` B2C 2 hafta %40 kâğıtlı sprint; botun B2C koşularında 103 kâğıt / 662 sprint = %15,6); bu yüzden probe oranları tek başına hedef kanıtı sayılmadı.
- `team=3` kadrosu: probe `team=N` için N−1 çalışan ekler, sıra `HIRES = [yazılımcı, tasarımcı, testçi, yazılımcı, ürün yöneticisi]` (`sprint_probe.gd`). Yani `team=3` = **kurucu + yazılımcı + tasarımcı**, testçi yok. PRD §4.5 "tasarımcı, geliştirici, testçi" der; bu kadro `team=4`'tür (kurucu + üçü). Konuşan kimlikleri `char_founder`, `char_probe_0` (yazılımcı), `char_probe_1` (tasarımcı) ve hiç testçi ya da PM konuşmadı. ⚠️ PRD ile uyuşmuyor.

## 6. Koşamadığım ve eksik kalan

- Sprint probe'un tam spec'i 104 haftalık kâğıt oranını/tekrarını ölçemiyor (§5.3). Bunun yerine gerçek koşulardan ve `fill=1` ekinden okundu; PRD'nin "ölçüm iki pazarda team=3, 104 tik, 10 tohum" cümlesi `team=3` kadrosu ve prob davranışı yüzünden birebir sağlanamadı.
- `team=3`'te testçi yok, bu yüzden testçi/PM kâğıtlarının probe'dan sayısı yok; yalnız bot koşularında (testçi 5, PM 1) görüldü.
- `regression`, `promise_due`, `sprint_late`, `sprint_late_solo` bot koşularında hiç gelmedi; bunların ölçümü ancak fikstürle (`--sprint-probe incident=`, `promise=1`) mümkün; brief'te yoktu, koşulmadı.
- §4.11 fark kaynağı (A'nın K5'inden B'ye) ve `fix_due` B2C erken payı %50 → %75 nedeni araştırılmadı; yalnız sayılar. B2C `fix_none` tohum 7'deki %77 MRR düşüşünün kaynağı da aynı (hangi olay/hangi hafta ölçülmedi).
- Ekranlı koşu, görsel kabul, plausibility, event-lint, loc_residue: bu adımın kapsamı değil.
- Tüm sayılar bir tohum kümesine ve tek ölçüme dayanır; tohum 7 ve 11'de iki koşu, tohum 1–10'da on koşu.
