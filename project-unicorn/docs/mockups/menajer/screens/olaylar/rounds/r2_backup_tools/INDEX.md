# Olaylar mail olarak · A4 ekran maketleri (grup "olaylar")

Erdem kararı 15: olaylar gelen kutusunda mail olarak okunur. Bu klasör mailin anatomisini, gönderen türlerini (SENDERS.md),
altı temsilî kartın mail taslağını (DRAFTS.md) ve kutunun bütün durumlarını onaylı Menajer Masası diliyle, tam kabuk içinde
1920×1080'de gösterir. Hepsi onay bekliyor.

- Sistem olduğu gibi kullanıldı: `../../system/tokens.css`, `base.css`, ikonlar, kırpım kuralı, üst bar ızgarası.
  Sistemin eksiği `olaylar.css`'te (aşağıda "Yeni bileşenler"); sistem klasörüne hiçbir şey yazılmadı (kit kopyaları ve
  önbellekleri `tools/syskit/`'te).
- Frank = aday A (`portraits/frank_cand_a.png`). Kurucu = `founder_01`. Yağlı boyalar yok.
- Ofis: `art/office_safe_1920.png` (184, 64)'te; hafta 1 çerçevesi `office_safe_1920_home.png` (ilk gün evde).
- Üst barın marka bloğu kullanıcı isteği ve plan kararı 14'ün **(a) seçeneği**: eski turuncu kare (`#FFA028`, marka
  sabiti, UI amberi değil) + "Project Unicorn". (b) seçeneği (oyuncunun şirketi + kendi logosu) kabuk grubunun işi;
  `tools/gen.py` `topbar()` tek yerde değişir.

Yeniden üretmek: `python tools/gen.py` (HTML'ler `build/`), `bash tools/render_all.sh <tur>` (PNG'ler bu klasöre, kopyası
`rounds/<tur>/`). `tools/dump_cards.py` kartları CSV metniyle döker, `tools/senders.py` SENDERS.md'yi yazar.
Turlar: r1 (19 çerçeve, hepsi tam boy ve 1:1 kırpımla okundu), r2 (düzeltmeler + taslak sayfası; değişen her çerçeve tam
boy, gerisi temas sayfası ve 1:1 kırpımla okundu). Kırpımlar `rounds/crops/`.

## Mailin anatomisi

| Parça | Ne | Kural |
|---|---|---|
| Künye (kicker) | konu etiketi + tür (Karar, Kağıt, Rapor, Mesaj, Dikkat) + durum (Cevap bekliyor amber; "2 hafta içinde"; "Bu hafta son" uyarı) | Tarih künyeden mail başlığına taşındı (SPEC §3.3 örneğinden sapma, soru 4). |
| Konu | `t-h2`, gönderenin yazdığı | Kartın yeni `subject` alanı; `title` iç ad olarak kalır. |
| Başlık | 40 px avatar (kişi: disk; şirket: monogram; yayın: yayın renginde monogram; masa: belge glifi) + ad + unvan/şirket; ikinci satır "Kime · Kurucu · Unicorn Inc."; sağda tarih | Gün sınırı kartında saat yok ("Hafta 14 · Nisan 2026"); saatlik kart ve oyuncunun açtığı mesaj saat yazar ("Hafta 1 · Ocak 2026 · 09:00"). Ayrılmış gönderende yüz gri %55, adın yanında "· Ayrıldı". |
| Gövde | paragraflar; selamlama ve kapanış göndericinin | Frank'in maili baştan sona Source Serif 4 20/30 (kendi yüzü), selam ve kapanış yok. Diğerleri Plex 16/24. |
| İmza | kısa çizgi, ad, unvan · şirket | Yapısal; adı olmayan muhatapta unvan + şirket. |
| Portre kuyusu | 256×320, sağda | Yalnız kişi yazınca (Frank, çalışan). Raporda yok: tablo tam genişlik alır. |
| Cevabın | etiket + "Seçim kalıcıdır · Oyun duraklatıldı" | Sistemin kur ve seç grameri aynen: tek açık seçenek kurulu gelir (bedel kutusu + tek amber düğme), çok seçenekte oyuncu kurar, kilitli seçenekte yalnız etiket ve kilit soluk, gerekçe tam mürekkep. |
| Kağıt | "Cevabın" altında kağıt çubuğu: kalan süre + "Cevapla" | Seçenekler "Cevapla"dan sonra açılır (saat orada durur). Karar beklerken çubuk "Önce bekleyen kararı cevapla." ve kapalı düğme. |
| Geçmiş | "Seçimin" altında cevaplanmış belge kartı: seçilen seçenek, etki çipleri, damga | Damga belgenin üstünde (CEVAPLANDI H11, AYRILDI H14). Liste satırının üçüncü satırı "Seçimin: …", damgaya çarpmaz. |
| Liste satırı | gönderen + konu etiketi / konu + sağda süre ya da saat / gövdenin ilk satırı (selamlama atlanır) | Amber nokta bekleyen karar, mürekkep nokta okunmamış; hatırlatıcıda nokta ve tarih yok. |

