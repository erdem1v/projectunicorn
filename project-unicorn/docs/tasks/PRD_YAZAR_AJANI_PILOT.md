# PRD · Yazar Ajanı · Pilot: gerçek hayattan olay kartları

**Kim çalıştırır:** ayrı bir Claude Code oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_YAZAR_AJANI_PILOT.md
dosyasını oku ve uygula."
**Durum:** sahip (Erdem) onaylı, 2026-10-08. Pilot çıktısı sahibin işaretlerinden geçer; onaylanırsa yöntem
mühürlenir ve departman departman yazıma geçilir.
**Tek cümle:** Forumlardan gerçek girişim olaylarını topla, oyuna uyar, kör puanla, 7'yi geçenleri oyunun kart
biçiminde önce EN sonra TR yaz; sahibe departman başına örnekleri bir inceleme sayfasında göster.

---

## 0. Bu oturumun kuralları (önce oku)

- **Repo yalnız okunur.** Repo: `C:\Users\erdem\Desktop\project steam\project-unicorn` (git kökü bir üstte). Bu
  oturum repo'da hiçbir dosyayı değiştirmez, stage etmez, commit etmez; Godot koşmaz. Aynı ağaçta başka oturumlar
  çalışıyor.
- **Çıktı dizini repo'nun dışındadır:** `C:\Users\erdem\Desktop\unicorn_writer_pilot\`. Her şey oraya yazılır.
- **Alt ajanlar Sonnet'te koşar** (`model: "sonnet"`). Sahibin haftalık limiti için kesin kural.
- **Web araması bütçesi:** pilot toplamda en çok 60 `WebSearch` kullanır (departman başına 10). `WebFetch`
  sınırsızdır ama günlüğe yazılır. Bütçe tükenince ajanlar sessizce model bilgisine düşer; bunu önlemek için her ajan
  `searches_used` ve her kaynak için `evidence: fetched | snippet` bildirir. Kanıtsız olay havuza girmez.
- **Telif ve gizlilik:** kaynağı kendi cümlelerinle özetle; 15 kelimeden uzun alıntı yok; kullanıcı adı, gerçek
  şirket, ürün ya da kişi adı hiçbir çıktıda yok. Kaynak URL yalnız kart dosyasının "kaynak" bölümünde durur, oyun
  metnine girmez.
- Oyuncu metni kuralları için `project-unicorn/CLAUDE.md` §5 bağlayıcıdır.

## 1. Neden

Oyun bir anlatı oyunudur; olaylar tekdüzeliği kıran şeydir (GDD ch11 §2). Canlı deste 58 karttır: müşteri 10,
kurucu 7, yatırım 18, ürün 9, rakip 2, ekip 4, dünya 8. Yatırım kartlarının çoğu Frank'in kapı kartıdır. 104 haftalık
bot koşusunda ateşlenen kartların %45'i istifa ve elde tutma kartıdır; oyuncu aynı kartı tekrar tekrar görüyor.
ch11 §2 v1 için en az ~40 düğüm ister, Erken Erişim için "çok daha fazlası"nı.

Sahibin isteği: "Gerçek hayattan, Reddit'te forumları gezip okuyacak agentlar; olayı görür, çeker, yorumlar, bizim
oyuna uygun olabilir der, varyant yaratır, skor verir; 7'den fazla puan alanlar; zaman zaman mizahi, zaman zaman
ciddiyeti hissettiren bir yazım tonu." Sahip, kendi editoryal kapasitesinin bu hacme yetmeyeceğini söylüyor. Bu
ajan kapasite verir; son söz sahibindedir.

İki eski dersin tekrarlanmaması şart. Kaynak: `git show 33c5323:project-unicorn/docs/reports/EVENT_DECK_DELETE_2026-08-31.md`.
- **COPY LIE.** Eski 28 kartın 27'sinde metin bir kaynağı söylüyor, motor başka bir kaynağı alıyordu. Metnin her
  iddiası bir etkiyle karşılanır; etkisi olmayan iddia metinde yer almaz.
