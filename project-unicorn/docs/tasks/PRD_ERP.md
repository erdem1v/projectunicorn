# PRD · ERP

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_ERP.md dosyasını oku ve uygula."
Ajan kendiliğinden başlamaz: §12'deki sorular cevaplanır, PRD güncellenir, sonra başlar (Erdem'in süreci, 13 Kasım).
**Durum:** taslak 1, 2026-11-13 gece, URUN oturumu. Kaynaklar:
- iki tasarım planı (`erp_tasarim_2026-11-12/PLAN_ERP_BUYUME.md`, `PLAN_ERP_EKIP.md`), eleştirmen turları ve araştırma dosyaları;
- modül şeması (`erp_tasarim_2026-11-12/MODUL_SEMASI.md`);
- Erdem'in 13 Kasım akşam yorumu (`tur4_ekranlar_2026-11-13/ERDEM_YORUMU_TUR4.md`).
Kaynak okumasıdır: kareler commit'siz bir prototipten çekildi, kod kaynağı sayılmaz. Her sayı başlangıç değeridir ve "onay
bekliyor" diye iner (§9); sayı ayarı playtest'tedir.
**Tek cümle:** ERP'nin her özelliği adlı bir modüldür; modüllerin kademeleri gerçek beceri ister ve oyuncu rolleri bu yüzden
işe alır. Eksik rol bir bedelle görünür. Müşteri adayı ERP'yi gerçekten alan sektörlerden, ürünün ününe ve uyumuna göre gelir.
Sözleşme yıllıktır. Hesap büyüdükçe yeni iş doğar.
**Çıktı:** main'e yaklaşık 76 commit (65 ile 130; push yok), §11'deki paket sırasıyla. Her commit kendi kapısı, §9 incelemesi ve görsel
kabulüyle iner.
**Yerini aldığı:** iki planın uygulanacak kısmı. Planlar gerekçe, araştırma ve ölçüm için okunur; çelişkide bu belge geçerlidir.

## Erdem için kısa özet

- **Çekirdek yok, modül var.** Sol sütun düz bir modül listesidir:
  - Muhasebe, Fatura, Kasa ve Banka, Kullanıcılar ve Yetki, Satın Alma, Stok, Mobil, Entegrasyonlar, Yedekleme;
  - hesap sayısı büyüyünce Toplu İçe Aktarma, Onay Akışı, Çok Şirket.
  Her modülün üç kademesi var (kare E1).
- **Kilitli kart şartını yazar.** "Stok · 1★ tasarımcı gerekli", "Belge Okuma · Semantik İndeks araştırılmalı". Tıklayınca işe
  alıma ya da Ar-Ge'ye gider (E1).
- **Testçi ve PM kilit değil, bedeldir.** Eksik rolün koltuğu boş görünür, uzmansız yapılan iş taralıdır (E2). Testçisiz ekipte
  Fatura'dan kaçan yanlış tutar ay sonu kapanışında o modülü kullanan bütün hesaplara aynı gece dokunur. PM'siz şirkette söz verilen
  kart büyür.
- **Yayından sonra haftada bir aday** (E3, beğenildi). Akış ürünün ününden gelir. Ün iki yönlüdür: kaçan hata ve bozulan söz onu
  düşürür. Büyük şirketler ürün onların ihtiyaç listesini karşılayınca gelir (E4). Adaylar inşaat, üretim, tekstil, toptan ticaret,
  lojistik, perakende, e-ticaret, oto yedek parça ve gıda şirketleridir; emlak ofisine ERP satılmaz.
- **Sözleşme yıllık, ödeme aylık.** Memnun olmayan hesap yıl ortasında gitmez, yenilemede gider. Yenileme her hesabın karar anıdır
  (soru 5).
- **Şirketin derinliği:** pilot müşteri, e-Fatura takvimi, kod incelemesi ve dört madde daha (soru 1).

## 0. Kararlar

### 0.1 Erdem'in kararları

| Karar | Ne | Bu belgede |
|---|---|---|
| ER1 | "Fatura kesmek tasarımcı istemez" | Fatura K1 kapısız (§2.3) |
| ER2 | Ölçek işi: yap ya da 12 haftalık kira öde; süre dolarsa bedel parayı oynatan yere | §2.6 |
| ER4 | Müşteriler Çekirdek'ten de ister; karşılanan istek büyüme ya da referans aday getirir | §2.5 (Çekirdek artık modüller) |
| Tur 4 | Ortak kurallar 1–9 (uydurma tanım yok, bilinemeyen bilgi yok, gerçek sektör, kilit yerine şart, az bilgi, sayı neye göre, soyut grup yok, angarya yok, deneme yanılma) | §1 |
| Tur 4 | E1 kilitli kartların görünmesi beğenildi; E3 yayından sonra tek aday iyi ("her satışın önemli olması") | §2.4, §4.3 |
| Tur 4 | Not ve Video türleri oyundan kalkar; demoda Pazaryeri ve ERP | Gelir alanı ERP'de yok (§2.1) |
| Tur 4 | Yayın şartı satırında tahmin yok (PY1a yorumu) | §2.4 |

### 0.2 Yardımcı yönetmenin kararları

- Dördüncü kademe (K4) yok (2026-11-13).
- Kademesiz istek ve ölçek kartının motoru ERP'nin işidir. Pazaryeri tüketicidir (2026-11-12).
- Teslimler hazır olur olmaz gider (2026-11-13).

### 0.3 Öbür oturumlarla uzlaşılanlar (13 Kasım)

- **OLAYLAR:**
  - Sözlü iş sprintin sabit bir payını geçmez. Pay PM'den bağımsızdır; PM yalnız hazırlanmamış sözlü kartın büyüme riskini
    kaldırır (§3.4).
  - Büyüme isteği yenilemeyle tek kâğıttır. Yıl ortasında yalnız hesabın istediği konu yayına çıkınca doğar (§4.5).
  - Talep konularının modülleri MODUL_SEMASI'na göre (Hesap Planı → "Hesap Eşleme").
  - D1, D4, D5, D8 kâğıtlarını OLAYLAR yazar.
  - İstek, söz ve büyüme kurallarının tek yeri PRD_TALEPLER'dir (§1, §4, §8.2). Bu PRD kademesiz kartı, kilit metnini ve sözleşmeyi
    tanımlar, kuralları atıfla okur.
- **PAZARYERI:**
  - Ortak dosyaların iniş sırası: önce PAZARYERI'nin test hazırlığı, sonra bu PRD'nin modül katmanı, kilitli satırı ve yayın
    şartı, sonra pazaryeri verisi. Ortak commit yok.
  - Şema 19 → 20 artışı pazaryerinde. Pazaryeri modül şemasını kullanır; yayın şartının not alanına gerek kalmadı.
- **ARAYUZ:**
  - Kilitli satır kuralı: kalıcı ekranda sıradaki kademe gerekçesiyle görünür (DIL_ONERISI §3).
  - Tür dosyasında ERP: "Yıllık sözleşme, aylık ödeme"; müşteri satırı "Üretim, inşaat, toptan ticaret, lojistik ve perakende
    şirketleri".
