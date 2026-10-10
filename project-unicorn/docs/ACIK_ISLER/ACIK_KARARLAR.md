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

Temizlikte ve sonraki turlarda bulunan, kodda doğrulanan maddeler.

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

- **2 · Ekip etkileri yapımın liderinden değil kurucunun Liderlik'inden okunuyor; GERÇEK LİDER'in faydası yok.**
  - Ne oluyor: (1) `lead_experience_mult` (1,5) okunmuyor; huyun yalnız bedeli işliyor
    (`HRMoraleSystem._charge_departure`: biri ayrılınca huyu taşıyan −10, öbürleri −5). (2) `HRSystem.tick_experience`
    herkesin deneyim kazancını kurucunun Liderlik'iyle çarpıyor (`HRConstants.experience_gain_mult`, en çok ×1,5);
    Ekip §4.2: "Ekibin deneyim kazanım hızını liderin kendisi değil, GERÇEK LİDER huyu etkiler". (3)
    `HRMoraleSystem._scale` her çalışanın moral düşüşünü kurucunun Liderlik'iyle ölçüyor; §7.1 "o alanın liderinin
    Liderlik yıldızı, lider yoksa kurucunun" der, §4.2 kurucuyu yalnız lideri olmayan alanlar (Satış, Destek, Hesap
    masaları) için sayar.
  - Nerede: `scripts/systems/hr_constants.gd` (`TRAITS["takes_them_under"]`, `experience_gain_mult`);
    `scripts/systems/hr_system.gd` (`tick_experience`); `scripts/systems/hr_morale_system.gd` (`_scale`,
    `_leadership_drop_mult`, `_charge_departure`). Lider koltuğu alan başına değil yapım başına tektir:
    `FeatureBuild.lead_engineer_id` (`ProductSystem.set_build_lead`).
  - Oyuncuya etkisi: Bedelli huy saf yük; hover "Sorumlusu olduğu alanda herkes daha hızlı öğrenir; ayrılıkları ağır
    alır." diyor, öğrenme hızı değişmiyor. Kurucunun Liderlik'i ise ekibin hem öğrenmesini hızlandırıyor hem moralini
    koruyor; yapıma yüksek Liderlik'li bir lider atamak ekibi korumuyor.
  - Seçenekler: A) GDD'nin harfi: yapıma atananlar için moral düşüş ölçeği yapımın aktif liderinin Liderlik'i,
    öbürleri için kurucununki; yapımın lideri GERÇEK LİDER taşıyorsa atananların (lider hariç) kazancı
    `lead_experience_mult` ile çarpılır ve kurucu Liderlik deneyim çarpanı kalkar. B) A'daki bağlamalar yapılır,
    kurucu Liderlik deneyim çarpanı da kalır (×2,25'e kadar); §4.2 cümlesi güncellenir. C) Kurucu tek kaynak kalır:
    §4.2 ve §7.1 buna göre güncellenir; GERÇEK LİDER ya bağlanır ya da metni (`HR_TRAIT_TAKES_THEM_UNDER_EFFECT`) ve
    Ekip §6 satırı değişir.
  - Kaynak: Ekip GDD §4.2, §6, §7.1.

- **4 · Balinanın güven şartı `security_cert`'i saymıyor.**
  - Ne oluyor: Şart yalnız `not InfraSystem.blocks_enterprise_signature()` okuyor: Yerel dışındaki her sağlayıcı şartı
    karşılıyor, `security_cert` araştırması sayılmıyor. GDD'ye göre sapma iki yönlü: Satış §8 şartı "sağlayıcı ya da
    security_cert" diye koyar; Ürün §10 güven koşulunu yalnız Kurumsal Bulut'a verir (düz Bulut "nötr"); Ar-Ge §4.2
    sertifikayı Kurumsal Bulut'a ikinci yol sayar. GDD'ye uyan yüklem zaten var ama üretimde okuyucusu yok (yalnız
    smoke): `InfraSystem.meets_enterprise_trust()`.
  - Nerede: `scripts/systems/sales_faucet_system.gd` (`_condition_met`, `WHALE_COND_PROVIDER`);
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
  - Kaynak: Satış GDD §8, §9; Ürün GDD (ch03) §10; Ar-Ge GDD §4.2 (rev 1.7).

- **5 · Olay seçicisi tek özne döndürüyor; o özne frenli ya da mandallıysa sıradakine düşülmüyor.**
  - Ne oluyor: Seçici uygun öznelerden yalnız birini döndürür; o özne frende ya da mandalda takılırsa aynı çekilişte
    başka özne denenmez. İki yerde görünüyor. (1) `tempo.gd` düzeltmesiyle olay freninin Katman 2'si (aynı özne;
    müşteri 30, çalışan 14 gün) ilk kez çalışıyor. Fren yalnız havuz çekilişinde sorulur ama tetiklenen ve istenen
    kartlar da pencereyi damgalar (`customer.retention`, `customer.request_*`). Destede müşteri öznesi taşıyan tek
    havuz kartı `customer.expansion`; `expansion_ready` seçicisi en yüksek MRR'lı uygun hesabı döndürür. (2) Günlük
    taramadaki varlık anahtarlı kartlar bağlamsız önerilir: `customer.cs_escalation` en düşük memnuniyetli tırmanan
    hesaba (`escalated`, hesap başına 21 günlük mandal), `funding.sheet_expiry` en az iş günü kalan teklife
    (`expiring_sheet`, fon başına one_shot) bağlanır; mandal doluysa kart G3'te düşer. `funding.sheet_decision` aynı
    düzenekle fonları bilerek sıraya koyuyor (kart notu), orada sorun yok. (2) kod okumasıyla doğrulandı, koşuda
    ölçülmedi.
  - Nerede: `scripts/events/gate/scope.gd` (`_select_customer` "expansion_ready" ve "escalated", `_select_investor`
    "expiring_sheet"); `scripts/events/present/tempo.gd` (`assign`, `_record`, `pool_blocked_reason`);
    `scripts/events/gate/gate.gd` (`propose`: varlık anahtarlı kartta G5, G3'ten önce);
    `scripts/events/core/engine.gd` (`_step_pool`, günlük tarama); kartlar
    `data/events/cards/customer/cs_escalation.json`, `data/events/cards/funding/sheet_expiry.json`.
  - Oyuncuya etkisi: En büyük uygun hesap elde tutma ya da talep kartı aldıktan sonra 30 gün boyunca hiçbir hesaba
    genişleme kağıdı gelmez (hesaplar 22 günde bir talep açtığı için daha uzun olabilir); Satış sekmesindeki
    "Değerlendir" düğmesi istek olarak geçtiği için çalışır. İki hesabın temsilcisi aynı dönemde alarm verirse
    ikincinin tırmanma kartı 21 gün ya da ilk hesap toparlanana dek gelmeyebilir. Son günü aynı olan iki term
    sheet'ten ikincisinin "son 3 gün" uyarısı hiç gelmez; karar kartı yine gelir.
  - Seçenekler: A) Seçici frenli ya da mandalı dolu özneyi atlayıp sıradakine düşer: deterministik kalır, `EvScope` ve
    `EvEngine` değişir; §4.3 ve §14.3'e birer cümle. B) Tarama kartı uygun her özne için ayrı önerilir; fazlası Katman
    4 ile kağıda düşer (§20 A6). (1)'i çözmez. C) Özneyi yalnız havuz kabulü damgalar: elde tutmadan birkaç gün sonra
    aynı hesaba genişleme gelebilir (§13.1'in "aynılık" sorunu); (2)'yi çözmez. D) Kalır; §13.3'e "tetiklenen ve
    istenen kartlar da pencereyi damgalar", kart notlarına ve §27'ye "özneler sırayla işlenir" yazılır.
  - Kaynak: Olay motoru GDD §4.3, §13.1, §13.3, §14.3, §20 A6, §27.4 (seçiciler), §27.5 madde 2.

- **6 · Risk'teki hesaba genişleme teklif edilebiliyor.**
  - Ne oluyor: `B2BSalesSystem.can_offer_expansion` pazara, duruma, `last_expansion_day` mandalına ve olgunluğa (45
    gün, `EXPANSION_MATURE_DAYS`) bakıyor, yaşam evresine (`lifecycle_phase`) bakmıyor. Aynı yüklemi
    `musteri.is_expansion_ready` seam'i (açıklaması "mature, healthy…" ama sağlık okunmuyor) ve `expansion_ready`
    seçicisi okuyor. Günlük tarama yalnız sağlıklı hesabı `expansion` evresine taşısa da havuz kartı
    `customer.expansion` Risk'teki hesabı seçebiliyor; masadaki kağıt da hesap Risk'e düşünce geçerli kalıyor.
  - Nerede: `scripts/systems/b2b_sales_system.gd` (`can_offer_expansion`, `expand`); seam
    `musteri.is_expansion_ready`.
  - Oyuncuya etkisi: "Churn'e ~N gün" sayan bir hesap için "Büyüme fırsatı" kağıdı gelebilir; kabul koltuk ve MRR
    ekler, hesap Risk'te kalır ve genişleme hakkı harcanır.
  - Seçenekler: A) `can_offer_expansion` Risk'i dışlar: tek satır; seam, seçici ve tarama birlikte düzelir. Bedel:
    Risk'e düşen hesabın masadaki kağıdı açılışta düşer ve `one_shot` mandalı kart kabul edilirken harcandığı için
    hesap bir daha teklif alamaz; bu yol da çözülmeli. B) Kalır; seam açıklaması düzeltilir.
  - Kaynak: Satış GDD §19 (genişleme kapısı "Korunanlar" arasında).

- **8 · EvTicker'ın tuttuğu oyuncu-sonucu satırlarını kimse okumuyor.**
  - Ne oluyor: `EvTicker.push`, `PRIORITY_PLAYER` satırlarını `_held` listesine ekliyor ve kayda yazıyor (`EvSave`,
    anahtar `held`). Ama projede `_held`'i okuyan ya da gösteren hiçbir yüzey yok. Motor GDD §18.3 "oyuncu-sonucu
    satırları asla düşürülmez" diyor; satırlar düşmüyor, ama hiçbir yerde görünmüyor da. Haber akışı tamponu dolunca
    aynı satır arşive girmiyor.
  - Nerede: `scripts/events/present/ticker.gd` (`_held`, `push`, `to_dict` / `from_dict`);
    `scripts/events/core/save.gd` (`held` alanı).
  - Oyuncuya etkisi: Tampon doluyken gelen bir oyuncu-sonucu satırı (`expire_note`, karar teyidi) canlı şeritte bir
    kez kayar, sonra geri bakılacak bir yerde kalmaz. Aynı sonuç History'de varsa (§18.1) kayıp yalnız ticker
    arşivindedir.
  - Seçenekler: A) `_held` bir yüzeye bağlanır (ör. haber akışı arşivinde öncelikli satır ya da History). B) `_held`
    emekliye ayrılır ve §18.3 "oyuncu-sonucu History'de durur" diye yazılır. C) Haber akışı tamponunda oyuncu-sonucu
    satırına öncelik verilir.
  - Kaynak: Olay motoru GDD §18.1, §18.3; motor GDD §18.2 koda göre yeniden yazılırken görüldü.

- **10 · VC iç sesi, sorulmuş soruya gelecek zamanla bakıyor (Beat 3 `_MONO` satırları).**
  - Ne oluyor: 3. vuruşta VC'nin sorusu (`active_line`) ile iç ses (`monologue_text`) aynı ekranda aynı anda çıkıyor.
    İç ses satırları ise gelecek zamanda yazılmış: "Churn'ü soracak.", "Tek-kurucu riskini soracak.", "Rakibi masaya
    koyacak.", "En zayıf ekseni bulacak.". Oyuncu soruyu okurken iç ses onun daha sorulacağını söylüyor.
  - Nerede: `scripts/systems/vc_pitch_system.gd` (`_beat3_view_state`: soru `active_line`, iç ses `monologue_text`);
    `scripts/modals/meeting_scene.gd` (`_apply_active_line` ikisini aynı anda çizer); anahtarlar `VC_Q_*_MONO` ve
    `SEED_Q_*_MONO`.
  - Oyuncuya etkisi: Sahnenin zamanı kayıyor: VC sormuş, iç ses "soracak" diyor. Satır bir önsezi gibi okunuyor ama
    önsezi için artık çok geç. Hazırlık ipucunun ("Sayıları hazırla") işe yarayacağı an zaten geçmiş.
  - Seçenekler: A) Metin: iç ses satırları şimdiki zamana ya da tepkiye çevrilir (ör. "Churn'ü soruyor. Sayılar hazır
    mı?"). TR ve EN sahip yazar, mekanik değişmez. B) Zamanlama: iç ses 2. vuruşta, soru gelmeden önce gösterilir.
    Bunun 1. vuruş istihbaratına bağlanıp bağlanmayacağı ayrıca seçilir. Bu, vuruş yapısını değiştirir. C) Olduğu gibi
    kalır. K31 (toplantı diyaloglarının yazım turu) kapsamına alınabilir.
  - Kaynak: ONERI_v3 §2 (şüphe 5); ACIK_KARARLAR K31 maddesi.

- **11 · Elde tutma kartı yalnız Risk'e girişte açılıyor (kalibrasyon).**
  - Ne oluyor: `customer.retention` artık yalnız hesap Risk'e girerken açılıyor (`customer_health_changed`); önceden
    Risk'teki her hesap her gün kart alıyordu (kartın kendi notu kararı girişe veriyor). Gitmiş hesabın sinyali
    (`_remove_lost`'un "churning" kenarı) kartı artık Risk'teki başka bir hesaba bağlamıyor: verilen id gitmişse kart
    G5'te gerekçesiyle reddediliyor (motor GDD §4.3). Kart, temsilcinin tırmandırdığı hesapta da açılmıyor (kodun
    kendi `can_offer_retention` kuralı). Bugünkü taban (full_run tohum 1, 760 gün, --lang=tr): retention kartı 180
    (Söz 30, Oyala 150, İndirim 0, 4. seçenek 0), `customer.cs_escalation` 35, CHURN 135, SÖZ 82; 730. gün MRR
    213.135, kasa 1,76M, müşteri 313, çalışan 13, marka 6; son running_on_fumes. Temizlik öncesi aynı koşu retention
    206, CHURN 66 ve 730. gün MRR 464.276 veriyordu. `cs_escalated` bir durumdur (atanmış ve memnuniyet < 35); 1★ ve
    sektör eki olmayan atanmış hesabın toleransı 33 olduğu için böyle bir hesap Risk'te hep tırmandırılmıştır ve elde
    tutma kartını hiç görmez, kararı `customer.cs_escalation` taşır. Hiçbir sabit değişmedi.
  - Nerede: `data/events/cards/customer/retention.json` (tetik, koşul, `cooldown_days`);
    `scripts/autoload/customer_registry.gd` (`set_lifecycle_phase`, `customer_churn_countdown_changed`);
    `scripts/systems/b2b_sales_system.gd` (`_tick_customer`, `_remove_lost`); churn geri sayımı ve seçenek etkileri
    `scripts/systems/b2b_constants.gd`; probe botunun tercih sırası `scripts/debug/run_probe.gd`
    (`RETAIN_PREFERENCE`).
  - Oyuncuya etkisi: Risk'e düşen hesap için karar bir kez sorulur; kaçırılırsa Satış sekmesindeki "İlgilen" kartı
    yeniden açar. Kurtarma şansı artık her gün yenilenmediği ve başka hesaplara taşmadığı için daha çok hesap
    kaybediliyor; geri sayım süresi ve Oyala/İndirim etkileri eski davranışa göre oturmuş olabilir. Tohumlu koşuda
    İndirim hiç seçilmiyor.
  - Seçenekler: A) Churn geri sayımı ve Oyala/İndirim etkileri bugünkü davranışla, tam probe setiyle yeniden kalibre
    edilir. B) Günlük yeniden soru tasarım sayılır, eski davranış geri gelir; kartın notu ve Satış §19 buna göre
    yazılır. C) Kalibrasyon sonraya.
  - Kaynak: Olay motoru GDD §4.3; Satış GDD §19 (retention kartı ve churn geri sayımı korunanlar arasında);
    `retention.json` `_port_note`; probe ölçümleri (ab863fa, f4b3460 ve §4.3 düzeltmesi; full_run:760:sim:1
    --lang=tr).

- **13 · Masadaki kağıdın öznesi giderse süre dolumu: ceza, not ve son uyarı birbirini tutmuyor.**
  - Ne oluyor: Kağıt, masaya düştüğünde öznelerini bağlıyor. Bir varlık kağıt masadayken giderse son gün uyarısı
    düşüyor (`EvGate.revalidate` bütün slotlara bakar), oyuncu açmak isterse kağıt kayboluyor. Ama süre dolunca
    `on_expire` çalışıyor, history `expired` yazıyor ve `expire_note` ticker'a gidiyor. İki durum var. (1) Ana özne
    (hesap) gitti: `on_expire`'ın etkileri hedef bulamıyor ("satisfaction_delta found no target" hatası,
    full_run:760:sim:1'de 3 kez). Not satırı da hesabın adı yerine iç id'sini yazıyor (ör. "co_lead_… bir daha
    aramadı."). (2) İkincil slot (talep kartının temsilcisi) gitti: ceza hesaba işliyor ve not çıkıyor. Aynı koşuda 8
    kağıt bu durumda (günler 327, 341, 563, 682). §12.4 "expire_note zorunludur, sessiz süre dolumu yoktur" diyor.
    §4.4 ve §20 A1 ise gösterimdeki yeniden doğrulamayı anlatıyor, açılmamış kağıdın süre dolumunu değil.
  - Nerede: `scripts/events/core/engine.gd` (`_step_paper_expiry`, `_step_last_warnings`, `open_paper`);
    `scripts/events/gate/gate.gd` (`revalidate`); `scripts/events/gate/scope.gd` (`still_valid`);
    `scripts/events/present/presenter.gd` (`_display_name`); `data/events/cards/customer/request_*.json` ve
    `retention.json` (`scope`, `on_expire`, `expire_note`).
  - Oyuncuya etkisi: (1) Haber akışında bir iç kod (hesap id'si) görünüyor; ceza kimseye işlemiyor. (2) Temsilci
    ayrılınca oyuncu son uyarıyı görmüyor ve kağıdı açamıyor, ama cezayı yiyor. Bu uyarısız bir kayıp.
  - Seçenekler: A) Hangi slottaki varlık giderse gitsin kağıt süre dolumunda düşer: history `dropped` (`entity_gone`),
    `on_expire` ve not çalışmaz. §12.4'e bu istisna yazılır. Tohumlu koşuda 8 kağıdın cezası kalkar. B) Yalnız ana
    özne gidince düşer; ikincil slotta uyarı ve açılış da yalnız ana özneye bakar, temsilci gitse de kağıt açılır ve
    ceza işler. Ana özne kuralı tohumlu koşuyu değiştirmiyor (369dc57'de ölçüldü). C) Süre dolumu hep çalışır: bağlam
    bağlanırken görünen adı da dondurur, not gitmiş varlığı adıyla anar, hedefsiz ceza sessizce atlanır. D) Temsilci
    slotu açılışta yeniden seçilir (reassign benzeri, yeni mekanik).
  - Kaynak: Olay motoru GDD §4.4, §12.4, §20 A1, §20 B11; probe ölçümü (369dc57, full_run:760:sim:1).

- **14 · Etki sözlüğünde karşılığı olmayan fiiller (uygulanmayan, hep reddedilen, çipsiz).**
  - Ne oluyor: Tablolarda duran dokuz fiilin `_apply`'da kolu yok: `assign_to`, `send_on_leave`, `start_training`,
    `damage_product`, `add_customer`, `convert_audience`, `open_paid_tier`, `change_salary`, `fire_employee`. Lint
    onları kabul ediyor, oyunda "not implemented" diye reddediliyorlar. `add_mrr` motor GDD §8.1 ve §8.3'te gerçek bir
    fiil; kod onu hep reddediyor (MRR defterden türetiliyor, `engine_probe` bu reddi doğruluyor) ve bu ayrılık §27'de
    yazılı değil. `notify` metni anahtar ya da çeviri olmadan ham basıyor. Çip tarafında 13 fiil ne
    `_describe_modifier`'da etiketli ne `SILENT_VERBS`'te: `clear_flag`, `set_timed_flag`, `ticker_push`, `notify`,
    `open_negotiation`, `add_mrr`, `assign_to`, `send_on_leave`, `start_training`, `damage_product`, `change_salary`,
    `fire_employee`, `add_customer`. Tersine `convert_audience` ile `open_paid_tier`'in çipi var ama fiilleri
    uygulanmıyor. Bugün hiçbir kart bu fiilleri kullanmıyor.
  - Nerede: `scripts/events/core/effects.gd` (`NEUTRAL_VERBS`, `ECONOMIC_VERBS`, `_apply`: "add_mrr", "notify");
    `scripts/modals/event_modal.gd` (`SILENT_VERBS`, `FIXED_CHIPS`, `_describe_modifier`);
    `scripts/events/tools/lint.gd` (`_lint_effects`); `scripts/events/tools/engine_probe.gd` (`_check_effects`).
  - Oyuncuya etkisi: Bugün yok. Bir yazar bu fiillerden birini kullanırsa lint geçer ve kart oyunda görünür, ama
    seçenek söylediğini yapmaz: sessizce reddedilir, bazen çipi de gösterilir. `notify` ile yazılan satır tek dilde
    kalır.
  - Seçenekler: A) GDD'nin adını verdiği fiiller (`fire_employee`, `add_customer`, `damage_product`, `assign_to`)
    sahibi modülün seam'iyle bağlanır, geri kalanı tablolardan çıkar. Bağlanan her fiil bir çip ya da `SILENT_VERBS`
    kaydıyla gelir. B) Bağlanmayan her fiil tablolardan çıkar ve lint onu bilinmeyen fiil diye reddeder. `add_mrr` GDD
    §8.1'den düşer, §27'ye "MRR türetilir, yazılmaz" notu girer. `notify` ya `line_key` alır ya da kalkar. C) Olduğu
    gibi kalır: liste §27'ye yazılır, lint uygulanmayan fiile uyarı verir.
  - Kaynak: Olay motoru GDD §8.1, §8.3, §11.1 (info sınıfı), §27; CLAUDE.md §5 EFFECT-VISIBILITY RULE.

- **15 · Bütçe bitince seçenek kilitlenmiyor (`spend_budget`, §8.5).**
  - Ne oluyor: GDD §8.5, bütçe bitince o etkiyi taşıyan seçeneğin kilitlenip gerekçesini göstermesini istiyor. §20 E8
    bu kontrolü `requires`'a koyuyor. Ama `EvBudgets.remaining()`'i okuyan ne bir seam ne bir koşul yaprağı var;
    §5.2'nin listesinde de bütçe yaprağı yok. Bütçe biterse `EvBudgets.spend` yalnız hata basıyor, seçenek açık
    kalıyor. Hiçbir kart `spend_budget` kullanmıyor.
  - Nerede: `scripts/events/core/budgets.gd` (`remaining`, `spend`); `scripts/events/core/effects.gd`
    ("spend_budget"); `scripts/events/core/condition.gd` (yaprak listesi); `scripts/events/seams/`.
  - Oyuncuya etkisi: Bugün yok, çünkü `frank_aphorism` bütçesini harcayan kart yok. İlk kart bağlandığında üçüncü
    aforizma seçeneği kilitlenmez: oyuncu tıklar ve hiçbir şey olmaz.
  - Seçenekler: A) Her bütçeye bir seam (ör. `frank.aphorisms_left`): yazar seçeneği `requires` ile kilitler, gerekçe
    metnini kart taşır (E8'in dediği). B) §5.2'ye yeni koşul yaprağı `{"budget": ad}`. C) Motor `spend_budget` taşıyan
    seçeneği kendiliğinden kilitler, gerekçe ortak bir anahtardan gelir (§8.5'in lafzı).
  - Kaynak: Olay motoru GDD §8.5, §5.2, §20 E8.

- **16 · Ark belleği (`arc.vars`) yazılıyor ama okunamıyor.**
  - Ne oluyor: `set_arc_var` fiili ve `EvArcs.set_var` arkın `vars` alanına yazıyor, alan kayda da giriyor. Ama onu
    okuyan ne bir koşul yaprağı ne kod var: §5.2'nin ark yaprakları yalnız `active`, `at_step`, `ended` ve
    `awaiting_subject`. Hiçbir kart bu fiili kullanmıyor. §20 G4 ise arka özgü durumun `arc.vars`'ta tutulduğunu
    söylüyor.
  - Nerede: `scripts/events/core/arcs.gd` (`set_var`); `scripts/events/core/effects.gd` ("set_arc_var");
    `scripts/events/core/condition.gd` (ark yaprakları); `scripts/modals/event_modal.gd` (`SILENT_VERBS`).
  - Oyuncuya etkisi: Bugün yok. Bir yazar ark belleğine yazabilir ama arkın sonraki adımı o değeri okuyamaz.
  - Seçenekler: A) Yeni yaprak `{"arc": "var", "id", "key", "op", "value"}`, §5.2'ye bir satır. B) `set_arc_var`
    emekliye ayrılır; ark belleği bayraklarla tutulur (G4'ün uyardığı çakışma riskiyle). C) Kalır; §27'ye "vars
    okunmuyor" notu girer.
  - Kaynak: Olay motoru GDD §5.2, §10.1, §16.1, §20 G4.

- **17 · Özne başına ark limiti: ikinci ark ertelenmiyor, hiç başlamıyor (§10.7).**
  - Ne oluyor: §10.7 ve §20 A4'e göre bir özne ikinci bir ark alırsa o ark `deferred` olur ve birincisi bitince
    yeniden proposal'a girer. `EvArcs.start` ise ikinci arkı reddediyor ve bir yere kaydetmiyor (limit
    `EvTuning.ARC_PER_SUBJECT_DEFAULT`'tan okunuyor). Ark, bir seçeneğin `start_arc` etkisiyle başlıyor. O kartın
    mandalı harcandığı için kart yeniden önerilmiyor, yani ark hiç başlamıyor. Bugün fikstürler dışında özneli ark yok
    (`arc_final_stretch` öznesiz).
  - Nerede: `scripts/events/core/arcs.gd` (`start`); `scripts/events/core/effects.gd` ("start_arc");
    `scripts/events/core/tuning.gd` (`ARC_PER_SUBJECT_DEFAULT`).
  - Oyuncuya etkisi: Bugün yok. Aynı özneye iki ark bağlandığında ikinci arkı açan seçenek sessizce hiçbir şey
    başlatmaz.
  - Seçenekler: A) Ertelenen başlatma motorda tutulur (`{arc_id, subject}`); birinci ark bitince ikincisi başlar.
    Kayda yeni bir alan girer. B) Seçim anında engel: özne doluysa arkı başlatacak seçenek gerekçesiyle kilitlenir. C)
    Ret kalır; §10.7 ve A4 "ikinci ark başlamaz" diye yeniden yazılır.
  - Kaynak: Olay motoru GDD §10.7, §10.9, §20 A4, §27.

