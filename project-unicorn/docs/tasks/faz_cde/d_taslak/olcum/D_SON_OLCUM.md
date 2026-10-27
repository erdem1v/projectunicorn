# D son ölçümü (Faz D, D8b ek'ten sonraki HEAD)

D0b tabanıyla yan yana. Bu belge ölçüm özetidir: neden bulmaz, tahmin yazmaz. Ölçemediği satırı "ölçülemedi" diye bırakır.

## Kaynak

- Ağaç: HEAD `baa63da` (Faz D D8b ek). Loglarda `COMMIT.txt` yok; ağaç `scratchpad/wf/tree_son` (`gates.sh prep`, 08:06): `scripts/`, `data/` ve `localization/` altındaki 673 izlenen dosyanın hepsi `git hash-object` ile HEAD'le bayt eş doğrulandı. Koşular 08:10 ile 09:16 arası, `C:/unicorn_d1/dson_logs`.
- Karşılaştırma tabanı: D0b, `base=5d3ea000 (kod 0616245f + D0a 8038c424)`, `C:/unicorn_d1/d0b_logs`, belge `D0b_TABAN.md`. Aradaki Faz D commit'leri: D1 `d325f88`, D1b `a397dcf`, D2b `f79a6a0`, D2b ek `edbee46`, D3 `ee9e799`, D4 `0b3c213`, D4 ek `82fc3d2`, D7m `4816edb`, D8b `10b2a27`, D8a `569c843`, D8b ek `baa63da` (arada Ürün arayüzü `de0182e`, `906deff`). Park listesindeki adımlar (D2a, D2c, D3b, D5, D6, D7, D9 ve arayüz parçaları) bu ağaçta yoktur.
- Koşu listesi (106 koşu, `progress.txt` `ALL DONE`, hepsi `rc=0`, `PROBE END` sayısı 1, hata satırı 0): `full_run_fix_{none,worst,due,off}` ve `full_run_b2c_fix_{none,worst,due,off}` tohum 1..11 (88 koşu, 104 hafta, `--lang=tr`); `_free` ikizleri (`worst`, `due`, `off`, iki pazar) tohum 7 ve 11 (12 koşu); `b2b_book20` (tohum 1, 104 hafta) ve `b2b_book330` (tohum 1, 52 hafta); `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` testçisiz ve `plus=tester@3`; `--tick-probe=1:accounts=20:team=6` ve `--tick-probe=1:accounts=330:team=50`.
- `tick_team50_acc330`'ın ilk denemesi D0b'dekiyle aynı nedenle reddedildi (`TICK ERROR ... holds saves`: koşucunun ortak `APPDATA`sında kayıt var; `tick_team50_acc330.refused.log`). Aynı komut ağaçta temiz `APPDATA=C:/dson_tick50` ile bir kez yeniden koşuldu; geçerli sonuç `tick_team50_acc330.log`'dur.
- Betikler (hepsi bu klasörde): `d0b_taban.py` (gövdeyi üretir; D0b'deki halinden iki fark: `PROBE SHIP` alanını `faulty` ya da `escaped` olarak kendisi seçer, A §4.2 çıktı yolu bir argümandır; D0b logları üzerinde koşturulunca `d0b_per_kosu.tsv` ve `D0b_a42_tablolar.txt` bayt eş çıkar), `d_son_karsilastir.py` (fark tabloları), `d_son_per_kosu.tsv` (koşu başına satırlar), `D_SON_a42_tablolar.txt` (A §4.2 tam çıktısı). Komutlar: `python -I d0b_taban.py C:/unicorn_d1/dson_logs <tree_son> d_son_per_kosu.tsv D_SON_a42_tablolar.txt` ve `python -I d_son_karsilastir.py <D0b gövdesi> <D son gövdesi> C:/unicorn_d1/d0b_logs C:/unicorn_d1/dson_logs C:/unicorn_d1/base <tree_son>`.
- Hücre biçimi: tohumlar arası "medyan / ortalama" (n=11; `_free` n=2). Fark tablolarında `med eski → yeni (±%)` ve `ort eski → yeni (±%)`; ⚠ = |sapma| > %30 (eski değer 0 iken yeni sıfırdan büyükse "yeni").

## Okumadan önce: bu fark neye bağlanamaz

D0b ile D son iki şey birden değişti, ayrı ölçüm yok: (1) oyun modeli (D1 ölçek, D1b hız eğrisi, D3 hata modeli, D4 PM, D7m düzeltme puanı ve itibar eşiği k, D8 öneri), (2) ölçüm botu (`run_probe.gd`, D8a sonrası). Bot artık sprinti yalnız liderin önerisiyle kurar; eski botun ücretli planı kendisi eklemesi (`paid plan card`), verilmiş sözün kartını kendisi koyması (`_plan_promises`) ve araştırma sprintine yanına adım koyması (`_keep_building`) kaldırıldı. `due` kolunun eşiği `DUE_BUGS × k` oldu. Bu yüzden aşağıdaki farklardan hiçbiri tek bir commit'e atfedilmez; ayırmak için ayrı koşu gerekir (koşulmadı).

`PROBE SHIP` satırının sayım alanı değişti: D0b'de `faulty=` (hattına hata yazılan KART sayısı, 100 koşuda hep 0), D son'da `escaped=` (testten kaçan HATA sayısı). İki alan aynı birimde değil; 1b'de fark hesaplanmaz.

## Özet

1. **Hata hacmi.** Tanım: `PROBE BUGS new=` toplamı, koşu başına (`run_probe.gd:_log_bugs`; D0b'deki satırla aynı): o hafta canlı hatlara inen hata = `ProductState.open_bugs` farkı + düzeltme kartının o arada temizlediği hata; v1.0'dan önce satır basılmadığı için yalnız ürün canlıyken inenleri sayar (97 canlı hafta). Koşu başına medyan: B2B `none/worst/due/off` **171 / 175 / 174 / 175** (D0b 267 / 227 / 225 / 226, yani −23% ile −36%); B2C **115 / 338 / 358 / 370** (D0b 267 / 413 / 456 / 483, −18% ile −57%). Haftada B2B 1,8, B2C 3,5 ile 3,8 (`none` dışı kollar; D0b 2,3 ve 4,3 ile 5,0). Bu sayının kart kaynaklı payı alt sınırdan görülür: testten kaçan hata (`PROBE SHIP escaped=` toplamı) koşu başına B2B 14 ile 17, B2C 20 ile 25 (`none` dışı kollarda hatanın medyan %8,6'sı B2B'de, %6,7'si B2C'de; B2C `none` %17). Kalanı log'da kaynağa ayrılmaz: Destek masasının doğruladığı bildirim (`support_system.gd:123`), olay ve kâğıt etkileri (`effects.gd`, `main.gd`), kâğıdın `leaks`'i. D3 `c`'sini bu toplama kalibre etmek hâlâ doğan hata modelini Destek akışıyla karıştırır; log hata başına kaynak yazmaz.
2. **Açık hata** (sprint sonu, koşu medyanı): B2B `worst/due/off` 8 / 7 / 7,5 (D0b 8 / 7 / 8, aynı), `none` 83 (146 ⚠); B2C `worst/due/off` 9 / 8 / 8 (15 ⚠ / 9 / 17 ⚠), `none` 61 (43 ⚠, artış).
3. **Acil durum**/koşu (medyan): B2B 8 / 7 / 8 / 8 (D0b 7 / 5 / 4 / 3), B2C 8 / 8 / 7 / 6 (D0b 7 / 6 / 5 / 4). **Sürüm sonrası bozulma artık geliyor:** B2B 4 / 4 / 5 / 5, B2C 2 / 4 / 4 / 3 (D0b 100 koşuda 0). Kesinti sayısı ise B2B'de düştü (6 / 4 / 4 / 3 yerine 4 / 3 / 3 / 2).
4. **Düzeltme payı** (sprint başı `share`, medyan): B2B 0,061 / 0,059 / 0,061 (D0b 0,05), B2C 0,113 / 0,112 / 0,113 (0,108 / 0,111 / 0,106); B2C `none` 0 (D0b 0,054). Hata sprinti oranı: B2B 0,014 ile 0,027 (D0b 0 ile 0,012), B2C `due` 0,059 (0,057).
5. **Kâğıt gelen sprint** (v1.0 sonrası): B2B %7,7 ile %8,9 (D0b %3,6 ile %6,0), B2C %6,6 ile %10,3 (%5,2 ile %9,6). Hiç gelmeyen kâğıt 18 (D0b 21): `sprint_pm_phone_too`, `sprint_pm_scope_grew`, `sprint_pm_spec_unclear`, `sprint_late` geldi; `sprint_founder_test_pile` D0b'de geliyordu, bu ölçümde gelmedi. Tasarımcı kâğıtlarının sekizi (8/8) yine hiç gelmiyor. Gelen kart 26 / 44 (23 / 44).
6. **`promise_due` ve `sprint_late`**: artık düşüyor (D0b'de 0): 100 koşuda toplam 18 `promise_due` ve 10 `sprint_late*`, hepsi B2B'de (B2C'de söz yok); medyan hâlâ 0, ortalama 0,2 ile 0,6. Verilen söz sayısı B2B'de medyan 8 ile 11 (D0b 2 ile 5); tutulmayan söz ortalaması 0,2 ile 1,1.
7. **Erken kapanan sprint**: kapanan 6.572 sprintin %62,3'ü 1 haftada kapandı (D0b %72,8; 4.097 bir hafta, 2.475 iki hafta). B2B %66 ile %71 (D0b %77 ile %83), B2C %52 ile %66 (%59 ile %71).
8. **MVP haftası** 7 (100 koşuda da, değişmedi). Hafta 103'te MRR ve kasa: B2B ~149 ile 154 bin $ ve 0,59 ile 0,60 milyon $ (D0b 160 ile 165 bin $ ve 0,62 ile 0,72 milyon $); B2C `worst/due/off` MRR 1,61 / 1,78 / 2,15 milyon $, kasa 5,15 / 5,60 / 6,20 milyon $ (D0b 1,40 / 1,67 / 2,21 ve 4,84 / 5,32 / 6,38); **B2C `none` çöktü**: MRR 19 bin $ (D0b 308 bin $ ⚠), kasa 0,27 milyon $ (2,14 milyon $ ⚠). Örnek koşu (`full_run_b2c_fix_none_s1`): hafta 100'de açık hata 118, memnuniyet 10; `none` kolunda bu ölçümde neredeyse hiç düzeltme kartı teslim edilmiyor (kart payı 0,010; D0b 0,325). Nedeni model mi bot mu ayrılamadı.
9. **A §4.2 hedefleri**: 76 hedefin 7'si MISS (D0b 9). 10 hedef durum değiştirdi (3 hedef MISS'ten PASS'e, 4 hedef PASS'ten MISS'e, 3 churn hedefi MISS'ten PASS'e); üç B2C erken dönem hedefi iki ölçümde de MISS. Ayrıntı K8b.
10. **Kitap fikstürleri** (Traction, kart + sprint başlatma): 20 hesapta haftada **1,50**, 330 hesapta **1,62** durma (D0b ile aynı); iki fikstürde istek kartı yok. 20 hesaplı fikstürde 1 `PROBE STOP` (D0b 0).
11. **team=3 probu**: testçisiz **164/172** eşleşme (D0b 190/198), testçili **186/195** (198/207). Uyuşmazlık 8 ve 9, hepsi adlı (`cause=` var); `team.burnout` baskın (5/8 ve 7/9). Testçisiz probda yeni neden `product.sprint_dev_old_phones` (2).
12. **Tick probu**: 6 kişi ve 20 hesapta gece en çok 67,6 ms (D0b 70,5), saat adımı p95 3,95 ms; 50 kişi ve 330 hesapta saat adımı p95 24,9 ms ⚠ (D0b 49,5) ve en çok 30,8 ms (82,1 ⚠), 16 ms üstü kare 9 (21); gece ölçümü yine yok (`night n=0`), beş adım tutuşla bitti (600 ile 926 ms; D0b 451 ile 1.111 ms). Her fikstür tek koşu ve süre ölçümüdür (tekrar yok); farkların gürültü payı ölçülmedi.

## Karşılaştırma tabloları (D0b → D son)

Hücre: `med` tohumlar arası medyan, `ort` ortalama; `eski → yeni (±%)`; `=` değişmedi; ⚠ = |sapma| > %30 (eski 0 iken yeni sıfırdan büyükse `yeni`). n=11 (`_free` n=2).


### K1. Hata hacmi ve açık hata (hücre: tohumlar arası medyan / ortalama)

| pazar | kol | n | hata/koşu (PROBE BUGS new= toplamı) | hata/canlı hafta | canlı hafta | açık hata, sprint sonu (koşu medyanı) | açık hata, sürüm anı (koşu medyanı) |
|---|---|---|---|---|---|---|---|
| b2b | none | = 11 | med 267 → 171 (-36%) ⚠ · ort 271 → 173 (-36%) ⚠ | med 2.75 → 1.76 (-36%) ⚠ · ort 2.79 → 1.78 (-36%) ⚠ | = 97 / 97 | med 146 → 83 (-43%) ⚠ · ort 146.1 → 83.2 (-43%) ⚠ | med 41 → 29 (-29%) · ort 41 → 29.8 (-27%) |
| b2b | worst | = 11 | med 227 → 175 (-23%) · ort 226 → 177 (-22%) | med 2.34 → 1.8 (-23%) · ort 2.33 → 1.82 (-22%) | = 97 / 97 | med 8 = · ort 7.8 → 7.7 (-1%) | med 5 → 6 (+20%) · ort 5.5 = |
| b2b | due | = 11 | med 225 → 174 (-23%) · ort 228 → 174 (-24%) | med 2.32 → 1.79 (-23%) · ort 2.35 → 1.8 (-23%) | = 97 / 97 | med 7 = · ort 6.8 → 6.7 (-1%) | med 4 = · ort 4.2 → 4.4 (+5%) |
| b2b | off | = 11 | med 226 → 175 (-23%) · ort 227 → 175 (-23%) | med 2.33 → 1.8 (-23%) · ort 2.34 → 1.81 (-23%) | = 97 / 97 | med 8 → 7.5 (-6%) · ort 8 → 7.5 (-6%) | med 6 → 5 (-17%) · ort 5.6 → 5.5 (-2%) |
| b2c | none | = 11 | med 267 → 115 (-57%) ⚠ · ort 263 → 116 (-56%) ⚠ | med 2.75 → 1.19 (-57%) ⚠ · ort 2.71 → 1.2 (-56%) ⚠ | = 97 / 97 | med 43 → 61 (+42%) ⚠ · ort 42.7 → 61.4 (+44%) ⚠ | med 43 → 31 (-28%) · ort 42.1 → 31.5 (-25%) |
| b2c | worst | = 11 | med 413 → 338 (-18%) · ort 410 → 333 (-19%) | med 4.26 → 3.48 (-18%) · ort 4.23 → 3.43 (-19%) | = 97 / 97 | med 15 → 9 (-40%) ⚠ · ort 16.1 → 9 (-44%) ⚠ | med 13 → 8 (-38%) ⚠ · ort 13.1 → 8 (-39%) ⚠ |
| b2c | due | = 11 | med 456 → 358 (-21%) · ort 452 → 351 (-22%) | med 4.7 → 3.69 (-21%) · ort 4.66 → 3.61 (-23%) | = 97 / 97 | med 9 → 8 (-11%) · ort 8.8 → 8.2 (-7%) | med 5 → 6 (+20%) · ort 5.1 → 5.9 (+16%) |
| b2c | off | = 11 | med 483 → 370 (-23%) · ort 491 → 375 (-24%) | med 4.98 → 3.81 (-23%) · ort 5.06 → 3.87 (-24%) | = 97 / 97 | med 17 → 8 (-53%) ⚠ · ort 17.8 → 9.1 (-49%) ⚠ | med 14 → 7 (-50%) ⚠ · ort 14.9 → 7.7 (-48%) ⚠ |

### K1b. Sürümden kaçan hata (`PROBE SHIP escaped=`)

| pazar | kol | n | sürümde `escaped` toplamı | hata kaçan sürüm | toplam sürüm |
|---|---|---|---|---|---|
| b2b | none | = 11 | 17 / 16 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 9 / 9 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | = 17 / 17 |
| b2b | worst | = 11 | 15 / 16 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 9 / 9 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | med 83 → 71 (-14%) · ort 83 → 71 (-14%) |
| b2b | due | = 11 | 15 / 16 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 9 / 10 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | med 66 → 57 (-14%) · ort 65 → 56 (-14%) |
| b2b | off | = 11 | 14 / 16 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 10 / 9 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | med 84 → 72 (-14%) · ort 83 → 71 (-14%) |
| b2c | none | = 11 | 20 / 20 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 10 / 11 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | med 73 → 22 (-70%) ⚠ · ort 73 → 22 (-70%) ⚠ |
| b2c | worst | = 11 | 25 / 25 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 13 / 14 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | med 71 → 65 (-8%) · ort 71 → 65 (-8%) |
| b2c | due | = 11 | 24 / 25 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 12 / 13 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | med 67 → 55 (-18%) · ort 67 → 55 (-18%) |
| b2c | off | = 11 | 25 / 25 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | 14 / 14 (D0b alanı `faulty`: 0 / 0; birim farklı, fark yok) | med 73 → 65 (-11%) · ort 72 → 63 (-12%) |

### K1c. Haftalık hata akışı, hafta türüne göre (88 ana koşu birleşik)

| pazar | kapanış türü | olay | hafta sayısı | hata toplamı | hata/hafta |
|---|---|---|---|---|---|
| b2b | halka açık sürümlü kapanış | olaylı hafta | 108 → 201 (+86%) ⚠ | 290 → 595 (+105%) ⚠ | 2.69 → 2.96 (+10%) |
| b2b | halka açık sürümlü kapanış | olaysız hafta | 2547 → 2085 (-18%) | 6471 → 4220 (-35%) ⚠ | 2.54 → 2.02 (-20%) |
| b2b | kapanışsız hafta | olaylı hafta | 231 → 378 (+64%) ⚠ | 426 → 384 (-10%) | 1.84 → 1.02 (-45%) ⚠ |
| b2b | kapanışsız hafta | olaysız hafta | 413 → 609 (+47%) ⚠ | 929 → 785 (-16%) | 2.25 → 1.29 (-43%) ⚠ |
| b2b | sürümsüz kapanış | olaylı hafta | 58 → 48 (-17%) | 125 → 93 (-26%) | 2.16 → 1.94 (-10%) |
| b2b | sürümsüz kapanış | olaysız hafta | 911 → 947 (+4%) | 2228 → 1611 (-28%) | 2.45 → 1.7 (-31%) ⚠ |
| b2c | halka açık sürümlü kapanış | olaylı hafta | 185 → 223 (+21%) | 963 → 1036 (+8%) | 5.21 → 4.65 (-11%) |
| b2c | halka açık sürümlü kapanış | olaysız hafta | 2849 → 1982 (-30%) ⚠ | 13254 → 7644 (-42%) ⚠ | 4.65 → 3.86 (-17%) |
| b2c | kapanışsız hafta | olaylı hafta | 284 → 315 (+11%) | 904 → 822 (-9%) | 3.18 → 2.61 (-18%) |
| b2c | kapanışsız hafta | olaysız hafta | 743 → 909 (+22%) | 2422 → 2443 (+1%) | 3.26 → 2.69 (-17%) |
| b2c | sürümsüz kapanış | olaylı hafta | 3 → 56 (+1767%) ⚠ | 6 → 86 (+1333%) ⚠ | 2 → 1.54 (-23%) |
| b2c | sürümsüz kapanış | olaysız hafta | 204 → 783 (+284%) ⚠ | 218 → 894 (+310%) ⚠ | 1.07 → 1.14 (+7%) |

### K2. Acil durum sayısı ve sürüm sonrası bozulma

| pazar | kol | n | acil durum/koşu | kesinti_b2b | kesinti_b2c | odeme | yorum_firtinasi | ay_kapanisi | surum_sonrasi_bozulma | launch_leak (B2C) |
|---|---|---|---|---|---|---|---|---|---|---|
| b2b | none | = 11 | med 7 → 8 (+14%) · ort 6.4 → 8.5 (+33%) ⚠ | med 6 → 4 (-33%) ⚠ · ort 6 → 4 (-33%) ⚠ | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.4 | med 0 → 4 (yeni) ⚠ · ort 0 → 4.1 (yeni) ⚠ | = 0.0 / 0.0 |
| b2b | worst | = 11 | med 5 → 7 (+40%) ⚠ · ort 5.1 → 7.5 (+47%) ⚠ | med 4 → 3 (-25%) · ort 5 → 3.2 (-36%) ⚠ | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | med 0 = · ort 0.1 → 0.2 (+100%) ⚠ | med 0 → 4 (yeni) ⚠ · ort 0 → 4.2 (yeni) ⚠ | = 0.0 / 0.0 |
| b2b | due | = 11 | med 4 → 8 (+100%) ⚠ · ort 4.7 → 8.4 (+79%) ⚠ | med 4 → 3 (-25%) · ort 4.6 → 2.9 (-37%) ⚠ | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | med 0 = · ort 0.1 → 0.2 (+100%) ⚠ | med 0 → 5 (yeni) ⚠ · ort 0 → 5.3 (yeni) ⚠ | = 0.0 / 0.0 |
| b2b | off | = 11 | med 3 → 8 (+167%) ⚠ · ort 3.1 → 7.5 (+142%) ⚠ | med 3 → 2 (-33%) ⚠ · ort 3.1 → 2.4 (-23%) | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | med 0 → 5 (yeni) ⚠ · ort 0 → 5.1 (yeni) ⚠ | = 0.0 / 0.0 |
| b2c | none | = 11 | med 7 → 8 (+14%) · ort 6.6 → 7.8 (+18%) | = 0.0 / 0.0 | med 3 → 2 (-33%) ⚠ · ort 2.5 = | med 2 → 1 (-50%) ⚠ · ort 1.8 → 1.6 (-11%) | med 2 = · ort 2.3 → 1.7 (-26%) | = 0.0 / 0.0 | med 0 → 2 (yeni) ⚠ · ort 0 → 2 (yeni) ⚠ | = 1.0 / 1.0 |
| b2c | worst | = 11 | med 6 → 8 (+33%) ⚠ · ort 5.8 → 8.2 (+41%) ⚠ | = 0.0 / 0.0 | med 3 = · ort 3.5 → 2.5 (-29%) | med 2 = · ort 2 → 1.5 (-25%) | med 0 = · ort 0.4 → 0.5 (+25%) | = 0.0 / 0.0 | med 0 → 4 (yeni) ⚠ · ort 0 → 3.7 (yeni) ⚠ | = 1.0 / 1.0 |
| b2c | due | = 11 | med 5 → 7 (+40%) ⚠ · ort 5.2 → 8 (+54%) ⚠ | = 0.0 / 0.0 | med 4 → 3 (-25%) · ort 3.3 → 2.6 (-21%) | med 2 → 1 (-50%) ⚠ · ort 1.8 → 1.5 (-17%) | med 0 = · ort 0.1 → 0 (-100%) ⚠ | = 0.0 / 0.0 | med 0 → 4 (yeni) ⚠ · ort 0 → 3.8 (yeni) ⚠ | = 1.0 / 1.0 |
| b2c | off | = 11 | med 4 → 6 (+50%) ⚠ · ort 3.5 → 6.5 (+86%) ⚠ | = 0.0 / 0.0 | med 3 → 2 (-33%) ⚠ · ort 2.8 → 2.1 (-25%) | med 0 → 1 (yeni) ⚠ · ort 0.7 → 0.8 (+14%) | = 0.0 / 0.0 | = 0.0 / 0.0 | med 0 → 3 (yeni) ⚠ · ort 0 → 3.6 (yeni) ⚠ | = 1.0 / 1.0 |

### K3. Düzeltme kartı payı

| pazar | kol | n | düzeltme payı, sprint başı (`share`, v1.0 sonrası, koşu medyanı) | düzeltme kartı / teslim edilen kart | hata sprinti oranı (pay > 0,5) |
|---|---|---|---|---|---|
| b2b | none | = 11 | = 0.000 / 0.000 | = 0.000 / 0.000 | = 0.000 / 0.000 |
| b2b | worst | = 11 | med 0.05 → 0.061 (+22%) · ort 0.052 → 0.064 (+23%) | med 0.378 → 0.395 (+4%) · ort 0.378 → 0.394 (+4%) | med 0 → 0.014 (yeni) ⚠ · ort 0 → 0.027 (yeni) ⚠ |
| b2b | due | = 11 | med 0.05 → 0.059 (+18%) · ort 0.055 → 0.062 (+13%) | med 0.417 → 0.408 (-2%) · ort 0.414 → 0.408 (-1%) | med 0.012 → 0.027 (+125%) ⚠ · ort 0.009 → 0.029 (+222%) ⚠ |
| b2b | off | = 11 | med 0.05 → 0.061 (+22%) · ort 0.052 → 0.065 (+25%) | med 0.378 → 0.397 (+5%) · ort 0.378 → 0.399 (+6%) | med 0 → 0.027 (yeni) ⚠ · ort 0 → 0.027 (yeni) ⚠ |
| b2c | none | = 11 | med 0.054 → 0 (-100%) ⚠ · ort 0.054 → 0 (-100%) ⚠ | med 0.325 → 0.01 (-97%) ⚠ · ort 0.324 → 0.015 (-95%) ⚠ | = 0.000 / 0.000 |
| b2c | worst | = 11 | med 0.108 → 0.113 (+5%) · ort 0.103 → 0.11 (+7%) | med 0.389 → 0.38 (-2%) · ort 0.389 → 0.385 (-1%) | med 0.014 → 0 (-100%) ⚠ · ort 0.012 → 0.014 (+17%) |
| b2c | due | = 11 | med 0.111 → 0.112 (+1%) · ort 0.121 → 0.112 (-7%) | med 0.545 → 0.507 (-7%) · ort 0.543 → 0.505 (-7%) | med 0.057 → 0.059 (+4%) · ort 0.054 → 0.057 (+6%) |
| b2c | off | = 11 | med 0.106 → 0.113 (+7%) · ort 0.105 → 0.116 (+10%) | med 0.38 → 0.382 (+1%) · ort 0.38 → 0.383 (+1%) | med 0.013 → 0.029 (+123%) ⚠ · ort 0.012 → 0.027 (+125%) ⚠ |

### K4. Kâğıt gelen sprint oranı

| pazar | kol | n | kâğıt gelen sprint oranı (tümü) | kâğıt gelen sprint oranı (v1.0 sonrası) | kâğıt/koşu | kapanan sprint/koşu |
|---|---|---|---|---|---|---|
| b2b | none | = 11 | med 0.035 → 0.075 (+114%) ⚠ · ort 0.044 → 0.084 (+91%) ⚠ | med 0.036 → 0.077 (+114%) ⚠ · ort 0.045 → 0.086 (+91%) ⚠ | med 3 → 6 (+100%) ⚠ · ort 3.8 → 6.6 (+74%) ⚠ | med 88 → 80 (-9%) · ort 88 → 80 (-9%) |
| b2b | worst | = 11 | med 0.059 → 0.076 (+29%) · ort 0.057 → 0.083 (+46%) ⚠ | med 0.06 → 0.078 (+30%) ⚠ · ort 0.058 → 0.085 (+47%) ⚠ | med 5 → 6 (+20%) · ort 4.8 → 6.4 (+33%) ⚠ | med 85 → 77 (-9%) · ort 85 → 77 (-9%) |
| b2b | due | = 11 | med 0.049 → 0.078 (+59%) ⚠ · ort 0.057 → 0.078 (+37%) ⚠ | med 0.05 → 0.08 (+60%) ⚠ · ort 0.058 → 0.08 (+38%) ⚠ | med 4 → 6 (+50%) ⚠ · ort 4.7 → 5.9 (+26%) | med 84 → 77 (-8%) · ort 83 → 76 (-8%) |
| b2b | off | = 11 | med 0.058 → 0.086 (+48%) ⚠ · ort 0.053 → 0.082 (+55%) ⚠ | med 0.06 → 0.089 (+48%) ⚠ · ort 0.055 → 0.084 (+53%) ⚠ | med 5 → 6 (+20%) · ort 4.5 → 6.3 (+40%) ⚠ | med 86 → 78 (-9%) · ort 85 → 77 (-9%) |
| b2c | none | = 11 | med 0.051 → 0.064 (+25%) · ort 0.056 → 0.059 (+5%) | med 0.052 → 0.066 (+27%) · ort 0.057 → 0.061 (+7%) | med 4 → 5 (+25%) · ort 4.5 = | med 80 → 77 (-4%) · ort 80 → 77 (-4%) |
| b2c | worst | = 11 | med 0.065 → 0.088 (+35%) ⚠ · ort 0.075 → 0.082 (+9%) | med 0.067 → 0.091 (+36%) ⚠ · ort 0.077 → 0.084 (+9%) | med 5 → 6 (+20%) · ort 5.7 → 5.8 (+2%) | med 77 → 70 (-9%) · ort 77 → 71 (-8%) |
| b2c | due | = 11 | med 0.093 → 0.1 (+8%) · ort 0.101 → 0.093 (-8%) | med 0.096 → 0.103 (+7%) · ort 0.104 → 0.096 (-8%) | med 7 = · ort 7.3 → 6.5 (-11%) | med 73 → 69 (-5%) · ort 72 → 69 (-4%) |
| b2c | off | = 11 | med 0.065 → 0.096 (+48%) ⚠ · ort 0.072 → 0.101 (+40%) ⚠ | med 0.067 → 0.099 (+48%) ⚠ · ort 0.074 → 0.104 (+41%) ⚠ | med 5 → 7 (+40%) ⚠ · ort 5.5 → 7 (+27%) | med 77 → 70 (-9%) · ort 77 → 70 (-9%) |

### K5. `promise_due` ve `sprint_late` sayısı

| pazar | kol | n | `promise_due` FIRE | `sprint_late*` FIRE | söz verildi (`PROMISE created`) | söz tutuldu (`resolved kept`) | söz tutulmadı (kept dışı) |
|---|---|---|---|---|---|---|---|
| b2b | none | = 11 | med 0 = · ort 0 → 0.3 (yeni) ⚠ | med 0 = · ort 0 → 0.3 (yeni) ⚠ | med 3 → 11 (+267%) ⚠ · ort 3.2 → 12.6 (+294%) ⚠ | med 3 → 11 (+267%) ⚠ · ort 3.2 → 12.5 (+291%) ⚠ | med 0 = · ort 0 → 0.2 (yeni) ⚠ |
| b2b | worst | = 11 | med 0 = · ort 0 → 0.6 (yeni) ⚠ | med 0 = · ort 0 → 0.2 (yeni) ⚠ | med 2 → 8 (+300%) ⚠ · ort 2.8 → 12 (+329%) ⚠ | med 2 → 8 (+300%) ⚠ · ort 2.8 → 11.7 (+318%) ⚠ | med 0 = · ort 0 → 0.5 (yeni) ⚠ |
| b2b | due | = 11 | med 0 = · ort 0 → 0.5 (yeni) ⚠ | med 0 = · ort 0 → 0.2 (yeni) ⚠ | med 5 → 11 (+120%) ⚠ · ort 4.3 → 11.8 (+174%) ⚠ | med 5 → 11 (+120%) ⚠ · ort 4.3 → 11.3 (+163%) ⚠ | med 0 = · ort 0 → 1.1 (yeni) ⚠ |
| b2b | off | = 11 | med 0 = · ort 0 → 0.3 (yeni) ⚠ | med 0 = · ort 0 → 0.3 (yeni) ⚠ | med 2 → 9 (+350%) ⚠ · ort 3.2 → 9.4 (+194%) ⚠ | med 2 → 9 (+350%) ⚠ · ort 3.2 → 8.8 (+175%) ⚠ | med 0 = · ort 0 → 1.1 (yeni) ⚠ |
| b2c | none | = 11 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 |
| b2c | worst | = 11 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 |
| b2c | due | = 11 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 |
| b2c | off | = 11 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 | = 0.0 / 0.0 |

### K6. Erken kapanan sprint oranı

| pazar | kol | n | erken kapanan sprint oranı (tümü) | erken kapanan (v1.0 sonrası) | ortalama sprint uzunluğu (hafta) |
|---|---|---|---|---|---|
| b2b | none | = 11 | med 0.83 → 0.713 (-14%) · ort 0.826 → 0.705 (-15%) | med 0.859 → 0.74 (-14%) · ort 0.855 → 0.732 (-14%) | med 1.17 → 1.29 (+10%) · ort 1.17 → 1.3 (+11%) |
| b2b | worst | = 11 | med 0.788 → 0.662 (-16%) · ort 0.789 → 0.665 (-16%) | med 0.817 → 0.689 (-16%) · ort 0.818 → 0.692 (-15%) | med 1.21 → 1.34 (+11%) · ort 1.21 → 1.34 (+11%) |
| b2b | due | = 11 | med 0.774 → 0.662 (-14%) · ort 0.765 → 0.649 (-15%) | med 0.802 → 0.689 (-14%) · ort 0.794 → 0.676 (-15%) | med 1.23 → 1.34 (+9%) · ort 1.24 → 1.35 (+9%) |
| b2b | off | = 11 | med 0.802 → 0.679 (-15%) · ort 0.791 → 0.662 (-16%) | med 0.831 → 0.707 (-15%) · ort 0.819 → 0.689 (-16%) | med 1.2 → 1.32 (+10%) · ort 1.21 → 1.34 (+11%) |
| b2c | none | = 11 | med 0.713 → 0.662 (-7%) · ort 0.717 → 0.664 (-7%) | med 0.74 → 0.689 (-7%) · ort 0.745 → 0.691 (-7%) | med 1.29 → 1.34 (+4%) · ort 1.28 → 1.34 (+5%) |
| b2c | worst | = 11 | med 0.662 → 0.543 (-18%) · ort 0.657 → 0.56 (-15%) | med 0.689 → 0.567 (-18%) · ort 0.684 → 0.584 (-15%) | med 1.34 → 1.46 (+9%) · ort 1.34 → 1.44 (+7%) |
| b2c | due | = 11 | med 0.589 → 0.522 (-11%) · ort 0.574 → 0.519 (-10%) | med 0.614 → 0.545 (-11%) · ort 0.599 → 0.542 (-10%) | med 1.41 → 1.48 (+5%) · ort 1.43 → 1.48 (+3%) |
| b2c | off | = 11 | med 0.662 → 0.543 (-18%) · ort 0.667 → 0.526 (-21%) | med 0.689 → 0.567 (-18%) · ort 0.694 → 0.55 (-21%) | med 1.34 → 1.46 (+9%) · ort 1.33 → 1.47 (+11%) |

### K7. MVP haftası, 104. haftada MRR ve kasa

| pazar | kol | n | MVP haftası (v1.0) | MRR (hafta 103) | kasa (hafta 103) | B2B hesap | B2C kitle | çalışan |
|---|---|---|---|---|---|---|---|---|
| b2b | none | = 11 | = 7 / 7 | med 159524 → 148890 (-7%) · ort 164974 → 147161 (-11%) | med 619184 → 595780 (-4%) · ort 667114 → 560917 (-16%) | med 249 → 243 (-2%) · ort 258 → 238 (-8%) | = 0 / 0 | med 13 = · ort 12 → 13 (+8%) |
| b2b | worst | = 11 | = 7 / 7 | med 164579 → 152583 (-7%) · ort 165284 → 157813 (-5%) | med 702452 → 590411 (-16%) · ort 722635 → 620960 (-14%) | med 267 → 253 (-5%) · ort 261 → 250 (-4%) | = 0 / 0 | = 13 / 13 |
| b2b | due | = 11 | = 7 / 7 | med 161250 → 153767 (-5%) · ort 170438 → 157230 (-8%) | med 718647 → 591306 (-18%) · ort 736746 → 618934 (-16%) | med 260 → 248 (-5%) · ort 259 → 245 (-5%) | = 0 / 0 | = 13 / 13 |
| b2b | off | = 11 | = 7 / 7 | med 159759 → 151576 (-5%) · ort 165042 → 151634 (-8%) | med 705024 → 601172 (-15%) · ort 718968 → 597928 (-17%) | med 258 → 249 (-3%) · ort 261 → 246 (-6%) | = 0 / 0 | med 13 = · ort 12 → 13 (+8%) |
| b2c | none | = 11 | = 7 / 7 | med 308148 → 19284 (-94%) ⚠ · ort 310555 → 25508 (-92%) ⚠ | med 2140789 → 269402 (-87%) ⚠ · ort 2025911 → 304473 (-85%) ⚠ | = 1 / 1 | med 42799 → 2678 (-94%) ⚠ · ort 43133 → 3543 (-92%) ⚠ | = 5 / 5 |
| b2c | worst | = 11 | = 7 / 7 | med 1396632 → 1613028 (+15%) · ort 1440878 → 1577520 (+9%) | med 4838469 → 5151443 (+6%) · ort 4961138 → 5188108 (+5%) | = 1 / 1 | med 193976 → 224031 (+15%) · ort 200122 → 219100 (+9%) | = 5 / 5 |
| b2c | due | = 11 | = 7 / 7 | med 1673808 → 1778544 (+6%) · ort 1611005 → 1821249 (+13%) | med 5315793 → 5597947 (+5%) · ort 5192846 → 5580212 (+7%) | = 1 / 1 | med 232474 → 247020 (+6%) · ort 223751 → 252951 (+13%) | med 6 → 5 (-17%) · ort 6 → 5 (-17%) |
| b2c | off | = 11 | = 7 / 7 | med 2211324 → 2151936 (-3%) · ort 2287593 → 2139113 (-6%) | med 6378479 → 6200629 (-3%) · ort 6710796 → 6183042 (-8%) | = 1 / 1 | med 307129 → 298880 (-3%) · ort 317721 → 297099 (-6%) | = 5 / 5 |

### K7b. Saat durması, Traction haftaları (`PROBE STATE phase=2`)

| pazar | kol | n | durma/hf (kart + sprint başlatma) | cevaplanan kart/hf | bunun istek kartı (`customer.request_feature`) | sprint başlatma/hf | 2 ve daha çok durmalı hafta oranı | bir haftada en çok durma |
|---|---|---|---|---|---|---|---|---|
| b2b | none | = 11 | med 2.55 → 2.68 (+5%) · ort 2.61 → 2.64 (+1%) | med 1.72 → 1.91 (+11%) · ort 1.76 → 1.88 (+7%) | med 1.04 → 1.02 (-2%) · ort 1.08 → 1.01 (-6%) | med 0.84 → 0.76 (-10%) · ort 0.85 → 0.76 (-11%) | med 0.766 → 0.782 (+2%) · ort 0.771 → 0.764 (-1%) | med 5 → 6 (+20%) · ort 5 → 6 (+20%) |
| b2b | worst | = 11 | med 2.52 → 2.45 (-3%) · ort 2.55 → 2.43 (-5%) | med 1.71 = · ort 1.73 → 1.71 (-1%) | med 1.07 → 1.03 (-4%) · ort 1.09 → 1.01 (-7%) | med 0.82 → 0.72 (-12%) · ort 0.81 → 0.72 (-11%) | med 0.761 → 0.74 (-3%) · ort 0.759 → 0.72 (-5%) | = 5 / 5 |
| b2b | due | = 11 | med 2.52 → 2.41 (-4%) · ort 2.51 → 2.42 (-4%) | med 1.74 → 1.7 (-2%) · ort 1.71 = | med 1.05 → 0.97 (-8%) · ort 1.07 → 0.97 (-9%) | med 0.79 → 0.71 (-10%) · ort 0.79 → 0.72 (-9%) | med 0.739 → 0.731 (-1%) · ort 0.739 → 0.731 (-1%) | = 5 / 5 |
| b2b | off | = 11 | med 2.49 → 2.47 (-1%) · ort 2.5 → 2.43 (-3%) | med 1.69 → 1.71 (+1%) · ort 1.69 → 1.7 (+1%) | med 1.08 → 1.03 (-5%) · ort 1.09 → 1.02 (-6%) | med 0.83 → 0.73 (-12%) · ort 0.81 → 0.73 (-10%) | med 0.745 → 0.747 (+0%) · ort 0.747 → 0.723 (-3%) | = 5 / 5 |
| b2c | none | = 11 | med 1.15 → 1.16 (+1%) · ort 1.14 → 1.17 (+3%) | med 0.42 → 0.39 (-7%) · ort 0.42 → 0.4 (-5%) | = 0.00 / 0.00 | med 0.72 → 0.77 (+7%) · ort 0.72 → 0.77 (+7%) | med 0.263 → 0.245 (-7%) · ort 0.261 → 0.254 (-3%) | = 3 / 3 |
| b2c | worst | = 11 | med 1.11 → 1.09 (-2%) · ort 1.1 → 1.08 (-2%) | med 0.42 = · ort 0.42 → 0.44 (+5%) | = 0.00 / 0.00 | med 0.68 → 0.64 (-6%) · ort 0.67 → 0.65 (-3%) | med 0.246 → 0.259 (+5%) · ort 0.245 → 0.24 (-2%) | = 3 / 3 |
| b2c | due | = 11 | med 1.07 → 1.09 (+2%) · ort 1.07 → 1.09 (+2%) | med 0.43 = · ort 0.42 → 0.43 (+2%) | = 0.00 / 0.00 | med 0.65 = · ort 0.64 → 0.65 (+2%) | med 0.218 → 0.241 (+11%) · ort 0.218 → 0.251 (+15%) | = 3 / 3 |
| b2c | off | = 11 | med 1.09 = · ort 1.08 → 1.09 (+1%) | med 0.43 → 0.44 (+2%) · ort 0.42 → 0.45 (+7%) | = 0.00 / 0.00 | med 0.67 → 0.65 (-3%) · ort 0.67 → 0.65 (-3%) | med 0.235 → 0.255 (+9%) · ort 0.236 = | = 3 / 3 |

### K8. A'nın §4.2 hedefleri (fix_due ve fix_worst; `fix_tables_fixed.py`, `bug_sprint` küçük harf okumasıyla)

| pazar | kol | dönem | düzeltme payı medyanı | hata sprinti oranı | üst üste iki hata sprinti oranı | n (pay) |
|---|---|---|---|---|---|---|
| b2b | fix_worst | erken | 0.125 → 0.167 (+34%) ⚠ | 0 → 0.182 (yeni) ⚠ | 0 → 0.082 (yeni) ⚠ | 125 → 121 (-3%) |
| b2b | fix_worst | geç | 0.051 → 0.061 (+20%) | = 0.000 | = 0.000 | 778 → 695 (-11%) |
| b2b | fix_due | erken | 0.037 → 0.122 (+230%) ⚠ | 0.06 → 0.164 (+173%) ⚠ | 0 → 0.048 (yeni) ⚠ | 117 → 116 (-1%) |
| b2b | fix_due | geç | 0.051 → 0.061 (+20%) | 0.001 → 0.006 (+500%) ⚠ | = 0.000 | 768 → 691 (-10%) |
| b2c | fix_worst | erken | 0.5 → 0.2 (-60%) ⚠ | 0.079 → 0.063 (-20%) | = 0.017 | 126 → 127 (+1%) |
| b2c | fix_worst | geç | 0.098 → 0.091 (-7%) | 0 → 0.003 (yeni) ⚠ | = 0.000 | 685 → 629 (-8%) |
| b2c | fix_due | erken | 0.333 → 0.113 (-66%) ⚠ | 0.252 → 0.161 (-36%) ⚠ | 0.107 → 0.044 (-59%) ⚠ | 123 → 124 (+1%) |
| b2c | fix_due | geç | 0.11 → 0.111 (+1%) | 0.016 → 0.036 (+125%) ⚠ | 0 → 0.003 (yeni) ⚠ | 640 → 610 (-5%) |

### K9. `_free` ikizleri (tohum 7 ve 11; n=2, medyan ve ortalama aynı iki sayıdan)

| pazar | kol | n | hata/koşu | açık hata, sprint sonu | acil durum/koşu | düzeltme payı | hata sprinti oranı | kâğıt gelen sprint (v1.0 sonrası) | erken kapanan | MVP haftası | MRR (hafta 103) | kasa (hafta 103) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2b | worst_free | = 2 | med 217 → 188 (-13%) · ort 217 → 188 (-13%) | med 7.5 → 7.8 (+4%) · ort 7.5 → 7.8 (+4%) | med 8.5 → 8 (-6%) · ort 8.5 → 8 (-6%) | med 0.057 → 0.068 (+19%) · ort 0.057 → 0.068 (+19%) | med 0 → 0.027 (yeni) ⚠ · ort 0 → 0.027 (yeni) ⚠ | med 0.054 → 0.1 (+85%) ⚠ · ort 0.054 → 0.1 (+85%) ⚠ | med 0.787 → 0.661 (-16%) · ort 0.787 → 0.661 (-16%) | = 7 / 7 | med 174238 → 172515 (-1%) · ort 174238 → 172515 (-1%) | med 816425 → 725363 (-11%) · ort 816425 → 725363 (-11%) |
| b2b | due_free | = 2 | med 220 → 176 (-20%) · ort 220 → 176 (-20%) | med 7 → 6.5 (-7%) · ort 7 → 6.5 (-7%) | med 7.5 → 8 (+7%) · ort 7.5 → 8 (+7%) | med 0.058 → 0.061 (+5%) · ort 0.058 → 0.061 (+5%) | med 0.006 → 0.027 (+350%) ⚠ · ort 0.006 → 0.027 (+350%) ⚠ | med 0.062 → 0.101 (+63%) ⚠ · ort 0.062 → 0.101 (+63%) ⚠ | med 0.751 → 0.654 (-13%) · ort 0.751 → 0.654 (-13%) | = 7 / 7 | med 203464 → 166523 (-18%) · ort 203464 → 166523 (-18%) | med 901458 → 681622 (-24%) · ort 901458 → 681622 (-24%) |
| b2b | off_free | = 2 | med 228 → 188 (-18%) · ort 228 → 188 (-18%) | med 7.5 → 7.8 (+4%) · ort 7.5 → 7.8 (+4%) | med 5.5 → 8 (+45%) ⚠ · ort 5.5 → 8 (+45%) ⚠ | med 0.057 → 0.068 (+19%) · ort 0.057 → 0.068 (+19%) | med 0 → 0.027 (yeni) ⚠ · ort 0 → 0.027 (yeni) ⚠ | med 0.062 → 0.093 (+50%) ⚠ · ort 0.062 → 0.093 (+50%) ⚠ | med 0.773 → 0.661 (-14%) · ort 0.773 → 0.661 (-14%) | = 7 / 7 | med 189456 → 169336 (-11%) · ort 189456 → 169336 (-11%) | med 869960 → 705384 (-19%) · ort 869960 → 705384 (-19%) |
| b2c | worst_free | = 2 | med 392 → 343 (-12%) · ort 392 → 343 (-12%) | med 15 → 9.2 (-39%) ⚠ · ort 15 → 9.2 (-39%) ⚠ | med 7 → 8 (+14%) · ort 7 → 8 (+14%) | med 0.112 → 0.1 (-11%) · ort 0.112 → 0.1 (-11%) | med 0.007 → 0.014 (+100%) ⚠ · ort 0.007 → 0.014 (+100%) ⚠ | med 0.11 → 0.071 (-35%) ⚠ · ort 0.11 → 0.071 (-35%) ⚠ | med 0.626 → 0.579 (-8%) · ort 0.626 → 0.579 (-8%) | = 7 / 7 | med 1255320 → 1397004 (+11%) · ort 1255320 → 1397004 (+11%) | med 4219958 → 5382556 (+28%) · ort 4219958 → 5382556 (+28%) |
| b2c | due_free | = 2 | med 484 → 357 (-26%) · ort 484 → 357 (-26%) | med 9.5 → 7.8 (-18%) · ort 9.5 → 7.8 (-18%) | med 6 → 8 (+33%) ⚠ · ort 6 → 8 (+33%) ⚠ | med 0.128 → 0.108 (-16%) · ort 0.128 → 0.108 (-16%) | med 0.08 → 0.045 (-44%) ⚠ · ort 0.08 → 0.045 (-44%) ⚠ | med 0.122 → 0.067 (-45%) ⚠ · ort 0.122 → 0.067 (-45%) ⚠ | med 0.569 → 0.525 (-8%) · ort 0.569 → 0.525 (-8%) | = 7 / 7 | med 1586916 → 1882368 (+19%) · ort 1586916 → 1882368 (+19%) | med 5249897 → 5664624 (+8%) · ort 5249897 → 5664624 (+8%) |
| b2c | off_free | = 2 | med 430 → 382 (-11%) · ort 430 → 382 (-11%) | med 15.5 → 11.5 (-26%) · ort 15.5 → 11.5 (-26%) | med 4 → 6 (+50%) ⚠ · ort 4 → 6 (+50%) ⚠ | med 0.103 → 0.113 (+10%) · ort 0.103 → 0.113 (+10%) | med 0.007 → 0.022 (+214%) ⚠ · ort 0.007 → 0.022 (+214%) ⚠ | med 0.08 → 0.117 (+46%) ⚠ · ort 0.08 → 0.117 (+46%) ⚠ | med 0.661 → 0.538 (-19%) · ort 0.661 → 0.538 (-19%) | = 7 / 7 | med 1744668 → 2239014 (+28%) · ort 1744668 → 2239014 (+28%) | med 5648820 → 6111746 (+8%) · ort 5648820 → 6111746 (+8%) |

### K10. Kitap fikstürleri: haftalık saat durması

| fikstür | hafta (Traction) | **durma/hf** (kart + sprint başlatma) | kart/hf | istek kartı/hf | sprint başlatma/hf | 2+ durmalı hafta | en çok durma/hafta | kesinti olan hafta | tüm FIRE olan hafta | acil durum | kâğıt | promise_due | kesintili sprint / kapanan sprint | PROBE STOP | hata/koşu | açık hata (sprint sonu medyanı) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2b_book20_s1 | 104 (101) | = **1.50** | = 0.51 | = 0.00 | = 0.98 | 0.446 → 0.455 (+2%) | = 3 | = 14 | 57 → 59 (+4%) | = 13 | = 1 | = 0 | = 14 / 100 | 0 → 1 (yeni) ⚠ | 111 → 93 (-16%) | = 1.0 |
| b2b_book330_s1 | 52 (50) | = **1.62** | = 0.64 | = 0.00 | = 0.98 | = 0.500 | = 4 | = 7 | 31 → 30 (-3%) | = 7 | = 0 | = 0 | = 7 / 51 | = 0 | 245 → 188 (-23%) | 5 → 6 (+20%) |

### K4b. Hiç gelmeyen kâğıtlar: D0b ve D son

- Kâğıt kimlikleri: D0b ağacında 44, D son ağacında 44. Yalnız D0b'de olan: yok. Yalnız D son'da olan: yok.
- D0b: 21 kart hiç gelmedi; D son: 18.
- D0b'de hiç gelmeyen, D son'da gelen: `product.sprint_pm_phone_too`, `product.sprint_pm_scope_grew`, `product.sprint_pm_spec_unclear`, `product.sprint_late`.
- D0b'de gelen, D son'da hiç gelmeyen: `product.sprint_founder_test_pile`.
- Her iki ölçümde de hiç gelmeyen: `product.sprint_design_color_blind`, `product.sprint_design_customer_colors`, `product.sprint_design_drawings_late`, `product.sprint_design_empty_state`, `product.sprint_design_empty_state_b2c`, `product.sprint_design_first_screen`, `product.sprint_design_gloves`, `product.sprint_design_notifications`, `product.sprint_pm_core_first`, `product.sprint_pm_phone_too_b2c`, `product.sprint_pm_renewal`, `product.sprint_pm_spec_unclear_b2c`, `product.sprint_pm_two_accounts`, `product.sprint_solo_signup_code`, `product.sprint_late_solo`, `product.sprint_test_stock_transfer`, `product.sprint_test_too_much`.
- Gelen kart 23 / 44 (D0b); Gelen kart 26 / 44 (D son).

### K8b. A'nın §4.2 hedefleri: PASS/MISS değişenler

D0b: 76 hedef, 9 MISS; D son: 76 hedef, 7 MISS.

| hedef | D0b | D son |
|---|---|---|
| fix_due b2b early haftada yeni hata (medyan) <= 1.5 | MISS 2.00 | PASS 1.00 |
| fix_worst b2c early düzeltme payı medyanı <= 30% | MISS 50.00 | PASS 20.00 |
| fix_due b2c early düzeltme payı medyanı <= 30% | MISS 33.30 | PASS 11.25 |
| fix_due b2b early hata sprinti oranı <= 15% | PASS 5.98 | MISS 16.38 |
| fix_worst b2b early üst üste iki hata sprinti oranı <= 1% | PASS 0.00 | MISS 8.18 |
| fix_due b2b early üst üste iki hata sprinti oranı <= 1% | PASS 0.00 | MISS 4.76 |
| fix_due b2c late üst üste iki hata sprinti oranı <= 0% | PASS 0.00 | MISS 0.33 |
| churn b2b tohum 3: fix_none kaybı >= 2 x fix_off | MISS 0.80 | PASS 4.17 |
| churn b2b tohum 4: fix_none kaybı >= 2 x fix_off | MISS 0.74 | PASS 1.95 |
| churn b2b tohum 8: fix_none kaybı >= 2 x fix_off | MISS 1.23 | PASS 3.77 |

Değişen hedef: 10. Her iki ölçümde MISS kalan: fix_due b2c early hata sprinti oranı <= 15%; fix_worst b2c early üst üste iki hata sprinti oranı <= 1%; fix_due b2c early üst üste iki hata sprinti oranı <= 1%.

### K11. `--sprint-probe` team=3

| koşu | alan | D0b | D son |
|---|---|---|---|
| testçisiz | eşleşme (tutan/toplam) | 190/198 | 164/172 |
| testçisiz | mvp_days | 3x1 | 3x1 |
| testçisiz | sprint | 50 | 43 |
| testçisiz | planlanan | 196 | 170 |
| testçisiz | biten | 181 | 158 |
| testçisiz | idle | 19 | 29 |
| testçisiz | limitler | ceiling:5,pool:45 | full:1,ceiling:2,pool:40 |
| testçisiz | kâğıt | 1 | 2 |
| testçisiz | kâğıtsız sprint | 49 | 41 |
| testçisiz | kâğıtsız oran | 0.98 | 0.95 |
| testçisiz | REPRED satırı | 7 | 16 |
| testçisiz | uyuşmazlık | 8, nedenler {'cause=team': 1, 'cause=team.burnout': 6, 'cause=product.sprint_design_first_screen': 1} | 8, nedenler {'cause=team': 1, 'cause=team.burnout': 5, 'cause=product.sprint_dev_old_phones': 2} |
| testçili | eşleşme (tutan/toplam) | 198/207 | 186/195 |
| testçili | mvp_days | 3x1 | 3x1 |
| testçili | sprint | 52 | 53 |
| testçili | planlanan | 205 | 193 |
| testçili | biten | 195 | 185 |
| testçili | idle | 52 | 56 |
| testçili | limitler | full:1,ceiling:2,pool:49 | full:2,pool:51 |
| testçili | kâğıt | 1 | 1 |
| testçili | kâğıtsız sprint | 51 | 52 |
| testçili | kâğıtsız oran | 0.98 | 0.98 |
| testçili | REPRED satırı | 9 | 9 |
| testçili | uyuşmazlık | 9, nedenler {'cause=team': 1, 'cause=team.burnout': 7, 'cause=product.sprint_dev_relogin': 1} | 9, nedenler {'cause=team': 2, 'cause=team.burnout': 7} |

### K12. `--tick-probe` (ms)

| koşu | ölçü | D0b | D son | fark |
|---|---|---|---|---|
| tick_team6_acc20 | saat adımı n | 39 | 39 | = |
| tick_team6_acc20 | saat adımı p50 | 3.07 | 3.19 | +4% |
| tick_team6_acc20 | saat adımı p95 | 4.07 | 3.95 | -3% |
| tick_team6_acc20 | saat adımı en çok | 4.07 | 4.81 | +18% |
| tick_team6_acc20 | saat sonrası kare en çok | 0.20 | 0.23 | +15% |
| tick_team6_acc20 | gece n | 3 | 3 | = |
| tick_team6_acc20 | gece en çok | 70.50 | 67.61 | -4% |
| tick_team6_acc20 | gece sonrası kare en çok | 0.22 | 0.27 | +23% |
| tick_team6_acc20 | ilk saat | 1.63 | 1.69 | +4% |
| tick_team6_acc20 | ilk gece | 43.79 | 57.31 | +31% ⚠ |
| tick_team6_acc20 | tutuşla biten adım sayısı | 2 | 2 | = |
| tick_team6_acc20 | 16 ms üstü kare | 5 | 5 | = |
| tick_team6_acc20 | kayıt karesi | 70.50 | 67.61 | -4% |
| tick_team6_acc20 | tutuşla biten adımlar (hafta:ms) | 3:210.9;5:215.5 | 3:174.7;5:194.0 | |
| tick_team50_acc330 | saat adımı n | 39 | 39 | = |
| tick_team50_acc330 | saat adımı p50 | 7.13 | 6.26 | -12% |
| tick_team50_acc330 | saat adımı p95 | 49.46 | 24.92 | -50% ⚠ |
| tick_team50_acc330 | saat adımı en çok | 82.14 | 30.82 | -62% ⚠ |
| tick_team50_acc330 | saat sonrası kare en çok | 0.57 | 3.00 | +426% ⚠ |
| tick_team50_acc330 | gece n | 0 | 0 | = |
| tick_team50_acc330 | gece en çok | -1.00 | -1.00 | = |
| tick_team50_acc330 | gece sonrası kare en çok | 0.00 | 0.00 | = |
| tick_team50_acc330 | ilk saat | 4.05 | 4.18 | +3% |
| tick_team50_acc330 | ilk gece | -1.00 | -1.00 | = |
| tick_team50_acc330 | tutuşla biten adım sayısı | 5 | 5 | = |
| tick_team50_acc330 | 16 ms üstü kare | 21 | 9 | -57% ⚠ |
| tick_team50_acc330 | kayıt karesi | -1.00 | -1.00 | = |
| tick_team50_acc330 | tutuşla biten adımlar (hafta:ms) | 2:624.0;3:1110.8;4:604.7;5:697.9;6:450.9 | 2:682.2;3:723.4;4:610.0;5:926.4;6:600.6 | |

## Ek: D son tabloları (gövde)

### Koşu envanteri

- Ana koşu: 88 dosya (iki pazar x dört kol x tohum 1..11); `_free` ikizleri: 12 dosya (tohum 7 ve 11).
- Her koşuda `PROBE END` sayısı: [1]; hata satırı (ERROR/SCRIPT ERROR/PROBE ERROR, 'resources still in use' hariç) toplamı: 0.
- Bitiş: {'running_on_fumes': 100}; bitiş haftası: {'104': 100}.
- Son `PROBE STATE` haftası: {'103': 100} (STATE hafta 1'den 103'e basılır; END 104'te basılır, 'Haftada 104' MRR ve kasa bu yüzden hafta 103'ün STATE'idir).

### 1. Hata hacmi ve açık hata (hücre: tohumlar arası medyan / ortalama)

**Ölçülen satır.** `PROBE BUGS new=` = o hafta canlı hatlara inen hata = `ProductState.open_bugs` farkı + düzeltme kartının o arada temizlediği hata (`run_probe.gd:_log_bugs`, D0b ile aynı satır ve aynı tanım). Koşu başına toplam, MVP'den (v1.0) önce satır basılmadığı için yalnız ürün canlıyken inenleri sayar. Hatanın girdiği yerler (`ProductState.add_bugs` çağrıları): kapanışta testten kaçan hata ve kâğıdın `leaks`'i (`SprintSystem._close` ve `_land_faulty`, kaçan hata başına 1, hat kartının hattı), olay ve kâğıt etkileri (`effects.gd`, `main.gd`) ve **Destek masasının doğruladığı kullanıcı bildirimi** (`support_system.gd:123`). Log hata başına kaynak yazmaz.

| pazar | kol | n | hata/koşu (PROBE BUGS new= toplamı) | hata/canlı hafta | canlı hafta | açık hata, sprint sonu (koşu medyanı) | açık hata, sürüm anı (koşu medyanı) |
|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 171 / 173 | 1.76 / 1.78 | 97 / 97 | 83.0 / 83.2 | 29.0 / 29.8 |
| b2b | worst | 11 | 175 / 177 | 1.80 / 1.82 | 97 / 97 | 8.0 / 7.7 | 6.0 / 5.5 |
| b2b | due | 11 | 174 / 174 | 1.79 / 1.80 | 97 / 97 | 7.0 / 6.7 | 4.0 / 4.4 |
| b2b | off | 11 | 175 / 175 | 1.80 / 1.81 | 97 / 97 | 7.5 / 7.5 | 5.0 / 5.5 |
| b2c | none | 11 | 115 / 116 | 1.19 / 1.20 | 97 / 97 | 61.0 / 61.4 | 31.0 / 31.5 |
| b2c | worst | 11 | 338 / 333 | 3.48 / 3.43 | 97 / 97 | 9.0 / 9.0 | 8.0 / 8.0 |
| b2c | due | 11 | 358 / 351 | 3.69 / 3.61 | 97 / 97 | 8.0 / 8.2 | 6.0 / 5.9 |
| b2c | off | 11 | 370 / 375 | 3.81 / 3.87 | 97 / 97 | 8.0 / 9.1 | 7.0 / 7.7 |

### 1b. Sürümden kaçan hata (`PROBE SHIP escaped=`)

Kayıt (`release.escaped`) sürümün testinden kaçan her hatanın hattıdır, hata başına bir satır (`SprintSystem._close`); `SHIP` satırı bu kayıt yazıldıktan sonra basılır. D0b'de bu alan `faulty` idi ve hattına hata yazılan KART sayısını sayıyordu; iki alan aynı birimde değildir (kart sayısı ve hata sayısı).

| pazar | kol | n | sürümde `escaped` toplamı | hata kaçan sürüm | toplam sürüm |
|---|---|---|---|---|---|
| b2b | none | 11 | 17 / 16 | 9 / 9 | 17 / 17 |
| b2b | worst | 11 | 15 / 16 | 9 / 9 | 71 / 71 |
| b2b | due | 11 | 15 / 16 | 9 / 10 | 57 / 56 |
| b2b | off | 11 | 14 / 16 | 10 / 9 | 72 / 71 |
| b2c | none | 11 | 20 / 20 | 10 / 11 | 22 / 22 |
| b2c | worst | 11 | 25 / 25 | 13 / 14 | 65 / 65 |
| b2c | due | 11 | 24 / 25 | 12 / 13 | 55 / 55 |
| b2c | off | 11 | 25 / 25 | 14 / 14 | 65 / 63 |

### 1c. Haftalık hata akışı, hafta türüne göre (88 ana koşu birleşik)

Hata hacminin kaynağını dolaylı gösterir: hafta türü değişince haftalık hata değişmiyorsa akış kapanıştan ve olaydan bağımsız, sürekli bir kaynaktan (Destek bildirimi) gelir. 'Olaylı' = o hafta acil durum, kâğıt ya da `promise_due` düştü.

| pazar | kapanış türü | olay | hafta sayısı | hata toplamı | hata/hafta |
|---|---|---|---|---|---|
| b2b | halka açık sürümlü kapanış | olaylı hafta | 201 | 595 | 2.96 |
| b2b | halka açık sürümlü kapanış | olaysız hafta | 2085 | 4220 | 2.02 |
| b2b | kapanışsız hafta | olaylı hafta | 378 | 384 | 1.02 |
| b2b | kapanışsız hafta | olaysız hafta | 609 | 785 | 1.29 |
| b2b | sürümsüz kapanış | olaylı hafta | 48 | 93 | 1.94 |
| b2b | sürümsüz kapanış | olaysız hafta | 947 | 1611 | 1.70 |
| b2c | halka açık sürümlü kapanış | olaylı hafta | 223 | 1036 | 4.65 |
| b2c | halka açık sürümlü kapanış | olaysız hafta | 1982 | 7644 | 3.86 |
| b2c | kapanışsız hafta | olaylı hafta | 315 | 822 | 2.61 |
| b2c | kapanışsız hafta | olaysız hafta | 909 | 2443 | 2.69 |
| b2c | sürümsüz kapanış | olaylı hafta | 56 | 86 | 1.54 |
| b2c | sürümsüz kapanış | olaysız hafta | 783 | 894 | 1.14 |

### 2. Acil durum sayısı ve sürüm sonrası bozulma

Acil durum = `analyze.EMERG`'in altı kimliği (`PROBE FIRE`). Sürüm sonrası bozulma = `product.incident_regression`; `IncidentSystem._regression_line` kapanan sürümün `escaped` listesinden hat okur.

| pazar | kol | n | acil durum/koşu | kesinti_b2b | kesinti_b2c | odeme | yorum_firtinasi | ay_kapanisi | surum_sonrasi_bozulma | launch_leak (B2C) |
|---|---|---|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 8.0 / 8.5 | 4.0 / 4.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.4 | 4.0 / 4.1 | 0.0 / 0.0 |
| b2b | worst | 11 | 7.0 / 7.5 | 3.0 / 3.2 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.2 | 4.0 / 4.2 | 0.0 / 0.0 |
| b2b | due | 11 | 8.0 / 8.4 | 3.0 / 2.9 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.2 | 5.0 / 5.3 | 0.0 / 0.0 |
| b2b | off | 11 | 8.0 / 7.5 | 2.0 / 2.4 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 5.0 / 5.1 | 0.0 / 0.0 |
| b2c | none | 11 | 8.0 / 7.8 | 0.0 / 0.0 | 2.0 / 2.5 | 1.0 / 1.6 | 2.0 / 1.7 | 0.0 / 0.0 | 2.0 / 2.0 | 1.0 / 1.0 |
| b2c | worst | 11 | 8.0 / 8.2 | 0.0 / 0.0 | 3.0 / 2.5 | 2.0 / 1.5 | 0.0 / 0.5 | 0.0 / 0.0 | 4.0 / 3.7 | 1.0 / 1.0 |
| b2c | due | 11 | 7.0 / 8.0 | 0.0 / 0.0 | 3.0 / 2.6 | 1.0 / 1.5 | 0.0 / 0.0 | 0.0 / 0.0 | 4.0 / 3.8 | 1.0 / 1.0 |
| b2c | off | 11 | 6.0 / 6.5 | 0.0 / 0.0 | 2.0 / 2.1 | 1.0 / 0.8 | 0.0 / 0.0 | 0.0 / 0.0 | 3.0 / 3.6 | 1.0 / 1.0 |

### 3. Düzeltme kartı payı

`share` = sprint başında düzeltme kartlarının kalan puanı / sprint kapasitesi (`PROBE FIX`). İkinci sütun `PROBE SPRINT shipped=` içindeki `fix:` kartlarının tüm teslim edilen kartlara oranı.

| pazar | kol | n | düzeltme payı, sprint başı (`share`, v1.0 sonrası, koşu medyanı) | düzeltme kartı / teslim edilen kart | hata sprinti oranı (pay > 0,5) |
|---|---|---|---|---|---|
| b2b | none | 11 | 0.000 / 0.000 | 0.000 / 0.000 | 0.000 / 0.000 |
| b2b | worst | 11 | 0.061 / 0.064 | 0.395 / 0.394 | 0.014 / 0.027 |
| b2b | due | 11 | 0.059 / 0.062 | 0.408 / 0.408 | 0.027 / 0.029 |
| b2b | off | 11 | 0.061 / 0.065 | 0.397 / 0.399 | 0.027 / 0.027 |
| b2c | none | 11 | 0.000 / 0.000 | 0.010 / 0.015 | 0.000 / 0.000 |
| b2c | worst | 11 | 0.113 / 0.110 | 0.380 / 0.385 | 0.000 / 0.014 |
| b2c | due | 11 | 0.112 / 0.112 | 0.507 / 0.505 | 0.059 / 0.057 |
| b2c | off | 11 | 0.113 / 0.116 | 0.382 / 0.383 | 0.029 / 0.027 |

### 4. Kâğıt gelen sprint oranı

Kâğıt = `data/events/cards/product/sprint_*.json` kimliklerinden biri (`PROBE FIRE`); bir sprint, kapanışından önceki kesintilerde en az bir kâğıt varsa 'kâğıt gelen'dir (`analyze.per_sprint` kuralı).

| pazar | kol | n | kâğıt gelen sprint oranı (tümü) | kâğıt gelen sprint oranı (v1.0 sonrası) | kâğıt/koşu | kapanan sprint/koşu |
|---|---|---|---|---|---|---|
| b2b | none | 11 | 0.075 / 0.084 | 0.077 / 0.086 | 6.0 / 6.6 | 80 / 80 |
| b2b | worst | 11 | 0.076 / 0.083 | 0.078 / 0.085 | 6.0 / 6.4 | 77 / 77 |
| b2b | due | 11 | 0.078 / 0.078 | 0.080 / 0.080 | 6.0 / 5.9 | 77 / 76 |
| b2b | off | 11 | 0.086 / 0.082 | 0.089 / 0.084 | 6.0 / 6.3 | 78 / 77 |
| b2c | none | 11 | 0.064 / 0.059 | 0.066 / 0.061 | 5.0 / 4.5 | 77 / 77 |
| b2c | worst | 11 | 0.088 / 0.082 | 0.091 / 0.084 | 6.0 / 5.8 | 70 / 71 |
| b2c | due | 11 | 0.100 / 0.093 | 0.103 / 0.096 | 7.0 / 6.5 | 69 / 69 |
| b2c | off | 11 | 0.096 / 0.101 | 0.099 / 0.104 | 7.0 / 7.0 | 70 / 70 |

### 4b. Hiç gelmeyen kâğıtlar (ana 88 koşu, 44 kart)

Gelen kart: 26 / 44. 'Pazar' kartın `guards.market` değeridir; tek pazarlık kart o pazarın 44 koşusunda, 'both' kart 88 koşuda hiç gelmediyse listelenir.

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
| product.sprint_founder_test_pile | no_tester | both | founder |
| product.sprint_pm_core_first | pm | b2c | product_manager |
| product.sprint_pm_phone_too_b2c | pm | b2c | product_manager |
| product.sprint_pm_renewal | pm | b2b | product_manager |
| product.sprint_pm_spec_unclear_b2c | pm | b2c | product_manager |
| product.sprint_pm_two_accounts | pm | b2b | product_manager |
| product.sprint_solo_signup_code | solo | b2c | founder |
| product.sprint_late_solo | system | both | founder |
| product.sprint_test_stock_transfer | tester | b2b | tester |
| product.sprint_test_too_much | tester | both | tester |

Hiç gelmeyen: 18 kart. En çok gelenler: product.sprint_dev_security_update=89, product.sprint_dev_shorter_path=82, product.sprint_solo_server_bill=55, product.sprint_dev_unasked_rewrite=49, product.sprint_untested_own_code=43

### 5. `promise_due` ve `sprint_late` sayısı

`promise_due` ve `sprint_late*` kartlarının `PROBE FIRE` sayısı (88 + 12 koşuda toplam 18 `promise_due`, 10 `sprint_late*`). `PROBE PROMISE` sütunları söz defteridir.

| pazar | kol | n | `promise_due` FIRE | `sprint_late*` FIRE | söz verildi (`PROMISE created`) | söz tutuldu (`resolved kept`) | söz tutulmadı (kept dışı) |
|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 0.0 / 0.3 | 0.0 / 0.3 | 11.0 / 12.6 | 11.0 / 12.5 | 0.0 / 0.2 |
| b2b | worst | 11 | 0.0 / 0.6 | 0.0 / 0.2 | 8.0 / 12.0 | 8.0 / 11.7 | 0.0 / 0.5 |
| b2b | due | 11 | 0.0 / 0.5 | 0.0 / 0.2 | 11.0 / 11.8 | 11.0 / 11.3 | 0.0 / 1.1 |
| b2b | off | 11 | 0.0 / 0.3 | 0.0 / 0.3 | 9.0 / 9.4 | 9.0 / 8.8 | 0.0 / 1.1 |
| b2c | none | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2c | worst | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2c | due | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |
| b2c | off | 11 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 | 0.0 / 0.0 |

### 6. Erken kapanan sprint oranı

Sprint 2 hafta sabittir; bütün kartlar biterse erken kapanır. Ölçü: `PROBE FIX` (başlangıç haftası) ile ardından gelen `PROBE SPRINT` (kapanış haftası) arasındaki fark, `weeks=` alanından kısaysa erken.

| pazar | kol | n | erken kapanan sprint oranı (tümü) | erken kapanan (v1.0 sonrası) | ortalama sprint uzunluğu (hafta) |
|---|---|---|---|---|---|
| b2b | none | 11 | 0.713 / 0.705 | 0.740 / 0.732 | 1.29 / 1.30 |
| b2b | worst | 11 | 0.662 / 0.665 | 0.689 / 0.692 | 1.34 / 1.34 |
| b2b | due | 11 | 0.662 / 0.649 | 0.689 / 0.676 | 1.34 / 1.35 |
| b2b | off | 11 | 0.679 / 0.662 | 0.707 / 0.689 | 1.32 / 1.34 |
| b2c | none | 11 | 0.662 / 0.664 | 0.689 / 0.691 | 1.34 / 1.34 |
| b2c | worst | 11 | 0.543 / 0.560 | 0.567 / 0.584 | 1.46 / 1.44 |
| b2c | due | 11 | 0.522 / 0.519 | 0.545 / 0.542 | 1.48 / 1.48 |
| b2c | off | 11 | 0.543 / 0.526 | 0.567 / 0.550 | 1.46 / 1.47 |

Kapanan sprintlerin uzunluk dağılımı (88 ana koşu, hafta: sayı): {1: 4097, 2: 2475}; erken kapanan toplam oran 62.3%.

### 7. MVP haftası, 104. haftada MRR ve kasa

Son `PROBE STATE` (hafta 103) alınır, bkz. envanter. `PROBE END` 104'te basılır ama MRR ve kasa taşımaz.

| pazar | kol | n | MVP haftası (v1.0) | MRR (hafta 103) | kasa (hafta 103) | B2B hesap | B2C kitle | çalışan |
|---|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 7 / 7 | 148890 / 147161 | 595780 / 560917 | 243 / 238 | 0 / 0 | 13 / 13 |
| b2b | worst | 11 | 7 / 7 | 152583 / 157813 | 590411 / 620960 | 253 / 250 | 0 / 0 | 13 / 13 |
| b2b | due | 11 | 7 / 7 | 153767 / 157230 | 591306 / 618934 | 248 / 245 | 0 / 0 | 13 / 13 |
| b2b | off | 11 | 7 / 7 | 151576 / 151634 | 601172 / 597928 | 249 / 246 | 0 / 0 | 13 / 13 |
| b2c | none | 11 | 7 / 7 | 19284 / 25508 | 269402 / 304473 | 1 / 1 | 2678 / 3543 | 5 / 5 |
| b2c | worst | 11 | 7 / 7 | 1613028 / 1577520 | 5151443 / 5188108 | 1 / 1 | 224031 / 219100 | 5 / 5 |
| b2c | due | 11 | 7 / 7 | 1778544 / 1821249 | 5597947 / 5580212 | 1 / 1 | 247020 / 252951 | 5 / 5 |
| b2c | off | 11 | 7 / 7 | 2151936 / 2139113 | 6200629 / 6183042 | 1 / 1 | 298880 / 297099 | 5 / 5 |

### 7b. Saat durması, Traction haftaları (`PROBE STATE phase=2`)

R15'in tanımı: durma = cevaplanan karar ya da tek düğmeli kart (`PROBE PICK`) + sprint başlatma (`PROBE FIX`). Mail ve not saati durdurmaz. R15'in B2B Traction sayısı 1,72'dir (karar 0,82 + tek düğmeli 0,16 + sprint başlatma 0,74); R15'in betiği klasörde yok ve bu tablo onu birebir yeniden üretmez: burada istek kartı (`customer.request_feature`, B2B'de haftada yaklaşık 1) dahil 2,5, çıkarılınca 1,4 ile 1,5 olur. R15'in istek kartını saydığı belgesinde yazılı değil; iki okuma da yan yana verilir.

| pazar | kol | n | durma/hf (kart + sprint başlatma) | cevaplanan kart/hf | bunun istek kartı (`customer.request_feature`) | sprint başlatma/hf | 2 ve daha çok durmalı hafta oranı | bir haftada en çok durma |
|---|---|---|---|---|---|---|---|---|
| b2b | none | 11 | 2.68 / 2.64 | 1.91 / 1.88 | 1.02 / 1.01 | 0.76 / 0.76 | 0.782 / 0.764 | 6 / 6 |
| b2b | worst | 11 | 2.45 / 2.43 | 1.71 / 1.71 | 1.03 / 1.01 | 0.72 / 0.72 | 0.740 / 0.720 | 5 / 5 |
| b2b | due | 11 | 2.41 / 2.42 | 1.70 / 1.71 | 0.97 / 0.97 | 0.71 / 0.72 | 0.731 / 0.731 | 5 / 5 |
| b2b | off | 11 | 2.47 / 2.43 | 1.71 / 1.70 | 1.03 / 1.02 | 0.73 / 0.73 | 0.747 / 0.723 | 5 / 5 |
| b2c | none | 11 | 1.16 / 1.17 | 0.39 / 0.40 | 0.00 / 0.00 | 0.77 / 0.77 | 0.245 / 0.254 | 3 / 3 |
| b2c | worst | 11 | 1.09 / 1.08 | 0.42 / 0.44 | 0.00 / 0.00 | 0.64 / 0.65 | 0.259 / 0.240 | 3 / 3 |
| b2c | due | 11 | 1.09 / 1.09 | 0.43 / 0.43 | 0.00 / 0.00 | 0.65 / 0.65 | 0.241 / 0.251 | 3 / 3 |
| b2c | off | 11 | 1.09 / 1.09 | 0.44 / 0.45 | 0.00 / 0.00 | 0.65 / 0.65 | 0.255 / 0.236 | 3 / 3 |

### 8. A'nın §4.2 hedefleri (fix_due ve fix_worst; `fix_tables_fixed.py`, `bug_sprint` küçük harf okumasıyla)

Havuz: 11 tohum birleşik, dönem 'erken' = v1.0'dan sonraki ilk 20 hafta, 'geç' = sonrası. Hücre: medyan (pay/açık hata) ya da ortalama (oran).

| pazar | kol | dönem | düzeltme payı medyanı | hata sprinti oranı | üst üste iki hata sprinti oranı | n (pay) |
|---|---|---|---|---|---|---|
| b2b | fix_worst | erken | 0.167 | 0.182 | 0.082 | 121 |
| b2b | fix_worst | geç | 0.061 | 0.000 | 0.000 | 695 |
| b2b | fix_due | erken | 0.122 | 0.164 | 0.048 | 116 |
| b2b | fix_due | geç | 0.061 | 0.006 | 0.000 | 691 |
| b2c | fix_worst | erken | 0.200 | 0.063 | 0.017 | 127 |
| b2c | fix_worst | geç | 0.091 | 0.003 | 0.000 | 629 |
| b2c | fix_due | erken | 0.113 | 0.161 | 0.044 | 124 |
| b2c | fix_due | geç | 0.111 | 0.036 | 0.003 | 610 |

A'nın hedef karşılaştırmaları (`fix_tables_fixed.targets`, eşikler betiğin içindeki E1 §9 sayıları; tam çıktı `D_SON_a42_tablolar.txt`):

```
PASS fix_due b2b early haftada yeni hata (medyan) <= 1.5                                              1.00  n=220
PASS fix_due b2b early açık hata, sürüm anında (medyan) <= 4                                          3.00  n=73
PASS fix_due b2b early açık hata, sprint sonu (medyan) <= 8                                           4.00  n=116
PASS fix_due b2b late haftada yeni hata (medyan) <= 4                                                 2.00  n=847
PASS fix_due b2b late açık hata, sürüm anında (medyan) <= 8                                           4.00  n=546
PASS fix_due b2b late açık hata, sprint sonu (medyan) <= 16                                           7.00  n=691
PASS fix_due b2c early haftada yeni hata (medyan) <= 1.5                                              1.00  n=220
PASS fix_due b2c early açık hata, sürüm anında (medyan) <= 4                                          3.00  n=87
PASS fix_due b2c early açık hata, sprint sonu (medyan) <= 8                                           4.00  n=124
PASS fix_due b2c late haftada yeni hata (medyan) <= 3                                                 3.00  n=847
PASS fix_due b2c late açık hata, sürüm anında (medyan) <= 8                                           6.00  n=523
PASS fix_due b2c late açık hata, sprint sonu (medyan) <= 16                                           9.00  n=610
PASS fix_worst b2b late düzeltme payı medyanı <= 15%                                                  6.10  n=695
PASS fix_worst b2b early düzeltme payı medyanı <= 30%                                                16.70  n=121
PASS fix_worst b2c late düzeltme payı medyanı <= 15%                                                  9.10  n=629
PASS fix_worst b2c early düzeltme payı medyanı <= 30%                                                20.00  n=127
PASS fix_due b2b late düzeltme payı medyanı <= 20%                                                    6.10  n=691
PASS fix_due b2b early düzeltme payı medyanı <= 30%                                                  12.25  n=116
PASS fix_due b2c late düzeltme payı medyanı <= 20%                                                   11.10  n=610
PASS fix_due b2c early düzeltme payı medyanı <= 30%                                                  11.25  n=124
PASS fix_due b2b late hata sprinti oranı <= 5%                                                        0.58  n=691
MISS fix_due b2b early hata sprinti oranı <= 15%                                                     16.38  n=116
PASS fix_due b2c late hata sprinti oranı <= 5%                                                        3.61  n=610
MISS fix_due b2c early hata sprinti oranı <= 15%                                                     16.13  n=124
PASS fix_worst b2b late üst üste iki hata sprinti oranı <= 0%                                         0.00  n=695
MISS fix_worst b2b early üst üste iki hata sprinti oranı <= 1%                                        8.18  n=110
PASS fix_worst b2c late üst üste iki hata sprinti oranı <= 0%                                         0.00  n=629
MISS fix_worst b2c early üst üste iki hata sprinti oranı <= 1%                                        1.72  n=116
PASS fix_due b2b late üst üste iki hata sprinti oranı <= 0%                                           0.00  n=691
MISS fix_due b2b early üst üste iki hata sprinti oranı <= 1%                                          4.76  n=105
MISS fix_due b2c late üst üste iki hata sprinti oranı <= 0%                                           0.33  n=610
MISS fix_due b2c early üst üste iki hata sprinti oranı <= 1%                                          4.42  n=113
PASS churn b2b tohum 1: fix_worst kaybı <= fix_off + 10 puan                                         -0.00  worst 0.44% off 0.44%
PASS churn b2b tohum 1: fix_none kaybı >= 2 x fix_off                                                 4.93  none 4.93% off 0.44%
PASS churn b2b tohum 2: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.00% off 0.00%
PASS churn b2b tohum 2: fix_none kaybı >= 2 x fix_off                                                 2.92  none 2.92% off 0.00%
PASS churn b2b tohum 3: fix_worst kaybı <= fix_off + 10 puan                                         -1.70  worst 0.00% off 1.70%
PASS churn b2b tohum 3: fix_none kaybı >= 2 x fix_off                                                 4.17  none 4.17% off 1.70%
PASS churn b2b tohum 4: fix_worst kaybı <= fix_off + 10 puan                                         -0.01  worst 0.37% off 0.38%
PASS churn b2b tohum 4: fix_none kaybı >= 2 x fix_off                                                 1.95  none 1.95% off 0.38%
PASS churn b2b tohum 5: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.40% off 0.40%
PASS churn b2b tohum 5: fix_none kaybı >= 2 x fix_off                                                 2.41  none 2.41% off 0.40%
PASS churn b2b tohum 6: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.86% off 0.86%
PASS churn b2b tohum 6: fix_none kaybı >= 2 x fix_off                                                 3.00  none 3.00% off 0.86%
PASS churn b2b tohum 7: fix_worst kaybı <= fix_off + 10 puan                                         -0.01  worst 0.38% off 0.39%
PASS churn b2b tohum 7: fix_none kaybı >= 2 x fix_off                                                 1.16  none 1.16% off 0.39%
PASS churn b2b tohum 8: fix_worst kaybı <= fix_off + 10 puan                                          0.41  worst 0.85% off 0.44%
PASS churn b2b tohum 8: fix_none kaybı >= 2 x fix_off                                                 3.77  none 3.77% off 0.44%
PASS churn b2b tohum 9: fix_worst kaybı <= fix_off + 10 puan                                          0.00  worst 0.00% off 0.00%
PASS churn b2b tohum 9: fix_none kaybı >= 2 x fix_off                                                 1.59  none 1.59% off 0.00%
PASS churn b2b tohum 10: fix_worst kaybı <= fix_off + 10 puan                                         0.00  worst 0.76% off 0.76%
PASS churn b2b tohum 10: fix_none kaybı >= 2 x fix_off                                                4.69  none 4.69% off 0.76%
PASS churn b2b tohum 11: fix_worst kaybı <= fix_off + 10 puan                                         0.00  worst 0.37% off 0.37%
PASS churn b2b tohum 11: fix_none kaybı >= 2 x fix_off                                                1.55  none 1.55% off 0.37%
PASS churn b2c tohum 1: fix_worst kaybı <= fix_off + 10 puan                                          6.10  worst 6.10% off 0.00%
PASS churn b2c tohum 1: fix_none kaybı >= 2 x fix_off                                                39.45  none 39.45% off 0.00%
PASS churn b2c tohum 2: fix_worst kaybı <= fix_off + 10 puan                                          7.87  worst 7.87% off 0.00%
PASS churn b2c tohum 2: fix_none kaybı >= 2 x fix_off                                                39.50  none 39.50% off 0.00%
PASS churn b2c tohum 3: fix_worst kaybı <= fix_off + 10 puan                                          7.48  worst 7.48% off 0.00%
PASS churn b2c tohum 3: fix_none kaybı >= 2 x fix_off                                                47.33  none 47.33% off 0.00%
PASS churn b2c tohum 4: fix_worst kaybı <= fix_off + 10 puan                                          6.45  worst 6.45% off 0.00%
PASS churn b2c tohum 4: fix_none kaybı >= 2 x fix_off                                                52.69  none 52.69% off 0.00%
PASS churn b2c tohum 5: fix_worst kaybı <= fix_off + 10 puan                                          7.69  worst 7.69% off 0.00%
PASS churn b2c tohum 5: fix_none kaybı >= 2 x fix_off                                                49.39  none 49.39% off 0.00%
PASS churn b2c tohum 6: fix_worst kaybı <= fix_off + 10 puan                                          7.54  worst 7.54% off 0.00%
PASS churn b2c tohum 6: fix_none kaybı >= 2 x fix_off                                                51.16  none 51.16% off 0.00%
PASS churn b2c tohum 7: fix_worst kaybı <= fix_off + 10 puan                                          5.97  worst 5.97% off 0.00%
PASS churn b2c tohum 7: fix_none kaybı >= 2 x fix_off                                                25.72  none 25.72% off 0.00%
PASS churn b2c tohum 8: fix_worst kaybı <= fix_off + 10 puan                                          7.47  worst 7.47% off 0.00%
PASS churn b2c tohum 8: fix_none kaybı >= 2 x fix_off                                                53.56  none 53.56% off 0.00%
PASS churn b2c tohum 9: fix_worst kaybı <= fix_off + 10 puan                                          6.91  worst 6.91% off 0.00%
PASS churn b2c tohum 9: fix_none kaybı >= 2 x fix_off                                                36.89  none 36.89% off 0.00%
PASS churn b2c tohum 10: fix_worst kaybı <= fix_off + 10 puan                                         7.98  worst 7.98% off 0.00%
PASS churn b2c tohum 10: fix_none kaybı >= 2 x fix_off                                               47.40  none 47.40% off 0.00%
PASS churn b2c tohum 11: fix_worst kaybı <= fix_off + 10 puan                                         8.44  worst 8.44% off 0.00%
PASS churn b2c tohum 11: fix_none kaybı >= 2 x fix_off                                               54.01  none 54.01% off 0.00%
ÖZET: 76 hedef, 7 MISS
```

### 9. `_free` ikizleri (tohum 7 ve 11; n=2, medyan ve ortalama aynı iki sayıdan)

`_free` kolları sprinti acil durum cevabında hiç durdurmaz.

| pazar | kol | n | hata/koşu | açık hata, sprint sonu | acil durum/koşu | düzeltme payı | hata sprinti oranı | kâğıt gelen sprint (v1.0 sonrası) | erken kapanan | MVP haftası | MRR (hafta 103) | kasa (hafta 103) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2b | worst_free | 2 | 188 / 188 | 7.8 / 7.8 | 8.0 / 8.0 | 0.068 / 0.068 | 0.027 / 0.027 | 0.100 / 0.100 | 0.661 / 0.661 | 7 / 7 | 172515 / 172515 | 725363 / 725363 |
| b2b | due_free | 2 | 176 / 176 | 6.5 / 6.5 | 8.0 / 8.0 | 0.061 / 0.061 | 0.027 / 0.027 | 0.101 / 0.101 | 0.654 / 0.654 | 7 / 7 | 166523 / 166523 | 681622 / 681622 |
| b2b | off_free | 2 | 188 / 188 | 7.8 / 7.8 | 8.0 / 8.0 | 0.068 / 0.068 | 0.027 / 0.027 | 0.093 / 0.093 | 0.661 / 0.661 | 7 / 7 | 169336 / 169336 | 705384 / 705384 |
| b2c | worst_free | 2 | 343 / 343 | 9.2 / 9.2 | 8.0 / 8.0 | 0.100 / 0.100 | 0.014 / 0.014 | 0.071 / 0.071 | 0.579 / 0.579 | 7 / 7 | 1397004 / 1397004 | 5382556 / 5382556 |
| b2c | due_free | 2 | 357 / 357 | 7.8 / 7.8 | 8.0 / 8.0 | 0.108 / 0.108 | 0.045 / 0.045 | 0.067 / 0.067 | 0.525 / 0.525 | 7 / 7 | 1882368 / 1882368 | 5664624 / 5664624 |
| b2c | off_free | 2 | 382 / 382 | 11.5 / 11.5 | 6.0 / 6.0 | 0.113 / 0.113 | 0.022 / 0.022 | 0.117 / 0.117 | 0.538 / 0.538 | 7 / 7 | 2239014 / 2239014 | 6111746 / 6111746 |

### 10. Kitap fikstürleri: haftalık saat durması

`b2b_book20` (20 hesap, 6 kişi, 104 hafta) ve `b2b_book330` (330 hesap, 50 kişi, 52 hafta). Bu presetler `fix` kolu olmadığı için `PROBE STOP` basmaz (iki logda da 0). Haftalık durma, 7b'deki tanımla okunur (cevaplanan kart + sprint başlatma, Traction haftaları; iki fikstür de 2. haftadan sonra hep Traction'dadır). Kesinti sütunları: acil durum + kâğıt + `promise_due` (`analyze.KINDS` kuralı) hangi haftalarda ve kaç sprintte düştü; ayrıca o haftaki tüm `PROBE FIRE` (WEEK fires=).

| fikstür | hafta (Traction) | **durma/hf** (kart + sprint başlatma) | kart/hf | istek kartı/hf | sprint başlatma/hf | 2+ durmalı hafta | en çok durma/hafta | kesinti olan hafta | tüm FIRE olan hafta | acil durum | kâğıt | promise_due | kesintili sprint / kapanan sprint | PROBE STOP | hata/koşu | açık hata (sprint sonu medyanı) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| b2b_book20_s1 | 104 (101) | **1.50** | 0.51 | 0.00 | 0.98 | 0.455 | 3 | 14 | 59 | 13 | 1 | 0 | 14 / 100 | 1 | 93 | 1.0 |
| b2b_book330_s1 | 52 (50) | **1.62** | 0.64 | 0.00 | 0.98 | 0.500 | 4 | 7 | 30 | 7 | 0 | 0 | 7 / 51 | 0 | 188 | 6.0 |

### 11. `--sprint-probe` team=3 (hours=40, cards=2, ticks=60, fill=1, events=1; tohum 424242)

**testçisiz**: `SUMMARY|match=164/172|mvp_days=3x1`, `LOADSUM|team=3|weeks=2|sprints=43|planned=170|finished=158|idle=29|limits=full:1,ceiling:2,pool:40`, `PAPERSUM|weeks=2|sprints=43|papers=2|empty=41|empty_rate=0.95`; REPRED satırı: 16; SKIP: {'full': 1, 'ceiling': 2}.
Uyuşmazlık: 8, hepsi adlı (`cause=` var: evet). Liste (sprint | kart | teslim 1/0 | devreden-bitmiş | neden):

| sprint | kart | teslim | kalan | neden |
|---|---|---|---|---|
| 2 | feat:line_note_tool_linking_k2 | 0 | 9.95 | cause=team |
| 3 | fix:line_note_tool_editor | 0 | 2.88 | cause=team.burnout |
| 3 | feat:line_note_tool_sync_k2 | 0 | 17.96 | cause=team.burnout |
| 3 | feat:line_shared_mobile_k2@note_tool | 0 | 8.96 | cause=team.burnout |
| 3 | res:onboarding | 0 | 0.00 | cause=team.burnout |
| 3 | feat:line_shared_integrations_k2@note_tool | 0 | 0.00 | cause=team.burnout |
| 4 | feat:line_shared_durability_k1@note_tool | 0 | 20.32 | cause=product.sprint_dev_old_phones |
| 4 | feat:line_shared_security_k1@note_tool | 0 | 2.00 | cause=product.sprint_dev_old_phones |

Neden dağılımı: {'cause=team': 1, 'cause=team.burnout': 5, 'cause=product.sprint_dev_old_phones': 2}

**testçili (`plus=tester@3`)**: `SUMMARY|match=186/195|mvp_days=3x1`, `LOADSUM|team=3|weeks=2|sprints=53|planned=193|finished=185|idle=56|limits=full:2,pool:51`, `PAPERSUM|weeks=2|sprints=53|papers=1|empty=52|empty_rate=0.98`; REPRED satırı: 9; SKIP: {'full': 2}.
Uyuşmazlık: 9, hepsi adlı (`cause=` var: evet). Liste (sprint | kart | teslim 1/0 | devreden-bitmiş | neden):

| sprint | kart | teslim | kalan | neden |
|---|---|---|---|---|
| 2 | feat:line_note_tool_sync_k2 | 0 | 7.30 | cause=team |
| 2 | feat:line_shared_mobile_k2@note_tool | 0 | 8.08 | cause=team |
| 3 | feat:line_note_tool_sync_k2 | 0 | 16.11 | cause=team.burnout |
| 3 | feat:line_shared_integrations_k2@note_tool | 1 | - | cause=team.burnout |
| 3 | fix:line_shared_security@note_tool | 0 | 0.11 | cause=team.burnout |
| 3 | feat:line_shared_durability_k2@note_tool | 0 | 0.00 | cause=team.burnout |
| 3 | feat:line_shared_security_k2@note_tool | 0 | 0.00 | cause=team.burnout |
| 3 | plan:cap_paid_plan | 0 | 0.00 | cause=team.burnout |
| 3 | res:revenue | 0 | 0.00 | cause=team.burnout |

Neden dağılımı: {'cause=team': 2, 'cause=team.burnout': 7}

### 12. `--tick-probe` (gece ve kare süreleri, ms)

`TICK|stopped` = saat ya da gece adımı bir tutuşla (saat durduran karar) bitti; o adımlar `hour` ve `night` istatistiğine girmez ve yanında hafta:ms yazar. `over16` = 16 ms'yi aşan kare sayısı.

| koşu | hour n/p50/p95/max | after_hour max | night n/max | each | after_night max | first_hour | first_night | stopped (hafta:ms) | topbar/gece | save kare | over16 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| team=6, 20 hesap | 39/3.19/3.95/4.81 | 0.23 | 3/67.61 | 2:57.3;4:55.8;6:67.6 | 0.27 | 1.69 | 57.31 | 3:174.7;5:194.0 (n=2) | 1 | 67.61 (async=1) | 5 |
| team=50, 330 hesap | 39/6.26/24.92/30.82 | 3.00 | 0/-1.00 | - | 0.00 | 4.18 | -1.00 | 2:682.2;3:723.4;4:610.0;5:926.4;6:600.6 (n=5) | 0 | -1.00 (async=0) | 9 |