## Çerçeveler

Sütunlar: durum, veri kaynağı, yeni bileşen, yeni metin (EN / TR; tam liste aşağıda), açık soru numaraları.
"Tohum" = `docs/mockups/menajer/data/screens.md` (theme seed, hafta 14, 11:00) ve `main.gd _seed_theme_surface`.

| PNG | Gösterdiği | Veri kaynağı | Yeni bileşen | Yeni metin | Soru |
|---|---|---|---|---|---|
| `olaylar__frank_teklif.png` | Frank'in teklifi seçili, karar bekliyor, saat kilitli (üst bar kapısı, hız tuşları kapalı, rayda amber nokta). Tek açık seçenek kurulu (Nakit +$25K, Frank'e %4 hisse, Kabul et), Reddet kilitli. Liste: kağıt (karar beklerken soluk), iki hatırlatıcı, bu haftanın Ar-Ge notu ve dönem özeti, hafta 1'de tanışma. | Tohum; kart `funding.frank_cheque`; metin DRAFTS 1. | mail başlığı, imza, Cevabın, künye türü | Teklif / An offer; Cevabın; Kime | 2, 3, 4 |
| `olaylar__frank_teklif_en.png` | Aynısı İngilizce. | Aynı; EN değerleri CSV'den, para EN biçiminde. | | Your reply, To, An offer | 2 |
| `olaylar__musteri_secenek_acik.png` | Ege Sigorta'nın maili (müşteri riski), dört seçenek; "İndirim ver" kurulmuş: bedel parçaları (Müşteri kalır · MRR −$150, İtibar −1), Vazgeç ve amber Seç. Ege'nin risk hatırlatıcısı karar beklerken gizli. | Tohum; `customer.retention`; ses `B2B_RISK_VOICE_SHORT_2` (`hash("co_ege") % 3 = 1`, `bugs_confirmed` 0 olduğu için); indirim = MRR $1.000 × `RETAIN_DISCOUNT_PCT` 0,15; gönderen unvanı `B2B_CONTACT_INSURANCE`. | nötr etki parçası (glifsiz) | Konuşmamız gerek / We need to talk; Merhaba, Saygılarımla | 5, 8, 12 |
| `olaylar__musteri_secenek_acik_en.png` | Aynısı İngilizce. | Aynı. | | Hello, Regards, IT Manager (CSV) | 5 |
| `olaylar__kilitli_secenek.png` | Ege'nin ikinci risk maili: "Söz ver" kilitli, gerekçe "Bu hesaba verdiğin son söz tutulmadı."; odak halkası ilk açık seçenekte (Oyala), hiçbiri kurulu değil. Ses tutulmayan söz sesi. Geçmişte Hafta 11 cevabı. | Tohumdan türetildi: Hafta 11'de retention'a "Söz ver" (2 hafta süreli söz), Hafta 13'te süre doldu tutulmadı (`B2B_RISK_VOICE_BROKEN`, kilit `B2B_LOCK_PROMISE_BROKEN`: canlı başarısız koşulun gerekçesi kazanır), Hafta 14'te hesap yeniden riske girdi (`RISK_REENTRY_WEEKS` 3). | | | 12 |
| `olaylar__gecmis_karar.png` | Aynı türetilmiş durumda Hafta 11 mailine dönülmüş: cevaplanmış belge kartı (Söz ver; Müşteri kalır · söz borcu, İtibar +1; CEVAPLANDI H11). Karar hâlâ bekliyor, kapı açık. | Aynı türetme; çipler kartın kendi etkileri. | cevaplanmış belge kartı | Seçimin (SPEC) | |
| `olaylar__kagit_onizleme.png` | Nordica'nın kağıdı önizlemede: mail + "2 hafta içinde" + amber Cevapla; saat 1x işliyor. Rayda Olaylar sayacı 1 (süreli kağıt). | Tohum (Nordica genişleme aşamasında, 20 koltuk $2,0K/ay); `customer.expansion`; gönderen unvanı `B2B_CONTACT_LOGISTICS`. | | Bir ekip daha / One more team; {n} hafta içinde (SPEC) | 19 |
| `olaylar__kagit_son_hafta.png` | Aynı kağıt son haftasında: künye ve çubuk uyarı renginde "Bu hafta son", başlık KPI'ı "Bu hafta". | Hafta 15 (kağıt Hafta 14'te 2 haftayla geldi). Üst bar değerleri tohumda tutuldu, yalnız tarih ve Sıradaki ("Mesai bitimi · 6 saat") değişti. | | Bu hafta son (SPEC) | 13 |
| `olaylar__kagit_karar_beklerken.png` | Karar beklerken kağıt seçili: okunur, "Önce bekleyen kararı cevapla." ve kapalı Cevapla. | Tohum + Frank'in teklifi. | | (SPEC) | |
| `olaylar__bildirimler.png` | Hatırlatıcı satırları: riskteki müşteri, ayrılabilir çalışan, büyüme talebi. Ege seçili: kayıt (MRR $1,0K/ay, 12 koltuk, Memnuniyet 25, 2 aydır müşteri, sebep, temsilci yok) + İlgilen. Karar ve kağıt yok. | Tohum, Satış portföy kartı verisi (screens.md). Büyüme kağıdı yokken büyüme hatırlatıcısı görünür. | hatırlatıcı kaydı | Dikkat / Attention | 8 |
| `olaylar__calisan_ayrilik.png` | Selin Kaya'nın istifa maili, tek açık seçenek kurulu: Ekip · Selin ayrılıyor (tehlike) + Anlaşıldı. Selin'in hatırlatıcısı gizli. | Tohum (moral 22); ayrılık turunun geldiği varsayıldı (tohum alttaki seriyi saklamıyor). Ses `HR_RESIGN_VOICE_4` (`hash("char_emp_shot_3") % 4 = 3`). | | İstifa dilekçem / My notice | |
| `olaylar__ayrilmis_gonderici.png` | Hafta 15: Selin'in maili geçmişte, yüz gri %55, "· Ayrıldı", AYRILDI H14 damgası; Ekip rozeti kalktı. | Önceki çerçevenin devamı; üst bar tohum değerlerinde. | | Ayrıldı (SPEC) | 13 |
| `olaylar__donem_ozeti.png` | Dönem özeti Muhasebe'den rapor maili olarak kendiliğinden açılmış; oyun duraklatıldı (II etkin, kilit değil), Devam et. | `--modal-shot=month` tohum çıktısı: Hafta 1-14, MRR $0 → $4,0K, Kasa $10,0K → $10,0K, Ekip 1 → 6, Marka 50 → 50, Runway Artıda, çeyreğin olayı; saat 08:00 (hafta başı). | rapor tablosu, öne çıkan satır | Muhasebe / Accounts; Devam et (UI_CONTINUE yeniden harf); Çeyreğin olayı (✦ atıldı, SPEC §13) | 6, 11 |
| `olaylar__frank_tanisma.png` | Yeni koşu, Hafta 1, 09:00: Frank'in ilk maili kendiliğinden açık, tek öğe; Hadi başlayalım. Ev ofisi, BuildHUD yok, ray rozetsiz. | Koşu başı: kasa $10.000, burn $1,5K/ay (`TOOLS_BASE_MONTHLY[1]`), MRR 0, net −$1,5K/ay (tehlike değil, mürekkep), runway 10000 / 50 / 30 = 6,7 → "7 ay", marka 50, itibar 0. Metin DRAFTS ek taslak. | | Ben Frank / It's Frank; Mesai bitimi · 8 saat | 10 |
| `olaylar__arge_notu.png` | Elif Demir'in aylık ürün notu (saat durmaz, 1x); Ar-Ge'ye git, Ürün sayfasına git. | `--modal-shot=rnd-note` tohum çıktısı, üç satır (rakip adı Operanda). "Bundan sonra bu not her ay Ar-Ge sayfasında…" ipucu atıldı: not artık kutuda. | | Aylık ürün notu (RND_NOTE_TITLE yeniden harf) | |
| `olaylar__haftalik_satis.png` | Hafta 15: Burak Şahin'in haftalık satış raporu (saat durmaz, 1x): müşteri, yıldız, koltuk, fiyat, MRR, toplam, defterdeki hesap. | **Satırlar hesaplanmadı**: onaylı sistem sayfası 06'nın örneği (Karadeniz Fabrika 12 × $85, Efes Emlak 8 × $75), tohumdaki iki lead'in kapandığı varsayımıyla; defterdeki hesap 3 + 2 = 5. Gerçek rapor `SalesLedger.weekly_close_lines()` basar. Üst bar tohumda (MRR yeni anlaşmaları içermiyor). | rapor tablosu | Müşteri, Yıldız, Koltuk, Fiyat, Toplam (sütunlar) | 13, 14 |
| `olaylar__bos_kutu.png` | "Bekleyen" süzgeci boş: listede ve bölmede boş durum. | Tohum, kararsız ve kağıtsız an. Gerçek bir koşuda kutu hiç tam boş olmaz (tanışma hep var); tam boş kutu yalnız `messages` alanı olmayan eski kayıtta. | liste ve bölme boş durumu | Bekleyen bir şey yok. / Nothing waiting.; Seçili mesaj yok. / No message selected. | 20 |
| `olaylar__kuyruk.png` | Üç karar: Frank'in teklifi etkin, kuyruk satırı "2 karar daha sırada · bundan sonra açılır", üst bar "3 karar bekliyor". | Tohum; kuyruktaki kartlar yalnız sayı (plan). | | (SPEC) | |
| `ekip__salt_okunur_karar_bekliyor.png` | Karar beklerken Ekip penceresi salt okunur: şerit "Karar bekliyor. Bu pencere yalnız okunur. Frank Köseoğlu · Teklif" + Karara dön; mesai çipi, İşe alım başlat ve tablodaki boş grup düğmesi kapalı; rayda Ekip etkin, Olaylar'da amber nokta. | Tohum; sistem Ekip penceresi (`kit.ekip_window`). | | | 2 |
| `olaylar__taslak_frank_ani_basin.png` | Taslak sayfası (kabuksuz): `customer.frank_intro` Frank'in tek seçenekli anı (Yeni aday, Seni oraya götürür, Satış'a git) ve `world.final_stretch_press` Sektör Telgrafı kağıdı (4 hafta içinde, Hafta 38 · Eylül 2027 = en erken tik 91). Altta dokuz gönderen türü başlık olarak. | DRAFTS 2 ve 6; tarih kuralı `get_date_dict` (yılın haftası). Adlı muhatap örneği tohumdaki Karadeniz Fabrika lead'inin alıcısı (`art/busts/counterparts.json`: Elif Yıldız, Satın Alma Sorumlusu); VC örneği Anchor Capital lideri. Frank anının tarihi tohum haftasında tutuldu. | gönderen türü kartı (yalnız sayfa), tek açık seçeneğin çipli bedel kutusu | Yıllık dosya / The annual file; Kendine not / Note to self; Alan adı aracısı / Domain reseller; Destek / Support | 5, 6, 9, 15, 16, 18, 21 |
| `olaylar__taslak_frank_ani_basin_en.png` | Aynısı İngilizce. | Aynı. | | | 21 |