- **18 · Okunmayan beş `EFFECT_*` anahtarı: DRAFT-EN kaydı ile CSV süpürmesi çelişiyor.**
  - Ne oluyor: `EFFECT_MRR`, `EFFECT_QUALITY_BONUS`, `EFFECT_NEW_TEAMMATE`, `EFFECT_PROMISE_HONOR` ve
    `EFFECT_PROMISE_REFUSE` CSV'de duruyor. Ama `event_modal.gd` (`FIXED_CHIPS`, `_describe_modifier`) hiçbirini
    okumuyor, üretim kodunda da okuyanı yok. DRAFT-EN kaydı `EFFECT_*` ailesini "üretim kodunun okudukları" arasında
    sayıyor ve "referanssız emekli anahtarları CSV süpürmesi siler" diyor. ISLER'deki CSV süpürmesi ise
    ACIK_KARARLAR'da geçen anahtarları bırakıyor. Bu beş anahtar için iki kural çelişiyor.
  - Nerede: `localization/strings.csv`; `scripts/modals/event_modal.gd` (`FIXED_CHIPS`, `_describe_modifier`);
    `docs/ACIK_ISLER/ACIK_KARARLAR.md` (DRAFT-EN kaydı); `docs/ACIK_ISLER/ISLER.md` (CSV süpürmesi).
  - Oyuncuya etkisi: Yok. Anahtarlar okunmayan metin.
  - Seçenekler: A) Süpürmeye girer, silinir. B) Kalır; DRAFT-EN kaydında "okunmayan, ileride çip olacak" diye ayrı
    satır alır. C) Yeniden bağlanır, ör. `EFFECT_PROMISE_HONOR` / `_REFUSE` vaat kartlarının çipi olur (içerik
    kararı).
  - Kaynak: CLAUDE.md §8 (ölü CSV anahtarı); ACIK_KARARLAR DRAFT-EN kaydı; ISLER CSV süpürmesi.

- **19 · `arc_final_stretch` sönünce ticker'a ham "arc_faded" yazılıyor.**
  - Ne oluyor: `arc_final_stretch` fade politikasında `note_key: "arc_faded"` taşıyor. Bu ne bir CSV anahtarı ne bir
    kart metni; ark tanımının metin bloğu da yok. Ark Series A imzasında ya da bootstrap kilometre taşında
    (`phase.bootstrap_milestone`) söner ve haber akışına ham "arc_faded" satırı düşer.
  - Nerede: `data/events/arcs/soft_cap_stretch.json` (`on_invalidate.note_key`); `scripts/events/core/engine.gd`
    (`_invalidate`, fade kolu); `scripts/events/present/ticker.gd` (`push`).
  - Oyuncuya etkisi: Ark canlıyken kârlı bootstrap kilometre taşı alınırsa (EA/tam) ticker'da ham bir kod satırı
    görünür. Series A imzasında koşu bittiği için pratikte görünmeyebilir.
  - Seçenekler: A) Yeni bir oyuncu satırı yazılır, önce EN sonra TR (ör. "The year-end file closed."); `note_key` o
    anahtarı taşır. B) `note_key` kaldırılır; bu ark için §10.5'in "ticker izi" düşer ve §27'ye not girer. C) Ark
    close politikasına geçer ve görünür bir kartla kapanır.
  - Kaynak: Olay motoru GDD §10.5, §18.3; CLAUDE.md §5.

- **23 · Aylık ürün notu Ar-Ge sekmesinde okunamıyor; rozet sönmüyor.**
  - Ne oluyor: Koşunun ilk notu bir kez modal açılıyor. Sonraki notların, ya da ilk modal Esc ile kapatıldıysa o
    notun, okunacağı bir yüzey yok. `RnDSystem._note_unread` true kalıyor, `mark_note_read`'i çağıran bir sekme yüzeyi
    yok, Ar-Ge ray rozeti (`attention_count`) koşu boyunca yanık kalıyor. `RND_NOTE_FIRST_HINT` oyuncuya "bundan sonra
    bu not her ay Ar-Ge sayfasında" diyor, ama sayfada not yok. `RND_NOTE_UNREAD` ve `RND_NOTE_OPEN` bu yüzeyin park
    edilmiş etiketleri.
  - Nerede: `scripts/systems/rnd_system.gd` (`note_pending`, `pending_note`, `mark_note_read`,
    `take_first_note_modal`, `attention_count`); `scripts/tabs/rnd_tab.gd` (sayfada not yüzeyi yok);
    `scripts/modals/rnd_card_modal.gd` (`_build_note`, `_read_and_close`); `scripts/main/main.gd`
    (`product_note_issued` → ilk not modalı); `localization/strings.csv` (`RND_NOTE_UNREAD`, `RND_NOTE_OPEN`,
    `RND_NOTE_FIRST_HINT`).
  - Oyuncuya etkisi: İkinci aydan itibaren raporlar görünmez oluyor. Rozet sürekli 1 (donmuş araştırma varsa 2)
    gösteriyor ve gerçek bir donmayı haber verme işlevini yitiriyor. İlk modaldaki ipucu karşılığı olmayan bir söz
    veriyor.
  - Seçenekler: A) Ar-Ge sayfasına bir not şeridi eklenir: "OKUNMADI · Aç" → `RnDCardModal` note (ipucu satırı
    olmadan) → `mark_note_read`. GDD §6.1'in tarif ettiği yol budur, yeni UI işidir. B) Ara çözüm: Ar-Ge sekmesi
    açılınca not okunmuş sayılır ve rozet söner; not yine okunamaz. C) Her rapor modal açar; bu §6.1 MÜHÜRLÜ kuralına
    aykırı olduğu için GDD değişikliği ister.
  - Kaynak: Ar-Ge GDD §6.1 (MÜHÜRLÜ teslim biçimi), §5.6.2 (rozet sayımı), §10 (`arge.note_pending`).

- **25 · Atama panelinde izindeki ya da eğitimdeki kişi seçilebiliyor ama koltuğa oturmuyor.**
  - Ne oluyor: `RnDAssignPanel._person_row` meşgul (izinde, eğitimde, kurucu pitch hazırlığında) kişiyi soluk ama
    seçilebilir bırakıyor; gerekçesi "oyuncu onu yine de seçebilmeli". `CharacterRegistry.assign_job` `STATUS !=
    ACTIVE` olan kişiyi `inactive` diye reddediyor ve `RnDSystem.set_assignees` onu yalnız `push_warning` ile
    düşürüyor. Seçim kabul edilmiş görünüyor ama kişi atanmıyor. Seçilenlerin hepsi meşgulse Başlat `REFUSE_ZERO` ile
    kapanıyor ve `RND_ASSIGN_ZERO` "Seçtiklerinin hiçbiri bu alanda çalışmıyor." diyor; bu cümle gerçek sebebi (izin
    ya da eğitim) söylemiyor.
  - Nerede: `scripts/tabs/rnd/rnd_assign_panel.gd` (`_person_row`, `_on_commit`); `scripts/systems/rnd_system.gd`
    (`set_assignees`, `start_refusal` `REFUSE_ZERO`, `research_per_day`); `scripts/autoload/character_registry.gd`
    (`assign_job` `inactive`); `localization/strings.csv` (`RND_ASSIGN_ZERO`).
  - Oyuncuya etkisi: Oyuncu izindeki birini araştırmaya koyduğunu sanıyor; o kişi döndüğünde araştırmada olmuyor. Ret
    cümlesi yanlış sebep gösteriyor.
  - Seçenekler: A) Meşgul satırlar seçilemez olur (görünür kalır, gerekçesi "İzinde · 12g sonra katılır" satırı). B)
    HR, izindeki ya da eğitimdeki kişiyi araştırmaya oturtur (§7'deki "atama silinmez, dönünce devam" mantığının yeni
    atamaya uzatılması; Ekip sahibinin dosyası). C) Seçim kalır, Uygula ya da Başlat oturtulamayan kişiyi adıyla bir
    satırda bildirir ve `REFUSE_ZERO` metni izin ya da eğitimi söyler.
  - Kaynak: Ar-Ge GDD §5.3 (panel havuzu), §5.5 (sıfır katkı koruması), §7 ("Araştırmadaki kişi izne çıkar" satırı;
    yeni atama için sessiz); Ekip GDD §12.3.

- **26 · Kilitli yuvada çapraz koşul satırı yok.**
  - Ne oluyor: Sürpriz duvar yasağı çapraz koşullu devam düğümünün kilitli yuvasında "Başka bir ailede bir araştırma
    ister." yazılmasını istiyor; `RND_NEED_CROSS_BLIND` CSV'de var ama hiçbir kod onu okumuyor. Karo küçük
    (`MicroLabel`, ortalı), bu yüzden bu satırın karoda mı, üzerine gelince mi, yoksa derin bağla seçilince detay
    kartında mı görüneceği bir yerleşim kararı.
  - Nerede: `scripts/tabs/rnd/rnd_tree_view.gd` (`_make_tile`, `TILE_LOCKED` dalı);
    `scripts/tabs/rnd/rnd_detail_panel.gd` (`_add_blockers`, kilitli düğüm); `localization/strings.csv`
    (`RND_NEED_CROSS_BLIND`).
  - Oyuncuya etkisi: Çapraz koşul ancak ad açıldıktan sonra görünüyor, yani §3'ün yasakladığı sürpriz duvar oluşuyor.
  - Seçenekler: A) Çapraz koşullu kilitli karoya ikinci `MicroLabel` satırı `RND_NEED_CROSS_BLIND` eklenir. B) Satır
    yalnız karonun üzerine gelince ipucu olarak çıkar. C) Satır derin bağla seçilen kilitli düğümün detay kartında
    (`_add_blockers`) yazılır. Her seçenekte TR/EN onay bekler.
  - Kaynak: Ar-Ge GDD §3 (MÜHÜRLÜ: sürpriz duvar yasağı), §8 ("çapraz koşulu eksik" durumu).

- **27 · Üç düğümün adlandırılmış maliyet etiketi yazılmamış.**
  - Ne oluyor: `rnd_tree.json`'da `ai_engine`, `security_cert` ve `analytics_engine` `"cost_label": true` taşıyor.
    Kart `PROD_RND_NODE_<ID>_COST` anahtarını arıyor (`RnDUiShared.t_or`), hiçbiri CSV'de yok, bu yüzden kart GDD'nin
    "GPU kirası $600" örneği yerine çıplak "$600" gösteriyor. GDD yalnız `ai_engine` için etiket veriyor ("GPU
    kirası"); `security_cert` ($900) ve `analytics_engine` ($400) için etiket yok.
  - Nerede: `data/techtree/rnd_tree.json` (`cost_label`); `scripts/tabs/rnd/rnd_detail_panel.gd` (`_add_state_body`,
    `has_cost_label` ve `t_or`); `scripts/systems/research_tree.gd` (`has_cost_label`); `localization/strings.csv`
    (`PROD_RND_NODE_*_COST` yok).
  - Oyuncuya etkisi: Nakit maliyetli üç düğümde oyuncu paranın neye gittiğini görmüyor. Kart GDD §8 örneğinden eksik
    kalıyor.
  - Seçenekler: A) Üç etiket yazılır (EN önce, TR ayrı adım): `ai_engine` "GPU kirası {money}", `security_cert` ve
    `analytics_engine` için yeni metin. B) Yalnız `ai_engine` etiketi yazılır, öteki ikisinden `cost_label`
    kaldırılır. C) Etiket kuralı emekliye ayrılır: `cost_label` ve `t_or` kolu silinir, tutar çıplak kalır (GDD §8
    örneği güncellenir).
  - Kaynak: Ar-Ge GDD §8 (kart örneği "GPU kirası $600"), §13 (nakit maliyetler [K]: ai_engine $600, analytics_engine
    $400, security_cert $900), §12.1.

- **28 · Kurucu huylarının etkisi yok ama etki metni gösteriliyor.**
  - Ne oluyor: Onboarding 2. sayfası her kurucu huyunun altında bir etki satırı basıyor (`TRAIT_*_EFFECT`, ör. "Ar-Ge
    sıçramaları daha sık", "Pivot maliyeti yüksek"). Seçilen huy id'leri kurucunun `Character.traits`'ine yazılıyor,
    ama kurucu huylarını hiçbir sistem okumuyor; `FounderConstants.TRAITS` yorumu bunları RESERVED diye işaretliyor.
  - Nerede: `scripts/systems/founder_constants.gd` (`TRAITS`, `effect_key`);
    `scripts/onboarding/steps/origin_traits_step.gd` (huy kartındaki `effect_lbl`); `scripts/autoload/game_state.gd`
    (`initialize_run`, kurucunun `traits`'i); `localization/strings.csv` (`TRAIT_*_EFFECT`).
  - Oyuncuya etkisi: Oyuncu koşunun başında bir etki vaat eden huy seçiyor, ama seçim oyunda hiçbir şeyi
    değiştirmiyor. "Pivot maliyeti yüksek" gibi olumsuz huylar bedava.
  - Seçenekler: A) Etkiler bağlanır: her huy için sahibin onaylayacağı bir çarpan (ch02 §8: beceri, hız, olasılık,
    moral) ve onu okuyan sistem; sayılar [WORKING]. B) Etkiler bağlanana kadar kartta yalnız huy adı kalır, etki
    satırı gizlenir. C) Etki satırı kalır, yanına "yakında" benzeri bir işaret eklenir (yeni metin, TR/EN onayı
    gerekir).
  - Kaynak: GDD ch02 §1 (kurucu huyları katalogdan, ikonla), ch02 §8 (huylar yalnız modifier); CLAUDE.md §5 (her
    seçenek görünür bir sonuca düşer).

- **29 · Mirasyedi kökeninin kilit notu: TAM SÜRÜMDE mi, ÇOK YAKINDA mı.**
  - Ne oluyor: Kilitli iki kökenden `heir` (Mirasyedi) "TAM SÜRÜMDE" (`LOCK_FULL`), `corporate_refugee` (Kurumsal
    Firari) "ÇOK YAKINDA" (`LOCK_SOON`) notunu taşıyor. ch14 §4 "kalan kökenleri" Early Access'e, §5 "ek kökenleri"
    tam sürüme koyuyor; §3 demodaki kilitli-görünür kökenleri Heir ve Corporate Refugee diye sayıyor. 58e603e'deki
    görsel kontrolde heir'in TR "TAM SÜRÜMDE" rozeti bilerek korunmuştu.
  - Nerede: `scripts/systems/founder_constants.gd` (`ORIGINS`, heir satırının `locked_note_key`'i);
    `scripts/onboarding/steps/origin_traits_step.gd` (kilitli köken kartı rozeti).
  - Oyuncuya etkisi: Onboarding 2. sayfadaki iki kilitli köken farklı çıkış zamanı vaat ediyor. ch14 §4 okunursa
    Mirasyedi'nin vaadi yanlış.
  - Seçenekler: A) heir `LOCK_SOON`'a geçer (ch14 §4: kalan kökenler EA'da). B) `LOCK_FULL` kalır, ch14 §4 ve §5
    Mirasyedi'yi tam sürüme koyacak biçimde netleştirilir. C) İki köken de tek bir nötr kilit notu taşır (ör.
    `LOCK_CHIP`).
  - Kaynak: GDD ch14 §3, §4, §5; ch01 §8; ch02 §1.

- **31 · Pazarlıkta sabır ve karşı teklif adımı mizaçtan gelmiyor.**
  - Ne oluyor: `NegotiationSystem.open` sabrı arketipin pazarlık profilinden okuyor (`SalesArchetypes.negotiation` →
    `patience`: ops_cautious 3, tech_exacting 2, finance_brisk 2). `offer` karşı teklif adımını kalan sabırdan
    türetiyor: `COUNTER_STEP_MIN..MAX` arasında, sabır doluyken en büyük. `SalesArchetypes.temperament` yalnız
    `SalesProbes.facts_for`'daki olguya gidiyor.
  - Nerede: `scripts/systems/negotiation_system.gd` (`open`, `offer`); `scripts/systems/sales_archetypes.gd` (`TABLE`:
    `temperament` ve `negotiation` alanları, `temperament()`); `scripts/systems/sales_constants.gd`
    (`PATIENCE_MIN/MAX`, `COUNTER_STEP_MIN/MAX`).
  - Oyuncuya etkisi: Sabır kutuları ve karşı tekliflerin ne kadar hızlı indiği mizaca değil arketip satırına ve tura
    bağlı. Mizaç tek başına masada hiçbir şeyi değiştirmiyor. Bağlanırsa anlaşma fiyatları değişir.
  - Seçenekler: A) Mizaç tablosu kurulur: her mizaç bir sabır kutusu sayısı ve bir adım katsayısı taşır, arketip
    profili bunları mizacından alır. B) Kod kalır; Satış §5.3 "sabır arketip profilinden, adım kalan sabırdan" diye
    güncellenir, mizaç yalnız olgu olarak kalır. C) Sabır arketipten kalır, adım mizaç katsayısıyla ölçeklenir.
  - Kaynak: Satış GDD §5.3 ("Sabır: mizaca göre 2–4 kutu [K]"; şekil formülleri: "karşı-teklif adımı mizaçtan"), §11.1
    (arketip alanları).

- **32 · Balina rolü musluktan da doğuyor; eşik de "bandın bir üstü" değil "bandın üstü".**
  - Ne oluyor: `SalesFaucetSystem.spawn` musluk lead'lerini de `_seat_whale_condition`'dan geçiriyor. Yıldızı
    `reach_band()`'ın üstünde olan ve arketipinin şart listesi bulunan her lead balina oluyor. Satış §3 balina rolünün
    karışımdan değil kahraman hesap ya da olay kanalından geldiğini söyler; §10'un 8–15 kahraman hesabı yazılmadı.
    Eşik de GDD'den ayrı: kod bandın her üstünü balina sayıyor (`p.star <= reach_band()` ise çıkar), §8 "erişim
    bandının bir üstünde" diyor; erişim 1 iken 3★ lead de balina.
  - Nerede: `scripts/systems/sales_faucet_system.gd` (`spawn`, `_seat_whale_condition`, `reach_band`; olay kanalı
    `spawn_prospect`); `scripts/systems/sales_ledger.gd` (`announce_signing`).
  - Oyuncuya etkisi: Erişim bandının üstündeki her musluk lead'i balina geliyor: şart rozeti, sert pazarlık (rezerv
    ×0,9, sabır −1), ticker haberi ve +3 marka (`SalesLedger.announce_signing`). Rol nadir değil; erişimi düşük koşuda
    sık görülüyor. "Bir üstü" okumasında erişim 1'de yalnız 2★ balina olur; 3★ sıradan lig üstü lead kalır ve yine lig
    üstü haber sayılır (§7.3).
  - Seçenekler: A) Balina yalnız `source != "faucet"` olan lead'lerde (olay kanalı, kahraman hesap); kahraman hesaplar
    yazılana kadar balina neredeyse hiç gelmez. B) Musluk balinası kahraman hesaplar gelene kadar geçici olarak kalır;
    §3'e not düşülür. C) Musluk balinası nadir kılınır (aynı anda en çok bir canlı balina ya da [K] bir oran). A
    dışındaki her seçenekte eşik ayrıca seçilir: (i) `star == reach_band() + 1` (§8'in harfi); (ii) kod kalır, §8
    "bandın üstünde" diye güncellenir.
  - Kaynak: Satış GDD §3 (yıldız karışımı), §7.3, §8, §10.

- **35 · Satış kartındaki sorumlu satırı kurucu masasını ve sahipsiz hesabı aynı ham "—" ile gösteriyor.**
  - Ne oluyor: `_add_steward_line` sorumlu adı bulamazsa CSV anahtarı olmayan sabit "—" yazıyor ("Müşteri temsilcisi:
    —"). Bu tek işaret iki ayrı durumu kapsıyor. (1) `assigned_to == ""`: hesap kurucunun masasında; `assign_customer`
    sözleşmesi ve `B2BSalesSystem._account_owner` kurucuyu sahip sayar, bakım yavaşlatması işler. (2) Temsilcisi
    ayrılmış hesap: `CharacterRegistry.remove` karakteri siler, `assigned_to` eski id'de kalır; `_account_owner` null
    döner ve hesap bakımsız aşınır; `founder_managed_count` ile `_delegate_excess` onu saymaz. Literal CLAUDE.md §5'i
    çiğniyor (anahtar yok, tire var).
  - Nerede: `scripts/tabs/sales_tab.gd` (`_add_steward_line`); `scripts/autoload/customer_registry.gd`
    (`assign_customer`); `scripts/systems/b2b_sales_system.gd` (`_account_owner`, `founder_managed_count`);
    `scripts/systems/customer_rep_system.gd` (`_delegate_excess`); `scripts/autoload/character_registry.gd`
    (`remove`).
  - Oyuncuya etkisi: Oyuncu kendi masasındaki hesabı, temsilcisi gidip bakımsız kalan hesaptan ayıramıyor. Ekip §11.3
    boşalan işin "boş göründüğü için okunur" olmasını istiyor. Ekranda tire var.
  - Seçenekler: A) İki anahtar: kurucu durumu için mevcut `HR_ROLE_FOUNDER` ("Kurucu"/"Founder") ya da yeni bir Satış
    anahtarı, sahipsiz durum için yeni `SALES_STEWARD_NONE` (EN önce, TR yerelleştirme adımı, onay bekler). B) İki
    durum için tek yeni anahtar ("atanmamış"); kurucu masası ayrıca belirtilmez. C) Ayrılışta hesaplar kurucuya döner
    (`assigned_to = ""`) ve yalnız kurucu etiketi gerekir; Ekip §11.3'ün "otomatik kurucuya devir varsayılan değildir"
    hükmüyle çelişir.
  - Kaynak: CLAUDE.md §5 (BILINGUAL BIRTH LAW, tire yasağı); Ekip GDD §11.3; ch01 §9.

- **38 · Müşteri masası Destek işindeki temsilciyi de sayıyor.**
  - Ne oluyor: Masa (`CustomerRepSystem.ranked_reps`) ve iki girişi (`reconcile_assignments`, `daily_tick`) unvanı
    değil alan atamasını okuyor: `HRSystem.assigned_to(AREA_CUSTOMER_SUCCESS)`, işlerden türeyen alan aynası. Destek
    işi de Müşteri İlişkileri alanını taşıdığı için (`HRConstants.JOB_AREAS["support"]`) Destek'teki bir Müşteri
    Temsilcisi masaya sayılıyor. Yeni işe alınan Müşteri Temsilcisi de
    `HRConstants.AREA_PRIMARY_JOB["customer_success"]` gereği Destek'e oturuyor ve masayı bu yoldan açıyor. Ekip
    §12.0'ın tablosu ise "müşteri olayları"nı Hesap sahipliğine, "bilet çözümü"nü Destek'e yazıyor.
  - Nerede: `scripts/systems/customer_rep_system.gd` (`ranked_reps`); `scripts/systems/hr_system.gd` (`assigned_to`,
    `assigned_to_job`); `scripts/systems/hr_constants.gd` (`JOB_AREAS`, `AREA_PRIMARY_JOB`);
    `scripts/tabs/sales_tab.gd` (`_open_steward_picker`).
  - Oyuncuya etkisi: Temsilcisini yalnız Destek'te tutan oyuncunun talep kanalı ve hesap sahipliği açık kalıyor; aynı
    kişi hem destek biletlerine hem hesaplara çıktı veriyor.
  - Seçenekler: A) Kalır; §12.0'ın "o işi taşıyan alanlara atanmış kimse var mı" cümlesi alan aynasıyla okunur. B)
    Masa, girişler ve seçici `HRSystem.assigned_to_job(JOB_ACCOUNTS)` üzerine kurulur. Yeni işe alınan temsilci
    Destek'e oturduğu için masa ancak oyuncu onu Hesap sahipliğine koyunca açılır;
    `AREA_PRIMARY_JOB["customer_success"]`'ın Hesap sahipliği olması ayrı bir alt karardır. Tohumlu koşu değişir;
    `_make_cs_rep` kullanan smoke vakaları yeniden yazılır.
  - Kaynak: Ekip GDD §12.0, §4.4, §10.4.

- **39 · Satış sekmesinin Risk sebebi ile elde tutma kartındaki müşteri sesi farklı kurala bakıyor.**
  - Ne oluyor: `sales_tab._card_risk`, `ProductSystem.live_bug_count() > B2BConstants.COMPLAINT_BUG_GATE` ise "sık
    kesinti şikayeti" (`SALES_REASON_OUTAGE`), değilse "memnuniyet düşüyor" (`SALES_REASON_SATISFACTION`) yazıyor.
    Aynı hesabın elde tutma kartındaki sesi `B2BSalesSystem.risk_voice` seçiyor: önce kırılmış söz (`b2b_broke_<id>` →
    `B2B_RISK_VOICE_BROKEN`), sonra `ProductState.bugs_confirmed() > COMPLAINT_BUG_GATE` ya da
    `InfraSystem.is_over_capacity()` (sektör şikâyeti), en son kısa ses. İki yol farklı hata sayacı okuyor; kapasite
    aşımı ve kırılmış söz sekmede sebep olarak hiç görünmüyor.
  - Nerede: `scripts/tabs/sales_tab.gd` (`_card_risk`); `scripts/systems/b2b_sales_system.gd` (`risk_voice`);
    `scripts/systems/product_system.gd` (`live_bug_count`); `ProductState.bugs_confirmed`;
    `InfraSystem.is_over_capacity`.
  - Oyuncuya etkisi: Sekme "Sebep: memnuniyet düşüyor" derken kart altyapı şikâyeti ya da kırılmış söz sesiyle
    açılabiliyor; tersi de olabiliyor.
  - Seçenekler: A) Sekme `risk_voice`'un sırasını ve yüklemini kullanır; kırılmış söz için yeni bir sebep satırı
    gerekir (yeni metin, onay bekler). B) Yalnız hata yüklemi `risk_voice` ile aynı yapılır (onaylı hata ya da
    kapasite aşımı), iki sebep kalır. C) Kalır.
  - Kaynak: Satış GDD §19 (retention kartı korunanlar arasında); ch11 §7.

- **40 · Kayıtlı ama okunmayan `Customer.health` alanı.**
  - Ne oluyor: `Customer.health` her memnuniyet değişiminde `update_health_from_satisfaction` ile yazılıyor ama
    okuyucusu yok; `SaveCodec` onu kaydediyor. Yazanlar: `CustomerRegistry.set_satisfaction`,
    `SalesSystem.add_b2b_customer`, B2C tabanı ve `main.gd`'deki debug fikstürü. `SaveCodec.res_from_dict` yalnız
    bugünkü alanları okuduğu için alanı silmek eski kayıtları bozmaz.
  - Nerede: `scripts/data_models/customer.gd` (`health`, `update_health_from_satisfaction`);
    `scripts/autoload/customer_registry.gd` (`set_satisfaction`); `scripts/systems/sales_system.gd`
    (`add_b2b_customer` ve B2C tabanı); `scripts/main/main.gd`.
  - Oyuncuya etkisi: Yok; kayıt dosyasında ve kodda ölü alan kalıyor (CLAUDE.md §8).
  - Seçenekler: A) Alan, fonksiyon ve dört çağrısı silinir (`main.gd` dahil). B) Kalır; sağlık bandı bir okuyucuya
    bağlanır.
  - Kaynak: CLAUDE.md §2, §6, §8.

