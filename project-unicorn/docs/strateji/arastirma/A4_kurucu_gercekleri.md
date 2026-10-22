# A4: İlk kez kurucuların gerçek sürprizleri ve akıllı olay tasarımı

Not: WebSearch bütçesi (en çok 12) 12. çağrıda bitti; WebSearch hata vermedi. Ondan sonra arama yapmadım. Kaynaksız satırlar "Kaynaksız (model bilgisi):" diye işaretli.

Arama sayısı: 12

Yöntem notu: 12 WebSearch kullandım. Arama özetleri ikincil olduğu için çıkan sayfaların çoğunu curl ile indirip metnini okudum (WebFetch 9 çağrı). Okuyamadığım ya da özetten aldığım satırları "özetten" diye işaretledim. Reddit'e erişemedim (403). Steam yorumlarını mağazanın appreviews API'sinden 19 Ekim 2026'da çektim. Kaynaksız her satır "Kaynaksız (model bilgisi):" ile başlar.

## Kısa cevaplar

1. İlk kez kurucuyu çoğu zaman büyük kriz değil, "böyle bir kalem varmış" sürprizi yakalıyor: ekipman, kesinti, sigorta sertifikası, vade, imza eksikliği. Ortak kalıp şu: kurucunun bir varsayımı var, arkasında görmediği bir bağımlılık çıkıyor, bir fatura geliyor [1] [4] [15] [19].
2. Erdem'in "bana iş bilgisayarı gönderecek misiniz" örneği gerçek bir kural ve gerçek bir maliyet. Türkiye'nin 2021 Uzaktan Çalışma Yönetmeliği, sözleşmede aksi yoksa iş araçlarını işverenin sağlamasını esas alıyor [4] [5]. GitLab yeni çalışana ilk yıl 1.500 dolar ev ofisi ödeneği veriyor [1].
3. Aşağıda 37 olay tohumu var. Çoğu mevcut fiillerle (`add_cash`, `change_morale`, `productivity_mod`, `set_flag`, `schedule_event`) yazılır. Fiil listesinde karşılığını görmediğim üç tür var: aylık sürekli gider, vadeli tahsilat, kilitli nakit [50].
4. "Düşünülmüş" olayın ortak izi: kendi durumundan doğar, bedel oyuncunun zaten korktuğu para biriminde ölçülür, şıklar farklı hamlelerdir, seçim iz bırakır. Jenerik olay bu dördünden birini kaçırır. Kanıt: Papers, Please [31] [32], Frostpunk [34] [35], RimWorld [39]; kötü örnekler This Is the Police [38], Crusader Kings III [42], Startup Company [43], Football Manager [44].
5. Mevcut 130 kartın 59'u ürün sprinti. Hiç kart yok: ilk işe alım, uzaktan çalışan, vergi kesintisi, sigorta, kira sözleşmesi. 24 kart tek düğmeli. `world.` altındaki dört kart aynı kalıp [48].
6. Dönem çelişkisi var: plan 2012, ama yazar brifi "2012'de uzaktan çalışma yok" diyor [49]. Tohumlara 2012 uyum etiketi koydum.

## Bulgular

### Soru 1. Aşama aşama gerçek sürprizler

