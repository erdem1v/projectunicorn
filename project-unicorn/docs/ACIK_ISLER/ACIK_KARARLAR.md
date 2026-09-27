# Açık kararlar

Bu dosya, sahibin (Erdem) henüz karar vermediği maddelerin tek listesidir. Ajanlar buradaki hiçbir
maddeyi açık bir sahip kararı olmadan uygulamaz, değiştirmez ya da başka bir işin yan etkisi olarak
kapatmaz. Bir madde karara bağlandığında satırı, kararı uygulayan commit'te bu dosyadan silinir.

"Kaynak" satırlarındaki kısa adlar aşağıdaki belgelerdir. Hepsi temizlikte silindi (CLAUDE.md yeniden yazıldı);
`6e3e190` commit'inde durur ve `git show 6e3e190:<yol>` ile okunur (yol git köküne göredir). K numaraları
ONERI_v3'ün, D ve B numaraları ACIK_KARARLAR_D1-D13'ün numaralarıdır; ikisi de bu dosya değildir.
"SONLAR #n", SONLAR_GAZETE_MODLAR'ın "Açık kararlar (sahip)" listesindeki n. maddedir. GDD'ler,
`docs/writing/` ve `docs/content/` ağaçta kalır.

| kısa ad | yol |
|---|---|
| ONERI_v3 | `6e3e190:project-unicorn/docs/handoff/ONERI_v3_K1-K32.md` |
| ACIK_KARARLAR_D1-D13 | `6e3e190:project-unicorn/docs/handoff/ACIK_KARARLAR_D1-D13.md` |
| HANDOFF_series_a | `6e3e190:project-unicorn/docs/handoff/HANDOFF_series_a.md` |
| PUSH_ONCESI_KONTROL | `6e3e190:project-unicorn/docs/handoff/PUSH_ONCESI_KONTROL.md` |
| RAPOR_LOKAL | `6e3e190:project-unicorn/docs/handoff/RAPOR_LOKAL_2026-09-25.md` |
| SONLAR_GAZETE_MODLAR | `6e3e190:project-unicorn/docs/design/SONLAR_GAZETE_MODLAR.md` |
| TOPLANTI_VE_SERIES_A_ONERI | `6e3e190:project-unicorn/docs/design/TOPLANTI_VE_SERIES_A_ONERI_2026-09.md` |
| VIZYON_v1_YANITLAR | `6e3e190:project-unicorn/docs/design/VIZYON_v1_YANITLAR.md` |
| localization_draft_en | `6e3e190:project-unicorn/docs/design/localization_draft_en.md` |
| EVENT_REVISION | `6e3e190:project-unicorn/docs/reports/EVENT_REVISION_2026-09.md` |
| EVENT_ENGINE_QUESTIONS | `6e3e190:project-unicorn/docs/EVENT_ENGINE_QUESTIONS.md` |
| SEAM_REGISTRY | `6e3e190:project-unicorn/docs/SEAM_REGISTRY.md` |
| eski CLAUDE.md | `6e3e190:project-unicorn/CLAUDE.md` |

## Temizlikten çıkanlar

Temizlikte bulunan ve kodda doğrulanan maddeler. 5. madde dalga 1'in `tempo.gd` düzeltmesinin yan etkisidir; 7. madde
doğrulama sırasında bulundu; 8. ve sonrası temizliğin son turundan.

- **1 · İŞKOLİK huyu etkisiz.**
  - Ne oluyor: Huyun tek etkisi olan `overtime_morale_mult` (0,5) anahtarını hiçbir kod okumuyor; huy okumaları
    `HRConstants.trait_mult` ya da `trait_sum` üzerinden geçiyor, ikisi de bu anahtarla çağrılmıyor.
  - Nerede: `scripts/systems/hr_constants.gd` (`TRAITS["last_one_out"]`); okuması gereken yer
    `scripts/systems/hr_morale_system.gd` (`tick_drift` ya da `_scale`).
  - Oyuncuya etkisi: Bedelsiz üç huydan biri boş. Hover "Mesai morali onda çok daha yavaş erir." diyor, mesaideki
    İŞKOLİK herkes kadar eriyor.
  - Seçenekler: A) `tick_drift`: kişi mesaideyken (günde sekiz saatin üstü) taban sürüklenme bu çarpanla çarpılır;
    yalnız günlük erime değişir ama huy ölçeklemesi `_scale` dışına çıkar. B) `_scale`: kişi mesaideyken her moral
    düşüşü çarpılır (olay deltaları ve HRActions önizlemeleri dahil); §7.1'in "tek fonksiyon" kuralı korunur, etki
    daha geniş. İkisinde de karar gereken: çarpan bütün sürüklenmeye mi (11 saatte toplam ×0,75, sekiz saat çalışandan
    bile yavaş erir) yoksa yalnız sekizin üstündeki paya mı (×1,25) uygulanır.
  - Kaynak: Ekip GDD §6, §7.1.

- **2 · GERÇEK LİDER'in faydası yok.**
  - Ne oluyor: `lead_experience_mult` (1,5) okunmuyor; huyun yalnız bedeli işliyor (`HRMoraleSystem._charge_departure`:
    biri ayrılınca huyu taşıyan −10, öbürleri −5 moral alır). Bağlanacağı yerde ikinci bir sapma var:
    `HRSystem.tick_experience` herkesin deneyim kazancını kurucunun Liderlik'iyle çarpıyor
    (`HRConstants.experience_gain_mult`, en çok ×1,5); Ekip §4.2 ise "Ekibin deneyim kazanım hızını liderin kendisi
    değil, GERÇEK LİDER huyu etkiler" diyor.
  - Nerede: `scripts/systems/hr_constants.gd` (`TRAITS["takes_them_under"]`), `scripts/systems/hr_system.gd`
    (`tick_experience`). Lider koltuğu alan başına değil, yapım başına tektir: `FeatureBuild.lead_engineer_id`
    (`ProductSystem.set_build_lead`).
  - Oyuncuya etkisi: Bedelli huy saf yük; hover "Sorumlusu olduğu alanda herkes daha hızlı öğrenir; ayrılıkları ağır
    alır." diyor, öğrenme hızı değişmiyor. Buna karşılık kurucunun Liderlik'i ekibin öğrenmesini hızlandırıyor.
  - Seçenekler: A) Yapımın aktif lideri bu huyu taşıyorsa yapıma atananların (liderin kendisi hariç) kazancı
    `lead_experience_mult` ile çarpılır, kurucu Liderlik çarpanı kalkar; GDD'nin harfi. B) A'daki bağlama yapılır,
    kurucu Liderlik çarpanı da kalır; ikisi çarpılır (×2,25'e kadar), §4.2 cümlesi güncellenir. C) Bağlanmaz; huy metni
    (`HR_TRAIT_TAKES_THEM_UNDER_EFFECT`) ve Ekip §6 satırı değişir.
  - Kaynak: Ekip GDD §4.2, §6.

- **3 · "Koşunun ilk 3★'ı" tekrarlanabiliyor.**
  - Ne oluyor: `SalesLedger.is_newsworthy_signing` ilkliği kalıcı bir kayıttan değil aktif hesaplardan okuyor
    (`deal_count(c.scale) <= 1`). Churn eden hesap kayıttan silindiği için koşunun tek 3★ hesabı giderse sonraki 3★
    imza yine "ilk" sayılır.
  - Nerede: `scripts/systems/sales_ledger.gd` (`is_newsworthy_signing`, `announce_signing`),
    `scripts/systems/b2b_sales_system.gd` (`_remove_lost`).
  - Oyuncuya etkisi: Haber bandı satırı ve +3 marka (`SalesConstants.PRESTIGE_SIGNING_BRAND`) yeniden gelir; marka
    Series A inancını oynatır. Yalnız erişim bandı 3 iken görünür (bant altındayken her 3★ zaten lig üstü haberdir).
  - Seçenekler: A) Koşu mandalı: yeni bir `GameState.FLAG_TYPES` bayrağı her 3★ imzada yazılır (balina ya da lig üstü
    olsa da), `is_newsworthy_signing` onu okur. Kayıt dokunuşu: varsayılanı false yeni bayrak; ilk 3★'ını kaybetmiş eski
    kayıtta bir kez daha haber çıkabilir; Satış §13'ün kayıt listesine girer. B) Kod kalır, §7.3'ün tanımı "defterdeki
    tek aktif 3★" olur; tek 3★'ını kaybedip yenisini imzalayan haberi ve +3 markayı yeniden alır.
  - Kaynak: Satış GDD §2, §7.3 [ÇALIŞMA], §13.

- **4 · Balinanın güven şartı `security_cert`'i saymıyor.**
  - Ne oluyor: Şart yalnız `not InfraSystem.blocks_enterprise_signature()` okuyor: Yerel dışındaki her sağlayıcı şartı
    karşılıyor, `security_cert` araştırması sayılmıyor. GDD'ye göre sapma iki yönlü: Satış §8 şartı "sağlayıcı ya da
    security_cert" diye koyar; Ürün §10 güven koşulunu yalnız Kurumsal Bulut'a verir (düz Bulut "nötr"); Ar-Ge §4.2
    sertifikayı Kurumsal Bulut'a ikinci yol sayar. GDD'ye uyan yüklem zaten var ama üretimde okuyucusu yok (yalnız
    smoke): `InfraSystem.meets_enterprise_trust()`.
  - Nerede: `scripts/systems/sales_faucet_system.gd` (`_condition_met`, `WHALE_COND_PROVIDER`),
    `scripts/systems/infra_system.gd` (`blocks_enterprise_signature`, `meets_enterprise_trust`).
  - Oyuncuya etkisi: Yerel sağlayıcıda Güvenlik Sertifikasyonu'nu bitiren oyuncuya balina hâlâ "Altyapı güvencesi
    istiyor." der; düğüm metni ise "Kurumsal alıcının ilk sorusu cevaplanmış olur" diyor. Düz Bulut'a geçmek şartı
    hemen karşılıyor.
  - Seçenekler: A) Şart `meets_enterprise_trust()` okur: GDD'nin harfi; düz Bulut'ta balina bugün sormadığı şartı
    sormaya başlar. B) `not blocks_enterprise_signature() or ResearchSeam.completed("security_cert")`: düz Bulut
    okuması kalır, sertifika eklenir; Ürün §10 ve Satış §8 güncellenir. C) Sertifika kancası emekliye ayrılır: Ar-Ge
    §4.2, düğüm metni (`PROD_RND_NODE_SECURITY_CERT_DESC`) ve `meets_enterprise_trust` düzeltilir. Alt soru: satış
    masası aynı yüklemi üç yerde okuyor (kayıp nedeni `SalesLedger._blocker_cleared` / `LOSS_PROVIDER_TRUST`, oran
    `provider_ok`, `probe_provider_trust` kilidi); yalnız biri değişirse müşteri döner ve aynı nedenle yine kaybedilir
    (Satış §9), bu yüzden birlikte değişmeliler. Masa metni `SALES_LOCK_PROVIDER` "kurumsal kademe" diyor ama yüklem
    düz Bulut'u da kabul ediyor.
  - Kaynak: Satış GDD §8, §9; Ürün GDD §10; Ar-Ge GDD §4.2 (rev 1.7).

