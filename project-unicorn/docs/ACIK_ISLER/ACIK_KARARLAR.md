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

- **2 · Ekip etkileri kurucunun Liderlik'inden okunuyor; GERÇEK LİDER'in faydası yok.**
  - Ne oluyor: (1) `lead_experience_mult` (1,5) okunmuyor; huyun yalnız bedeli işliyor
    (`HRMoraleSystem._charge_departure`: biri ayrılınca huyu taşıyan −10, öbürleri −5). (2) `HRSystem.tick_experience`
    herkesin deneyim kazancını kurucunun Liderlik'iyle çarpıyor (`HRConstants.experience_gain_mult`, en çok ×1,5);
    Ekip §4.2: "Ekibin deneyim kazanım hızını liderin kendisi değil, GERÇEK LİDER huyu etkiler". (3)
    `HRMoraleSystem._scale` her çalışanın moral düşüşünü kurucunun Liderlik'iyle ölçüyor; §7.1 "o alanın liderinin
    Liderlik yıldızı, lider yoksa kurucunun" der, §4.2 kurucuyu yalnız lideri olmayan alanlar (Satış, Destek, Hesap
    masaları) için sayar. Yapım lideri koltuğu yok (sprint lideri yalnız öneri verir; kayıt göçü eski `area_leads`'i
    siler), yani GERÇEK LİDER'in bağlanacağı bir koltuk da yok.
  - Nerede: `scripts/systems/hr_constants.gd` (`TRAITS["takes_them_under"]`, `experience_gain_mult`);
    `scripts/systems/hr_system.gd` (`tick_experience`); `scripts/systems/hr_morale_system.gd` (`_scale`,
    `_leadership_drop_mult`, `_charge_departure`).
  - Oyuncuya etkisi: Bedelli huy saf yük; hover "Sorumlusu olduğu alanda herkes daha hızlı öğrenir; ayrılıkları ağır
    alır." diyor, öğrenme hızı değişmiyor. Kurucunun Liderlik'i ise ekibin hem öğrenmesini hızlandırıyor hem moralini
    koruyor.
  - Seçenekler: A) Kurucu tek kaynak kalır: Ekip §4.2 ve §7.1 buna göre güncellenir; GERÇEK LİDER ya bağlanacağı bir
    rol bulur ya da metni (`HR_TRAIT_TAKES_THEM_UNDER_EFFECT`) ve Ekip §6 satırı değişir. B) §4.2'nin harfi: deneyim
    kazancındaki kurucu Liderlik çarpanı (`experience_gain_mult`) kalkar, öğrenmeyi yalnız GERÇEK LİDER hızlandırır;
    huyun hangi kişilere işleyeceği (bugün lider koltuğu yok) ayrıca seçilir. Moral ölçeği (`_scale`) iki seçenekte de
    kurucudan kalır, §7.1 güncellenir.
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
    müşteri 4, çalışan 2 hafta) ilk kez çalışıyor. Fren yalnız havuz çekilişinde sorulur ama tetiklenen ve istenen
    kartlar da pencereyi damgalar (`customer.retention`, `customer.request_*`). Destede müşteri öznesi taşıyan tek
    havuz kartı `customer.expansion`; `expansion_ready` seçicisi en yüksek MRR'lı uygun hesabı döndürür. (2) Günlük
    taramadaki varlık anahtarlı kartlar bağlamsız önerilir: `customer.cs_escalation` en düşük memnuniyetli tırmanan
    hesaba (`escalated`, hesap başına 3 haftalık mandal), `funding.sheet_expiry` en az hafta kalan teklife
    (`expiring_sheet`, fon başına one_shot) bağlanır; mandal doluysa kart G3'te düşer. `funding.sheet_decision` aynı
    düzenekle fonları bilerek sıraya koyuyor (kart notu), orada sorun yok. (2) kod okumasıyla doğrulandı, koşuda
    ölçülmedi.
  - Nerede: `scripts/events/gate/scope.gd` (`_select_customer` "expansion_ready" ve "escalated", `_select_investor`
    "expiring_sheet"); `scripts/events/present/tempo.gd` (`assign`, `_record`, `pool_blocked_reason`);
    `scripts/events/gate/gate.gd` (`propose`: varlık anahtarlı kartta G5, G3'ten önce);
    `scripts/events/core/engine.gd` (`_step_pool`, günlük tarama); kartlar
    `data/events/cards/customer/cs_escalation.json`, `data/events/cards/funding/sheet_expiry.json`.
  - Oyuncuya etkisi: En büyük uygun hesap elde tutma ya da talep kartı aldıktan sonra 4 hafta boyunca hiçbir hesaba
    genişleme kağıdı gelmez (hesaplar 3 haftada bir talep açtığı için daha uzun olabilir); Satış sekmesindeki
    "Değerlendir" düğmesi istek olarak geçtiği için çalışır. İki hesabın temsilcisi aynı dönemde alarm verirse
    ikincinin tırmanma kartı 3 hafta ya da ilk hesap toparlanana dek gelmeyebilir. Son haftası aynı olan iki term
    sheet'ten ikincisinin "son 2 hafta" uyarısı hiç gelmez; karar kartı yine gelir.
  - Seçenekler: A) Seçici frenli ya da mandalı dolu özneyi atlayıp sıradakine düşer: deterministik kalır, `EvScope` ve
    `EvEngine` değişir; §4.3 ve §14.3'e birer cümle. B) Tarama kartı uygun her özne için ayrı önerilir; fazlası Katman
    4 ile kağıda düşer (§20 A6). (1)'i çözmez. C) Özneyi yalnız havuz kabulü damgalar: elde tutmanın ertesi haftası
    aynı hesaba genişleme gelebilir (§13.1'in "aynılık" sorunu); (2)'yi çözmez. D) Kalır; §13.3'e "tetiklenen ve
    istenen kartlar da pencereyi damgalar", kart notlarına ve §27'ye "özneler sırayla işlenir" yazılır.
  - Kaynak: Olay motoru GDD §4.3, §13.1, §13.3, §14.3, §20 A6, §27.4 (seçiciler), §27.5 madde 2.

- **6 · Risk'teki hesaba genişleme teklif edilebiliyor.**
  - Ne oluyor: `B2BSalesSystem.can_offer_expansion` pazara, duruma, `last_expansion_day` mandalına ve olgunluğa (6
    hafta, `EXPANSION_MATURE_WEEKS`) bakıyor, yaşam evresine (`lifecycle_phase`) bakmıyor. Aynı yüklemi
    `musteri.is_expansion_ready` seam'i (açıklaması "mature, healthy…" ama sağlık okunmuyor) ve `expansion_ready`
    seçicisi okuyor. Günlük tarama yalnız sağlıklı hesabı `expansion` evresine taşısa da havuz kartı
    `customer.expansion` Risk'teki hesabı seçebiliyor; masadaki kağıt da hesap Risk'e düşünce geçerli kalıyor.
  - Nerede: `scripts/systems/b2b_sales_system.gd` (`can_offer_expansion`, `expand`); seam
    `musteri.is_expansion_ready`.
  - Oyuncuya etkisi: "Churn'e ~N hafta" sayan bir hesap için "Büyüme fırsatı" kağıdı gelebilir; kabul koltuk ve MRR
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
    koyacak.", "En zayıf alanı bulacak.". Oyuncu soruyu okurken iç ses onun daha sorulacağını söylüyor.
  - Nerede: `scripts/systems/vc_pitch_system.gd` (`_beat3_view_state`: soru `active_line`, iç ses `monologue_text`);
    `scripts/ui/meeting/vc_meeting_adapter.gd` (`_lines` soruyu `counterpart`, iç sesi `quiet` satır olarak aynı
    görünümde art arda çizer); anahtarlar `VC_Q_*_MONO` ve `SEED_Q_*_MONO`.
  - Oyuncuya etkisi: Sahnenin zamanı kayıyor: VC sormuş, iç ses "soracak" diyor. Satır bir önsezi gibi okunuyor ama
    önsezi için artık çok geç. Hazırlık ipucunun ("Sayıları hazırla") işe yarayacağı an zaten geçmiş.
  - Seçenekler: A) Metin: iç ses satırları şimdiki zamana ya da tepkiye çevrilir (ör. "Churn'ü soruyor. Sayılar hazır
    mı?"). TR ve EN sahip yazar, mekanik değişmez. B) Zamanlama: iç ses 2. vuruşta, soru gelmeden önce gösterilir.
    Bunun 1. vuruş istihbaratına bağlanıp bağlanmayacağı ayrıca seçilir. Bu, vuruş yapısını değiştirir. C) Olduğu gibi
    kalır. K31 (toplantı diyaloglarının yazım turu) kapsamına alınabilir.
  - Kaynak: ONERI_v3 §2 (şüphe 5); ACIK_KARARLAR K31 maddesi.

- **11 · Elde tutma kartı yalnız Risk'e girişte açılıyor (kalibrasyon).**
  - Ne oluyor: `customer.retention` artık yalnız hesap Risk'e girerken açılıyor (`customer_health_changed`); önceden
    Risk'teki her hesap her tikte kart alıyordu (kartın kendi notu kararı girişe veriyor). Gitmiş hesabın sinyali
    (`_remove_lost`'un "churning" kenarı) kartı artık Risk'teki başka bir hesaba bağlamıyor: verilen id gitmişse kart
    G5'te gerekçesiyle reddediliyor (motor GDD §4.3). Kart, temsilcinin tırmandırdığı hesapta da açılmıyor (kodun
    kendi `can_offer_retention` kuralı). `cs_escalated` bir durumdur (atanmış ve memnuniyet < 35); 1★ ve
    sektör eki olmayan atanmış hesabın toleransı 33 olduğu için böyle bir hesap Risk'te hep tırmandırılmıştır ve elde
    tutma kartını hiç görmez, kararı `customer.cs_escalation` taşır. Hiçbir sabit değişmedi.
  - Nerede: `data/events/cards/customer/retention.json` (tetik, koşul, `cooldown_weeks`);
    `scripts/autoload/customer_registry.gd` (`set_lifecycle_phase`, `customer_churn_countdown_changed`);
    `scripts/systems/b2b_sales_system.gd` (`_tick_customer`, `_remove_lost`); churn geri sayımı ve seçenek etkileri
    `scripts/systems/b2b_constants.gd`; probe botunun tercih sırası `scripts/debug/run_probe.gd`
    (`RETAIN_PREFERENCE`).
  - Oyuncuya etkisi: Risk'e düşen hesap için karar bir kez sorulur; kaçırılırsa Satış sekmesindeki "İlgilen" kartı
    yeniden açar. Kurtarma şansı artık her tikte yenilenmediği ve başka hesaplara taşmadığı için daha çok hesap
    kaybediliyor; geri sayım süresi ve Oyala/İndirim etkileri eski davranışa göre oturmuş olabilir.
  - Seçenekler: A) Churn geri sayımı ve Oyala/İndirim etkileri bugünkü davranışla, tam probe setiyle yeniden kalibre
    edilir. B) Günlük yeniden soru tasarım sayılır, eski davranış geri gelir; kartın notu ve Satış §19 buna göre
    yazılır. C) Kalibrasyon sonraya.
  - Kaynak: Olay motoru GDD §4.3; Satış GDD §19 (retention kartı ve churn geri sayımı korunanlar arasında);
    `retention.json` `_port_note`.

- **13 · Masadaki kağıdın öznesi giderse süre dolumu: ceza, not ve son uyarı birbirini tutmuyor.**
  - Ne oluyor: Kağıt, masaya düştüğünde öznelerini bağlıyor ve adlarını dondurur (`EvPapers`,
    `EvPresenter.freeze_names`). Bir varlık kağıt masadayken giderse son gün uyarısı düşüyor (`EvGate.revalidate`
    bütün slotlara bakar), oyuncu açmak isterse kağıt kayboluyor. Ama süre dolunca `on_expire` çalışıyor, history
    `expired` yazıyor ve `expire_note` dondurulmuş adlarla ticker'a gidiyor. İki durum var. (1) Ana özne (hesap)
    gitti: `on_expire`'ın etkileri hedef bulamıyor (`EvEffects._no_target`: "satisfaction_delta found no target"
    hatası basılıyor). (2) İkincil slot (talep kartının temsilcisi) gitti: ceza hesaba işliyor ve not çıkıyor. §12.4
    "expire_note zorunludur, sessiz süre dolumu yoktur" diyor. §4.4 ve §20 A1 ise gösterimdeki yeniden doğrulamayı
    anlatıyor, açılmamış kağıdın süre dolumunu değil.
  - Nerede: `scripts/events/core/engine.gd` (`_step_paper_expiry`, `_step_last_warnings`, `open_paper`);
    `scripts/events/gate/gate.gd` (`revalidate`); `scripts/events/gate/scope.gd` (`still_valid`);
    `scripts/events/present/presenter.gd` (`freeze_names`), `papers.gd` (`names`);
    `data/events/cards/customer/request_*.json` ve `retention.json` (`scope`, `on_expire`, `expire_note`).
  - Oyuncuya etkisi: (1) Ceza kimseye işlemiyor; hata motor logunda kalıyor. (2) Temsilci
    ayrılınca oyuncu son uyarıyı görmüyor ve kağıdı açamıyor, ama cezayı yiyor. Bu uyarısız bir kayıp.
  - Seçenekler: A) Hangi slottaki varlık giderse gitsin kağıt süre dolumunda düşer: history `dropped` (`entity_gone`),
    `on_expire` ve not çalışmaz. §12.4'e bu istisna yazılır. B) Yalnız ana özne gidince düşer; ikincil slotta uyarı ve
    açılış da yalnız ana özneye bakar, temsilci gitse de kağıt açılır ve ceza işler. Ana özne kuralı tohumlu koşuyu
    değiştirmiyor (369dc57'de ölçüldü). C) Süre dolumu hep çalışır (adlar bugün bağlanırken donuyor, not gitmiş
    varlığı adıyla anıyor); hedefsiz ceza sessizce atlanır. D) Temsilci slotu açılışta yeniden seçilir (reassign
    benzeri, yeni mekanik).
  - Kaynak: Olay motoru GDD §4.4, §12.4, §20 A1, §20 B11; probe ölçümü (369dc57, full_run:760:sim:1).

- **14 · Etki sözlüğünde karşılığı olmayan fiiller (uygulanmayan, hep reddedilen, çipsiz).**
  - Ne oluyor: Tablolarda duran yedi fiilin `_apply`'da kolu yok: `assign_to`, `start_training`, `add_customer`,
    `convert_audience`, `open_paid_tier`, `change_salary`, `fire_employee`. Oyunda "not implemented" diye
    reddediliyorlar; lint V1 (`WRITER_VERBS` ve `SYSTEM_VERBS` dışı fiil yazılamaz) onları bir kartta yazılmaktan da
    alıkoyuyor. `add_mrr` motor GDD §8.1 ve §8.3'te gerçek bir fiil; kod onu hep reddediyor (MRR defterden
    türetiliyor, `engine_probe` bu reddi doğruluyor) ve bu ayrılık §27'de yazılı değil. `notify` metni anahtar ya da
    çeviri olmadan ham basıyor. Çip tarafında 11 fiil ne `EvChips.describe`'da etiketli ne `SILENT_VERBS`'te:
    `clear_flag`, `set_timed_flag`, `ticker_push`, `notify`, `open_negotiation`, `add_mrr`, `assign_to`,
    `start_training`, `change_salary`, `fire_employee`, `add_customer`. Tersine `convert_audience` ile
    `open_paid_tier`'in çipi var ama fiilleri uygulanmıyor. Bugün hiçbir kart bu fiilleri kullanmıyor.
  - Nerede: `scripts/events/core/effects.gd` (`NEUTRAL_VERBS`, `ECONOMIC_VERBS`, `_apply`: "add_mrr", "notify");
    `scripts/events/present/chips.gd` (`SILENT_VERBS`, `FIXED_CHIPS`, `describe`);
    `scripts/events/tools/lint.gd` (`_lint_effects`); `scripts/events/tools/engine_probe.gd` (`_check_effects`).
  - Oyuncuya etkisi: Bugün yok. Bir yazar bu fiillerden birini kullanırsa lint V1 reddeder; kural gevşerse kart oyunda
    görünür ama seçenek söylediğini yapmaz: sessizce reddedilir, bazen çipi de gösterilir. `notify` ile yazılan satır
    tek dilde kalır.
  - Seçenekler: A) GDD'nin adını verdiği fiiller (`fire_employee`, `add_customer`, `assign_to`)
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
    `scripts/events/core/condition.gd` (ark yaprakları); `scripts/events/present/chips.gd` (`SILENT_VERBS`).
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

