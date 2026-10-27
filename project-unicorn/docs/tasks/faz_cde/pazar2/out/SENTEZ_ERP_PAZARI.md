# Sentez · ERP pazarı modeli (Pazar 2)

**Durum (2026-10-22, devir).** Tasarım Erdem'in 1-11 ve 24-31 cevaplarıyla yazılı; simülasyon kapanışı (SIM3, §13.4 madde 1-11) bitti, madde 12 (YZ dalgaları, `SORU_PAKETI_3.md`) Ar-Ge PRD'sine kaldı. Kapılar (§13.2): ✅ G1 (N=10), G4, G5 kart, G6, G7, G8, G3 (yalnız "erken" öncü politikasıyla), demo; ❌ G2 geç, G9, tempo K3, fiyat, G11 (gelir/gider 2,0-3,1; ölçek 600 sim sabiti), G10 ekip kolları. Sim şekil gösterir, kalibrasyon değildir; tüm sabitler [WORKING]. **Sim3'te yalnız iki sabit değişti** (`sim/sim3.json`): `eskime_memnuniyet` 0 → 2 (G4 kaybı %34/39/44 → %41/41/45) ve `istek_omur_hafta` 26 → 13 (G5 istek kartı p95 4 → 3). **Erdem'e 8 açık karar** (etkileri ve oyuncu örnekleri §13.4 ve `tur2/SIM_RAPOR_2.md` §4-5): (1) dev payı G2 geç: kapıyı ürün üstünlüğü diye oku / bitişi 2035 / 5 modül; (2) fiyat kapısı: kapanış çarpanı 1,1/1/0,85 mi 1,25/1/0,75 mi 1,4/1/0,65 mi; (3) tempo K3: eğri ×4,5 mi yumuşasın ya da hedef "3 modülde K2" olsun; (4) G9 ölü bölge: 1★ beklentisine K2 üst sınırı; (5) G3 dev payında mevzuat hatları sayılsın mı; (6) kadro aşama payı 0,5 mi 0,35 mi (D'nin birimine bağlı); (7) rakip kasası: girişim fonu sabiti ya da kasa bağından vazgeç; (8) ürün dışı ayrılma oranı (üçte bir mi, daha yüksek mi). Bunlar ERP, kart, Ar-Ge ve rakipler PRD oturumunda kapanır; kod öncesi ayrıntılı PRD yazılacak.

Tarih: 2026-10-20, son hâli 2026-10-21. Hazırlayan: sentez ajanı (kıdemli tasarım yönetmeni rolü). Oyun koduna, CSV'ye,
`data/`'ya yazılmadı. **Erdem'in 1-11 (2026-10-20) ve 24-31 (2026-10-21) cevapları işlendi**: her karar ilgili bölümde KARAR
olarak durur, toplu liste §15'te. Eski seçenek dili ve ajan görüşleri silindi; kalan tek açık soru `pazar2/out/SORU_PAKETI_3.md`'de.

Girdi (hepsi `docs/tasks/faz_cde/pazar2/out/` altında):
- Tur 1: K (kod haritası), A1 (ERP evrimi), A2 (ERP satışı), A3 (sektör ve modül), B1 (rakip şirketler), B2 (dönem kilitleri),
  V (şüpheci doğrulama).
- Tur 2 (`tur2/`): P (sektör profili ve `P_profiles.json`), M (modül sayısı), F1 (gerçek ERP fiyatı), F2 (oyunlarda fiyat),
  S1 (gerçek sıralama ve ödül), S2 (oyunlarda sıralama ve ödül), Y (bitiş yılı), B (bilinen yol), K2 (kod ve içerik maliyeti),
  V2 (doğrulama), SIM_RAPOR_1, SIM_RAPOR_2.
- Tur 3: `tur2/R3_mini.md` (önerilen fiyat formülü, YZ zamanı ve Ar-Ge tavanı, yıllık rapor ve modül ödülü).
- Kararlar: `docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md` ve Erdem'in 2026-10-17 cevabı (`faz_cde/ERDEM_CDQ_CEVAP.md`).
  Faz C ve D taslakları: `c_taslak/PLAN_C.md`, `PLAN_C_E1.md`, `d_taslak/ATAMA/` (A1-A4, A6).

Arama: bu belge için 0 WebSearch. Tur 1 kollarında transkriptte sayılan tekil WebSearch 95 (A1 17, A2 22, A3 10, B1 16, B2 18,
V 12); tur 2 kollarının kendi beyanı P 14, M 10, F1 12, F2 8, S1 10, S2 8, Y 8, B 8, V2 8; R3 15 (beyan, transkriptle sayılmadı).
Simülasyon: `docs/tasks/faz_cde/pazar2/sim/` (`sim.py`, `constants.json`, `sim2.json`, `eras.json`, `modules.json`, `rivals.json`;
`python -I`, oyun kodunu okumaz; komutlar `sim/README.md`'de). Sonuçlar `out/tur2/sim1_sonuc*.json`, `sim2_sonuc*.json` ve `sim3_*.json`
(SIM3, 2026-10-22: §13.4 madde 1-10), okuması SIM_RAPOR_1 ve SIM_RAPOR_2. Sim uydurma bir dünyadır: sayıları biçim gösterir,
kalibrasyon değildir.

Gösterim: `[A1-S24]` = A1'in 24 numaralı kaynağı; tur 2 ve tur 3 kaynakları kol adıyla öneklenir (`[P-S1]`, `[F1-S8]`, `[S1-S19]`,
`[R3-S7]`); hepsi §17'de. `[V #2]`, `[V2 #19]` = doğrulama tablosunun satırı; `[K §2.4]`, `[K2 §1.6]` = kod haritası bölümü;
`[SIM2 §4.3]` = sim raporunun bölümü. Kararlar: **Erdem N** `ERDEM_KARARLAR`'ın "1-23" ve "24-31" cevap listesidir (Pazar 2'ninkiler 1-11 ve 26-31, D'ninkiler
18-25); **Erdem K1-K9** Pazar merdiveni cevaplarıdır; **Karar N** aynı dosyanın ilk listesidir (C, Q, D bölümleri); **Erdem 2026-10-17** adil ekonomi cevabıdır.
Etiketler: [BOŞLUK] kanıtsız yük taşıyan iddia · [SIÇRAMA] kanıttan çıkmayan sonuç · [VARSAYIM] söylenmeden dayanılan kabul ·
[DEĞERLENDİREMEM] · [GÖRÜŞ] benim yargım · (varsayım A#) §18'deki liste · (hesap) benim aritmetiğim · [WORKING] kalibrasyon
girdisi, tek veri dosyasında durur. V'nin YANLIŞ dediği iddiaya dayanılmadı (A1'in "e-Fatura 2014'te zorunlu" satırı yerine V #2'nin
düzelttiği takvim kullanıldı); V ve V2'nin AÇILAMADI dediği sayılar yalnız [WORKING] başlangıç değeridir.

---

## 0. Özet (14 satır)

1. Tek model: ERP bir **modül pazarı**dır. **10 modül** (Erdem 26) bugünkü hattın yerini alır; 13 sektör adı **9 profile**
   bağlanır (Erdem 1, P). Müşterinin sektörü hangi modülleri istediğini, büyüklüğü (5★) kaç modül istediğini ve hangi çıtaya
   baktığını söyler.
2. Standart bir sayı değil bir yarıştır: rakipler (dev, yerleşik, girişim) oyuncuyla **aynı kart kataloğunu ve Ar-Ge ağacını**
   kendi ekipleriyle yürütür. Her modülde rakiplerin çoğunun yayımladığı seviye **standart**, en iyi ikincisininki **kısa liste
   seviyesi**dir. Oyuncu bu hesaba girmez; kopyalama yok, "bilinen yol" indirimi yok (Erdem K2, 31).
3. Müşteri imzada standarda göre yerini alır (küçük hesap standardın altına razı, 5★ kısa listeyi ister) ve bu yer hesabın ömrü
   boyunca sabittir: koltuk artışı beklentiyi artırmaz, beklentiyi yalnız pazarın yürümesi taşır.
4. Beklentinin üç sesi var: satışta "bu modül bizim için önemli", **yalnız 3★ ve üstünden** yıl ortası istek (4-5★ daha sık;
   Erdem 5), pazar yürüdükçe yenilemede şart. Yüzlerce hesapta sesler modül kartında birleşir; haftada en çok 2 müşteri maili.
5. Koltuk bantları 3-10 / 10-30 / 30-100 / 100-300 / 300-1.000 (Erdem 6). Koltuk müşterinin kendi gidişinden gelir; yenilemelerin
   çoğunda değişmez; bant sınırını geçen hesabın yıldızı yenilemede değişir.
6. Satış: kapanış = yıldız tabanı × modül uyumu × satışçı çarpanı × fiyat duruşu; %60 tabanı ve kesin kazanç yok. Satışçı en çok
   kendi yıldızının bir üstündeki hesaba gider, şansı ×0,6 (Erdem 7).
7. Fiyat: teklif üç düğmedir (ucuz, standart, pahalı); her birinin önerilen koltuk fiyatı müşterinin istediği modüllerden ve o
   modüllerin kalitesinden hesaplanır; anlaşma = koltuk × fiyat (Erdem 30). Hacim indirimi yok; 5★'ın yüksek geliri sorun değil.
8. Durgunluk: ayrı sürüm-ritmi cezası yok (Erdem 11). Ürün eskir: standart yürüdükçe geride kalan modül memnuniyeti adıyla düşürür,
   yenilemede şart ve adlı ayrılma doğurur; sürüm çıkmayınca ilgi söner. Hata kanalı bugünkü gibi sürer.
9. Dönem ve tavan: kademeler dönemle açılır (iki yılda bir), ilk kademeler biraz pahalılaşır, Ar-Ge ağacı tavanı yükseltir, dönem
   geçişleri ağaca yeni düğüm getirir (Erdem 27). Bitiş 2030 sonu: 991 hafta, 1×'te 6,2 saat (Erdem 28).
10. Kim önde: her yıl Kasım'da bir sektör raporu (en büyükler, en hızlı büyüyenler) ve aynı anda B2B'de modül ödülleri; ödülün tek
    karşılığı 12 ay boyunca o modülü isteyen adayların daha sık gelmesi. B2C'de modül ödülü yok (Erdem 29).
11. Dev rakip erken oyunda geçilmez, geç oyunda geçilebilir (Erdem 9).
12. Sim (üç tur): 10 modül, iki parçalı efor ve "yalnız piyasadaki seviyeyi iste" kuralı devin erken doygunluğunu ve istek
    birikimini çözüyor; satış zarı istenen oranları veriyor; memnuniyet eskimesi durgunluk kapısını (G4) ve 13 haftalık istek ömrü
    istek kartı kapısını (G5) geçiriyor; öncülük (G3) öncü bot politikasıyla geçiyor. Açık: dev pazar payı 2030'a kadar geçilmiyor
    (en iyi %35), ürün dışı ayrılma düşük kalınca 1★ tutma bandın üstünde (%95), 104 haftada K3 tempo hedefi G1'le çelişiyor,
    "pahalı" duruş tek doğru cevap oluyor, ölü bölge (G9) geride kalan oyuncuda 2022'den sonra boş, şartlı yenileme hiç doğmuyor
    (§11.4, §13).
13. Pre-mortem: en olası ölüm "şart maili angaryası ve dev hep önde"; yeni riskler 10 modülün içerik bedeli, iki parçalı eforun
    demo temposunu bozması ve önerilen fiyatın tek doğru cevaba dönmesi (§12).
14. Faz etkisi: C1, C2, C4, C7, C9 sürer; C3b, C5, C6, C8 yeniden yazılır, C3a satır ekler; Q'nun alan tabanlı beklentisi ve iki
    ayrı rakip modeli kalkar; D'nin kataloğu büyür; Ar-Ge'ye dönem düğümleri ve tavan etkisi gelir (§14). Tek açık soru YZ
    dalgalarının sayısı (§15, `SORU_PAKETI_3.md`).

---

## 1. Önceki tasarımdan farkı ve kanıtın gücü

**Bırakılanlar** ("Pazar merdiveni"nden): ürün uyumu U'nun ve beklentinin ekranda sayı olarak görünmesi (Erdem K1), rakibin öne
geçtiğin alana yetişmesi (kopyalama, K2), koltuk artışının beklentiyi taşıması (K3), alan ortalaması üstünden beklenti
(`ProductQuality.TABLE`, `CORE_2`, `EMPHASIS_*`, `CLOSE_CURVE`, `loss_area` [K §1.1, §5]), sabit çıkış tablolu ve kalite
eksenli iki ayrı rakip modeli [K §4.1].

**Kalan tek fikir**: standart rakip sürümlerinden doğar. Bunu Erdem K6'da kendisi söyledi; bu belge onu gerçek pazarın üç
mekanizmasına (rakip sürümü, mevzuat, alıcının gecikmeli benimsemesi [A1 §4]) ve büyük alıcının kısa liste davranışına
[A1-S34] bağlar.

**Yeni olanlar**: modül (hat) ve sektör profili, 5 yıldız ve müşterinin kendi büyümesi, istek ile şartın ayrılması (fırsat ve
tehdit), aynı katalogu yürüten rakip şirket, dönem tablosu ve Ar-Ge tavanı, ürünün eskimesi, kaliteden hesaplanan önerilen fiyat,
yıllık rapor ve modül ödülü, yüzlerce hesapta sesin birleştirilmesi.