- **DUZELTME:** pazarlamanın aday kaynakları sektörü bu PRD'den okur (§4.1).

## 1. Kurallar

1. **Modül işleviyle adlandırılır; üstünde grup yoktur** (ortak kural 7). Oyuncu "Çekirdek" ya da "Güven & Ölçek" görmez.
2. **Kilit yalnız gerçek içerikte, şartı yazar** (kural 4). Arayüz Tasarım, süreç ve model Ürün, yük Yazılım ister. Test ve Hazırlık
   hiçbir kartı kilitlemez: testçisi ya da PM'i olmayan şirket o işi yine yapar, daha hatalı ve daha geç.
3. **Önce görünür bedel.** Her rolün yokluğu bir sonuçla görünür, yazıyla değil (§3).
4. **Yalnız sıradaki kademe görünür.** Sonraki kademelerin adı, sayısı ve "kaç kaldı" işareti yoktur.
5. **Oyuncunun bilemeyeceği bilgi gösterilmez** (kural 2). Adayın huyu (alıcı tipi) pazarlıkta davranışla görünür, satırda cümleyle
   değil.
6. **Gerçek dünya tutarlılığı** (kural 3). ERP'yi yalnız onu gerçekten alan sektörler alır. Her mekanik "gerçek bir yazılım
   şirketinde böyle mi olur" testinden geçer (PLAN_ERP_EKIP eleştirmen turu).
7. **Her sayı neye göre olduğunu söyler** (kural 6). Anlatılamayan sayı ekrana çıkmaz.
8. **Gizli gider yok.** Her bedelin ekranda bir sayacı ya da satırı, para ya da iş olarak bir çıkışı vardır.
9. **Kural tek yerde tutulur.** Sistemler birbirinin durumunu yazmaz, okur (CLAUDE.md WRITE-THROUGH).

## 2. Ürün: modüller, kademeler, yayın şartı

### 2.1 Modül

- **Modül bugünkü hattın kendisidir:** id, ad, ikon, iş profili (tasarım, geliştirme, test), üç adlı kademe (K1, K2, K3) ve
  kademelerin kapıları. Veri ürün türünün dosyasında durur (`data/product/lines/erp.json`). Kimlik hattı ile paylaşılan hat ayrımı
  içeride kalır, oyuncu görmez.
- **Alan katmanı kalkar.** Kalanlar:
  - `sprint.json` `areas`;
  - `ProductQuality.TABLE`, `weights`, `used_areas`, `CORE_2` … `REST_3`;
  - `SprintCatalog.area_ids`, `area_name`, `area_short`;
  - `ProductModel._module` alan döngüsü;
  - `area_panel.gd` `AREA_ICONS`.
  Hepsinin yerini modül ve alıcının ihtiyaç listesi alır (§4.2). Alan kimliğini okuyan her yer bir modül kimliğine ya da bir ihtiyaç
  listesine çevrilir; tam liste §10.
- **Sol sütun:** düz modül listesi. Sıra: yayın şartının modülleri, sonra kullanım akışı (alış, stok, satış), sonra ölçek modülleri.
- **Gelir alanı** (B2C Ücretli plan) ERP'de yoktur. Not ve Video türleri kalktığı için silinir. Pazaryerinin Premium'u
  PAZARYERI'nin modülüdür.
- **GDD ayrılığı:**
  - ch03 §12.1'in hat modeli kalır.
  - §12.2'nin paylaşılan hat adlarından üçü değişir (§2.2).
  - GUNCELLEMELER'in sprint turu maddesindeki "Alanlar" ve yıldız beklenti tablosu kalkar.
  - `docs/ACIK_ISLER/ACIK_KARARLAR.md`'ye "alan katmanı kalktı, modül = hat" maddesi bu PRD'nin ilk paketiyle girer.

### 2.2 ERP'nin modülleri (adlar TR/EN onay bekliyor)

