# Modül şeması ve ERP alıcı sektörleri (öneri)

URUN, 2026-11-13 akşam. Kaynak: Erdem'in tur 4 yorumu, ortak kural 3 ve 7 (`tur4_ekranlar_2026-11-13/ERDEM_YORUMU_TUR4.md`).
Adlar, ikonlar ve metinler **onay bekliyor**. PRD_ERP.md'ye girer; öbür oturumlar karelerini bununla kurar.

## 1. Modül nedir

- **Modül, işleviyle adlandırılmış tek bir özellik ailesidir.** Bugünkü "hat"ın kendisidir: üç adlı kademesi (K1, K2, K3)
  ve kendi ikonu vardır. Kademe kendinden öncekinin yerini alır (ch03 §12.1 aynen). Fatura Kesme, Toplu Fatura ve Tahsilat
  Döngüsü "Fatura" modülünün üç kademesidir.
- **Modüllerin üstünde grup yoktur.** Bugünkü alanlar (Çekirdek, İlk Kullanım ve Erişim, Büyüme ya da Entegrasyonlar, Güven &
  Ölçek, Gelir) kalkar. Sprint planının sol sütunu modülleri düz bir liste olarak gösterir. Sıra kullanım akışıdır: yayın
  şartının modülleri önce, sonra ürünün işlediği sıra (alış, stok, satış), en sonda ölçek modülleri.
- **Modülün verisi ürün türünün dosyasındadır** (`data/product/lines/<tür>.json`): id, ad, ikon, iş profili (tasarım,
  geliştirme, test), üç kademe ve kapıları. Bugünkü "kimlik hattı" ile "paylaşılan hat" ayrımı içeride kalır (veri yeniden
  kullanımı), oyuncu görmez.
- **Alıcı modüle bakar, alana değil.** Her alıcı sektörü kullandığı modülleri ve boyuna göre beklediği kademeyi bir ihtiyaç
  listesinde taşır (§4). Bugün alanların yaptığı her iş bu listeye geçer:
  - 1★ Çekirdek beklentisi;
  - sektörün iki vurgu alanı;
  - hatanın dokunduğu hesaplar (`uses_area`);
  - talebin alanı;
  - yatırımcının en zayıf alanı.

## 2. ERP'nin modülleri

