# Playtest 2026-10-28: B2B ERP, kurucu tek başına, ilk 30 hafta

Yardımcı yönetmen adına OLAYLAR oturumu yaptı (Erdem: "paralelde bir playtest yapar mısın, gelen eventleri yanıtlayarak").
Build `b2639465` (Olaylar 8 dahil), dizüstü (Mac), pencereli, kendi HOME'uyla; oyun Godot MCP (gopeak) ile oyuncu gibi
sürüldü: menüden yeni oyun, onboarding, sprint planı, işe alım, satış görüşmeleri, her kâğıda düşünülerek cevap. 30. haftaya
66 dakikada varıldı. Kareler 1920×1200 (oyunun bu ekrandaki pencereli varsayılanı). Bulgular kodda ayrıca doğrulandı
(`dogrulama.json`); "hata" kodun ya da oyuncuya gösterilen metnin kendi söylediğini yapmadığı yer, "tasarım" kodun bilerek
yaptığı ama oyuncunun takıldığı yerdir. [GÖRÜŞ] işaretli cümleler oynayanın izlenimidir.

## Erdem'in bilmesi gerekenler

1. **Çeyrek bülteni cevaplanamadı (hata).** `world.quarterly_bulletin` H14'te geldi; H15'te "Bu hafta son" yazan ve
   Cevapla'sı açık kâğıda basınca "Bu kâğıdın konusu kalmadı" çıktı, kâğıt silindi (kayıtta `dropped`) ve koşu boyunca bir
   daha gelmez. Kartın koşulu `time.quarter_start` yalnız çeyreğin ilk haftasında doğru, ömrü ise 2 hafta; açarken koşul
   yeniden okunuyor. `data/events/cards/world/quarterly_bulletin.json:43-45`, `:85`; `scripts/events/core/engine.gd:766-780`;
   `scripts/tabs/events/mail_pane.gd:540-542`. Kare `11_h15_kagidin_konusu_kalmadi_BUG`.
2. **H19–H25 sprintleri neredeyse boş koştu (tasarım).** Hız 11/36, 9/36, 10/38: hatların sonraki kademeleri kapanınca
   sprint listesinde yalnız görüşme ve düzeltme kalıyor; yeni kart Ar-Ge'den açılıyor ama plan ekranı Ar-Ge'yi göstermiyor
   (KR7: kilitler sprint ekranında görünmez; `PRODUCT_GO_RND` yalnız v1.0 sürüm notunda ve iki özel durumda). Ar-Ge'nin "1"
   rozeti H7'den H25'e kadar durdu; maaşı ödenen geliştirici yedi hafta çoğunlukla boştu. `scripts/tabs/product/product_model.gd:243`.
   Kareler `16_h21_sprint12_kapasite_bos`, `20_h25_arge_agaci_veri_modeli`. [GÖRÜŞ] Oyunun en uzun "beklemek" hissi buradan geldi.
3. **Kâğıtlar arası sessizlik ve kimden geldikleri (araştırma soruları).** Gerçek seçimli kâğıtlar: H6, 12, 16, 18, 20, 22,
   22, 29, 29, 30. İlk 5 hafta karar yok; en uzun ara H22→H29 (7 hafta; arada yalnız tek şıklı Frank kartı, Q2 raporu ve bir
   keşif notu). Sessiz havuz uyarısı ("the floor has found nothing N times running — the quiet pool is too thin") 11 kez
   geldi, N 3'ten 13'e çıktı; sayaç yalnız havuzdan kart kabul edilince sıfırlanır ve hiç sıfırlanmadı
   (`scripts/events/core/engine.gd:397-404`). İlk 12 haftanın 8 kartının 8'i Kurucu ya da Frank'ten; müşteri ve çalışan sesi H16'dan sonra başlıyor.
4. **Arda'nın sprint kâğıdı görülmeden doldu (tasarım).** `product.sprint_dev_backfill` H29 09:00'da masaya geldi, sprintin
   kapandığı H30 00:00 tikinde süresi doldu ve bedeli (1 hata) indi; oyuncu kâğıdı görmedi, yalnız haber bandında "Cevap
   gelmedi, eski kayıtlar boş kaldı" geçti. Bütün `sprint_*` kâğıtları bir haftalık (`expires_weeks: 1`) ve bir haftalık
   kâğıda son uyarı yok (`scripts/events/present/papers.gd:85-86`); süresi dolan satır kutuya H30 11:00'de düşer.
   `data/events/cards/product/sprint_dev_backfill.json:121-128`.
