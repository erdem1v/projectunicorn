# Olaylar mail olarak · A4 ekran maketleri (grup "olaylar")

Erdem kararı 15: olaylar gelen kutusunda mail olarak okunur. Bu klasör mailin anatomisini, gönderen türlerini (SENDERS.md),
altı temsilî kartın mail taslağını (DRAFTS.md) ve kutunun bütün durumlarını onaylı Menajer Masası diliyle, tam kabuk içinde
1920×1080'de gösterir. Hepsi onay bekliyor.

- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, ikonlar, kırpım kuralı. Sistemin eksiği
  `olaylar.css`'te (aşağıda "Yeni bileşenler"); sistem klasörüne hiçbir şey yazılmadı (kit kopyaları ve önbellekleri
  `tools/syskit/`'te).
- **Kabuk tek kaynaktan:** üst bar ve marka bloğu, ray, haber şeridi, ofis katmanı (A2 kafa ikonlu `noicons`
  plakası), BuildHUD, bildirim yığını ve Ofisi taşı kabuk grubunun `../kabuk/tools/gen.py`'sinden çağrılır (salt okunur
  yüklenir) ve `../kabuk/kabuk.css` ile çizilir. Bu grup yalnız kutuyu ve okuma bölmesini kurar. Kabuk kurucuları
  değişirse bu çerçeveler yeniden üretilmeli.
- Frank = aday A (`portraits/frank_cand_a.png`). Kurucu = `founder_01`. Yağlı boyalar yok.
- Marka bloğu: plan kararı 14'ün **(a) seçeneği** (turuncu kare + "Project Unicorn"), kabuktan.

Yeniden üretmek: `python tools/gen.py` (HTML'ler `build/`), `bash tools/render_all.sh <tur>` (PNG'ler bu klasöre, kopyası
`rounds/<tur>/`). `tools/dump_cards.py` kartları CSV metniyle döker, `tools/senders.py` SENDERS.md'yi yazar.
Turlar: r1 (19 çerçeve), r2 (düzeltmeler + taslak sayfası), r3 (olaylar + kabuk incelemesinin S1/S2/S3 bulguları; 26
çerçeve, hepsi tam boy okundu; yığın, başlık, BuildHUD, marka, şerit kenarı, zar, kaydırma çubuğu, rapor tablosu 1:1 ve
2×–4× kırpımla `rounds/crops/r3/`). r2'nin araçları `rounds/r2_backup_tools/`.

## Mailin anatomisi