- **18 · Okunmayan beş `EFFECT_*` anahtarı: DRAFT-EN kaydı onları okunan sayıyor.**
  - Ne oluyor: `EFFECT_MRR`, `EFFECT_QUALITY_BONUS`, `EFFECT_NEW_TEAMMATE`, `EFFECT_PROMISE_HONOR` ve
    `EFFECT_PROMISE_REFUSE` CSV'de duruyor. Ama çipleri kuran `EvChips` (`FIXED_CHIPS`, `describe`) hiçbirini
    okumuyor, üretim kodunda da okuyanı yok. DRAFT-EN kaydı `EFFECT_*` ailesini "üretim kodunun okudukları" arasında
    sayıyor ve "referanssız emekli anahtarları CSV süpürmesi siler" diyor; bu beş anahtar referanssız olduğu hâlde
    okunan görünüyor.
  - Nerede: `localization/strings.csv`; `scripts/events/present/chips.gd` (`FIXED_CHIPS`, `describe`);
    `docs/ACIK_ISLER/ACIK_KARARLAR.md` (DRAFT-EN kaydı).
  - Oyuncuya etkisi: Yok. Anahtarlar okunmayan metin.
  - Seçenekler: A) Silinir. B) Kalır; DRAFT-EN kaydında "okunmayan, ileride çip olacak" diye ayrı satır alır. C)
    Yeniden bağlanır, ör. `EFFECT_PROMISE_HONOR` / `_REFUSE` vaat kartlarının çipi olur (içerik kararı).
  - Kaynak: CLAUDE.md §8 (ölü CSV anahtarı); ACIK_KARARLAR DRAFT-EN kaydı.

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
    ister." yazılmasını istiyor; `RND_NEED_CROSS_BLIND` CSV'de var ama hiçbir kod onu okumuyor. Kilitli yuva yalnız
    `RND_LOCKED_SLOT` ("? {alan}") yazar: küçük (`Caption`, ortalı) ve tıklanmaz (`MOUSE_FILTER_IGNORE`, ad sızmasın
    diye); çapraz koşul ancak açılmış karonun ayağında alan adıyla görünür (`_tile_foot`). Bu yüzden bu satırın karoda
    mı, üzerine gelince mi, yoksa derin bağla seçilince detay kartında mı görüneceği bir yerleşim kararı.
  - Nerede: `scripts/tabs/rnd/rnd_tree_view.gd` (`_make_tile`, `TILE_LOCKED` dalı);
    `scripts/tabs/rnd/rnd_detail_panel.gd` (`_lines`, kilitli düğüm); `localization/strings.csv`
    (`RND_NEED_CROSS_BLIND`).
  - Oyuncuya etkisi: Çapraz koşul ancak ad açıldıktan sonra görünüyor, yani §3'ün yasakladığı sürpriz duvar oluşuyor.
  - Seçenekler: A) Çapraz koşullu kilitli karoya ikinci `Caption` satırı `RND_NEED_CROSS_BLIND` eklenir. B) Satır
    yalnız karonun üzerine gelince ipucu olarak çıkar (kilitli yuva bugün üzerine gelinmez). C) Satır derin bağla
    seçilen kilitli düğümün detay kartında (`_lines`) yazılır. Her seçenekte TR/EN onay bekler.
  - Kaynak: Ar-Ge GDD §3 (MÜHÜRLÜ: sürpriz duvar yasağı), §8 ("çapraz koşulu eksik" durumu).

- **27 · Üç düğümün adlandırılmış maliyet etiketi yazılmamış.**
  - Ne oluyor: `rnd_tree.json`'da `ai_engine`, `security_cert` ve `analytics_engine` `"cost_label": true` taşıyor.
    Kart `PROD_RND_NODE_<ID>_COST` anahtarını arıyor (`RnDUiShared.t_or`), hiçbiri CSV'de yok, bu yüzden kart GDD'nin
    "GPU kirası $600" örneği yerine çıplak "$600" gösteriyor. GDD yalnız `ai_engine` için etiket veriyor ("GPU
    kirası"); `security_cert` ($900) ve `analytics_engine` ($400) için etiket yok.
  - Nerede: `data/techtree/rnd_tree.json` (`cost_label`); `scripts/tabs/rnd/rnd_detail_panel.gd` (`_chips`,
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

- **28 · Kurucu huylarının oyunda etkisi yok.**
  - Ne oluyor: Onboarding 2. sayfası her huyun altında bir tarif satırı basıyor (`TRAIT_*_EFFECT`, ör. "Hafta hafta
    plana sadık kalır."). Metinler 2026-10-10'da etki vaadinden tarife çevrildi (Açılış C5). Seçilen huylar kurucunun
    `Character.traits`'ine yazılıyor ama hiçbir sistem onları okumuyor (`FounderConstants.TRAITS` RESERVED). Huy
    formülü (bir olumlu bedava, iki olumlu bir olumsuz ister; `FounderConstants.validate_traits`) bedeli olmayan bir
    bedel istiyor.
  - Nerede: `scripts/systems/founder_constants.gd` (`TRAITS`, `validate_traits`);
    `scripts/onboarding/steps/origin_traits_step.gd`; `scripts/autoload/game_state.gd` (`initialize_run`, kurucunun
    `traits`'i); `localization/strings.csv` (`TRAIT_*_EFFECT`).
  - Oyuncuya etkisi: Huy seçimi koşuda hiçbir şeyi değiştirmiyor. "Bir kez karar verdi mi, döndürmesi zordur." gibi
    olumsuz huylar bedava, formülün dengesi görünüşte kalıyor.
  - Seçenekler: A) Etkiler bağlanır: her huy için sahibin onaylayacağı bir çarpan (ch02 §8: beceri, hız, olasılık,
    moral) ve onu okuyan sistem; sayılar [WORKING]. B) Huylar karakter tarifi olarak kalır; formülün olumsuz huy şartı
    kalkar ya da kalır, ch02 §1 ve §8 buna göre güncellenir.
  - Kaynak: GDD ch02 §1, ch02 §8; PRD_ACILIS R8 (C-12).

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
  - Ne oluyor: `_account_foot` sorumlu adı bulamazsa CSV anahtarı olmayan sabit "—" yazıyor ("Müşteri temsilcisi:
    —"). Bu tek işaret iki ayrı durumu kapsıyor. (1) `assigned_to == ""`: hesap kurucunun masasında; `assign_customer`
    sözleşmesi ve `B2BSalesSystem._account_owner` kurucuyu sahip sayar, bakım yavaşlatması işler. (2) Temsilcisi
    ayrılmış hesap: `CharacterRegistry.remove` karakteri siler, `assigned_to` eski id'de kalır; `_account_owner` null
    döner ve hesap bakımsız aşınır; `founder_managed_count` ile `_delegate_excess` onu saymaz. Literal CLAUDE.md §5'i
    çiğniyor (anahtar yok, tire var).
  - Nerede: `scripts/tabs/sales_tab.gd` (`_account_foot`); `scripts/autoload/customer_registry.gd`
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
  - Ne oluyor: Satış sekmesinin hesap kartı sebebi `Inbox.risk_reason(c)`'den okunur. Hesabın kullandığı hatlardaki açık
    hata (`B2BSalesSystem.account_bugs`) `B2BConstants.COMPLAINT_BUG_GATE`'in (hesap başına 6) üstündeyse sebep
    "kullandığı hatlardaki açık hatalar" (`SALES_REASON_OUTAGE`) olur. Değilse söz defteri (`trust_offset`) 0 ya da
    üstündeyse "ürün yeterince güvenilir değil (Güven & Ölçek)" (`SALES_REASON_STABILITY`), altındaysa "memnuniyet
    düşüyor" (`SALES_REASON_SATISFACTION`) olur. Aynı hesabın elde tutma kartındaki sesi `B2BSalesSystem.risk_voice`
    seçer: önce kırılmış söz (`b2b_broke_<id>` → `B2B_RISK_VOICE_BROKEN`), sonra aynı hata yüklemi ya da
    `InfraSystem.is_over_capacity()` (sektör şikâyeti), sonra yeni hesap sesi, en son kısa ses. Hata yüklemi iki yolda
    aynı. Kapasite kolu Faz C'nin silme listesinde (Erdem'in C kararı 1: dolu sunucunun tek bedeli kesinti). Kırılmış
    söz sekmede kendi sebebi olarak görünmüyor.
  - Nerede: `scripts/ui/components/inbox.gd` (`risk_reason`), `scripts/tabs/sales_tab.gd` (`_account_card`);
    `scripts/systems/b2b_sales_system.gd` (`risk_voice`, `account_bugs`).
  - Oyuncuya etkisi: Kırılmış sözü olan hesap sekmede "memnuniyet düşüyor" ya da "ürün yeterince güvenilir değil" diye
    okunur, kart ise kırılmış sözle açılır.
  - Seçenekler: A) Sekme `risk_voice`'un sırasını izler; kırılmış söz için yeni bir sebep satırı yazılır (yeni metin,
    onay bekler). B) Kalır.
  - Kaynak: Satış GDD §19 (retention kartı korunanlar arasında); ch11 §7.

- **40 · Kayıtlı ama okunmayan `Customer.health` alanı.**
  - Ne oluyor: `Customer.health` her memnuniyet değişiminde `update_health_from_satisfaction` ile yazılıyor ama
    okuyucusu yok; `SaveCodec` onu kaydediyor. Yazanlar: `CustomerRegistry.set_satisfaction`,
    `SalesSystem.add_b2b_customer`, B2C tabanı, `main.gd`'deki debug fikstürü ve `sprint_probe.gd`.
    `SaveCodec.res_from_dict` yalnız bugünkü alanları okuduğu için alanı silmek eski kayıtları bozmaz.
  - Nerede: `scripts/data_models/customer.gd` (`health`, `update_health_from_satisfaction`);
    `scripts/autoload/customer_registry.gd` (`set_satisfaction`); `scripts/systems/sales_system.gd`
    (`add_b2b_customer` ve B2C tabanı); `scripts/main/main.gd`; `scripts/debug/sprint_probe.gd`.
  - Oyuncuya etkisi: Yok; kayıt dosyasında ve kodda ölü alan kalıyor (CLAUDE.md §8).
  - Seçenekler: A) Alan, fonksiyon ve beş çağrısı silinir (`main.gd` ve `sprint_probe.gd` dahil). B) Kalır; sağlık
    bandı bir okuyucuya bağlanır.
  - Kaynak: CLAUDE.md §2, §6, §8.

- **41 · §12.8 kapı-üstü Yazılım hız bonusu uygulanmıyor.**
  - Ne oluyor: Ürün GDD §12.8 "fazladan Yazılım yıldızları hızı aynı kademeyle çarpar" diyor; GUNCELLEMELER kapı-üstü
    basamaklarını yürürlükteki kural olarak tutuyor ("henüz uygulanmaz"). `LineGates.speed_bonus_for` bu bonusu
    (+%8 / +%4) hesaplıyor ama hiçbir yer çağırmıyor; sprint puanı bonus almıyor. Ölçü de belirsiz: bir sürümde farklı
    Yazılım kapısı taşıyan birden çok kademe olabilir. Bugünkü fonksiyon her kademenin kendi kapısına göre en büyük
    fazlayı okuyor. Kişi kapısı ile toplam kapısının hangisinin sayılacağı da yazılı değil.
  - Nerede: `scripts/systems/line_gates.gd` (`speed_bonus_for`, `_excess_for`, `_excess_ladder`, `ABOVE_GATE_FIRST`,
    `ABOVE_GATE_SECOND`); sprint puanını kuran `scripts/systems/sprint_system.gd` (`_points`).
  - Oyuncuya etkisi: Kapının üstünde güçlü yazılımcı tutmak sprinti hızlandırmıyor; GDD'nin vaat ettiği ödül yok.
    Bağlanırsa sprint puanları ve tohumlu koşu değişir.
  - Seçenekler: A) Sprintteki kartların kademelerinin kendi Yazılım kapılarına göre en büyük fazla (bugünkü
    `speed_bonus_for`) sprint puanını ×(1+bonus) çarpar. B) Fazla, sprintteki en büyük Yazılım kapısına göre tek
    referansla ölçülür. C) Bonus kaldırılır: §12.8'in hız cümlesi GDD'den çıkar, `speed_bonus_for` ve `ABOVE_GATE_*`
    silinir.
  - Kaynak: Ürün GDD (ch03) §12.8, §6.1, §24 (§12.8 inşa notu).

- **44 · Düz özellik kataloğunun emekliliği.**
  - Ne oluyor: GDD §21 "katalog hat modeline geçer, 61 düz özellik ve ölü alanlar silinir" diyor. Düz yolun yapım kısmı
    ve `main.gd` debug tohumları silindi; üç oynanabilir alt-tip (`note_tool`, `video_clip`, `erp`) hat alt-tipi. Düz havuzlar
    (`ProductCatalog.FEATURE_POOLS`) üretimde iki yerde okunuyor: `B2BSalesSystem.pick_pain_feature`'ın düz dalı ve
    `ProductState.is_feature_live`'ın düz kimlik dalı. 122 `PROD_FEAT_*` satırını yalnız smoke okuyor.
  - Nerede: `scripts/systems/product_catalog.gd` (`FEATURE_POOLS`, `get_feature_pool`);
    `scripts/systems/b2b_sales_system.gd` (`pick_pain_feature`); `scripts/systems/product_state.gd`
    (`is_feature_live`); `localization/strings.csv` (`PROD_FEAT_*` satırları).
  - Oyuncuya etkisi: Doğrudan görünmez; ölü yol her ürün işini pahalılaştırıyor.
  - Seçenekler: A) Havuzlar ve iki düz dal silinir; smoke/probe fikstürleri test paketi işiyle hat yoluna taşınır. B)
    Havuzlar yalnız kilitli (hat içeriği olmayan) tiplerin veri kaynağı olarak kalır. C) Bugünkü hâl kalır, GDD
    §21'e not düşülür.
  - Kaynak: Ürün GDD (ch03) §12.1, §20, §21, §22.5; `docs/ACIK_ISLER/ISLER.md` "Test paketi".

- **50 · Kademe açıklamaları yazılmış ama hiçbir ekranda görünmüyor.**
  - Ne oluyor: Her kademe bir `desc_key` taşıyor (`PROD_STEP_*_DESC`; paylaşılan hatlarda alt-tip başına ayrı satır).
    Anahtar hat verisinde durmuyor, `ProductLines._build_line` onu `name_key`'den türetiyor. Anahtarlar CSV'de TR ve
    EN olarak yazılmış ve `loc_product_line_keys_resolve` smoke'u çözüldüklerini denetliyor. Hiçbir arayüz `desc_key`
    okumuyor: sprint ekranı kademeyi yalnız adıyla basıyor (`SprintCatalog.step_name_key`).
  - Nerede: `scripts/systems/product_lines.gd` (`_build_line`, `desc_key`);
    `scripts/systems/sprint_catalog.gd` (`step_name_key`); `localization/strings.csv`
    (`PROD_STEP_*_DESC`).
  - Oyuncuya etkisi: §12.12'nin yazdırdığı tek satırlık açıklamaları (90 satır, gizli hat dahil: dosyalardaki hatların
    45 kimlik kademesi ve 36 paylaşılan satırı, Ar-Ge'nin açtığı `line_hidden_self_serve` hattının 9 satırı) oyuncu
    hiç görmez; kademeyi yalnız adından tanır.
  - Seçenekler: A) Açıklama kademe adının üzerine gelince ipucu olarak görünür. B) Seçili kademenin açıklaması Ürün
    penceresinde tek satır olarak durur. C) Gösterilmez; `desc_key` türetmesi, CSV anahtarları ve smoke denetimi
    silinir.
  - Kaynak: Ürün GDD (ch03) §12.12 (ad + tek satır açıklama yazılır).

- **57 · Araştırma görevinin GÖREV cümlesi yok.**
  - Ne oluyor: Kadro defterinin GÖREV hücresi tek işli kişide `HR_TASK_ON_JOB_<İŞ>` cümlesini basıyor (ör. "Satışta
    görev alıyor"). Araştırma için `HR_TASK_ON_JOB_RESEARCH` satırı yok; kod bilinçli olarak iş etiketine düşüyor
    ("Araştırma"). Ham anahtar ekrana çıkmıyor ama bu satır öbür işlerle aynı biçimde okunmuyor.
  - Nerede: `scripts/tabs/hr/hr_ledger.gd` (`_job_text`, `task_text`); `localization/strings.csv` (`HR_TASK_ON_JOB_*`
    ailesi).
  - Oyuncuya etkisi: Araştırmadaki kişinin GÖREV hücresinde cümle yerine tek kelime görünüyor; defterin dili tutarsız.
  - Seçenekler: A) Yeni anahtar yazılır: EN "Working on research", TR "Araştırmada görev alıyor" (onay bekler);
    ardından `_job_text`'teki geri düşüş dalı silinir. B) Bugünkü gibi: etiket yeterli, geri düşüş kalır.
  - Kaynak: Ekip GDD §12.2 (iş metni); Ar-Ge GDD §5.0 (araştırma dışlayıcı iştir).

