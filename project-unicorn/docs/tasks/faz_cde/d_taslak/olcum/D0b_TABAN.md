# D0b taban ölçümü

Faz D, D1'den önceki ağaç. Karşılaştırma yok: bu belge yalnız tabandır (D9 ve D_SON_OLCUM yan yana koyar).

## Kaynak

- Ağaç: `base=5d3ea000 (kod 0616245f + D0a 8038c424)` (`COMMIT.txt`), anlık görüntü `C:/unicorn_d1/base` (`git archive`, boşluksuz yol), log klasörü `C:/unicorn_d1/d0b_logs`.
- Koşu listesi (106 koşu; `progress.txt` `ALL DONE` ile bitti):
  - `full_run_fix_{none,worst,due,off}` ve `full_run_b2c_fix_{none,worst,due,off}`, tohum 1..11: 88 koşu, 104 hafta, `--lang=tr`.
  - `_free` ikizleri (`worst`, `due`, `off`, iki pazar), tohum 7 ve 11: 12 koşu.
  - `b2b_book20` (tohum 1, 104 hafta) ve `b2b_book330` (tohum 1, 52 hafta).
  - `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1`, testçisiz ve `plus=tester@3`.
  - `--tick-probe=1:accounts=20:team=6` ve `--tick-probe=1:accounts=330:team=50`. İkincisinin ilk denemesi kayıt taşıyan `APPDATA` yüzünden reddedildi (`tick_team50_acc330.refused.log`, `TICK ERROR ... holds saves`); geçerli sonuç `C:/d0b_tick50` kullanıcı dizininde yeniden koşulan `tick_team50_acc330.log`'dur.