**Kanıt gücü** (V ve V2'nin hükümleriyle):

| Sınıf | Neler | Tasarımda kullanımı |
|---|---|---|
| Doğrulandı | SAP 2024 Ar-Ge 6.514 M€, %19,1, 37.590 FTE [A1-S5, V #4]; NetSuite FY2015 741,1 M$, 4.603 çalışan, 5 dikey sürüm [A1-S10, V #5]; Ebsta "altın dönem" ve "2 katı açık kalan fırsat %3" [A2-S10, V #1]; Eurostat ERP kullanımı küçük %38, büyük %86 [A2-S18, V #8]; Business Central 80/110/8 $ [A2-S15, F1-S1, V #9, V2 #1]; e-Fatura takvimi (düzeltilmiş) [V #2]; OpenTTD eskime ve 2050 dondurma [B2-S18, V #14]; Game Dev Tycoon 35 yıl [B2-S1, V #15]; Big Ambitions "7 kat olmamalı" [B1-S5, V #16]; başarısız projeler [V #10]; Mikro ve Logo fiyat listeleri, Odoo'nun 2022 gerekçesi [F1-S7, F1-S8, F1-S3, V2 #3, #6, #7]; NetSuite FY2012 beş sektör sürümü [P-S1, V2 #21]; AB takvimi (ViDA 2030, AI Act 2027, CRA 2027) ve 2030 sonuna 991 hafta [Y-S1, Y-S2, Y-S3, V2 #17, #19]; TrustRadius alıcı anketi, yorum sitesi G2'nin segment eşikleri, ARTW pazar payı [S1-S19, S1-S3, S1-S23, V2 #14] | Kural biçimine dayanak |
| Kısmen | SAP ECC "%39 geçmişti, %61 geride" [A1-S6, V #3]; NetSuite'in "büyük rakiplerde bulut suit yok" inancı [V #5]; sektör × modül matrisi (tek yayıncı) [A3, V #13] ve 9 profilli tablo (aritmetiği doğru, hücre dayanağı ince: 90 hücrenin 43'ü varsayım) [P, V2 #22]; Capitalism Lab yetişme formülü (yalnız oyuncu tarafı belgelenmiş) [B1-S2, V #18]; SAP ECC'nin 2033 "özel uzatması" (SAP değil danışman sözü) [Y-S11, V2 #18]; Gartner 2024 bulut ERP lider listesi [S1-S29, V2 #13] | Yalnız yön |
| Açılamadı / türetilmiş | Koltuk bantları, yıldız başına kapanış oranı ve süre, satışçı yıldız çarpanları, yenilemede koltuk değişimi, genişleme sıklığı, kurulum süresi, Panorama 2026 "9 ay" [V #7, #20]; Software Inc'te "önerilen fiyatta kâr tepe yapar" deneyi [F2-S3, V2 #15] | [WORKING] başlangıç değeri, sim kalibre eder |
| Bulunamadı | Standardın sayısal büyüme hızı [A1 §4 BOŞLUK]; "sektöre özgü modül eksikliği yüzünden batan proje" [A3-S16, V #10, P §10]; yenilemede özellik şartı koşan ERP müşterisine dair veri [A2 §5.4]; mobil ve API pazarı kilometre taşları [A1 §2]; sektör × modül kullanım yüzdesi [P §11]; fiyat ile kalite ilişkisini ölçen iyi kaynaklı çalışma ve premium fiyatın kapanışı ne kadar düşürdüğü [R3 §A1, §A2]; rozetin ya da ödülün satın almaya bağımsız ölçülmüş etkisi [R3 §C1]; 2019-2020'ye özgü ERP YZ kilometre taşı [R3 §B1] | Tasarım kararı, gerekçesi yazılı |

---

## 2. Model tek bakışta

Tek cümle: **Pazar bir yarıştır; sen ve rakipler aynı modül kademelerini kendi ekibinizle yaparsınız, çoğunun yaptığı seviye
standart olur, her müşteri kendi büyüklüğüne göre standarda bakar ve bunu sana istek ya da şart olarak söyler.**

Zincir (her ok bir veri ya da kural; ekranda sayı yok, cümle ve ad var):

1. **Dönem tablosu** (veri): hangi yıl hangi kademe ya da hat açılır, Ar-Ge'ye hangi düğüm gelir, hangi mevzuat kime şart olur (§9).
2. **Şirketler** (rakipler ve oyuncu): ekip × verim → kart; aynı katalog, aynı efor, aynı Ar-Ge ağacı ve tavanı (§3.3, §8).
3. **Standart** (her modül için, haftalık): rakiplerin yayındaki seviyelerinin medyanı S, en iyi ikincisi L (§6).
4. **Müşteri**: sektör → hangi modüller; yıldız → kaç modül ve imzadaki yeri (göreli konum `o`); şirketin gidişi → koltuk (§3, §4).
5. **Teklif**: üç düğme, önerilen fiyat modüllerden ve kaliteden; kapanış zarı (§5).
6. **Ses**: satış cümlesi, 3★ ve üstünden yıl ortası istek, yenileme şartı; modül kartında birleşir (§7).
7. **Sonuç**: imza ya da adlı kayıp, genişleme, şartlı yenileme, eskime satırı, adlı ayrılma (§5, §10).
8. **Rapor**: yılda bir kim önde; B2B'de modül ödülü (§6.5).

Oyuncunun sorduğu her "neden" bu zincirin bir halkasının adıyla cevaplanır: "Stok 4'te kaldın, standart 6, Werktag'a geçti."
Böylece gizli ceza yok (Erdem'in genel kuralı) ve rakibin davranışı "hile" okunmaz (FM [B1-S10], Big Ambitions [B1-S5]).

---

## 3. Modüller ve sektörler (kapsam 1)

### 3.1 Modül = hat (yeni yapı değil, yeniden adlandırma ve ekleme)

Bugün "modül" kavramına en yakın yapı hattır: kimliği, adı, kademeleri, iş profili, kullanım ağırlığı ve açık hata deposu var;
rakip çıkışı da hat bazlıdır [K §1.5, §3.1]. Hesabın hangi hatları kullandığı bugün alan üstünden türüyor
(`uses_area`); yerine hesabın modül listesi gelir [K §1.5]. **Benim kararım:** modül = hat; alan (Çekirdek, Onboarding,
Entegrasyon, Güven) beklenti birimi olmaktan çıkar, sprint ekranında gruplama olarak kalabilir.

**KARAR (Erdem 26): 10 modül.** Sektörler 10 modülle anlam kazanır.

| Modül (oyuncu dili) | Ne yapar | Bugünkü karşılığı | Her zaman isteyen profiller (§3.2) |
|---|---|---|---|
| Finans ve Muhasebe | defter, borç, alacak, nakit akışı | `line_erp_ledger` + `line_erp_cashflow` birleşir | hepsi |
| Fatura ve e-Belge | fatura; dönemle e-Fatura, e-Arşiv, e-İrsaliye kademeleri | `line_erp_invoicing` | Mali Hizmetler dışında hepsi |
| Satın Alma | sipariş, tedarikçi | `line_erp_intake` (Veri Girişi) yeniden adlanır | İmalat, Dağıtım, Perakende, İnşaat, Sağlık |
| İK ve Bordro | çalışan, bordro, izin | yeni | hepsi, 2★ ve üstünde |
| Stok | stok, lot, son kullanma, beden-renk varyantı | `line_erp_stock` | İmalat, Dağıtım, Perakende, E-ticaret, Sağlık |
| Üretim | ürün ağacı, MRP, kalite, izlenebilirlik | yeni | İmalat |
| Depo ve Sevkiyat | depo, nakliye, taşıyıcı | yeni | Dağıtım, E-ticaret |
| Mağaza ve Kanal | POS, çok kanallı sipariş; pazaryeri kademeleri dönemle | yeni | Perakende, E-ticaret |
| Proje ve Zaman | iş maliyeti, zaman, kaynak, ilerleme faturası | yeni | Hizmet, İnşaat |
| Varlık ve Bakım | ekipman, mülk, filo, bakım, kalibrasyon | yeni | İnşaat, Gayrimenkul |

Neden 10: gerçek ERP'lerde "iş alanı" birimiyle sayı 6-10 arasıdır (Dynamics NAV 2013 R2 10 iş alanı, Business Central 7+2,
S/4HANA 9 adlı alan) [M-S6, M-S5, M §1]; 5, 7 ve 10'un üçü de bu aralıkta ya da yanındadır, yani sayıyı gerçek dünya değil oyun
belirler. Oyun tarafı: 10 modülde 9 profilin hepsi farklı bir "her zaman" kümesi ister; 7'de 7'si, 5'te 5'i (İmalat, Dağıtım,
Perakende ve Sağlık aynı beş modülü ister, sektör seçimi kararı kalmaz) [P §7.2, V2 #22]. Sim: rakiplerin erken yıllarda bütün
modüllerde tavana yapışmasını (§3.3) yalnız 10 modül önlüyor; 5 ve 7'de dev 2015'te hatlarının %77-82'sinde tavanda [SIM1 §4.1,
§6.1]. Bedeli içeriktir (§12 Yol 3). Fatura'nın ayrı modül olmasının gerekçesi dönemdir (e-Belge 2016 sonrası), "gerçek ERP'ler de
ayırıyor" değil: çoğu satıcı faturayı Finans ya da Satış içinde tutar [M §2].

**Platform hatları** (müşteri seçmez, her hesap kullanır; dönem çıtası en çok buradan büyür): bugünkü dört paylaşılan hat
Entegrasyonlar, Güvenlik ve Yetki, Dayanıklılık, Mobil ve Erişim [K §3.1]. Dönemle açılan hatlar (mobil uygulama 2014, API ve
pazar 2019, YZ dalgaları; §3.3, §9) aynı yoldan eklenir: `register_runtime_line`, gizli hatlarla aynı [K §3.4].

Dayanak: ERP tanımı "çekirdek + sektör eki" yapısındadır [A3-S18]; temel dört parça (finans, fatura, satın alma, İK) her sektör
sayfasında ortak [A3 §1]; Panorama 2012'ye göre ilk uygulanan modüller muhasebe/finans, satış-sipariş-stok ve bordro/İK,
depo ve üretim sonra gelir [A2-S40] ("temelle gir, sonra genişle"); NetSuite'in beş dikey sürümü sektöre göre paket
pratiğini doğrular [A1-S10, V #5, #13]; Business Central'da Premium'u Essentials'tan ayıran şey üretim ve hizmet
modülleridir [A2-S15, S41]. Matrisin hücreleri tek yayıncıdan (ERP Research, satıcı eşleştirme sitesi) [V #13]: yön olarak
kullanılır, ağırlıklar [WORKING].

Önemli boşluk: "bu sektöre uygun modülü olmayan ürün satıldı ve battı" türünde bir başarısız örnek **bulunamadı** [A3-S16,
V #10, P §10]. Bu yüzden modül eksikliği tasarımda **ceza değil bilgi**dir: satışta adı geçen bir kapanış değiştiricisi ve
yenilemede adı geçen bir şart. Gizli düşüş üretmez.

### 3.2 Sektör: 13 ad kalır, 9 profile bağlanır

Bugün sektör 13 kimliktir ve yalnız sayı ve metin kanalıdır; oyuncu onu hiçbir ekranda etiket olarak görmez [K §1.1, §1.3].
**KARAR (Erdem 1): sektör modül profiliyle anlam kazanır.** Profil tablosu P'nin sürümüdür (makine okunur hâli
`tur2/P_profiles.json`, hücreler [WORKING]):

| Profil | Kod kimlikleri | Her zaman ister | Sık ister | Nadir ister | Hiç istemez | Önemli modül (sektöre göre) |
|---|---|---|---|---|---|---|
| İmalat | manufacturing, textile | Finans, Fatura, Satın Alma, İK, Stok, Üretim | Depo ve Sevkiyat, Varlık ve Bakım | Mağaza ve Kanal | Proje ve Zaman | manufacturing: Üretim · textile: Stok (beden-renk varyantı), Üretim |
| Dağıtım ve Lojistik | logistics | Finans, Fatura, Satın Alma, İK, Stok, Depo ve Sevkiyat | Varlık ve Bakım (filo) | Mağaza ve Kanal | Üretim, Proje ve Zaman | Depo ve Sevkiyat, Varlık ve Bakım |
| Perakende | retail | Finans, Fatura, Satın Alma, İK, Stok, Mağaza ve Kanal | Depo ve Sevkiyat | Varlık ve Bakım | Üretim, Proje ve Zaman | Mağaza ve Kanal, Stok |
| E-ticaret | ecommerce | Finans, Fatura, İK, Stok, Depo ve Sevkiyat, Mağaza ve Kanal | Satın Alma | | Üretim, Proje ve Zaman, Varlık ve Bakım | Mağaza ve Kanal, Depo ve Sevkiyat |
| Hizmet | technology, legal, media | Finans, Fatura, İK, Proje ve Zaman | Satın Alma | | Stok, Üretim, Depo ve Sevkiyat, Mağaza ve Kanal, Varlık ve Bakım | Proje ve Zaman (technology'de ayrıca Fatura: abonelik) |
| Mali Hizmetler | finance, insurance | Finans, İK | Fatura, Satın Alma | Proje ve Zaman, Varlık ve Bakım | Stok, Üretim, Depo ve Sevkiyat, Mağaza ve Kanal | Finans |
| İnşaat | construction | Finans, Fatura, Satın Alma, İK, Proje ve Zaman, Varlık ve Bakım | Stok | Depo ve Sevkiyat | Üretim, Mağaza ve Kanal | Proje ve Zaman, Varlık ve Bakım |
| Gayrimenkul | real_estate | Finans, Fatura, İK, Varlık ve Bakım | Satın Alma, Proje ve Zaman | | Stok, Üretim, Depo ve Sevkiyat, Mağaza ve Kanal | Varlık ve Bakım, Fatura (dönemsel kira faturası) |
| Sağlık | health | Finans, Fatura, Satın Alma, İK, Stok | Varlık ve Bakım | Proje ve Zaman | Üretim, Depo ve Sevkiyat, Mağaza ve Kanal | Stok (lot, son kullanma), Varlık ve Bakım |

- Sık ister %40-60, nadir ister %5-15 olasılıkla [WORKING]. İK her profilde "her zaman" ama 1★ (3-10 koltuk) İK istemez.
- Neden 9: Mali Hizmetler'i Hizmet'e, Gayrimenkul'ü İnşaat'a bağlamak bankaya "Proje ve Zaman her zaman", emlakçıya "Stok sık"
  dedirtiyordu (3 saçma hücre); ayrı tutulunca 0 [P §3.1, §5]. Hizmet merkezli sınıf (sağlık,
  finans) Üretim, Depo, Mağaza taşımaz (Gartner'ın ürün merkezli ve hizmet merkezli ayrımı) [P-S6]; hiçbir satıcı finans ya da
  sigorta dikeyi kurmamış ama bu sektörler ERP'yi arka ofis için alıyor (NetSuite 2012 gelirinde 8. sırada) [P-S1, V2 #21].
- 90 hücrenin 47'si kaynaklı, 43'ü varsayım; "her zaman" olup varsayım olan üç hücre (Dağıtım × Satın Alma, Sağlık × Stok,
  Gayrimenkul × Fatura) kalibrasyonda önce bakılır [P §2, V2 #22]. Sektöre göre modül kullanım yüzdesi hiçbir bağımsız kaynakta
  yok [P §11].
- "Sağlık firması lojistik modülü almaz" Erdem'in örneğidir ve tabloda "hiç" yazılır. Sağlık ve Mali Hizmetler'in başka profille
  paylaşmadığı "imza modülü" yok; kimlikleri önemli modülden ve istedikleri modüllerin azlığından gelir [P §7.2].
- Sıra kuralı: 1★ 2-3 modül ister; "her zaman" kümesi bundan büyükse sıra önemli modül, Finans, sektörün imza modülü, sonra kalan
  "her zaman"lar; "sık" ve "nadir" modüller 3★ ve üstünde olasılıkla eklenir [P §7.4, WORKING].
- Gıda imalatın içindedir; kamu ilk sürümde yok [A3 §2.7, §2.9]. İki sektörü tek profile bağlamanın ölçütü: uyuşmayan hücre en
  çok bir basamak [P §3.1]; yeni sektör eklenirken aynı ölçü kullanılır.
- Sektöre özgü mevzuat (sağlıkta e-Belge eşiksiz, KVKK'da özel nitelikli veri) Erdem 1'de seçilmedi: ilk sürümde mevzuat bütün
  profillere aynı takvimle gelir. (Sim sağlığa bir yıl erken şart koydu, `eras.json` `profil_istisna`; kod buna uymaz.)
- **Dönem eğilimi** profil tablosuna değil aday üretim ağırlığına yazılır: 2012'de imalat, dağıtım, hizmet, perakende ağırlıklı;
  e-ticaret 2015 sonrası artar; sağlık ve mali hizmetler önce seyrek [P §6, varsayım; NetSuite'in 2012 sıralaması tek şirket].

**Oyuncu ne görür:** aday kartında sektör adı (bugün yok) ve "İstediği modüller" satırı: modül adı ve yanında sözcük
("istediği seviyede", "bir adım eksik", "çok eksik", "bizde yok"); biri "önemli" işaretli. "Hiç istemez" modül aday kartında hiç
görünmez. Hesap kartında modül çipleri. Görüşmedeki bugünkü "emphasis" soru ailesi (`probe_emphasis_*` [K §1.2]) "önemli modül"
sorusu olarak yeniden kullanılır. Aynı profildeki iki aday önemli modülüyle ayrılır: hukuk bürosu "zaman çizelgesinden faturalama
bizim için önemli", yazılım şirketi "abonelik faturası bizim için önemli" der [P §4.3].

**Açık iş (Erdem 26): oyuncu hedef sektör seçebilir.** Mekanik tasarlanmadı; sektörlerin müşteri tiplerinin artı ve eksileri
sonraki konudur. Sim'in bilgisi: yıllık sektör listesi (profil başına ilk üç) odaklı oyuncuyu ödüllendiriyor (yılların %64-75'i),
dağınık oyuncuyu hiç (%0) [SIM2 §4.3]. Erdem 26 ayrıca "ERP ve e-ticaret ileride ayrıntılandırılacak" dedi.

### 3.3 Derinlik ve tavan

Bugün `TIER_MAX := 3` ve yükleyici 3'ten fazla kademeyi reddeder; ERP'nin bütün tavanı 27 kademedir ve oyun 2-3 yılda
ona varabilir [K §3.4].

**KARAR (Erdem 27):** kademeler dönemle açılır; ilk kademeler biraz pahalılaşır; Ar-Ge ağacı geliştirme tavanını sürekli
yükseltir; dönem geçişleriyle Ar-Ge'ye yeni şeyler gelir (ör. YZ furyası: araştırması yapılınca ek ürün geliştirme tavanı).
"2-3 yılda bütün ERP'nin bitmesi oyunu öldürüyor."

Tavanın iki katmanı:
- **Dönem tavanı (dünya):** modülde açık en yüksek kademe 2012'de K3, iki yılda bir bir kademe artar, 2030'da K12; platform
  hatlarında bir altı [WORKING, sim `eras.json`]. Teknoloji yılları ±2 çeyrek kayar; mevzuat yılları sabittir (§9.1).
- **Ar-Ge tavanı (şirket):** bir araştırma bitince seçtiği modüllerin tavanı dönem tavanının bir üstüne çıkar [R3 D-B1, WORKING].
  Rakip aynı ağacı yürütür, yani tavanını o da yükseltir. Dönem geçişi ağaca yeni düğüm getirir: e-Belge 2015, veri koruma 2016,
  API 2019, YZ dalgaları (aşağıda). Dönem açar (dünyanın olayı), Ar-Ge yükseltir (şirketin emeği); bu ayrım tavanın "yapay engel"
  okunmasını azaltır [R3 §B2, GÖRÜŞ]. Oyunlarda tavan kilidine "yapay engel" şikâyeti bulunamadı [R3 BOŞLUK].
- **Ekranda tavan açık yazılır:** "Stok tavanı şimdi 6 · 2020'de 7 · 'Makine öğrenmesi' araştırmasıyla 7". Virtonomica teknoloji
  seviyesinin azami kaliteyi nasıl sınırladığını tabloyla gösterir [R3-S16]; Game Dev Tycoon'da en çok şikâyet edilen şey gizli
  mekaniktir [R3-S20]. Ar-Ge ilerlemesi kayıtta kalıcıdır (Game Dev Tycoon'da güncellemeyle kaybolunca oyuncu bıraktı [R3-S20]).
- **Oyun sonu boşluğu:** son teknoloji araştırıldıktan sonra yapacak iş kalmaması bilinen sorundur (Civilization'da tekrar eden
  "gelecek teknolojisi" [R3-S18, B2-S26]); tavan basamakları 2030 sonuna yayılır, son kademeler bitişe yakın açılır.

**İlk kademeler (okunuş: eforları).** Sim'in iki parçalı eforu bu kararın uygulamasıdır: K1 bugünkü gibi (tek kurucunun ilk K1'i
~4 hafta), K1-K3 arası dik (her kademe ×4,5), sonrası yumuşak (her kademe ×1,2) [SIM1 §4.1]. Kodun bugünkü eforuyla rakipler
standardı 2015-2027 boyunca tavana yapıştırıyordu; düz ×8 çarpan medyanı tavandan ayırıyor ama tek kurucunun ilk K1'ini ~29 haftaya çıkarıyordu
(demo bozulur); iki parçalı eğri ikisini birden tutuyor. Uyarı: sim'de K3 bugünkünün ~10 katı (111 puana karşı 11); bu "biraz"dan
büyük. Demo temposu ölçüldü (SIM3): tek kurucunun ilk K1'i 3-4 hafta ✅, ama ilk 104 haftada 3 kişilik ekip hiçbir modülde, 6 kişilik ekip
1-4 modülde K3'e varıyor (hedef 2-3; mükemmel yığılsa bile 3 kişide 2,4, büyüyen takımda 1,6-2,1 modül) ❌; eğriyi yumuşatmak (×3,5) tempoyu
düzeltiyor ama erken doygunluğu (G1) bozuyor (§13.2, SIM_RAPOR_2 §4.6); karar Erdem'de. Büyük kademe birden çok sprint süren karttır (Erdem'in D tarifi: "büyük modül birkaç sprint
sürebilir").

**Genişlik kuralı:** tavanı derinlik değil genişlik ve dönem uzaklaştırır. Bütün modüllerin ve dönem hatlarının yeni kademelerinin
toplam eforu en geniş rakibin dönem başına kapasitesinden büyük olmalı; tek modülde derinlik yumuşak artmalı ki odak hız
kazandırsın. Sim bunu doğruladı: aynı eğriyle 10 modülde dev 2015'te hatlarının %59'unda tavanda (eşik %60), 5 ve 7 modülde
%77-82 [SIM1 §4.1].

**YZ dalgaları.**
- Araştırma: ERP'de iki dalga var. Birincisi makine öğrenmesi ve otomasyon duyurularıdır: SAP Leonardo 18 Mayıs 2017, Oracle
  Adaptive Intelligent Apps 2 Ekim 2017, NetSuite "ilk akıllı bulut suit" 24-25 Nisan 2018, Dynamics 365 AI 18 Eylül 2018
  [R3-S7, R3-S9, R3-S11, R3-S12]. Bu dalga olgunluktan çok duyuruydu: modüller "önümüzdeki aylarda" gelecekti, Oracle'ınkiler
  fiyatsız ayrı eklentiydi, ML 2017'de "abartılı beklenti zirvesi"ndeydi [R3-S12, R3-S9, R3-S15]. İkincisi üretken YZ asistanıdır:
  Dynamics 365 Copilot 6 Mart 2023, Oracle'ın Fusion'a gömdüğü üretken YZ özellikleri ve SAP Joule Eylül 2023 [B-S17, B-S18]. 2019-2020'ye özgü bir kilometre taşı bulunamadı.
- Çelişki: Erdem'in örneği "2020 civarı"; tur 2 tasarımı ve sim tek hatla 2023'ü kullandı; kaynaklar 2018 ve 2023'ü gösteriyor.
- Uzlaştırma (çalışma kararı, Erdem'in cevabına kadar): iki dalga. 2018'de "Akıllı otomasyon" hattı ve Ar-Ge düğümü açılır, ilk
  kademesi düşük kazançlıdır; ürünlerin olgunlaştığı 2020 civarı (Erdem'in örneği) ikinci kademesi açılır. 2023'te "YZ yardımcısı"
  hattı açılır, herkes sıfırdan başlar, ~2027'de 5★ için standart olur [R3 §B1 tablo]. İsteğe bağlı üçüncü dalga ajan YZ
  2027-2028 (Gartner: 2028'e kadar kurumsal yazılımın %33'ü ajan YZ içerecek; aynı rapor ajan projelerinin %40'tan fazlasının 2027
  sonuna kadar iptal edileceğini söylüyor) [Y-S17].
- Açık: tek dalga mı iki dalga mı Erdem'in kararıdır (`SORU_PAKETI_3.md` Soru 1). Kod ve sim buna kadar dönem tablosunun YZ
  satırlarına dokunmaz.

### 3.4 Oynanış merceği

| Soru | Cevap |
|---|---|
| Hangi kararı verdiriyor? | Hangi sektöre odaklanayım (yılda 1-2); hangi modülü geliştireyim (her sprint); hangi araştırmayı ne zaman bitireyim (dönem başına 1-2); bu adaya teklif vereyim mi (her görüşme) |
| Tek satır | Aday kartında "İstediği modüller" satırı; ürün ekranında modülün tavan satırı |
| 1 kişide | 2-3 modülle 1★-2★ satış; sektör seçimi ilk büyük karar |
| 50 kişide | 10 modülün çoğu, birkaç sektör; hangi modülde lider olacağın, hangi YZ dalgasına erken gireceğin |
| Angarya | Yok: modül seçimi satış başına bir bakış, ürün kararı sprintte, araştırma kararı dönem başına |
| Hüküm | Tut |

---

## 4. Müşteri: 5 yıldız, koltuk, büyüme (kapsam 2)

### 4.1 Yıldız ve koltuk bantları

Bugün yıldız 1-3'e kilitli (`STAR_MAX := 3` iki yerde, `SEAT_BAND` yalnız 1-3: 5-10, 15-30, 40-70) [K §2.1]; 5'e çıkmak
yaklaşık 30 kod noktasına dokunur, bazıları zaten hazır (`D_stars` 5 glif, `DEAL_BASE_WEEKS` 5 giriş) [K §2.4].

**KARAR (Erdem 6): koltuk bantları her basamakta ~×3.**

| Yıldız | Koltuk |
|---|---|
| 1★ | 3-10 |
| 2★ | 10-30 |
| 3★ | 30-100 |
| 4★ | 100-300 |
| 5★ | 300-1.000 |

Bantlar AB işletme sınıfları [A2-S17 Yüksek] ve ERP kullanan çalışan oranının yaklaşık %26 olduğu satıcı beyanından [A2-S19 Düşük]
türetilmiştir; V gerçek ERP verisiyle doğrulayamadı [V #20]. Bant bir oyun sabitidir. Yorum sitesi G2'nin segmentleri (en çok 50,
51-1.000, 1.001 ve üstü çalışan) birebir örtüşmez [S1-S3]; oyunun yıllık listeleri bu bantları okur (§6.5).

**Görünmeyen ama okunur şirket büyüklüğü:** her hesabın bir çalışan sayısı vardır; koltuk ihtiyacı = çalışan × kullanım oranı
[WORKING]. Hesap kartında "180 çalışan · 46 koltuk" yazar: büyüme ve küçülmenin nedeni bu satırdan okunur.

**Modül sayısı yıldızla:** 1★ 2-3, 2★ 3-5, 3★ 4-6, 4★ 6-8, 5★ 7-10 (profilin "her zaman"ı ve "sık"ın çoğu) [A3 §7.1 varsayım;
WORKING]. Profilin kümesi küçükse küme sınırlar: 5★ banka en çok 6 modül ister (Mali Hizmetler'in "hiç" istemediği dört modül
var). Gerçekte de küçük şirket az modülle başlar (finans, satış-sipariş-stok, bordro sırası; Mikro'nun en küçük sürümü dört öğe)
[M §4.1].

### 4.2 İmzadaki yer (göreli konum `o`) ve koltuğun beklentiyi taşımaması

Her modül için hesabın istediği seviye = o modülün standardı S + hesabın göreli konumu `o`:

| Yıldız | `o` | Okunuşu |
|---|---|---|
| 1★ | S − 2 | "işimizi görsün yeter" |
| 2★ | S − 1 | |
| 3★ | S | "piyasa ne veriyorsa o" |
| 4★ | S + 1 (en çok L) | |
| 5★ | L (kısa liste seviyesi) | "en iyilerle kıyaslarız" |

En az K1. **`o` imzada belirlenir ve hesabın ömrü boyunca değişmez.** Hesap 2★'tan 3★'a büyüse de `o` aynı kalır: Erdem'in
"koltuk artışı beklentiyi artırmaz" kuralı (Erdem K3) böyle tutulur. İstenen seviyeyi yalnız pazar (S ve L) yürütür.
Büyüyen müşterinin yeni ihtiyacı beklenti olarak değil **istek** olarak gelir (§7): karşılanırsa genişleme, karşılanmazsa
fırsat kaçar, hesap tehdit etmez.

Dayanak: büyük alıcının kısa listesi büyük satıcılarla başlar (Panorama 2015: kısa liste SAP %27, Oracle %19, Microsoft %13
[A1-S34], seçilim yanlılığı olası); seçimde 3-5 kısa liste, 2-3 demo finalisti [A2-S36 Düşük]; alıcı komitesi 5-16 kişi
[A2-S35 Orta-Düşük]. Liderin çıtası ile ortalama müşterinin çıtası arasında yıllarca fark vardır (S/4HANA 2015'te çıktı,
2024 sonunda ECC müşterilerinin ~%61'i hâlâ geçmemişti [A1-S2, S6; V #3 düzeltmesiyle]); küçük hesabın standardın altına
razı olması bunu taşır. 5★'ın L'ye bakması [SIÇRAMA]: kısa liste davranışından modül seviyesine geçiş benim çıkarımımdır.

### 4.3 Koltuk: şirketin kendi gidişi

Her hesabın bir **gidişi** vardır: büyüyen, durağan ya da küçülen. İmzada sektörün dönem eğiliminden ve büyüklükten çekilir,
her yenilemede yeniden çekilebilir [WORKING]. Gidiş çalışan sayısını yılda değiştirir; koltuk yalnız yenilemede bakılır:

| Durum (yenilemede) | Sonuç | Oyuncunun gördüğü |
|---|---|---|
| İhtiyaç, mevcut koltuğu en az max(1, %5) aşıyor ve hesap memnun [WORKING, sim2.json] | Koltuk eklenir | "Anadolu Gıda büyüdü (180 → 230 çalışan): +12 koltuk" |
| Aynı, ama memnuniyet düşük | Koltuk eklenmez | "Büyüdü ama yeni koltuk almadı: memnuniyet düşük (hata 6, bekleyen istek)" |
| İhtiyaç mevcudun aynı eşikten fazla altında | Koltuk azalır, memnuniyetten bağımsız | "Küçüldü (140 → 110 çalışan): −8 koltuk" |
| Arada | Değişmez | (satır yok) |
| Koltuk bant sınırını geçti | Yıldız değişir | "3★ → 4★" |

1★ çoğunlukla durağandır ve büyüdüğünde artış eşiğin altında kalır: 1★ sürekli koltuk almaz (Erdem K3). Yenilemelerin çoğunda
koltuk değişmez (Erdem K9). Sim: yenilemelerin %21-30'unda koltuk değişiyor, 1★'ların en çok %5,0'ı yılda büyüyor, yıldız
değişimi yenilemelerin en çok %3,8'i; üçü de hedef bandında [SIM3, SIM_RAPOR_2 §1, koltuk kapısı G6]. Bu, eşiği max(2, %10)'dan max(1, %5)'e indiren sim
ayarıyla geldi (eski eşikte koltuk değişen yenileme %11-19'du); ayar onay bekliyor [SIM2 §3].

Dayanak (hepsi yön; ERP'ye özgü veri yok [A2 §5.2 BOŞLUK, V #20]): özel B2B SaaS'ta medyan net gelir tutma %100, brüt %90
(2020) [A2-S12]; küçük hesap daha çok kaybeder (SMB brüt tutma %80-88, kurumsal %92-96, Düşük) [A2-S14]; sağlıklı küçülme
yılda %5-8 (Düşük) [A2-S43]; "büyüme mevcut sistemin eksiklerini açığa çıkarır" ayrılma nedenlerinin başında (%50,7, satıcı
anketi, Düşük) [A2-S25]; kullanımdaki ERP'nin ortalama yaşı ~11 yıl [A2-S30]: büyük hesap kolay gitmez.

### 4.4 Ayrılma

Yalnız yenilemede ve her zaman adlı:
1. Şart karşılanmadı: "Akdeniz Lojistik yenilemedi: Depo ve Sevkiyat 3'te kaldı, istediği 5; Werktag'a geçti."
2. Memnuniyet düşük: defterin satırlarıyla (hata, kırılan söz, destek, eskiyen modül) [C3a'nın defteri; §10].
3. Ürün dışı (bütçe kesintisi, şirket satın alındı, kapandı): **KARAR (Erdem 2026-10-17): düşük olasılıkla ve nedeni yazılarak**
   ("Harcamalarımızı azaltıyoruz, yenilemeyeceğiz"). Karar 10 gereği kayıp sayılır; nedeni yazıldığı için adlı ayrılmadır.
   Gerçek dünya oranı tek başına gerekçe değildir: küçük şirketin gerçek brüt tutması %80-88'dir [A2-S14 Düşük] ama Erdem'in hedefi
   gerçek hayat kadar zorlamak değil, sağlıklı büyümedir. Sim'in kural kolundaki oran (yılda 1★ %14, 2★ %8, 3★ %5, 4★ %3, 5★ %2)
   bu kararla fazla yüksektir; oran [WORKING]. Üçte biriyle (1★ %4,7, 2★ %2,7, 3★ %1,7, 4★ %1,0, 5★ %0,7) yeniden ölçüldü: G4 ve G6 geçiyor,
   1★ yıllık tutma %95 (SIM3, §13.4 madde 2).

Büyük hesap önce şart koşar, küçük hesap çoğu zaman sessiz gider [A2 §5.5 GÖRÜŞ]: 3★ ve üstü şartla konuşur, 1★-2★'ın
ayrılması haftalık özetin satırıdır (nedeniyle).

### 4.5 Oynanış merceği

| Soru | Cevap |
|---|---|
| Karar | Hangi büyüklüğe satayım; büyüyen hesabın isteğini yapayım mı |
| Sıklık | Yenileme hesap başına yılda bir; koltuk değişimi yenilemelerin azında |
| Tek satır | Hesap kartında "çalışan · koltuk" ve yenileme satırı |
| Görünür neden | Her koltuk ve yıldız değişimi çalışan sayısıyla adlı |
| 1 kişi / 50 kişi | 1 kişide birkaç 1★, değişim seyrek; 50 kişide yüzlerce hesap, yenileme satırları özette toplu |
| Hüküm | Tut |

---

## 5. Satış akışı (kapsam 3)

### 5.1 Aday ve görüşme

Aday şunu söyler: sektör, koltuk, istediği modüller (her biri için sözcük), bir "önemli modül" (sektörün önemli modülü, ör.
imalatta Üretim; §3.2). Görüşmede (kurucu) ya da temsilcinin planında müşteri modülleri ve koltuğu söyler, oyuncu teklif verir
(Erdem'in sektör cevabı, K bölümü). Koltuk pazarlık edilmez [K §1.5]; bu kalır. Teklif üç düğmedir ve fiyat modüllerden ve
kaliteden gelir (§5.6).

Eksik modül için oyuncunun elinde mevcut **söz** mekaniği var: "Stok'u üç ay içinde getiririz" sözü kapanışı yükseltir, söz
kırılırsa hesabın izine bedel yazılır (`PromiseRegistry`, bugün var). Gerçek dünyada satıştaki aşırı söz ile teslimat farkı
başarısız projelerin ortak desenidir (Sunshine Mills 61,4 M$ jüri kararı [A2-S21, V #10], ScanSource 17 → 66 M$ [A2-S22],
Waste Management 100 M$ dava [A2-S20]). **Benim kararım:** yeni sistem değil, söz satıştaki modül eksiğine bağlanır.

### 5.2 Kapanış ihtimali (%60 tabanı yok)

P = taban(yıldız) × uyum × satıcı × fiyat, sonra [%3, %92] arasına kırpılır. Kesin kazanç yok, sıfır da yok [WORKING].

| Terim | Değer [WORKING] | Dayanak |
|---|---|---|
| Taban | 1★ %85, 2★ %80, 3★ %70, 4★ %60, 5★ %50 | Büyüdükçe kazanma oranı düşer (orta pazar %22-28, kurumsal %15-20; Düşük) [A2-S38]; oyundaki aday zaten nitelikli olduğu için genel B2B oranı (%19-23) taban olamaz [SIÇRAMA] |
| Uyum | Her istenen modül: seviyede ×1; bir adım eksik ×0,8 (önemli modülse ×0,6); çok eksik ya da yok ×0,5 (önemli modülse ×0,15) | Modül eksikliği bilgi olarak; ERP Research sektör sayfaları [A3 §2, Düşük] |
| Satıcı | d = satıcı★ − hesap★; d ≥ 0: ×(1 + 0,05·d), en çok ×1,15; **d = −1: ×0,6; d ≤ −2: satışçı bu adaya gidemez** (Erdem 7) | Yön: kurumsal satışçının kotası küçük anlaşma satışçısının ~2,5 katı [A2-S6]; satışçıların %16'sı gelirin %83'ünü getirdi [A2-S11]; çarpanlar türetme [V #20] |
| Fiyat | ucuz ×1,1, standart ×1, pahalı ×0,85 (kapanışa etkisi; fiyatın kendisi §5.6) | Yön tek: ucuz teklif daha çok kapanır; büyüklük kaynaksız [R3 §A2 BOŞLUK] |

Bugünkü `CLOSE_CURVE` ve "hiçbir alan beklentinin altında değilse zar yok, %100" kısa devresi [K §5] kalkar; masalı koşuda
328 kapanışta 0 kayıp bu kısa devreden geliyordu [K §5, RAPOR_Q]. Kurucunun masasındaki yıldız uyumsuzluğu cezası
`[0; 0,14; 0,34]` [K §5] aynı satıcı çarpanıyla değiştirilir: kurucu da satıcıdır (bir üst kuralı ona da uygulanır; §16).

Sim bu formülü kurduğu gibi doğruladı: eşleşen satıcı ve tam uyumda 1★ %91,4, 5★ %49,8 kapanıyor; bir yıldız alttaki satıcı
eşleşenin 0,59-0,61'ini alıyor; kendi süresinin iki katını aşan aday %0,45 [SIM3, SIM_RAPOR_2 §1, satış kapısı G7]. Bunun çoğu formülün kendisidir;
eğlenceli olup olmadığını oynanış gösterir [SIM2 §6].

### 5.3 Süre ve çürüme

Süre: bugünkü `DEAL_BASE_WEEKS` zaten 5 yıldız için tanımlı (2, 3, 6, 8, 12 hafta) ve satıcı üstteyse yıldız başına yarım hafta
kısalır [K §2.1, §5]. Ek: satıcı alttaysa yıldız başına +%20 [A2 §4.2 varsayım]. Gerçek dünyada büyük anlaşmanın "altın
dönemi" 150-180 gün (Ebsta, doğrulandı) [A2-S10, V #1]; ERP seçimi kurumsalda 6-12 ay (Düşük) [A2-S36]. **Benim kararım:**
bugünkü tabloyla başla, sim'de 4★-5★'ı uzatma gerekip gerekmediğine bak (Erdem K5: takvim sıkışmaz).

Çürüme: açık aday kendi süresinin iki katını aşınca kapanış ihtimali %3'e iner (Ebsta: ortalama döngünün 2 katından uzun açık
kalan fırsatın kapanma şansı %3, doğrulandı [A2-S10, V #1]). Aday kartında "soğuyor" sözcüğü.

### 5.4 Satışçı yıldızı oyuncuya ne verir (Erdem K8)

**KARAR (Erdem 7): satışçı en çok kendi yıldızının bir üstündeki hesaba gider, şansı düşer (×0,6).** Bugünkü sert bant kapısı
(satışçı kendi yıldızının üstündeki adaya bakamaz [K §5 madde 1]) bir yıldız genişler; iki yıldız üstü kurucuya ya da daha
yıldızlı satışçıya kalır.

1. **Büyük hesabın anahtarı**: 4★ hesap için en az 3★, 5★ hesap için en az 4★ satışçı gerekir; yıldızlı satışçı işe almak bir
   karar olur. Sim: büyüyen takımla ilk 104 haftada 4★ kapatan tohum %0-5; satışa yatırım yapan 3 kişilik ekiple %35-55 [SIM3, SIM_RAPOR_2 §4.2].
2. **Hız**: aynı adayı daha kısa sürede kapatır, çürümeden önce.
3. **Okunur neden**: kayıp satırı "satışçının deneyimi yetmedi (2★ satışçı, 3★ hesap)" der; gidemediği aday listede kilitli
   görünür, gerekçesiyle ("Bu hesap için en az 3★ satışçı").
4. **Haber ve marka**: bugünkü ulaşım bandı kuralı kalır (en yüksek satıcının üstündeki imza haberlik) [K §5 madde 3].
5. Dokunmadığı: fiyat ve koltuk [K §5]; indirim ihtiyacına etkisi için kanıt yok [A2 §4.2 BOŞLUK].

Yıldızın yükselmesi bugünkü İK beceri sistemiyle kalır.

### 5.5 Kayıp nedenleri

Her kayıp tek nedenle adlanır, öncelik sırasıyla: önemli modül yok ya da çok eksik · başka bir modül eksik · rakip daha
özellikli ("Pythia'nın Stok'u daha derin") · satışçının deneyimi · fiyat ("Werktag 52 $ verdi, siz 61 $") · aday soğudu. Haftada en
çok bir kayıp maili, kalanı haftalık özetin satırı (bugünkü kural) [CLAUDE.md §6]. Kaybedilen aday adlı rakibe gider (§8.5).
Two Point Hospital'da ret nedeni tek bir çubuğa bağlı ve görünmez olunca oyuncular "hep %100 bırak" gibi birbirini yalanlayan mitler
üretti [F2-S13]; nedeni yazılı kayıp bunu önler.

### 5.6 Fiyat

**KARAR (Erdem 30):** fiyat oyuncuyu yormaz, angarya olmaz. Ucuz / Standart / Pahalı üç seçenek; her birinin önerilen fiyatı
var; oyuncu birini seçer, teklif gider. Fiyat koltuk başıdır; anlaşma = koltuk × fiyat. Önerilen fiyat müşterinin istediği
modüllerden ve o modüllerin kalitesinden hesaplanır (zayıf modül ucuzlatır, iyi modül pahalandırır). 5★'ın yüksek geliri sorun
değil (5★ bağlamak zaten çok zor). Hesaplama araştırıldı (R3); daha iyi öneriye açık. Erdem 8'in "modül fiyatı olsun"u bu
formülün içindedir: çok modül isteyen hesabın koltuğu pahalıdır.

**Önerilen fiyat formülü** [R3 §A4; hepsi WORKING]:

```
r_m      = q_m / q_std,m                      (modülün seviyesi ÷ o modülün piyasa standardı; 1 = standartta)
k_m      = sınırla( 1 + 0,5 × (r_m − 1) ; 0,75 ; 1,25 )
K̄        = Σ(w_m × k_m) / Σ(w_m)              (modül ağırlıklı kalite çarpanı)
standart = P0 × (1 + Σ w_m) × K̄
ucuz     = standart × 0,85 ;  pahalı = standart × 1,15
anlaşma (aylık) = koltuk × seçilen koltuk fiyatı
```

- P0 = 30 $ (bugünkü bandın tabanı [K2 §1.1]). Modül ağırlığı w: hafif 0,10, orta 0,20, ağır 0,30. Gerçek listelerde ağır modül
  hafifin yaklaşık 2,7-2,9 katıdır (Mikro'da Üretim ana paketin %79'u, Perakende %29'u; Logo'da e-Fatura %57'si, e-Arşiv %20'si)
  [F1-S7, F1-S8; R3 §A1 hesap]. Hangi modülün hangi sınıfta olduğu [WORKING] bir veri tablosudur; gerçek listelerde Üretim,
  bordro ve e-Fatura ağır tarafta (Mikro'da ana paketin %79-100'ü), perakende ve POS hafif tarafta (%29-48) durur.
- Kalite primi ±%25 dar tutulur: Microsoft'un sürüm farkı 1,38-1,43 kattır (Business Central 80/110 $, Dynamics 365 Finance ve
  Supply Chain 210/300 $) [F1-S1, F1-S16, R3-S6]; fiyat ile algılanan kalite ilişkisini ölçen iyi kaynaklı çalışma bulunamadı.
- Örnekler (R3'ün hesabı, yuvarlanmış): 2 modül (1 hafif, 1 orta) standart kalitede 39 $ (ucuz 33, pahalı 45); 5 modül (2 hafif,
  2 orta, 1 ağır) 57 $; aynı 5 modülde ağır modül zayıfsa 52 $, hepsi zayıfsa 43 $, hepsi iyiyse 71 $; 10 modül (4 hafif, 4 orta,
  2 ağır) 84 $ (ucuz 71, pahalı 97).
- Birim fiyat koltuktan bağımsızdır: 1 koltukta da 1.000 koltukta da aynı; "koltuk artışı beklentiyi artırmaz" kuralıyla uyumlu.
- Rakibin fiyatı aynı formülle rakibin kendi modül kalitelerinden çıkar: yeni veri gerekmez, kopyalama yoktur (kodda rakip fiyat
  alanı yok [K2 §1.5]).

**Ekranda:** üç düğme; her birinde koltuk fiyatı, aylık toplam ve kapanış şansı sözcükle ("yüksek", "orta", "düşük"); altında tek
satır gerekçe ("Stok piyasanın altında: fiyat %8 düşük") ve en güçlü rakibin standart teklifi. "Optimal" sözcüğü yok.

**Kim seçer:** kurucunun görüşmesinde oyuncu her teklifte bir düğme seçer. Temsilciler oyuncunun Satış sekmesinde seçtiği duruşla
çalışır (bugünkü "Fiyat duruşu" seçicisi): hesap başına karar yok, 1 hesapta da 400 hesapta da aynı yük. Big Ambitions'ta fiyat
mağaza başına sürekli konunca 60-70 mağazada "kâbus" denildi, geliştirici sonradan "Fiyat Müdürü" ve "önerilen fiyatları uygula"
düğmesini ekledi [F2-S7, F2-S8, F2-S6]. Bugünkü pazarlık cetvelinin serbest fiyat girişi ve karşı teklif turu kalkar (oyuncu birini
seçer, teklif gider); müşteri teklifi kapanış zarıyla kabul eder ya da etmez.

**Duruşun bedeli ve getirisi:** ucuz daha çok kapanır (×1,1), pahalı daha az (×0,85) [WORKING]; ucuzun bedeli düşük MRR'dir ve
ekranda görünür. "İndirimle kazanılan müşteri daha çok ayrılır" yönü tutarlı ama sayılar ikinci elden ve doğrulanamadı [R3 §A2];
bu yüzden ucuz duruşa gizli bir ayrılma bedeli bağlanmaz (Erdem 2026-10-17: gizli bedel yok).

**Genişleme ve yenileme:** fiyat imzada damgalanır. Hesap yeni bir modül eklediğinde (istek karşılandı, genişleme) koltuk fiyatı
yalnız yeni modülün ağırlığı kadar artar: fiyat × (1 + Σw + w_yeni) ÷ (1 + Σw). Yenilemede fiyat değişmez, zam kararı yok
(bugünkü kod; hesap başına karar angarya olur) [§16].

**Hacim indirimi yok** (Erdem 30). Gerçekte var (Logo'da +10 kullanıcı bloğu +2'ye göre %28 ucuz; NetSuite çok yıllıkta %20-30,
Düşük) [F1-S8, F1-S12]; ekonomi ölçümü (Faz C'nin E2'si) gerekirse tek tablo olarak eklenir, formül değişmez. 5★ geliri: 650
koltuk × 84 $ ≈ 55.000 $/ay (hesap). Tek 5★ seed kapısını (`DOOR_MRR` 20.000 $) aşar; sorun sayılmaz, çünkü demoda 5★ kapatmak
çok zordur (Erdem 5; sim'de büyüyen takımla ilk 104 haftada %0 [SIM2 §1]). Eski "tek 5★ ≤ 20.000 $" hedefi düştü.

**Tek doğru cevap riski:** Software Inc'te önerilen fiyat gösterilince oyuncular onu kopyaladı; bir oyuncu "ya ücretsiz ya
önerilen fiyat, arası yok" yazdı (tek yazar, tek koşu; V2 deneyi açamadı) [F2-S1, F2-S3, V2 #15]. Önlemler: tek sayı değil üç
duruş; kapanış zarlı (aynı duruş aynı sonucu vermez); kayıp nedeni satırda; rakibin teklifi görünür; profil başına fiyat
duyarlılığı ileride eklenebilir (Capitalism Lab'de fiyatın ağırlığı ürüne göre değişir [F2-S17]). Sim kapısı: hiçbir duruş
tohumların %80'inden fazlasında en yüksek MRR'yi vermez (§13). Sim (SIM3, beşinci kol; formül SENTEZ'in
örnekleriyle bire bir tuttu) kapıyı geçmedi: ×0,85 / ×1,15 fiyat ve ×1,1 / ×0,85 kapanış çarpanıyla "pahalı" duruş tohumların %66'sında
(huni serbestken %75'inde) en yüksek MRR'yi veriyor, çünkü kapanış çarpanı satış hacmini az etkiliyor; ×1,4 / ×0,65 kapanış çarpanıyla
havuzda dengeli (%37 / %34 / %29), küçük ekipler ucuz ya da standart, baştan büyük ekipler pahalı seçiyor (bir hücrede %85). Seçenekler
§13.4 madde 6'da; çarpanlar [WORKING], onay bekliyor.

**Kod maliyeti** (K2'nin dosya haritası; K2 "modül eki + hacim indirimi" için ölçtü, Erdem 30'un farkı son sütunda):

| # | Yer | Değişiklik | Erdem 30 modelinde |
|---|---|---|---|
| 1 | `sales_constants.gd` (`SEAT_PRICE_MIN/MAX`, `STANCE_MULT`, `SEAT_BAND`) | tek $30-70 bandı kalkar; `STANCE_MULT` 0,85/1/1,15 kalır; `SEAT_BAND` 5 yıldıza | + P0 ve modül ağırlık tablosu; hacim tablosu yok |
| 2 | `sales_ledger.gd` `seat_price_anchor` | (duruş, modüller, kalite) okur; 4 çağıran | formülün kendisi ≈30 satır (kolay) |
| 3 | `negotiation_system.gd` | bağlama modüller | serbest fiyat cetveli, sabır kutusu, karşı teklif üç düğmeye iner (silme ağırlıklı, ölçülmedi) |
| 4 | `sales_meeting_adapter.gd`, `meeting_ruler.gd` | teklif panelinde 4. satır (bugün 3 sabit etiket) | üç düğme, gerekçe ve rakip satırı |
| 5 | `sales_system.gd` `add_b2b_customer`, `pipeline_optimistic_mrr` | modül listesi, MRR formülü | aynı |
| 6 | `sales_finalizer.gd`, `sales_rep_system.gd` | modül listesini terimlere taşı | temsilci duruşun önerilen fiyatından kapatır |
| 7 | `customer.gd`, `prospect.gd` | `modules` alanı | aynı (modül tasarımının zaten önkoşulu) |
| 8 | `b2b_sales_system.gd` `expand` + yeni `add_module` | yeni modül = genişleme | fiyat yalnız yeni modülün ağırlığıyla |
| 9 | `effects.gd`, `chips.gd` | modül ekleyen fiil ve çip önizlemesi | aynı |
| 10 | `sales_tab.gd` | aday ve hesap kartında modül satırı | aynı |
| 11 | `save_manager.gd` | şema 18 → 19 göçü, eski hesaplara modül listesi | aynı |
| 12 | `product_quality.gd` `close_chance` (temsilci) | bugün duruşu okumaz | duruşun kapanış çarpanı ~10 satır |
| 13 | `strings.csv` | 8 satır (fiyat satırı şablonları, `SALES_STANCE_HINT_*`) | duruş adları Ucuz/Standart/Pahalı, gerekçe ve rakip satırı |

Toplam (K2): **13 kod dosyası + CSV, ~140-190 satır, ~35 smoke noktası; zorluk orta** (modül listesi hazırken), modül listesi ve
şema göçü birlikte orta-zor [K2 §1.6, V2 #23]. Erdem 30 modelinde hacim satırları düşer; formül (≈30 satır) ve pazarlık cetvelinin
sadeleşmesi eklenir. Silinenler: tek bant, "kadran B2B fiyatının tek kaynağıdır" yorumları, bant ortası × çapa formülü.

### 5.7 Oynanış merceği

| Soru | Cevap |
|---|---|
| Karar | Bu adaya kimi göndereyim, hangi duruşla, söz vereyim mi; yıldızlı satışçı alayım mı |
| Sıklık | Kurucu her teklifte bir tık; temsilciler için duruş ara sıra; işe alma yılda birkaç kez |
| Tek satır | Zar panelinin değiştirici satırları (en çok 4, bugünkü sınır `MODIFIER_LINES_MAX`); teklif panelinde üç düğme |
| 1 kişi / 50 kişi | 1 kişide kurucu satıcıdır, 1★-3★ kapatır; 50 kişide satış ekibinin yıldız dağılımı hangi hesaplara ulaşacağını belirler, fiyat kararı yine duruş başına bir |
| Hüküm | Tut; %60 tabanının yerine okunur kayıp nedeni; serbest fiyat yerine üç düğme |

---

## 6. Sektör standardı (kapsam 4)

### 6.1 Nasıl doğar

Her modül m için, **yayınlanmış** rakip sürümlerinin seviyeleri r_i(m) (o modülü sunmayan rakip sayılmaz):
- **Standart S(m)** = medyan: "pazarda çoğunun verdiği".
- **Kısa liste seviyesi L(m)** = en iyi ikincisi: büyük alıcının kısa listesinde en az iki ciddi aday olur.
- Oyuncu bu hesaba **girmez**. Öne geçtiğinde standart onu kovalamaz; "ölçüt senin en iyi işin" kuralı Game Dev Tycoon'da
  "nedeni görünmeyen zorlaşma" diye yaşandı [B2-S4]. Bu Erdem'in "kopyalama yok" kararının yapısal karşılığıdır.

İkinci kaynak **mevzuattır**: belli bir tarihte belli büyüklükteki müşteri için bir kademe zorunlu olur, rakipler ne yaparsa
yapsın (e-Belge, KVKK; §9). Gerçek dünyada standart üç mekanizmayla oluşur: mevzuat, satıcı duyurusu, alıcının gecikmeli
benimsemesi [A1 §4 GÖRÜŞ, S6, S35; mevzuat takvimi V #2]. Erdem K6 yalnız rakip sürümünü söyledi; mevzuatı eklemek benim kararım
(§16) [GÖRÜŞ].

### 6.2 Büyük hesap neden daha özellikli ürüne yönelir

Çünkü baktığı çıta farklıdır (`o`, §4.2): 5★ L'ye, 1★ S − 2'ye bakar. Büyük hesabın kısa listesi büyük satıcılarla başlar
[A1-S34], komitesi kalabalıktır [A2-S35], ve daha çok modül ister (§4.1). Oyunda: aynı ürün 1★ adaya "fazlasıyla yeter",
5★ adaya "iki modülünüz kısa listenin altında" der.

### 6.3 Nasıl büyür

Rakiplerin kapasitesi, Ar-Ge'si ve dönem açılımlarıyla (§3.3, §8, §9). Standardın gerçek dünyadaki sayısal büyüme hızına dair
kaynak yok [A1 §4 BOŞLUK]; biçimini erken doygunluk kapısı zorlar: medyan dönem tavanının en az bir kademe altında kalmalı, yoksa
standart takvime döner (§3.3, kapı G1). Hedef büyüklük [WORKING]: 2014 sonrası her modülde S yılda 0,3-0,7 kademe. Sim: 2015-2030
her yıl medyan tavanın en az bir altında ✅, ama hız yılda 0,24-0,31 kademe, hedefin biraz altında; 2026'dan sonra rakip ekipleri
tavanlarında durduğu için ~0,2'ye iniyor: 2030'da standart K6, dönem tavanı K12 [SIM1 §5.1, §5.2]. SIM3'te rakip ekip tavanı gelire
bağlandı: yukarı yönlü bağlama standardı değiştirmedi, tam bağlama girişimleri geliri taşıyamaz hâle getirip standardı dondurdu (§11.2, §13.4).

### 6.4 Oyuncuya nasıl gösterilir (sayı yok)

Her zaman olanlar:
- **Haber şeridi**: rakip sürümleri, haftada en çok bir satır, birleştirilmiş ("Werktag Stok'u yeniledi"). Rakibin hamlesi
  haber olarak görünür; Motorsport Manager'da rakip gelişimi görünmeyince "AI değişmedi" denmişti [B1-S38].
- **Satışta müşterinin cümlesi**: "Stok bizim için önemli, sizde istediğimiz seviyede değil." (Erdem K6)
- **Yenilemede şart cümlesi**: "Rakiplerde olan Depo ve Sevkiyat sizde zayıf; yenilerken bunu istiyoruz." (Erdem K3)
- **Her kayıpta kazanan rakibin adı ve modülü.** Big Ambitions'ta açıklanamayan rakip kârı "hile" diye okundu ve geliştirici
  hata kabul etti [B1-S5, V #16]; Offworld'de "AI gizli bilgi kullanmaz" cümlesi güven doğurdu [B1-S20].
- **Yılda bir: sektör raporu ve modül ödülleri** (§6.5).

Ürün sayfasında sürekli "standardın altında / standartta / önde" sözcüğü yok: beklenti ekranda metrik olarak gösterilmez (Erdem K1)
ve Erdem 29 yıllık raporu seçti.

### 6.5 Yıllık rapor ve modül ödülü

**KARAR (Erdem 29):** yıllık rapor (en büyükler ve en hızlı büyüyenler; bir derginin ya da vakfın yıllık listesi gibi) ve B2B'de
modül bazında ödül ("en iyi Stok modülü"); ödül raporla aynı anda, yılda bir (sıklığı Erdem'in bıraktığı üzerine yardımcı
yönetmen belirledi). B2C'de modül ödülü yok; yalnız en büyük ve en hızlı büyüyen platformlar.

**Ne zaman:** her yıl Kasım'da, o yılın 1 Ocak-31 Ekim verisiyle [R3 §C4, GÖRÜŞ]. Gerçek listeler çoğunlukla Ağustos-Eylül'de
önceki yılı okur (Inc. 5000 Ağustos, Bilişim 500 5 Ağustos 2026, Forbes Cloud 100 Eylül başı) [R3-S25, S1-S13, R3-S27]; Gartner'ın
bulut ERP raporu 11 Kasım 2024 tarihlidir [S1-S29, V2 #13]. Kasım seçimi demoda iki rapor verir (Kasım 2012 ~46. hafta, Kasım 2013 ~98.
hafta; Ağustos seçilse ilk rapor oyuncunun elinde bir yıl yokken gelirdi); 2030 sonuna kadar 19 rapor.

**Ne yazar (gelen kutusunda tek mail, yılda bir; sayı değil sıra ve ad, gerekirse fark):**
1. **En büyükler**: ilk beş şirket, adı ve hesap sayısı; oyuncu listede değilse kendi sırası tek satır ("Siz 9. sıradasınız").
   Sıra numarası tek başına farkı gizler (Motorsport Manager'da "sıralama her basamaktaki farkı söylemiyor" tepkisi [S2-S17]);
   bu yüzden hesap sayısı yanında yazılır. Gerçekte "en büyük ERP" sırası gelire göredir ve ilk 10 pazarın %31,9'unu tutar [S1-S24]:
   büyüklük listesi küçüğü dışlar; oyuncunun buraya girmesi geç oyundur (Erdem 9).
2. **En hızlı büyüyenler**: yüzdesel büyüme, 52 haftalık pencere, bir gelir tabanı ve en az bir yıllık varlık şartıyla [WORKING].
   Gerçekte büyüme listeleri küçüğe açıktır (Inc. 5000 2 milyon $ yıllık gelirle, Deloitte Fast 500 ve Fast 50 Türkiye göreli
   büyümeyle sıralar) [R3-S23, R3-S26, S1-S12]. Oyuncunun ilk yıllarda girebildiği liste budur; erken bir ödül hissi verir.
3. **B2B modül ödülleri**: on modülün her birinde tek kazanan ("Yılın Stok modülü: Werktag"). Koşul: o modülün seviyesi
   yayımlayanlar arasında en yüksek ve modülü en az N hesap kullanıyor (alçak kapı; yorum sitesi G2'nin ürün başına 10 yorum eşiği gibi) [WORKING,
   R3 §C2, S1-S3]. Bir şirket bir modülde yılda en çok bir ödül alır; rozet enflasyonu (bir satıcının yılda ~39-50 rozet listelemesi)
   oyuna girmez [S1-S25]. Küçük şirketin müşterisi de sayılır (Gartner'ın 50 milyon $ altı şirket yorumlarını saymaması küçük
   satıcıyı dışlıyor) [R3-S22]. Oyuncunun kendi modülleri için raporda tek satır durum: "Stok: ödül" · "kısa listede" · "standartta"
   · "geride" (yılda bir okunan değerlendirme, sürekli gösterge değil).
4. **B2C**: yalnız en büyük ve en hızlı büyüyen platformlar.

**Ödülün tek görünür karşılığı:** o modülü isteyen adaylar 12 ay boyunca daha sık gelir (×1,3) [WORKING]; ekranda süresiyle yazılır
("Yılın Stok modülü: Stok isteyen adaylar Kasım 2015'e kadar daha sık geliyor"). Neden bu: ödülün satın almaya ölçülmüş tek etkisi
aday akışıdır (yorum sitesi G2'nin kendi vakasında "lider" rozetini tanıtan Looker'ın ücretli kanal lead'leri 2 kat; baz ve kapanış yok, Düşük)
[R3-S21]; rozetin kapanışı artırdığını gösteren bağımsız çalışma bulunamadı. Öbür adaylar elendi: 4-5★ kısa listesi demoda 5★'ı
açardı (Erdem 5 ile çatışır); itibar oyuncuya görünmez kalırdı (Software Inc'te oyuncular "ödüller ne yapıyor?" diye sordu, cevaplar
çelişti [S2-S10]); kapanış zarına dokunmak kanıtsız. Two Point Hospital'da yıllık tören var [S2-S13]. Kod: B2B lead akışı bugün
marka ve itibarı okumaz; çarpan `lead_rate_per_week` içine tek satır girer [K2 madde 21]. Rakip ödül alınca aynı çarpan onun pay
çekimine yazar (aynı kural).

**Kuralların hepsi yardım metninde yazılıdır** (eşik, ölçüt, hangi ay): gerçekte en çok şikâyet edilen şey listelerin kuralının
görünmemesidir (Gartner'a "parayla yer" davaları) [S1-S16]. Listeden düşen oyuncu nedenini görür.

**Sim'in gösterdiği** [SIM3, SIM_RAPOR_2 §4.3, büyüyen takım, 2013-2030]: modül ilk üçü neredeyse her yıl geliyor (dağınık oyuncuda bile %100):
ucuz bir haber, bu yüzden raporda yalnız birinci (ödül) adıyla yazılır. Ödülü odaklı oyuncu yılların %39'unda, verimli %61'inde,
öncü %28'inde, dağınık %25'inde alıyor; durgun hiç. "En büyükler" listesinde oyuncunun tahmini sırası 2020'de 4., 2030'da 2-4.
(gölge sıra; sim portföyü sabit tuttuğu için gerçek sıra ölçülmedi).

Bu tasarım "liderlik bilgisi" sorusunu kapatır: oyuncu kimin önde olduğunu yılda bir, adıyla ve nedeniyle öğrenir; arada müşteri
cümleleri ve rakip sürüm haberleri konuşur. Gizli yıllık artan çıta "bir şey değişti, oyun zorlaştı" dedirtmişti (MGT2 [B2-S10, S11]).

### 6.6 Oynanış merceği

| Soru | Cevap |
|---|---|
| Karar | Hangi modülde standarda yetişeyim, hangisinde ödül için yarışayım; büyümeyi mi büyüklüğü mü kovalayayım |
| Sıklık | Sürekli arka plan; somut an satış, yenileme ve Kasım raporu |
| Tek satır | Müşterinin cümlesi; yılda bir rapor maili |
| Angarya | Yok: oyuncu standardı izlemek zorunda değil, müşteri söyler; rapor yılda bir |
| 1 kişi / 50 kişi | 1 kişide "en hızlı büyüyenler" erişilebilir; 50 kişide modül ödülleri ve "en büyükler" yarışı |
| Hüküm | Tut |

---

## 7. Beklentinin sesi: istek ve şart (kapsam 5)

### 7.1 Üç ses, iki anlam

| Ses | Ne zaman | Kim | Anlamı | Karşılanmazsa |
|---|---|---|---|---|
| Satış cümlesi | Görüşme ve aday kartı | Aday | Bilgi | Kapanış düşer, adlı |
| **Yıl ortası istek** | Hesabın şirketi büyüdü, yeni bir modüle ihtiyaç doğdu (profilin "sık" hücresi açıldı) ya da yeni dönem hattı çıktı | **Yalnız 3★ ve üstü** (Erdem 5) | **Fırsat**: yeni modül (genişleme, fiyatı artırır §5.6) ya da kullandığı modülde derinlik; derinlik isteği yalnız pazarda var olan seviyeyi ister (en iyi ikinci rakibin seviyesi ya da hesabın kendi standardı) | Fırsat kaçar; iki çeyrekten uzun bekleyen istek adlı küçük bir memnuniyet satırı ("İsteği 2 çeyrektir bekliyor") [WORKING] |
| **Yenileme şartı** | Yenilemeden 8 hafta önce [WORKING], kullandığı bir modül istediği seviyenin altındaysa | 3★ ve üstü şartla; 1★-2★ çoğu zaman sessiz | **Tehdit** | Bir adım açık: şartlı yenileme, şartın süresi var (C4'ün Kurumsal madde düzeneği: etiket, tarih, fesih bildirimi). İki adım ve üstü ya da düşük memnuniyet: ayrılır, adlı |

Erdem K1'deki "müşteri ilişkisi iyi, ürün düzenli gelişiyor, istekler karşılanıyorsa memnun kalır" şöyle okunur: memnuniyet
defteri ilişkiyi (destek, söz, hata) taşır; bekleyen istek küçük bir satır yazar. **Ürün eskir (Erdem 11):** hesabın kullandığı
bir modül istediği seviyenin altında kaldıkça memnuniyet adlı bir satırla düşer ("Stok 4'te kaldı, rakiplerde 5") [WORKING
büyüklük; sim'de `eskime_memnuniyet`, henüz denenmedi]; açık yenilemede ayrıca şart olarak konuşur. Erdem 2026-10-17'nin listesi
de bunu sayar: memnuniyeti açık hata, kesinti, tutulmayan söz ve uzun süre güncelleme almayan ürün düşürür; nedensiz düşüş yok.
**Memnun 3★+ hesap bir adımlık açığı şart değil istek olarak söyler** [WORKING]: destek ve ilişki burada oyuncuya zaman kazandırır
(Erdem K2'deki "destekte öne geçmek").

Derinlik isteğinin "yalnız pazarda var olan seviye" kuralı sim'den geldi: istek oyuncunun kendi seviyesinin bir üstünü isteyince
güçlü oyuncu kimsenin yapmadığı, bir yıldan uzun süren kademelere istek alıyordu ve sprint başına 8-10 bekleyen modül kartı
birikiyordu; kural 3-4'e indirdi ve Erdem K6'nın "rakiplerde olan şu alanınız zayıf" cümlesiyle örtüşüyor [SIM1 §4.2; §16].

Gerçek dünya notu: yenilemede müşterinin koştuğu şartlar fiyat ve sözleşme maddeleridir (artış sınırı, denetim, kullanılmayan
lisans) [A2-S28, S29 Düşük]; **özellik şartı için ERP'ye özgü kanıt bulunamadı** [A2 §5.4 BOŞLUK]. Özellik şartı Erdem'in
tasarım kararıdır; mevzuat şartı ise gerçek dünyada vardır (e-Fatura çıktısı olmayan ürün zorunlu mükellefin işini görmez
[A3 §4, V #2]).

### 7.2 Sıklık (kaç hesapta, ne kadar)

**KARAR (Erdem 5):** istek yalnız 3★ ve üstünden gelir; 4-5★ 3★'tan daha sık ister. Demoda 5★'a erişim çok zor olmalı (playtest'te
bakılacak). Yıl ortası istek ihtimali, hesap başına yılda [WORKING]: 1★ ve 2★ yok, 3★ %25, 4★ %40, 5★ %60. 300 hesaplık bir
karışımda (150 1★, 100 2★, 40 3★, 8 4★, 2 5★): 10 + 3,2 + 1,2 ≈ 14 istek/yıl, haftada ~0,3 (hesap). Şart sayısı standardın hızına
bağlı: oyuncu odak modüllerinde yetişirse şart yalnız ihmal edilen modüllerde doğar. Hedef [WORKING]: şartlı yenilenen hesap yılda
en çok %25; güçlü oyuncu şartsız kalabilir (ödülü budur), durgun ve dağınık oyuncuda şart görünür olmalı (en az %5). Sim: güçlü
botlarda yılda %0-1,3 (SIM3; eskime ve ürün dışı ayrılma açıkken), durgun kolda %4-16 (SIM1), 1-3 kişilik ekiplerde %0,3-14 (SIM1) [SIM3 §1, SIM1 §4.2]. Alt sınır (%5) hiçbir kolda tutmuyor.

### 7.3 Yüzlerce hesapta angarya olmadan

- **Birleştirme**: istekler ve şartlar (modül, kademe) çiftinde tek sprint kartında toplanır: "Stok 6 · 14 hesap istiyor ·
  3'ü şartlı · 21.000 $ MRR". Kartın adı isteğin konusundan gelir (Karar 25). Oyuncu hesap hesap değil modül modül karar verir.
- **Mail bütçesi**: haftada en çok 2 müşteri maili, öncelik şartlı 3★+ hesap; kalanlar haftalık özette sayı satırı.
  Temsilci varsa ses temsilcinin ağzından, yoksa müşterinin mailiyle (Karar 9).
- **Görünüm**: Genel Bakış'ta tek şerit ("Şartlı yenileme: 3 hesap · Stok, Depo ve Sevkiyat"); HESAPLAR tablosunda (C8)
  "şartlı" süzgeci.
- **Hesap başına zorunlu eylem yok**: söz vermek yalnız 3★+ için isteğe bağlı bir hamle.
- Sim: 330 hesapta haftalık müşteri maili medyanı 0, en kötü tohumda p99 5 (hedef ≤ 2 ve ≤ 5) ✅; sprint başında bekleyen ayrı istek
  kartı p95 3 (hedef 3) ✅ [SIM3; istek ömrü 26 → 13 hafta ve memnuniyet eskimesiyle p95 4'ten 3'e indi, ses yükü kapısı G5].

Angarya kanıtı: ağaç bitince tekrar eden seçim Civilization VI'da angarya bulundu [B2-S26]; yenileme düğmesi Anno'da sıkıcı
tekrar sayıldı [B2 §2.5]; ölçekte şikâyet "atama değil genel bakış yok, tek tek tıklama" [ATAMA-A1 §0 madde 6].

### 7.4 Oynanış merceği

| Soru | Cevap |
|---|---|
| Karar | Bu modül kartını bu sprinte alayım mı (kaç hesap, ne kadar MRR, kaçı şartlı) |
| Sıklık | İstek haftada ~0,3 (300 hesapta), kart sprint başına en çok 3 |
| Tek satır | Modül kartının başlığı |
| 1 kişi / 50 kişi | 1 kişide istek yok (1★-2★ istemez), ilk 3★ ile istek tanışılır; 50 kişide aynı sayıda kart, daha büyük toplamlar |
| Hüküm | Tut; birleştirme şart |

---

## 8. Rakipler (kapsam 6)

### 8.1 Rakip = şirket, aynı kurallar

Her rakibin durumu: ekip (geliştirici sayısı ve test/tasarım dağılımı, hat profillerinin hızını belirler), verim (oyuncunun
kişi başı haftalık puanıyla aynı sabit, `person_points_week`), bakım payı (hata akışı aynı formül: 0,1 × (1 + hesap/80)
[K §6] → düzeltme kartları), hesap sayısı ve MRR (pazar havuzundan, §8.5), kasa (gelir − maaş), kart kuyruğu (aynı
katalog, aynı efor, aynı Ar-Ge ve dönem kapısı), Ar-Ge düğümleri (aynı ağaç). Bugün rakipte çalışan, hat kademesi, Ar-Ge
durumu yok; iki ayrı model var ve kayıtlı çıkış tablosundaki üç ERP rakibi girişimdir, dev ve yerleşikler yoktur
[K §4.1, V #19].

Kural aynı, **karar tarzı** farklı (FM'de AI yöneticilerin tarzı farklıdır ama kuralları aynı sanılır [B1-S8, S11]):

| Tür | Başlangıç (2012) | Odak | Ar-Ge | Dönem hattına | Not |
|---|---|---|---|---|---|
| Dev (Datenwald, 1988) | Çoğu modülde dönem tavanında | Geniş: bütün modüller ve profiller | Orta | İlk şirket K1 çıkardıktan ~1 yıl sonra başlar | Çok hesap → yüksek bakım payı (aynı kural) |
| Yerleşik (Pythia, Werktag) | Orta | 1-2 profil | Orta | Orta | |
| Girişim (Ardenna, Tacita, Raketenhaus, Sumpter, Thymeworks) | Düşük | Dar | Yüksek | Erken | Kasa biterse satın alınır |

Dayanak: devin yeni modele geç ve yavaş dönmesi gerçek: NetSuite bulut suiti 1999-2002, SAP'ın bulut KOBİ ürünü ByDesign 2007
[A1-S37, S10, S4]; Oracle Fusion 2005 duyuru, 2011 çıkış [A1-S30, S31]. Girişimin devle yarışı yeni modelle ve açıklıkla oldu
(NetSuite, Odoo; ikisi de 10+ yıl) [A1 §6]. Satıcılar çöker ya da satılır (Baan 700 → 135 M$, PeopleSoft'ta 11.000'den 6.000
işten çıkarma, Nebim → Param, Mikro → TeamSystem) [A1-S29, S28, S21, S22].

**Kart seçme kuralı** (tek ve küçük; Motorsport Manager'da AI'nin kendi bütçesini bozması rakibi dondurdu [B1-S17]):
1. Kendi hesaplarının şartlı modülleri, 2. odak modüllerinde standarda yetiş, 3. odak modüllerinde lider olmaya çalış,
4. dönem hattı ve Ar-Ge düğümü (tarzına göre), 5. genişlik. Kasa yetmiyorsa işe almaz; maaş geliri aşarsa küçülür (oyuncunun da
tabi olduğu kural). Rakip oyuncunun iç durumunu (kasa, ekip, hesap listesi) görmez; yalnız yayınlanmış sürümleri görür [B1-S20
dersi]. Rakip de aynı satış, fiyat (§5.6) ve atama kurallarına tabidir.

### 8.2 Faz D'ye bağımlılık

Rakiplerin "aynı kart listesiyle çalışması" Faz D'nin atama kuralını okur. D'nin durumu: atamayı sistem yapar, elle atama yok
(Erdem 18-A, 2026-10-21); atama proaktif ve reaktiftir, sprint düzeyinde ileriye bakar, kart bitince yeniden dağıtır (Erdem 25).
D'nin atama tasarımı taslağında kartın kadro tavanı aşamanın ihtiyacına bağlı: ⌈ihtiyaç ÷ 8⌉, en az 1 (`d_taslak/ATAMA/A4_TASARIM.md`
§1). Rakip kişileri tek tek taşımaz; ekip toplamı aynı kadro tavanıyla çalışır. Sim 6 kişilik sabit yer tutucuyla koştu; geç
kademelerde bağlayıcıydı (hatta haftada en çok 9 puan) [SIM1 §8]. D'nin kuralı büyük kartta daha çok kişiye izin verirse geç
oyunda standart sim'den hızlı yürür; SIM3'te bu geç oyunda görünmedi (standart aynı), ama aşama payı ≥ 0,5'te devin 2015 doygunluğunu eşiğin üstüne itti (§13.4 madde 7). Uyarı: devredilen katmanın kuralı görünmezse "neden çalışmıyor" sorusu doğuyor
[ATAMA-A1 §0 madde 3]; rakibin kart seçme kuralı da haber satırında okunur olmalı.

### 8.3 Oyun ölçeği

Dev, SAP'ın gerçek boyutu değildir (SAP 2024: 37.590 Ar-Ge FTE [A1-S5, V #4]); "bu pazardaki ERP takımı"dır. Sim'in rakipleri
oyun ölçeğinde: dev 18 geliştiriciyle başlar, 30'da durur; iki yerleşik 6 → 15; beş girişim 1,5 → 12 (±%15 tohum payı) [SIM1 §2,
WORKING]. Devin "yüksek başlar, geçmesi uzun sürer" hissi takım boyundan değil yüksek başlangıçtan, genişlikten ve bakım yükünden
gelir: sim'de dev 2030'da ~9.000 hesap taşıyor ve 45 puanlık haftasının ~32'si bakıma gidiyor [SIM1 §6.2 hesap].

**KARAR (Erdem 9):** dev geç oyunda geçilebilir (oyunun amacı); erken oyunda geçmek çok zor, hatta imkânsız. "Geçmek" iki
katmanlıdır: ürünle geçmek (bir modülde devin önünde olmak, modül ödülü) daha erken gelir; asıl hedef yıllık raporun "en büyükler"
listesinde devin önüne çıkmaktır (§6.5, §16). Sim: güçlü botların 2012-2017'de herhangi bir modülde lider olduğu koşu payı %3 ✅;
2030 sonunda güçlü botların %77'si hatların yarısından çoğunda ürünle devin önünde ama pazar payında değil (oyuncu %16, dev %25 kural
adaylarıyla; yılda %12 el değiştiren pay 2030'a yetişmiyor) ❌. Devin eski çekirdeğinin 2027'de ihaleye çıkması bunu %20'ye, pay devrini
%20 ve ihale payını %50 yapmak %35'e (2035'te %52) çıkarıyor, yine 2030 için ❌ [SIM3, SIM_RAPOR_2 §1, §5]. Açık kapı (§13.4).

### 8.4 Oyuncunun öne geçme yolları (Erdem K2)

| Yol | Mekanik | Kanıt |
|---|---|---|
| Hız ve verim | Ekip, PM, Ar-Ge'nin efor indirimleri (ör. `design_system` tasarım hattında −%20 [K kod: `RND_DESIGN_EFFORT_MULT`]) | Sim: verimli bot 2030'da devi 19 hattın 15'inde geçiyor [SIM1 §6.1] |
| Odak | Daha az modülde derinlik; dev geniş olduğu için modül başına yavaştır | Sim: odaklı bot 2030'da devi 19 hattın 8'inde geçiyor, sektör listesinde yılların %64'ünde ilk üçte [SIM1 §6.1, SIM2 §4.3] |
| Satış | Yıldızlı satışçı büyük hesabı açar; bir üst kuralı (§5.4) | [A2-S6, S11] yön |
| Destek | Memnun 3★+ hesap bir adımlık açığı istek olarak söyler, şart değil (§7.1) | [A2-S25] yön |
| Ar-Ge öncülüğü | Dönem hattında herkes sıfırdan başlar; ilk K1 sürümü "öncü" haberi alır; o hat bir süre yalnız sende olduğu için onu isteyen 4★-5★ aday seninle konuşur; Ar-Ge düğümü tavanı erken yükseltir (§3.3) | NetSuite bulut örneği [A1-S10]; OpenTTD prototip: erken uygulayan riski alır (ilk sürüm daha çok hata), geç kalan olgun ürün alır [B2-S18] |
| Ödül | Bir modülde ödül alan 12 ay o modülü isteyen adayları daha sık görür (§6.5) | [R3-S21] yön |

Öncü riskinin kuralı zaten var: yeni kodun hata terimi büyük eforla büyür [K §6 madde 2]; ilk dönem kartı daha çok hata
taşır, yeni sistem gerekmez. Sim'de öncü bot dönem hatlarının yalnız 1-2'sinde (7'den) ilk K1'i alıyordu; "yeni dönem hattı en yüksek öncelik" politikasıyla büyüyen takımla 6 hattan 3,5'inde
(%63; teknoloji hatlarında %71) ilk, devin ilk olduğu teknoloji hattı %0; mevzuat hatlarında dev ilk (%35) (§13.4 madde 9) [SIM3].

**Bilinen yol** (pazarda yapılmış kademenin herkese ucuzlaması) şimdilik yok (Erdem 31: "güzel fikir ama uygulaması zor"); ileride
Ar-Ge düğümü adayı.

### 8.5 Pazar havuzu

Profil × yıldız başına hesap sayısı (veri, yıla göre büyür; ERP kullanımı küçükte %38, büyükte %86 [A2-S18]). Her şirketin
payı çekime göre (ürün seviyesi ile standardın farkı + satış gücü). **Toplam korunur**: Startup Company'de sınırsız dinamik
rakip 10 milyar ve negatif kullanıcıya gitti, geliştirici rakipleri dondurdu [B1-S22]. Rakip hesapları sayıdır, varlık değil.
Kaybedilen aday ve ayrılan hesap adlı bir rakibe gider; kazanılan hesap adlı bir rakipten gelir ("Pythia'dan geçti") [GÖRÜŞ].
Bugünkü `MARKET_TOTAL_MRR := 1_500_000` (`rival_catalog.gd:144`) 50 kişilik bir oyuncunun gerçekçi cirosuyla çatışır (§11.3):
havuz yılla büyümeli (ERP pazarı 2023'te 45 → 51 milyar $, arama özeti [A1-S38]; ARTW'ye göre 2024'te 132,2, 2025'te 145,6 milyar $,
farklı tanım [S1-S23, S1-S24]). Sim'in havuzu 2012'de 12.000 hesap, yılda %6 büyür; hesapların yılda %12'si çekime göre şirketler
arasında el değiştirir [WORKING, SIM1 §2]. Pazar parçalıdır: gerçekte ilk 10 satıcı payın üçte birine yakınını tutar [S1-S24].

### 8.6 Giriş ve çıkış

Kasası biten girişim satın alınır (haber); dönem açılışlarında yılda 0-1 yeni girişim [WORKING]. Rakip listesi sabit kalınca pazar
kurur (Software Inc.: "2009'da 5 şirket kaldık" [B1-S25]).

### 8.7 Başarım maliyeti

Rakip başına haftada bir adım: ~19 hat taraması ve kart ilerlemesi; sim'de 8 rakip haftada ~55 işlem, bir dünya 0,08 sn
[SIM1 §7]. Bugün `advance_all` her tikte 8 × 13 alt tür rakibi dolaşıyor; 330 hesapta gece tiki 133,6 ms, kapı 148,2 ms
[K §4.2 madde 9]; C1 commit'inde gece tiki 146,36 ms, marj 1,84 ms; modül bazlı uyum hesabı her tik her hesapta koşarsa kapıya
çarpabilir (ölçülmedi) [K2 madde 17]. **Benim kararım:**
yalnız oyuncunun ürün alt türünün rakipleri tam koşar, öbürleri bugünkü değer eğrisinde kalır. Kesin ölçüm kodda
`--tick-probe=<hız>:accounts=330` ile.

### 8.8 Ne silinir

Model A'nın kalite boyutları (`COMPOSITE_AXES`, `QualityModel.grow`, `TIER_ASYMPTOTE`) ve Model B'nin sabit çıkış tablosu
(`rivals.json` 11 çıkış) tek modele iner; `VCPitchSystem._rival_ahead` (hep true) gerçek karşılaştırmaya bağlanır
[K §4.1, §4.2 madde 5]. B2C türlerinin (not aracı, video) rakipleri bugünkü modelde kalır (benim kararım; aynı şirket modeli
B2C'ye sonra).

### 8.9 Oynanış merceği

| Soru | Cevap |
|---|---|
| Karar | Odak ve öncülük: hangi modülde yarışayım, hangi dönem hattına ve araştırmaya erken gireyim |
| Sıklık | Haber haftada en çok bir satır; öncülük kararı dönem başına bir; rapor yılda bir |
| Tek satır | Haber satırı; kayıpta rakibin adı; yıllık raporda sıra |
| Hile algısı | Her rakip hamlesi ve her kayıp adlı; rakip iç bilgini görmez |
| Hüküm | Tut. Dev erken geçilmez, geç geçilir (Erdem 9); bilinen yol yok (Erdem 31) |

---

## 9. Dönem ve tavan (kapsam 7)

### 9.1 Dönem tablosu (veri dosyası, ör. `data/market/eras.json`)

Satır: yıl (± pay), tür (mevzuat / teknoloji / pazar), açtığı (kademe, hat ya da Ar-Ge düğümü), kime şart olur (yıldız eşiği),
duyuru yılı, haber anahtarı. Bugün ürün, kart ve Ar-Ge'de yıl kilidi **yok** [K §3.3]; `ai_engine` düğümü 2012'de açık.
**KARAR (Erdem 28): oyun 2030 sonunda biter**; içerik geliştikçe süre artabilir ya da azalabilir; demo 2030'u görmez.

| Yıl | Tür | Açılır | Şart kime | Dayanak |
|---|---|---|---|---|
| 2012 | başlangıç | Modüllerde K1-K3, platform K1-K2 | yok; e-Fatura ve e-Defter gönüllü (2013-2014'te yalnız dar gruplara zorunlu: madeni yağ, ÖTV III zinciri; oyunda yok sayılır) | [V #2]; bulut 2012'de "fark yaratan", oyuncu zaten SaaS (Panorama 2015: SaaS payı %4 → %33 [A1-S34], V açamadı #21) |
| 2014 | teknoloji | Modüllerde K4; Mobil uygulama hattı | yok | mobil ERP kilometre taşı bulunamadı [A1 §2 BOŞLUK] (varsayım A3) |
| 2015 Haziran duyuru, 2016 Ocak | mevzuat | Fatura'da e-Belge kademesi; Ar-Ge'de e-Belge düğümü | 3★ ve üstü (≥10 milyon TL hasılat) | 454 sayılı tebliğ [V #2, Grant Thornton ve KPMG özetleri, Orta-Yüksek] |
| 2016 | teknoloji ve pazar | K5; devin "yeni çekirdek" duyurusu (haber) | yok | S/4HANA 2015 [A1-S2] |
| 2016 Nisan duyuru, 2018 Nisan | mevzuat | Güvenlik ve Yetki'de veri koruma kademesi; Ar-Ge düğümü | herkes (sektöre özgü erken tarih yok, §3.2) | KVKK 6698 [A1-S27, A3-S14 Yüksek]; GDPR 2016/2018 [A1-S26] |
| 2018 | teknoloji | K6; YZ birinci dalga: "Akıllı otomasyon" hattı ve Ar-Ge düğümü, ilk kademe düşük kazançlı (dalga sayısı açık soru, §3.3) | yok | SAP Leonardo Mayıs 2017, Oracle Ekim 2017, NetSuite Nisan 2018, Dynamics 365 AI Eylül 2018 [R3-S7, R3-S9, R3-S11, R3-S12]; Business Central Nisan 2018 [A1-S11] |
| 2018-2022 | mevzuat | e-Belge eşiği iner | 2★ (2019), 1★ (2022) | 3 milyon TL ve e-ticaret 500 bin TL eşikleri [V #2: Paraşüt, Düşük-Orta] |
| 2019-2020 | teknoloji | Entegrasyonlar'da API ve pazar kademesi (hat ve Ar-Ge düğümü); Mobil ve Erişim'de uzaktan çalışma kademesi | yok | kaynak bulunamadı [A1 §2 BOŞLUK] (varsayım A3) |
| 2020 | teknoloji | Akıllı otomasyonun ikinci kademesi (ürünlerin olgunlaştığı yıl; Erdem'in "2020 civarı" örneği) | yok | [R3 §B1 GÖRÜŞ] |
| 2020-2030 | teknoloji | Modüllerde yaklaşık iki yılda bir yeni kademe (K7 2020 … K12 2030) | yok | Çıtalar 2-3 yılda bir: SAP iki yıllık büyük sürüm döngüsü 2023 [A1-S8]; "18 yılda 6-8 büyük çıta" [A1 §8 GÖRÜŞ] |
| 2023 | teknoloji | YZ ikinci dalga: "YZ yardımcısı" hattı (herkes sıfırdan) ve Ar-Ge düğümü | yok; ~2027'de 5★ için standart | Copilot Mart 2023, Joule Eylül 2023 [B-S17, B-S18, A1-S8]; benimseme başta düşük [A1-S35] |
| 2026-2027 | mevzuat | Fatura'da e-Dönüşüm genişlemesi: e-Fatura parasal sınırı kalkar (2026), e-Arşiv tam zorunlu (2027) | 1★ dahil | Sovos takvimi [Y-S15, Düşük-Orta]; 2028 sonrası Türkiye adımı bulunamadı |
| 2027 | pazar | Devin eski çekirdeğinin desteği biter: büyük hesapları yeniden ihale açar (fırsat penceresi) | yok | ECC ana bakım sonu 2027, uzatılmış 2030 [Y-S11, V2 #18] |
| 2027 Aralık | mevzuat | Güvenlik ve Yetki'de siber dayanıklılık kademesi | 3★ ve üstü [WORKING] | AB Siber Dayanıklılık Yasası tam uygulama 11 Ara 2027 [Y-S3] |
| 2027 Aralık, 2028 Ağustos | mevzuat | YZ hattında uyum kademesi (işe alım ve performans YZ'si: İK) | YZ hattını kullanan 3★ ve üstü [WORKING] | AB YZ Yasası yüksek risk yükümlülükleri 2 Ara 2027, Ek I 2 Ağu 2028 [Y-S2] |
| 2028 | teknoloji ve öngörü | K11; isteğe bağlı üçüncü YZ dalgası (ajan YZ) | yok | Gartner: 2028'e kadar kurumsal yazılımın %33'ü ajan YZ içerecek; projelerin %40'ından fazlası 2027 sonuna kadar iptal [Y-S17] |
| 2028 Temmuz, 2030 Temmuz | mevzuat | Fatura'da tek KDV kaydı (2028) ve sınır ötesi gerçek zamanlı e-fatura raporlaması (2030) kademeleri | 3★ ve üstü [WORKING] | AB ViDA [Y-S1, V2 #17] |
| 2030 sonu | bitiş | Tablo biter; sonun tasarımı ayrı iştir (§12 mercek) | | OpenTTD 2050'de yeni teknolojiyi keser, oyun sürer [B2-S18, V #14] |

Teknoloji satırlarına ±2 çeyrek pay [WORKING] (OpenTTD tanıtım tarihine 0-511 gün ekler, ilk iki yılda eklemez [B2-S21,
V #14]); mevzuat satırları sabit ve önceden duyurulu (gerçek dünyada da öyle [A1 §3.2]). Mevzuat Türk ve AB takviminden alınmıştır;
oyunun ülkesi parodi bir dünya olduğu için "e-Belge yasası", "veri koruma yasası", "YZ yasası" gibi genel adlar kullanılır
[SIÇRAMA uyarısı; benim kararım]. 2027-2030 maddelerinin %79'u (14'te 11) önceden ilan edilmiş gerçek tarihtir; kurgu payı düşük
[Y §5.4, V2 §2 madde 3]. Yeni teknoloji gerçekte tahmin edilenden yavaş yayılır (Gartner'ın 2014 "postmodern ERP" öngörüsü hızı
abarttı; ECC bakımı 2025'ten 2027'ye, 2030'a ertelendi) [Y-S19, Y-S11]: dönem satırı "herkes bir yılda geçer" demez.

### 9.2 Tavanın uzaklığı

Dört fren birlikte: (a) dönem kilidi (Erdem K4, 27), (b) genişlik kapasiteden büyük (10 modül + 4 platform + dönem hatları),
(c) ilk kademeleri pahalı, sonrası yumuşak efor (§3.3), (d) Ar-Ge'nin tavanı şirket şirket yükseltmesi. "2020'de en çok o dönemin
tavanı" (Erdem K4) yalnız odak modüllerinde görülür; bütün modüllerde görülmemeli. Sim'de tavan 2020'den sonra kimseyi bağlamıyor:
2030'da standart K6, tavan K12 [SIM1 §0 madde 9]; yani geç oyunda baskıyı tavan değil rakip yarışı ve Ar-Ge kurar. Ağaç bitince
tekrar eden kart olmaz (Civilization VI "Future Tech" angaryası [B2-S26]); son kademeler bitiş yılına yakın açılır. Çağ sıfırlaması
yok (Civilization VII'nin çağ geçişi ve erken biten ağacı eleştirildi, Steam %51 [B2-S27, S29]): standart yükselir, oyuncunun
elindeki silinmez.

### 9.3 Süre

Bir oyun yılı 52 tik; 1×'te hafta 22,5 saniye [CLAUDE.md §6]. 1 Ocak 2012'den 2030 sonuna **991 hafta** (52 tik/yıl kuralıyla
988): 1×'te **6,2 saat**, 2×'te 3,1, 3×'te 2,1 saat (duraklamasız). Hafta 40 saniyeye çekilirse 11,0, 50 saniyeye çekilirse 13,8
saat [Y §1, V2 #19]. Demo 104 hafta, 28 Aralık 2013'te biter; oyunun %10,5'i. YZ ikinci dalgasından (2023) bitişe 8 yıl, oyunun
%42'si [Y §7]. Game Dev Tycoon'un 35 yılı oyuncu beyanına göre ~5 saat [B2-S3]; Unicorn'un bir yılı 1×'te 19,5 dakika,
GDT'ninkinin 2,3 katı [Y §1.5]. Erdem K5: takvim sıkışmaz, hafta süresi sonra kalibre edilir.

### 9.4 Oynanış merceği

| Soru | Cevap |
|---|---|
| Karar | Yeni dönem açılınca erken mi gireyim bekleyeyim mi, hangi araştırmayı bitireyim (dönem başına bir); mevzuata yetişeyim mi (duyurudan şarta 1-2 yıl) |
| Sıklık | Oyun boyunca 12-16 dönem satırı |
| Tek satır | Haber şeridi ve gelen kutusunda duyuru; ürün ekranında tavan satırı |
| Hüküm | Tut; erken doygunluk kapısı (G1) sim'de 10 modül ve iki parçalı eforla ✅ |

---

## 10. Durgunluk cezası (kapsam 8)

Bugün: sürüm çıkmazsa tek mekanik ceza ilgi sönümüdür (lead akışı ×1,3'ten ×0,8 tabanına); hata akışı sürer; beklenti zamana
bağlı değildir. Kod okumasından çıkarım: hata çıkmayan durgun üründe B2B hesapların memnuniyeti düşmüyor, yani "geliştirmesem
de olur" bugün **doğru** [K §6].

**KARAR (Erdem 11): ayrı sürüm-ritmi cezası yok; ürün eskir, memnuniyet ve ilgi düşer, o yeter.** Yeni model iki kanalı ayırır ve
ikisini de adlandırır:

| Kanal | Ne olur | Zamana mı rakibe mi bağlı | Görünür satır |
|---|---|---|---|
| **Hata** (bugün var) | Düzeltilmeyen hata, o modülü kullanan hesapların memnuniyetinden düşer (açık hata başına −0,3, tavan −20) [K §6 madde 3]; ihmal itibarı düşürür | Kendi kodun | Modül satırında açık hata; defterde "Stok'ta 6 hata" |
| **Eskime** (yeni) | Rakipler yürüdükçe standart yükselir; hesabın istediği seviyenin altında kalan modül memnuniyeti adlı satırla düşürür; 3★+ hesapta önce istek, yenilemede şart, sonra adlı ayrılma | Rakibe | "Stok 4'te kaldı, rakiplerde 5"; "Şartlı yenileme: Stok 4, istenen 5"; kayıpta rakibin adı |
| İlgi (bugün var) | Sürüm çıkmayınca lead akışı düşer | Zamana | Bugünkü sürüm yaşı rozeti |

Mevzuat şartı durgunluğu takvime bağlar ama önceden duyurulur (e-Belge 2015 duyuru → 2016 şart): gerçek dünyada da destek
bitişleri ve mevzuat yıllar önce ilan edilir [A1-S13, S6; V #11].

Neden bu biçim: eskime cezası kademeli, adlı ve standarda bağlı olunca kabul görüyor; gizli olunca "bir şey değişti, oyun
zorlaştı" (MGT2 [B2-S10]) ya da "bug mı özellik mi" (Software Inc. [B2-S15]) okunuyor; ani ve ayarsız olunca oyuncular onu
kapatan ayar istiyor (OpenTTD "Vehicles never expire" [B2-S20]; tepkinin boyutu bilinmiyor [V #14]).

Kaba zamanlama (hesap): standart bir modülde ~2 yılda bir kademe yükselirse, imzada tam standartta olan 3★ hesap (`o` = 0)
ilk yükselişte şart koşar; aynı ürüne 1★ olarak giren hesap (`o` = −2) üç yükselişe dayanır. Durgun oyuncu önce büyük
hesaplarını kaybeder: MRR'nin çoğu oradadır. Durgunluk kapısı (G4, "geliştirmeyi bırakan oyuncu kaybeder ve nedenini görür"):
geliştirmeyi bırakan kol 104 haftada B2B MRR'sinin en az %40'ını kaybeder ve kayıpların en az %95'i modül, rakip ya da ürün dışı
neden adı taşır. Sim (2015 başındaki portföy, 104 hafta, memnuniyet eskimesi açık: hat başına, adım başına 2 puan): kayıp büyüyen takımda %42,
25 kişide %41, 50 kişide %45 ✅ (eskimesiz %34 / %39 / %44); kayıpların %100'ü adlı; kaybın çoğu mevzuattan (e-Belge 2016), modül
eskimesinden az, çünkü iki parçalı eforla standart 2015-2017'de yavaş yürüyor [SIM3, SIM_RAPOR_2 §4.1].

| Oynanış merceği | |
|---|---|
| Karar | Bu modülü bırakabilir miyim (hangi hesaplar buna bağlı) |
| Görünür ve etkilenebilir | Evet: her eskime satırı, şart ve ayrılma modül adıyla, önceden |
| 1 kişi / 50 kişi | 1 kişide 1★ toleransı zaman kazandırır; 50 kişide ihmal edilen modül birden çok hesabı birlikte şarta sokar |
| Hüküm | Tut |

---

## 11. Ölçek, kaçak büyüme, ölü bölge (kapsam 9)

### 11.1 Ölçek tablosu (beklenen, [WORKING])

| Ekip | Hesap | Modül | Haftalık ses | Rakip ilişkisi |
|---|---|---|---|---|
| 1 | 1-5 (1★) | 2-3 | İstek yok (1★-2★ istemez); ayrılma özette | Girişimlerle aynı katta |
| 3 | 5-15 | 3-4 | İstek yok; ilk eskime satırları | Bir modülde standarda yetişir |
| 6 | 15-40 (1-2★, ilk 3★) | 4-5 | Yılda 0-2 istek, ilk şartlar | İlk şartlar |
| 12 | 40-100 | 5-6 | Yılda ~2-5 istek | Yerleşiklerle yarış |
| 25 | 100-250 | 6-8 | Haftada ~0,1-0,2 | Dev'le odak modülde yarış; ilk modül ödülleri |
| 50 | 250-600 | 7-10 | Haftada ~0,3-0,6, kart sprint başına ≤ 3 | Liderlik, öncülük, "en büyükler" yarışı |

Ses sütunu §7.2'nin karışımıyla (hesap); sim 330 hesapta haftada ortalama 0,13-0,55 müşteri maili ölçtü [SIM1 §5.3]. Kural her
ölçekte aynı: istek ihtimali hesap başına, şart modül başına, mail haftalık bütçeyle. Ölçek kapısı (G10, "kural 1 kişide de 50
kişide de aynı oranla işler"): aynı ekip gücündeki oyuncuda hesap başına istek ve şart oranı ölçekler arasında ±%30 içinde kalır.
Sim: ölçekler arasında istek %25, şart %24 sapıyor ✅; ekip kolları arasında %73 ve %128, çünkü güçlü ekip standardın önünde kalıp
daha az şart, daha çok 3★+ (dolayısıyla istek) görür. Bu kuralın doğasıdır, kırılma değil: oran ekibin kapasitesinin
genişliğe oranını izler [SIM2 §1, SIM1 §4.2; §16].

### 11.2 Kaçak büyümeye karşı

- **Oyuncu**: öne geçtiği modülde bile dönem yeni kademe açar ve rakipler gelir; 5★ daha çok modül ister (genişlik); hata yükü
  hesap sayısıyla büyür (aynı kural); genişleme isteği kapasite yer. Football Manager'da "11 üst üste şampiyonluk sıkıcı"
  [B2-S39]: geç oyunda yeni ihtiyaç sürekli gelmeli. Ürün dışı ayrılma düşük olasılıkla küçük hesapları ara sıra eksiltir (§4.4).
- **Rakip**: havuz korunur; işe alım kasaya bağlı; kasa biterse satın alınır; negatif ya da sınırsız sayı yok (havuz kapısı G8,
  sim'in kollarında 0 ihlal ✅ [SIM3]). Sim'de rakip ekipleri 2026'da tavanlarına varıyor ve geç oyunda büyümüyor. Rakip ekip tavanı
  gelire bağlandı (SIM3: hesap × 2.200 $ × 12 × %35 ÷ 2,07 milyon $): yalnız gelire bağlanınca girişimler (460 hesap = 2 geliştirici) ürün
  çıkaramıyor ve standart donuyor (N=5 ve 7'de K2, N=10'da 2030'da K5,5); eski tavan alt sınır kalıp gelir yalnız yukarı bağlanınca dev
  30 → 34 (2030) / 47 (2035) oluyor ama standart (sekiz rakibin üst medyanı) değişmiyor. Geç oyun baskısı kasadan değil girişim ve
  yerleşiklerin gelişiminden gelir; girişimler için dışarıdan fon (VC) ayrı bir sabit olur (SIM_RAPOR_2 §4.5).

### 11.3 Ölü bölgeye karşı

- **Oyuncu geride**: 1★ hesap S − 2'ye razı; K1-K2 ürünle her yıl satılabilecek 1★-2★ aday bulunur (ölü bölge kapısı G9). Sim ❌: geride
  kalan oyuncu (2015'te duran ürün) 2022'den sonra yılda 0 kazanılabilir 1★-2★ aday görüyor, tek kurucu 2026-2028'den sonra 0 (standart
  yürüdükçe S − 2, K2'yi aşıyor). 1★ hesabın beklentisine mutlak üst sınır K2 konursa tek kurucuda yılda 9-13 aday kalıyor, durgun
  oyuncuda yine 0; G4 kaybı değişmiyor (SIM_RAPOR_2 §4.8); karar Erdem'de. Girişimler de altta.
- **Rakip geride**: satın alınır, haber olur; havuz bozulmaz.
- **Ekonomi** (önerilen fiyatla, standart duruş ve standart kalite, bant orta noktaları; hesap): 1★ 6,5 koltuk × ~39 $ ≈ 250 $,
  3★ 65 koltuk × ~57 $ ≈ 3.700 $, 5★ 650 koltuk × ~84 $ ≈ 55.000 $ aylık MRR (§5.6'nın örnek fiyatları). Tek bir 5★ hesap seed
  kapısını (20.000 $, `seed_constants.gd` `DOOR_MRR`) aşar; Erdem 30 bunu sorun saymaz, 5★ demoda çok zordur (Erdem 5). Sim'de
  eski düz fiyatla 5★ MRR medyanı 19.000-23.200 $, 5★'ların %45-71'i tek başına seed kapısını aşıyordu [SIM2 §1, §4.4]. Sunucu
  payı: 650 koltuk = 13 Standart birim × 120 $ = 1.560 $, MRR'nin ~%3'ü (hesap; Karar 2'nin fiyatı).
- **Gelir/çalışan gerçeği**: SAP ~319 bin €, NetSuite ~161 bin $, Odoo ~128 bin € (hesap) [A1 §5; SAP ve NetSuite V #4, #5
  ile doğrulandı]; 50 kişilik bir şirket için yıllık 6-16 milyon, aylık ~0,5-1,3 milyon (hesap). Havuz bunu taşıyabilmeli
  (§8.5).

### 11.4 Simülasyonun söyledikleri (SIM_RAPOR_1 ve 2'den, kısa)

Uydurma dünya: 8 rakip (1 dev, 2 yerleşik, 5 girişim) ve oyuncu botu 2012'den haftalık yarışır; 20 tohum; SIM1 5.040 oyuncu
koşusu. Sayılar biçimi gösterir, kalibrasyon değildir. Ayrıntı ve açık işler §13.

1. **Kodun bugünkü kademe eforu doygunluk üretir**: rakipler standardı 2015-2027 boyunca dönem tavanına yapıştırıyor; düz ×8 efor
   medyanı tavandan ayırıyor ama tek kurucunun ilk K1'i 4 haftadan ~29 haftaya çıkıyor [SIM1 §3.1, §4.1].
2. **İki parçalı efor ve 10 modül birlikte çözer**: 10 modülde dev 2015'te hatlarının %59'unda tavanda (eşik %60), tek kurucunun ilk
   K1'i ~4 hafta; 5 ve 7 modülde %77-82 ❌ [SIM1 §4.1].
3. **İstek birikimi kuraldan gelir**: "bir üst seviye" isteğiyle sprint başına 8-10 bekleyen modül kartı; "yalnız pazardaki
   seviye" kuralıyla 3-4 [SIM1 §4.2, SIM2 §1].
4. **Satış zarı formülü tutarlı**: eşleşen satıcı ve tam uyumda 1★ %91,4, 5★ %49,8; bir yıldız alttaki satıcı 0,59-0,61 kat
   [SIM3, SIM_RAPOR_2 §1].
5. **Koltuk ve yıldız bantta**: koltuk değişen yenileme %21-30, yıldız değişimi en çok %3,8 [SIM3, SIM_RAPOR_2 §1].
6. **Dev**: erken geçilmiyor ✅ (koşuların %3'ü); 2030'da güçlü botların %77'si hatların yarısından çoğunda ürünle önde, ama
   pazar payında geçilmiyor (oyuncu %16, dev %25) ❌ [SIM3, SIM_RAPOR_2 §1].
7. **Durgunluk eskimeyle bağlandı**: memnuniyet eskimesi açıkken geliştirmeyi bırakan oyuncu 104 haftada MRR'nin %41-45'ini kaybediyor
   (hedef ≥ %40) ✅; eskimesiz %34-44 idi [SIM3, SIM_RAPOR_2 §4.1].
8. **Demo**: büyüyen takımla ilk 104 haftada 5★ kapatan tohum %0 ✅; 4★ satışa yatırım yapan ekiple %35-55 [SIM3, SIM_RAPOR_2 §4.2].
9. **Geç oyun durgunluğu**: rakip ekipleri 2026'da tavanda, standart yılda ~0,25-0,3 kademe yürüyor; 2030'da standart K6-7, tavan K12;
   Ar-Ge +1 tavanı ve gelire bağlı yukarı kasa bunu değiştirmiyor [SIM3, SIM_RAPOR_2 §4.5].
10. **Modelde hâlâ olmayanlar**: ayrı Ar-Ge araştırma kuyruğu (Ar-Ge tavanı premium efor olarak modellendi), B2C, girişim fonu, D'nin
    kadro tavanının gerçek birimi (aşama payı varsayımı 0,5) [SIM_RAPOR_2 §6].

---

## 12. Pre-mortem (kapsam 10)

**Varsayım:** model kodlandı. Haziran 2027 kapalı oyun testinde açıkça başarısız oldu: oyuncular 2016-2018 arasında bıraktı,
Steam demo yorumlarında "her yıl aynı şart mailleri, Datenwald hep önde" yazdı.

**Yol 1 (kanıtı vurur): standardın hızı kanıtsızdı ve takvime döndü.** Standardın gerçek dünyadaki sayısal büyümesine dair
kaynak yok [A1 §4 BOŞLUK]; koltuk bantları, kapanış oranları, yenileme değişimleri türetme [V #20]; sektör matrisi tek
yayıncıdan [V #13], 9 profilin 90 hücresinin 43'ü varsayım [V2 #22]. Sim'in gösterdiği doygunluk oyunda da oluşur: kodun
bugünkü eforuyla rakipler dönem tavanına erken varır, standart tavana eşitlenir, oyuncu hiçbir modülde "önde" olamaz ve her yeni
kademe açılışında bütün 3★+ hesaplar aynı anda şart koşar. Sim bunu 10 modül ve iki parçalı eforla kapattı (§11.4); Ar-Ge +1 tavanı G1'i bozmadı, D'nin kadro tavanı birim eşlemesine bağlı
(aşama payı 0,5'te dev 2015'te %62, eşik %60; 0,35'te geçiyor). Büyüklük: dönem açılış yılında 3★ hesapların yarısı şartlı.
- En erken uyarı: erken doygunluk kapısı (G1); eşik: 2014 sonrası üst üste iki yıl modül medyanı tavana eşitse ya da dev hatlarının
  %60'ından fazlasında tavandaysa model yeniden ayarlanır.
- Önlem: Ar-Ge tavanı ve kadro tavanı sim'e eklendi ve G1 yeniden koşuldu (§13.4); rakip kapasitesi, efor eğrisi ve dönem
  açılımı tek veri dosyasında.

**Yol 2 (aktörün tepkisi): oyuncu ve içerik üreticisi rakibi hile, kaybı keyfî okudu.** Football Manager'da sonuçların önceden
yazıldığı iddiası geliştiricinin yalanlamasına rağmen sürdü [B1-S10]; Big Ambitions'ta rakip kârı 7 kat çıkınca geliştirici
hatayı kabul etti [B1-S5]; tersi de var: pasif rakip geç oyunu kolaylaştırdı (Software Inc. [B1-S27]). İçerik üreticisinin
cümlesi: "Datenwald'ı 10 saatte hiçbir modülde geçemedim" ya da "durgun ürünle 2 yıl oynadım, hiçbir şey olmadı".
- En erken uyarı: Erdem'in ilk 2 saatlik oynamasında bir kaybın nedenini ekrandan söyleyemediği an (eşik: tek bir adsız kayıp
  hatadır); dev kapısında (G2) güçlü botun 2026-2030'da "en büyükler" listesinde devin önüne hiç geçememesi (bugün öyle: %0-15).
- Önlem: her kayıp, şart, eskime satırı ve rakip hamlesi modül ve rakip adı taşır (adsız satır yazılamaz kuralı); "rakipler
  senin iç bilgini görmez" cümlesi yardım metninde; yıllık raporun kuralları yardım metninde; G2 ve G4 kapıları.

**Yol 3 (bağımlılık ve içerik): içerik taştı, kod aynı anda çok yeri değiştirdi.** 10 modül × K12 = 120 modül kademesi: 250 CSV
satırı (her biri TR ve EN, iki ayrı yazım; ~1.600 TR ve ~2.250 EN sözcük) [K2 §2.3]; platform hatları K12'ye uzarsa +72 satır;
`TIER_MAX` küresel kalırsa öbür iki ürün türü için +252 satır (hat başına kademe sayısı değişken yapılırsa 0) [K2 §2.2]; rakip
sürüm haberleri ve 2027-2030 dönem haberleriyle toplam ~736 dizge [Y §6]; 9 profil, YZ dalgaları, rapor ve ödül metinleri
(~45-60 satır) [K2 §2.4]. Bunlar Erdem'in tek metin turunu (Karar 30) taşırır; aynı dönemde kayıt şeması 19 (C3a), yıldızın 5'e
çıkışı (~30 nokta [K §2.4]), `TIER_MAX`, `EFFORT_BANDS` ve `IDENTITY_*` doğrulayıcıları ve GDD'nin "9 hat × 3 kademe = 27" mührü
[K2 §2.5], rakip modelinin birleşmesi [K §4] ve D'nin atama kodu.
- En erken uyarı: C3b ya da C5 kod adımı başlarken modül adları ve kademe metinleri yok; eşik: sim kapıları geçti ama metin
  taslağı yok → kod bekler.
- Önlem: kademe adları şablonla başlar ("Stok · 2016 sürümü"); metin turu ayrı; bugünkü Stok ve Fatura'nın 3 kademe metni
  kalırsa 14 satır düşer [K2 §2.2].

**Yeni kararların riskleri:**
- **İki parçalı efor demo temposunu bozar (ölçüldü, ❌).** Sim'de K3 bugünkünün ~10 katı; Erdem "biraz" dedi. İlk 104 haftada 3 kişilik
  ekip hiçbir modülde, 6 kişilik ekip 1-4 modülde K3'e varıyor; hepsi 7 modülde K2'de. "Hiçbir şey açılmıyor" hissi riski gerçek. Ölçüm:
  kurucu ve 3-6 kişilik ekip ilk 104 haftada kaç modülde K3'e varıyor. Önlem: eğri tek veri dosyasında; K2-K3 adımı yumuşatılır, doygunluk 10 modülün
  genişliğine ve rakip ölçeğine bırakılır.
- **Önerilen fiyat tek doğru cevaba döner.** Software Inc'te önerilen fiyat kopyalandı [F2-S3]. Oyuncu her teklifte "standart"a
  basıyorsa fiyat bir karar değildir. En erken uyarı: sim'in fiyat kapısı (bir duruş tohumların %80'inden fazlasında en yüksek
  MRR'yi veriyorsa) ve playtest'te duruş dağılımı. Önlem: üç duruş, zarlı kapanış, görünür kayıp nedeni ve rakip teklifi (§5.6);
  gerekirse profil başına fiyat duyarlılığı.
- **10 modülün içerik ve ekran bedeli.** Yukarıdaki Yol 3'e ek olarak teklif paneli ve hesap kartı 10 modül çipi için yeniden
  dizilir; HESAPLAR tablosu (C8) henüz yok [K2 §3]. Önlem: modül satırı aday kartında yalnız istenen modülleri gösterir; ürün
  ekranında modüller alanlara gruplanır.

**Mercek kontrolü:**
- Kapsam ve zaman: bitiş 2030 sonu (Erdem 28); oyunun ana gövdesi bugünkü sonun (Series A, yumuşak tavan 104 hafta
  [CLAUDE.md §1, K §3.3]) sonrasıdır: Series A sonrası fon, büyüme ve son tasarlanmadı. Bu bir okyanus riskidir; bu model demo
  dilimini (2012-2013) bozmadan kurulmalı, geç oyun ayrı faz. Geç oyun boşluğu bilinen bir şikâyettir (GDT'de 20. yılda "artık
  düşünmüyorum, tıklıyorum" [B2-S3]); 2026 sonrası rakip büyümesi ve Ar-Ge düğümleri bunu taşımalı.
- Teknik: tik bütçesinde 330 hesapta 14,6 ms boşluk [K §4.2 madde 9]; rakip adımı ucuz; yenileme taraması haftalık.
- Pazar: Software Inc. %94, Big Ambitions %91 [B1 §1, §4]; farkımız gerçek ERP pazarı ve yaşayan rakip şirketler. ERP'nin
  oyuncuya sıkıcı gelip gelmediği araştırılmadı [DEĞERLENDİREMEM].
- Maliyet: C3a-C8'in yeniden yazımı, rakip modeli, dönem tablosu, Ar-Ge tavanı, fiyat ve içerik; açık sim kapıları kapanmadan
  kod başlarsa kod iki kez yazılır.

**Olumsuz Steam yorumunun tek cümlesi:** "Her yıl aynı 'şu modülü getirin yoksa gideriz' mailleri geliyor, Datenwald ne
yaparsam yapayım önde; on saatten sonra oyun bir yapılacaklar listesine dönüyor."

**En hızlı ucuz risk azaltma hamlesi (yapıldı, SIM3):** memnuniyet eskimesi ve düşük ürün dışı ayrılma (durgunluk ✅), istek ömrü 13 hafta
(istek kartı ✅); pay devri (dev geç geçilir) tek başına yetmedi (§13.4).

**Kabul edilen riskler:** gerçek dünya oranları (koltuk, kapanış, yenileme) hiçbir zaman doğrulanamayacak; hedefler oyun
hissine göre, Erdem'in oynamasıyla kapanır (Kat 2).

---

## 13. Kod öncesi simülasyon: ne koşuldu, ne çıktı, ne açık (kapsam 11)

### 13.1 Yer ve araç

- Yer: `docs/tasks/faz_cde/pazar2/sim/` (`.gdignore` ile). Tek betik `sim.py`; veri `constants.json` (her sabit değeri, kaynağı ve
  [WORKING] işaretiyle), `sim2.json` (SIM2 katmanı), `eras.json` (dönem tavanı ve dönem hatları), `modules.json` (5 / 7 / 10 modül
  kümeleri, 4 platform hattı), `rivals.json`; profil verisi `out/tur2/P_profiles.json`. `python -I`, yalnız standart kütüphane;
  aynı tohum ve ayarla çıktı bayt düzeyinde aynı. Oyun kodunu okumaz; kodun sabitleri elle aktarılmıştır. Komutlar `sim/README.md`'de,
  model yapısı ve ayar noktaları `sim/DEVIR.md`'de.
- Model: haftalık adım; 8 rakip (1 dev, 2 yerleşik, 5 girişim) ve oyuncu botu; havuz; hesaplar (yıldız, koltuk, çalışan, gidiş,
  modüller, `o`, memnuniyet); satış zarı (SIM2); yenileme, istek ve şart; yıllık sıralama (SIM2).
- Botlar: durgun, dağınık, odaklı, öncü, satışçı, verimli. Ekip kolları 1, 3, 6, 12, 25, 50 kişi ve büyüyen kol (1 → 50, 2023).
  Hesap ölçekleri 10, 100, 330, 600. 20 tohum.
- Koşular: SIM1 (erken doygunluk G1, ses yükü G5, havuz G8; resmî ayar ve iki kural adayıyla), SIM2 (satış zarı G7, dev G2,
  durgunluk G4, koltuk G6, demo, sıralama, fiyat; dört kol).
  Erdem'in 24-31 cevaplarına en yakın kol: SIM2 `aday` (10 modül, iki parçalı efor, piyasa hedefli istek, 2030 sonu). SIM3 (madde 1-10)
  2026-10-22'de koşuldu: 2 tam koşu ve 43 kısmi koşu (`sim3_*.json`), Ar-Ge +1 tavanı, kadro kuralı, rakip kasası, fiyat kolu ve G3 / G9 /
  tempo ölçüleri sim'e eklendi (varsayılan kapalı).

### 13.2 Kapılar: hedef ve bugünkü durum

Hedefler kod öncesi yazıldı, hepsi [WORKING]. Durum SIM3 (2026-10-22): `sim3_tam_aday.json` ve `sim3_tam_kural.json`, 10 modül, 2030 sonu [SIM_RAPOR_2 §1]; SIM1'den gelenler işaretli.

| Kapı | Sade anlamı | Hedef | Durum |
|---|---|---|---|
| G1 | Erken doygunluk: rakipler ilk yıllarda bütün modüllerde tavana yapışmaz, standart takvime dönmez | 2014 sonrası her yıl modül medyanı dönem tavanının ≥ 1 altında; dev hatlarının ≤ %60'ında tavanda | ✅ N=10 (dev en çok 2015'te %59); N=5 ve N=7 ❌ (dev 2015 ve 2017'de %82 / %77) |
| G2 | Dev erken geçilmez, geç geçilir (Erdem 9) | 2012-2017'de güçlü bot herhangi modülde lider ≤ %5; 2026-2030'da güçlü botların en az yarısı "en büyükler" listesinde devin önünde | erken ✅ %3; geç ❌ 2030'da %8 (kural adaylarıyla %20; pay devri 0,2 ve ihale 0,5 ile %35), 2035'te %32 (%38; %52) |
| G3 | Öncülük: yeni dönem hattına erken giren ödül alır | Öncü bot dönem hatlarının ≥ %50'sinde ilk K1; dev ≤ %20 | ✅ öncü bot "erken" politikasıyla 6 hattan 3,5'inde (%63; teknoloji hatlarında %71) ilk K1; politikasız %37 ❌. Dev: teknoloji hatlarında %0 ✅, mevzuat hatları dahil %35 ❌ (mevzuatta herkes aynı gün başlar) |
| G4 | Durgunluk görünür: geliştirmeyi bırakan kaybeder ve nedenini görür | Durgun kol 104 haftada B2B MRR'nin ≥ %40'ını kaybeder; kayıpların ≥ %95'i adlı (ürün dışı ayrılma nedeniyle yazıldığı için adlı); kaybedilenlerin ≤ %30'u 1★ | ✅ kayıp %42 / %41 / %45 (büyüyen / 25 / 50 kişi; memnuniyet eskimesi 2; kural adaylarıyla %42 / %49 / %46); adlı %100 ✅; 1★ %4 (kural adaylarıyla %12-16) ✅ |
| G5 | Ses yükü: yüzlerce hesapta angarya yok | Haftalık müşteri maili medyan ≤ 2, p99 ≤ 5; sprint başına bekleyen istek kartı p95 ≤ 3; şartlı yenileme yılda ≤ %25, durgun ve dağınık oyuncuda ≥ %5 | mail ✅ 0 / 4; kart ✅ p95 3 (istek ömrü 13 hafta + eskime); şartlı yenileme ❌ yılda %0-0,8 (alt sınır %5): hiçbir kolda doğmuyor |
| G6 | Koltuk ve yıldız | Yenilemelerin %20-50'sinde koltuk değişir; 1★'ın yıllık büyüyen oranı ≤ %10; yıldız değişimi ≤ %10; 1.000 koltuk üstü yok | ✅ koltuk %21-29, yıldız %3,6, 1★ büyüme %4,9 (gerçek dünya tutma bantları kaldırıldı: Erdem 2026-10-17 doz kuralı, §4.4; bilgi: 1★ tutma %99-100, ürün dışı üçte birle %95) |
| G7 | Satış zarı | Eşleşen satıcı ve tam uyumda 1★ %75-92, 5★ %45-60; bir yıldız alttaki satıcı eşleşenin 0,5-0,75'i; iki yıldız alt yok; %100 yok; iki kat bayat aday ≤ %5 | ✅ 1★ %91,4, 5★ %49,8; alt satıcı oranı 0,59-0,61; bayat %0,45 |
| G8 | Havuz: rakip sayıları taşmaz | Rakip ekibi 1 ile tavanı arasında; Σ hesap ≤ havuz; negatif yok | ✅ |
| G9 | Ölü bölge: geride kalan da satabilir | Her yıl K1-K2 ürünle kazanılabilir ≥ 6 adet 1★-2★ aday | ❌ geride kalan oyuncu (durgun) 2022'den sonra yılda 0 kazanılabilir 1★-2★ aday; tek kurucu 2026-2028'den sonra 0 (1★ beklentisine mutlak üst sınır K2 konursa tek kurucuda yılda 9-13) |
| G10 | Ölçek: kural 1 kişide de 50 kişide de aynı oranla işler | Aynı ekip gücünde hesap başına istek ve şart oranı ölçekler arasında ±%30 | ölçekler arası istek ✅ %21-25; şart ✅ %14 (kural adaylarıyla), ❌ %34 (kural adayları kapalı, eskime açıkken); ekip kolları arası ❌ %78-98 (kuralın doğası, §11.1) |
| G11 | Ekonomi | 50 kişide yıllık gelir, maaş × 1,5 giderinin 1,2-2 katı (tek 5★ tavanı Erdem 30 ile düştü) | ❌ masa başında: 2030, 50 kişi, ölçek 600 hesapta gelir / gider 2,0-3,2 (orta kıdem), 1,1-1,8 (hep kıdemli), 3,6-5,8 (hep junior); gerçekçi karışımda ~2,0-3,1, bandın üstü. Bant ~250-410 hesapta tutar (§13.5) |
| G12 | Maliyet | Rakip haftalık adımı raporlanır; kodda `--tick-probe ... accounts=330` kapısı (148,2 ms) | SIM1: haftada ~55 işlem, dünya 0,08 sn |
| Demo | Erdem 5 | İlk 104 haftada 5★ kapatan tohum ≤ %5; 4★ yalnız satışa yatırım yapan ekiple | ✅ 5★ %0; 4★ satış odaklı 3 kişiyle %35-55, büyüyen takımla %0-5 |
| Tempo | Erdem 27 "biraz" | Tek kurucunun ilk K1'i ≤ 6 hafta; ilk 104 haftada kurucu ve 3-6 kişilik ekip en az 2-3 modülde K3'e varır | K1 ✅ 3-4 hafta; K3 ❌: 3 kişi 0 modül, 6 kişi 1-4 modül (kapasite 2,4 / 4,5-5,7), büyüyen 0 (1,6-2,1); efor eğrisi ×3,5'a yumuşatılınca 6 kişi 4-7 modül ama G1 ❌ |
| Fiyat | Tek doğru cevap yok | Hiçbir duruş tohumların %80'inden fazlasında en yüksek MRR'yi vermez | ❌ iki turda: önerilen fiyat kolu sim'de (formül SENTEZ'in örnekleriyle tutuyor); "pahalı" duruş havuzda %66, huni serbestken %75 kazanıyor, en kötü hücre %95-100; kapanış çarpanı 1,4 / 0,65 ile havuz dengeli (%37 / %34 / %29), en kötü hücre %85 |
| Rapor | Erdem 29 | Güçlü oyuncu modül ödülünü yılların bir kısmında alır, durgun hiç almaz; küçük oyuncu "en hızlı büyüyenler"e girebilir | ödül ✅ (%25-61, durgun %0); en hızlı büyüyenler ilk üç %36-39 |

### 13.3 SIM2 ve SIM3 katmanları (onay bekliyor)

`sim2.json` SIM1 sabitlerinin üstüne şunları yazar; satış zarı Erdem 6-7'nin cevabıdır, öbürleri ayar turudur ve gerekçeleri
kayıtlı değil [SIM2 §3]: koltuk değişim eşiği max(2, %10) → max(1, %5); 2★-5★ şirket gidişi büyüyen / durağan / küçülen %30 / %45 /
%25; gidişin yeniden çekilme olasılığı 0,3 → 0,5; şart süresi 26 → 13 hafta; memnun ve düşük memnuniyet eşikleri 70 / 40 → 80 / 50;
düşük yıldızın şart koşma olasılığı 0,2 → 0,3. İlk ikisi koltuk kapısını bantta tuttu; öbürleri tek başına bir kapıyı açmadı.

`sim3.json` (SIM3, hepsi [WORKING], kaynaksız; yalnız kendi kapısını geçenler):

| Sabit | eski | yeni | Kapı |
|---|---|---|---|
| `eskime_memnuniyet` (hat ve adım başına memnuniyet puanı, yenileme kontrolünde) | 0 | 2 | G4 kaybı %34 / %39 / %44 → %41 / %41 / %45 ✅ (tur 1) |
| `istek_omur_hafta` | 26 | 13 | G5 istek kartı p95 4 → 3 ✅ (tur 1; yan etki: 26 haftalık bekleme cezası artık işlemiyor) |

Denendi, **değişmedi**: `pay_devri` 0,12 → 0,2 ve `dev_ihale_payi` 0,3 → 0,5 (G2 geç hâlâ ❌, 2030'da en çok %35); kadro kuralı "d"
(aşama payı 0,5'te G1 ❌, 0,35'te ✅; birim eşlemesi D'ye bağlı); rakip kasası; fiyat kapanış çarpanları (1,1 / 0,85); efor eğrisi
(`efor_g_giris` 4,5). Kural adayları (`urun_disi_ayrilma` üçte bir, `donem_ilk_yil_sart`, `dev_ihale_yili` 2027) sim'de kapalı, Erdem'in kararını bekliyor;
iki sütunlu sonuçlar SIM_RAPOR_2 §1'de. Ar-Ge +1 tavanı (`arge_tavan`, 2018'den, +1 kademe %150 eforla) sim'e eklendi, G1'i bozmuyor.

### 13.4 Madde madde durum (SIM3 koşuldu, 2026-10-22; ayrıntı SIM_RAPOR_2 §4-5)

Her madde için en çok iki tur; geçmeyen kapıda sabit zorlanmadı, kural seçenekleri Erdem'e (aşağıdaki "Erdem'e" sütunu).

| # | Açık | Sonuç | Erdem'e (seçenek ve etkisi) |
|---|---|---|---|
| 1 | Durgunluk kaybı, memnuniyet eskimesi | ✅ tur 1: `eskime_memnuniyet` 2 ile kayıp %41-45 | yok |
| 2 | Ürün dışı ayrılma düşük | ✅ üçte bir oranla (1★ %4,7 ... 5★ %0,7) G4 (adlı %100, 1★ kaybı %12-16) ve G6 geçiyor; 1★ tutma %95 | oran: %4,7 (tutma %95), %9,3 (%90-91), %14 (%85,5-86,6, 1★ kaybı %28-30 sınırda). Örnek: 150 1★ hesapla girilen ilk yenilemede 7 / 14 / 21 hesap "şirketimiz kapandı" der |
| 3 | Dev pazar payı | ❌ iki turda: pay devri 0,2 → 2030 %25; + ihale 0,5 → %28 (son tabanda %35, 2035'te %52) | (a) kapıyı "hatların yarısında ürünle devin önünde" yap (zaten %77, 2035'te %100), (b) pay devri 0,2 + ihale 0,5 ve 2035 (bitiş kararına, 2030'a, aykırı), (c) 5 modül (%97, Erdem 26'ya aykırı). Örnek: Ekim 2030 raporunda "en büyükler": oyuncu %20, Datenwald %23 |
| 4 | İstek kartı p95 | ✅ ömür 13: p95 4 → 3 (en kötü tohum 4) | yok |
| 5 | Ar-Ge tavanı | G1 ✅ (N=10, dev 2015 %59; etkin tavan rakipleri bağlamıyor), G2 geç %13 → %20 ❌ | yok |
| 6 | Fiyat | ❌ iki turda (§5.6 çarpanlarıyla "pahalı" baskın) | kapanış çarpanı: 1,1 / 0,85 (bugün: pahalı %75), 1,25 / 0,75 (%52 ama bir hücrede %90), 1,4 / 0,65 (havuz %37 / %34 / %29, bir hücre %85). Örnek: 2027, 12 kişilik ekip, 200 hesap: pahalı duruşta hesap %12 az, fiyat %15 yüksek; 1,4 / 0,65'te küçük ekip ucuz ya da standart, baştan 50 kişilik ekip pahalı seçer |
| 7 | Kadro tavanı | aşama payı 0,5 → G1 N=10 ❌ (dev 2015 %62); 0,35 → ✅; G2, G5, geç standart değişmedi | D'nin "aşama ihtiyacı" biriminin sim puanıyla eşlemesi (Faz D); payı ≥ 0,5 ise dev 2015'te eşiği aşar |
| 8 | Rakip kasası | gelire tam bağlama standardı donduruyor (girişimler geliri taşıyamaz); yalnız yukarı bağlama etkisiz (dev 30 → 34 / 47, standart aynı) | girişim fonu (VC) sabiti eklensin mi, yoksa kasa bağından vazgeçilsin mi. Örnek: Tacita 2024'te 460 hesapla ancak 2 geliştirici taşır, yeni modülü çıkaramaz |
| 9 | G3, G9 | G3 ✅ ("erken" öncü politikası, teknoloji hatlarında); G9 ❌ | G3: dev payı "mevzuat dahil" mi "teknoloji" mi sayılsın. G9: 1★ beklentisi S − 2 (bugün; tek kurucu 2028'den sonra 0 aday), S − 3 (etkisiz), mutlak üst sınır K2 (yılda 9-13 aday; durgun yine 0). Örnek: Mart 2029, tek kurucu, ürün K2: 1★ bakkal "faturamı kessin yeter" der mi, yoksa K6'yı mı bekler |
| 10 | Demo temposu | K1 ✅ 3-4 hafta; K3 ❌ | efor eğrisi: ×4,5 (bugün; G1 ✅, 3 kişi 0 / 6 kişi 1-4 modülde K3), ×3,5 (6 kişi 4-7, 3 kişi 0-2, G1 ❌ dev 2015, 2017, 2019), ×3,0 (6 kişi 6-7, G1 ❌ + modül medyanı tavana yakın), ya da hedef "K3" yerine "3 modülde K2" (ADAY eğrisinde 3 kişi 7 modülde K2 ✅). Örnek: Ocak 2014, 104. hafta, 3 kişilik ekip: 7 modülde K2, hiçbirinde K3 |
| 11 | 50 kişide gelir / gider (G11) | yapıldı (masa başı, koşu yok): §13.5; sonuç ❌, bant ölçek ~250-410 hesapta tutar; ölçek 600 [WORKING] değişmedi, karar bekliyor | |
| 12 | YZ dalgaları | Erdem'in cevabından sonra `eras.json` (SORU_PAKETI_3 Soru 1); kapsam dışı | |

Sonuçlar SIM_RAPOR_2'de; Erdem'e tek görsel sayfa (yardımcı yönetmen getirir).

### 13.5 G11 masa başı hesap (madde 11, yeni koşu yok)

Girdi: `sim2_sonuc_aday.json` fiyat kolu, A (tek koltuk fiyatı 50 $), `10|<bot>|50|600|2030`: 50 kişilik takım, ölçek 600 hesap,
2030 son MRR (aylık). Beş botun medyanı 1,32 milyon $, en az 0,90 (odaklı), en çok 1,42 milyon $. Gider: 50 kişilik kadro (20 geliştirici,
4 ürün yöneticisi, 6 testçi, 4 tasarımcı, 8 satışçı, 8 müşteri temsilcisi; [WORKING] karışım) × `HRConstants.SALARY_BANDS_BY_LEVEL` bant
ortası × 1,5.

| Kadro seviyesi | Maaş / ay | × 1,5 | Gelir / gider (en az · medyan · en çok) |
|---|---|---|---|
| hepsi junior | 165.000 $ | 247.500 $ | 3,6 · 5,3 · 5,8 |
| yarı junior, yarı orta | 231.000 $ | 346.500 $ | 2,6 · 3,8 · 4,1 |
| hepsi orta | 297.000 $ | 445.500 $ | 2,0 · 3,0 · 3,2 |
| %30 junior, %50 orta, %20 kıdemli | 303.600 $ | 455.400 $ | 2,0 · 2,9 · 3,1 |
| hepsi kıdemli | 528.000 $ | 792.000 $ | 1,1 · 1,7 · 1,8 |

Okuma:
- **Gerçekçi karışımda oran 2,0-3,1, bandın (1,2-2) üstünde.** Yalnız kıdemli kadro bandın içine iner. Ofis kirası (Loft 18.000 $/ay) oranı en çok 0,1-0,2
  azaltır, sonucu değiştirmez; sunucu, vergi ve işe alım gideri hesapta yok.
- **Sayı ölçeğin seçiminden gelir.** Sim portföyü 3 yılda ölçeğe çıkarıp orada tutar (SIM_RAPOR_2 §6): 600 hesap, takımın o hesapları
  işleyip işleyemeyeceğinden değil sim sabitinden gelir. Hesap başına ortalama MRR ~2.200 $ (A) olduğundan bant, orta kıdem kadroda
  yaklaşık 250-410 hesapta (gider 445.000 $ için gelir 535.000-891.000 $), kıdemli kadroda 430-720 hesapta tutar.
- **Fiyat modeli oranı yükseltir, düşürmez.** Dört kolun B'si (modül eki) 50 kişide A'nın 1,27-1,37 katı MRR verdi; SIM3'te beşinci kol
  (Erdem 30'un önerilen fiyatı, standart duruş) 50 kişide, ölçek 600'de A'nın 1,58-1,66 katı çıktı, yani gerçekçi karışımda oran ~3,2-5,0'a çıkar.
  Talebin fiyata duyarlılığı modelde yalnız kapanış çarpanı.
- **Zaman:** 2020'de aynı takım ölçeğinde MRR 0,96-1,08 milyon $ (orta kıdem kadroda oran 2,2-2,4): açık yalnız son yıllarda değil baştan var.

Sonuç: G11 ikinci yarı ❌ ve bu bir **kalibrasyon girdisi**, ayar değil: ölçek sabiti (600) ya da fiyat tabanı (P0 30 $, koltuk 50 $) tek başına
bandı tutturur. İkisi de [WORKING], sim gerektirir (kapanış koşusu onayına bağlı). **Hiçbir sabit değişmedi.** Faz C'nin E2'sinde bakılacak şey:
gerçek oyunda 50 kişilik takımın kaç hesabı işleyebildiği (müşteri temsilcisi kapasitesi); bu sayı 250-410'a yakınsa 600 ölçeği yanlış, yüksekse
fiyat tabanı yüksek.

---

## 14. Faz Q, C, D ve Ar-Ge'ye etkisi (kapsam 12)

### 14.1 Faz Q (kod `main`'de)

| Q'nun işi | Durum |
|---|---|
| 2012 takvimi (K10) | **Aynı kalır**; dönem tablosu ona dayanır |
| CSV temizlikleri (K11, K12), outsource kaldırma | Aynı kalır |
| Alan tabanlı beklenti: `ProductQuality.TABLE` (sektör → alan ağırlığı), `CORE_2` (1,25), `EMPHASIS_*`, `market_ref`, `CLOSE_CURVE`, `loss_area`, `account_fit` | **Yeniden yazılır**: modül tabanlı uyum (§5.2) ve göreli konum (§4.2) |
| Ürün sayfasının sözcükleri (Zayıf / Yeterli / Güçlü) | Ürün sayfasında sürekli modül sözcüğü yok (Erdem K1, 29); sözcükler yıllık raporun modül satırında ve müşteri cümlesinde yeniden kullanılabilir |
| 2★ Çekirdek 1,25 mi 1,5 mi | Konusuz kalır |

### 14.2 Faz C

| Adım | Etki |
|---|---|
| C1 Sunucu | **Aynı.** Not: 5★ hesap 6-20 kapasite birimi (50 koltuk/birim); Otomatik ayar eşiği büyük koltukta da çalışmalı |
| C2 Giderler | **Aynı.** C2'nin ekonomi ölçümündeki uyarı (orta ve geç oyun fazla rahat) gelir modeline bağlıydı; yeni fiyat modeliyle gelir ve gider E2'de birlikte ölçülür |
| C4 Kurumsal madde | **Aynı.** "3★ ve üstü" eşiği tek sabit [PLAN_C_E1 satır 44]; Erdem 6'nın bantlarında yeni 3★ (30-100) eski 3★'a (40-70) denk düşer, eşik 3 kalır. Şart düzeneği (etiket, tarih, fesih bildirimi) yenileme şartında yeniden kullanılır |
| C7 Destek raporu | **Aynı**; ileride satırlar modüle göre gruplanabilir |
| C9 Ev ve ofis | **Aynı** |
| C3a Memnuniyet defteri | Büyük ölçüde kalır; yeni satırlar: "İsteği bekliyor", "Şart: <modül>", eskime ("Stok 4'te kaldı, rakiplerde 5"; Erdem 11), ürün dışı ayrılma (bütçe kesintisi, düşük olasılık); şema 19 göçü buraya `Customer.modules`, çalışan sayısı, gidiş ve `o`'yu da alır |
| C3b İmza | **Yeniden yazılır**: modül uyumu, satışçı bir üst kuralı (×0,6), üç düğmeli teklif ve önerilen fiyat, temsilcinin kapanışında duruş çarpanı, %60 yok |
| C5 Yenileme | **Yeniden yazılır**: gidiş, koltuk kuralı, şart; fiyat yenilemede değişmez; PRD'deki yıldız başına koltuk artış tabanları (1★ %25 … [PRD_FAZ_C satır 255]) Erdem K3'ün "1★ sürekli koltuk almaz" kararıyla çelişir, düşer |
| C6 İstekler | **Yeniden yazılır**: modül kartında birleştirme; yalnız 3★ ve üstü, 4-5★ daha sık (Erdem 5); temsilci şartı yok (Karar 9); derinlik isteği yalnız pazardaki seviyeyi ister; yeni modül genişlemesi fiyatı artırır |
| C8 HESAPLAR | **Genişler**: sektör, modüller, yıldız, çalışan · koltuk, gidiş, yenileme tarihi, şart sütunları; "şartlı" süzgeci. Bugün yok; hesap kartı listesi sayfalamasız [K2 §3] |

Sonuç: C'nin bugün kodladığı sıra (C2 → C1 → C4 → C7 → C9a → C9a-3B) bu modelle **durmaz**.

### 14.3 Faz D

- Kart kataloğu büyür: 10 modül × K12 = 120 modül kademesi kartı (bugün 27) [K2 §2.3]; büyük kademe çok sprintlik kart (Erdem'in
  "büyük modül birkaç sprint" notu); `effort.k4`… anahtarları ya da efor formülü (iki parçalı eğri, §3.3) [K2 §2.5].
- İstek kartı modül kartıyla birleşir (Karar 25: adı isteğin konusundan).
- Atama: sistem atar (Erdem 18-A), proaktif ve reaktif (Erdem 25); kadro tavanı D'nin taslağında (§8.2). Rakip aynı kuralı okur.
- Hata modeli: iş büyüdükçe hata ihtimali artar, ekip kalitesi belirler (Erdem 19, 24); rakip de aynı kurala tabidir (§8.1).
- PM planının ufku 3 sprint [K §3.2]; büyük kartta yetmeyebilir, D'ye not.

### 14.4 Ar-Ge

- Düğümlere yıl alanı (dönem kilidi); `ai_engine` ve kardeşleri 2012'de açık olmamalı [K §3.3].
- Yeni etki: düğüm bitince seçili modüllerin tavanı dönem tavanının bir üstüne çıkar (Erdem 27; §3.3). Ekranda tavan ve onu
  yükseltecek araştırma yazılı.
- Dönem düğümleri: e-Belge (2015), veri koruma (2016), API (2019), YZ birinci dalga (2018) ve ikinci dalga (2023; dalga sayısı açık
  soru), isteğe bağlı ajan YZ (2028); `incident_playbook` kalktı (Karar 4).
- Bugün 19 düğümün 12'si kademe kapısı olabilir; 14 K3 (10 modül + 4 platform) bunlara düşer; yeni düğüm = 1 `rnd_tree.json` girdisi
  + 2 CSV satırı [K2 §2.5]. "Ar-Ge düğümü her K3'te ve yalnız K3'te" doğrulayıcısı yeniden yazılır.
- Rakip aynı ağacı yürütür: `ResearchSeam.completed` şirket başına olur [K §4.2 madde 4].
- Bilinen yol ileride düğüm adayıdır (Erdem 31).

### 14.5 Kod noktaları (özet)

Yıldızın 5'e çıkışı (~30 nokta, liste [K §2.4]; `counterpart_system` 3 rolü, `MISMATCH_PENALTY` 3 elemanı, `_roll_star` döngüsü),
`TIER_MAX`, `EFFORT_BANDS` ve `IDENTITY_LINE_COUNT 5` / `IDENTITY_PROFILE_SHAPE` doğrulayıcıları [K §3.4, K2 §2.5], GDD ÜRÜN rev 6
§12.1-12.2'nin "9 hat × 3 kademe = 27" mührü (smoke'ta sabit; sahibin kararıyla GDD'ye yazılır) [K2 madde 12], `Customer.modules`
ve `Prospect.modules` (@export, varsayılan göçtür) [K §1.5], rakip durum alanları `Rival` @export'u [K §4.2 madde 1, 8],
`market_ref` kopyalarının göçü [K §2.4], `ProductQuality.TABLE`'ı kaldırmak 16 dosyada ~40 çağrı noktası [K2 §4.3], fiyat 13 dosya
(§5.6), sektör CSV'si (40 satır) korunur, 13 ad 9 profile eşlenir (veri dosyası, metin gerektirmez) [K §1.1, K2 §4.2].

---

## 15. Kararlar ve açık soru (kapsam 13)

### 15.1 Erdem'in kararları (bu belgeye işlenenler)

| # | Karar | Nerede |
|---|---|---|
| K1 | Beklenti ekranda metrik olarak gösterilmez; istek ve şart olarak gelir | §6.4, §7 |
| K2 | Kopyalama yok; rakipler aynı kart listesi ve Ar-Ge ağacıyla yürüyen şirketlerdir; fark hız, verim, satış, destek ve Ar-Ge'de öne geçmekle | §6.1, §8 |
| K3 | Koltuk artışı beklentiyi artırmaz; her müşteri büyümez; 1★ sürekli koltuk almaz | §4.2, §4.3 |
| K4 | Tavan çok uzak; Ar-Ge ve yıla bağlı kilitler; erken yılda tavana varılmaz | §3.3, §9 |
| K5 | Takvim sıkışmaz; hafta süresi sonra kalibre edilir | §9.3 |
| K6 | Rakip sürümleri standart oluşturur; büyük hesap özellikli ürüne yönelir | §6 |
| K7 | Geliştirilmeyen ürünün görünür cezası olur | §10 |
| K8 | %60 tabanı kalkar; satışçı yıldızının etkisi araştırılır | §5.2, §5.4 |
| K9 | Yıldız koltukla uyumlu ve 5 basamak; yenilemede değişebilir; her yenilemede koltuk değişmez | §4.1, §4.3 |
| 1 | Sektör modül profiliyle anlam kazanır (B) | §3.2 |
| 2 | Modül sayısı: 26 ile kapandı | §3.1 |
| 3 | Bitiş yılı: 28 ile kapandı | §9 |
| 4 | Önde olan yıllık rapor ve ödülle görünür: 29 ile kapandı | §6.5 |
| 5 | İstek yalnız 3★ ve üstünden; 4-5★ 3★'tan sık; demoda 5★ çok zor | §7.2, §13.2 |
| 6 | Koltuk bantları 3-10 / 10-30 / 30-100 / 100-300 / 300-1.000 | §4.1 |
| 7 | Satışçı en çok kendi yıldızının bir üstüne gider, şansı düşer | §5.2, §5.4 |
| 8 | Modül fiyatı olsun; nasıl: 30 ile kapandı | §5.6 |
| 9 | Dev geç oyunda geçilebilir (oyunun amacı); erken oyunda imkânsıza yakın | §8.3 |
| 10 | Bilinen yol: 31 ile kapandı | §8.4 |
| 11 | Ayrı sürüm-ritmi cezası yok; ürün eskir, memnuniyet ve ilgi düşer | §7.1, §10 |
| 26 | 10 modül; oyuncu hedef sektör seçebilir; sektörlerin müşteri tiplerinin artı ve eksileri sonra | §3.1, §3.2 |
| 27 | Kademeler dönemle açılır; ilk kademeler biraz artırılır; Ar-Ge tavanı sürekli yükseltir; dönemle Ar-Ge'ye yeni şeyler gelir | §3.3, §9 |
| 28 | Bitiş 2030 (sonu); demo 2030'u görmez | §9 |
| 29 | Yıllık rapor (en büyükler, en hızlı büyüyenler) ve B2B'de modül ödülü; yıllık, raporla aynı anda; B2C'de modül ödülü yok | §6.5 |
| 30 | Fiyat üç seçenek, önerilen fiyat modüllerden ve kaliteden; anlaşma = koltuk × fiyat; 5★ geliri sorun değil | §5.6 |
| 31 | Bilinen yol şimdilik yok | §8.4 |
| 2026-10-17 | Gizli gider ve ceza yok; memnuniyet nedensiz düşmez; ürün dışı ayrılma düşük olasılıkla ve nedeni yazılı; amaç sağlıklı büyüme | §4.4, §5.6, §7.1 |
| Karar 2, 9, 10, 25, 30 | Sunucu fiyatı bugünkü; istekte temsilci şartı yok; her kayıp kayıptır; istek kartının adı isteğin konusundan; tek metin turu | §11.3, §7.3, §4.4, §12 |
| Genel | Olabildiğince basit; kural 1 kişide de 50 kişide de kırılmaz; her mekanikte oynanışa etkisi; eski belge ve kod silinir | bütün belge |

### 15.2 Açık soru

Araştırmadan sonra hâlâ Erdem'in kararı olan ve tasarımı değiştiren tek soru: **YZ dalgası tek mi iki mi** (Erdem'in "2020
civarı" örneği ile kaynakların 2018 ve 2023'ü çelişiyor; §3.3). Soru, araştırma özeti, seçeneklerin oyunda neyi değiştirdiği ve
oyuncu örneğiyle `pazar2/out/SORU_PAKETI_3.md`'de. Tasarım cevaba kadar iki dalgayla yazıldı; kod ve sim YZ satırlarına dokunmaz.

Soru olmayan, Erdem'e bilgi:
- Hedef sektör seçimi ve sektörlerin müşteri tiplerinin artı ve eksileri sonraki konudur (Erdem 26); bu belgede tasarlanmadı.
- "İlk kademeler biraz artırılır": sim'in eğrisi K3'ü bugünkünün ~10 katına çıkarıyor; demo temposu ölçüldü ve ❌ çıktı:
  3-6 kişilik ekip 104 haftada 0-4 modülde K3'e varıyor (hedef 2-3); yumuşatma G1'i bozuyor, seçenekler §13.4 madde 10'da Erdem'e.
- Dev "geç geçilir" hedefi sim'de 2030'a yetişmiyor (en iyi %35; ayar iki turda yetmedi); seçenekler §13.4 madde 3'te Erdem'e.

### 15.3 Onay bekleyen sabitler (kod öncesi, hepsi [WORKING])

Kapanış tabanı ve uyum çarpanları (§5.2); satışçı çarpanları (×1,05/yıldız, en çok ×1,15; ×0,6) (§5.2); fiyat: P0 30 $, modül
ağırlıkları 0,10 / 0,20 / 0,30 ve sınıfları, kalite primi ±%25, duruş fiyatı ×0,85 / ×1,15, duruşun kapanış etkisi ×1,1 / ×0,85
(§5.6); ödülün aday akışı çarpanı ×1,3, 12 ay, kullanıcı eşiği N (§6.5); istek olasılıkları 3★ %25, 4★ %40, 5★ %60 (§7.2); iki
parçalı efor (K1 bugünkü, K1-K3 ×4,5, sonra ×1,2) ve dönem tavanı takvimi (§3.3); Ar-Ge tavanı +1 (2018'den, ayrı araştırma %150 efor; §3.3);
ürün dışı ayrılma oranı (§4.4); memnuniyet eskimesi 2 ve istek ömrü 13 hafta (`sim3.json`); `sim2.json` katmanı (§13.3); kapı hedefleri (§13.2).

---

## 16. Benim verdiğim küçük kararlar (itiraz edilirse değişir)

1. Modül = hat; alan beklenti birimi olmaktan çıkar, gruplama olarak kalabilir (§3.1).
2. Oyuncu standardın hesabına girmez (§6.1).
3. Göreli konum `o` imzada sabitlenir; yıldız değişimi onu değiştirmez (§4.2).
4. Mevzuat standardın ikinci kaynağıdır (§6.1, §9.1).
5. Kapanış formülünün biçimi ve [%3, %92] sınırı (§5.2).
6. Süre tablosu bugünkü (2, 3, 6, 8, 12 hafta) ile başlar (§5.3).
7. Satıştaki modül eksiğine mevcut söz mekaniği bağlanır, yeni sistem yok (§5.1).
8. Rakibin beş adımlı kart seçme kuralı (§8.1).
9. Rakip hesapları sayıdır; tam rakip simülasyonu yalnız oyuncunun ürün alt türünde (§8.5, §8.7).
10. B2C rakipleri bugünkü modelde kalır (§8.8).
11. Haftada en çok 2 müşteri maili; istek ve şart modül kartında birleşir (§7.3).
12. Mevzuat satırları parodi dünyada "e-Belge yasası", "veri koruma yasası", "YZ yasası" gibi genel adlarla tutulur (§9.1).
13. Sim yeri `pazar2/sim/` ve `.gdignore` (§13.1); kademe adları şablonla başlar (§12 Yol 3).
14. "Satışçı bir üst" kuralı kurucuya da uygulanır: kurucu da satıcıdır (§5.2).
15. Temsilciler oyuncunun Satış sekmesinde seçtiği duruşla çalışır; üç düğme her teklifte yalnız kurucunun görüşmesinde sorulur;
    pazarlık cetvelinin serbest fiyatı ve karşı teklif turu kalkar (Erdem 30'un "oyuncu birini seçer, teklif gider"inin okunuşu)
    (§5.6).
16. Fiyat imzada damgalanır; yenilemede değişmez; yeni modül eklenince yalnız o modülün ağırlığı eklenir (§5.6).
17. Rakibin fiyatı aynı formülle rakibin kendi modül kalitelerinden çıkar; teklif ekranında ve kayıp satırında tek satır (§5.6).
18. Derinlik isteği yalnız pazarda var olan seviyeyi ister (sim'in kural adayı) (§7.1).
19. Erdem 27'nin "ilk kademeler biraz artırılır"ı kademe eforu olarak okundu; iki parçalı eğri demo temposu ölçülene kadar
    [WORKING] (§3.3).
20. Tavanın iki katmanı: dönem açar, Ar-Ge bir üst kademeye yükseltir; ekranda tavan ve yükseltecek araştırma yazılı (§3.3).
21. Modül ödülünün tek karşılığı aday akışı (×1,3, 12 ay); kısa liste ve itibar elendi (§6.5). Rapor Kasım'da (§6.5).
22. "Devi geçmek" = yıllık raporun "en büyükler" listesinde devin önüne çıkmak; ürünle geçmek daha erken gelir (§8.3).
23. Ürün dışı ayrılma nedeniyle yazıldığı için durgunluk kapısında adlı sayılır; gerçek dünya tutma bantları kapıdan çıktı (§4.4,
    §13.2).
24. Ölçek kapısı aynı ekip gücündeki oyuncuda ölçekler arası okunur; ekip kolları arasındaki fark kuralın doğasıdır (§11.1).
25. Sektöre özgü erken mevzuat (sağlıkta KVKK, e-Belge) Erdem 1 B ile ilk sürüme girmez (§3.2, §9.1).

---

## 17. Kaynak sicili (devralınan, bu belgede kullanılanlar)

Erişim tarihi: tur 1 kaynaklarında 2026-10-20, tur 2'de 2026-10-20/21, R3'te 2026-10-21 (kol ajanlarının sicilinden aynen). "V"
sütunu doğrulama hükmüdür (tur 1 için V, tur 2 için V2). Tur 2 ve tur 3 kaynakları kol adıyla öneklenmiştir; numara o kolun kendi
sicilindeki numaradır.

### A1 · ERP evrimi

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| A1-S1 | https://en.wikipedia.org/wiki/SAP_ERP | Wikipedia | sürekli güncel | Orta | |
| A1-S2 | https://en.wikipedia.org/wiki/SAP_S/4HANA | Wikipedia | sürekli güncel | Orta | |
| A1-S4 | https://en.wikipedia.org/wiki/SAP_Business_ByDesign | Wikipedia | sürekli güncel | Orta | |
| A1-S5 | https://ir-api.eqs.com/media/document/72b51d5c-6d29-4600-b313-5a29f95bee2d/assets/DE0007164600-JA-2024-EQ-E-00.pdf?disposition=inline | SAP SE, 2024 Entegre Rapor | 2025 (FY2024) | Yüksek | Doğrulandı (#4, 20-F ile) |
| A1-S6 | https://www.theregister.com/2026/02/05/sap_migrations_research/ | The Register (Gartner, ISG aktarımı) | 2026-02-05 | Orta | Kısmen (#3: %39 geçmişti) |
| A1-S8 | https://www.constellationr.com/insights/news/sap-launches-joule-generative-ai-copilot-goes-2-year-s4hana-cloud-major-release-cycle | Constellation Research | 2023-09 | Orta (arama özeti) | |
| A1-S10 | https://www.sec.gov/Archives/edgar/data/0001117106/000111710616000050/a2015netsuiteform10-k.htm | NetSuite Inc., SEC 10-K FY2015 | 2016 | Yüksek | Rakamlar doğrulandı, beyan kısmen (#5) |
| A1-S11 | https://en.wikipedia.org/wiki/Microsoft_Dynamics_365_Business_Central | Wikipedia | sürekli güncel | Orta | |
| A1-S12 | https://blogs.microsoft.com/blog/2023/03/06/introducing-microsoft-dynamics-365-copilot/ | Microsoft | 2023-03-06 | Düşük (yalnız tarih) | |
| A1-S13 | https://support.microsoft.com/help/17920 | Microsoft yaşam döngüsü | 2024-2025 | Orta-Yüksek | Doğrulandı nüansla (#11) |
| A1-S26 | https://en.wikipedia.org/wiki/General_Data_Protection_Regulation | Wikipedia | sürekli güncel | Orta | |
| A1-S27 | https://tr.wikipedia.org/wiki/Kişisel_Verilerin_Korunması_Kanunu | Vikipedi | sürekli güncel | Orta | |
| A1-S28 | https://en.wikipedia.org/wiki/PeopleSoft | Wikipedia | sürekli güncel | Orta | |
| A1-S29 | https://en.wikipedia.org/wiki/Baan_Corporation | Wikipedia | sürekli güncel | Orta | |
| A1-S30 | https://en.wikipedia.org/wiki/Oracle_Fusion_Applications | Wikipedia | sürekli güncel | Orta | |
| A1-S31 | https://www.computerworld.com/article/2772084/10-famous-erp-disasters--dustups-and-disappointments.html | Computerworld / CIO.com | 2009-03-30 | Orta | |
| A1-S34 | https://www.panorama-consulting.com/wp-content/uploads/2016/07/2015-ERP-Report-3.pdf | Panorama Consulting, 2015 ERP Report | 2015 | Orta (seçilim yanlılığı olası) | Açılmadı (#21) |
| A1-S35 | https://4439340.fs1.hubspotusercontent-na1.net/hubfs/4439340/Reports/ERP%20Report/2024-erp-report-panorama-consulting-group.pdf | Panorama Consulting, 2024 ERP Report | 2024 | Orta | |
| A1-S37 | https://en.wikipedia.org/wiki/Enterprise_resource_planning | Wikipedia | sürekli güncel | Orta | |
| A1-S38 | https://www.techtarget.com/searcherp/news/366616112/Cloud-ERP-is-deployment-choice-for-top-tier-systems | TechTarget | 2024-2025 | Orta (arama özeti) | |
| A1-S21 | https://webrazzi.com/2024/10/18/param-nebim-yazilim-in-cogunluk-hissesini-satin-aldi/ | Webrazzi | 2024-10-18 | Orta | |
| A1-S22 | https://www.mikro.com.tr/hakkimizda | Mikro Yazılım | sürekli güncel | Düşük | |
| e-Fatura takvimi | Grant Thornton 2015/64 sirküleri ve KPMG 2013 özeti (V'nin indirip okuduğu PDF'ler; 421 ve 454 sayılı tebliğler) | Danışmanlık özetleri | 2013, 2015 | Orta-Yüksek | V #2 (A1'in 2014 satırı YANLIŞ) |

### A2 · ERP satışı

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| A2-S6 | https://blog.bridgegroupinc.com/2024-ae-metrics-compensation-benchmark | The Bridge Group | 2024 | Orta | |
| A2-S10 | https://www.ebsta.com/wp-content/uploads/2023/02/2023-B2B-Sales-Benchmark-Report.pdf | Ebsta ve Pavilion (3,2 milyon fırsat) | 2023 | Orta (kendi ürününü satar) | Doğrulandı (#1) |
| A2-S11 | https://ebsta.com/wp-content/uploads/2024/07/H1-Update-2024-B2B-Sales-Benchmarks.pdf | Ebsta | 2024-07 | Orta | |
| A2-S12 | https://www.saas-capital.com/blog-posts/new-retention-data-and-the-impact-on-valuation/ | SaaS Capital | 2020-06-26 | Orta | Açılmadı, ERP'ye özgü değil (#20) |
| A2-S14 | https://stealthagents.com/research/startup-gross-retention-benchmarks | Stealth Agents | 2026 | Düşük | |
| A2-S15 | https://www.microsoft.com/en-us/dynamics-365/products/business-central/pricing | Microsoft fiyat sayfası | güncel | Orta | Doğrulandı (#9) |
| A2-S16 | https://redresscompliance.com/oracle-netsuite-pricing-guide.html | İş ortağı blogları | 2025-2026 | Düşük | |
| A2-S17 | https://single-market-economy.ec.europa.eu/smes/sme-definition_en | Avrupa Komisyonu | güncel | Yüksek | |
| A2-S18 | https://ec.europa.eu/eurostat/web/products-eurostat-news/w/ddn-20240516-2 | Eurostat | 2024-05-16 | Yüksek | Doğrulandı (#8) |
| A2-S19 | https://netsuite.com/portal/resource/articles/erp/erp-statistics.shtml | NetSuite (403, arama özeti) | belirsiz | Düşük | Türetmenin girdisi (#20) |
| A2-S20 | https://www.panorama-consulting.com/the-hidden-costs-of-erp-failure/ | Panorama Consulting | 2025-07-02 | Orta | |
| A2-S21 | https://www.computerworld.com/article/1547747/jury-awards-61m-to-sunshine-mills-over-botched-erp-project.html | Computerworld | 2010-12-06 | Orta-Yüksek | Doğrulandı (#10) |
| A2-S22 | https://www.networkworld.com/article/667719/erp-microsoft-accenture-joint-venture-avanade-sued-over-alleged-erp-project-failure.html | Network World | 2013-01-03 | Orta | |
| A2-S25 | https://www.businesswire.com/news/home/20160225005106/en/3718917/New-Study-Companies-Replace-ERP-Vendor-Software | SYSPRO anketi (403, arama özeti) | 2016-02-25 | Düşük | |
| A2-S28 | https://redresscompliance.com/sap-license-renewal-the-complete-guide.html | Redress Compliance | 2026 | Düşük | |
| A2-S29 | https://saplicensingexperts.com/blog/sap-price-increase-negotiation-guide | SAP Licensing Experts | 2026 | Düşük | |
| A2-S30 | https://www.organisator.ch/en/?p=7297 | organisator.ch (Trovarit) | 2020 verisi | Orta | |
| A2-S35 | https://www.thestarrconspiracy.com/insights/benchmarks/b2b-buying-committee-benchmarks-2025 | The Starr Conspiracy | 2025 | Orta-Düşük | |
| A2-S36 | https://www.erpresearch.com/en-us/erp-evaluation-selection | ERP Research | 2026-07 | Düşük | |
| A2-S38 | https://prospeo.io/s/sales-cycle | Prospeo (satıcı blogu) | 2026 | Düşük | Doğrulanmadı (#20) |
| A2-S40 | https://www.lemondeinformatique.fr/actualites/lireamp-les-entreprises-plutot-satisfaites-de-leur-erp-selon-un-rapport-de-panorama-48115.html | Le Monde Informatique (Panorama 2012) | 2012 | Orta-Düşük | |
| A2-S41 | https://en.wikipedia.org/wiki/Microsoft_Dynamics_365 | Wikipedia | güncel | Düşük | |
| A2-S43 | https://www.getmonetizely.com/articles/understanding-contraction-revenue-a-critical-metric-for-saas-growth-and-retention | Monetizely | belirsiz | Düşük | |

### A3 · Sektör ve modül

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| A3-S1 … S9 | https://www.erpresearch.com/industries/manufacturing ve kardeş sayfalar (perakende, dağıtım, hizmet, e-ticaret, sağlık, inşaat, kamu) | ERP Research (satıcı eşleştirme sitesi) | 2026-08 | Düşük | Kısmen, tek yayıncı (#13) |
| A3-S10 | https://www.parasut.com/blog/vergi-mevzuatinda-yeni-duzenlemeler | Paraşüt | 2024-2026 (tutarsız) | Düşük-Orta | #2'de kullanıldı |
| A3-S11 | https://ozbekcpa.com/mandatory-transition-to-e-document-applications-in-turkiye/ | Özbek CPA | 2026-09-24 | Orta | |
| A3-S14 | https://www.mevzuat.gov.tr/mevzuatmetin/1.5.6698.pdf | T.C. Mevzuat Bilgi Sistemi (6698 sayılı Kanun) | 2016-04-07; 2024 değişikliği | Yüksek | |
| A3-S16 | https://www.panorama-consulting.com/top-10-erp-failures/ | Panorama Consulting | 2025-09-09 | Orta | Doğrulandı (#10) |
| A3-S17 | https://trginternational.com/blog/should-your-erp-system-be-vertical-specific/ | TRG International | 2016-12-09 | Düşük-Orta | |
| A3-S18 | https://en.wikipedia.org/wiki/Enterprise_resource_planning | Wikipedia | erişim anı | Orta | |

### B1 · Rakip şirketler (oyunlar)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| B1-S1 | https://www.capitalismlab.com/?p=473 | Enlight Software, rakip ayar sayfası | belirtilmemiş | Düşük-Orta | |
| B1-S2 | https://www.capitalismlab.com/digital-age-dlc/technology-research/ | Enlight Software, Digital Age DLC | belirtilmemiş | Düşük-Orta | Formül doğrulandı, rakiplere uygulanması açılamadı (#18) |
| B1-S5 | https://steamcommunity.com/app/1331550/discussions/0/4416424806092527106 | Steam, Big Ambitions; geliştirici yanıtları | 4-12 Tem 2024 | Yüksek (geliştirici) | Doğrulandı (#16) |
| B1-S8 | https://www.footballmanager.com/features/smarter-transfers-squad-building-and-finance | Sports Interactive FM24 yazısı | 19 Eyl 2023 | Düşük | |
| B1-S10 | https://steamcommunity.com/app/482730/discussions/0/1291817837631653819 | Steam, FM 2017 "Cheating"; geliştirici yanıtı | 4 Haz-1 Tem 2017 | Orta | |
| B1-S11 | https://fmprojects.substack.com/p/reputation | Football Manager Projects | 7 Ara 2024 | Orta-Düşük | |
| B1-S17 | https://steamcommunity.com/app/415200/discussions/0/1519260397777880664 | Steam, Motorsport Manager | 28 Eyl-2 Eki 2017 | Orta | |
| B1-S20 | https://forum.quartertothree.com/t/offworld-trading-company-from-mohawk-games/74837?page=11 | Quarter to Three; Soren Johnson yanıtları | 18-19 Oca 2015 | Orta (geliştirici satırı Yüksek) | |
| B1-S22 | https://steamcommunity.com/app/606800/discussions/0/1638676181986210763 | Steam, Startup Company; geliştirici Jonas | 13-14 Kas 2019 | Yüksek (geliştirici) | |
| B1-S25 | https://steamcommunity.com/app/362620/discussions/0/530647080134369375 | Steam, Software Inc. "No more competition?" | 13 Tem 2015 | Orta (alfa) | |
| B1-S27 | https://steamcommunity.com/app/362620/discussions/0/6664812048258268104 | Steam, Software Inc. "More Competitor depth" | 16-19 Haz 2023 | Orta | |
| B1-S38 | https://steamcommunity.com/app/415200/discussions/0/1842367319512870168 | Steam, Motorsport Manager, sıralama farkı (R2'den) | 10-11 Ara 2016 | Orta | |

### B2 · Dönem kilitleri (oyunlar)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| B2-S1 | https://www.greenheartgames.com/app/game-dev-tycoon/ | Greenheart Games | güncel | Düşük | Doğrulandı (#15) |
| B2-S3 | https://steamcommunity.com/app/239820/discussions/0/864977564053270644 | Steam Topluluğu | 2013 | Düşük | |
| B2-S4 | https://steamcommunity.com/app/239820/discussions/0/1480982338955468057 | Steam Topluluğu | 2017 | Düşük | |
| B2-S10 | https://steamcommunity.com/app/1342330/discussions/3/3058491773346971759/ | Steam Topluluğu (MGT2) | 10 Tem 2021 | Düşük | |
| B2-S11 | https://steamcommunity.com/app/1342330/discussions/0/7607215340155700440 | Steam Topluluğu (MGT2) | 2024-2025 | Düşük | |
| B2-S15 | https://steamcommunity.com/app/362620/discussions/0/3079873787853220696/ | Steam Topluluğu (Software Inc.) | Nis 2021 | Düşük | |
| B2-S18 | https://wiki.openttd.org/en/Manual/Vehicles | OpenTTD wiki | güncel | Orta | Doğrulandı (#14) |
| B2-S20 | https://wiki.openttd.org/en/Archive/Manual/Settings/Never%20expire%20vehicles | OpenTTD wiki | güncel | Orta | Ayar var, tepki boyutu yok (#14) |
| B2-S21 | https://newgrf-specs.tt-wiki.net/wiki/Action0General | NewGRF spesifikasyonu | güncel | Orta | Doğrulandı; ilk iki yılda pay yok (#14) |
| B2-S26 | https://steamcommunity.com/app/289070/discussions/0/282992562607266710/?l=czech | Steam Topluluğu (Civ VI) | 2 Kas 2016 | Düşük | |
| B2-S27 | https://en.wikipedia.org/wiki/Civilization_VII | Wikipedia | güncel | Orta | |
| B2-S29 | https://store.steampowered.com/app/1295660/Sid_Meiers_Civilization_VII/ | Steam mağaza | güncel (oran değişken) | Düşük (oran veri) | |
| B2-S39 | https://www.passion4fm.com/how-to-approach-long-term-saves-in-football-manager/ | Passion4FM | 28 Tem 2021 | Düşük-Orta | |

### P · Sektör profili (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| P-S1 | https://www.sec.gov/Archives/edgar/data/0001117106/000111710613000006/a2012netsuiteform10-k.htm | NetSuite Inc., SEC 10-K FY2012 | 2013 | Orta (gelir sıralaması), Düşük (ürün tanımı) | Doğrulandı (V2 #21) |
| P-S6 | https://www.cxtoday.com/customer-analytics-intelligence/gartner-magic-quadrant-for-cloud-erp-for-service-centric-enterprises-2023-the-rundown/ | CX Today (Gartner hizmet merkezli MQ özeti) | 2023-09-11 | Orta (ikincil) | |

### M · Modül sayısı (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| M-S5 | https://en.wikipedia.org/wiki/Microsoft_Dynamics_NAV | Wikipedia | sürekli güncel | Orta | |
| M-S6 | https://learn.microsoft.com/en-us/previous-versions/dynamicsnav-2013r2/dd338912(v=nav.71) | Microsoft Learn arşivi (NAV 2013 R2) | 2013-12-11 | Orta-Yüksek | Doğrulandı (V2 #20) |

### F1 · Gerçek ERP fiyatı (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| F1-S1 | https://www.microsoft.com/en-us/dynamics-365/products/business-central/pricing | Microsoft (resmî fiyat sayfası) | güncel | Orta | Doğrulandı (V2 #1) |
| F1-S3 | https://www.odoo.com/blog/reis-5/odoo-s-nieuwe-prijzen-970 | Odoo S.A. blogu | 2022-10-18 | Orta-Düşük (satıcının gerekçesi) | Doğrulandı (V2 #3) |
| F1-S7 | https://www.mikro.com.tr/fiyat-listesi | Mikro Yazılım (resmî liste) | tarih yok | Orta | Doğrulandı (V2 #6) |
| F1-S8 | https://cdn.logo.com.tr/files/logocomtr//Uploads/Documents/logo-go-wings-fiyat-listesi.pdf | Logo Yazılım (resmî liste, KOBİ) | geçerlilik 2026-01-07 | Orta | Doğrulandı (V2 #7) |
| F1-S12 | https://www.erpresearch.com/en-us/netsuite-pricing | ERP Research | 2026 | Düşük | |
| F1-S16 | https://www.microsoft.com/en-us/dynamics-365/products/finance/pricing | Microsoft (resmî fiyat sayfası) | güncel | Orta | |

### F2 · Oyunlarda fiyat (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| F2-S1 | https://steamcommunity.com/app/362620/discussions/0/3288067088115504970 | Steam, Software Inc oyuncuları | 2018-04-20 | Düşük | Gösterge doğrulandı (V2 #15) |
| F2-S3 | https://steamcommunity.com/sharedfiles/filedetails/?id=3256150569 | Steam rehberi ve yorumları (kaldırılmış) | 2024-06; yorumlar 2025 sonuna dek | Düşük (tek yazar, tek koşu) | Deney açılamadı (V2 #15) |
| F2-S6 | https://www.whisperofthehouse.com/big-ambitions/pricing-guide | Whisper of the House (hayran sitesi) | 2026-08-30 | Düşük | |
| F2-S7 | https://steamcommunity.com/app/1331550/discussions/0/4336483289195964575 | Steam, Big Ambitions; geliştirici yanıtı | 2024-06/09 | Orta | |
| F2-S8 | https://steamcommunity.com/app/1331550/discussions/0/4339861623043791608 | Steam, Big Ambitions; geliştirici yanıtı | 2024-06 | Orta | |
| F2-S13 | https://steamcommunity.com/app/535930/discussions/0/1770385542765130889 | Steam, Two Point Hospital | 2019 | Düşük | |
| F2-S17 | https://www.capitalismlab.com/beginners-guide-gameplay-basics/ | Capitalism Lab (geliştirici sitesi) | belirsiz | Düşük | |

### S1 · Gerçek sıralama ve ödül (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| S1-S3 | https://documentation.g2.com/docs/research-scoring-methodologies | G2 | sürekli güncel | Orta (yöntem olgusu) | Doğrulandı (V2 #14) |
| S1-S12 | https://www.deloitte.com/tr/en/Industries/tmt/perspectives/technology-fast-50.html | Deloitte Türkiye | 2026 programı | Orta | |
| S1-S13 | https://www.bilisim500.com | BThaber / m2s | 2026-08 (27. baskı) | Orta | |
| S1-S16 | https://diginomica.com/2014/08/07/gartner-mq-fire-netscout-alleges-unfair-practices-pay-play-lawsuit/ | diginomica (Den Howlett) | 2014-08-07 | Orta (yorum) | Dava doğrulandı (V2 #13) |
| S1-S19 | https://www.marketscale.com/industries/software-and-technology/94-of-b2b-buyers-fact-check-ai-research-and-peer-reviews-still-close-the-deal | MarketScale (TrustRadius raporu) | 2026-07-31 | Orta (yayıncı yorum platformu) | Doğrulandı (V2 #14) |
| S1-S23 | https://www.appsruntheworld.com/oracle-surpasses-sap-to-become-no-1-erp-apps-provider/ | Apps Run The World | 2025-04-13 | Orta (tahmin) | Doğrulandı (V2 #14) |
| S1-S24 | https://www.appsruntheworld.com/top-10-erp-software-vendors | Apps Run The World | 2026-08 | Orta (tahmin) | |
| S1-S25 | https://www.acumatica.com/blog/acumatica-cloud-erp-winsthree-pcmag-editors-choice-awards-and-one-best-app-award-in-record-setting-year/ | Acumatica (satıcı PR'ı) | 2026 | Düşük | |
| S1-S29 | https://www.cxtoday.com/?p=66764 ; https://www.businesswire.com/news/home/20241114447680/en | CX Today; Epicor/BusinessWire | 2024-11 | Orta-Düşük (arama özeti) | Kısmen (V2 #13) |

### S2 · Oyunlarda sıralama ve ödül (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| S2-S10 | https://steamcommunity.com/app/362620/discussions/0/4303823318963208172 | Steam, Software Inc "What do awards actually do?" | 2024-02 | Düşük | |
| S2-S13 | https://en.wikipedia.org/wiki/Two_Point_Hospital | Wikipedia | erişim anı | Orta | |
| S2-S17 | https://steamcommunity.com/app/415200/discussions/0/1842367319512870168 | Steam, Motorsport Manager sıralama başlığı | 2016-12 | Düşük-Orta | |

### Y · Bitiş yılı (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| Y-S1 | https://taxation-customs.ec.europa.eu/taxation/vat/vat-digital-age-vida_en | AB Komisyonu (ViDA) | güncel | Yüksek | Doğrulandı (V2 #17) |
| Y-S2 | https://digital-strategy.ec.europa.eu/en/policies/regulatory-framework-ai | AB Komisyonu (YZ Yasası) | güncel | Yüksek | Doğrulandı (V2 #17) |
| Y-S3 | https://digital-strategy.ec.europa.eu/en/policies/cra-summary | AB Komisyonu (Siber Dayanıklılık Yasası) | güncel | Yüksek | Doğrulandı (V2 #17) |
| Y-S11 | https://www.theregister.com/2025/06/20/rimini_street_sap_ecc/ | The Register | 2025-06-20 | Orta | Kısmen: 2027/2030 doğru, 2033 danışman sözü (V2 #18) |
| Y-S15 | https://sovos.com/tr/blog/kdv/sirketler-icin-2026-e-donusum-takvimi-ve-zorunluluklar/ | Sovos Türkiye (e-fatura satıcısı) | 2026-05-05 | Düşük-Orta | |
| Y-S17 | https://sdtimes.com/agentic-ai/gartner-more-than-40-of-agentic-ai-projects-will-be-canceled-in-next-few-years/ | SD Times (Gartner aktarımı) | 2025-06-30 | Orta | Doğrulandı (V2 #18) |
| Y-S19 | https://www.gartner.com/en/newsroom/press-releases/2014-01-29-gartner-says-by-2016-the-impact-of-cloud-and-emergence-of-postmodern-erp-will-relegate-highly-customized-erp-systems-to-legacy-status | Gartner | 2014-01-29 | Orta (yalnız arama özeti) | Başlık ve tarih doğrulandı (V2 #18) |

### B · Bilinen yol (tur 2)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| B-S17 | https://blogs.microsoft.com/blog/2023/03/06/introducing-microsoft-dynamics-365-copilot/ | Microsoft | 2023-03-06 | Orta (yalnız tarih için) | |
| B-S18 | https://www.techtarget.com/searcherp/podcast/Oracle-Salesforce-SAP-go-big-into-generative-AI-products | TechTarget | 2023-09 (içerikten) | Orta | |

### R3 · Önerilen fiyat, YZ zamanı, rapor ve ödül (tur 3)

| ID | URL | Yayıncı | Yayın | Güven | V |
|---|---|---|---|---|---|
| R3-S6 | https://www.microsoft.com/en-us/dynamics-365/products/supply-chain-management/pricing | Microsoft (resmî fiyat sayfası) | güncel | Orta | |
| R3-S7 | https://www.constellationr.com/blog-news/event-report-sap-sapphire-2017-all-leonardo-wait-there-more | Constellation Research (Holger Mueller) | 2017-05-19 | Orta | |
| R3-S9 | https://www.eweek.com/cloud/oracle-launches-major-ai-initiative-with-intelligent-cloud-apps | eWeek | 2017-10 | Orta-Düşük (sayfa 403, özet) | |
| R3-S11 | https://www.cpapracticeadvisor.com/2018/04/25/netsuite-launches-first-intelligent-cloud-suite-with-ai-and-machine-learning/29721/ | CPA Practice Advisor (NetSuite bülteni aktarımı) | 2018-04-25 | Orta | |
| R3-S12 | https://www.theregister.com/2018/09/18/dynamics_365_ai/ | The Register | 2018-09-18 | Orta | |
| R3-S15 | https://voicebot.ai/2017/11/05/gartner-hype-cycle-suggests-another-ai-winter-near | Voicebot.ai (Gartner aktarımı) | 2017-11-05 | Orta-Düşük (özet) | |
| R3-S16 | https://virtonomica.ru/help/index.php/Science/en | Virtonomica (oyunun yardım sayfası) | yok | Orta-Düşük | |
| R3-S18 | https://en.wikipedia.org/wiki/Technology_tree | Wikipedia | güncel | Orta | |
| R3-S20 | https://steamcommunity.com/app/239820/discussions | Steam Topluluğu, Game Dev Tycoon (birkaç başlık) | 2013-2020 | Düşük (arama özeti) | |
| R3-S21 | https://sell.g2.com/case-studies/looker-increases-average-ctr-with-g2 | G2 (satıcının vaka çalışması) | 2020-06-29 | Düşük | |
| R3-S22 | https://blogs.gartner.com/reviews-pages/?p=4894 (ve ?p=4861, ?p=5159) | Gartner Peer Insights metodoloji sürümleri | 2021 civarı | Orta-Düşük (özet) | |
| R3-S23 | https://inc5000.secure-platform.com/ | Inc. (resmî başvuru sayfası) | 2026 listesi | Orta | |
| R3-S25 | https://bmf3d.com/news/inc-5000-2024-meet-the-companies-building-the-future/ | bmf3d | 2024-08 | Düşük (özet) | |
| R3-S26 | https://www2.deloitte.com/content/dam/Deloitte/us/Documents/technology-media-telecommunications/us-technology-fast-500-eligibility-requirements.pdf | Deloitte (eşik belgesi) | 2024 | Orta (özet) | |
| R3-S27 | https://www.bvp.com/atlas/the-cloud-100-benchmarks-report | Bessemer Venture Partners | 2025-09-03 | Orta | |

### İç kaynaklar

| ID | Yer |
|---|---|
| K | `docs/tasks/faz_cde/pazar2/out/K_kod_haritasi.md` (kod `HEAD` `e4e7e9b9`; V #19 doğruladı) |
| V | `docs/tasks/faz_cde/pazar2/out/V_dogrulama.md` |
| P, M, F1, F2, S1, S2, Y, B, K2, V2 | `docs/tasks/faz_cde/pazar2/out/tur2/` altında `P_sektor_profil.md` (+ `P_profiles.json`), `M_modul_sayilari.md`, `F1_fiyat_erp.md`, `F2_fiyat_oyun.md`, `S1_siralama_gercek.md`, `S2_siralama_oyun.md`, `Y_bitis_yili.md`, `B_bilinen_yol.md`, `K2_kod_fiyat_icerik.md` (kod `HEAD` `3bc600f2`; V2 #23 doğruladı), `V2_dogrulama.md` |
| R3 | `docs/tasks/faz_cde/pazar2/out/tur2/R3_mini.md` |
| SIM1, SIM2 | `docs/tasks/faz_cde/pazar2/out/tur2/SIM_RAPOR_1.md`, `SIM_RAPOR_2.md`; sonuçlar `sim1_sonuc*.json`, `sim2_sonuc*.json`; betik ve veri `docs/tasks/faz_cde/pazar2/sim/` |
| ATAMA-A1, ATAMA-A2, ATAMA-A4 | `docs/tasks/faz_cde/d_taslak/ATAMA/A1_OYUNLAR_1.md`, `A2_OYUNLAR_2.md` (oyun dökümleri), `A4_TASARIM.md` (D'nin atama tasarımı taslağı) |
| PLAN_C, PLAN_C_E1, PRD_FAZ_C | `docs/tasks/faz_cde/c_taslak/PLAN_C.md`, `PLAN_C_E1.md`, `docs/tasks/faz_cde/PRD_FAZ_C_URUN_HESAP.md` |
| Kararlar | `docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md`; Erdem 2026-10-17: `docs/tasks/faz_cde/ERDEM_CDQ_CEVAP.md` |
| Kod sabitleri (bu belgede ayrıca okunan) | `scripts/systems/sales_constants.gd:113-131` (`SEAT_BAND`, `SEAT_PRICE_MIN/MAX`, `STANCE_MULT`); `scripts/systems/seed_constants.gd:21` (`DOOR_MRR 20_000`); `scripts/systems/rival_catalog.gd:144` (`MARKET_TOTAL_MRR`); `scripts/systems/product_lines.gd:20-40` (`TIER_MAX`, `EFFORT_BANDS`, `RND_DESIGN_EFFORT_MULT`, `IDENTITY_*`); `data/product/sprint.json:21` (`person_points_week 2`); `data/techtree/rnd_tree.json` (20 düğüm) |

---

## 18. Varsayımlar (A#)

- **A1** Oyundaki aday nitelikli bir fırsattır; genel B2B kazanma oranları (%19-23) taban olarak kullanılamaz (§5.2).
- **A2** Koltuk ihtiyacı çalışan sayısıyla orantılıdır (ERP kullanan çalışan oranı ~%26 satıcı beyanı, Düşük) (§4.1).
- **A3** Mobil, API pazarı ve uzaktan çalışma dönem satırlarının yılları kaynaksızdır; yer tutucudur (§9.1). Akıllı otomasyonun
  ikinci kademesinin 2020'ye konması kaynaksızdır (ürün olgunluğu sezgisi) [R3 §B1 GÖRÜŞ].
- **A4** Dev rakibin oyundaki boyutu "bu pazardaki ERP takımı"dır; gerçek şirket boyutu değildir (§8.3).
- **A5** 5★'ın kısa liste seviyesine (en iyi ikinci rakip) bakması, alıcı kısa listesi davranışından modül seviyesine
  benim geçişimdir (§4.2) [SIÇRAMA].
- **A6** Yenilemede özellik şartı gerçek ERP verisinde bulunamadı; Erdem'in tasarım kararıdır (§7.1).
- **A7** Simülasyon uydurma bir dünyadır (rakip politikası, ekip büyümesi, havuz, pay devri, kart başına 6 kişi, memnuniyet
  dağılımı); yalnız biçimi gösterir (§11.4, §13).
- **A8** Mevzuat takvimi Türkiye ve AB'den alınmıştır; oyunun dünyası parodi olduğu için genel adla kullanılır (§9.1).
- **A9** Sektör profil tablosunun 90 hücresinin 43'ü varsayımdır; sektöre göre modül kullanım yüzdesi hiçbir bağımsız kaynakta yok
  (§3.2).
- **A10** Önerilen fiyatın modül ağırlıkları gerçek fiyat listelerindeki oranlardan (ağır ≈ hafifin 3 katı) türetilmiştir; kalite
  primi (±%25) ve duruşların kapanış etkisi için kaynak yok (§5.6).
- **A11** Modül ödülünün aday akışına etkisi (×1,3) tek bir satıcı vaka çalışmasının yönünden alınmıştır; büyüklük kaynaksız (§6.5).

Etiket özeti: [BOŞLUK] standardın sayısal hızı, yenilemede özellik şartı, mobil ve API kilometre taşları, 2019-2020 ERP YZ
kilometre taşı, sektöre özgü modül eksikliği başarısızlığı, satışçının indirime etkisi, fiyat-kalite ilişkisi ve premium fiyatın
kapanışa etkisi, ödülün satın almaya bağımsız etkisi; [SIÇRAMA] 5★ ve L (A5), oyundaki aday tabanı (A1), mevzuatın parodi dünyaya
taşınması; [DEĞERLENDİREMEM] ERP temasının oyuncuya çekiciliği; [GÖRÜŞ] mevzuatın ikinci standart kaynağı olması, rakibe giden
hesabın adlanması, tavanın iki katmanı, raporun Kasım'da çıkması, §16'daki küçük kararlar.