| # | Modül | İkon (ARAYUZ çizer) | K1 · K2 · K3 | Bugünkü alanı | Not |
|---|---|---|---|---|---|
| 1 | Muhasebe | defter | Ön Muhasebe · Muhasebeciye Aktarım · Otomatik Mutabakat | Çekirdek | yayın şartı |
| 2 | Fatura | fatura kâğıdı | Fatura Kesme · Toplu Fatura · Tahsilat Döngüsü | Çekirdek | yayın şartı |
| 3 | Kasa ve Banka | kasa | Kasa Hareketleri · Nakit Akış Tablosu · Nakit Öngörüsü | Çekirdek ("Nakit Akışı") | yayın şartı; ad değişir |
| 4 | Satın Alma | teslim kutusu | Alış Faturası ve Gider · Tedarikçi ve Teklif · Belge Okuma | Çekirdek | |
| 5 | Stok | koli | Stok Sayacı · Çoklu Depo · El Terminali | Çekirdek | K2 "Depo ve Raf" → "Çoklu Depo" (Erdem'in "raf" itirazı pazaryeri içindi, ama kelime karışmasın) |
| 6 | Kullanıcılar ve Yetki | anahtar | Hesap & Oturum · Roller ve İzinler · Denetim İzi & Şifreleme | Güven & Ölçek ("Güvenlik & Yetki") | yayın şartı; ad değişir |
| 7 | Yedekleme | bulut ve ok | Otomatik Kayıt · Sürüm Geçmişi · Çevrimdışı Çalışma | Güven & Ölçek ("Dayanıklılık") | ad değişir |
| 8 | Entegrasyonlar | priz | Tekil Bağlantı · Çoklu Entegrasyon · Açık API & Webhook | Entegrasyonlar | |
| 9 | Mobil | telefon | Duyarlı Arayüz · Mobil Uygulama · Çevrimdışı Mobil | İlk Kullanım ve Erişim ("Mobil & Erişim") | |
| 10 | Toplu İçe Aktarma | tablo ve ok | Tablodan Aktarma · Eşleme Şablonları · Gece Aktarımı | ölçek kartı (PLAN_ERP_BUYUME) | 25 hesapta açılır |
| 11 | Onay Akışı | onay işareti | Tek Onay · Tutar Sınırları · Çok Basamaklı Onay | ölçek kartı | 50 hesapta |
| 12 | Çok Şirket | iki bina | İkinci Şirket · Şirketler Arası Kayıt · Konsolide Rapor | ölçek kartı | 100 hesapta ya da mali müşavir bürosuyla (PLAN_ERP_EKIP D3) |

Gizli self-serve hattı Ar-Ge'den açılırsa 13. modül olur.

## 3. Bugünkü gruplar neye dönüşür

| Bugün | Ne olur |
|---|---|
| Çekirdek (beş kimlik hattı) | Beş ayrı modül: Muhasebe, Fatura, Kasa ve Banka, Satın Alma, Stok |
| İlk Kullanım ve Erişim | Mobil modülü (gizli self-serve açılırsa kendi modülü) |
| Entegrasyonlar (B2B) · Büyüme (B2C) | Entegrasyonlar modülü |
| Güven & Ölçek | İki modül: Kullanıcılar ve Yetki, Yedekleme |
| Gelir (yalnız B2C, Ücretli plan) | ERP'de yok. Not ve Video türleri kalktığı için bugünkü yeri kalmaz; pazaryerinin Premium'u PAZARYERI'nin modülüdür |
| "Bu çeyrek: hedef alan" (PM) | Hedef modül |
| Alanın seviye sözcüğü (Yok · Zayıf · Yeterli · Güçlü) | Modülün kademesi adıyla görünür ("Fatura · Toplu Fatura"). Ürün sayfası bir boy için eksik modülleri yazar ("2★ inşaat firması için: Satın Alma'da Tedarikçi ve Teklif") |
| Alan başına "kullanıcıyla görüş" araştırma kartı | Ürün başına tek kart; konuştuğu kullanıcılar en zayıf ihtiyaç duyulan modülü söyler. Açık soru (PRD) |
| Rakip çıkışının alan çipi | Modülün çipi |

## 4. Yayın şartı ve kapılar buna nasıl oturur

- **Yayın şartı:** v1.0, ürün türünün adlı modüllerinin K1'idir (`sprint.json` `mvp_named`). ERP'de Muhasebe, Fatura, Kasa ve
  Banka, Kullanıcılar ve Yetki. Satır "Yayına kalan: Fatura Kesme, Hesap & Oturum" der. Pazaryeri aynı bileşeni kendi
  modülleriyle kullanır. 1★ alıcının beklentisi yayın şartının kendisidir: "Çekirdek" yerine "adlı modüllerin K1'i".
- **Kapılar:** kademenin kapısı değişmez. Kart başına bakar (beceri yıldızı, toplam Yazılım, Ar-Ge düğümü). Kilitli satır
  "kilitli" yazmaz, şartı yazar (ortak kural 4):
  - "1★ tasarımcı gerekli";
  - "2★ ürün uzmanı (PM) gerekli";
  - "Semantik İndeks araştırılmalı";
  - "Toplam Yazılım 3★ gerekli (ekipte 2★)".
  Beceriyi kurucu taşıyorsa kilit hiç çıkmaz.
- **Alıcının ihtiyaç listesi:** her sektörün kullandığı modüller, alıcının boyuna göre beklenen kademe. Örnek, inşaat firması:
  - 1★: yayın şartı;
  - 2★: Satın Alma K2 ve Çok Şirket K1 (şantiye başına şirket);
  - 3★: Onay Akışı K2 ve Entegrasyonlar K2.
  Bant (PLAN_ERP_EKIP §5) bu listeden okunur: ürün bir boyun listesini karşılayınca o boyun şirketleri gelir. Hata, hatanın
  modülünü kullanan hesaplara dokunur. Talep, hesabın listesindeki bir modülden doğar.

## 5. GDD ile ayrılık (Erdem'in yeni kararı, 2026-11-13)

- **ch03 §12.1 (mühürlü):** "Alt-tip başına 9 hat, eksen başına 3, her hat 3 isimli kademe". Hat modeli kalır, modül hattın
  kendisidir. Ölçek hatlarıyla ERP 12 modüle çıkar; 9 sınırını ölçek kartları zaten aşmıştı (PLAN_ERP_BUYUME, ER2 onaylı).
- **ch03 §12.2:** kimlik hattı ve paylaşılan hat ayrımı ve kanonik paylaşılan adlar ("Güvenlik & Yetki", "Dayanıklılık", "Mobil &
  Erişim"). Ayrım içeride kalır; üç modül adı değişir (§2).
- **GUNCELLEMELER, sprint turu maddesi:** "Alanlar: Çekirdek (beş kimlik hattı), İlk Kullanım ve Erişim …, Büyüme ya da
  Entegrasyonlar, Güven & Ölçek, Gelir". Ayrıca alan seviyesi, alan sözcüğü ve yıldız beklenti tablosu ("1★ Çekirdek MVP; 2★
  Çekirdek 1,25 ve sektörün iki vurgusu 1; 3★ Çekirdek 2, vurgular 1,5, kalan alan 1"). Bu madde kalkar, yerine §1 ve §4 gelir.
  Kod: `data/product/sprint.json` `areas`, `ProductQuality.TABLE` ve `weights`, `used_areas`, `CORE_2` … `REST_3`,
  `SprintCatalog.area_ids`, `ProductModel._module`.
- `docs/ACIK_ISLER/ACIK_KARARLAR.md`'ye "alan katmanı kalktı, modül = hat" maddesi PRD ile girer.

## 6. ERP alıcı sektörleri (ortak kural 3)

ERP (ön muhasebe, fatura, stok, satın alma) stoğu, alışı ve faturası olan şirkete satılır. Önerilen liste:

| Alır | Neden |
|---|---|
| İnşaat ve taahhüt | Malzeme alışı, şantiye stoğu, hakediş faturası, şantiye başına şirket (Erdem'in örneği) |
| Üretim (metal, plastik, mobilya) | Hammadde, üretim stoğu, satış faturası |
| Tekstil ve konfeksiyon | Kumaş stoğu, fason alış, ihracat faturası |
| Toptan ticaret ve dağıtım | Depo, cari, toplu fatura; e-Fatura'nın ÖTV (III) zinciri (içecek, tütün dağıtımı) |
| Lojistik ve depolama | Depo, sevkiyat, cari |
| Perakende zincirleri (market, mağaza) | Çoklu depo, alış, kasa |
| E-ticaret satıcıları | Stok, fatura, pazaryeri entegrasyonu |
| Oto yedek parça ve servis | Parça stoğu, servis faturası; e-Fatura'nın madeni yağ zinciri |
| Gıda üretimi ve dağıtımı | Parti ve son kullanma takibiyle stok, alış, dağıtım |

| Almaz | Neden |
|---|---|
| Emlak ofisi | Stoğu ve alışı yok; portföy ve komisyon izler, ön muhasebeyi mali müşaviri tutar |
| Hukuk ve danışmanlık bürosu | Saat ve dosya takibi, büro yazılımı; stok yok |
| Sigorta acentesi | Sigorta şirketinin sistemini kullanır |
| Finans ve portföy şirketi | Düzenlemeye tabi kendi çekirdek sistemi |
| Medya ve prodüksiyon stüdyosu | Proje ve sözleşme takibi; stok yok |
| Yazılım ve bilişim firması | Stoksuz; ön muhasebe programıyla yetinir |
| Sağlık kliniği | Hasta ve randevu sistemi alır, ERP değil (medikal ürün dağıtıcısı "toptan ticaret"tir) |
| Tek kişilik hizmet işletmesi | Ön muhasebeyi mali müşaviri tutar |

**Bugün nerede bozuluyor:**
- `scripts/systems/sales_archetypes.gd:165-185` `candidates_for`: ürün türüne uyan alıcı tipini yalnız öne alıyor
  (`AFFINITY_WEIGHT` 2, satır 155), uymayanı da havuzda tutuyor. Yorum açıkça "affinity biases the draw, it does not win it"
  diyor.
- `sales_archetypes.gd:46, 64, 82`: üç alıcı tipinin sektör listeleri. Yalnız `ops_cautious` ERP'ye bağlı (`subtype_affinity:
  ["erp"]`, satır 47); `tech_exacting` (teknoloji, e-ticaret, finans, medya) ve `finance_brisk` (sigorta, hukuk, perakende,
  emlak) her B2B ürününe aday veriyor.
- Sektörü `SalesFaucetSystem.spawn` (`sales_faucet_system.gd:198-214`) alıcı tipinin listesinden çekiyor. Adı
  `SalesNamePool.SECTOR_WORDS`'ten alıyor (`sales_name_pool.gd:41-54`; "Emlak", "Gayrimenkul" 49. satırda; "Yayın",
  "Stüdyo" 53. satırda).
- Sektörün alan vurgusu `ProductQuality.TABLE`'da (`product_quality.gd:47-61`).

**Önerilen düzeltme (PRD):** alıcı sektörleri ürün türünün verisine taşınır (`data/product/lines/erp.json` `buyer_sectors`,
her sektörün ihtiyaç listesiyle, §4). Aday sektörünü türün listesinden çeker. Alıcı tipi (temkinli, titiz, aceleci) yalnız
pazarlık huyunu verir, sektör vermez. Yeni sektörler (toptan ticaret, oto yedek parça, gıda) `SECTOR_WORDS`'e ve CompanyCatalog'a
ad alır. Listede olmayan sektör ERP'ye aday vermez.

**Kopyalarda prototip süzgeci (bu akşam):** karelerde hesap ve aday adı yalnız şu sektörlerden olsun: `construction`,
`manufacturing`, `textile`, `logistics`, `retail`, `ecommerce` (bugün var olanlar). Sonekleri İnşaat, Yapı, Beton, Proje, Üretim,
Fabrika, Metal, Endüstri, Tekstil, Dokuma, Konfeksiyon, Lojistik, Kargo, Nakliyat, Terminal, Market, Mağazacılık, Perakende,
Ticaret, Pazar, Online, Sepet. Emlak, Gayrimenkul, Arsa, Holding (real_estate), Klinik, Sağlık, Medikal, Poliklinik, Hukuk,
Danışmanlık, Legal, Sigorta, Poliçe, Teminat, Medya, Yayın, Prodüksiyon, Stüdyo, Finans, Yatırım, Portföy, Kapital, Yazılım,
Teknoloji, Bilişim, Sistemler süzülür.
