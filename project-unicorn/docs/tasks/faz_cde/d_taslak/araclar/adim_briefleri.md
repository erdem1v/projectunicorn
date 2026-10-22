# Faz B adım brief'leri (taslak; B0'dan sonra A'nın gerçek adlarıyla tazelenir)
Her adım `faz_b_step.js` iş akışıyla koşar: args = {step, effort, brief, gates, shots}. Commit ana oturumda.
Ortak kapılar her adımda: `--event-lint`, `loc_residue`, `smoke_run.sh loc_csv_integrity`, her yeni kart `--why-fire`,
bağlama adımlarında `python -I <SP>/textparity.py <ROOT> --wave Wn --ids <önekler>`.

## B1 · Mail ve bildirim saatleri (Sonnet max)
Girdi: `b_taslak/B0t_MAIL_SAATLERI.md` §5 (B0'da A'ya göre tazelenmiş hâli). PRD Karar 4 (gece yalnız acil kart; öbürü
mesai başına kadar bekler), Karar 21, §4.4.
- `at` alanı (mutlak dakika, −1 saatsiz), küçük statik `MailClock` (pencere, geliş saati çekimi `EvDice.unit`, saatlik
  salıverme). Mesajlar dış kutu (`GameState.mail_outbox`); motor kartları ve geçmiş damga + okuma süzgeci (varlık
  okumaları süzülmez: R2); hatırlatıcılar `GameState.desk_arrivals` ilk görülme defteri; Frank satırı `mentor_line_at`;
  haber bandı canlı satırları dinleyicide bekler; acil ayrımı `terminal_warning` / `urgent` etiketi ve kuyrukta `urgent`.
- Sinyal yayınları (`summary_ready`, `product_note_issued`, `weekly_sales_report_issued`) salıverme anına taşınır.
- `mail_pane` o anki saati değil damgayı gösterir; liste ve kart başlığı ss:dd.
- Şema 17 (A'nın 16'sının üstüne; göç yok, yeni alanlar varsayılan taşır, eski kayıt "saatsiz").
- Yayılım 4 saat [WORKING], `expires_weeks: 1` kâğıtlar 1 saat [WORKING] (onay bekliyor).
- 00:00 saatlik dilimi `advance_day`'den önce koşar (R8); `_sim_day`/`_sim_day_full` yardımcılarının gecikmeyle uyumu
  (R1) B1'in kararı, raporda.
- Kapsam dışı: sprint planı kapısı (R10). Otomatik açılışın öğlene kayması (R9) raporda ⚠️ olarak Erdem'e.
- Kapı: yeni smoke `inbox_no_night_stamp` (104 hafta, iki pencere 08–17 ve 11–24; falsification: dış kutu kapatılınca
  FAIL), etkilenen mevcut smoke önekleri (event_*, inbox*, summary*, rnd_note*, sales_report*), `plausibility_run.sh`,
  `run_gate.sh`. Görsel: `--inbox-shot` yeni "gece sonrası sabah" durumu (00:00 ve mesai başı + 30 dk) TR ve EN.

## B2 · Motor fiilleri (Sonnet xhigh)
- `amount_seam` (+ `amount_mult`): ekonomik fiilin tutarı bir seam'den (`add_cash`, `audience_delta` ve gerekirse
  ödeyen kaybı). `EvEffects._amount` ve `EvChips.describe` aynı yardımcıyı okur; çip = uygulanan.
- `trust_delta {amount, accounts: slot | decision_line | incident}`: kalıcı memnuniyet izi `trust_offset` üstünden,
  sahibinin seam'iyle (`CustomerRegistry`). Süren erteleme bedeli ("her sprint sonunda −3") B4'te.
- Kişiye moral: adlı ödeyen listesine moral (Karar 6 sırası: hattında koşan sprintte kartı olan yazılımcı ve testçi;
  yoksa Görevler matrisinde Yapım ya da Test işindekiler; ikisi boşsa seçenek kilitli). Çip adları yazar
  (`EFFECT_NIGHT_CREW`).
- W1'in çip şablonları `strings.csv`'ye (bayt eşliği). `--event-vocab`, `gen_signal_manifest.py`.
- Kapı: smoke `event_amount_seam`, `event_trust_delta_lasting` (bir tik sonra iz durur ve çipteki sayı oyuncunun
  gördüğü değer), `event_chip_coverage`; `--sprint-probe=hours=8:cards=2:ticks=12:events=1` (PRED = CLOSE).