- **41 · §12.8 kapı-üstü Yazılım hız bonusu uygulanmıyor.**
  - Ne oluyor: Ürün GDD §12.8 "fazladan Yazılım yıldızları hızı aynı kademeyle çarpar" diyor.
    `LineGates.speed_bonus_for` bu bonusu (+%8 / +%4) hesaplıyor ama hiçbir yer çağırmıyor; hat yapımının hızı
    (`ProductSystem.build_effort_per_day`) bonus almıyor. Ölçü de belirsiz: bir sürümde farklı Yazılım kapısı taşıyan
    birden çok kademe olabilir. Bugünkü fonksiyon her kademenin kendi kapısına göre en büyük fazlayı okuyor; eski
    yorum "en büyük kapıya göre" diyordu. Kişi kapısı ile toplam kapısının hangisinin sayılacağı da yazılı değil.
  - Nerede: `scripts/systems/line_gates.gd` (`speed_bonus_for`, `_excess_for`, `_excess_ladder`);
    `scripts/systems/product_system.gd` (`build_effort_per_day`, `_tick_line_build_hourly`,
    `estimate_line_build_days`).
  - Oyuncuya etkisi: Kapının üstünde güçlü yazılımcı tutmak yapımı hızlandırmıyor; GDD'nin vaat ettiği ödül yok.
    Bağlanırsa yapım süreleri ve tohumlu koşu değişir.
  - Seçenekler: A) Sürümdeki kademelerin kendi Yazılım kapılarına göre en büyük fazla (bugünkü `speed_bonus_for`) hızı
    ×(1+bonus) çarpar; Konsept'in süre önizlemesi aynı çarpanı okur. B) Fazla, sürümdeki en büyük Yazılım kapısına
    göre tek referansla ölçülür. C) Bonus kaldırılır: §12.8'in hız cümlesi GDD'den çıkar, `speed_bonus_for` silinir.
  - Kaynak: Ürün GDD (ch03) §12.8, §6.1, §24 (§12.8 inşa notu).

- **42 · §10 kapasite uyarı kartı bağlı değil.**
  - Ne oluyor: §10 "%80–100 kapasite çubuğu sararır ve sürüm başına bir kez olay kartı düşer" diyor (kart: "Sunucular
    yoruluyor."; seçenekler kapasite artır ya da şimdilik bekle). Kodda sürüm başına mandal var
    (`InfraSystem.due_capacity_warning`, `mark_capacity_warning_shown`, `_warning_consumed_version`, `to_dict` /
    `from_dict` / `reset`) ama çağıran yok. Kart JSON'u ve metni yok. Mandal kayda ve `SaveManager.reset_all_owners`'a
    girmiyor.
  - Nerede: `scripts/systems/infra_system.gd` (`due_capacity_warning`, `mark_capacity_warning_shown`, `daily_tick`);
    `data/events/cards/product/` (kart yok); `scripts/autoload/save_manager.gd` (`reset_all_owners`,
    `_capture_systems`).
  - Oyuncuya etkisi: Doluluk %80'i geçince çubuk sararıyor ama kart gelmiyor; oyuncu aşım zararına (memnuniyet
    −0,8/gün, GELEN ×1,5, B2C edinim ×0,6) kartla uyarılmadan girebiliyor.
  - Seçenekler: A) Kart yazılır (önce EN, TR ayrı adım; seçenekler kapasite +1 / bekle). `InfraSystem.daily_tick`
    mandalı okuyup `EventGate.request` eder; mandal kayda ve `reset_all_owners`'a girer. B) Uyarı yalnız çubuğun
    sararması olarak kalır; kart cümlesi GDD'den çıkar ve mandal silinir. C) "Olay içeriği eksik" maddesinin içerik
    turuna bırakılır.
  - Kaynak: Ürün GDD (ch03) §10, §8.5 (uyarısız kayıp yok); ch11 §3.

- **43 · Hat ürünlerinde karmaşıklık sıfır: hata riski ve aşınma.**
  - Ne oluyor: Sprint motoru `mvp_components`'i yazmıyor (yalnız fikstürler ve probe yazar); bu yüzden hat
    ürünlerinde `ProductSystem._shipped_total_complexity()` hep 0. Canlı aşınmanın karmaşıklık terimi
    (`WEAR_CPLX_COEF`) düşüyor. `product_bug_risk()` max(1,0)=1'e bölüyor: tek açık hata "orta", iki ve fazlası
    "yüksek" okunuyor. Kademelerde karmaşıklık alanı yok. Kısmen kapandı (sahip kararı 2026-10-02, kalibrasyon turu):
    `SalesSystem.product_value` artık canlı hatlardan okur, genişlik `ProductState.lines_open`, derinlik
    `usage_weight_total` (A seçeneğinin ürün değeri yarısı; GUNCELLEMELER "Kalibrasyon turu · ürün rev 7").
  - Nerede: `scripts/systems/product_system.gd` (`_shipped_total_complexity`, `_post_ship_wear_hourly`,
    `product_bug_risk`); `data/product/lines/*.json`.
  - Oyuncuya etkisi: Karmaşık ürün daha hızlı aşınmıyor; hata riski zinciri (bugün yüzeyi yok, ISLER "Yeniden yuva
    listesi") tek hatada "orta"ya fırlıyor.
  - Seçenekler: A) Payda yayınlanmış kademelerin efor toplamı ya da kullanım ağırlığı toplamı
    (`ProductState.usage_weight_total`) olur; aşınma ve risk ürün değerinin okuduğu sayıyı okur. B) Kademelere
    `complexity` alanı eklenir (içerik işi, §12.12 şartnamesi). C) Risk rozeti DOĞRULANMIŞ hata sayısına göre mutlak
    eşiklerle okunur; karmaşıklık terimi aşınmayla birlikte kalkar (bkz. 45. madde).
  - Kaynak: Ürün GDD (ch03) §8, §9, §10 (kullanım ağırlığı), §12.4, §17, §21.

- **44 · Düz özellik kataloğunun emekliliği.**
  - Ne oluyor: GDD §21 "katalog hat modeline geçer, 61 düz özellik ve ölü alanlar silinir" diyor. Düz yol oyunda
    yalnız `main.gd` debug tohumlarından ve smoke/probe'dan erişiliyor; üç oynanabilir alt-tip (`note_tool`,
    `video_clip`, `erp`) hat alt-tipi. Bu yol `ProductCatalog.FEATURE_POOLS`, `ProductSystem.start_build` /
    `start_version_build`, `_tick_build_hourly`, TASARIM tur zinciri, `projected_axes`, `estimate_build_days` ve
    bunların sabitlerinden oluşuyor. Ama havuzlar üretimde hâlâ okunuyor: `B2BSalesSystem`'in pain feature seçimi,
    `ProductSystem` hata tohumu ve aşınma, `ProductState`'in feature canlılık sorgusu.
  - Nerede: `scripts/systems/product_catalog.gd` (`FEATURE_POOLS`, `get_feature_pool`, `get_feature_by_id`,
    `sum_efor`, `sum_cost`); `scripts/systems/product_system.gd` (düz katalog bölümü ve sabitleri);
    `scripts/systems/b2b_sales_system.gd`; `scripts/systems/product_state.gd`; `scripts/main/main.gd` debug tohumları; `localization/strings.csv`
    (`PROD_FEAT_*` satırları).
  - Oyuncuya etkisi: Doğrudan görünmez; ölü yol her ürün işini pahalılaştırıyor (hat ürünlerinde karmaşıklık için bkz.
    43. madde).
  - Seçenekler: A) Düz yol ve havuzlar tümüyle silinir; tüketiciler hat karşılıklarına bağlanır (43. maddenin kararı
    önce gelir); smoke/probe fikstürleri test paketi işiyle hat yoluna taşınır. B) Havuzlar yalnız kilitli (hat
    içeriği olmayan) tiplerin veri kaynağı olarak kalır, yapım yolu silinir. C) Bugünkü hâl kalır, GDD §21'e not
    düşülür.
  - Kaynak: Ürün GDD (ch03) §12.1, §20, §21, §22.5; `docs/ACIK_ISLER/ISLER.md` "Test paketi".

- **45 · Canlı aşınma §9'un taşınan hata terimini büyütüyor.**
  - Ne oluyor: `SupportSystem.reports_per_day`'deki §9 taşınan_hata terimi `ProductSystem.live_bug_count()`
    (`mvp_live_bug_count`) okuyor. Sayaç yayında BETA'dan devreden açık hatalarla başlıyor, sonra
    `_post_ship_wear_hourly` ile her saat kitle ve karmaşıklıkla büyüyor. Onu düşüren üretim yolu yok: hata sprinti
    yalnız testten çağrılıyor, düzeltme koşusu DOĞRULANMIŞ'ı eritiyor. Ürün GDD §8–§9'da aşınma yok. Aynı sayaç
    ekonomi Kararlılığını (`QualityModel.economy_dims_from_flags`), sağlık rozetini ve VC/term sheet kontrollerini de
    oynatıyor. Ara karar (sahip kararı 2026-10-02, kalibrasyon turu): aşınma kalır ama kullanıcı terimi küçüldü,
    `WEAR_AUD_COEF` 0,00004 → 0,000002 (1.000 kullanıcı haftada ~6,7 yerine ~0,3 canlı hata ekler); eski değerde
    büyüyen B2C kitlesi hata yığınıyla memnuniyeti ve dönüşümü boğuyordu. Madde açık kalır.
  - Nerede: `scripts/systems/support_system.gd` (`reports_per_day`); `scripts/systems/product_system.gd`
    (`live_bug_count`, `_post_ship_wear_hourly`, `WEAR_*`, `health_state`, `product_bug_risk`);
    `scripts/systems/quality_model.gd` (`economy_dims_from_flags`); `vc_pitch_system.gd` ve
    `term_sheet_table_system.gd` (`live_bug_count` okuyucuları).
  - Oyuncuya etkisi: Canlı ürünün GELEN akışı zamanla kendiliğinden artıyor; oyuncunun düzeltme koşusu bu terimi hiç
    düşürmüyor ve Kararlılık erimesi geri alınamıyor.
  - Seçenekler: A) Aşınma kalkar: taşınan_hata yayındaki devir sayısıdır (`mvp_bug_count_at_launch`) ve her yayında
    tazelenir. B) Taşınan hatalar GELEN'e dönüştükçe terim azalır; düzeltme koşusunda çözülenler `live_bug_count`'u da
    düşürür. C) Taşınan hatalar yayında DOĞRULANMIŞ'a tohumlanır ve akıştaki terim kalkar (§9'un "zamanla yüzeye
    çıkar" cümlesiyle çelişir). D) Aşınma kalır ve GDD'ye işlenir.
  - Kaynak: Ürün GDD (ch03) §7, §8.1, §8.4, §9, §11.2, §20.

- **46 · Boş ürün adı her yüzeyde farklı görünüyor.**
  - Ne oluyor: Konsept'te ad alanı boş bırakılabiliyor. `ProductSystem.start_line_build` v1'de adı
    `ProductState.product_name()`'e (boş) düşürüyor; `FeatureBuild.product_name` ve yayında `mvp_product_name` boş
    kalabiliyor. Yüzeylerin yedekleri farklı: Konsept özetinde tip adı (`creation_flow`), destek barında şirket adı,
    yapım barında yalnız sürüm, Ekip defterinin iş hücresinde yedek yok (" v2"). B2C'de yedek kayda da iniyor:
    `SalesSystem._ensure_b2c_record` ad boşsa `_product_name()`'in çevrilmiş yedeğini
    (`TranslationServer.translate("PRODUCT_FALLBACK_NAME")` ya da `ProductCatalog.type_name`) `Customer.name_arg`'a
    yazıyor; kullanıcı kaydının adı o anki dilde kayda donuyor (CLAUDE.md §5: durumda metin değil id).
  - Nerede: `scripts/systems/product_system.gd` (`start_line_build`); `scripts/data_models/feature_build.gd`
    (`product_name`); `scripts/tabs/product/creation_flow.gd`; `scripts/ui/components/build_bar_model.gd`;
    `scripts/tabs/hr/hr_ledger.gd` (`_job_text`); `scripts/systems/sales_system.gd` (`_ensure_b2c_record`,
    `_product_name`); `scripts/data_models/customer.gd` (`display_name`).
  - Oyuncuya etkisi: Adsız ürün farklı ekranlarda farklı adla ya da adsız (" v2") görünüyor.
  - Seçenekler: A) Konsept onayı ad girilmeden açılmaz. B) Boş ad `ProductCatalog.PRODUCT_NAME_POOL`'dan bir öneriyle
    doldurulur (özel ad; çevrilmez, saklanabilir). C) Tek görüntüleme yardımcısı kurulur: ad boşsa anahtardan tip adı
    okunur, durumda saklanmaz; bütün yüzeyler onu okur.
  - Kaynak: Ürün GDD (ch03) §3; CLAUDE.md §5 (durumda metin değil id).

- **47 · "+N gün" olayı Build'de kimse yokken etkisiz.**
  - Ne oluyor: `delay_days` olay fiili `ProductSystem.apply_speed_bonus`'u çağırıyor. Hat yapımında günler
    `build_effort_per_day` ile efora çevriliyor; Build işinde kimse yoksa hız 0 ve toplam efor değişmiyor. Düz yolun
    `team_speed`'i `SPEED_MIN` = 1 tabanı taşıdığı için orada olay her zaman etki ediyordu. Kart modalı "+N gün" der,
    etki olmaz.
  - Nerede: `scripts/systems/product_system.gd` (`apply_speed_bonus`, `build_effort_per_day`, `SPEED_MIN`);
    `scripts/events/core/effects.gd` (`delay_days`).
  - Oyuncuya etkisi: Build'de kimse yokken düşen gecikme ya da hızlanma kartı söylediğini yapmıyor. Yapım o anda
    oto-duraklı olduğu için etki küçük.
  - Seçenekler: A) Hat yolunda hız tabanlanır (ör. `maxf(SPEED_MIN, build_effort_per_day)`); olay toplamı her zaman
    değiştirir. B) Hız 0 iken fiil reddedilir (effects `refused` döner, çip çizilmez). C) Kabul edilir ve
    `apply_speed_bonus`'un yorumunda söylenir.
  - Kaynak: Ürün GDD (ch03) §6.1; ch11 §3; CLAUDE.md §5 (seçeneğin anlattığını modifier'lar yapar).

- **48 · Ürün Detayı'nda sonraki sürüm kartı hep "~3+ GÜN" yazıyor.**
  - Ne oluyor: Sonraki sürüm kartının durum etiketi `PROD_ETA_DAYS` ("~{n}+ GÜN") `maxi(3,
    ProductSystem.estimate_build_days([], [], ""))` ile doluyor. Tahmin fonksiyonu boş listelerle hep 0 döndüğü için
    etiket her ürün, ekip ve fazda "~3+ GÜN" kalıyor. Sonraki sürümün planı bu ekranda henüz yok; gerçek bir süre
    ancak kademeler seçilince (`ProductSystem.estimate_line_build_days`) bilinir.
  - Nerede: `scripts/tabs/product/detail_view.gd` (`repaint`, `_v_status`); `scripts/systems/product_system.gd`
    (`estimate_build_days`, `estimate_line_build_days`).
  - Oyuncuya etkisi: Oyuncu v2'nin en az 3 gün süreceğini okur. Bu sayı hiçbir durumdan türemiyor; büyük ekiple de tek
    kişiyle de aynı.
  - Seçenekler: A) Etiket gerçek bir alt sınır gösterir: seçilebilir en ucuz kademenin süresi, bugünkü lider ve ekiple
    (`estimate_line_build_days`). B) Süre etiketi kalkar; kart yalnız başlık ve açıklama taşır, süre Konsept'in toplam
    satırında zaten var. C) "~3+" kalır ama adlı bir ayar sabitine taşınır ve boş tahmin çağrısı silinir.
  - Kaynak: Ürün GDD (ch03) §3 (maliyet dürüstlüğü: "Toplam efor · süre" Konsept'te), §6.0, §6.1.

- **49 · Konsept'te onay düğmesi gerekçesiz kapanıyor (plan ret kimliklerinin metni yok).**
  - Ne oluyor: Konsept'in onay kartı, `ProductSystem.validate_line_plan` boş olmayan bir ret kimliği döndürünce
    "Onayla ve Başlat"ı kapatıyor ama sebebini yazmıyor. Not satırı (`_note_label`) ekip ataması retlerini gösteriyor
    (`_reseed_team`, `TEAM_REFUSAL_KEYS`: `job_cap`, `not_your_job`, `inactive` → `PROD_TEAM_REFUSE_*`); plan reddi
    için metin yok ve not satırı o durumda yalnız `PROD_POLISH_NOTE` gösteriyor. Plan ret kimlikleri makine kimliği ve
    CSV karşılıkları yok: `empty_plan`, `unknown_subtype`, `unknown_step`, `step_from_another_subtype`, `locked`;
    `ProductLines.ladder_refusal` için `already_shipped`, `skips_tier`, `line_already_planned`. Oyuncunun pratikte
    ulaşabildiği hâller `empty_plan` (hiç kademe seçilmemiş) ve `locked` (taslaktan dönen bir kademe arada
    kilitlenmiş). Merdiven retlerini hat listesi zaten tıklamada sessizce eliyor.
  - Nerede: `scripts/tabs/product/creation_flow.gd` (`_update_dynamic`, `_commit_btn`, `_note_label`,
    `TEAM_REFUSAL_KEYS`); `scripts/systems/product_system.gd` (`validate_line_plan`);
    `scripts/systems/product_lines.gd` (`ladder_refusal`); `localization/strings.csv`.
  - Oyuncuya etkisi: Düğme gri kalır ve oyuncu nedenini ekranda göremez. Kilitlenmiş bir taslak kademesi olduğunda
    hangi kademenin engel olduğunu tahmin etmek zorunda kalır.
  - Seçenekler: A) Ulaşılabilir iki ret (`empty_plan`, `locked`) için TR/EN anahtarı yazılır ve not satırına basılır.
    B) Bütün ret kimliklerine anahtar yazılır, bir kimlik→anahtar tablosu not satırını besler (hazır desen:
    `TEAM_REFUSAL_KEYS`). C) Olduğu gibi kalır; boş plan kendini açıklar, kilitli taslak kademesi `setup`'ta
    düşürülür.
  - Kaynak: Ürün GDD (ch03) §3, §12.3, §12.9, §18; CLAUDE.md §5 (kilitli seçenek gerekçesiyle görünür).

- **50 · Kademe açıklamaları yazılmış ama hiçbir ekranda görünmüyor.**
  - Ne oluyor: Her kademe bir `desc_key` taşıyor (`PROD_STEP_*_DESC`; paylaşılan hatlarda alt-tip başına ayrı satır).
    Anahtar hat verisinde durmuyor, `ProductLines._build_line` onu `name_key`'den türetiyor. Anahtarlar CSV'de TR ve
    EN olarak yazılmış ve `loc_product_line_keys_resolve` smoke'u çözüldüklerini denetliyor. Hiçbir arayüz `desc_key`
    okumuyor: `FeatureLinesView` yalnız `name_key` basıyor.
  - Nerede: `scripts/systems/product_lines.gd` (`_build_line`, `desc_key`);
    `scripts/tabs/product/feature_lines_view.gd` (`_make_line_row`, `_make_lock_row`); `localization/strings.csv`
    (`PROD_STEP_*_DESC`).
  - Oyuncuya etkisi: §12.12'nin yazdırdığı tek satırlık açıklamaları (90 satır, gizli hat dahil: dosyalardaki hatların
    45 kimlik kademesi ve 36 paylaşılan satırı, Ar-Ge'nin açtığı `line_hidden_self_serve` hattının 9 satırı) oyuncu
    hiç görmez; kademeyi yalnız adından tanır.
  - Seçenekler: A) Açıklama hat satırının hover'ında görünür (kilit satırının tooltip'i gibi); §12.9'un iki satır
    sınırı korunur. B) Seçili ya da üzerine gelinen kademenin açıklaması Konsept'in sağ sütununda tek satır olarak
    durur. C) Gösterilmez; `desc_key` türetmesi, CSV anahtarları ve smoke denetimi silinir.
  - Kaynak: Ürün GDD (ch03) §12.9 (satır anatomisi, satır başına en fazla iki metin satırı), §12.12 (ad + tek satır
    açıklama yazılır).

- **51 · Veri yok işareti ve hayalet satırda uzun tire (—).**
  - Ne oluyor: Ürün ekranları eksik değer için uzun tire basıyor. `detail_view` `NO_DATA_MARK` ("—") DURUM
    hücrelerinin ilk değeri; B2B'de hesap yokken memnuniyet ve churn, B2C'de kullanıcı kaydı yokken memnuniyet bu
    işareti gösteriyor. `team_panel` `_make_pinned_ghost_row` kurucunun yukarı taşındığı grupta ad yerine "—"
    literal'i yazıyor. `capacity_block` bilinmeyen sağlayıcıda "—" basıyor. Aynı işaret ürün dışında da var:
    `scripts/tabs/hr/hr_ui_shared.gd`, `scripts/tabs/personal_tab.gd` (değerleme, net varlık, zirve),
    `scripts/tabs/sales_tab.gd` (sorumlu satırı 35. maddenin konusu), `scripts/ui/components/dialogue_choice_card.gd`.
    `HR_TASK_NONE`'un CSV değeri iki dilde de "—"; İK kadrosunun GÖREV hücresinde (`hr_ledger.gd` `_task_cell`) ve
    `HRUiShared.status_cell`'in boş durumunda görünüyor.
  - Nerede: `scripts/tabs/product/detail_view.gd` (`NO_DATA_MARK`, `_status_card`, `_repaint_stats`);
    `scripts/tabs/product/team_panel.gd` (`_make_pinned_ghost_row`); `scripts/tabs/product/capacity_block.gd`
    (`_provider_row`); `scripts/tabs/hr/hr_ledger.gd` (`_task_cell`); `scripts/tabs/hr/hr_ui_shared.gd`
    (`status_cell`); `localization/strings.csv` (`HR_TASK_NONE`); diğer ürün dışı dosyalar yukarıda.
  - Oyuncuya etkisi: Oyuncu ekranda uzun tire görür. ch01 §9'un "no dashes in copy" kuralı ve CLAUDE.md §5'in tire
    yasağı çiğneniyor; hayalet satırdaki tire ayrıca script içinde oyuncuya görünen bir literal.
  - Seçenekler: A) "—" metin değil noktalama sayılır ve kurala yazılı istisna olarak eklenir. B) Tek yerde tanımlı
    başka bir glif (ör. "·" ya da "0") her yüzeyde kullanılır. C) Yerelleştirilmiş bir anahtar ("yok" / "none") eksik
    değeri, ayrı bir anahtar hayalet satırı taşır.
  - Kaynak: ch01 §9 (Non-negotiables: no dashes in copy); Ürün GDD (ch03) §12.12 (gövde metinlerinde tire yok);
    CLAUDE.md §5.

