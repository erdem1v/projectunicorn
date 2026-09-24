# Event Revizyonu ve Series A Kapısı — Eylül 2026

Hazırlayan: Claude (lead designer rolünde) · Tarih: 24 Eylül 2026 · Dal: `claude/sharp-dirac-lev32p`
Referans: GDD v2 ch11 (Olaylar), Olay Motoru GDD rev 2, Satış GDD rev 6, Ürün rev 6.1, Ekip rev 11.
Frank kartlarına dokunulmadı.

---

## 0. Kısa özet

**Soru:** Series A kapısına neden ulaşılamıyor? Erdem'in hipotezi: event'ler kötü tasarlanmış,
aynı event'ler tekrar tekrar ateşlenip modifier'larıyla ekonomiyi aşağı çekiyor.

**Cevap: hipotez büyük ölçüde doğru, ama tek sebep değil.** Ölçüm bunu üç katmanda gösterdi:

1. **Event katmanı (senin tespitin).** `customer.retention` 730 günlük baseline koşuda **181 kez**
   ateşleniyor, verilen **181 sözün 173'ü bozuluyor**. Her bozuk söz marka −3, memnuniyet −20 ve
   tolerans +5 getiriyor; hesap riske geri dönüyor, kart yeniden ateşleniyor. Marka 181. günde 0.
   Series A kapısı marka ≥ 25 istediği için bu döngü tek başına kapıyı kilitliyor. Döngünün kökünde
   bir **kod hatası**, bir **veri boşluğu** ve üç **tasarım hatası** var (§2).
2. **Ölçüm katmanı.** "11.9K$ tavan" ölçümü, eski ürün modeliyle oynayan bir bottan geliyordu.
   Bot toplantıların %4'ünü kazanıyordu. Bot düzeltilince ekonominin gerçek şekli görünür oldu (§1).
3. **Yapısal katman.** Event'ler düzeltildikten ve bot yetkin oynadıktan sonra MRR 120K$ bandını
   rahatça geçiyor. Kapıyı artık iki şart tutuyor: **marka ≥ 25** (markanın oyunda kaynağı yok) ve
   **art arda 3 ay, aylık en az %12 büyüme** (doğrusal satış büyüdükçe bu oran düşüyor). İkisi de GDD'ler
   arasında çelişkili konular; senin kararın gerekiyor (§5).

**Yapılanlar:** Frank dışındaki 12 kartın hepsi elden geçti (11'i yeniden yazıldı, 1'i gerekçesiyle
bekletildi). Metinler önce İngilizce yazıldı, Türkçesi ayrı lokalizasyon olarak kuruldu. 6 sistem
hatası düzeltildi. Ölçüm botu baştan kuruldu. 730. gün uyarısındaki iki delik kapandı. B2C kusur
testi düzeltildi. CLAUDE.md, GDD'leri referans alacak şekilde sadeleştirildi.

**Sonuç (5 tohum × 3 politika, aynı yetkin bot):** eski kodla Series A kapısı **15 koşunun hiçbirinde
açılmadı**, marka 39–66. günlerde çöktü. Yeni kodla **15 koşunun 12'sinde açıldı** (her politikada 4/5, 238.–640. günler),
mantıklı politikada 161 sözün yalnız 1'i bozuldu. Tablolar §5'te.

---

## 1. Nasıl ölçtük

`--run-log=<preset>:<days>:sim[:<seed>]` bir koşuyu başsız oynatıp her event'i, her seçimi ve her
günün ekonomisini loglayan araç. Bu turda Godot 4.6.2 kurulup araç gerçekten koşturuldu; rapordaki
her sayı bir log'dan geliyor.

**Eski bot neden yanlış ölçüyordu:**

| Kusur | Sonuç |
|---|---|
| Eski düz katalog ürünü `saas_ops`'u kuruyordu; yeni ürün hattı modelinde bu ürünün verisi yok | Satış toplantısı ürün uyumunu 0 okudu, bot toplantıların **12/291'ini (%4)** kazandı |
| Sunucu kapasitesi almıyordu | İlk koltuktan itibaren kapasite aşımı |
| Yalnız bir geliştirici alıyordu; satış, destek ve QA hiç yoktu | Ürün ilerlemedi, destek masası kapalı kaldı |
| Cevap politikası emekli `ev_*` id'lerine bakıyordu | Yeni kartlarda hep ilk seçenek seçildi |
| Yalnız kuyruktaki ilk lead'i deniyordu | Engelli bir şirket günlerce toplantı hakkını boşa harcattı |