- **110 · Düz özellik havuzunda B2B sözü: ürünün zaten sunduğu yetenek söz konusu olabilir.**
  - Ne oluyor: `B2BSalesSystem.pick_pain_feature`'ın düz havuz yolu (hat modeli olmayan alt-türler) bir özelliğin
    ürün tarafından henüz sunulmadığını `mvp_components` bayrağından okur. Sprint motoru bu bayrağı yazmaz (yalnız
    smoke yazar); bu yüzden yol "hiçbir şey canlı değil" görür ve adayın ya da hesabın acısı olarak
    ürünün zaten sunduğu bir özelliği seçebilir. Böyle bir söz ya bedava kazanç ya haksız kayıp olur. Oynanabilir üç
    tür (`note_tool`, `video_clip`, `erp`) hat alt-türüdür ve `_pick_line_pain`'e gider; düz yola yalnız hat içeriği
    olmayan alt-türler (smoke fikstürleri) girer. Faz A bu yola dokunmadı: söz kaydı ve smoke vakaları
    `mvp_components` bayrağına bağlı.
  - Nerede: `scripts/systems/b2b_sales_system.gd` (`pick_pain_feature`, `mvp_components` okuması);
    `scripts/systems/product_state.gd` (`is_feature_live`'ın düz kimlik dalı).
  - Oyuncuya etkisi: Bugünkü oynanabilir türlerde yok. Düz havuzlu bir alt-tür oynanabilir olursa söz sistemi
    ürünün zaten sunduğu yeteneği isteyen hesaplar üretir.
  - Seçenekler: A) Düz yol silinir (44. maddenin A seçeneği); `mvp_components` okuması söz kaydıyla birlikte kalkar.
    B) Düz yol adayı `ProductState.is_feature_live(kimlik)` ile süzer. C) Kalır; düz havuz oynanabilir türlere
    dönmeyecekse sorun yoktur.
  - Kaynak: Faz A K8 taraması; ürün GDD (ch03) §12.1, §21.

## Tasarım ve denge

- **K13 · Kilometre taşı maddesi (Series B köprüsü).** ch09 §5 term sheet koşulları arasında
  "milestone clauses" sayıyor; kodda yok. Seçenekler: kur, ch09'dan çıkar ya da not olarak beklet
  (öneri: beklet). Kaynak: ONERI_v3 K13.

- **K14 · Reddedilme zinciri ve pivot mandalı (D2, D3).** Sayım kümülatif; sağlıklı şirkette `pivot_offer_made`
  sessizce yazılıyor, bağlı kartı olmadığı için zincir hiç çalışmıyor. Öneri: sayım üst üste (teklif alınınca sıfır); fonun
  kalkması sayılsın, oyuncunun kalkması ve K10 reddi sayılmasın; üçüncü redde yol kapansın, şirket sağlamsa koşu sürsün,
  çöküyorsa `vc_rejection_cascade`; mandal silinsin. Kaynak: ONERI_v3 K14, ACIK_KARARLAR_D1-D13 §1.

- **K15 · 104. hafta ve canlı teklif.** Soft cap (`EndingsSystem.SOFT_CAP_WEEK`, 104 hafta), canlı teklif ya da
  görüşme varken de `running_on_fumes` ile bitiriyor (bugünkü kural: otomatik imza yok, erteleme yok). Öneri: canlı
  teklif varken son hafta, K10 karar kartı gelene kadar uzasın. Kaynak: ONERI_v3 K15.

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
  hükmü, GDD bölümü). K18: Series A gibi 3 hafta, sonra K10 karar kartı. K19: "Şimdilik hayır" seçeneği; seed
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

- **K25–K27 · Satış pazarlığındaki üç açık.** Hakaretin bedeli fiilen masadan kalkmakla aynı: ikisi de 4 hafta kilit
  (`RETURN_LOCK_WEEKS`, `WALK_LOCK_WEEKS`); hakaret hesap hafızasına yazılır (`SalesLedger.record_insult`) ve sonuç
  kartı bunu söyler (`MEETING_RES_INSULT_MEMORY`), ama hafızayı okuyan yok (öneri: kilit uzasın, ONERI_v3'te 60 gün,
  yaklaşık 9 hafta; hafıza okunsun). Aynı teklifi tekrarlamak karşı teklifi yükseltiyor (öneri: karşı teklif sabit,
  alıcının sabrı −2). "SON RAKAM" masayı kayıpla kapatıyor (öneri: son teklif olarak gitsin). Kaynak: ONERI_v3
  K25–K27.

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

- **B2 ekonomisi (D13).** Kapı gününde (5 tohum) son ay marjı %63–75, kârlı ay serisi 7–11. Demo'da yüzleşme sayılan her
  hareket ertesi gün bootstrap zaferi getiriyor; satın alma teklifi pratikte görünmüyor. ch08 §2 marjın ölçekle düşmesini
  istiyor. "Harness mi ekonomi mi" karşılaştırması yapılmadı. Ofis gideri 0 (`FinanceSystem`'deki "office" TODO).
  Kaynak: ACIK_KARARLAR_D1-D13 B2 ve D13, HANDOFF_series_a §C, RAPOR_LOKAL §3.

- **Kadro ve İK kalibrasyonu.** Kapı gününde çalışanların %68,5'i satış ve müşteri temsilcisi, %17'si geliştirici.
  Açık soru: botun işe alım merdiveninin etkisi mi, yoksa Series A için ürün tarafında bir şart mı gerekiyor.
  EVENT_REVISION ölçümünde (61d5c2c botu) koşu başına 30–50 istifa; seed kapısı 50–60. günde açılıyor.
  Kaynak: HANDOFF_series_a §H.3, EVENT_REVISION §6.3–6.4.

- **Series A ekranlarındaki görsel gözlemler.** Masa kadranında ibre yüzde yazısının üstünden geçiyor. Seed
  masasındaki kilitli board satırı hâlâ bir hedef gösteriyor ("0 koltuk + veto → temiz"). Av'da ürün kartı TEKLİFLER
  panelini örtüyor; "BEKLEYEN" kutusu ile sıradaki teklif karışıyor. EA iflas gazetesinin rayı neredeyse boş. Kaynak:
  RAPOR_LOKAL T2.4, TOPLANTI_VE_SERIES_A_ONERI §A.

- **Oyun Vizyonu v1'in çalışma kararları.** Erdem'in 31 Ağustos tarihli belgesi repoda yok. Yanıt (54ace8d) onay
  almadı; dosya sahip kararıyla silindi. Açık kararlar: perde sınırları, kişisel runway, 104 haftanın Perde 2 saati
  olması, remote çalışan ve ekip tavanı, İK rolü, run kartı, teknik borç, tükenmişlik sonu. 3D sanat yönü ve kapsamı
  ile ofis kataloğu 2026-09-27'de karara bağlandı (gerçek zamanlı izometrik 3B ofis; Ev → İş hanı → Plaza katı → Depo
  loft; `GDDs/GUNCELLEMELER.md` ch12). #11 (kurgu etkinlik adları) karar değil, mevcut yasadır (ch14 §6). Birçoğu
  yürürlükteki GDD'lerle çelişiyor (ch14 §7 çalışan yüzü, Ekip GDD ekip tavanı). Kaynak: VIZYON_v1_YANITLAR §2–§3.

- **GDD'ler arası iki çelişki.** (1) Zor mod: ch01 §6 "v1 yalnız Normal; Hard, Normal kalibre edilene kadar
  kilitli-görünür", ch14 §2 "Hard demo'da çıkar" diyor; ch14 §8 ayarlı mı kaba mı çıkacağını açık bırakıyor. Kodda zor mod
  yok: son ekranında "ZOR MOD · YAKINDA" kilitli, Frank'in çekini ve seed'i reddetmek "zor modda açılır" kilidinde.
  `GDDs/README.md` ch01 §6 için ch14'ü okutur. Açık: Hard demo'ya girecek mi. (2) Ar-Ge sekmesi: ch12 §1 ve ch14 §3
  "kilitli-görünür" diyor; Ar-Ge GDD §2 (rev 1.8) ray öğesini ilk günden normal sekme sayıyor, kod (`UiTokens.TABS`) buna
  uyuyor. Açık: ch12 §1 ve ch14 §3 güncellensin mi.

- **60 · Ofis kirası, depozitosu ve nakliyesi ekonomiye bağlı değil.**
  - Kapandı (sahip kararı 2026-10-11, C seçildi): taşınma bedelsiz kalır; kasa şartı yalnız kapıdır. Karttan KİRA / AY
    ve TAŞINMA hücreleri, depozito + nakliye notu ve düğmedeki tutar kalktı (düğme "Buraya taşın"), hover yalnız masa
    sayısını yazar. `CATALOG`'dan `rent`, `deposit` ve `move_cost` alanları ile `OFFICE_CARD_RENT`, `_MOVE`,
    `_MOVE_NOTE`, `_MOVE_FREE`, `_MOVE_FOR` anahtarları silindi; silinen sayılar aşağıdaki "Ne oluyor" satırında durur.
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

- **61 · Krem paletin onay bekleyen renkleri.**
  - Ne oluyor: Krem palete geçişte yeni değer alan ve F5 onayı bekleyen renkler: `ACCENT_HOVER` #F6D059,
    `ACCENT_PRESSED` #D7AC2A ve renk körü zeminleri (`POSITIVE_BG_CB` #D9E5F0, `NEGATIVE_BG_CB` #F1E4D1).
  - Nerede: `scripts/theme/ui_tokens.gd` (`# WORKING` işaretleri).
  - Oyuncuya etkisi: CTA'nın hover ve basılı hâli, renk körü paletinde olumlu ve olumsuz zemin.
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

- **75 · Temsilcinin planı verime bölünüyor; odak payı ve çalışma saati plana girmiyor.**
  - Ne oluyor: Satış masasında anlaşma yarım hafta cinsinden bir plandır ve açıldığı anda bir kez kurulur: müşterinin ve
    satıcının yıldızı planı kurar (`SalesConstants.deal_halfweeks`), Premium +%30 uzatır
    (`PROCESS_PREMIUM_PENALTY`), plan satıcının o haftaki verimine bölünür (`HRSystem.productivity`: moral payı ve olay
    satırları). Odak payı (`HRConstants.focus_mult`, iki işte 0,5) ve çalışma saati (`HRConstants.hours_output_mult`)
    plana girmez; sprint puanı ikisini de okur.
  - Nerede: `scripts/systems/sales_rep_system.gd` (`_desk_halfweeks`); `scripts/systems/sales_constants.gd`
    (`deal_halfweeks`, `PROCESS_PREMIUM_PENALTY`).
  - Oyuncuya etkisi: Moralsiz temsilci daha yavaş kapatır; iki işte çalışan ya da uzun mesaideki temsilci ötekiyle aynı
    hızda kapatır.
  - Seçenekler: A) Kalır. B) Plan odak payına ve çalışma saatine de bölünür.
  - Kaynak: Satış GDD §7.2; GDD Zaman Modeli §4.5; Erdem, 2026-10-11 kararı (satış bir süreçtir).

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
  - Ne oluyor: Günden haftaya çeviride bir haftanın altındaki süreler tek tike indi, aradaki ayrım kayboldu. Musluk
    haftanın lead'lerini tek seferde üretir (`FAUCET_TICK_MAX` 14). Haber şeridi haftada 3 ile 5 satır yazar
    (`NewsFeedSystem.WEEKLY_LINES_MIN` / `_MAX`; eskiden günde 3 ile 5).
  - Nerede: `scripts/systems/sales_faucet_system.gd` (`_tick_inflow`); `scripts/systems/news_feed_system.gd`.
  - Oyuncuya etkisi: Lead'ler tik başında toplu gelir; haber şeridi haftada 3 ile 5 satır yazar.
  - Seçenekler: A) Kalır (tik iriliğinin bilinçli bedeli). B) Saat çözünürlüklü süre: kısa süreler saatle sayılır ve
    haftanın içinde biter (ayrı tasarım). C) Yalnız seçilen satırlar saat çözünürlüğüne geçer (ör. lead gelişi).
  - Kaynak: GDD Zaman Modeli §4.5, §4.9 ve Açık 3; Erdem, 2026-09-27 ve 2026-09-28 kararları.

- **78 · Olay kartları haftanın başında geliyor.**
  - Ne oluyor: Günlük kartlar günlük tikte değerlendirilir; günlük tik 00:00 devrindedir ve gece atlamasının toplu
    adımının içinde koşar. Toplu adım sürerken gösterim ertelenir (`TimeManager.is_batching`); adım bitince
    (`EventBus.clock_batch_ended`) motor kuyruğu boşaltır, ama kart ekrana şirketin mesai penceresinde çekilmiş geliş
    saatinde gelir (`MailClock`, pencerenin ilk 4 saatine yayılım [WORKING]): tik başına en çok 2 kesinti
    (`EvTuning.MAX_INTERRUPTS_PER_DAY`), gerisi masadaki kâğıtlara düşer; süresi dolan kâğıtlar o anda düşer; haftalık
    satış raporu kart değil mesajdır. Gün içinde yalnız saatlik kartlar (`allowed_hours`) ve oyuncunun eylemlerine
    bağlı kartlar gelir.
  - Nerede: `scripts/autoload/time_manager.gd` (`skip_night`, `_run_batch`, `_dispatch_daily_tick`);
    `scripts/events/core/engine.gd` (pump ertelemesi); `scripts/events/core/signals.gd`;
    `scripts/events/core/tuning.gd`; `scripts/systems/mail_clock.gd`.
  - Oyuncuya etkisi: Hafta kararlarla açılır; kartlar mesainin ilk dört saatine yayılır; 1×'te 22,5 saniyelik haftanın
    ilk yarısı kalabalık, gerisi çoğunlukla sessizdir.
  - Seçenekler: A) Kalır. B) Yayılım 4 saatten genişler (`MailClock.SPREAD_HOURS`). C) Yalnız kritik kartlar ilk
    saatlerde kalır, öbürleri gün içine yayılır.
  - Kaynak: Erdem, 2026-09-27 kararı (bir oyun günü bir hafta; ofis boşalınca gece atlanır); ch11 §5; olay motoru GDD
    §13 (tempo); GDD Zaman Modeli §7.