Dünyanın yeri (Görüş: sonuç bana ait, veri kaynaklı). `localization/strings.csv` içinde İstanbul, Ankara, İzmir, Kadıköy, Levent gibi şehir ya da semt adı yok. Türkçe adlar var: İş hanı, Plaza katı, Depo loft, Marmara Lojistik, Deniz Lojistik, Lira Kapital. Para birimi dolar (Frank'in çeki "yirmi beş bin dolar"). Haber bandında "kur dalgası" ve "yazılım ihracatında vergi istisnası" var [47]. "Ege Lojistik" strings.csv'de yok, yalnız `docs/tasks/faz_cde/` PRD'lerinde geçiyor [49]. Yani dünya Türk kokulu ama şehirsiz ve dolarlı. Türkiye'ye özgü sürprizler adı değil işlevi anlatılarak (ihbar süresi, kıdem, stopaj) EN oyuncuya da anlaşılır olur.

Evden çalışma ve ilk uzaktan çalışan
- GitLab yeni çalışana ilk yıl 1.500 USD ev ofisi ödeneği, sonraki yıllar 500 USD yenileme veriyor. Laptop ayrı: şirket sağlıyor. Aylık internet faturası geri ödeniyor, kurulum ve router ödenmiyor [1].
- Aynı politikada internet ödemesi bazı ülkelerde vergilenebilir gider sayılıyor (İngiltere örneği) ve Hollanda'da ayrı form isteniyor [1]. Yani "internet yardımı" ülkeye göre karmaşıklaşıyor.
- Uzaktan işe girişte tipik teknik sorunlar: "delayed equipment delivery, to trouble with account creation". Farklı saat dilimlerinde belgeyle asenkron çalışma öğretmek öneriliyor [2].
- Şirket laptopları uzaktan şifrelenip kilitlenip silinebilen yönetilen cihaz. Çalışanın kendi aldığı cihaz elle kaydedilmeli; kayıtsız cihazdan şirket servislerine girilmemeli [3].
- Türkiye: uzaktan çalışma sözleşmesi yazılı olur (m.5). Mal ve hizmet üretimi için gereken araçları, sözleşmede aksi yoksa işveren sağlar: "aksi kararlaştırılmamışsa işveren tarafından sağlanması esastır" (m.7). Sağlanan araçların teslim günündeki bedelini gösteren liste çalışana yazılı verilir, imzalı nüsha özlük dosyasında kalır. Üretimle ilgili zorunlu giderlerin kim tarafından karşılanacağı sözleşmede yazılır (m.8) [4] [5]. Yönetmelik 10 Mart 2021 tarihli; 2012 dünyasında yoktur.
- İşveren primleri: Türkiye'de işveren katkısı %22,75 olarak veriliyor; giriş bildirimi çalışan başlamadan önce yapılır [6]. YC rehberi ABD için bir mühendisin "tüm giderle" ayda yaklaşık 15 bin dolara geldiğini söylüyor [12].
- Çalışan mı serbest mi: IRS üç kategoriye bakıyor: davranışsal kontrol, finansal kontrol (araçları kim sağlıyor, giderler nasıl ödeniyor), ilişkinin türü [30].

İlk işe alım
- Paul Graham: iş adamları "iyi programcı sandıkları" ama olmayan kişileri seçiyor [10]. "The classic way to burn through cash is by hiring a lot of people" [10]. Kurucu kavgaları yaygın: fonladıkları şirketlerin yaklaşık %20'sinde bir kurucu ayrılmış; vesting önerisi buradan çıkıyor [10].
- Türkiye: deneme süresi 2 ay (toplu sözleşmeyle 4), bu sürede ihbar ve tazminat yok. İhbar süresi kıdeme göre 2, 4, 6, 8 hafta [6]. Kıdem tazminatı yıl başına 30 günlük brüt ücret, 1 yıl dolunca doğar; tavan 6 ayda bir güncellenir ve 1 Temmuz 2026'dan itibaren yıl başına 73.729,87 TL [7]. İhbarı paraya çevirmek mümkün (ihbar tazminatı), vergilenir [7].
- Karşı teklif, "beklenti farkı" ve aday pazarlığı için güvenilir kaynak bulamadım (Bulunamayanlar).

İlk ofis
- Ev sahibi, şirketin geçmişi kısaysa kurucudan kişisel kefalet isteyebilir; tutar sınırı ya da bitiş tarihi pazarlık edilebilir. Baz kira dışında vergi, sigorta, bakım ve büyük sermaye harcamaları kiracıya yüklenebilir [21] (WebFetch özeti).
- Türkiye: kirayı bireyden kiralıyorsan şirket %20 stopaj keser ve muhtasar beyanla öder; kurumsal ev sahibinde yok. Satıcı rehberi bunu yeni şirketlerin en sık hatası sayıyor [8].
- Depozito tutarı, internet hattı kurulum süresi, tadilat gecikmesi için doğrulanmış kaynak bulamadım. Komşu, gürültü, bina kuralları için de yok.

İlk kurumsal müşteri
- Güvenlik anketi ve sigorta: alıcıların tedarikçiden Tech E&O ve siber sigorta sertifikası istediği, sertifika gelene kadar tedarikçi kaydının durduğu anlatılıyor. Kaynak bir sigorta şirketi, ticari çıkarı var [20].
- Vade: Net 30 ABD B2B varsayılanı; Net 60 ve Net 90 alıcının ödeme süresini uzatır, tedarikçinin tahsilat süresini artırır [19].
- SLA: %99,9 erişilebilirlik yılda 8760 saatin 8751'ini çalışmak demek, yani yaklaşık 9 saat kesinti payı [29].
- Paul Graham: "The big customer who wants to use your system in their whole company won't" [11]. Anlaşma gerçekleşmeden varsayma.
- 60 gün vade, güvenlik anketi ve SLA için "ilk kez yaşayan kurucu" anlatısı (blog, Reddit) bulamadım; bunlar kurum kuralı kaynakları.

İlk yatırım
- YC: hisse turu her zaman SAFE'ten daha karmaşık, pahalı ve uzun; bu yüzden "always want to hire a lawyer". Seed için çok due diligence belgesi hazırlama; çok isteyen yatırımcıdan kaçın [12].
- Techstars: sorun tek büyük hukuk meselesi değil; küçük boşluklar toplamı: belgelerle tutmayan cap table, düzgün çıkmamış kurucu hissesi, eksik IP devri, imzasız danışman sözleşmesi [14]. Yüklenicinin yazdığı kod ve şirket kurulmadan önce yazılan kod için ayrı devir gerekir [15].
- Delaware: 10 milyon yetkili hisseyle varsayılan yöntem 85.165 dolar gösterir (Clerky örneği), alternatif yöntemle çoğu girişim 400 dolar öder [16] [17].
- 83(b) beyanı hisse devrinden 30 gün sonra kapanır, uzatma yok; kaçıran, satamadığı hisse üzerinden gelir vergisi öder [18].
- "The VCs who say they're going to invest in you aren't" [11].

Büyüme
- İlk işten çıkarma: yazılı not tut, kişi performanstan haberli olsun. "If someone is surprised they are getting fired for performance, then you've failed as their manager" [13]. İlk çıkarmadan önce avukat danış [13].
- Türkiye'de işe iade davasından önce zorunlu arabuluculuk var (2018'den beri) [7].
- Paul Graham: "Disasters are normal in a startup": kurucu ayrılır, anlaşma düşer [11].
- İlk yönetici, kültür, ilk istifa için kaynaklı anlatı bulamadım.

B2C
- Apple: gönderim son sürüm olmalı, yer tutucu metin silinmeli, hesap tabanlı özellik varsa demo hesap verilmeli (m.2.1) [22]. Hesap oluşturma varsa uygulama içinde hesap silme de sunulmalı [22]. Komisyon: yılda 1 milyon dolara kadar %15 [23].
- Google Play: yeni kişisel geliştirici hesabı yayından önce "a minimum of 12 testers" ile en az 14 gün kapalı test yapmalı [24].
- Ters ibraz: banka ödemeyi hemen geri alır ve Stripe bakiyenden anapara ile ağ ücretini keser. Yanıt penceresi genelde 7 ile 21 gün; yanıtlamazsan otomatik kaybedersin. Ağ izleme eşiği olarak %0,75 aşırı sayılır [25]. Uyum itirazında ayrıca 500 dolar [25].
- Yeni işte ödeme sağlayıcı satışın %5 ile %15'ini 30 ile 180 gün tutabilir (rolling reserve). Kaynak ödeme-itiraz hizmeti satan bir şirket [26].
- GDPR: silme talebine bir ay içinde yanıt, zor durumda iki ay daha uzatma [27].
- Ani trafik: büyük bir site linkleyince küçük site aşırı yüklenir ve erişilemez olabilir (hug of death) [28].

### Soru 2. Olay tohumları

Tahmin: Tablodaki seçenek bedelleri oyun ölçeğine uyarlanmış tasarım önerisidir. Ölçek: junior geliştirici 2.000 ile 3.000 dolar/ay [50], başlangıç kasası 10.000 dolar (Erdem 50.000 diyor). Olgu kısmı (durum, neden ilk kez) kaynaklıdır. Mevcut kartlarla çakışanı son sütunda belirttim. Dönem sütunu: E = 2012'de de olur, U = 2012'ye uyarla, H = 2012'de yok (yalnız 2026 başlangıcında olur).