- **5 · Elde tutma ve talep kartları genişleme teklifini 30 gün tutabiliyor (`tempo.gd` düzeltmesinin yan etkisi).**
  - Ne oluyor: `tempo.gd` düzeltmesiyle olay freninin Katman 2'si (aynı özne; müşteri 30, çalışan 14 gün) ilk kez
    çalışıyor: `EvTempo._record` artık kabul edilen kartın öznesini yazıyor, önceden hep boş yazıyordu. Fren yalnız
    havuz çekilişinde sorulur ama tetiklenen ve istenen kartlar da pencereyi damgalar: `customer.retention` ve
    `customer.request_*`. Bugünkü destede müşteri öznesi taşıyan tek havuz kartı `customer.expansion`; `expansion_ready`
    seçicisi uygun hesaplardan yalnız en yüksek MRR'lıyı döndürür, o hesap frenliyse sıradakine düşmez.
  - Nerede: `scripts/events/present/tempo.gd` (`assign`, `_record`), `scripts/events/gate/scope.gd`
    (`_select_customer`, `"expansion_ready"`), `scripts/events/core/engine.gd` (`_step_pool`).
  - Oyuncuya etkisi: En büyük uygun hesap elde tutma ya da talep kartı aldıktan sonra 30 gün boyunca hiçbir hesaba
    genişleme kağıdı gelmez; damga tekrarlanırsa daha uzun (hesaplar 22 günde bir talep açar,
    `CS_REQUEST_INTERVAL_DAYS`). Satış sekmesindeki "Değerlendir" düğmesi istek olarak geçtiği için çalışır.
  - Seçenekler: A) Özneyi yalnız havuz kabulü damgalar: elde tutmadan birkaç gün sonra aynı hesaba genişleme gelebilir
    (§13.1'in "aynılık" sorunu); §13.3'e bir cümle. B) Çekiliş sıradakine düşer: frenli hesap dışarıda bırakılıp seçici
    yeniden çözülür; deterministik kalır, `EvEngine` ve `EvScope` değişir, §14.3'e bir cümle. C) Olduğu gibi kalır;
    §13.3'e "tetiklenen ve istenen kartlar da pencereyi damgalar" yazılır.
  - Kaynak: olay motoru GDD §13.1, §13.3, §14.3.

- **6 · Risk'teki hesaba genişleme teklif edilebiliyor.**
  - Ne oluyor: `B2BSalesSystem.can_offer_expansion` pazara, duruma, `last_expansion_day` mandalına ve olgunluğa (45 gün,
    `EXPANSION_MATURE_DAYS`) bakıyor, yaşam evresine (`lifecycle_phase`) bakmıyor. Aynı yüklemi `musteri.is_expansion_ready`
    seam'i (açıklaması "mature, healthy…" ama sağlık okunmuyor) ve `expansion_ready` seçicisi okuyor. Günlük tarama yalnız
    sağlıklı hesabı `expansion` evresine taşısa da havuz kartı `customer.expansion` Risk'teki hesabı seçebiliyor; masadaki
    kağıt da hesap Risk'e düşünce geçerli kalıyor. Bu dalgadan önce de böyleydi.
  - Nerede: `scripts/systems/b2b_sales_system.gd` (`can_offer_expansion`, `expand`), seam `musteri.is_expansion_ready`.
  - Oyuncuya etkisi: "Churn'e ~N gün" sayan bir hesap için "Büyüme fırsatı" kağıdı gelebilir; kabul koltuk ve MRR ekler,
    hesap Risk'te kalır ve genişleme hakkı harcanır.
  - Seçenekler: A) `can_offer_expansion` Risk'i dışlar: tek satır; seam, seçici ve tarama birlikte düzelir. Bedel: Risk'e
    düşen hesabın masadaki kağıdı açılışta düşer ve `one_shot` mandalı kart kabul edilirken harcandığı için hesap bir daha
    teklif alamaz; bu yol da çözülmeli. B) Kalır; seam açıklaması düzeltilir.
  - Kaynak: Satış GDD §19 (genişleme kapısı "Korunanlar" arasında).

- **7 · Moral düşüş ölçeği hep kurucunun Liderlik'i.**
  - Ne oluyor: `HRMoraleSystem._scale` her çalışanın moral düşüşünü kurucunun Liderlik'iyle ölçüyor. Ekip §7.1: "O alanın
    liderinin Liderlik yıldızı — lider yoksa kurucunun Liderliği (§4.2)"; §4.2 kurucuyu yalnız lideri olmayan alanlar
    (Satış, Destek, Hesap masaları) için sayar.
  - Nerede: `scripts/systems/hr_morale_system.gd` (`_scale`, `_leadership_drop_mult`). Lider koltuğu yapım başına tektir
    (`FeatureBuild.lead_engineer_id`).
  - Oyuncuya etkisi: Yapıma yüksek Liderlik'li bir lider atamak ekibin moralini korumuyor; "iyi lider ekibi ayakta
    tutar" (§4.2) hissi oluşmuyor.
  - Seçenekler: A) Yapıma atananlar için yapımın aktif liderinin Liderlik'i, öbürleri için kurucununki okunur. B) Kalır;
    §4.2 ve §7.1 kurucuyu tek kaynak diye güncellenir.
  - Kaynak: Ekip GDD §4.2, §7.1.

- **8 · EvTicker'ın tuttuğu oyuncu-sonucu satırlarını kimse okumuyor.**
  - Ne oluyor: EvTicker.push, PRIORITY_PLAYER satırlarını _held listesine ekliyor ve kayda yazıyor (EvSave, anahtar
    'held'). Ama projede _held'i okuyan ya da gösteren hiçbir yüzey yok. Motor GDD §18.3 'oyuncu-sonucu satırları asla
    düşürülmez' diyor; satırlar düşmüyor, ama hiçbir yerde görünmüyor da. Haber akışı tamponu dolunca aynı satır
    arşive girmiyor.
  - Nerede: `scripts/events/present/ticker.gd` (`_held`, `push`, `to_dict` / `from_dict`),
    `scripts/events/core/save.gd` (`held` alanı).
  - Oyuncuya etkisi: Tampon doluyken gelen bir oyuncu-sonucu satırı (expire_note, karar teyidi) canlı şeritte bir kez
    kayar, sonra geri bakılacak bir yerde kalmaz. Aynı sonuç History'de varsa (§18.1) kayıp yalnız ticker
    arşivindedir.
  - Seçenekler: (a) _held'i bir yüzeye bağla (ör. haber akışı arşivinde öncelikli satır ya da History). (b) _held'i
    emekliye ayır ve §18.3'ü 'oyuncu-sonucu History'de durur' diye yaz. (c) Haber akışı tamponunda oyuncu-sonucu
    satırına öncelik ver.
  - Kaynak: Olay motoru GDD §18.1, §18.3; motor GDD §18.2 koda göre yeniden yazılırken görüldü.

- **9 · Seçicili tarama kartı tek özneye bağlanıyor; mandalı dolu özne öbür hesapları bekletiyor.**
  - Ne oluyor: Günlük taramadaki varlık anahtarlı kartlar bağlamsız önerilir ve seçici tek özne döndürür:
    `customer.cs_escalation` için en düşük memnuniyetli tırmanan hesap (`escalated`), `funding.sheet_expiry` için en
    az iş günü kalan teklif (`expiring_sheet`). O öznenin mandalı doluysa kart G3'te düşer, aynı taramada başka uygun
    özne denenmez. `cs_escalated` her gün yeniden hesaplanan bir durumdur (`B2BSalesSystem._tick_customer`) ve kartın
    hesap başına mandalı 21 gün: en mutsuz tırmanan hesap tırmanık kaldıkça öbür tırmanan hesaplara kart gelmez.
    `sheet_expiry` fon başına one_shot: iki teklifin son günü aynıysa ikinci fonun uyarısı hiç gelmez, ikisi birlikte
    karar gününe geçince seçici ikisini de atlar. `funding.sheet_decision` aynı düzenekle fonları bilerek sıraya
    koyuyor (kart notu), orada sorun yok. Kuyruk ve masa kimliği düzeltmesi bunu çözmez, çünkü ikinci özne hiç
    önerilmiyor. Kod okumasıyla doğrulandı, koşuda ölçülmedi.
  - Nerede: `scripts/events/gate/scope.gd` (`_select_customer` "escalated", `_select_investor` "expiring_sheet"),
    `scripts/events/gate/gate.gd` (`propose`: varlık anahtarlı kartta G5, G3'ten önce),
    `scripts/events/core/engine.gd` (günlük tarama); kartlar `data/events/cards/customer/cs_escalation.json`,
    `data/events/cards/funding/sheet_expiry.json`.
  - Oyuncuya etkisi: İki hesabın temsilcisi aynı dönemde alarm verirse ikinci hesabın tırmanma kartı 21 gün boyunca ya
    da ilk hesap toparlanana dek gelmeyebilir. Son günü aynı olan iki term sheet'ten ikincisinin "son 3 gün" uyarısı
    hiç gelmez; karar kartı (`funding.sheet_decision`) yine gelir.
  - Seçenekler: A) Seçici mandalı dolu özneyi atlayıp sıradakine düşer: deterministik kalır, 5. açık maddenin B
    seçeneğiyle aynı düzenek (EvScope seçimi mandala bakar). B) Tarama kartı uygun her özne için ayrı önerilir: aynı
    gün birden çok örnek olur, fazlası Katman 4 ile kağıda düşer (§20 A6'daki gibi). C) Kalır: özneler sırayla
    işlenir; kart notlarına ve motor md §27'ye yazılır.
  - Kaynak: Olay motoru GDD §4.3, §20 A6, §27.4 (seçiciler), §27.5 madde 2 (iki canlı teklifte ikinci uyarının
    yutulması); docs/ACIK_ISLER/ACIK_KARARLAR.md 5. madde (aynı seçici düzeneği).

- **10 · VC iç sesi, sorulmuş soruya gelecek zamanla bakıyor (Beat 3 _MONO satırları).**
  - Ne oluyor: 3. vuruşta VC'nin sorusu (active_line) ile iç ses (monologue_text) aynı ekranda aynı anda çıkıyor. İç
    ses satırları ise gelecek zamanda yazılmış: "Churn'ü soracak.", "Tek-kurucu riskini soracak.", "Rakibi masaya
    koyacak.", "En zayıf ekseni bulacak.". Oyuncu soruyu okurken iç ses onun daha sorulacağını söylüyor.
  - Nerede: `scripts/systems/vc_pitch_system.gd` (`_beat3_view_state`: soru `active_line`, iç ses `monologue_text`),
    `scripts/modals/meeting_scene.gd` (`_apply_active_line` ikisini aynı anda çizer); anahtarlar `VC_Q_*_MONO` ve
    `SEED_Q_*_MONO`.
  - Oyuncuya etkisi: Sahnenin zamanı kayıyor: VC sormuş, iç ses "soracak" diyor. Satır bir önsezi gibi okunuyor ama
    önsezi için artık çok geç. Hazırlık ipucunun ("Sayıları hazırla") işe yarayacağı an zaten geçmiş.
  - Seçenekler: A) Metin: iç ses satırları şimdiki zamana ya da tepkiye çevrilir (ör. "Churn'ü soruyor. Sayılar hazır
    mı?"). TR ve EN sahip yazar, mekanik değişmez. B) Zamanlama: iç ses 2. vuruşta, soru gelmeden önce gösterilir.
    Bunun 1. vuruş istihbaratına bağlanıp bağlanmayacağı ayrıca seçilir. Bu, vuruş yapısını değiştirir. C) Olduğu gibi
    kalır. K31 (toplantı diyaloglarının yazım turu) kapsamına alınabilir.
  - Kaynak: ONERI_v3 §2 (şüphe 5); ACIK_KARARLAR Frank belgeleri maddesi (K31 yazım turu).

- **11 · Elde tutma kartı yalnız Risk'e girişte: kurtarma azaldı, churn arttı (kalibrasyon).**
  - Ne oluyor: `customer.retention` artık yalnız hesap Risk'e girerken açılıyor; kartın kendi notu kararı bu ana
    veriyor. Önceden churn geri sayımı her gün aynı sinyali yaydığı için Risk'teki her hesap her gün yeni kart
    alıyordu. full_run tohum 1 (760 gün): retention kartı 438 → 261, CHURN 44 → 101, İNDİRİM 98 → 31, SÖZ 105 → 88;
    730. gün MRR 409.490 → 278.481, marka 100 → 3; son aynı (running_on_fumes). Hiçbir sabit değişmedi.
  - Nerede: `scripts/autoload/customer_registry.gd` (`set_churn_countdown`, `customer_churn_countdown_changed`),
    `data/events/cards/customer/retention.json` (tetik, `cooldown_days`), churn geri sayımı ve seçenek etkileri
    `scripts/systems/b2b_constants.gd`'de.
  - Oyuncuya etkisi: Risk'e düşen hesap için karar bir kez sorulur; kaçırılırsa Satış sekmesindeki "İlgilen" kartı
    yeniden açar. Kurtarma şansı artık her gün yenilenmediği için daha çok hesap kaybediliyor; geri sayım süresi ve
    Oyala/İndirim etkileri eski günlük soruya göre oturmuş olabilir.
  - Seçenekler: A) Davranış kalır; churn geri sayımı ve seçenek etkileri tam probe setiyle ölçülerek yeniden kalibre
    edilir. B) Günlük yeniden soru tasarım sayılır; kartın notu ve Satış §19 buna göre yazılır, eski davranış geri
    gelir. C) Kalır, kalibrasyon sonraya.
  - Kaynak: `retention.json` `_port_note`; Satış GDD §19 (retention kartı ve churn geri sayımı korunanlar arasında);
    bu commit'in probe ölçümü.

