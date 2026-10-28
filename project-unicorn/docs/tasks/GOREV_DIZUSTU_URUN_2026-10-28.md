# Görev · Ürün arayüzü, dizüstü turu (URUN_ARAYUZU)

2026-10-28 · Yazan: yardımcı yönetmen (`co-director`) · Oturum etiketi: **URUN_ARAYUZU** · Paralel oturum: OLAYLAR
(`GOREV_DIZUSTU_OLAYLAR_IKON_2026-10-28.md`). Bir Opus incelemesinin bulguları bu metne işlendi.

## Amaç

Sprint ekranını Erdem'in 2026-10-28 kararlarıyla bitirmek ve U7–U8'i kapatmak. Oyuncu sonunda:
- kart kutularını geniş bir eksende okur;
- her kartın hangi aşamada ve yüzde kaçta olduğunu görür;
- hiçbir metnin kesilmediği bir sprint ekranı görür.

## Önce oku

1. `PRD_URUN_SPRINT_ARAYUZU.md`:
   - en sondaki "Erdem'in 2026-10-28 kararları" (E1–E7). Çelişirse bu bölüm geçerlidir;
   - §13 U7 ve U8;
   - "Erdem'in A4 cevabı" bölümü (UK, UM, N1–N4).
2. `GOREV_URUN_ARAYUZU_DEVAM.md` "Devir (2026-10-27)": son commit `d1eb210`, kalanlar ve dosyalar `urun_arayuzu_devir/`.
3. `ORTAK_CALISMA.md` §1–§8 ve **§9 (dizüstü)**. §9 makineyi, betiklerin Mac'e çevrilmesini, kilitleri ve **MCP tarifini**
   anlatır.
4. Hafıza (`/Users/tugbauysal/.claude/projects/-Users-tugbauysal-Desktop-project-steam-Project-Unicorn/memory/`):
   `feedback-codirector-visible-rulings`, `feedback-no-truncation-mcp-validation`, `godot-mcp-runtime-verification`
   (yalnız MCP tuzakları), `partial-staging-shared-tree`, `strings-csv-surgery`, `godot-import-cache-gotchas`.

## Adımlar

Akış her kod adımında PRD §13'teki gibidir:
- Sonnet (xhigh) kodlar;
- Haiku kapıları koşar ve kareleri çeker;
- Opus (high) yalnız diff'i inceler.

Commit başına en çok 1 inceleme ve 1 düzeltme. Görünür her adım commit'ten önce MCP tarifiyle ve TR/EN karelerle
doğrulanır (E3); raporda her karenin altında "taşma yok, kesilme yok" satırı bulunur.