- **52 · Eksen sayıları üç yüzeyde iki farklı cetvelle gösteriliyor.**
  - Ne oluyor: Ürün Detayı üçgeni ve legend'i `ProductState.axis_readings()`'in §11.3 okumasını sabit
    `QualityModel.READING_MAX` (120) üstünde çiziyor. Aynı sayfadaki B2C fiyat panelinin eksen çipleri
    (`PROD_AXIS_INNOVATION_N` / `_STABILITY_N` / `_EXPERIENCE_N`) ise ham `mvp_innovation` / `mvp_stability` /
    `mvp_experience` bayraklarını, yani fiyat ve değer hesabının girdisi olan gerçekleşen eksen değerlerini basıyor.
    Konsept'in önizleme üçgeni `ProductSystem.projected_line_dims`'in ham değerini (taban cila ×1,00)
    `max(PREVIEW_SCALE_FLOOR = 25, en büyük eksen)` ölçeğinde çiziyor; ölçek seçimle kayıyor. Legend sayıları farklı
    birimde ("7,2" ile "83" gibi).
  - Nerede: `scripts/tabs/product/pricing_panel.gd` (`repaint`, eksen çipleri); `scripts/tabs/product/detail_view.gd`
    (`_repaint_profile`, legend çubukları); `scripts/tabs/product/creation_flow.gd` (`_update_dynamic`,
    `PREVIEW_SCALE_FLOOR`); `scripts/systems/product_state.gd` (`axis_readings`);
    `scripts/ui/components/triangle_radar.gd` (`set_axes`).
  - Oyuncuya etkisi: Oyuncu aynı eksen için aynı ekranda iki sayı görür ve hangisinin ürünü anlattığını bilemez;
    Konsept'te planladığı şekli yayından sonra Ürün Detayı'nda gördüğüyle karşılaştıramaz; önizlemede bir eksenin
    büyümesi öbürlerini küçülmüş gösterebilir.
  - Seçenekler: A) Tek cetvel: çipler ve Konsept önizlemesi de §11.3 okumasını (projeksiyon / fazın çıtası × 100,
    READING_MAX üstünde) gösterir. B) Çipler kalkar (§17: eksen okumaları yalnız üçgende yaşar); önizleme A'daki
    cetvele geçer. C) Yüzeyler ayrı kalır: çip ve önizleme ham değeri korur ama bunu söyleyen yeni birer başlık alır
    (yeni metin) ve önizleme sabit bir ölçek (o fazın çıtası) kullanır.
  - Kaynak: Ürün GDD (ch03) §5 (Konsept önizlemesi taban cila), §11.1, §11.2, §11.3, §17 ("Eksen okumaları monitörün
    üçgeninde yaşar; ayrı panel yoktur", "üçgenin ölçekleme hatası ekran turunda düzeltilir").

- **54 · `PROD_DESK_NOBODY_ELIGIBLE` okunmuyor: masaya kimse uygun değilken işe alım ipucu yok.**
  - Ne oluyor: DESTEK bloğunun masa cümlesi, masa boşken ve masayı taşıyabilecek çalışan yokken her zaman
    `PROD_DESK_FOUNDER_BUSY` gösteriyor (canlı üründe boş masa, kurucunun başka bir işte olduğu demek).
    `PROD_DESK_NOBODY_ELIGIBLE` ("Masayı taşıyabilecek kimse yok. Bir Müşteri Temsilcisi ya da Yazılımcı işe al.")
    CSV'de duruyor ama okuyan yok; onu okuyan dal hiç ulaşılamaz olduğu için silinmişti.
  - Nerede: `scripts/tabs/product/detail_view.gd` (`_desk_sentences`); `localization/strings.csv`
    (`PROD_DESK_NOBODY_ELIGIBLE`, `PROD_DESK_FOUNDER_BUSY`).
  - Oyuncuya etkisi: Kurucu meşgulken ve masaya uygun çalışan yokken oyuncu yalnız kurucunun meşguliyetini okur.
    Doğrulama akışını yeniden başlatacak işe alım yolu ona söylenmez.
  - Seçenekler: A) Anahtar silinir (ISLER'deki CSV süpürmesine girer). B) Uygun çalışan yoksa `FOUNDER_BUSY` yerine
    `NOBODY_ELIGIBLE` gösterilir. C) İkisi alt alta: önce kurucunun meşguliyeti, altında işe alım ipucu.
  - Kaynak: Ürün GDD (ch03) §8.2 (doğrulama Müşteri İlişkileri'nin işi), §17 (destek durumu).

- **57 · Araştırma görevinin GÖREV cümlesi yok.**
  - Ne oluyor: Kadro defterinin GÖREV hücresi tek işli kişide `HR_TASK_ON_JOB_<İŞ>` cümlesini basıyor (ör. "Satışta
    görev alıyor"). Araştırma için `HR_TASK_ON_JOB_RESEARCH` satırı yok; kod bilinçli olarak iş etiketine düşüyor
    ("Araştırma"). Ham anahtar ekrana çıkmıyor ama bu satır öbür işlerle aynı biçimde okunmuyor.
  - Nerede: `scripts/tabs/hr/hr_ledger.gd` (`_job_text`, `_task_cell`); `localization/strings.csv` (`HR_TASK_ON_JOB_*`
    ailesi).
  - Oyuncuya etkisi: Araştırmadaki kişinin GÖREV hücresinde cümle yerine tek kelime görünüyor; defterin dili tutarsız.
  - Seçenekler: A) Yeni anahtar yazılır: EN "Working on research", TR "Araştırmada görev alıyor" (onay bekler);
    ardından `_job_text`'teki geri düşüş dalı silinir. B) Bugünkü gibi: etiket yeterli, geri düşüş kalır.
  - Kaynak: Ekip GDD §12.2 (iş metni); Ar-Ge GDD §5.0 (araştırma dışlayıcı iştir).

- **59 · VC'nin zayıf boyut tabanı ham eksenle karşılaştırılıyor; ürün uyumu bonusu fiilen hiç verilmiyor.**
  - Ne oluyor: `VCPitchSystem._weakest_dimension` literal `< 40.0` çalışma tabanını,
    `TermSheetTableSystem.E_FIT_PRODUCT_DIM_FLOOR` (40,0) ise ürün alanının uyum puanını yayındaki HAM
    `mvp_innovation` / `mvp_stability` / `mvp_experience` değerleriyle (`QualityModel.dims_from_flags`)
    karşılaştırıyor. Hat modelinde bu değerler 52. maddenin kaydettiği gibi tek haneden ~20'lere uzanır. Eksen başına
    üç hattın K1'i 12 eder (`QualityModel.PHASE_BAR[1]`). 40'a ancak bir eksenin üç hattı da K3'teyken (3 × 14,4 =
    43,2, tam gerçekleşmede) varılır. `full_run:760:sim` probe'unda (tohum 1, 2, 3) 12–16 sürümde en yüksek ham eksen
    31,6 / 27,9 / 33,3'te kaldı, deneyim ekseni 3,0–5,7'yi geçmedi.
  - Nerede: `scripts/systems/vc_pitch_system.gd` (`_weakest_dimension`; okuyanları `_sorgu_product` ve seed'in ürün
    sorusu); `scripts/systems/term_sheet_table_system.gd` (`E_FIT_PRODUCT_DIM_FLOOR`, `E_FIT_PRODUCT_DIMS`,
    `_domain_fit` "product" dalı); `scripts/systems/quality_model.gd` (`dims_from_flags`, `axis_readings`).
  - Oyuncuya etkisi: VC her koşuda bir zayıf boyut bulur. Canlı hata yokken Series A sorgusu hep `VC_Q_WEAK_DIM`
    sorar, seed'in ürün sorusu hep `SEED_Q_HOW_BIG` olur, "temiz" dal (`VC_Q_CLEAN` / `SEED_Q_CLEAN`) ürün alanında
    hiç gelmez. Meridian masasında `E_FIT_PRODUCT_DIMS` (+4) pratikte hiç verilmez; ürünü ne kadar iyi olursa olsun
    oyuncu bu isteklilik puanını alamaz.
  - Seçenekler: A) İki taban da §11.3 eksen okumasıyla (`ProductState.axis_readings`, 0–120, çıtaya göre)
    karşılaştırılır; 40 okuma çıtanın %40'ı demek olur. B) Tabanlar ham aralığa göre yeniden ölçeklenir [K] (ör. 12 =
    eksen başına K1 dolu). C) Bugünkü davranış kalır ve GDD'ye yazılır: ürün alanında VC hep bir zayıflık bulur, boyut
    bonusu Series A'da ulaşılmaz bir hedeftir. İki sabit de E modeli sabitidir, değişikliği sahip onayı gerektirir
    (CLAUDE.md §3).
  - Kaynak: GDD ch09 (Funding & Investors) ve Ürün GDD (ch03) §11.2–§11.3 VC tabanının hangi ölçeğe baktığını
    söylemiyor; `QualityModel` hat modeli; probe ölçümü (`full_run:760:sim:1-3` PROBE SHIP satırları); 52. madde (ham
    eksen aralığı).

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
  dosya sahip kararıyla silindi. Açık kararlar: perde sınırları, kişisel runway, 730'un Perde 2 saati olması, remote
  çalışan ve ekip tavanı, İK rolü, run kartı, teknik borç, tükenmişlik sonu. 3D sanat yönü ve kapsamı ile ofis kataloğu
  2026-09-27'de karara bağlandı (gerçek zamanlı izometrik 3B ofis; Ev → İş hanı → Plaza katı → Depo loft;
  `GDDs/GUNCELLEMELER.md` ch12); kalan: kira ve ekonominin bağlanması (60. madde). #11 (kurgu etkinlik adları) karar
  değil, mevcut yasadır (ch14 §6). Birçoğu yürürlükteki GDD'lerle çelişiyor (ch14 §7 çalışan yüzü, Ekip GDD ekip
  tavanı). Kaynak: VIZYON_v1_YANITLAR §2–§3.

- **GDD'ler arası iki çelişki.** (1) Zor mod: ch01 §6 "v1 yalnız Normal; Hard, Normal kalibre edilene kadar
  kilitli-görünür", ch14 §2 "Hard demo'da çıkar" diyor; ch14 §8 ayarlı mı kaba mı çıkacağını açık bırakıyor. Kodda zor mod
  yok: son ekranında "ZOR MOD · YAKINDA" kilitli, Frank'in çekini ve seed'i reddetmek "zor modda açılır" kilidinde.
  `GDDs/README.md` ch01 §6 için ch14'ü okutur. Açık: Hard demo'ya girecek mi. (2) Ar-Ge sekmesi: ch12 §1 ve ch14 §3
  "kilitli-görünür" diyor; Ar-Ge GDD §2 (rev 1.8) ray öğesini ilk günden normal sekme sayıyor, kod (`UiTokens.TABS`) buna
  uyuyor. Açık: ch12 §1 ve ch14 §3 güncellensin mi.

- **60 · Ofis kirası, depozitosu ve nakliyesi ekonomiye bağlı değil.**
  - Ne oluyor: Katalog tasarımın sayılarını taşıyor, hepsi [WORKING]: İş hanı kira 2.500 / depozito 5.000 / nakliye
    1.500, Plaza 18.000 / 36.000 / 9.000, Depo loft 45.000 / 90.000 / 20.000; şartlar İş hanı'nda Frank'in çeki ve
    kasa 6.500, Plaza'da ekip 12, kasa 45.000, marka 40, Depo loft'ta ekip 35, kasa 110.000, marka 70. Taşınma kasadan
    hiçbir tutar düşmüyor; `FinanceSystem`'in "office" gider kalemi 0. Kasa şartı yalnız kapıdır.
  - Nerede: `scripts/systems/office_constants.gd` (`CATALOG`); `scripts/systems/office_system.gd` (`move_to`);
    `scripts/systems/finance_system.gd` (`STARTING_BURN_BREAKDOWN` "office"); `scripts/ui/office/office_map_card.gd`.
  - Oyuncuya etkisi: Harita kartı kirayı ve "Taşın · {depozito + nakliye}" tutarını gösteriyor, kasa değişmiyor; büyük
    ofisin bedeli yok.
  - Seçenekler: A) Depozito ve nakliye taşınmada tek seferlik gider (`FinanceSystem.apply_one_time_cost`), kira aylık
    "office" kalemi olur; sayılar kalibrasyonla. B) Yalnız kira bağlanır. C) Kalır (görsel ilerleme); karttaki bedel
    satırları kalkar.
  - Kaynak: Erdem, 2026-09-27 görev kararı (izometrik ofis; bu turda kasa hareketi yok); ch08 §1; "B2 ekonomisi (D13)"
    maddesi ("Ofis gideri 0").

- **61 · Krem paletin ve ofis kişilerinin onay bekleyen renkleri.**
  - Ne oluyor: Krem palete geçişte yeni değer alan ve F5 onayı bekleyen renkler: `ACCENT_HOVER` #F6D059,
    `ACCENT_PRESSED` #D7AC2A, `BUILD_RAMP_2` #C0692A, `BUILD_RAMP_3` #2F8783, `BORDER_STEPPER_OWN` #AF9E7F, `DOT_IDLE`
    #C4B79F, `BUILD_FILL_PAUSED` #EFE8DA ve renk körü zeminleri (`POSITIVE_BG_CB` #D9E5F0, `NEGATIVE_BG_CB` #F1E4D1).
    Ofiste Müşteri Temsilcisinin kıyafet rengi `OfficeConstants.ROLE_COLORS["cs"]` #8a63d2; tasarımda bu rol yok.
  - Nerede: `scripts/theme/ui_tokens.gd` (`# WORKING` işaretleri); `scripts/systems/office_constants.gd` (`ROLE_COLORS`).
  - Oyuncuya etkisi: CTA'nın hover ve basılı hâli, Build Bar'ın 2. ve 3. tur rengi, stepper kenarı, kazanılmamış
    kilometre taşı noktası, duran çubuğun dolgusu, renk körü paletinde olumlu ve olumsuz zemin, ofiste müşteri
    temsilcileri.
  - Seçenekler: A) Görsel turda olduğu gibi mühürlenir. B) Sahip değerleri değiştirir (token değişikliği `THEME_STAMP`'i
    artırır, tema yeniden üretilir).
  - Kaynak: Erdem, 2026-09-27 görev kararı (renkler F5 ile mühürlenir); CLAUDE.md §7.

- **62 · Ofisin ekip şartı izindekileri de sayıyor.**
  - Ne oluyor: Plaza (12) ve Depo loft (35) ekip şartı `HRSystem.headcount()`'u okuyor, o da
    `CharacterRegistry.count_employees()`'u: izindeki ve eğitimdeki çalışanlar dahil, kurucu hariç. İşbaşındakiler
    (`get_active_employees`) ayrı sayıdır; ofiste yalnız onlar görünür.
  - Nerede: `scripts/systems/office_system.gd` (`requirement_state`, "team"); `scripts/systems/hr_system.gd`
    (`headcount`); `scripts/autoload/character_registry.gd` (`count_employees`, `get_active_employees`).
  - Oyuncuya etkisi: İzne çıkan biri kapıyı kapatmaz; kart "şu an 12" derken ofiste 11 çalışan görünebilir.
  - Seçenekler: A) Kadro sayısı kalır (izin geçicidir). B) Yalnız işbaşındakiler sayılır.
  - Kaynak: ofis tasarımı (şart "Ekip en az N kişi", `OFFICE_REQ_TEAM`); Erdem, 2026-09-27 görev kararı.

- **64 · Plaza ve Depo loft sahnesinde katalogdan fazla masa var.**
  - Ne oluyor: Sahne (tasarımın `maxN`'i) Plaza'da 37, Depo loft'ta 69 çalışan masası kuruyor (kurucu masası
    hariç); katalog (`desks`, tasarımın ofis kartından) 36 ve 64 diyor. Harita kartı ve hover satırı katalog sayısını,
    oturtma sahnenin sayısını okuyor. İş hanında ikisi de 10.
  - Nerede: `art/office3d/{plaza,loft}.json` (`maxN`, `spots.desk`); `scripts/systems/office_constants.gd`
    (`CATALOG`); `scripts/ui/office/office_people.gd` (`_seat_everyone`); `scripts/ui/office/office_map_card.gd`,
    `scripts/ui/office/office_city.gd` (`OFFICE_HOVER_LINE`).
  - Oyuncuya etkisi: Kart "36 masa" derken ofiste 37. çalışan da masaya oturur.
  - Seçenekler: A) Katalog sahneye eşitlenir (37 / 69). B) Oturtma katalog sayısıyla sınırlanır, fazla masalar boş
    kalır. C) Tasarım düzeltilir ve yeniden dışa aktarılır.
  - Kaynak: ofis tasarımı (Claude Design `65a0b148`: `office-plaza-v2.js`, `office-loft-v2.js` ve ofis kartı).

- **65 · Pencere ölçüleri: Ekip mockup'tan geniş, ürün kurmanın 3. adımı Ürün penceresine sığmıyor.**
  - Ne oluyor: Ekip penceresi 1200×720 (`WindowLayer.SPECS`); mockup 1000 genişlik veriyor. Kadro defterinin yoğun
    kademesinde sabit sütunlar 874 px tutuyor (`HRLedger.W_*_DENSE`); ÇALIŞAN sütunu ve kenar boşluklarıyla 1000'e
    sığmıyor. Ürün kurma akışının 3. adımı 1280 genişliğindeki Ürün penceresini 59 px aşıyor (görsel tur ölçümü).
  - Nerede: `scripts/ui/components/window_layer.gd` (`SPECS`); `scripts/tabs/hr/hr_ledger.gd` (`W_*_DENSE`,
    `measure`); `scripts/tabs/product/creation_flow.gd`.
  - Oyuncuya etkisi: Ekip penceresi arkadaki ofisi mockup'tan çok örtüyor; ürün kurmanın 3. adımında içerik taşıyor.
  - Seçenekler: Ekip için A) 1200 kalır, B) 1000'e iner ve defter sütunları yeniden ölçülür (ad ve rol kısalır). Ürün
    için A) pencere en az 59 px genişler, B) 3. adımın sütunları daralır.
  - Kaynak: ofis tasarımının pencere mockup'ı; Erdem, 2026-09-27 görev kararı (sabit yuvalı pencereler); görsel tur
    ölçümü (2026-09-27).

- **75 · Temsilcinin etkin çıktısı işleme süresini etkilemiyor.**
  - Ne oluyor: Satış §7.2'de işleme süresi lige göre bir aralıktır (kendi ligi 6 ile 7 gün, bir alt 3 ile 4, iki alt
    2 ile 3) ve temsilcinin etkin çıktısı (`hr.effective_skill`: moral, odak, mesai) deal'i bu aralığa yerleştirir.
    Haftalık modelde süre tik başına kapanma ihtimaline döndü: `SalesConstants.PROCESS_CLOSE_CHANCE` kendi ligde
    0,50, bir altta 0,75, iki altta 1,00 [WORKING]; Premium'da ihtimal 1,30'a bölünür. Beklenen süre 2 / 1,33 / 1
    hafta. İhtimal yalnız lig farkından okunur: `PROCESS_REFERENCE_OUTPUT`, `PROCESS_MIN_DAYS` ve
    `Prospect.work_due_day` silindi, satış masası `hr.effective_skill` okumuyor.
  - Nerede: `scripts/systems/sales_rep_system.gd` (`close_chance`, `_tick_processing`);
    `scripts/systems/sales_constants.gd` (`PROCESS_CLOSE_CHANCE`, `PROCESS_PREMIUM_PENALTY`).
  - Oyuncuya etkisi: Temsilcinin morali, odağı ve mesaisi kapanış hızını değiştirmez; hızı yalnız lig farkı ve kadran
    belirler. Moralsiz ya da kısa mesaili temsilci ötekiyle aynı hızda kapatır.
  - Seçenekler: A) Kalır; §7.2'nin "aynı süreyi oynatır" cümlesi GDD'den düşer. B) Etkin çıktı ihtimali ölçekler [K]
    (ör. çıktı / referans çıktı ile çarpılır, tavan 1,00). C) Etkin çıktı lig farkını kaydırır: güçlü temsilci bir alt
    ligin ihtimaliyle kapatır.
  - Kaynak: Satış GDD §7.2, §17; GDD Zaman Modeli §4.5 ve Açık 1; Erdem, 2026-09-27 kararı (tik başına kapanma
    ihtimali).

- **76 · HAYIR DİYEMEZ'in fiyat-kırma kartına etkisi kalmadı.**
  - Ne oluyor: Satış §7.6 fiyat-kırma kartını Premium'da, fiyata duyarlı arketipte işlemenin son günlerinde düşürür;
    HAYIR DİYEMEZ'li temsilcide kart daha sık gelir [K] (§11.8: huyun satış ucu). Gün modelinde pencere son 2 gündü
    (`PRICE_BREAK_TRIGGER_LAST_DAYS`) ve HAYIR DİYEMEZ onu ×1,6 genişletiyordu (`PRICE_BREAK_CANT_SAY_NO_MULT`).
    Haftalık modelde vade yok: an her işleme tikinde zardan önce değerlendirilir ve lead başına bir kez gelir; iki
    sabit silindi. Kartın kendisi bugün de bağlı değil: an yalnız `EventBus.rep_discount_requested` yayar.
  - Nerede: `scripts/systems/sales_rep_system.gd` (`price_break_due`, `_maybe_price_break`);
    `scripts/systems/hr_constants.gd` (`TRAITS["cant_say_no"]`).
  - Oyuncuya etkisi: Bugün yok (kart bağlı değil). Kart bağlanınca HAYIR DİYEMEZ'li temsilci öbürlerinden farksız
    olur; §11.8'in saydığı satış ucu işlemez.
  - Seçenekler: A) HAYIR DİYEMEZ'li temsilcide an, deal sürdükçe her işleme tikinde bir ihtimalle yeniden gelebilir [K];
    öbür temsilcilerde lead başına bir kez kalır. B) Öbür temsilcilerde an bir ihtimale bağlanır [K], HAYIR DİYEMEZ'de
    kesin gelir. C) Satış ucu kalkar; §7.6'nın cümlesi ve §11.8'in huy satırı güncellenir.
  - Kaynak: Satış GDD §7.6, §11.8, §17 ("kart tetik günü + HAYIR DİYEMEZ çarpanı"); GDD Zaman Modeli §4.5 ve Açık
    2; Erdem, 2026-09-27 kararı.

- **77 · Bir haftadan kısa süreler tek tike çöküyor.**
  - Ne oluyor: Günden haftaya çeviride bir haftanın altındaki süreler tek tike indi, aradaki ayrım kayboldu. Canlı
    hata sprinti her zaman bir haftadır (`SPRINT_WEEKS`, sahip kararı): gün modelinde hata sayısına ve Test alanına göre
    1 ile 7 gün sürüyordu; test uzmanlığının sprinti kısaltması (`TESTER_SPRINT_PER_EXPERTISE`) silindi. Pitch
    hazırlığı bir hafta sürer ve yalnız görüşmeye en az bir hafta varken başlar (`PREP_WEEKS`,
    `PREP_MIN_WEEKS_BEFORE` 1); bir haftalık randevuda bu, randevunun alındığı haftadır. Hata trendi bu hafta ile
    geçen haftayı karşılaştırır (`BUG_HISTORY_WEEKS` 2 örnek; eskiden 7 günlük örnek). Musluk haftanın lead'lerini tek
    seferde üretir (`FAUCET_TICK_MAX` 14). Haber şeridi haftada 3 ile 5 satır yazar (`NewsFeedSystem.WEEKLY_LINES_MIN`
    / `_MAX`; eskiden günde 3 ile 5).
  - Nerede: `scripts/systems/product_system.gd` (`SPRINT_WEEKS`, `start_bug_sprint`, `BUG_HISTORY_WEEKS`);
    `scripts/systems/pitch_constants.gd`; `scripts/systems/sales_faucet_system.gd` (`_tick_inflow`);
    `scripts/systems/news_feed_system.gd`.
  - Oyuncuya etkisi: Üç hatalık sprint de bir hafta sürer ve Test'e atanan kişi onu kısaltmaz; hazırlık için tek hafta
    vardır; hata trendi iki noktadan okunur; lead'ler ve haber satırları hafta başında toplu gelir.
  - Seçenekler: A) Kalır (tik iriliğinin bilinçli bedeli). B) Saat çözünürlüklü süre: kısa süreler saatle sayılır ve
    haftanın içinde biter (ayrı tasarım). C) Yalnız seçilen satırlar saat çözünürlüğüne geçer (ör. sprint ve lead
    gelişi).
  - Kaynak: GDD Zaman Modeli §4.2, §4.5, §4.7, §4.9 ve Açık 3; Erdem, 2026-09-27 ve 2026-09-28 kararları.

- **78 · Olay kartları haftanın başında geliyor.**
  - Ne oluyor: Günlük kartlar günlük tikte değerlendirilir; günlük tik 00:00 devrindedir ve gece atlamasının toplu
    adımının içinde koşar. Toplu adım sürerken gösterim ertelenir (`TimeManager.is_batching`); adım bitince
    (`EventBus.clock_batch_ended`) motor kartları 08:00'de sırayla gösterir: tik başına en çok 2 kesinti
    (`EvTuning.MAX_INTERRUPTS_PER_DAY`), gerisi masadaki kâğıtlara düşer. Haftalık satış kartı da o anda gelir,
    süresi dolan kâğıtlar o anda düşer. Gün içinde yalnız saatlik kartlar (`allowed_hours`) ve oyuncunun eylemlerine
    bağlı kartlar gelir.
  - Nerede: `scripts/autoload/time_manager.gd` (`skip_night`, `_run_batch`, `_dispatch_daily_tick`);
    `scripts/events/core/engine.gd` (pump ertelemesi); `scripts/events/core/signals.gd`;
    `scripts/events/core/tuning.gd`.
  - Oyuncuya etkisi: Hafta 08:00'de kararlarla açılır; 1×'te 90 saniyelik haftanın ilk anı kalabalık, gerisi
    çoğunlukla sessizdir.
  - Seçenekler: A) Kalır: hafta başı sabah postası gibi okunur. B) Günlük kartlar haftanın gündüz saatlerine yayılır
    (motor tasarımı: kuyruktaki kart saatlere dağıtılarak gösterilir). C) Yalnız kritik kartlar 08:00'de kalır,
    öbürleri gün içine yayılır.
  - Kaynak: Erdem, 2026-09-27 kararı (bir oyun günü bir hafta; ofis boşalınca gece atlanır); ch11 §5; olay motoru GDD
    §13 (tempo); GDD Zaman Modeli §7.

- **79 · Satış masasının haftalık ayrıntıları: hafta içinde doğan lead, haftalık rapor, gece kilidi.**
  - Ne oluyor: (1) Sahip kararı, hafta başladıktan sonra doğan lead'e (olay kartından gelen) bir hafta fazla ömür
    veriyordu: o tikin temsilci masası çoktan koşmuştur. Kod kararın amacını ek hafta yerine sırayla karşılar: her lead
    1 hafta yaşar (`LEAD_LIFE_WEEKS`), süre dolumu temsilci masasından sonra süpürülür
    (`SalesFaucetSystem.expire_leads`, `B2BSalesSystem.daily_tick`). Lead dolduğu tikte de masaya girebilir; hafta
    içinde doğan lead ertesi tikin masasına ulaşır, ama aynı günlük dağıtımda, masadan hemen sonra düşer: oyuncu onu
    yalnız doğduğu haftanın kalan saatlerinde görür. (2) Haftalık satış raporu yalnız masanın kapanış yaptığı haftada
    yenisiyle değişir; okunmamış N. hafta kartı N+1'in raporu yazıldıktan sonra gösterilirse N+1'in kapanışlarını
    listeler (bilgi kartı süreyle düşmez; kuyruktan haftanın başında gösterildiği için seyrek). (3) Gece ve "mesai
    bitmek üzere" aynı kilit metnini gösterir (`SALES_BLOCK_TOO_LATE`); ayrı bir gece anahtarı yok.
  - Nerede: `scripts/systems/sales_faucet_system.gd` (`spawn`, `expire_leads`); `scripts/systems/b2b_sales_system.gd`
    (`daily_tick`); `scripts/systems/sales_ledger.gd` (`close_week`, `weekly_close_lines`, `meeting_block_reason`);
    `data/events/cards/customer/weekly_summary.json`.
  - Oyuncuya etkisi: (1) Olay kartından gelen lead panoda yalnız doğduğu haftanın sonuna kadar durur. (2) ve (3) kenar
    durumlarıdır: rapor kartı nadiren yanlış haftanın kapanışlarını sayar; gece masaya oturmak isteyen oyuncu "mesai
    bitmek üzere" okur.
  - Seçenekler: (1) A) Sıra kalır: her lead 1 hafta, dolum masadan sonra. B) Kararın harfi: hafta içinde doğan lead 2
    hafta yaşar (sıra da kalır). (2) A) Kalır. B) Rapor, kart okunana kadar birikir. (3) A) Tek anahtar kalır. B) Gece
    için ayrı kilit metni yazılır (önce EN, sonra TR).
  - Kaynak: Satış GDD §4 (lead ömrü), §5.0 (giriş kapısı), §7.3 (haftalık özet); GDD Zaman Modeli §4.5, §8.2;
    Erdem, 2026-09-28 kararı (hafta içinde doğan lead'e ek hafta).

- **81 · Yatırım toplantısının haftalık takvimi: erteleme, kart saatleri, geç masa kilidi, giriş kapısı.**
  - Ne oluyor: (1) Erteleme tavansızdır: toplantı haftasından önceki her hafta "Ertele" randevuyu bir bekleme süresi
    (`PitchConstants.MEETING_LEAD_WEEKS`, 1) daha iter ve fona her seferinde `MEETING_RESCHEDULE_PENALTY` yazar; gün
    modelinin davranışı budur. Adım sabit bir hafta değil bekleme süresidir; sabit değişirse adım da değişir. (2)
    `funding.meeting_day` kartı günlük değil saatliktir ve koşulunda `funding.meeting_sitting_open` kapısını taşır:
    günlük tarama 00:00'da, gecenin içinde koştuğu için kapılı günlük kart hiç geçemezdi. Kart ekrana yine 08:00'de
    gelir ama havuza 00:00 yerine 08:00'de girer. (3) `funding.sheet_decision`'ın "Masaya otur" seçeneği
    `VC_BLOCK_LATE` kilidi taşır; kilit görünürse açık kalan tek seçenek reddetmektir ve fon kalıcı kapanır. Kartın
    koşulu da masa kapısını beklediği için bu yalnız bir oturumun saatleri koşmuşken ekrana gelen kartta olabilir. (4)
    Oturum kapısı (`WorkHoursSystem.sitting_open`) yalnız giriş yüzeylerinde (Yatırım sekmesi düğmeleri, kart
    seam'leri) zorlanır; `VCPitchSystem.begin_meeting`, `TermSheetTableSystem.open` ve `SeedRoundSystem.begin_pitch`
    geç saatte reddetmez (satış toplantısının deseni; smoke ve probe oturumları 00:00'da açılır).
  - Nerede: `scripts/systems/vc_pitch_system.gd` (`reschedule_meeting`, `begin_meeting`);
    `scripts/systems/work_hours_system.gd` (`sitting_open`); `scripts/systems/pitch_constants.gd`;
    `scripts/systems/term_sheet_table_system.gd` (`open`); `scripts/systems/seed_round_system.gd` (`begin_pitch`);
    `data/events/cards/funding/meeting_day.json`, `sheet_decision.json`; `scripts/events/seams/seams_ported.gd`;
    `scripts/tabs/hunt_tab.gd`.
  - Oyuncuya etkisi: (1) Oyuncu toplantıyı istediği kadar erteleyebilir; bedeli fonun hafızasıdır. (3) Nadir bir anda
    tek açık seçenek fonu kapatmaktır. (2) ve (4) oyuncuya görünmez.
  - Seçenekler: (1) A) Kalır. B) Erteleme sayısına tavan [K]. C) Erteleme sabit bir hafta iter. (2) A) Saatlik kart
    onaylanır. B) Kart kapısız ve kilitsiz günlük kalır. (3) A) Kilit kalır. B) Bu kartta kilit kalkar; oyuncu geç
    saatte de masaya oturur. (4) A) Kalır. B) Oturum sistemleri de kapıyı zorlar; smoke ve probe oturumları gündüz
    saatine taşınır.
  - Kaynak: ch09 §4, §5; GDD Zaman Modeli §4.7, §8.2, §8.6; Erdem, 2026-09-27 kararı (toplantı süreleri, tek giriş
    kapısı).