- **79 · Satış masasının haftalık ayrıntıları: hafta içinde doğan lead, gece kilidi.**
  - Ne oluyor: (1) Sahip kararı, hafta başladıktan sonra doğan lead'e (olay kartından gelen) bir hafta fazla ömür
    veriyordu: o tikin temsilci masası çoktan koşmuştur. Kod kararın amacını ek hafta yerine sırayla karşılar: her lead
    1 hafta yaşar (`LEAD_LIFE_WEEKS`), süre dolumu temsilci masasından sonra süpürülür
    (`SalesFaucetSystem.expire_leads`, `B2BSalesSystem.daily_tick`). Lead dolduğu tikte de masaya girebilir; hafta
    içinde doğan lead ertesi tikin masasına ulaşır, ama aynı günlük dağıtımda, masadan hemen sonra düşer: oyuncu onu
    yalnız doğduğu haftanın kalan saatlerinde görür. (2) Gece ve "mesai bitmek üzere" aynı kilit metnini gösterir
    (`SALES_BLOCK_TOO_LATE`); ayrı bir gece anahtarı yok.
  - Nerede: `scripts/systems/sales_faucet_system.gd` (`spawn`, `expire_leads`); `scripts/systems/b2b_sales_system.gd`
    (`daily_tick`); `scripts/systems/sales_ledger.gd` (`meeting_block_reason`).
  - Oyuncuya etkisi: (1) Olay kartından gelen lead panoda yalnız doğduğu haftanın sonuna kadar durur. (2) Kenar
    durumdur: gece masaya oturmak isteyen oyuncu "mesai bitmek üzere" okur.
  - Seçenekler: (1) A) Sıra kalır: her lead 1 hafta, dolum masadan sonra. B) Kararın harfi: hafta içinde doğan lead 2
    hafta yaşar (sıra da kalır). (2) A) Tek anahtar kalır. B) Gece için ayrı kilit metni yazılır (önce EN, sonra TR).
  - Kaynak: Satış GDD §4 (lead ömrü), §5.0 (giriş kapısı); GDD Zaman Modeli §4.5, §8.2; Erdem, 2026-09-28 kararı
    (hafta içinde doğan lead'e ek hafta).

- **81 · Yatırım toplantısının haftalık takvimi: erteleme, geç masa kilidi, giriş kapısı.**
  - Ne oluyor: (1) Erteleme tavansızdır: toplantı haftasından önceki her hafta "Ertele" randevuyu bir bekleme süresi
    (`PitchConstants.MEETING_LEAD_WEEKS`, 1) daha iter ve fona her seferinde `MEETING_RESCHEDULE_PENALTY` yazar; gün
    modelinin davranışı budur. Adım sabit bir hafta değil bekleme süresidir; sabit değişirse adım da değişir. (2)
    `funding.sheet_decision`'ın "Masaya otur" seçeneği `VC_BLOCK_LATE` kilidi taşır; kilit görünürse açık kalan tek
    seçenek reddetmektir ve fon kalıcı kapanır. Kartın koşulu da masa kapısını (`funding.table_sitting_open`)
    beklediği için bu yalnız bir oturumun saatleri koşmuşken ekrana gelen kartta olabilir. (3) Oturum kapısı
    (`WorkHoursSystem.sitting_open`) yalnız giriş yüzeylerinde (Yatırım sekmesi düğmeleri, kart seam'leri) zorlanır;
    `VCPitchSystem.begin_meeting`, `TermSheetTableSystem.open` ve `SeedRoundSystem.begin_pitch` geç saatte reddetmez
    (satış toplantısının deseni; smoke ve probe oturumları 00:00'da açılır).
  - Nerede: `scripts/systems/vc_pitch_system.gd` (`reschedule_meeting`, `begin_meeting`);
    `scripts/systems/work_hours_system.gd` (`sitting_open`); `scripts/systems/pitch_constants.gd`;
    `scripts/systems/term_sheet_table_system.gd` (`open`); `scripts/systems/seed_round_system.gd` (`begin_pitch`);
    `data/events/cards/funding/sheet_decision.json`; `scripts/events/seams/seams_ported.gd`;
    `scripts/tabs/hunt_tab.gd`.
  - Oyuncuya etkisi: (1) Oyuncu toplantıyı istediği kadar erteleyebilir; bedeli fonun hafızasıdır. (2) Nadir bir anda
    tek açık seçenek fonu kapatmaktır. (3) oyuncuya görünmez.
  - Seçenekler: (1) A) Kalır. B) Erteleme sayısına tavan [K]. C) Erteleme sabit bir hafta iter. (2) A) Kilit kalır. B)
    Bu kartta kilit kalkar; oyuncu geç saatte de masaya oturur. (3) A) Kalır. B) Oturum sistemleri de kapıyı zorlar;
    smoke ve probe oturumları gündüz saatine taşınır.
  - Kaynak: ch09 §4, §5; GDD Zaman Modeli §4.7, §8.2, §8.6; Erdem, 2026-09-27 kararı (toplantı süreleri, tek giriş
    kapısı).

- **82 · Sürüm yaşı geç yayında ilk tikte "1 hafta" okuyor.**
  - Ne oluyor: Yayın saat kesriyle damgalanır (`mvp_version_launch_day` = tik + saat / 24). Destek akışı ve ilgi
    kesirli yaşı okur (`ProductState.version_age`). `urun.version_age` seam'i ve satış görüşmesinin soru bağlamı
    `ProductRead.version_age()` okur, yani kesirli yaşın yukarı yuvarlanmışını (`ProductState.version_age_weeks`).
    Haftanın geç saatinde yayınlanan sürüm bir sonraki tikte, bir haftadan az geçmişken "1 hafta" okur; gün modelinde
    sayaç yayından sonra dönen günleri sayıyordu.
  - Nerede: `scripts/systems/product_state.gd` (`version_age`, `version_age_weeks`); `scripts/systems/product_read.gd`;
    `scripts/events/seams/seams_product.gd` (`urun.version_age`); `scripts/systems/sales_probes.gd`.
  - Oyuncuya etkisi: `urun.version_age` okuyan kartlar (`repeat_reminders`) ve görüşme soruları yayından bir hafta
    geçmeden "1 hafta" görür.
  - Seçenekler: A) Kalır: yayından sonra dönen tik sayılır. B) Tamamlanan hafta (kesirli yaşın aşağı yuvarlanmışı): geç
    yayında bir tik boyunca 0 okunur.
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
    `scripts/tabs/events/mail_pane.gd` (`_summary`); `localization/strings.csv`.
  - Oyuncuya etkisi: (2) Özet müşteri değişimini göstermez. (3) Haftalık özetin başlığı kendini tekrar eder. (4)
    Sessiz dönem satırı gözlem yerine hüküm okur (CLAUDE.md §5).
  - Seçenekler: (1) A) Yuva 0'da temizlik onaylanır. B) Yayında temizlenir. (2) A) Kalır. B) Özete müşteri satırı
    eklenir, defter müşteriyi de tutar. (3) A) Kalır. B) Haftalık kipte aralık satırı düşer. (4) A) Kopya kalır. B)
    İkizler yalnız gözlem taşıyan yeni metin alır (önce EN, sonra TR).
  - Kaynak: ch08 §4 (Monthly close, one screen); GDD Zaman Modeli §6.3; Erdem, 2026-09-27 kararı (sessiz ay kapanışı,
    özet sıklığı); CLAUDE.md §5.

- **84 · Finans işlem listesinin tarih sütunu yılı taşıyor.**
  - Ne oluyor: İşlem listesinin tarih sütunu yılı da taşır (`FIN_TX_DATE`, ör. "H14 · Nis 2012"); sütun 96 px'dir
    (`UiTokens.D_W_TX_DATE`).
  - Nerede: `scripts/tabs/finance/finance_ozet_view.gd` (işlem satırı); `scripts/theme/ui_tokens.gd`
    (`D_W_TX_DATE`).
  - Oyuncuya etkisi: Tarih sütunu geniştir.
  - Seçenekler: A) Yıl kalır. B) Kısa biçim ("H14 · Nis"); sütun 72 px'e döner.
  - Kaynak: GDD Zaman Modeli §4.6, §5; Erdem, 2026-09-28 kararı.

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
    - Eşleme. (1) Yetenek mevcut hattır; alanlar: Çekirdek beş kimlik hattı, İlk Kullanım ve Erişim mobil hat ve gizli
      `line_hidden_self_serve`, Büyüme (B2C) ya da Entegrasyonlar (B2B) entegrasyon hattı, Güven & Ölçek güvenlik ve
      dayanıklılık, Gelir yalnız B2C'de sanal "Ücretli plan"; B2B'de Gelir yerine Müşteriler satırı
      (`data/product/sprint.json` `areas`). (2) Cila kartı üretilmez, katalogda cila adı yok; cila sayacını yalnız
      kayıt göçü doldurur (`sprint.json` `polish_*`). (3) Kademenin lisans bedeli kartın sprinti başlarken bir kez
      alınır, göçle gelen kart ödenmiş sayılır (`SprintSystem.start`, `card.paid`). (4) Faz → rol → Ekip alanı
      tablosu; uymayan kişi fazı %50 hızla yürütür, Test'e uyan kimse yoksa testsiz biten kart hatalıdır
      (`sprint.json` `roles`, `role_areas`, `no_role_speed`; `SprintSystem._fits`). (5) Sprint ekibi Görevler
      matrisinde Yapım ya da Test işini tutan aktif kişilerdir, kurucu dahil; payı sprint işi sayısı × odak payıdır
      (`SprintSystem._share`, `HRConstants.focus_mult`): tek işte 1,0, Yapım ile Test'te 1,0, Yapım ile Destek'te 0,5,
      Ar-Ge'de ve yalnız Destek'te 0. Beceri bandı rolün ana alanından okunur, ikincil alanla uyan kişi aynı puanla
      çalışır; kurucu moralsizdir, çarpanı ve rolleri sahip kararıdır (1,0; Ürün, Tasarım, Yazılım, Test;
      GUNCELLEMELER "Kalibrasyon turu · ürün rev 7") (`SprintSystem.team`, `_points`). (6) Kurucunun satış toplantısı
      sprint kapasitesini düşürmez: sprint puanı haftalıktır, Satış §5.0 toplantı payı uygulanmaz;
      `sales_meeting_time_skip_founder_share` toplantı payını DESTEK masasında ölçer. (7) Lider en yüksek Liderlik'li
      aktif çalışandır (eşitlikte küçük kimlik), yoksa kurucu (`product_model.gd`). (8) Sprint numarası saklanır,
      hafta günden türetilir: planlama başlangıcı geciktirebildiği için PRD §3.11'in "numara günden türetilir" yarısı
      uygulanmadı (`GameState.product.sprint`). (9) "!" bir yetenekte 5 ve üstü açık hata (`fix_effort.priority`) ya
      da Güven'de sunucu aşımıdır (`SprintCatalog.area_alert`). (10) Müşteri isteğinin alanı hesabın sektörünün
      birinci vurgu alanıdır (`ProductQuality.emphasis(c.industry)[0]`), sözleşme 52 hafta; zamanında çıkan talep
      yalnız "memnun" işaretlenir, Satış'a ya da memnuniyete yazılmaz; geç talep sessizce düşer (`sprint.json`
      `request`; `SprintBridges.tick_requests`). (11) `product.paid_tier` kartı kalır, üç eski ürün kartı
      `cards/unwired/`'a taşındı.
    - Katalog ve lider. (12) Beklenti alanın ulaşabileceği en yüksek seviyeye kırpılır; Gelir'in tavanı 1'dir
      (`ProductQuality.expectation`). (13) Tasarım profilli hatların kademelerine Ar-Ge `design_system`'in %20 efor
      indirimi uygulanır (`SprintCatalog.step_effort`, `ProductLines.work_profile`). (14) Durum eşikleri sırayla
      okunur: 0 Yok, beklentinin altı Zayıf, beklenti + 1'in altı Yeterli, üstü Güçlü; PRD'nin "±0,5 Yeterli"si
      "Zayıf"la çakışıyordu (`ProductQuality.word_for`). (15) Rakibin kademesi taban tablo + her çıkış için +1;
      beklenti artışı birikimlidir: aday ve ekonomi bağlamında alanın beklentisi rakip çıkışı başına 0,5 artar, en çok
      1,0, yalnız son 6 haftanın sprintlerindeki çıkışlardan; ürün sayfasının referansı rakipsizdir; çip, cümle ve ses
      aynı pencereyi okur (`ProductQuality.expectation`, `SprintCatalog.recent_hits`, `sprint.json` `rival_bump`,
      `rival_bump_max`, `rival_window_weeks`, `rivals.json`). (16) Lider kuralının açılımı: zorunlu seçimler sırasıyla
      verilmiş sözlerin kartları (son tarihi yakın önde), en yakın son tarihli açık talep, B2C'de yayından sonra
      Ücretli plan, en zayıf alanın en iyi kartı ve öncelikli düzeltmelerdir; MVP'den önce zorunlu alan Çekirdek'tir
      (yoksa Tasarım ★ kilitli Onboarding "en zayıf" sayılıp yalnız araştırma verirdi); küçük ekipte (sprint en çok
      `lead.small_team_cards` (2) K1 alıyorsa) tek açık kartı araştırma olan alan en zayıf sayılmaz, bütün alanlar
      öyleyse araştırma zorunlu kalır; en zayıf alan yuvarlanmamış seviyeyle seçilir, eşitlikte o alanın en iyi
      kartının etki/efor oranı yüksek olan; zorunlular %125'e, dolgu %100'e kadar girer, yük kartın kalan puanıdır;
      boş sprint tavanı aşan zorunlu kartı da alır (yalnız kurucu kapasite 4 iken K2 5 puandır); etkisi 0 olan kart
      dolguya girmez; kilitli, başka sütunda duran ve PM'in onaylı planındaki kart önerilmez
      (`SprintCatalog._suggest`, `_weakest`). Söz kartının ve Ücretli planın zorunluluğu sahip kararıdır
      (GUNCELLEMELER "Kalibrasyon turu · ürün rev 7"); sıra, küçük ekip eşiği ve eşitlik kuralı onay bekler. (17)
      Araştırmanın etki ağırlığı 0,5 → 0: araştırma yalnız zorunlu seçim olarak gelir, yoksa her K2'yi geçip
      sprintleri dolduruyordu (`sprint.json` `impact.research`). (18) Ücretli plan MVP'ye kadar kilitlidir ("Kilit:
      Canlı ürün ✗"); "+", "→" ve lider onu almaz (`SprintCatalog.gate_reason`). (19) Kalibrasyon girdisi, değişiklik
      değil: dört kişi ve kurucuda sprintin bitirdiği iş kapasitenin %58–79'u; açık her adım yapılınca otomatik
      sprintler yalnız araştırma taşır.
    - Motor. (21) Hatalı kart ticket açmaz: hatası kartın hattına açık hata olarak düşer, MVP öncesi kapanışta v1.0'a
      kadar bekler, sürüm çıkarmayan kapanışta da düşer (`SprintSystem._close`, `_land_faulty`). (23)
      `refresh_on_publish`'in yeni kod terimi katalog eforunu okur (`ProductLines.effort_of`, DESTEK'in kalibre olduğu
      ölçek), sprint puanını değil. (24) Yalnız araştırma çıkan kapanış sürüm değildir. (25) Kâğıt sprint başına tek
      zarla istenir: 1 haftalık sprintte başlarken, 2 haftalıkta ilk haftanın sonunda
      (`SprintSystem._request_decision`, `decision.sprint_chance`). Kâğıt sprint sürerken kapanınca haftanın ataması
      baştan yapılır ve ekip karta döner (Erdem 2026-10-18; `SprintSystem._clear_decision`). (26) Durum eklemeleri:
      `sprint.status` "closed", `sprint.hours_mult`, `card.base`, `card.paid`, `product.worked`; sürüm kaydı etiket
      değil numara saklar (`release.number`, 0 sürüm değildir). (27) "→" kilitli kartı da reddeder (PRD yalnız "+"yı
      kilitler); sonraki sütundaki kart planlama dışında yalnız "çıkar"ı sunar.
    - Köprüler. (28) Talep yalnız kilitsiz adımı hedefler; alanında yapılabilir adım yoksa o pencerede talep doğmaz
      (`SprintBridges.tick_requests`). (29) Yeni hata canlı hatlara eşit olasılıkla düşer; dağıtım ağırlığı yoktur.
      (30) MVP'de sunucu bulutta ve önerilen kapasiteyle açılır (`SprintBridges.on_mvp`,
      `InfraSystem.suggested_start_units`); sürümde kapasite büyümez, yalnız oyuncu ve Otomatik ayarla değiştirir
      (`SprintBridges.on_release`). (31) Rakip çıkışı şeride yalnız canlı satır olarak düşer (`ticker_live_line`),
      arşive girmez; basın satırı "Biz" arşivine girer (`headline_added`). (32) Müşteriler satırı yalnız açık talebi
      olanı listeler; PRD C5'in müşteri başına ticket sayısı ("Beykoz · 2 ticket") yoktur, açık hata hatta bağlıdır.
    - Ekran. (33) Kırmızı ton hem "!" hem Zayıf alanda (`product_model.gd`). (35) "Sprint otomatik başladı" çipi
      yalnız o sprint koşarken görünür (`build_bar.gd`). (36) Onaysız PM planı saklanmaz, her okumada bugünkü durumdan
      kurulur; yalnız onaylı plan saklanır (`SprintCatalog.pm_plans`). (37) "Düzenle" yalnız SONRAKİ sprintin
      sütununda: C4 fikstürü artık onu yalnız Sprint 8'in altında çizer, mockup 8, 9 ve 10'un altında
      (`quarter_view.gd`). (38) Düzenle önerinin kartlarını onaysız olarak sonraki sütuna koyar ve PM kalan kapasiteye
      ek kart önerebilir; onaylanan sonraki sprint planı hemen sütuna geçer, ileri onaylı plan sprinti sonraki olunca
      geçer (`SprintSystem.approve`, `edit`, `plan_next`). (39) Hedef şeridi 10 kare, çizgi 5. karede; dolu kare = en
      çok 10, yuvarla(seviye / beklenti × 5) (`sprint.json` `pm.goal_squares`, `pm.goal_mark`). (40) Tür seçici yalnız
      oynanabilir türleri çizer; yol başına üç kilitli kart (ch03 §12.11, GUNCELLEMELER ch14 §2) çizilmez
      (`type_picker.gd`).
    - Kayıt. (41) v15 göçünde ilerleme birimi faz puanıdır; yapımın gizli hataları, tasarım eforu, beta ve iterasyon
      durumu taşınmaz; cila eşlemesi 1,0'ın üstü → 0,5, 1,11 ve üstü → 1,0; `bug_count_at_bugfix_start_*` de düşer;
      sürüm geçmişi `releases`'a sprintsiz (−1) geçer (`save_manager.gd` `_migrate_15`).
    - Silmeler. (42) `PROD_RIVAL_PASSED` ("{rival} seni geçti.") TR metniyle silindi; süpürme listesi onu sahip kararı
      diye işaretlemişti. (43) Frank anahtarları `PROD_MENTOR_LINE` ve `PROD_READY_TALK_FRANK` okuyucusuz kaldı; Frank
      külliyatı olduğu için silinmedi. (44) Probe preset'leri `full_run_weak`, `b2c_keep`, `b2b_risk_keep`,
      `b2b_slip_keep` silindi (düz alt-tür, sprint oynayamaz).
    - Metin (TR/EN onay bekliyor). (46) Stage 1'in `PRODUCT_*` içerik anahtarları (alan adları ve kısa adları, alan ×
      durum cümleleri, rakip ve aşım ekleri, kart adları, araştırma ve rakip sesleri, rakip haber satırları, basın
      satırları, beklenen ve gerçekleşen cümleleri, lider cümleleri, otomatik başlama notu) ve Faz A ekran
      anahtarları; `PRODUCT_LOCK_LIVE`, `PRODUCT_GOAL_CORE`, `PRODUCT_GOAL_ONBOARDING`, `PRODUCT_GOAL_GROWTH`,
      `PRODUCT_GOAL_INTEGRATIONS`, `PRODUCT_GOAL_TRUST`, `PRODUCT_GOAL_REVENUE`, `PRODUCT_GOAL_PROGRESS`; çipler
      `EFFECT_SPRINT_CARRY`, `EFFECT_SPRINT_HOURS`; `HR_TASK_ON_PRODUCT`. (47) Karar fikstürleri silindi. (48)
      `rivals.json`'ın rakip seçimi, kademe tablosu ve çıkış takvimi. (49) "sprint" ve "PM" izinli ödünç listesinde
      yok (`docs/design/localization_glossary.md` satırları yazıldı, TR onay bekliyor); "Onboarding" sahip kararıyla
      listeye girdi; "ticket" oyuncu metninden kalktı.
    - İnceleme turu. (50) Sayaç, aşınma ve devir yoktur: açık hata sürümle sıfırlanmaz, yalnız düzeltme kartı hattının
      hatasını siler (`ProductState.clear_line_bugs`). (51) Kademesine başka bir kartla varılmış kart kapanışta kademe
      yazmaz, sinyal atmaz, yeni kod saymaz ve sonraki planlamada saklı kartlardan düşer (geç kalan talebin kartı ile
      aynı kademenin özellik kartı; `SprintSystem._close`, `plan_next`). (52) Başlamamış düzeltme kartının hata sayısı
      ve eforu hata deposundan okunur, koşan kartınki başlatmada kilitlenir (`SprintSystem._refresh_fix_cards`);
      kapanış hattın bütün açık hatasını siler (`ProductState.clear_line_bugs`). (53) Kartın yükü kalan puanıdır ve
      kesirli toplanır; yuvarlama yalnız gösterimdedir (`ProductModel`), kapasite çubuğunun dilimleri ile "kullanılan"
      aynı sayıdır; kalan puan her fazın eksik payının toplamıdır, efor indirimi onu eksiye düşürmez
      (`SprintSystem.used`, `card_load`, `remaining`, `points_left`). (54) Etki satırının seviye geçişi kelimesini
      beklentiye göre taşır (`ProductQuality.word_for`): öngörü, alan satırı ve sürüm notu aynı kelimeyi okur; yetenek
      geçişinin dilimleri de alanın beklentisiyle boyanır (`SprintCatalog.card_effect`, `forecast`).
  - Nerede: her maddenin parantezinde; ayrıntılı gerekçe ajan raporlarındadır.
  - Oyuncuya etkisi: Ürün sekmesinin bütün kuralları; özellikle lider önerisi (16, 17), MVP öncesi Ücretli plan (18),
    hata (21, 29, 50, 52), talepler (28), altyapı (30), ÇEYREK (36–39), tür seçici (40) ve karar
    kartı (25).
  - Seçenekler: Her madde için A) onaylanır, B) sahip değiştirir (değer ve kural `sprint.json`'da ya da parantezdeki
    yerde), C) metin maddelerinde sahip yeniden yazar.
  - Kaynak: sahip kararı 2026-10-01; `docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md`; GUNCELLEMELER "Ürün rev 7";
    CLAUDE.md §3 (tasarım sabiti ve TR metni onay bekler).

