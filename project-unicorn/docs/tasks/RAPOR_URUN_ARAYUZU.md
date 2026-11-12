# Rapor: Ürün arayüzü (URUN_ARAYUZU), dizüstü turu ve 2026-11-11 kararları

Oturum `project-unicorn-36` (`15e4f65e-5e2f-4650-8a09-3461c49bb834`). Görev yazıları: `GOREV_DIZUSTU_URUN_2026-10-28.md` (Mac, D0–D8) ve
`GOREV_URUN_2026-11-11.md` (masaüstü, U-1–U-7). Adresler: yardımcı yönetmen `co-director`; OLAYLAR `project-unicorn-03`; ARAYUZ `project-unicorn-07`;
DUZELTME `project-unicorn-8e`. Push yok; her commit `main`'e ORTAK §3 yöntemiyle (özel index, üç yollu birleştirme, karşılaştırmalı update-ref).

## Özet

| Adım | Ne | Durum | Commit | Kanıt |
|---|---|---|---|---|
| D0 | Mac kurulum, Z6 ve PLANMS tabanı | ✅ | yok | Z6 f06bed6 7/7; Mac PLANMS medyan 61,4 ms (yalnız Mac) |
| D1 | E5 kareleri (plandaki istek) | ✅ | yok | kareler Erdem'e gitti; biçim seçimi U-1'e kaldı |
| D2 | UK(a): koşan sprintte durum yuvası | ✅ | `eebf909` | smoke 56/56, Z6 7/7 |
| D3 | UE1: Ürün penceresi 1688×928 | ✅ | `820ba5f` | Mac'te hazırlandı, masaüstünde yardımcı yönetmen yeniden kurdu |
| D5 | UM1: Yardım Merkezi | ✅ | `a243eba` | aynı |
| D4a | U7: statik fikstür emekli | ✅ | `435fb3b` | aynı |
| D4b | U7: E2 kesme taraması | ✅ | `d074f9b` | aynı |
| D6 | E4 ikonlar, E5 biçimi | ⚠️ | U-2'de | ikonlar U-2'de kodlandı; E5 Erdem'de (U-1) |
| D7 | U8 görsel kabul sayfası | ✅ | yok | `docs/tasks/dizustu/raporlar/u8_gorsel_kabul/` |
| U-1 | E5 plandaki istek biçimi | ⚠️ | yok | Erdem N02'yi cevapladı; gerçek adlarla kareler sırada, sonra kod |
| U-2 | Modül ikonları (UE2) | ✅ | `9c3d7289` | kareler a4_eleven TR/EN/1,25, b2b_requests, b2c_live |
| U-3 | Dar aşama çubuğunda sayı dışarıda | ✅ | `79a757ab` | a4_eleven 4/4, a4_two_pm 2/2 sayı görünür |
| U-4 | Hat adları (UM2) | ✅ | `c8bfe5f4` | Destek raporu TR/EN |
| U-5 | "+" ilk tıkta ekler (H09) | ✅ | `486e37a2` | gerçek girdi olaylarıyla 12/12 |
| U-6 | Plan ekranında Ar-Ge göstergesi (H06) | ✅ | `69fcca9c` | Erdem A seçti; a4_waiting TR/EN, a4_waiting_tip TR/EN, a4_waiting_all |
| ek | Son tarih çipi büyük harf (Erdem 2026-11-12), U-6 satırına hover | ✅ | `314aae33` | a4_requests TR/EN, a4_waiting_tip, a4_eleven_tip |
| O-4 | Sprint kâğıdı mekanizması (OLAYLAR'ın isteği) | ✅ | `6fd69c49` | 100 smoke vakası; probe team=12 kâğıtlı sprint 8/191 → 46/148 |
| U-7 | Sessiz PLANMS ve bu rapor | ✅ (oranla) | bu commit | aynı yükte HEAD/taban 1,068 (kapı 1,10); temiz mutlak ölçüm bekliyor |

## Mac turu (2026-10-28) ve kayıp

- D2 (`eebf909`) Mac'te commit'lendi. D3, D5, D4a ve D4b Mac kopyalarında hazırdı, kapıları ve Opus incelemeleri geçmişti; iCloud `.git` paketini
  boşaltınca git yazımı durdu. 2026-11-02'de macOS'un /tmp temizliği scratchpad'i sildi; ayrıntı ve kurtarma `GOREV_URUN_ARAYUZU_DEVAM.md` ve
  `docs/tasks/urun_arayuzu_devir/masaustu_2026-11-02/`'de. Yardımcı yönetmen dört adımı masaüstünde oturum kaydından yeniden kurdu (`820ba5f`,
  `a243eba`, `435fb3b`, `d074f9b`); okudum, dosya listeleri ve inceleme düzeltmeleri Mac'teki hâlle aynı.