- **82 · Sürüm yaşı rozeti geç yayında ilk tikte "1 hafta" okuyor.**
  - Ne oluyor: Yayın saat kesriyle damgalanır (`mvp_version_launch_day` = tik + saat / 24). Destek akışı ve ilgi
    kesirli yaşı okur (`ProductState.version_age`). Ürün Detayı'nın sürüm rozeti ve `urun.version_age` seam'i
    `ProductState.version_age_weeks()` okur, yani kesirli yaşın yukarı yuvarlanmışını. Haftanın geç saatinde
    yayınlanan sürüm bir sonraki tikte, bir haftadan az geçmişken "1 hafta" okur; gün modelinde rozet yayından sonra
    dönen günleri sayıyordu.
  - Nerede: `scripts/systems/product_state.gd` (`version_age`, `version_age_weeks`); `scripts/systems/product_read.gd`;
    `scripts/tabs/product/detail_view.gd`; `scripts/events/seams/seams_product.gd` (`urun.version_age`).
  - Oyuncuya etkisi: Yayından bir hafta geçmeden rozet "1 hafta" der; `urun.version_age` okuyan kartlar da aynı sayıyı
    görür.
  - Seçenekler: A) Kalır: rozet yayından sonra dönen tiki sayar. B) Tamamlanan hafta (kesirli yaşın aşağı
    yuvarlanmışı): geç yayında rozet bir tik boyunca 0 okur.
  - Kaynak: Ürün GDD (ch03) §9, §17 (sürüm yaşı); GDD Zaman Modeli §3.5.

- **83 · Dönem özetinin dört açık ayrıntısı.**
  - Ne oluyor: Özet oyuncunun seçtiği sıklıkta gelir (haftalık, aylık, çeyreklik, yıllık; varsayılan çeyreklik). (1)
    Dönemin öne çıkan olayı (`month_highlight_*`) dönem kapanırken, yuva 0'da, yük kurulunca temizlenir; özet yuva
    10'da yayılır. Kapanış tikinin 1 ile 9. yuvalarında yazılan öne çıkanlar yeni dönemin ilk haftasına aittir ve
    yayında temizlense kaybolurdu. (2) Dönem defteri (`summary_ledger`) başlangıç tikini, MRR'ı, kasayı, ekibi ve
    markayı tutar; müşteri alanı yok, çünkü hiçbir özet satırı müşteri okumuyor. (3) Haftalık kipte hafta numarası hem
    başlıkta hem aralık satırında geçer. (4) Sessiz dönem satırının dönem ikizleri (`SUMMARY_HIGHLIGHT_FALLBACK_WEEK`,
    `_QUARTER`, `_YEAR`) onaylı aylık metni (`MONTH_HIGHLIGHT_FALLBACK`) kopyalar; o metin hüküm taşır ("Sakin aylar
    ucuz değildir").
  - Nerede: `scripts/systems/summary_system.gd` (`begin_day`, `_open_period`, `_build_summary_data`, `PERIOD_KEYS`);
    `scripts/modals/month_summary_modal.gd`; `localization/strings.csv`.
  - Oyuncuya etkisi: (2) Özet müşteri değişimini göstermez. (3) Haftalık özetin başlığı kendini tekrar eder. (4)
    Sessiz dönem satırı gözlem yerine hüküm okur (CLAUDE.md §5).
  - Seçenekler: (1) A) Yuva 0'da temizlik onaylanır. B) Yayında temizlenir. (2) A) Kalır. B) Özete müşteri satırı
    eklenir, defter müşteriyi de tutar. (3) A) Kalır. B) Haftalık kipte aralık satırı düşer. (4) A) Kopya kalır. B)
    İkizler yalnız gözlem taşıyan yeni metin alır (önce EN, sonra TR).
  - Kaynak: ch08 §4 (Monthly close, one screen); GDD Zaman Modeli §6.3; Erdem, 2026-09-27 kararı (sessiz ay kapanışı,
    özet sıklığı); CLAUDE.md §5.

- **84 · Finans gösterimi: runway çiftinin kırmızısı ve işlem tarihinin yılı.**
  - Ne oluyor: (1) Runway çifti (önce → sonra) basılan iki metin farklıysa değişmiş sayılır (sahip kararı;
    `RUNWAY_PAIR_EPSILON` silindi). Bu kuralla kârlılıktan yanmaya geçiş ("Artıda" → "N ay"; ör. kârlılığı bitiren işe
    alım) Ekip Atlas'ının şeridinde kırmızı basar, eskiden nötrdü; 1,0 aydan 0,99 aya düşüş de "1 ay → 4 hafta" diye
    kırmızıdır. (2) İşlem listesinin tarih sütunu yılı da taşır (`FIN_TX_DATE`, ör. "H14 · Nis 2026"); sütun 96 px'dir.
  - Nerede: `scripts/theme/ui_tokens.gd` (`net_runway_pair`, `_runway_weeks`); `scripts/tabs/hr/hr_atlas_modal.gd`;
    `scripts/tabs/finance/finance_ozet_view.gd` (işlem satırı).
  - Oyuncuya etkisi: (1) Kârlılığı bitiren işe alım kırmızı uyarı gibi okunur. (2) Tarih sütunu geniştir.
  - Seçenekler: (1) A) İki durum da kırmızı kalır. B) Sonsuzdan sonluya geçiş nötr kalır, yalnız sayıdan sayıya düşüş
    kırmızıdır. (2) A) Yıl kalır. B) Kısa biçim ("H14 · Nis"); sütun 72 px'e döner.
  - Kaynak: GDD Zaman Modeli §4.6, §5; Erdem, 2026-09-28 kararı (çift, basılan metinler farklıysa değişmiş sayılır).

- **85 · Kurucunun toplantı yolculuğu: perde, üst bar tıkları, koşuyu bitiren imza.**
  - Ne oluyor: Dış toplantıya (satış, VC ve seed pitch'i, term sheet masası) giderken saat donar ve ağaç koşar;
    kurucu çıkışa yürür, görünüm haritaya kararır, kamera hedef binaya kayar. (1) Perde pencereleri, BuildHUD'u, not
    yığınını ve "Ofisi taşı" düğmesini gizler, ofis görünür kalır; kararda adı geçen yalnız BuildHUD'du. (2)
    Yolculukta tuşlar yutulur ama TopBar'ın hız düğmeleri tıklanabilir: duraklatmak kurucuyu ve asansörü dondurur,
    yolculuk yine süre sınırlarıyla (`EXIT_S`, sonra harita) biter. (3) Koşuyu bitiren imzada (Series A) yolculukta
    bekletilen kart atılır, ama `EventGate` onu hâlâ aktif kart sayar (`flush` yalnız kuyruğu temizler); sondan sonra
    onu çözecek yol yok ve `EventGate.has_pending()` true kalır.
  - Nerede: `scripts/main/main.gd` (`_leave_office`, `_return_to_office`, `_on_event_modal_requested`);
    `scripts/ui/office/office_travel.gd`; `scripts/ui/office/office_view.gd` (`set_veiled`, `_step_overlays`);
    `scripts/ui/components/window_layer.gd` (`set_veiled`); `scripts/ui/components/top_bar.gd`;
    `scripts/events/event_gate.gd`, `scripts/events/core/queue.gd` (`flush`).
  - Oyuncuya etkisi: (1) Yolculukta not yığını ve taşınma düğmesi görünmez. (2) Duraklatılan yolculuk takılmış gibi
    görünebilir. (3) Görünür etkisi bulunmadı.
  - Seçenekler: (1) A) Kalır. B) Yalnız BuildHUD gizlenir. (2) A) Kalır. B) Yolculuk TopBar tıklarını da keser. (3)
    A) Kalır. B) Koşuyu bitiren imzada aktif kart da temizlenir.
  - Kaynak: Erdem, 2026-09-27 kararı (kurucunun dış toplantıya gidişi geçiştir: çıkış, harita geçişi, oda); ch09 §4;
    GDD Zaman Modeli §8.5.

- **88 · Mesai modalında 12 ile 16 saat: üç amber işaret tavanı ve ortak `HR_HOURS_HOVER_LONG` cümlesi.**
  - Ne oluyor: Süre tavanı 16 saate çıktı (`HRConstants.WORK_HOURS_MAX`). Satırın moral yönü sekizi aşan her saat için
    bir amber işaret çizer, en fazla üç (`CHEVRON_MAX` 3): 11 ile 16 saat aynı üç işareti gösterir, oysa moral çarpanı
    1,5'ten 2,5'e çıkar (`HOUR_MORALE_MULT`). Hover cümlesi 11 saate kadar kademe başınadır (`HR_HOURS_HOVER_5` ile
    `HR_HOURS_HOVER_11`); 12 ile 16 saat tek ortak cümleyi paylaşır (`HR_HOURS_HOVER_LONG`, `HOVER_KEYED_MAX` 11): EN
    "Every hour past an eleven-hour day erodes morale faster still", TR "On bir saatlik günü aşan her saat morali daha
    da hızlı eritir". Ortak cümlenin iki dili de onay bekliyor; Ekip §8.5'in hover tablosu 5 ile 11 saati sayar.
  - Nerede: `scripts/modals/work_hours_modal.gd` (`CHEVRON_MAX`, `HOVER_KEYED_MAX`, `_morale_direction`);
    `localization/strings.csv` (`HR_HOURS_HOVER_LONG`); `scripts/systems/hr_constants.gd` (`HOUR_MORALE_MULT`).
  - Oyuncuya etkisi: 11 saatten sonra modal uzayan günün artan moral bedelini ne işaretle ne cümleyle ayırt ettirir.
  - Seçenekler: A) Kalır; üç işaret ve ortak cümle görsel kabulle onaylanır. B) İşaret merdiveni 12 ile 16 saat için
    uzar (ör. dördüncü basamak ya da ayrı renk) [K]. C) 12 ile 16 saatin her biri kendi hover cümlesini alır (önce EN,
    sonra TR).
  - Kaynak: Ekip GDD §7.1, §8.5; GUNCELLEMELER Ekip §8.5 maddesi; GDD Zaman Modeli §9; sahip kararı 2026-09-27/28
    (süre 5 ile 16 saat, çarpan 12 ile 16 saat için 1,7 ile 2,5).

- **93 · Görüşme panelinin [WORKING] değerleri ve tasarımdan sapmaları onay bekliyor.**
  - Ne oluyor: Risk sözcüğü eşikleri `UiTokens.RISK_SAFE_MIN` 0,62 ve `RISK_RISKY_MIN` 0,40; TUTUM'un "temkinli"
    sınırı `ATTITUDE_WARY_MIN` 25; satışta "ılık" sınırı `SalesMeetingAdapter.LUKEWARM_MIN` 40 (iğnenin bu aralıkta
    kural sınırı yok, VC'nin 40'ıyla aynı); satışta baş sallama eşiği cevabın tam ağırlığının yarısı (`NOD_SHARE`);
    oynatma süreleri (`MeetingPanel`: zar 0,8 sn, yazma hızı, aralar). Tasarımdan sapmalar: karşı taraf satırı serif
    16 (tasarımda 19, merdivende yok); balon köşesi 2 px (tasarımda 3/14); sonuç kartı krem kart ve renkli bant
    (tasarımda koyu kart); "ılık" sözcüğü başlık zemininde `ACCENT_DEEP` ile 3,9:1 (tasarımın rengi 4,1:1; ikisi de
    4,5'in altında). Sonuç kartı: masa dolu diye bekleyen teklif geçerlilik süresi yazmaz (süre masada yer açılınca
    başlar); kurucudan başka çalışan yokken ret kartı yalnız marka bedelini yazar (moral bedeli çalışanlara iner).
  - Nerede: `scripts/theme/ui_tokens.gd`; `scripts/ui/meeting/`.
  - Oyuncuya etkisi: Seçeneklerin risk sözcüğü, tutum sözcükleri, jestlerin sıklığı, panelin okunurluğu.
  - Seçenekler: A) Değerler ve sapmalar onaylanır. B) Sahip değiştirir.
  - Kaynak: görüşme akışı planı §6, §8, §10 (Erdem, 2026-09-29).

- **94 · Tek oda ve tek kule; silinen Frank kartı ve resimler.**
  - Ne oluyor: Bütün görüşmeler (satış, seed, Series A, term sheet masası) şehirdeki yatırımcı kulesinin en üst
    katındaki tek toplantı odasında geçer; harita hedefi her karşı taraf için bu kuledir. Frank'in
    `funding.meeting_day` kartı silindi, yerini fonun çağrısı aldı. Dört oda resmi ve dört fon portresi silindi.
  - Nerede: `scripts/ui/office/office_layout.gd` (`meet_hit`), `office_city.gd`, `office_travel.gd`;
    `art/office3d/meet.*`.
  - Oyuncuya etkisi: Her görüşme aynı odada; fonlar ve müşteriler yerle değil kişilerle ayrışır.
  - Seçenekler: A) Onaylanır. B) Fon ya da müşteri başına ayrı oda ve bina (varlık hattı işi).
  - Kaynak: görüşme akışı planı §0 varsayımları ve §10 (Erdem, 2026-09-29).

- **96 · Ürün rev 7 · Faz B ajan kararları onay bekliyor.**
  - Ne oluyor: Sprint döngüsü canlıya alınırken ajanlar PRD'nin ve sahip kararlarının (GUNCELLEMELER "Ürün rev 7")
    açık bıraktığı yerlerde karar verdi. Kod bu kararlarla çalışır; hiçbiri GUNCELLEMELER'in kuralı değildir.
    - Eşleme. (1) Yetenek mevcut hattır; alanlar: Çekirdek beş kimlik hattı, Onboarding & Erişim mobil hat ve gizli
      `line_hidden_self_serve`, Büyüme (B2C) ya da Entegrasyonlar (B2B) entegrasyon hattı, Güven & Ölçek güvenlik ve
      dayanıklılık, Gelir yalnız B2C'de sanal "Ücretli plan"; B2B'de Gelir yerine Müşteriler satırı
      (`data/product/sprint.json` `areas`). (2) Cila kartı üretilmez, katalogda cila adı yok; cila sayacını yalnız kayıt
      göçü doldurur (`sprint.json` `polish_*`). (3) Kademenin lisans bedeli kartın sprinti başlarken bir kez alınır,
      göçle gelen kart ödenmiş sayılır (`SprintSystem.start`, `card.paid`). (4) Faz → rol → Ekip alanı tablosu;
      uymayan kişi fazı %50 hızla yürütür, Test'e uyan kimse yoksa testsiz biten kart hatalıdır (`sprint.json`
      `roles`, `role_areas`, `no_role_speed`; `SprintSystem._fits`). (5) Sprint ekibi aktif kurucu ve ürün alanlı aktif
      çalışanlardır, Satış ve Müşteri Temsilcisi sayılmaz; beceri bandı rolün ana alanından okunur, ikincil alanla uyan
      kişi aynı puanla çalışır; kurucu moralsizdir, çarpanı ve rolleri sahip kararıdır (1,0; Ürün, Tasarım, Yazılım,
      Test; GUNCELLEMELER "Kalibrasyon turu · ürün rev 7") (`SprintSystem.team`, `_points`).
      Ekip sekmesindeki iş ataması (Ar-Ge dışında, Yapım sütunu dahil) ve Ekip §12.1'in iki işte 0,50 odak katsayısı
      (`HRConstants.focus_mult`) sprint puanına girmez: Yapım ve Destek'teki yazılımcı sprintte de masada da tam çıktı
      verir.
      (6) Kurucunun satış toplantısı ve VC hazırlığı sprint kapasitesini düşürmez: sprint puanı haftalıktır, Satış §5.0
      toplantı payı uygulanmaz; `sales_meeting_time_skip_founder_share` toplantı payını DESTEK masasında,
      `prep_bonus_and_capacity` kapasitenin değişmediğini ölçer. (7) Lider en yüksek Liderlik'li aktif çalışandır
      (eşitlikte küçük kimlik), yoksa kurucu (`product_model.gd`). (8) Sprint numarası saklanır, hafta günden türetilir:
      planlama başlangıcı geciktirebildiği için PRD §3.11'in "numara günden türetilir" yarısı uygulanmadı
      (`GameState.product.sprint`). (9) "!" bir yetenekte 3+ ticket ya da Güven'de altyapı aşımıdır
      (`SprintCatalog.area_alert`). (10) Müşteri arketipi `Customer.industry`'nin sektöründen okunur (Hevesli → Çekirdek,
      Fiyat-avcısı → Entegrasyonlar, Bürokratik → Güven, öbürü → Onboarding), sözleşme 52 hafta; zamanında çıkan talep
      yalnız "memnun" işaretlenir, Satış'a ya da memnuniyete yazılmaz; geç talep sessizce düşer
      (`sprint.json` `archetypes`, `request`; `SprintBridges.tick_requests`). (11) `product.paid_tier` kartı kalır,
      üç eski ürün kartı `cards/unwired/`'a taşındı.
    - Katalog ve lider. (12) Beklenti alanın ulaşabileceği en yüksek seviyeye kırpılır; Gelir'in tavanı 1'dir, yoksa
      Traction ve Series A'da hep Zayıf okunurdu (`SprintCatalog.expectation`). (13) Deneyim eksenli adımlara Ar-Ge
      `design_system`'in %20 efor indirimi uygulanır (`SprintCatalog.step_effort`). (14) Durum eşikleri sırayla okunur:
      0 Yok, beklentinin altı Zayıf, beklenti + 1'in altı Yeterli, üstü Güçlü; PRD'nin "±0,5 Yeterli"si "Zayıf"la
      çakışıyordu (`SprintCatalog.word_for`). (15) Rakibin kademesi taban tablo + her çıkış için +1; beklenti artışı
      birikimlidir (en çok +1); çip, cümle ve ses son 3 sprintin çıkışlarını okur (`SprintCatalog`, `rivals.json`).
      (16) Lider kuralının açılımı: zorunlu seçimler sırasıyla verilmiş sözlerin kartları (son tarihi yakın önde), en
      yakın son tarihli açık talep, B2C'de yayından sonra Ücretli plan, en zayıf alanın en iyi kartı ve acil
      düzeltmelerdir; MVP'den önce zorunlu alan Çekirdek'tir (yoksa Tasarım ★ kilitli Onboarding "en zayıf" sayılıp
      yalnız araştırma verirdi); küçük ekipte (sprint en çok `lead.small_team_cards` (2) K1 alıyorsa) tek açık kartı
      araştırma olan alan en zayıf sayılmaz, bütün alanlar öyleyse araştırma zorunlu kalır; en zayıf alan yuvarlanmamış
      seviyeyle seçilir, eşitlikte o alanın en iyi kartının etki/efor oranı yüksek olan; zorunlular %125'e, dolgu
      %100'e kadar girer, yük kartın kalan puanıdır; boş sprint tavanı aşan zorunlu kartı da alır (yalnız kurucu
      kapasite 4 iken K2 5 puandır); etkisi 0 olan kart dolguya girmez; kilitli, başka sütunda duran ve PM'in onaylı
      planındaki kart önerilmez (`SprintCatalog._suggest`, `_weakest`). Söz kartının ve Ücretli planın zorunluluğu
      sahip kararıdır (GUNCELLEMELER "Kalibrasyon turu · ürün rev 7"); sıra, küçük ekip eşiği ve eşitlik kuralı onay
      bekler. (17) Araştırmanın etki ağırlığı 0,5 → 0: araştırma yalnız zorunlu
      seçim olarak gelir, yoksa her K2'yi geçip sprintleri dolduruyordu (`sprint.json` `impact.research`).
      (18) Ücretli plan MVP'ye kadar kilitlidir ("Kilit: Canlı ürün ✗"); "+", "→" ve lider onu almaz
      (`SprintCatalog.gate_reason`). (19) Kalibrasyon girdisi, değişiklik değil: dört kişi ve kurucuda sprintin
      bitirdiği iş kapasitenin %58–79'u; açık her adım yapılınca otomatik sprintler yalnız araştırma taşır.
    - Motor. (20) Beta bir kanaldır, sonraki sprintte de açık kalır (`SprintSystem.plan_next`). (21) Hatalı kart
      yalnız sürüm çıkaran kapanışta ticket açar; MVP öncesi açmaz (`SprintSystem._close`). (22) Çıkan kademeye
      gerçekleşme damgası vurulmaz: eski kapı üstü bonus (+%8 / +%4) ve tasarım turu cilası yeni kademede yoktur
      (`SprintSystem._close`; `LineGates.above_gate_bonus` yalnız smoke'ta). (23) `refresh_on_publish`'in yeni kod
      terimi katalog eforunu okur (`ProductLines.effort_of`, DESTEK'in kalibre olduğu ölçek), sprint puanını değil.
      (24) Yalnız araştırma çıkan kapanış sürüm değildir. (25) Karar 2. haftanın tikinde istenir. Kâğıt sprint sürerken
      kapanınca kart haftanın kalanında o hafta boşta kalanlarla yürür; boşta kimse yoksa yürümez ve devreder
      (`SprintSystem._clear_decision`). (26) Durum eklemeleri: `sprint.status` "closed", `sprint.hours_mult`,
      `card.base`, `card.paid`, `product.worked`; sürüm kaydı etiket değil numara saklar (`release.number`, 0 sürüm
      değildir). (27) "→" kilitli kartı da reddeder (PRD yalnız "+"yı kilitler); sonraki
      sütundaki kart planlama dışında yalnız "çıkar"ı sunar.
    - Köprüler. (28) Talep yalnız kilitsiz adımı hedefler; alanında yapılabilir adım yoksa o pencerede talep doğmaz
      (`SprintBridges.tick_requests`). (29) Ticket dağıtım ağırlığı 1 + kullanım ağırlığıdır (çoğu K1'in kullanım
      ağırlığı 0). (30) Sürümde altyapı, doluluk `InfraSystem.OCCUPANCY_AMBER` (0,80) altında kalacak kadar (+1 birim)
      büyür, hiç küçülmez (`InfraSystem.units_for_occupancy`); MVP'de bulut ve `suggested_start_units` (`SprintBridges.on_mvp`, `on_release`). (31) Rakip
      çıkışı şeride yalnız canlı satır olarak düşer (`ticker_live_line`), arşive girmez; basın satırı "Biz" arşivine
      girer (`headline_added`). (32) Müşteriler satırı yalnız açık talebi olanı listeler; müşteri başına ticket sayısı
      yoktur, ticket yeteneğe bağlıdır (PRD C5 "Beykoz · 2 ticket").
    - Ekran. (33) Kırmızı ton hem "!" hem Zayıf alanda (`product_model.gd`). (34) Beta sürüm notu sonraki sürümün
      etiketini beta notuyla gösterir. (35) "Sprint otomatik başladı" çipi yalnız o sprint koşarken görünür
      (`top_bar.gd`). (36) Onaysız PM planı saklanmaz, her okumada bugünkü durumdan kurulur; yalnız onaylı plan saklanır
      (`SprintCatalog.pm_plans`). (37) "Düzenle" yalnız SONRAKİ sprintin sütununda: C4 fikstürü artık onu yalnız Sprint
      8'in altında çizer, mockup 8, 9 ve 10'un altında (`quarter_view.gd`). (38) Düzenle önerinin kartlarını onaysız
      olarak sonraki sütuna koyar ve PM kalan kapasiteye ek kart önerebilir; onaylanan sonraki sprint planı hemen
      sütuna geçer, ileri onaylı plan sprinti sonraki olunca geçer (`SprintSystem.approve`, `edit`, `plan_next`).
      (39) Hedef şeridi 10 kare, çizgi 5. karede; dolu kare = en çok 10, yuvarla(seviye / beklenti × 5)
      (`sprint.json` `pm.goal_squares`, `pm.goal_mark`). (40) Tür seçici yalnız oynanabilir türleri çizer; yol başına
      üç kilitli kart (ch03 §12.11, GUNCELLEMELER ch14 §2) çizilmez (`type_picker.gd`).
    - Kayıt. (41) v15 göçünde ilerleme birimi faz puanıdır; yapımın gizli hataları, tasarım eforu, beta ve iterasyon
      durumu taşınmaz; cila eşlemesi 1,0'ın üstü → 0,5, 1,11 ve üstü → 1,0; `bug_count_at_bugfix_start_*` de düşer;
      sürüm geçmişi `releases`'a sprintsiz (−1) geçer (`save_manager.gd` `_migrate_15`).
    - Silmeler. (42) `PROD_RIVAL_PASSED` ("{rival} seni geçti.") TR metniyle silindi; süpürme listesi onu sahip kararı
      diye işaretlemişti. (43) Frank anahtarları `PROD_MENTOR_LINE`, `PROD_TIP_BUGS`, `PROD_TIP_GOOD`, `PROD_TIP_WEAK`,
      `PROD_READY_TALK_FRANK` okuyucusuz kaldı; Frank külliyatı olduğu için silinmedi. (44) Probe preset'leri
      `full_run_weak`, `b2c_keep`, `b2b_risk_keep`, `b2b_slip_keep` silindi (düz alt-tür, sprint oynayamaz). (45) Konusu silinen yüzeyde kalan açık maddeler: 2'nin yapım lideri koltuğu
      (`set_build_lead` yok; sprint lideri yalnız öneri verir), 41 (yapım hızı yok), 43 (`FeatureBuild` yok), 46
      (Konsept'te boş ad; tür seçici adı boşken onaylamaz), 48 ve 51 (Ürün Detayı), 49 (Konsept onayı), 52 (fiyat
      paneli ve detay üçgeni), 54 (DESTEK bloğunun masa cümlesi), 65'in ürün kurma yarısı, 82'nin Ürün Detayı sayacı; 44 (`start_build`, `start_version_build`, `sum_efor`, `sum_cost` ve havuzun efor, maliyet ve boyut katkısı
      alanları silindi; havuzların öbür okuyucuları kalır), 45 (sayaç artık her açık sürümde sıfırlanır, devir 0'dır,
      bkz. (50); `mvp_bug_count_at_launch` yok), 47 (`delay_days` ve `apply_speed_bonus` silindi), 50
      (`FeatureLinesView` ve Konsept yok; açıklamalar yine hiçbir ekranda görünmüyor), 61'in Build Bar 2. ve 3. tur
      rengi (`BUILD_RAMP_*` silindi), 77'nin hata sprinti yarısı (`SPRINT_WEEKS`, `start_bug_sprint` silindi) ve
      `Chrome*` maddesinin alıntıladığı liste (CLAUDE.md §7'de Ürün sayfasının Frank şeridi artık yok).
    - Metin (TR/EN onay bekliyor). (46) Stage 1'in 74 `PRODUCT_*` içerik anahtarı (alan adları ve kısa adları, alan ×
      durum cümleleri, ticket, rakip ve aşım ekleri, kart adları, ticket başlıkları, araştırma ve rakip sesleri, rakip
      haber satırları, basın satırları, beklenen ve gerçekleşen cümleleri, lider cümleleri, otomatik başlama notu) ve
      Faz A ekran anahtarları; `PRODUCT_LOCK_LIVE`, `PRODUCT_GOAL_CORE`, `PRODUCT_GOAL_ONBOARDING`,
      `PRODUCT_GOAL_GROWTH`, `PRODUCT_GOAL_INTEGRATIONS`, `PRODUCT_GOAL_TRUST`, `PRODUCT_GOAL_REVENUE`,
      `PRODUCT_GOAL_PROGRESS`; çipler `EFFECT_SPRINT_EFFORT`, `EFFECT_SPRINT_PROGRESS`, `EFFECT_SPRINT_CARRY`,
      `EFFECT_SPRINT_HOURS`; `HR_TASK_ON_PRODUCT`. (47) Karar fikstürleri silindi; gerçek sprint karar kartlarının metni
      ve değerleri 97'dedir. (48) `rivals.json`'ın rakip seçimi, kademe tablosu ve çıkış takvimi. (49) "sprint",
      "ticket", "PM" ve "Onboarding" izinli ödünç listesinde yok; `docs/design/localization_glossary.md` satırı gerekir.
    - İnceleme turu. (50) Her açık sürüm canlı hata havuzunu sıfırlar (`mvp_live_bug_count` 0, `mvp_live_bug_progress`
      0,0): eski yayın sayacı BETA'nın devriyle başlıyordu, sprintte gizli hata devri yoktur, devir 0'dır; aşınma sonraki
      sürüme kadar yeniden biriktirir (45'in A seçeneğinin aşınmalı hâli; `SprintSystem._close`). Göç eski
      `mvp_bug_count_at_launch` bayrağını düşürür. (51) Kademesine başka bir kartla varılmış kart kapanışta kademe
      yazmaz, sinyal atmaz, yeni kod saymaz ve sonraki planlamada saklı kartlardan düşer (geç kalan talebin kartı ile
      aynı kademenin özellik kartı; `SprintSystem._close`, `plan_next`). (52) Düzeltme kartının ticket'ları kart
      koşmaya başlayana dek defterden okunur (koşunun erittikleri düşer, hattın yenileri eklenir); kapanış gerçekten
      kapananları sayar ve sürüm notuna onlar yazılır (`SprintSystem._refresh_fix_cards`, `SprintBridges.close_tickets`).
      (53) Kartın yükü kalan puanıdır ve kesirli toplanır; yuvarlama yalnız gösterimdedir (`ProductModel`), kapasite
      çubuğunun dilimleri ile "kullanılan" aynı sayıdır; kalan puan her fazın eksik payının toplamıdır, efor indirimi
      onu eksiye düşürmez (`SprintSystem.used`, `card_load`, `remaining`, `points_left`). (54) Etki satırının seviye geçişi kelimesini beklentiye göre taşır
      (`SprintCatalog.word_for`): öngörü, alan satırı ve sürüm notu aynı kelimeyi okur; yetenek geçişinin dilimleri de
      alanın beklentisiyle boyanır (`SprintCatalog.card_effect`, `forecast`).
  - Nerede: her maddenin parantezinde; ayrıntılı gerekçe ajan raporlarındadır.
  - Oyuncuya etkisi: Ürün sekmesinin bütün kuralları; özellikle lider önerisi (16, 17), MVP öncesi Ücretli plan (18),
    beta (20), hata ve ticket (21, 29, 50, 52), talepler (28), altyapı (30), ÇEYREK (36–39), tür seçici (40) ve karar
    kartı (25).
  - Seçenekler: Her madde için A) onaylanır, B) sahip değiştirir (değer ve kural `sprint.json`'da ya da parantezdeki
    yerde), C) metin maddelerinde sahip yeniden yazar.
  - Kaynak: sahip kararı 2026-10-01; `docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md`; GUNCELLEMELER "Ürün rev 7";
    CLAUDE.md §3 (tasarım sabiti ve TR metni onay bekler).