- **12 · Gitmiş hesabın sinyali elde tutma kartını başka bir hesaba bağlıyor (11. maddeye bağlı).**
  - Ne oluyor: Kapı, çağıranın verdiği özne id'sini (sinyal yükü, istek) yalnız o varlık hâlâ varsa kullanıyor. Hesap
    gitmişse, id yanlış türdeyse ya da başka slota bağlıysa seçiciye düşüyor ve kartı başka bir hesaba bağlıyor. GDD
    §4.3 ise çağıranın bağlamının kullanıldığını ve tahmin yapılmadığını söylüyor. full_run:760:sim:1'de ilk örnek 70.
    günde: churn eden co_lead_57_35'in sinyaliyle açılan customer.retention, Risk'teki başka bir hesaba bağlanıyor.
    Verilen id gitmişse kartı G5'te reddeden bir sürüm bu dalgada ölçüldü ve geri alındı. O sürümde elde tutma kartı
    261'den 217'ye, CHURN 101'den 153'e, İNDİRİM 31'den 0'a iniyor (koşudaki 31 indirimin hepsi yanlış bağlanan
    kartlardan geliyor), 4. seçenek 18'den 0'a, SÖZ satırı 88'den 84'e düşüyor. 730. gün MRR 278.481'den 210.894'e,
    kasa 2,44M'den 1,58M'e, müşteri 450'den 346'ya, çalışan 13'ten 7'ye iniyor; marka 3'ten 19'a çıkıyor. Son aynı
    (running_on_fumes). 11. maddedeki rakamlar bugünkü, yanlış bağlanan davranışla ölçüldü.
  - Nerede: scripts/events/gate/scope.gd (resolve, verilen id dalı), scripts/events/gate/gate.gd (propose, G5),
    scripts/events/core/engine.gd (sinyal adımı, request), scripts/autoload/customer_registry.gd (churn geri sayımı
    sinyali)
  - Oyuncuya etkisi: Giden hesap için açılan elde tutma kartı, oyuncuya Risk'teki başka bir hesabı kurtarma şansı
    veriyor. O hesap Risk'e girişte zaten sorulmuş olabilir, yani 11. maddedeki "bir kez sorulur" kuralının dışında
    ikinci kez soruluyor. Koşudaki indirim seçimlerinin tamamı bu yoldan geliyor.
  - Seçenekler: A) Verilen id gitmişse kart G5'te gerekçesiyle reddedilir (§4.3'ün lafzı). 11. maddenin kalibrasyonu
    yeni rakamlarla yapılır. B) Seçiciye düşme tasarım sayılır. §4.3'e ve §27'ye "verilen özne gitmişse seçici yeniden
    bağlar" yazılır. C) A ile 11. madde tek karar olarak ele alınır: churn geri sayımı ve Oyala/İndirim etkileri aynı
    ölçümle yeniden oturtulur.
  - Kaynak: Olay motoru GDD §4.3; ACIK_KARARLAR 11. madde; bu dalganın probe ölçümü (HEAD ab863fa, full_run:760:sim:1
    --lang=tr)

- **13 · Masadaki kağıdın öznesi giderse süre dolumu: ceza, not ve son uyarı birbirini tutmuyor.**
  - Ne oluyor: Kağıt, masaya düştüğünde öznelerini bağlıyor. Bir varlık kağıt masadayken giderse son gün uyarısı
    düşüyor (`EvGate.revalidate` bütün slotlara bakar), oyuncu açmak isterse kağıt kayboluyor. Ama süre dolunca
    `on_expire` çalışıyor, history `expired` yazıyor ve expire_note ticker'a gidiyor. İki durum var. (1) Ana özne
    (hesap) gitti: on_expire'ın etkileri hedef bulamıyor ("satisfaction_delta found no target" hatası,
    full_run:760:sim:1'de 3 kez). Not satırı da hesabın adı yerine iç id'sini yazıyor (ör. "co_lead_… bir daha
    aramadı."); bu dalgaya kadar her süre dolumunda ham "expire_note" yazıyordu. (2) İkincil slot (talep kartının
    temsilcisi) gitti: ceza hesaba işliyor ve not çıkıyor. Aynı koşuda 8 kağıt bu durumda (günler 327, 341, 563, 682).
    §12.4 "expire_note zorunludur, sessiz süre dolumu yoktur" diyor. §4.4 ve §20 A1 ise gösterimdeki yeniden
    doğrulamayı anlatıyor, açılmamış kağıdın süre dolumunu değil.
  - Nerede: scripts/events/core/engine.gd (_step_paper_expiry, _step_last_warnings, open_paper),
    scripts/events/gate/gate.gd (revalidate), scripts/events/gate/scope.gd (still_valid),
    scripts/events/present/presenter.gd (_display_name), data/events/cards/customer/request_*.json ve retention.json
    (scope, on_expire, expire_note)
  - Oyuncuya etkisi: (1) Haber akışında bir iç kod (hesap id'si) görünüyor; ceza kimseye işlemiyor. (2) Temsilci
    ayrılınca oyuncu son uyarıyı görmüyor ve kağıdı açamıyor, ama cezayı yiyor. Bu uyarısız bir kayıp.
  - Seçenekler: A) Hangi slottaki varlık giderse gitsin kağıt süre dolumunda düşer: history `dropped` (entity_gone),
    on_expire ve not çalışmaz. §12.4'e bu istisna yazılır. Seeded koşuda 8 kağıdın cezası kalkar. B) Yalnız ana özne
    gidince düşer; ikincil slotta uyarı ve açılış da yalnız ana özneye bakar, temsilci gitse de kağıt açılır ve ceza
    işler. Ana özne kuralı seeded koşuyu değiştirmiyor (bu dalgada ölçüldü). C) Süre dolumu hep çalışır: bağlam
    bağlanırken görünen adı da dondurur, not gitmiş varlığı adıyla anar, hedefsiz ceza sessizce atlanır. D) Temsilci
    slotu açılışta yeniden seçilir (reassign benzeri, yeni mekanik).
  - Kaynak: Olay motoru GDD §4.4, §12.4, §20 A1, §20 B11; bu dalganın probe ölçümü

- **14 · Etki sözlüğünde karşılığı olmayan fiiller (uygulanmayan, hep reddedilen, çipsiz).**
  - Ne oluyor: Tablolarda duran dokuz fiilin `_apply`'da kolu yok: assign_to, send_on_leave, start_training,
    damage_product, add_customer, convert_audience, open_paid_tier, change_salary, fire_employee. Lint onları kabul
    ediyor, oyunda "not implemented" diye reddediliyorlar. `add_mrr` motor GDD §8.1 ve §8.3'te gerçek bir fiil; kod
    onu hep reddediyor (MRR defterden türetiliyor, `engine_probe` bu reddi doğruluyor) ve bu ayrılık §27'de yazılı
    değil. `notify` metni anahtar ya da çeviri olmadan ham basıyor. Çip tarafında 13 fiil ne `_describe_modifier`'da
    etiketli ne `SILENT_VERBS`'te: clear_flag, set_timed_flag, ticker_push, notify, open_negotiation, add_mrr,
    assign_to, send_on_leave, start_training, damage_product, change_salary, fire_employee, add_customer. Tersine
    `convert_audience` ile `open_paid_tier`'in çipi var ama fiilleri uygulanmıyor. Bugün hiçbir kart bu fiilleri
    kullanmıyor.
  - Nerede: scripts/events/core/effects.gd (NEUTRAL_VERBS, ECONOMIC_VERBS, _apply: "add_mrr", "notify"),
    scripts/modals/event_modal.gd (SILENT_VERBS, FIXED_CHIPS, _describe_modifier), scripts/events/tools/lint.gd
    (_lint_effects), scripts/events/tools/engine_probe.gd (_check_effects)
  - Oyuncuya etkisi: Bugün yok. Bir yazar bu fiillerden birini kullanırsa lint geçer ve kart oyunda görünür, ama
    seçenek söylediğini yapmaz: sessizce reddedilir, bazen çipi de gösterilir. notify ile yazılan satır tek dilde
    kalır.
  - Seçenekler: A) GDD'nin adını verdiği fiiller (fire_employee, add_customer, damage_product, assign_to) sahibi
    modülün seam'iyle bağlanır, geri kalanı tablolardan çıkar. Bağlanan her fiil bir çip ya da SILENT_VERBS kaydıyla
    gelir. B) Bağlanmayan her fiil tablolardan çıkar ve lint onu bilinmeyen fiil diye reddeder. add_mrr GDD §8.1'den
    düşer, §27'ye "MRR türetilir, yazılmaz" notu girer. notify ya line_key alır ya da kalkar. C) Olduğu gibi kalır:
    liste §27'ye yazılır, lint uygulanmayan fiile uyarı verir.
  - Kaynak: Olay motoru GDD §8.1, §8.3, §11.1 (info sınıfı), §27; CLAUDE.md §5 EFFECT-VISIBILITY RULE

- **15 · Bütçe bitince seçenek kilitlenmiyor (spend_budget, §8.5).**
  - Ne oluyor: GDD §8.5, bütçe bitince o etkiyi taşıyan seçeneğin kilitlenip gerekçesini göstermesini istiyor. §20 E8
    bu kontrolü `requires`'a koyuyor. Ama `EvBudgets.remaining()`'i okuyan ne bir seam ne bir koşul yaprağı var;
    §5.2'nin listesinde de bütçe yaprağı yok. Bütçe biterse `EvBudgets.spend` yalnız hata basıyor, seçenek açık
    kalıyor. Hiçbir kart `spend_budget` kullanmıyor.
  - Nerede: scripts/events/core/budgets.gd (remaining, spend), scripts/events/core/effects.gd ("spend_budget"),
    scripts/events/core/condition.gd (yaprak listesi), scripts/events/seams/
  - Oyuncuya etkisi: Bugün yok, çünkü frank_aphorism bütçesini harcayan kart yok. İlk kart bağlandığında üçüncü
    aforizma seçeneği kilitlenmez: oyuncu tıklar ve hiçbir şey olmaz.
  - Seçenekler: A) Her bütçeye bir seam (ör. `frank.aphorisms_left`): yazar seçeneği `requires` ile kilitler, gerekçe
    metnini kart taşır (E8'in dediği). B) §5.2'ye yeni koşul yaprağı `{"budget": ad}`. C) Motor `spend_budget` taşıyan
    seçeneği kendiliğinden kilitler, gerekçe ortak bir anahtardan gelir (§8.5'in lafzı).
  - Kaynak: Olay motoru GDD §8.5, §5.2, §20 E8

- **16 · Ark belleği (arc.vars) yazılıyor ama okunamıyor.**
  - Ne oluyor: `set_arc_var` fiili ve `EvArcs.set_var` arkın `vars` alanına yazıyor, alan kayda da giriyor. Ama onu
    okuyan ne bir koşul yaprağı ne kod var: §5.2'nin ark yaprakları yalnız active, at_step, ended ve awaiting_subject.
    Hiçbir kart bu fiili kullanmıyor. §20 G4 ise arka özgü durumun arc.vars'ta tutulduğunu söylüyor.
  - Nerede: scripts/events/core/arcs.gd (set_var), scripts/events/core/effects.gd ("set_arc_var"),
    scripts/events/core/condition.gd (ark yaprakları), scripts/modals/event_modal.gd (SILENT_VERBS)
  - Oyuncuya etkisi: Bugün yok. Bir yazar ark belleğine yazabilir ama arkın sonraki adımı o değeri okuyamaz.
  - Seçenekler: A) Yeni yaprak `{"arc": "var", "id", "key", "op", "value"}`, §5.2'ye bir satır. B) `set_arc_var`
    emekliye ayrılır; ark belleği bayraklarla tutulur (G4'ün uyardığı çakışma riskiyle). C) Kalır; §27'ye "vars
    okunmuyor" notu girer.
  - Kaynak: Olay motoru GDD §5.2, §10.1, §16.1, §20 G4

- **17 · Özne başına ark limiti: ikinci ark ertelenmiyor, hiç başlamıyor (§10.7).**
  - Ne oluyor: §10.7 ve §20 A4'e göre bir özne ikinci bir ark alırsa o ark `deferred` olur ve birincisi bitince
    yeniden proposal'a girer. `EvArcs.start` ise ikinci arkı reddediyor ve bir yere kaydetmiyor (limit
    `EvTuning.ARC_PER_SUBJECT_DEFAULT`'tan okunuyor). Ark, bir seçeneğin `start_arc` etkisiyle başlıyor. O kartın
    mandalı harcandığı için kart yeniden önerilmiyor, yani ark hiç başlamıyor. Bugün fixture'lar dışında özneli ark
    yok (`arc_final_stretch` öznesiz).
  - Nerede: scripts/events/core/arcs.gd (start), scripts/events/core/effects.gd ("start_arc"),
    scripts/events/core/tuning.gd (ARC_PER_SUBJECT_DEFAULT)
  - Oyuncuya etkisi: Bugün yok. Aynı özneye iki ark bağlandığında ikinci arkı açan seçenek sessizce hiçbir şey
    başlatmaz.
  - Seçenekler: A) Ertelenen başlatma motorda tutulur ({arc_id, subject}); birinci ark bitince ikincisi başlar. Kayda
    yeni bir alan girer. B) Seçim anında engel: özne doluysa arkı başlatacak seçenek gerekçesiyle kilitlenir. C) Ret
    kalır; §10.7 ve A4 "ikinci ark başlamaz" diye yeniden yazılır.
  - Kaynak: Olay motoru GDD §10.7, §10.9, §20 A4, §27