- D7: U8 sayfası (https://claude.ai/artifact/Wqm2PqBZQXcuGjJzyotNvz) ve kaynakları `docs/tasks/dizustu/raporlar/u8_gorsel_kabul/`'de; 56 kare, 24 maket.
- D8 Mac'te yapılmadı; U-7 olarak masaüstünde.
- Ders: çalışma kopyaları artık `C:\Users\erdem\pu_calisma\urun_arayuzu\` altında (Temp değil).

## E2 kesme taraması (D4b, `d074f9b`)

| Yer | Önce | Sonra |
|---|---|---|
| Pano kart adı | iki satırdan sonra "…" | kelime sınırında sarar, satır büyür |
| Düzeltme kartı satırı | "5 hata · 2 hesap · 24 kullanıcı" (en büyük hesap ipucunda) | tam metin, en büyük hesap dahil, sarar |
| Sol sütun aday düzeltme kartı | "{n} hata" | aynı tam metin |
| Aday damgası | "S3" | "Sprint 3" |
| Sonraki sprint kutusu | uzun ad "…"; yüz hücresi kırpılır, "+{n}" gizlenir | ad sarar; ilk yüz kırpılmaz, "+{n}" her zaman görünür |
| ÇEYREK mini kart | ad kesilir ("Spreadshe / et Import") | ad kendi satırında sarar; sütunlar dikey kayar |
| Sürüm notu orta sütun | uzun içerik kesilir | dikey kayar |
| Bilerek kalanlar | modül kısa adı; "+{n}" biçimleri (Erdem K13: kalır); grafik kırpmaları | |

## Masaüstü adımları (2026-11-11)

- **S0.** Kopya `cb3185b4`; import ve ısınma temiz. Sessiz PLANMS tabanı (team=50, cards=13, 5 koşu, hepsi kirlenmemiş): ekran medyanları 83,754 /
  87,245 / 81,259 / 80,692 / 81,109 ms → **taban 81,259 ms**, kapı ≤ 89,4 ms.
- **U-2 (`9c3d7289`).** İki harfli işaretler (ÇK, İK, EN, GÜ, BÜ, GE) yerine küp, açık kapı, yapboz, kalkan, filiz, kredi kartı. Çekirdek ve Güven setin
  `rail/product.svg` ve `util/shield.svg`'sini okur (DUZELTME Lucide geçişinde onları `box` ve `shield` yapacak, şekil kalır); öbür dördü
  `assets/icons/product/area_*.svg` (OLAYLAR'ın aday dosyaları, `fill2.py` stroke 2.2). Silinen: 6 `PRODUCT_AREA_*_MONO`, `MonoMark`, `_mono`;
  `HRUiShared.D_mono` → `D_mono_box` (DUZELTME onayıyla). THEME_STAMP 47. Opus 6 bulgu, tek turda uygulandı.
- **U-3 (`79a757ab`).** Dar çubukta sayı çubuğun hemen sağında, eksenin içinde; yer yoksa düşer. 1920: a4_eleven 4/4, a4_two_pm 2/2; 1,25'te a4_two_pm'de
  1 çubuk düşer. Opus 7 bulgu (üst üste binen çubuk, bekleme çizgisi), tek turda 6'sı uygulandı.
- **U-4 (`c8bfe5f4`).** Veri Girişi → Satın Alma / Purchasing, Defter → Muhasebe / Accounting, EN Stock → Inventory. Opus'un dört metin notu Erdem'in
  sayfasında (T06): Satın Alma hattının K1/K2 adımları veri girişi anlatıyor; RND_NOTE_DEMAND_B2B_3 tekrarı; PROD_TYPE_ERP_DESC EN; sözlük satırı.
- **U-5 (`486e37a2`).** Kök: her kurulumda "+" değerleri kare başına bütçeyle hesaplanıyor, sırası gelmemiş "+" tıkı geçiriyordu. Düzeltmeden önce soğuk
  "+"a 4 tık yolunun 3'ü düşüyordu, sonra 12/12 ekliyor. Görünür değişiklik: hayalet satırdaki basılamayan "+" kalktı (yardımcı yönetmene bildirildi).
- **O-4 (`6fd69c49`).** OLAYLAR'ın isteğiyle sprint kâğıdı: ilk haftasında kapanacak sprintte zar başta; art arda 2 kararsız sprintten sonra zar tutmuş
  sayılır (acil durum ve söz olayı kararlı sayılır); `pm_two_accounts`'un ikinci hesabı bulunuyor. Probe team=12 8/191 → 46/148, team=6 20/939 → ~50/935.
- **U-6 (`69fcca9c`).** Erdem A'yı seçti: modülün araştırma bekleyen sıradaki kartı aday listesinin sonunda soluk satır, "+" yerinde Ar-Ge şişesi;
  ipucu yalnız "{node} araştırılmalı" (PROD_LOCK_RESEARCH), tık Ar-Ge'yi o düğümde açar. Bütün adayları kilitli modül artık gizlenmez.
- **Çip ve hover (`314aae33`).** Erdem: "Gelecek çeyrekte oradakilerin küçük harfle başlaması kötü görünüyor." Büyük harf çipte (`Fmt.cap_first`);
  CSV aynı, çünkü metin ipucunda cümle içinde okunur ("söz: bu çeyrek"). U-6 satırı öteki tıklanan satırlar gibi üstüne gelince aydınlanır.
- **U-1.** Prototip kopyada (commit'siz). Erdem N02'yi cevapladı (söz en çok gelecek çeyrek için; iş bitince "3. çeyrekte tamamlandı";
  satırda sözün son tarihi, planlandı mı (çeyrek ya da sprint), geliştirmedeyse halka ve aşamanın adı). Önce gerçek havuz adlarıyla kareler
  Erdem'e, sonra kod; envanterin product-13 ve product-14 satırları bu işin içinde.
- **Sırada:** T06 (Satın Alma hattının ilk iki kademesi, Ar-Ge notu, ERP'nin EN açıklaması; tek CSV commit'i), U-1 kareleri, envanter
  product-01…21 (ekran başına bir commit; product-10 "Kalsın").

## PLANMS (U-7)

HEAD `49ed1842` (U-2…U-6, O-4, çip ve hover `314aae33`, öteki oturumların commit'leri dahil), taze kopya, import ve ısınma temiz. Probe
`--sprint-probe=hours=40:cards=2:ticks=60:team=50:market=b2b:planms=1`, ölçü "screen" medyanı (cards=13, n=9).

- **İlk koşu, kirli.** 5 koşu: 130,7 / 135,0 / 198,4 / 168,7 / 132,7 ms, medyan 135,0 ms (S0 tabanı 81,259, kapı 89,4). Koşular arası dağılım
  çok geniş. Makine sessiz değildi: CPU %55 (League istemcisi 11 Kasım 06:47'den beri açık; başka bir projenin `pytest` koşusu). Betik yalnız
  Godot süreçlerini saydığı için bunu görmedi.
- **Eşli koşu, karar bu.** Yardımcı yönetmenin kuralı: aynı yükte HEAD/taban oranı kapının oranını (89,4 / 81,259 ≈ 1,10) aşarsa gerileme
  vardır. Taban `cb3185b4` (S0 kopyası) ile HEAD sırayla (b1 h1 … b5 h5), her koşudan önce CPU yükü kayıtlı (%23–77):

| Tur | Taban ms | HEAD ms | HEAD/taban | CPU (taban / HEAD) |
|---|---|---|---|---|
| 1 | 141,3 | 199,7 | 1,41 | %54 / %77 |
| 2 | 127,7 | 128,9 | 1,01 | %70 / %64 |
| 3 | 123,1 | 136,9 | 1,11 | %56 / %54 |
| 4 | 130,7 | 142,2 | 1,09 | %63 / %23 |
| 5 | 128,2 | 101,2 | 0,79 | %46 / %69 |
| Medyan | 128,2 | 136,9 | **1,068** (eşli oranların medyanı 1,088) | |

- **Hüküm:** iki oran da 1,10'un altında, gerileme yok. Pay dar, gürültü büyük: taban bu yükte S0'dan 1,58 kat yavaş. Mutlak sayı bu turda
  hüküm sayılmadı. League istemcisi kapalıyken tek bir temiz ölçüm mutlak kapıyı da sınar (Erdem'e yardımcı yönetmen soruyor).
- Kanıt: `pu_calisma/urun_arayuzu/planms_u7/` (ilk koşu) ve `planms_u7ab/` (eşli), betik `bin/quiet_planms3.sh`.

## Onay bekleyenler

- TR/EN onay bekliyor (metin): PRODUCT_STAGE_PCT (`eebf909`); PROD_LINE_HIDDEN_SELF_SERVE, PROD_RND_NODE_TEST_AUTOMATION_UNLOCK (`a243eba`);
  PRODUCT_TAG_SPRINT, PRODUCT_FX_TOP (`d074f9b`, yeni yerde); PROD_LINE_ERP_INTAKE "Purchasing", PROD_LINE_ERP_LEDGER "Accounting" (`c8bfe5f4`);
  PROD_LOCK_RESEARCH EN "Research {node} first" (`69fcca9c`).
- Tasarım sabiti onay bekliyor (`6fd69c49`): decision.max_dry_sprints = 2; zarın ilk haftasında kapanacak sprintte başa alınması; kesintinin sayacı
  sıfırlaması.
- Cevaplandı, kodu sırada: N02 (U-1), T06 (metinler). Hâlâ açık: N2 küçük harf etiketleri (devreden, yetişmez, bitti, hazırlıkta, sonraki
  sprinte kalır; "planda" envanterin product-14'üyle U-1'de); sprint_pm_two_accounts kart metni (OLAYLAR üzerinden); temiz mutlak PLANMS.

## Çalışma notları

- Ekran kilidi darboğazdı: dört oturum tek kilidi bekledi; benim bir kare koşum kilidi 06:43'te boş klasörle bıraktı (Windows'ta rmdir düştü),
  `lock_drop` artık birkaç kez dener. Yardımcı yönetmen iki monitörü ayrı kilitlemeyi Erdem'e soruyor.
- Belge çakışmaları: kod haritası sistem sayfalarındaki satır sayıları komşu commit'lerle çakıştı (U-2, U-5 iki kez); iki taraf korunarak çözüldü.
- Ölçüm açığı: sessiz PLANMS betiği yalnız Godot süreçlerini sayıyordu; makinenin öbür yükünü (12 Kasım'da League istemcisi ve başka bir
  projenin pytest koşusu, CPU %55) görmüyordu. Makinenin toplam CPU yükü her koşuda kayda girmeli (quiet_planms3.sh koşu başına yazıyor);
  test makinesine ayrı iş olarak yardımcı yönetmende.
- Yetim süreç: U-5 ajanının başsız `--product-shot` koşusu 06:40'tan 12 Kasım'a dek askıda kaldı (Godot pid 17324); sonlandırma bu oturumda izin
  sisteminde reddedildi, Erdem'in isteğiyle yardımcı yönetmen kapattı. Ders: her Godot koşusu timeout ile, ölçümden önce yetim taraması.