## Yeni bileşenler (`olaylar.css`, sistem grameriyle)

| Sınıf | Ne | Godot karşılığı (öneri) |
|---|---|---|
| `.brand-sq` + `--brand-mark` | Marka bloğunda 20 px turuncu kare (`#FFA028`), karar 14 (a) | `LogoEmblem` sabit renk; `D_BRAND_MARK` sahne sabiti, UI token'ı değil |
| `.pane-kicker .kind/.state` | Künye: tür + durum (amber yalnız Cevap bekliyor, uyarı son hafta) | okuma bölmesi başlık satırı |
| `.subj-row` | Konu satırı | Label `t-h2` |
| `.mh`, `.mh-l1`, `.mh-l2`, `.mh-date` | Mail başlığı: avatar, ad, unvan, Kime, tarih | HBox + iki Label satırı |
| `.mono.m40`, `.mono.outlet.<yayın>` | 40 px monogram; yayın renginde çerçeveli monogram | `UiFactory.make_monogram(text, kind)` |
| `.mbody`, `.mbody.serif` | Gövde; Frank'in maili Source Serif 4 20/30 opsz 20 | RichTextLabel, `QuoteSerif` koyu varyasyonu |
| `.msig` | Yapısal imza: 24 px çizgi, ad, unvan · şirket | VBox |
| `.reply`, `.reply-head` | Cevabın bloğu ve kalıcılık satırı | okuma bölmesi karar alanı |
| `.stake.sm` + `.opt-fx` | Sözlü sonuçlu tek açık seçenek: anahtar uydurmadan çiplerle bedel kutusu | aynı bedel kutusu, çip kipinde |
| `.fx.neutral` | Kutupsuz etki parçası, glifsiz (düz çubuk tire gibi okunuyordu) | `EvChips` polarity `neutral` |
| `.answered`, `.answered-l` | Cevaplanmış belge kartı: seçilen seçenek, çipler, damga | geçmiş kipi |
| `.ib-row.is-notice`, `.ib-row.is-history .ib-l3`, `.ch-k` | Hatırlatıcı satırı; geçmiş satırında "Seçimin:" ve damga payı | kutu satırı varyasyonları |
| `.ib-empty`, `.pane-empty` | Liste ve bölme boş durumu (`.empty` ile) | |
| `.rpt`, `.rpt-grid`, `.rpt-total`, `.hl` | Rapor tablosu (satır çizgisi kesintisiz), toplam satırı, öne çıkan satır | rapor maili gövdesi |
| `.rec-head`, `.rec-facts`, `.rec-line` | Hatırlatıcı kaydı: başlık, bedel kutusu dilinde olgular, sebep satırları | Dikkat kipi |
| `.portrait .gone-img` | Ayrılmış göndericinin kuyusu gri %55 | `avatar_grey.gdshader` |
| `.gal`, `.gal-k` | Yalnız taslak sayfası: gönderen türü kartı | yok |

