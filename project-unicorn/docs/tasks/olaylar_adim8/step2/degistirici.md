# OLAYLAR 2. adım: değiştirici tablosu

Her şıkkın kazancı, bedeli ve riski. Bütün sayılar [WORKING]; kartın JSON'unda ya da EvTuning'de durur. Erdem'e bilgi olarak gider, onay sorusu değildir.

## Örnek dünyalar

- **Bootstrap:** Kurucu + 2 çalışan (junior geliştirici ~$3.750, junior müşteri temsilcisi ~$2.800), Ev, sunucu ~$240 → ~$6.800/ay, haftalık ~$1.590. MRR ~$2–4K, hesaplar 1★ $250–500 ve 2★ $750–1.500.
- **Traction:** 7 çalışan (geliştirici ×2, temsilci ×2, testçi, satışçı ×2), İş hanı $4.000, sunucu ~12 birim cloud $1.440 → ~$34.800/ay, haftalık ~$8.100. MRR $15–50K, ~20 hesap, 2★ ve 3★ ($2.000–3.500).
- **Series A:** 13 çalışan, Plaza $8.000, sunucu ~42 birim cloud $5.040 → ~$80.600/ay, haftalık ~$18.800. MRR $80–120K (TRACTION_MRR_TARGET 120.000), ~60 hesap.

Kaynak: STAFF_LADDER (run_probe.gd:1478), SALARY_BANDS_BY_LEVEL (hr_constants.gd:586), OfficeConstants kiraları, InfraSystem birim fiyatı (infra_system.gd:23-25), SEAT_BAND ve koltuk fiyatı ~$50 (sales_constants.gd:114-131). Kurucunun maaşı 0. Haftalık gider = daily_burn × 7 = aylık × 7/30.

## Ölçek sözlüğü