| Parça | Ne | Kural |
|---|---|---|
| Künye (kicker) | konu etiketi + tür (Karar, Kağıt, Rapor, Mesaj, Dikkat) + durum (Cevap bekliyor amber; "2 hafta içinde"; "Bu hafta son" uyarı) | Tarih künyede değil (soru 4). |
| Konu | `t-h2`, gönderenin yazdığı | Kartın yeni `subject` alanı; `title` iç ad olarak kalır. Konusu yazılmamış kartta (geçmiş satırları) başlık durur. |
| Başlık | 40 px avatar (kişi: disk; şirket: monogram; yayın: yayın renginde monogram; masa: belge glifi) + **1. satır** ad + unvan; **2. satır** "Kime · Kurucu · Unicorn Inc." ve sağda tarih | Tarih 2. satırın sağında **sabit bir sütunda**: genişliği on iki ayın TR ve EN değerlerinin en kötüsünden ölçülür (en geniş "Week 52 · September 2026 · 09:00": Chrome 222 px, Godot payıyla 242 px; `gen.py DATE_W`). 1. satır tam genişliği alır, uzun unvan önce kısalır; 2. satırda önce Kime değeri kısalır. Monogram gösterilen addan türer (Alan adı aracısı AA, Domain reseller DR). Ayrılmış gönderende yüz gri %55, unvandan sonra "·" ayracı (künyedeki gibi iki yanı 8 px) ve "Ayrıldı". |
| Saat | Gün sınırı kartı saat yazmaz ("Hafta 14 · Nisan 2026"); saatlik kart ve oyuncunun açtığı mesaj yazar ("Hafta 1 · Ocak 2026 · 09:00"). | Günlük tikli kart, ve günlük tikin içinde istenen ya da sinyalle doğan kart (`customer.retention` risk girişi `B2BSalesSystem` günlük tikinde, `team.resignation` `HRSystem.daily_tick` → `tick_thresholds`'ta) gece adımının 00:00'ında doğar; motor adım sürerken pompalamaz (`engine.gd pump`: `TimeManager.is_batching()`), kartı adım bitince (`clock_batch_ended` → `EvEngine.pump`, `signals.gd`) **08:00'de** açar ve kapı saati orada tutar. Bu yüzden kapılı çerçevelerin hepsi 08:00'i okur, hafta çubuğu başta. Oyuncunun açtığı kağıt (Cevapla) saati açtığı anda tutar (11:00). |
| Gövde | paragraflar; selamlama ve kapanış göndericinin | Frank'in maili baştan sona Source Serif 4 20/30, selam ve kapanış yok. Diğerleri Plex 16/24. Müşteri "Saygılarımla," ile kapatır; çalışan kapanış yazmaz (imza adını taşır). |
| İmza | kısa çizgi, ad, unvan · şirket | Yapısal. Frank'in onaysız satırlarında imzanın sağında kesik çerçeveli **TASLAK** işareti (maket notu, oyun öğesi değil). |
| Portre kuyusu | 256×320, sağda | Yalnız kişi yazınca (Frank, çalışan). Raporda yok. |
| Cevabın | etiket + "Seçim kalıcıdır · Oyun duraklatıldı" | Sistemin kur ve seç grameri: tek açık seçenek kurulu gelir (bedel kutusu + 56 px amber düğme), çok seçenekte oyuncu kurar, kilitli seçenekte yalnız etiket ve kilit soluk, gerekçe tam mürekkep. |
| Eylem satırı | Mesaj, rapor ve kayıtta (karar değil) | **Tek kural:** sağa yaslı, birincil en sağda, düğmeler 40 px; not varsa solda (ör. "Otomatik özet · her çeyrek sonu"). Kararın tek açık seçeneği sistemin 56 px bedel kutusu düğmesinde kalır. |
| Kağıt | "Cevabın" altında kağıt çubuğu: kalan süre + "Cevapla" | Cevapla'dan sonra kağıt bekleyen karar olur: seçenekler açılır, saat durur, altta "Kenara koy · Esc" ve kalan süre (Esc kağıdı masaya geri koyar, süre işlemeye devam eder). Karar beklerken çubuk "Önce bekleyen kararı cevapla." ve kapalı düğme. |
| Zar | Seçeneğin kendi oranı (motor GDD §9.2, §9.6) | Oran hep görünür, bilgi tonunda ve noktalı çizgiyle (üstüne gelinir); üstünde modifier listesi: işaretli (yukarı ok lehte, aşağı ok aleyhte), sayısız, büyüklüğe göre, en çok 4 satır. Kurulu seçenekte üç parça: Kalır %58 · Kalırsa (bedel) · Kalmazsa (tehlike). |
| Geçmiş | "Seçimin" altında cevaplanmış belge kartı | Damga belgenin üstünde (CEVAPLANDI H11, AYRILDI H14). Liste satırının üçüncü satırı "Seçimin: …". |
| Liste satırı | gönderen + konu etiketi / konu + sağda süre ya da saat / gövdenin ilk satırı | Amber nokta bekleyen karar, mürekkep nokta okunmamış; hatırlatıcıda nokta ve tarih yok, üçüncü satırı dik (italik yok: Plex Italic yüz listesinde değil), anahtar "Sebep:" orta kalınlıkta. Seçili satır her zaman mürekkep: seçili soluk satırın (kapalı kağıt, geçmiş) konusu ink-2. |
| Süzgeç sayıları | Tümü · Bekleyen · Okunmamış | `gen.py counts()` satır listesinden sayar: **Tümü** her öğe (gün ayracı hariç; kuyruktaki kararlar dahil); **Bekleyen** kararlar, kuyruktakiler ve kağıtlar (hatırlatıcı değil); **Okunmamış** mürekkep noktalı satırlar + hiç açılmamış kuyruk kararları. |
| Bildirim yığını | Kutunun önizlemesi | Kutudaki kağıt ve hatırlatıcılar, kutunun sırasıyla; kabuğun satır kurucusu (`notices`, `stack_row`): gönderen · konu · kalan süre. Etkin karar yığında değil (kapı yuvasında), onunla aynı konudaki hatırlatıcı listede de yığında da gizli. Tohum anı (H14) her çerçevede aynı üç satır: "Nordica · Bir ekip daha · 2 hafta", "Ege Sigorta · Risk altında", "Selin Kaya · Ayrılabilir". |

## Çerçeveler

Sütunlar: durum, veri kaynağı, yeni bileşen, yeni metin (EN / TR; tam liste aşağıda), açık soru numaraları.
"Tohum" = `docs/mockups/menajer/data/screens.md` (theme seed, hafta 14, 11:00) ve `main.gd _seed_theme_surface`.
Üst bar değerleri her çerçevede tohumun kendisi (kabukla aynı): **tohum ekonomisi yeniden hesaplanmadı** (aşağıda not).

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `olaylar__frank_teklif.png` | Frank'in teklifi seçili, karar bekliyor; saat **08:00**'de kapıda tutulu (hız tuşları kapalı, rayda amber nokta). Tek açık seçenek kurulu (Nakit +$25K, Frank'e %4 hisse, Kabul et), Reddet kilitli. Liste: kağıt (karar beklerken soluk), iki hatırlatıcı, bu haftanın Ar-Ge notu ve dönem özeti, hafta 1'de tanışma. Süzgeç 7 · 2 · 2. Yığın tohumun üç satırı. | Tohum; kart `funding.frank_cheque` (`tick: daily`); metin DRAFTS 1. | mail başlığı, imza, Cevabın, künye türü, TASLAK işareti | Teklif / An offer; Cevabın; Kime | 2, 3, 4 |
| `olaylar__frank_teklif_en.png` | Aynısı İngilizce (sayfa dili `en`: REPUTATION düz I). | Aynı; EN değerleri CSV'den. | | Your reply, To, An offer | 2 |
| `olaylar__kuyruk.png` | Üç karar: Frank'in teklifi etkin, kuyruk satırı "2 karar daha sırada · bundan sonra açılır", üst bar "3 karar bekliyor", 08:00. Süzgeç 9 · 4 · 4 (kuyruktakiler sayılır). | Tohum; kuyruktaki kartlar yalnız sayı (plan). | | (SPEC) | |
| `olaylar__musteri_secenek_acik.png` | Ege Sigorta'nın maili (müşteri riski), dört seçenek; "İndirim ver" kurulu: Müşteri kalır · MRR −$150, İtibar −1, Vazgeç ve amber Seç. Ege'nin hatırlatıcısı listede ve yığında gizli. 08:00. | Tohum; `customer.retention` (risk girişi günlük tikte); ses `B2B_RISK_VOICE_SHORT_2`; indirim = MRR $1.000 × `RETAIN_DISCOUNT_PCT` 0,15; unvan `B2B_CONTACT_INSURANCE`. | nötr etki parçası (glifsiz) | Konuşmamız gerek / We need to talk; Merhaba, Saygılarımla | 5, 8, 12, 24 |
| `olaylar__musteri_secenek_acik_en.png` | Aynısı İngilizce. | Aynı. | | Hello, Regards, IT Manager (CSV) | 5 |
| `olaylar__kilitli_secenek.png` | Ege'nin ikinci risk maili: "Söz ver" kilitli ("Bu hesaba verdiğin son söz tutulmadı."), odak halkası Oyala'da, hiçbiri kurulu değil. Geçmişte Hafta 11 cevabı. | Tohumdan türetildi: Hafta 11'de "Söz ver" (2 haftalık söz), Hafta 13'te tutulmadı (`B2B_RISK_VOICE_BROKEN`, kilit `B2B_LOCK_PROMISE_BROKEN`), Hafta 14'te yeniden risk (`RISK_REENTRY_WEEKS` 3). | | | 12 |
| `olaylar__gecmis_karar.png` | Aynı durumda Hafta 11 mailine dönülmüş: cevaplanmış belge kartı (Söz ver; Müşteri kalır · söz borcu, İtibar +1; CEVAPLANDI H11). Karar hâlâ bekliyor, kapı açık. Seçili geçmiş satırının konusu ink-2. | Aynı türetme. | cevaplanmış belge kartı | Seçimin (SPEC) | |
| `olaylar__kagit_onizleme.png` | Nordica'nın kağıdı önizlemede: "2 hafta içinde" + amber Cevapla; saat 11:00, 1x işliyor. Süzgeç 6 · 1 · 2. | Tohum (Nordica 20 koltuk $2,0K/ay); `customer.expansion` (`tick: daily`, 08:00'de geldi); unvan `B2B_CONTACT_LOGISTICS`. | | Bir ekip daha / One more team; {n} hafta içinde (SPEC) | 19 |
| `olaylar__kagit_acik.png` | **Yeni.** Oyuncu 11:00'de Cevapla'ya bastı: kağıt bekleyen karar oldu (kapı "Cevap bekliyor · Nordica", saat 11:00'de tutulu), iki seçenek açık, odak ilkinde: Koltukları ekle (Koltuk +3 · MRR +$360), Şimdi değil (Değişiklik yok). Altta "Kenara koy" + Esc tuşu ve "2 hafta içinde". Yığında kağıt yok (etkin karar), Ege ve Selin var. | `customer.expansion` seçenekleri; çip `event_modal._describe_modifier` `b2b_expand`: `B2BConstants.expansion_seats` (tohumda `company_size` boş → small = 3) × fiyat (tohumda `seat_price` 0 → `EXPANSION_PER_SEAT_MRR` 120) = +$360; `b2b_expand_decline` → `EFFECT_NO_CHANGE`. Esc: SPEC §6 madde 7 (`EventGate.set_aside`). | kağıt ayağı (`.reply-foot`, `kbd`) | Set aside / Kenara koy | 25 |
| `olaylar__kagit_son_hafta.png` | Aynı kağıt son haftasında: künye ve çubuk uyarı renginde "Bu hafta son", başlık KPI'ı "Bu hafta", yığında "bu hafta" uyarı renginde. | Hafta 15 (kağıt Hafta 14'te 2 haftayla geldi). Üst bar tohumda, yalnız tarih ve Sıradaki değişti. | | Bu hafta son (SPEC) | 13 |
| `olaylar__kagit_karar_beklerken.png` | Karar beklerken kağıt seçili: okunur, "Önce bekleyen kararı cevapla." ve kapalı Cevapla; seçili soluk satırın konusu ink-2. 08:00. | Tohum + Frank'in teklifi. | | (SPEC) | |
| `olaylar__bildirimler.png` | Hatırlatıcı satırları: riskteki müşteri, ayrılabilir çalışan, büyüme talebi. Ege seçili: kayıt (MRR $1,0K/ay, 12 koltuk, Memnuniyet 25, 2 aydır müşteri) + dik "Sebep: sık kesinti şikayeti" ve "Müşteri temsilcisi: atanmadı" + sağda İlgilen (40 px). Yığın kutu sırasıyla: Ege, Selin, Nordica (büyümek istiyor). | Tohum, Satış portföy kartı verisi. Büyüme kağıdı yokken büyüme hatırlatıcısı görünür. | hatırlatıcı kaydı | Dikkat / Attention; Reason: / Sebep: | 8 |
| `olaylar__calisan_ayrilik.png` | Selin Kaya'nın istifa maili, tek açık seçenek kurulu: Ekip · Selin ayrılıyor (tehlike) + Anlaşıldı. Gövdede kapanış adı yok. Selin'in hatırlatıcısı gizli. 08:00. | Tohum (moral 22); ayrılık turu varsayıldı. Ses `HR_RESIGN_VOICE_4`. Kart `HRSystem.daily_tick` içinde istenir: 08:00'de açılır. | | İstifa dilekçem / My notice | |
| `olaylar__ayrilmis_gonderici.png` | Hafta 15: Selin'in maili geçmişte, yüz gri %55, "Test Mühendisi · Ayrıldı", AYRILDI H14 damgası; Ekip rozeti kalktı; yığında kağıt (bu hafta) ve Ege. | Önceki çerçevenin devamı. | | Ayrıldı (SPEC) | 13 |
| `olaylar__zar_secenegi.png` | **Yeni.** Zarlı karar (Hafta 15, 08:00): Selin'in istifa maili üç seçenekle. "Zam teklif et" kurulu: Kalır **%58** (bilgi tonu, noktalı çizgi) · Kalırsa Maaş +$700/ay · Kalmazsa Selin ayrılıyor + Seç. "Kalması için konuş": şans çipinin oranı "%31" üstünde (düz çizgi), modifier listesi açık (aşağı ok "Elinde başka teklif var", aşağı ok "Morali düşük"). "Anlaşıldı": Selin ayrılıyor. Kağıt son haftasında (uyarı), Burak'ın raporu yeni. | **Durum örneği, gönderilmiş kart değil:** bugün hiçbir kartta `check` yok (`data/events/cards` taraması). Yapı motor GDD §9.2 (seçenek başına `check`, `odds_seam`), §9.3 (farklı seçenek farklı zar, farklı bedel), §9.6 (oran hep görünür, farklı ton, liste yalnız üstünde, işaretli, sayısız, en çok 4). Oranlar, zam ve modifier etiketleri örnek. | zar parçası ve oran (`.odds`), modifier listesi (`.odds-tip`, `.mod`) | aşağıdaki liste (örnek) | 26 |
| `olaylar__zar_secenegi_renk_koru.png` | **Yeni.** Aynı çerçeve renk körü paletinde (`body.cb`): Artıda ve yığın noktası mavi, tehlike cıva turuncusu, son hafta soluk sarı, oran soluk mavi, amber değişmez. | Sistem CB paleti (`tokens.css [data-palette=cb], body.cb`). | | | |
| `olaylar__donem_ozeti.png` | Dönem özeti Muhasebe'den rapor maili olarak kendiliğinden açılmış; oyun duraklatıldı (II etkin, kilit değil), 08:00. Başlık **"1. Çeyrek 2026"**, aralık **"Hafta 1-13 · Bootstrap"**, satır "Ekip · kurucu dahil 1 → 6", not solda, Devam et sağda (40 px). | `--modal-shot=month` tohum çıktısı (MRR $0 → $4,0K, Kasa $10,0K → $10,0K, Ekip 1 → 6, Marka 50 → 50, Runway Artıda); `SUMMARY_TITLE_QUARTER`, `SUMMARY_RANGE`. Motor "2. Çeyrek, Hafta 1-14" basıyor (soru 11); kapanan çeyrek 1. çeyrek (hafta 1-13), çerçeve doğrusunu çizer. Ekip satırı `SummarySystem._team_size` = kurucu + bordro: Ekip penceresindeki ÇALIŞAN 5 ile aynı kadro. | rapor tablosu, öne çıkan satır | Team · incl. founder / Ekip · kurucu dahil; Muhasebe; Devam et; Çeyreğin olayı | 6, 11 |
| `olaylar__frank_tanisma.png` | Yeni koşu, Hafta 1, 09:00: Frank'in ilk maili kendiliğinden açık, tek öğe; Hadi başlayalım sağda 40 px. Tarih 2. satırda sabit sütunda (Kime ile arada 90 px). Ev ofisi, BuildHUD yok, ray rozetsiz, yığın boş. | Koşu başı (kabuğun `V_WEEK1`'i): kasa $10.000, burn $1,5K/ay, MRR 0, net −$1,5K/ay, runway 7 ay. Metin DRAFTS ek taslak. | | Ben Frank / It's Frank | 10 |
| `olaylar__frank_ani.png` | **Yeni.** Frank'in tek seçenekli anı tam kabukta: "Eski bir dost", 08:00 kapıda; tek açık seçenek kurulu (Yeni aday · Seni oraya götürür + Satış'a git, 56 px). | `customer.frank_intro` (`tick: daily`, interrupt); DRAFTS 2. Tarih tohum haftasında tutuldu (kart gerçekte ürün yayına girince gelir). | | Eski bir dost / An old friend | 15 |
| `olaylar__arge_notu.png` | Elif Demir'in aylık ürün notu (saat durmaz, 1x); iki ikincil düğme sağa yaslı: Ürün sayfasına git, Ar-Ge'ye git. | `--modal-shot=rnd-note` tohum çıktısı (rakip Operanda). | | Aylık ürün notu (RND_NOTE_TITLE yeniden harf) | |
| `olaylar__haftalik_satis.png` | Hafta 15: Burak Şahin'in haftalık satış raporu: "Geçen hafta kapananlar:", tablo (YILDIZ sütunu 56 px, "2" + tek yıldız glifi), toplam ve "Defterdeki hesap: 5". | **Satırlar hesaplanmadı**: sistem sayfası 06'nın örneği (Karadeniz Fabrika 12 × $85, Efes Emlak 8 × $75), tohumdaki iki lead'in kapandığı varsayımıyla. Yıldız 1-3 (`SalesConstants.STAR_MAX` 3), `SALES_BAND_STAR` "{n}" + `util/star_full`. | rapor tablosu, tek yıldızlı hücre (`.star1`) | Closed last week: / Geçen hafta kapananlar:; Accounts on the books: {n} / Defterdeki hesap: {n}; sütunlar | 13, 14 |
| `olaylar__bos_kutu.png` | "Bekleyen" süzgeci boş: listede ve bölmede boş durum, ikisi de kutunun ortak gövdesinde (süzgeç başlığının altı) aynı yükseklikte. Süzgeç 6 · 0 · 0; yığında üç hatırlatıcı. | Tohum, kararsız ve kağıtsız an (kutuda üç hatırlatıcı ve iki rapor). | liste ve bölme boş durumu | Nothing waiting. / Bekleyen bir şey yok.; No message selected. / Seçili mesaj yok. | 20 |
| `olaylar__uzun_gecmis.png` | **Yeni.** Uzun kutu, kaydırılmış (236 px): üstte yarım kalmış satır, altı gün ayracı (Hafta 14, 13, 11, 7, 5, 1), 8 px çubuk listenin 12 px oluğunda (satırlar oluğa girmez), başparmak ortada. Seçili: Hafta 7 "Eski bir dost" cevabı (Satış'a git, CEVAPLANDI H7). Süzgeç 10 · 1 · 1. | **Geçmiş türetildi** (tohum geçmiş saklamaz), gerçek kartlardan: H13 Nordica `customer.request_feature` → Listede olduğunu söyle; H11 Ege `customer.request_complaint` → Durumu açıkça anlat; H7 `customer.frank_intro`; H5 `product.paid_tier` → Ürüne git. İlk aylık not H14 (kisisel_arge grubuyla aynı). | kaydırılan liste (`.ib-scroll`, `.ib-rows`) | | |
| `ekip__salt_okunur_karar_bekliyor.png` | Karar beklerken Ekip penceresi salt okunur: şerit "Karar bekliyor. Bu pencere yalnız okunur. Frank Köseoğlu · Teklif" + Karara dön (sağ kenarı 1534'te, kontrol şeridiyle aynı 24 px iç boşluk); mesai çipi ve İşe alım kapalı; Ofisi taşı kapalı + "Cevap bekliyor" (pencere ona değmez); yığın tohumun üç satırı. 08:00. | Tohum; sistem Ekip penceresi. | şerit sağ boşluğu 24 | | 2 |
| `olaylar__taslak_frank_ani_basin.png` | Taslak sayfası (kabuksuz): `customer.frank_intro` (tam kabukta: `olaylar__frank_ani`) ve `world.final_stretch_press` Sektör Telgrafı kağıdı (4 hafta içinde, Hafta 38 · Eylül 2027 = en erken tik 91). Altta dokuz gönderen türü başlık olarak. | DRAFTS 2 ve 6; adlı muhatap örneği `art/busts/counterparts.json` (Elif Yıldız), VC örneği Anchor Capital lideri. | gönderen türü kartı (yalnız sayfa), tek açık seçeneğin çipli bedel kutusu | Yıllık dosya / The annual file; Kendine not / Note to self; Alan adı aracısı / Domain reseller; Destek / Support | 5, 6, 9, 15, 16, 18, 21 |
| `olaylar__taslak_frank_ani_basin_en.png` | Aynısı İngilizce (dış gönderen monogramı DR). | Aynı. | | | 21 |

**Başka gruplarda çizilen olay durumları:** Ar-Ge keşif maili `../kisisel_arge/olaylar__arge_kesif.png` (o grubun
`tools/mail_gen.py`'si bu klasörün r2 `gen.py`'sinin anlık kopyası: r3'ün başlık, eylem satırı ve yığın değişikliklerini
almadı); karar beklerken kayıt kapalı sistem menüsü `../modallar_acilis/sistem__karar_bekliyor.png` (+ `_en`), kayıt
penceresi `../modallar_acilis/kayit__karar_bekliyor.png`.

**Tohum ekonomisi (kabukla aynı not):** üst bar tohumun kendi değerleri: BURN $1,5K/ay, NET +$2,5K/ay, RUNWAY Artıda;
Ekip penceresinin AYLIK MAAŞ YÜKÜ $43.600'ü burn'e yansımaz (tohum tik koşturmadı). Yan yana: `ekip__salt_okunur`. Dönem
özetinde Kasa ±0 ile NET +$2,5K/ay aynı nedenle yan yana: özet tohumun kendi defterinden basıldı. Maaştan hesaplansa
burn ~$45,1K/ay ve runway bir haftanın altına iner; tohum korunup not düşüldü.

## Yeni bileşenler (`olaylar.css`, sistem grameriyle)

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.pane-kicker .kind/.state` | Künye: tür + durum (amber yalnız Cevap bekliyor, uyarı son hafta) | okuma bölmesi başlık satırı |
| `.subj-row` | Konu satırı | Label `t-h2` |
| `.mh`, `.mh-l1` (`.sep`, `.gone`), `.mh-l2`, `.mh-date` | Mail başlığı: avatar, ad + unvan; Kime + sabit genişlikli tarih sütunu | HBox + iki satır; tarih Label'ı `custom_minimum_size.x` = ölçülen en kötü değer, unvan ve Kime `text_overrun_behavior = ELLIPSIS` |
| `.mono.m40`, `.mono.outlet.<yayın>` | 40 px monogram (gösterilen addan); yayın renginde çerçeveli monogram | `UiFactory.make_monogram(text, kind)` |
| `.mbody`, `.mbody.serif` | Gövde; Frank'in maili Source Serif 4 20/30 opsz 20 | RichTextLabel, `QuoteSerif` koyu varyasyonu |
| `.msig`, `.msig-row`, `.draft-mark` | Yapısal imza; TASLAK işareti (yalnız maket) | VBox |
| `.reply`, `.reply-head`, `.reply-acts` (`.note`), `.reply-foot` (`kbd`) | Cevabın bloğu; tek eylem satırı kuralı; açık kağıdın Esc ayağı | okuma bölmesi karar alanı |
| `.stake.sm` + `.opt-fx` | Sözlü sonuçlu tek açık seçenek: çiplerle bedel kutusu | aynı bedel kutusu, çip kipinde |
| `.fx.neutral` | Kutupsuz etki parçası, glifsiz | `EvChips` polarity `neutral` |
| `.odds`, `.fx.has-tip`, `.odds-tip`, `.mod.up/.down` | Zar oranı (bilgi tonu + noktalı çizgi, üstünde düz çizgi) ve modifier listesi | oran Label'ı `D_INFO`, alt çizgi StyleBox; liste `tooltip` paneli, satır başına `util/chevron_up/down` |
| `.answered`, `.answered-l` | Cevaplanmış belge kartı | geçmiş kipi |
| `.ib-row.is-notice`, `.ib-l3 .rk`, `.ib-row.is-history .ib-l3`, `.ch-k` | Hatırlatıcı satırı (dik, anahtar orta kalınlık); geçmiş satırında "Seçimin:" ve damga payı | kutu satırı varyasyonları |
| `.ib-row.is-selected.is-blocked/.is-history .ib-subj` | Seçili soluk satırın konusu ink-2 | seçili durum StyleBox + font rengi |
| `.ib-scroll`, `.ib-rows` | Kaydırılan liste (çubuk 12 px olukta) | ScrollContainer, sağ boşluk 12 |
| `.ib-empty`, `.pane-empty` | Liste ve bölme boş durumu, ortak gövdede aynı yükseklik | |
| `.rpt`, `.rpt-grid`, `.rpt-total`, `.hl`, `.star1` | Rapor tablosu, toplam satırı, öne çıkan satır, sayı + tek yıldız | rapor maili gövdesi |
| `.rec-head`, `.rec-facts`, `.rec-line` | Hatırlatıcı kaydı: başlık, olgular, dik anahtar + değer satırları | Dikkat kipi |
| `.portrait .gone-img` | Ayrılmış göndericinin kuyusu gri %55 | `avatar_grey.gdshader` |
| `.win-ro` (sağ boşluk 24) | Salt okunur şeridin düğmesi içerik kenarında biter | `win-ro` MarginContainer sağ 24 |
| `.gal`, `.gal-k` | Yalnız taslak sayfası: gönderen türü kartı | yok |

Kabuktan gelenler (`../kabuk/kabuk.css`): `.brand-sq`, BuildHUD kapalı eylem + gerekçe (`.bh-act .why`), yığın satırının
süre sütunu (`.notice .nwk`), kapalı Ofisi taşı (`.fbtn.is-disabled .why`), ofis katmanı (`.office-layer`, `.head-ic`).

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

SPEC §13'te zaten önerilenler (kapı, kuyruk, süzgeçler, "En yakın süre", kağıt çubuğu, Seçimin, damgalar) ve kabuğun
listesindekiler (marka, "No confirmed bugs.", yığın satırı) tekrar edilmedi.

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `MAIL_REPLY` | Your reply | Cevabın | Cevabın bloğu |
| `MAIL_TO` | To | Kime | başlık |
| `MAIL_TO_LINE` | {name} · {company} | {name} · {company} | başlık (kurucu adı boşsa `HR_ROLE_FOUNDER`) |
| `MAIL_KIND_DECISION` / `_PAPER` / `_REPORT` / `_MESSAGE` / `_ATTENTION` | Decision / Paper / Report / Message / Attention | Karar / Kağıt / Rapor / Mesaj / Dikkat | künye |
| `MAIL_ROW_REPORT` | report | rapor | liste satırı sağı |
| `MAIL_SENDER_ACCOUNTS` | Accounts | Muhasebe | DESK gönderen |
| `MAIL_SENDER_SUPPORT` | Support | Destek | DESK gönderen |
| `MAIL_SELF_NOTE` | Note to self | Kendine not | SELF gönderen |
| `MAIL_OUTSIDE_DOMAIN` | Domain reseller | Alan adı aracısı | OUTSIDE örneği |
| `MAIL_GREETING` / `MAIL_GREETING_TEAM` | Hello, / Hi, | Merhaba, / Merhaba, | müşteri / çalışan maili |
| `MAIL_SIGNOFF` | Regards, | Saygılarımla, | müşteri maili (çalışan kapanış yazmaz) |
| `PAPER_SET_ASIDE` | Set aside | Kenara koy | açık kağıdın ayağı (+ Esc tuş görseli) |
| `INBOX_EMPTY_WAITING` | Nothing waiting. | Bekleyen bir şey yok. | boş süzgeç |
| `INBOX_PANE_EMPTY` | No message selected. | Seçili mesaj yok. | boş bölme |
| `MAIL_RPT_CUSTOMER` / `_STARS` / `_SEATS` / `_PRICE` / `_TOTAL` | Customer / Stars / Seats / Price / Total | Müşteri / Yıldız / Koltuk / Fiyat / Toplam | satış raporu |
| `MAIL_RPT_CLOSED` | Closed last week: | Geçen hafta kapananlar: | satış raporu gövdesi |
| `MAIL_RPT_BOOKS` | Accounts on the books: {n} | Defterdeki hesap: {n} | satış raporu toplamı |
| `REC_REASON_KEY` | Reason: | Sebep: | hatırlatıcı satırı ve kaydı (değer ayrı: "sık kesinti şikayeti") |
| `REC_AM_KEY` + değer | Account manager: · not assigned | Müşteri temsilcisi: · atanmadı | hatırlatıcı kaydı (tohum düzeltmesi) |
| `REC_TENURE_KEY` + değer | Customer · 2 mo | Müşteri · 2 aydır | hatırlatıcı kaydı (`SALES_TENURE` ikiye bölünür) |
| `SUMMARY_ROW_TEAM_FOUNDER` | Team · incl. founder | Ekip · kurucu dahil | dönem özeti (`MONTH_ROW_TEAM`'in yerine; ya da sayı çalışana döner, soru 11) |
| konu alanları | An offer, We need to talk, One more team, My notice, An old friend, The annual file, It's Frank | Teklif, Konuşmamız gerek, Bir ekip daha, İstifa dilekçem, Eski bir dost, Yıllık dosya, Ben Frank | DRAFTS |
| zar (örnek, kart yok) | Offer a raise; Make the case to stay; Stays; If she stays; If not; Salary +$700/mo; {who} stays; If not, she leaves | Zam teklif et; Kalması için konuş; Kalır; Kalırsa; Kalmazsa; Maaş +$700/ay; {who} kalır; Kalmazsa ayrılıyor | `olaylar__zar_secenegi` |
| zar modifier'ları (örnek) | An offer from elsewhere; Low morale; A raise on the table | Elinde başka teklif var; Morali düşük; Zam teklifi | seam etiketleri (`EvDice.modifier_lines` `labels`) |
| `B2B_EV_RISK_EXPIRED` değişikliği | {customer} didn't write again. | {customer} bir daha yazmadı. | DRAFTS 3 |
| yeniden harf | No intervention · the counter keeps running | Müdahale yok · sayaç işlemeye devam eder | `EFFECT_RETAIN_IGNORE` (bugün küçük harfle başlayan tek çip) |
| yeniden harf | Monthly product note, Continue, Event of the quarter | Aylık ürün notu, Devam et, Çeyreğin olayı | `RND_NOTE_TITLE`, `UI_CONTINUE`, `SUMMARY_EVENT_QUARTER` (✦ atıldı) |
| tohum düzeltmesi | Account manager: not assigned | Müşteri temsilcisi: atanmadı | screens.md'deki düzeltme |

Frank'in her satırı (DRAFTS 1, 2 ve ek taslak) ayrıca taslaktır; çerçevelerde TASLAK işaretiyle.

## Açık sorular (Erdem)

1. **Marka bloğu**: çerçeveler (a) turuncu kare + "Project Unicorn" ile; (b) kabuk grubunda. Hangisi?
2. **Kapı yuvası alt satırı** göndereni yazıyor ("Cevap bekliyor · Frank Köseoğlu"), kart başlığını değil; salt okunur şerit
   "Frank Köseoğlu · Teklif". Kabul mü?
3. **Konu ve başlık**: kutu, bölme ve kapı yeni `subject`'i okur; `title` iç ad (geçmiş, toast) olarak kalır. İkisi tek alan mı olsun?
4. **Künyede tarih yok**: tarih mail başlığının 2. satırında, künye yalnız tür ve durum (SPEC §3.3 örneğinden sapma).
5. **Muhatap**: hesabın göndericisi masada tanışılan alıcı mı (`CounterpartSystem`), sektör unvanıyla mı (`B2B_CONTACT_*`)?
6. **Şirket masaları**: "Muhasebe" ve "Destek" adları; avatar belge glifi mi, oyuncunun şirket logosu mu?
7. **Frank'in maili**: selam ve kapanış yok, gövde baştan sona serif. Uygun mu?
8. **Hatırlatıcılar** mail değil kayıt (tarih ve okundu yok); aynı konuda bekleyen karar varken listede ve yığında gizli.
   Kayıt mail gibi bir gönderen alsın mı (ör. Destek)?
9. **İki sesli kartlar** (`funding.acquisition_offer`, `funding.seed_offer`): VC maili + Frank'in tek satırı aynı zincirde ikinci mail.
10. **Tanışma**: (A) Frank'in maili (taslak, çerçevede), (B) mühürlü sahne kurucunun notu olarak, Frank mail atmaz.
11. **Dönem özeti**: motor tohumda "2. Çeyrek 2026, Hafta 1-14" basıyor; kapanan çeyrek 1. çeyrek, hafta 1-13. Çerçeve
    doğrusunu çizdi; motorun başlık ve aralık hesabı düzeltilsin mi? Ekip satırı: "kurucu dahil" etiketi mi, yoksa satır
    çalışan sayısına mı dönsün (0 → 5, Ekip penceresindeki ÇALIŞAN ile aynı)?
12. Tohumun bilinen çelişkisi: Satış sebebi `live_bug_count` (12) ile "sık kesinti", risk sesi `bugs_confirmed` (0) ile
    kısa ses seçiyor. Çerçeveler motorun seçtiği sesi gösterir.
13. Hafta 15 çerçevelerinde üst bar tohum değerlerinde tutuldu; yalnız tarih ve Sıradaki değişti.
14. Haftalık satış satırları sistem sayfası 06'nın örneği, hesaplanmadı.
15. `customer.frank_intro` kartında `speaker` boş (MENTOR rozeti ve yüz çıkmıyor); `speaker: char_mentor_frank` eklensin mi?
    `mentor_advisory` notu artık mailin tekrarı (kabuğun yığınında Frank'in satırı olarak görünüyor): kalsın mı?
16. `B2B_LOCK_STALL_CAP` ikinci cümlesi ("Üçüncüsünü kimse beklemez.") kilidin bilgeliği; "İki kez oyaladın." yeter mi?
17. Gün sınırı kartlarında saat yok; oyuncunun İlgilen ile açtığı karar saat yazar mı?
18. Bülten kurucuya "sen" mi "siz" mi der?
19. Kağıt önizlemesinde seçenekler gizli (sistem kuralı); etiketleri soluk bir satırda görünsün mü?
20. Gerçek koşuda kutu hiç boş değil (tanışma); boş durum yalnız süzgeçte ve eski kayıtta. Kutu kapasitesi [WORKING].
21. EN başlıktaki "Sector Telegraph" çevrilmiş özel ad; gönderen iki dilde "Sektör Telgrafı".
22. **Kapı saati (kabuk sorusu 22'nin cevabı, koddan):** gün sınırı kartı gece adımında doğar ama motor adım sürerken
    pompalamaz (`engine.gd pump` → `TimeManager.is_batching()`); kart `clock_batch_ended`'de (`signals.gd` 47-48), adım
    08:00'e vardıktan sonra açılır. Kapılı çerçevelerin hepsi 08:00. Bu, incelemenin "risk ve istifa gün ortasında gelir"
    notunu da düzeltir: ikisi de günlük tikin içinde doğar (B2B risk girişi, `HRSystem.daily_tick`), saat yazmaz.
23. **Hafta 11'in iki türetmesi:** `kilitli_secenek` / `gecmis_karar` H11'de Ege'ye "Söz ver" verildiğini, `uzun_gecmis`
    H11'de Ege'nin şikâyetine "Durumu açıkça anlat" denildiğini varsayar. İkisi ayrı türetilmiş koşu; aynı koşu
    istenirse uzun geçmişe retention satırı eklenir.
24. **Yığın ve hatırlatıcı:** Ege'nin kararı açıkken Ege hatırlatıcısı listede de yığında da yok (kabukla aynı kural).
25. **Açık kağıdın ayağı:** "Kenara koy" + Esc görseli öneri; SPEC §6 Esc'i söylüyor ama ekranda bir ipucu çizmiyor.
    Kalsın mı, yalnız klavye mi?
26. **Zar çerçevesi:** gönderilmiş kartta `check` yok; çerçeve GDD §9'un gramerini bir istifaya giydirdi (oranlar, zam
    tutarı ve modifier etiketleri örnek). İlk zarlı kart hangisi olacak? Oran tonu bilgi rengi (`--info`) + noktalı
    çizgi: GDD "farklı renk tonu" diyor, ton seçimi onay bekliyor.