| # | Aşama | Durum | Neden ilk kez | Bedel | Seçenekler ve bedeller (Tahmin) | Kaynak | Dönem |
|---|---|---|---|---|---|---|---|
| 1 | Uzaktan | İkinci haftada çalışan yazar: "Bana iş bilgisayarı göndereceksiniz, değil mi? Kendi bilgisayarımdan çalışıyorum." | Ofiste bilgisayar zaten vardı, ödenmişti. Uzaktan çalışanda "ofis" yok. | kasa, moral | (a) Yeni laptop gönder: -1.300$, bir hafta kargo, moral +. (b) Tek seferlik 800$ ödenek, kendisi alsın: -800$, moral 0. (c) Kendi cihazıyla devam, ayda 50$ kira: sürekli gider, veri riski (tohum 3). Seçim "ekipman politikası" bayrağı kurar. | [1] [4] [5] | E |
| 2 | Uzaktan | Çalışan sorar: "Evde internet ve elektrik faturası kime ait?" | Ofiste hiç sorulmazdı; sözleşmede yazmadın. | kasa (aylık), moral | (a) Aylık sabit 40$. (b) Belgeyle geri öde. (c) "Sözleşmede yok": 0$, moral -4, ayrılma riski. | [1] [4] | E |
| 3 | Uzaktan | Çalışan müşteri verisini aileyle paylaştığı kişisel laptopta tutuyor. | "Yönetilen cihaz" kavramı hiç aklında yoktu. | itibar, zaman | (a) Yönetilen laptop + disk şifreleme: -1.300$, bir hafta. (b) Yazılı kural + kurulum yardımı: 0$, kurucudan 3 gün. (c) Bırak: 0$, ileride sızıntı kartının olasılığı artar. | [3] | U |
| 4 | Uzaktan | İlk iş günü: hesaplar açılmamış, laptop yolda, çalışan üç gün boşta. | Onboarding'i hiç yapmadın. | zaman, moral | (a) Express kargo -90$, kurucu telefonla eşlik eder. (b) Geçici kendi cihazıyla başlat (tohum 3 riski). (c) Başlangıcı bir hafta kaydır: maaş akar, iş yok. | [2] | E |
| 5 | Uzaktan | Çalışan başka saat diliminde; kurucu 21:00'de görüşme istiyor. | "Aynı odada olmak" varsayımı. | zaman, moral | (a) Üç saatlik ortak pencere: hız -%10. (b) Yazılı günlük: belge +, hız -. (c) Kurucu geceye kayar: kurucu verimi -%20, iki hafta. | [2] | E |
| 6 | Uzaktan | "Fatura keserim" diyen serbest çalışan haftada 40 saat çalışıyor, sözleşme yok. | Çalışan ile serbest farkı yazılı değildi. | kasa, itibar | (a) Çalışan olarak kaydet: maliyet +%22,75. (b) Proje bazlı sözleşmeye çevir: kapsam küçülür. (c) Olduğu gibi bırak: denetim riski. | [6] [30] | E |
| 7 | İşe alım | "Net 2.500 konuşmuştuk": gerçek maliyet brütten ve primlerden büyük. | Net mi brüt mü diye sormadın. | kasa | (a) Net'i tut: aylık maliyet yaklaşık +%23. (b) Brüte çevir: güven -. (c) Rolü küçült. | [6] [12] | E |
| 8 | İşe alım | Aday: "Şu anki işimde ihbar süresi var, altı hafta sonra başlarım." | "Hemen başlar" sanıyordun. | zaman | (a) Bekle: sprint boş kalır. (b) Köprü için serbest çalışan: -2.400$. (c) Yarı zamanlı başlat: aday eski işverenle sürtüşür. | [6] | E |
| 9 | İşe alım | Yedinci haftada ilk çalışan beklenenin altında; deneme süresi iki ay. | Deneme süresinin ucuz çıkış olduğunu bilmiyordun. | zaman, moral, kasa | (a) Deneme bitmeden ayrıl: bedelsiz, itibar -1. (b) Dört hafta koçluk: maaş + kurucu zamanı. (c) Sür: bir yıl sonra kıdem tazminatı doğar. | [6] [7] [13] | E |
| 10 | İşe alım | Parlak özgeçmiş, "sertifikalı" geliştirici; üç haftadır teslim yok. | Teknik değerlendirme yapamıyorsun. | zaman, kasa | (a) Dışarıdan kıdemli kod incelemesi: -600$. (b) İki haftalık deneme işi. (c) Güven, devam. | [10] | E |
| 11 | İşe alım | Arkadaşın "ben de gelsem" diyor; işi yok, paran dar. | İlk kez kadro kararı kişisel. | kasa, ilişki | (a) Hayır: ilişki -. (b) Proje bazlı: -800$. (c) Al: aylık -2.000$, runway kısalır. | [10] | E |
| 12 | İşe alım | İlk çalışan maaş yerine hisse ister. | Hisse planın yok. | seyrelme, hukuk | (a) Küçük opsiyon + avukat: -2.000$. (b) Zam ver, hisse verme: +300$/ay. (c) Reddet: moral, çıkış riski. | [12] [14] | E |
| 13 | Ofis | Ev sahibi üç aylık depozito ve kurucudan kişisel kefalet ister. | Şirketin kredi geçmişi yok. | kasa kilitli, risk | (a) Depozito öde: nakit kilitlenir. (b) Kişisel kefil ol: nakit az, kefalet bayrağı. (c) Coworking: pahalı ama esnek. Depozito oranı: Kaynaksız (model bilgisi). | [21] | E |
| 14 | Ofis | Ev sahibi birey; şirket %20 stopaj kesip beyan etmeli. | Kirayı tam ödemek yetmez. | kasa, zaman | (a) Muhasebeci ayda 150$. (b) Kendin öğren: kurucu zamanı. (c) Unut: ceza sonra gelir. | [8] | E |
| 15 | Ofis | Kira dışında ortak gider ve büyük tadilat payı çıkıyor. | Sözleşmede "ek kira" kalemlerini okumadın. | kasa | (a) Tavan pazarlığı: bir hafta. (b) Kabul et. (c) Daha ucuz binaya bak. | [21] | E |
| 16 | Ofis | Taşınma haftası: internet hattı gelmedi, masalar yarım. | Kurulum süreleri bilinmiyor. | zaman | (a) Mobil internet -200$. (b) Evden devam: hafta kaybı. (c) Taşınmayı ertele. Kaynaksız (model bilgisi). | - | E |
| 17 | Kurumsal | Büyük müşteri sözleşme öncesi Tech E&O ve siber sigorta sertifikası ister; gelene kadar tedarikçi kaydı durur. | Küçük müşteriler sigorta sormamıştı. | kasa, zaman | (a) Poliçe al: yıllık -2.500$, bir hafta. (b) Limit pazarlığı: avukat -600$, iki hafta gecikme. (c) Vazgeç: müşteri kaybı. | [20] | U |
| 18 | Kurumsal | İlk büyük fatura Net 60; ay sonunda kasa eksiye yaklaşır. | Satış yapmak para almak sanıldı. | kasa (zamanlama) | (a) Net 30 iste: hız düşer ya da reddedilir. (b) Faktoring: tutarın %3'ü. (c) Kabul et: runway -4 hafta. | [19] | E |
| 19 | Kurumsal | Sözleşmede %99,9 yazıyor; ay içinde altı saat kesinti oldu. | %99,9 yılda yaklaşık 9 saat demek. | kasa, memnuniyet | (a) Kredi öde: o ay MRR -%10. (b) Nöbet düzeni: kurucu geceleri. (c) Sessiz kal: güven -. Çakışma: `product.incident_outage_b2b` var; bu madde onu önceden sahneler. | [29] | E |
| 20 | Kurumsal | Müşteri "bütün şirkete yayacağız" dedi, üç haftadır ses yok; sen işe alım planını buna kurdun. | "Büyük müşteri evet dedi" sanıldı. | zaman, moral | (a) Takibi sürdür: zaman. (b) Planı muhafazakar kur. (c) Yine de işe al: kasa riski. | [11] | E |
| 21 | B2C | Kullanıcı: "Verilerimi silin"; yanıt süresi bir ay. | Silme aracın yok. | zaman, itibar | (a) Elle sil: kurucudan iki gün. (b) Silme aracı sprint kartı. (c) Yok say: şikâyet büyür. | [27] | U |
| 22 | Yatırım | Frank'in çeki geldi, ardından avukat faturası. | "Çek bedava para" sanıldı. | kasa | (a) Standart belge: -3.000$. (b) Tam tur belgeleri: -12.000$. (c) Avukatsız: risk. | [12] | E |
| 23 | Yatırım | Hisse devrinden sonra 83(b) beyanı için 30 gün var; sen kaçırdın. | Kuruluş evrakı "bitti" sanıldı. | kasa (gecikmeli) | (a) Avukatla hemen: -400$. (b) Kendin: hata riski. (c) Unut: yıllar sonra vergi. | [18] | E |
| 24 | Yatırım | Delaware bildirimi: 85.165$ franchise tax. | Yetkili hisse sayısı yüksek açılmıştı. | kasa, zaman | (a) Yeniden hesapla, 400$ öde: iki gün. (b) Panikle öde: -85.165$. (c) Muhasebeciye ver: -500$. | [16] [17] | U |
| 25 | Yatırım | Due diligence: eski yüklenici kodun sahibi, devir imzası yok. | Ödemenin mülkiyeti devrettiğini sandın. | kasa, zaman, itibar | (a) Yükleniciye devir imzası için -1.500$. (b) Kodu yeniden yaz: üç hafta. (c) Yatırımcıya açıkla: tur gecikir. | [15] [14] | E |
| 26 | Yatırım | Cap table belgelerle tutmuyor: danışmana sözlü hisse sözü vermiştin. | Sözü yazıya dökmedin. | zaman, itibar | (a) Düzelt: avukat -2.000$. (b) Yatırımcıya baştan söyle. (c) Sakla. | [14] | E |
| 27 | Yatırım | Yatırımcı "evet" dedi, üç haftadır sessiz; kasa 14 hafta. | Sözlü evet bağlayıcı sanıldı. | zaman, moral | (a) İki yeni görüşme aç. (b) Maaş kesintisi öner. (c) Bekle. | [11] | E |
| 28 | Büyüme | İlk kovma: çalışan "neden?" der, ekip sessizleşir. | Yazılı geri bildirim vermemiştin. | moral, kasa | (a) Ayrılık paketi (1 ay) + belge. (b) Yazılı uyarı + dört haftalık plan. (c) Ertele: ekip morali -. | [13] | E |
| 29 | Büyüme | Bir yılı dolduran çalışanı çıkarmak kıdem tazminatı doğurur. | "Çıkarırım" bedelsiz sanıldı. | kasa | (a) Öde: yıl başına 30 gün brüt. (b) Yıl dolmadan karar ver. (c) Rolünü değiştir. Not: oyunun `HRConstants.severance_amount` kuralı yıl başına bir aylık maaş verir (en çok 3 ay; yıldan azsa üçte bir); Türkiye kuralından farklıdır. | [7] [50] | E |
| 30 | Büyüme | Çıkarılan çalışan arabulucuya başvurur. | Hukuki süreç olacağını düşünmedin. | kasa, zaman | (a) Uzlaş: iki aylık maaş. (b) Savun: avukat -3.000$, zaman. (c) Dinlemeden geç. | [7] | U |
| 31 | Büyüme | Kurucu ortak ayrılır, vesting yok, hissesi onda kalır. | Kurucu kavgası olacağını düşünmedin. | hisse, moral | (a) Geri satın al: -kasa. (b) Hissesi onda kalsın: seyrelme, yatırımcı sorusu. (c) Uzlaşma: danışman. | [10] [11] | E |
| 32 | B2C | İlk mağaza gönderimi reddedildi: demo hesap yok, metin yer tutucu. | İncelemeyi insan yapıyor; sonuç günlerle ölçülüyor. | zaman | (a) Düzelt, yeniden gönder: bir hafta. (b) İtiraz: belirsiz. (c) Önce başka platform. | [22] | E |
| 33 | B2C | Play'de yeni hesap, yayından önce 12 test kullanıcısıyla 14 gün kapalı test ister. | Yayın tarihi planda bunu içermiyordu. | zaman | (a) 12 arkadaş bul: marka +/-0. (b) Ücretli test servisi: -300$. (c) Önce yalnız iOS. | [24] | H |
| 34 | B2C | Ödeme sağlayıcı satışın %10'unu 90 ile 180 gün tutuyor. | İlk geliri "hemen kasada" sandın. | kasa (zamanlama) | (a) Yıllık plan teşviki: nakit önden. (b) Sağlayıcı değiştir: iki hafta. (c) Kabul et. | [26] | E |
| 35 | B2C | Ters ibraz: para anında geri çekildi, ücret kesildi; yanıt için 7 ile 21 gün var. | Müşteri sana değil bankaya gitti. | kasa, itibar | (a) Kanıt topla: zaman. (b) İade et: ücret yine ödenir. (c) İade politikasını netleştir. Çakışma: `customer.chargeback` B2B tarafı. | [25] | E |
| 36 | B2C | Forumda paylaşıldı: trafik 40 kat, site düşer, sunucu faturası. | Ölçek planı yoktu. | kasa, kullanıcı | (a) Ölçekle: -1.500$. (b) Kayıt kapat: kullanıcı -. (c) Bırak. Çakışma: `product.sprint_solo_server_bill`, `product.incident_review_storm`. | [28] | E |
| 37 | B2C | Mağaza ödemesi geldi, %30'u gitti. | Fiyatı komisyonsuz hesaplamıştın. | marj | (a) Fiyatı artır. (b) Web ödemesine yönlendir (mağaza kuralına bağlı). (c) Kabul et. | [22] [23] | E |