- **97 · Kalibrasyon turu · onay bekleyen değerler.**
  - Ne oluyor: Ürün rev 7 kalibrasyon turu (sahip kararları 2026-10-02, GUNCELLEMELER "Kalibrasyon turu · ürün
    rev 7") sabitleri değiştirdi ve desteye 27 kart ekledi. Sahip kararlarındaki ve onaylanan tur planındaki değerler
    kayıt içindir; plandan sapanlar (±%50 ayar penceresinin kenarındakiler **kenarda** diye işaretli) ve planda
    olmayanlar onay bekler. Biçim: eski → yeni, neden, ölçüm. Ölçüm: tohum 1–8, 120 hafta, `--lang=tr`; oynanan
    sekiz preset (`full_run`, `full_run_lean`, `full_run_vc_cautious`, `full_run_b2c`, `full_run_b2c_video`,
    `full_run_b2c_vc_cautious`, `full_run_b2c_vc_walk`, `full_run_b2c_k1`) ve 26 haftalık `b2c`, `b2c_neglect`
    fikstürleri; 80 koşu, her biri tek `PROBE END`, hatasız. Son ölçümde 18 kabul satırının 17'si geçer (tutmayan: 98).
    - Sprint (`data/product/sprint.json`). `founder_mult` 0,75 → 1,0 (karar 9): tek kurucunun sprinti 4 puan; MVP
      64/64 oynanan koşuda 7. tikte (taban 13). `founder_roles` [Ürün, Yazılım] → [Ürün, Tasarım, Yazılım, Test]
      (karar 2). `decision.rate` 0,25 → 0,35 (plan): ilk 6 haftada 3–4 ayrı karar haftası (taban 0); 0,175 kırık
      sözü düşürmedi. `decision.cards` fikstür → `product.sprint_two_paths`, `product.sprint_late`,
      `product.sprint_contractor` (plan). Yeni `hours_mult` {0,5–1,5}: `sprint_hours` çarpımla yığılır ve bu aralığa
      kenetlenir (plan). Yeni `lead.small_team_cards` 2: sprint en çok iki K1 alıyorsa tek açık kartı araştırma olan
      alan en zayıf sayılmaz (planda sayı yok).
    - Söz. `B2BConstants.PROMISE_RELOCK_WEEKS` yok → 8 (karar 8). Kırık söz koşu başına 0–3 (taban 6–23); aynı
      hesaba ikinci kırılma hiç yok, yani kilit ölçümde devreye girmedi.
    - B2C (`sales_system.gd`, `product_system.gd`; B2B akışı bu sabitleri okumaz, B2B koşuları değişmedi):
      - `WEAR_AUD_COEF` 0,00004 → 0,000002 (plan; 45'in ara kararı).
      - `CHURN_COEF` 0,0002 → 0,000036 (plan 0,00003, +%20): plan değerinde yalnız K1'li ürün $15K'yı aşıyordu;
        son değerde K1'li ürünün tepe MRR'ı 12.256–12.952 $.
      - `EROSION_THRESHOLD` 42 → 25 (plan 30, −%17): 30'da B2C Series A kapısı hiç açılmadı; 15'te K1'in rakibe
        göre kalitesi (16–18) eşiği aştı ve K1'li ürün 27–61K $'a çıktı.
      - `WOM_COEF` 0,005 → 0,0012 (plan 0,0008, +%50, **kenarda**): kapıyı 70–95. hafta penceresine çeken değer.
      - `WOM_SAT_GATE` 60 → 30 (plan 35, −%14): note_tool kapısı 8/8 pencerede.
      - `WOM_MULT_PIVOT` 50 → 15 (plan 30, −%50, **kenarda**): ölçülen MVP deneyimi ~14, boş destek masasında
        memnuniyet ~10; 30'da kapı açılmadı ve video 3 tohumun 2'sinde iflas etti.
      - `SATISFACTION_QUALITY_GATE` 40 → silindi (kural değişti; 34 kapandı).
      - `SATISFACTION_DRIFT_PER_DAY` yok → 1,5 (plan 1, +%50, **kenarda**): 1,0'da kapılar 92–102. haftada ya da
        hiç; 1,25'te MVP sonrası kitle eridi.
      - `SATISFACTION_BUG_PUSH_PER_DAY` yok → 1 (planın "itiş aynı kalır"ı; ilk iki ayar turunda itiş adıma bağlıydı
        ve 1,5 / gün çalıştı): 60. haftadan sonra memnuniyeti ≤ 10 olan hafta 401 → 376 / 688.
      - `VALUE_FEATURE_COEF` yayınlanan özellik başına 1,2 → açık hat başına 0,75 ve `VALUE_COMPLEXITY_COEF` 0,6 →
        kullanım ağırlığı puanı başına 0,375 (plan 0,6 / 0,3, +%25): planda video ürünü 7,66K $'da kaldı (tasarımcı
        basamağı 8K $), 0,6 / 0,3'te video kapısı 6/6 kapalı.
      - İlginin B2C kazanımına çarpanı kendi sabitini taşımaz.
    - Gider (`finance_system.gd`, `infra_system.gd`). `TOOLS_BASE_MONTHLY` {1: 1.500, 2: 1.500, 3: 5.500},
      `TOOLS_PER_EMPLOYEE_MONTHLY` {1: 150, 2: 300, 3: 500}, `SERVICE_PER_ACCOUNT_B2B` 45, `SERVICE_PER_SEAT_B2B` 8 ×
      yük, `SERVICE_PER_1K_USERS_B2C` 700 × yük: yok → plan değerleri. `STARTING_BURN_BREAKDOWN` "founder" 50 →
      "tools" 1.500 / 30 = 50 (karar 7); `BURN_IDS`'ten "founder" çıktı, "tools" ve "service" girdi.
      `ONBOARDING_MRR_MULT` yok → {1: 0, 2: **0,25**, 3: 3,0}: plan ve karar 6 Traction için 0,5 diyordu (−%50,
      **kenarda**; planın iki ayar turundan sonra yapılan üçüncü adım). Neden: 0,5'te seed 2 üç B2B preset'inde 41.
      günde iflas etti (3/24) ve `full_run_vc_cautious` s5'te marka < 15 payı 0,507 oldu. Mekanizma botun işe alım
      kapısıdır (kasa ≥ 6 × aylık net çıkış): 15. gün kasa 26.577 $ < 35.010 $, test uzmanı gelmedi, K2 acıları
      kilitlendi, 106 churn. 0,25'te test uzmanı 13. gün gelir, seed 23. gün, 29 churn; iflas 0/24, marka payı en çok
      0,132. 0,375 iflası kaldırır ama marka 0,507'de kalır. B2C koşuları iki değerde bayt-aynıdır. Bedeli: B2B
      Traction'da sonlu runway payı 0,13–0,29'dan 0,09–0,21'e iner (98). Kapı bir harness sezgisidir; onu değiştirip
      0,5'i korumak da seçenektir.
    - Tek seferlik etiketler (`FinanceSystem.ONE_TIME_LABELS`): planın dokuzu (incident, audit, retention,
      contractor, outreach, refunds, side_work, meetup, sponsor) ve planda olmayan üç (domain, user_tests,
      trade_fair).
    - `SalesSystem.growth_band()` çevrilmiş sözcük yerine bant id'si döndürür (melting, flat, steady, fast); tek
      okuyucusu `sales.growth_band` seam'idir, `world.b2c_creator_feature` bu sayede bağlandı ve okuyucusuz kalan
      `GROWTH_*` anahtarları silindi. Plan dışı; geri alınırsa ikisi birlikte.
    - Yeni kartlar (27, hepsi `demo`; Frank satırı yok; her kâğıt ve kesinti `expires_weeks`, `on_expire` ve not
      taşır):
      - MVP öncesi: `founder.meetup_talk` (kâğıt, tek sefer, 2. haftadan ve sprint koşarken; konuş −600 $, saat
        ×0,9 ve marka +4, yalnız sprint koşarken açık; dinle −200 $ ve marka +1), `founder.side_contract` (kâğıt,
        cooldown 10, 4. haftadan, runway < 24 hafta; al +3.000 $ ve saat ×0,6, yarım +1.200 $ ve ×0,85; ret satırı
        yok, süresi dolmak bedelsiz rettir), `founder.domain_name` (planda yok; kâğıt, tek sefer, 1. sprintten; al
        −900 $, bekle marka −2), `founder.friends_test` (planda yok; kâğıt, tek sefer, 2. sprintten; ağırla −300 $ ve
        marka +2, gönder marka +1 ve itibar −1); quiet `founder.savings_note` (cooldown 8), `founder.unseen_build`
        (6), `founder.company_of_one` (4; planda yok), `product.working_parts` (4; planda yok).
      - Sprint kararları (istek kartı, kâğıt, 1 hafta): `product.sprint_two_paths` (cooldown 2, kart eforu ≥ 5; yeni
        yol efor −3 ve ilerleme −2, bilinen yol bedelsiz), `product.sprint_late` (cooldown 2, kart ekibin hızıyla bu
        sprintte bitmeyecekse; taşı ya da **yetiştir: saat ×1,25 ve marka −2**; süresi dolarsa taşınır),
        `product.sprint_contractor` (cooldown 4, efor ≥ 5; dış kaynak −2.000 $ ve ilerleme +3, öğren efor +2; süresi
        dolarsa efor +1). Plan "yetiştir" için moral −4 ve ekipsiz kilit diyordu: kurucunun morali hiçbir yere
        işlemiyor, tek kurucuda satır açık olmalıydı. Efor ≥ 5 ve "geride" koşulları plandan farklıdır.
      - Ekip: quiet `team.first_weeks` (tek sefer kişi başı; eşlik moral +6 ve saat ×0,95, not moral −3), quiet
        `team.demo_day` (cooldown 8, 3+ kişi, sprintin 2. haftası; yap moral +3 ve saat ×0,95, atla moral −2),
        `team.outside_offer` (tek sefer kişi başı, 5+ kişi, 12+ hafta kıdem; prim −5.000 $ ve moral +10, konuş moral
        −6, bırak ayrılık ve itibar +1).
      - Ürün ve destek: `product.bug_pile` (cooldown 8, 12+ doğrulanmış hata ve masa dolu; şimdi düzelt
        `fix_run_start`, sonra itibar −1), `product.outage` (cooldown 26, Traction ve sonrası, kapasite aşımı ve 5+
        hesap ya da 2.000+ kitle; seferberlik saat ×0,6 ve marka −1, kredi −6.000 $, sessiz düzelt marka −4 ve itibar
        −2).
      - B2B: `customer.security_review` (tek sefer hesap başı, Traction ve sonrası, ölçek ≥ 3, 6+ hafta, kurumsal
        güven yok; denetim −8.000 $ ve memnuniyet +10, ekip saati ×0,8 ve +4, ret −12), `rival.funding_round`
        (Traction ve sonrası, Series A yaklaşımı ≥ 2 ya da faz 3; kampanya **−18.000 $** (plan −12.000, +%50,
        **kenarda**) ve marka +5, fonlara anlat saat ×0,9 ve itibar +2, bekle marka −3 ve 4 hafta sonra
        `rival.price_cut`; **cooldown 8**: plan tek sefer diyordu, karar 12 tekrar dedi ama değer vermedi),
        `rival.price_cut` (cooldown 16, 6+ hesap; indirim, söz, bekle memnuniyet −6 ve itibar +1), `world.trade_fair`
        (planda yok; Traction ve sonrası, kasa ≥ 200.000 $, **cooldown 10**; stant −30.000 $ ve iki aday, geç marka
        −2), `world.analyst_guide` (planda yok; faz 3'ün ilk iki haftası, kasa ≥ 120.000 $, tek sefer, **critical**;
        brifing −30.000 $ ve iki aday, uzak dur marka −2).
      - B2C: `customer.b2c_refunds` (cooldown 12, 8+ doğrulanmış hata ya da sıcak masa, 1.000+ kitle; iade −3.000 $
        ve memnuniyet +6, politika −5 ve marka −1), `product.b2c_floor_signal` (cooldown 8, yayından 4+ hafta, bir
        eksen tabana yakın; geri bildirim saat ×0,9 ve memnuniyet +3, not et −2), `product.b2c_floor_churn`
        (cooldown 8, taban aşıldı ve uyarısı görüldü; bırak kitle −%15, kredi −1.000 $ ve −%5, yol haritası marka −2,
        −%8 ve itibar +1), `world.b2c_creator_feature` (cooldown 26, büyüme bandı "fast", hiçbir taban aşılmamış;
        sponsorluk −2.500 $, kitle +%10 ve marka +2, geç marka −2), `world.app_placement` (planda yok; Traction ve
        sonrası; **−25.000 $, kasa ≥ 167.000 $, cooldown 10**; ilk yazılan −5.000 $ / 40.000 $ / 16'ydı: ×5 ve ×4,2,
        **ayar penceresinin dışında**; "maliyet tabanın %15'i" kuralı `trade_fair`'in oranıdır, kart %12,5 yazılmıştı;
        al kitle +%20, geç marka −2), `world.newsletter_slot` (planda yok; faz 3'ün ilk iki haftası, kasa ≥ 100.000 $,
        tek sefer, **critical**; al −25.000 $ ve kitle +%20, geç marka −2).
      - Faz 3 giriş kartları (`world.analyst_guide`, `world.newsletter_slot`): 56/56 faz 3 koşusunda faz 3'ün ilk
        tikinden sonraki tikte geldi; `analyst_guide` önceki günün kasasının %9,2–13,6'sı (14 brifing, 10 uzak dur),
        `newsletter_slot` %7,5–10,0 (32/32 alındı). `critical` etiketi Frank dışı iki harcama kartındadır: günlük
        havuz tik başına tek kart aldığı için etiketsiz kart penceresini kaçırdı (öncül `world.final_stretch_press`).
        Bedeli: `full_run_b2c_vc_walk` bootstrap'ı kartlar olmadan 8/8, kartlarla 5/8 (s3'te 84. günde kapanan ay
        `newsletter_slot` −25K ve `funding_round` −18K ile eksiye düştü, kâr serisi 9 → 0).
      - Değişen kartlar: `customer.retention`, `cs_escalation`, `request_feature`, `request_complaint` ve
        `rival.price_cut`'ın söz satırları `musteri.broke_promise == false` (gerekçe `B2B_LOCK_PROMISE_BROKEN`) ve
        `musteri.promise_fits` (gerekçe `SALES_LOCK_PROMISE_NO_ROOM`) ister.
    - Ajan kararları (kod bu yorumlarla çalışır): (a) B2C memnuniyeti tik başına kenetle(hedef − memnuniyet, ±adım) −
      itiş kadar değişir (adım 10, itiş 7): birikim varken tırmanış durur, hedefin üstünden hedef − 7'ye iner. (b)
      Sözün beta payı: adımın kartı betada bekliyorsa bir sprint daha; talep pay almaz. Sürümde açık bulunan sprint
      sözü hep tutulmuş sayılır (geç olan aynı tikte zaten kırılmıştır). (c) Sığma: yalnız planlanabilir sprinte
      borçlu sözler sayılır, bir adım kaç hesaba söz verilmiş olursa olsun bir kez; koşan sprintte boş yer = kapasite /
      saat çarpanı − sonraki sütunun kalan puanı. (d) Servis maliyeti B2C'de bütün kitleyi okur, ödeyenleri değil;
      onboarding katı imzadan sonraki 4 tikte işler. (e) Artı `add_cash` tek seferlik gelirdir, ay gelirine ve kâr
      serisine yazılmaz (yan iş +3.000 $). (f) Lint etiketi bütün `ONE_TIME_LABELS`'a karşı denetler; kart "hire" gibi
      bir sistem etiketini de geçirebilir. (g) Planın `rival.segment_leader` seam'i `rival.leader` adını aldı: lint'in
      gerçek marka listesi "segment"i kart gövdesinde reddediyor. (h) `product.b2c_floor_churn`'ün kaybı kitle
      yüzdesidir (`churn_customer`'ın çipi "Bir müşteri kaybedildi" yazardı). (i) Faz 3 girişi
      `funding.gate_series_a`'nın son çözümünden geçen haftayla okunur; motor faz değişiminde mandal sıfırlamadığı
      için `trade_fair` ve `app_placement` yeniden açılmadı, iki yeni kart yazıldı.
    - Metin (TR/EN onay bekliyor): 27 yeni kartın metni (`EV_FOUNDER_*`, `EV_PRODUCT_*`, `EV_TEAM_*`, `EV_RIVAL_*`,
      `EV_WORLD_*`, `EV_CUSTOMER_*`, `EV_LOCK_NO_SPRINT`; seam okuyan gövdeler satır içi), `FIN_BURN_TOOLS`,
      `FIN_BURN_SERVICE`, 12 `FIN_ONETIME_*`, `HR_ROW_TOOLS`, `PRODUCT_FX_PROMISE`, `PRODUCT_FX_PROMISE_KEPT`,
      `PRODUCT_PROMISED`, `SALES_PROMISE_OPEN_SPRINT`, `B2B_LOCK_PROMISE_BROKEN`, `SALES_LOCK_PROMISE_NO_ROOM`,
      `EFFECT_FIX_RUN_STARTS`; yeniden yazılan `EV_PRODUCT_SPRINT_LATE_CRUNCH`; silinen `FIN_BURN_FOUNDER` ve
      `GROWTH_*`.
  - Nerede: her maddenin parantezinde; ölçüm tabloları ve iz kayıtları kalibrasyon turunun raporundadır.
  - Oyuncuya etkisi: Erken oyunun temposu (MVP 7. tik, ilk 6 haftada 3–4 karar), sözlerin kırılması, B2C'nin
    büyümesi ve iki sonu, geç oyunun gider baskısı ve faz 3'ün harcama kararları.
  - Seçenekler: Her madde için A) onaylanır, B) sahip değiştirir (değer parantezdeki yerde), C) metin maddelerinde
    sahip yeniden yazar.
  - Kaynak: sahip kararı 2026-10-02 (1–12); GUNCELLEMELER "Kalibrasyon turu · ürün rev 7"; CLAUDE.md §3.

- **98 · B2B Traction'da sonlu runway hedefi tutmadı.**
  - Ne oluyor: Turun kabul ölçütü Traction haftalarının en az %40'ında sonlu runway istiyordu (ch01 §5: her evre
    runway'i yeniden daraltır). Ölçülen pay 0,09–0,21 (`full_run` 0,10–0,21, `full_run_lean` 0,09–0,20; taban
    0,05–0,11). Gider kalemleri payı yükseltti ama hedefe varmadı; onboarding düzeltmesi (97) payı 0,13–0,29'dan
    düşürdü. Traction gider kaldıraçlarını pencerenin üst ucuna çeken her ölçülen ayar (koltuk 12, hesap 67,
    Traction onboarding katı 0,75, araç değerleri en üstte) en az bir tohumu seed'den önce iflas ettirdi (iflas
    30.–35. gün; hayatta kalanlarda pay %32–54). Mekanizma: Frank'in çeki (~10. gün) ile seed (17.–23. gün) arası ek
    gideri taşımıyor. Gider artınca bot işe almayı keser, gece churn'ü MRR'ı seed eşiğinin (20K $) altında tutar
    (`SeedRoundSystem.daily_tick` MRR'ı gece churn'ünden sonra okur), seed gelmez.
  - Nerede: `scripts/systems/infra_system.gd` (`SERVICE_*`, `ONBOARDING_MRR_MULT`); `finance_system.gd` (`TOOLS_*`);
    `seed_round_system.gd` (kapı); `scripts/debug/run_probe.gd` (işe alım kapısı).
  - Oyuncuya etkisi: Traction'da runway çoğu hafta sonsuz okunur; evre runway'i yeniden daraltmaz.
  - Seçenekler: A) Ölçüt yumuşar ya da kalkar: Traction'ın baskısı seed öncesindeki dar penceredir. B) Seed'den sonra
    başlayan Traction baskısı (seed imzasından sonra devreye giren gider ya da nakit maliyetli kartlar). C) Seed
    kapısı değişir (eşik ya da okuma anı), kaldıraçlar yeniden ölçülür. D) Botun işe alım kapısı (harness) değişir,
    yeniden ölçülür.
  - Kaynak: ch01 §5; kalibrasyon turu ölçümü (sahip kararı 2026-10-02).

- **99 · Geç B2C memnuniyeti 10'a çakılı; doğrulanmış hata birikimi büyüyor.**
  - Ne oluyor: Büyüyen 16 B2C koşusunda (`full_run_b2c`, `full_run_b2c_video`) 60. haftadan sonraki 688 haftanın
    376'sında memnuniyet ≤ 10 (koşu başına 43 haftanın 15–34'ü). Hedef (deneyim) sonda 54 iken memnuniyet 16 koşunun
    15'inde 10'da biter, dip 3'tür. Doğrulanmış hata 60. haftadan sonra 248–895'e çıkar, sonda 182–686'dır. Kapıya
    ağızdan ağıza değil taban büyüme ve ücretli kartlarla varılır. `full_run_b2c_k1` etkilenmez (memnuniyet ≥ 25,
    doğrulanmış ≤ 12). Neden: düzeltme tarafı geç oyunda doyuyor. Bot düzeltme koşusuna tek geliştirici ödünç
    veriyor; masadaki kurucu düzeltir ama doğrulamaz (probe kurucusunun Müşteri İlişkileri'si 0). Sprint puanı işi ve
    odak payını okumadığı için (96 (5)) düzeltmeyi genişletmek sprintten bedava ödünç olurdu; bot genişletilmedi.
  - Nerede: `scripts/systems/sales_system.gd` (`_tick_satisfaction`, `SATISFACTION_*`); `support_system.gd`;
    `sprint_system.gd` (`team`, `_points`); `scripts/debug/run_probe.gd` (düzeltme koşusu, masa).
  - Oyuncuya etkisi: Büyük B2C ürününde memnuniyet dipte kalır; ağızdan ağıza büyüme geç oyunda çalışmaz.
  - Seçenekler: A) Kabul: B2C geç oyununun baskısı budur. B) Destek ve düzeltme sabitleri yeniden ayarlanır. C) Sprint
    puanı işi ve odağı okur (96 (5)), sonra bot düzeltmeyi genişletir ve yeniden ölçülür. D) Memnuniyetin itişi
    yeniden ayarlanır.
  - Kaynak: Ürün GDD (ch03) §8–§9; kalibrasyon turu ölçümü.