5. **"Zor modda açılır" sözü tutmuyor (hata).** Frank'in teklifinde (`funding.frank_cheque`, H25) "Reddet" kilitli ve
   "Zor modda açılır" diyor; kilidi okuyan `hard_mode_unlocked` bayrağını yazan kod yok (yalnız smoke), onboarding'deki Zor
   zorluk yalnız başlangıç kasasını değiştiriyor: Zor seçilse de Reddet açılmaz. `scripts/events/seams/seams_ported.gd:105-107`,
   `scripts/autoload/game_state.gd:116-117`. Frank'in üç "Karar" kartının üçü de tek seçilebilir şıklı (tasarım, `critical`
   kartlar not sayılmıyor). Kare `21_h25_frankin_teklifi_reddet_kilitli`.
6. **Satış ekranında iki hata.** (a) Haftanın başında 00:00–07:59 arası satış paneli "Mesai bitiyor. Bu hafta yeni bir
   masaya oturulmaz." diyor ve görüşmeyi kapatıyor; gece ile mesai sonu aynı anahtara düşüyor, 08:00'de aynı hafta açılıyor
   (`scripts/systems/sales_ledger.gd:327-328`, `scripts/systems/work_hours_system.gd:57-59`). (b) Müşteri kartı "Müşteri
   temsilcisi: atanmadı" yazarken atama listesi "Kurucu … zaten sorumlu" diyor; ikisi aynı durumu (`assigned_to == ""`,
   kurucunun hesabı) farklı adlandırıyor (`scripts/tabs/sales_tab.gd:661-666`, `scripts/data_models/customer.gd:43`).
7. **"…" ile kesilen metin (hata, 28 Ekim kuralına aykırı).** Üst barın SIRADAKİ yuvası "Çeyrek bülteni: i… · bu hafta son"
   (`top_bar.gd` `_fit_next`, sabit 208 px yuva), Ekip > Kadro'nun Görev sütunu "Defterix Fatura v1.9 üzer…"
   (`hr_ledger._text`: `clip_text` ve `OVERRUN_TRIM_ELLIPSIS`). Kare `10_h15_ceyrek_bulteni_kagit`.
8. **Yeni işe alınan hemen izne çıkıyor (tasarım).** Arda H18'de alındı, H23'te; Selin H27'de alındı, H28'de iki haftalık
   yaz iznine çıktı; kart yok, yalnız haber bandı. İzin haftası işe alım sırasından türüyor ve yeni gelene muafiyet yok
   (`scripts/systems/hr_constants.gd:1089-1090`, `scripts/autoload/character_registry.gd:445-447`).

[GÖRÜŞ] En iyi okunan kâğıtlar H30'un iki müşteri kâğıdıydı ("Sahibi değişti", "Muhasebecileri"): üç şıkkın üçü gerçek
ödünleşim, Türkçeleri doğal, çipler oyunda birebir indi. Kareler `23_h30_sahibi_degisti_kagit`, `24_h30_muhasebecileri_kagit`.

## Durum (H30, Temmuz 2012)

Kasa $26.199 · MRR $5.173 · net -$1,9K/ay · runway 13 ay · burn $7,1K/ay · 4 müşteri (Bakırçay Tekstil, Sultanahmet Üretim,
Alaçatı Beton, Lumen Dokuma), 0 kayıp, 2 genişleme · ekip: kurucu, Arda Güneş (Jr Yazılım), Selin Güneş (Jr Ürün Yöneticisi)
· marka 48 · faz Traction · ürün v1.9 (10 sürüm) · Frank: $25K karşılığı %4. Şirket ve ürün adı Defterix / "Defterix Fatura";
kurucunun adı boş bırakıldı, oyun ona "Kurucu" dedi (tasarım: ad alanının ipucu bunu söylüyor).

## Kâğıtlar ve kartlar (kayıttaki olay geçmişi; hafta = kaydın günü)