## B3 · Acil durum sistemi ve kesinti kartları (Sonnet max)
- `IncidentSystem` (ya da `GameState`'te tek sözlük): haftalık tehlike `BASE 0,10 × kademe × doluluk_çarpanı() (=1)
  × (1 + min(açık hata, 12)/8)`, tavan; en az 4 hafta aralık, sonrası rastgele (hash'li zar, kayıt güvenli); olay
  kapısı reddederse olay başlamamış sayılır (aralık sayacı, bedel, tutuş ilerlemez). Kademe çarpanı `sprint.json`
  `incident.tier`; `InfraSystem.provider()` okunur. Yük sebep cümlesi yok.
- Saat: kesinti 00:30–04:30 başlar, kart ilk tam saatte açılır, mail kartla aynı saatte damgalanır (W1 kararı), gövde
  başlama saatini söyler. `hold_clock("incident")` yalnız `request` true dönerse; kart gösterilince bırakılır; pompa
  kartı düşürürse bırakılır. Gece yalnız acil kart; karar sonrası mesai başına kadar başka kart açılmaz. `EvQueue.rank`
  acil kartı son uyarının önüne alır. 00:00 adımı kullanılmaz.
- Kartlar: `product.incident_outage_b2b`, `_b2c` (W1, bayt eşliği); eski `outage.json` ve `EV_PRODUCT_OUTAGE_*` silinir.
  `system: true`, `critical`, `urgent`.
- Bedeller: B2B kredi kademeleri %10/%15/%25 (7 ve 12 saat) `FinanceSystem.apply_one_time_cost`, `mrr` değişmez;
  sabah yolu güven izi saat başı −0,6 en çok −8 (kredide %85 silinir); B2C anlık kitle düşüşü %0,3 × saat en çok %4;
  bir ay ücretsiz (gider yalnız ödeyen payı); kendin düzelt verim −%15 1 hafta (`productivity_mod`); ekip moral −10.
- Prob: `--sprint-probe` `market=`, `incident=<tür>@<tik>` dize ayrıştırma, pazara göre ürün (`erp`), PRD rollerini
  veren kadro (`team=3` tasarımcı, yazılımcı, testçi). Harness değişikliği ayrı raporlanır.
- Kapı: smoke `incident_gap_and_spread` (300 hafta: en küçük aralık ≥4, aralıkların ≥%30'u 4–6 dışı),
  `incident_night_hold_resumes` (03:00'te açılır; kuyrukta süresi dolan kâğıt varken de acil kart; karar sonrası mesai
  başına kadar kart yok; 00:00'da istek yok; falsification), `incident_scale` (kredi = kademe × aylık ücret, `mrr`
  değişmez, B2C orantılı), `incident_save_roundtrip`; `--why-fire`; plausibility. Görsel: `--event-shot` iki kart TR/EN,
  `--inbox-shot` gece kartı, `--clock-shot=held`.

## B4 · Kalan acil durum kartları ve bot (Sonnet xhigh)
- Kartlar (W1): `customer.incident_month_close` (damga 22:10–22:55, kart 23:00; hat eşiği B0'dan),
  `product.incident_checkout`, `product.incident_regression` (sürüm yolu: A'nın hatalı sürüm listesi, kritik hatlar
  `sprint.json`), `product.incident_review_storm`.
- "Sprinti durdur": A'nın "düzeltme kartını sprinte koyan ya da başa taşıyan" girişi; kart sprintteyse başa taşınır;
  ödeme olayında tek seferlik düzeltme kartı; çip kayan kartın adı. Ay sonu sprint yoluna hesaba −3 (onay bekliyor).
- Erteleme: B2B hemen −6, hat düzelmeden geçen her sprint kapanışında −3; B2C düzelene kadar kitle haftada −%2;
  A'nın "hat temizlendi" sinyali ya da düzeltme sürümüyle biter (kayıtlı durum).
- Bot: A'nın kollarında acil kart seçimi fiile göre (`fix_none` → erteleme, kilitliyse ilk açık; öbürleri → sprinti
  durdur); "Sprinti durdur" hiç seçilmeyen ikinci koşu bayrağı.
- Kapı: `--why-fire` dört kart, plausibility, `run_gate.sh`; §4.7 `--sprint-probe=...:events=1:incident=<tür>@<tik>`
  "Sprinti durdur" (PRED = CLOSE). Görsel `--event-shot` dört kart TR/EN.

## B7 · B2B söz olayı (Sonnet xhigh)
- `product.promise_due` (W3): son sprint haftasında, karta bu sprint için söz verilmiş hesap varsa ve kart bu hızla
  yetişmeyecekse sistem ister. "Testi kısalt": test işinin yarısı silinir, hatalı çıkma ihtimali
  `max(önceki, sprint.json promise.cut_test_escape 0,15)`; çip önce/sonra aynı fonksiyondan. Fazla mesai: o kartta
  çalışanlara moral −5. Ek süre: hesaba −6 iz, bir kez (`Promise.extended`). Söz kaçsın: bugünkü bozulma zinciri,
  çip oyuncunun göreceği değer (58 → 49).
- Söz varken "Sprint yetişmeyecek" gelmez. Kesinti sırasına söz kaydı (B5 okur).
- `docs/ACIK_ISLER/ISLER.md`'ye B2C söz satırı (W3 rule metni).
- Kapı: `--why-fire`, plausibility, `run_gate.sh`, `inbox_no_night_stamp`, var olan söz vakaları; §4.7 "Testi kısalt"
  (B2B, testçili kadro, PRED = CLOSE). Görsel `--event-shot=product.promise_due:customer=<fikstür>` TR/EN.

## B5 · Kâğıt motoru (Sonnet xhigh)
- Sprint başına en çok bir kâğıt; bazı sprintler boş (≥⅓ hedef, bir ve iki haftalık sprintte ayrı); kart başına haftalık
  zar (`decision.rate`) kalkar. Kesinti sırası: söz ya da acil durum gelen sprintte kâğıt yok; kâğıt gelen sprintte yalnız
  "servis çöktü" acil durumu gelir, öbürleri sonraki sprinte kayar. Mandal 52 hafta + en çok 3, `latch_key: run` (lint
  kuralı); seçim ağırlığı 1/(1 + 2 × görülme).
- Konuşan: kartın o aşamadaki `assignees` + `role_of`; payının tamamı Destek'te olan konuşmaz; PM istisnası (ekipteki PM,
  sprintte planlı müşteri isteği kartı; PM yoksa PM kâğıdı yok); kurucu tekken kendi notu.
- Prob: `SPRINTPROBE PAPER|<seed>|<sprint>|<event_id>|<speaker>` ve boş sprint oranı.
- Kapı: smoke `paper_speaker_is_assignee`, `decision_one_per_sprint`, `decision_no_fourth_show`, §4.1 smoke yeniden,
  `inbox_no_night_stamp`. Görsel `--product-shot=live:decision_paper` TR/EN (konuşanın adı ve rolü).

## B6a, B6b · Kâğıt içeriği (Sonnet xhigh)
- W2'nin 40 kâğıdı (20 + 20) + sistem kâğıdı `sprint_late` (yalnız kartı bekleyen varken, 26 hafta, en çok 3); bugünkü
  9 dosyanın akıbeti `existing_tr`'deki gibi (takipler silinir, renk kâğıtları birleşir). Kâğıtların gerektirdiği
  fiiller (`sprint_card_trim`, `line_harden`, …) ilk gerektiği dilimde.
- B6b sonunda tek seferlik ölçüm: §4.1 raporu (104 hf × 10 tohum: olay sayısı ve aralıklar), §4.5 (iki pazar, bir ve
  iki haftalık ayrı, toplam kesinti), §4.11 (A'nın kolları, olaylar açık; "Sprinti durdur" hiç seçilmeden ikinci koşu),
  §4.12 (olay türü ve kâğıt rolü sayıları, `fix_worst`).

## B8 · Sürüm anı (Sonnet xhigh)
- `customer.release_thanks` (W3): üç tetikleyici; hesap başına sürümde en çok 1, sürümde en çok 3; söz ile istek aynıysa
  söz metni; hızlı düzeltme teşekkürü yalnız olayı yaşamış hesaptan. Mesai içinde teslim.
- B2C yorum satırı sürüm notunda (W3 seçim kuralı), koyu dil `D_` token'ları.
- Kapı: `--why-fire`, plausibility, `inbox_no_night_stamp`, `--theme-contrast-audit`; her teşekkür türü bir vakayla.
  Görsel: teşekkür maili, sürüm notu yorum satırı TR/EN.

## B9 · Yatırımcı hazırlığının kalkması (Sonnet xhigh)
- Önce geçici bot kolu (`full_run_vc_cautious`, her Series A görüşmesinden önce hazırlık) ile 10 tohum × 2 kol imza oranı;
  odaklanan sorunun geçme ihtimali `PREP_BONUS`'la ve onsuz. Sonra silme: `GameState.prep`, `pitch_prep_active`,
  `founder_state` `pitch_prep` (`_vocabulary.md`), Series A sekmesindeki hazırlık satırı, `PREP_*`, `PREP_BONUS`,
  `HUNT_PREP_*`, `VC_PREP_*`, `HR_FOUNDER_STATE_PITCH_PREP`, hazırlık smoke vakaları, `save_manager.gd`'deki `prep`
  damgası; geçici kol silinir. Yükleyici `prep` ve `pitch_prep_active`'i her yüklemede düşürür. `MEETING_CHIP_PREP`
  satışta kalır, yalnız VC satırı silinir.
- Kapı: `--event-vocab`, VC smoke'ları, `run_gate.sh` (`full_run_vc_cautious` bir sonla biter). Görsel: Series A sekmesi,
  `--meeting-shot=open`.