Dönem notu: [49] planın 2012 olduğunu ve yazar brifinin "uzaktan çalışma ve ekip sohbet uygulaması yok (2012)" dediğini söylüyor. Görüş: Tohum 1, 2, 4, 5 (laptop, internet, kargo, saat farkı) dönemden bağımsız yazılabilir, çünkü uzaktan çalışma 2012'de de Skype ve e-postayla yapılabiliyordu (bu ayrıntı kaynaksız: model bilgisi). Tohum 3 (yönetilen cihaz), 21 (GDPR), 30 (zorunlu arabuluculuk), 33 (Play testi) bugünkü kuralla yazılmış; 2012 karşılığı ayrı yazılmalı. Yönetmelik maddeleri (tohum 1) 2021'den; 2012 sahnesinde bu "sözleşmede yazmamıştın" biçiminde kalır.

Kaynak güvenilirliği: [8] [19] [20] [26] satıcı ya da danışmanlık sayfası. [21] WebFetch özeti. Hukuki sayıların (stopaj, prim oranı, tavan) bugünkü doğruluğunu yerel avukat teyit etmeli.

### Soru 3. Düşünülmüş olay ile jenerik olay farkı

R6'daki RimWorld, CK3, Reigns, Cultist Simulator, Hades bulgularını tekrar etmedim [R6]. Eksik kalanlar:

- Papers, Please: Lucas Pope oyunu aşağıdan yukarı kurdu: önce belge kontrol mekaniği, anlatı sonra. Tavsiyesi: "Don't tell or show something when you can make the player do it themselves" [32]. Her gün sonunda para kira, yemek, ısınma için bölüştürülür; borçlanırsan oyun biter [31]. Hata (ceza) da para kesiyor. Bu yüzden her ahlaki seçim aynı paranın içinde ölçülüyor.
- Papers, Please oyuncu tepkisi: 43.914 yorumun %97'si olumlu [33]. Bir yorumcu hızla ve titizlikle çalışmanın dengesini anlatıyor: "rushing through inspections meant making mistakes and receiving citations, which cost me even more" (id 234574274). Başkası: "forcing you to weigh your morals against the financial consequences" (id 233607208) [33].
- Frostpunk: ilk sürümde vatandaş talebi çıkıyordu, oyuncuya "player agency" yoktu. 11 bit bunu Yasalar Kitabı'na çevirdi. Marta Fijak: "there is no player agency" [35]. Yasalar sıralı ve her biri öncekinden "biraz daha fazla": "creeping normality" [34] [35]. Eleştirmenler etik seçimleri övdü, tekrar oynama değerini eleştirdi [34]. Steam'de olumsuz yorum: "low replay value" ve "There is a clear winning strategy" [36].
- This Is the Police: net hedef (180 günde 500.000 dolar) her seçime para ağırlığı veriyor [37]. Ama eleştirmenler tekrarı sevmedi: Kate Gray ilk birkaç saatten sonra sıkıcı buldu [37]. Steam %72,6 olumlu (3.697 yorum) [38]. Olumsuz yorumlar tam bizim sorunumuz: "zero choice importance" (id 233923822) ve "you basically have to figure out how the developer wants you to play" (id 234085806) [38]. Yani sahte seçenek özgürlüğü ve geç oyunda tekrar.
- RimWorld: "storyteller" algoritması oyuncunun mevcut durumunu analiz edip olay seçiyor; üç anlatıcı var: gerilim yükselip alçalan Cassandra, mola bırakan Phoebe, rastgele Randy [39]. 143.395 yorumun %98'i olumlu; yorumcular anlatıcıyı oyunun parçası sayıyor (id 236234847) [40].
- Crusader Kings III: kişilik özelliklerine bağlı olaylar var ve "Friends and Foes" paketi 100'den fazla ilişki olayı ile anılar ekliyor [41]. Ama Steam olumsuz yorumu: "random stress events generated by the game, usually caused by traits, where none of the options are particularly good" (id 234522879) [42]. Ders: durumdan doğan olay tek başına yetmiyor, şıklar da gerçek hamle olmalı.
- Startup Company (doğrudan rakip): %80 olumlu (3.103 yorum) [43]. Olumsuz yorum karar jenerikliğini anlatıyor: "All the different businesses are literally the same, only the names of your competitors change" (id 231549262) [43].
- Football Manager 2024: 11.652 yorumun %93'ü olumlu. Yine de 1.172 saatlik bir oyuncu "Press conferences remain a chore you click through on autopilot" diyor (id 234734618) [44]. Sevilen oyunda bile tekrarlayan etkileşim otomatik pilota biniyor.
- Suzerain: karar ağırlıklı, 450.000 kelimelik diyalog; ana oyun 12 saatin altında bitiyor; Der Spiegel "perhaps the most realistic video game about politics" diye yazdı [45]. Diplomasi tarzı oyun yönü için kanıt: metin yoğunluğu yalnız yazı kalitesi yüksekse taşınıyor.
- Big Ambitions (öğretici ve görev sorusu): erken oyunda zengin amca öğretici oluyor. Bir oyuncu "one of the best tutorials I've ever played in my 25 years of gaming" yazmış (id 236251470); %91 olumlu (6.491 yorum) [46].

Görüş: Bu bulgulardan "düşünülmüş olay" için dört test çıkıyor: (1) olay oyuncunun kendi durumundan doğar [39] [31]; (2) bedel oyuncunun zaten saydığı para biriminde ölçülür [31] [37]; (3) şıklar farklı türde hamlelerdir, fiyat kademesi değil [42] [38]; (4) seçim iz bırakır ve sonraki olay onu anar [34] [35]. Jenerik olay bunlardan en az birini kaçırır.

### Soru 4. Mevcut olaylarla karşılaştırma