| # | Ne | Kanıt / kapı | Süre |
|---|---|---|---|
| D0 | **Kurulum.** `urun_arayuzu_devir/bin/`'i kendi scratchpad'ine kopyala ve ORTAK §9'un listesine göre çevir. HEAD'i kopyaya dışa aktar, `--import`, ısınma, `all_scripts_load`. **Z6'yı HEAD'de bir kez koş ve referans al:** eski referans Windows'taki 4.6.2'nindir, burada 4.6.3 var; tek tek ya da `-P 2`. **PLANMS tabanını** sessiz kilitle al: 50 kişi, 5 koşu, ortanca. MCP tarifini bir kez dene. | `all_scripts_load` PASS; Z6 ve PLANMS tabanı rapora; MCP `runtime-status` connected | 2 sa |
| D1 | **E5 kareleri (commit yok).** Kopyada koşan sprintli bir B2B dünyası kur (yeni bir `a4_*` türü): en az bir bu sprintte planlı, bir sonraki sütunda planlı, bir karşılanmış ve bir gelecek çeyrek isteği. "Sürüyor"un iki biçimi: (1) ikon, (2) kartın aşaması ve yüzdesi ya da "Sonraki sprint". Karşılanmış istek yeşil tik. Satır soluk değil; "Gelecek çeyrek" ad boyunda. Karşılanmış satırın kalma süresi, sırası ve katlamaya sayılıp sayılmaması için önerin. TR ve EN. | İki kare yan yana, N1–N4 satırı, önerilerin → `co-director`. Beklerken D2'ye geç. | 2 sa |
| D2 | **UK (a)** (E6). `uk_a.patch` yalnız yol gösterir; U6'nın üstüne yeniden yaz. Boş yuva genişlik almaz. Yüzde görününce söz çipi o satırdan kalkar. | `live:a4_run_w2` TR/EN, `a4_eleven` EN; `sprint_`/`product_` vakaları; Z6 bayt eş (HEAD D0'dan sonra kıpırdadıysa Z6'yı yeni HEAD'de yeniden koş, onunla karşılaştır); commit `Ürün arayüzü UK:`; `PRODUCT_STAGE_PCT` "TR/EN onay bekliyor" | 3 sa |
| D3 | **E1: Ürün penceresi genişler. `co-director`'ün "D3 başla" mesajını bekle** (Erdem'in "a"sı teyit ediliyor). Genişlik E1'in kuralıyla: genişliğin tamamı eksene gider, üç sütun yerinde kalır. Mesaj gelmeden D4'e geç; D3 sonra yapılır. | E1'in kare listesi önce/sonra; bir haftanın px'i; pencerenin px'i; `--shot-scale=1.25`; MCP'de pencere alanına sığıyor; commit `Ürün arayüzü UE1:`. Kareler `co-director`'e. | 3 sa |
| D4 | **U7** (PRD §13) **ve E2'nin kesme taraması.** İki bilinen kesme: (1) panoda kart adı iki satırdan sonra "…" (`board_row.gd` `OVERRUN_TRIM_ELLIPSIS`); (2) ÇEYREK'in dar görünümünde bölünen ya da kesilen EN kart adları. Tarama listesi E2'de. "+{n}" biçimleri yerinde kalır, kareleri D7'ye. | §13 U7 kapıları; silinen her ad için grep kanıtı. Kareler: `a4_eleven_tip` (uzun adlar) TR/EN ve `live:b2b_quarter` EN. Uzun adlı pano dünyası `a4_two_pm_long` repoda yok, gerekirse kopyada kur. Commit(ler) `Ürün arayüzü U7:`. | 6 sa |
| D5 | **UM: Yardım Merkezi** (E7). Yalnız CSV değeri ve adın geçtiği cümle (`PROD_RND_NODE_TEST_AUTOMATION_UNLOCK`). Bayt aralığıyla değiştir, CSV'yi baştan yazma. | `loc_csv_integrity`, `loc_residue`, glif denetimi; `--rnd-shot=discovery` TR/EN; düzeltme kartı yerine adın geçtiği her anahtarın grep listesi; commit `Ürün arayüzü UM1:`; metin "TR/EN onay bekliyor" | 0,5 sa |
| D6 | **Erdem seçince:** E4 ikonları (OLAYLAR'ın aday kâğıdından seçilenler) ve E5'in seçilen biçimi. İki harfli işaretler sol sütundan kalkar. `PRODUCT_AREA_*_MONO`'nun başka okuyucusunu grep'le bul ve rapora yaz (UM soru 3). | Sol sütun B2B (`a4_two_pm`) ve B2C (`b2c_live`) TR/EN, uzun adlı istek satırı; commit `Ürün arayüzü UE2:` | 2 sa |
| D7 | **U8** (PRD §13): görsel kabul sayfası. Her karede "taşma yok, kesilme yok" satırı. U3–U6'nın görünür kararları ve U6 karar 6 "yardımcı yönetmen kararı" etiketiyle durur. "+{n}" biçimleri ayrı bir karar bölümünde. Ek kareler `u8_todo.txt`'te. Artifact olarak yayınla, bağlantıyı `co-director`'e ver. | sayfa: JS derlemesi, başsız Chrome'da yatay taşma yok, 375 px genişlik | 4 sa |
| D8 | **PLANMS** (sessiz kilit; OLAYLAR'a önce tek satır yaz) ve `RAPOR_URUN_ARAYUZU.md` (devir notunun 6. maddesi). | Kapı: son HEAD'in ortancası D0 tabanının en çok %10 üstü; aynı makine, aynı yöntem, 5 koşu. Windows'un 100 ms kapısı dizüstünde askıda; mutlak değer bilgi için yazılır. | 1,5 sa |

Toplam yaklaşık 24 saat ajan zamanı. Sıra: D0 → D1 → D2 → (D3, mesaj gelince) → D4 → D5 → (D6) → D7 → D8. Erdem'i
bekleyen adımlar D3 (teyit) ve D6 (seçim); bekleme sırasında sıradaki adıma geçilir.

## Yapma

- E5 ve E4'ü Erdem seçmeden kodlama. D3'ü mesaj gelmeden başlatma.
- "+{n}" biçimlerini kaldırma: yalnız kare ve karar.
- UM'nin öbür satırlarına dokunma: üç soru Erdem'de.
- Olaylar dosyalarına (`scripts/events/**`, `data/events/**`) dokunma; §2'nin üç adımı geçerli.
- Push etme. Paylaşılan ağaçta Godot koşma.
- Ekranlı koşuyu `ekran` kilidi olmadan başlatma. Godot'yu `gd`/`gdw` dışında başlatma.

## Sorular

PRD sessiz ya da çelişkiliyse o noktada dur. `co-director`'e numaralı liste gönder ve beklerken sıradaki adıma geç.
Oyuncunun gördüğü yerleşim ve metin seçimleri iki kare ve önerinle gider. Teknik kararlar senin.

## Bitince

`RAPOR_URUN_ARAYUZU.md`:
- adım başına ✅ / ⚠️ / ❌ ve kanıt: commit, kapı, kare;
- E2 taramasının tablosu;
- TR/EN onay bekleyen anahtarların listesi.

`GOREV_URUN_ARAYUZU_DEVAM.md`'nin devir notu güncellenir. Son mesaj `co-director`'e: "hazır, son commit <sha>".