| H | Kart | Gönderen | Seçim | Neden (oyuncu) |
|---|---|---|---|---|
| 3 | `founder.company_of_one` | Kurucu | not | |
| 4 | `product.working_parts` | Kurucu | not | |
| 7 | `founder.domain_name` | Kurucu | Uzun adresle devam et | Kasa $10K, gelir 0; B2B müşteri toplantıyla gelir, kısa adres $900'a değmez |
| 8 | `customer.frank_intro` | Frank | Satışa git (tek şık) | |
| 11 | `funding.gate_traction` | Frank | Traction'a geç (tek şık) | |
| 12 | `product.sprint_solo_server_bill` | Kurucu | Kodu düzelt | Tek başına kapasite nakitten değerli; öbür şık 10 puanı sonraki sprinte itiyor |
| 15 | `world.quarterly_bulletin` | Sektör Telgrafı | **düştü** (madde 1) | |
| 16 | `product.incident_regression` | Zeynep Güneş (Sultanahmet) | Kendin düzelt | Sızıntı yeni müşteride; "sprinti durdur"un bedeli yazmıyor |
| 18 | `customer.expansion` | Bilge Polat (Bakırçay) | Koltukları ekle | Bedelsiz gelir |
| 19 | `customer.release_thanks` | Zeynep Güneş | not | |
| 21 | `rival.copycat` | Kurucu | Onların ilk müşterilerini ara | $3K ihtarname runway'i ~2 ay kısaltır; B2B'de somut aday işe yarar |
| 22 | `customer.expansion` | Zeynep Güneş (Sultanahmet) | Koltukları ekle | Aynı kâğıt, aynı cevap |
| 22 | `product.incident_regression` | Arda Güneş | Sprinti durdur, şimdi düzelt | Sprint neredeyse boş, durmanın kaybı küçük |
| 23 | `customer.release_thanks` | Bilge Polat | not | |
| 25 | `funding.frank_cheque` | Frank | Kabul (Reddet kilitli, madde 5) | |
| 30 | `product.sprint_dev_backfill` | Arda Güneş | **süresi doldu, görülmedi** (madde 4) | |
| 30 | `customer.new_owner` | Bilge Polat (Bakırçay) | Avukat parasını fiyata yansıt | $2,5K tek sefer, +$400/ay ile ~6 ayda döner |
| 30 | `customer.chargeback` | Destek | Bırak, para onda kalsın | $1,8K tek sefer; öbür şıklar daha pahalı ya da churn riski |

Her kartın şıkları, çipleri ve Türkçe notları `notlar.md`'de (oyun sırasında yazıldı).

## Araştırma soruları

**Sessizlik.** Karar isteyen kartlar (tek düğmeli "Karar"lar dahil) H6, 8, 11, 12, 14, 16, 18, 20, 22, 22, 25, 29, 29, 30;
aralar 2-3-1-2-2-2-2-2-3-4-1. Gerçek seçimliler (en az iki açık şık) H6, 12, 16, 18, 20, 22, 22, 29, 29, 30; en uzun sessizlik
H22→H29. Sessiz havuz oyun boyunca art arda 13 kez boş döndü (madde 3).

**Kimden.** 14 karar kartı: Kurucu 3 (H6, 12, 20), Frank 3 (H8, 11, 25), Sektör Telgrafı 1 (H14), Zeynep Güneş 2 (H16, 22),
Bilge Polat 2 (H18, 29), Arda Güneş 2 (H22, 29), Destek 1 (H30). Not ve raporlar: Kurucu 4, Muhasebe 2, teşekkür 2.
H16'dan önce gelen her şey Kurucu ya da Frank'ten.

## Sprint ekranında takılınan yerler

- Modül panelindeki "+" bazen yalnız orta listede EKLENEBİLİR satırını vurguluyor; orta listede vurgu yokken basılacak "+"
  kalmıyor (tasarım: hayalet yalnız imleç üstündeyken kurulur, `scripts/tabs/product/area_panel.gd:262-264`).
- Sığmayan kartın "+"ı kapalı ve nedeni yalnız ipucunda ("%125 üstünde kart eklenmez"); ekranda "2 efor daha sığar" yazarken
  25'lik kart eklenemiyor (tasarım, `area_panel.gd:274-286`).
- H12'de cevapsız kâğıdın kartı iki "DEVREDEN" satırı ve Test "5/0" olarak göründü: kâğıt beklerken karta kimse atanmıyor, kalan
  iş sprint dışına taşıyor ("5/0" iş/ekip) (tasarım, `scripts/systems/sprint_system.gd:1361`). Kare `09_h12_sprint_devreden_onizleme`.
- "Sprinti durdur"un bedel çipi yok: sprintte yer varken düzeltme kartı kimseyi kaydırmıyor, çip yalnız kayan kart varsa
  çıkıyor (tasarım, `scripts/events/present/chips.gd:25-26`). Kare `17_h22_v17_bir_sey_bozuldu_arda`.
- "Sprinti başlat", "Cevapla" ve sol menü bazen ilk tıklamaya tepki vermedi; kodda çift giriş isteyen bir yol yok, MCP'nin
  enjekte ettiği tıklamadan olabilir (belirsiz).

## Satış

- "İmzalarsanız … sonraki sprintimize yazarım" sonraki sprint boşken "Bir sonraki sprintte buna yer yok" ile kilitliydi:
  istenen kademenin tam eforu (15/25/40) tek kurucunun bir sonraki sprintteki boş puanını aşıyor (tasarım,
  `scripts/systems/sales_meeting_system.gd:391-394`). Kare `19_h24_sprintte_yer_yok_ama_sprint_bos`.
- "Ürün kolay öğreniliyor" H13 ve H16'da açık, H22 ve H24'te kapalıydı: kilit ürüne değil adaya bağlı; masadaki adayın sektörü
  İlk kullanım'ı vurguluyorsa ve İlk kullanım Yeterli değilse kapanıyor (tasarım, `scripts/systems/sales_probes.gd:63-64`, `:222-228`).