- **18 · Okunmayan beş EFFECT_* anahtarı: DRAFT-EN kaydı ile CSV süpürmesi çelişiyor.**
  - Ne oluyor: EFFECT_MRR, EFFECT_QUALITY_BONUS, EFFECT_NEW_TEAMMATE, EFFECT_PROMISE_HONOR ve EFFECT_PROMISE_REFUSE
    CSV'de duruyor. Ama `event_modal.gd` (FIXED_CHIPS, _describe_modifier) hiçbirini okumuyor, üretim kodunda da
    okuyanı yok. DRAFT-EN kaydı `EFFECT_*` ailesini "üretim kodunun okudukları" arasında sayıyor ve "referanssız
    emekli anahtarları CSV süpürmesi siler" diyor. ISLER'deki CSV süpürmesi ise ACIK_KARARLAR'da geçen anahtarları
    bırakıyor. Bu beş anahtar için iki kural çelişiyor.
  - Nerede: localization/strings.csv; scripts/modals/event_modal.gd (FIXED_CHIPS, _describe_modifier);
    docs/ACIK_ISLER/ACIK_KARARLAR.md (DRAFT-EN kaydı); docs/ACIK_ISLER/ISLER.md (CSV süpürmesi)
  - Oyuncuya etkisi: Yok. Anahtarlar okunmayan metin.
  - Seçenekler: A) Süpürmeye girer, silinir. B) Kalır; DRAFT-EN kaydında "okunmayan, ileride çip olacak" diye ayrı
    satır alır. C) Yeniden bağlanır, ör. EFFECT_PROMISE_HONOR/REFUSE vaat kartlarının çipi olur (içerik kararı).
  - Kaynak: CLAUDE.md §8 (ölü CSV anahtarı); ACIK_KARARLAR DRAFT-EN kaydı; ISLER CSV süpürmesi

- **19 · arc_final_stretch sönünce ticker'a ham "arc_faded" yazılıyor.**
  - Ne oluyor: `arc_final_stretch` fade politikasında `note_key: "arc_faded"` taşıyor. Bu ne bir CSV anahtarı ne bir
    kart metni; ark tanımının metin bloğu da yok. Ark Series A imzasında ya da bootstrap kilometre taşında
    (`phase.bootstrap_milestone`) söner ve haber akışına ham "arc_faded" satırı düşer.
  - Nerede: data/events/arcs/soft_cap_stretch.json (on_invalidate.note_key), scripts/events/core/engine.gd
    (_invalidate, fade kolu), scripts/events/present/ticker.gd (push)
  - Oyuncuya etkisi: Ark canlıyken kârlı bootstrap kilometre taşı alınırsa (EA/tam) ticker'da ham bir kod satırı
    görünür. Series A imzasında koşu bittiği için pratikte görünmeyebilir.
  - Seçenekler: A) Yeni bir oyuncu satırı yazılır, önce EN sonra TR (ör. "The year-end file closed."); note_key o
    anahtarı taşır. B) note_key kaldırılır; bu ark için §10.5'in "ticker izi" düşer ve §27'ye not girer. C) Ark close
    politikasına geçer ve görünür bir kartla kapanır.
  - Kaynak: Olay motoru GDD §10.5, §18.3; CLAUDE.md §5

- **20 · Ay sonu özeti çipinde tire ve script literali (±0 —).**
  - Ne oluyor: Ay boyunca değişmeyen satırın (MRR, kasa, ekip, marka) çipinde "±0 —" yazıyor. Bu metin bir anahtar
    değil, script literali ve uzun tire içeriyor.
  - Nerede: scripts/modals/month_summary_modal.gd `_delta_chip`
  - Oyuncuya etkisi: Değişmeyen her satırda iki dilde de aynı "±0 —" çipi görünüyor. Bu, oyuncu metnindeki tire
    yasağına aykırı.
  - Seçenekler: A) Yalnız "±0" yazılsın (sembol, anahtar gerekmez). B) Yeni MONTH_CHIP_FLAT anahtarı açılsın (önce EN,
    sonra TR). C) Olduğu gibi kalsın, sembol çipi istisna sayılsın.
  - Kaynak: GDD ch01 §9 (no dashes in copy); CLAUDE.md §5

- **21 · Kurucu yaşam gideri hâlâ burn'ün tamamı.**
  - Ne oluyor: FinanceSystem.STARTING_BURN_BREAKDOWN içinde "founder": 50 $/gün [ÇALIŞMA] var ve 1. günün burn'ünün
    tamamı bu. Finans'ta FIN_BURN_FOUNDER "Kurucu yaşam gideri / Founder living costs" satırı olarak görünüyor. GDD
    yaşam giderini kaldırıyor: ch08 §1'e göre burn maaşlar + araçlar + servis + marketing'den oluşuyor ve 'araçlar'
    kalemi kodda yok.
  - Nerede: scripts/systems/finance_system.gd `STARTING_BURN_BREAKDOWN`, `BURN_IDS`; localization/strings.csv
    `FIN_BURN_FOUNDER`
  - Oyuncuya etkisi: Başlangıç runway'i (10K$ ile ~6,6 ay) bu kaleme dayanıyor ve oyuncu GDD'nin kaldırdığı bir gider
    satırını görüyor. Kalem silinirse ilk maaşa kadar burn sıfıra iner.
  - Seçenekler: A) Kalem ch08 §1'in 'araçlar' kalemi olarak yeniden adlandırılsın (aynı 50 $/gün, yeni FIN_BURN_TOOLS
    metni; denge değişmez). B) Kalem silinsin (0 $, erken oyun baskısı kalkar, yeniden kalibrasyon gerekir). C)
    Kalsın, ayrılık GDD'ye istisna olarak yazılsın.
  - Kaynak: GDD ch08 §1; ch02 §1; Ekip GDD §9.1 ('Yaşam maliyeti yoktur')

- **22 · InvestorRegistry'deki donmuş değerleme ve pay rakamları okunmuyor.**
  - Ne oluyor: Her fonun opening_terms'ündeki valuation_m ve dilution_pct hiçbir yerde okunmuyor. Series A açılış
    şartları ARR'den türetiliyor; registry'den yalnız board_seats ve board_veto okunuyor.
  - Nerede: scripts/autoload/investor_registry.gd `INVESTORS[*].opening_terms`; okuyucu
    scripts/systems/vc_pitch_system.gd `_derive_series_a_terms`
  - Oyuncuya etkisi: Bugün bir etkisi yok, ölü veri. Ancak satın alma kartı ve finance.valuation() seam'i için
    değerleme kaynağı eksik ve docs/writing/FRANK_UNWIRED.md bu rakamları o kaynağın adayı olarak anıyor.
  - Seçenekler: A) valuation_m ve dilution_pct silinsin, opening_terms yalnız yönetim kurulu şartlarını taşısın
    (FRANK_UNWIRED satırı güncellenir). B) Satın alma teklifi ya da finance.valuation() seam'i için değerleme kaynağı
    olarak bağlansın. C) Series A türetimine fon başına taban ya da tavan olarak bağlansın.
  - Kaynak: GDD ch09 §5; ACIK_KARARLAR 'Seam envanterinin açık YOK satırları' (finance.valuation()) ve 'Satın alma
    sonu'; docs/writing/FRANK_UNWIRED.md

- **23 · Aylık ürün notu Ar-Ge sekmesinde okunamıyor; rozet sönmüyor.**
  - Ne oluyor: Koşunun ilk notu bir kez modal açılıyor. Sonraki notların, ya da ilk modal Esc ile kapatıldıysa o
    notun, okunacağı bir yüzey yok. RnDSystem._note_unread true kalıyor, mark_note_read'i çağıran bir sekme yüzeyi
    yok, Ar-Ge ray rozeti (attention_count) koşu boyunca yanık kalıyor. RND_NOTE_FIRST_HINT oyuncuya 'bundan sonra bu
    not her ay Ar-Ge sayfasında' diyor, ama sayfada not yok. RND_NOTE_UNREAD ve RND_NOTE_OPEN bu yüzeyin park edilmiş
    etiketleri.
  - Nerede: scripts/systems/rnd_system.gd (note_pending, pending_note, mark_note_read, take_first_note_modal,
    attention_count); scripts/tabs/rnd_tab.gd (sayfada not yüzeyi yok); scripts/modals/rnd_card_modal.gd (_build_note,
    _read_and_close); scripts/main/main.gd (product_note_issued → ilk not modalı); localization/strings.csv
    RND_NOTE_UNREAD, RND_NOTE_OPEN, RND_NOTE_FIRST_HINT
  - Oyuncuya etkisi: İkinci aydan itibaren raporlar görünmez oluyor. Rozet sürekli 1 (donmuş araştırma varsa 2)
    gösteriyor ve gerçek bir donmayı haber verme işlevini yitiriyor. İlk modaldaki ipucu karşılığı olmayan bir söz
    veriyor.
  - Seçenekler: A) Ar-Ge sayfasına bir not şeridi eklenir: 'OKUNMADI · Aç' → RnDCardModal note (ipucu satırı olmadan)
    → mark_note_read. GDD §6.1'in tarif ettiği yol budur, yeni UI işidir. B) Ara çözüm: Ar-Ge sekmesi açılınca not
    okunmuş sayılır ve rozet söner; not yine okunamaz. C) Her rapor modal açar; bu §6.1 MÜHÜRLÜ kuralına aykırı olduğu
    için GDD değişikliği ister.
  - Kaynak: Ar-Ge GDD §6.1 (MÜHÜRLÜ teslim biçimi), §5.6.2 (rozet sayımı), §10 (arge.note_pending)