| # | Modül | K1 · K2 · K3 | Bugünden farkı |
|---|---|---|---|
| 1 | Muhasebe | Ön Muhasebe · Muhasebeciye Aktarım · Otomatik Mutabakat | K2 "Hesap Planı" → "Muhasebeciye Aktarım" (Tekdüzen Hesap Planı ilk günden zorunlu; müşterinin istediği muhasebecisine aktarım) |
| 2 | Fatura | Fatura Kesme · Toplu Fatura · Tahsilat Döngüsü | — |
| 3 | Kasa ve Banka | Kasa Hareketleri · Nakit Akış Tablosu · Nakit Öngörüsü | ad "Nakit Akışı" → "Kasa ve Banka" |
| 4 | Kullanıcılar ve Yetki | Hesap & Oturum · Roller ve İzinler · Denetim İzi & Şifreleme | ad "Güvenlik & Yetki" → "Kullanıcılar ve Yetki" |
| 5 | Satın Alma | Alış Faturası ve Gider · Tedarikçi ve Teklif · Belge Okuma | K1 "Satın Alma Talebi" → "Alış Faturası ve Gider" (KOBİ'de satın almanın karşılığı) |
| 6 | Stok | Stok Sayacı · Çoklu Depo · El Terminali | K2 "Depo ve Raf" → "Çoklu Depo" |
| 7 | Mobil | Duyarlı Arayüz · Mobil Uygulama · Çevrimdışı Mobil | ad "Mobil & Erişim" → "Mobil" |
| 8 | Entegrasyonlar | Tekil Bağlantı · Çoklu Entegrasyon · Açık API & Webhook | — |
| 9 | Yedekleme | Otomatik Kayıt · Sürüm Geçmişi · Çevrimdışı Çalışma | ad "Dayanıklılık" → "Yedekleme" |
| 10 | Toplu İçe Aktarma | Tablodan Aktarma · Eşleme Şablonları · Gece Aktarımı | yeni, 25 hesapta açılır (§2.6) |
| 11 | Onay Akışı | Tek Onay · Tutar Sınırları · Çok Basamaklı Onay | yeni, 50 hesapta |
| 12 | Çok Şirket | İkinci Şirket · Şirketler Arası Kayıt · Konsolide Rapor | yeni, 100 hesapta ya da mali müşavir programıyla (D3) |

Gizli Kendi Kendine Destek hattı Ar-Ge'den açılırsa 13. modül olur. İkonlar ARAYUZ'un işidir (MODUL_SEMASI §2'de tarifleri).

### 2.3 Kapılar (kademe başına, kart başına bakılır)

"kişi" ekipteki en iyi tek kişinin yıldızı, "toplam" ekibin toplamıdır. Puan K1 15, K2 25, K3 40.

| Modül | K1 | K2 | K3 |
|---|---|---|---|
| Muhasebe | yok | kişi Ürün 1★ | `bug_tracker`, kişi Ürün 2★ |
| Fatura | yok (ER1) | toplam Yazılım 3★ | `scalable_backend`, toplam Yazılım 4★, kişi Ürün 1★ |
| Kasa ve Banka | yok | kişi Yazılım 2★, Ürün 1★ | `analytics_engine`, kişi Yazılım 2★, Ürün 2★ |
| Kullanıcılar ve Yetki | yok | kişi Ürün 1★ | `security_cert`, toplam Yazılım 5★ |
| Satın Alma | yok | kişi Yazılım 2★, Ürün 1★ | `semantic_index`, kişi Ürün 2★ |
| Stok | yok | kişi Tasarım 1★, Yazılım 2★ | `design_system`, kişi Tasarım 2★, Yazılım 2★ |
| Mobil | kişi Tasarım 1★ | kişi Tasarım 1★, toplam Yazılım 4★ | `design_system`, kişi Tasarım 2★ |
| Entegrasyonlar | yok | kişi Yazılım 2★, Ürün 1★ | `data_model`, kişi Ürün 2★, toplam Yazılım 4★ |
| Yedekleme | yok | kişi Yazılım 2★ | `scalable_backend`, kişi Yazılım 2★ |
| Toplu İçe Aktarma | yok | kişi Tasarım 1★ | `data_model`, kişi Yazılım 2★ |
| Onay Akışı | kişi Ürün 1★ | kişi Ürün 2★ | `security_cert`, kişi Ürün 2★ |
| Çok Şirket | kişi Yazılım 2★ | kişi Ürün 1★, Yazılım 2★ | `analytics_engine`, kişi Ürün 2★, Tasarım 1★ |

- **Bugünden farkı:**
  - Test kapıları kalkar: K2'de 4 kart, K3'te 6 kart (kural 2).
  - Fatura K1'in tasarım kapısı kalkar (ER1).
  - Mobil K3'te Tasarım 3★ → 2★.
  - Muhasebe K2'de Ürün 2★ → 1★.
- **Fatura'nın iş profili tasarım kalır.** GDD §12.2'nin kimlik şekli 2 geliştirme, 1 test, 2 tasarımdır ve oyun bu şekli tutmayan
  türü yüklemez (`product_lines.gd:119`). Tasarım payı matbu fatura düzenidir.
- **Kurucu kapıyı karşılayabilir:** 6 dağıtım puanı var, alan başına en çok 3.
- **Ar-Ge:** düğüm K3'ü açar, hiçbir kart düğüm açmaz. Dallar rollere eşleşir:
  - Test dalını Test becerisi olan araştırır;
  - Tasarım dalını tasarımcı;
  - Ürün dalını PM.
  `test_automation` testçinin regresyon işini azaltır (bugün hiçbir karta bağlı değil).

### 2.4 Yayın şartı

- v1.0, adlı modüllerin K1'idir (`sprint.json` `mvp_named`): Muhasebe, Fatura, Kasa ve Banka, Kullanıcılar ve Yetki. 60 puandır;
  tek kurucuyla yaklaşık 10. haftada çıkar.
- Sürüm notu ve sprint planı tek satır yazar: "Yayına kalan: Ön Muhasebe, Fatura Kesme, Hesap & Oturum". Satırda tahmin yoktur
  (Erdem'in PY1a yorumu). Kurucunun notu sıradaki modülü adıyla söyler ("Kullanıcılar ve Yetki sırada").
- 1★ alıcının beklentisi yayın şartının kendisidir. `ProductQuality`'nin "Çekirdek ÷ hat sayısı" hücresi kalkar.
- Bileşen pazaryeriyle ortaktır (`SprintCatalog.mvp_named`, `mvp_left_names`). Adlı listesi olmayan türde bugünkü `mvp_lines` kalır.

### 2.5 Kademesiz istek kartı (PLAN_ERP_BUYUME §2.3; ER4)

- Hesap, modülün K3'ü çıktıktan sonra o modülden küçük bir özellik ister: 16 kart × 15 puan. Liste PLAN_ERP_BUYUME §3'te; adları
  MODUL_SEMASI'na göre ("Hesap Eşleme").
- İstek, söz ve büyüme kurallarının tek yeri PRD_TALEPLER'dir. Bu PRD yalnız kademesiz kartın kendisini tanımlar.
  - Kıtlık söz payındadır (PRD_TALEPLER §1, §4).
  - Zamanında tutulan söz bir büyüme isteği doğurur; bedeli kurulum haftası ya da indirimdir (PRD_TALEPLER §8.2). Otomatik koltuk
    büyümesi yoktur.
  - Hesabın yıldız bandı doluysa büyüme isteği yerine hesabın sektöründen, onun yıldızında bir referans aday gelir.
- Makine pazaryeriyle ortaktır, önce ERP kurar.

### 2.6 Ölçek kartı ve ölçek modülleri (PLAN_ERP_BUYUME §2.3; ER2)

- **Ölçek kartı.** Hesap sayısı 25, 50, 100'ü, sonra her 50'yi geçince iki kart doğar (Arama Hızı ve Rapor Kuyruğu, …). İki kartın
  toplamı eşik kadar puandır; tavanı sprint kapasitesinin 3 katı. Kart sunucu maddesinin kalıbıyla, sayacıyla gelir. Oyuncu kartı
  yapar ya da 12 haftalık kira öder:
  - kira = 0,25 × aylık gelir × (kart puanı ÷ sprint kapasitesi);
  - süre dolarsa ay sonu kapanışının ihtimali artar ve o hesapların büyümesi kapanır.
- **Ölçek modülleri** (Toplu İçe Aktarma, Onay Akışı, Çok Şirket) eşikte çalışma anında açılır (`register_runtime_line`'ın yolu).
  Alan ortalaması kalktığı için PLAN_ERP_BUYUME'nin "yeni hat seviyeyi düşürür" sorunu kalkar. Modül, alıcının ihtiyaç listesine
  girdiği boyda beklenir (§4.2).

## 3. Ekip baskısı

### 3.1 Roller

| Rol | Yokken görünen bedel | Kilit |
|---|---|---|
| 2. geliştirici | Kurucu sprintte tek K1 sığdırır | Yazılım: kişi 2★ 11 kartta, toplam 3–5★ 5 kartta |
| Tasarımcı | Tasarım aşamasını uzman olmayan yapar (yarı hız; kurucu da 0★'la yavaş). Küçük müşteri (alan da kullanan da aynı kişi) Mobil ya da Toplu İçe Aktarma zayıfsa denemede bırakır | Tasarım: 7 kart |
| Testçi | Testi kartı yazan yapar ve az yakalar (×0,6). Çekirdek modüllerinden (Muhasebe, Fatura, Kasa ve Banka) kaçan hata yanlış tutardır (§3.3) | Yok |
| PM | Hazırlanmamış sözlü kart Geliştirme'de büyür ("isteyen ekledi", söz tarihi kayar). Kurucu isteyenle kendisi görüşüp kartı küçültebilir, ama bu görüşme saatinden yer | Ürün 15 kartta; 1★'ı kurucu karşılar, 2★ K3'ler PM ister. ERP'de Ürün becerisi muhasebe ve mevzuat bilgisi olarak okunur |

- **Atama:** aşamaya uyan kişiler arasında ana rol öne alınır. Testi testçi, tasarımı tasarımcı yapar (`SprintSystem._assign`;
  PLAN_ERP_EKIP Ek A.3: 12 kişide kaçan hata 13,1'den 9,1'e).

### 3.2 Eksik rolün görünümü (kare E2)

- **Satır:** sprint planında uzmanı olmayan aşamanın (Tasarım, Test) kişi şeridinin başında rol ikonlu, kesik çizgili bir boş koltuk
  durur. Adının yanında küçük bir etiket olur ("TESTÇİ YOK", "TASARIMCI YOK").
- **Çubuk:** uzman olmayanın yaptığı pay taralıdır.
- **İpucu:** sonucu söyler: "Testi kartı yazan yapıyor; kaçan hata, modülü kullanan her hesaba dokunur." / "Tasarımı tasarımcı olmayan
  biri yarı hızla yapıyor."
- **Hazırlık:** bugün de boş halkadır ("PM yok"), aynı biçime girer.
- **Testi kim yapıyor:** bugün testçisiz ekipte Test satırında kimse görünmüyor, çubuk dolu ve ✓. Testi yapan geliştiriciler
  satırda yüzleriyle görünür.
- **Metin:** TR/EN onay bekliyor.

### 3.3 Hatanın ağırlığı

- **Çekirdek modüllerinden kaçan hata yanlış tutardır.** Muhasebe, Fatura ve Kasa ve Banka'dan kaçan hata ay sonu kapanışı acil
  durumuna bağlanır (`IncidentSystem`). O modülü kullanan hesaplara aynı gece dokunur ve karar ister. Karar oyuncunundur: hotfix,
  özür ve kredi, ya da sabaha bırakmak.
- **Öbür modüllerin hatası destek bildirimidir** (bugünkü gibi).
- **Hesap sayısı:** bedel kullanan hesap sayısıyla büyür; büyük şirket kendi büyüklüğünden fren alır.
- **Ün:** yanlış tutar ünü düşürür (§4.4).
- **Sürüm notu:** kaçan hatayı ve etkilenen hesapları yazar ("Fatura: KDV yuvarlama hatası · 12 hesap").
- **Neden:** testçili ekip daha zor kart açtığı için toplamda daha çok hata görüyor (Ek A.3). Hata sayılmakla kalmamalı, tartılmalı.

### 3.4 Sözlü iş (OLAYLAR'la)

- **Sabit pay:** sözlü iş sprintin sabit bir payını geçmez (örnek: dörtte bir). Pay PM'den bağımsızdır.
- **Neden pay var:** söz geri alınamadığı için tavansız plan sözle kilitlenir.
- **PM'siz büyüme:** hazırlanmamış sözlü kart Geliştirme'ye girince isteyen kapsam ekleyebilir. Kart büyür, satırda "isteyen
  ekledi" yazar.
- **PM'in işi:** PM hazırlarsa kart büyümez. PM kapasite üretmez, belirsizliği azaltır.
- **Hız kuralı:** sözlü kart her sprintte en çok payın kadar ilerler (PRD_TALEPLER §4.1). Bu olmadan söz hep erken tutulur ve bedava
  bir ödüle döner. Kural `SprintSystem` atamasına dokunur; dosyaya önce bu PRD'nin paket 5'i iner, OLAYLAR'ın commit'i arkasından.
- **Kaynak:** "isteyen ekledi" kâğıdı (tetik, üç seçenek, bedeller) PRD_TALEPLER §4.3'tedir. "Kapsamı koru" seçeneği kurucunun
  görüşme saatini harcar. Bu fiil D2'nin kurulum haftası fiiliyle ortak yazılır (tek fiil, iki kâğıt).

### 3.5 Kilitli satır (kare E1)

- **Satır:** kapalı modülün sıradaki kademesi kilitliyse modülün adının altında şart yazar. Açık modülde kademenin satırı şartı ve
  kartın adını taşır. Koşullar yan yana çipler olarak durur: karşılanan yanar, karşılanmayan söner.
- **Metin** (kural 4):
  - kişi kilidi: "{yıldız} {rol} gerekli", ör. "1★ tasarımcı gerekli", "2★ ürün yöneticisi gerekli";
  - toplam kilidi: "Toplam Yazılım: 3★ gerekli (ekipte 2★)";
  - Ar-Ge kilidi: "{düğüm} araştırılmalı".
  Rol adı Ekip'in rol etiketidir (`HRConstants.role_label`); alan kimliğinden rol eşlemesi tek yerde durur. Kilit metninin sahibi
  bu PRD'dir; Talepler bu işlevi okur.
- **Not (Erdem'e):** kişi kapısı tek kişinin becerisini sayar, ikinci becerisi ve kurucu dahil (`line_gates.gd:38-58`). Tasarımcının
  ikinci becerisi Ürün'dür (`hr_constants.gd:86-88`). Bu yüzden "2★ ürün yöneticisi gerekli" satırını 2★ Ürün'ü olan bir tasarımcı
  ya da kurucu da kaldırır. Satır rolü yazar (Erdem'in örneği); ipucu beceriyi kimlerin taşıdığını söyler ("Ürün: ürün yöneticisinin
  ana, tasarımcının ikinci becerisi; kurucu da taşıyabilir").
- **Gizli düğüm:** kilidin söylediği Ar-Ge düğümü ağaçta henüz görünmüyor olabilir. Örnek: Veri Modeli bitmeden Semantik İndeks
  görünmez (`rnd_system.gd:81-86`). Kilidin ağacın gösterdiği ilk düğümü mü, hedefi mi söyleyeceği PRD_TALEPLER'in 5. sorusudur;
  cevap bu bölüme de işlenir.
- **Tık:**
  - kişi ya da toplam kilidi işe alım atlasını o rolle süzülmüş açar;
  - Ar-Ge kilidi Ar-Ge'yi o düğümde açar.
  İki eylem bugün var (`product_tab.gd:322-326`).
- **Görünmeyen:** sonraki kademeler, kademe sayısı, "kaç kaldı" (kural 4 ve §1.4).

## 4. Müşteri

### 4.1 ERP alıcı sektörleri (kural 3)

- **Alır:**
  - inşaat ve taahhüt;
  - üretim;
  - tekstil ve konfeksiyon;
  - toptan ticaret ve dağıtım;
  - lojistik ve depolama;
  - perakende zincirleri;
  - e-ticaret satıcıları;
  - oto yedek parça ve servis;
  - gıda üretimi ve dağıtımı.
- **Almaz:**
  - emlak ofisi;
  - hukuk ve danışmanlık bürosu;
  - sigorta acentesi;
  - finans ve portföy şirketi;
  - medya ve prodüksiyon stüdyosu;
  - yazılım firması;
  - sağlık kliniği;
  - tek kişilik hizmet işletmesi.
  Gerekçeler MODUL_SEMASI §6'da.
- **Bugün nerede bozuluyor:**
  - `scripts/systems/sales_archetypes.gd:165-185` `candidates_for`: ürün türüne uyan alıcı tipini yalnız öne alıyor
    (`AFFINITY_WEIGHT` 2, satır 155), uymayanı da havuzda tutuyor.
  - `sales_archetypes.gd:64` (`tech_exacting`: teknoloji, e-ticaret, finans, medya) ve `:82` (`finance_brisk`: sigorta, hukuk,
    perakende, emlak) her B2B ürününe aday veriyor.
  - Sektörü `SalesFaucetSystem.spawn` (`sales_faucet_system.gd:198-214`) alıcı tipinden çekiyor. Adı `SalesNamePool.SECTOR_WORDS`
    (`sales_name_pool.gd:41-54`) veriyor: "Emlak", "Gayrimenkul" 49. satırda; "Yayın", "Stüdyo" 53. satırda.
- **Düzeltme:**
  - Sektör ürün türünün verisine taşınır: `data/product/lines/erp.json` `buyer_sectors`, her sektörün ihtiyaç listesiyle (§4.2).
  - Aday sektörünü türün listesinden çeker.
  - Alıcı tipi (temkinli, titiz, aceleci) yalnız pazarlık huyunu verir, sektör vermez. `sectors` alanı alıcı tipinden kalkar.
  - Yeni sektörler (toptan ticaret, oto yedek parça, gıda) `SECTOR_WORDS`'e ve `CompanyCatalog`'a ad alır.
  - Listede olmayan sektör ERP'ye aday vermez.
  - Smoke: ERP koşusunda 104 haftada doğan her adayın sektörü listededir.

### 4.2 Alıcının ihtiyaç listesi

- **Liste:** her sektör kullandığı modülleri ve boyuna (yıldızına) göre beklediği kademeyi taşır. 1★ beklenti yayın şartının
  kendisidir.
- **Örnek, inşaat firması** (onay bekliyor):
  - 2★: Satın Alma K2, Çok Şirket K1;
  - 3★: Onay Akışı K2, Entegrasyonlar K2.
- **Alanların bugünkü işi bu listeye geçer:**
  - adayın ve hesabın uyumu (`ProductQuality.prospect_fit`, `account_fit`, `close_chance`);
  - hatanın dokunduğu hesaplar (`uses_area` → modülü kullanıyor mu);
  - talebin modülü;
  - yatırımcının en zayıf alanı (`weakest_area` → en zayıf beklenen modül).
- **Ürün sayfası** (Genel bakış) bir boyun eksiklerini modül ve kademe adıyla yazar: "2★ inşaat firması için: Satın Alma · Tedarikçi
  ve Teklif".
- **Kayıp nedenleri:**
  - 1★ adayın kaybı küçük işletmenin kaybıdır: "denemede bıraktı";
  - 2★ ve 3★ adayın nedeni eksik modülün adıdır: entegrasyon, kurulum, referans;
  - 3★ görüşmesine "firma küçük ya da genç" itirazı eklenir; cevabı seed ve ekip boyudur.

### 4.3 Aday akışı

- **Ün oyunun İtibar'ıdır** (üst bar, `GameState.reputation`, −10..100; ayrı bir stok iki sayıyla aynı şeyi anlatırdı. Yardımcı
  yönetmen 2026-11-14, onay bekliyor).
  - Giriş: kademe yayını, tutulan söz; teşekkür notu ve referans hesap (D1) kâğıtları gelince bağlanır.
  - Çıkış: kaçan hatanın dokunduğu hesaplar, bozulan söz, kaybedilen hesap. Olay fiilleri ve hata ihmali bugünkü gibi yazar; olay
    kartıyla kaybedilen hesap (`churn_customer` fiili) bu çıkışa girmez.
  - Girdileri `Reputation` dinler ve `set_reputation` ile yazar; ağırlıklar `SalesConstants.REP_*`.
  - Akış İtibar'ı okur: yayında haftada 1 aday (E3, beğenildi), İtibar büyüdükçe artar.
  - İtibar düşünce nedeni Satış başlığının ipucunda ve haber şeridinde görünür.
  - Kayıtta tek yeni alan: değişimlerin nedenli kaydı (`reputation_log`, artışsız, varsayılan boş).
- **Yıldız bandı ürünün o boya uyumunu okur.** 2★ şirketler ürün 2★ ihtiyaç listesini karşılayınca, 3★ şirketler 3★ listesini
  karşılayınca gelir (`ProductQuality.market_fit(star)`, kapanışın ölçüsü). Herhangi bir modülün K2'si bandı açmaz.
- **Sektör çekimi:** adayın sektörü ürünün güçlü olduğu modülleri kullanan sektörlerden ağırlıklı çekilir. Depoyu derinleştiren
  üretici ve lojistik, Fatura'yı derinleştiren toptancı çeker. Modül seçmek pazar seçmektir.
- **Ekran:**
  - Satış hattının başlığı "Akış: 1/hafta · Gelen: ★☆☆" der (E3, E4).
  - Ölçek şirket kartlarıyla aynı 5 yıldızdır; sıradaki yıldızın üstünde kilit glifi durur.
  - İpucu eksik kartları oyundaki adlarıyla yazar ("★★ için: Tedarikçi ve Teklif, Çoklu Depo").
  - Ürün'de o kartların satırında küçük bir yıldız çipi durur.
  - Metin TR/EN onay bekliyor.
- **Aday satırı:** ad, yıldız, süre, düğmeler. Alıcı tipinin "sesi" ("Hızlı konuşur, düşük rakam ister.") satırdan ve görüşme
  panelinin başlığından kalkar (kural 2): `sales_tab.gd:349`, `sales_meeting_adapter.gd:69`. `SALES_ARCH_*_LINE` anahtarları silinir.
  Adayın söylediği şart ("Yazılı bir hizmet sözü istiyor") kalır: aday onu söyler.
- **Randevu (park; paket 6'nın dışında, yardımcı yönetmen 2026-11-14):** aday görüşmeyi en çok iki hafta ertelemeye razı olur,
  ilgisi görünür biçimde soğur. Görüşmenin sonucu o haftanın ürün uyumunu okur. "Görüşmeye git" düğmesi kurucunun sprintinden
  düşen saati yazar.

### 4.4 Ünün kaynakları ve gerçeklik

- **Gerçeklik** (PLAN_ERP_EKIP §5):
  - satışçısız ilk yılda haftada 1–2 nitelikli aday gerçekçidir;
  - büyük alıcı "benim boyumda kim kullanıyor" ve "bu firma iki yıl sonra var mı" diye sorar;
  - 2013 Türkiye'sinde güven sorusu yedek, veri yeri ve ISO 27001'dir.
- **Ölçüm:** ilk biçim (ün kademe sayısından) Ek A.2'de ölçüldü. Stok ve uyum biçimi ölçülmedi; bot kolu ölçer (§11 paket 8).

### 4.5 Sözleşme ve yenileme (soru 5)

- **Bugün:**
  - sözleşme 52 haftadır (`data/product/sprint.json:48` `request.contract_weeks`); talepler ve yenileme penceresi bundan sayılır;
  - ödeme ve MRR aylıktır;
  - memnuniyeti düşen hesap Risk ve ayrılma makinesiyle yılın ortasında da gidebiliyor (`B2BSalesSystem`).
- **Öneri: "Yıllık sözleşme, aylık ödeme"** (ARAYUZ'un tür dosyasında böyle). MRR aylık kalır; Series A eşiği ve üst bar aylık
  geliri okur.
- **Kural (onay bekliyor):** memnun olmayan hesap yıl ortasında gitmez, yenilemede gider.
  - Risk durumu "yenilemede kaybedilebilir" okunur.
  - Yıl ortasında gidiş yalnız sözleşme bozulunca olur (fesih hakkı): sunucu maddesi (bugün var) ve Çekirdek modüllerinden kaçan
    yanlış tutar (§3.3).
- **Yenileme kâğıdı:** her hesabın yıldönümünde tek bir kâğıt gelir. Seçenekler: yenile, büyüyerek yenile (memnun hesapta) ya da
  hesap gider (memnun değilse).
  - "Büyüyerek yenile" PRD_TALEPLER §8.2'nin kuralını okur: sürüm başına en çok 3 büyüme isteği, hesap başına 1.
  - Kâğıdın metni OLAYLAR'ındır; commit'i bu PRD'nin paket 7'siyle birlikte iner (OLAYLAR'ın 12. commit'i).
  - Büyümenin bedeli yeni koltukların kurulum haftasıdır: temsilcinin ya da kurucunun bir haftası (D2). Hacim indirimi pazarlığın
    indirim satırıyla çalışır.
  - Kâğıt metni OLAYLAR'ın.
- **Hesap kartı:** "Yıllık · aylık $600 · yenileme Mart 2013".
- **Gerçek karşılığı:** bulut ön muhasebe yıllık plan satar, aylık tahsil eder. Kazanılan hesabın geçiş maliyeti yüksektir.

## 5. Derinlik maddeleri (PLAN_ERP_EKIP §7; soru 1)

Sekiz madde; her biri bir karar, iki mekaniğe bağ, bir kazanç ve bir kayıp. Açılış haftaya değil şirketin durumuna bağlıdır.

| # | Madde | Açılış | Karar (özet) | Yapım |
|---|---|---|---|---|
| D1 | Pilot müşteri | Yayından önce | İndirimli pilot: v1.0 için söz, kurucunun görüşme saati, genel ya da özel istek; söz kayarsa pilot gider, olumsuz referans | 2–3 commit + kâğıt |
| D2 | Kurulum ve veri taşıma | İlk 2★ hesap | Pazarlıkta "kurulum ücretli mi" satırı; iş: eski programdan cari ve stok aktarımı, matbu fatura düzeni; Ocak dalgası | 3–4 |
| D3 | Mali müşavir programı | 25 hesap | Büroya ücretsiz panel: büro müşterilerini getirir (aday kaynağı `accountant`), aktarım ve çok firma ister | 4–5 |
| D4 | Özel geliştirme teklifi | İlk 2★ hesap | Tek seferlik ödeme (her sürümde bakım yükü), ürüne al ve herkese aç, ya da reddet (memnuniyet); OLAYLAR'ın "ücretli özel geliştirme"siyle tek mekanik | 2 + kâğıt |
| D5 | Mevzuat takvimi ve e-Fatura | Her Ocak; e-Fatura tebliği Aralık 2012 (~50. hafta) | Ertelenemez güncelleme kartı; e-Fatura'da kendi GİB entegrasyonu, özel entegratör ya da GİB portalı; kapsam hesabın sektörüne bağlı (madeni yağ, ÖTV (III) zinciri); ödül duyurudan itibaren yayılır, Series A görüşmesinde sorulur | 3–4 + kâğıt |
| D6 | Beyanname haftası nöbeti | İlk 3★ hesap | Nöbet: ay sonu kapanışı hızla kapanır; ücret giderde, moral düşer | 3 |
| D7 | Kod incelemesi | İkinci geliştirici | Modül başına seçilir; Geliştirme uzar, hata azalır, junior hızlı büyür, ayrılık riski küçülür; kartın çubuğunda "incelemede yakalandı" dilimi | 2–3 |
| D8 | Anahtar kişi | Bir kapıyı tek kişi tuttuğunda | Ayrılık ve tükenme kâğıdı kişinin tuttuğu kapıları okur; zam, ikinci kişiyi yetiştir, riski al | 2 + kâğıt |

- **Demo önerisi:** D1, D5, D7. Dördüncü olarak D4. Kalanı EA.
- **`[VOCAB?]` fiiller** (OLAYLAR): olumsuz referans (seam `Customer.market_ref` var, fiil yok), hesaba özel bakım yükü, özel
  entegratörün aylık gideri, D8'in iki seam'i.
- **e-Fatura kaynakları:** 421 sıra no.lu tebliğ 14 Aralık 2012'de yayımlandı. Madeni yağ zinciri 25 milyon TL eşikli (doğrulandı).
  ÖTV (III) zinciri, 10 milyon TL eşiği ve 1 Eylül 2013 başvuru tarihi doğrulanmalı (PLAN_ERP_EKIP Ek B).

## 6. Ekranlar (kareler `erp_tasarim_2026-11-12/kareler/ekip/`)

| Kare | Ekran | Bu belgede |
|---|---|---|
| E1 | Ürün › Sprint: düz modül listesi, kilitli modülün şartı | §2.1, §3.5 |
| E2 | Ürün › Sprint: eksik rolün boş koltuğu, taralı pay, küçük etiket | §3.2 |
| E3 | Satış: tek aday, ERP sektörü, sessiz aday satırı, "Akış · Gelen" başlığı | §4.1, §4.3 |
| E4 | Satış: ürün 2★ listesini karşılayınca "Gelen: ★★☆" | §4.3 |
| E5 | Ürün › Sürüm notu: "Yayına kalan", tahminsiz; kurucunun notu modülü söyler | §2.4 |
| E6 | Satış, EN | §4.3 |

- **Kare sınırları:**
  - İkonlar bugünkü alan ikonları.
  - EN kilit metni prototipte küçük harfli rol adı; kodda TR ve EN ayrı anahtar.
  - E4'te bant prototipte ilk K2'yle açılıyor, kuralı §4.3.
  - Sonra karelerinde sprint numarası bir ileride: dört parçalı yayın şartı v1.0'ı bir sprint geç çıkarıyor.
- **Görsel kabul:** her paket kendi karesini `--screen 2` ile, kare dünyasında (`_A4_WORLDS`) çeker. Kare dünyası oyunun üreticisinden
  ad alır, maaşı ve evreyi doğru kurar (PLAN_ERP_EKIP kare dersleri; `kareler/fikstur/apply_ekip.py`).

## 7. Olaylar ve kâğıtlar

| Kâğıt | Sahibi | Mekanik |
|---|---|---|
| Yenileme (yenile, büyüyerek yenile, gider) | OLAYLAR | §4.5 |
| Ay sonu kapanışında yanlış tutar (hotfix, özür ve kredi, sabaha bırak) | OLAYLAR (var olan acil durum) | §3.3 |
| Sözlü kartta "isteyen ekledi" | OLAYLAR | §3.4 |
| D1 pilot, D4 özel geliştirme, D5 e-Fatura, D8 anahtar kişi | OLAYLAR | §5 |
| Ölçek kartının süresi doldu | sistem satırı (kâğıt değil) | §2.6 |

Ortak kâğıt kuralı (Erdem'in olay seçeneği kuralları):
- somut hamle olur;
- bedel öznede ve sonuçla yazılır, iç birimle değil;
- gövdede "kart" geçmez;
- bedava çıkış yoktur.

## 8. Kayıt

- Kayıtlı alanların biçimi değişmez. Şema 19 → 20 artışı pazaryerinin sistem commit'inde olur.
- Yeni alanlar anlamlı varsayılanla, artışsız eklenir:
  - İtibar'ın değişim kaydı (`reputation_log`);
  - ölçek kartları ve sayaçları;
  - kademesiz istek kimlikleri;
  - derinlik maddelerinin durumu;
  - hesabın yenileme kararı.
- Yenileme günü imza gününden türer (bugünkü `next_renewal_day`).

## 9. Onay bekleyen sabitler

| Sabit | Başlangıç | Yer |
|---|---|---|
| Kapılar | §2.3 tablosu | `data/product/lines/erp.json`, `shared_gate_overrides` |
| Yayın şartı | 4 adlı modülün K1'i | `sprint.json` `mvp_named` |
| İhtiyaç listeleri | sektör × yıldız × modül kademesi | `erp.json` `buyer_sectors` |
| İtibar'ın girdileri | yayındaki kademe +1, tutulan söz +2 (bozulmuş sözün geç tutulması +1), bozulan söz −3, kaybedilen hesap −3, kaçan hata hesap başına −1 (sürümde en çok −3) | `SalesConstants.REP_*` |
| Bant eşiği | `market_fit(star)` ≥ beklenti | `SalesConstants` |
| Testçi olmayanın yakalaması | ×0,6 | `sprint.json` `bugs` |
| Sözlü iş payı | sprintin dörtte biri | `sprint.json` (OLAYLAR) |
| Yenileme | 52 hafta; yıl ortası gidiş yalnız fesih hakkında | `sprint.json` `request.contract_weeks`, `B2BConstants` |
| Kademesiz isteğin ödülü | büyüme isteği (bedelli) ya da referans aday | PRD_TALEPLER §8.2 |
| Ölçek kartı | eşikler 25, 50, 100, +50; kira r = 0,25; tavan 3 × kapasite | `sprint.json` `scale` |
| Randevu | en çok 2 hafta | `SalesConstants` |

## 10. Kod etki haritası

Satırlar HEAD `f4307fb9`. Ayrıntılı tablolar PLAN_ERP_BUYUME §4'te ve PLAN_ERP_EKIP §9'da; burada yalnız yeni olanlar ve
paketin dokunduğu dosyalar.

| Paket | Dosyalar | Not |
|---|---|---|
| 1 Modül katmanı | `sprint.json` `areas`; `sprint_catalog.gd` `area_ids`, `area_name`, `area_short`, `capabilities`, `release_lead_sentence`; `product_model.gd` modül döngüsü, `_module`, `_quarter` (hedef modül); `area_panel.gd`; `product_quality.gd` `TABLE`, `weights`, `used_areas`, `level`, `expectation`, `weakest_area`; `sprint_bridges.gd` talebin alanı; rakip çipi (`rivals.json`); `endgame_smoke.gd` alan sayan vakalar | Prototip: `kareler/fikstur/apply_moduller.py` |
| 2 Kilitli satır | `product_model.gd` `_locked`; `area_panel.gd`; `sprint_catalog.gd` `gate_reason`; `strings.csv` `PROD_LOCK_*` (rol adlı) | PLAN_ERP_BUYUME paket 1 |
| 3 Sektörler | `sales_archetypes.gd` (`sectors` kalkar, `candidates_for`); `sales_faucet_system.gd` `spawn`; `erp.json` `buyer_sectors`; `sales_name_pool.gd`; `company_catalog.gd`; `sales_tab.gd:349`; `sales_meeting_adapter.gd:69`; `strings.csv` `SALES_ARCH_*_LINE` silinir; aynı commit'te tür ekranının ERP müşteri satırı (`PROD_TYPE_ERP_WHO`, bugün "Üretim, lojistik ve perakende şirketleri") listeyle genişler (ARAYUZ'un notu; TR/EN onay bekliyor) | DUZELTME ve OLAYLAR bu listeyi okur |
| 4 Kapılar, adlar, yayın şartı | `erp.json`; `shared.json` adları; `sprint.json` `mvp_named`; `product_quality.gd` 1★ hücresi; `endgame_smoke.gd` `_seed_mvp_lines` | PAZARYERI'yle ortak bileşen |
| 5 Ekip baskısı | `sprint_system.gd` `_assign`, `team()`; `sprint_bugs.gd` `catch_rate`; `capacity_view.gd`, `stage_paint.gd` (boş koltuk, taralı pay); `incident_system.gd` (ay sonu ve yanlış tutar); `support_system.gd` | |
| 6 Akış | `sales_faucet_system.gd` `lead_rate_per_week`, `star_mix_now`; `product_quality.gd` `market_fit`; ün stoku (`SalesSystem` ya da yeni sahip, tek yazar); `sales_tab.gd` başlık; haber satırı | |
| 7 Sözleşme | `b2b_sales_system.gd` Risk ve ayrılma; `customer_rep_system.gd` yenileme; `sprint_bridges.gd` `next_renewal_day`; hesap kartı | OLAYLAR'ın kâğıdıyla |
| 8 Bot ve ölçüm | `run_probe.gd` (tasarımcı, Mid alımı, masa kipi, yenileme) | Harness değişikliği serbest |
| 9 Kademesiz istek | PLAN_ERP_BUYUME §4.2 | Pazaryeriyle ortak |
| 10 Ölçek kartı | PLAN_ERP_BUYUME §4.3 | Pazaryeriyle ortak |
| 11 Ölçek modülleri | PLAN_ERP_BUYUME §4.4 (alan ortalaması satırı düşer) | |
| 12 Derinlik | seçilen maddeler (§5) | Erdem'in seçimi |
| 13 Belge | `GDDs/GUNCELLEMELER.md`, `ACIK_ISLER/ACIK_KARARLAR.md`, `docs/kod_haritasi/sistemler/02_urun_sprint.md`, `03_satis_b2b.md` | |

**Dosya başına tek yazar ve sıra.** Çakışan dosyalar ve sıra:
- `sprint.json`, `sprint_catalog.gd`, `product_model.gd`, `area_panel.gd`, `product_quality.gd`: önce bu PRD (paket 1, 2, 4), sonra
  OLAYLAR (talep bölümü), sonra PAZARYERI'nin verisi.
- `sales_tab.gd`: önce paket 6'nın başlığı, sonra Pazarlama'nın kaynak izi, sonra pazaryeri gövdesi.
- Tek yazarlı dosyalar: `run_probe.gd`, `strings.csv`, `main.gd` `_A4_WORLDS`.

## 11. Paketler ve takvim

Hız: oturum günü dört commit. Darboğaz onaydır.

| Paket | Commit | Gün | Erdem onayı |
|---|---|---|---|
| 1 Modül katmanı | 10 | 2,5 | Modül adları, ürün sayfasının dili |
| 2 Kilitli satır | 4 | 1 | Kare (E1 beğenildi), rol metni |
| 3 Sektörler | 4 | 1 | Sektör listesi |
| 4 Kapılar, adlar, yayın şartı | 3 | 0,75 | Adlar |
| 5 Ekip baskısı | 7 | 1,75 | Soru 2, E2 |
| 6 Akış | 6 | 1,5 | Ün ve bant kuralı |
| 7 Sözleşme | 4 | 1 | Soru 5 |
| 8 Bot ve ölçüm | 2 | 0,5 | |
| 9 Kademesiz istek | 10 | 2,5 | Ödül, metin |
| 10 Ölçek kartı | 8 | 2 | Bedel, metin |
| 11 Ölçek modülleri | 5 | 1,25 | |
| 12 Derinlik (D1, D5, D7) | 9 | 2,25 | Soru 1, 4 |
| 13 Belge ve kalibrasyon | 4 | 1 | |
| **Beklenen** | **76** | **19** | |
| Kötümser (×1,7) | 130 | 32 | |

- **Kesme sırası:** 1, 2, 3, 4, 5, 6, 8, 7, 9, 10, 12, 11, 13. Yalnız 1–6 inerse Erdem'in tur 4 kurallarının hepsi ve ekip baskısı
  oyundadır; ikinci yarının içeriği (9–11) eksik kalır.
- **Pazaryeriyle:**
  - Pazaryeri ~111 commit, bu PRD ~76 commit. Ortak makine (kademesiz istek, ölçek kartı, modül paneli, yayın şartı) iki yerde
    sayılmaz; pazaryerinden 8–12 commit düşer.
  - Özellik 18 Ocak'ta donar. Beklenen hâl sığar; kötümser hâl sığmaz.
  - Ne kesileceğine yardımcı yönetmen Erdem'le karar verir.

## 12. Sorular

1. **Derinlik listesinden hangileri demoda?**
   - Demet'in şirketi büyüdükçe karşısına gerçek bir yazılım şirketinin kararları çıkar: pilot müşteri, kurulum, mali müşavir,
     özel geliştirme, mevzuat ve e-Fatura, beyanname nöbeti, kod incelemesi, anahtar kişi.
   - Önerim D1 pilot müşteri, D5 e-Fatura, D7 kod incelemesi; dördüncü olarak D4 özel geliştirme. Kalanı EA.
2. **Testçinin yokluğu nasıl görünsün?**
   - Demet'in altı kişilik ekibinde testçi yok; geliştiriciler kendi kodlarını test ediyor.
   - A: testçinin koltuğu boş, test payı taralı. Fatura'dan kaçan yanlış tutar ay sonunda o modülü kullanan hesaplara aynı gece
     dokunur. Bedel müşteri çoğaldıkça büyür.
   - B: test yarı hızla yapılır, sprintler belirgin yavaşlar. Küçük şirkette geliştiricinin test ettiği gerçek dünyayla çelişir.
   - Önerim A (kare E2).
3. **Kapı kartın tamamına mı, aşamaya mı?** Çoklu Depo kartı 1★ tasarımcı istiyor.
   - A: kart başına. Ekipte 1★ tasarımcı varsa kart açılır, satır kilidin şartını yazar.
   - B: aşama başına. Kartın Tasarım aşamasında çalışan kişi 1★ taşımalı; tasarımcısı izne çıkan ekipte kart durur. 8–12 commit
     daha; erken oyun kapanır.
   - Önerim A.
4. **e-Fatura kâğıdında gerçek kurum ve mevzuat adları geçebilir mi?** "GİB", "ÖTV (III) listesi", "421 sıra no.lu tebliğ" gibi.
   CLAUDE.md gerçek markayı yasaklar; kurum ve mevzuat adı ayrı bir sorudur (OLAYLAR'ın notu).
   - A: gerçek adlar.
   - B: "vergi idaresi", "elektronik fatura zorunluluğu" gibi genel adlar.
   - Önerim A: takvim gerçek tarihle örtüşüyor ve 2012 Türkiye'sinde oynayan oyuncu adları tanır.
5. **Sözleşme yıllık mı?** Erdem'in sorusu: "yıllık yapıp aylık gösterirsek tatsız mı olur?"
   - Önerim: yıllık sözleşme, aylık ödeme; MRR aylık kalır.
   - Bunun için bir kural değişir: memnun olmayan hesap yıl ortasında değil yenilemede gider. Yıl ortasında yalnız sözleşme
     bozulunca gider (sunucu maddesi, Çekirdek modüllerinde yanlış tutar).
   - Yenileme her hesabın yıldönümünde bir karar anı olur: yenile, büyüyerek yenile ya da gider.
   - A: bu kural. B: bugünkü gibi, hesap her an gidebilir; "yıllık" yalnız ad olur. Önerim A.
6. **"Kullanıcıyla görüş" araştırma kartı nereye?** Bugün her alanda bir tane var; alan kalkınca yeri kalmıyor.
   - A: ürün başına tek kart; görüşülen kullanıcılar en zayıf beklenen modülü söyler.
   - B: modül başına bir kart (12 kart, liste kalabalıklaşır).
   - Önerim A.

## Ek. Kaynaklar

- **Gerekçe, araştırma ve ölçüm:** `erp_tasarim_2026-11-12/`:
  - `PLAN_ERP_BUYUME.md` (kâğıt hesabı Ek B, eleştirmen turu Ek C);
  - `PLAN_ERP_EKIP.md` (ölçüm Ek A, kaynaklar Ek B);
  - `ELESTIRMEN_EKIP.md`;
  - `D_EKIP_ARASTIRMA.md`, `D_ERP_ARASTIRMA.md`, `C_EKIP_KOD.md`.
- **Modül şeması ve sektörler:** `MODUL_SEMASI.md`.
- **Kareler ve prototip yamaları:** `kareler/ekip/E1–E6`, `kareler/fikstur/` (`apply.py`, `apply_ekip.py`, `apply_ekip_gates2.py`,
  `apply_moduller.py`).
- **Ortak arayüzler:** `tur4_ekranlar_2026-11-13/pazaryeri/ORTAK_ARAYUZLER.md`, `secim_ekrani/DIL_ONERISI.md`.