## Yeni oyuncu metinleri (EN önce, TR; hepsi onay bekliyor)

SPEC §13'te zaten önerilenler (kapı, kuyruk, süzgeçler, "En yakın süre", kağıt çubuğu, Seçimin, damgalar) tekrar edilmedi.

| Anahtar (öneri) | EN | TR | Nerede |
|---|---|---|---|
| `TOPBAR_BRAND` | Project Unicorn | Project Unicorn | marka bloğu (özel ad) |
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
| `MAIL_SIGNOFF` | Regards, | Saygılarımla, | müşteri maili |
| `INBOX_EMPTY_WAITING` | Nothing waiting. | Bekleyen bir şey yok. | boş süzgeç |
| `INBOX_PANE_EMPTY` | No message selected. | Seçili mesaj yok. | boş bölme |
| `MAIL_RPT_CUSTOMER` / `_STARS` / `_SEATS` / `_PRICE` / `_TOTAL` | Customer / Stars / Seats / Price / Total | Müşteri / Yıldız / Koltuk / Fiyat / Toplam | satış raporu |
| `REC_TENURE_KEY` + değer | Customer · 2 mo | Müşteri · 2 aydır | hatırlatıcı kaydı (`SALES_TENURE` ikiye bölünür) |
| konu alanları | An offer, We need to talk, One more team, My notice, An old friend, The annual file, It's Frank | Teklif, Konuşmamız gerek, Bir ekip daha, İstifa dilekçem, Eski bir dost, Yıllık dosya, Ben Frank | DRAFTS |
| `B2B_EV_RISK_EXPIRED` değişikliği | {customer} didn't write again. | {customer} bir daha yazmadı. | DRAFTS 3 |
| yeniden harf | Monthly product note, Continue, Event of the quarter | Aylık ürün notu, Devam et, Çeyreğin olayı | `RND_NOTE_TITLE`, `UI_CONTINUE`, `SUMMARY_EVENT_QUARTER` (✦ atıldı) |
| tohum düzeltmesi | Account manager: not assigned | Müşteri temsilcisi: atanmadı | screens.md'deki düzeltme |