- **24 · Düğüm kartında gereksinim satırı ham '{area} {stars}' basıyor.**
  - Ne oluyor: RnDDetailPanel._add_state_body açılmış ya da kilitli düğümde RND_REQ_STARS ('{area} {stars}')
    anahtarını {"n": yıldız} ile formatlıyor, yer tutucular dolmuyor. Ekranda 'Ürün alanı · {area} {stars} · ~4 gün
    (Kurucu)' görünüyor. Düzeltme bir metin kararı istiyor: yıldız ★2 mi yazılır, 2★ mı (SALES_BAND_STAR '{n}★'),
    yoksa sayı mı; RND_AREA_OF ('{area} alanı') parçası kalır mı; iki alanlı düğümde iki gereksinim nasıl dizilir.
    İlişkili ret metni RND_NEED_STARS ('{area} alanında {n} yıldız gerekiyor.') GDD'nin 'Ürün ★2 gerekiyor.'
    biçiminden farklı. GDD'nin biçimine uyan RND_NEED_AREA ('{area} {stars} gerekiyor.') kullanılmıyor.
  - Nerede: scripts/tabs/rnd/rnd_detail_panel.gd (_add_state_body, varsayılan kol); scripts/tabs/rnd/rnd_ui_shared.gd
    (area_parts, refusal_text REFUSE_STARS); localization/strings.csv RND_REQ_STARS, RND_AREA_OF, RND_NEED_STARS,
    RND_NEED_AREA
  - Oyuncuya etkisi: Araştırılabilir her düğümün kartında ham yer tutucu görünüyor. Oyuncu gereken yıldız eşiğini
    Başlat'tan önce okuyamıyor, oysa §5.5 bunu MÜHÜRLÜ kural olarak istiyor.
  - Seçenekler: A) §5.5 biçimi: alan parçası yerine her alan için 'Ürün ★2' (RND_REQ_STARS {area}, {stars}='★2'); ret
    satırı RND_NEED_AREA'ya geçer ve RND_NEED_STARS silinir. B) §8 örneği: 'Ürün alanı · ~9 gün (Kurucu)' kalır,
    yıldız ayrı parça olarak 'Ürün alanı ★2' biçiminde birleşir. C) Yalnız yer tutucu düzeltilir, 'Ürün alanı · Ürün
    ★2 · …' tekrarı kabul edilir. Her seçenekte TR/EN onay bekler.
  - Kaynak: Ar-Ge GDD §5.5 (MÜHÜRLÜ: 'Ürün ★2 · ~9 gün · Kurucu', 'Ürün ★2 gerekiyor.'), §7 ('Yazılım ★2 gerekiyor.'),
    §8 (kart örneği 'Ürün alanı · ~9 gün (Kurucu) · GPU kirası $600')

- **25 · Atama panelinde izindeki ya da eğitimdeki kişi seçilebiliyor ama koltuğa oturmuyor.**
  - Ne oluyor: RnDAssignPanel._person_row meşgul (izinde, eğitimde, kurucu pitch hazırlığında) kişiyi soluk ama
    seçilebilir bırakıyor; gerekçesi 'oyuncu onu yine de seçebilmeli'. CharacterRegistry.assign_job STATUS != ACTIVE
    olan kişiyi 'inactive' diye reddediyor ve RnDSystem.set_assignees onu yalnız push_warning ile düşürüyor. Seçim
    kabul edilmiş görünüyor ama kişi atanmıyor. Seçilenlerin hepsi meşgulse Başlat REFUSE_ZERO ile kapanıyor ve
    RND_ASSIGN_ZERO 'Seçtiklerinin hiçbiri bu alanda çalışmıyor.' diyor; bu cümle gerçek sebebi (izin ya da eğitim)
    söylemiyor.
  - Nerede: scripts/tabs/rnd/rnd_assign_panel.gd (_person_row, _on_commit); scripts/systems/rnd_system.gd
    (set_assignees, start_refusal REFUSE_ZERO, research_per_day); scripts/autoload/character_registry.gd (assign_job
    'inactive'); localization/strings.csv RND_ASSIGN_ZERO
  - Oyuncuya etkisi: Oyuncu izindeki birini araştırmaya koyduğunu sanıyor; o kişi döndüğünde araştırmada olmuyor. Ret
    cümlesi yanlış sebep gösteriyor.
  - Seçenekler: A) Meşgul satırlar seçilemez olur (görünür kalır, gerekçesi 'İzinde · 12g sonra katılır' satırı). B)
    HR, izindeki ya da eğitimdeki kişiyi araştırmaya oturtur (§7'deki 'atama silinmez, dönünce devam' mantığının yeni
    atamaya uzatılması; Ekip sahibinin dosyası). C) Seçim kalır, Uygula ya da Başlat oturtulamayan kişiyi adıyla bir
    satırda bildirir ve REFUSE_ZERO metni izin ya da eğitimi söyler.
  - Kaynak: Ar-Ge GDD §5.3 (panel havuzu), §5.5 (sıfır katkı koruması), §7 ('Araştırmadaki kişi izne çıkar' satırı;
    yeni atama için sessiz); Ekip GDD §12.3

- **26 · Kilitli yuvada '?' ve çapraz koşul satırı yok.**
  - Ne oluyor: GDD kilitli yuvayı '? Ürün' diye yazıyor; RND_LOCKED_SLOT değeri '{area}', '?' yok. Sürpriz duvar
    yasağı çapraz koşullu devam düğümünün kilitli yuvasında 'Başka bir ailede bir araştırma ister.' yazılmasını
    istiyor; RND_NEED_CROSS_BLIND CSV'de var ama hiçbir kod onu okumuyor. Karo küçük (MicroLabel, ortalı), bu yüzden
    ikinci satırın karoda mı, üzerine gelince mi, yoksa derin bağla seçilince detay kartında mı görüneceği bir
    yerleşim kararı.
  - Nerede: scripts/tabs/rnd/rnd_tree_view.gd (_make_tile, TILE_LOCKED dalı); scripts/tabs/rnd/rnd_detail_panel.gd
    (_add_blockers, kilitli düğüm); localization/strings.csv RND_LOCKED_SLOT, RND_NEED_CROSS_BLIND
  - Oyuncuya etkisi: Oyuncu kilitli yuvanın bir araştırma olduğunu '?' ile okuyamıyor. Çapraz koşul ancak ad
    açıldıktan sonra görünüyor, yani §3'ün yasakladığı sürpriz duvar oluşuyor.
  - Seçenekler: A) RND_LOCKED_SLOT '? {area}' olur; çapraz koşullu kilitli karoya ikinci MicroLabel satırı
    RND_NEED_CROSS_BLIND eklenir. B) '?' eklenir; çapraz satırı yalnız karonun üzerine gelince ipucu olarak çıkar. C)
    '?' eklenir; çapraz satırı derin bağla seçilen kilitli düğümün detay kartında (_add_blockers) yazılır. Her
    seçenekte TR/EN onay bekler.
  - Kaynak: Ar-Ge GDD §3 (MÜHÜRLÜ: kilitli yuva '? Ürün'; sürpriz duvar yasağı), §5.5, §8 ('kilitli yuva (ad yok, ?)')

- **27 · Üç düğümün adlandırılmış maliyet etiketi yazılmamış.**
  - Ne oluyor: rnd_tree.json'da ai_engine, security_cert ve analytics_engine 'cost_label': true taşıyor. Kart
    PROD_RND_NODE_<ID>_COST anahtarını arıyor (RnDUiShared.t_or), hiçbiri CSV'de yok, bu yüzden kart GDD'nin 'GPU
    kirası $600' örneği yerine çıplak '$600' gösteriyor. GDD yalnız ai_engine için etiket veriyor ('GPU kirası');
    security_cert ($900) ve analytics_engine ($400) için etiket yok.
  - Nerede: data/techtree/rnd_tree.json (cost_label); scripts/tabs/rnd/rnd_detail_panel.gd (_add_state_body,
    has_cost_label ve t_or); scripts/systems/research_tree.gd (has_cost_label); localization/strings.csv
    (PROD_RND_NODE_*_COST yok)
  - Oyuncuya etkisi: Nakit maliyetli üç düğümde oyuncu paranın neye gittiğini görmüyor. Kart GDD §8 örneğinden eksik
    kalıyor.
  - Seçenekler: A) Üç etiket yazılır (EN önce, TR ayrı adım): ai_engine 'GPU kirası {money}', security_cert ve
    analytics_engine için yeni metin. B) Yalnız ai_engine etiketi yazılır, öteki ikisinden cost_label kaldırılır. C)
    Etiket kuralı emekliye ayrılır: cost_label ve t_or kolu silinir, tutar çıplak kalır (GDD §8 örneği güncellenir).
  - Kaynak: Ar-Ge GDD §8 (kart örneği 'GPU kirası $600'), §13 (nakit maliyetler [K]: ai_engine $600, analytics_engine
    $400, security_cert $900), §12.1

- **28 · Kurucu huylarının etkisi yok ama etki metni gösteriliyor.**
  - Ne oluyor: Onboarding 2. sayfası her kurucu huyunun altında bir etki satırı basıyor (TRAIT_*_EFFECT, ör. 'Ar-Ge
    sıçramaları daha sık', 'Pivot maliyeti yüksek'). Seçilen huy id'leri kurucunun Character.traits'ine yazılıyor, ama
    kurucu huylarını hiçbir sistem okumuyor; FounderConstants.TRAITS yorumu bunları RESERVED diye işaretliyor.
  - Nerede: scripts/systems/founder_constants.gd (TRAITS, effect_key); scripts/onboarding/steps/origin_traits_step.gd
    (huy kartındaki effect_lbl); scripts/autoload/game_state.gd (initialize_run, kurucunun traits'i);
    localization/strings.csv (TRAIT_*_EFFECT)
  - Oyuncuya etkisi: Oyuncu koşunun başında bir etki vaat eden huy seçiyor, ama seçim oyunda hiçbir şeyi
    değiştirmiyor. 'Pivot maliyeti yüksek' gibi olumsuz huylar bedava.
  - Seçenekler: A) Etkileri bağla: her huy için sahibin onaylayacağı bir çarpan (ch02 §8: beceri, hız, olasılık,
    moral) ve onu okuyan sistem; sayılar [WORKING]. B) Etkiler bağlanana kadar kartta yalnız huy adı kalsın, etki
    satırı gizlensin. C) Etki satırı kalsın, yanına 'yakında' benzeri bir işaret eklensin (yeni metin, TR/EN onayı
    gerekir).
  - Kaynak: GDD ch02 §1 (kurucu huyları katalogdan, ikonla), ch02 §8 (huylar yalnız modifier); CLAUDE.md §5 (her
    seçenek görünür bir sonuca düşer)

- **29 · Mirasyedi kökeninin kilit notu: TAM SÜRÜMDE mi, ÇOK YAKINDA mı.**
  - Ne oluyor: Kilitli iki kökenden heir (Mirasyedi) 'TAM SÜRÜMDE' (LOCK_FULL), corporate_refugee (Kurumsal Firari)
    'ÇOK YAKINDA' (LOCK_SOON) notunu taşıyor. ch14 §4 'kalan kökenleri' Early Access'e, §5 'ek kökenleri' tam sürüme
    koyuyor; §3 demodaki kilitli-görünür kökenleri Heir ve Corporate Refugee diye sayıyor. 58e603e'deki görsel
    kontrolde heir'in TR 'TAM SÜRÜMDE' rozeti bilerek korunmuştu.
  - Nerede: scripts/systems/founder_constants.gd (ORIGINS, heir satırının locked_note_key'i);
    scripts/onboarding/steps/origin_traits_step.gd (kilitli köken kartı rozeti)
  - Oyuncuya etkisi: Onboarding 2. sayfadaki iki kilitli köken farklı çıkış zamanı vaat ediyor. ch14 §4 okunursa
    Mirasyedi'nin vaadi yanlış.
  - Seçenekler: A) heir LOCK_SOON'a geçsin (ch14 §4: kalan kökenler EA'da). B) LOCK_FULL kalsın, ch14 §4 ve §5
    Mirasyedi'yi tam sürüme koyacak biçimde netleştirilsin. C) İki köken de tek bir nötr kilit notu taşısın (ör.
    LOCK_CHIP).
  - Kaynak: GDD ch14 §3, §4, §5; ch01 §8; ch02 §1

## Tasarım ve denge

- **K13 · Kilometre taşı maddesi (Series B köprüsü).** ch09 §5 term sheet koşulları arasında
  "milestone clauses" sayıyor; kodda yok. Seçenekler: kur, ch09'dan çıkar ya da not olarak beklet
  (öneri: beklet). Kaynak: ONERI_v3 K13.

