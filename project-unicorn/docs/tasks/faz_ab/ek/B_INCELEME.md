# Faz B planı · Kıdemli inceleme (Opus, 2026-10-16)
İncelenen: `B_PLAN.md`. Okunanlar: `ERDEM_TUR2_YORUM.md`, karar defteri (Faz B ve "Fazlar arası sınırlar"), `ORTAK.md`,
`B_GOREV.md`, `B_ARASTIRMA.md`, `C_PLAN.md`, `D_PLAN.md`, `E_PLAN.md`. `A_PLAN.md` henüz yok; A'nın adları için
`A_GOREV.md` okundu. Kod `main` @ `1faeb82` üstünde doğrulandı; repoda hiçbir dosya değişmedi.
Plana yapılan her düzeltme `(inceleme)` işaretiyle duruyor (90 yer).

**Hüküm: düzeltmeyle hazır.** Tasarım karar defterini karşılıyor ve reddedilen fikirler geri gelmemiş. Kod iddialarının
çoğu doğru çıktı. İki iddia yanlıştı (gece kartının 02:10'da açılması, "Testi kısalt"ın sabit +30'u); ikisi de plana
düzeltildi. Kalan 8 karar Erdem'in.

---

## 1. Bulgular

| # | Bulgu | Nerede | Düzeltme | Uygulandı mı |
|---|---|---|---|---|
| 1 | **Gece kartı 02:10'da açılamaz.** Gece `skip_night` ile tam saat adımlarıyla geçiyor (`time_manager.gd` `_step_hour`, `frac 0`). Tutuş adımı 02:00'de dakikasız durdurur. Kart 02:00'de açılırsa "02:10 itibarıyla" daha gelmemiş bir saati anlatır. Erdem'in en sevmediği türden bir mantık çelişkisi. | §0, §2.1 Saat, §5.1 Saat, Olay 1–2 | Kart, başlama dakikasından sonraki ilk tam saatte açılır (02:10 → 03:00). Mail 02:10 damgalı kalır, metin geçmiş zamanla anlatır. | Evet |
| 2 | **Ay sonu maili 23:40, kartı 00:00 adımına iter.** O adımda gün dönümü, ay kapanışı ve oto kayıt koşuyor. Ayrıca CLAUDE.md §5'teki "gün sınırında ateşlenen kart saat yazmaz" kuralına takılır. | Olay 3, §5.1 | Damga 22:10–22:55, kart 23:00'te açılır. | Evet (sahip sorusu 8) |
| 3 | Gündüz penceresi 10:00–18:00, ama 17:00'den sonrası gece toplu adımına giriyor (`is_night`). | §5.1 Saat | 10:00–16:00 | Evet |
| 4 | **Tutuşun ne zaman alınıp bırakılacağı yazılmamıştı.** Motor isteği reddederse sistemin aldığı tutuş kalıcı kalır ve saat kilitlenir. | §5.1 Saat | Tutuş yalnız `EventGate.request` true dönerse alınır. Kart gösterilince bırakılır, o andan sonra `main`'in `"event"` tutuşu devreye girer. 00:00 adımı hiç kullanılmaz. Yeni smoke `incident_night_hold_resumes` falsification ile kanıtlanır. | Evet |
| 5 | **"Testi kısalt" %40 → %70 (`CUT_TEST_FAULTY` 0,7).** Erdem testçisiz %40'ı bile "fazla" buldu. D'nin modelinde ihtimal %2 ile %14 arasında ve D açıkça "B ayrı bir ihtimal eki yazmaz" diyor (D §5.4). | §2.4, §5.2, §5.6, §5.7 | "Testi kısalt" yalnız test işini yarıya indirir. İhtimal `SprintSystem.escape_chance(card)`'dan okunur ve çip önceki ile sonraki değeri aynı fonksiyondan gösterir. | Evet |
| 6 | **D'nin ×5 puan ölçeği.** Kâğıtlardaki puan miktarları (+2, −3, +4…) ve "puan başı $1.000" bugünkü ölçekte yazılmıştı ama tek yerde listelenmemişti. D bu listeyi istiyor (D §5.4 ve risk 3). | §5.6 | Liste eklendi. D listeyi ×5 yapar, puan başı fiyatı /5'e indirir. Çipler miktarı fiilin kendisinden okur. | Evet |
| 7 | B'nin eşik tablosundaki "C varsayımı" (26 + 4×) eskidi. C planı 30 + 3 × (yıldız − 1) + ⌊sektör/2⌋ öneriyor. | §5.5 | Tablo C'nin sayılarıyla güncellendi. Sonuç değişmedi: D = 6 ile tek erteleme sağlam ürünü yakmaz, iki erteleme 2★ ve üstünü riske sokar. C'nin bot ölçümü de "eşik 30'a iner, erteleme güven kaydına yazılır" diyor; iki plan uyumlu. | Evet |
| 8 | **Kademe çarpanı iki planda farklı.** B'de 1,5 / 1,0 / 0,6, C'de 1,6 / 1,0 / 0,5. C ikisini de "B'nin sayısı" diye yazıyor. | §5.1 | Çarpanın tek evi B'nin `sprint.json` `incident.tier` alanıdır. C'nin ipucu `IncidentSystem.tier_mult()`'i okur. C tazelemesinde C'nin tablosu buna bağlanır. | Evet (B tarafı) |
| 9 | **Doluluk.** C doluluğu ve aşımı tamamen kaldırıyor (bot ölçümünde 97 haftada hiç aşılmamış). B ise `LOAD` çarpanını ve "sunucular kapasitenin sınırındaydı" sebep cümlesini kuruyor. C gelince bunlar ölü kod olur. | §5.1, Olay 1–2 metni | Öneri: B doluluğu hiç okumasın, `BASE` baştan 0,10 olsun. Okunacaksa tek fonksiyonda (`_load_mult()`) durur. Olay 2 örneği sağlayıcı sebebine çevrildi. | Kısmen, sahip sorusu 6 |
| 10 | Ar-Ge `incident_playbook` bugün aşım cezasını yumuşatıyor. C aşımı kaldırınca etkisi ölür ve C, B'nin devralmasını bekliyor (C §5.7 madde 9). B planında yoktu. | §5.1, §5.6 | Araştırılmışsa bütün kesinti süreleri ×0,75 [ÇALIŞMA]. | Evet |
| 11 | C, B'den `founder_hours` fiilini bekliyor (C §5.7 madde 7). B kurucu bedelini var olan `productivity_mod` ile yazıyor. Yeni fiil gerekmiyor. | §5.2, §5.7 | `productivity_mod` tabloya açıkça yazıldı. `founder_hours` C'nin işi. | Evet |
| 12 | **`trust_offset` iddiası doğru:** günde 0,4, tikte 2,8 affediliyor, −25 ile +10 arasında kırpılıyor (`b2b_sales_system.gd` `_target_on`, `_forgiven_trust`). Kalıcı B2B bedeli için doğru yol. Ancak aynı defter sözü de taşıyor. Ayrıca A, hedefe hesap başına açık hata terimi ekleyecek. | §5.3 | C'nin memnuniyet ipucu bu terimi "söz" diye adlandırmamalı, "güven (söz ve kesintiler)" yazmalı. Ertelemenin A'nın terimiyle çift sayımı B3 ölçümünde ayrıca raporlanır. | Evet (not) |
| 13 | **Mandal iddiası doğru:** `EvLatches.blocked_reason` önce `max_fires`'ı, sonra `cooldown_weeks`'i uyguluyor ve ikisi birlikte çalışıyor. Ancak kâğıtlar `employee` slotu taşıyor ve `latch_key: entity` olursa sayaç kişi başına tutulur. `max_fires` bugün hiçbir kartta kullanılmıyor. | §5.4 | `latch_key: "run"` açık yazılır ve lint'e kural olarak eklenir. `decision_no_fourth_show` vakası ilk kullanımın kanıtı olur. | Evet |
| 14 | Kayıt eksikleri: (a) Statik `IncidentSystem` yalnız `reset_all_owners`'a değil, `save_manager.gd`'nin sistem bloğuna da girmeli. (b) `line_harden` için hat başına bitiş tiki yeni durum listesinde yoktu. (c) B2C kamu sözünde müşteri kimliği boş kalırsa `has_open_for("")` yanlış cevap verir. | §5.8 | Üçü de yazıldı. (a) için daha basit seçenek de not edildi: durumu `GameState`'te bir sözlükte tutmak. | Evet |
| 15 | `{belirti}`, `{son}`, `{ekran}` ve `{alıntı}` motor belirteci değil. Kart gövdesinde yalnız `{slot}` ve `{seam:…}` çözülür, gerisi ekrana süslü parantezle çıkar. | §6.1 Olay 5 ve 6 | Gövde, hat başına tam cümle olarak yazılır ve var olan `by_seam` / `variants` biçimiyle seçilir (`presenter.gd` `_resolve_variant`). | Evet |
| 16 | **Ödeme olayında ekip ikiden büyükken tek açık seçenek kalıyordu.** "Kendin bak" kilitli, "Bırak" kilitli, "Telafi" yalnız pazaryerinde. Kalan tek seçenek bir karar değildir ("bedava çıkış yok, her seçenek bir durumda en iyisi" kuralı). | §2.1 tablo, Olay 4, §6.1 | "Sprinti durdur, düzeltmeyi sprintin başına al" eklendi: ekibin haftası korunur, kesinti uzar. | Evet |
| 17 | Kilit gerekçeleri hüküm veriyordu: "…; bekleyecek bir şey yok." CLAUDE.md §5'e göre gerekçe yalnız olguyu söyler. | §2.1, Olay 2 ve 4, §6.1 | "Uygulama şu anda kimseye açılmıyor." / "Şu anda kimse ödeme yapamıyor." | Evet |
| 18 | "Ne zaman geliyor?" kartı istek sayısını temsilci olmadan gösteriyordu. Karar defteri "istekler yalnız müşteri temsilcisi bulunca ortaya çıkar" diyor. | §2.4, §6.3 | Kartın koşulu ekipte temsilci olması, konuşan da temsilci. | Evet |
| 19 | "Tarih sessizce geçsin" bedeli "Kitle −%1,5": olaydan kopuk sabit bir yüzde. Olayda "140 kişi bekliyor" yazıyor. | §2.4, §5.6, §6.3 | Bekleyenlerin %40'ı gider (140 → −56) [ÇALIŞMA]. | Evet |
| 20 | K3 (PM): "filtreyle dışa aktarmayı sonraki sprinte at" seçeneği `bugs 2` yazıyordu. Kapsam ertelemek hata üretmez; metinle çelişiyordu. | §6.2 K3 | `bugs` silindi. Seçenek bedelsiz kalmasın diye ertelenen iş +1 puanlık yeniden açma payıyla döner [ÇALIŞMA]. | Evet |
| 21 | K4 (tasarımcı): "Üç soruyla çık" seçeneğinin bedeli açık hataydı. Bir tasarım seçimi hata değildir; gövdede "ikincisi daha çok kişiyi tutar" yazıyor. | §6.2 K4 | Bedel tutulamayan kullanıcılar: haftalık yeni kullanıcının %10'u × 8 hafta, tek seferlik [ÇALIŞMA]. | Evet |
| 22 | K6: Planda "gövdede ihtimal yazar" deniyordu ama gövdede ihtimal yok. `covered`, D gelince D'nin "testi kim yaptı" kalite modeliyle çakışır. Test 0★ kurucu, ikincil rolde test yapan geliştiriciden iyi değildir. | §6.2 K6, §5.2 | İhtimal her seçeneğin çipinde yazar. D gelince testi gerçekte yapanın yıldızı okunur. | Evet |
| 23 | K8: "{customer} da kendi renklerini istiyor" cümlesinde belirtecin ardından ünlü uyumuna bağlı bir ek geliyor ("Ekol da", "Lale de"). Token kuralı ihlali. | §6.2 K8 | "{customer} ekibi de …" | Evet |
| 24 | Yazım: 16 cümle zayıftı. Ayrıntısı §2'de. | §2, §6 | Yeniden yazıldı | Evet |
| 25 | **E, not ve video uygulamasını siliyor** (E §5.8, açık soru 1). B'nin B2C metinlerinin çoğu bu iki ürün için: 56 yorumun 40'ı, video belirtileri, video alıntısı, K7. Hepsi E2'de çöpe gider. | §6.5, §5.7 | Öneri: B yalnız ortak B2C hatlarını ve not uygulamasının çalışan asgarisini yazar. Pazaryeri metinleri E'de yazılır. | Not, sahip sorusu 7 |
| 26 | Karar defteri B2C yorumlarının "son kullanıcıdan ve mağazadan" gelmesini istiyor. Plan mağaza kaynağını "Satıcı" diye adlandırıyordu; E'nin sözlüğünde taraflar "Alıcı" ve "Mağaza". Mağaza yarısı ancak E ile gelebilir; izlenebilirlik tablosunda bu yazmıyordu. | §2.5, §6.5, §3 | Etiket "Mağaza" / "Store" oldu. İzlenebilirlik tablosuna satır eklendi. | Evet |
| 27 | Planda "Tam smoke yalnız push öncesi" yazıyordu. Erdem 2026-10-06'da "push et doğrudan push demek, tam smoke yok" dedi. | §7, §9 | Düzeltildi. Push yalnız Erdem'in sözüyle, tam smoke koşulmadan. | Evet |
| 28 | B2 için 120 dakika az: yeni sistem, kayıt, saat tutuşu, `insert_urgent_fix` ve iki kart bir arada. | §9 | 180 dakika. Toplam ≈ 18–20 saat. | Evet |
| 29 | **Yeni `IncidentSystem` gerekçesi sahibin ölçütüyle yazılmamıştı.** "En az yeni sistem" kuralı bedeli ve "neden var olanı değil" sorusunun cevabını istiyor. Ayrı sistem haklı: aday evler SupportSystem (A yeniden yazıyor) ve InfraSystem (C söküyor); ikisine eklemek üç fazı aynı dosyalarda çakıştırırdı. | §5.1 | Bedel (orta; yeni durum var, yeni ekran yok) ve gerekçe yazıldı. | Evet |
| 30 | "Sprinti durdur" o hattın düzeltme kartı zaten sprintteyse ikinci bir kart açabilirdi. | §2.1 | Var olan kart başa taşınır. | Evet |
| 31 | Örneklerdeki "Ekol" (Ekol Lojistik) ve C'deki "Arkas" gerçek Türk şirketleri. Oyun verisinde yoklar; oyunda `{customer}` slotu kendi verisinden dolar. Ama bu örnekler Erdem'e sunulan metinlerde duruyor. | §2 örnekleri, C planı | Sunumdan önce örnek adlar uydurma adlarla değiştirilmeli. Bütün planları etkilediği için ana oturuma bırakıldı. | Hayır (ana oturum) |
| 32 | B7'de Söz verisi: `PromiseRegistry.create` yalnız hedefsiz sözü reddediyor; kamu sözü açılabilir. | §5.8 | Bulgu 14 (c) ile çözüldü. | Evet |