- **97 · Kalibrasyon turu · onay bekleyen değerler.**
  - Ne oluyor: Ürün rev 7 kalibrasyon turu (sahip kararları 2026-10-02, GUNCELLEMELER "Kalibrasyon turu · ürün
    rev 7") sabitleri değiştirdi ve desteye 27 kart ekledi (21'i bugün destede). Sahip kararlarındaki ve onaylanan
    tur planındaki değerler kayıt içindir; plandan sapanlar (±%50 ayar penceresinin kenarındakiler **kenarda** diye
    işaretli) ve planda olmayanlar onay bekler. Biçim: eski → yeni, neden, ölçüm. Ölçüm: tohum 1–8, 120 hafta, `--lang=tr`; oynanan
    sekiz preset (`full_run`, `full_run_lean`, `full_run_vc_cautious`, `full_run_b2c`, `full_run_b2c_video`,
    `full_run_b2c_vc_cautious`, `full_run_b2c_vc_walk`, `full_run_b2c_k1`) ve 26 haftalık `b2c`, `b2c_neglect`
    fikstürleri; 80 koşu, her biri tek `PROBE END`, hatasız. Son ölçümde 18 kabul satırının 17'si geçer (tutmayan: 98).
    - Sprint (`data/product/sprint.json`). `founder_mult` 0,75 → 1,0 (karar 9): tek kurucunun sprinti 4 puan; MVP
      64/64 oynanan koşuda 7. tikte (taban 13). `founder_roles` [Ürün, Yazılım] → [Ürün, Tasarım, Yazılım, Test]
      (karar 2). Yeni `hours_mult` {0,5–1,5}: `sprint_hours` çarpımla yığılır ve bu aralığa
      kenetlenir (plan). Yeni `lead.small_team_cards` 2: sprint en çok iki K1 alıyorsa tek açık kartı araştırma olan
      alan en zayıf sayılmaz (planda sayı yok).
    - Söz. `B2BConstants.PROMISE_RELOCK_WEEKS` yok → 8 (karar 8). Kırık söz koşu başına 0–3 (taban 6–23); aynı
      hesaba ikinci kırılma hiç yok, yani kilit ölçümde devreye girmedi.
    - B2C (`sales_system.gd`; B2B akışı bu sabitleri okumaz, B2B koşuları değişmedi):
      - `CHURN_COEF` 0,0002 → 0,000036 (plan 0,00003, +%20): plan değerinde yalnız K1'li ürün $15K'yı aşıyordu;
        son değerde K1'li ürünün tepe MRR'ı 12.256–12.952 $. Faz Q'dan beri kalite terimi U × 5/7'dir; değer aynı,
        anlamı kaydı.
      - `EROSION_THRESHOLD` 42 → 25 (plan 30, −%17): 30'da B2C Series A kapısı hiç açılmadı. Faz Q'dan beri kalite
        terimi ürün uyumu U × 5/7'dir (50 = ürün kitlenin beklentisini karşılıyor); değer aynı kaldı, anlamı kaydı.
      - `WOM_COEF` 0,005 → 0,00103 (Faz Q K9b, Erdem'in C10 seçimi; RAPOR_Q).
      - `WOM_SAT_GATE` 60 → 65 (aynı seçim).
      - `WOM_MULT_PIVOT` 50 → 233 (aynı seçim): üç değer kitleyi 26., 52. ve 104. haftada ekonominin dengelendiği
        büyüklükte tutar; onay bekliyor.
      - `SATISFACTION_QUALITY_GATE` 40 → silindi (kural değişti; 34 kapandı).
      - `SATISFACTION_DRIFT_PER_DAY` yok → 1,5 (plan 1, +%50, **kenarda**): 1,0'da kapılar 92–102. haftada ya da
        hiç; 1,25'te MVP sonrası kitle eridi.
      - `VALUE_FEATURE_COEF` yayınlanan özellik başına 1,2 → açık hat başına 0,75 ve `VALUE_COMPLEXITY_COEF` 0,6 →
        kullanım ağırlığı puanı başına 0,375 (plan 0,6 / 0,3, +%25): planda video ürünü 7,66K $'da kaldı (tasarımcı
        basamağı 8K $), 0,6 / 0,3'te video kapısı 6/6 kapalı.
      - İlginin B2C kazanımına çarpanı kendi sabitini taşımaz.
    - Tek seferlik etiketler (`FinanceSystem.ONE_TIME_LABELS`): planın sekizi (incident, audit, retention, outreach,
      refunds, side_work, meetup, sponsor) ve planda olmayan üç (domain, user_tests, trade_fair).
    - `SalesSystem.growth_band()` çevrilmiş sözcük yerine bant id'si döndürür (melting, flat, steady, fast); tek
      okuyucusu `sales.growth_band` seam'idir, `world.b2c_creator_feature` bu sayede bağlandı ve okuyucusuz kalan
      `GROWTH_*` anahtarları silindi. Plan dışı; geri alınırsa ikisi birlikte.
    - Yeni kartlar (21, hepsi `demo`; Frank satırı yok; her kâğıt ve kesinti `expires_weeks`, `on_expire` ve not
      taşır):
      - MVP öncesi: `founder.meetup_talk` (kâğıt, tek sefer, 2. haftadan ve sprint koşarken; konuş −600 $, saat
        ×0,9 ve marka +4, yalnız sprint koşarken açık; dinle −200 $ ve marka +1), `founder.side_contract` (kâğıt,
        cooldown 10, 4. haftadan, runway < 24 hafta; al +3.000 $ ve saat ×0,6, yarım +1.200 $ ve ×0,85; ret satırı
        yok, süresi dolmak bedelsiz rettir), `founder.domain_name` (planda yok; kâğıt, tek sefer, 1. sprintten; al
        −900 $, bekle marka −2), `founder.friends_test` (planda yok; kâğıt, tek sefer, 2. sprintten; ağırla −300 $ ve
        marka +2, gönder marka +1 ve itibar −1); quiet `founder.savings_note` (cooldown 8), `founder.unseen_build`
        (6), `founder.company_of_one` (4; planda yok), `product.working_parts` (4; planda yok).
      - Ekip: quiet `team.demo_day` (cooldown 8, 3+ kişi, sprintin 2. haftası; yap moral +3 ve saat ×0,95, atla
        moral −2), `team.outside_offer` (tek sefer kişi başı, 5+ kişi, 12+ hafta kıdem; prim −5.000 $ ve moral +10,
        konuş moral −6, bırak ayrılık ve itibar +1).
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
        alan tabana yakın; geri bildirim saat ×0,9 ve memnuniyet +3, not et −2), `product.b2c_floor_churn`
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
    - Ajan kararları (kod bu yorumlarla çalışır): (a) B2C memnuniyeti tik başına hedefe doğru en çok adım kadar (10)
      yaklaşır ve hedefte durur (`SalesSystem._tick_satisfaction`). (b) Sürümde açık bulunan sprint sözü hep tutulmuş
      sayılır (geç olan aynı tikte zaten kırılmıştır). (c) Sığma: yalnız planlanabilir sprinte borçlu sözler sayılır,
      bir adım kaç hesaba söz verilmiş olursa olsun bir kez; koşan sprintte boş yer = kapasite / saat çarpanı −
      sonraki sütunun kalan puanı. (e) Artı `add_cash` tek seferlik gelirdir, ay gelirine ve kâr serisine yazılmaz
      (yan iş +3.000 $). (f) Lint etiketi bütün `ONE_TIME_LABELS`'a karşı denetler; kart "hire" gibi bir sistem
      etiketini de geçirebilir. (g) Planın `rival.segment_leader` seam'i `rival.leader` adını aldı: lint'in gerçek
      marka listesi "segment"i kart gövdesinde reddediyor. (h) `product.b2c_floor_churn`'ün kaybı kitle yüzdesidir
      (`churn_customer`'ın çipi "Bir müşteri kaybedildi" yazardı). (i) Faz 3 girişi `funding.gate_series_a`'nın son
      çözümünden geçen haftayla okunur; motor faz değişiminde mandal sıfırlamadığı için `trade_fair` ve
      `app_placement` yeniden açılmadı, iki yeni kart yazıldı.
    - Metin (TR/EN onay bekliyor): 21 yeni kartın metni (`EV_FOUNDER_*`, `EV_PRODUCT_*`, `EV_TEAM_*`, `EV_RIVAL_*`,
      `EV_WORLD_*`, `EV_CUSTOMER_*`, `EV_LOCK_NO_SPRINT`; seam okuyan gövdeler satır içi), `FIN_ONETIME_*`,
      `PRODUCT_FX_PROMISE`, `PRODUCT_FX_PROMISE_KEPT`, `PRODUCT_PROMISED`, `SALES_PROMISE_OPEN_SPRINT`,
      `B2B_LOCK_PROMISE_BROKEN`, `SALES_LOCK_PROMISE_NO_ROOM`.
  - Nerede: her maddenin parantezinde; ölçüm tabloları ve iz kayıtları kalibrasyon turunun raporundadır.
  - Oyuncuya etkisi: Erken oyunun temposu (MVP 7. tik), sözlerin kırılması, B2C'nin büyümesi ve iki sonu,
    faz 3'ün harcama kararları.
  - Seçenekler: Her madde için A) onaylanır, B) sahip değiştirir (değer parantezdeki yerde), C) metin maddelerinde
    sahip yeniden yazar.
  - Kaynak: sahip kararı 2026-10-02 (1–12); GUNCELLEMELER "Kalibrasyon turu · ürün rev 7"; CLAUDE.md §3.

- **98 · B2B Traction'da runway baskısı zayıf.**
  - Ne oluyor: Turun kabul ölçütü Traction haftalarının en az %40'ında sonlu runway istiyordu (ch01 §5: her evre
    runway'i yeniden daraltır); kalibrasyon turunda ölçülen pay 0,09 ile 0,21 (taban 0,05 ile 0,11). Araç ve servis
    gideri Erdem'in "gizli gider yok" kararıyla kalktı (Faz C C2): gider dökümünde maaş, ek mesai, pazarlama, ofis ve
    sunucu kaldı, turun gider kaldıraçlarının hiçbiri yok. Runway yalnız net akış eksideyken görünür. C2 ölçümü orta ve
    geç oyunun da belirgin rahatladığını gösterdi (evre 3'te ayda yaklaşık 40 ile 53 bin gider kalktı, evre 2'de kasa
    dört ayın altına inmiyor).
  - Nerede: `scripts/systems/finance_system.gd` (`BURN_IDS`); `seed_round_system.gd` (kapı);
    `scripts/debug/run_probe.gd` (işe alım kapısı).
  - Oyuncuya etkisi: Traction'da runway çoğu hafta görünmez; evre runway'i yeniden daraltmaz.
  - Seçenekler: A) Ölçüt yumuşar ya da kalkar: Traction'ın baskısı seed öncesindeki dar penceredir. B) Seed'den sonra
    başlayan Traction baskısı (seed imzasından sonra devreye giren gider ya da nakit maliyetli kartlar). C) Seed
    kapısı değişir (eşik ya da okuma anı). D) Botun işe alım kapısı (harness) değişir, yeniden ölçülür. E) Gelir
    modeliyle (Pazar 2) birlikte ele alınır; ölçüm Faz C'nin E2 turunda.
  - Kaynak: ch01 §5; kalibrasyon turu ölçümü (sahip kararı 2026-10-02); sahip kararı 2026-10-20 (gizli gider yok); 108.

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
  - Faz A ile değişti (2026-10-17): Düzeltme koşusu ve doğrulanmış hata birikimi yoktur: hata tek depodur, düzeltme sprintin düzeltme kartıdır ve geç B2C'de hatanın bedeli kitle kaybıdır. C seçeneğinin sprint yarısı Faz A Karar 13 ile uygulandı (sprint puanı Görevler matrisini okur; Yapım ve Destek'teki yazılımcı 0,5 sayılır). Bot düzeltme kolları (`fix_none`, `fix_worst`, `fix_due`, `fix_off`) bu değişikliklerle yeniden ölçüldü; ölçüm RAPOR_A'dadır. Madde açık kalır. Sahip onayı RAPOR_A'da.

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