**Yeni bot (`scripts/debug/run_probe.gd`)** bir oyuncunun yapacağını yapıyor:
- gerçek `erp` hattını kuruyor;
- sunucu kapasitesini doluluğa göre artırıyor;
- bir işe alım merdiveni izliyor: geliştirici, destek, QA, satış, …; her basamak altı aylık runway şartına bağlı;
- hata düzeltme koşusunda bir geliştiriciyi destek masasına veriyor;
- sıradaki kilitli adımın istediği araştırmayı yapıyor;
- morali 40'ın altına inen çalışana zam ya da izin veriyor;
- bütün lead'leri deniyor;
- üç hafta arayla, kararlılık hatlarını önceleyerek sürüm çıkarıyor.

Üç cevap politikası var:
- `full_run`: mantıklı sıra, söz > oyala > indirim > bırak.
- `full_run_naive`: hep ilk açık seçenek.
- `full_run_discount`: hep önce indirim.

Politikalar arasındaki fark, kart tasarımının ekonomiye etkisini ayrı ölçüyor.

**Kontrollü deney:** Aynı yeni bot hem **eski kodla** (değişikliklerimden önceki ağaç) hem **yeni kodla**
koşturuldu. Aradaki fark doğrudan bu revizyonun etkisi.

---

## 2. Kök neden zinciri: Series A'yı kilitleyen şey

Sıra, etkinin büyüklüğüne göre.

### 2.1 Kod hatası: bütün sözler "pain" adlı hayali bir özelliğe veriliyordu
Dört kart (`retention`, `request_feature`, `request_complaint`, `cs_escalation`) söz etkisine
`feature_id: "pain"` geçiyordu. Bu, "müşterinin istediği şey" anlamında bir yer tutucuydu, ama
etki (`effects.gd` `promise_create`) onu **olduğu gibi** söz kaydına yazıyordu. Hiçbir sürüm "pain"
adında bir özellik çıkaramayacağı için **her söz, istenen şey yayına çıksa bile bozuldu**.
Baseline: 181 sözün 173'ü bozuk, marka 181. günde 0.
**Düzeltme:** etki yer tutucuyu müşterinin gerçek isteğine çözüyor (`EvEffects.PAIN_SENTINEL`).

### 2.2 Veri boşluğu: `erp` müşterilerinin istediği bir şey yoktu
Oynanabilir tek B2B ürün `erp`, ve `erp`'nin eski özellik havuzunda kaydı yok. Müşteri isteği
seçen kod (`pick_pain_feature`) boş dönüyordu. Sonuç: gerçek bir oyuncuda **"Söz ver" seçeneği
her kartta kilitliydi**; riskteki hesabı kurtaran tek araç MRR'ı %15 kesen indirimdi.
**Düzeltme:** hat modelinde müşteri, ürünün **açık hatlarının sıradaki adımını** istiyor. En düşük
kademe öncelikli, böylece istekler kümeleniyor ve tek bir sürüm birden çok hesabın sözünü tutuyor.
Adım yayına çıkınca hesap bir sonrakini istiyor. Söz, hat kademesi ulaşınca tutulmuş sayılıyor
(`ProductState.is_feature_live`, tek okuyucu).

