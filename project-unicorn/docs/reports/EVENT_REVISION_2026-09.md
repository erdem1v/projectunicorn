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

{{RESULTS_HEADLINE}}

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

{{CHAIN_NUMBERS}}

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

{{RESULTS_TABLE}}

---

## 6. Series A için senin kararın gereken konular

{{DECISIONS}}

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

{{VERIFICATION}}

---

## Ek A — Kartların tam metni

{{APPENDIX}}