- **Başka bir oyun için yazılmış içerik.** Eski destenin B2C koşusunda oyuncunun cevapladığı 26 kartın 24'ü bugünkü
  mekaniğe bağlı değildi. Her kart bugünkü bir sistem kenarına bağlanır (ch11 §5, §9).

## 2. Kapsam

Altı departman, her birinden 2 ile 3 kart: toplam 12 ile 18 kart taslağı ve en az bir varyant ailesi.

| Departman | Oyundaki karşılığı | Okuyacağı yerler |
|---|---|---|
| **Ekip** | çalışan hayatı, işe alım, moral, istifa, maaş, eğitim | `hr.*` seam'leri, `{employee}` slotu, Ekip GDD |
| **Müşteri** | B2B hesap (koltuk, memnuniyet, söz, yenileme), B2C kitle | `musteri.*`, `sales.*`, `{customer}` slotu, Satış GDD |
| **Ürün** | sürüm, hata, kesinti, destek hattı, kalite | `urun.*`, `destek.*`, Ürün GDD (ch03), Ar-Ge GDD |
| **Sprint planlama** | sprint açılışı, kapsam, gecikme, kısa yol, borç | `urun.sprint_*` seam'leri, `SprintSystem` kenarları |
| **Yatırım** | melek, seed, Series A, yönetim kurulu, term sheet | `funding.*`, `investor.*`, `{investor}` slotu, ch09 |
| **Rakip dünyası** | lig rakipleri, Piyasa listesi, sektör haberleri | `rival.*`, `docs/tasks/PRD_RAKIP_DUNYASI.md` §4.5 |

**Dışında:** kurucu kategorisi (yöntem onaylanınca eklenir); Frank'in replikleri (külliyat sahibindir; Frank bir
kartta konuşacaksa satır "taslak, onay bekliyor" diye işaretlenir ve kart Frank'in payı olan bir yerde olmalıdır);
yeni mekanik; repo'ya yazmak; Godot koşmak.

## 3. Önce oku (bağlam)

Yollar `project-unicorn/`'a göredir.
1. `CLAUDE.md` §1 (oyun bugün), §5 (oyuncu metni), §6 (olay motoru, WRITE-THROUGH).
2. GDD ch11 Olaylar ve Anlatı: `GDDs/GDD v2 — 11 · Events & Narrative.docx`. Özeti §7'de; tam metin gerekirse
   docx'i düz metne çevir (`python -c` ile zip içindeki `word/document.xml`).
3. `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`: kart şeması, sınıflar, mandal, süre dolumu, koşul dili.
4. `docs/content/events_draft/_vocabulary.md`: kullanılabilecek etki fiilleri ve seam'ler (üretilmiş, güncel).
   Burada olmayan fiil ya da seam `[VOCAB?]` / `[COND?]` olur. Fiilin hangi kökenden kullanılabildiği tablosu
   dosyanın başındadır (seçenek etkisi, süre dolumu cezası, ...).
5. `docs/content/events_draft/Frank Diyalogları · v6.md`: ses kuralları, "Frank nerede kalır", tire yasağı,
   "günlük olaylar gece yarısı patlar" (gün içi zaman kelimesi yok), İngilizce yazım ilkesi.
6. `docs/design/localization_glossary.md`: TR↔EN terim kanonu, izinli ödünç kelimeler.
7. Ton ve şema referansı olarak dört canlı kart. JSON'ları `data/events/cards/...`, metinleri
   `localization/strings.csv`'de `EV_<KATEGORİ>_<AD>_*` anahtarlarıyla:
   `founder/side_contract.json`, `team/outside_offer.json`, `customer/security_review.json`,
   `product/sprint_two_paths.json`.