**Doğrulanan kod iddiaları (sorun yok):**
- `EventGate.request` bool döner. Bugünkü `_request_decision` kâğıtları sırayla deniyor ve ilk kabul edileni alıyor; plandaki "ilk kabul edilen gelir" buna uyuyor.
- İstekle gelen kartlarda motor geceyi denetlemiyor (`gate.gd` yalnız `hourly` kartı süzer). Toplu adım içinde gelen kart, adım bitince gösteriliyor (`engine.gd` `pump`). Tutuşla kesilen gece, tutuş kalkıp oyuncu saati başlatınca kaldığı saatten sürüyor (`_can_step` yorumu).
- `productivity_mod` (ekip kapsamı dahil), `morale_all`, `sprint_card_effort`, `sprint_card_progress`, `sprint_card_carry` ve `sprint_hours` var. `morale_all`'a eklenecek `scope` parametresi yeni.
- `InfraSystem.provider()` ve `capacity_state()` var. Bugünkü `outage.json` `urun.capacity_state`'i okuyor. B bu kartı silip yerine yenisini koyduğu için C'nin "kart ölü kalır" riski kapanıyor.
- Yatırımcı hazırlığı yalnız Series A'da uygulanıyor (`vc_pitch_system.gd:85`, `if series_a`); planın tespiti doğru. Karar defterindeki "seed görüşmesi öncesi" ifadesi yanlıştı.
- Seçimi bir seam'e bağlı gövde varyantları motorda var.
- Bütün kapı araçları var: `--event-shot`, `--inbox-shot`, `--clock-shot=held`, `--why-fire`, `--event-harness`, `--sprint-probe`, `run_gate.sh`, `plausibility_run.sh`.