### 2.3 Tasarım hatası: inşa edilemeyecek şeye söz verilebiliyordu
Kod hatası kapandıktan sonra bozuk sözlerin büyük kısmı (bir koşuda 241'i), araştırma ya da
yıldız isteyen **kilitli** adımlara verilmişti. Bu, "sahte seçenek yok" yasasının ihlali.
**Düzeltme:** yeni seam `musteri.pain_buildable`; istenen adımın kapısı bugün açık değilse söz
satırı kilitli görünür ve nedenini söyler: *"Nobody here can build that yet. Not the people and not
the research."* / *"Bunu yapabilecek kimse yok henüz. Ne ekip var ne araştırma."*

### 2.4 Tasarım hatası: bozuk söz toleransı sınırsız artırıyordu
Her bozuk söz toleransa kalıcı +5 ekliyordu. Birkaç sözden sonra tolerans 57–100'e çıkıyor,
en iyi ürün bile hedefi 47'nin üstüne taşıyamıyordu. Hesap bir daha memnun edilemiyor, 21 günde
bir riske giriyor, kart yeniden ateşleniyordu.
**Düzeltme:** tolerans başlangıç değerinin en fazla 10 üstüne çıkabiliyor
(`PROMISE_TOLERANCE_CEILING`). Bozuk söz hesabı seçici yapıyor, imkânsız yapmıyor.

### 2.5 Tasarım hatası: `cs_escalation`'da tek açık seçenek hesabı kaybettiriyordu
Söz kilitliyken açık kalan tek seçenek "Hayır, yapmıyoruz"du: hesap anında gidiyor, marka −3,
temsilci morali −10. Bir koşuda kart 143 kez ateşlendi.
**Düzeltme:** üçüncü seçenek *"Ask them to be patient" / "Sabır iste"*: memnuniyet −3, temsilci
morali −5, hesap kalıyor. Gövde artık temsilcinin söz verdiğini iddia etmiyor ve her hesaba
"büyük müşteri" demiyor.

### 2.6 Tasarım hatası: "Oyala" markadan ödüyordu
Bir hesabı özel olarak oyalamak pazardaki markayı değil, o ilişkideki güvenilirliği etkiler.
İndirim zaten itibardan ödüyordu. 40 gün içinde 21 "Oyala" markayı 21 puan eritti.
**Düzeltme:** bedel itibara taşındı (`RETAIN_DELAY_REP`).

### 2.7 Yapısal: markanın kaynağı yok
Kodda markaya yazan her yer onu düşürüyor: churn −2, bozuk söz −3, VC reddi, birkaç kart. Artıran
tek sistem yok. Pazarlama modülü, yani markanın tasarlanmış kaynağı, henüz yok. Satış GDD §7.3 ise
"Prestij: haber değeri **ve marka etkisi**" diyor: lig üstü imza, balina ya da koşunun ilk 3★ hesabı.
Bu imza ticker'a düşüyordu ama markaya dokunmuyordu.
**Düzeltme (GDD'nin onayladığı kadar):** haber değerli imza marka +3 (`PRESTIGE_SIGNING_BRAND`,
[ÇALIŞMA]). Churn'ün sürekli erimesini dengelemiyor; bu bir karar konusu (§5).

### 2.8 Yapısal: büyüme serisi şartı
Kapı art arda 3 ay, aylık en az %12 büyüme istiyor. Satış doğrusal büyüdüğü için MRR arttıkça
aylık yüzde düşüyor. Seri çoğu zaman erken dönemde bir kez tutuyor, sonra bir daha tutmuyor.

---

## 3. Kart kart revizyon

Frank dışındaki 12 kartın kararları:

| Kart | Karar | Oyuna etki |
|---|---|---|
| `customer.retention` | Yeniden yazıldı | Gövde riskin **sebebini** söylüyor (yeni `musteri.risk_voice`): bozuk söz, görünür arıza (sektör satırı) ya da "yetmiyor artık". Söz satırına `pain_buildable` kilidi. Oyala bedeli itibara taşındı |
| `customer.cs_escalation` | Yeniden yazıldı | "Sabır iste" eklendi, sahte seçenek kapandı. Gövde doğru |
| `customer.request_complaint` | Yeniden yazıldı | İndirim satırı kaldırıldı: şikâyet ürünle ya da dürüstlükle cevaplanır, fiyat yenilemenin kaldıracı. Görünen +8 / gerçek +16 çift memnuniyet kalktı |
| `customer.request_feature` | Yeniden yazıldı | Gövde müşterinin **istediği adımın adını** söylüyor (önceden "sistem çöküyor" diyordu). "Listede" +5 → +3: tarihsiz evet sözden hafif olmalı |
| `customer.request_renewal` | Yeniden yazıldı | İndirimin tek meşru yeri. Gizli çift memnuniyet kalktı. Süre dolumu metni etkisiyle eşleşti ("yeniledi, bizden arayan olmadı" + −5) |
| `customer.expansion` | Yeniden yazıldı | Etiket her kartta "Koltuk +0 · MRR +$0" gösteriyordu. Artık eklenecek koltuğu ve MRR'ı önceden hesaplıyor |
| `sales.weekly_summary` | Yeniden yazıldı | Oyuncuya "PH:" yer tutucu metni görünüyordu |
| `funding.seed_stalled` | Yeniden yazıldı | "Çeyrek notu" 30 günde bir geliyordu; bekleme 90 gün |
| `team.resignation` | EN yeniden yazıldı | Dört ayrılık cümlesi doğal İngilizceyle yazıldı. TR satırlar zaten iyiydi, korundu |
| `world.final_stretch_press` | Yeniden yazıldı | Kategori `rival` → `world`. "Senin turunda" funding turu gibi okunuyordu, "seninle aynı yıl" oldu. Süre dolumu sırası düzeltildi. Koşul 730 deliğini kapatacak şekilde genişledi |
| `world.final_stretch_comment` | Yeniden yazıldı | İki seçenek de saf kazançtı. Rakam: marka +2 / itibar −1. Sessizlik: itibar +1 / marka −1 |
| `sales.price_break` | **Bekletildi** | Satış GDD §7.6'da mühürlü bir kart. Henüz bağlanmadı, bir smoke vakası da bağsız durmasını doğruluyor. Silmek GDD'yi ezerdi. Bağlanması Satış tarafının işi |

Ortak düzeltmeler:
- Sektör şikâyet cümlelerinin (15 satır) İngilizcesi doğal dille yeniden yazıldı; tireler kaldırıldı.
- Kilit nedenleri kendi bilgeliğini söylemiyor. Örnek: *"Bu hesabı fiyat değil ürün tutar"* yerine *"Fiyatlarını zaten iki kez indirdin."*
- Aynı talep türünün aynı hesaptan art arda gelmesini engelleyen kayıt hiç yazılmıyordu; artık yazılıyor.

Kartların tam metni (EN önce, TR lokalizasyon, seçenek etkileri ve kilitleri) **Ek A**'da.

---

## 4. Değişen dosyalar

**Oyun kodu**
- `scripts/events/core/effects.gd` — `PAIN_SENTINEL`, söz hedefinin çözümü.
- `scripts/systems/product_state.gd` — `is_feature_live`: düz özellik ve hat adımı için tek okuyucu.
- `scripts/systems/b2b_sales_system.gd` — hat modeli istek seçici (kümeleyen), sevkiyat sonrası istek yenileme, `risk_voice`, tolerans tavanı.
- `scripts/systems/b2b_constants.gd` — `PROMISE_TOLERANCE_CEILING`, `RETAIN_DELAY_REP`.
- `scripts/autoload/customer_registry.gd` — `set_pain_feature` seam'i.
- `scripts/autoload/promise_registry.gd` — `is_feature_live` ile tutma; sevkiyattan sonra istek yenileme.
- `scripts/events/seams/seams_ported.gd` — `musteri.pain_buildable`, `musteri.risk_voice`.
- `scripts/systems/customer_rep_system.gd`, `b2b_event_factory.gd` — son talep türü kaydı, tek okuyucu.
- `scripts/modals/event_modal.gd` — genişleme önizlemesi.
- `scripts/systems/sales_ledger.gd`, `sales_finalizer.gd`, `sales_rep_system.gd`, `sales_constants.gd` — prestij markası.
- `scripts/systems/sales_system.gd` — B2C edinim çarpanı bağlandı (Ops §10, kapasite aşımında ×0,6).
- `scripts/main/main.gd` — `--run-log` tohum parametresiyle sim modunda çıkış.

**İçerik**
- 11 kart JSON'u.
- `data/events/arcs/soft_cap_stretch.json`.
- `localization/strings.csv`: 50+ anahtar; EN önce, TR lokalizasyon.

**Araçlar ve testler**
- `scripts/debug/run_probe.gd` — yeni bot.
- `scripts/debug/endgame_smoke.gd`:
  - yeni `soft_cap_warns_open_hunt` vakası;
  - B2C kalite kapısı vakası, destek masası sessiz kurularak düzeltildi (kusur raporunun 1. çözümü);
  - oyala vakası itibara göre güncellendi.

**Belgeler**
- `CLAUDE.md`.
- `docs/SEAM_REGISTRY.md` §11a.
- Dört eski belgeye "geçersiz kılındı" başlığı.

---

## 5. Sonuçlar

### 5.1 Baseline (değişiklikten önceki kod + eski bot, tek tohum)

| Ölçü | Değer |
|---|---|
| Toplantı kazanma | 12/291 (%4) |
| Tepe MRR (730 gün) | 11.864$ |
| `customer.retention` ateşleme | **181** |
| Verilen / bozulan söz | 181 / **173** |
| Marka | 181. günde 0 |
| Series A Hunt'a giriş | yok |

### 5.2 Kontrollü deney: aynı yetkin bot, eski kod ve yeni kod (730 gün, 5 tohum)

Tohumlar: 424242, 11, 22, 33, 44. MRR, retention ve churn değerleri medyan; "marka <25" her tohum için gün.

| Kod · politika | Series A Hunt'a giriş | Giriş günleri | MRR 365. gün | Tepe MRR | Markanın 25 altına düştüğü gün | Bozuk / toplam söz | Retention ateşleme | Churn |
|---|---|---|---|---|---|---|---|---|
| Eski kod · mantıklı | **0/5** | — | 116.951 | 390.692 | 46, 43, 50, 39, 48 | 0/0 | 185 | 40 |
| Eski kod · naif | **0/5** | — | 117.163 | 393.404 | 46, 43, 50, 39, 48 | 0/0 | 185 | 40 |
| Eski kod · hep indirim | **0/5** | — | 178.232 | 496.214 | 65, 60, 66, 58, 65 | 0/0 | 102 | 27 |
| **Yeni kod · mantıklı** | **4/5** | 276, 238, 336, 640 | 179.767 | 419.716 | 88, 89, 92, —, 82 | 1/161 | 123 | 65 |
| Yeni kod · naif | **4/5** | 276, 238, 336, 640 | 179.767 | 419.716 | 88, 89, 92, —, 82 | 1/161 | 123 | 65 |
| Yeni kod · hep indirim | **4/5** | 398, 301, 349, 305 | 160.755 | 381.376 | 89, 98, 98, 95, 101 | 9/111 | 127 | 66 |

### 5.3 Ne söylüyor

- **Eski kodda kapı 15 koşunun hiçbirinde açılmıyor**, MRR 300–590K$'a çıksa bile. Sebep tek: marka
  39–66. günlerde 25'in altına düşüyor ve 0'da kalıyor. Bu, event katmanı (oyala, sahte seçenekler,
  çalışmayan söz sistemi) ile kaynaksız markanın birleşik sonucu. **Senin hipotezin ölçümle doğrulanıyor.**
- **Yeni kodda kapı 15 koşunun 12'sinde açılıyor** (her politikada 4/5). Mantıklı politikada
  161 sözün 1'i bozuk.
- Eski kodda söz sistemi `erp` için hiç çalışmıyordu (0 söz). Yenide sözler tutuluyor ve hesap kurtarmanın
  indirimsiz yolu oluyor.
- Naif politika mantıklıyla aynı sonucu veriyor, çünkü ilk açık seçenek zaten söz. İndirimci politika
  daha az MRR ile ve daha geç (301–398. gün) açıyor. İndirim artık tek kurtarış değil.
- **Bir tohum (424242) kapıya hâlâ ulaşamıyor:** erken bir churn dalgası (178 churn) markayı 88. günde
  25'in altına çekiyor ve marka toparlanamıyor. Kalan yapısal risk bu (§6.1).
- **Bot Series A görüşmesini oynamıyor.** VC sahnesi ve term sheet masası elle oynanan sahneler; bot kapıdan
  girip Hunt fazına geçiyor, orada duruyor. Bu yüzden bütün koşular "running_on_fumes" ile bitiyor.
  "Kapıya ulaşmak" burada Series A Hunt fazına girmek demek; görüşmenin kalibrasyonu ayrı bir iş.
- **Ekip dağılması hâlâ yüksek:** bot moral bakımı yapsa bile koşu başına 30–50 istifa var. İK
  ekonomisine ayrıca bakılmalı (§6.4).

### 5.4 Event harness (20 tohum × 730 gün, rastgele politika)

- 0 çökme, 0 sallanan ark, **0 uyarısız kayıp**. HARNESS PASS.
- En uzun sessizlik 639 gün; sessiz taban 2.860 günde kart bulamadı. Sessiz kart havuzu boş (§9).


---

## 6. Series A için senin kararın gereken konular

### 6.1 Marka kapısı (en önemli karar)
Kapı marka ≥ 25 istiyor ve markanın düzenli bir kaynağı yok. GDD'ler de bu konuda çelişkili:
ch01 §2 kapıya markayı koyuyor, ch08 §5 "yalnız MRR" diyor. İki yol görüyorum:
- **A (önerim):** Pazarlama modülü gelene kadar kapıdaki marka tabanı ch08'e göre kaldırılır ya da
  düşürülür (ör. 25 → 10). Marka satış görüşmesi inancını ve VC puanını zaten etkiliyor; orada yaşamaya
  devam eder.
- **B:** Marka kapıda kalır ama bir kaynak eklenir (ör. tutulan söz +1, sürüm yayını +1). Bu GDD'de
  yazılı değil, senin onayını ister.

### 6.2 Büyüme serisi (%12 × 3 ay)
Kapı ilk kez açıldığında MRR 120K$ bandında ve seri tutuyor. Ama kapı bir kez kapanırsa yüksek MRR'da
%12 çok zor. Öneri: seriyi mutlak MRR artışı olarak tanımlamak ya da yüzdeyi MRR bandıyla düşürmek.
ch09 ile birlikte karar verilmeli.

### 6.3 Seed kapısı ve Series A takvimi
Yeni kodla MRR 120K$'a 237–491. günlerde ulaşıyor; 20K$'lık seed kapısı 50–60. günlerde açılıyor.
Vizyon belgesindeki "Perde 1 = 45–60 dk" hedefi için seed biraz erken; ayrı bir kalibrasyon oturumunda
bakılmalı. Series A eşiğini (120K$) bu turda değiştirmedim.

### 6.4 Ekip dağılması
Bot moral bakımı yapsa bile koşu başına 30–50 istifa var (ortalama moral ~40). Moral her gün 0,25
eriyor; toparlayan tek araçlar zam, yılda bir tatil ve kısa mesai. Bu İK ekonomisinin kalibrasyon
konusu, event'lerle ilgili değil.

### 6.5 `sales.price_break`
Satış GDD §7.6 kartı. Bağlanması için Satış tarafında "Standart fiyattan kapat" etkisinin (imza
indirimi) bir seam'e ihtiyacı var. Bu turda bekletildi.


---

## 7. 730. gün uyarısı

İki delik kapandı:
- `arc_final_stretch` artık açık kapı sinyalinde sönmüyor; yalnız **imzalı** Series A uyarıyı bitiriyor.
- `final_stretch_press` koşulu "gün ≥ 640 ve imzalı tur yok" oldu. Canlı teklifi olmayan faz 3 oyuncusu da uyarı alıyor.

Yeni smoke vakası `soft_cap_warns_open_hunt` iki durumu da doğruluyor. Eski ark dosyasıyla
çalıştırıldığında düştüğü kontrol edildi.

---

## 8. Kanon temizliği

**CLAUDE.md artık GDD'leri tasarım otoritesi olarak adlandırıyor.**

Çıkarılanlar:
- Release Scope tablosu;
- "~150 gün" özeti;
- PROJECT_SPEC'i tasarım ustası sayan referanslar;
- bayat "Next Step" ve "What this project is NOT" blokları.

Kalanlar ve güncellenenler:
- Kalibrasyon yasaları bayat sayılar olmadan duruyor.
- Dil yasaları kart formatına (`text.tr/en`) göre düzeltildi.
- **Yeni kural:** ajanlar metni önce İngilizce yazıp Türkçesini ayrı bir lokalizasyon olarak kurar; Frank korpusu ajanlara kapalı.
- Delivery Law, Write-Through, UI/Style, Tech Stack ve Teaching Mode değişmedi.

`docs/PROJECT_SPEC.md`, `docs/ENDGAME_DESIGN.md`, `docs/VC_PITCH_DESIGN.md` ve
`docs/design/EVENT_POOL_DESIGN_v1.md` silinmedi, çünkü audit'ler bunlara bağlantı veriyor. Her birinin
başında hangi GDD'nin onları geçersiz kıldığı yazıyor.

**Not:** Delivery Law "yalnız main" diyor. Bu oturum ortamın gereği olarak
`claude/sharp-dirac-lev32p` dalında çalıştı. Kurala dokunmadım; birleştirme senin kararın.

---

## 9. Eksik içerik

Kart sayısı az, bu yüzden oyun sessiz. Canlı destede Frank dışında 12 kart var; ch11'in dokuz arkının
çoğu yazılmadı:
- **Y3 ekip hayatı:** yalnız istifa var.
- **Y4 işe alım:** yok.
- **Y7 ürün sağlığı:** hata eşiği döngüsü yok.
- **Y8 rakipler:** rakip hamlesi yok.
- **Y9 kriz:** yok.
- **Sessiz taban (§13.6):** kart yok.

Bu turda yeni içerik yazılmadı; önce mevcut kartların ekonomiyi bozmaması gerekiyordu. Sıradaki
yazım turunun ilk adayları:
- **Y7:** hata eşiği ve düzeltme koşusu kararı.
- **Y4:** ilk işe alım.
- **Y8:** rakibin fiyat kırması; ch14 demo için en az bir rakip hamlesi istiyor.

---

## 10. Doğrulama

| Kapı | Sonuç |
|---|---|
| `--event-lint` | PASS · 0 hata · 0 uyarı · 38 kart · 3 ark |
| `--event-probe` | PASS · 159/159 |
| Smoke (`tools/smoke_run.sh --all`) | 336/338 geçti. Kalan 2 kırmızı baseline'da da vardı: `save_migration_v7_to_v8` ve `trait_migration_real_load` (v5/v7 kayıtları bilinçli olarak ölü, `MIN_LOADABLE_VERSION` 10). Baseline 334/337'ydi; `b2c_satisfaction_gate_experience` yeşile döndü, yeni `soft_cap_warns_open_hunt` yeşil |
| `loc_residue.gd` | CLEAN · 0 bulgu |
| `loc_csv_integrity` | PASS |
| Event harness | PASS · 0 uyarısız kayıp |
| `--run-log` matrisi | 30 koşu, 0 script hatası |


---

## Ek A — Kartların tam metni

### `customer.retention`
- Tetik: `signal` · sınıf: `interrupt` · kategori: `customer` · mandal: `{"cooldown_days": 1}` · süre: 7 gün

**EN (önce yazıldı)**
> **Account at risk**
>
> {customer} on the line.
> 
> "{seam:musteri.risk_voice}"

- *Promise it* → söz (istenen adım, 14 gün); itibar +1 · kilit: B2B_LOCK_NO_PAIN_TARGET, B2B_LOCK_PAIN_SHIPPED, B2B_LOCK_PAIN_GATED, B2B_LOCK_PROMISE_OPEN
- *Stall them* → churn sayacı +3 gün; itibar -1 · kilit: B2B_LOCK_STALL_CAP
- *Offer a discount* → MRR −%15 (hesap kalır); itibar -1 · kilit: B2B_DISCOUNT_SPENT_DESC
- *Let it go* → müdahale yok

**TR (lokalizasyon)**
> **Müşteri riski**
>
> {customer} hatta.
> 
> "{seam:musteri.risk_voice}"

- *Söz ver*
- *Oyala*
- *İndirim ver*
- *Kendi haline bırak*

### `customer.cs_escalation`
- Tetik: `daily` · sınıf: `interrupt` · kategori: `customer` · mandal: `{"cooldown_days": 21}` · süre: 7 gün

**EN (önce yazıldı)**
> **Account manager warning**
>
> Boss, {customer} has been waiting a while. I've kept them on the line as long as I can.
> 
> They want to hear from you that it's getting fixed.

- *Give them your word* → söz (istenen adım, 14 gün) · kilit: B2B_LOCK_NO_PAIN_TARGET, B2B_LOCK_PAIN_SHIPPED, B2B_LOCK_PAIN_GATED, B2B_LOCK_PROMISE_OPEN
- *Ask them to be patient* → memnuniyet -3; temsilci morali -5
- *Tell them no* → hesap anında gider; marka -3; temsilci morali -10

**TR (lokalizasyon)**
> **Müşteri temsilcisi uyarısı**
>
> Patron, {customer} bir süredir bekliyor. Tutabildiğim kadar tuttum.
> 
> Düzeleceğini senden duymak istiyorlar.

- *Söz ver*
- *Sabır iste*
- *Hayır de*

### `customer.request_complaint`
- Tetik: `request` · sınıf: `paper` · kategori: `customer` · mandal: `{"cooldown_days": 14}` · süre: 7 gün

**EN (önce yazıldı)**
> **Customer complaint**
>
> {customer} called the support line.
> 
> "{seam:musteri.complaint_voice}"
> 
> I've kept them talking. What do I tell them?

- *Promise a fix* → söz (istenen adım, 14 gün) · kilit: B2B_LOCK_NO_PAIN_TARGET, B2B_LOCK_PAIN_SHIPPED, B2B_LOCK_PAIN_GATED, B2B_LOCK_PROMISE_OPEN
- *Tell them the truth* → memnuniyet +3

**TR (lokalizasyon)**
> **Müşteri şikâyeti**
>
> {customer} destek hattını aradı.
> 
> "{seam:musteri.complaint_voice}"
> 
> Şimdilik oyaladım. Onlara ne diyeyim?

- *Düzeltme sözü ver*
- *Durumu açıkça anlat*

### `customer.request_feature`
- Tetik: `request` · sınıf: `paper` · kategori: `customer` · mandal: `{"cooldown_days": 14}` · süre: 7 gün

**EN (önce yazıldı)**
> **Customer request**
>
> {customer} wants something the product doesn't do yet: {seam:musteri.pain_feature_label}.
> 
> They asked when. I said I'd find out.

- *Give them a date* → söz (istenen adım, 14 gün) · kilit: B2B_LOCK_NO_PAIN_TARGET, B2B_LOCK_PAIN_SHIPPED, B2B_LOCK_PAIN_GATED, B2B_LOCK_PROMISE_OPEN
- *Say it's on the list* → memnuniyet +3
- *Say not now* → memnuniyet -4

**TR (lokalizasyon)**
> **Müşteri talebi**
>
> {customer} ürünün henüz yapmadığı bir şey istiyor: {seam:musteri.pain_feature_label}.
> 
> Ne zaman diye sordular. Öğrenip döneceğimi söyledim.

- *Tarih ver*
- *Listede olduğunu söyle*
- *Şimdilik olmaz de*

### `customer.request_renewal`
- Tetik: `request` · sınıf: `paper` · kategori: `customer` · mandal: `{"cooldown_days": 14}` · süre: 7 gün

**EN (önce yazıldı)**
> **Renewal signal**
>
> Renewal is coming up for {customer}, and they're reading the invoice line by line.
> 
> They want someone from our side at the table.

- *Sit down with them* → memnuniyet +4
- *Renew at a lower rate* → MRR −%15 (hesap kalır) · kilit: B2B_DISCOUNT_SPENT_DESC
- *Let it wait* → memnuniyet -2

**TR (lokalizasyon)**
> **Yenileme sinyali**
>
> Yenileme dönemi yaklaşıyor. {customer} faturayı satır satır okuyor.
> 
> Karşılarında bizden birini görmek istiyorlar.

- *Masaya otur*
- *Daha düşük fiyatla yenile*
- *Beklet*

### `customer.expansion`
- Tetik: `daily` · sınıf: `paper` · kategori: `customer` · mandal: `{"one_shot": true}` · süre: 14 gün

**EN (önce yazıldı)**
> **Growth opening**
>
> {customer} wants to roll the system out to another team.
> 
> They're asking for more seats at the same price.

- *Add the seats* → koltuk + MRR (hesabın kendi fiyatıyla)
- *Not now* → değişiklik yok

**TR (lokalizasyon)**
> **Büyüme fırsatı**
>
> {customer} sistemi bir ekibe daha açmak istiyor.
> 
> Aynı fiyattan koltuk istiyorlar.

- *Koltukları ekle*
- *Şimdi değil*

### `sales.weekly_summary`
- Tetik: `request` · sınıf: `info` · kategori: `customer` · mandal: `{"cooldown_days": 6}`

**EN (önce yazıldı)**
> **The week in sales**
>
> Closed this week:
> 
> {seam:sales.weekly_closes}
> 
> Accounts on the books: {seam:sales.account_count}

- *Close* → —

**TR (lokalizasyon)**
> **Haftanın satışları**
>
> Bu hafta kapananlar:
> 
> {seam:sales.weekly_closes}
> 
> Defterdeki hesap: {seam:sales.account_count}

- *Kapat*

### `funding.seed_stalled`
- Tetik: `daily` · sınıf: `paper` · kategori: `funding` · mandal: `{"cooldown_days": 90}` · süre: 14 gün

**EN (önce yazıldı)**
> **The quarterly note**
>
> A mail from {investor}: the last three months on a single page. No comment.
> 
> The growth line has nothing written next to it. That's the comment.

- *Set it aside* → —

**TR (lokalizasyon)**
> **Çeyrek notu**
>
> {investor} bir mail göndermiş: son üç ay, tek sayfa, yorumsuz.
> 
> Büyüme satırının yanı boş. Yorum da bu.

- *Kenara koy*

### `team.resignation`
- Tetik: `request` · sınıf: `interrupt` · kategori: `team` · mandal: `{"one_shot": true}`

**EN (önce yazıldı)**
> **A departure**
>
> {seam:hr.resign_voice}

- *Understood* → çalışan ayrılır

**TR (lokalizasyon)**
> **Ayrılık**
>
> {seam:hr.resign_voice}

- *Anlaşıldı*

### `world.final_stretch_press`
- Tetik: `daily` · sınıf: `paper` · kategori: `world` · mandal: `{"one_shot": true}` · süre: 30 gün

**EN (önce yazıldı)**
> **Sector Telegraph · the annual file**
>
> The annual file is out. It lists every company founded the same year as yours. Most have a round, a sale or a closure next to the name.
> 
> Next to yours is the line they wrote on day one. The file doesn't comment. It only lists.

- *Set the file aside* → —

**TR (lokalizasyon)**
> **Sektör Telgrafı · yıllık dosya**
>
> Yıllık dosya çıkmış. Seninle aynı yıl kurulan şirketlerin listesi. Çoğunun yanında bir tur, bir satış ya da bir kapanış yazıyor.
> 
> Seninkinin yanında ilk gün yazdıkları satır duruyor. Dosya yorum yapmıyor. Sadece sıralıyor.

- *Dosyayı kenara koy*

### `world.final_stretch_comment`
- Tetik: `daily` · sınıf: `interrupt` · kategori: `world` · mandal: `{"one_shot": true}`

**EN (önce yazıldı)**
> **They want a comment**
>
> The reporter is polite. They want a few lines for the year-end round-up. You're one of the few companies still standing from that year, and to them that's a story.
> 
> Give them a number and you're in the piece. Say nothing and you're in it anyway, under a different sentence.

- *Give them the number* → marka +2; itibar -1
- *No comment* → itibar +1; marka -1

**TR (lokalizasyon)**
> **Yorum istiyorlar**
>
> Muhabir kibar. Yıl sonu derlemesi için birkaç satır istiyor. O yıl kurulanlardan ayakta kalan birkaç şirketten birisin ve onun için bu bir hikâye.
> 
> Bir rakam verirsen yazıya girersin. Susarsan da girersin, sadece başka bir cümleyle.

- *Rakamı ver*
- *Yorum yok*