8. Canlı destenin tamamı (tekrar yazmamak için): `data/events/cards/*/` ve başlıkları CSV'de.
9. Dönem: `docs/tasks/PRD_RAKIP_DUNYASI.md` §1 karar B (koşu 2012'de başlıyor; demo 2012-13 dilimi).

## 4. Kart şeması (canlı kartlardan; motor md'si son sözdür)

- `id` `<kategori>.<ad>`; `category` (customer, founder, funding, product, rival, team, world); `version_scope`
  (`demo` ya da `ea`).
- `class`: `interrupt` (hemen açılır, saati tutar), `paper` (masaya düşer, `expires_weeks` içinde cevap bekler),
  `info`, `ambient`. Karar olmayan an kart değil mesajdır; tek seçenekli ve etkisiz kart yalnız açık bir "beat" olur.
- `tick`: `daily`, `hourly`, `scheduled`, `signal`, `request` (bir sistemin adıyla istediği kart).
- `sender`: `frank`, `self`, `employee`, `contact`, `investor`, `press`, `desk`.
- `guards`: `market` (`b2b` / `b2c`), `product_live` (bool). `latch`: `one_shot` ya da `cooldown_weeks`.
- `condition`: `all` / `any` / `none` / `not` ağacı; yapraklar `{seam, op, value}` (yalnız sözlükteki seam'ler).
- `options[]`: `id`, `outcome_id`, `effects[]` (`{verb, ...}`; para etkisinde `label`, bu etiket
  `FinanceSystem.ONE_TIME_LABELS`'ta olmalı, yoksa `[VOCAB?]`).
- `text.tr` ve `text.en`: aynı anahtar kümesi (`title`, `body`, `options{}`, `expire_note`); değerler CSV
  anahtarıdır. `expires_weeks`, `on_expire.penalties` (yalnız negatif ekonomik ya da nötr fiiller), `expire_note`.
- Slotlar: `{customer}`, `{employee}`, `{investor}` (kartın kapsamındaki varlık). Gövdede yalnız `{slot}` ve
  `{seam:ns.ad}` çözülür; başka süslü parantez ekrana çıplak çıkar. `{company}` diye slot yoktur.

## 5. İş akışı (her aşama ayrı Sonnet ajanı; yazar kendi puanını vermez)

```
Keşif (6 ajan, paralel) → Ayıklama → Uyarlama + Yazım (departman başına 1 ajan) → Kör eleştiri (kart başına 1 ajan) → Kapı → Paket
```

### 5.1 Keşif
Departman başına 12 ile 15 gerçek olay. "Olay", bir kişinin yaşadığı, karar anı içeren somut durumdur ("en iyi
geliştiricimiz rakipten teklif aldı, karşı teklif mi verelim"); genel tavsiye yazısı değildir.
- **Reddit:** r/startups, r/SaaS, r/Entrepreneur, r/smallbusiness, r/sales, r/ExperiencedDevs, r/cscareerquestions,
  r/managers, r/humanresources, r/ProductManagement, r/agile, r/scrum, r/venturecapital, r/talesfromtechsupport,
  r/sysadmin. Arama: `WebSearch` ile `site:reddit.com/r/<ad> <konu>`. Okuma: `WebFetch` önce
  `https://old.reddit.com/r/<ad>/comments/<id>/.json`, olmazsa sayfanın kendisi. Engellenirse arama özetiyle yetin,
  kanıtı `snippet` diye işaretle.
- **Hacker News (engelsiz, en verimli):** `https://hn.algolia.com/api/v1/search?query=<q>&tags=ask_hn` ve yorum ağacı
  için `https://hn.algolia.com/api/v1/items/<id>`. "Ask HN" savaş hikâyeleri.
- **Indie Hackers**, kurucu ölüm sonrası yazıları, kurucu blogları.
- Aday kaydı: kaynak URL, tarih, kendi cümlelerinle bir paragraf özet, karar anı, seçenekler, biliniyorsa sonuç,
  neden komik ya da ağır olduğu, `evidence`.

### 5.2 Ayıklama
Tut, eğer hepsi evetse:
- En az iki savunulabilir yolu olan bir **karar** var.
- **Ölçek** tutuyor: 1 ile ~40 kişilik, erken evre bir teknoloji girişimi.
- **Dönem** tutuyor: 2012-2014'e uyar ya da dönemden bağımsız yazılabilir (yapay zekâ asistanı, salgın dönemi uzaktan
  çalışma, kripto çılgınlığı yok).
- Oyunun bugünkü bir **sistem kenarına** bağlanıyor (ch11 §5: churn, faz geçişi, kesinti, zam talebi, rakip hamlesi,
  sürüm, kapsam kırmızısı, bozulan söz; ya da bir seam koşulu).
- Canlı destede **eşi yok**.

### 5.3 Uyarlama ve yazım
**Uyarlama tablosu:** tetik (kenar ya da koşul ağacı), sınıf, gönderen, slot, seçenekler ve etkileri, süre dolumu,
mandal, kart başına "kim için doğru" cümlesi (baskın seçenek yok), tahmini görülme sıklığı ve gerekçesi, hafıza
(yazdığı bayrak, okuyabilecek sonraki kart). Bedel yasası: her seçenek gerçek bir kaynağa mal olur (para, kurucu
saati, sprint saati, moral, memnuniyet, marka, itibar, MRR, koltuk) ve sonucu görünür bir çipe düşer. Motorun
bilmediği etki ya da koşul `[VOCAB?]` / `[COND?]`; kart "bağlanamaz" işaretlenir ve geliştirici öneri listesine girer.

**Yazım:**
- **Önce EN.** İngilizce, İngilizce yazılmış gibi okunur. **TR ayrı bir yazımdır**, çeviri değil: sahneyi Türk okur
  için yeniden yaz. TR'de İngilizce yalnız izinli ödünç kelimelerde (pitch, startup, demo, momentum, MRR, runway,
  churn, burn, laptop, mail, VC) ve özel adlarda.
- **Edgü kesimi (ch11 §7):** gözlem, hüküm yok, son cümle en kısa. Hüküm yalnız Frank'in ağzındadır.
- **Yasak:** tire (— –); benzetme; aforizma; sahne ve aksesuar betimi; UI talimatı ve sekme adı; gün içi zaman
  ("sabah", "akşam"); gerçek marka, şirket, ürün ya da kişi.
- **Ton:** mizah durumun kendisinden gelir, anlatıcı espri yapmaz. Örnek kalıp (yalnız kalıbı göstermek için):
  EN "The client loved the demo and asked when it would be ready. It was the product." / TR "Müşteri demoyu çok
  beğendi ve ne zaman hazır olacağını sordu. Ürünün kendisiydi." Her taslak ton etiketi taşır: `ciddi`,
  `kuru mizah`, `acı tatlı`. Pilotta yaklaşık üçte bir hafif ton.
- **Uzunluk:** başlık en çok 4 kelime; gövde EN en çok 45 kelime (canlı kartlar 20 ile 35 arası); seçenek en çok 6
  kelime ve bir fiille başlar; süre dolumu notu en çok 12 kelime. Kilitli seçenek gerekçesiyle görünür; gerekçe kendi
  bilgeliğini söylemez.
- CSV kuralı: araya giren değer ek almaz (`Sözleşme: {customer}` olur, `{customer}'nin sözleşmesi` olmaz); iki dilde
  token kümesi aynı.

### 5.4 Kör eleştiri
Eleştirmen yazarın puanını görmez. Kartı, kaynak özetini ve uyarlama tablosunu okur, `_vocabulary.md` ile fiil ve
seam'leri denetler, canlı desteyle eşini arar.

| Ölçüt | Ağırlık | 10 puan ne demek |
|---|---|---|
| Gerçeklik | %20 | Gerçek kaynağa dayalı; bu işi yapmış biri "bu bizde de oldu" der |
| Karar kalitesi | %25 | En az iki savunulabilir yol, her biri gerçek bir bedel, baskın seçenek yok |
| Mekanik uyum | %20 | Var olan fiil ve seam'lerle bağlanır; her metin iddiası bir etkiyle karşılanır; sonuç görünür |
| Yazım ve ton | %20 | Ses kuralları tutuyor; mizah ya da ağırlık yerine oturuyor; EN doğal, TR iyi bir yeniden yazım |
| Tazelik ve varyant gücü | %15 | Destede eşi yok; en az iki varyant çıkar (pazar, evre, şirket boyu) |

**Sert kurallar** (biri varsa kart düşer): tire; gerçek marka ya da kişi; UI talimatı ya da sekme adı; gün içi zaman
kelimesi; Frank dışında hüküm; işaretsiz bilinmeyen fiil ya da seam; COPY LIE; işaretsiz Frank satırı; beat olmayan
bedelsiz seçenek.

### 5.5 Kapı
Kart pakete girer: eleştirmenin ağırlıklı puanı **≥ 7,0**, hiçbir ölçüt 5'in altında değil, sert kural ihlali yok.
Yazar ile eleştirmen arasında 2 puandan büyük fark rapora ayrıca yazılır. Fikri iyi ama kapıdan geçemeyen kart bir
kez yeniden yazılır ve yeniden kör puanlanır.

## 6. Teslim

`C:\Users\erdem\Desktop\unicorn_writer_pilot\` altında:
- `INDEX.md`: departman başına aday sayısı, geçen sayısı, puan dağılımı, kullanılan arama sayısı, `[VOCAB?]` ve
  `[COND?]` istekleri (geliştiriciye öneri listesi), sahibe sorular.
- `<departman>/candidates.json`: tüm adaylar, kaynakları, ayıklama hükmü.
- `<departman>/<kart_id>.md`: kaynak özeti ve bağlantı; neden uygun; uyarlama tablosu; kart JSON taslağı; EN ve TR
  metin; ton etiketi; varyantlar; yazar puanı; eleştirmen puanı ve gerekçesi; sert kural denetimi.
- `cards.json`: geçen kartların JSON taslakları. `strings_draft.csv`: `keys,tr,en` biçiminde, anahtar adları
  `EV_<KATEGORİ>_<AD>_<PARÇA>`.
- `review.html`: sahibin inceleme sayfası. Her kart oyundaki kart gibi okunur (başlık, gönderen, gövde, seçenekler,
  etki çipleri okunur etiketle), yanında ton, puan ve kaynak özeti; kart başına "onay / düzelt / ret" işareti ve not
  alanı; işaretler sayfadan kopyalanabilir bir metin olarak dışa alınır. Oturumda Artifact aracı varsa sayfayı özel
  bir artifact olarak yayımla ve bağlantısını ver; yoksa dosyayı gönder.

**Done mesajı (sahibe):** kaç aday, kaç kart geçti, departman başına en iyi kart başlığı ve puanı, ton dağılımı,
kullanılan arama sayısı, `[VOCAB?]` listesi, inceleme sayfasının bağlantısı ya da yolu, açık sorular.

## 7. GDD ch11 özeti (bağlayıcı)
- Yapı: sisteme bağlı arklar ve küçük bir doku havuzu; dokular ekonomik ağırlık taşımaz, günde en çok bir tane.
- Sözlük yasası: olay yalnız motorun bildiği etkiyi kullanır; bilinmeyen `[VOCAB?]`, kart bağlanmaz.
- Bedel yasası: her seçenek gerçek bir kaynağa mal olur ve görünür bir okuyucusu vardır; bedelsiz yalnız beat.
- Tetik: sistem kenarları; rastgele takvim zarı değil.
- Hafıza: düğümler bayrak yazar, sonrakiler okur.
- Ses: Edgü kesimi; EN doğal; Frank kısa, ağabey, hüküm yalnız onda, düğüm başına en çok üç cümle.
- Kilitli seçenek gerekçesiyle görünür, asla gizlenmez.

## 8. Pilot onaylanınca (bu task'ın dışı, bilgi için)
1. Sahibin işaretleri ve düzeltmeleriyle yöntem `docs/writing/OLAY_YAZIM_YONTEMI.md` olarak mühürlenir.
2. ch11 §10'un açık kararı için öneri: departman başına ilk parti 8 ile 12 kart.
3. Her parti: yazar ajanı → sahibin işaretleri → geliştirici ajanı kartları bağlar (JSON, CSV cerrahisi, lint,
   `EvChips` kapsamı, `--event-harness` ile erişim ölçümü) → yardımcı yönetmen doğrular.
4. `[VOCAB?]` istekleri ayrı geliştirici işi olur; hangilerinin yapılacağına sahip karar verir.