- **104 · Hız merdiveni dört kat hızlandı: bağlı hedefler ve hızlı basamakların yan etkileri.**
  - Ne oluyor: Sahip kararıyla `TimeModel.SECONDS_PER_HOUR` [0.0, 2.5, 1.25, 2.5 / 3.0]'tür (duraklat, 1×, 2×, 3×;
    4× basamağı yok); varsayılan mesaide hafta 1×'te 22,5, 2×'te 11,25, 3×'te 7,5 sn sürer (eski 4× yeni 1×'tir).
    Kararın açtığı
    sorular ve işi yapan ajanın verdiği kararlar:
    (1) Demo hedefi 60–90 dk [WORKING] (CLAUDE.md §1; GUNCELLEMELER ch01 §1, ch14 §1) eskiden 1×'te 40–60 haftaya
    denk geliyordu. Bugün 60–90 dk saf 1× saatiyle 160–240 hafta eder, 104 haftalık tavanın üstü; 104 haftalık koşu
    1×'te, duraklama ve toplantı hariç, yaklaşık 39 dk.
    (2) Olay temposu çapası (motor md §13.7; `EvTuning.ANCHOR_MINUTES_PER_DECISION` 2,5,
    `ANCHOR_MAX_INTERRUPTS_PER_3_MIN` 3): 3 gerçek dakika artık 1×'te 8, 3×'te 24 haftadır;
    tik tavanı (2) dolarsa 1×'te 16 kesinti eder. Harness (`--event-harness=random:seeds=10:weeks=104`, 4 farklı kart
    ateşlendi): 1×'te 1,4 dakikada bir karar; en yoğun 3 dakika 1×'te 4, 2×'te 5, 3×'te 7 kesinti; en uzun sessizlik
    1×'te 68 sn.
    (3) Kapandı (sahip kararı 2026-10-09, eski 90 sn haftanın ritmi, Software Inc. modeli): `k` saatin hızıyla
    doğrusaldır, ambiyans saniyesi her hızda 6 oyun dakikasıdır; GUNCELLEMELER ch12 §6, GDD Zaman Modeli §7.4.
    (4) Ev'de kurucu (ajan kararı): yatağa gidiş ve dönüş yürüyüşleri pencerenin yarısından fazlasını alıyorsa
    08:00'den masasındadır, yatakta görünmez ve gece kararmasında kesilir (personelin `MIN_PRESENCE` kuralı). Ambiyans
    saniyesi her hızda 6 oyun dakikası olduğundan kural hızdan bağımsızdır: Ev'in yatak yürüyüşü (zincirler boyunca
    yaklaşık 14,5 m, kalkıp yatmayla) yaklaşık 60 oyun dakikasıdır ve kural ancak 4 saatten kısa bir pencerede
    devreye girer, varsayılan 09:00–17:00'de girmez. Ölçümde (oyun saati, hızdan bağımsız) kurucu 09:17'ye kadar uyur,
    09:40'ta
    masasındadır, 16:31'de yatağa yürür, 16:54'te yataktadır.
    (5) Kapandı (sahip kararı 2026-10-10, saati yalnız oyuncu başlatır): istek anında kurucu ofiste görünürse saat
    durur; Ertele kartı kapatır, saati başlatmaz, telefon saat duruk çalmaya devam eder; GDD Zaman Modeli §8.5.
    (6) İş hanında kurucunun çıkış anı (`bitiş − EXIT_SLACK × yürüyüş`) 12 oyun dk/ambiyans sn'lik eski tempoyla
    14:00'ten önceydi; giriş 15:00'e kadar açık olduğu hâlde bu arada istenen satış görüşmesinin telefonu görünmüyor ve
    kesimde sessizce düşüyordu. 6 dk/as ile çıkış anı yaklaşık 16:00'dır (köşe odaya dönüş yürüyüşü `--travel-shot`'ta
    1×'te yaklaşık 1,75 sn, 7 ambiyans sn): ölçümde kurucu 15:17'de mutfakta, 16:48'de masasındadır,
    15:00 kesiminden önce çıkmaz. Akşam kapıdan da çıkmaz: bitişi günün bitişine eşitken çıkış anında kapı sırası
    (`_head_out`) günün bitişini geçer, kurucu masasında kalır ve gece kararmasında kesilir (aynı karelerde 16:48'de
    ofiste yalnız kurucu kalmıştır, masasındadır).
    (8) Haftalık otomatik kayıt 3×'te 10 sn tabanı (`AUTOSAVE_MIN_REAL_SECONDS`) yüzünden iki haftada bir iner.
    (9) Sahibin hedefi (2026-10-09) hızlı basamağın 1×'in gerçekten o katı olmasıdır; çözüm ajanındır ve onay bekler (91):
    gece kesmesinin kararması (`CUT_FADE_S`) hızla kısalır, GDD Zaman Modeli §7.3–7.4. Ölçüm (gece kararması dahil, 2026-10-10): `--tempo-probe=1:shell` haftası 22,65 ve 22,73 sn (+%0,7, +%1,0),
    `=3:shell` 7,55 ve 7,58 sn (+%0,6, +%1,1); 3× 1×'in 3,00 katı.
    (10) Depo loft'un feribotu ve suyu oyun dakikasıyla akar: en hızlı basamakta (3×) feribot ekranı yaklaşık 6 sn'de
    geçer. B2C ücretli koşuda Finans sayfası her MRR değişiminde (her oyun saati) baştan kurulur, gizli Yatırım sayfası
    da: 3×'te saniyede 1,2 kez; maliyeti ölçülmedi.
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

- **K31 · Toplantı diyaloglarının yazım turu.** Satış toplantısının 54 satırından ve Ekip'teki kurucu durum etiketi
  `HR_FOUNDER_STATE_CARE`'den "PH:" öneki kalktı (43e0a28; TR/EN sahip onayı bekliyor). Açık kalan toplantının sesidir:
  VC ve seed'de tepki satırları az ve iki oda arasında ortak, fonların kendi sesi yok. Öneri: açılış, tepki, geçiş ve
  gerekçeli kapanış slotları, "en uzun süredir söylenmemiş" seçimi, hafıza; önce yaklaşık 150 satırlık MVP, sonra
  yaklaşık 425 satır. Fon ses kartları yalnız EN; Anchor'ınki onaylı.
  Kaynak: ONERI_v3 K31, §5 ve §5.4; TOPLANTI_VE_SERIES_A_ONERI §A–§C.

- **Olay içeriği eksik (ch11 §1–§2, ch14 §2).** ch11 dokuz ark ve Frank hariç ~40 düğüm, ch14 §2 demo için 40–60
  düğüm, en az bir rakip hamlesi ve bir olay (incident) istiyor. Canlı destede Frank'inkiler dahil 129 demo kapsamlı
  kart var (2026-10-21; müşteri 17, kurucu 7, fonlama 23, ürün 57, rakip 6, ekip 8, dünya 8, bağlı olmayan 3); en az
  bir rakip hamlesi (`rival.funding_round`, `rival.price_cut`) ve bir olay (`product.incident_outage_b2b`,
  `product.incident_outage_b2c`) bulunuyor. Kalibrasyon turu 27 kart ekledi (97): Y3 `team.demo_day` ve
  `team.outside_offer`, Y4 `team.first_weeks` (sonradan emekli), Y7 `product.bug_pile` (Faz A'da silindi), Y8
  `rival.funding_round` ve `rival.price_cut`, Y9 `product.outage` (Faz B B3'te gece kesintisi zarına döndü; kartlar
  `product.incident_outage_b2b` ve `_b2c`). `quiet` etiketli beş canlı kart olay motoru GDD §13.6'nın sessiz tabanını
  doldurur (`founder.company_of_one`, `founder.savings_note`, `founder.unseen_build`, `product.working_parts`,
  `team.demo_day`). Açık kalan: ch11'in dokuz arkı (`data/events/arcs/`'ta tek gerçek ark `soft_cap_stretch`). Kaynak:
  EVENT_REVISION §9.

- **Son ve kapı metinleri (K23 dahil).** `END_BS_HEAD` "{company} Kimseye El Açmadan Ayakta", `END_BS_SUB` "Dışarıdan
  tek kuruş almadan büyüyen bir şirket…" diyor. Oysa Frank'in çeki normal modda reddedilemiyor ve seed alınmış koşu da
  bootstrap'a ulaşıyor. `ENDING_CARD_SERIESB_BODY` "Series A oyunu bitirmez" diyor; `ENDING_BADGE_EA` Series B'yi
  Erken Erişim'e koyuyor (ch14 §5: tam sürüm). `ENDING_RUN_META` sabit "NORMAL MOD" yazıyor. Canlı metinde tire (ch01
  §9, ch11 §7): `GATE_ADVANCE`, `GATE_SERIES_A_BODY_0`, `END_META_SERIES_A_CLOSE_FRANK`, `END_META_BANKRUPTCY_FRANK`,
  `END_HL_SHUTTER_STARTED`; CSV'nin TR sütununda toplam 28 satır tire taşıyor (EN'de 27); Erdem'in 2026-10-20 kararı
  14 gereği tire kalkar (sorulmaz, yapılır), bu satırların tiresiz yazımı onay bekleyen metin işidir.
  `END_META_*_FRANK` satırları FRANK_ORPHANS'ta. Kaynak: ONERI_v3 K23, SONLAR_GAZETE_MODLAR §1.6 ve §5.6, SONLAR #17
  ve #21, PUSH_ONCESI_KONTROL §10.

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
  - Ürün: `PROD_TYPE_*_{DESC,TRADEOFF}`, `PROD_EV_{FIRST_SHIP,VERSION_SHIP,ITER_DECISION}_BODY`.
  - Finans ve VC: `VC_B1_*`…`VC_B4_*`, `VC_Q_*`, `VC_RES_*`, `VC_REACT_*`, `VC_WHY_*`, canlı `VC_EV_*` satırları
    (OFFER_EXPIRING_TITLE, GO_FUNDING, DECISION, LAST_DAY), `GATE_TRACTION_*`, `GATE_SERIES_A_*`,
    `TERM_FRANK_*`, `TERM_RESULT_*`, `FIN_MENTOR_QUOTE`.
  - Dünya, olay, son: `NEWS_S_*`, `NEWS_RIVAL_{UP,DOWN}_*`, `MONTH_FRANK_*`, `EFFECT_*`, `MENTOR_INTRO_BODY`,
    `END_{SA,ACQ,BK,BC,VC,BS,RF,GENERIC}*`, `END_META_*`, `END_EV_SHUTTER_*`, `END_EV_ACQ_{TITLE,ACCEPT,DECLINE}`.
  Kayıttaki bekletilen Frank metni (üç `PITCH_*`, `VC_EV_*` ve `END_EV_PIVOT_*` satırları) aşağıdaki Frank belgeleri
  maddesinde. Yalnız smoke'un okuduğu kayıt aileleri (`COMPANY_BG_*`, `PROD_FEAT_*_VOICE`, `PROD_TYPE_*_{BET,PITCH}`,
  `B2B_PAIN_*`) oyunda okunmuyor. Kayıt dışında da yalnız smoke'un okuduğu satırlar var: B2B'ye özgü `SECTOR_TEXTILE`,
  fikstür `SECTOR_TESTING` ve `SECTOR_FALLBACK`. Oyunda `SECTOR_` yalnız `ProductCatalog.type_sector_labels` ile ürün
  tiplerinin sektörlerinden kurulur; bu iki id hiçbir ürün tipinde yok ve o yolun yedek anahtarı yok. Kayıttaki
  referanssız emekli anahtarların çoğunu CSV süpürmesi sildi (84498d96); CSV'de kalanlar `VC_EV_OFFER_EXPIRING_BODY`
  ve `END_EV_ACQ_BODY` (ikisi de okuyucusuz). Açık: EN geçişi yapılsın mı. Kaynak: localization_draft_en.

- **Frank belgeleri (bu dosyalar kalır).** `docs/writing/FRANK_ORPHANS.md`: v6'da olmayan Frank satırları, satır satır
  sahip kararı bekliyor. `docs/writing/FRANK_UNWIRED.md` §4: D12. Seed kapısı: `funding.seed_door` kartı
  `SEED_DOOR_TITLE`, `SEED_DOOR_BODY` ve `SEED_DOOR_GO` metniyle 7946ff3'ten beri canlı; Frank v6 yüzey 12 bu kartı
  "yeniden tasarlanacak" diye metinsiz bırakıyor, metnin sahip onayı belirsiz. FRANK_UNWIRED §1, §5 ve §6 bayat: seed
  kapısının metni var, `goto_tab` fiili yedi kartta çalışıyor, `FIN_SUBTAB_INVESTMENT` EN'i "Funding"; belge
  güncellenmeli. `docs/writing/FRANK_VOICE_INVENTORY.md` kodu satır numarasıyla anıyor ve atıflar kaymış:
  `time_manager.gd:45` INITIAL_HOUR (sabit kodda artık yok), `:245-279` (günlük yuva sırası hâlâ artık olmayan
  EventManager'ı sayıyor; günlük dağıtıcı `TimeManager._dispatch_daily_tick`), `event_manager.gd:804-816` (dosya yok);
  `time_manager.gd` bugün 450 satır, öbür atıfları (:115-143, :344-355, :402-404) yeniden doğrulanmalı. Belgede 81
  ayrı dosya:satır atfı var; sahip bu gerçekleri tazeler ya da satır numaralarını sembol adına çevirir. Kodun
  okumadığı ama karar gelene kadar CSV'de kalan Frank metni: `VC_EV_DEAL_TITLE`, `DEAL_PROMPT_LINE`,
  `DEAL_PROMPT_SIT`, `DEAL_PROMPT_VALIDITY`, `DEAL_PROMPT_DEFER`, `VC_EV_ACK`, `END_EV_PIVOT_TITLE`,
  `END_EV_PIVOT_BODY`, `END_EV_PIVOT_ACCEPT`, `END_EV_PIVOT_DECLINE`, `PITCH_S0_NPC`, `PITCH_S0_INNER`,
  `PITCH_INNER_CLOSED`, `PROD_SHIP_VERSION_BODY`, `PROD_SHIP_FIRST_READY`, `PROD_SHIP_FIRST_BODY`,
  `PROD_DESIGN_DECISION_BODY`.

- **66 · `OFFICE_REQ_ANGEL`'ın TR metni onay bekliyor.**
  - Ne oluyor: İş hanının ilk şartı Frank'in çekidir (`GameState.run_angel_amount > 0`); çek seed değildir, tek çek,
    tur değil. Harita kartındaki şart satırı `OFFICE_REQ_ANGEL` kapıya uyar: EN "Frank's cheque taken", TR "Frank'in
    çeki alındı". TR satır sahibin onayından geçmedi.
  - Nerede: `localization/strings.csv` (`OFFICE_REQ_ANGEL`); `scripts/systems/office_system.gd`
    (`requirement_state`, "angel"); `scripts/ui/office/office_map_card.gd`.
  - Oyuncuya etkisi: TR ekranda onaysız bir satır.
  - Seçenekler: A) TR onaylanır. B) Sahip TR'yi yeniden yazar.
  - Kaynak: ofis tasarımının şart metni; CLAUDE.md §1, §5.

