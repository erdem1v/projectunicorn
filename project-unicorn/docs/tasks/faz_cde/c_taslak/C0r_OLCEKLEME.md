# C0r · Otomatik ölçekleme araştırması

Görev: PRD_FAZ_C_URUN_HESAP.md §5 (C0r), Karar 1 ("Otomatik ayarla" anahtarı); ERDEM_QCD_CEVAP.md §2.2 C5.
Tarih: 2026-10-18. Bu oturumda 13 WebSearch ve 11 WebFetch yapıldı. Oyun dosyaları fc6b392'den okundu.

## E1'e giden özet (3 satır)

1. **Eşik %80 kalsın; adım "yükü %65'e indirecek en küçük tam birim" olsun (80'de yaklaşık ×1,23; PRD'nin ≈×1,25'i bunun yuvarlağıdır); küçültme yok.** Gerçek bulutta hedef kullanım 50 ile 75 arasında örneklenir, GCP "%85 ve üstünü önermeyiz" der; oyunumuzda 80, mevcut sarı çizgiyle ve %90 kesinti çizgisiyle uyumludur.
2. **Adım sabit sayı değil orandır:** AWS hedef izleme, GCP ve Kubernetes HPA kapasiteyi yükün hedefe oranıyla ölçer ve yukarı yuvarlar; tek büyüme yükü hedefe indirir, sıçrayan yükte de.
3. **Bekleme süresi gerekmez:** gerçek sistemlerin bekleme/ısınma süresi yeni makinenin geç açılmasından ve küçültme salınımından doğar; bizde büyüme hemen işler ve küçültme yoktur. Aynı hafta ikinci büyüme yalnız yük yeniden %80'e varırsa olur (80'den 65'e iniş 15 puanlık doğal banttır).

## 1. Kaynaklı tablo

Eşik / hedef sütunu varsayılanı ya da belgenin verdiği örneği yazar; "örnek" yazan satırda belge varsayılan vermez.

| Kaynak | Eşik / hedef | Adım | Küçültme | Bekleme | URL | Kanıt |
|---|---|---|---|---|---|---|
| AWS EC2 Auto Scaling, hedef izleme | Varsayılan yok; örnek %50 CPU. "set the target value as high as possible with a reasonable buffer for unexpected traffic increases" | Orantılı: metrik değerinden gereken örnek sayısı hesaplanır, yukarı yuvarlanır (1,5 örnek gerekirse 2 eklenir) | Var ama temkinli: "scaling in more gradually when traffic is decreasing"; 0,5 örnek çıkarmak yükü hedefin üstüne atacaksa küçültmez ("won't cause oscillation"); isteğe bağlı kapatılabilir | Kopma yok. Isınma süresi: ısınan örnekler metriğe sayılmaz, ısınırken büyüme sürerse onlar kapasiteye sayılır; büyüme sürerken küçültme bloklanır | https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html | fetched |
| AWS EC2 Auto Scaling, adım ölçekleme | Alarm eşiğine göre aşım büyüklüğü basamakları; belgenin örneği: %60'ta +10 örnek, %75'te +30, %85'te +40; başka örnek: %60'ta %10, %70'te %30 | Basamaklı; `ChangeInCapacity` (sabit) ya da `PercentChangeInCapacity` (oran); oranda `MinAdjustmentMagnitude` ile en az birim. Örnek: %25 eklemek, 4 örnekte 1'dir, asgari 2 verilmişse 2 eklenir | Ayrı bir küçültme politikası; "choose an adequate margin between the scale-out and scale-in thresholds to prevent flapping" | Isınma süresi aynı mantık: ısınan örnek sonraki hesapta kapasiteye sayılır, aynı basamaktaki ardışık ihlaller tek işlem olur | https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html | fetched |
| AWS EC2 Auto Scaling, bekleme (cooldown) | Eşik konusu değil | Yalnız basit ölçekleme politikasına uygulanır | Küçültme için ayrı daha kısa bekleme önerilir (örnek metin) | Varsayılan 300 sn. "Target tracking and step scaling policies can initiate a scale-out activity immediately without waiting for the cooldown period"; AWS basit ölçeklemeyi ve cooldown'u önermez | https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-scaling-cooldowns.html | fetched |
| Google Cloud yönetilen örnek grubu (MIG) | CPU hedefi örnek: 0,60 ve 0,75; sayfa varsayılan vermez, "Google recommends that you don't set a target CPU utilization of 85% or higher". Ayrı bir arama özeti (Ansible modül belgesi) varsayılanı 0,6 gösteriyor | Hedef ortalamanın üstündeyse VM eklenir; formül yazılı değil. Yük %100'e yakınken "the autoscaler increases the number of virtual machines by 50% at most" (sayfa bu davranışın değişebileceğini söyler). Sonuç yukarı yuvarlanır ("always acts conservatively by rounding up or down") | Var; kararı kararlılık süresindeki tepe yüke dayanır ("recommended target size based on peak load over the stabilization period"). İsteğe bağlı kontrol: zaman penceresinde en çok kaç VM çıkarılabilir (`maxScaledInReplicas`, `timeWindowSec`; örnek 10 VM / 20 dk) | Başlatma süresi varsayılanı 60 sn; küçültme kararlılık süresi varsayılanı 10 dk (0 ile 3600 sn arası ayarlanır) | https://docs.cloud.google.com/compute/docs/autoscaler/scaling-cpu ; https://docs.cloud.google.com/compute/docs/autoscaler/understanding-autoscaler-decisions ; Ansible özeti: https://docs.ansible.com/ansible/latest/modules/gcp_compute_autoscaler_module.html | fetched (60 sn başlatma, %85 uyarısı, %50 tavan: scaling-cpu sayfası); search_snippet (0,6 varsayılan, 10 dk kararlılık, kontrol alanları) |
| Kubernetes HPA | Hedef kullanım kullanıcının verdiği değerdir, varsayılan yok. Tolerans: oran 1,0'a 0,1 kadar yakınsa işlem yapılmaz | Orantılı: `desiredReplicas = ceil[currentReplicas × currentMetricValue / desiredMetricValue]`. Varsayılan hız sınırı: 15 sn'de 4 pod ya da mevcut kopyaların %100'ü (büyük olan) | Var; varsayılan politika 15 sn'de %100'e kadar çıkarabilir, ama kararlılık penceresi 300 sn | Büyütmede kararlılık penceresi 0 ("scaled up immediately"), küçültmede 300 sn; denetim aralığı 15 sn | https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/ | fetched |
| Software Inc. (oyun) | Belgeli eşik yok. Oyuncu raporu: sunucular "40% capacity to over 100% capacity" arasında salınıyor, sözleşmeye göre | Elle: sunucu rafı boyutu seçilir. Geliştirici "bigger server in a future update" diyor; otomatik büyüme anılmıyor | Yok (yalnız el ile) | Yok | https://steamcommunity.com/app/362620/discussions/0/133256080240773413 | fetched |
| Mad Games Tycoon 1 (MGT2'nin öncülü; MGT2 için ayrı satır aşağıda) | Eşik yok. 2016 değişiklik notu: sunucu odası yoksa MMO pazardan hemen çıkmaz, abonelikler haftada üçte bir düşer | Yok | Yok | Yok | https://games.softpedia.com/progChangelog/Mad-Games-Tycoon-Changelog-144703.html | search_snippet |
| Mad Games Tycoon 2 | Aramalar sunucu kapasitesi ya da otomatik büyüme mekaniği bulmadı (yalnız "sunucu odası" oda türü ve sunucu giderinin ayrı gösterilmesi). Eşik, adım, küçültme, bekleme: bilinmiyor | - | - | - | yok | kanitsiz |
| Startup Company (oyun) | İki arama sonuç vermedi. Eşik, adım, küçültme, bekleme: bilinmiyor; model bilgisinden doldurmuyorum | - | - | - | yok | kanitsiz |

Okuma notu: oyun satırları zayıftır; üç oyundan yalnız Software Inc. için bir kanıt var ve o da "otomatik ölçekleme yok, oyuncu elle yönetir, yük 100'ü aşabilir" yönünde. Bu bir doğrulama değil, bir boşluk bulgusudur. Karar gerçek bulut belgelerine dayanır.

## 2. Tablodan çıkan dört bulgu

1. **Hedef kullanım hep 100'ün epeyce altında.** AWS: "as high as possible with a reasonable buffer"; örnek %50. GCP: örnekler %60 ve %75, %85 ve üstü önerilmez. Pay, beklenmedik artışı karşılamak içindir (AWS aynı paragraf).
2. **Adım oran çıkar, sabit sayı değil, yukarı yuvarlanır.** AWS hedef izleme, GCP ve HPA (`ceil[...]` formülü) kapasiteyi yükün hedefe oranından hesaplar. Adım ölçeklemede oran ya da sabit seçilebilir, oran seçilince asgari birim verilebilir (`MinAdjustmentMagnitude`): bu bizim "en az 1 birim" kuralının karşılığıdır.
3. **Büyütme hızlı, küçültme yavaş.** HPA: büyütme penceresi 0, küçültme 300 sn. GCP: küçültme kararlılığı 10 dk, tepe yüke bakar. AWS: küçültme "more gradually", büyütme sürerken bloklu. Üçünde de küçültme vardır ve üçünde de bilerek yavaştır.
4. **Bekleme iki nedenle vardır:** (a) yeni makine açılana kadar geçen süre (AWS ısınma, GCP başlatma 60 sn); (b) küçültme ile büyütme arasında salınım (AWS "flapping", GCP/HPA küçültme penceresi). Büyütmenin kendisi beklemez (AWS: cooldown beklemeden hemen, HPA: hemen).

## 3. Oyunumuza çeviri

Oyunun bugünkü sabitleri (fc6b392, `infra_system.gd`): bir birim B2C'de 1.000 kullanıcı, B2B'de 50 koltuk (`:30-31`); sarı çizgi %80, aşım %100 (`:59-61`); kapasite ±1 birim (`:50`); fatura günlük, aylık/30 (`:77`). PRD'ye göre bir tik bir haftadır, kapasite haftalık faturalı birimdir, Artır/Azalt hemen işler, eşik yalnız büyüme anlarında (imza, kitle değişimi) okunur (PRD Karar 1).

Gerçek sistemden farklar, çevirinin dayanağı:
- Gerçek sistem dakikada bir ölçer; bizde ölçüm büyüme anlarındadır ve arada kapasite sabittir. Bu yüzden iki ölçüm arasında yükün ne kadar sıçrayacağı kesin değildir, tampon (80 ile 100 arası) bu yüzden büyük tutulur.
- Bizde yeni kapasite ısınmaz: Artır "hemen işler" (PRD Karar 1), yük yeni kapasiteye göre okunur.
- Bizde otomasyonun küçültmesi yok (PRD Karar 1).

### 3.1 Eşik %80: doğrulanıyor

- Gerçek bulutta hedef 50 ile 75 civarında örneklenir ve %85+ önerilmez; %80 hedef olarak yüksektir, ama bizde %80 **tetik**tir, hedef değil: büyüme yükü %65'e indirir (bkz. 3.2). Büyüme sonrası yük gerçek örneklerin içine düşer.
- %80, kodun mevcut sarı çizgisidir (`infra_system.gd:60`), yani oyuncu zaten bu çizgiyi tanıyor. PRD'deki yeni kesinti çarpanı %90'da başlar (Karar 1); tetik ile çarpan arasında 10 puan kalır. Ölçüm büyüme anlarında okunduğundan, iki ölçüm arasında yükün 10 puandan fazla sıçrayabileceği haftalarda tampon biter. %70 tetik bu riski azaltır ama boş payı hep yaklaşık %30'da tutar ve PRD'nin "paranın görünür bedeli" amacıyla (Karar 1, Oynanışa etkisi) çelişir: Erdem'in sözü "%70 ya da %80" idi (ERDEM_QCD_CEVAP.md:74-77); araştırma %80'i destekler, ikisini birden ayıran bir kanıt yoktur.
- Değişmesi için gerekçe yok.

### 3.2 Adım: "yükü %65'e indirecek en küçük tam birim" (PRD ile aynı, kuralı netleştirilmiş hâli)

Önerilen kural: **yeni kapasite = ⌈hizmet edilen birim ÷ 0,65⌉**, yani ayarla-tetikle ikilisi 80 / 65.

- Gerçek sistemlerin üçü de orantılıdır; sabit "×1,25" yalnız yükün tam %80 olduğu anda yükü %64'e indirir (80 ÷ 1,25 = 64). Yük sıçramışsa (örnek %100) ×1,25 yükü %80'de bırakır ve ikinci büyüme gerekir. Orantılı kural her durumda %65'in altına iner.
- %80 tetikte kural kapasiteyi yaklaşık ×1,23 yapar (0,80 ÷ 0,65 = 1,231). PRD'nin "yaklaşık ×1,25"i bu yuvarlak sayıdır; ipucu metni "yaklaşık %65" der, bu kural onu tutar. İpucu ve belge ×1,25 değil "yük %65 olacak kadar" demeli.
- Tam birime yuvarlama yukarıdır (AWS "rounding up", GCP "rounding up", HPA `ceil`). Küçük kapasitede yuvarlama oranı büyütür; örnek: 1 birim ve %80 yük, sonuç 2 birim (yük %40); 4 birimde 3,2 ÷ 0,65 = 4,92, sonuç 5 birim (yük %64); 20 birimde 16 ÷ 0,65 = 24,6, sonuç 25 birim (+%25, yük %64). "Asgari 1 birim" kuralı kendiliğinden tutar: tetikte ⌈x⌉ en az mevcut kapasite artı 1'dir.
- Üst sınır önerisi yok: HPA'nın 15 sn'de %100 ve GCP'nin %50 tavanı, makinenin dakikalar içinde yükü ölçmesinden doğar. Bizde ölçüm seyrektir ve büyütme parası görünür bir satırdır.
- Elle Artır/Azalt adımı: **birimin %10'u, en az 1 birim**. AWS adım ölçeklemenin oran + asgari birim düzenine uyar (`MinAdjustmentMagnitude`). Otomatik adım (≈+%23) elle adımdan (%10) bilerek büyüktür: otomasyon kaçırılan haftaları kapatır, oyuncu ince ayar yapar.
- Küçük kapasitede elle adım 1 birim sabittir (10 birimin altında %10 birimin altına düşer): 1 birimde elle +%100, 10 birimde +%10, 1.000 birimde +100 birim. Bu, "kural 1-50 kişi arasında kırılmamalı" kuralıyla (hafızadaki Erdem notu) çelişmez: oran geniş aralıkta çalışır, yalnız en küçük kapasitede tam birim sınırı vardır.

### 3.3 Küçültme yok: gerçek sistemle çelişmiyor, yalnız onun bir seçeneğidir

Gerçek sistemlerin hepsi küçültür, ama üçü de bilerek yavaş: HPA 300 sn, GCP 10 dk, AWS "scaling in more gradually"; AWS ayrıca küçültme kısmını kapatmaya izin verir. PRD'nin gerekçesi (Karar 1): küçülten otomasyon boş payı oyuncunun görmediği anda eritir, kararı oyuncudan alır. Araştırma bu gerekçeyi çürütmez; "küçültme yok" seçilebilir bir uç noktadır (AWS'te `disableScaleIn` karşılığı). Sonuç: **küçültme yok**, Azalt oyuncuda. Maliyeti: kitle ya da koltuk düşünce kapasite şişkin kalır ve fatura sürer; bunu oyuncu "Yük %"te ve "boş pay"ın parasında görür, Azalt ile kapatır. Bu zaten PRD'nin tasarladığı karardır.

### 3.4 "Bekleme" bizde: zamanlı bekleme gerekmez, tek kural yeter

Gerçek bekleme/ısınmanın iki nedeni (bkz. 2.4) bizde yok: yeni kapasite hemen sayılır ve küçültme yoktur, yani salınım imkânsızdır. Aynı hafta iki büyümenin olup olmaması için öneri:

- **Zamanlı bekleme (haftada en çok bir büyüme gibi) koymayın.** Gerekçe: büyüme yükü %65'e indirir; ikinci büyüme ancak yük aynı hafta içinde yeniden %80'e varırsa tetiklenir, bu da mevcut kapasitenin %23'ünden fazla yeni yük demektir (örnek: 65'ten 80'e). Bu durumda ikinci büyüme haklıdır, ve engellenirse yük %90'ı geçip kesinti çarpanına girer (PRD Karar 1); oyuncu açtığı otomasyonun tam bu anda çalışmamasını beklemez.
- **Teknik koruma:** her değerlendirme en çok bir büyüme yapar (döngü yok); her yeni büyüme anı (imza, kitle değişimi) yeni değerlendirmedir. Hesap bir kez oranla tam indiğinden bir değerlendirmede ikinci büyüme zaten gerekmez.
- **Gösterge:** blokta yalnız son otomatik büyüme yazar (PRD Karar 1, "tek satır"); aynı hafta iki büyüme olursa satır sonuncuyu gösterir, ilkini ezmesi kabul. Hafta içi iki büyüme çok sık çıkıyorsa PROBE satırı bunu sayar ("otomatik büyüme" alanı PLAN_C C1'de zaten var); sıklık çoksa tetik %80'den %85'e değil, hedef %65'ten %60'a çekilir (sıklık düşer, para artar). Bu bir ölçüm kararıdır, E1'e öneri olarak girmez.
- **Anahtarın açıldığı an:** yük zaten %80 ya da üstündeyse ilk değerlendirme sonraki büyüme anında yapılır, açılışta ayrıca büyütme yapılmaz. (Gerçek kaynakta karşılığı yok; PRD sustuğu için varsayılan olarak yazdım, C1 adımında teyit istenir.)

## 4. Önerinin PRD'ye karşı durumu

| PRD önerisi (Karar 1, §5) | Araştırma | Karar |
|---|---|---|
| Eşik %80 | Gerçek hedefler 50 ile 75; %80 tetik olarak güvenli, %85+ önerilmez (GCP); oyun içi sarı çizgiyle aynı | Doğrulanıyor |
| Adım yükü yaklaşık %65'e indirecek kadar, ≈×1,25 | Üç gerçek sistem de orantılı ve yukarı yuvarlar; sabit ×1,25 sıçrayan yükte yetmez | Doğrulanıyor, kural "yeni kapasite = ⌈hizmet edilen ÷ 0,65⌉" diye yazılsın; "×1,25" ipucundan çıksın |
| Küçültme yok | Gerçek sistemler küçültür ama yavaş ve kapatılabilir (AWS); çelişki yok | Doğrulanıyor |
| Artır/Azalt adımı birimin %10'u, en az 1 birim | AWS adım ölçeklemenin oran + asgari birim düzeniyle aynı | Doğrulanıyor |
| (bekleme) PRD'de yok | Gerçek bekleme gerekçeleri bizde yok | Zamanlı bekleme eklenmez; her değerlendirme en çok bir büyüme yapar |

## 5. Sınırlar

- Üç oyunun hiçbiri için eşik ve adım kaynağı bulunamadı (Software Inc. dışında hiç kanıt yok, onda da otomasyon yok). Bu, "oyunlar ne yapıyor" sorusunun cevapsız kaldığı anlamına gelir; gerçek bulut belgeleri tek dayanaktır.
- GCP'nin %50 büyüme tavanı belgenin kendi uyarısıyla "değişebilir" diye geçer; dayanak olarak kullanılmadı.
- Fetch araçları sayfayı özetleyen küçük bir modelden döner; tırnak içi metinler o özetten alındı. GCP varsayılan hedef (0,6) yalnız arama özetidir, resmi GCP sayfası varsayılan vermedi.