Sayım [48]: 130 kart (retired, fixture, unwired hariç). Ürün 59, funding 25, customer 17, world 8, team 8, founder 7, rival 6. Tek şıklı kart 24; bunların çoğu funding (14) ve Frank mesajları. İlk işe alım, uzaktan çalışan, vergi, sigorta, kira ve hukuk konulu kart yok; `team.first_weeks` (yeni çalışanın ilk haftaları) `retired`.

- founder: `founder.side_contract` iyi (zamanı paraya takas, iki gerçek hamle). `founder.domain_name` küçük ama somut (900$ ya da marka -2). `founder.company_of_one`, `founder.savings_note`, `founder.unseen_build` tek düğmeli gözlem kartları; bedel ve karar yok, çıtanın altında. Görüş: founder klasörü ilk kez kurucu sürprizlerine hiç değmiyor.
- team: `team.wiped_table` çıtayı geçiyor: somut kaza ("The filter was empty, and the delete took every account"), üç farklı hamle, üç farklı bedel (zaman, kasa, kitle). `team.password_rule` iyi: teknik ayrıntı ("The reminder mails out the password itself") şıkları doğuruyor. `team.demo_day` düşük riskli, soyut (morale_all +3). `team.outside_offer` jenerik: "an offer from a larger company" ve sabit -5.000$.
- customer: `customer.chargeback` güçlü ("The bank took her side"; üç hamle). `customer.new_owner` güçlü ("It sent ninety pages... The price is blank. The discount isn't."). `customer.expansion` zayıf: iki düğme, bedel kartta görünmüyor (etki `b2b_expand` fiilinin içinde). `customer.security_review` doğru konu ve doğru ilk-kez bacağı ama metin genel; anket sayısı, son gün, hangi cevap eksik gibi ayrıntı yok.
- funding: `funding.portfolio_vendor` çok iyi: yatırımcı kendi portföy şirketini dayatıyor, dört hamle, ilişki bedeli (`investor_strain`). `funding.closing_docs_diligence` iyi ("Nobody had asked about them"). `funding.hire_nudge`, `funding.frank_office_move`, `funding.seed_stalled` yönlendirme ya da tek düğme; öğretici olarak tamam, olay olarak değil.
- product: `product.launch_leak` en iyilerden: adres çubuğundaki sayıyı değiştirip başkasının hesabına girmek, dört hamle, itibar ile kitle arasında gerçek takas. `product.repeat_reminders` ("Nobody has apologised to {customer}") güçlü. `product.incident_checkout` sprint durdurma, kurucu düzeltmesi, gece mesaisi, erteleme gibi farklı türde hamleler sunuyor.
- world: `world.app_placement` ile `world.newsletter_slot` aynı sayılarla aynı kalıp (-25.000$, +0,2 kitle; geçersen marka -2). `world.trade_fair` ve `world.b2c_creator_feature` da "öde, büyü; geç, marka -2" kalıbında. Görüş: dört kart tek şablon; oyuncu ikincisinde kalıbı tanır.
- rival: `rival.false_partner` güçlü ("said they were calling on your behalf", dört hamle). `rival.copycat` ("down to the typo") somut ve iyi. `rival.shutdown_notice` somut ayrıntıyla ("a file no other app can open") iyi. `rival.price_cut` makul ama şıklar (`b2b_retain_discount`, `promise_create`) bir fiile bağlı.

Görüş: Kartların en güçlüleri (`team.wiped_table`, `product.launch_leak`, `customer.new_owner`) Erdem'in çıtasına yakın: tek bir ürün kazası ya da müşteri hamlesi, farklı türde şıklar. Eksik olan kart türü "ilk kez" sürprizleri: şirketin çalışma biçiminden doğan, kuralı bilmemekten gelen bedeller.

## Project Unicorn için dersler

