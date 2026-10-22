# B0t · Mail ve bildirim saatleri (PRD §5, Karar 21, §4.4) · B1'in tek girdisi
Salt okuma araştırması. Kod `main` @ `1faeb82` (A henüz commit atmadı). Satır numaraları o commit'e göredir. "A/B varsayımı" = A'nın vereceği ad ya da davranış; A bitince B0 tazeler. Doğrulanamayan şey "DOĞRULANMADI" diye işaretli.

## 0. Hüküm (10 satır)
1. Kökü bir cümlede: gün dönümü ve günlük dağıtım **00:00'da gece toplu adımının içinde** koşar (`time_manager.gd:142-154`: saatlik dilim, sonra `advance_day`, sonra `_dispatch_daily_tick`). Her günlük üretici o anda yazar. Gece toplu adımı tek karede senkron koşar (`_advance_real` → `skip_night`, `time_manager.gd:116-122`), bu yüzden oyuncu 00:00'ı hiç görmez: bildirim yığını yenilemesi `call_deferred` (`office_notice_stack.gd:90-94`) olduğundan toplu adımdan sonra çalışır, kartlar `clock_batch_ended`'da pompalanır (`engine.gd:536-538`), dönem özeti ve ilk Ar-Ge notu ise toplu adımın içinde gelen kutusunu açıp hızı 0 yapar (`main.gd:3829-3834`). Sonuç: gece bitince **08:00'de bir mail yığını**, damgasız; 08:00 mesai başı da değildir (varsayılan pencere 09:00). Erdem'in "gece yarısı düşüyor" gözlemi, verinin 00:00 adımında doğması ve sabah tek seferde yığılmasıdır.
2. Hiçbir öğe geliş saati taşımıyor: mesaj `day`, kart geçmişi `day`, kâğıt `admitted_day`, kuyruk `admitted_day`, hatırlatıcı hiç. Ekran saati yalnız tek yerde yazıyor ve o da damga değil (`mail_pane.gd:121-123`).
3. **Öneri (en az değişiklik):** her mağazaya tek bir `at` alanı (mutlak dakika = `gün * 1440 + dakika`, `-1` = saatsiz), tek bir küçük statik sınıf `MailClock` (pencere sorgusu, geliş saati çekimi, saatlik salıverme) ve iki ayrı teslim biçimi: **mesajlar için dış kutu (outbox)**, **motor kartları ve geçmiş için damga + okuma süzgeci**. Hatırlatıcılar için **türetilmiş kalır, ilk görülme defteri** (tick'te senkronlanan `GameState.desk_arrivals`). Haber bandı canlı satırları için dinleyici tarafı bekletme.
4. Acil ayrımı kart etiketiyle (`terminal_warning` zaten var, B3'ün acil durum kartları yeni `urgent` etiketi alır); son uyarı kuyruk girdisinde `urgent: true`.
5. Şema 17: veri göçü gerekmez (yeni alanlar anlamlı varsayılan taşır, eksik `at` = `-1` = saatsiz); yalnız `SCHEMA_VERSION` artar.
6. Dikkat: bu araştırma PRD'nin üç iddiasını düzeltiyor (§8): "82 kart" doğrulanmadı (demo yapıda 71), `team.demo_day` `_end_week`'ten gelmiyor, `mail_pane` yalnız tek kart türünde "şimdiki saati" yazıyor. Ayrıca PRD'de olmayan, en görünür 00:00 yolu bulundu: `main.gd:4243-4251` dönem özeti ve ilk Ar-Ge notu gelince gelen kutusunu kendiliğinden açıp hızı 0 yapıyor.

## 1. Bugünkü damgalar (doğrulama)
| Yüzey | Alan | Yer | Saat var mı |
|---|---|---|---|
| Mesaj (`GameState.messages`) | `{id, kind, day, key, args, read}` | `message_system.gd:18-19` | hayır |
| Olay geçmişi (`EvHistory`) | satır `day` | `history.gd:34-47` | hayır |
| Kâğıt (`EvPapers`) | `admitted_day`, `expires_on` | `papers.gd:27-39` | hayır |
| Kuyruk (`EvQueue`) | `admitted_day` | `queue.gd:42-48` | hayır |
| Hatırlatıcı (`desk()`) | `day = -1` | `inbox.gd:314-317` (`_reminder`) | hiç damga yok, her okumada kuruluyor (`inbox.gd:73-135`) |
| Frank'in satırı | `mentor_line_key/args` | `game_state.gd:311-322` | hayır |
| Canlı haber satırı | `{src}` + satır | `news_ticker.gd:101-107` | hayır; bellekte, kayda girmiyor |
| Sürüm notu (`product.release`) | `day` | `sprint_system.gd:1059-1066` | hayır |

`mail_pane.gd:121-123` DOĞRULANDI ama kapsamı dar: `hour = GameState.current_hour if _mode == "live" and _item.hourly else -1`. Yani **yalnız canlı ekrandaki `tick: hourly` kart** (bugün tek kart: `funding.sheet_decision`) şimdiki saati yazar. Geri kalan her mail yalnız tarih gösterir (`INBOX.date_text(day, hour)`, `inbox.gd:480-482`; mesajlarda `mail_pane.gd:142-154`). Başlık `_header(from, date)` (`mail_pane.gd:209`) tek gösterim noktasıdır; liste bandı `events_tab.gd:232` ve geçmiş satırı rozeti `events_tab.gd:327` günlüdür.

## 2. Karar 21'deki üreticilerin doğrulaması
Sıra: günlük dağıtım slotları `time_manager.gd:373-417` (yuva 0 `SummarySystem.begin_day` :378, ürün :381, sprint :384, destek :385, altyapı :386, Ar-Ge :389, ekip :392, satış :393, finans :397, ofis :399, kapı :403-404, **olaylar :406**, haber :408, VC :411, sonlar :413, özet :415, `day_tick_completed` :417). Hepsi 00:00 gün dönümü adımında, toplu adımın içinde.

| # | Üretici | Yer | Hangi tikte / saatte | Nereye yazıyor | Bugünkü damga |
|---|---|---|---|---|---|
| 1a | Dönem özeti | `summary_system.gd:94-95` (yuva 10); `main.gd:4243` | günlük, 00:00 | gelen kutusu mesajı + `summary_ready` → **gelen kutusunu kendiliğinden açar, hızı 0 yapar** (`_open_note`, `main.gd:3829-3834`) | `day` |
| 1b | Haftalık satış raporu | `sales_rep_system.gd:271-286` (`daily_tick` :33 ← `b2b_sales_system.gd:44`) | günlük, 00:00 (B2B ve kapanış varsa) | gelen kutusu mesajı | `day` |
| 1c | Ar-Ge notu | `rnd_system.gd:525-540` (`daily_tick` :101) | günlük, 00:00 | mesaj + `product_note_issued` → **ilk not gelen kutusunu açar** (`main.gd:4249-4251`) | `day` |
| 1d | Ar-Ge keşfi | `rnd_system.gd:466` (`_complete` ← `_accrue` :122) | günlük, 00:00 | mesaj + bildirim yığınında "okunmamış keşif" (`inbox.gd:137-147`) | `day` |
| 1e | Kurucunun giriş notu | `game_state.gd:937` (`initialize_run`) | koşu başı, 08:00, saat durmuş | mesaj | `day` · **acil sayılmalı** |
| 2 | `tick: daily` kartlar | `engine.gd:67-84` ← `time_manager.gd:406`; kabul tek yer `_admit` :474 | günlük, 00:00 | sınıfa göre: `interrupt` kuyruğa, `paper` masaya, tek seçenekli etkisiz kart (`is_note`) doğrudan geçmişe (`unread`) | `admitted_day` / `day` |
| 3 | Sprint karar kâğıdı | `sprint_system.gd:720-746` (`_end_week` → `_request_decision` :745 → `EventGate.request` :849) | günlük, 00:00; ayrıca `_begin` :166 (1 haftalık sprint) | masa kâğıdı (`paper`) | `admitted_day` |
| 3b | `team.demo_day` | `sprint_system.gd:167` (`_begin`) | **yalnız sprint başlarken, 1 haftalık sprintte**; 00:00'da yalnız `_auto_start` yolundan (:42, :45, :962) | kuyruk (`interrupt`) | `admitted_day` · **PRD'nin "`_end_week`" iddiası yanlış** |
| 4 | Müşteri temsilcisi talepleri | `customer_rep_system.gd:192-196`, `_escalate` :304 | günlük, 00:00 (`b2b_sales_system.gd:39`) | `customer.request_*` kâğıdı | `admitted_day` |
| 5a | Tükenmişlik | `hr_morale_system.gd:86-95` (`EventGate.request("team.burnout")` :92-93) | günlük, 00:00 (`hr_system.gd:45`) | interrupt kuyruğu | `admitted_day` |
| 5b | İstifa | `hr_morale_system.gd:330-341` | günlük, 00:00 (`tick_thresholds` `hr_system.gd:44`) | interrupt (`critical`) | `admitted_day` |
| 6 | Aday dosyaları hazır | `hr_search_system.gd:39-46`, `_deliver_files` :285-301 | günlük, 00:00 (`hr_system.gd:41`) | haber satırı (`HR_NEWS_FILES_READY`, :300) + "atlas" hatırlatıcısı (`inbox.gd:104-107`) | yok |
| 7a | Term sheet teslimi | `vc_pitch_system.gd:875-887` | günlük, 00:00 (:865-872) | `active_sheets` (durum) → "sheet" hatırlatıcısı (`inbox.gd:93-103`) + `sheet_granted` sinyali (kartlar `closing_docs*`) | yok |
| 7b | Geri arama + Frank satırı | `vc_pitch_system.gd:890-903` | günlük, 00:00 | `EventBus.mentor_advisory_changed("VC_CALLBACK_REOPENED")` → bildirim yığını Frank satırı | yok |
| 7c | Görüşme günü | `vc_pitch_system.gd:914-921` | günlük, 00:00 | `meeting_day` sinyali → `closing_docs_diligence` (signal kartı) | `admitted_day` |
| 8 | Gelen kutusu hatırlatıcıları (`desk()`) | `inbox.gd:73-135`: kapı :86-92, sheet :93-103, atlas :104-107, B2B Risk/Genişleme :108-121, kaçma riski :122-133 | durum 00:00'da değişir (`set_lifecycle_phase` `customer_registry.gd:177-186` günlük; moral günlük) | bildirim yığını (`office_notice_stack.gd:136`) + Olaylar listesi | **hiç** |
| 9a | Kâğıt son uyarısı | `engine.gd:138-148` (`EvQueue.admit` doğrudan, `_admit`'i atlar) | günlük, 00:00 (yuva a) | interrupt kuyruğu | `admitted_day` · **acil** |
| 9b | Süre bitimi notu | `engine.gd:124-129` (`EvTicker.push`), ark sönüşü :198-200 | günlük, 00:00 | haber bandı canlı satırı + `EvTicker._held` (kayıtlı) + geçmiş satırı `expired` | satır `day` |
| 10a | Ay kapanışı ve runway satırı | `summary_system.gd:86-92` | günlük, 00:00 (yuva 10) | haber bandı canlı satırı | yok |
| 10b | Piyasa girişi (halka arz) | `news_feed_system.gd:156,395-405` | günlük, 00:00 | canlı satır; akış satırları `stream` (`_append` :413, `day`) | `day` |
| 10c | Rakip çıkışı, basın satırı | `sprint_bridges.gd:134` (`tick_rivals`), :162 (`press_line`) | sprint başlarken / `_close` (00:00) | canlı satır; `headline_added` ayrıca "Biz" arşivine (`news_feed_system.gd:172-192`) | yok |
| 11 | Sprint kapanışı, sürüm notu | `sprint_system.gd:986-1083` (`_close`) | günlük, 00:00 | `product.release` (durum) + `version_shipped` + `sync_plan_hold` (toplu adım sonuna ertelenir, :1154-1165; kapı 08:00'de kapanır) | `release.day` |
| 12 | Kepenk kartı | `endings_system.gd:112-121` | günlük, 00:00 (yuva 9) | interrupt, `terminal_warning` | `admitted_day` · **acil** |

Notlar:
- **Kart sayısı.** PRD "82 kart" diyor; DOĞRULANMADI. Yüklenen kartlar (`unwired/` ve `_fixtures/` dışı) için demo yapıda (`SHIPPED_SCOPES` = yalnız `demo`) **85 kart**: `daily` 61, `scheduled` 4, `signal` 6, `request` 13, `hourly` 1. 00:00 günlük dağıtımından doğrudan ya da sinyalle giren **71** kart (61+4+6). EA yapı `ea` kapsamlı kartları da ekler.
- 3b: Sprint başlatma oyuncunun hamlesidir (`start()` :129) ya da devredilmiş sprintte hız 0'ın üstüne çıkınca (`_on_speed_changed` :926). Yani demo günü 00:00'da yalnız `_auto_start` ile gelir.
- 9a ile 12 PRD'ye göre acil, 00:00'da kalır. 9b (süre bitimi notu) acil değil.
- 11: sürüm notunun kendisi bir mail değil durum. Sürüm notunun ekrana gelişi plan kapısının saat tutuşudur (`awaits_plan` → `hold_clock("sprint_plan")`); tutuş toplu adımda ertelenip `clock_batch_ended` ile **08:00'de** alınır. Pencere 09:00-11:00'da başlıyorsa kapı mesai öncesinde kapanır. Bkz. §7 karar sorusu 2.

## 3. Yeni üreticiler ve boğumlar
### 3.1 Karar 21 dışı yeniler (5)
| # | Üretici | Yer | Not |
|---|---|---|---|
| N1 | Ofis taşıma varışı | `office_system.gd:58-64` (günlük yuva) → `office_changed` → **toast** `OFFICE_TOAST_MOVED` (`office_hud.gd:61,120-122`) | gelen kutusu/yığın değil, toast; 00:00'da düşer |
| N2 | İzin dönüşü ve izne çıkış | `hr_morale_system.gd:41` (`HR_NEWS_BACK_FROM`), :264 (`HR_NEWS_ON_LEAVE`; oyuncu izninde gündüz) | günlük, 00:00; canlı satır + "Biz" arşivi |
| N3 | Eğitim bitti | `hr_system.gd:100` (`tick_training`, `hr_system.gd:47`) | günlük, 00:00; canlı satır |
| N4 | Temsilci imza haberi | `sales_ledger.gd:264-269` ← `sales_rep_system.gd:243` (temsilci kapanışı, günlük); kurucu masası `sales_finalizer.gd:99` gündüz | canlı satır + marka |
| N5 | Kendiliğinden açılış | `main.gd:4243-4251` ← `summary_ready`/`product_note_issued`; `_open_note` `main.gd:3829-3834` | tüketici tarafı; 00:00 mailinin Erdem'in gördüğü asıl hâli (hızı 0 yapar, gelen kutusunu seçer) |
Ek: kart etkileri `ticker_push` / `notify` (`effects.gd:446-458`) gün sınırında yalnız `on_expire` ya da ark sönüşünden koşar (oyuncu kararı gündüzdür).

### 3.2 Boğumlar (dördü doğrulandı, ikisi eklendi)
1. **`MessageSystem.post`** (`message_system.gd:14`): 5 çağıran (§2 1a-1e) + 2 debug çekimi `main.gd:871,880` + iki smoke.
2. **Motor kabulü:** `EvEngine._admit` (`engine.gd:474`; günlük, saatlik, sinyal, takvim, ark, havuz, taban ve `request` hepsi buradan) + iki yan kapı: `_step_last_warnings` → `EvQueue.admit` (:147), `force_fire` → `EvQueue.admit` (:717, yalnız debug). `EvHistory.record` altı yerde yazıyor: :124 süre bitti, :490 not, :558 ve :603 ve :741 düştü, :631 seçildi. `EvPapers.place` iki yerde: :422 (düşürülmüş interrupt'ın masaya inmesi, **sıfırdan damga çekmemeli**, kuyruk girdisinin damgasını taşımalı), :499.
3. **`EventBus.headline_added` / `ticker_live_line`**: 12 çağıran (`hr_morale_system.gd:41,264`, `hr_search_system.gd:300`, `hr_system.gd:100`, `news_feed_system.gd:405`, `sales_ledger.gd:267`, `sprint_bridges.gd:134,162`, `summary_system.gd:88,92`, `office_travel.gd:123` oyuncu hamlesi, `ticker.gd:25` ← `engine.gd:128,200`, `effects.gd:448,458`). Dinleyiciler iki: `news_ticker.gd:69-70` ve `NewsFeedSystem.on_headline_added` (`time_manager.gd:83`).
4. **`desk()`** (`inbox.gd:73`): bildirim yığınının (`office_notice_stack.gd:136`), Olaylar listesinin (`inbox.gd:40-70`), üst barın ve sol rayın rozetlerinin (`top_bar.gd:253,318`, `left_tabs.gd:305`) tek model kaynağı.
5. **(eklendi) `mentor_advisory_changed`**: üç yayıcı: `effects.gd:531` (yalnız iki kart, `frank_intro` ve `paid_tier`, ikisi de oyuncu kararı), `vc_pitch_system.gd:902` (günlük), `sprint_bridges.gd:187` (satırı siler). Tüketici `game_state.gd:320-322` ve `office_notice_stack.gd:100-117`.
6. **(eklendi) Otomatik açılış** `main.gd:4243-4251`: `summary_ready` ve `product_note_issued` tüketicisi.

Boğumdan geçmeyen yol: **`desk()`'e giren ama motor/mesaj kuyruğundan geçmeyen** durum kaynakları (§4'te hatırlatıcı defteri), `_step_last_warnings` (bilerek) ve `OfficeSystem` toast'ı. Başka `GameState.messages` yazıcısı yok (`grep`: yalnız `MessageSystem`).

Diğer günlük slotlar (`ProductSystem`, `SupportSystem`, `InfraSystem`, `ProductRead.emit_edges`, `FinanceSystem`, `PhaseGateSystem`, `SeedRoundSystem`, `RivalRegistry`, `HRSystem` deneyim) doğrudan gelen kutusuna ya da yığına yazmıyor; sinyal (`axis_floor_*`, `customer_health_changed`, `version_shipped`, `sheet_granted`, `meeting_day`) ya da durum bayrağı yayıyor, kartlar motor üzerinden geliyor. Doğrulandı.

Saatlik dağıtım (`time_manager.gd:422-432`): `ProductSystem`, `SupportSystem`, `SalesSystem.hourly_tick` (B2B anlaşmaları 12:00'de imzalanır, `sales_system.gd:149-154`; pencere en az 5 saat olduğundan 12:00 her zaman pencerede), `EventGate.hourly_tick`. Saatlik kartlar `DEFAULT_ALLOWED_HOURS = [8, 20]` ile kapılanıyor (`gate.gd:37`, :201-210): **pencere farkında değil**; pencere 11:00-24:00 iken 08:00-10:59 arası saatlik kart gelebilir. Bugün tek saatlik kart `[0, 23]` verir ve `critical` olduğu için zaten kendi koşuluyla (`funding.table_sitting_open`) kapılı.

## 4. Hatırlatıcılar: geliş saatini nasıl tutarız
`desk()` durumsuz (her okumada kuruluyor), kaynakları durum: kapı (`GameState.phase_gate_ready`), term sheet (`active_sheets`), aday dosyaları (`hr_search` durumu), B2B yaşam döngüsü (`lifecycle_phase`), çalışan morali (`is_flight_risk`).

| | Seçenek | Bedel | Sorun |
|---|---|---|---|
| R-A | **Türetilmiş kalır + tick'te senkronlanan ilk-görülme defteri** `GameState.desk_arrivals: {hatırlatıcı_id: at}`. `MailClock.sync()` günlük dağıtımın sonunda (`time_manager.gd:417` öncesi) ve her saatlik dilimde koşar: durum doğruysa ve defterde yoksa geliş saatini çeker (§5.2), durum bittiyse siler. `desk()` yalnız `at <= şimdi` olanı gösterir. | +1 kayıtlı sözlük, +1 senkron fonksiyonu (~25 satır). `desk()`'in beş koşulu **sistem katmanına** çıkarılır (`MailClock.reminder_ids()` gibi tek kaynak), `desk()` onun üstüne kurulur; aksi hâlde sistem UI'dan okur. | Koşulun sahibi tek yer olur. Yeni bir sistem hatırlatıcı eklerse listeye girmek zorunda (smoke bunu `desk()` ile `reminder_ids()` eşliğiyle sınar). |
| R-B | `desk()` içinde tembel damga: bir hatırlatıcı ilk kez okununca defter satırı açılır, `desk()` dönüşünde olmayanlar silinir. | En az satır; defter yine kayıtlı. | **Okuma yan etki yapar**; ilk okuyan yüzey (bildirim yığını gece 00:00 sinyalle okur, `office_notice_stack.gd:42`) damgayı belirler; yüzey kurulu değilse (başsız smoke) damga hiç yazılmaz; durum 00:00'da kapanıp açılırsa eski bölüm kalır. Önerilmez. |
| R-C | Hatırlatıcı gerçek giriş olur (kenar yayınında `MailClock` kuyruğuna girer, `desk()` kuyruğu okur). | En büyük: beş kaynakta kenar noktası (`set_lifecycle_phase`, moral eşiği, `sheet_granted`, `_deliver_files`, kapı) | Yüklemede kenar kaçar; kaçan kenar hiç hatırlatıcı üretmez. Reddedildi. |

**Öneri: R-A.** Eski kayıt: ilk senkronda zaten doğru olan hatırlatıcılar `-1` (saatsiz) ile açılır (görünür kalır, damga yazmaz); sonra doğan her yeni hatırlatıcı çekilmiş saatle gelir. Gece doğan sonsuza kadar gizli kalmasın diye senkron her saatlik dilimde de koşar; gün içinde pencere içinde doğan hatırlatıcı bir sonraki saatlik senkronda (en çok 1 oyun saati gecikme) görünür. İsterse `customer_health_changed` ve `morale_changed` sinyalleri senkronu o anda da tetikler (opsiyonel).
Frank'in satırı için aynı kural: `GameState.mentor_line_at` (varsayılan `-1`); `game_state.gd:320-322` dinleyicisi `MailClock.arrival(...)` ile yazar, `office_notice_stack.gd:100` yalnız `at <= şimdi` iken çizer. Boş anahtar (`""`, satırı siler) her zaman anında.

## 5. En az değişiklikle taşıma yolu

### 5.1 Alan
Her mağazada tek alan: `at: int`, mutlak dakika = `gün * 1440 + günün dakikası`, `-1` saatsiz. Mutlak biçim seçildi çünkü "damga şimdiden ileride olamaz" ve "teslim edildi mi" tek bir tamsayı karşılaştırması (`at <= MailClock.now()`); tarih `at / 1440`, saat `(at % 1440)`. Kayıt JSON'da tamsayılar float döner: her okuma `int()` ile (bilinen tuzak, A_PLAN'da da var).
- `GameState.messages[i].at` (mesajlar dış kutudan çıkarken yazılır, aşağıda).
- `EvQueue` girdisi `at`, `urgent`; `EvPapers` girdisi `at` (`admitted_day` kalır, süre hesabı değişmez).
- `EvHistory` satırı `at` (not satırı: geliş saati; `chosen` satırı: cevap anı; `expired` satırı: §5.2 kuralıyla çekilen saat).
- `GameState.mentor_line_at`, `GameState.desk_arrivals`.
- Ekran: `INBOX.date_text(day, hour)` (`inbox.gd:480`) yerine `date_text(at)`; `at < 0` ise bugünkü gibi yalnız tarih. `mail_pane.gd:121-123` silinir (şimdiki saat yazma kalkar), `_header` damgayı alır. Liste satırına küçük saat çıktısı opsiyonel (`events_tab.gd:327` rozetinin yanı).

### 5.2 Geliş saati çekimi ve acil ayrımı
`MailClock.arrival(anahtar, acil := false)`:
```
şimdi   = gün * 1440 + int(TimeManager.day_minute())
pencere = WorkHoursSystem.company_window()           # {start, end}; end en çok 24
s = start * 60;  e = end * 60;  m = şimdi % 1440
acil ya da (s <= m ve m < e)  -> şimdi                # pencerede ya da acil: anında, damga = şimdi
gün = şimdi / 1440 + (1 eğer m >= e)                  # pencere sonrası: ertesi günün penceresi; 00:00 ile s arası: aynı gün
saat = floor(EvDice.unit("arrival", gün, anahtar, "") * min(YAYILIM_SAAT, e/60 - s/60))
-> gün * 1440 + s + saat * 60
```
- `EvDice.unit` (`dice.gd:33-37`) kullanılmalı: projenin kararlı FNV özeti, `hash()` değil.
- `YAYILIM_SAAT = 4` [WORKING, onay bekliyor]: sabah kümelenir (Erdem'in örneği 09:00-10:00).
- **Ömrü bir hafta olan kâğıt** (sprint karar kâğıtları `expires_weeks: 1`, `product/sprint_*.json`) 12:00'ye düşerse oyuncuya kalan mesai kısalır; öneri: bu kâğıtlar için yayılım 1 saat (pencere başı). Bu bir tasarım sabiti, onay bekler.
- Acil: kartta `terminal_warning` ya da `urgent` etiketi; kuyruk girdisinde `urgent: true` (son uyarı); mesajlarda `post(..., acil := true)` (yalnız giriş notu). Etiket seçimi: `terminal_warning` (6 kart: `acquisition_offer`, `last_answer`, `shutter_warning`, `final_stretch_*`) zaten "sonun işaret fişeği", acil olması doğal. B3'ün acil durum kartları `urgent` ekler (etiket doğrulaması yok, `lint.gd`'de etiket listesi yok).
- Acil kartta B3'ün "mail 02:10 damgalı, kart 03:00'te açılır" ihtiyacı: damga tek parametreyle geçilir; B1 bunu eklemez (kullanılmayan parametre), B3 `EventGate.request`'e ekler.

### 5.3 Teslim: iki biçim
**Mesajlar: dış kutu.** `MessageSystem.post` pencere dışında `GameState.mail_outbox` (kayıtlı dizi: `{kind, key, args, due}`) içine yazar; mesaj henüz yok. Saatlik dilimde `MailClock.hourly_tick(hour)` `due <= şimdi` olanları `messages`'a ekler (`id = kind:gün:n` bu anda, gün = `due / 1440`), `at = due`, sonra `messages_changed`; arkasından o mesaja eşlik eden sinyali yayar (`summary_ready`, `product_note_issued`, `weekly_sales_report_issued`). Bu sinyallerin bugünkü yayın noktaları (`summary_system.gd:95`, `rnd_system.gd:540`, `sales_rep_system.gd:284`) salıverme anına taşınır; aksi hâlde `main.gd:4243-4251` hâlâ gece açar. Okuyucular (`inbox.items`, `unread_discovery`, `_open_note`, `RnDSystem.mark_note_read`) **değişmez**, çünkü mesaj dışarıda beklerken `messages`'ta görünmez. Gerekçe: mesajın motor tarafında mandalı, kotası, tekilleştirmesi yok.
**Motor kartları: damga + okuma süzgeci.** Kart 00:00'da bugünkü gibi kabul edilir (mandal harcanır, `_today_admissions`, tempo sınıfı, `EvTempo.assign` kotası; hepsi `engine.gd:474-514`, `present/tempo.gd:46-86`), ama `_admit` kuyruğa/masaya/geçmişe `at = MailClock.arrival(EvLatches.key_of(...), acil)` ile yazar. Süzülecek okuyucular (görünürlük) ve süzülmeyecekler (varlık sorusu):
- Süzülür (oyuncuya gösterim): `EvQueue.next()` (:60) ve `EvQueue.size()` (:149) yalnız `at <= şimdi`; `EventGate.desk_papers()` varsayılan süzgeçli (`presenter.gd:181`); `EvHistory.newest_unread_note` (:149); `inbox.items()` geçmiş satırı; `top_bar.gd:253,318`; `left_tabs.gd:305` (hepsi `desk_papers`/`queue_size` üzerinden).
- **Süzülmez** (varlık/yinelenme): `EvQueue.has/holds/ids` (:130,:138,:153), `EvPapers.has/keys_of`, `EvPapers.is_empty` (taban mantığı, :170), `EvPapers.take_expired`, `needing_last_warning`. `sprint_system.gd:863-864` ve :947 `desk_papers`'ı varlık için okuyor: **süzgeçsiz sürüm gerekir** (`desk_papers(slots, hepsi := true)` ya da ayrı `EventGate.paper_exists`), aksi hâlde gizli karar kâğıdı "yok" sanılır ve `_settle_decision` kartı serbest bırakır. Bu yan etki risk R2'dir.
- `EvEngine.pump` (:536) toplu adımda zaten ertelenir; ek olarak `EvQueue.next()` süzgeci gelecekteki kartı mount etmez. Notlar (`_unannounced`) `event_triggered`'ı kabulde değil salıvermede yayar.
- `EvEngine.hourly_tick` (:89) başında `MailClock.hourly_tick(hour)` (salıverme + `desk_changed` + gerekirse `pump`) koşar; `time_manager.gd:432` öncesine eklenir. Salıverme sürecin kendisi değil, **yalnız yenileme sinyalidir**: görünürlük okuma anında `at <= şimdi` karşılaştırmasıdır, bu yüzden yükleme ve atlama sağlam.
- **00:00 saatlik dilimi `advance_day()`'den ÖNCE koşar** (`time_manager.gd:150-153`): `MailClock.hourly_tick(0)` hiçbir şey yapmamalı; bu dilimde `şimdi` bir önceki güne ait olur.
- Kuyruk şimdi ve gelecek girdileri birlikte taşır; `EvQueue.to_dict` zaten tüm girdileri kaydeder (`queue.gd:203-208`), `at` anahtarı kendiliğinden girer.
**Hatırlatıcı ve Frank satırı:** §4 (defter ve `mentor_line_at`).
**Haber bandı canlı satırları:** `news_ticker.gd:101-107` (`_on_live_line`) pencere dışında satırı kendi bekleme listesine alır, `EventBus.hour_changed` ile (mesai içinde ilk saat) bırakır. Üretici çağıranlara (12 yer) dokunulmaz. Kayıt yok (bugün de canlı satırlar kayda girmez). "Biz" arşivi (`on_headline_added`) olduğu gibi kalır: damgası yok, gösterim yüzeyi ayrı. Değer düşük, maliyet küçük (~15 satır); PRD Karar 21 listelediği için önerilir, Erdem istemezse atlanabilir.
**Toast (N1):** `office_hud.gd:61` aynı bekletme kuralı; istenirse. DOĞRULANMADI: toast'ın gece görünür olup olmadığı (gece ofis boş, kabuk toast'ı gösteriyor olabilir).

### 5.4 Gece toplu adımı, tutuş ve oto kayıt
- `skip_night` (`time_manager.gd:179-186`) 08:00'e kadar her saati `_step_hour` ile koşar; salıverme saatlik dilimin içinde olduğundan pencere 08:00'de başlıyorsa 08:00 girdileri adımın son saatinde salınır, `pump` toplu adım bitince (`clock_batch_ended`) gösterir. Pencere sonrasına (09:00+) kalan girdiler normal akışta salınır.
- `hold_clock` (B3 gece olayı) toplu adımı keser, kaldığı yerden sürer (`_can_step` :160; yorum :157-159). Gece saatlerinde yalnız `at <= şimdi` olan karta izin vardır; acil olmayan kartın `at`'ı gece olamayacağı için "karar sonrası mesai başına kadar başka kart açılmaz" kendiliğinden sağlanır. **Dikkat (B3 kabul 4.3):** `EvQueue.rank` merdiveninde son uyarı (`expiring`, derece 1) `critical` (2) üstünde; kuyrukta son uyarı bekliyorken B3'ün 03:00 acil kartı `critical` ise **ikinci sırada kalır**. Kabul ölçütü tam bunu sınıyor; sıralama ya `urgent` kartı yukarı alacak ya da son uyarı geceye bırakılmayacak.
- `advance_hours(n, meeting)` (:169) pencere içinde koşarsa salıverme toplantının saatlerinde olur, gösterim `clock_batch_ended`'e kadar ertelenir; damga gösterimden ileride olmaz.
- Oto kayıt `day_tick_completed` ile 00:00'da (`save_manager.gd:405-408`) bekleyen girdilerle yazılır (`can_save` yalnız etkin kartı engeller, `save_manager.gd:85-95`). Dış kutu `GameState`'te olduğundan SaveCodec kendisi bulur.
- `reset_all_owners` (`save_manager.gd:320-355`): `GameState.initialize_run` yeni alanları sıfırlar; `MailClock` statik durum tutmaz (dış kutu ve defter `GameState`'te), listeye eklemek gerekmez. Statik durum eklenirse listeye girmek zorunda (CLAUDE.md §6).
- Koşu başında: giriş notu `acil := true` (saat durmuş, 08:00, mesai öncesi olabilir).

### 5.5 Kayıt
`SCHEMA_VERSION` 16 → 17 (A 16 alıyor, `PRD_FAZ_A_HATALAR.md` karar 7). Göç yok: yeni alanlar (`mail_outbox`, `desk_arrivals`, `mentor_line_at`, `at`, `urgent`) varsayılan taşır, okuma `get("at", -1)`. Eski kayıttaki mesajlar, kuyruk, kâğıt, geçmiş `-1` yani saatsiz açılır ve saatsiz her zaman "teslim edilmiş" sayılır. Yalnız `read_slot` zincirine `if version < 17` satırı (boş ya da hiç) ve CLAUDE.md §6 "SCHEMA_VERSION 17" cümlesi. Eski kayıtta kuyrukta duran kart (gece kaydı) bugünkü gibi yüklemede anında gösterilir (`main.gd:4240`).

## 6. Kabul ve kanıt planı (PRD §4.4)
- **`inbox_no_night_stamp`:** 104 hafta, iki pencere: `company_start_hour=8`, `company_work_hours=9` (08:00-17:00) ve `11`, `13` (11:00-24:00). Sürücü gerçek saat yolu olmalı: `RunProbe` sim kipi saat saat `advance_hours(1)` + `skip_night` (`run_probe.gd:671-692`) ve `sprint_probe.gd:80-93` (`events=1`) pencereyi `WorkHoursSystem.set_company_start_hour/hours` ile kuruyor. Denetim: mesajlar, `EvHistory.rows()`, `EvPapers` girdileri, `EvQueue.entries()`, `desk_arrivals`, `mentor_line_at`; acil olmayan her `at` için `s <= at % 1440 < e` ve `at <= şimdi`. Acil muafiyeti: `terminal_warning`/`urgent` kart, `urgent: true` girdi. Falsification: `MailClock.arrival` hep `şimdi` dönsün (kuyruk kapalı) → 00:00 damgalar → FAIL.
- **`--inbox-shot` "gece sonrası sabah":** `main.gd:751` `_run_inbox_shot` durumları sahne kurar (`_shot_paper`, `_shot_answered`); yeni durum 00:00 ve mesai başından yarım saat sonrası iki kare. Fikstür gerçek saat yolunu çalıştırmalı (`advance_hours`), çünkü bugünkü çekimler `GameState.day` el ile oynatıyor (`main.gd:853`).
- Mevcut smoke yardımcıları: `_sim_day()` (`endgame_smoke.gd:559-561`, 149 çağıran) günlük dağıtımı doğrudan koşar, saatsiz; `_sim_day_full()` (43 çağıran) 00:00'a kadar koşar ve oradan sonraki salıverme saatlerini koşmaz. Gecikmeyi bilen kod yalnız `_sim_day`/`_sim_day_full` sonunda `MailClock.release_all()` çağırırsa 149+43 yer değişmez. Bu, yalnız bu iki yardımcıda ve harness'te geçerli; `release_all` oyun kodunda kullanılmaz (CLAUDE.md "ölü kod yok" ile sürtüşür; alternatif: yardımcılar `GameState.current_hour`'u pencere içine alır). Karar B1'de.

## 7. Riskler (ağırlık sırasıyla)
1. **R1 · Mevcut smoke ve bot.** Günlük dağıtım sonrası "kart hemen gelsin" varsayan vakalar (149 `_sim_day` çağırıyor; `endgame_smoke.gd` 391 vaka) gecikmeyle kırılır. Bot (`RunProbe`) zaten saat saat oynar, kart öğleye kayar; ekonomi kayması rapora (PRD 4.9). `run_gate.sh` etkilenmez ama `PROBE FIRE ... hour=` satırlarındaki saat değişir.
2. **R2 · Varlık ile görünürlük karışırsa çift kart ya da kayıp kâğıt.** `desk_papers`/`queue_size` süzülürken `sprint_system.gd:863-864,947`, `engine.gd:254` (`_step_arc_steps` `EvQueue.has`/`EvPapers.keys_of`), `hr_morale_system.gd` `_pending` ve `EventGate.instances_of` süzülmemeli. Aksi hâlde sprint karar kartı serbest kalır, ark adımı iki kez önerilir.
3. **R3 · Kısa ömürlü kâğıt.** `expires_weeks: 1` kâğıtlar pencerenin geç saatinde teslim edilirse yaşamları kısalır (§5.2); `EvPapers` süre hesabı `expires_on` mutlak tik olduğundan süre bitimi değişmez. Yayılımı kısaltmak ya da süreyi teslimden saymak tasarım sabiti.
4. **R4 · "Gün sınırında ateşlenen kart saat yazmaz" kuralı (CLAUDE.md §5).** Kural kartın kabul anına dair; gösterim saati artık gün içinde olduğundan kural gevşemez ama geçerliliğini korur. Saat anlatan kartlar (B3 gece/ay sonu) `request` ile saatlik dilimde kabul edilir ve acildir, kural dışıdır. Metin yazarı "bu sabah" gibi saat ima etmemeli (W1-W3).
5. **R5 · Kotalar.** Tempo penceresi ve interrupt tavanı kabul anında (00:00, `engine.gd:412-424`, `tempo.gd:46`) hesaplanır; gecikme bunu değiştirmez. Aynı sabah birden fazla interrupt teslimi aynı saate düşebilir (kuyrukta sırayla gösterilir, bugünkü 08:00 yığılmasının aynısı). Demote edilmiş interrupt (`engine.gd:422`) masaya inerken **kuyruk girdisinin `at`'ını taşımalı**.
6. **R6 · Pencere ayarı koşu ortasında değişirse** (oyuncu mesaiyi 08:00 → 11:00 yapar) bekleyen `at`'lar eski pencereye göre kalır, yeniden çekilmez. Kabul edilen sapma; smoke pencereyi koşu başında kurar.
7. **R7 · Kayıt tipleri.** `at` JSON'dan float döner; karşılaştırma ve `%` için `int()` şart. `desk_arrivals` anahtarları string.
8. **R8 · 00:00 saatlik dilimi.** `advance_day()` saatlik dilimden sonra koşar (`time_manager.gd:147-153`); `MailClock` bu dilimde `şimdi`'yi bir önceki güne yazar. Çözüm: `hourly_tick(0)` boş, ya da `şimdi` hesabı `current_hour == 0` iken `day + 1` alır (DOĞRULANMADI: hangisi daha az sürpriz; B1 seçer, hiçbir saatlik üretici 00:00'da yazmıyor).
9. **R9 · Otomatik açılış.** `summary_ready` ve ilk Ar-Ge notu salıverme anında gelen kutusunu açıp hızı 0 yapar (`main.gd:3829-3834`); öğlen bir anda duraklama çıkar. Tasarımın istediği bu olabilir (özet "kendini okutuyor"); Erdem'e sorulmalı mı, B1 raporunda belirtilir.
10. **R10 · Sürüm notu / plan kapısı.** 08:00'de alınan `sprint_plan` tutuşu mesai öncesinde. Kapsam dışı tutulmasını öneriyorum (kapı bir mail değil, oyuncunun günü başlatma eşiği). Almak istenirse `sync_plan_hold` (`sprint_system.gd:1154-1165`) tutuşu pencere başına kadar bekletmeli; birçok smoke `awaits_plan`'a dayanıyor.
11. **R11 · Haber bandı bekletmesi.** UI düğümünde durum: ticker kurulu değilken (başsız) hiç satır tutulmaz; kayıt yok. Hat: `news_ticker.gd` yeniden kurulursa (dil/palet) bekleyen satırlar korunmalı.

## 8. PRD düzeltmeleri ve doğrulanmayanlar
- "82 kart" doğrulanmadı (demo 71, §2 notu).
- `team.demo_day` `_end_week`'ten değil `_begin`'den (§2 3b).
- `mail_pane.gd` "o anki saati yazıyor": yalnız canlı ekrandaki saatlik kartta; diğerleri saatsiz.
- "Sprint kapanışındaki sürüm notu" bir mail değil durum (§2 11, R10).
- Karar 21 listesinde olmayan ama gözlemlenen 00:00 yolu: otomatik açılış (N5) ve ofis toast'ı (N1).
- DOĞRULANMADI: toast'ın gecede kullanıcıya görünüp görünmediği; "Biz" arşivinin damga ihtiyacı (kullanıcıya zaman göstermiyor); `EvTempo`'nun istek kartını `interrupt` tavanında `paper`'a düşürme olasılığı B3'te `critical` etiketiyle önlenir (`tempo.gd:69-73`).
- `--sprint-probe` `team=3` PRD'nin "tasarımcı, geliştirici, testçi" tarifi değil: `HIRES` sırası geliştirici, tasarımcı, testçi (`sprint_probe.gd:40-41`, `_hire` :172); `team=3` kurucu+geliştirici+tasarımcı. Testçi için `team=4`. B5 ölçümü bunu düzeltmeli.

## 9. A/B varsayımları (bu dosyada: 2)
- AB-1: A, `SCHEMA_VERSION` 16'yı alıp `_migrate_16`'yı ekler (PRD A karar 7). B1 `if version < 17` satırını onun altına koyar.
- AB-2: A, `EventBus.day_tick_completed`/`GameState.day` semantiğine ve `time_manager.gd` dağıtım sırasına dokunmaz (A yalnız `ProductSystem`/`SupportSystem`/`SprintSystem` içini değiştirir). A dağıtıma yeni slot eklerse `MailClock.sync()` yeri kayar.

## 10. B1 için dokunulacak dosyalar (öneri)
`scripts/systems/mail_clock.gd` (yeni, ~90 satır), `message_system.gd`, `game_state.gd` (`mail_outbox`, `desk_arrivals`, `mentor_line_at`), `time_manager.gd` (iki çağrı), `events/core/{engine,queue,history}.gd`, `events/present/{papers,presenter}.gd`, `events/event_gate.gd`, `ui/components/inbox.gd`, `ui/office/office_notice_stack.gd`, `tabs/events/mail_pane.gd`, `tabs/events_tab.gd`, `ui/components/news_ticker.gd`, `systems/{summary_system,rnd_system,sales_rep_system}.gd` (üç sinyal yayını), `systems/sprint_system.gd` (varlık okuması), `autoload/save_manager.gd` (sürüm), CLAUDE.md §5 ve §6, HARITA, motor md §27.26. `strings.csv`: stamp biçimi anahtar gerektirmez (`%02d:%02d`).


## B0 tazelemesi (A'dan sonra)
Kaynak: `main` HEAD `26b60da` (A K1-K8, `e33caac`...`26b60da`). Yukarıdaki bölümler `1faeb82`'ye göredir ve silinmedi. A raporu: `RAPOR_A.md` yok, taslak (`.../ba70cede-.../scratchpad/RAPOR_A_taslak.md`) kullanıldı. Salt okuma.

### T1 · Tarama yöntemi ve sonucu
- Komut: `git diff 1faeb82 HEAD -U0 -- scripts/` çıktısında eklenen ve silinen satırlarda `MessageSystem`, `headline_added`, `ticker_live_line`, `EvTicker`, `hold_clock`, `summary_ready`, `product_note_issued`, `mentor_advisory`, `EventGate.request`, `notify`, `EventBus.*.emit` arandı; sonra değişen dosyaların günlük ve saatlik tike dokunan kısımları elle okundu (`time_manager.gd`, `support_system.gd`, `vc_pitch_system.gd`, `rnd_system.gd`, `sprint_bridges.gd`, `sprint_system.gd`, `inbox.gd`, `product_read.gd`, `main.gd`).
- **Sonuç: A gelen kutusuna, bildirim yığınına, olay kabulüne ya da haber bandına yazan YENİ bir üretici eklemedi.** Eklenen `EventGate.request("founder.savings_note")` yalnız smoke'ta; `bug_confirmed.emit` mevcut `ProductRead.emit_edges` içinde; silinen tek istek `EventGate.request("product.bug_pile")`. Aşağıdaki tablo A'nın günlük ya da saatlik tike dokunan DEĞİŞMİŞ yollarını sayar.
- `MessageSystem.post` çağıranları değişmedi: `game_state.gd:934` (giriş notu), `summary_system.gd`, `sales_rep_system.gd`, `rnd_system.gd:466, 539` (+ debug `main.gd:870, 879`).

### T2 · Değişen üreticiler ve yollar
| # | Yol | Yer (HEAD) | A ne yaptı | B1 için sonuç |
|---|---|---|---|---|
| 1 | Saatlik dağıtım | `time_manager.gd:422-430` | `ProductSystem.hourly_tick` kalktı; dilim şimdi `SupportSystem` (`:426`), `SalesSystem` (`:428`), `EventGate` (`:430`) | `MailClock.hourly_tick` yeri bu üç çağrının çevresi; hiçbiri mail yazmıyor (değişmedi) |
| 2 | Hata akışı | `support_system.gd:106-126` | doğrulanan her bildirim `ProductState.add_bugs(hat, 1)`; gelen kutusuna ya da yığına yazmaz | etkisiz |
| 3 | İhmal kuralı (itibar -1) | `support_system.gd:281-290`, `neglect_note` `:299` | günlük tikte (00:00) itibar düşer; sebep yalnız TopBar ve Destek kartı ipucunda (`top_bar.gd:221-225`) | mail ya da yığın üretmez; teslim kuralı gerekmez |
| 4 | `bug_confirmed` kenarı | `product_read.gd` `emit_edges` (çağrı `time_manager.gd:387`) | sinyal artık toplam açık hata artışında yayılır (00:00 yuvası) | `data/events` içinde bu sinyali dinleyen kart yok, dinleyen yalnız smoke: mail yok |
| 5 | VC geri arama | `vc_pitch_system.gd:919-933` | yeni `churn_under` dalı: pencere kayıpla dolarsa geri aramayı sessizce yeniler (`:932-933`); `callback_ready` ve `mentor_advisory_changed("VC_CALLBACK_REOPENED")` yalnız `met` olunca (`:930-931`, eskisi gibi, 00:00) | B0t #7b ile aynı üretici; yenileme sessiz, yeni yüzey yok |
| 6 | Ar-Ge notu içeriği | `rnd_system.gd:597-606` (`_demand_line`), yayın `:539-540` | ilk satır açık hata oylarını sayar; yayın yolu aynı | değişmedi (içerik) |
| 7 | B2B Risk sebebi | `inbox.gd:208-213` (`risk_reason`) | metin kaynağı `account_bugs(c)` | hatırlatıcının kimliği ve doğum koşulu (`inbox.gd:108-121`, `lifecycle_phase`) aynı: R-A defteri etkilenmez |
| 8 | Sprint kapanışı | `sprint_system.gd:1007-1105` | `clear_line_bugs` (`:1032`) `line_bugs_cleared` yayar; hatalı kart hatası `_land_faulty` (`:1126-1132`) | B8 teşekkür tetikleyicisi 00:00'da doğar: mail doğuşta pencere dışı, `MessageSystem.post` dış kutusundan geçmeli (B1 kuralı aynen) |
| 9 | Basın ve rakip satırı | `sprint_bridges.gd:79` (`ticker_live_line`), `:107` (`headline_added`) | bilet bölümü silindi, satırlar kaydı; davranış aynı | B0t #10c adresleri güncellendi |
| 10 | `product.bug_pile` | `data/events/cards/product/bug_pile.json` silindi | günlük kart yolu bir kart azaldı | 00:00 yoluna giren kart sayısı **71 → 70** (HEAD: 84 kart = günlük 60, takvimli 4, sinyalli 6, istek 13, saatlik 1) |
| 11 | Smoke yardımcıları | `endgame_smoke.gd:573-579` (`_sim_day`), `:581` (`_sim_day_full`) | çağıran sayısı 149 → **160** (`_sim_day_full` 43, aynı) | R1 riski büyüdü, çözüm aynı |
| 12 | Çekim fikstürleri | `main.gd` `desk_shut`, `rnd_note_demand` | `ProductState.add_bugs` ile kurulur | `--inbox-shot` gece durumuyla çakışmaz |

### T3 · Satır adresi kaymaları (B0t_MAIL_SAATLERI, eski → HEAD)
| Referans | Eski | HEAD |
|---|---|---|
| `time_manager.gd` `_step_hour` | 142-154 | 142-157 |
| `time_manager.gd` `skip_night` | 179-186 | 179-187 |
| `time_manager.gd` saatlik dağıtım | 422-432 | 422-430 |
| `time_manager.gd` günlük dağıtım, yuvalar | 373-417 | 373-417 (aynı) |
| `game_state.gd` Frank satırı | 311-322 | 308-319 |
| `game_state.gd` giriş notu | 937 | 934 |
| `sprint_system.gd` `_end_week` | 720-746 | 738-764 |
| `sprint_system.gd` `_request_decision` çağrıları | 166, 745 | 167, 763 |
| `sprint_system.gd` `EventGate.request(event_id)` | 849 | 867 |
| `sprint_system.gd` `team.demo_day` | 167 | 168 |
| `sprint_system.gd` `_auto_start` | 962 | 980 |
| `sprint_system.gd` `sync_plan_hold` | 1154-1165 | 1181-1191 |
| `sprint_system.gd` `_close`, sürüm kaydı | 986-1083, 1059-1066 | 1007-1105, 1089-1096 |
| `sprint_bridges.gd` rakip, basın | 134, 162 | 79, 107 |
| `sprint_bridges.gd` `mentor_advisory_changed` (boş anahtar) | 187 | 132 (`open_paid_plan`) |
| `main.gd` `_open_note` | 3829-3834 | 3823-3828 |
| `main.gd` özet ve not dinleyicisi | 4243-4251 | 4238-4246 |
| `main.gd` `_run_inbox_shot` | 751 | 750 |
| `vc_pitch_system.gd` term sheet teslimi | 865-887 | 903-916 (`daily_tick` 894-901) |
| `vc_pitch_system.gd` geri arama | 890-903 | 919-933 |
| `vc_pitch_system.gd` görüşme günü | 914-921 | 946-952 |
| `save_manager.gd` oto kayıt | 405-408 | 407-410 |
| `save_manager.gd` `can_save` | 85-95 | 81- |
| `effects.gd` `ticker_push`, `notify`, `mentor_advisory` | 446-458, 531 | 440-455, 526 |
| `top_bar.gd` bekleyen sayacı | 253, 318 | 258, 323 |
| `endgame_smoke.gd` `_sim_day` | 559-561 | 573-575 |

Aynı kalanlar (dosya A'nın diff'inde yok): `message_system.gd`, `engine.gd`, `queue.gd`, `history.gd`, `papers.gd`, `event_gate.gd`, `presenter.gd`, `mail_pane.gd`, `events_tab.gd`, `office_notice_stack.gd`, `news_ticker.gd`, `summary_system.gd`, `sales_rep_system.gd`, `hr_morale_system.gd`, `hr_search_system.gd`, `hr_system.gd` (26-47, 100), `customer_rep_system.gd`, `endings_system.gd`, `news_feed_system.gd`, `office_system.gd`, `work_hours_system.gd` (`company_window` `:112`).

### T4 · Önceki öneri hâlâ geçerli mi
| Öneri | Karar | Gerekçe |
|---|---|---|
| Her mağazada tek `at` alanı (mutlak dakika, `-1` saatsiz) | **geçerli** | A hiçbir mesaj, kuyruk, kâğıt ya da geçmiş şemasını değiştirmedi; `GameState.messages` şekli aynı (`message_system.gd:18-19`) |
| `MailClock` (statik, durumsuz) | **geçerli** | `reset_all_owners` (`save_manager.gd:322`) listesine girmez; `company_window` ve `day_minute` aynı |
| Mesajlar için dış kutu `mail_outbox` | **geçerli** | `post` çağıranları aynı (T1); B8 teşekkürü ve B7 söz mesajı da aynı kapıdan |
| Hatırlatıcılar R-A: `desk_arrivals` | **geçerli** | `desk()` koşulları aynı; A yalnız `risk_reason` metnini değiştirdi (T2 #7) |
| Frank satırı `mentor_line_at` | **geçerli** | alan `game_state.gd:308-309`, dinleyici `:317-319`; yayıcılar T3'teki yeni adreslerde |
| Şema 17, göç yok | **geçerli** | AB-1 ✅ (A 16'yı aldı, `SCHEMA_VERSION` `save_manager.gd:16`); B1 `if version < 17` satırını `:202-203` zincirinin altına koyar |
| AB-2: günlük dağıtım sırası değişmez | **doğrulandı** | yuva sırası ve numaraları aynı, A yeni yuva eklemedi (`time_manager.gd:373-417`) |
| Acil ayrımı `urgent` etiketi | **geçerli** | B3 yazar; `EvQueue.rank` sorunu (son uyarı `critical`'in üstünde) sürüyor (`queue.gd:74-83`) |

### T5 · B1'i değiştiren bulgular
1. **Saatlik dilimde `ProductSystem` yok** (T2 #1). `MailClock.hourly_tick` üç çağrılı dilimin çevresine girer; B0t'nin "`time_manager.gd:432` öncesine" cümlesi bugün "`:430` `EventGate.hourly_tick` öncesine" okunur.
2. **Günlük yola giren kart 70** (71 değil). Kabul 4.4 vakasının kart listesi bu sayıya göre.
3. **Smoke yardımcıları 160 + 43 çağıran.** `release_all` ya da pencereye alma kararı (B0t §6 sonu) B1'de verilir; çağıran sayısı kararı değiştirmez.
4. **B3, B7, B8 yeni 00:00 üreticileri olarak:** `line_bugs_cleared` ve `version_shipped` 00:00'da sprint kapanışında yayılır (`sprint_system.gd:1032, 1102`). Teşekkür maili ve B2C yorum satırı bu anda doğar; ikisi de dış kutudan ve mesai kuralıyla teslim edilir. Acil durumun "hızla kapandı" bayrağı ise oyuncu kararı anında (gündüz ya da gece) doğar; teşekkür maili sürüm anına kadar dış kutuda bekleyebilir.
5. **Frank satırı üç yayıcıdan** (`effects.gd:526` oyuncu kararı, `sprint_bridges.gd:132` boş anahtar, `vc_pitch_system.gd:931` 00:00): boş anahtar her zaman anında, T4 kuralı değişmedi.
6. **Sorun bulunmadı:** ihmal kuralının itibar düşüşü ve VC callback yenilemesi sessiz durum değişikliği; teslim kuralına girmezler.
7. **Hâlâ doğrulanmayan:** ofis taşıma toast'ının gece görünürlüğü (§8), kullanıcıya zaman göstermeyen "Biz" arşivinin damga ihtiyacı.

## B0v · Opus kontrolü (2026-10-17)
Tazeleme doğrulandı (T1-T5 geçerli). Düzeltmeler:
1. **Sinyaller:** salıverme anına taşınacaklar `summary_ready` ve `product_note_issued`'dır (`main.gd:4237, 4243`
   dinler). `weekly_sales_report_issued`'ı oyunda dinleyen yok (yalnız `endgame_smoke.gd:16322`), `post`'tan önce
   yayılıyor (`sales_rep_system.gd:284`); taşınması gerekmez.
2. **Varlık okuması:** süzülmeyecek okuma `_settle_decision` `sprint_system.gd:881-882`'dir (§5.3'teki 863-864 eski).
   `decision_paper()` (`:963-968`) ve `product_model.gd:508` gösterimdir, süzülür.
3. **Gece kapısı (B3 için):** Karar 4 "gece yalnız acil durum kartı" der; son uyarı ve kepenk de acil sayılıp 00:00'da
   kuyruğa girer ve sırada öndedir (`queue.gd:72-82`). B1'in `at <= şimdi` süzgeci onları gizlemez. B3, aynı
   `EvQueue.next()` (`queue.gd:60`) içinde mesai penceresi dışında yalnız olay kartını açar; B1 süzgeci bu kapıya yer
   bırakacak biçimde tek fonksiyonda yazar.
4. **Damga parametresi:** W1 gece kesintisinde damgayı kartın açıldığı tam saat yaptı (03:00), parametre gerekmez. Ay
   sonu (22:40 → 23:00), ödeme, bozulma ve fırtına (damga açılıştan önce, aynı pencerede) parametre ister: B4 ekler.
5. **Teşekkür maili** mesaj değil seçeneksiz not kartıdır (`customer.release_thanks`, müşteri slotu): gönderen
   `contact()`'tan gelir, teslim `_admit`'in `at` kuralıyla olur (B0_HARITA §9).
6. **Mesai ≠ gece:** `is_night()` `workday_end` ile 08:00 arasıdır (`time_manager.gd:208-211`); mesai başı 08:00-11:00
   (`work_hours_system.gd:112-116`). 08:00 ile mesai başı arası gece değildir ama mesai dışıdır: acil olmayan teslim ve
   B3'ün kapısı pencereyi okur, `is_night()`'ı değil.
