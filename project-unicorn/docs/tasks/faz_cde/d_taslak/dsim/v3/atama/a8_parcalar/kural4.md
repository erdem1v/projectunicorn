### 4.1 Kural

Planlayıcı iki katmandır: her atama anında çalışan bir **dağıtım kuralı** (reaktif) ve her hafta başında kuralın seçeneklerini ileri oynatıp en iyisini seçen **sprint planı** (proaktif). İkisi de aynı motoru (`week3`) kullanır; ayrı bir "tahmin motoru" yoktur.

**Dağıtım kuralı** (kod: `a8plan.py`, `alloc_p8` ve `assign_e8`). Atama anı: sprint başı, her hafta başı ve bir kartın aşaması bittiği her an (kişi boşalır, kural o anda yeniden çalışır). Her satır (Tasarım, Yazılım, Test) için, boşta olan kişilerle:

1. **Ufuk.** Her kartın o aşaması için "en geç ne zamana kadar bitmeli" bulunur. Kart, başka iş yokmuş gibi her aşamada kadro tavanı kadar en iyi uygun kişiyle (gereksinimi karşılayanlarla) bitirilirse ne kadar sürer? Bu süre bu sprinte sığıyorsa ufuk sprintin sonudur; sığmıyorsa kartın bitebileceği ilk sprintin sonudur (Erdem'in büyük kartı için 4. haftanın sonu). Aşamaya, kartın kalan işindeki payı kadar süre düşer.
2. **En az kişilik ekip.** Kartlar **plan sırasıyla** dolaşılır. Her karta, aşamasını ufkunda bitirecek hızı tutturan **en az kişilik** ekip ayrılır (kartta zaten çalışanlar sayılır; %5 pay vardır, bir tutam eksikle bir kişi fazlaya sıçranmasın diye). Boşta kimse kalmadıysa sıradaki kartlar bekler; kişi boşalınca yine plan sırasıyla dolar. Büyük kart herkesi toplamaz: yalnız ufkunu tutturacak kadarını alır.
3. **Kimse boşta kalmaz.** Ekipler kurulunca artan kişiler kartları plan sırasıyla kadro tavanına kadar doldurur (kartı hızlandırır). Yalnız gereksinimi karşılamayan kişi boşta kalabilir.
4. **İlke (Karar 19).** Gereksinimin altındaki kişi hiçbir adımda karta girmez. Ekipler belirlendikten sonra, kartların ufuk hızını bozmayan yer değişimleriyle daha karmaşık kartın (puan × gereksinim büyük olan) ekibi daha iyi kişilerden olur, basit kart zayıfları alır. Yani ilke "aynı plan amacını tutan seçenekler arasında" işler; plan amacı ilkenin önündedir.
5. **Satır seçimi.** Birden çok işi yapabilen kişi (kurucu, testi de yapan geliştirici) önce ihtiyacı karşılanmamış kartın satırına girer; "asıl işi" olan kişi ikincil işi olan kişiden önce yerleşir. Böylece "herkes büyük kartın yazılımına yığıldı, biten kartın testini yapan yok" olmaz.
6. **Kalır.** Kişi bir kartın aşamasına girince aşama bitene kadar orada kalır (sprint ve hafta sınırını aşar). Kural bunu bilerek kurar: ekip büyüklüğü ve ufuk, kimin ne kadar süre kilitleneceğini hesaba katar (§4.1'deki "saklamalı" seçenekler).

**Sprint planı** (kod: `week8`, `decide`, `rollout`). Her hafta başında (sprint başı ve 2. hafta başı) planlayıcı, dağıtım kuralının **8 seçeneğini** o haftadan sprint sonuna aynı motorla ileri oynatır (kopya kartlar, gerçek puanlar, gerçek hata zarı akışı, çekme kuralı dahil) ve **plan puanına** göre en iyisini seçer:

| Seçenek | Anlamı |
|---|---|
| ufuk payı 1,0 / 0,7 / 0,45 | Aşama ufkun tamamını (tam zamanında), %70'ini ya da %45'ini kullanacak şekilde boyutlanır; pay küçüldükçe karta daha çok kişi girer, kart daha erken biter, daha az kart aynı anda yürür. |
| kadro tavanı | Kartlar plan sırasıyla kadro tavanı kadar kişi alır (R'nin doldurması gibi, ama gereksinime uyar). |
| T_plan | Tarifin 1. adımı plan sırasıyla (A6 tanı kolu). |
| ufuk payı 1,0 / 0,45 / kadro tavanı, **saklamalı** | Yukarıdakilerin, asıl işi başka satırda sprintte hâlâ bekleyen ikincil kişiyi (örneğin Yazılım satırında testçi) o satıra kilitlemeyen hâli. |

Plan puanı sırayla: (a) sprintte bitirilen kartlar, plan sırasına göre ağırlıklı (her sıra bir öncekinin %85'i; 8'den fazla kartlı planda düşüş yumuşatılır ki ilk 8 sıranın toplam düşüşü planın uzunluğundan bağımsız kalsın ve büyük ekibin sondaki kartları da sayılsın); (b) boşta kalan insan-hafta (aradaki fark kapasitenin %3'ünün altındaysa "aynı"); (c) ilerleme (%2 altında "aynı"); (d) eşitlikte **ilke puanı** (iş × kartın karmaşıklığı × kişinin yıldızı toplamı büyük olan). Seçilen seçeneğin yer değişimli hâli, yer değişimsiz hâline göre plan puanında gerçekten kötüyse yer değişimsiz hâl seçilir (ilke yalnız eşitlikte işler). Söz kartı plan sırasında zaten öndedir (öneri sırası, Karar 12) ve ayrıca öne alınmaz (Karar 20).

**Tahmin = sonuç.** Plan oynatması (sprint planı ekranındaki tahmin) ve gerçek oynatma aynı fonksiyonu çalıştırır. Hafta başı seçimi durumun bir imzasına (kartların ilerlemesi, kişilerin hızları, kimin nerede kilitli olduğu) bağlı olarak saklanır: plan oynatması seçimi hesaplar, gerçek oynatma aynı durumu görünce aynı seçimi kullanır (hesaplamadan). Durum plandan sapmışsa (örneğin biri plandan yavaş çalışmışsa) imza tutmaz ve planlayıcı o hafta seçimi yeniden hesaplar: **reaktif yeniden kurma** budur (§6, tepki testi). İmza yalnız hafta başında sorulur; hafta içindeki sapmaya seçim değil dağıtım kuralı tepki verir (aşama bitişlerinde). Kuralın içinde rastgelelik yoktur; hata zarı kartın kimliğine bağlı ayrı akıştır. Dağıtım kuralı zarı kullanmaz, ama ileri oynatmalar aynı zar akışını çektiği için testte çıkacak düzeltme işini görür ve seçim bundan etkilenebilir (§7, "Hata zarı planı bilir").

### 4.2 Plan süresi

Bir sprint planı hafta başı iki seçim yapar (sprint başı ve 2. hafta başı); her seçimde 8 seçenek ve yer değişimli/değişimsiz karşılaştırması için bir ek oynatma, yani **sprint başına yaklaşık 18 oynatma** (seçilen seçenek T_plan ise yer değişimi karşılaştırması yapılmaz; tek kişilik ekipte seçenek olmadığı için 0). Oynatmalar kalan süreyi oynatır (ilk seçimde sprintin tamamı, ikincisinde yarısı). Süre bu makinede, Python'da, tek işlemcide ölçüldü (oyunun kendi dilinde farklı olur; Godot koşturulmadı, §7):

{{tab:plan}}

Oyunun plan ekranı her "+" tıklamasında yeniden hesaplar. Bu hesabın üç parçası var: kartın sprinte girip girmeyeceğini bakan alım sınaması (R ve Tarif'te de var, süresi burada ölçülmedi), tahmin oynatması ve P'nin seçimi. P'de alım sınaması seçilen seçeneği değil hafif kipin kuralını (ufuk payı 1,0, tek seçenek) oynatır (`a8plan.week8`, `probe` dalı; A9 incelemesi): kartın "iş alır mı" sınaması ile sprintte uygulanan yerleşim aynı değil. Tahmin = sonuç bundan etkilenmez (tahmin seçilen yerleşimle oynatılır), ama alım sınamasının geçirdiği bir kart seçilen yerleşimde iş almayabilir; bunun sıklığı ölçülmedi. P'nin payı yukarıdaki tablodur; ileri oynatmasız hafif kip (`P_sabit`, tek seçenek, tek oynatma) ne kazandırıp ne kaybettirdiği §4.3'te.

### 4.3 Ne işe yarıyor: kapatarak ölçüm

Aynı 20 tohum, 3, 6 ve 12 kişi (sınırsız ve kaynaklı arz). `P_sabit` = ileri oynatma yok (her hafta tek seçenek: ufuk payı 1,0, yer değişimli); `P_core5` = saklama seçenekleri yok (5 seçenek); `P_ns` = ileri oynatma yok ve yer değişimi yok; `P_np` = "kalır" kapalı (tanı); `T_plan_np` = T_plan'ın "kalır" kapalı hâli (tanı).

*MVP haftası*

{{tab:abl_mvp}}

*Açık hata*

{{tab:abl_acik}}

*Teslim (puan/hf)*

{{tab:abl_teslim}}

*Kaçan söz (kaynaklı arz)*

{{tab:abl_soz}}

*Doğan hata*

{{tab:abl_dogan}}

Eşli farklar (bir seçeneğin ya da adımın etkisi; her satır a − b):

*MVP haftası*

{{tab:abl_fark_mvp}}

*Açık hata*

{{tab:abl_fark_acik}}

*Teslim (puan/hf)*

{{tab:abl_fark_teslim}}

*Doğan hata*

{{tab:abl_fark_dogan}}

*Kaçan söz (yalnız kaynaklı arz)*

{{tab:abl_fark_soz}}

{{dosya:a8_parcalar/kural43.md}}