- **100 · Faz 3'te iki kararsız hafta üst üste gelebiliyor.**
  - Ne oluyor: Karar 12'nin ölçütü (faz 3'te her 2 haftada en az 1 karar ve kasanın en az %5'ini harcatan en az 1
    teklif) 56/56 faz 3 koşusunda tutar; oran en az 1,24 / 2 hafta. Daha sıkı okuma ("iki kararsız faz 3 haftası üst
    üste gelmez") 23/56 koşuda tutar, en az 5 hafta faz 3'te kalan koşularda 9/41. Uzun koşularda en uzun boşluğun
    ortancası 2 hafta, en kötüsü 5 (`full_run` s2, `full_run_b2c_vc_walk` s5). Series A kapı kartı sayılmasa da sonuç
    aynı. Karar: iki ya da daha çok seçenekli, quiet olmayan kart.
  - Nerede: faz 3 kartları (`rival.funding_round` cooldown 8, `world.trade_fair` ve `world.app_placement` cooldown 10,
    giriş kartları tek sefer); `scripts/events/present/tempo.gd` (kotalar).
  - Oyuncuya etkisi: Uzun bir faz 3'te art arda birkaç hafta karar gelmeyebilir.
  - Seçenekler: A) Ölçüt "2 haftada en az 1 karar" olarak kalır. B) Faz 3'e içerik eklenir (yeni ya da daha kısa
    cooldown'lı kart). C) Motor: faz 3'te taban ya da kategori kotası.
  - Kaynak: sahip kararı 2026-10-02 (12); kalibrasyon turu ölçümü.

- **102 · `meeting_during_kepenk` fikstürünün öncülü değişti: faz 3'te taze büyük hesap.**
  - Ne oluyor: Ortak smoke fikstürü `_seed_b2b_series_a` kapıya 121K $ MRR'lı tek bir hesap imzalatır. Faz 3'ün
    onboarding katı (3×) bu hesaba ilk 4 haftasında ayda ~363K $ servis maliyeti yükler; kasa erir, runway 1 ayın
    altına iner ve toplantının "temiz" kolu da ince runway cezasını (`CONV_THIN_RUNWAY_PENALTY` −8) yer: vaka 32 − 25
    = 7 okuyup düştü (beklenen 15). Fikstür artık hesabın onboarding penceresini kapatır (kapıda yerleşik defter,
    taze imza değil) ve vaka geçer. Oyunda Series A Hunt'ta tek bir büyük imza ilk ayında MRR'ının üç katı servis
    maliyeti taşır.
  - Nerede: `scripts/debug/endgame_smoke.gd` (`_seed_b2b_series_a`); `scripts/systems/infra_system.gd`
    (`ONBOARDING_MRR_MULT`, `monthly_service`).
  - Oyuncuya etkisi: Series A Hunt'ta balina imzası ilk 4 haftada nakdi sert düşürür; o arada VC görüşmesine giren
    oyuncu ince runway cezası alabilir.
  - Seçenekler: A) Kabul; fikstürün yeni öncülü kalır. B) Faz 3 katı hesap başına tavanlanır ya da imzanın
    büyüklüğüyle azalır (karar 6'nın 3×'i). C) Fikstür taze imzaya döner, vaka cezayı bekler.
  - Kaynak: sahip kararı 2026-10-02 (6); smoke `meeting_during_kepenk`.

- **104 · Hız merdiveni dört kat hızlandı: bağlı hedefler ve hızlı basamakların yan etkileri.**
  - Ne oluyor: Sahip kararıyla `TimeModel.SECONDS_PER_HOUR` [0.0, 2.5, 1.25, 2.5 / 3.0, 0.625]'tir; varsayılan
    mesaide hafta 1×'te 22,5, 2×'te 11,25, 3×'te 7,5, 4×'te 5,625 sn sürer (eski 4× yeni 1×'tir). Kararın açtığı
    sorular ve işi yapan ajanın verdiği kararlar:
    (1) Demo hedefi 60–90 dk [WORKING] (CLAUDE.md §1; GUNCELLEMELER ch01 §1, ch14 §1) eskiden 1×'te 40–60 haftaya
    denk geliyordu. Bugün 60–90 dk saf 1× saatiyle 160–240 hafta eder, 104 haftalık tavanın üstü; 104 haftalık koşu
    1×'te, duraklama ve toplantı hariç, yaklaşık 39 dk.
    (2) Olay temposu çapası (motor md §13.7; `EvTuning.ANCHOR_MINUTES_PER_DECISION` 2,5,
    `ANCHOR_MAX_INTERRUPTS_PER_3_MIN` 3): 3 gerçek dakika artık 1×'te 8, 4×'te 32 haftadır; tik tavanı (2) dolarsa
    1×'te 16 kesinti eder. Harness (`--event-harness=random:seeds=10:weeks=104`, 4 farklı kart ateşlendi): 1×'te 1,4
    dakikada bir karar; en yoğun 3 dakika 1×'te 4, 2×'te 5, 3×'te 7, 4×'te 9 kesinti; en uzun sessizlik 1×'te 68,
    4×'te 17 sn.
    (3) Kapandı (sahip kararı 2026-10-09, eski 90 sn haftanın ritmi, Software Inc. modeli): `k` saatin hızıyla
    doğrusaldır, ambiyans saniyesi her hızda 6 oyun dakikasıdır; GUNCELLEMELER ch12 §6, GDD Zaman Modeli §7.4.
    (4) Ev'de kurucu (ajan kararı): yatağa gidiş ve dönüş yürüyüşleri pencerenin yarısından fazlasını alıyorsa
    08:00'den masasındadır, yatakta görünmez ve gece kararmasında kesilir (personelin `MIN_PRESENCE` kuralı). Ambiyans
    saniyesi her hızda 6 oyun dakikası olduğundan kural hızdan bağımsızdır: Ev'in yatak yürüyüşü (zincirler boyunca
    yaklaşık 14,5 m, kalkıp yatmayla) yaklaşık 60 oyun dakikasıdır ve kural ancak 4 saatten kısa bir pencerede
    devreye girer, varsayılan 09:00–17:00'de girmez. `--day-shot=home:4`'te kurucu 09:17'ye kadar uyur, 09:40'ta
    masasındadır, 16:31'de yatağa yürür, 16:54'te yataktadır.
    (5) Kapandı (sahip kararı 2026-10-10, saati yalnız oyuncu başlatır): istek anında kurucu ofiste görünürse saat
    durur; Ertele kartı kapatır, saati başlatmaz, telefon saat duruk çalmaya devam eder; GDD Zaman Modeli §8.5.
    (6) İş hanında kurucunun çıkış anı (`bitiş − EXIT_SLACK × yürüyüş`) 12 oyun dk/ambiyans sn'lik eski tempoyla
    14:00'ten önceydi; giriş 15:00'e kadar açık olduğu hâlde bu arada istenen satış görüşmesinin telefonu görünmüyor ve
    kesimde sessizce düşüyordu. 6 dk/as ile çıkış anı yaklaşık 16:00'dır (köşe odaya dönüş yürüyüşü `--travel-shot`'ta
    1×'te yaklaşık 1,75 sn, 7 ambiyans sn): `--day-shot=ishani:4`'te kurucu 15:17'de mutfakta, 16:48'de masasındadır,
    15:00 kesiminden önce çıkmaz. Akşam kapıdan da çıkmaz: bitişi günün bitişine eşitken çıkış anında kapı sırası
    (`_head_out`) günün bitişini geçer, kurucu masasında kalır ve gece kararmasında kesilir (aynı karelerde 16:48'de
    ofiste yalnız kurucu kalmıştır, masasındadır).
    (7) 63. maddenin kapanış gerekçesi: 8 saatlik mesai bugün 1×'te 20, 4×'te 5 sn. 78'deki 90 saniyelik hafta eski
    tempoyla yazılıdır; 91'in ambiyans değerleri, ambiyans saniyesi yeniden her hızda 6 oyun dakikası olduğundan
    yazıldıkları oyun dakikasını tutar.
    (8) Haftalık otomatik kayıt 3×'te 10 sn tabanı (`AUTOSAVE_MIN_REAL_SECONDS`) yüzünden iki haftada bir iner.
    (9) Sahibin hedefi (2026-10-09) hızlı basamağın 1×'in gerçekten o katı olmasıdır; çözüm ajanındır ve onay bekler (91):
    gece kesmesinin kararması (`CUT_FADE_S`) hızla kısalır, GDD Zaman Modeli §7.3–7.4. Ölçüm (ikinci hafta, 2026-10-10): `--tempo-probe=1:shell` haftası 22,48 sn (−%0,1), `=3:shell` 7,48 ve 7,47 sn
    (−%0,2, −%0,4); 3× 1×'in 3,00 ve 3,01 katı.
    (10) Depo loft'un feribotu ve suyu oyun dakikasıyla akar: 4×'te feribot ekranı yaklaşık 4,6 sn'de geçer. B2C
    ücretli koşuda Finans sayfası her MRR değişiminde (her oyun saati) baştan kurulur, gizli Yatırım sayfası da:
    4×'te saniyede 1,6 kez; maliyeti ölçülmedi.
  - Nerede: `scripts/systems/time_model.gd`; `scripts/ui/office/office_people.gd` (`_wanted`, `_head_out`),
    `scripts/systems/office_constants.gd`; `scripts/main/main.gd` (`_on_pitch_requested`, `_on_call_postponed`);
    `scripts/events/core/tuning.gd`; `scripts/autoload/save_manager.gd`; `scripts/ui/office/office_lighting.gd`;
    `scripts/tabs/finance/finance_ozet_view.gd`, `scripts/tabs/hunt_tab.gd`.
  - Oyuncuya etkisi: Koşu dört kat kısadır ve kararlar gerçek zamanda dört kat sık gelir.
  - Seçenekler: (1) A) dakika hedefi kalır, duraklama ve karar süresi de sayılır; B) dakika hedefi kısalır; C) tavan
    uzar. (2) A) çapa yeni tempoya göre yeniden yazılır; B) tik tavanı düşer; C) kalır, yalnız raporlanır. (4)
    A) kabul; B) geri alınır. (6) A) kabul; B) kurucunun çıkış yürüyüşü görüşme kesiminden önce başlamaz; C) kurucu
    ofiste değilken görüşme doğrudan açılır. (8) A) kabul; B) taban düşer. (10) A) kabul; B) feribot ve su gerçek
    saniyeye bağlanır; C) Finans ve Yatırım sayfaları kare başına bir kez ve yalnız görünürken kurulur.
  - Kaynak: sahip kararı 2026-10-09 ("4x kaç saniye sürüyorsa onu 1x yapalım. Gerçekten 4x'i de 4 kat
    hızlandıralım."); GDD Zaman Modeli §2.

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
  en az bir rakip hamlesi ve bir olay (incident) istiyor. Canlı destede Frank'inkiler dahil 58 demo kartı var;
  kalibrasyon turu 27 kart ekledi (97): Y3 `team.demo_day` ve `team.outside_offer`, Y4 `team.first_weeks`, Y7
  `product.bug_pile`, Y8 `rival.funding_round` ve `rival.price_cut`, Y9 `product.outage`. Altı `quiet` kart olay motoru
  GDD §13.6'nın sessiz tabanını doldurur. Açık kalan: ch11'in dokuz arkı. Kaynak: EVENT_REVISION §9.

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
    `TERM_FRANK_*`, `TERM_RESULT_*`, `FIN_MENTOR_QUOTE`.
  - Dünya, olay, son: `NEWS_S_*`, `NEWS_RIVAL_{UP,DOWN}_*`, `MONTH_FRANK_*`, `EFFECT_*`, `MENTOR_INTRO_BODY`,
    `END_{SA,ACQ,BK,BC,VC,BS,RF,GENERIC}*`, `END_META_*`, `END_EV_SHUTTER_*`, `END_EV_ACQ_{TITLE,ACCEPT,DECLINE}`.
  Kayıttaki bekletilen Frank metni (`PROD_ITER_CEILING_NOTE`, üç `PITCH_*`, dört `VC_EV_*` ve `END_EV_PIVOT_*` satırları)
  aşağıdaki Frank belgeleri maddesinde. Yalnız smoke'un okuduğu kayıt aileleri (`COMPANY_BG_*`, `PROD_FEAT_*_VOICE`,
  `PROD_TYPE_*_{BET,PITCH}`, `B2B_PAIN_*`) oyunda okunmuyor. Kayıt dışında da yalnız smoke'un okuduğu satırlar var: B2B'ye özgü `SECTOR_TEXTILE`, fikstür `SECTOR_TESTING` ve `SECTOR_FALLBACK`. Oyunda `SECTOR_` yalnız `ProductCatalog.type_sector_labels` ile ürün tiplerinin sektörlerinden kurulur; bu iki id hiçbir ürün tipinde yok ve o yolun yedek anahtarı yok. Kayıttaki referanssız emekli anahtarlar listede yok; temizliğin
  CSV süpürmesi onları siler: eski B2B pitch'inin `PITCH_{S0..S3,CHECK,RESULT,INNER,BAND,NEED,REAL_NEED}_*` satırları (üç
  Frank satırı hariç; canlı `PITCH_DIFF_*` kayıtta değil), `B2B_EV_COMPLAINT_HARD`, `B2B_EV_REQUEST_BODY_PLAIN`,
  `VC_EV_OFFER_EXPIRING_BODY`, `END_EV_ACQ_BODY`.
  Açık: EN geçişi yapılsın mı. Kaynak: localization_draft_en.

- **Frank belgeleri (bu dosyalar kalır).** `docs/writing/FRANK_ORPHANS.md`: v6'da olmayan Frank satırları, satır satır
  sahip kararı bekliyor. `docs/writing/FRANK_UNWIRED.md` §4: D12. Seed kapısı: `funding.seed_door` kartı
  `SEED_DOOR_TITLE`, `SEED_DOOR_BODY` ve `SEED_DOOR_GO` metniyle 7946ff3'ten beri canlı; Frank v6 yüzey 12 bu kartı
  "yeniden tasarlanacak" diye metinsiz bırakıyor, metnin sahip onayı belirsiz. FRANK_UNWIRED §1, §5 ve §6 bayat: seed
  kapısının metni var, `goto_tab` fiili yedi kartta çalışıyor, `FIN_SUBTAB_INVESTMENT` EN'i "Funding"; belge güncellenmeli.
  `docs/writing/FRANK_VOICE_INVENTORY.md` kodu satır numarasıyla anıyor ve atıflar kaymış: `time_manager.gd:45`
  INITIAL_HOUR (bugün 25. satır), `time_manager.gd:115-143`, `:245-279` (günlük yuva sırası hâlâ artık olmayan
  EventManager'ı sayıyor; günlük dağıtıcı `TimeManager._dispatch_daily_tick`), `:344-355` ve `:402-404` (dosya 227
  satır), `event_manager.gd:804-816` (dosya yok). Belgede yaklaşık 90 dosya:satır atfı var; sahip bu gerçekleri
  tazeler ya da satır numaralarını sembol adına çevirir. Kodun okumadığı ama karar gelene kadar CSV'de kalan Frank
  metni: `VC_EV_DEAL_TITLE`, `DEAL_PROMPT_LINE`, `DEAL_PROMPT_SIT`, `DEAL_PROMPT_VALIDITY`, `DEAL_PROMPT_DEFER`,
  `VC_EV_SKIP_MEETING`, `VC_EV_ACK`, `END_EV_PIVOT_TITLE`, `END_EV_PIVOT_BODY`, `END_EV_PIVOT_ACCEPT`,
  `END_EV_PIVOT_DECLINE`, `PITCH_S0_NPC`, `PITCH_S0_INNER`, `PITCH_INNER_CLOSED`, `PROD_SHIP_VERSION_BODY`,
  `PROD_SHIP_FIRST_READY`, `PROD_SHIP_FIRST_BODY`, `PROD_DESIGN_CEILING_NOTE`, `PROD_DESIGN_DECISION_BODY`,
  `PROD_ITER_CEILING_NOTE`.

- **66 · `OFFICE_REQ_ANGEL`'ın TR metni onay bekliyor.**
  - Ne oluyor: İş hanının ilk şartı Frank'in çekidir (`GameState.run_angel_amount > 0`); çek seed değildir, tek çek,
    tur değil. Harita kartındaki şart satırı `OFFICE_REQ_ANGEL` kapıya uyar: EN "Frank's cheque taken", TR "Frank'in
    çeki alındı". TR satır sahibin onayından geçmedi.
  - Nerede: `localization/strings.csv` (`OFFICE_REQ_ANGEL`); `scripts/systems/office_system.gd`
    (`requirement_state`, "angel"); `scripts/ui/office/office_map_card.gd`.
  - Oyuncuya etkisi: TR ekranda onaysız bir satır.
  - Seçenekler: A) TR onaylanır. B) Sahip TR'yi yeniden yazar.
  - Kaynak: ofis tasarımının şart metni; CLAUDE.md §1, §5.

- **68 · Yeniden adlandırılan üç anahtarın TR metninde oyuncuya görünen tire.**
  - Ne oluyor: `DESK_PAPER_GATE_TITLE` (TR "Faz kapısı açık — karar bekliyor"), `DESK_PAPER_SHEET_TITLE` (TR "Yatırım
    teklifi masada — son {days} gün") ve `PERSONAL_MS_SHIP_NOTE` (TR "Ürün raflara çıktı — artık dünya da
    oynuyor.") metinlerini aynen taşıyor. EN tiresiz yeniden yazıldı ("Phase gate open: decision pending", "Offer on
    the table, {days} days left", "The product hit the shelves; now the world plays too."); TR sahibin metni, onay
    bekliyor.
  - Nerede: `localization/strings.csv`; okuyanlar `scripts/ui/components/desk_papers.gd` ve `scripts/tabs/personal_tab.gd`
    (`_milestones`).
  - Oyuncuya etkisi: TR'de not yığını, Olaylar sayfası ve Kişisel'in Kilometre Taşları kartı ekranda tire gösteriyor
    (ch01 §9).
  - Seçenekler: A) TR ayrı yerelleştirme adımında yeniden yazılır (onay bekler). B) Tire noktalama sayılır (51.
    maddenin A seçeneğiyle birlikte).
  - Kaynak: ch01 §9; CLAUDE.md §5.

- **69 · Frank'in taşınma kartı taslak; onaya kadar demo destesinde değil.**
  - Ne oluyor: `funding.frank_office_move` Frank'in çekinden sonra, şirket hâlâ Ev'deyken bir kez gelir
    (`investor.angel_taken`, `office.current == home`); tek seçenekli bir beat. TR ve EN metni ajan taslağıdır; kart
    onaya kadar `version_scope: ea`'da, demo destesine girmiyor. EA ve tam sürüm onu hâlâ taşıyor.
  - Nerede: `data/events/cards/funding/frank_office_move.json` (`version_scope`, `text.tr`, `text.en`).
  - Oyuncuya etkisi: Demoda ilk taşınmayı ofis düğmesinin nabzı tek başına gösteriyor.
  - Seçenekler: A) Sahip metni onaylar ya da yeniden yazar; kart `demo`'ya döner. B) Kart silinir; nabız yeter.
  - Kaynak: CLAUDE.md §3 (Frank'in külliyatı Erdem'indir; yeni Frank satırı onaysız ekrana çıkmaz); Erdem, 2026-09-27
    görev kararı (ilk taşınmayı Frank'in kartı önerir).

- **86 · Haftalık modelin metin soruları.**
  - Ne oluyor: Haftaya dönen oyuncu metinleri (önce EN, sonra TR) onay bekliyor; commit "TR/EN onay bekliyor" diye
    işaretlidir, Frank satırlarının yeni hâli taslaktır. Onayın ötesinde açık kalan ifade soruları: (1) `END_DATE_LINE`
    EN'de "ISSUE" yerine sözlüğün "No." karşılığı önerildi; `ENDING_RUN_META` TR'de "BU RUN" yerine "BU OYUN". (2)
    `HR_SEARCHING` anlam değiştirdi: aramanın geçen gününü değil, dosyaların gelmesine kalan süreyi sayar (bir
    haftalık aramada geçen hafta hep 0 olurdu). (3) `HR_NEWS_ON_LEAVE_MONTH` ("bu ay izinde") yerine `{n}` ve tekil
    ikiz taşıyan `HR_NEWS_ON_LEAVE` geldi; önerilen TR "{name} {n} hafta izinde" (yaz izni 2 haftadır). Frank
    satırlarının haftalık taslakları 90. maddededir.
  - Nerede: `localization/strings.csv`; okuyanlar `scripts/systems/endings_copy.gd`, `scripts/modals/ending_scene.gd`,
    `scripts/tabs/hr_tab.gd`, `scripts/systems/hr_morale_system.gd`.
  - Oyuncuya etkisi: Onaysız metin ekranda.
  - Seçenekler: A) Öneri onaylanır. B) Sahip metni yeniden yazar.
  - Kaynak: CLAUDE.md §3, §5; `docs/design/localization_glossary.md` (SAYI {n} → No. {n}); GDD Zaman Modeli §5.

- **89 · Okuyucusu olmayan üç gün sözlü anahtar: silinsin mi, bağlansın mı.**
  - Ne oluyor: `DEAL_PROMPT_VALIDITY` (TR "Geçerlilik: {days} gün", EN "Valid for {days} days"), `VC_EV_SKIP_MEETING`
    (TR "Bugün değil (randevu yanar)", EN "Not today (the meeting is forfeit)") ve `VC_EV_OFFER_EXPIRING_BODY`
    (Frank'in "{days} gün içinde yanıt vermeliyiz" / "inside {days} days" satırı) hâlâ gün ya da "bugün" der. Haftalık
    modelde tike bağlı metin gün saymaz ve "bugün" demez (GDD Zaman Modeli §5). Üçünü de kod, sahne ya da kart okumadığı
    için haftalık metin turu onlara dokunmadı. İlk ikisi "Frank belgeleri" maddesinde, kodun okumadığı ama karar
    gelene kadar CSV'de kalan Frank metni arasında ve `docs/writing/FRANK_ORPHANS.md`'de satır kararı bekliyor;
    üçüncüsü DRAFT-EN kaydında CSV süpürmesinin sileceği referanssız anahtarlar arasında.
  - Nerede: `localization/strings.csv` (`DEAL_PROMPT_VALIDITY`, `VC_EV_SKIP_MEETING`, `VC_EV_OFFER_EXPIRING_BODY`).
  - Oyuncuya etkisi: Bugün yok, ekrana çıkmıyorlar. Bu hâlleriyle bağlanırlarsa yanlış birim söylerler.
  - Seçenekler: A) Üçü CSV'den silinir (ölü anahtar kuralı, CLAUDE.md §8). B) Bağlanırlar: önce haftalık metin yazılır
    (önce EN, sonra TR; Frank satırı taslak olarak), sonra okuyucu kurulur. C) Frank satırlarının satır kararına
    (FRANK_ORPHANS) kadar kalırlar.
  - Kaynak: CLAUDE.md §3, §5, §8; GDD Zaman Modeli §5; `docs/writing/FRANK_ORPHANS.md`.

- **90 · Haftalık modelin Frank taslakları onay bekliyor.**
  - Ne oluyor: Tike bağlı gün sözü taşıyan Frank satırlarının haftalık hâli taslak olarak yazıldı. Hiçbiri CSV'ye ya da
    karta işlenmedi; onaya kadar onaylı metin ekranda kalır. Taslaklar (EN / TR; değişmeyen paragraflar yazılmadı):
    (1) Yeni `SUMMARY_FRANK_SHUTTER`, `SUMMARY_FRANK_GOOD`, `SUMMARY_FRANK_ANOTHER`, üç `MONTH_FRANK_*` kuralının
    döneme nötr ikizleri: "The shutter counter is running, however this stretch went." / "Kepenk sayacı işliyor; dönem
    nasıl geçerse geçsin."; "All four numbers up. A good stretch." / "Dört rakam da yukarı. İyi bir dönem.";
    "Another stretch behind you." / "Bir dönem daha geride." Onaya kadar bu üç kural aylık kip dışında susar
    (`SummarySystem.PERIOD_NEUTRAL_FRANK`). (2) `END_META_BANKRUPTCY_FRANK`: "You stayed in the red for {weeks}
    weeks. Numbers are not cruel, only patient." / "{weeks} hafta kırmızıda kaldın. Rakamlar kaba değildir, sadece
    sabırlıdır." Onaylı metin `{days}` okur (`EndingsSystem.ending_frank_line` 28 verir) ve tire taşır; taslak
    tiresizdir, onaylanırsa kod `{weeks}` (`SHUTTER_WEEKS`) verir. (3) `VC_EV_LAST_DAY_BODY` (`funding.last_answer`):
    "This is the last week to give the investors an answer." / "Yatırımcılara dönüş için son hafta."; Frank "Nowhere
    left to run. If you're signing, sign this week." / "Artık kaçış yok. İmzalayacaksan bu hafta imzala." (4)
    `SEED_STALL_VERDICT` ve `world.final_stretch_verdict` kartının 0. varyantı (kart JSON'u): son paragraf "Next week
    we do not talk about this again." / "Gelecek hafta bunu bir daha konuşmayacağız." ("Tomorrow" / "Yarın" yerine).
    (5) `funding.sheet_expiry` gövdesi (kart JSON'u) `funding.sheet_weeks_left`'e göre iki varyanta ayrılır; Frank'in
    son cümlesi 1 haftada "We need to give them an answer this week." / "Bu hafta yanıt vermeliyiz.", 2 haftada "We
    need to give them an answer inside two weeks." / "İki hafta içinde yanıt vermeliyiz." olur. Onaya kadar gövde gün
    değerli `funding.sheet_days_left`'i okur; onaylanınca o seam silinir. (6) `VC_EV_MEETING_BODY`: anlatıcı satırı
    "Your meeting with {investor} is this week." / "Bu hafta {investor} ile toplantın var."; Frank'in taksi satırı
    kalır. Bütün gövde haftaya dönerse Frank: "Big week. I'm in a cab. Don't you dare be late." / "Büyük hafta.
    Taksideyim, sakın geç kalma." (`VC_EV_MEETING_TITLE` kalır).
  - Nerede: `localization/strings.csv`; `data/events/cards/world/final_stretch_verdict.json`,
    `data/events/cards/funding/sheet_expiry.json`; okuyanlar `scripts/systems/summary_system.gd` (`_pick_frank_line`),
    `scripts/systems/endings_system.gd` (`ending_frank_line`), `data/events/cards/funding/last_answer.json`,
    `data/events/cards/funding/meeting_day.json`; `scripts/events/seams/seams_ported.gd` (`funding.sheet_days_left`).
  - Oyuncuya etkisi: Onaya kadar Frank bu satırlarda "bugün", "yarın" ya da gün sayısı söyler; aylık kip dışındaki
    özetlerde Frank'in üç kuralı susar.
  - Seçenekler: Her taslak için A) onaylanır ve işlenir, B) sahip yeniden yazar, C) onaylı metin kalır.
  - Kaynak: CLAUDE.md §3 (Frank'in külliyatı Erdem'indir; yeni Frank satırı onaysız ekrana çıkmaz); GDD Zaman Modeli
    §5, §6.3; olay motoru GDD §8.4.