- **68 · Yeniden adlandırılan iki anahtarın TR metninde oyuncuya görünen tire.**
  - Ne oluyor: `DESK_PAPER_GATE_TITLE` (TR "Faz kapısı açık — karar bekliyor") ve `PERSONAL_MS_SHIP_NOTE` (TR "Ürün
    raflara çıktı — artık dünya da oynuyor.") metinlerini aynen taşıyor. EN tiresiz yeniden yazıldı ("Phase gate open:
    decision pending", "The product hit the shelves; now the world plays too."). `DESK_PAPER_SHEET_TITLE` tiresiz
    yazıldı ("Yatırım teklifi masada, son {weeks} hafta").
  - Nerede: `localization/strings.csv`; okuyanlar `scripts/ui/components/inbox.gd` ve `scripts/tabs/personal_tab.gd`
    (`_milestones`).
  - Oyuncuya etkisi: TR'de Olaylar gelen kutusu ve Kişisel'in Kilometre Taşları kartı ekranda tire gösteriyor
    (ch01 §9).
  - Seçenekler: Erdem'in 2026-10-20 kararı 14 gereği tire kalkar; iki TR satırı tiresiz yazılır, TR metni onay bekler.
  - Kaynak: ch01 §9; CLAUDE.md §5; Erdem, 2026-10-20 kararı 14.

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

- **89 · Okuyucusu olmayan iki gün sözlü anahtar: silinsin mi, bağlansın mı.**
  - Ne oluyor: `DEAL_PROMPT_VALIDITY` (TR "Geçerlilik: {days} gün", EN "Valid for {days} days") ve
    `VC_EV_OFFER_EXPIRING_BODY` (Frank'in "{days} gün içinde yanıt vermeliyiz" / "inside {days} days" satırı) hâlâ gün
    der. Haftalık modelde tike bağlı metin gün saymaz ve "bugün" demez (GDD Zaman Modeli §5). İkisini de kod, sahne ya
    da kart okumadığı için haftalık metin turu onlara dokunmadı (üçüncüsü `VC_EV_SKIP_MEETING` toplantı günü kartıyla
    birlikte silindi). Birincisi "Frank belgeleri" maddesinde, kodun okumadığı ama karar gelene kadar CSV'de kalan Frank
    metni arasında ve `docs/writing/FRANK_ORPHANS.md`'de satır kararı bekliyor; ikincisi DRAFT-EN kaydında CSV'de kalan
    referanssız anahtarlar arasında.
  - Nerede: `localization/strings.csv` (`DEAL_PROMPT_VALIDITY`, `VC_EV_OFFER_EXPIRING_BODY`).
  - Oyuncuya etkisi: Bugün yok, ekrana çıkmıyorlar. Bu hâlleriyle bağlanırlarsa yanlış birim söylerler.
  - Seçenekler: A) İkisi CSV'den silinir (ölü anahtar kuralı, CLAUDE.md §8). B) Bağlanırlar: önce haftalık metin yazılır
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
    değerli `funding.sheet_days_left`'i okur; onaylanınca o seam silinir.
  - Nerede: `localization/strings.csv`; `data/events/cards/world/final_stretch_verdict.json`,
    `data/events/cards/funding/sheet_expiry.json`; okuyanlar `scripts/systems/summary_system.gd` (`_pick_frank_line`),
    `scripts/systems/endings_system.gd` (`ending_frank_line`), `data/events/cards/funding/last_answer.json`;
    `scripts/events/seams/seams_ported.gd` (`funding.sheet_days_left`).
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
  - Ölçüm dört basamaklı merdivenle alındı (1× / 2× / 4×); 4× basamağı kalktı (`6d75ad84`), en hızlı basamak 3×, 3×
    ölçümü yeniden alınmadı. Masa sayıları C9b'de değişir (İş hanı 12, Plaza 38; Erdem 2026-10-20 kararı 6), ölçüm
    ondan sonra yenilenir. Ölçüm (`--office-crowd-probe`, 2026-10-09, bu makine; sıçrama, duraklatmada kıpırtı,
    takılma, poz hatası ve hata her koşuda 0; gece kapısı 0,14–0,26 sn, tavana hiç düşmedi). Kapıdan yürüyerek /
    kesmeyle çıkan, 1× / 2× / 4×: İş hanı 11 kişi her hızda 9 / 1, toplantı 2; Plaza 40 kişi 10 / 29, 10 / 29, 9 / 30,
    kuyruğa giren 9, 9, 10; Depo loft 70 kişi 7 / 59, 6 / 60, 5–6 / 60–61, kuyruğa giren 7–8, 4, 0. Çakışma sayacı
    (ayaktaki iki kişi 0,3 m'den yakın, kare başına), 1× / 2× / 4×: İş hanı 0 / 85 / 21, Plaza 15 / 537 / 145–157,
    Depo loft 16 / 39 / 93; 2× ve üstünde kaçınma kapalı olduğu için çakışmalar Plaza'da asansör önü koridorda, Depo
    loft'ta merdiven ağzında toplanır. Eski 1× ölçümüne göre (İş hanı 7 / 3, Plaza 22 / 18) İş hanı daha iyi, Plaza
    akşamı daha kötüdür; sırası gelen toplantının grup beklemesi bunun nedeni değildir (eski toplantı kuralıyla Plaza
    1× yine 10 / 29), akşamı kapı sırası belirler (`DOOR_S` kişi başına 3 oyun dakikası). Depo loft'ta sabah kapısı
    doludur (70 kişi tek tek, kişi başına yaklaşık 0,53 ambiyans sn); yavaş bir kare 4×'te dört kat oyun dakikası
    sürer ve kapı karede bir kişi alır, bu yüzden 4×'te gelişler ortalama yaklaşık 15 oyun dakikası geç kalır (masaya
    oturuşun ortancası 1×'te 10:47, 4×'te 11:14), ilk molalar öğle penceresine kayar (kısa mola 1×'te 23–25, 4×'te
    10–18; öğle 1×'te 12–15, 4×'te 14–16) ve kahve kuyruğu oluşmaz. Depo loft'ta 4×'in kare p99'u dokuz çiftin
    sekizinde 1×'ten %4–38 yüksektir (ortalama −%4…+%20, makine yüküyle değişir); aynı günün işi dört kat az kareye
    sığar: poz kare başına +0,6 ms, gün akışı +0,24 ms, kişilerin fizik tiki 2,0 ms'ye karşı 0,5 ms (tik başına dört
    kat yürüyüş; 1×'te bir kısmı kaçınma geri çağrısında koşar). Varsayılan 09:00–17:00 mesaide all-hands hiç olmuyor
    (17:00'de ofis boş).
  - Nerede: `scripts/systems/office_constants.gd`; `scripts/ui/office/office_venue.gd`, `office_people.gd`,
    `office_person.gd`.
  - Oyuncuya etkisi: İş hanı ve Plaza'da ofisin günü oyun saatinde her hızda aynıdır; Plaza 40'ta akşam kişilerin
    dörtte üçü masada kesilir. 2× ve üstünde kalabalık ofiste kişiler koridorda ve merdiven ağzında birbirinin içinden
    geçer. Depo loft'ta en hızlı basamakta (ölçüm 4×'te alındı) sabah kapı kuyruğu yavaş karelerle uzar, kahve kuyruğu
    oluşmaz ve kare süresi 1×'ten biraz yüksektir.
  - Seçenekler: A) Değerler mühürlenir. B) Sahip değiştirir (ör. all-hands 16:00, daha kısa `DOOR_S`). C) Huylar
    ritmi etkiler (trait task'ı; ISLER).
  - Kaynak: ofis karakterleri planı §2, §9 (Erdem, 2026-09-28).

- **95 · Görüşme metinleri; mevcut VC satırlarında tire ve tırnak.**
  - Ne oluyor: Görüşme akışının yeni anahtarları (`MEETING_*`: kicker'lar, VC ve satış rol adları, tutum ve risk
    sözcükleri, sonuç kartı, davet, dönüş sorusu, `MEETING_ROLE_LINE`, `MEETING_RES_PAIR`, `MEETING_RES_COST_BRAND`)
    EN önce yazıldı, TR tasarımın ifadelerini izler; onay bekliyor. Panel mevcut VC satırlarını olduğu gibi gösterir:
    bazılarında tire var (`VC_B4_CALLBACK`, `VC_B4_PUSH`; `VC_B1_LINE` ve `VC_B1_CHOICE` Faz Q K12'de tiresiz yazıldı)
    ve karşı taraf satırları tırnak içinde (24 `VC_` anahtarı; tasarımda tırnak yok). Satış satırlarında `PH:` öneki
    kalmadı (43e0a28).
  - Nerede: `localization/strings.csv`.
  - Seçenekler: A) Yeni metin onaylanır. B) Sahip yeniden yazar; tırnaklar kalkar (LANGUAGE INTEGRITY LAW). Tire
    Erdem'in 2026-10-20 kararı 14 gereği kalkar.
  - Kaynak: CLAUDE.md §3, §5; 1888fe4, eba2140, 4ebcc5d, cf80260.

## Kod ve test altyapısı

- **EA/tam'da kalan "yakında" izleri.** Av'daki kilitli "— · Tier 2'de" fon satırı (`InvestorRegistry` `locked_tier2`)
  ve Pazarlama sekmesinin koşulsuz `"lock": "ea"` kilidi her build'de görünüyor. Seçenekler: build kapsamına bağla ya da
  olduğu gibi bırak. Kaynak: SONLAR_GAZETE_MODLAR §U.4 madde 3.

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
  - `finance.valuation` · Yatırım. Seam kuruldu (`seams_finance.gd`, `GameState.get_valuation_m()`: imzalı Series A'nın
    post-money'si, yoksa seed'inki, yoksa 0,0). Açık kalan: `InvestorRegistry.INVESTORS[*].opening_terms`'teki donmuş
    `valuation_m` ve `dilution_pct` hiçbir yerde okunmuyor; Series A açılış şartları ARR'den türetiliyor
    (`VCPitchSystem._derive_series_a_terms` registry'den yalnız `board_seats` ve `board_veto` okur). Açık: bu iki rakam
    silinsin mi (`opening_terms` yalnız kurul şartlarını taşır), yoksa Series A türetimine fon başına taban ya da
    tavan olarak mı bağlansın (ch09 §5). Satın alma kartının kendi fiyatı var (`EndingsSystem.acquisition_valuation()`,
    seam `funding.acq_valuation`). `docs/writing/FRANK_UNWIRED.md`'nin "Waiting on" listesi bu rakamları aday sayıyor
    ama aynı belge değerlemenin `acquisition_valuation()` ile çözüldüğünü de yazıyor; bayat.
  - `sales.market_share_by_segment()` · Satış / Rakipler. ch10 §2 segment başına pay istiyor; bugün
    tek küresel pay var (`sales.market_share_pct`). ch10 §8 pay formülünü ayrı bir tasarım oturumuna bırakır.
  - `destek.queue_length()` · Operasyon. Açık talep listesi `CustomerRepSystem._open_requests()`
    içinde ve özel; seam yok.
  - `rival.is_ahead_of_player()` · Rakipler. Hesap `VCPitchSystem._rival_ahead()` içinde, özel ve
    yanlış modülde.
  - `urun.tech_debt` seviye olarak · Ürün. Bugün yalnız bayrak var (`tech_debt_birikti`). Ürün §20
    teknoloji borcunu demodan çıkarır ve §23'te EA sorusu sayar; ch06 §1.4 ve ch14 §2 demoda sayar.
  Kapananlar: `finance.runway_months` ve `finance.runway_weeks` kayıtlı; `finance.valuation` kayıtlı; `founder.energy`
  Ekip §2 ile iptal (enerji barı yok).
  Kaynak: SEAM_REGISTRY §7.

- **71 · Kalabalık Depo loft'un kare maliyeti.**
  - Ne oluyor: Kişiler Quaternius gövdeleridir; aynı görünüm ve parçalar mesh önbelleğini paylaşır, poz ekran boyuna
    göre seyrelir (LOD). 70 kişilik Depo loft 4×'te (eski merdivenin 4×'ü, bugünkü 1×'in temposu) ortalama kare ~9,9 ms
    (ölçüm sondasının payı dahil; sondasız ~8,4 ms), 40 kişilik Plaza ~5,8 ms (180 Hz ekranın sınırında). Eski Xbot
    kadrosu 70 kişide ~6 ms'ydi; plan hedefi 40 kişide ≤8 ms tutuyor, 70 kişide aşılıyor.
  - Nerede: `scripts/ui/office/office_person.gd` (`LOD`, `OFF_SCREEN`), `office_body.gd`, `office_people.gd`.
  - Oyuncuya etkisi: Büyük kadroda zayıf makinede kare düşebilir.
  - Seçenekler: A) LOD turu: uzaktaki ve oturan kişilerin pozu daha seyrek, kaçınma yalnız yürüyende. B) Kalır;
    ölçüm hedef donanımda tekrarlanır.
  - Kaynak: `--office-crowd-probe=loft:70:4` ve `plaza:40:4` ölçümü (2026-09-28, eski merdiven; probe bugün hız 1-3
    kabul eder, aynı tempo `:1`).

- **72 · Harita kartı küçük resimlerindeki Mixamo X Bot figürleri: lisans onayı.**
  - Ne oluyor: Ofis kişileri artık Quaternius karakterleridir (CC0, `assets/art/people/LICENSES/`); X Bot dosyası
    repodan çıktı. X Bot yalnız şehir haritası kartlarının küçük resimlerinde, tasarımın kendi çizdiği figürler olarak
    kaldı. Mixamo koşulları karakterin oyunlarda telif ücretsiz kullanımına izin verir; ticari sürüm için sahibin onayı
    yok.
  - Nerede: `assets/art/office/thumb_*.jpg`, `assets/art/office/README.md`, `tools/office3d/README.md`.
  - Oyuncuya etkisi: Yok; küçük resimlerin hukuki dayanağı.
  - Seçenekler: A) README notu yeterli sayılır. B) Küçük resimler Quaternius karakterleriyle ya da kişisiz yeniden
    üretilir (render hattı aynı; ISLER).
  - Kaynak: `assets/art/office/README.md`; ofis tasarımı (`office-sim-v12.js` `loadXbot`).

- **74 · Güncel olmayan ofis çipleri ve güncel ofis hapı koyu çiftle çiziliyor.**
  - Ne oluyor: Şehir haritasında güncel olmayan ofislerin çipleri ve harita kartındaki güncel ofis hapı 3B dioramanın
    üstünde `BG_TOPBAR` zemin ve `CREAM` yazıyla çiziliyor; tasarımın niyeti bu (güncel ofisin çipi amber `BADGE_*`).
    CLAUDE.md §7 koyu çifti çerçeveye (TopBar, NewsTicker) ayırıyor, bu iki yüzey listede yok.
  - Nerede: `scripts/ui/office/office_city.gd` (güncel olmayan ofis çipleri); `scripts/ui/office/office_map_card.gd`
    (güncel ofis hapı).
  - Oyuncuya etkisi: Yok.
  - Seçenekler: A) §7'ye "3B ofisin üstündeki çip ve haplar" eklenir. B) Krem çifte dönerler.
  - Kaynak: ofis tasarımı; CLAUDE.md §7.

- **87 · Lint: her kesinti kartında `expires_weeks` zorunlu; gün adı kuralı değerlere de bakıyor.**
  - Ne oluyor: (1) §17.7 denetimi her kâğıt ve her kesinti kartında `expires_weeks` ister. Kritik kesinti hiç
    bildirime düşmez, o kartlardaki değer hiç okunmaz. Canlı destede `critical` etiketi taşımayan kesinti kartı 18'dir
    (ör. `sales.price_break`, `customer.retention`, `team.burnout`, `product.promise_due`, `rival.price_cut`);
    `funding.shutter_warning` gibi kritik kesintiler ayrı bir kümedir. (2) Gün adı kuralı (§17.1) yalnız anahtarlara
    değil, tanımlayıcı biçimli dize değerlerine de bakar (`^[a-z0-9_.]+$`): `_days` ya da `days_since` içeren ya da
    `days`'e eşit değer hatadır. Böylece `history` biçimi `days_since`, eski `delay_days` fiili ve `*_days_*` adlı
    seam de yakalanır.
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

- **105 · Piyasa artımlı kurulmuyor: pencere açıkken her hafta bir kare takılıyor.**
  - Ne oluyor: Piyasa penceresi her hafta dönümünde (`day_advanced`) ve hisse dağılımı değişince (`equity_changed`:
    Frank'in çeki, seed imzası) baştan kurulur: üç karo, listenin bütün satırları ve seçili şirketin kartı. Kurulum
    gece adımının karesinden çıkarıldı, adımdan sonraki karede koşar; işi aynıdır, yalnız karesi değişti. Ölçüm
    (başsız, iki koşu): `--tick-probe=1:piyasa` gece karesi (`TICK|night` max) 38,3 ve 62,7 ms, pencere kapalıyken
    (`--tick-probe=1`) 65,3 ve 52,1 ms; kurulumun karesi (`TICK|after_night` max) 112,3 ve 113,6 ms, pencere
    kapalıyken 0,4 ve 0,3 ms; kare bütçesi 60 Hz'te 16,7 ms.
    Artımlı kurulum yapılmadı: sayfanın tek kurulum yolu baştan kurmaktır (`UiFactory.clear` ve yeniden kurma);
    değeri yerinde yazmak satır, karo ve kart düğümlerinin tutulmasını ister.
  - Nerede: `scripts/tabs/piyasa_tab.gd` (`_queue_build`, `_build`, `_build_tiles`, `_build_list`, `_build_card`).
  - Oyuncuya etkisi: Piyasa açıkken her hafta, gece bittikten hemen sonra bir takılma; pencere kapalıyken yok.
  - Seçenekler: A) Kabul: takılma yalnız Piyasa açıkken ve haftada bir. B) Artımlı kurulum: satır, karo ve kart
    düğümleri kalır; haftada yalnız rakamlar, sıra ve grafik verisi yazılır. C) Kurulum birkaç kareye bölünür
    (karolar ve kart önce, liste sonra).
  - Kaynak: `--tick-probe` ölçümü (2026-10-10); yardımcı yönetmen hükmü A9, 2026-10-10 (kurulum gece karesinden
    ayrı kareye taşınır, artımlı kurulum ayrı iştir).

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