**Kapsam:** Karar defterinin Faz B maddelerinin hepsinin planda bir karşılığı var ve bu karşılıklar tasarımın içinde de duruyor; tabloda iddia olarak kalmıyor. Reddedilen fikirlerin hiçbiri geri gelmemiş: satıcı ödemesi ikizi, kurucunun müşteri görüşmesi, öneri çipi, retro ve sürüm duyurusu planda yok.

Sabit bedeller: Kalan sabitler marka ±1 ya da ±2 (tek bir genel ölçek), "%25 ihtimalle aceleden hata" (bir olasılık, bedel değil) ve kurucu verimi −%15 (Erdem'in istediği büyüklük). Dolar ve kitle bedellerinin hepsi olaydan türüyor.

Bir yakınlık var: B2C söz ikizindeki "duyur" seçeneğinin Marka +1 etkisi, pazarlamaya ertelenen sürüm duyurusuna yakın duruyor. Ancak ikisi farklı şeyler: bu seçenek bir tarih sözü veriyor, kitleye doğrudan ekleme yapmıyor. Sahip sorusu 3 bunu da kapsar.

**Fazla iş:** Yeni ekran yok. Yeni sistem tek ve gerekçesi yukarıda. Fazlalığın asıl kaynağı yazım hacmi: E'nin sileceği B2C ürünleri için ≈60 metin (bulgu 25). `amount_seam` motor eklentisi küçük ve "bedel olaydan türer" kuralının tek dayanağı; yerinde.

**Adım tablosu:** Kurala uyuyor: kodu Sonnet xhigh ya da max ile yazıyor, kapıları Haiku düşük düşünmeyle koşuyor, her commit'ten önce bir Opus incelemesi var. Yazımın Opus'ta yapılması gerekçeli (Erdem'in en sert eleştirisi). Erdem'in onayını beklemek süreye dahil değil. Tek değişiklik B2'nin süresi (bulgu 28).

---

## 2. Yazım (zayıf cümle → yeni hâli; hepsi plana uygulandı)

| # | Zayıf cümle | Sorun | Yeni hâli |
|---|---|---|---|
| Y1 | "Servis {clock} itibarıyla cevap vermiyor." (ve Olay 2, 4 ile pazaryeri gövdesinde aynı kalıp) | Resmî yazışma dili. Beyaz yaka biri gece mesajında böyle yazmaz. | "Servis saat {clock} sularında durdu, o zamandan beri cevap vermiyor." / "…saat {clock} sularından beri…" (belirtecin ardına ek gelmez) |
| Y2 | "ilk telefon {customer} deposundan geldi" | Gece vardiyalı sektörlerden biri sağlık; hastanenin deposu olmaz. Mantık çelişkisi. | "ilk arayan {customer} oldu" |
| Y3 | "…servisi belleği doldurup duruyor." | İki anlama okunuyor ("sürekli dolduruyor" mu, "doldurup duruyor" mu). | "…servisi belleği doldurup çöküyor." |
| Y4 | "…aboneliğini başlatmak ya da yenilemek istedi, yapamadı." | Virgülle eklenmiş iki cümle; bağlaç eksik. | "…istedi ama yapamadı." |
| Y5 | "Uygulama açılmıyor; bekleyecek bir şey yok." / "Kimse ödeme yapamıyor; bekleyecek bir şey yok." | Kilit gerekçesi hüküm veriyor (CLAUDE.md §5). | "Uygulama şu anda kimseye açılmıyor." / "Şu anda kimse ödeme yapamıyor." |
| Y6 | "Özür dile, …yarı fiyat tanımla; düzeltme sonraki sprinte" | Yüklemsiz, kesik bitiyor. | "…; düzeltmeyi sonraki sprinte bırak" |
| Y7 | "…etkilenen ödeyenlere…" | "Ödeyenler" kesik ve devrik duruyor. | "…etkilenen ücretli kullanıcılara bir aylık ücretlerini iade et" |
| Y8 | Başlık "Bir gönderi, 310 paylaşım" | Virgüllü slogan başlığı. | "Bir gönderi 310 kez paylaşıldı" |
| Y9 | Kâğıt başlıkları "Üçü de aynı yerden", "İskontodan önce KDV", "Hazır bir parça", "İki ilk ekran", "İki cihaz, bir not" | Kesik ve slogan gibi duruyorlar. Bunlar iş yerinde gelen mailin konu satırı olmalı. | "Üç hata aynı yerden çıkıyor", "İskontolu faturada KDV yanlış hesaplanıyor", "Bu iş için hazır bir bileşen var", "İlk ekranın iki hâli var", "İki cihazda yazılan değişiklik kayboluyor" |
| Y10 | "Bir yılın faturalarında ise bir denetçinin ilk bulacağı şey bu." | Vurgu için ayrı cümleye bölünmüş; "Nadir ama para." tonuna yakın. | "Tek bir faturada fark çok küçük; ama bir yılın faturaları toplanınca denetimde ilk göze batacak şey bu olur." |
| Y11 | "Düzelt; kart bir gün geç biter" | Haftalık tik modelinde "gün" diye bir birim yok. | "Çıkmadan düzelt" (bedel çipte puan olarak yazar) |
| Y12 | "Not, not olarak kaldı." | Kelime oyunu, kesik vurgu. | "Cevap verilmedi; kod olduğu gibi kaldı." |
| Y13 | "Bu ay en çok sorulan soru Paylaşılan Not: …" | Dil bilgisi yanlış: soru özelliğin kendisi değil. | "Bu ay en çok sorulan şey Paylaşılan Not: …" |
| Y14 | "Sonraki sprintin sonu diye duyur" | Devrik ve kesik. | "Sonraki sprintin sonunda çıkacağını duyur" |
| Y15 | "{customer} da kendi renklerini istiyor." | Belirtecin ardından ünlü uyumuna bağlı bir ek geliyor. | "{customer} ekibi de ekranları kendi renklerinde istiyor. Geçen sefer renkleri elle değiştirdik; bu sefer de aynı süreyi alacak." |
| Y16 | "…ama onlar en sadık kullanıcılarımız." | Bir değerlendirme; metin gözlemlemeli, hüküm vermemeli. | "…uygulamayı en çok kullananlar da onlar." |
| Y17 | "Sonunda telefonda yazdığım not, masaya oturmadan bilgisayarımda oluyor." | Cümle kuruluşu aksıyor ("bilgisayarımda oluyor"). | "Telefonda yazdığım not artık bilgisayarı açtığımda orada oluyor." |
| Y18 | EN "Comments after the release" | TR'deki "öne çıkan"ı karşılamıyor. | "Top comments after the release" |

**Dokunulmayanlar, gerekçeyle:** Ay sonu, teşekkür maili, K1, K3 ve K5 gövdeleri doğal, tam cümle ve çelişkisizler. "Muhasebe kapanışı iki gün erken" tuzağına düşülmemiş: mail yalnız yaşanmış bir işi anlatıyor. "Ekip iki kişiyi geçti" bir olgu olarak kalabilir. "Tarih verirsek beklerler; vermezsek sormaya devam ederler." cümlesi ölçülü ama PM ağzından doğal bir tespit; kalabilir. Metinlerde tire yok ve gerçek marka yok (Ekol örneği için bulgu 31'e bakın).

---

## 3. Erdem'in kararı gereken maddeler (kapalı sorular, önerili)

1. **Yatırımcı hazırlığı kalksın mı?** Hazırlık yalnız Series A'da var. Karşılığı görüşmedeki tek bir soruda +%20 şans ve oyuncu bunu görmüyor. **Öneri: evet, kalksın.**
2. **Sprint ortası kâğıtları sprint başına en çok bir tane olsun mu?** Böylece koşu başına ≈70 kâğıt 30–38'e iner. **Öneri: evet.** "52 hafta beklemeden dönmez, koşuda en çok 3 kez" kuralı ancak bu sıklıkta havuzu tüketmeden çalışır.
3. **B2C söz ikizi "kullanıcılara duyurulan tarih" olsun mu?** Kart ancak ekipte müşteri temsilcisi varken gelir. **Öneri: evet.**
4. **Erteleme düşüşü 6 puan olsun ve C'nin eşiği (30 + 3 × (yıldız − 1)) kabul edilsin mi?** **Öneri: evet.** İki planın sayıları artık uyuşuyor.
5. **B2B kesinti kredisi araştırmadaki tabloyla mı (%10 / %25 / %50) verilsin, %20 tavanla mı?** **Öneri: tablo.** Sabaha bırakılan gece kesintisi %25'e düşer. %50'lik basamak B'nin olaylarında neredeyse hiç oluşmuyor.
6. **(Yeni) B doluluğu hiç okumasın mı?** C doluluğu kaldırmayı öneriyor. B okumazsa olasılık yalnız sunucu kademesinden, açık hatadan ve hatalı sürümden gelir; `BASE` 0,10 olur. **Öneri: evet.** C'nin sileceği kodu ve metni B hiç yazmamış olur. C'nin kaldırma önerisi reddedilirse doluluk C'de eklenir.
7. **(Yeni) Not ve video uygulamasına özel B2C metinleri yazılmasın mı?** Kapsam: ≈40 yorum, video belirtileri ve video alıntısı. B yalnız ortak B2C hatlarını ve not uygulamasının çalışan asgarisini yazar. Pazaryerinin ödeme, yorum ve mağaza sesi E'de yazılır. **Öneri: evet.** E'nin "not ve video silinir" sorusuna bağlı; o soru "hayır" çıkarsa bu metinler B'nin yazım adımına geri döner.
8. **(Yeni, teknik) Ay sonu maili 23:40 yerine 22:10–22:55 arasında damgalansın mı?** Kart 23:00'te açılır. **Öneri: evet.** 23:40 kartı gün dönümü adımına iter; o adımda ay kapanışı ve oto kayıt da koşar.

**Ana oturuma not (Erdem kararı değil):**
- C tazelemesinde: (a) kademe çarpanı tablosu B'nin fonksiyonuna bağlanır; (b) memnuniyet ipucu güven terimini "söz ve kesintiler" diye adlandırır; (c) `founder_hours` fiilini C kurar; (d) `incident_playbook`'un açıklaması "kesintiye hazırlık" olur.
- D tazelemesinde: B'nin puan listesi ×5 yapılır; "Testi kısalt" ve K6'nın `covered` seçeneği `escape_chance`'e bağlanır.
- E tazelemesinde: B2C iade ve özür indirimi "üye × üyelik ücreti" üzerinden hesaplanır; yorum kaynağının etiketi "Mağaza".
- Bütün planlarda örnek şirket adları ("Ekol", "Arkas") gerçek şirketlerden uydurma adlara çevrilir.