- Teklifteki "Kapasite 79/50" sunucu doluluğu: bütün hesapların koltuğu artı bu anlaşma / satın alınan kapasite; aşımda ton ya da
  uyarı yok (tasarım, `scripts/systems/negotiation_system.gd:263-267`).
- Satış hataları madde 6'da.

## Metin

- Kesilen metin madde 7'de.
- Kâğıt açıkken küre düğmesinin yanındaki "Cevap bekliyor" serif görünüyor: yedek font değil, `CaptionMuted` varyasyonu serif
  (Source Serif 4) tanımlı (tasarım, `scripts/ui/office/office_hud.gd:51`). Kareler 04, 21, 23.
- Q1 raporu "Kasa $10K → $11K (+$672)": değerler 10.000 → 10.672; uçlar bine yuvarlanıyor, fark tam yazılıyor (tasarım,
  `scripts/tabs/events/mail_pane.gd:620-621`). [GÖRÜŞ] Okurken çelişkili duruyor.
- Faz adları "BOOTSTRAP", "TRACTION" ve Frank'in unvanı "Operating Partner" İngilizce; MRR, burn, runway izinli ödünç sözcük.
  Ham anahtar görülmedi.
- Kart ile liste arasında saat farkı: "Alan adı" kartta H6 10:00, listede H7 08:00 (kayıtta H7); "Büyüme fırsatı" kartta 10:00,
  listede 00:00.

## Hatalar (oyun logu)

- `ERROR` ya da `SCRIPT ERROR` satırı yok.
- Tek uyarı sessiz havuz uyarısı (11 kez, N=3…13): `_step_floor` `scripts/events/core/engine.gd:402` ← `daily_tick`.

## Haftalık günlük

- H1: Onboarding, ERP; S1 Kasa Hareketleri ve görüşme. Kasa $10.000.
- H2–H6: S2 Elle Giriş ve İK görüşmesi, S3 Stok Sayacı ve EN görüşmesi. H6 alan adı kâğıdı.
- H7: v1.0. S4 Ön Muhasebe.
- H8: Frank'in tanıştırdığı Bakırçay ile görüşme, $1.200 MRR.
- H9–H11: v1.1, v1.2. İlk ödeme, Traction. Kasa $10.168, MRR $1.200.
- H12: Sunucu faturası (kodu düzelt).
- H13: Sultanahmet görüşmesi, $660. İşe alım ertelendi.
- H14–H15: Q1 raporu; çeyrek bülteni düştü. v1.4.
- H16: v1.4 bozuldu (kendin düzelt); Safir görüşmesi kaybedildi; Jr Yazılım araması.
- H18: Bakırçay genişledi; Arda Güneş işe alındı.
- H19–H21: v1.5, v1.6; "Yazım hatasına kadar" (rakibin müşterilerini ara).
- H22: Sultanahmet genişledi; v1.7 bozuldu (sprinti durdur); Alaçatı görüşmesi, $1.200. Kasa $9.219, MRR $2.412.
- H23–H24: Sprintler boş, Arda izinde; Lumen görüşmesi, $1.161.
- H25: Ar-Ge bulundu (Veri Modeli). Frank'in çeki, +$25K / %4. Jr Ürün Yöneticisi araması.
- H27: Selin Güneş işe alındı; Q2 raporu. Kasa $33.862, MRR $4,8K.
- H28: Ar-Ge bitti, Çoklu Entegrasyon kartı; ilk dolu sprint. Selin izinde.
- H29–H30: v1.9. "Sahibi değişti", "Muhasebecileri". Arda'nın kâğıdı görülmeden doldu. Kasa $26.199, MRR $5.173.

## Dosyalar

- `notlar.md`: oyun sırasında yazılan tam not (her kartın şıkları, çipleri, Türkçe notu, sprint ve satış gözlemleri).
- `dogrulama.json`: bulguların kod doğrulaması (karar, mekanizma, `dosya:satır` kanıt).
- `kareler/`: 13 anahtar kare (WebP).
- H30 kaydı (`quick_mvx54wxk.json`, olay geçmişi `state/systems/event_engine/rows`) **kayboldu**: dizüstünün `/tmp` temizliği oyun klasörünü sildi (2026-11-02); haftalık olay dökümü `notlar.md`de duruyor.

Bu klasör 2026-11-02 geri kuruldu (dizüstünün `/tmp` temizliği çalışma kopyasını sildi): `RAPOR.md`, `notlar.md` ve `dogrulama.json` oturum kaydından, kareler ve `index.html` yayımlanmış sayfadan; içerik 28 Ekim sürümüyle aynı, yalnız kayıt satırı değişti.