1. Görüş: "İlk kez" sürprizleri aşamalara sıkı bağlı. Ev, ilk uzaktan çalışan, ilk ofis, ilk kurumsal müşteri, ilk yatırım, ilk yönetici: her eşikte yeni bir "ilk kez" kümesi doğuyor (37 tohumun aşama dağılımı bunu gösteriyor). Bu, Erdem'in "birinci saat ile 20. saat farklı olsun" vaadine içerikten gelen bir eksen: oyuncu her eşikte yeni bir şey bilmediğini keşfediyor, aynı sorunla uğraşmıyor.
2. Görüş: Kart yazım kalıbı olarak şu dört satırı öneririm: kurucunun varsayımı, görmediği bağımlılık, fatura, üç farklı hamle. Erdem'in laptop örneği tam bu kalıp: varsayım "ofis her şeyi sağlar", bağımlılık "uzaktaki çalışanın ofisi yok", fatura 1.300$, hamleler yeni cihaz, ödenek, kendi cihazı.
3. Görüş: Seçim iz bıraksın. Tohum 1'de oyuncunun cevabı "ekipman politikası" bayrağını kursun (`set_flag`); ikinci uzaktan çalışan geldiğinde soru tekrar edilmesin, politika gereği bedel otomatik düşsün ya da politikayı değiştirme kararı çıksın. Bu hem tekrarı önler hem Frostpunk'ın sıralı yasa fikrini küçük ölçekte uygular [34] [35]. Motor bunu `set_flag` ve `schedule_event` ile yapabilir [50].
4. Görüş: Bedeli sabit dolar değil ölçeğe bağla (aylık maaşın oranı, runway haftası). Başlangıç kasası 10.000$'dan 50.000$'a çıkarsa 1.300$'lık laptop %13'ten %2,6'ya düşer. Kural 1 ile 50 kişi arasında kırılmamalı kuralıyla (Erdem 2026-10-17, bellek notu) uyumlu.
5. Görüş: "Gizli gider yok" kuralıyla çakışmayan biçim: sürpriz bedel oyuncunun seçimine bağlı olsun, durup dururken kasayı eksiltmesin. Tohumlarda hep "ben sormadım, çalışan sordu" biçiminde yazıldı; çalışanın sorusu bir seçimdir, kasadan kesinti değil.
6. Görüş: Ton. "Hüküm yalnız Frank'in ağzında" kuralı (CLAUDE.md §5) bu tohumlara uyar: kart durumu söyler (çalışan sordu, ev sahibi istedi), hükmü vermez. Doğru bilgiyi kartın içine koymak (yönetmelik, stopaj) öğretir ama ders anlatmaya kaymasın: bilgi bir ayrıntı olarak girsin, oyuncu çıkarsın.
7. Görüş: Şık kalitesi. CK3'te "none of the options are particularly good" [42] ve Erdem'in daha önceki "sorun şıklar" geri bildirimi aynı yere işaret ediyor. Her tohumda üç hamle farklı türde yazıldı (para öde, zaman öde, ilişki öde). Fiyat kademesi (küçük, orta, büyük bedel) şık sayılmaz.
8. Görüş: Şablon tekrarını ölç. `world.` dört kartının aynı kalıbı [48] tek başına jenerik hissi verir. Yeni kart eklerken kalıp çeşitliliğini (öde-büyü, geç-kaybet, vazgeç) de say.
9. Görüş: Yeni mekanik gereksinimi: aylık sürekli gider (tohum 2 ve 1'in (c) şıkkı), vadeli tahsilat (18, 34), kilitli nakit (13, 34). Olay motorunda bunlar için fiil görmedim; tek seferlik `add_cash` var [50]. Faz C'nin giderler işi bunu getirirse bu tohumlar yazılabilir. Bu arada tek seferlik karşılıklarıyla (ödenek, depozito kaybı) yazılabilen tohumlar: 1, 4, 5, 6, 8, 9, 10, 11, 12, 14, 15, 22 ile 32.
10. Görüş: Dönem kararı gerek. Plan 2012 [49]; Erdem'in uzaktan çalışan isteği ise PLAN_C'de "C9 askıda" duruyor [49] ve yazar brifi 2012'de uzaktan çalışma yok diyor [49]. Laptop, internet, saat farkı 2012'de de var (Skype, e-posta). Yönetilen cihaz, Slack benzeri sohbet, GDPR ve Play testi 2012'de yok. Karar Erdem'in.
11. Görüş: Tohum 6 ve 7 (çalışan mı serbest mi, net mi brüt mü) oyuncuyu ilk işe alım ekranında bilgilendirme olarak da çıkabilir. Olay olarak yazmadan önce işe alım penceresinde "işveren maliyeti" satırı olması daha çok kişiyi yakalar. Bu bir arayüz önerisidir, bu araştırma onu test etmedi.
12. Tahmin: Demo (Bootstrap'tan Series A'ya) bu "ilk kez" kümelerinin yalnız ilk üçünü (ev, ilk çalışan, ilk ofis) ve belki ilk kurumsal müşteriyi gösterir. Oyuncu "birinci saat ile 20. saat farklı" duygusunu demoda ancak bu eşiklerin demo içinde aralıklı gelmesiyle alır. Demo süresi 60 ile 90 dakika hedefli [CLAUDE.md]; hangi eşiklerin sığacağını ölçmedim.
13. Görüş: Tekrar eden etkileşim çöpe gider: Football Manager basın toplantısı örneği [44]. Her tohum kartı bir kez, bir eşikte gelsin; ikinci kez gelirse kısa varyantla (politika bayrağı) gelsin.

## Bulunamayanlar

- Reddit r/startups ve r/Entrepreneur: erişim 403. WebSearch özetleri Reddit sayfalarını getirmedi. Hacker News Algolia aramasını denedim, alakasız sonuç verdi. Kurucu deneyimi için bu yüzden blog ve rehber kaynaklarına yaslandım.
- Aday karşı teklifi, ihbar süresi sürtüşmesi, "beklenti farkı": doğrulanmış kaynak yok. Türkiye ihbar bantları [6] var, karşı teklif ve beklenti için yok.
- Ofis depozito oranı, internet hattı kurulum süresi, tadilat gecikmesi, komşu ve bina kuralları: bulamadım. Satır 13 ve 16 "Kaynaksız (model bilgisi)" olarak işaretli.
- Güvenlik anketi ve Net 60 için bir ilk kez kurucunun kendi anlatımı: yok; yalnız satıcı ve kurum kaynakları [19] [20].
- İlk yönetici, kültür, ilk istifa, terfi eden mühendisin kötü yönetici olması: kaynaklı bulgu yok.
- Yabancı para birimiyle fiyatlandırma: CMS 2018 yasağının Mart 2025'te yalnız mal satışları için kalktığını söylüyor [9]. Hizmet ve yazılım sözleşmelerinin bugünkü durumunu doğrulayamadım.
- YC "6 things you need to know before hiring your first employee": tahmin ettiğim URL 404 verdi. Stripe Atlas rehberlerinin adresini bilmediğim için hiç okuyamadım.
- Doğrulanmamış rakamlar: kira stopajı %20 [8] ve işveren prim oranı %22,75 [6] danışmanlık ve satıcı sayfaları; resmi Gelir İdaresi ve SGK sayfasından teyit edilmedi. Kıdem tavanı [7] aynı şekilde.
- Steam yorumları "en yararlı" sıralı ilk 100 ile 300 yoruma bakar, temsili örneklem değildir. Örnek yorumlar yönü gösterir, oranı göstermez.
- Reigns, Cultist Simulator, Hades için yeni arama yapmadım (R6'da var).

## Kaynaklar

1. GitLab Handbook, Expenses (ev ofisi ödeneği, internet), sayfa son değişikliği 13 Eylül 2026. https://handbook.gitlab.com/handbook/finance/expenses/
2. GitLab Handbook, The complete guide to remote onboarding for new hires, son değişiklik 19 Ağustos 2026. https://handbook.gitlab.com/handbook/company/culture/all-remote/onboarding/
3. GitLab Handbook, Laptop Management, son değişiklik 17 Ağustos 2026. https://handbook.gitlab.com/handbook/security/corporate/end-user-services/laptop-management/
4. Uzaktan Çalışma Yönetmeliği, Resmi Gazete 10 Mart 2021, sayı 31419 (metin kopyası, Alomaliye). https://www.alomaliye.com/2021/03/10/uzaktan-calisma-yonetmeligi/
5. Esin Attorney Partnership, Remote Working Regulation Entered Into Force, Mart 2021. https://www.esin.av.tr/wp-content/uploads/2021/03/Remote-Working-Regulation-Entered-Into-Force-1.pdf
6. Özbek CPA, Turkish Labour Law, 16 Eylül 2026. https://ozbekcpa.com/?p=8728
7. Teamed, Turkey Termination & Severance 2026. https://www.teamed.global/country-hiring-guides/turkey/termination-and-severance.md
8. Accounts-OS, Turkey: office rent (stopaj), tarihsiz. https://accounts-os.com/tr/expenses/office-rent-tr
9. CMS, Foreign Currency Back in Play: Türkiye Re-Allows FX Payments in Domestic Sales of Goods, Mart 2025 sonrası. https://cms.law/en/tur/legal-updates/foreign-currency-back-in-play-tuerkiye-re-allows-fx-payments-in-domestic-sales-of-goods-vehicle-sales-excluded
10. Paul Graham, The 18 Mistakes That Kill Startups, Ekim 2006. https://www.paulgraham.com/startupmistakes.html
11. Paul Graham, The Hardest Lessons for Startups to Learn, Nisan 2006. https://www.paulgraham.com/startuplessons.html
12. Y Combinator Startup Library, A guide to seed fundraising, 9 Haziran 2020. https://www.ycombinator.com/library/4A-a-guide-to-seed-fundraising
13. First Round Review, Firing Underperforming Employees (at Startups), sayfa meta tarihi 9 Eylül 2026. https://review.firstround.com/firing-underperforming-employees-at-startups/
14. Techstars, The Legal Red Flags That Can Slow Down Your Seed Round, tarihsiz. https://www.techstars.com/blog/founder-advice/the-legal-red-flags-that-can-slow-down-your-seed-round
15. OneGC, IP Assignment for Startups: The Gaps That Kill Deals, tarihsiz. https://onegc.com/blog/ip-assignment-for-startups
16. Clerky Help, How do I calculate the Delaware franchise tax?, tarihsiz. https://help.clerky.com/article/2796-calculate-delaware-franchise-tax
17. Gust, Don't Panic! Your pre-revenue startup doesn't owe $85,165 in Delaware Franchise Taxes, tarihsiz. https://gust.com/blog/delaware-franchise-taxes/
18. Rho, 83(b) election, tarihsiz. https://www.rho.co/blog/83b-election
19. Corpay, Business Payment Terms: The Complete Guide, tarihsiz. https://www.corpay.com/resources/blog/business-payment-terms
20. Corgi (sigorta şirketi blogu, ticari), How startups can instantly meet SOC 2 and enterprise vendor contract requirements, tarihsiz. https://www.corgi.insure/blog/how-startups-can-instantly-meet-soc-2-and-enterprise-vendor-contract-requirements
21. Fox Rothschild, Seven Tips for Negotiating Your First Office Lease, tarihsiz (WebFetch özeti). https://www.foxrothschild.com/publications/seven-tips-for-negotiating-your-first-office-lease
22. Apple, App Review Guidelines, erişim 19 Ekim 2026. https://developer.apple.com/app-store/review/guidelines/
23. Apple, App Store Small Business Program, erişim 19 Ekim 2026. https://developer.apple.com/app-store/small-business-program/
24. Google Play Console Help, App testing requirements for new personal developer accounts, tarihsiz. https://support.google.com/googleplay/android-developer/answer/14151465
25. Stripe Docs, Disputes; Respond to disputes; Measure disputes, erişim 19 Ekim 2026. https://docs.stripe.com/disputes ; https://docs.stripe.com/disputes/responding ; https://docs.stripe.com/disputes/measuring
26. chargeback.io (ödeme itirazı hizmeti, ticari), What is a Rolling Reserve for Merchant Accounts, tarihsiz. https://www.chargeback.io/blog/what-is-a-rolling-reserve
27. GDPR madde 12 ve 17. https://gdpr-info.eu/art-12-gdpr/ ; https://gdpr-info.eu/art-17-gdpr/
28. Wikipedia, Slashdot effect, erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/Slashdot_effect
29. Wikipedia, High availability, erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/High_availability
30. IRS, Independent contractor (self-employed) or employee?, erişim 19 Ekim 2026. https://www.irs.gov/businesses/small-businesses-self-employed/independent-contractor-self-employed-or-employee
31. Wikipedia, Papers, Please, erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/Papers,_Please
32. Reason, Papers, Please, Politics in Games, and the Growth of Indie Development: An Interview with Lucas Pope, 26 Eylül 2013. https://reason.com/2013/09/26/papers-please-politics-in-games-and-the/
33. Steam appreviews API, Papers, Please (239030), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/239030?json=1&language=english
34. Wikipedia, Frostpunk, erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/Frostpunk
35. PC Gamer (Christopher Livingston), Frostpunk developers on hope, misery, and the ultimately terrifying book of laws, tarih sayfada yok. https://www.pcgamer.com/frostpunk-developers-on-hope-misery-and-the-ultimately-terrifying-book-of-laws/
36. Steam appreviews API, Frostpunk (323190), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/323190?json=1&language=english
37. Wikipedia, This Is the Police, erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/This_Is_the_Police
38. Steam appreviews API, This Is the Police (443810), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/443810?json=1&language=english
39. Wikipedia, RimWorld, erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/RimWorld
40. Steam appreviews API, RimWorld (294100), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/294100?json=1&language=english
41. Wikipedia, Crusader Kings III, erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/Crusader_Kings_III
42. Steam appreviews API, Crusader Kings III (1158310), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/1158310?json=1&language=english
43. Steam appreviews API, Startup Company (606800), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/606800?json=1&language=english
44. Steam appreviews API, Football Manager 2024 (2252570), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/2252570?json=1&language=english
45. Wikipedia, Suzerain (video game), erişim 19 Ekim 2026. https://en.wikipedia.org/wiki/Suzerain_(video_game)
46. Steam appreviews API, Big Ambitions (1331550), çekim 19 Ekim 2026. https://store.steampowered.com/appreviews/1331550?json=1&language=english
47. Yerel dosya: `localization/strings.csv` (OFFICE_NAME_*, COMPANY_BG_*, NEWS_S_KUR_DALGA, NEWS_S_SAAS_VERGI), okuma 19 Ekim 2026.
48. Yerel dosyalar: `data/events/cards/{customer,founder,funding,product,rival,team,world}/*.json`, kart metinleri strings.csv'den; sayımı kendi betiğimle çıkardım (retired, fixture, unwired hariç), 19 Ekim 2026.
49. Yerel dosyalar: `docs/tasks/PRD_RAKIP_DUNYASI.md` (karar B, dönem 2012), `docs/tasks/PRD_YAZAR_AJANI_V2.md` (satır 380), `docs/tasks/faz_cde/c_taslak/PLAN_C.md` (C9 askıda), 19 Ekim 2026.
50. Yerel dosyalar: `scripts/systems/hr_constants.gd` (maaş bantları, kıdem), `docs/content/events_draft/_vocabulary.md` (fiil ve seam listesi), 19 Ekim 2026.
R6. Yerel dosya: `docs/strateji/arastirma/R6_yazi_anlati.md`, tekrar edilmedi.