Frank'in her satırı (DRAFTS 1, 2 ve ek taslak) ayrıca taslaktır.

## Açık sorular (Erdem)

1. **Marka bloğu**: çerçeveler (a) turuncu kare + "Project Unicorn" ile; (b) oyuncunun şirketi + logosu kabuk grubunda. Hangisi?
2. **Kapı yuvası alt satırı** göndereni yazıyor ("Cevap bekliyor · Frank Köseoğlu"), kart başlığını değil; salt okunur şerit
   "Frank Köseoğlu · Teklif". Saat kilidi toastı da "Önce Frank'e cevap ver" olabilir. Kabul mü?
3. **Konu ve başlık**: kutu, bölme ve kapı yeni `subject`'i okur; `title` iç ad (geçmiş, toast) olarak kalır. İkisi tek alan mı olsun?
4. **Künyede tarih yok**: tarih mail başlığında, künye yalnız tür ve durum (SPEC §3.3 örneği "Karar · Hafta 14 · Nisan 2026" bu ekranda değişir).
5. **Muhatap**: hesabın göndericisi masada tanışılan alıcı mı (`CounterpartSystem`, `co_` + lead kimliğinden aynı ad ve
   görünüş), sektör unvanıyla mı (`B2B_CONTACT_*`)? Lead'i olmayan hesap (fikstür, başlangıç) monogram + unvan. Satın alma
   konuları (yenileme, güvenlik anketi, rakip fiyatı) alıcıdan, işletme konuları (risk, şikâyet) sektör unvanından gelebilir.