- **K14 · Reddedilme zinciri ve pivot mandalı (D2, D3).** Sayım kümülatif; sağlıklı şirkette `pivot_offer_made`
  sessizce yazılıyor, bağlı kartı olmadığı için zincir hiç çalışmıyor. Öneri: sayım üst üste (teklif alınınca sıfır); fonun
  kalkması sayılsın, oyuncunun kalkması ve K10 reddi sayılmasın; üçüncü redde yol kapansın, şirket sağlamsa koşu sürsün,
  çöküyorsa `vc_rejection_cascade`; mandal silinsin. Kaynak: ONERI_v3 K14, ACIK_KARARLAR_D1-D13 §1.

- **K15 · 730. gün ve canlı teklif.** Soft cap, canlı teklif ya da görüşme varken de `running_on_fumes` ile bitiriyor
  (bugünkü kural: otomatik imza yok, erteleme yok). Öneri: canlı teklif varken son gün, K10 karar kartı gelene kadar
  uzasın. Kaynak: ONERI_v3 K15.

- **K16 · Satın alma yolunu açan haller (D4).** `EndingsSystem.road_over()` yalnız oyuncu Av'da teklifi yaktığında
  ya da masadan kalktığında doğru. Fonun kalkması, K10 reddi, bütün fonların kapanması ve üçüncü red saymıyor.
  Öneri: beşi de saysın. Önce satın almanın v1'de olup olmadığı kararlaşmalı (GDD bölümü, ilk madde).
  Kaynak: ONERI_v3 K16, ACIK_KARARLAR_D1-D13 §2.

- **D5 · "Series A kararıyla yüzleşti" sayılan haller (ch13 §7).** `profitable_bootstrap`'ın beşinci şartı.
  Bugün Av'da teklifi yakmak, masadan kalkmak ve fonun kalkması yazıyor; kapı davetini reddetmek saymıyor. Öneri: D4'teki
  haller + kapı davetini 3 kez reddetmek. Demo'da koşuyu bitiren, EA/tam'da kilometre taşı gazetesini açan
  hareketi bu belirler. Kaynak: ACIK_KARARLAR_D1-D13 D5, SONLAR_GAZETE_MODLAR §7.

- **K17 · Series A kapanış metni imzalanan şartları okusun.** Bugün manşet `founder_friendly` (pay ≤ 18, veto yok) ya da
  `aggressive`; Frank satırı şartlara bakmıyor. Seçenekler: A) pay ≤ 15 ve kurul ağırlığı 0, B) yalnız kurul ağırlığı 0,
  C) üçüncü "dengeli" varyant (ch09 §7'yi genişletir). Ayrıca: imzalayan fon koşu defterine girsin mi, "Kontrol El Değiştirdi"
  yeniden yazılsın mı; hüküm satırlarını (artık yalnız demo'da) sahip yazar. Kaynak: ONERI_v3 K17, SONLAR_GAZETE_MODLAR §5.

- **K18, K19 · Seed teklifinin süresi ve reddi.** Seed teklifi hiç dolmuyor ve reddedilemiyor (garanti basamak
  hükmü, GDD bölümü). K18: Series A gibi 10 iş günü, sonra K10 karar kartı. K19: "Şimdilik hayır" seçeneği; seed
  kapısı yeniden açılmaz, bootstrap sonu açık kalır. İkisi de garanti basamak hükmünü değiştirir. Kaynak: ONERI_v3 K18–K19.

- **K20 · Seed'de 1. vuruşta çekilmek hakkı yakıyor (D6).** Hak görüşmeden önce harcanıyor. Kaydı yükleyen oyuncu hakkı
  geri alıyor, dürüst oyuncu kaybediyor; Av şeridinde yatırımcı adı boş kalıyor. Öneri: çekilmek hakkı geri versin, o fon
  seed'de kapansın, Series A'da o fonun inancı −5; onay satırı bedeli yazsın. Kaynak: ONERI_v3 K20, ACIK_KARARLAR_D1-D13 §3.

- **K21 · Seed yönetim kurulu koltuğu (D7).** fc58e7c'den beri seed masasındaki board satırı görünür ama itilemez;
  seed imzası koltuk ve vetoyu saklamıyor. Seçenekler: kalıcı yap (kaydet, pay tablosunda göster, Series A masası
  toplamı göstersin, K17 okusun) ya da satırı seed masasından kaldır. Kaynak: ONERI_v3 K21, ACIK_KARARLAR_D1-D13 D7.

- **K22 · Seed odası "şimdi değil" desin mi (D8).** Öneri: hayır; garanti basamak hükmü ve Frank'in mühürlü seed
  satırları buna dayanıyor. ch09 §4 ise "not now" sonucunu tanımlıyor. Kaynak: ONERI_v3 K22, ACIK_KARARLAR_D1-D13 D8.

- **K24 · Görüşmenin girdileri (D9).** Series A inancı MRR / `PitchConstants.CONV_MRR_REFERENCE` (40K$) oranını
  1,5'te kırpıyor; kapıya gelen herkes tavandan başlıyor. Büyüme, churn ve marj okunmuyor; `growth_flat` sorusu
  erişilemez. Öneri: fon ağırlıklı beş girdi; Beat 3 sorusu en zayıf girdiden seçilsin. Eksik: ekip girdisinin tanımı,
  ürün girdisinin sıfır noktası, marjın hep +1 olması, `CONV_BASE` ayarı. Kaynak: ONERI_v3 K24, ACIK_KARARLAR_D1-D13 §4.

- **K29 · Fon arketipleri.** ch09 §1 dört fonu "relationship / numbers / vision / follower" diye tanımlıyor; kod
  metrik / ekip / anlatı / ürün (Anchor, Nexus, Bosphorus, Meridian). Öneri: kod kalsın, ch09 güncellensin.
  Kaynak: ONERI_v3 K29.

- **Frank'in tanıştırması (ch09 §6).** ch09 §6 tanıştırmayı oynanan bir karar sayıyor (kabul = adı belli bir fonda
  kolay oda, tek başına = soğuk). Kodda sabit bir kayıt bayrağı: `warm_intro` yalnız Bosphorus'ta doğru ve inanca
  `CONV_WARM_INTRO_BONUS` (12) ekliyor. Seçenekler: tanıştırmayı oynanan bir Frank kartı yap (yüzeyin metnini sahip
  yazar) ya da ch09 §6'yı güncelle. Kaynak: TOPLANTI_VE_SERIES_A_ONERI §D6.

- **K30 · VC görüşmesinde vuruş sırası.** Bugün her fonda aynı dört sabit vuruş. Öneri: fon başına 3–4 vuruş,
  sıra fona göre değişsin. Kaynak: ONERI_v3 K30 ve §5.3.

- **K25–K27 · Satış pazarlığındaki üç açık.** Hakaretin bedeli masadan kalkmakla aynı (öneri: 60 gün kilit ve şirket
  hafızası). Aynı teklifi tekrarlamak karşı teklifi yükseltiyor (öneri: karşı teklif sabit, alıcının sabrı −2).
  "SON RAKAM" masayı kayıpla kapatıyor (öneri: son teklif olarak gitsin). Kaynak: ONERI_v3 K25–K27.

- **K28 · Satış arketipleri.** Kodda üç arketip var (`ops_cautious`, `tech_exacting`, `finance_brisk`); Satış GDD
  6–8 istiyor. Öneri: satın alma birimi, kurucu-sahip, kurumsal BT ve fiyat avcısı eklensin. Kaynak: ONERI_v3 K28.

- **`sales.price_break` bağlı değil.** Satış GDD §7.6'nın fiyat kırma kartı (`data/events/cards/customer/price_break.json`)
  hazır, ama `SalesRepSystem` an gelince yalnız `rep_discount_requested` sinyalini yayıyor, `EventGate.request` çağırmıyor;
  kart hiç gelmiyor. Bağlamak için "standart fiyattan kapat" etkisinin (imza indirimi) bir seam'i gerekiyor.
  Açık: bağlansın mı. Kaynak: EVENT_REVISION §6.5.

- **D10 · Frank'in yaklaşma satırları.** Kartlar `critical` etiketli, haftalık funding kotası onlara işlemiyor.
  Sürüm çıkışındaki Frank satırlarıyla bir gün arayla üst üste biniyorlar; "kapı açıldı" ile `gate_series_a` art arda
  iki günde geliyor. A: %50/%75/%90 satırları ch08 §5'teki Finans notuna taşınsın, `gate_series_a` en erken 3 gün sonra
  gelsin. B: kartlar kalsın, 7 gün ve 14 gün aralık şartı eklensin. Kaynak: ACIK_KARARLAR_D1-D13 §5, PUSH_ONCESI_KONTROL §8a.

- **D12 · Eski "teklif e-postası" akışı.** `docs/writing/FRANK_UNWIRED.md` §4'teki akış (e-posta, 3 gün, 30 günlük
  sayaç) K5 ve K10 ile çelişiyor; kartı bugün bağlı değil. Öneri: akış emekliye ayrılsın, metni K10 kartına ya da teklifin
  geldiği ana taşınsın. Metin: `VC_EV_DEAL_TITLE`, `DEAL_PROMPT_LINE`, `DEAL_PROMPT_SIT`, `DEAL_PROMPT_VALIDITY`,
  `DEAL_PROMPT_DEFER`; kod hiçbirini okumuyor, karar gelene kadar CSV'de kalır. Kaynak: ACIK_KARARLAR_D1-D13 §6 ve D12.

- **E (isteklilik) modeli sabitleri.** 2cbbcd8'de seçilen EAGERNESS bloğu (`TermSheetTableSystem`) onaylanmadı.
  Ölçüm (63800db): saf politikada 4 masanın 2'si fonun kalkmasıyla bitti (hedef en çok %25); E0 = 70 + uyum ile
  400 tekrarın 400'ü kalkma. Nexus'ta "diğer teklifi göster" hep yerinde duruyor; OUT satırları her itişte tekrar ediyor.
  Ölçümdeki görüşme kuralı bir harness varsayımı. Kaynak: PUSH_ONCESI_KONTROL §7, ACIK_KARARLAR_D1-D13 §8, RAPOR_LOKAL §4.

- **Skandal bayrağı ve `brand_collapse`.** `GameState.unmanaged_major_scandal` ve `active_scandal`'a oyunda yazan yok
  (`active_scandal` yalnız F6 hata ayıklama tuşuyla). Skandal geri çağrısı, −12 inanç cezası, Nexus'un skandal sorusu ve
  `HUNT_CB_SCANDAL` hiç devreye girmiyor. `brand_collapse`'a oynanarak ulaşılamıyor, telgrafı da yok. ch13 §1 onu EA'ya
  koyuyor. Seçenekler: bayrağa bir yazar bağla ya da skandal içeriğini kaldır. Kaynak: ONERI_v3 §2 ve §4.4, PUSH_ONCESI_KONTROL §5.

- **Seed ticker haberi.** Sahip kararı: seed gazete değil ticker haberidir. Uygulanmadı: seed imzası ticker'a satır
  düşmüyor. Açık: an (`SeedRoundSystem.accept` ya da `seed_round_closed` dinleyicisi), kaynak ("Ekonomi Postası" ya da
  "İÇERİDEN"), metin, fon ve tutarın yazılıp yazılmayacağı. Kaynak: SONLAR_GAZETE_MODLAR §6, SONLAR #18.

- **ANA MENÜ sonrası.** Ana menü sahnesi yok. ANA MENÜ koşuyu elle kayıt slotuna yazıp oyunu yeniden başlatıyor
  ("sanki varmış gibi"). Açılış ekranında kayıt yükleme girişi yok (ESC → Yükle ile açılıyor). Yeniden başlatma, debug'da
  komut satırından verilen `--build=ea`'yı düşürüyor. Açık: ana menü gelene kadar bu hâl yeterli mi.
  Kaynak: SONLAR_GAZETE_MODLAR §U.4 madde 4–5.

