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
  `DEAL_PROMPT_SIT`, `DEAL_PROMPT_VALIDITY`, `DEAL_PROMPT_DEFER`, `VC_EV_ENTER_MEETING`, `VC_EV_SKIP_MEETING`, `VC_EV_ACK`,
  `END_EV_PIVOT_TITLE`, `END_EV_PIVOT_BODY`, `END_EV_PIVOT_ACCEPT`, `END_EV_PIVOT_DECLINE`, `PITCH_S0_NPC`, `PITCH_S0_INNER`,
  `PITCH_INNER_CLOSED`, `PROD_SHIP_VERSION_BODY`, `PROD_SHIP_FIRST_READY`, `PROD_SHIP_FIRST_BODY`,
  `PROD_DESIGN_CEILING_NOTE`, `PROD_DESIGN_DECISION_BODY`, `PROD_ITER_CEILING_NOTE`.

## Kod ve test altyapısı

- **İki build kaynağı.** Kart kapsamı `EvTuning.SHIPPED_SCOPES` her build'de `["demo"]`; build'i okuyan yalnız sonlar
  (`EndingsSystem.build_scope()`). İlk `ea` kapsamlı kart gelmeden ikisi tek kaynağa bağlanmalı, yoksa o kart EA build'de
  hiç gelmez. Projede export ön ayarı henüz yok; `ea` etiketi olmayan bir EA export'u demo gibi davranır.
  Kaynak: SONLAR_GAZETE_MODLAR §U.2 ve §U.4 madde 2, RAPOR_LOKAL "Onay bekliyor" madde 3.

- **EA/tam'da kalan "yakında" izleri.** Av'daki kilitli "— · Tier 2'de" fon satırı (`InvestorRegistry` `locked_tier2`)
  ve Pazarlama sekmesinin koşulsuz `"lock": "ea"` kilidi her build'de görünüyor. Seçenekler: build kapsamına bağla ya da
  olduğu gibi bırak. Kaynak: SONLAR_GAZETE_MODLAR §U.4 madde 3.

- **`EvTuning.TICKER_CAPACITY`.** Hiçbir yer okumuyor. Olay motoru GDD §18.2 "kapasite ~20, taşınca en eski düşer" diyor.
  `NewsFeedSystem`'in "biz" tamponu 10 satır ve taşınca en yeni satır düşüyor. Seçenekler: bağla ya da emekliye ayır
  (GDD'yi günceller). Kaynak: SONLAR_GAZETE_MODLAR §6.2, SONLAR #19.

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

- **Doğrulanmamış hata şüpheleri.** Okuyucu ajan bildirdi, kimse doğrulamadı: `VC_Q_SOLO` hiç çıkmıyor; `run_investment_amount`
  pre-money değeri post-money gibi kullanıyor; 1. vuruş "Algı" etiketli ama zar Karizma ile atılıyor; VC kurucu konuşmadan "Beni
  ikna etmedi" diyor; iç ses gelecek zamanda; Av görüşmeden sonra yenilenmiyor; `meeting_day` butonunun etiketi yanlış; seed
  görüşmesi `run_pitches`'i artırıyor; `_sheet_for` seed teklifini seçebiliyor. Kaynak: ONERI_v3 §2 (🔎 listesi).

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