- **EA/tam'da kârlı bootstrap kilometre taşıdır (f50d481).** Sahibin 2026-09-25 kararları: EA/tam'da kayıp sonları
  koşuyu bitirir. Kârlı bootstrap gazeteyi bir kez açar, DEVAM ET ile koşu sürer, 104 haftalık tavan kalkar ve
  final_stretch telgrafı susar. Frank şeridi, wishlist ve "SIRADA NE VAR?" kartları yalnız demo'da. ch13 §1
  bootstrap'ı zafer sonu, ch01 §1 730 günü (bugün 104 hafta) tavan, ch13 §2 Frank şeridini son ekranının öğesi
  sayıyor. Açık: ch13 §1–§2 ve galeri (§4) güncellensin mi. Kaynak: HANDOFF_series_a §D ve §H.2.

- **Seed garanti basamaktır (7946ff3, sahip hükmü 2026-08-27).** Seed odası reddedemez, seed teklifi dolmaz, masadan kalkmak
  ZOR MOD kilidinde; Frank'in mühürlü seed satırları buna dayanıyor. ch09 §3 seed için "kabul / bir kez pazarlık / ret" ve retle
  açık kalan bootstrap yolunu, ch09 §4 "şimdi değil" sonucunu tanımlıyor. Açık: ch09 §3–§4 güncellensin mi; tasarım soruları
  K18–K22'de. Kaynak: ACIK_KARARLAR_D1-D13 B3.

- **Frank sahnede görünmez.** `docs/content/events_draft/Frank Diyalogları · v6.md` ("Frank'in kanalı telefon"): anlatıcı
  Frank'i odaya sokmaz, Frank nerede olduğunu yalnız kendisi söyler. Yürürlükteki GDD'lerde bu kural yok (ch14 §7 yalnız portreyi
  ve kart gramerini tanımlıyor). Kurala takılan canlı metin: `GATE_SERIES_A_BODY_0` ("Frank telefonunu ters çevirip masaya
  koyuyor"). Açık: ch11 §7 ya da ch14 §7'ye işlensin mi. Kaynak: VIZYON_v1_YANITLAR §1.2 ve §3-C.

- **Oyuncu metnini kim yazar.** Sahibin kararı (2026-09-26, `61f38bc`; CLAUDE.md §5): ajan oyuncu metnini önce
  İngilizce yazar, Türkçe ayrı bir yerelleştirme adımıdır; Erdem ikisini düzeltir; Frank satırları yalnız taslak. ch14
  §2 "olay metnini yönetmen tarafı yazar, ajanlar yazmaz" diyor. Açık: ch14 §2 güncellensin mi. Kaynak:
  HANDOFF_series_a §F.

- **Ürün rev 7 sprint döngüsü canlı, eski akış silindi (sahip kararı 2026-10-01).** Geçiş bayrağı yoktur; Ürün
  sekmesi sprint ekranıdır ve canlı veriyle çalışır (`SprintSystem`, `SprintCatalog`, `SprintBridges`,
  `GameState.product`). Eski Konsept, yapım ve yayın akışı, eski sekme ve onları sınayan smoke
  vakaları silindi. Kural `GDDs/GUNCELLEMELER.md` "Ürün rev 7" bölümüne işlendi; GDD ch03 rev 6.1 .docx hâlâ eski akışı
  (Konsept, yayın akışı, kapasite bloğu, fiyat paneli, Frank şeridi, monitör), ch12 .docx §3 ve §5 eski ev sahiplerini
  ve onboarding'in Konsept'e açılmasını anlatıyor. Ajanın verdiği kararlar 96'dadır. Açık: ch03 ve ch12 .docx rev 7'ye
  güncellensin mi. Kaynak: `docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md`; GUNCELLEMELER "Ürün rev 7".

- **Üst barın saati kendi bloğunda (tasarım sistemi, sahip onayı 2026-10-02).** Üst bar tarihi ve saati ayrı
  bloklarda gösterir: gün bloğu tarihi (`DATE_LINE`, "Hafta 14 · Nisan 2012"; dar genişlikte `TOPBAR_DATE_COMPACT`,
  "H14 · Nis") ve hafta çubuğunu, saat bloğu saati ve hız tuşlarını taşır (`top_bar.gd`). ZAMAN MODELİ §5 TopBar'ın
  saati tarih satırına eklediğini ("Hafta 14 · Nisan 2012 · 09:00") ve kısa biçimi `TOPBAR_CLOCK_COMPACT`
  ("H14 · Nis · 09:00") anlatıyor; o anahtar silindi. Açık: ZAMAN MODELİ §5 ya da GUNCELLEMELER güncellensin mi.
  Kaynak: Menajer Masası tasarım sistemi (Erdem 2026-10-02, "UI approved").

- **103 · Verim: kişi başı haftalık çıktı yüzdesi (sahip kararı 2026-10-08, GDD'ye işlenmemiş).** Sahibin kararları:
  (1) verim çalışanın üstüne gelindiğinde görünsün (Software Inc'teki gibi) ve haftalık çıktı hızı gerçekten ona
  bağlansın; (2) ofis kademesi gibi etkenler artı versin, düşük moral ve fazla mesai eksi; (3) olay kartı bir kişinin
  hızını süreli düşürebilsin; (4) "ben yaparım" seçenekleri kurucunun verimine yazılsın, kurucunun morali ve enerji
  barı yoktur hükmü değişmez; (5) olayların hız artışı kalsın, Ekip GDD §8.4'ün "ayrı hız bonusu yoktur" cümlesi olay
  kartları için esnesin. Kodda olan: moral payı, olay satırları ve gün içi verim eğrisi (`HRSystem.productivity`,
  `CharacterRegistry.add_productivity_mod`; Ekip satırının ipucu ve ekip dosyasının VERİM bölümü "Verim %84 → %72" der;
  olay motoru md'si §27.15). Moral payı ve gün içi eğri GUNCELLEMELER Ekip §4.5 ve §8.2 maddelerindedir
  (`docs/tasks/PRD_EKIP_VERIM_DESTEK.md` §3 V1; sayılar [WORKING]). Ofis artısı yok: sahibin 2026-10-20 kararı ofisin
  getirisini yalnız itibar sıçraması yapıyor; (2)'nin ofis yarısını Faz C'nin C9a'sı kapatır. Değişen hükümler: Ekip
  GDD §2.2 (kısmi kapasite yok), §4.2 ve §8.5 (yüzdeler ekranda görünmez), §8.4 (ayrı hız çarpanı yok; GUNCELLEMELER
  §8.2 maddesi de "ayrı hız bonusu hâlâ yoktur" der, olay satırının en çok +%30'u ile çelişir), §7 (süreli uyarı bu
  modülde yok). Açık: (3)-(5) GUNCELLEMELER'e işlensin mi. Üç alt karar **onay bekliyor**: (a) verimin kenet aralığı
  %40 ile %130 mu (bugün toplam verim kenetli değil: yalnız olay satırlarının çarpımı 0,50 ile 1,30 arasına kenetli,
  moral payıyla verim 0,45 ile 1,43 arasında kalır); (b) huy ve toplantı payı sprinte de girsin mi
  (`SprintSystem._points` huy çarpanını okumaz; çıktıyı değiştirir); (c) tek başına kurucu tavanı (en çok −%30, 2 hafta)
  uygun mu (tavan satır başınadır: iki kart birlikte kurucuyu yine 0,50 tabanına indirebilir). Ayrıca **onay
  bekliyor**: satış masasının işleme süresi (`SalesRepSystem._desk_halfweeks`) verimin tamamını, moral payı dahil okur;
  moralin satışa girmesi kalibre ekonomiyi oynatır. Kaynak: yazar pilotu klasöründeki
  `research/verimlilik/TASARIM_NOTU_VERIM.md` §1 ve §8 (repo dışında).

- **106 · Sprint turu: dürüst plan, sürüm anı, oyuncunun onayı, B2C okuması (sahip kararları 2026-10-10, GDD'ye
  işlenmemiş).** Sahibin kararları: artık puan sonraki karta akar, kapasite ve hız kesirlidir (B1); plan tahmini
  motorun oynatmasından gelir ("devreder", "başlamaz", SPRINT SONUNDA yalnız bitenler), "+" eklendikten sonraki yükü
  %125'le sınar ve kart bu sprintte puan alamayacaksa kapalıdır (B2, B-K1); sürüm koşulu ve MVP tahmini plan, aktif ve
  sürüm notu kiplerinde tek satırdır, MVP öncesi not "kart kaldı" der (B3); MVP'de
  sürüm kapısı Yayınla / Bir sprint daha, v1.1 ve sonrası kendiliğinden, bot Yayınla seçer (B4); yayından sonra B2C
  okunur: Ürün başlığı, Satış'ın B2C sayfası, sürüm notunda ilk kullanıcılar, evreye göre boş hâller; haftalık kitle
  örneği son 26 hafta (B5, B-K9); koşan sprint okunur: "Sırada", faz puanı, sayaç, tek kartlı sprintte devret uyarısı
  (B6); sprint oyuncunun onayı olmadan başlamaz (B7): plan tutuşu sürüm notu kipinde de alınır (B-K2), planlanacak
  kart yokken boş sprint kendiliğinden başlar (B-K3), boş geçirme oyuncunun açık onayıdır (B-K4), devirde sprint
  `plan_next`'te ya da saat sürdürülünce başlar (B-K5), kapı devirde de oyuncuyu bekler (B-K6), "Sprinti başlat" saati
  akıtmaz (B-K10); lider yalnız bitecek kartları ve en çok bir devreden kartı önerir, PM planları toplamla kalır,
  lider kurucuysa "Kendi notun" (B8, B-K7); mesai modali sprint puanı etkisini ve "Kurucu + N çalışan"ı yazar (B9);
  belgeler (B10). Kural GUNCELLEMELER "Ürün rev 7" bölümüne ("sprint turunun sahip kararları" maddesi) ve PRD rev 7
  §3.5, §3.6, §3.8, §3.9, §3.11'e işlendi; GDD ch03 rev 6.1 .docx yapımı ve yayını, Ekip GDD'si mesai modalini bu
  kararlar olmadan anlatır. Açık: ch03 ve Ekip GDD'si .docx güncellensin mi. Kaynak: `docs/tasks/PRD_SPRINT.md` §0, §2, §3,
  §6.

- **107 · Onarım 1 sahip kararları (2026-10-11, dördü de uygulandı).** (a) Onboarding tabanı, O19 `419ee6e`; (b) tek para
  tabanı, O17 `2870897` (ek mesai ücreti takvim günü oranıyla işler, ay 22 iş günü kadar mesai öder); (c) bedelsiz
  taşınma (ACIK 60 · C), O18 `c24f213`; (d) `WARM_INTRO_MISMATCH_MULT` 0,5, O20 `324ba37`. (a), (c), (d) ve Risk nedeni
  GUNCELLEMELER'e işlendi; (b) işlenmedi. (c) Faz C'nin C9a'sında değişir (sahip kararı 2026-10-20: taşınmanın peşin
  bedeli iki aylık kira).
  - Açık: (b) GUNCELLEMELER'e işlensin mi. Risk nedeninin ayrılması (PRD §11.7; `Inbox.risk_reason`: hesabın hatlarındaki
    açık hata şikayet kapısını aşarsa kesinti, değilse `trust_offset >= 0` ise kararlılık, değilse memnuniyet) ve beş
    metnin TR/EN'i onay bekliyor (`PROD_TYPE_ERP_TRADEOFF`, `PROD_PATH_B2B_DESC` dahil).
  - Kaynak: `docs/tasks/PRD_ONARIM_1.md` §2.3, §4.2, §6, §11.
- **108 · Traction gerilimi gider tarafından.**
  - Ne oluyor: Onboarding tabanı (O19 `419ee6e`) erken B2B hesaplarını tutunca Traction haftalarında runway'in sonlu
    kaldığı pay (`finite_runway_p2`, 98'in ölçüsü) 0,24'ten 0,09'a indi; satış süreci (O22) onu 0,13'e getirdi. Ölçüm
    (`full_run:40:sim:1..20`, bot; taban O19 ve O20): O22'nin taban süreleri 2/3/6/8/12 hafta ile 0,13; 2/4/6/8/12 ile
    0,14; 3/4/6/8/12 ile 0,12. Süreyi uzatmak payı yükseltmiyor: gelir gecikince botun Frank çeki, seed'i ve işe alımı da
    gecikiyor (`run_probe.gd` `STAFF_LADDER`: test uzmanı 3K, satış temsilcisi 4K MRR'da; `_hire_after_the_seed`), yakma
    MRR'ı izliyor. Gerilim gelir tarafından gelmiyor, gider tarafında aranır.
  - Nerede: Traction'ın gider kalemleri (`FinanceSystem`; 98'in ölçtüğü kaldıraçlar: koltuk, hesap; gider kalemleri
    maaş, ek mesai, pazarlama, ofis (bugün 0, Faz C C9 yazar) ve sunucudur, araç ve servis gideri `2e8dfad2` ile
    kalktı),
    maaşlar (`HRConstants` seviye bantları), işe alımın temposu (büyümenin ekip gereksinimi; botta `STAFF_LADDER`).
  - Oyuncuya etkisi: B2B koşusunda Traction'ın çoğu haftası nakit fazlası verir; runway baskısı erken oyunda zayıf kalır.
  - Seçenekler (uygulama yok): A) Traction'a faza bağlı gider (ofis, pazarlama), 98'in seed öncesi iflas
    uyarısıyla birlikte ölçülür. B) Maaşlar: seviye fiyatı ya da Traction'da artış. C) İşe alım temposu: büyümenin ekip
    gereksinimi (ör. hesap başına destek, sürüm başına test). D) Bekle: Pazar 2'nin gelir modeli ve Faz E (`PRD_URUN_DERINLIK`)
    ekonomiyi yeniden oynatacak; gelir ve gider birlikte ele alınır, ölçüm Faz C'nin E2'sinde tekrarlanır.
  - Kaynak: sahip kararı 2026-10-11 (yardımcı yönetmen iletti: 0,15 eşiği O22'nin emniyetiydi, O22 süreleriyle olduğu
    gibi girdi; gider tarafı bu maddede, uygulama yok); 98; O19 `419ee6e`; O22; ölçüm kayıtları repo dışında.

- **109 · Menü sonrası açıklar (ana menü işine alınmadı).**
  - Xbot küçük resimleri (`assets/art/office/thumb_<id>.jpg`): lisansı doğrulanmadığı için yayın engeli sayılır; karar
    ACIK_KARARLAR 72'de.
  - `use_custom_user_dir` ve göç: `user://` bugün `%APPDATA%/Godot/app_userdata/Project Unicorn`'dur, `project.godot`'ta `use_custom_user_dir` yoktur. Steam Auto-Cloud sabit, ada bağlı bir kök yol ister; açılırsa mevcut kayıtlar yeni dizine taşınır (göç adımı şart). Seçenekler (uygulama yok): açıp göçü yazmak ya da Auto-Cloud kullanılmayacaksa bırakmak.
  - Steam istek listesi: menüde 'İstek listesine ekle' düğmesi yoktur. Sonlardaki WISHLIST'E EKLE'nin mağaza adresi boştur (`ending_scene.gd`) ve basılınca bir şey yapmaz; adres gelince menüde de olup olmayacağı ve yeri sahibin.
  - UI tık sesi ve menü müziği: menüde bugünkü tek parça çalar; SFX bus'ında oynatıcı olmadığından Ayarlar'da Efektler kaydırıcısı kapalıdır (`SET_SFX_NONE`). Tık sesi ve menüye ayrı parça, parçanın kaynağı ve lisansı (`Döngü Modu.mp3`) açılana dek yapılmaz.
  - Kaynak: ana menü denetimi (L5, D6, M7, M8); sahip kararı 2026-10-11 (istek listesi menüden düştü; D6 ve M7 ertelendi).