- **B2 ekonomisi (D13).** Kapı gününde (5 tohum) son ay marjı %63–75, kârlı ay serisi 7–11. Demo'da yüzleşme sayılan her
  hareket ertesi gün bootstrap zaferi getiriyor; satın alma teklifi pratikte görünmüyor. ch08 §2 marjın ölçekle düşmesini
  istiyor. "Harness mi ekonomi mi" karşılaştırması yapılmadı. Ofis gideri 0 (`FinanceSystem`'deki "office" TODO).
  Kaynak: ACIK_KARARLAR_D1-D13 B2 ve D13, HANDOFF_series_a §C, RAPOR_LOKAL §3.

- **Kadro ve İK kalibrasyonu.** Kapı gününde çalışanların %68,5'i satış ve müşteri temsilcisi, %17'si geliştirici.
  Açık soru: botun işe alım merdiveninin etkisi mi, yoksa Series A için ürün tarafında bir şart mı gerekiyor.
  EVENT_REVISION ölçümünde (61d5c2c botu) koşu başına 30–50 istifa; seed kapısı 50–60. günde açılıyor.
  Kaynak: HANDOFF_series_a §H.3, EVENT_REVISION §6.3–6.4.

- **Series A ekranlarındaki görsel gözlemler.** Masa kadranında ibre yüzde yazısının üstünden geçiyor. Seed masasındaki
  kilitli board satırı hâlâ bir hedef gösteriyor ("0 koltuk + veto → temiz"). Av'da ürün kartı TEKLİFLER panelini örtüyor;
  "BEKLEYEN" kutusu ile sıradaki teklif karışıyor. EA iflas gazetesinin rayı neredeyse boş. Satış toplantısının oda sanatı
  hep aynı. Kaynak: RAPOR_LOKAL T2.4, TOPLANTI_VE_SERIES_A_ONERI §A.

- **Oyun Vizyonu v1'in çalışma kararları.** Erdem'in 31 Ağustos tarihli belgesi repoda yok. Yanıt (54ace8d) onay almadı;
  dosya sahip kararıyla silindi. Açık kararlar: perde sınırları, 3D sanat yönü ve kapsamı, kişisel runway, 730'un Perde 2
  saati olması, remote çalışan ve ekip tavanı, ofis kataloğu, İK rolü, run kartı, teknik borç, tükenmişlik sonu. #11 (kurgu
  etkinlik adları) karar değil, mevcut yasadır (ch14 §6). Birçoğu yürürlükteki GDD'lerle çelişiyor (ch12 gerçek zamanlı 3D,
  ch14 §7 çalışan yüzü, Ekip GDD ekip tavanı). Kaynak: VIZYON_v1_YANITLAR §2–§3.

- **GDD'ler arası iki çelişki.** (1) Zor mod: ch01 §6 "v1 yalnız Normal; Hard, Normal kalibre edilene kadar
  kilitli-görünür", ch14 §2 "Hard demo'da çıkar" diyor; ch14 §8 ayarlı mı kaba mı çıkacağını açık bırakıyor. Kodda zor mod
  yok: son ekranında "ZOR MOD · YAKINDA" kilitli, Frank'in çekini ve seed'i reddetmek "zor modda açılır" kilidinde.
  `GDDs/README.md` ch01 §6 için ch14'ü okutur. Açık: Hard demo'ya girecek mi. (2) Ar-Ge sekmesi: ch12 §1 ve ch14 §3
  "kilitli-görünür" diyor; Ar-Ge GDD §2 (rev 1.8) ray öğesini ilk günden normal sekme sayıyor, kod (`UiTokens.TABS`) buna
  uyuyor. Açık: ch12 §1 ve ch14 §3 güncellensin mi.

## Metin ve yerelleştirme

- **`TERM_INV_*` masa satırları (15 TR + 15 EN).** TR 95bc9ea'da, EN 8457ce3'te yazıldı; ikisi de onay bekliyor.
  `TERM_INV_OUT_ANCHOR` için eski, onaylı EN satırı alternatif olarak duruyor. Kaynak: RAPOR_LOKAL §2b ve T2.1.

- **Frank'in yaklaşma ve soğuk çıkış satırları (10 satır).** Yaklaşma: `FRANK_APPROACH_HALF`, `FRANK_APPROACH_NEAR`,
  `FRANK_APPROACH_CLOSE`, `FRANK_DOOR_OPEN` (8e49dbd; kartlar `funding.frank_approach_*`, `funding.frank_door_open`).
  Soğuk çıkış: `VC_FRANK_COLD_{ANCHOR,NEXUS,BOSPHORUS,MERIDIAN,GENERAL_1,GENERAL_2}` (28d5edc). TR ve EN aynı turda
  taslak olarak yazıldı; bazı TR satırları EN'in çevirisi gibi. Sahibin düzeltmesini bekliyor.
  Kaynak: ONERI_v3 §6, PUSH_ONCESI_KONTROL §8c.

- **K32 · Frank'in kalan yüzeyleri (D11).** Yazılmamış: K10 karar kartı (bugün konuşmacısız), fonun masadan kalkması,
  "diğer teklifi göster" anı, fona özel masa açılışları, üçüncü redde "yol kapandı", seed'de çekilme onayı. F1–F6 taslakları
  ACIK_KARARLAR_D1-D13 §6'da. İnceleme notu: hepsi TR önce yeniden yazılır; F4 satırları E modelinden türetilmeli; F5 dönüş
  vaat ediyor; F2 suçlayıcı. Kaynak: ONERI_v3 K32, ACIK_KARARLAR_D1-D13 D11.

- **K31 · Toplantı diyaloglarının yazım turu.** Satış toplantısında 54 satır "PH:" yer tutucusu taşıyor; ayrıca Ekip'teki
  kurucu durum etiketi `HR_FOUNDER_STATE_CARE` "PH:" taşıyor. VC ve seed'de tepki satırları az ve iki oda arasında ortak,
  fonların kendi sesi yok. Öneri: açılış, tepki, geçiş ve gerekçeli kapanış slotları, "en uzun süredir söylenmemiş" seçimi,
  hafıza; önce yaklaşık 150 satırlık MVP, sonra yaklaşık 425 satır. Fon ses kartları yalnız EN; Anchor'ınki onaylı.
  Kaynak: ONERI_v3 K31, §5 ve §5.4; TOPLANTI_VE_SERIES_A_ONERI §A–§C.

- **Olay içeriği eksik (ch11 §1–§2, ch14 §2).** ch11 dokuz ark ve Frank hariç ~40 düğüm, ch14 §2 demo için 40–60 düğüm,
  en az bir rakip hamlesi ve bir olay (incident) istiyor. Canlı destede Frank'inkiler dahil 35 demo kartı var. Y3'te yalnız
  istifa var; Y4 (Frank'in `hire_nudge`'ı dışında), Y7, Y8 ve Y9'un kartı yok. `quiet` etiketli kart yok, olay motoru GDD
  §13.6'nın sessiz tabanı boş dönüyor. İlk adaylar: Y7 hata eşiği ve düzeltme koşusu kararı, Y4 ilk işe alım, Y8 rakibin
  fiyat kırması. Kaynak: EVENT_REVISION §9.

- **Son ve kapı metinleri (K23 dahil).** `END_BS_HEAD` "{company} Kimseye El Açmadan Ayakta", `END_BS_SUB` "Dışarıdan tek
  kuruş almadan büyüyen bir şirket…" diyor. Oysa Frank'in çeki normal modda reddedilemiyor ve seed alınmış koşu da
  bootstrap'a ulaşıyor. `ENDING_CARD_SERIESB_BODY` "Series A oyunu bitirmez" diyor; `ENDING_BADGE_EA` Series B'yi Erken
  Erişim'e koyuyor (ch14 §5: tam sürüm). `ENDING_RUN_META` sabit "NORMAL MOD" yazıyor. Canlı metinde tire (ch01 §9,
  ch11 §7): `GATE_ADVANCE`, `GATE_SERIES_A_BODY_0`, `END_META_SERIES_A_CLOSE_FRANK`, `END_META_BANKRUPTCY_FRANK`,
  `END_HL_SHUTTER_STARTED`; CSV'nin TR sütununda toplam 63 satır tire taşıyor (emekliler dahil). `END_META_BANKRUPTCY_FRANK`
  "Otuz gün"ü elle yazıyor, `EndingsSystem.SHUTTER_DAYS`'i okumuyor. `END_META_*_FRANK` satırları FRANK_ORPHANS'ta.
  Kaynak: ONERI_v3 K23, SONLAR_GAZETE_MODLAR §1.6 ve §5.6, SONLAR #17 ve #21, PUSH_ONCESI_KONTROL §10.

- **Karışık dilli satırlar.** TR ekranda İngilizce kalanlar: `TERM_LEVER_BOARD` "Board", `EFFECT_TERM_TABLE`
  "Term sheet masası açılır". Av listesindeki "— · Tier 2'de" ise CSV'de değil, `InvestorRegistry` içinde sabit bir Türkçe
  literal. Hiçbiri sözlükte ya da ödünç kelime listesinde yok. Seçenek: Türkçeleştir ya da listeye ekle.
  Kaynak: RAPOR_LOKAL T2.4, TOPLANTI_VE_SERIES_A_ONERI §D9.

- **DRAFT-EN kaydı.** EN'i "düz doğru" ama ses geçişi görmemiş aileler (kayıt 2026-08-19, TR önce kuralından önce).
  Kayıttaki anahtarlardan CSV'de duran ve üretim kodunun okudukları (`6e3e190`):
  - Satış: `B2B_EV_EXPANSION_BODY`, `B2B_EV_REP_WARN_BODY`, `B2B_EV_RENEWAL_BODY`, `B2B_COMPLAINT_*`, `HUNT_FRANK_LINE`,
    `HUNT_WALK_CONFIRM_BODY`, `HUNT_COUNTER_PIVOT`, `PRICE_TIP_PREMIUM`, `PRICE_TIP_VOLUME`.
  - Ekip: `HR_RESIGN_VOICE_*`, `HR_FILE_NOTE_*`, `HR_TRAIT_*`, `HR_ROLE_HINT_*`, `HR_WARN_COMMISSION_CASH`,
    `HR_WARN_SALARY_CASHFLOW`.
  - Ürün: `PROD_TYPE_*_{DESC,TRADEOFF}`, `PROD_TIP_{WEAK,GOOD,BUGS}`, `PROD_EV_{FIRST_SHIP,VERSION_SHIP,ITER_DECISION}_BODY`.
  - Finans ve VC: `VC_B1_*`…`VC_B4_*`, `VC_Q_*`, `VC_RES_*`, `VC_REACT_*`, `VC_WHY_*`, canlı `VC_EV_*` satırları
    (MEETING, OFFER_EXPIRING_TITLE, GO_FUNDING, DECISION, LAST_DAY), `GATE_TRACTION_*`, `GATE_SERIES_A_*`,
    `TERM_FRANK_*`, `TERM_RESULT_*`, `FIN_MENTOR_QUOTE`, `FIN_LEGEND_PROJECTION_TARGET`.
  - Dünya, olay, son: `NEWS_S_*`, `NEWS_RIVAL_{UP,DOWN}_*`, `MONTH_FRANK_*`, `EFFECT_*`, `MENTOR_INTRO_BODY`,
    `END_{SA,ACQ,BK,BC,VC,BS,RF,GENERIC}*`, `END_META_*`, `END_EV_SHUTTER_*`, `END_EV_ACQ_{TITLE,ACCEPT,DECLINE}`.
  Kayıttaki bekletilen Frank metni (`PROD_ITER_CEILING_NOTE`, üç `PITCH_*`, dört `VC_EV_*` ve `END_EV_PIVOT_*` satırları)
  aşağıdaki Frank belgeleri maddesinde. Yalnız smoke'un okuduğu kayıt aileleri (`COMPANY_BG_*`, `PROD_FEAT_*_VOICE`,
  `PROD_TYPE_*_{BET,PITCH}`, `B2B_PAIN_*`) oyunda okunmuyor. Kayıttaki referanssız emekli anahtarlar listede yok; temizliğin
  CSV süpürmesi onları siler: eski B2B pitch'inin `PITCH_{S0..S3,CHECK,RESULT,INNER,BAND,NEED,REAL_NEED}_*` satırları (üç
  Frank satırı hariç; canlı `PITCH_DIFF_*` kayıtta değil), `B2B_EV_COMPLAINT_HARD`, `B2B_EV_REQUEST_BODY_PLAIN`,
  `VC_EV_OFFER_EXPIRING_BODY`, `END_EV_ACQ_BODY`.
  Açık: EN geçişi yapılsın mı. Kaynak: localization_draft_en.