- **91 · Ofis kişilerinin ritim değerleri onay bekliyor.**
  - Ne oluyor: Kişilerin günü şu [WORKING] değerlerle akar (`OfficeConstants`): kaçınma sınırı `AVOID_MAX_K` 6 (bu
    `k`'ya kadar kişiler birbirinin etrafından dolaşır, üstünde yollarını düz yürür ve birbirinin içinden geçebilir;
    1×'in 4'ü kaçınır, 2×'in 8'i kaçınmaz); döngü animasyonlarının tavanı `ANIM_LOOP_MAX` doğal hızın 3 katı
    (idle'lar, adım, el hareketleri; `k` her hızda 3'ün üstünde olduğundan döngüler her hızda bu tavanda oynar; kök
    hareketi ve tek seferlik klipler `k` ile oynar, ayak kayar); kurucu toplantıya çıkarken (saat donuk) kişilerin
    temposu `TRIP_K` 2 (hızdan bağımsız; dönüşte içeri yürüyüş hızın `k`'sıyla oynar); takılan yürüyüşün gerçek-zaman
    tabanı `OfficePerson.STALL_MIN_S` 0,25 sn; geliş gecikmesi 0–60 oyun dk, haftaların %10'unda +30–75 dk; çıkış
    erkenliği 0–45 dk; yürüyerek geç gelme payı `ARRIVE_LATE_OK` 90 dk; çıkış yürüyüşü süresinin `EXIT_SLACK` 1,5 katı
    önce başlar; `MIN_PRESENCE` pencerenin %50'si; kapı: `DOOR_CLEAR` 0,9 m (gelenler arası), `DOOR_S` 0,5 ambiyans sn
    (çıkanlar arası), içeri beklemenin tavanı `OfficePerson.DOOR_WAIT` 6 sn; `NIGHT_WAIT_S` 3,5 gerçek sn; gece
    kesmesinin kararması `OfficePeople.CUT_FADE_S` 1×'te 0,25 sn (hızla kısalır); ilk mola 10–30, molalar arası 25–60,
    ertelenen mola 15–30 ambiyans sn; mola ağırlıkları çalışan/kurucu: kahve 3/2, WC 2/1, masa ziyareti 1/4, kabin 2/0
    (yalnız satışçı); kalış: kahve 6–10, WC 5–8, kabin 10–16, ziyaret 5–8, öğle 15–25 sn; öğle penceresi 12:00–13:30;
    masa başı hareket her 12–30 sn, 4–8 sn sürer; ekip toplantısı oda başına 40–80 sn arayla (sırası gelen toplantı,
    masasında iki kişisi olan bir rol grubu çıkana kadar bekler ve `MEETING_RETRY` 1 sn'de bir yeniden bakar; eskiden
    grup yoksa yeni aralık çekilip toplantı düşüyordu, bu davranış değişikliği de onay bekliyor), 20–30 sn, kurucu %30
    katılır, masada hareket 5 sn'de bir; all-hands 17:00, 20 sn; kuyruk en çok 3 kişi, 0,75 m aralık (`OfficeVenue`).
    Kahvenin kapasitesi tasarımın kahve noktası sayısıdır: İş hanı 4, Plaza 4, Depo loft 5; Ev'de kettle 1.
  - Plandan ayrılan iki nokta: kapıdan iki geliş arası 2 ambiyans saniyesi (`ARRIVAL_GAP`) 40 kişide sabahı 80 saniyeye
    yayıyordu; yerine gelen, bir öncekinin kapıdan `DOOR_CLEAR` uzaklaşmasını bekler. Çıkışta fiziksel kuyruk Plaza'da
    koridoru tıkadı; yerine kapı sırası (`DOOR_S`) geldi, sırası günün sonundan sonraya düşen masasında kalıp kesilir.
  - Ölçüm (`--office-crowd-probe`, 2026-10-09, bu makine; sıçrama, duraklatmada kıpırtı, takılma, poz hatası ve hata
    her koşuda 0; gece kapısı 0,14–0,26 sn, tavana hiç düşmedi). Kapıdan yürüyerek / kesmeyle çıkan, 1× / 2× / 4×: İş
    hanı 11 kişi her hızda 9 / 1, toplantı 2; Plaza 40 kişi 10 / 29, 10 / 29, 9 / 30, kuyruğa giren 9, 9, 10; Depo
    loft 70 kişi 7 / 59, 6 / 60, 5–6 / 60–61, kuyruğa giren 7–8, 4, 0. Çakışma sayacı (ayaktaki iki kişi 0,3 m'den
    yakın, kare başına), 1× / 2× / 4×: İş hanı 0 / 85 / 21, Plaza 15 / 537 / 145–157, Depo loft 16 / 39 / 93; 2× ve
    üstünde kaçınma kapalı olduğu için çakışmalar Plaza'da asansör önü koridorda, Depo loft'ta merdiven ağzında
    toplanır. Eski 1× ölçümüne göre (İş hanı 7 / 3, Plaza 22
    / 18) İş hanı daha iyi, Plaza akşamı daha kötüdür; sırası gelen toplantının grup beklemesi bunun nedeni değildir
    (eski toplantı kuralıyla Plaza 1× yine 10 / 29), akşamı kapı sırası belirler (`DOOR_S` kişi başına 3 oyun
    dakikası). Depo loft'ta sabah kapısı doludur (70 kişi tek tek, kişi başına yaklaşık 0,53 ambiyans sn); yavaş bir
    kare 4×'te dört kat oyun dakikası sürer ve kapı karede bir kişi alır, bu yüzden 4×'te gelişler ortalama yaklaşık
    15 oyun dakikası geç kalır (masaya oturuşun ortancası 1×'te 10:47, 4×'te 11:14), ilk molalar öğle penceresine
    kayar (kısa mola 1×'te 23–25, 4×'te 10–18; öğle 1×'te 12–15, 4×'te 14–16) ve kahve kuyruğu oluşmaz. Depo loft'ta
    4×'in kare p99'u dokuz çiftin sekizinde 1×'ten %4–38 yüksektir (ortalama −%4…+%20, makine yüküyle değişir); aynı
    günün işi dört kat az kareye sığar: poz kare başına +0,6 ms, gün akışı +0,24 ms, kişilerin fizik tiki 2,0 ms'ye
    karşı 0,5 ms (tik başına dört kat yürüyüş; 1×'te bir kısmı kaçınma geri çağrısında koşar). Varsayılan 09:00–17:00
    mesaide all-hands hiç olmuyor (17:00'de ofis boş).
  - Nerede: `scripts/systems/office_constants.gd`; `scripts/ui/office/office_venue.gd`, `office_people.gd`,
    `office_person.gd`.
  - Oyuncuya etkisi: İş hanı ve Plaza'da ofisin günü oyun saatinde her hızda aynıdır; Plaza 40'ta akşam kişilerin
    dörtte üçü masada kesilir. 2× ve üstünde kalabalık ofiste kişiler koridorda ve merdiven ağzında birbirinin içinden
    geçer. Depo loft'ta 4×'te sabah kapı kuyruğu yavaş karelerle uzar, kahve kuyruğu oluşmaz ve
    kare süresi 1×'ten biraz yüksektir.
  - Seçenekler: A) Değerler mühürlenir. B) Sahip değiştirir (ör. all-hands 16:00, daha kısa `DOOR_S`). C) Huylar
    ritmi etkiler (trait task'ı; ISLER).
  - Kaynak: ofis karakterleri planı §2, §9 (Erdem, 2026-09-28).

- **95 · Görüşme metinleri; mevcut VC satırlarında tire ve tırnak.**
  - Ne oluyor: Görüşme akışının yeni anahtarları (`MEETING_*`: kicker'lar, VC ve satış rol adları, tutum ve risk
    sözcükleri, sonuç kartı, davet, dönüş sorusu, `MEETING_ROLE_LINE`, `MEETING_RES_PAIR`, `MEETING_RES_COST_BRAND`)
    EN önce yazıldı, TR tasarımın ifadelerini izler; onay bekliyor. Panel mevcut VC satırlarını olduğu gibi gösterir:
    bazılarında tire var (`VC_B1_LINE` "Vaktim kısa — beni…", `VC_B1_CHOICE`, `VC_B4_CALLBACK`, `VC_B4_PUSH`) ve karşı
    taraf satırları tırnak içinde (tasarımda tırnak yok). Satış satırları hâlâ `PH:` yer tutucusu.
  - Nerede: `localization/strings.csv`.
  - Seçenekler: A) Yeni metin onaylanır. B) Sahip yeniden yazar; tire ve tırnaklar kalkar (LANGUAGE INTEGRITY LAW).
  - Kaynak: CLAUDE.md §3, §5; 1888fe4, eba2140, 4ebcc5d, cf80260.

## Kod ve test altyapısı

- **EA/tam'da kalan "yakında" izleri.** Av'daki kilitli "— · Tier 2'de" fon satırı (`InvestorRegistry` `locked_tier2`)
  ve Pazarlama sekmesinin koşulsuz `"lock": "ea"` kilidi her build'de görünüyor. Seçenekler: build kapsamına bağla ya da
  olduğu gibi bırak. Kaynak: SONLAR_GAZETE_MODLAR §U.4 madde 3.

- **`Chrome*` liste dışı kullanım: Satış sekmesi.** CLAUDE.md §7'nin listesi: TopBar, MonthSummary, NewsTicker, Ürün
  sayfasının Frank şeridi, koyu sahneler (`DialogueChoiceButton`, `ChromeAlertButton`). Liste dışında kalan tek kullanım
  Satış sekmesinin fiyat duruşu kadranı ve temsilci bant tavanı seçicisi (`ChromeTabButton` / `ChromeTabButtonActive`,
  `scripts/tabs/sales_tab.gd`). İki varyasyon bugün `TabButton` / `TabButtonActive`'in birebir aynısıdır
  (`build_theme.gd`). Seçenekler: listeye ekle ya da Satış sekmesi `TabButton`'a geçsin ve `ChromeTabButton*` silinsin.
  Kaynak: eski CLAUDE.md Chrome kuralı; CLAUDE.md §7.

- **Pre-commit kancası.** Git kökündeki pre-commit kancası (`--event-lint` ve `loc_residue`) hazır, ama `core.hooksPath`
  ayarlı değil. Açmak tek bir `git config` komutu ve sahibe bırakıldı. Kaynak: EVENT_ENGINE_QUESTIONS Q16.

- **Seam envanterinin açık YOK satırları.** Olay motoru GDD §6.3 YOK satırlarını sahibi modülün
  açık işi olarak dosyalatır; envanter dosyası silindi (GDD §27.8). Hâlâ açık olanlar:
  - `hr.salary_vs_band(p)` · Ekip. Motor `hr.salary_band_position` ile sarıyor; sarmalayıcı Ekip'in
    seam'i gelince emekliye ayrılır. Üretimde çalışanı banda karşılaştıran başka okuyucu yok.
  - `hr.raise_edge` · Ekip. `EventBus.raise_requested` bildirili, hiç yayınlanmıyor. Ekip §9.2 zam
    talebini olay motorunun konusu sayar, kenar tanımlamaz; kenarı seçmek tasarım kararıdır.
  - `hr.promotion_edge` · Ekip. `employee_eligible_for_promotion` bildirili, yayınlanmıyor; Ekip §9.3
    seviye tavanı dışında koşul vermez. Envanterin önerisi: `experience_bar_full` kenarı ve `level < 2`.
  - `finance.valuation()` · Yatırım. Şirket değerlemesi seam'i yok; `GameState.run_valuation_m` yalnız term sheet
    imzasında yazılıyor. Satın alma kartının kendi fiyatı var (`EndingsSystem.acquisition_valuation()`, seam
    `funding.acq_valuation`). `InvestorRegistry.INVESTORS[*].opening_terms`'teki donmuş `valuation_m` ve
    `dilution_pct` hiçbir yerde okunmuyor: Series A açılış şartları ARR'den türetiliyor
    (`VCPitchSystem._derive_series_a_terms` registry'den yalnız `board_seats` ve `board_veto` okur). Açık: bu iki
    rakam silinsin mi (`opening_terms` yalnız kurul şartlarını taşır), seam'in kaynağı mı olsun, yoksa Series A
    türetimine fon başına taban ya da tavan olarak mı bağlansın (ch09 §5). `docs/writing/FRANK_UNWIRED.md`'nin
    "Waiting on" listesi bu rakamları aday sayıyor ama aynı belge değerlemenin `acquisition_valuation()` ile
    çözüldüğünü de yazıyor; bayat.
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

- **70 · 3B ofis 1080p'nin üstünde yumuşak çiziliyor.**
  - Ne oluyor: `OfficeView`'in `SubViewportContainer`'ı `stretch` ile konteynerin mantıksal boyutunda çiziyor (1920×1080
    tabanında 1836×992). `canvas_items` ölçeklemesinde 1440p ve 4K'da bu görüntü büyütülür; arayüz metni ise fiziksel
    çözünürlükte çizilir.
  - Nerede: `scenes/office/OfficeView.tscn` (`Viewport3D`, `stretch`); `project.godot` (`window/stretch/mode`).
  - Oyuncuya etkisi: Yüksek çözünürlüklü ekranda ofis bulanık, pencereler keskin.
  - Seçenekler: A) SubViewport fiziksel çözünürlükte çizer (4K'da dört kat piksel, GPU bedeli ölçülür). B) Ayarlara bir
    kalite seçeneği olarak bağlanır. C) Kalır.
  - Kaynak: görsel tur (2026-09-27); UiTokens yazı tipi içe aktarma notu (canvas_items metni fiziksel çözünürlükte).

- **71 · Kalabalık Depo loft'un kare maliyeti.**
  - Ne oluyor: Kişiler Quaternius gövdeleridir; aynı görünüm ve parçalar mesh önbelleğini paylaşır, poz ekran boyuna
    göre seyrelir (LOD). 70 kişilik Depo loft 4×'te ortalama kare ~9,9 ms (ölçüm sondasının payı dahil; sondasız
    ~8,4 ms), 40 kişilik Plaza ~5,8 ms (180 Hz ekranın sınırında). Eski Xbot kadrosu 70 kişide ~6 ms'ydi; plan hedefi
    40 kişide ≤8 ms tutuyor, 70 kişide aşılıyor.
  - Nerede: `scripts/ui/office/office_person.gd` (`LOD`, `OFF_SCREEN`), `office_body.gd`, `office_people.gd`.
  - Oyuncuya etkisi: Büyük kadroda zayıf makinede kare düşebilir.
  - Seçenekler: A) LOD turu: uzaktaki ve oturan kişilerin pozu daha seyrek, kaçınma yalnız yürüyende. B) Kalır;
    ölçüm hedef donanımda tekrarlanır.
  - Kaynak: `--office-crowd-probe=loft:70:4` ve `plaza:40:4` ölçümü (2026-09-28).

- **72 · Harita kartı küçük resimlerindeki Mixamo X Bot figürleri: lisans onayı.**
  - Ne oluyor: Ofis kişileri artık Quaternius karakterleridir (CC0, `assets/art/people/LICENSES/`); X Bot dosyası
    repodan çıktı. X Bot yalnız şehir haritası kartlarının küçük resimlerinde, tasarımın kendi çizdiği figürler olarak
    kaldı. Mixamo koşulları karakterin oyunlarda telif ücretsiz kullanımına izin verir; ticari sürüm için sahibin onayı
    yok.
  - Nerede: `assets/art/office/thumb_*.jpg`, `assets/art/office/README.md`, `tools/office3d/README.md`.
  - Oyuncuya etkisi: Yok; küçük resimlerin hukuki dayanağı.
  - Seçenekler: A) README notu yeterli sayılır. B) Küçük resimler Quaternius karakterleriyle yeniden çekilir (ISLER).
  - Kaynak: `assets/art/office/README.md`; ofis tasarımı (`office-sim-v12.js` `loadXbot`).

- **73 · `ChromeAlertButton` renk körü takasına girmiyor.**
  - Ne oluyor: Pazarlık sahnesinin teklif butonu hakaret bölgesinde ve son teklifte `ChromeAlertButton`'a dönüyor;
    varyasyonun yazı rengi temada sabit `NEGATIVE_BRIGHT`. Aynı sahnede cetvelin tutamacı ve son sabır kutusu
    `UiTokens.negative_bright()`'ı okuyup takası izliyor; TopBar'ın `ChromeAlert` etiketi aynı sorunu `top_bar.gd`'de
    override ile çözüyor.
  - Nerede: `scripts/theme/build_theme.gd` (`ChromeAlertButton`); `scripts/modals/negotiation_scene.gd` (`_offer_btn`);
    `scripts/ui/components/top_bar.gd`.
  - Oyuncuya etkisi: Renk körü paletinde teklif butonu kırmızı kalır, çevresi turuncuya döner.
  - Seçenekler: A) Sahne butonun yazı rengini `negative_bright()` ile override eder (TopBar deseni). B) Tema renk körü
    için ikinci bir varyasyon taşır, sahne seçer. C) Kalır.
  - Kaynak: CLAUDE.md §7 (duruma bağlı stil helper'dan okunur); Ayarlar > Erişilebilirlik.

- **74 · Harita çipleri ve güncel ofis hapı koyu çiftle çiziliyor.**
  - Ne oluyor: Şehir haritasının çipleri ve harita kartındaki güncel ofis hapı 3B dioramanın üstünde `BG_TOPBAR` zemin
    ve `CREAM` yazıyla çiziliyor; tasarımın niyeti bu. CLAUDE.md §7 koyu çifti çerçeveye (TopBar, NewsTicker, MonthSummary
    bandı) ayırıyor, bu iki yüzey listede yok.
  - Nerede: `scripts/ui/office/office_city.gd` (harita çipleri); `scripts/ui/office/office_map_card.gd` (güncel ofis hapı).
  - Oyuncuya etkisi: Yok.
  - Seçenekler: A) §7'ye "3B ofisin üstündeki çip ve haplar" eklenir. B) Krem çifte dönerler.
  - Kaynak: ofis tasarımı; CLAUDE.md §7.

- **87 · Lint: her kesinti kartında `expires_weeks` zorunlu; gün adı kuralı değerlere de bakıyor.**
  - Ne oluyor: (1) §17.7 denetimi her kâğıt ve her kesinti kartında `expires_weeks` ister. Kritik kesinti hiç
    bildirime düşmez, o kartlardaki değer hiç okunmaz. Canlı destede bildirime düşebilen kesinti ikidir
    (`sales.price_break`, `customer.retention`); fonlama, ürün, ekip ve dünya kesintilerinin hepsi kritiktir (ör.
    `funding.shutter_warning`). (2) Gün adı kuralı (§17.1) yalnız anahtarlara değil, tanımlayıcı biçimli dize
    değerlerine de bakar (`^[a-z0-9_.]+$`): `_days` ya da `days_since` içeren ya da `days`'e eşit değer hatadır.
    Böylece `history` biçimi `days_since`, eski `delay_days` fiili ve `*_days_*` adlı seam de yakalanır.
  - Nerede: `scripts/events/tools/lint.gd` (§17.7 bloğu, `_lint_day_names`, `_is_day_name`).
  - Oyuncuya etkisi: Yok; içerik yazımının kuralı.
  - Seçenekler: (1) A) Kural yazıldığı gibi kalır. B) Yalnız bildirime düşebilen kartlarda (kâğıt ve kritik olmayan
    kesinti) zorunludur; kritik kartlardaki değer silinir. (2) A) Değer denetimi kalır. B) Yalnız anahtarlar denetlenir.
  - Kaynak: olay motoru GDD §12, §13.2, §17.1, §17.7; GDD Zaman Modeli §3.8.

- **101 · Ölçümde tohumdan bağımsız kalanlar: erken oyun ve iki B2C fikstürü.**
  - Ne oluyor: Sprint karar zarı kalibrasyon turundan önce koşu tohumunu okumuyordu (kart, sprint ve hafta
    hash'i); B2C ölçümleri alt-tür başına yaklaşık iki bağımsız gidişata iniyordu. Zar artık `GameState.run_seed`'i de
    okur ve sekiz tohum ayrı akışlar verir. Kalanlar: (1) erken oyun tohumdan bağımsızdır: MVP bütün koşularda 7.,
    B2C Traction 9., B2C Frank çeki note_tool'da 17., video'da 18. tikte (B2B Frank tohumla oynar); (2)
    `b2c_neglect` fikstürünün akışları `BEGIN` satırı dışında sekiz tohumda bayt-aynı, `b2c` fikstürünün son ölçüleri
    tohumlar arasında aynı: fikstür kabul satırındaki "8/8" fiilen tek gidişattır.
  - Nerede: `scripts/systems/sprint_system.gd` (karar isteği); `scripts/debug/run_probe.gd` (`_seed_b2c_world`,
    `_seed_b2c_neglect`).
  - Oyuncuya etkisi: Yok; ölçümün gücü.
  - Seçenekler: A) Kabul: fikstür tek gidişattır, çok tohumlu okuma oynanan koşulardan gelir. B) Fikstürler tohumdan
    beslenen bir değişken alır (harness). C) Erken oyuna tohuma bağlı bir kaynak gerekir mi, tasarım olarak ayrıca
    sorulur.
  - Kaynak: kalibrasyon turu ölçümü.

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

- **Ürün rev 7 sprint döngüsü canlı, eski akış silindi (sahip kararı 2026-10-01).** Geçiş bayrağı yoktur; Ürün
  sekmesi sprint ekranıdır ve canlı veriyle çalışır (`SprintSystem`, `SprintCatalog`, `SprintBridges`,
  `GameState.product`, kayıt şeması 15). Eski Konsept, yapım ve yayın akışı, eski sekme ve onları sınayan smoke
  vakaları silindi. Kural `GDDs/GUNCELLEMELER.md` "Ürün rev 7" bölümüne işlendi; GDD ch03 rev 6.1 .docx hâlâ eski akışı
  (Konsept, yayın akışı, kapasite bloğu, fiyat paneli, Frank şeridi, monitör), ch12 .docx §3 ve §5 eski ev sahiplerini
  ve onboarding'in Konsept'e açılmasını anlatıyor. Ajanın verdiği kararlar 96'dadır. Açık: ch03 ve ch12 .docx rev 7'ye
  güncellensin mi. Kaynak: `docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md`; GUNCELLEMELER "Ürün rev 7".

- **Üst barın saati kendi bloğunda (tasarım sistemi, sahip onayı 2026-10-02).** Üst bar tarihi ve saati ayrı
  bloklarda gösterir: gün bloğu tarihi (`DATE_LINE`, "Hafta 14 · Nisan 2026"; dar genişlikte `TOPBAR_DATE_COMPACT`,
  "H14 · Nis") ve hafta çubuğunu, saat bloğu saati ve hız tuşlarını taşır (`top_bar.gd`). ZAMAN MODELİ §5 TopBar'ın
  saati tarih satırına eklediğini ("Hafta 14 · Nisan 2026 · 09:00") ve kısa biçimi `TOPBAR_CLOCK_COMPACT`
  ("H14 · Nis · 09:00") anlatıyor; o anahtar silindi. Açık: ZAMAN MODELİ §5 ya da GUNCELLEMELER güncellensin mi.
  Kaynak: Menajer Masası tasarım sistemi (Erdem 2026-10-02, "UI approved").

- **103 · Verim: kişi başı haftalık çıktı yüzdesi (sahip kararı 2026-10-08, GDD'ye işlenmemiş).** Sahibin kararları:
  (1) verim gelsin, çalışanın üstüne gelindiğinde görünsün (Software Inc'teki gibi) ve haftalık çıktı hızı gerçekten
  ona bağlansın; (2) ofis kademesi gibi etkenler artı versin, düşük moral ve fazla mesai eksi ("90 yerine 80-85
  çıktı"); (3) olay kartı bir kişinin hızını süreli düşürebilsin; (4) "ben yaparım" seçenekleri kurucunun verimine
  yazılsın, kurucunun morali ve enerji barı yoktur hükmü değişmez; (5) olayların hız artışı kalsın, Ekip GDD §8.4'ün
  "ayrı hız bonusu yoktur" cümlesi olay kartları için esnesin. Kodda olan: olay satırı ve moral bandı
  (`HRSystem.productivity`, `productivity_mod`, Ekip satırının ipucu ve ekip dosyasının VERİM bölümü; olay motoru
  md'si §27.15). Değişen hükümler: Ekip GDD §2.2 (kısmi kapasite yok), §4.2 ve §8.5 (yüzdeler ekranda görünmez),
  §8.4 (ayrı hız çarpanı yok), §7 (süreli uyarı bu modülde yok). Açık: Ekip GDD'si ya da GUNCELLEMELER bu kararlarla
  güncellensin mi. Altı alt karar **onay bekliyor**: (1) mesai yorgunluğu: ölçü son 4 haftanın ortalaması, sekizi
  aşan her saat −%3, en çok −%15; (2) ofis artısı İş hanı +%3, Plaza katı +%6, Depo loft +%8 mi, yoksa ofisin başka
  etkisi (moral) mi; (3) verimin kenet aralığı %40 ile %130 mu (bugün toplam verim kenetli değil: yalnız olay satırlarının
  çarpımı 0,50 ile 1,30 arasına kenetli, moral bandıyla çarpılınca verim 0,425 ile 1,43 arasında kalır); (4) huy ve toplantı payı sprinte de girsin mi (çıktıyı değiştirir); (5) ipucunda yüzde mi
  ("Verim %85"), kelime ve bar mı; (6) tek başına kurucu tavanı (en çok −%30, 2 hafta) uygun mu (tavan satır başınadır: iki kart birlikte
  kurucuyu yine 0,50 tabanına indirebilir). Ayrıca **onay bekliyor**: satış masası (temsilcinin kapanış
  ihtimali, `SalesRepSystem.close_chance`) verimin yalnız olay satırlarını okur; satış masası moral bandını okumaz,
  verim satırındaki moral satırı satışta etkisizdir (bandı satışa sokmak kalibre ekonomiyi oynatır). Kaynak: yazar
  pilotu klasöründeki `research/verimlilik/TASARIM_NOTU_VERIM.md` §1 ve §8 (repo dışında).
