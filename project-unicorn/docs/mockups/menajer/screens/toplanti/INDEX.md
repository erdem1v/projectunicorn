# Toplantı · A4 ekran maketleri (grup "toplanti")

Görüşme paneli (sağ dok, ofis görünümünün 0,34'ü), pazarlık, VC odası, davet halkası ve arama kartı, erteleme toastı,
kurucunun yolculuğu ve term sheet masası; onaylı Menajer Masası diliyle, 1920×1080 (iki kare 1536×864 mantıksal, ölçek
1,25). Dört kare İngilizce (`_en`, SPEC §3.4 en kötü durum kontrolü). Hepsi onay bekliyor.

- **Kabuk tek yerden çizilir.** Üst bar, ray, haber şeridi, ofis plakası ve A2 baş ikonları (`noicons` plaka + `.head-ic`),
  BuildHUD, bildirim yığını, Ofisi taşı, toast ve şehir haritasındaki yolculuk (yol, kurucu diski, çipler, "Yolu geçmek
  için tıkla" ipucu) kabuk grubunun `../kabuk/tools/gen.py` ve `../kabuk/kabuk.css` dosyalarından okunur (salt okunur;
  `tools/gen.py` onu modül olarak yükler, sayfalar `kabuk.css`'i bağlar). Kabukta bir değişiklik bir sonraki
  `python gen.py`'de bu karelere geçer; kabuğun işaretlemesi değişirse üreteç `assert` ile durur, sessizce kaymaz.
- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, ikonlar, kırpım kuralı, üst bar ızgarası, `.opt`,
  `.tag`, `.stamp`, `.mchip`. Sistemin ve kabuğun eksiği `toplanti.css`'te (aşağıda "Yeni bileşenler"); sistem ve kabuk
  klasörlerine hiçbir şey yazılmadı (kit kopyaları ve önbellekleri `tools/syskit/`).
- Frank = aday A (`portraits/frank_cand_a.png`), kurucu = `founder_01`. Yağlı boyalar yok.
- Üst barın marka bloğu: karar 14 (a), kabuğun `brand_block("a")`'sı.
- Muhataplar `art/busts/counterparts.json`'dan: satışta tohumun 2★ adayı Karadeniz Fabrika (Elif Yıldız, Sena Uysal),
  VC'de Meridian Growth (Tolga Erdem, Sena Koç, Kaan Demir), term sheet'te Bosphorus Partners (Tolga Polat) ve Anchor
  Capital (Kerem Kaya).
- **Portreler yer tutucudur.** Muhatap diskleri bugünkü büstlerden kırpıldı; karar 13'ün düzeltilmesini istediği A3
  kusurları görünür: açık tenli yüzler `ink-2`'ye çok yakın (örnek #E2D4C4, `ink-2` #E9E4DA) ve gözlük düz siyah bant
  (Elif Yıldız, `bust_lead_14_2_0_buyer`). Faz C'nin düzeltilmiş çekimi (SPEC §3.5 pozlama kuralı) gelince değişir.
- Toplantı odası: `art/office_safe_1920_meet_dock.png` (masa dokun solunda çerçeveli); davet: kabuğun İş hanı katmanı;
  yolculuk: kabuğun `trip_map()`'i (`office_safe_1920_city.png`).

Yeniden üretmek: `python tools/gen.py` (HTML'ler `build/`), `bash tools/render_all.sh <tur> [ad ...]` (PNG'ler bu klasöre,
kopyası `rounds/<tur>/`; 1536 kareleri `1536 864 1.25` ile). Turlar: r1 (29 kare), r2 (yazışma akışı, "Masada", geçmiş
adımlar, term sheet sahnesi), r3 (term sheet şeridi, kadran rengi, dönüş yolu, ret maliyeti, seed kapanışı), **r4**
(eleştiri turu, aşağıda; 33 kare, hepsi tam boy okundu, 1:1 ve 2-3 kat kırpımlar: arama halkası, kart ile yığın, dok
başı TR/EN, yazışma solması, sorgu ve pazarlık güvertesi, term sheet başı, ok, kadran anahtarı, alt bar).

## r4: eleştiri turu (`_critique/toplanti_modallar_acilis`)

| No | Ne değişti |
|---|---|
| 1 | Davet kareleri `office_safe_1920_noicons.png` + kabuğun A2 baş ikonları (koyu disk, krem glif). Telefon çalarken kurucunun baş yuvasını halka alır (içinde A2 `phone` ikonu); VC erteleme karesinde halka söner ve kurucunun ikonu geri gelir. |
| 2 | BuildHUD kabuğun: "Düzeltme başlat" kapalı, yanında "Doğrulanmış hata yok." (`fix_run_refusal = no_confirmed_bugs`). |
| 4 | Üst bar yuvası evre başına tek durum (kabukla aynı): **davet** "Sıradaki · 14:00 · Karadeniz Fabrika", saat işler (satış 1x; VC kartı saati durdurarak açılır, II); **yolculuk** gidiş ve dönüş "Şimdi", tuşlar kapalı, amber yok; **görüşme** "Görüşmede · 14:00 · Karadeniz Fabrika", tuşlar kapalı. Görüşmenin saati hafta çubuğunda elmasla işaretli. Yolculuk kuralı kodun kuralıdır: `office_travel.gd` "saat donuk, Space ve hız tuşları yolculukta bir şey yapmaz" der; baseline `travel__ishani_vc_20`'deki yanık 1x bugünkü TopBar'ın donmayı göstermemesidir. Kabuğun `ustbar__yolculuk`'u zaten böyle çizer; kabukta değişiklik gerekmez. |
| 5 | Yolculuk kabuğun `trip_map()`'idir: kalın koyu dikiş + beyaz kesik, 3 px beyaz halkalı disk, bina ikonlu varış çipi, "Mevcut" taç çipi, "Yolu geçmek için tıkla ya da Esc'ye bas." ipucu. `yolculuk__gidis` kabuğun `ustbar__yolculuk`'uyla aynı kod ve aynı durum; `yolculuk__donus` diski kabuğun kendi yolunda t = 0,75'e taşır (dönüşün dörtte biri). |
| 9 | Toastlar kabuğun: "Ertelendi · Telefon çalmaya devam ediyor." ve "Ertelendi · Toplantı gelecek haftaya ertelendi. Bir daha ertelenemez." |
| 11 | Bildirim yığını kabuğun hafta 14 tohumundan (`SEED_INBOX`): bu tur kabuk onu Nordica "Bir ekip daha · 2 hafta", Ege Sigorta, Selin Kaya olarak değiştirdi; kareler bunu gösterir. VC dünyasında (hafta 9 harness) yığın yok. |
| 12 | Kırmızı yalnız tehlikede: Geçiştir alt satırı `ink-3`; başarısız zar nötr ✕ çerçeve etiket (`vc_ret`'te ✕ DÜRÜST, ✕ ANLATI); TUTUM dolgusu her bantta nötr (`bar-fill`), bant çentiklerde ve kelime etiketinde (sıcak `pos`, öteki bantlar çerçeve); kadran iğnesi sonuç ne olursa olsun mürekkep. Kırmızı kalanlar: "Anlaşma olmadı", "Bu sefer değil", hakaret bölgesi, "Masadan kalktılar. Teklif gitti." ve Masayı zorla'nın "Başarısızsan masa kapanır." satırı (yıkıcı sonuç, kural 2). "Güvenli" ile "riskli" zar çelişkisi: alt satır kazık büyüklüğünü (±5, 65 tavan), zar şansı (%60) söyler; alt satır "Kaybı az, ..." diye yeniden yazıldı (metin tablosu). |
| 13 | "Spin" TR'de "Parlat" önerisiyle onay listesine girdi; "Seed" de listeye işaretlendi (aşağıda). |
| 14 | Hakaret: "Teklif et"in altında hep görünen `neg-ink` satır "Bu rakam masayı devirir.", ipucu yok; seçenek tehlike tonunda (aşağıdaki tablo da öyle der). |
| 15 | Karşı rakam karesinde anlaşma satırı "Kabul edersen: 19 koltuk × $46 = $874 MRR". |
| 16 | Yazışma alta yaslı: en yeni satır güverteye oturur, kısa yazışmada boşluk üstte kalır. |
| 17 | Kadranın altında anahtar: yay "İtme şansı", iğne "Son zar" (iğne yalnız bir itiş olduysa); sütun başı "Şans ve sonuç". |
| 21 | Portre kusurları yukarıdaki notta. |
| 22 | EN kareler: `toplanti__satis_locked_en`, `toplanti__vc_sorgu_en`, `termsheet__table_en`, `davet__satis_kart_en`. EN geçişi bir taşma buldu: "AT THE TABLE" 56 px anahtar sütununda iki satıra kırılıyordu; dok başının anahtar sütunu 88 oldu (en kötü değer × 1,08 + 2). |
| 23 | Arama kartında yalnız unvan; şirketi gövde satırı söyler. Kart, üç satırlık yığının üstünde 24 px yukarı alındı. |
| 24 | Term sheet oku rakamlarla aynı boyda, `ink-3`, rakamların orta çizgisinde. |
| 25 | Term sheet: içerik başın altına yaslı; kasa şeridi alt barda, paranın altında tek satır ("Kasa: $330,0K · Runway: 220 ay · Kapanan masa: 0/3"; runway üst barın biçiminde: 942 hafta × 7 / 30 = 220 ay); başta kişi önce ("Tolga Polat", sonra "Kurucu Ortak · Bosphorus Partners", arketip) ve teklifin süresi ("Teklif · 2 hafta kaldı", üst barın term sheet yuvasıyla aynı metin, `warn`, saat glifi; SHEET_VALIDITY_WEEKS 3, bir hafta geçmiş). Fon kalkınca süre gösterilmez. |
| 26 | "Teklif · $55" ve "Karşı rakam · $46" aynı ayraçla. |
| 27 | Kaymış yazışmanın üstünde 24 px solma. |
| 28 | `toplanti.css` sistemin linter'ıyla temiz: 160'lık kenar boşluğu `.tt-w` sütununa (genişlik 1600) döndü, halka `translate(-50%, -50%)` ile ortalanır, iç ses satırı metin sütununa `left: 44px` ile oturur, diğer teklif satırı ve gerekçesi bir sarmalayıcıda `gap`'le. |
| 37 | "Taç": A4'te mevcut ofis çipinin taç glifi. Kulenin taç ışığı (`--office-shot=city:<saat>:crown`) 3B sahne ışığıdır; baseline'da çekimi yok, Faz F'te gelir. |

## Veri

| Kaynak | Ne için |
|---|---|
| Tema tohumu (`data/screens.md`, `main.gd _seed_theme_surface`, hafta 14), kabuğun `SEED` ve `SEED_INBOX`'ı | Satış ve davet kareleri: üst bar ($10.000, Artıda, MRR $4,0K), ray rozetleri, bildirim yığını, Karadeniz Fabrika 2★ ve okuması "Ölçülü bir alıcı. Önce kararlılığı sorar." |
| `--meeting-shot` / `--negotiation-shot` baseline'ları (satış dünyası, `_seed_sales_world`) | Sorular, cevaplar, iç ses, kapanış satırları, İkna yüzdeleri (%69, %34, %66, %5), kilit gerekçesi, sonuç kartı satırları. Şirket ve kişiler tohumun adayıyla değiştirildi. EN metinler CSV'nin `en` sütunundan, `PH:` önekleri atıldı. |
| `--meeting-shot` VC türleri (fon `meridian`, randevu bir kez kaydırılmış, prova) | VC kareleri: üst bar ($48.000, MRR $125K, hafta 9), satırlar `VC_*` / `SEED_*`, sonuç kartları baseline'la birebir. |
| `--vc-shot` (PromptPilot dünyası, kasa $330.000, runway 942 hafta) | Term sheet kareleri: kollar, oranlar, kadran, yatırım, kasa ve runway, "Kapanan masa". |
| Oyunun kuralından türetildi | Karadeniz Fabrika masası (`lead_14_2`): 19 koltuk (`SEAT_BAND` 2★ 15-30 × `mix_unit`), çapa $50, rezerv $46, hakaret çizgisi $59, sabır 3; karşı rakam $55 teklife $46. Kapasite 63/261. VC zar sözleri: kurucu karizma 4 → Odayı oku %45 riskli, Dürüst %65 güvenli (prova +2), Spin %30 tehlikeli, Geçiştir %60 riskli (±5, tavan 65: `GECISTIR_*`), Masayı zorla %30 tehlikeli. Term sheet süresi `SHEET_VALIDITY_WEEKS` 3. |

Metin: TR, CSV'deki gibi; `PH:` önekleri atıldı (satış diyaloğu hâlâ yer tutucu, yazım turu bekliyor), tireler yeniden
yazıldı, büyük harf yalnız sistemin kuralıyla. EN karelerde tohumun kurucu adı "Kurucu" EN'de "Founder" yazıldı (oyunda
oyuncunun yazdığı addır).

## Çerçeveler

Sütunlar: durum, veri, yeni bileşen, yeni metin (tam liste aşağıda), açık soru numaraları.

| PNG | Gösterdiği | Veri | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `toplanti__satis_probe.png` | Satış görüşmesi açılır: Elif'in ilk sorusu güverteye oturur, üstte boşluk; iç ses, üç numaralı cevap. Başta 96'lık portre, ad (`t-h2`), unvan · şirket, yıldızlar ve okuma; "Masada" satırı (konuşan mürekkep halkada); TUTUM ılık %69. Üst bar "Görüşmede · 14:00 · Karadeniz Fabrika", hız tuşları kapalı, 14:00 elması. | Tohum + `meeting__probe` | dok, dok başı, Masada satırı, TUTUM ölçeri, yazışma satırları, numaralı seçenek | Görüşmede; Masada; Satış görüşmesi (yeniden harf) | 2, 15 |
| `toplanti__satis_locked.png` | İkinci soru (Sena): "Gücü göster" kilitli, kilit ve etiket soluk, gerekçe tam mürekkep; numaralar yalnız açık seçeneklerde; "Teklife geç" zar + "tehlikeli". TUTUM temkinli %34 (çerçeve etiket). | `meeting__locked` | kilitli seçenek, zar sözü | | |
| `toplanti__satis_locked_en.png` | Aynı durum İngilizce: "AT THE TABLE", "ATTITUDE", "Persuasion 34%", kilitli seçeneğin iki satırlık etiketi. | Aynı, CSV `en` | | | |
| `toplanti__satis_won.png` | Masa rakama kesti: dört adım, kapanış satırı, tek amber "Rakamı konuş ⏎". Yazışma panele sığar, alta yaslı. | `meeting__won` | dok altlığı, Enter glifi | | |
| `toplanti__satis_lost.png` | Kayıp: TUTUM soğuk %5 (nötr dolgu, çerçeve "soğuk" etiketi); sonuç kartı ✕ "Anlaşma olmadı" (kırmızı), masaya etkisi, ilişki, hafıza; Devam. | `meeting__lost` | sonuç kartı | | |
| `toplanti__satis_handoff.png` | Perde 2 açılışı: künye "Satış görüşmesi · Rakam", SABIR 3 kutu; cetvel: $30-$70 bant, çapa çentiği, kırmızı hakaret bölgesi $59'dan, tutamak $50; "19 koltuk × $50 = $950 MRR", "Kapasite: 63/261"; Teklif et / Masadan kalk. | Türetilmiş masa | fiyat cetveli, sabır kutuları | Rakam (künye) | 6 |
| `toplanti__pazarlik_open_1536.png` | Aynı açılış 1536×864'te (dok 500 mantıksal): sıkışık üst bar, ikon ray, yazışma kayar. | Aynı | | | 10 |
| `toplanti__pazarlik_countered.png` | Teklif $55, karşı rakam $46: iki rakam satırı ("Teklif · $55", "Karşı rakam · $46"), cetvelde karşı rakam çizgisi, "Kabul edersen: 19 koltuk × $46 = $874 MRR", sabır 2/3, "Kabul et" açıldı. | Türetilmiş | rakam satırı | Teklif · {price}, Karşı rakam · {price}, Kabul edersen: {line} | |
| `toplanti__pazarlik_insult.png` | Fiyat $62 hakaret bölgesinde: tutamak ve fiyat kırmızı, "Teklif et" tehlike tonunda (`neg-tag` zemin, `neg-ink` etiket) ve altında hep görünen `neg-ink` gerekçe "Bu rakam masayı devirir." | `negotiation__insult` | tehlike tonlu seçenek | | |
| `toplanti__pazarlik_confirm.png` | Karşı rakam kabul, imza: ✓ "Anlaşma imzalandı" + İMZALANDI damgası, "19 koltuk × $46 = $874 MRR · Kapasite: 63/261", ilişki. | Türetilmiş | damgalı sonuç kartı | | |
| `toplanti__vc_open.png` | Yatırımcı görüşmesi · Odayı oku · 1/4: Tolga'nın açılışı güverteye oturur, oda okuması, tek seçenek "Odayı oku: karşındakini tart." riskli; HAFIZA "Randevuyu kaydırdın"; "Toplantıdan çekil" (yalnız 1. adımda, Esc). TUTUM ılık 46. | VC open | Hafıza satırı | | 7, 14 |
| `toplanti__vc_sorgu.png` | Sorgu · 3/4: Kaan sorar; Dürüst "Prova edildi" etiketiyle güvenli; "Parlat: zayıflığı güce çevir." tehlikeli; Geçiştir riskli, alt satırı `ink-3` "Kaybı az, ama masa buradan çıkmaz (65 tavan)." Kurucunun Anlatı adımı ✓ ANLATI. TUTUM sıcak 71. | VC sorgu | işaret etiketi, alt satır | Parlat (Spin), Geçiştir alt satırı | 20 |
| `toplanti__vc_sorgu_en.png` | Aynı durum İngilizce ("Interrogation · 3/4", "Rehearsed", "Spin: turn the weakness into a strength.", "Little to lose, ..."). | Aynı, CSV `en` | | | |
| `toplanti__vc_sheet.png` | Kapanış · 4/4, sıcak oda: ✓ "Teklif gelecek", "Teklif var · 3 hafta geçerli", "Tolga Erdem: ılık → sıcak", hafıza satırı; Devam. | VC sheet | | | |
| `toplanti__vc_callback.png` | Ilık oda, geri dönüş: "Yeniden görüşülecek" uyarı renginde takvim glifiyle, "Geri dönüş · Koşul: Aktif hata < 3". | VC callback | | Geri dönüşü kabul et: koşulu tuttur. | 5 |
| `toplanti__vc_ret.png` | Soğuk oda: ✕ ANLATI ve ✕ DÜRÜST nötr çerçeve etiket, "Bu sefer değil" (kırmızı), "Reddetti · Marka −3", üst barda MARKA 47; Frank'in çıkış satırı kendi satırında, portre A ve serif. Kaymış yazışmanın üstü solar. | VC ret | Frank satırı | | 8 |
| `toplanti__vc_seed.png` | Seed görüşmesi · Kapanış: "Odayı kazandın.", "Kâğıt yolda. İyi bir tur olacak.", "Açık koşullar · süresiz". Üst bar evresi Traction. | VC seed (evre 2) | | Seed görüşmesi | 19 |
| `toplanti__vc_long.png` | En dolu panel: dört adımın tamamı, ılık kapanış, iki seçenek (geri dönüş güvenli; masayı zorla tehlikeli, `neg-ink` alt satır). | VC long | | Masayı zorla: şimdi karar ver. | |
| `toplanti__vc_long_1536.png` | Aynı panel en dar dokta (1536×864, 500 mantıksal); 88'lik anahtar sütunu sığar. | VC long, `--shot-scale=1.25` | | | 10 |
| `davet__satis_halka.png` | "Görüşmeye git" sonrası ofiste telefon çalıyor: kurucunun baş yuvasında A2 telefon ikonu ve amber zaman halkası (kart kapalı); öteki başlarda kabuğun A2 ikonları. Üst bar "Sıradaki · 14:00 · Karadeniz Fabrika", 1x. | Tohum, kurucu başı `office_safe_1920_heads.json` | arama halkası | | 11, 12 |
| `davet__satis_kart.png` | Kart açık: "Gelen arama · 14:00" amber künye, Elif'in 40'lık yüzü, adı, unvanı, "Karadeniz Fabrika adına Elif Yıldız görüşmeye hazır.", amber Kabul et + Ertele. Yığının 24 px üstünde. | `MEETING_INVITE_SALES` | arama kartı | Gelen arama · {hour}:00 | 11 |
| `davet__satis_kart_en.png` | Aynı kart İngilizce: "Incoming call · 14:00", "Procurement Lead", "Elif Yıldız of Karadeniz Fabrika is ready to meet.", Accept / Postpone; üst bar, BuildHUD, yığın, ray ve şerit EN. | Aynı, CSV `en` | | | |
| `davet__vc_kart.png` | Fonun haftası geldi: kart ilk çalıştan açık, saat durdu (II), üst bar "Sıradaki · 10:00 · Meridian Growth", not "Toplantı yalnız bir kez ertelenebilir. Fonun bir sonraki toplantısında ikna −2." | `MEETING_INVITE_VC`, `MEETING_POSTPONE_ONCE` | kart notu | | 11 |
| `davet__ertele_satis.png` | Ertele: kart kapanır, telefon çalmayı sürdürür; kabuğun toastı "Ertelendi · Telefon çalmaya devam ediyor." | `MEETING_POSTPONED` | | (kabuğun listesinde) | |
| `davet__ertele_vc.png` | VC erteleme: halka söner, kurucunun ikonu geri gelir, üst bar yedek satıra düşer ("Mesai bitimi · 7 saat"); toast "Ertelendi · Toplantı gelecek haftaya ertelendi. Bir daha ertelenemez." | `MEETING_POSTPONED_VC` | | (kabuğun listesinde) | |
| `yolculuk__gidis.png` | Kabuğun yolculuğu: yol, kurucu diski, "Mevcut · İş hanı" taç çipi, varış çipi "Karadeniz Fabrika · Elif Yıldız", geçme ipucu; üst bar "Şimdi · 14:00 · Karadeniz Fabrika", tuşlar kapalı. Kabuğun `ustbar__yolculuk`'uyla aynı. | Şehir plakası | (kabuğun) | | 13 |
| `yolculuk__donus.png` | Dönüş 16:00: disk kuleden ofise dönüşün dörtte birinde; üst bar "Şimdi · Ofise dönüş", tuşlar kapalı. | Aynı | | Ofise dönüş | 13 |
| `termsheet__table.png` | Term sheet masası (tam ekran sahne): başta Tolga Polat, "Kurucu Ortak · Bosphorus Partners", arketip, "Teklif · 2 hafta kaldı", SABIR 1/2 (son kutu uyarı). İçerik başın altına yaslı. Belge köşeli teklif kâğıdında üç kol (1-3), seçili kol mürekkep işaretli, "İtir"; "$12M → $16M" ve oran dökümü. Kadran %63, altında "İtme şansı · Son zar" anahtarı, iğne başarısız itişte (mürekkep); "Reddettiler. Olduğu yerde kaldı: $12M.", fonun satırı, Frank "Bir hamlen kaldı." Alt bar: Masadan kalk (tehlike), "$2,2M yatırım" ve altında "Kasa: $330,0K · Runway: 220 ay · Kapanan masa: 0/3", tek amber İmzala. | `vc__table` | term sheet sahnesi, kol, kadran ve anahtarı, süre, Frank satırı | Yönetim kurulu, Şans ve sonuç, İtme şansı, Son zar, kasa satırı | 6, 7, 8, 9, 21 |
| `termsheet__table_en.png` | Aynı masa İngilizce ("Founding Partner · Bosphorus Partners", "Offer · 2 weeks left", "Odds and result", "Push chance · Last roll", "Cash: $330.0K · Runway: 220 mo · Tables closed: 0/3"). | Aynı, CSV `en` | | | |
| `termsheet__table_final.png` | Sabır bitti: son teklif uyarı renginde, İtir kapalı, "Bu kadar. Daha fazla esnemiyoruz.", Frank "Sabırları bitti. Başka masa yok." $1,9M. | `vc__table_final` | | | |
| `termsheet__table_walk.png` | Fon kalktı: "Masadan kalktılar. Teklif gitti." kırmızı, süre yok, İmzala kapalı, sol düğme "Masadan ayrıl", "Kapanan masa: 1/3". | `vc__table_walk` | | Masadan ayrıl | |
| `termsheet__table_other.png` | Diğer teklif gösterildi (Anchor, kaldıraç +%10): kadran %85 (iğne yay ucunda, anahtar yalnız "İtme şansı"), "Kıpırdamadılar. Teklif aynı.", diğer teklifin belgesi + kapalı "Diğer teklifi göster" ve gerekçesi. | `vc__table_other` | diğer teklif satırı | | |
| `termsheet__seed_table.png` | Seed masası: Yatırım kolu $130.000 → $140.000, Yönetim kurulu kilitli ve gerekçesi kol satırında; Masadan kalk kapalı, gerekçe yanında; "$130,0K yatırım", altında "ima edilen değerleme $812.500" ve kasa satırı; Frank'in seed açılış satırı. | `vc__seed_table` | | | 9 |

## Yeni bileşenler (`toplanti.css`, sistem grameriyle)

Kabuğun bileşenleri (üst bar durumları ve `.topbar.is-held`, `.brand-sq`, `.head-ic`, `.bh-act .why`, `.notice`, `.fbtn`,
`.toast.at`, `.road`, `.road-disc`, `.mchip.is-dest`, `.skip`) `kabuk.css`'tedir ve kabuğun INDEX'inde anlatılır.

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.dock`, `.dk-head`, `.dk-kick` | Sağ dok (0,34 W, üst bardan şeride), `surface-4` başlık, künye cümle düzeninde | `MeetingDock`, `MeetingHeader` varyasyonları |
| `.dk-who`, `.dk-id`, `.dk-read` | 96'lık disk, ad `t-h2`, unvan · şirket, yıldız + okuma satırı | aynı başlık |
| `.dk-seats`, `.seat3` | "Masada": masadaki herkes 24'lük yüz + ad; konuşan `ink-1` halka. Baş satırlarının anahtar sütunu 88 ("AT THE TABLE" × 1,08 + 2) | HBox, `make_person_avatar` 24 |
| `.tut` | TUTUM: tek nötr dolgu (`bar-fill`), 25 / ılık / sıcak bant çentikleri, şimdi işareti, kelime etiketi (sıcak `pos`, öteki bantlar çerçeve), satışta "İkna %n" | `_draw_gauge` yerine ProgressBar + çentik |
| `.pat` | Sabır kutuları: dolu `ink-2`, harcanmış boş, son kalan `warn` | `_draw_patience` token'ları |
| `.dk-mem` | HAFIZA satırı | Label |
| `.dk-flow`, `.is-scrolled`, `.tr`, `.tr.is-you`, `.tr-quiet`, `.tr.is-frank`, `.tr.is-figure`, `.is-past` | Yazışma alta yaslı (en yeni satır güverteye oturur); taşınca eski satırlar 24 px solmanın altından kayar. Muhatap satırı, kurucunun belge köşeli kutusu ve zar etiketi (✓ `pos` / ✕ çerçeve), iç ses kenar notu, Frank serif satırı, Perde 2 rakam satırı; oynanmış adım bir mürekkep basamağı geride | ScrollContainer alta kenetli + üst solma; `_counterpart_row`, `_founder_row`, `_state_row` |
| `.opt.mo`, `.kcap`, `.mo-die` | Numaralı görüşme seçeneği (1-5 tuşu kapakta), cümle ya da komut etiketi, işaret etiketi, alt satır (`ink-3`; yıkıcı sonuçta `neg-ink`), zar + risk sözü, kilitli, hakaret bölgesinde tehlike tonu (`.is-alert`) ve hep görünen gerekçe satırı | `meeting_panel_option.gd` |
| `.mres` | Sonuç kartı: belge köşesi, glif + başlık (pos ✓, neg ✕, warn takvim), damga, anahtar/değer satırları | `_result_card` |
| `.dk-foot` | Toplantıdan çekil (ikincil) + tek amber Devam ⏎ | footer |
| `.rul` | Fiyat cetveli: bant, hakaret bölgesi (`neg`), çapa çentiği, karşı rakam izleri, tutamak, tutulan fiyat, anlaşma ve kapasite satırları | `meeting_ruler.gd` |
| `.callring`, `.callcard` | Telefon: kurucunun baş yuvasında A2 telefon ikonu + amber zaman halkası; arama kartı belge köşeli float, amber künye, yüz, ad, unvan, satır, Kabul et + Ertele, not | `meeting_invite.gd` |
| `.tt`, `.tt-w`, `.tt-head`, `.tt-due`, `.tt-sheet`, `.lev`, `.dial`, `.dkey`, `.tt-say`, `.tt-other-w`, `.tt-frank`, `.tt-foot` | Term sheet sahnesi: tam genişlik baş ve alt bant, içerik 1600'lük sütunda; baş (kişi, unvan · fon, arketip, süre, sabır), belge köşeli teklif kâğıdı ve kolları (ok rakam boyunda `ink-3`), kadran (şans yayı `bar-emph`, iğne mürekkep) ve anahtarı, sonuç satırı, fon satırı, diğer teklif, Frank satırı, alt bar (para, altında kasa satırı) | `term_sheet_table_scene.gd`, `radial_dial.gd` (yeşil/kırmızı yaylar kalkar) |

## Yeni ve değişen oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

Erteleme toastları (`MEETING_POSTPONED`, `MEETING_POSTPONED_VC`) ve yolculuk ipucu kabuğun listesindedir; burada tekrar
edilmez.

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `TOPBAR_IN_MEETING` | In a meeting | Görüşmede | üst bar yuvası, oturum sürerken (alt satır SPEC'in `{time} · {company}` kalıbı) |
| `TOPBAR_TRIP_HOME` (yeni) | Back to the office | Ofise dönüş | üst bar yuvası, dönüş yolunda kabuğun "Şimdi" etiketinin altında |
| `MEETING_AT_TABLE` | At the table | Masada | dok başı, masadakiler satırı |
| `MEETING_KICKER_SALES` / `_VC` / `_SEED` yeniden harf | Sales meeting / Investor meeting / Seed meeting | Satış görüşmesi / Yatırımcı görüşmesi / Seed görüşmesi | künye cümle düzeni (SPEC §3.3). **"Seed" izinli ödünç kelimelerde yok:** TR onayı ("Seed" kalsın mı, "Tohum" mu; CSV'de `SEED_SECTION_TITLE` "Seed turu", `TICKER_01` "Tohum yatırımcıları") |
| `VC_BEAT1_LABEL` .. `VC_BEAT4_LABEL` yeniden harf | Read the room · 1/4, Narrative · 2/4, Interrogation · 3/4, Closing · 4/4 | Odayı oku · 1/4, Anlatı · 2/4, Sorgu · 3/4, Kapanış · 4/4 | künye |
| `VC_B3_SPIN`, `VC_APPROACH_SPIN` TR yeniden yazımı | Spin: turn the weakness into a strength. / Spin | Parlat: zayıflığı güce çevir. / Parlat | sorgu seçeneği ve kurucunun zar etiketi; "Spin" izinli ödünç kelime değil (öneri; seçenekler: "Tersine çevir", "Cilala") |
| `VC_B3_DEFLECT_CAP` yeniden yazım | Little to lose, but the table stops here ({cap} ceiling). | Kaybı az, ama masa buradan çıkmaz ({cap} tavan). | Geçiştir alt satırı; "Güvenli" zarın "riskli" sözüyle çelişiyordu (alt satır kazığı, zar şansı söyler) |
| `MEETING_INVITE_KICKER` yeniden harf | Incoming call · {hour}:00 | Gelen arama · {hour}:00 | arama kartı künyesi |
| `MEETING_OFFER_ROW` yeniden harf | Offer · {price} | Teklif · {price} | Perde 2 rakam satırı |
| `NEG_COUNTER` yeniden yazım | Their number · {price} | Karşı rakam · {price} | Perde 2 rakam satırı, teklif satırıyla aynı ayraç |
| `NEG_DEAL_IF_ACCEPT` (yeni) | If you accept: {line} | Kabul edersen: {line} | karşı rakam varken cetvelin anlaşma satırı (`{line}` = `NEG_CONFIRM_LINE`) |
| düğme yeniden harf | Make the offer, Accept, Walk away, Their last number, Push, Sign, Walk away, Leave the table, Show the other offer | Teklif et, Kabul et, Masadan kalk, Son rakam, İtir, İmzala, Masadan kalk, Masadan ayrıl, Diğer teklifi göster | `NEG_OFFER`, `NEG_ACCEPT`, `NEG_WALK`, `NEG_LAST_OFFER`, `TERM_PUSH`, `TERM_SIGN_OK`, `TERM_WALK_OK`, `TERM_LEAVE`, `TERM_SHOW_OTHER` |
| etiket CSV'de cümle düzeni, çizimde `Fmt.upper` | Attitude, Memory, Patience, The offer on the table, Result, On the table, Relationship, What they'll remember | Tutum, Hafıza, Sabır, Masadaki teklif, Sonuç, Masaya etkisi, İlişki, Hafızaya yazılan | `MEETING_ATTITUDE`, `MEETING_MEMORY`, `NEG_PATIENCE`/`TERM_PATIENCE`, `TERM_OFFER_HEADER`, `TERM_RESULT_HEADER`, `MEETING_RES_*` |
| `TERM_RESULT_HEADER` yeniden yazım | Odds and result | Şans ve sonuç | term sheet sağ sütun başı ("Sonuç" kadranı anlatmıyordu) |
| `TERM_DIAL_CHANCE`, `TERM_DIAL_ROLL` (yeni) | Push chance / Last roll | İtme şansı / Son zar | kadranın anahtarı (yay, iğne) |
| `TERM_CASH_RUNWAY` yeniden yazım | Cash: {cash} · Runway: {runway} | Kasa: {cash} · Runway: {runway} | term sheet alt barı; `{runway}` üst barın biçimi (`net_runway_text`: "220 ay", "Artıda", ayın altında hafta); `_ONE` varyantı düşer |
| term sheet başında süre | Offer · {n} weeks left | Teklif · {n} hafta kaldı | üst barın term sheet yuvası metni (sistemin `next_offer` satırı), yeni anahtar yok |
| `TERM_LEVER_BOARD` TR | Board | Yönetim kurulu | kol adı; "Board" izinli ödünç kelime değil |
| tire yeniden yazımı | "{investor}. Sit. My time is short. Show me why you called me here." · Read the room: take their measure. · Take the callback: meet the condition. · Push the table: decide now. | "{investor}. Otur. Vaktim kısa. Beni neden buraya çağırdığını göster." · Odayı oku: karşındakini tart. · Geri dönüşü kabul et: koşulu tuttur. · Masayı zorla: şimdi karar ver. | `VC_B1_LINE`, `VC_B1_CHOICE`, `VC_B4_CALLBACK` (TR "Callback" da "Geri dönüş"e), `VC_B4_PUSH` |
| Frank'in çıkış satırı | (prefix dropped) | `VC_FRANK_COLD_EXIT` "Frank: "{line}"" öneki kalkar | VC ret |
| term sheet başı | {name} · {role} · {fund} sırası | {name}, sonra {role} · {fund} | lider adı başta, sonra unvan · fon (olaylar grubunun VC gönderici grameri) |

Frank'in satırları CSV'den, olduğu gibi (yeni Frank satırı yok). Satış diyaloğu `PH:` yer tutucusudur; çerçeveler öneki
atarak gösterir, metnin kendisi yazım turunu bekler.

## Açık sorular (Erdem)

1. **Saat kuralı**: davette saat işler (VC kartı II ile açılır); yolculukta ve görüşmede saat tutulur, tuşlar kapalı,
   amber yok. Yolculukta kodun kuralı (donuk saat) baseline'ın yanık 1x'inin yerine seçildi. Onay.
2. **Koltuk renkleri**: bugünkü üç koltuk tonu (`MEETING_SEAT_1..3`) kalktı; kimlik yüz + ad, konuşan mürekkep halka.
3. ~~TUTUM rengi~~: AD kararı uygulandı (nötr dolgu, kelime etiketi).
4. ~~Zar sonucu rengi~~: AD kararı uygulandı (başarısız zar nötr ✕; kadran iğnesi de mürekkep).
5. **Geri dönüş kartı** bugün amber bantlı; sistem amberi zaman durumuna ayırdığı için `warn` + takvim glifi. Uygun mu?
6. **Pazarlık açılışı** için ayrı 1920 karesi yok: `toplanti__satis_handoff` Perde 2'nin açılış hâlidir.
7. **Term sheet masası** kendi tam ekran sahnesi olarak kaldı (SPEC §11.4). Toplantı odasının üstünde bir pencere mi olmalı?
8. **Frank satırı** dokta ve masada portre A'lı kendi satırı, serif; bugünkü "Frank: "..."" iç not biçimi kalkar.
9. **Seed masası** sol düğmesi kilitli ve gerekçesi yanında yazılı (bugün yalnız ipucu). Kural 4 bunu ister; onay.
10. **1536**: toplantı odası plakası yalnız 1920'de var; 1536 karelerinde ölçeklenip alttan kırpıldı. Faz F 1536 plakası çeker.
11. **Arama kartı** kurucunun başının yanında, görünüme kenetli; yığın üç satıra çıkınca kart 24 px yukarı alındı. Kart
    yığınla çakışırsa yığın mı gizlenir, kart mı kayar?
12. **Plaka sanatı**: kurucunun zemin halkası plakada hâlâ amber (3B sanat, Faz F); telefon halkası amber kalır (zaman durumu).
13. **Yolculuk** kabuğun; "taç" A4'te mevcut ofis çipinin glifi, kulenin taç ışığı Faz F.
14. **Toplantıdan çekil** dok altında ikincil küçük düğme, yalnız 1. adımda; Esc de çeker.
15. **Seçim**: görüşme seçenekleri tıkla ya da 1-5 ile hemen seçilir (kur ve seç yalnız Olaylar kararları için, SPEC §6).
16. ~~Hakaret uyarısı~~: hep görünen `neg-ink` satır uygulandı.
17. **Karışık tohum**: satış karelerinde şirket tema tohumundan, diyalog ve yüzdeler satış dünyası shot'larından; kapasite
    261 satış dünyasının altyapısından. Faz F tek fikstürde birleştirmeli.
18. **VC dünyası üst barı**: shot MRR'yi $125K'ya çekiyor ama burn'ü yeniden hesaplamıyor (NET +$124K, Artıda).
19. **"Seed"** TR'de kalsın mı ("Seed görüşmesi", "Seed turu"), "Tohum" mu?
20. **"Spin"** TR önerisi "Parlat" (öteki seçenekler "Tersine çevir", "Cilala").
21. **Term sheet alt boşluğu**: içerik başın altına yaslanınca sağ sütunun altıyla alt bar arasında ~220 px boş kalır (son
    teklif ve fon kalktı karelerinde de). Kabul mü, yoksa kollar ve kadran mı büyüsün?
22. **Masayı zorla** alt satırı "Başarısızsan masa kapanır." `neg-ink` kaldı (yıkıcı sonuç, kural 2). AD kararının
    kırmızı listesi bunu saymıyor; onay.
23. **Dok başı anahtar sütunu** EN için 88'e çıktı, TR'de de 88 (sabit sütun, SPEC §3.4).