- **Frank belgeleri (bu dosyalar kalır).** `docs/writing/FRANK_ORPHANS.md`: v6'da olmayan Frank satırları, satır satır
  sahip kararı bekliyor. `docs/writing/FRANK_UNWIRED.md` §4: D12. Seed kapısı: `funding.seed_door` kartı
  `SEED_DOOR_TITLE`, `SEED_DOOR_BODY` ve `SEED_DOOR_GO` metniyle 7946ff3'ten beri canlı; Frank v6 yüzey 12 bu kartı
  "yeniden tasarlanacak" diye metinsiz bırakıyor, metnin sahip onayı belirsiz. FRANK_UNWIRED §1, §5 ve §6 bayat: seed
  kapısının metni var, `goto_tab` fiili yedi kartta çalışıyor, `FIN_SUBTAB_INVESTMENT` EN'i "Funding"; belge güncellenmeli.
  Kodun okumadığı ama karar gelene kadar CSV'de kalan Frank metni: `VC_EV_DEAL_TITLE`, `DEAL_PROMPT_LINE`,
  `DEAL_PROMPT_SIT`, `DEAL_PROMPT_VALIDITY`, `DEAL_PROMPT_DEFER`, `VC_EV_SKIP_MEETING`, `VC_EV_ACK`,
  `END_EV_PIVOT_TITLE`, `END_EV_PIVOT_BODY`, `END_EV_PIVOT_ACCEPT`, `END_EV_PIVOT_DECLINE`, `PITCH_S0_NPC`, `PITCH_S0_INNER`,
  `PITCH_INNER_CLOSED`, `PROD_SHIP_VERSION_BODY`, `PROD_SHIP_FIRST_READY`, `PROD_SHIP_FIRST_BODY`,
  `PROD_DESIGN_CEILING_NOTE`, `PROD_DESIGN_DECISION_BODY`, `PROD_ITER_CEILING_NOTE`.

## Kod ve test altyapısı

- **EA/tam'da kalan "yakında" izleri.** Av'daki kilitli "— · Tier 2'de" fon satırı (`InvestorRegistry` `locked_tier2`)
  ve Pazarlama sekmesinin koşulsuz `"lock": "ea"` kilidi her build'de görünüyor. Seçenekler: build kapsamına bağla ya da
  olduğu gibi bırak. Kaynak: SONLAR_GAZETE_MODLAR §U.4 madde 3.

- **`Chrome*` liste dışı kullanım.** Eski CLAUDE.md'nin onaylı listesi: TopBar, MonthSummary bandı, LeftTabs,
  TabPageChrome, tooltip kabuğu; ODA kendi donmuş temasından çözer. Liste dışında: Satış sekmesinin fiyat duruşu kadranı
  ve temsilci bant tavanı seçicisi (`ChromeTabButton`/`ChromeTabButtonActive`, `scripts/tabs/sales_tab.gd`), pazarlık
  sahnesinin teklif butonu (`ChromeAlert`, `scripts/modals/negotiation_scene.gd`). Seçenekler: listeye ekle ya da gövde
  varyasyonuna taşı. Kaynak: eski CLAUDE.md Chrome kuralı.

- **Pre-commit kancası.** Git kökündeki pre-commit kancası (`--event-lint` ve `loc_residue`) hazır, ama `core.hooksPath`
  ayarlı değil. Açmak tek bir `git config` komutu ve sahibe bırakıldı. Kaynak: EVENT_ENGINE_QUESTIONS Q16.

- **Çalışma ağacındaki iki `.tres` farkı.** Godot editörü `themes/master_theme.tres` ve `themes/oda_frozen_theme.tres`'i
  `uid=` öznitelikleriyle yeniden kaydetti; fark commit edilmemiş duruyor. `oda_frozen_theme` "düzenlenmez" kuralı altında.
  Seçenekler: geri al ya da commit et.

- **Seam envanterinin açık YOK satırları.** Olay motoru GDD §6.3 YOK satırlarını sahibi modülün
  açık işi olarak dosyalatır; envanter dosyası silindi (GDD §27.8). Hâlâ açık olanlar:
  - `hr.salary_vs_band(p)` · Ekip. Motor `hr.salary_band_position` ile sarıyor; sarmalayıcı Ekip'in
    seam'i gelince emekliye ayrılır. Üretimde çalışanı banda karşılaştıran başka okuyucu yok.
  - `hr.raise_edge` · Ekip. `EventBus.raise_requested` bildirili, hiç yayınlanmıyor. Ekip §9.2 zam
    talebini olay motorunun konusu sayar, kenar tanımlamaz; kenarı seçmek tasarım kararıdır.
  - `hr.promotion_edge` · Ekip. `employee_eligible_for_promotion` bildirili, yayınlanmıyor; Ekip §9.3
    seviye tavanı dışında koşul vermez. Envanterin önerisi: `experience_bar_full` kenarı ve `level < 2`.
  - `finance.valuation()` · Yatırım. Şirket değerlemesi seam'i yok; `GameState.run_valuation_m`
    yalnız term sheet imzasında yazılıyor.
  - `sales.market_share_by_segment()` · Satış / Rakipler. ch10 §2 segment başına pay istiyor; bugün
    tek küresel pay var (`sales.market_share_pct`). ch10 §8 pay formülünü ayrı bir tasarım oturumuna bırakır.
  - `destek.queue_length()` · Operasyon. Açık talep listesi `CustomerRepSystem._open_requests()`
    içinde ve özel; seam yok.
  - `rival.is_ahead_of_player()` · Rakipler. Hesap `VCPitchSystem._rival_ahead()` içinde, özel ve
    yanlış modülde.
  - `urun.tech_debt` seviye olarak · Ürün. Bugün yalnız bayrak var (`tech_debt_birikti`). Ürün §20
    teknoloji borcunu demodan çıkarır ve §23'te EA sorusu sayar; ch06 §1.4 ve ch14 §2 demoda sayar.
  Kapananlar: `finance.runway_days` kayıtlı; `founder.energy` Ekip §2 ile iptal (enerji barı yok).
  Kaynak: SEAM_REGISTRY §7.

- **Olay motoru GDD'sinin `docs/SEAM_REGISTRY.md` şartı.** §6.4'ün seam sözleşmesi her modülün
  seam'lerini `docs/SEAM_REGISTRY.md`'ye işlemesini, §23 A2 eksiklerin modüllere dosyalanmasını
  istiyor; dosya silindi (§27.8). Önerilen okuma kuralı: seam `scripts/events/seams/` altında
  kayıtlıdır ve `--event-vocab` yeniden koşulmuştur; eksikler bu dosyaya yazılır. Onaylanırsa kural
  §27.8'e eklenir. Kaynak: olay motoru GDD §6.4, §23 A2, §27.8.

## GDD'ye işlenmemiş sahip kararları

- **Satın alma sonu.** ch01 §3, ch13 §1 ve ch14 §6 "CUT: acquisition" diyor. Oysa `funding.acquisition_offer` kartı (Frank v6
  metni, 7946ff3) ve `acquisition` sonu canlı. f50d481 satışı EA/tam'da da son yaptı (onay bekliyor); kilometre taşından sonra
  kârlı şirkete de teklif gelebiliyor. Açık: satın alma v1'de var mı (D1). Varsa ch01, ch13 ve ch14 güncellenir, yoksa kart
  kapanır. Kaynak: ACIK_KARARLAR_D1-D13 B1 ve D1, SONLAR_GAZETE_MODLAR §U.4 madde 1, SONLAR #9.

- **Series A kapısı yalnız MRR; çip kalır (K1–K3, 8e49dbd).** Kapının tek şartı `finance.mrr ≥ SalesSystem.TRACTION_MRR_TARGET` (120K$).
  Büyüme serisi ve marka tabanı kapıdan kalktı; çip kaldı, çubuk ve "n/3" kalktı. ch01 §2 kapıyı "MRR çıtası + süren büyüme +
  marka + kapanış penceresi" diye tanımlıyor. ch08 §5 "kapı yalnız MRR" diyor, ama çipin yerine Finans'ta tek satırlık bir Frank
  notu istiyor. Açık: ch01 §2 ve ch08 §5 güncellensin mi (not için D10). Kaynak: ONERI_v3 K1–K3, EVENT_REVISION §6.1–6.2.

- **Build kapsamı demo/ea/full ve "Perde 3" (f50d481).** `EndingsSystem.build_scope()` build türünü export ön ayarındaki
  özel etiketten, debug'da `--build=` argümanından okur; varsayılan demo; smoke ve probe demo'ya sabit. ch14 içerik kapsamını
  tanımlıyor, build türünü ve ona bağlı davranışı tanımlamıyor. "Series A, Perde 3 oynanabilir olana kadar son" kararı
  Perde kavramına dayanıyor; Perde yalnız onaysız VIZYON yanıtında tanımlıydı. Kaynak: SONLAR_GAZETE_MODLAR §U.2, SONLAR #3 ve #20.

- **EA/tam'da kârlı bootstrap kilometre taşıdır (f50d481).** Sahibin 2026-09-25 kararları: EA/tam'da kayıp sonları koşuyu
  bitirir. Kârlı bootstrap gazeteyi bir kez açar, DEVAM ET ile koşu sürer, 730 tavanı kalkar ve final_stretch telgrafı susar.
  Frank şeridi, wishlist ve "SIRADA NE VAR?" kartları yalnız demo'da. ch13 §1 bootstrap'ı zafer sonu, ch01 §1 730'u tavan, ch13 §2
  Frank şeridini son ekranının öğesi sayıyor. Açık: ch13 §1–§2 ve galeri (§4) güncellensin mi. Kaynak: HANDOFF_series_a §D ve §H.2.

- **Av ve masa kuralları (K4–K12; 2cbbcd8, 28d5edc).** Teklif 10 iş günü; süre dolunca ertelenemez karar kartı; en çok 2 canlı
  teklif ve görünür sıra. Masada sabırla çoklu itiş var; sabır bitince son teklif ya da fonun kalkması. Reddeden fon geri dönmez
  (K9). ch09 §5 "bir kez pazarlık", ch09 §6 "geçen fon rakamlar değişince dönebilir" diyor. K9 kararı ch09 §6'daki cümlenin
  çıkarılmasını söylüyor; yapılmadı. Kaynak: ONERI_v3 §0A.

- **Seed garanti basamaktır (7946ff3, sahip hükmü 2026-08-27).** Seed odası reddedemez, seed teklifi dolmaz, masadan kalkmak
  ZOR MOD kilidinde; Frank'in mühürlü seed satırları buna dayanıyor. ch09 §3 seed için "kabul / bir kez pazarlık / ret" ve retle
  açık kalan bootstrap yolunu, ch09 §4 "şimdi değil" sonucunu tanımlıyor. Açık: ch09 §3–§4 güncellensin mi; tasarım soruları
  K18–K22'de. Kaynak: ACIK_KARARLAR_D1-D13 B3.

- **Frank sahnede görünmez.** `docs/content/events_draft/Frank Diyalogları · v6.md` ("Frank'in kanalı telefon"): anlatıcı
  Frank'i odaya sokmaz, Frank nerede olduğunu yalnız kendisi söyler. Yürürlükteki GDD'lerde bu kural yok (ch14 §7 yalnız portreyi
  ve kart gramerini tanımlıyor). Kurala takılan canlı metin: `GATE_SERIES_A_BODY_0` ("Frank telefonunu ters çevirip masaya
  koyuyor"). Açık: ch11 §7 ya da ch14 §7'ye işlensin mi. Kaynak: VIZYON_v1_YANITLAR §1.2 ve §3-C.

- **Oyuncu metnini kim yazar.** 2026-09-25 hükmü (6edade6): ajan oyuncu metnini önce Türkçe, sonra ayrı bir İngilizce olarak
  yazar; Erdem ikisini düzeltir; Frank satırları yalnız taslak. ch14 §2 "olay metnini yönetmen tarafı yazar, ajanlar yazmaz"
  diyor. Açık: ch14 §2 güncellensin mi. Kaynak: HANDOFF_series_a §F.
