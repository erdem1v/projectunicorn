# RAPOR C · Faz C devir raporu (ürün sayfası, sunucu, giderler, B2B hesaplar)

2026-10-22 · Uygulayıcı oturum 7a140906 (Erdem bu oturumu kapatıp Faz C'ye yeni bir çalışma yöntemiyle devam edecek).
Bu dosya tek başına yeterli olacak biçimde yazıldı. Taslak `main` @ `cf452525` üstünden yazıldı, 2026-10-22'nin dört commit'iyle güncellendi (son C commit'i `0616245`;
aradaki başka commit'ler Q K20 `7012218a` ve D D0a `8038c424`). Satır numaraları ilk taslağın HEAD'ine göredir; kayabilir.


## 0. Bir bakışta

- **Biten:** 13 commit main'de: C2, C1, C4, C2 düzeltmesi, C7, C9a, C9b, C2b, C9a-3B (push'lu, origin/main = `cf452525`) ve
  2026-10-22'nin dört tam tanımlı işi C9a-3C `3535b6c`, C2c `ee7a611`, C7b `2916cb5`, C9c `0616245` (push YOK; Erdem "push et" deyince) (§1).
- **Sırada:** yok. Yardımcı yönetmenin 2026-10-22 kararıyla C yeni iş almaz; devam yeni çalışma yöntemiyle, bu rapordan.
- **Park:** C3a, C3b, C5, C6, C8 ve PLAN_C_P2'nin önerdiği C10, C11a, C11b, C12, C3b-4a/4b. Modül, fiyat, B2B pazarlık ve pazar
  modeli için önce Erdem'le ayrıntılı PRD yazılacak (§4).
- **Şema:** C göç yazmadı. `SaveManager.SCHEMA_VERSION` **18** (`scripts/autoload/save_manager.gd:16`, zincirin son kolu
  `if version < 18` :204). Sıradaki numarayı ilk inen adım alır (§5.4).
- **E2 ölçümü ve R adımı koşmadı;** E2 listesinin durumu §5.1'de. Bu dosya PLAN'daki R'nin yerine devir raporudur.
- **Erdem'in kararını bekleyen:** 10 sabit grubu (§2, C7b'nin `REPORT_WORST_LEAD`'i dahil), 8 commit'in TR/EN metni (C2c dahil) (tek metin turu, §3), 7 ayrı karar (§5.5).

## 1. Commit'ler

| sha | adım | tarih | oyuncu ne görür | kapılar | onay bekleyen |
|---|---|---|---|---|---|
| `2e8dfad` | C2 | 2026-10-20 | İlk haftada gider $0, runway satırı yok; para kaybetmeye başladığı hafta runway belirir. Araç ve servis satırı hiçbir ekranda yok; gider listesi boşken "Bu ay gider yok."; term sheet masası gider 0'da yalnız "Kasa: ..." yazar. | event-lint 0, loc_residue 0, loc_csv_integrity, hedefli vakalar, run_gate 3/3 (full_run ve full_run_b2c running_on_fumes, vc_cautious series_a_close, 0 ERROR), TR ve EN kareler | TR/EN (HR_HIRE_CONFIRM_BODY_AFTER, TERM_CASH, FIN_BURN_EMPTY, ONB_DOC_BURN). Sabit yok (silme adımı) |
| `16a0eb6` | C1 | 2026-10-20 | v1.0'dan sonra Ürün penceresinde GENEL BAKIŞ kâğıdı ve Sunucu bloğu: Ekonomik, Standart, Kurumsal kademe; kapasite, fatura, %90'da sarı ve %100'de kırmızı yük çubuğu, Artır ve Azalt, Otomatik ayarla. Dolu sunucu yalnız kesinti ihtimalini artırır, kesinti kartı yükü söyler; Kurumsal'dan inilmez. Ar-Ge ağacı 19 düğüm (Olay el kitabı kalktı). | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, hedefli vakalar, tick-probe gece en çok 146,36 ms (kapı 148,2), run_gate 3/3 (vc_cautious running_on_fumes ile bitti), TR, EN, renk körü, 1,25 kareler | TR/EN (38 yeni anahtar, 3 değişen). Sabitler (§2: adım, yük çizgileri, yük katı, otomatik ayar, büyüme satırı) |
| `7f4d51f` | C4 | 2026-10-21 | Pazarlık onay şeridinde üçüncü satır "Sözleşme maddesi: kurumsal sunucu · 8 hafta içinde · ayda $180 fazla"; hesabın Bilgi İşlem'inden dört mail ve mailde "Kurumsal sunucuya geç" düğmesi; Satış hesap kartında tarihli etiket; Genel Bakış'ta "Kurumsal sunucu bekleyen N hesap". Ekonomik kademe büyük hesabın imzasını artık engellemez; aşımdaki kapasite sorusu görüşmeden kalktı. | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, 22 hedefli vaka, run_gate 3/3 (full_run ve full_run_b2c running_on_fumes, vc_cautious series_a_close, 0 ERROR), W1 eşliği 34/34, TR ve EN kareler | TR/EN (16 yeni, SALES_LOCK_PROVIDER değişti). Sabitler (madde: 3★, 8 hf, 4 hf, 20) |
| `ec78197` | C2 düzeltmesi | 2026-10-21 | Oyuncu bir şey görmez. `save_roundtrip_fingerprint` fikstürü pazarlama giderini `FinanceSystem.set_burn_category` ile yazar (C2'den beri düşüyordu, Q buldu). | SMOKE PASS save_roundtrip_fingerprint | yok |
| `0c13424` | C7 | 2026-10-21 | Olaylar kutusunda "{ad} · Müşteri temsilcisi" imzalı "Destek · Hafta N" raporu; "En çok sorun çıkan" ve "Bu hafta" bölümleri; düğme en kötü hattın alanını Ürün SPRINT'te açar. Müşteri İlişkileri'nde temsilci yoksa ya da yeni bir şey yoksa rapor gelmez. | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, 26 hedefli vaka, run_gate 3/3 (0 ERROR), W1 eşliği 10/10, TR ve EN kareler | TR/EN (10 SUPPORT_RPT_* anahtarı). Sabit REPORT_BEHIND_ONE_IN |
| `395576f` | C9a | 2026-10-21 | Şehir haritasında ofis kartı "12 masa · ayda $4.000 kira", tek şart "Peşin: $8.000, iki aylık kira"; Finans'ta "Ofis taşınması, iki aylık peşin kira" ve Ofis gider kalemi; Atlas'ta ofisteyken "Masa N · boş M" ve "Ofisleri gör", masa dolunca uyarı şeridi ve işe alım kapalı. Evde sınır yok. Maaş bantları ×1,5. | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, 40+ hedefli vaka, run_gate 3/3 (0 ERROR), plausibility_run fails=0 (40 + 4 uzun), W1 eşliği 11/11, TR, EN, renk körü kareler | TR/EN (10 yeni, OFFICE_REQ_CASH değişti). Sabitler: bot eşikleri (katalog değerleri Erdem'in, §2) |
| `09c9101` | C9b | 2026-10-21 | Henüz varılmamış kademenin kartında yeşil "Buraya taşınmak markanı bir kez 3 puan yükseltir."; varış bildirimi "Yeni ofis · İş hanı · Marka +3", üst barda marka 50'den 53'e. Frank'in taşınma kartı seed imzasından sonra gelir, kapsamı ea (metin taslaktı). | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, office_brand_once, office_move_gates_and_save, desk_cap_blocks_hire, --why-fire=funding.frank_office_move, run_gate 3/3 (ikinci koşu), TR ofis kartı ve EN varış bildirimi kareleri | TR/EN (OFFICE_CARD_BRAND, OFFICE_TOAST_BRAND). Sabitler (marka 3/6/10) |
| `50dcb19` | C2b | 2026-10-21 | Yatırımcı notu kâğıdı ekrandaki sayıyı yazar ("Runway satırında 8 hafta yazıyor."); kâğıt beklerken şirket kâra geçerse gövde "Gelir şu an gideri karşılıyor." olur; hiçbir kart "9999 hafta" yazmaz. Kasa eksideyken birikim notu ve yan iş kartları gelebilir. | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, runway_weeks_seam ve ilgili hedefli vakalar (runway, beat, kepenk, iflas), plausibility_run fails=0, run_gate 3/3 (0 ERROR), 8 TR/EN event-shot karesi, --inbox-shot=beat | TR/EN (`monthly_update.json` gövde varyantı). Sabit yok |
| `80cafcd` | C9a-3B | 2026-10-21 | İş hanı'nda bitkinin yanındaki üçüncü kümede yeni çalışan masası; 12 kişilik kadroda herkes kendi masasında. | check_export.py 0 sorun, all_scripts_load, event-lint 0, loc_residue 0, loc_csv_integrity, office_pace_linear, office_move_gates_and_save, desk_cap_blocks_hire, office_brand_once, İş hanı 13:00 ve 22:00 TR, 13:00 EN kareleri, kalabalık probu ishani:11:1 ve :12:1 | Erdem'in görsel onayı (üçüncü kümenin arka sol köşesi boş kaldı → C9a-3C) |
| `ee7a611` | C2c | 2026-10-22 | Kâra geçmiş şirkette bekleyen yatırımcı notu "Aylık not" başlığıyla açılır; "Maaşlarda indirime git" ("Maaşlar şu an gelirden ödeniyor.") ve "Notu iyi haberlerle aç" ("Bu ay notta gömülecek bir runway satırı yok.") kilitli ve nedenli, ek yatırım ve tanıştırma açık. 8 haftalık hâlde kart eskisi gibi. Ek yatırım ve iyi haber kilitlerinin {investor} adı mail panelinde artık parantezle çıkmaz. Varyant başlıklı kartta tanıştırma şıkkının çalışma anı hatası (String(sözlük)) düzeldi; lint varyant başlık, şık ve kilit nedenlerinin her kolunu okur. | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, runway_weeks_seam (altı kasıtlı bozulmada düştü), card_body_tokens_resolve, event_chip_coverage, event_history_names_survive, quiet_cards_fill_empty_floor, event_lint_v3_rules, event_beat_*, productivity_mod_paces_the_sprint, run_gate 3/3, dört event-shot karesi TR/EN | TR/EN onay bekliyor: üç satır içi metin (kâr başlığı, maaş indirimi kilidi, iyi haber kilidinin kâr kolu) |
| `2916cb5` | C7b | 2026-10-22 | En kötü hat düzeltildiği hafta raporun "Bu hafta" bölümünde yalnız düzeltme satırı var, "en çok sorunlu yer artık" satırı yok; başka hat önceki en kötüyü azalmadan en az iki açık hatayla geçince satır gelir. Rapor daha seyrek: botlu full_run'da rapor gelen hafta / temsilcili hafta HEAD 70/81, (b) 70/81, (a)+(b) 57/81. PROBE END'e kalıcı `support_reports=` ve `support_news=` alanları. | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, support_report_quiet_week (iki kasıtlı bozulmada düştü), support_* ve C7'nin hedefli vakaları, üç full_run ölçümü, run_gate 3/3, support_week karesi TR ve EN | Sabit: `SupportSystem.REPORT_WORST_LEAD = 2` (yeni) ve `REPORT_BEHIND_ONE_IN = 5`. Açık konu (yardımcı yönetmende): 57/81 hâlâ yarıdan fazla; "hat boşaldı" haberi (CLEARED) haftaların %65'inde; "kısmi düzeltme" haberi (SHIPPED) bugün tetiklenemiyor (hata yalnız hattı boşaltan düzeltmeyle azalır). |
| `3535b6c` | C9a-3C | 2026-10-22 | İş hanı'nın üç masa kümesi birbirinin aynısı, her biri dört koltuklu; üçüncü kümenin arka sol köşesi dolu. İş hanı'na 13 kişi sığar (12 çalışan ve kurucu): şehir haritasındaki kart "13 masa · ayda $4.000 kira", dolu ofiste Atlas "Masa 13 · boş 0" der. Katalog 12'den 13'e (Erdem 2026-10-22 (a)), değer onaylı. | check_export.py 0 sorun, all_scripts_load, event-lint 0, loc_residue 0, loc_csv_integrity, office_pace_linear, office_move_gates_and_save, desk_cap_blocks_hire (13 masa, falsification), office_brand_once, run_gate 3/3 (full_run ve full_run_b2c running_on_fumes, vc_cautious series_a_close), move_weeks 84,90 (C9a ile aynı), İş hanı 13:00 ve 22:00 TR, 13:00 EN, nav, harita kartı TR ve EN, atlas-dolu kareleri, kalabalık probu 11, 12 ve 13 kişi (hareket hatası 0; 13 kişide (10,5) çevresinde bilinen toplantı takipçisi örtüşmesi) | Erdem'in görsel onayı: üç özdeş küme (önce/sonra kesiti `c_taslak/kareler/C9a-3C_once_13.png`, `C9a-3C_sonra_13.png`). Yeni arka sol koltuğun ziyaret yolu saksının 0,28 m yanından geçer; gerekirse bitki plant(16, 0, 14.2)'ye alınır (tam dışa aktarma ister). |
| `0616245` | C9c | 2026-10-22 | Seed imzasından sonra evdeki kurucuya Frank "Taşınma vakti" kartını demoda da getirir; mesaj: "Daire işini gördü, bundan sonrasını kaldırmaz. Seed'i şirket senin mutfağında otursun diye kapatmadın. Şehirde bir dolaş, şirkete düzgün bir ofis bul." (EN "... You didn't close a seed round so the company could keep living in your kitchen. ..."). Kapsam ea'dan demoya; botlu full_run'da kart 30. günde bir kez gelir. | event-lint 0, loc_residue 0, loc_csv_integrity, all_scripts_load, --why-fire (ea'ya geri çevrilince G2'de reddedildi), office_brand_once, office_move_gates_and_save, kapsam ve demo vakaları (event_i5_trigger_is_data, ending_modes_by_build, gate_scope_and_halves ve öbürleri), run_gate 3/3, event-shot TR ve EN | yok (metin Erdem onaylı) |

Dört işin briefleri `c_taslak/araclar/<adım>_args.json`; kareler `c_taslak/kareler/`.

## 2. Onay bekleyen sabitler

Erdem'in Karar 16'sı (`ERDEM_KARARLAR_2026-10-20.md:46`): C'nin "onay bekliyor" sabitleri PRD değerleriyle girer; ölçüm turunda
sorun çıkaranlar Erdem'e gelir. Ölçüm turu (E2) koşmadı, yani hiçbiri henüz Erdem'e ölçümle gitmedi.

**Onay bekleyen (9 grup):**

| Ad | Değer | Dosya:satır (HEAD) | Commit | Dayanak |
|---|---|---|---|---|
| `InfraSystem.CAPACITY_STEP_SHARE` | 0,10 (en az 1 birim) | `scripts/systems/infra_system.gd:40` | C1 | PRD Karar 1 "(onay bekliyor)" |
| `InfraSystem.LOAD_AMBER`, `LOAD_OVER` | 90, 100 | `infra_system.gd:47`, `:48` | C1 | 90 Erdem'in sözü ("%90'ı geçince"), 100 PRD Karar 1 |
| `incident.load` amber, over | 1,5, 2,5 | `data/product/sprint.json:50` | C1 | Kural Erdem'in Karar 1'i (A, onaylı); basamaklar PRD Karar 1 "onay bekliyor" |
| `InfraSystem.AUTO_EDGE`, `AUTO_TARGET` | 80, 65 | `infra_system.gd:53`, `:54` | C1 | PRD Karar 1; C0r doğruladı |
| `InfraSystem.GROWTH_LOOKBACK_WEEKS`, `GROWTH_HORIZON_WEEKS` | 4, 4 | `infra_system.gd:57`, `:58` | C1 | PRD Karar 1 "Büyüme satırı (onay bekliyor)" |
| `B2BConstants.CLAUSE_STAR`, `CLAUSE_WEEKS`, `CLAUSE_NOTICE_WEEKS`, `CLAUSE_MARGIN` | 3, 8, 4, 20 | `scripts/systems/b2b_constants.gd:49`, `:50`, `:51`, `:52` | C4 | PRD Karar 4 (8 hafta Erdem'in "iki ay" örneği); SENTEZ §14.2 eşik 3 kalır |
| `SupportSystem.REPORT_BEHIND_ONE_IN` | 5 (haftanın gelenlerinin beşte biri) | `scripts/systems/support_system.gd` (C7b'den sonra satır kaydı) | C7 | PRD Karar 12 |
| `SupportSystem.REPORT_WORST_LEAD` | 2 (yeni en kötü hat öncekini en az 2 açık hatayla geçmeli) | `scripts/systems/support_system.gd` (`REPORT_BEHIND_ONE_IN`'in yanında) | C7b | Yardımcı yönetmenin 2026-10-22 brifi, kural (a) |
| `RunProbe.HIRE_MONTHS`, `FIRST_HIRE_MONTHS`, `MOVE_MONTHS` (bot) | 6; spend 2, hoard 6,7; 6, spend 2 | `scripts/debug/run_probe.gd:227`, `:228`, `:231` | C9a | PLAN_C_E1 §2 C9a "bot eşikleri onay bekliyor"; harness (CLAUDE.md §3) |
| `OfficeConstants.CATALOG` `brand` | İş hanı 3, Plaza 6, Loft 10 | `scripts/systems/office_constants.gd:33`, `:43`, `:54` | C9b | Erdem'in seçtiği seçeneğin örnek değerleri (PLAN_C_E1 §8) |

Bilgi (harness, onay gerekmez): C1 botunun `SERVER_LINES` lean 95, wide 60 ve `SERVER_PRESSES` 40 (`run_probe.gd:223`, `:225`).

**Erdem'in onayladığı (ofis değerleri koda [WORKING] işaretiyle girdi; işaret onayı değiştirmez):**
- `InfraSystem.UNIT_PRICE_B2B` 60/120/240, `UNIT_PRICE_B2C` 125/250/500 (`infra_system.gd:25`, `:23`; C1): Karar 2 (Standart $120 ve
  $250; 1 : 2 : 4 oranı PRD Karar 2'de Erdem'in).
- `OfficeConstants.UPFRONT_MONTHS` 2 (`office_constants.gd:12`; C9a): Karar 3.
- `desks` 13/38/70 (`:31`, `:41`, `:52`): Karar 6; İş hanı 12'den 13'e Erdem 2026-10-22 (a) ile, C9a-3C `3535b6c` yazdı, işaretsiz.
- `rent` 4.000/8.000/18.000 (`:32`, `:42`, `:53`; C9a): PRD Karar 3 "Ofis kirası (Erdem)"; Karar 3'ün peşin tutarları bununla.
- `HRConstants.SALARY_BANDS_BY_LEVEL` ×1,5 (`scripts/systems/hr_constants.gd:586-593`; C9a): PRD Karar 3 "Maaş bantları ×1,5 (Erdem)".
- Standart kademenin kesinti katı ×0,5 (`sprint.json:49`, C öncesi): Karar 13.

## 3. Onay bekleyen metinler (TR/EN)

Erdem'in Karar 30'u (`ERDEM_KARARLAR_2026-10-20.md:66`): araştırma ve tasarım bitince **tek metin turu**; bugünkü metinler büyük
ölçüde kabul. Yardımcı yönetmen ACIK_KARARLAR'daki "TR/EN onay bekliyor" metin maddelerini kabul sayıp sildi (aynı dosya :143).
Commit mesajları yine "TR/EN onay bekliyor" der; metinler o turda okunur.

| Commit | CSV anahtarları ve kart metni | W1 bağı |
|---|---|---|
| C2 `2e8dfad` | yeni FIN_BURN_EMPTY, HR_HIRE_CONFIRM_BODY_AFTER, TERM_CASH; değişen ONB_DOC_BURN; silinen FIN_BURN_TOOLS, FIN_BURN_SERVICE, HR_ROW_TOOLS, RUNWAY_PROFITABLE, RUNWAY_PROFITABLE_NOTE | C2'nin 7 öğesi |
| C1 `16a0eb6` | yeni PRODUCT_OV_TAB_OVERVIEW, PRODUCT_OV_LOCKED ve 36 PRODUCT_SERVER_* anahtarı; değişen PROD_RND_NODE_SCALABLE_BACKEND_DESC, _DISCOVERY, _UNLOCK; silinen PROD_RND_NODE_INCIDENT_PLAYBOOK ve _DESC, _UNLOCK; kart `incident_outage_b2b/b2c.json` gövdesi `by_seam: olay.outage_load` ("91" kolu yükü söyleyen cümle) | C1'in 41 öğesi; `incident.load_line` kartta `{pct}` yerine `{seam:olay.outage_load}` ile |
| C4 `7f4d51f` | yeni 15 SALES_CLAUSE_* ve SALES_LOG_CLAUSE_ENDED; değişen SALES_LOCK_PROVIDER ("Sunucuların Ekonomik kademede."); silinen SALES_PROBE_PROBE_CAPACITY, SALES_ANS_PROBE_CAPACITY_A_ADMIT, _A_PROMISE, SALES_WHALE_PROVIDER_OR_CERT | C4'ün 17 öğesi; `sat.term_clause` C3a'ya kaldı |
| C7 `0c13424` | yeni SUPPORT_RPT_SUBJECT, _SENDER, _SEC_TROUBLE, _SEC_WEEK, _NEW_PRIORITY, _NEW_CLEARED, _NEW_WORST, _SHIPPED, _BEHIND, _BTN_FIX | C7'nin 10 öğesi; `support.sec_asked`, `support.new_request` C6'ya kaldı |
| C9a `395576f` | yeni FIN_OFFICE_TIP, FIN_ONETIME_OFFICE, HR_ATLAS_DESK_LINE, _FULL, _OFFICES, OFFICE_CARD_LINE, _CURRENT, _HOME, OFFICE_MOVE_TIP, OFFICE_MOVE_OVER_CAP; değişen OFFICE_REQ_CASH; silinen OFFICE_REQ_ANGEL, _TEAM, _BRAND, _NOW_CLOSED, _NOW_OPEN, OFFICE_CARD_UNMET, OFFICE_CARD_DESKS | C9 öğeleri (C9a ve C9b birlikte 12) |
| C9b `09c9101` | yeni OFFICE_CARD_BRAND, OFFICE_TOAST_BRAND; Frank'in kartı (`funding/frank_office_move.json`) yalnız koşul değişti, metin değişmedi | `office.card_brand` bayt bayt |
| C2b `50dcb19` | CSV yok; `funding/monthly_update.json` gövdesi `by_seam: finance.runway_weeks`: "0" kolu eski cümle, "9999" kolu TR "Gelir şu an gideri karşılıyor." EN "Revenue covers the costs right now." | yok |
| C2c `ee7a611` | CSV yok; `monthly_update.json` satır içi: başlık 9999 kolu "Aylık not" / "The monthly update"; maaş indirimi kilidi "Maaşlar şu an gelirden ödeniyor." / "Payroll is paid out of revenue right now."; iyi haber kilidinin 9999 kolu "Bu ay notta gömülecek bir runway satırı yok." / "There is no runway line to bury this month." | yok |

W1 eşliği bu rapor için HEAD'e karşı yeniden koşuldu (`araclar/w1parity.py`, W1 + W1_E1): yukarıdaki sayılar bayt bayt bulunan
öğelerdir. W1_E1'in düşürdükleri: C1 `server.release_drop_seats`, `_users`, `server.tier_tip_no_enterprise`; C4
`clause.downgrade_fact`, `_one`; C9 `atlas.home`, `atlas.moving`, `office.req_team`.
C2c'nin yeni satır içi metinleri sonraki metin turuna gider; C9c'nin Frank metni Erdem onaylıdır (2026-10-22,
`ERDEM_KARARLAR_2026-10-20.md:174`), yeni onay istemez. W2'nin 232 metni park edilen adımlarındır, hepsi ÖNERİ (§4).

## 4. Park edilen adımlar ve neden

**Adımlar:** C3a (memnuniyet defteri ve tek göç), C3b (imza ve kapanış), C5 (yenileme), C6 (istekler, Genel Bakış sol sütunu),
C8 (HESAPLAR tablosu). PLAN_C_P2 bunları böler ve şunları ekler: C10 (dönem tavanı), C11a (rakip şirketler ve standart), C11b
(pazar havuzu), C12 (yıllık rapor ve modül ödülü), C3b-4a (önerilen fiyat formülü), C3b-4b (kurucu görüşmesinin akışı).

**Tarihçe:**
1. 2026-10-20, E1 cevabı: bu beş adım müşteri beklentisi algoritmasının araştırmasına bağlandı; beklentiye bağlı olmayan C1, C2,
   C4, C7, C9 yürüdü (`ERDEM_KARARLAR_2026-10-20.md:70`).
2. Aynı gün "Pazar merdiveni" tasarımı reddedildi (K1-K9, :78-91); gerçek ERP pazarı araştırıldı (Pazar 2). 2026-10-21 Erdem'in
   24-31 cevapları geldi (:147-156); sentez `pazar2/out/SENTEZ_ERP_PAZARI.md` kapandı, tek açık soru YZ dalgası
   (`pazar2/out/SORU_PAKETI_3.md`).
3. 2026-10-22 sabah: yardımcı yönetmen sentezi PRD saydı (:162), PLAN_C_P2'yi (20 adım, ~71 ajan saati) ve §8 varsayılanlarını
   onayladı (:166; PLAN_C_P2 §9). C0p ve W2 koştu.
4. Aynı gün öğleden sonra Erdem'in yönüyle DUR (:170): yalnız tam tanımlı işler ajana gider; modüller, fiyat, B2B pazarlık ve pazar
   modeli Erdem'le ayrıntılı konuşulmadı, önce ayrıntılı PRD yazılacak; sentez PRD yerine geçmez. Plan onaylarının hepsi geri alındı
   (PLAN_C_P2 başındaki PARK notu). B2B fiyat için Erdem'in kastı: premium fiyatın dolar cinsinden önerilen bir fiyatı olur,
   pazarlık onun üzerinden döner; ayrıntı satış ve pazarlık PRD'sinde (:171).

**Yeniden başlarken girdiler:**
- `pazar2/out/SENTEZ_ERP_PAZARI.md`: model; §14.2 (satır 1181) C'ye etkisi (C1, C2, C4, C7, C9 aynı; C3a büyük ölçüde kalır; C3b, C5,
  C6 yeniden yazılır; C8 genişler).
- `c_taslak/PLAN_C_P2.md`: §3 adım tablosu, §5 tek göç, §6 düşen eski plan, §7 E2 ekleri, §8 sessiz yerler. Kodlanmaz, PRD girdisidir.
- `c_taslak/C0p_HARITA.md`: PLAN_C_P2 adımlarının HEAD `cf452525`'e göre dosya:satırı; plan sapmaları sonundaki §S'de ve PLAN_C_P2
  §10'da. HEAD ilerledikçe satırlar kayar, kodlamadan önce tazelenir.
- `c_taslak/W2_METINLER.json/.md`: 232 metin ve 97 W1 düşüşü, `w2check.py` fail=0; hepsi ÖNERİ. İki yazım notu ("Üretim" yerine
  "İmalat"; eskime satırı 4-5★'ta "en iyi rakiplerde") de ÖNERİ'ye döndü.

**PLAN_C_P2 §8'in PRD'nin cevaplaması gereken sessiz yerleri** (10, 11, 12, 28 sentezle kapandı; "bilgi" karar istemez):
- 1 (bilgi). Finans birleşmesi (Defter + Nakit Akışı) kayıt kimliği sildiği için göç ister.
- 2. 10 modül, profil, 5 yıldız, rakip modeli, havuz, dönem tavanı ve yıllık raporun hangi faza ait olduğu.
- 3. Altı yeni modülün iş profili (dev, test, design); `IDENTITY_PROFILE_SHAPE` 2/1/2'yi zorlar, D'nin aşama payı profili okur.
- 4. Altı yeni modülün K3 Ar-Ge düğümü eşlemesi.
- 5. Modüller geldikten sonra aday uyumu ve B2B sayfa sözcüğü düzelene kadar (C3a-2 ile C3b-2 arası) ölçüm nasıl okunur, push olur mu.
- 6. Ürün terimi kalkınca memnuniyetin tabanı (öneri 70).
- 7. Hata terimi: sentezin anlattığı bugünkü −0,3/−20 mi, PRD'nin min(3 × H, 60)'ı mı.
- 8. "Ayrılma yalnız yenilemede" ile "Risk makinesi kalır" çelişkisi: Risk geri sayımı ve "Oyala" silinir mi.
- 9. "Memnun" ve "düşük": sim2'nin mutlak 80/50'si mi, hesabın toleransına göre mi (C4'ün fesih kuralı toleransı okur).
- 13. Kurucu görüşmesinde ibre ile kapanış zarı tek zar mı; cetvel, sabır ve karşı teklifin yerini ne alır (satış ve pazarlık PRD'si).
- 14. Rakibin haftalık puanı D'nin birimine bağlı (`person_points_week` ×5, Y(s), kadro tavanı): rakip neyi okur.
- 15. Eski kayıtta rakip durumu: boş durum 2012'den bugüne ileri mi sarılır.
- 16. Platform hatları uyum, eskime ve şarta girer mi, yalnız hata terimine mi.
- 17. B2B sayfa sözcüğü kalkınca D'nin önerisi ve çeyrek şeridi neyi okur.
- 18. Yıldız karışımını ürün uyumuyla kısan `product_strength` silinir mi; 5 elemanlı karışım.
- 19. 4★ ve 5★ adayda karşı masada kaç kişi, kaç soru.
- 20. İstek kesintisi kalkınca söz nerede verilir.
- 21 (bilgi). Kesinti sırası satırını C5 devralır ve değiştirmez (D sözleşmesi).
- 22. C0v'nin "bekler: C3a" soruları: 13 (B2C destek zararı), 15 (her sprint −3), 21 ("Hayır diyemez"), 22 ("Söz ver" +8), 26 (B2C
  kalibrasyonu), 28 (`risk_reason`).
- 23. Şirketin gidişi için sektör eğilim tablosu yok: sim2'nin %30/45/25'i mi.
- 24. Kurumsal madde ve modül şartı aynı hesapta: şart kendi alanlarıyla mı durur.
- 25. Standardı 0 olan modülde fiyat oranı tanımsız (q_std en az K1 mi).
- 26. Yıllık raporun kuralları nerede yazılır (oyunda yardım ekranı yok).
- 27. Dönem tablosunun mevzuat, dönem düğümü, yeni girişim ve YZ satırlarının sahibi; `ai_engine` 2012'de açık.
- 29. K3 sonrası arzı D'nin derinlik kartı da dönemin K4'ü de veriyor: standart hangisini sayar.
- 30. `docs/tasks/PRD_RAKIP_DUNYASI.md` I2 ve I3 sentezle örtüşüyor: ERP için hangisi geçerli.
- 31. "9 hat × 3 = 27" mührünün yeni hâli (10 modül ve 4 platform hattı) GDD'ye nasıl yazılır.
- 32. Kayıttaki alan hedefli kayıp izi modüle çevrilemiyor: göç temizler mi.
- 33. B2B hata terimindeki k'nin evi ve ilk kuran adım (D sözleşmesi; k'yi D7 kurar, C3a-1 önce gelir).
- 34. Defterdeki "Şart: <modül>" satırının tutarı (eskime satırıyla çift sayım riski).
- 35. Gece tikinin 148,2 ms kapısı: rakip adımı ve haftalık hesap taramasının bütçesi; taban ölçümü.
- 36. HESAPLAR'ın "Yenilemeyebilir" durumu ve "İlgilen" düğmesi yeni modelde ne olur.
- 37. Satıştaki söz kapanışı nasıl yükseltir (kapanış formülünün terimlerinde yok).
- 38. B2C yıllık raporu hangi veriden sıralanır (B2C rakipleri hesap ve havuz taşımıyor).

## 5. Açık kalan her şey

### 5.1 E2 ölçümleri (PLAN_C_E1 §9; E2 koşmadı)
1. Evre 2 ve 3 ekonomisi: **ölçülmedi** (gerçek koşu yok). Yalnız C2 öncesi sim (`c_taslak/msim/out/c0s_econ_e1.md`): evre 2'de kasa
   4 ayın altına inmiyor, evre 3 neti bugünün 2-5 katı. PLAN_C_P2 §7: yeni fiyat modeliyle gelir ve gider birlikte ölçülecekti (park).
2. `full_run_vc_cautious`'un sonu: **ölçülmedi.** C1'de `series_a_close`'dan `running_on_fumes`'a döndü, C4'ün run_gate'inde yeniden
   `series_a_close`; C7, C9a, C9b, C2b mesajları sonu yazmıyor. Neden (fiyat, bot politikası, gece kesintisi) bilinmiyor.
3. Sunucu faturasının gelire payı: **ölçülmedi.** `full_run_server_{lean,wide,auto}` ve `full_run_b2c_server_*` kolları C1'de hazır.
4. Evde kalmanın baskınlığı: **kısmen.** Sim ~30 hafta işe alım kapalı diyordu; C9a gerçek koşu: `full_run` İş hanı'na hf 84,
   Plaza'ya hf 90; `full_run_cash_spend` seed'de hf 26. `home` koluyla Series A farkı ölçülmedi. C9a'nın 6 ay eşiği de burada.
5. Gider 0'da `founder.savings_note` ve `founder.side_contract`: C2b kasa eksi hâlini açtı (seam 0); net akış ≥ 0 iken seam 9999,
   iki kart ilk haftalarda hâlâ gelmez. **Ölçülmedi.**
6. Geç B2C'de memnuniyet dibe oturuyor mu (eski ACIK 99'un belirtisi): **ölçülmedi.**
Ek (commit notlarından): C4 botunun fesih dalı (`clause_ended=`) full_run'da ölçülmüyor, iki bot kolu E2'de; C7'nin sıklığını C7b
ölçer (HEAD, (b), gerekirse (a)+(b)).

### 5.2 Bilinen sorunlar ve gözlemler
- **Sunucu fiyatı ×2-3:** Standart B2B $45 → $120. Karar 2 "fiyat esastır, %8-12 gider payı hedef değil" dedi; pay E2'de raporlanır.
- **Gece tiki marjı:** C1 sonrası 146,36 ms, kapı 148,2 (marj 1,84). PLAN_C_P2 Sessiz 35 C3a-1'den önce HEAD'de
  `--tick-probe=3:accounts=330` taban ölçümü istiyordu; koşmadı.
- **Kalabalık probu:** `ishani:12:1` iki koşunun birinde (10,5) noktasında toplantı takipçilerinin üst üste binmesini saydı (crowd=7),
  yeni masadan uzakta. C9a-3B mesajı "210c2a8'den beri", hafıza notu "f63c427'den beri" der (ikisi de 2026-10-10); doğrulanmadı.
- **`urun.decision_request_votes`** tüketici talep verisi gelene dek 0 döner; `sprint_pm_core_first`, `sprint_pm_phone_too_b2c`,
  `sprint_pm_spec_unclear_b2c` oyunda gelmez (Q K24 `03d24a3d` buldu; istek tasarımı C6'da, park). İki `sprint_pm_phone_too*.json` kartının
  tire temizliği Q K20'de (`7012218a`) indi.
- **C2b → C2c:** kârdaki not kâğıdının başlık ve şık sorunu C2c `ee7a611`'de kapandı (lint varyant başlığı okur).
- **C4:** kural PLAN_C_E1'in yalnız ay başı tikinden farklı olarak süre dolduğu tikte de işler (PRD Karar 4 "süre dolunca"); toplantı
  çıkışında Kurumsal'a geç düğmesi yok; mail düğmesi onay sormaz ve geri dönüşsüzdür; −10 durum terimi C3a'ya kaldı (park).
- **C7:** botlu full_run'da 82 haftanın 77'sinde rapor geliyor (en kötü hat değişti 65, boşaldı 60) → C7b.
- **C9a:** C2 ölçümünün "seed'de İş hanı" öngörüsü gerçek koşuda tutmadı (×1,5 maaşla bot erken ve çok alıyor).
- **C9b oynanış uyarısı:** uzaktan çalışmanın bedeli gelene kadar evde kalmak baskın strateji (PLAN_C_E1 §8).
- **C9a-3B:** üçüncü kümenin arka sol köşesi boş → C9a-3C. `bake_nav`'ın "Identifier not found: GameState" satırları autoload'suz
  araç koşusundandır, fırınlama tamamlanır.
- **Karar 15 rengi:** Atlas şeridi `D_WARN` (#E8913A, kehribar); Erdem "sarı" dedi. Yeni renk yazılmadı, Erdem karede görür.
- **Karar 1'in bilgi notu** ("Yerel'de 12 hata ve %104 yükte haftalık kesinti %75") HEAD sayılarıyla tutmuyor (0,1 × (1 + 12 / 8) × 2,5 =
  0,625, yalnız kesinti payına uygulanınca daha düşük); kural değişmez (PLAN_C_E1 "Düzeltemediğim").
- **Karar 13 notu:** maddeli müşterisi olmayan B2C oyuncusu Kurumsal'a geçerse faturası kalıcı 2 katı; playtest'te izlenir.
- **`c_taslak/araclar/faz_c_step.js`** yola bağlı değil: `w1parity.py`'yi `araclar/`'dan çağırır, Godot APPDATA dizinlerini
  args'ın `scratch` alanına (yeni oturumun scratchpad'i) açar; alan yoksa `araclar/run/`.

- **Destek raporu sıklığı (C7b sonrası, park):** botlu full_run'da rapor gelen hafta / temsilcili hafta 57/81; yardımcı yönetmen
  2026-10-22'de C7b'yi kabul etti, (a) eşiği `REPORT_WORST_LEAD` [WORKING] kalır. Gerisi net iş değil, park: "hat temizlendi"
  haberi (CLEARED, haftaların %65'i) rapor sebebi sayılsın mı, haberler tek raporda mı birleşsin; soru Erdem'in konuşulacaklar
  sayfasında hesap yaşamı PRD'sine gider. ACIK_KARARLAR'a yazılmadı (yardımcı yönetmenin kararı).
- **SUPPORT_RPT_SHIPPED dalı:** bugün tetiklenemez (açık hata yalnız hattı tümden boşaltan `ProductState.clear_line_bugs` ile
  azalır; ölçümde 0). Silinmedi: D'nin yeni hata modeli (D3) kısmi düzeltmeyi mümkün kılabilir, D3'ten sonra yeniden bakılır.
- **C7b HEAD ölçümü:** sayaç eklenip kural değişmeden HEAD 70/81 (worst 55, cleared 53); C7'nin ölçümü 77/82 (worst 65,
  cleared 60). Fark büyük olasılıkla C9a'nın bot ve maaş değişikliğinden (botun kadrosu ve hata akışı); C7 ağacı ayrıca
  koşturulmadı, doğrulanmadı.

### 5.3 ACIK_ISLER'e girmemiş ya da bayatlamış maddeler (C bu dosyalara yazmaz; yardımcı yönetmene)
- ISLER'de yok (HEAD'de aranıp bulunmadı): uzaktan çalışmanın ekip büyüdükçe bedeli; kredi (Erdem: "sonra, ayrı tasarım");
  `--tab-shot=product` kırığı (PLAN_C_E1 §5 madde 30).
- ACIK_KARARLAR'da C9a ve C9b'den sonra bayat: 60 ("taşınma bedelsiz kalır"; C9a kira ve peşin getirdi), 62 (ekip şartı; C9a sildi),
  66 (Frank çeki şartı ve `OFFICE_REQ_ANGEL`; C9a sildi), 69 (Frank kartının koşulu ve kapsamı; C9b koşulu değiştirdi, C9c `0616245` metni onaylı alıp kartı demoya açtı: madde kapanabilir, "Ne oluyor" metni artık yanlış).
- ACIK 39 "kapasite kolu Faz C'nin silme listesinde" der; `InfraSystem.is_over_capacity()` HEAD'de hâlâ müşteri sesini
  (`b2b_sales_system.gd:625` `risk_voice`) ve Güven & Ölçek uyarısını (`sprint_catalog.gd:702`) okur. İkisi bedel değil ses ve
  uyarıdır; C1 silmedi. Karar yardımcı yönetmenin.
- Destek raporunun göndereni: Karar 11 Müşteri İlişkileri dedi, kodda Destek işi ayrı listedir (PLAN_C_E1 §7-4; ERDEM_KARARLAR :41
  "Erdem'e soruldu"); cevap kayıtlı değil.

### 5.4 D ile sözleşmeler ve D'nin istekleri
Üç sözleşme (`d_taslak/ADIM_TABLOSU_D_v2.md` §4 madde 5; C kabul etti 2026-10-22):
1. **Şema:** ilk inen adım sıradaki numarayı alır (zincir `if version < N`). Bugün 18; D1 önce inerse D 19, C'ninki 20.
2. **Kesinti sırası:** D3b `sprint.json`'da tek veri satırı kurar; C5 o satırı devralır, sırasını değiştirmez, tür eklemez.
3. **B2B hata terimi:** D7 `B2B_BUG_SAT_PER`, `B2B_BUG_SAT_CAP` ve `COMPLAINT_BUG_GATE`'i ölçeklemez (`b2b_constants.gd:72`, `:73`,
   `:70`); C3a bunları siler, hata terimini ve şikâyet eşiğini `SprintCatalog`'daki k ile kurar.

D'nin iki isteği:
- (a) "C bitti" mesajında şema değeri: **18** (C göç yazmadı).
- (b) `SprintBridges.tick_requests` (C6 koşmadı, HEAD hâli, C dokunmadı): `static func tick_requests() -> void`
  (`scripts/systems/sprint_bridges.gd:22`, `SprintSystem.daily_tick`'ten her tik, `sprint_system.gd:33`): sprinti kapanmış ya da hesabı
  gitmiş açık talebi `late` yapar; her B2B hesabına imzadan `request.first_after_weeks` sonra ve her yenilemeden
  `request.before_renewal_weeks` önce açılan pencerede en çok bir açık talep doğurur (hesabın sektör vurgusu 1 alanında kilidi açık,
  başka talepte olmayan sonraki kademe, hash'le; son tarih planlanabilir sprint + `deadline_weeks`; değer MRR × 12); yenileme
  penceresinin açıldığı gün hesabın `market_ref`'ini yeniden kopyalar.

### 5.5 Erdem'de bekleyen kararlar (7)
1. Onay bekleyen sabitler (§2); Karar 16 gereği E2 ölçümünde sorun çıkanlar ona gelir.
2. Yedi commit'in metinleri ve C2c'nin satır içi metinleri: tek metin turu (§3).
3. Destek raporunu Destek işi mi Müşteri İlişkileri mi gönderir (§5.3).
4. Atlas şeridinin rengi: kehribar `D_WARN` mı, yeni bir sarı mı (§5.2).
5. İş hanı'nın üç özdeş kümesinin görünüşü (C9a-3C'nin önce/sonra karesi).
6. Park edilen adımların PRD'si: modül, fiyat, B2B pazarlık ve pazar modeli (§4).
7. Destek raporunun "hat temizlendi" haberi ve haberlerin birleşmesi (hesap yaşamı PRD'si, §5.2).

## 6. Çalışma kuralları (yeni oturum için)

- **Önce adım tablosu ve onay.** Yalnız tam tanımlı iş ajana gider; netleşmeyen park edilir ve listelenir (Erdem 2026-10-22).
- **Commit akışı:** Sonnet kod (xhigh, ağır adımda max) → Haiku kapı ve kare (düşük) → Opus kıdemli inceleme, en çok bir düzeltme
  turu → yalnız inceleme kodu değiştirdiyse Haiku kapıyı yeniden koşar → commit'i ana oturum atar. Mesaj tek paragraf, önek
  "Faz C <id>:", metin varsa "TR/EN onay bekliyor", sabit varsa "sabitler onay bekliyor", sonda attribution satırları. Commit başına
  bir inceleme; ölçüm ya da delta turu yok. Kapı yeşil değilse commit yok.
- **Push** yalnız Erdem "push et" deyince. Tek klasör, `main`; worktree ve dal yok; `git checkout --` ve `git stash` yasak (kirli
  dosyada başkasının işini siler). `project.godot` ve tema farkı commit edilmez.
- **Ortak git index'i:** oturumlar arası "index bende / boş" el sıkışması; biri sahnelerken öbürü commit atmaz. Paylaşılan dosyada
  yalnız kendi hunk'ın sahnelenir (`stage_step.py`), commit ağacı `checkout-index` ile koşturularak doğrulanabilir.
- **Godot'u aynı anda tek oturum koşar:** başlamadan Q ve D'ye "kapı bende", bitince "bitti"; adresler kayar, her seferinde
  `ListAgents`'tan okunur. Koşu öncesi `tasklist` ile Godot sayısı 0 olmalı. Erdem oyundayken ağır iş ve ekranlı koşu yok.
- **Oyuncu metni** TR ve EN birlikte, tiresiz; `strings.csv`'ye yalnız tam eşleşmeli bayt splice. Eski kod, metin, smoke vakası ve
  belge aynı adımda silinir (Genel kural). Onaysız sabit yazılmaz; PLAN'da ya da PRD'de yoksa adım "blocked" döner.
- **ACIK_KARARLAR ve ISLER'e C yazmaz:** sahibi yardımcı yönetmen; öneri commit notunda "ACIK_ISLER önerisi:" diye gider.

**Araçlar** (`c_taslak/araclar/`):
- `faz_c_step.js`: Workflow betiği; args alanları `step`, `effort`, `brief`, `gates`, `shots`, `sources`, `extra_gates`, `scratch`. Bir adım
  için `<adım>_args.json`'un içeriği args olarak verilir. Dönüş `{code, gates, review, regate}`; ana oturum
  `review.files_to_commit` ve `review.commit_message` ile commit'ler. COMMON metni kaynak önceliğini (ERDEM_KARARLAR → PLAN_C_E1 →
  PRD → PLAN_C ve C0v) ve ağaç kurallarını taşır; Pazar 2 adımları için bu liste güncellenmeli. Args'a `scratch` alanı (oturumun scratchpad'i) eklenir.
- `stage_step.py` (git kökünden, `python -I`): `list <yol>` HEAD → çalışma ağacı parçalarını numaralar; `stage <yol> --re R --idx 1,4
  --not-re R` yalnız seçilen parçaları index'e yazar, çalışma ağacına dokunmaz.
- `w1parity.py`: `python -I w1parity.py <project-unicorn> --w1 W1_METINLER.json --override W1_E1.json [--override W2_METINLER.json]
  --ids a,b`: metnin CSV'de ya da `data/` JSON'unda bayt bayt bulunduğunu kanıtlar.
- `wcheck.py`, `w2check.py`: W1 ve W2'nin mekanik kapısı (tire yok, TR ve EN yer tutucusu aynı, `[a-z_]+`); JSON'dan md üretir.
- Args: `c2c_args.json`, `c7b_args.json`, `c9a3c_args.json`, `c9c_args.json` (2026-10-22'nin dört adımının bağlayıcı briefleri; hepsi commit'li).

## 7. Dosya dizini

Kök `project-unicorn/docs/tasks/faz_cde/` (repoya girmez, Erdem'in Karar 23'ü).

**Görev ve kararlar**
- `PRD_FAZ_C_URUN_HESAP.md`: Faz C görevi (2026-10-18), Kararlar 1-14, kabul ölçütleri §4; Erdem'in sonraki kararları onu ezer.
- `ERDEM_QCD_CEVAP.md`: Erdem'in 2026-10-18 cevabı (§1 birebir, §2 onaylı okuma); PRD'nin üstünde.
- `ERDEM_KARARLAR_2026-10-20.md`: bütün kararların tek kaydı (C 1-16, C9 cevapları, Genel kural, 2026-10-22 yön); yardımcı yönetmen yazar.
- `ERDEM_CD_YORUM.md`, `ERDEM_CDQ_CEVAP.md`: Erdem'in 2026-10-17 C ve D yorumları, birebir.
- `RAPOR_Q.md`: Faz Q'nun devri; §7 C ve D'ye sözleşme.
- `d_taslak/ADIM_TABLOSU_D_v2.md`: Faz D'nin tablosu; §2 aynı ağaç kuralları, §4 madde 5 C ile üç sözleşme.
- `AJAN_MESAJLARI.md`, `ACIK_ISLER.md`: 2026-10-18 dalga sırası ve Q, C, D dışı işler.
- Tarihçe (PRD öncesi tur, PRD'nin kaynağı): `C_GOREV.md`, `C_ARASTIRMA.md`, `C_PLAN.md`, `C_INCELEME.md`, `C_ICERIK_v2.md`,
  `C_ICERIK_v3.md`, `KALITE_v2.md`, `X_URUN_EKSENLERI.md`, `MEMNUNIYET_SIM.md`, `OYUN_SISTEMLERI.md`, `OYNANIS_HUKMU.md`, `ORTAK.md`,
  `QCD_GOREV_PAKETI.md`; web araştırmaları `arastirma/R1`…`R15`.

**Planlar (`c_taslak/`)**
- `PLAN_C.md`: ilk onaylı adım tablosu (2026-10-18) ve commit akışı; aslı `C:/Users/erdem/.claude/plans/sen-project-unicorn-da-faz-vivid-karp.md`.
- `PLAN_C_E1.md`: E1 kararlarının işlendiği plan; §8 Erdem'in dört cevabı, §9 E2 listesi; yürüyen adımların dayanağı.
- `PLAN_C_P2.md`: Pazar 2 tablosu (20 adım), PARK; §8 sessiz yerler, §10 C0p ve W2 notları.

**Haritalar ve ölçümler (`c_taslak/`)**
- `C0_HARITA.md`: bağlantı haritası (`fc6b392`, C0q ile `910ad1f`'a tazelendi).
- `C0v_ADIM_EKLERI.md`: C1-C9 adım ekleri, E1 soruları 1-31.
- `C0q_TAZELEME.md`: Q'dan sonra tazeleme (`910ad1f`).
- `C0p_HARITA.md`: PLAN_C_P2 adımlarının HEAD `cf452525` dosya:satırı, §S sapmalar.
- `C0S_SONUC.md`: C0s simülasyon ve ekonomi tahmini; betikler `msim/` (`python -I c0s_run_all.py`), çıktılar `msim/out/`
  (`c0s_econ_e1.md` C2'nin para ölçümü).
- `C0r_OLCEKLEME.md`: otomatik ölçekleme araştırması (eşik %80, adım orantılı, küçültme yok).
- `C0m/C0M_KARELER.md`, `C0m/png/` (20 kare), `c0m_shots.gd`, `c0m_screens.gd`: oyunun arayüzüyle maketler.
- `arastirma/OFIS_BUFF.md`, `arastirma/RUNWAY_GOSTERIM.md`: C9b ve C2'nin araştırmaları.
- `E1/e1_sablon.html`: E1 sayfası şablonu (Faz D'nin E1 durağından); C'nin E1 sayfası yazılmadı.

**Metinler (`c_taslak/`)**
- `W1_METINLER.json/.md`: 242 metin (C1-C9), `wcheck.py` ile.
- `W1_E1.json`: E1 kararlarının 24 öğesi; aynı id W1'i ezer, `drop` bağlanmaz.
- `W2_METINLER.json/.md`: Pazar 2 metinleri, 232 metin ve 97 W1 düşüşü, ÖNERİ.

**Araçlar:** `c_taslak/araclar/` (§6).

**Pazar 2 (`pazar2/`)**
- `out/SENTEZ_ERP_PAZARI.md`: ERP pazarı modeli; §14.2 C'ye etkisi, §15 kararlar, §16 küçük kararlar.
- `out/SORU_PAKETI_3.md`: tek açık soru (YZ dalgası). `out/K_kod_haritasi.md`, `out/tur2/K2_kod_fiyat_icerik.md`: kod haritaları.
- `sim/` (`eras.json`, `constants.json` vb.): C10, C11a, C11b'nin veri kaynağı olarak önerilen dosyalar.

**Hafıza:** `C:/Users/erdem/.claude/projects/C--Users-erdem-Desktop-Project-Unicorn/memory/faz-c-execution-2026-10-18.md`.