6. **Şirket masaları**: "Muhasebe" ve "Destek" adları; avatar belge glifi mi, oyuncunun şirket logosu mu (seçenek b ile bağ)?
7. **Frank'in maili**: selam ve kapanış yok, gövde baştan sona serif. Uygun mu?
8. **Hatırlatıcılar** mail değil kayıt (tarih ve okundu yok, plan); aynı konuda bekleyen karar varken hatırlatıcı gizlenir
   (Ege riski, Selin) öneri. Kayıt mail gibi bir gönderen alsın mı (ör. Destek)?
9. **İki sesli kartlar** (`funding.acquisition_offer`, `funding.seed_offer`): VC maili + Frank'in tek satırı aynı zincirde ikinci mail.
10. **Tanışma**: (A) Frank'in maili (taslak, çerçevede), (B) mühürlü sahne kurucunun notu olarak, Frank mail atmaz.
11. Dönem özeti tohumda "2. Çeyrek 2026, Hafta 1-14" basıyor: kapanan çeyrek 1. çeyrek. Motor başlığı mı yanlış?
12. Tohumun bilinen çelişkisi: Satış sebebi `live_bug_count` (12) ile "sık kesinti", risk sesi `bugs_confirmed` (0) ile
    kısa ses seçiyor. Çerçeveler motorun seçtiği sesi gösterir.
13. Hafta 15 çerçevelerinde üst bar tohum değerlerinde tutuldu (tohumun geçmişi yok); yalnız tarih ve Sıradaki değişti.
14. Haftalık satış satırları sistem sayfası 06'nın örneği, hesaplanmadı.
15. `customer.frank_intro` kartında `speaker` boş (MENTOR rozeti ve yüz çıkmıyor); `speaker: char_mentor_frank` eklensin mi?
    `mentor_advisory` notu artık mailin tekrarı: kalsın mı?
16. `B2B_LOCK_STALL_CAP` ikinci cümlesi ("Üçüncüsünü kimse beklemez.") kilidin bilgeliği; "İki kez oyaladın." yeter mi?
17. Gün sınırı kartlarında saat yok; oyuncunun İlgilen ile açtığı karar saat yazar mı?
18. Bülten kurucuya "sen" mi "siz" mi der?
19. Kağıt önizlemesinde seçenekler gizli (sistem kuralı); etiketleri soluk bir satırda görünsün mü?
20. Gerçek koşuda kutu hiç boş değil (tanışma); boş durum yalnız süzgeçte ve eski kayıtta. Kutu kapasitesi [WORKING].
21. EN başlıktaki "Sector Telegraph" çevrilmiş özel ad; gönderen iki dilde "Sektör Telgrafı".