- **moral:** biraz ±4, yükselir/düşer ±6, çok ±10 (görev: biraz 3–5, çok 8–12).
- **memnuniyet trust delta:** biraz ±4, artar/düşer ±8 (kâğıtların −8'i), çok +10 (TRUST_OFFSET_MAX) / −12 (kırık söz). trust_offset tikte 2,8 söner: −8 ~3 hafta, −12 ~4 hafta (b2b_constants.gd:280-282).
- **zaman:** bir gün = productivity_mod −20 / 1 hafta; iki gün −40 / 1 hafta; bir haftalık iş −50 / 2 hafta; bir sprintlik iş −50 / 4 hafta (productivity_terms [-50, +30], 1–8 hafta; tek kişilik şirkette ≥ −30, ≤ 2 hafta).
- **kart puani:** kâğıtlarla aynı: +5 / +10 / +15, takip kartı 5 (paper.reopen_points), hata 1. Geliştirici haftada 10 × Y(s): 2★ ~8,6, 3★ ~11,6, 4★ ~15,4 puan.
- **para:** en çok ~2 haftalık gider (finance.daily_burn × −14); kişiye bağlı tutar hr.salary + amount_slot, hesaba bağlı musteri.mrr + amount_slot. İstisna #30 ödülü (karar 3).
- **marka itibar:** marka ±1–3; itibar ±1–3, kumarın kötü dalında −8 (Erdem onaylı #31).

## İhtimal tablosu (EvTuning, tek yer)

| Seam | Değer | Kullanan |
|---|---|---|
| `olay.odds_10` | 0,1 | kriz.acik S3, kriz.acik.b2b S3, odul.final S3 |
| `olay.odds_15` | 0,15 | calisan.kaba_musteri S2, odul.final S2 |
| `olay.odds_20` | 0,2 | rakip.panel S1 |
| `olay.odds_25` | 0,25 | dunya.veri_nerede S3 |
| `olay.award_live_odds` | 0,25 − 0,05 × min(urun.open_bugs, 3), taban 0,10 [WORKING] | durumdan |
| `olay.award_live_slip` | urun.open_bugs == 0 ise +1, değilse −2 (marka; #30 kayıp dalı) [WORKING] | durumdan |
| `olay.year_roll_same_leave` | EvDice.unit('year', yıl, kart id, '') < 0,5 (karar 4e) [WORKING] | durumdan |

Zarın anlamı: Motorda odds_seam on_pass ihtimalidir (engine.gd:645-648: unit < odds → on_pass). Görev çipi '%15 ihtimalle:' + on_fail yazar. Tablo değerleri yazılı riskin ihtimalidir; 4. adım ya riski on_pass'a koyar ya da check'i 'risk dalı ihtimali' olarak çevirir (bugün check kullanan kart 0). Bu tabloda her kumar 'risk dalı' ve 'iki dal ortak' diye yazıldı; motor bir şıkta effects ile check'i birlikte koşmadığı için ortak etkiler iki dala da yazılır.

Öbür [WORKING] sayılar: fesih bildirimi hafta 4 (karar 6, B2BSalesSystem sabiti); ortaya cikis gecikmesi 3 hafta (#25 → world.data_claim_exposed); basin gecikmesi schedule 4 hafta + hedef kartın delay_weeks [0,4] = 4–8 hafta (#31); kurulum vurgusu +0,05 iğne, 13 hafta (#26); indirim X %15, 52 hafta (#21); erken deneme A B +6 / −8 (#19).

## calisan.bilgisayar (`team.work_laptop`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Yeni bir bilgisayar gönder | Mert'in morali biraz yükselir (75'ten 79'a: 76 eşiğini geçer, iki hafta kadar verim +%5). | Kasa yaklaşık bir haftalık gider kadar azalır. | Yok. | Kasanın pisti 6 aydan uzunken; ilk çalışanın hızı ürünün hızıyken. |
| Kendi eski laptopunu gönder | Kasa korunur. | Mert'in morali biraz düşer; eski laptopla dört hafta verimi %10 düşer. | Yok. | Pist 3 aydan kısayken. |

- **1. şığın sayıları:** add_cash amount_seam finance.daily_burn × amount_mult −7 (bir haftalık gider), label: yeni 'equipment' etiketi (3. adım; ONE_TIME_LABELS'ta ekipman yok). change_morale scope employee +4.
  - **Örnek dünyalar:** Bootstrap, ilk çalışan Ev'de: gider maaş ($3.000–4.500) + sunucu (~$120) ≈ $3.100–4.600/ay → çip ≈ $730–1.080 (Erdem'in onayladığı $1.000'ın ölçeği). Traction ve Series A: kart gelmez (koşul).
- **2. şığın sayıları:** change_morale scope employee −4; productivity_mod scope employee pct −10 weeks 4.
  - **Örnek dünyalar:** Bootstrap: junior geliştirici (Y(4)≈0,86 → ~8,6 puan/hafta) dört haftada ~3,4 puan kaybeder, maaşının ~$350'si kadar iş. Traction ve Series A: kart gelmez (koşul).

- **Cevap gelmezse:** change_morale employee −6 ve productivity_mod employee −10 / 4 hafta (bilgisayar hiç gelmedi: kendi gürültülü makinesiyle sürer). expires_weeks 2 (EXPIRY_LOW_STAKES_WEEKS).
- **Tekrar:** Koşuda bir kez: latch one_shot; family_subject once (yalnız ilk çalışan).
- **Neden hiçbir şık öbürünü geçmiyor:** Para ↔ kişi: 1. şık parayı verir, moral ve verim alır; 2. şık parayı korur, moral ve dört haftalık verim öder. Pist kısayken 2., uzunken 1. şık iyidir.
- **Not:** Erdem'in onayladığı 2. şık sonucu 'Kasa değişmez, morali biraz düşer' idi; tek başına −4 moral 75'lik yeni çalışanda verim bandını değiştirmez (MORALE_PACE_STEPS 50–75 arası 0), şık oynanışta bedava kalırdı. Verim satırı bu yüzden eklendi (metin_ekleri).

## calisan.dugun (`team.wedding_invite`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Düğüne git, tam altın tak | Ece'nin morali çok yükselir (+10). | Kasa, Ece'nin aylık maaşının %10'u kadar azalır. | Yok. | Ece kilit bir kişiyken ya da morali 50'ye yaklaşmışken (kaçma riski 35'in altında başlar). |
| Düğüne git, çeyrek altın tak | Ece'nin morali yükselir (+5). | Kasa, Ece'nin aylık maaşının %3'ü kadar azalır. | Yok. | Moral orta bantta (50–75) ve kasa rahat değilken. |
| Gidemeyeceğini söyle, çiçek gönder | En ucuz cevap; moral yerinde kalır. | Kasa, maaşının %1,5'i kadar azalır; moral kazancı yok. | Yok. | Kasa çok darken ya da Ece'nin morali zaten 80'in üstündeyken. |

- **1. şığın sayıları:** change_morale scope employee +10; add_cash amount_seam hr.salary + amount_slot employee × amount_mult −0,10, label: yeni 'gift' etiketi (3. adım; yoksa 'retention').
  - **Örnek dünyalar:** Bootstrap: junior tasarımcı $2.250–3.375 → $225–340 (haftalık giderin ~%15–20'si). Traction: orta geliştirici $6.750 → $675 (~%8). Series A: kıdemli geliştirici $12.000 → $1.200 (~%6).
- **2. şığın sayıları:** change_morale scope employee +5; add_cash amount_seam hr.salary + amount_slot employee × −0,03, label gift.
  - **Örnek dünyalar:** Bootstrap: $70–100. Traction: $200. Series A: $360.
- **3. şığın sayıları:** add_cash amount_seam hr.salary + amount_slot employee × −0,015, label gift. Moral fiili yok (çip değişmeyeni yazmaz).
  - **Örnek dünyalar:** Bootstrap: $35–50. Traction: $100. Series A: $180.

- **Cevap gelmezse:** change_morale employee −6 (davete cevap verilmedi). expires_weeks 2.
- **Tekrar:** Kişi başına bir kez: family_subject once, latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** Üç basamaklı para ↔ moral merdiveni: her basamak daha çok para verir, daha çok moral alır. 3. şıkkın tek kazancı ucuzluğu; 1. şık en pahalı. Hiçbiri öbürünü iki eksende birden geçmez.

## calisan.yuksek_lisans (`team.master_degree`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Tebrik et, son ayında işini devretsin | Maaş yükü dört hafta sonra kalkar; Elif dört hafta daha çalışır. | Elif dört hafta sonra ayrılır (tehlike çipi); ayrılışta kalan herkesin morali −5. | Yok. | Elif'in rolünde yedeği varken ya da pist kısa ve maaştan kurtulmak işe yarıyorken. |
| Okulu bir yıl ertelemesini rica et, terfi teklif et | Elif kalır, junior'dan orta seviyeye geçer, morali ~+12 (terfinin kendi kazancı). | Maaşı kalıcı olarak %15 artar. | Yok (metin kesin kalış yazar, onaylı). | Elif rolünde tek kişiyken ya da ekip büyürken. |

- **1. şığın sayıları:** schedule_event team.master_degree_farewell delay_weeks 4 (ayrılış o kartta employee_leaves). Ekip morali −5 motorun kendisidir (HRMoraleSystem._charge_departure, MORALE_FIRE_TEAM 5).
  - **Örnek dünyalar:** Bootstrap: junior testçi $3.375/ay tasarruf (giderin ~%50'si), ama tek testçi gider. Traction: ~%10. Series A: ~%4.
- **2. şığın sayıları:** HRActions.apply_promotion(emp, 15) tek kapıdır: maaşı %15 artırır, last_raise_day'i kurar, moral promotion_morale_gain(15) ≈ +12 (%10 → 8, %25 → 20 doğrusal). apply_raise AYRICA çağrılmaz: ikisi birlikte %32'lik zam olur.
  - **Örnek dünyalar:** Junior testçi $3.375 → +$506/ay. Bootstrap (~$6.800/ay gider): +%7. Traction (~$34.800): +%1,5. Series A (~$80.600): +%0,6.

- **Cevap gelmezse:** schedule_event team.master_degree_farewell 4 hafta (1. şıkla aynı yol: cevapsız kalan teklif ayrılıştır). expires_weeks 2.
- **Tekrar:** Kişi başına bir kez: family_subject once, latch_key entity; kart cooldown_weeks 52 (bahar sonu, yılda bir).
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık parayı kazanır, kişiyi kaybeder; 2. şık kişiyi tutar, parayı öder. Küçük ekipte 2., pisti kısa şirkette 1. şık öne çıkar.
- **Not:** kod_notu 'terfi apply_promotion, maaş apply_raise' diyordu: ikisi birden çift zam yazar. Tek kapı apply_promotion(15).

## calisan.yuksek_lisans.ayrilis (`team.master_degree_farewell`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Teşekkür et, yolu açık olsun de | Yok (açık beat). | Elif haftanın sonunda ayrılır; kalan herkesin morali −5. | Yok. | Tek şık. |

- **1. şığın sayıları:** employee_leaves scope employee reason 'resigned' (tehlike çipi). Ekip morali −5 motorun kendisidir.
  - **Örnek dünyalar:** Ana kartın sayıları (yukarıda).

- **Cevap gelmezse:** employee_leaves employee (aynı ayrılış). expires_weeks 1.
- **Tekrar:** Ana karta bağlı: follows calisan.yuksek_lisans, tick scheduled, kişi başına bir kez.
- **Neden hiçbir şık öbürünü geçmiyor:** Tek şıklı açık beat; bedeli ana kartın 1. şıkkında seçildi. lint_baseline O2 gerekçesi.

## calisan.kaba_musteri (`team.rude_client`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kuzey İnşaat ile bundan sonra sen ilgilen | Zeynep'in morali biraz yükselir; hesap kurucunun masasına geçer, hesabın memnuniyeti dokunulmaz. | Kurucunun verimi iki hafta %15 düşer. | Yok. | Hesap büyük ve hassasken, kurucu iki hafta ürün ya da satıştan biraz kopabiliyorken. |
| Müdürü ara, ekibine böyle konuşamayacağını söyle | Zeynep'in morali yükselir (+6). | Hesabın memnuniyeti biraz düşer (trust −4). | %15 ihtimalle hesap fesih bildirir: dört hafta sonra sözleşme biter. | Hesap küçük ya da yerine konabilir, temsilci kilit ve morali düşükken. |
| Zeynep'e “müşteri bu, idare et” de | Kurucunun zamanı ve hesabın memnuniyeti korunur. | Zeynep'in morali düşer (−6). | Yok. | Kurucu çok yoğunken ve temsilcinin morali 80'in üstündeyken. |

- **1. şığın sayıları:** productivity_mod scope founder pct −15 weeks 2; change_morale scope employee +4; hesabın sahibini kurucuya çeviren fiil 3. adımda (CustomerRegistry.assign_customer, pinned).
  - **Örnek dünyalar:** Bootstrap: kurucu çoğu zaman tek geliştiricidir, iki hafta −%15 ≈ 0,3 haftalık iş. Traction ve Series A: kurucunun görüşme ve sprint payı aynı oranda düşer.
- **2. şığın sayıları:** check odds_seam olay.odds_15. İki dalda: change_morale employee +6, trust_delta scope customer −4. Risk dalında ek: maddeden bağımsız fesih bildirimi (karar 6 seam'i, notice 4 hafta).
  - **Örnek dünyalar:** Risk: 2★ hesap $750–1.500/ay. Bootstrap (MRR ~$2–4K): MRR'ın %20–50'si. Traction (~$20–50K): %2–5. Series A (~$100K): %1–2.
- **3. şığın sayıları:** change_morale scope employee −6.
  - **Örnek dünyalar:** Her dünyada aynı: tek kişinin morali.

- **Cevap gelmezse:** change_morale employee −8 (temsilci cevapsız kaldı; 3. şıktan kötü). expires_weeks 1.
- **Tekrar:** Temsilci başına bir kez: family_subject once, latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** Bedel üç ayrı özneye düşer: 1. şık kurucunun zamanı, 2. şık hesap (ve yazılı zar), 3. şık temsilcinin morali. Kazançlar da ayrı: 1. ve 2. temsilciye moral, 3. kurucuya zaman.
- **Not:** 1. şıkka temsilcinin moral kazancı eklendi; yoksa 1. şık 3. şıktan yalnız pahalı olurdu (metin_ekleri).

## ekip.ayni_izin.pm (`team.same_leave_pm`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kartları önden hazırlasınlar, sonra ikisi de çıksın | İzinden önceki iki hafta ikisinin de verimi %20 artar: hazırlık işi öne alınır. | İkisi aynı iki hafta yok: o haftalar hazırlık durur. | Yok. | Sonraki sütunda hazırlanacak çok kart varken. |
| Kendi aralarında karar versinler | Rol hiç boş kalmaz: izinler örtüşmez. | İkisinin de morali biraz düşer (−4). | Yok. | Sprintte sözlü kart ya da teslim varken. |
| İkisi de gitsin, sürüm kaysın | İkisinin de morali biraz yükselir (+4, dönüşteki doğal +15'e ek). | İkisi aynı iki hafta yok, plan kayar (planda görünür, çip iki izni yazar). | Yok. | Sözlü kart yokken, ekibin morali düşükken. |

- **1. şığın sayıları:** productivity_mod scope employee pct +20 weeks 2 ve scope other pct +20 weeks 2 (kart iznin 2–4 hafta öncesinde gelir, mod hemen başlar). İzinler doğal başlar (HRMoraleSystem.tick_leave_departures) ve dönüşte herkes doğal +15 moral alır (MORALE_LEAVE_RETURN); bunlar kartın uyguladığı değil, bütün şıklarda ortaktır.
  - **Örnek dünyalar:** PM hızı P(s) 15–25 puan/hafta: iki PM iki haftada ~12–20 puan hazırlığı öne alır, izin haftalarında ~30–50 puan hazırlık eksik kalır. Bootstrap'ta iki PM yok (kart gelmez).
- **2. şığın sayıları:** yeni HR seam'i (karar 4d): geç başlayanın izni yalnız bu yıl, leave_week farkı ≥2 olacak kadar kayar; change_morale scope employee −4, scope other −4.
  - **Örnek dünyalar:** Traction ve Series A: iki kişi × −4; 76 eşiğindeki kişide verim +%5'ten 0'a iner.
- **3. şığın sayıları:** change_morale scope employee +4, scope other +4; çip iki izni yazar (karar 4f, ayrı kayma fiili yok). İzinler doğal başlar (HRMoraleSystem.tick_leave_departures) ve dönüşte herkes doğal +15 moral alır (MORALE_LEAVE_RETURN); bunlar kartın uyguladığı değil, bütün şıklarda ortaktır.
  - **Örnek dünyalar:** Kayma: iki PM'in iki haftalık hazırlığı (~30–50 puan).

- **Cevap gelmezse:** change_morale employee −3, other −3 (cevap gelmedi; izinler doğal örtüşür). expires_weeks 1 (kart izinden 2–4 hafta önce gelir).
- **Tekrar:** Yıl zarı EvDice.unit('year', yıl, kart id, '') < 0,5 (yeni seam, EvTuning [WORKING]); latch cooldown_weeks 52; üç varyant tek aile (team_same_leave, FAMILY_GAP_WEEKS 52 [WORKING]): yılda en çok bir varyant.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık iş kazanır moral kazanmaz, 3. şık moral kazanır iş kazanmaz (ikisinde de rol iki hafta boş), 2. şık rolü dolu tutar ve moral öder.
- **Not:** Onaylı 1. şık 'izinden önceki iki hafta verimi %30 düşer' idi: PM'in işi zaten hazırlıktır, verim düşüşünün oyunda karşılığı (önden hazırlanan kart) yoktu ve şık 3. şıktan her yönden kötüydü. Hazırlığın kendisi verim artışı olarak yazıldı (metin_ekleri, TR/EN onay bekliyor).

## ekip.ayni_izin.gelistirici (`team.same_leave_dev`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kendi aralarında karar versinler | Rol hiç boş kalmaz. | İkisinin de morali biraz düşer (−4). | Yok. | Para darken ve sprintte teslim varken. |
| İkisi de gitsin, sürüm kaysın | İkisinin de morali biraz yükselir (+4). | İkisi aynı iki hafta yok; geliştirme o haftalar yavaşlar. | Yok. | Sözlü kart yokken, moral düşükken. |
| Birinin iznini kaydır, karşılığında prim ver | Rol boş kalmaz, moral bozulmaz. | Kasa, kayan kişinin bir haftalık maaşı kadar azalır. | Yok. | Kasa rahat, teslim yakınken. |

- **1. şığın sayıları:** yeni HR seam'i (karar 4d): geç başlayanın izni yalnız bu yıl, leave_week farkı ≥2 olacak kadar kayar; change_morale employee −4, other −4.
  - **Örnek dünyalar:** Her dünyada iki kişi × −4.
- **2. şığın sayıları:** change_morale employee +4, other +4; çip iki izni yazar. İzinler doğal başlar (HRMoraleSystem.tick_leave_departures) ve dönüşte herkes doğal +15 moral alır (MORALE_LEAVE_RETURN); bunlar kartın uyguladığı değil, bütün şıklarda ortaktır.
  - **Örnek dünyalar:** İki geliştirici × ~9–15 puan/hafta (Y(4)–Y(8)): çakışma haftasında ~18–30 puan eksik. Traction'da ekibin geliştirme gücünün büyük kısmı.
- **3. şığın sayıları:** yeni HR seam'i (karar 4d): geç başlayanın izni yalnız bu yıl, leave_week farkı ≥2 olacak kadar kayar; add_cash amount_seam hr.salary + amount_slot other (kayan, geç başlayan kişi) × amount_mult −0,233 (7/30, bir haftalık maaş), label retention.
  - **Örnek dünyalar:** Junior $3.750 → $875; orta $6.750 → $1.575; kıdemli $12.000 → $2.800. Traction (haftalık gider ~$8.100): %11–35. Series A (~$18.800): %5–15. Bootstrap'ta iki geliştirici nadirdir (haftalık ~$1.800: %50).

- **Cevap gelmezse:** change_morale employee −3, other −3. expires_weeks 1.
- **Tekrar:** PM varyantıyla aynı (yıl zarı 0,5, cooldown 52, ortak aile).
- **Neden hiçbir şık öbürünü geçmiyor:** Her şık tek eksende öder: 1. moral, 2. hız, 3. para.
- **Not:** amount_slot için yuva kuralı: 'other' yuvası geç başlayan (kayan) kişidir, gönderen erken başlayandır. Aksi hâlde prim kaymayan kişinin maaşından okunur (5. adım yuvaları buna göre kurar).

## ekip.ayni_izin.testci (`team.same_leave_tester`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kendi aralarında karar versinler | Rol hiç boş kalmaz. | İkisinin de morali biraz düşer (−4). | Yok. | Para darken, sürüm yakınken. |
| İkisi de gitsin, testi geliştiriciler yapsın | İkisinin de morali biraz yükselir (+4). | O iki hafta testte daha az hata yakalanır ve geliştiriciler testte yarım hızla çalışır. | Kaçan hatalar sürümle hatta açık hata olur (testin yakalama payından doğar, zar karta yazılmaz). | Sözlü kart yokken, moral düşükken. |
| Birinin iznini kaydır, karşılığında prim ver | Rol boş kalmaz, moral bozulmaz. | Kasa, kayan kişinin bir haftalık maaşı kadar azalır. | Yok. | Kasa rahat, sürüm yakınken. |

- **1. şığın sayıları:** yeni HR seam'i (karar 4d): geç başlayanın izni yalnız bu yıl, leave_week farkı ≥2 olacak kadar kayar; change_morale employee −4, other −4.
  - **Örnek dünyalar:** Her dünyada iki kişi × −4.
- **2. şığın sayıları:** change_morale employee +4, other +4; çip iki izni yazar. Test geliştiriciye doğal olarak düşer: rolü uymayan fazda no_role_speed 0,5 (sprint.json), kendi kodunu test eden ×0,6 yakalar (SprintBugs).
  - **Örnek dünyalar:** Traction: tipik iki testçi; o iki hafta test hızı yarıya iner, yakalama ~%40 düşer (kendi kodunda).
- **3. şığın sayıları:** yeni HR seam'i (karar 4d): geç başlayanın izni yalnız bu yıl, leave_week farkı ≥2 olacak kadar kayar; add_cash amount_seam hr.salary + amount_slot other × −0,233, label retention.
  - **Örnek dünyalar:** Junior testçi $3.375 → $790; orta $6.075 → $1.420; kıdemli $10.800 → $2.520. Traction %10–30, Series A %4–13 haftalık gider.

- **Cevap gelmezse:** change_morale employee −3, other −3. expires_weeks 1.
- **Tekrar:** PM varyantıyla aynı.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. moral, 2. hata riski ve hız, 3. para öder.
- **Not:** Eski 3. şık 'İkisi de gitsin, sürüm kaysın' koddaki doğal davranışla 2. şığın aynısıdır: sprint test fazını rol önceliğiyle herkese verir (sprint_system.gd:1276-1281, no_role_speed 0,5), 'test testçiyi bekler' kuralı yoktur; yeni mekanik yazmadan ayrışmaz. Yerine geliştirici varyantının prim şıkkı geldi (metin_ekleri, TR/EN onay bekliyor).

## ekip.kod_inceleme (`product.sprint_dev_code_review`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kerem yalnız hataya yol açacak notlarda dursun, gerisini geçsin | Kartın kalan işi 5 puan kısalır. | Kart çıkınca hattına 1 açık hata düşer; Kerem'in morali biraz düşer (−4). | Yok (hata kesindir, kâğıt kuralı). | Kart sözlü ya da sprinte yetişmesi şartken. |
| Kerem'le Onur'u bir gün aynı masaya oturt, notları birlikte kapatsınlar | Onur'un morali yükselir (+6); kart hatasız ve bu sprintte sürer. | Kerem'in ve Onur'un bu hafta birer günü gider. | Yok. | Junior'un morali düşükken, kıdemli bu hafta kritik kartta değilken. |
| Kart bu sprintte bu hâliyle kalsın, Onur notları sonraki sprintte düzeltsin | Onur'un morali biraz yükselir (+4); bu sprintin teslimi korunur. | Sonraki sprinte 5 puanlık takip kartı girer. | Yok. | Bu sprintte sürüm şartken ve sonraki sprintte yer varken. |
| Onur bu sefer notların hepsini kapatsın, kart sağlam çıksın | Kartın hattı 26 hafta yeni hata almaz. | Kartın işi 10 puan büyür; Onur'un morali düşer (−6). | Yok. | Hat çok kullanılan (çok hesaplı) ve sprintte yer varken. |

- **1. şığın sayıları:** sprint_card_effort −5; sprint_card_trim bugs 1 (kart çıkınca kendi hattında açık hata, test_* kâğıtlarının 'bilinen hatayla çıkar' kalıbı; damage_product değil çünkü hata bu kartın incelenmemiş kodundadır); change_morale scope lead −4.
  - **Örnek dünyalar:** −5 puan ≈ junior geliştiricinin (Y(3)≈0,74 → ~7,4 puan/hafta) ~0,7 haftası. Açık hata: B2B'de o hattı kullanan her hesabın hedefi −3 (account_bugs ×3).
- **2. şığın sayıları:** productivity_mod scope lead pct −20 weeks 1; productivity_mod scope dev pct −20 weeks 1; change_morale scope dev +6.
  - **Örnek dünyalar:** Kıdemli (~15 puan/hafta) ~3 puan + junior ~1,5 puan ≈ 4,5 puan bu sprintten.
- **3. şığın sayıları:** sprint_card_trim amount 5 follow true (paper.reopen_points 5); change_morale scope dev +4.
  - **Örnek dünyalar:** 5 puan ≈ junior'un 0,7 haftası, sonraki sprintten.
- **4. şığın sayıları:** sprint_card_effort +10; line_harden line decision (paper.harden_weeks 26); change_morale scope dev −6. Sayılar sprint_dev_root_cause 'rewrite' ile aynı (+10, line_harden).
  - **Örnek dünyalar:** +10 puan ≈ junior'un ~1,4 haftası.

- **Cevap gelmezse:** sprint_card_effort +5 ve morale_crew speaker −4 (notlar dönmeye devam eder). expires_weeks 1.
- **Tekrar:** Kâğıt standardı: latch cooldown_weeks 52, max_fires 3; family sprint_dev; family_subject cooldown_weeks 26; decision.cards havuzu.
- **Neden hiçbir şık öbürünü geçmiyor:** Dört bedel dört eksende: hata (1), iki kişinin günü (2), sonraki sprint (3), +10 puan ve moral (4). Kazançlar da ayrı: hız, moral, bu sprintin teslimi, hattın dayanıklılığı.
- **Not:** 2. şık etiketi 'yarım gün' idi; bedel bir gün (verim −%20) olarak yazıldı, çünkü yarım gün (−%10) 3. şıktan her yönden ucuz kalıyordu. Etiket 'bir gün' oldu (metin_ekleri).

## ekip.soz_verdi (`team.promise_made`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kaan ay sonuna kadar yalnız buna baksın | Sözlü kart en güçlü geliştiriciyle yürür; söz tutulursa hesap +6 (PROMISE_KEPT_OFFSET). | Kaan'ın öbür kartları bekler; Kaan'ın morali düşer (−6). | Yok (yetişme garanti değil, çip yazmaz). | Söz büyük hesaba verilmişken ve kart Kaan'la yetişebilecekken. |
| Müşteriyi ara, ek süre iste | Söz bir sprint uzar. | Hesabın memnuniyeti biraz düşer (trust −6). | Yok. | Özellik yoldayken ama bu sprintte yetişmeyecekken. |
| Bu özelliğin şimdilik olmayacağını söyle | Plan serbest kalır, söz yükü kalkar. | Söz geri alınır: kırık sözün bedeli (trust −12, kırık söz kilidi). | Yok. | Özellik yol haritasında yokken, hesap küçükken. |

- **1. şığın sayıları:** assign_to scope dev (söz kartına, ay sonuna ya da kart bitene dek; kilit Ürün arayüzünün _assign değişikliği); change_morale scope dev −6.
  - **Örnek dünyalar:** Kaan ~10–15 puan/hafta başka kartlardan çekilir (ay sonuna 2–4 hafta).
- **2. şığın sayıları:** trust_delta scope customer −6; promise_extend (bir kez). Sayı product.promise_due 'extend' ile aynı. Kilit: söz zaten uzatıldıysa (metin_ekleri gerekçesi).
  - **Örnek dünyalar:** −6 hedef, tikte 2,8 söner (~2 hafta). 2★ hesap toleransı ~42+sektör.
- **3. şığın sayıları:** promise_break (sistemin bedeli: PROMISE_BROKEN_OFFSET −12, b2b_constants.gd:279; çip chips.gd _break_parts).
  - **Örnek dünyalar:** −12 hedef ~4 haftada söner; memnuniyeti eşiğin 12 puan yakınındaki hesap riske girer.

- **Cevap gelmezse:** change_morale scope employee (konuşan PM) −4. expires_weeks 1.
- **Tekrar:** Hesap başına bir kez: latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık kişiyi öder, 2. şık hesaptan az öder ama sözü taşır, 3. şık hesaptan çok öder ve planı kurtarır.
- **Not:** promise_extend ve promise_break SYSTEM_VERBS'tedir ve sprint söz olayının sözlerine iner (görevin 'hazır olmayan fiiller' tablosu): bu kartın sözüne inmesi 3. adımın işi.

## musteri.egitim (`customer.training_request`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Deniz gelecek hafta bir gün gidip anlatsın | Anadolu Yapı'nın memnuniyeti artar (trust +8). | Deniz'in bir günü gider. | Yok. | Tek hesap ilk ayındayken, temsilci boşken. |
| İki günlük eğitim teklif et, ücretini iste | Kasa, hesabın yarım aylık ücreti kadar artar. | Deniz'in iki günü gider; hesabın memnuniyeti biraz düşer (−4). | Yok. | Kasa darken (Bootstrap). |
| Deniz ekran ekran anlatan bir onboarding dokümanı hazırlasın | İlk ayındaki bütün hesapların memnuniyeti biraz artar (+4 her biri). | Deniz'in iki günü gider. | Yok. | Aynı anda birkaç hesap ilk ayındayken (Traction ve sonrası). |
| Ürüne yardım merkezi ekle | Sonraki sprinte bir Onboarding kartı girer: Onboarding alanı yükselince bütün hesapların ve adayların uyumu artar. | Kartın puanı sonraki sprintten; Anadolu Yapı'nın memnuniyeti bu ay biraz düşer (−4). | Yok. | Onboarding alanı sektörünün vurgusuyken (inşaat, emlak) ve sprintte yer varken. |

- **1. şığın sayıları:** productivity_mod scope rep pct −20 weeks 1; trust_delta scope customer +8. Temsilci yoksa kurucu: productivity_mod founder −20 / 1 hafta.
  - **Örnek dünyalar:** Her dünyada aynı ölçek: bir hesabın hedefi +8 (~3 hafta).
- **2. şığın sayıları:** add_cash amount_seam musteri.mrr + amount_slot customer × amount_mult +0,5, label training; productivity_mod rep −40 weeks 1; trust_delta customer −4.
  - **Örnek dünyalar:** Orta boy (2★) hesap $750–1.500/ay → +$375–750. Bootstrap (haftalık ~$1.590): %24–47. Traction (~$8.100): %5–9. Series A (~$18.800): %2–4.
- **3. şığın sayıları:** productivity_mod rep −40 weeks 1; trust_delta accounts: yeni 'onboarding' anahtarı (onboarding_until ≥ bugün olan hesaplar; 3. adım) +4.
  - **Örnek dünyalar:** Bootstrap: genelde tek hesap (o zaman 1. şıktan kötü). Traction: 2–4 yeni hesap × +4. Series A: 4–8 hesap × +4.
- **4. şığın sayıları:** Olay kartından sonraki sprinte kart koyan yeni fiil (3. adım); trust_delta customer −4.
  - **Örnek dünyalar:** Kartın puanı kademesine göre K1 15 / K2 25 / K3 40 (sprint.json effort).

- **Cevap gelmezse:** trust_delta customer −6 (rica cevapsız). expires_weeks 2.
- **Tekrar:** Hesap başına bir kez: latch_key entity (imzanın ertesi haftası tek seferdir); kart cooldown_weeks 8.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. ve 3. şık temsilcinin zamanını öder, biri tek hesaba çok, öbürü çok hesaba az verir; 2. şık para kazanır memnuniyet öder; 4. şık bugünün memnuniyetini ve sprint puanını kalıcı düzeltmeye yatırır.

## musteri.kendi_hatasi (`customer.own_data_error`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Deniz kayıtlarla müdüre gitsin | Ekin Gıda'nın memnuniyeti artar (+8). | Deniz'in bir günü gider. | Yok. | Temsilci varken (yoksa şık görünmez). |
| Müdürü sen ara, kayıtları nazikçe anlat | Ekin Gıda'nın memnuniyeti biraz artar (+4). | Kurucunun verimi bu hafta %10 düşer. | Yok. | Temsilci yokken, kurucunun haftası hafifken. |
| Sayım ekranına uyarı ekle, müdüre aldığımız önlemi anlat | Ekin Gıda +8; Stok hattını kullanan öbür hesaplar da biraz (+4). | Emre'nin bir haftası gider. | Yok. | Stok hattını çok hesap kullanırken (perakende, lojistik). |

- **1. şığın sayıları:** productivity_mod scope rep pct −20 weeks 1; trust_delta customer +8.
  - **Örnek dünyalar:** Her dünyada tek hesap +8.
- **2. şığın sayıları:** productivity_mod scope founder pct −10 weeks 1; trust_delta customer +4.
  - **Örnek dünyalar:** Bootstrap: kurucu çoğu zaman geliştirir, ~1 puan.
- **3. şığın sayıları:** productivity_mod scope employee pct −50 weeks 2 (bir haftalık iş); trust_delta customer +8; trust_delta accounts: yeni 'line' anahtarı (Stok hattını kullanan hesaplar, SprintCatalog.line_accounts; 3. adım) +4. Anahtar kurulamazsa yalnız bu hesap +10.
  - **Örnek dünyalar:** Emre ~9–15 puan/hafta. Traction: Stok hattında 5–10 hesap × +4. Series A: 15+ hesap.

- **Cevap gelmezse:** trust_delta customer −6. expires_weeks 2.
- **Tekrar:** Hesap başına bir kez: latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık temsilcinin günü, 2. şık en ucuz ama az kazanç, 3. şık en pahalı (geliştiricinin haftası) ama hattaki bütün hesaplara yayılır.
- **Not:** 3. şıkka hattaki öbür hesapların kazancı eklendi; yoksa geliştiricinin haftası 1. şığın temsilci gününden yalnız pahalı kalırdı (metin_ekleri).

## musteri.muhasebeci (`customer.finance_team`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Tabloya aktarmayı sonraki sprinte al | Kardelen'in memnuniyeti artar (+8); Defter hattına dışa aktarma kademesi gelir. | Kartın puanı sonraki sprintten. | Yok. | Defter hattı çok hesapça kullanılırken, sprintte yer varken. |
| Deniz finans ekibine bir gün sistemi göstersin | Memnuniyet biraz artar (+4). | Deniz'in bir günü gider. | Yok. | Sprint doluyken, temsilci boşken. |
| Şimdilik böyle devam etmelerini rica et | Hiçbir kaynak harcanmaz. | Memnuniyet düşer (−8). | Yok. | Hesap küçük ve sprint ile temsilci doluyken. |

- **1. şığın sayıları:** Sonraki sprinte istek kartı koyan yeni fiil (3. adım; hesabın istek akışı musteri.request_kind'e bağlanabilir); trust_delta customer +8.
  - **Örnek dünyalar:** Kademe kartı K1 15 / K2 25 puan.
- **2. şığın sayıları:** productivity_mod scope rep pct −20 weeks 1 (temsilci yoksa founder −20 / 1 hafta); trust_delta customer +4.
  - **Örnek dünyalar:** Her dünyada tek hesap +4.
- **3. şığın sayıları:** trust_delta customer −8.
  - **Örnek dünyalar:** 2★ hesap için −8 hedef (~3 hafta).

- **Cevap gelmezse:** trust_delta customer −8 (3. şıkla aynı). expires_weeks 2.
- **Tekrar:** Hesap başına bir kez: latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** Sprint puanı, temsilci zamanı ya da hesabın memnuniyeti: her şık birini öder, kazanç bedelle büyür.

## urun.eski_tarayici (`customer.old_browser`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Desteğe söz ver | Aday masada kalır; imzalarsa hesap açılır (tutulan söz +6). | İmzada söz yükü: eski tarayıcı kademesi 4 hafta içinde yapılmalı. | Söz tutulmazsa kırık söz bedeli (trust −12) sözleşmenin ilk ayına düşer. | Mobil ve Erişim hattında yer varken, sağlık sektöründe büyümek isterken. |
| Yapamayacağımızı söyle | Söz yükü alınmaz. | Aday düşer. | Yok. | Sprint doluyken ya da hat başka işe ayrılmışken. |

- **1. şığın sayıları:** Adaya teklif koşulu: söz (karar 15); imzada promise_create deadline_weeks 4 [WORKING]. Kapanış zarına teklif terimi YOK: aday 'o tarayıcıda açılmazsa imza yok' dediği için teklif yalnız adayı akışta tutar.
  - **Örnek dünyalar:** Sağlık adayı 1★ $250–500, 2★ $750–1.500, 3★ $2.000–3.500 potansiyel MRR.
- **2. şığın sayıları:** Adayı düşüren fiil (3. adım; SalesFinalizer.lose yolu).
  - **Örnek dünyalar:** Kayıp potansiyel MRR yukarıdaki gibi.

- **Cevap gelmezse:** Aday düşer (2. şıkla aynı). expires_weeks 2.
- **Tekrar:** Aday başına bir kez: latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık adayı alır, gelecek bir yükü ve riski alır; 2. şık yük almaz, adayı bırakır.

## rakip.kesinti (`rival.outage`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kaan bu hafta üçüne de demo yapsın | Üç yeni aday (iki küçük, bir orta). | Kaan'ın bir haftalık işi buna gider. | Yok. | Tek şık. |

- **1. şığın sayıları:** add_prospect archetype small ×2, mid ×1, source rival_outage; productivity_mod scope employee pct −50 weeks 2 (bir haftalık iş). Temsilci yoksa 'Üçüyle de bu hafta görüş': productivity_mod founder −30 weeks 2 (tek kişilik şirket sınırı).
  - **Örnek dünyalar:** Bootstrap: üç aday boru hattını ikiye katlar. Traction ve Series A: haftalık musluğa ek, bedeli tek temsilcinin haftası.

- **Cevap gelmezse:** Yok (fırsat kaçar; olumlu etki süre dolumunda verilmez, I2). expire_note yazılır. expires_weeks 1.
- **Tekrar:** Rakip başına bir kez: latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** Tek şıklı fırsat (Erdem onaylı): kazancı ve bedeli okunur, seçim yok. O2'ye takılmaz (bedeli var).

## rakip.ayni_ozellik (`product.sprint_pm_rival_batch`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| En yakın üç müşterimiz bu hafta erkenden denesin | Üç hesabın memnuniyeti artar (trust +6 her biri). | Kartın testi hata bulursa aynı üç hesap −8. | Durumdan: kartın test zarı (SprintBugs, Poisson H × yakalama payı). İhtimal karta yazılmaz; çip koşulu yazar. | Kartın hata yükü düşükken (iyi PM hazırlığı, güçlü geliştirici). |
| Planı bozma, kart sırası gelince çıksın | Hiçbir risk alınmaz, plan aynen sürer. | Ardenna önce duyurur: Marka −1. | Yok. | Sprint planı sıkıyken ya da hesaplar zaten huzursuzken. |
| Testi kısalt, kart bu sprintin sürümüne girsin | Önce biz duyururuz: Marka +3. | Kartın testi yarıya iner. | Kaçan hatalar sürümle Fatura hattına açık hata olur (yakalama payı yarım testle düşer). | Marka eşiğe yakınken ve Fatura hattını kullanan hesap azken. |

- **1. şığın sayıları:** A = +6 (PROMISE_KEPT_OFFSET ile eş), B = −8 (kâğıtlardaki hesap bedeli). trust_delta accounts: yeni 'top3' seçicisi (memnuniyeti en yüksek üç hesap) +6; test bitince (EventBus.card_phase_changed) bulunan hata ≥1 ise aynı üç hesaba −8 (yeni gözcü, karar 7).
  - **Örnek dünyalar:** 2★–3★ hesaplarda: +6 hedef ~2 hafta tam, ~4 haftada söner (tikte 2,8). Hata çıkarsa net −2 ve 3 hafta. Bootstrap'ta üç hesap yoksa kart gelmez.
- **2. şığın sayıları:** add_brand −1.
  - **Örnek dünyalar:** Marka 0–100 ölçeğinde −1, her dünyada aynı.
- **3. şığın sayıları:** sprint_card_test card decision; add_brand +3.
  - **Örnek dünyalar:** Kaçan her hata Fatura hattını kullanan her hesabın hedefinden −3.

- **Cevap gelmezse:** add_brand −1 (cevapsız kâğıt planı bozmaz). expires_weeks 1.
- **Tekrar:** Toplu Fatura kartına özgü: latch max_fires 1 (koşuda bir), cooldown_weeks 52; decision.cards havuzu.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık hesaplarla, 3. şık hatla kumar oynar, 2. şık güvenli ama marka öder. Kazançların öznesi ayrı: üç hesap ya da marka.
- **Not:** 'Kalıcı olarak artar' sözü yanlış: trust_offset tikte 2,8 söner (b2b_constants.gd:282), +6 yaklaşık dört haftada biter (metin_ekleri).

## rakip.panel (`rival.new_firm_warning`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Bilge adayı memnun bir müşterimizle görüştürsün | Aday tam fiyattan imzalayabilir. | Bilge'nin iki günü gider. | %20 ihtimalle aday yine de Pythia'yı seçer (aday düşer). | Satış temsilcisi boşken ve memnun referans hesabınız varken. |
| İlk yıl indirimli fiyat ver | Pythia riski kalkar; zar yok. | Aday imzalarsa hesabın MRR'ı 52 hafta %15 eksik açılır. | Yok (imza akışın kendi zarındadır; teklif ona terim eklemez). | Temsilci doluyken, kasa rahatken ve aday büyükken. |

- **1. şığın sayıları:** check odds_seam olay.odds_20. İki dalda: productivity_mod scope employee pct −40 weeks 1. Risk dalında ek: adayı düşüren fiil (#15 ile aynı, 3. adım).
  - **Örnek dünyalar:** Kaybedilebilecek potansiyel MRR: 2★ $750–1.500, 3★ $2.000–3.500.
- **2. şığın sayıları:** X = %15 [WORKING] (RETAIN_DISCOUNT_PCT ve PRICE_BREAK_SIGNING_DISCOUNT ile aynı). Adaya teklif koşulu: indirim %15, 52 hafta (karar 8 ve 15 seam'leri).
  - **Örnek dünyalar:** 2★: $112–225/ay, yılda $1.350–2.700. 3★: $300–525/ay, yılda $3.600–6.300. Bootstrap (haftalık ~$1.590): 2★ indirimi yılda ~1–1,7 haftalık gider. Series A (~$18.800): 3★ indirimi yılda ~0,2–0,3 hafta.

- **Cevap gelmezse:** Aday düşer (temsilci yardım istedi, cevap gelmedi: 1. şığın riskinden kötü). expires_weeks 1.
- **Tekrar:** Aday başına bir kez: latch_key entity; kart cooldown_weeks 26.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık zaman ve %20 aday kaybı öder, tam fiyatı korur; 2. şık riski parayla satın alır.
- **Not:** Karar 15: teklif kapanış zarına terim eklemiyor; şıklar arasındaki fark yalnız Pythia riskidir. Erdem'in 'imzayı şimdi al' gibi ifade çıkar kuralına uyar.

## dunya.disk (`world.server_price_hike`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Zammı kabul et, yerimizde kalalım | Kimse işinden olmaz, kademe ve kapasite serbest kalır. | Sunucu faturası %15 artar. | Yok. | Sunucu faturası küçükken (Bootstrap) ya da kademe/kapasite esnekliği gerekirken. |
| Ucuz sağlayıcıya geç | Fatura bugünkünden %10 düşer, kademe değişmez. | Kerem'in bir sprinti taşımaya gider. | Yok. | Fatura büyük, 3★ hesap yok ve Kerem bir sprint ayrılabilirken (Traction). |
| Bir yıllık sözleşme imzala, zammı yarıya indir | Zam %7'de kalır. | Bir yıl boyunca sunucu kademesi değişmez ve kapasite bugünkünün altına inmez. | Yok (kilit kesin; Kurumsal'a geçemeyen B2B oyuncusu sunucu maddeli hesabı riske atar). | Kademe ve kapasite bir yıl yeterliyken. |

- **1. şığın sayıları:** Yeni fiyat çarpanı fiili: ProductState.infra_price_mult ×1,15 (karar 1).
  - **Örnek dünyalar:** Sunucu faturası (B2B birim 50 koltuk; local $60, cloud $120, enterprise $240): Bootstrap ~2 birim cloud $240 → +$36/ay. Traction ~12 birim $1.440 → +$216/ay. Series A ~42 birim $5.040 → +$756/ay (Kurumsal'da +$1.512).
- **2. şığın sayıları:** infra_price_mult ×0,90; productivity_mod scope employee pct −50 weeks 4 (bir sprintlik iş; O3: tek kişilik kartta sprint_hours yok). Kilit: 3★ ve üstü hesap varken (YY kararı; gerekçe metin_ekleri).
  - **Örnek dünyalar:** Bootstrap: −$24/ay, ama tek geliştiricinin iki haftası (ürünün bütün hızı). Traction: −$144/ay (zamla farkı $360/ay, yılda ~$4.300) karşılığında kıdemlinin ~30 puanı (≈ bir K2 kartı, $4.200–7.000 maaş zamanı). Series A: −$504/ay (fark yılda ~$15.000), ama çoğu Series A şirketinde 3★ hesap olduğu için şık kilitlidir.
- **3. şığın sayıları:** infra_price_mult ×1,07; 52 hafta kilit ve kapasite tabanı ProductState bayrağında (karar 1). Koşuda bir kez sunulur.
  - **Örnek dünyalar:** Bootstrap: +$17/ay. Traction: +$101/ay (zamla farkı $115/ay). Series A: +$353/ay (fark $403/ay, yılda ~$4.800); Kurumsal'a geçemeyiş 3★ hesap maddesinde hesap kaybı riskidir.

- **Cevap gelmezse:** Zam kabul edilir (×1,15; 1. şık). expires_weeks 4 (EXPIRY_MONEY_WEEKS).
- **Tekrar:** Koşuda bir kez: latch one_shot.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık para öder, esnekliği korur; 2. şık parayı kazanır, bir sprint öder; 3. şık daha az para öder, bir yıllık esnekliği öder. Küçük faturada 1., Traction'da 2., kademesi oturmuş şirkette 3. şık öne çıkar.
- **Not:** Sunucu bütçenin küçük payıdır (Traction'da giderin ~%4'ü): zam şıklarının gerçek bedeli para değil, Kerem'in sprinti ve bir yıllık kilittir. Karar 1'in sayıları sabittir.

## dunya.bulut (`world.cloud_price_cut`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Anladım | Standart ve Kurumsal sunucu %30 ucuzlar. | Yok (açık beat). | Yok. | Tek şık. |

- **1. şığın sayıları:** Standart ve Kurumsal birim fiyatı ×0,70 (karar 1; infra_price_mult ile çarpılır, Ekonomik etkilenmez).
  - **Örnek dünyalar:** Traction cloud $1.440 → $1.008 (−$432/ay). Series A cloud $5.040 → $3.528; Kurumsal $10.080 → $7.056.

- **Cevap gelmezse:** Yok (I2: olumlu etki süre dolumunda verilmez). expires_weeks 4; kart okunmazsa indirim inmez, 5. adım kartı uzun bekletir.
- **Tekrar:** Koşuda bir kez: one_shot; #23'ten ≥26 hafta sonra; #23'te ucuz sağlayıcıya geçildiyse gelmez.
- **Neden hiçbir şık öbürünü geçmiyor:** Tek şıklı dünya duyurusu (O2 baseline gerekçesi).

## dunya.veri_nerede (`world.data_location`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Bilgi işlem müdürünü sen ara, sunucu düzenini anlat | Hesabın memnuniyeti artar (+8). | Kurucunun verimi bu hafta %10 düşer. | Yok. | Hesap büyükken ve kurucunun haftası hafifken. |
| Bütün hesaplara aynı açıklamayı gönder | Öbür hesapların memnuniyeti biraz artar (+4 her biri). | Soran hesabın memnuniyeti biraz düşer (−4): kişisel cevap bekliyordu. | Yok. | Çok hesap varken (Traction, Series A). |
| “Verileriniz Türkiye'de ayrı bir sunucuya alınıyor” de | Hesabın memnuniyeti çok artar (+10, trust_offset tavanı). | Kazanç dört haftada söner. | %25 ihtimalle birkaç hafta içinde gerçek ortaya çıkar ve hesap fesih bildirir (dört hafta sonra sözleşme biter). | Hesap küçük ve memnuniyeti eşikteyken (kaybetse de az kaybeder). |

- **1. şığın sayıları:** productivity_mod scope founder pct −10 weeks 1; trust_delta customer +8.
  - **Örnek dünyalar:** Her dünyada tek hesap +8.
- **2. şığın sayıları:** trust_delta customer −4; trust_delta accounts 'other' (chips TRUST_GROUP_KEYS 'other'; 3. adım) +4.
  - **Örnek dünyalar:** Bootstrap: 2–4 öbür hesap × +4. Traction: ~20. Series A: ~60.
- **3. şığın sayıları:** check odds_seam olay.odds_25. İki dalda: trust_delta customer +10. Risk dalında ek: schedule_event world.data_claim_exposed delay_weeks 3 [WORKING] (bildirim o kartta). TUZAK: check dalındaki schedule_event'i lint zincir taraması görmez (lint.gd:492, 895), 4. adım düzeltir.
  - **Örnek dünyalar:** Sağlık/finans hesabı 2★ $750–1.500, 3★ $2.000–3.500. Bootstrap'ta MRR'ın %20–60'ı; Traction %2–7; Series A %1–3.

- **Cevap gelmezse:** trust_delta customer −8 (bu hafta cevap istendi). expires_weeks 1.
- **Tekrar:** Koşuda bir kez: one_shot.
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık kurucunun zamanını, 2. şık soran hesabı öder; 3. şık bedava görünür ama bedeli yazılı zardır (%25 hesap kaybı).

## dunya.veri_nerede.ortaya (`world.data_claim_exposed`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Müdürü ara, özür dile | İtibar daha az düşer. | Kurucunun verimi bu hafta %10 düşer; itibar biraz düşer (−1). | Yok (bildirim sürer). | İtibar eşiğe yakınken. |
| Bildirimi sessizce kabul et | Kurucunun zamanı korunur. | İtibar düşer (−3). | Yok. | Kurucu yoğunken. |

- **1. şığın sayıları:** productivity_mod founder −10 weeks 1; add_reputation −1. Bildirim karar 6 seam'iyle sürer.
  - **Örnek dünyalar:** İtibar −10..100 ölçeğinde.
- **2. şığın sayıları:** add_reputation −3.
  - **Örnek dünyalar:** Her dünyada aynı.

- **Cevap gelmezse:** add_reputation −3 (2. şıkla aynı). expires_weeks 1.
- **Tekrar:** Ana karta bağlı: follows dunya.veri_nerede, tick scheduled, bir kez.
- **Neden hiçbir şık öbürünü geçmiyor:** Kurucunun zamanı ↔ itibar.

## dunya.ceyrek_bulteni (`world.quarterly_bulletin`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Bu çeyrek satış görüşmelerinde kurulum desteğine ağırlık veririm | Bu çeyrek (13 hafta) satış görüşmelerinde kurulum vurgusu ağırlık kazanır: ürünün Onboarding'i yeterliyse iğneye +0,05. | Yok (açık beat). | Yok. | Tek şık. |

- **1. şığın sayıları:** Süreli bayrak 13 hafta (set_timed_flag WRITER_VERBS'e ya da yeni yazar fiili, karar 5); SalesMeetingSystem._build_base_contributions'a {seam, delta} terimi +0,05 [WORKING], Onboarding yetersizse 0. Sayı EvTuning ya da sales sabitinde, kartta değil.
  - **Örnek dünyalar:** İğne tabanı 0,35, kesimler 0,72 / 0,12: +0,05 aralığın ~1/12'si; ürün uyumu terimi 0,42.

- **Cevap gelmezse:** Yok (I2). expires_weeks 2.
- **Tekrar:** Bu sayı koşuda bir kez: one_shot; bülten kategorisi çeyrek başına tek konu.
- **Neden hiçbir şık öbürünü geçmiyor:** Tek şıklı duyuru (O2 baseline gerekçesi).

## odul.final (`world.award_final`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Canlı demo yap | %25 ihtimalle birincilik: Kasa +$10.000, Marka +3. | Kurucunun bir günü provaya gider; kazanamazsan Marka yalnız +1. | Açık hatan varsa birincilik ihtimali düşer (en az %10) ve kazanamazsan demo sahnede takılmış sayılır: Marka −2. | Ürünün açık hatası yokken ve para markadan değerliyken. |
| Önceden çekilmiş demo videosu göster | Marka +2 kesin; %15 ihtimalle birincilik (Kasa +$10.000). | Mert'in iki günü gider. | Yok. | Açık hata çokken ya da marka paradan değerliyken. |
| Slaytla anlat | Marka +1 kesin; %10 ihtimalle birincilik. | Kurucunun yarım günü slaytlara gider. | Yok. | Sprint çok sıkışıkken. |

- **1. şığın sayıları:** check odds_seam olay.award_live_odds (durumdan: 0,25 − 0,05 × min(açık hata, 3), taban 0,10). Ödül dalı: add_cash +10000 (label: yeni gelir etiketi 'award', 3. adım), add_brand +3. Öbür dal: add_brand amount_seam olay.award_live_slip (açık hata 0 ise +1, ≥1 ise −2). İki dalda productivity_mod founder −20 weeks 1. modifier_lines: 'Açık hatalar ▼'.
  - **Örnek dünyalar:** Yalnız Bootstrap ve v1.0 çıkmış. Ödül $10.000 (karar 3): 1 çalışanlı şirkette ~2,5 aylık, 2 çalışanlıda ~1,5 aylık gider. Beklenen değer hatasız: $2.500 + Marka 1,5; 3 açık hatada: $1.000 + Marka −1,5.
- **2. şığın sayıları:** check odds_seam olay.odds_15. İki dalda: productivity_mod scope employee pct −40 weeks 1, add_brand +2. Ödül dalında ek: add_cash +10000 (award).
  - **Örnek dünyalar:** Beklenen: $1.500 + Marka 2; bedel en güçlü geliştiricinin ~0,4 haftası (~4–6 puan).
- **3. şığın sayıları:** check odds_seam olay.odds_10. İki dalda: productivity_mod founder −10 weeks 1, add_brand +1. Ödül dalında ek: add_cash +10000.
  - **Örnek dünyalar:** Beklenen: $1.000 + Marka 1; en ucuz zaman.

- **Cevap gelmezse:** add_brand −1 (finale katılım bildirilmedi). expires_weeks 1.
- **Tekrar:** Koşuda bir kez: one_shot (karar 3).
- **Neden hiçbir şık öbürünü geçmiyor:** Hatasız üründe canlı demo parada en iyi, markada en kötü (beklenen 1,5 < 2); video markada en iyi, geliştirici zamanı öder; slayt en ucuz, en az kazanır. Açık hata canlı demoyu kötüleştirir: oyuncu finalden önce hatayı kapatmaya itilir.
- **Not:** İki zar tek şıkta motorda yok (bir şık tek check). Takılma ayrı bir zar değil, durumdan okunan ödül ihtimali ve kayıp dalının marka satırıdır; çip ihtimali ve iki dalı açık hata sayısıyla yazar (metin_ekleri).
- **Not:** Bu kartta zar kazanç tarafındadır (ödül); 'ihtimalle' satırı ödül dalını yazar. Çip kuralı 'ihtimalli dal + yoksa' olarak kurulur (4. adım).
- **Not:** Öneri: plausibility headcount ≥1 (bootstrap_team). Tek kurucuda gider ~$240/ay olduğundan $10.000 kırk aylık gider olur.

## kriz.acik (`product.encryption_flaw`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Yamala, basına duyur, herkesten şifresini değiştirmesini iste | İtibar +3. | Kitle −%2. | Yok. | İtibar kitleden değerliyken (yatırım görüşmesi yakın). |
| Yamala, yalnız kullanıcılara mail at | İtibar +1. | Kitle −%1. | Yok. | Orta yol: büyüme kırılganken. |
| Yamala, kimseye duyurma | Kitle değişmez. | Yok. | %10 ihtimalle 4–8 hafta sonra basında çıkar: İtibar −8, Kitle −%5. | Büyüme her şeyken ve itibar payı varken. |

- **1. şığın sayıları:** add_reputation +3; audience_delta pct −0,02.
  - **Örnek dünyalar:** Kitle 10.000'de −200, 100.000'de −2.000 (yüzde ölçeklenir).
- **2. şığın sayıları:** add_reputation +1; audience_delta pct −0,01.
  - **Örnek dünyalar:** Kitle 10.000'de −100.
- **3. şığın sayıları:** check odds_seam olay.odds_10; güvenli dal boş; risk dalı: schedule_event product.encryption_flaw_press delay_weeks 4 (basın kartı delay_weeks [0,4]). Aynı check-dalı TUZAĞI (#25).
  - **Örnek dünyalar:** Beklenen: İtibar −0,8, Kitle −%0,5 (2. şıkla yakın; varyans yüksek).

- **Cevap gelmezse:** add_reputation −2 (sessiz kalmış sayılır; zar süre dolumunda atılmaz). expires_weeks 1 (urgent).
- **Tekrar:** Koşuda bir kez: one_shot; B2B ikiziyle ortak aile (product_encryption_flaw), koşuda yalnız biri.
- **Neden hiçbir şık öbürünü geçmiyor:** İtibar ↔ kitle ↔ risk: 1. şık itibarı kitleyle alır, 3. şık kitleyi riskle korur.
- **Not:** Onaylı −%1 ve −%0,5: çip yüzdeyi tam sayı yazar (EFFECT_AUDIENCE_PCT, chips.gd:194-198), %0,5 yazılamaz. Oran korunarak −%2 ve −%1 oldu (metin_ekleri).

## kriz.acik.b2b (`product.encryption_flaw_b2b`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Yamala, basına duyur, hesaplardan şifrelerini değiştirmelerini iste | İtibar +3. | Bütün hesapların memnuniyeti biraz düşer (−4 her biri). | Yok. | İtibar değerliyken ve hesaplar eşikten uzakken. |
| Yamala, yalnız hesaplara mail at | İtibar +1. | Bütün hesaplar −2. | Yok. | Hesaplar eşiğe yakınken. |
| Yamala, kimseye duyurma | Hesaplar değişmez. | Yok. | %10 ihtimalle 4–8 hafta sonra basında çıkar: İtibar −8, bütün hesaplar −8. | Hesaplar eşikteyken ve itibar payı varken. |

- **1. şığın sayıları:** add_reputation +3; trust_delta accounts: yeni 'all' anahtarı (chips TRUST_GROUP_KEYS 'all') −4.
  - **Örnek dünyalar:** Traction ~20 hesap, Series A ~60 hesap × −4 (~2 hafta).
- **2. şığın sayıları:** add_reputation +1; trust_delta accounts all −2.
  - **Örnek dünyalar:** Her hesap −2 (~1 hafta).
- **3. şığın sayıları:** check odds_seam olay.odds_10; risk dalı schedule_event product.encryption_flaw_press delay_weeks 4 (B2B satırları).
  - **Örnek dünyalar:** Risk: Series A'da 60 hesap × −8: eşiğe 8 puan yakın her hesap riske girer.

- **Cevap gelmezse:** add_reputation −2. expires_weeks 1.
- **Tekrar:** B2C kartıyla ortak aile, koşuda bir kez.
- **Neden hiçbir şık öbürünü geçmiyor:** B2C kartıyla aynı denge; kitle yerine bütün hesaplar.

## kriz.acik.basin (`product.encryption_flaw_press`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Yorum yapmayalım | Yok (açık beat). | İtibar −8; B2C: Kitle −%5; B2B: bütün hesaplar −8. | Yok (zar ana kartta atıldı). | Tek şık. |

- **1. şığın sayıları:** add_reputation −8; audience_delta pct −0,05 (B2C) ya da trust_delta accounts all −8 (B2B). Erdem'in onayladığı #31 3. şık satırı.
  - **Örnek dünyalar:** Kitle 10.000'de −500; Series A'da 60 hesap × −8.

- **Cevap gelmezse:** Aynı (add_reputation −8 ve kitle/hesap satırı). expires_weeks 1.
- **Tekrar:** Ana karta bağlı: follows kriz.acik, tick scheduled, bir kez.
- **Neden hiçbir şık öbürünü geçmiyor:** Tek şıklı beat (O2 baseline); bedel ana kartın 3. şıkkında zarla seçildi.

## kriz.ameliyat (`product.sprint_pm_hospital`)

| Şık | Kazanç | Bedel | Risk | En iyi olduğu durum |
|---|---|---|---|---|
| Kart Mert dönene kadar beklesin | Ek iş yok, Mert kendi kodunu kaldığı yerden sürer. | Kart sonraki sprinte kalır. | Kart sözlüyse söz olayı kendiliğinden gelir. | Kart sözsüzken ve Mert'in kodu başkasına zorken. |
| Kartı başka bir geliştirici devralsın | Kart bu sprintte sürer. | Kartın işi %20 büyür; devralanın kendi kartı bekler. | Yok. | Kart sözlü ya da sürüm için şartken. |
| Mert taburcu olunca on dakika arayıp kaldığı yeri anlatsın | Kart ek iş olmadan sürer. | Mert'in morali düşer (−6). | Yok. | Mert'in morali yüksekken ve kart acilken. |

- **1. şığın sayıları:** Hastalık yokluğu 2 hafta (yeni HR seam'i, karar 14; bütün şıklarda ve on_expire'da ortak). sprint_card_carry.
  - **Örnek dünyalar:** Kartın kalan işi bir sprint gecikir.
- **2. şığın sayıları:** assign_to (kartta olmayan bir geliştirici; _assign kilidi Ürün arayüzünden); sprint_card_effort amount_seam urun.decision_card_effort × amount_mult 0,2.
  - **Örnek dünyalar:** K1 15 → +3 puan; K2 25 → +5; K3 40 → +8 (kâğıtların +5/+10 aralığında).
- **3. şığın sayıları:** change_morale scope dev −6.
  - **Örnek dünyalar:** Tek kişinin morali; 76 eşiğindeyse verim +%5'ten düşer.

- **Cevap gelmezse:** Hastalık yokluğu ve sprint_card_carry (1. şıkla aynı). expires_weeks 1.
- **Tekrar:** Kâğıt standardı: latch cooldown_weeks 52, max_fires 3; family_subject cooldown_weeks 52 (kişi başına yılda bir).
- **Neden hiçbir şık öbürünü geçmiyor:** 1. şık zamanı (kart gecikir), 2. şık işi (puan ve başka bir kart), 3. şık hasta kişinin moralini öder.
- **Not:** 2. şık sonucu 'kalan işi %20 artar' idi; mevcut seam kartın toplam puanıdır (urun.decision_card_effort), yeni seam yazmamak için 'kartın işi %20 büyür' (metin_ekleri). Kalan işten okunması istenirse 3. adım urun.decision_card_left yazar.

## Değişen ya da yeni metinler

Ayrıntı `metin_ekleri.json`'da. Hepsi TR/EN onay bekliyor.

| Kart | Şık | Alan | TR | Neden |
|---|---|---|---|---|
| calisan.bilgisayar | 1 | sonuc | Kasa yaklaşık bir haftalık gider kadar azalır, Mert'in morali biraz yükselir | Sabit $1.000 yerine haftalık giderden ölçeklenir (ilk çalışanlı Ev'de ~$1.000). Çip doları yazar; bu satır Erdem'in okuduğu özettir. |
| calisan.bilgisayar | 2 | sonuc | Kasa değişmez, Mert'in morali biraz düşer, eski laptopla dört hafta verimi %10 düşer | Yalnız −4 moral 75'lik yeni çalışanın verim bandını değiştirmez; şık oynanışta bedavaydı. |
| calisan.dugun | 1 | sonuc | Kasa Ece'nin aylık maaşının %10'u kadar azalır, Ece'nin morali çok yükselir | Sabit $400 yerine kişinin maaşından (hr.salary + amount_slot). |
| calisan.dugun | 2 | sonuc | Kasa Ece'nin aylık maaşının %3'ü kadar azalır, Ece'nin morali yükselir | Sabit $100 yerine maaştan. |
| calisan.dugun | 3 | sonuc | Kasa Ece'nin aylık maaşının %1,5'i kadar azalır, Ece'nin morali değişmez | Sabit $60 yerine maaştan. |
| calisan.kaba_musteri | 1 | sonuc | Kuzey İnşaat'ın aramaları sana geçer, iki hafta verimin düşer, Zeynep'in morali biraz yükselir | Şığın okunur bir kazancı yoktu; 3. şıktan yalnız pahalıydı. |
| ekip.ayni_izin.pm | 1 | sonuc | İkisi de iki hafta izinde, ikisinin de morali yükselir; izinden önceki iki hafta ikisinin de verimi %20 artar | PM'in işi hazırlıktır; 'verim %30 düşer' hazırlığı öne alan bir kazanç vermiyor, şık 3. şıktan her yönden kötüydü. TR/EN onay bekliyor. |
| ekip.ayni_izin.gelistirici | 3 | sonuc | Geç başlayanın izni bu yıl örtüşmeyecek kadar kayar, Kasa onun bir haftalık maaşı kadar azalır | Adım 1'in '[2. adım]' yer tutucusu dolduruldu. |
| ekip.ayni_izin.testci | 3 | etiket | Birinin iznini kaydır, karşılığında prim ver | Eski 3. şık 'İkisi de gitsin, sürüm kaysın' koddaki doğal davranışla 2. şıkla aynıdır (test fazı geliştiriciye kendiliğinden düşer, sprint_system.gd:1276-1281); geliştirici varyantının prim şıkkı geldi. TR/EN onay bekliyor. |
| ekip.ayni_izin.testci | 3 | sonuc | Geç başlayanın izni bu yıl örtüşmeyecek kadar kayar, Kasa onun bir haftalık maaşı kadar azalır | Yukarıdaki etiketle birlikte. |
| ekip.kod_inceleme | 2 | etiket | Kerem'le Onur'u bir gün aynı masaya oturt, notları birlikte kapatsınlar | Bedel iki kişinin birer günüdür; yarım gün 3. şıktan her yönden ucuz kalıyordu. |
| ekip.kod_inceleme | 2 | etiket_yuva | {lead} ile {dev} bir gün aynı masaya otursun, notları birlikte kapatsınlar | Etiketle aynı değişiklik, eksiz yuva biçimi. |
| ekip.kod_inceleme | 2 | sonuc | Kerem'in ve Onur'un bu hafta birer günü gider, Onur'un morali yükselir | Sayı −%30 (yalnız Kerem) yerine ikisine −%20. |
| ekip.kod_inceleme | 1 | sonuc | Kartın kalan işi kısalır, kart çıkınca hattına bir hata düşer, Kerem'in morali biraz düşer | Hata kartın incelenmemiş kodundadır, kart çıkınca düşer (sprint_card_trim bugs 1). |
| ekip.soz_verdi | 2 | locked_reason | Bu sözü bir kez uzattık. | Söz yalnız bir kez uzar (PromiseRegistry.extend); kilitli şık gerekçesiyle görünür. |
| musteri.egitim | 2 | sonuc | Kasa hesabın yarım aylık ücreti kadar artar, Deniz'in iki günü gider, Anadolu Yapı'nın memnuniyeti biraz düşer | Sabit $600 yerine hesabın MRR'ından (musteri.mrr + amount_slot). |
| musteri.kendi_hatasi | 3 | sonuc | Emre'nin bir haftası gider, Ekin Gıda'nın memnuniyeti artar, Stok hattını kullanan öbür hesapların memnuniyeti biraz artar | Geliştiricinin haftası temsilcinin gününden yalnız pahalıydı; önlem hattın bütün hesaplarına yayılır. |
| rakip.ayni_ozellik | 1 | sonuc | Üç hesabın memnuniyeti artar; kartın testi hata bulursa aynı üç hesabın memnuniyeti daha çok düşer | 'Kalıcı olarak' yanlış: trust_offset dört haftada söner. B (−8) A'dan (+6) büyük. |
| rakip.panel | 2 | sonuc | Aday imzalarsa hesap ilk yıl %15 indirimli açılır, imzalamazsa teklif düşer | Adım 1'in X yer tutucusu: %15. |
| dunya.disk | 2 | locked_reason | Büyük müşterilerimizin sözleşmesinde bugünkü sağlayıcımızın adı yazıyor. | Yardımcı yönetmen kararı: 3★ ve üstü hesap varken 2. şık kilitli, gerekçe kademeden bağımsız (adım 1'deki 'adıyla yazıyor' cümlesinin yerine). TR/EN onay bekliyor. |
| odul.final | 1 | sonuc | Bir günün provaya gider; %25 ihtimalle birincilik (Kasa +$10.000, Marka +3), yoksa Marka +1; açık hatan varsa ihtimal düşer ve demo sahnede takılır (Marka −2) | Bir şık tek zar taşır; takılma durumdan okunur. Kesin Marka +3 canlı demoyu video ve slayttan her yönden iyi yapıyordu. Çip yüzdeyi seam'den yazar, karta sayı girmez. |
| odul.final | 3 | sonuc | Yarım günün slaytlara gider, Marka +1, %10 ihtimalle birincilik | Şığın bedeli yoktu. |
| kriz.acik | 1 | sonuc | İtibar +3, Kitle −%2 | Çip yüzdeyi tam sayı yazar; −%0,5 yazılamaz. Oran korundu (1. şık 2. şıkkın iki katı). |
| kriz.acik | 2 | sonuc | İtibar +1, Kitle −%1 | Aynı gerekçe. |
| kriz.ameliyat | 2 | sonuc | Kart sürer, kartın işi %20 büyür, devralanın kendi kartı bekler | Mevcut seam kartın toplam puanını okur (urun.decision_card_effort); 'kalan' için yeni seam gerekir. |