- Toplayan betikler: `d0b_taban.py` (bu belgenin gövdesini üretir, `analyze.py` ve `fix_tables_fixed.py`'yi içe alır), koşu başına satırlar `d0b_per_kosu.tsv`, A §4.2 tabloları `D0b_a42_tablolar.txt`. Komut: `python -I d0b_taban.py C:/unicorn_d1/d0b_logs C:/unicorn_d1/base d0b_per_kosu.tsv`.
- Hücre biçimi: "tohumlar arası medyan / ortalama" (n=11; `_free` n=2).

## Özet

1. **Hata hacmi** (`PROBE BUGS new=` toplamı, canlı hatlara inen hata, koşu başına; medyan): B2B `none` 267, `worst` 227, `due` 225, `off` 226; B2C `none` 267, `worst` 413, `due` 456, `off` 483. Haftada 2,3 (B2B) ile 4,7 (B2C). **Kaynak uyarısı:** `SHIP faulty=` 100 koşuda hep 0; hatalı çıkan kart ve acil durum bu sayının küçük payı. Kod okumasına ve 1c'ye göre büyük pay Destek masasının doğruladığı kullanıcı bildirimidir (`support_system.gd:128`). Log hata başına kaynak yazmaz; D3'ün `c`'sini bu toplama kalibre etmek doğan hata modelini (kart başına Poisson) Destek akışıyla karıştırır.
2. **Açık hata** (sprint sonu, koşu medyanı): B2B `worst/due/off` 7 ile 8, `none` 146 (hiç düzeltilmiyor); B2C `due` 9, `worst` 15, `off` 17, `none` 43.
3. **Acil durum**/koşu (medyan): B2B 7 / 5 / 4 / 3 (`none/worst/due/off`), B2C 7 / 6 / 5 / 4. Sürüm sonrası bozulma (`incident_regression`): 0, 100 koşuda hiç gelmedi.
4. **Düzeltme payı** (sprint başı `share`, medyan): B2B 0,05, B2C 0,11 (`none` B2B'de 0). Hata sprinti oranı en çok B2C `due` %5,7.
5. **Kâğıt gelen sprint**: B2B %3,5 ile %5,9, B2C %5,1 ile %9,3 (hedef önerisi %30 ile %67). Hiç gelmeyen kâğıt: 44'ten 21 (tasarımcı 8/8, PM 8/8, ayrıntı 4b). `promise_due` ve `sprint_late`: 0.
6. **Erken kapanan sprint**: kapanan 7.124 sprintin %72,8'i 1 haftada kapandı (B2B %77 ile %83, B2C %59 ile %71).
7. **MVP haftası** 7 (100 koşuda da). Hafta 103'te MRR ve kasa: B2B ~160 bin $ ve ~0,6 ile 0,74 milyon $; B2C kolla çok değişir (MRR 0,31 ile 2,2 milyon $).
8. **A §4.2 hedefleri**: 76 hedefin 9'u MISS (B2C erken dönem düzeltme payı ve hata sprinti, B2B erken yeni hata, `fix_none` churn katı üç B2B tohumda (3, 4, 8)).
9. **Kitap fikstürleri** (Traction, kart + sprint başlatma): 20 hesapta haftada 1,50, 330 hesapta 1,62 durma; iki fikstürde istek kartı yok.
10. **team=3 probu**: testçisiz 190/198, testçili 198/207 eşleşme; 8 ve 9 uyuşmazlığın hepsi adlı (`team.burnout` baskın).
11. **Tick probu**: 6 kişi ve 20 hesapta gece en çok 70,5 ms; 50 kişi ve 330 hesapta saat adımı p95 49,5 ms, en çok 82,1 ms, 21 kare 16 ms üstü; gece ölçümü yok (`night n=0`), beş adım tutuşla bitip `TICK|stopped`a düştü (450 ile 1.111 ms).

## Koşu envanteri

- Ana koşu: 88 dosya (iki pazar x dört kol x tohum 1..11); `_free` ikizleri: 12 dosya (tohum 7 ve 11).
- Her koşuda `PROBE END` sayısı: [1]; hata satırı (ERROR/SCRIPT ERROR/PROBE ERROR, 'resources still in use' hariç) toplamı: 0.
- Bitiş: {'running_on_fumes': 100}; bitiş haftası: {'104': 100}.
- Son `PROBE STATE` haftası: {'103': 100} (STATE hafta 1'den 103'e basılır; END 104'te basılır, 'Haftada 104' MRR ve kasa bu yüzden hafta 103'ün STATE'idir).

### 1. Hata hacmi ve açık hata (hücre: tohumlar arası medyan / ortalama)

**Ölçülen satır.** `PROBE BUGS new=` = o hafta canlı hatlara inen hata = `ProductState.open_bugs` farkı + düzeltme kartının o arada temizlediği hata (`run_probe.gd:_log_bugs`). Koşu başına toplam, MVP'den (v1.0) önce satır basılmadığı için yalnız ürün canlıyken inenleri sayar. Oyun kodunda hatanın girdiği üç yer var (`ProductState.add_bugs` çağrıları): kapanışta hatalı çıkan kartın hattı ve kâğıdın `leaks`'i (`SprintSystem._land_faulty`, kart başına 1), olay kartının `damage_product` etkisi (yalnız `sprint_dev_security_update` ve `sprint_solo_backup`) ve **Destek masasının doğruladığı kullanıcı bildirimi** (`SupportSystem` `:128`, haftada bildirim x doğrulama, hatlara eşit olasılıkla). Log hata başına kaynak yazmaz; 1c'deki ayrım kaynağı dolaylı gösterir. **Kod okumasına ve 1c'ye göre ölçülen sayının büyük kısmı Destek bildiriminden gelir, hatalı çıkan kartlardan ve acil durumlardan değil.** **D3 c'si bu toplama (`hata/koşu`, özellikle `fix_off` ve `fix_due` satırları) kalibre edilir.**

| pazar | kol | n | hata/koşu (PROBE BUGS new= toplamı) | hata/canlı hafta | canlı hafta | açık hata, sprint sonu (koşu medyanı) | açık hata, sürüm anı (koşu medyanı) |
|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 267 / 271 | 2.75 / 2.79 | 97 / 97 | 146.0 / 146.1 | 41.0 / 41.0 |
| b2b | worst | 11 | 227 / 226 | 2.34 / 2.33 | 97 / 97 | 8.0 / 7.8 | 5.0 / 5.5 |
| b2b | due | 11 | 225 / 228 | 2.32 / 2.35 | 97 / 97 | 7.0 / 6.8 | 4.0 / 4.2 |
| b2b | off | 11 | 226 / 227 | 2.33 / 2.34 | 97 / 97 | 8.0 / 8.0 | 6.0 / 5.6 |
| b2c | none | 11 | 267 / 263 | 2.75 / 2.71 | 97 / 97 | 43.0 / 42.7 | 43.0 / 42.1 |
| b2c | worst | 11 | 413 / 410 | 4.26 / 4.23 | 97 / 97 | 15.0 / 16.1 | 13.0 / 13.1 |
| b2c | due | 11 | 456 / 452 | 4.70 / 4.66 | 97 / 97 | 9.0 / 8.8 | 5.0 / 5.1 |
| b2c | off | 11 | 483 / 491 | 4.98 / 5.06 | 97 / 97 | 17.0 / 17.8 | 14.0 / 14.9 |

### 1b. Hatalı çıkan sürümler (`PROBE SHIP faulty=` = hattına hata yazılan kart sayısı, hata sayısı değil)

Kayıt (`release.faulty`) kapanış zarının hatalı saydığı kartların hatlarıdır ve `SHIP` satırı bu kayıt yazıldıktan sonra basılır. 100 koşuda toplam 0: halka açık hiçbir sürümde zar hata çıkarmadı (zar yalnız Test rolü olmadan test edilen ya da testi kısaltılan kart için atılır). Zarın MVP öncesi ya da halka açık olmayan kapanışlardaki sonucu log'da yoktur.

| pazar | kol | n | sürümde `faulty` hat toplamı | hatalı çıkan sürüm | toplam sürüm |
|---|---|---|---|---|---|
| b2b | none | 11 | 0 / 0 | 0 / 0 | 17 / 17 |
| b2b | worst | 11 | 0 / 0 | 0 / 0 | 83 / 83 |
| b2b | due | 11 | 0 / 0 | 0 / 0 | 66 / 65 |
| b2b | off | 11 | 0 / 0 | 0 / 0 | 84 / 83 |
| b2c | none | 11 | 0 / 0 | 0 / 0 | 73 / 73 |
| b2c | worst | 11 | 0 / 0 | 0 / 0 | 71 / 71 |
| b2c | due | 11 | 0 / 0 | 0 / 0 | 67 / 67 |
| b2c | off | 11 | 0 / 0 | 0 / 0 | 73 / 72 |

### 1c. Haftalık hata akışı, hafta türüne göre (88 ana koşu birleşik)

Hata hacminin kaynağını dolaylı gösterir: hafta türü değişince haftalık hata değişmiyorsa akış kapanıştan ve olaydan bağımsız, sürekli bir kaynaktan (Destek bildirimi) gelir. 'Olaylı' = o hafta acil durum, kâğıt ya da `promise_due` düştü.

| pazar | kapanış türü | olay | hafta sayısı | hata toplamı | hata/hafta |
|---|---|---|---|---|---|
| b2b | halka açık sürümlü kapanış | olaylı hafta | 108 | 290 | 2.69 |
| b2b | halka açık sürümlü kapanış | olaysız hafta | 2547 | 6471 | 2.54 |
| b2b | kapanışsız hafta | olaylı hafta | 231 | 426 | 1.84 |
| b2b | kapanışsız hafta | olaysız hafta | 413 | 929 | 2.25 |
| b2b | sürümsüz kapanış | olaylı hafta | 58 | 125 | 2.16 |
| b2b | sürümsüz kapanış | olaysız hafta | 911 | 2228 | 2.45 |
| b2c | halka açık sürümlü kapanış | olaylı hafta | 185 | 963 | 5.21 |
| b2c | halka açık sürümlü kapanış | olaysız hafta | 2849 | 13254 | 4.65 |
| b2c | kapanışsız hafta | olaylı hafta | 284 | 904 | 3.18 |
| b2c | kapanışsız hafta | olaysız hafta | 743 | 2422 | 3.26 |
| b2c | sürümsüz kapanış | olaylı hafta | 3 | 6 | 2.00 |
| b2c | sürümsüz kapanış | olaysız hafta | 204 | 218 | 1.07 |

### 2. Acil durum sayısı ve sürüm sonrası bozulma

Acil durum = `analyze.EMERG`'in altı kimliği (`PROBE FIRE`). Sürüm sonrası bozulma = `product.incident_regression`; `IncidentSystem._regression_line` kapanan sürümün `faulty` listesinden hat okur (D0t_HARITA O6). 1b'de hiçbir halka açık sürümün `faulty` listesi dolu değil, bu yüzden kart 100 koşuda hiç gelmedi.

| pazar | kol | n | acil durum/koşu | kesinti_b2b | kesinti_b2c | odeme | yorum_firtinasi | ay_kapanisi | surum_sonrasi_bozulma | launch_leak (B2C) |
|---|---|---|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 7.0 / 6.4 | 6.0 / 6.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.4 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2b | worst | 11 | 5.0 / 5.1 | 4.0 / 5.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.1 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2b | due | 11 | 4.0 / 4.7 | 4.0 / 4.6 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.1 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2b | off | 11 | 3.0 / 3.1 | 3.0 / 3.1 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2c | none | 11 | 7.0 / 6.6 | 0.0 / 0.0 | 3.0 / 2.5 | 2.0 / 1.8 | 2.0 / 2.3 | 0.0 / 0.0 | 0.0 / 0.0 | 1.0 / 1.0 |
| b2c | worst | 11 | 6.0 / 5.8 | 0.0 / 0.0 | 3.0 / 3.5 | 2.0 / 2.0 | 0.0 / 0.4 | 0.0 / 0.0 | 0.0 / 0.0 | 1.0 / 1.0 |
| b2c | due | 11 | 5.0 / 5.2 | 0.0 / 0.0 | 4.0 / 3.3 | 2.0 / 1.8 | 0.0 / 0.1 | 0.0 / 0.0 | 0.0 / 0.0 | 1.0 / 1.0 |
| b2c | off | 11 | 4.0 / 3.5 | 0.0 / 0.0 | 3.0 / 2.8 | 0.0 / 0.7 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 1.0 / 1.0 |

### 3. Düzeltme kartı payı

`share` = sprint başında düzeltme kartlarının kalan puanı / sprint kapasitesi (`PROBE FIX`). İkinci sütun `PROBE SPRINT shipped=` içindeki `fix:` kartlarının tüm teslim edilen kartlara oranı.

| pazar | kol | n | düzeltme payı, sprint başı (`share`, v1.0 sonrası, koşu medyanı) | düzeltme kartı / teslim edilen kart | hata sprinti oranı (pay > 0,5) |
|---|---|---|---|---|---|
| b2b | none | 11 | 0.000 / 0.000 | 0.000 / 0.000 | 0.000 / 0.000 |
| b2b | worst | 11 | 0.050 / 0.052 | 0.378 / 0.378 | 0.000 / 0.000 |
| b2b | due | 11 | 0.050 / 0.055 | 0.417 / 0.414 | 0.012 / 0.009 |
| b2b | off | 11 | 0.050 / 0.052 | 0.378 / 0.378 | 0.000 / 0.000 |
| b2c | none | 11 | 0.054 / 0.054 | 0.325 / 0.324 | 0.000 / 0.000 |
| b2c | worst | 11 | 0.108 / 0.103 | 0.389 / 0.389 | 0.014 / 0.012 |
| b2c | due | 11 | 0.111 / 0.121 | 0.545 / 0.543 | 0.057 / 0.054 |
| b2c | off | 11 | 0.106 / 0.105 | 0.380 / 0.380 | 0.013 / 0.012 |

### 4. Kâğıt gelen sprint oranı

Kâğıt = `data/events/cards/product/sprint_*.json` kimliklerinden biri (`PROBE FIRE`); bir sprint, kapanışından önceki kesintilerde en az bir kâğıt varsa 'kâğıt gelen'dir (`analyze.per_sprint` kuralı).

| pazar | kol | n | kâğıt gelen sprint oranı (tümü) | kâğıt gelen sprint oranı (v1.0 sonrası) | kâğıt/koşu | kapanan sprint/koşu |
|---|---|---|---|---|---|---|
| b2b | none | 11 | 0.035 / 0.044 | 0.036 / 0.045 | 3.0 / 3.8 | 88 / 88 |
| b2b | worst | 11 | 0.059 / 0.057 | 0.060 / 0.058 | 5.0 / 4.8 | 85 / 85 |
| b2b | due | 11 | 0.049 / 0.057 | 0.050 / 0.058 | 4.0 / 4.7 | 84 / 83 |
| b2b | off | 11 | 0.058 / 0.053 | 0.060 / 0.055 | 5.0 / 4.5 | 86 / 85 |
| b2c | none | 11 | 0.051 / 0.056 | 0.052 / 0.057 | 4.0 / 4.5 | 80 / 80 |
| b2c | worst | 11 | 0.065 / 0.075 | 0.067 / 0.077 | 5.0 / 5.7 | 77 / 77 |
| b2c | due | 11 | 0.093 / 0.101 | 0.096 / 0.104 | 7.0 / 7.3 | 73 / 72 |
| b2c | off | 11 | 0.065 / 0.072 | 0.067 / 0.074 | 5.0 / 5.5 | 77 / 77 |

### 4b. Hiç gelmeyen kâğıtlar (ana 88 koşu, 44 kart)

Gelen kart: 23 / 44. 'Pazar' kartın `guards.market` değeridir; tek pazarlık kart o pazarın 44 koşusunda, 'both' kart 88 koşuda hiç gelmediyse listelenir.

| kart | pool_group | pazar | konuşan |
|---|---|---|---|
| product.sprint_design_color_blind | designer | both | designer |
| product.sprint_design_customer_colors | designer | b2b | designer |
| product.sprint_design_drawings_late | designer | both | designer |
| product.sprint_design_empty_state | designer | b2b | designer |
| product.sprint_design_empty_state_b2c | designer | b2c | designer |
| product.sprint_design_first_screen | designer | b2c | designer |
| product.sprint_design_gloves | designer | b2b | designer |
| product.sprint_design_notifications | designer | b2c | designer |
| product.sprint_pm_core_first | pm | b2c | product_manager |
| product.sprint_pm_phone_too | pm | b2b | product_manager |
| product.sprint_pm_phone_too_b2c | pm | b2c | product_manager |
| product.sprint_pm_renewal | pm | b2b | product_manager |
| product.sprint_pm_scope_grew | pm | b2b | product_manager |
| product.sprint_pm_spec_unclear | pm | b2b | product_manager |
| product.sprint_pm_spec_unclear_b2c | pm | b2c | product_manager |
| product.sprint_pm_two_accounts | pm | b2b | product_manager |
| product.sprint_solo_signup_code | solo | b2c | founder |
| product.sprint_late | system | both | developer|designer|tester |
| product.sprint_late_solo | system | both | founder |
| product.sprint_test_stock_transfer | tester | b2b | tester |
| product.sprint_test_too_much | tester | both | tester |

Hiç gelmeyen: 21 kart. En çok gelenler: product.sprint_dev_security_update=81, product.sprint_dev_shorter_path=78, product.sprint_solo_server_bill=57, product.sprint_untested_old_screens=33, product.sprint_dev_root_cause=30

### 5. `promise_due` ve `sprint_late` sayısı

İki kart da `PROBE FIRE`'da hiç görünmedi (88 + 12 koşuda toplam 0 `promise_due`, 0 `sprint_late`). Sebep: söz hep tutulmuş (`PROMISE resolved status=kept`) ve sprintler yük kapasitenin çok altında kalıp hep zamanında kapanıyor. `PROBE PROMISE` sütunları söz defteridir.

| pazar | kol | n | `promise_due` FIRE | `sprint_late*` FIRE | söz verildi (`PROMISE created`) | söz tutuldu (`resolved kept`) | söz tutulmadı (kept dışı) |
|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 3.0 / 3.2 | 3.0 / 3.2 | 0.0 / 0.0 |
| b2b | worst | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 2.0 / 2.8 | 2.0 / 2.8 | 0.0 / 0.0 |
| b2b | due | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 5.0 / 4.3 | 5.0 / 4.3 | 0.0 / 0.0 |
| b2b | off | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 2.0 / 3.2 | 2.0 / 3.2 | 0.0 / 0.0 |
| b2c | none | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2c | worst | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2c | due | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2c | off | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |

### 6. Erken kapanan sprint oranı

Sprint 2 hafta sabittir; bütün kartlar biterse erken kapanır. Ölçü: `PROBE FIX` (başlangıç haftası) ile ardından gelen `PROBE SPRINT` (kapanış haftası) arasındaki fark, `weeks=` alanından kısaysa erken.

| pazar | kol | n | erken kapanan sprint oranı (tümü) | erken kapanan (v1.0 sonrası) | ortalama sprint uzunluğu (hafta) |
|---|---|---|---|---|---|
| b2b | none | 11 | 0.830 / 0.826 | 0.859 / 0.855 | 1.17 / 1.17 |
| b2b | worst | 11 | 0.788 / 0.789 | 0.817 / 0.818 | 1.21 / 1.21 |
| b2b | due | 11 | 0.774 / 0.765 | 0.802 / 0.794 | 1.23 / 1.24 |
| b2b | off | 11 | 0.802 / 0.791 | 0.831 / 0.819 | 1.20 / 1.21 |
| b2c | none | 11 | 0.713 / 0.717 | 0.740 / 0.745 | 1.29 / 1.28 |
| b2c | worst | 11 | 0.662 / 0.657 | 0.689 / 0.684 | 1.34 / 1.34 |
| b2c | due | 11 | 0.589 / 0.574 | 0.614 / 0.599 | 1.41 / 1.43 |
| b2c | off | 11 | 0.662 / 0.667 | 0.689 / 0.694 | 1.34 / 1.33 |

Kapanan sprintlerin uzunluk dağılımı (88 ana koşu, hafta: sayı): {1: 5189, 2: 1935}; erken kapanan toplam oran 72.8%.

### 7. MVP haftası, 104. haftada MRR ve kasa

Son `PROBE STATE` (hafta 103) alınır, bkz. envanter. `PROBE END` 104'te basılır ama MRR ve kasa taşımaz.

| pazar | kol | n | MVP haftası (v1.0) | MRR (hafta 103) | kasa (hafta 103) | B2B hesap | B2C kitle | çalışan |
|---|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 7 / 7 | 159524 / 164974 | 619184 / 667114 | 249 / 258 | 0 / 0 | 13 / 12 |
| b2b | worst | 11 | 7 / 7 | 164579 / 165284 | 702452 / 722635 | 267 / 261 | 0 / 0 | 13 / 13 |
| b2b | due | 11 | 7 / 7 | 161250 / 170438 | 718647 / 736746 | 260 / 259 | 0 / 0 | 13 / 13 |
| b2b | off | 11 | 7 / 7 | 159759 / 165042 | 705024 / 718968 | 258 / 261 | 0 / 0 | 13 / 12 |
| b2c | none | 11 | 7 / 7 | 308148 / 310555 | 2140789 / 2025911 | 1 / 1 | 42799 / 43133 | 5 / 5 |
| b2c | worst | 11 | 7 / 7 | 1396632 / 1440878 | 4838469 / 4961138 | 1 / 1 | 193976 / 200122 | 5 / 5 |
| b2c | due | 11 | 7 / 7 | 1673808 / 1611005 | 5315793 / 5192846 | 1 / 1 | 232474 / 223751 | 6 / 6 |
| b2c | off | 11 | 7 / 7 | 2211324 / 2287593 | 6378479 / 6710796 | 1 / 1 | 307129 / 317721 | 5 / 5 |

### 7b. Saat durması, Traction haftaları (`PROBE STATE phase=2`)

R15'in tanımı: durma = cevaplanan karar ya da tek düğmeli kart (`PROBE PICK`) + sprint başlatma (`PROBE FIX`). Mail ve not saati durdurmaz. R15'in B2B Traction sayısı 1,72'dir (karar 0,82 + tek düğmeli 0,16 + sprint başlatma 0,74); R15'in betiği klasörde yok ve bu tablo onu birebir yeniden üretmez: burada istek kartı (`customer.request_feature`, B2B'de haftada yaklaşık 1) dahil 2,5, çıkarılınca 1,4 ile 1,5 olur. R15'in istek kartını saydığı belgesinde yazılı değil; iki okuma da yan yana verilir.

| pazar | kol | n | durma/hf (kart + sprint başlatma) | cevaplanan kart/hf | bunun istek kartı (`customer.request_feature`) | sprint başlatma/hf | 2 ve daha çok durmalı hafta oranı | bir haftada en çok durma |
|---|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 2.55 / 2.61 | 1.72 / 1.76 | 1.04 / 1.08 | 0.84 / 0.85 | 0.766 / 0.771 | 5 / 5 |
| b2b | worst | 11 | 2.52 / 2.55 | 1.71 / 1.73 | 1.07 / 1.09 | 0.82 / 0.81 | 0.761 / 0.759 | 5 / 5 |
| b2b | due | 11 | 2.52 / 2.51 | 1.74 / 1.71 | 1.05 / 1.07 | 0.79 / 0.79 | 0.739 / 0.739 | 5 / 5 |
| b2b | off | 11 | 2.49 / 2.50 | 1.69 / 1.69 | 1.08 / 1.09 | 0.83 / 0.81 | 0.745 / 0.747 | 5 / 5 |
| b2c | none | 11 | 1.15 / 1.14 | 0.42 / 0.42 | 0.00 / 0.00 | 0.72 / 0.72 | 0.263 / 0.261 | 3 / 3 |
| b2c | worst | 11 | 1.11 / 1.10 | 0.42 / 0.42 | 0.00 / 0.00 | 0.68 / 0.67 | 0.246 / 0.245 | 3 / 3 |
| b2c | due | 11 | 1.07 / 1.07 | 0.43 / 0.42 | 0.00 / 0.00 | 0.65 / 0.64 | 0.218 / 0.218 | 3 / 3 |
| b2c | off | 11 | 1.09 / 1.08 | 0.43 / 0.42 | 0.00 / 0.00 | 0.67 / 0.67 | 0.235 / 0.236 | 3 / 3 |

### 8. A'nın §4.2 hedefleri (fix_due ve fix_worst; `fix_tables_fixed.py`, `bug_sprint` küçük harf okumasıyla)

Havuz: 11 tohum birleşik, dönem 'erken' = v1.0'dan sonraki ilk 20 hafta, 'geç' = sonrası. Hücre: medyan (pay/açık hata) ya da ortalama (oran).

| pazar | kol | dönem | düzeltme payı medyanı | hata sprinti oranı | üst üste iki hata sprinti oranı | n (pay) |
|---|---|---|---|---|---|---|
| b2b | fix_worst | erken | 0.125 | 0.000 | 0.000 | 125 |
| b2b | fix_worst | geç | 0.051 | 0.000 | 0.000 | 778 |
| b2b | fix_due | erken | 0.037 | 0.060 | 0.000 | 117 |
| b2b | fix_due | geç | 0.051 | 0.001 | 0.000 | 768 |
| b2c | fix_worst | erken | 0.500 | 0.079 | 0.017 | 126 |
| b2c | fix_worst | geç | 0.098 | 0.000 | 0.000 | 685 |
| b2c | fix_due | erken | 0.333 | 0.252 | 0.107 | 123 |
| b2c | fix_due | geç | 0.110 | 0.016 | 0.000 | 640 |

A'nın hedef karşılaştırmaları (`fix_tables_fixed.targets`, eşikler betiğin içindeki E1 §9 sayıları; tam çıktı `D0b_a42_tablolar.txt`):

```
MISS fix_due b2b early haftada yeni hata (medyan) <= 1.5                                              2.00  n=220
PASS fix_due b2b early açık hata, sürüm anında (medyan) <= 4                                          3.00  n=112
PASS fix_due b2b early açık hata, sprint sonu (medyan) <= 8                                           7.00  n=117
PASS fix_due b2b late haftada yeni hata (medyan) <= 4                                                 2.00  n=847
PASS fix_due b2b late açık hata, sürüm anında (medyan) <= 8                                           4.00  n=603
PASS fix_due b2b late açık hata, sprint sonu (medyan) <= 16                                           7.00  n=768
PASS fix_due b2c early haftada yeni hata (medyan) <= 1.5                                              1.00  n=220
PASS fix_due b2c early açık hata, sürüm anında (medyan) <= 4                                          3.00  n=93
PASS fix_due b2c early açık hata, sprint sonu (medyan) <= 8                                           5.00  n=123
PASS fix_due b2c late haftada yeni hata (medyan) <= 3                                                 3.00  n=847
PASS fix_due b2c late açık hata, sürüm anında (medyan) <= 8                                           5.50  n=642
PASS fix_due b2c late açık hata, sprint sonu (medyan) <= 16                                          10.00  n=640
PASS fix_worst b2b late düzeltme payı medyanı <= 15%                                                  5.10  n=778
PASS fix_worst b2b early düzeltme payı medyanı <= 30%                                                12.50  n=125
PASS fix_worst b2c late düzeltme payı medyanı <= 15%                                                  9.80  n=685
MISS fix_worst b2c early düzeltme payı medyanı <= 30%                                                50.00  n=126
PASS fix_due b2b late düzeltme payı medyanı <= 20%                                                    5.10  n=768
PASS fix_due b2b early düzeltme payı medyanı <= 30%                                                   3.70  n=117
PASS fix_due b2c late düzeltme payı medyanı <= 20%                                                   11.00  n=640
MISS fix_due b2c early düzeltme payı medyanı <= 30%                                                  33.30  n=123
PASS fix_due b2b late hata sprinti oranı <= 5%                                                        0.13  n=768
PASS fix_due b2b early hata sprinti oranı <= 15%                                                      5.98  n=117
PASS fix_due b2c late hata sprinti oranı <= 5%                                                        1.56  n=640
MISS fix_due b2c early hata sprinti oranı <= 15%                                                     25.20  n=123
PASS fix_worst b2b late üst üste iki hata sprinti oranı <= 0%                                         0.00  n=778
PASS fix_worst b2b early üst üste iki hata sprinti oranı <= 1%                                        0.00  n=114
PASS fix_worst b2c late üst üste iki hata sprinti oranı <= 0%                                         0.00  n=685
MISS fix_worst b2c early üst üste iki hata sprinti oranı <= 1%                                        1.74  n=115
PASS fix_due b2b late üst üste iki hata sprinti oranı <= 0%                                           0.00  n=768
PASS fix_due b2b early üst üste iki hata sprinti oranı <= 1%                                          0.00  n=106
PASS fix_due b2c late üst üste iki hata sprinti oranı <= 0%                                           0.00  n=640
MISS fix_due b2c early üst üste iki hata sprinti oranı <= 1%                                         10.71  n=112
PASS churn b2b tohum 1: fix_worst kaybı <= fix_off + 10 puan                                          0.38  worst 0.38% off 0.00%
PASS churn b2b tohum 1: fix_none kaybı >= 2 x fix_off                                                 2.35  none 2.35% off 0.00%
PASS churn b2b tohum 2: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.42% off 0.42%
PASS churn b2b tohum 2: fix_none kaybı >= 2 x fix_off                                                 1.22  none 1.22% off 0.42%
PASS churn b2b tohum 3: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.40% off 0.40%
MISS churn b2b tohum 3: fix_none kaybı >= 2 x fix_off                                                 0.80  none 0.80% off 0.40%
PASS churn b2b tohum 4: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.37% off 0.37%
MISS churn b2b tohum 4: fix_none kaybı >= 2 x fix_off                                                 0.74  none 0.74% off 0.37%
PASS churn b2b tohum 5: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.00% off 0.00%
PASS churn b2b tohum 5: fix_none kaybı >= 2 x fix_off                                                 1.73  none 1.73% off 0.00%
PASS churn b2b tohum 6: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.37% off 0.36%
PASS churn b2b tohum 6: fix_none kaybı >= 2 x fix_off                                                 1.09  none 1.09% off 0.36%
PASS churn b2b tohum 7: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.00% off 0.00%
PASS churn b2b tohum 7: fix_none kaybı >= 2 x fix_off                                                 3.18  none 3.18% off 0.00%
PASS churn b2b tohum 8: fix_worst kaybı <= fix_off + 10 puan                                         -0.01  worst 0.74% off 0.74%
MISS churn b2b tohum 8: fix_none kaybı >= 2 x fix_off                                                 1.23  none 1.23% off 0.74%
PASS churn b2b tohum 9: fix_worst kaybı <= fix_off + 10 puan                                         -0.03  worst 0.37% off 0.40%
PASS churn b2b tohum 9: fix_none kaybı >= 2 x fix_off                                                 2.75  none 2.75% off 0.40%
PASS churn b2b tohum 10: fix_worst kaybı <= fix_off + 10 puan                                         0.02  worst 0.43% off 0.42%
PASS churn b2b tohum 10: fix_none kaybı >= 2 x fix_off                                                1.62  none 1.62% off 0.42%
PASS churn b2b tohum 11: fix_worst kaybı <= fix_off + 10 puan                                         0.00  worst 0.00% off 0.00%
PASS churn b2b tohum 11: fix_none kaybı >= 2 x fix_off                                                2.86  none 2.86% off 0.00%
PASS churn b2c tohum 1: fix_worst kaybı <= fix_off + 10 puan                                          7.42  worst 7.42% off 0.00%
PASS churn b2c tohum 1: fix_none kaybı >= 2 x fix_off                                                 9.35  none 9.35% off 0.00%
PASS churn b2c tohum 2: fix_worst kaybı <= fix_off + 10 puan                                          7.55  worst 7.55% off 0.00%
PASS churn b2c tohum 2: fix_none kaybı >= 2 x fix_off                                                25.63  none 25.63% off 0.00%
PASS churn b2c tohum 3: fix_worst kaybı <= fix_off + 10 puan                                          9.06  worst 9.06% off 0.00%
PASS churn b2c tohum 3: fix_none kaybı >= 2 x fix_off                                                34.59  none 34.59% off 0.00%
PASS churn b2c tohum 4: fix_worst kaybı <= fix_off + 10 puan                                          6.45  worst 6.45% off 0.00%
PASS churn b2c tohum 4: fix_none kaybı >= 2 x fix_off                                                18.92  none 18.92% off 0.00%
PASS churn b2c tohum 5: fix_worst kaybı <= fix_off + 10 puan                                          7.36  worst 7.36% off 0.00%
PASS churn b2c tohum 5: fix_none kaybı >= 2 x fix_off                                                19.23  none 19.23% off 0.00%
PASS churn b2c tohum 6: fix_worst kaybı <= fix_off + 10 puan                                          8.08  worst 8.08% off 0.00%
PASS churn b2c tohum 6: fix_none kaybı >= 2 x fix_off                                                25.17  none 25.17% off 0.00%
PASS churn b2c tohum 7: fix_worst kaybı <= fix_off + 10 puan                                          6.79  worst 6.79% off 0.00%
PASS churn b2c tohum 7: fix_none kaybı >= 2 x fix_off                                                24.28  none 24.28% off 0.00%
PASS churn b2c tohum 8: fix_worst kaybı <= fix_off + 10 puan                                          7.73  worst 7.73% off 0.00%
PASS churn b2c tohum 8: fix_none kaybı >= 2 x fix_off                                                22.03  none 22.03% off 0.00%
PASS churn b2c tohum 9: fix_worst kaybı <= fix_off + 10 puan                                          8.05  worst 8.05% off 0.00%
PASS churn b2c tohum 9: fix_none kaybı >= 2 x fix_off                                                17.86  none 17.86% off 0.00%
PASS churn b2c tohum 10: fix_worst kaybı <= fix_off + 10 puan                                         8.43  worst 8.43% off 0.00%
PASS churn b2c tohum 10: fix_none kaybı >= 2 x fix_off                                               16.52  none 16.52% off 0.00%
PASS churn b2c tohum 11: fix_worst kaybı <= fix_off + 10 puan                                         7.95  worst 7.95% off 0.00%
PASS churn b2c tohum 11: fix_none kaybı >= 2 x fix_off                                               21.04  none 21.04% off 0.00%
ÖZET: 76 hedef, 9 MISS
```

### 9. `_free` ikizleri (tohum 7 ve 11; n=2, medyan ve ortalama aynı iki sayıdan)

`_free` kolları sprinti acil durum cevabında hiç durdurmaz.

| pazar | kol | n | hata/koşu | açık hata, sprint sonu | acil durum/koşu | düzeltme payı | hata sprinti oranı | kâğıt gelen sprint (v1.0 sonrası) | erken kapanan | MVP haftası | MRR (hafta 103) | kasa (hafta 103) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2b | worst_free | 2 | 217 / 217 | 7.5 / 7.5 | 8.5 / 8.5 | 0.057 / 0.057 | 0.000 / 0.000 | 0.054 / 0.054 | 0.787 / 0.787 | 7 / 7 | 174238 / 174238 | 816425 / 816425 |
| b2b | due_free | 2 | 220 / 220 | 7.0 / 7.0 | 7.5 / 7.5 | 0.058 / 0.058 | 0.006 / 0.006 | 0.062 / 0.062 | 0.751 / 0.751 | 7 / 7 | 203464 / 203464 | 901458 / 901458 |
| b2b | off_free | 2 | 228 / 228 | 7.5 / 7.5 | 5.5 / 5.5 | 0.057 / 0.057 | 0.000 / 0.000 | 0.062 / 0.062 | 0.773 / 0.773 | 7 / 7 | 189456 / 189456 | 869960 / 869960 |
| b2c | worst_free | 2 | 392 / 392 | 15.0 / 15.0 | 7.0 / 7.0 | 0.112 / 0.112 | 0.007 / 0.007 | 0.110 / 0.110 | 0.626 / 0.626 | 7 / 7 | 1255320 / 1255320 | 4219958 / 4219958 |
| b2c | due_free | 2 | 484 / 484 | 9.5 / 9.5 | 6.0 / 6.0 | 0.128 / 0.128 | 0.080 / 0.080 | 0.122 / 0.122 | 0.569 / 0.569 | 7 / 7 | 1586916 / 1586916 | 5249897 / 5249897 |
| b2c | off_free | 2 | 430 / 430 | 15.5 / 15.5 | 4.0 / 4.0 | 0.103 / 0.103 | 0.007 / 0.007 | 0.080 / 0.080 | 0.661 / 0.661 | 7 / 7 | 1744668 / 1744668 | 5648820 / 5648820 |

### 10. Kitap fikstürleri: haftalık saat durması

`b2b_book20` (20 hesap, 6 kişi, 104 hafta) ve `b2b_book330` (330 hesap, 50 kişi, 52 hafta). Bu presetler `fix` kolu olmadığı için `PROBE STOP` basmaz (iki logda da 0). Haftalık durma, 7b'deki tanımla okunur (cevaplanan kart + sprint başlatma, Traction haftaları; iki fikstür de 2. haftadan sonra hep Traction'dadır). Kesinti sütunları: acil durum + kâğıt + `promise_due` (`analyze.KINDS` kuralı) hangi haftalarda ve kaç sprintte düştü; ayrıca o haftaki tüm `PROBE FIRE` (WEEK fires=).

| fikstür | hafta (Traction) | **durma/hf** (kart + sprint başlatma) | kart/hf | istek kartı/hf | sprint başlatma/hf | 2+ durmalı hafta | en çok durma/hafta | kesinti olan hafta | tüm FIRE olan hafta | acil durum | kâğıt | promise_due | kesintili sprint / kapanan sprint | PROBE STOP | hata/koşu | açık hata (sprint sonu medyanı) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2b_book20_s1 | 104 (101) | **1.50** | 0.51 | 0.00 | 0.98 | 0.446 | 3 | 14 | 57 | 13 | 1 | 0 | 14 / 100 | 0 | 111 | 1.0 |
| b2b_book330_s1 | 52 (50) | **1.62** | 0.64 | 0.00 | 0.98 | 0.500 | 4 | 7 | 31 | 7 | 0 | 0 | 7 / 51 | 0 | 245 | 5.0 |

### 11. `--sprint-probe` team=3 (hours=40, cards=2, ticks=60, fill=1, events=1; tohum 424242)

**testçisiz**: `SUMMARY|match=190/198|mvp_days=3x1`, `LOADSUM|team=3|weeks=2|sprints=50|planned=196|finished=181|idle=19|limits=ceiling:5,pool:45`, `PAPERSUM|weeks=2|sprints=50|papers=1|empty=49|empty_rate=0.98`; REPRED satırı: 7; SKIP: {'ceiling': 5}.
Uyuşmazlık: 8, hepsi adlı (`cause=` var: evet). Liste (sprint | kart | teslim 1/0 | devreden-bitmiş | neden):

| sprint | kart | teslim | kalan | neden |
|---|---|---|---|---|
| 2 | feat:line_note_tool_linking_k2 | 0 | 2.57 | cause=team |
| 3 | fix:line_note_tool_search | 0 | 0.36 | cause=team.burnout |
| 3 | feat:line_note_tool_sync_k2 | 0 | 1.39 | cause=team.burnout |
| 3 | res:onboarding | 0 | 0.39 | cause=team.burnout |
| 4 | feat:line_shared_security_k1@note_tool | 0 | 1.00 | cause=product.sprint_design_first_screen |
| 5 | fix:line_shared_mobile@note_tool | 0 | 0.16 | cause=team.burnout |
| 5 | fix:line_shared_integrations@note_tool | 0 | 0.00 | cause=team.burnout |
| 5 | plan:cap_paid_plan | 0 | 0.60 | cause=team.burnout |

Neden dağılımı: {'cause=team': 1, 'cause=team.burnout': 6, 'cause=product.sprint_design_first_screen': 1}

**testçili (`plus=tester@3`)**: `SUMMARY|match=198/207|mvp_days=3x1`, `LOADSUM|team=3|weeks=2|sprints=52|planned=205|finished=195|idle=52|limits=full:1,ceiling:2,pool:49`, `PAPERSUM|weeks=2|sprints=52|papers=1|empty=51|empty_rate=0.98`; REPRED satırı: 9; SKIP: {'full': 1, 'ceiling': 2}.
Uyuşmazlık: 9, hepsi adlı (`cause=` var: evet). Liste (sprint | kart | teslim 1/0 | devreden-bitmiş | neden):

| sprint | kart | teslim | kalan | neden |
|---|---|---|---|---|
| 2 | feat:line_note_tool_sync_k2 | 0 | 2.17 | cause=team |
| 3 | feat:line_shared_mobile_k2@note_tool | 0 | 3.22 | cause=team.burnout |
| 3 | feat:line_shared_integrations_k2@note_tool | 0 | 3.01 | cause=team.burnout |
| 3 | fix:line_shared_integrations@note_tool | 0 | 0.00 | cause=team.burnout |
| 3 | res:growth | 0 | 0.22 | cause=team.burnout |
| 3 | fix:line_shared_security@note_tool | 0 | 0.00 | cause=team.burnout |
| 3 | fix:line_shared_durability@note_tool | 0 | 0.00 | cause=team.burnout |
| 3 | feat:line_shared_durability_k2@note_tool | 0 | 0.00 | cause=team.burnout |
| 4 | plan:cap_paid_plan | 0 | 1.25 | cause=product.sprint_dev_relogin |

Neden dağılımı: {'cause=team': 1, 'cause=team.burnout': 7, 'cause=product.sprint_dev_relogin': 1}

### 12. `--tick-probe` (gece ve kare süreleri, ms)

`TICK|stopped` = saat ya da gece adımı bir tutuşla (saat durduran karar) bitti; o adımlar `hour` ve `night` istatistiğine girmez ve yanında hafta:ms yazar. `over16` = 16 ms'yi aşan kare sayısı.

| koşu | hour n/p50/p95/max | after_hour max | night n/max | each | after_night max | first_hour | first_night | stopped (hafta:ms) | topbar/gece | save kare | over16 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| team=6, 20 hesap | 39/3.07/4.07/4.07 | 0.20 | 3/70.50 | 2:43.8;4:59.5;6:70.5 | 0.22 | 1.63 | 43.79 | 3:210.9;5:215.5 (n=2) | 1 | 70.50 (async=1) | 5 |
| team=50, 330 hesap | 39/7.13/49.46/82.14 | 0.57 | 0/-1.00 | - | 0.00 | 4.05 | -1.00 | 2:624.0;3:1110.8;4:604.7;5:697.9;6:450.9 (n=5) | 0 | -1.00 (async=0) | 21 |
