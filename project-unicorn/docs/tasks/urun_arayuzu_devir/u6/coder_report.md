# U6 kodlayıcı raporu (Sonnet xhigh, kopya w8, taban b_u6 = 287f6f5)

## 1. Dosyalar
Eklendi: scripts/tabs/product/card_tip.gd (+.uid; CardTip, zengin kart ipucu paneli).
Değişti: scripts/tabs/product/ board_row, capacity_view, sprint_next, sprint_foot, sprint_board, stage_paint (tip_panel + _make_custom_tooltip),
sprint_ui_shared, product_model, area_panel; scripts/systems/sprint_catalog.gd, scripts/theme/ui_tokens.gd, scripts/main/main.gd,
scripts/debug/product_fixtures.gd; localization/strings.csv (+36 satır, bayt kesme); docs/kod_haritasi/sistemler/02, 08, 09.
Silinen: SprintCatalog.due_sprint → due() ({sprint, customer, value, promise}), tek çağıran ProductModel._row; AreaPanel.STAGE_KEYS ve
CapacityView.STAGE_KEYS → SprintUiShared.STAGE_KEYS; BoardRow._icon → SprintUiShared.stage_icon; D_W_CAP_TIP → D_W_TIP (288).
project.godot tabana geri konuldu. Geçici kanca/döküm sınıfı silindi. ≈426 satır (scripts).

## 2. §11.2 envanteri
Bağlıydı: T1–T5, C1, C3, C4, C5, C6, C7, C8 metni, KT11, F1, F2, L1–L5.
Düzeltildi: C2 rozet düz ipucu yalnız "Sığıyor" ya da "{n} efor sonraki sprinte kalır" (önce C1'in tam metni); C5 kalabalık satırda tek kurucu yüzü PERSON_TIP.
Bağlandı: KT1 (zengin panel), KT2–KT7, KT9, KT10; B1–B7; dört karar (kapısı kapanan kart = gate_reason + yeni anahtar, tek tik kutusu satır satır,
düzeltme kartı tam hata metni (en büyük hesapla), B6 bayrak/yazı/taralı alan); F3 (set_progress ile), R1–R7.
Yapılamadı: C8 PRODUCT_SUGGEST_NONE (aday yokken satır çizilmiyor, U1 cevap 7); B1 PRODUCT_TIP_REQ (P8, D2a verisi yok).

## 3. Kapılar
event-lint PASS 0/0 (10 baselined); loc_residue CLEAN csv_keys=3274; smoke 75/75 (u6/smoke_list.txt); tema bayt eş (stamp artmadı),
theme_check PASS, contrast 601 çift fails=0, glyph missing=0; PLANMS ilk kare 77,6/79,4 ms (taban aynı koşuda 79,4/78,5; göreli);
Z6 taban dosyalarıyla 7/7 bayt eş (z6_hd eski: lines_3/lines_6 farkı f7a878c'den, motor değişmedi);
live:a4_* başsız döküm TR 24 + EN 24: row_gaps=0, sağ 300, orta 754, TRIMMED/TRUNCATED/OUTSIDE 0; panel dış 312 px (içerik 288), boy ~290–480;
fikstür+canlı süpürme 104 koşu script_err=0.

## 4. A8: 205 anahtar TR/EN, yasak ifade 0, kart ipucunda ". hafta"/"week " 0 (kart dışı: EARLY_END_TIP, STARTS_AHEAD, WEEK_ORD). CLEAN.
CSV'de olmayan PRD jetonları: PRODUCT_SUGGEST_NONE, PRODUCT_TIP_REQ.

## 5. Silinenlerin okuyucusu 0. Kalan ve okunan: PRODUCT_AREA_OVER_CAPACITY, _AREA_RIVAL (area_sentence), PRODUCT_AREA_REVENUE_* (dinamik),
PRODUCT_BUGS_TIP_PREV/_TOP (bug_row_of), PRODUCT_PERSON_ROLE (avatar), PRODUCT_THIS_SPRINT (quarter_view). area_sentence Genel Bakış için hazır, bağlı değil (U7).

## 6. Yeni anahtarlar (36): §11.1'den 34: PRODUCT_EFFORT_TIP, _EARLY_END_TIP, _RISK_TIP, _RISK_LOW, _RISK_MEDIUM, _RISK_HIGH, _RISK_PREPARED,
_PREPARED_BY, _PM_PREPARED, _ASK_TIP, _CARRIED_TIP, _LATE_TIP, _ON_TIME, _STAGE_READY, _STAGE_RAW, _STAGE_SHADOW, _STAGE_NOW, _AHEAD_DONE,
_WAIT_FOR, _WAIT_DESIGN, _WAIT_DEV, _WAIT_TEST, _MEETING_SALES, _MEETING_VC, _MEETING_TABLE, _DAYS, _DAYS_ONE, _NO_PM_TIP, _FOUNDER_CARD,
_PROGRESS_TIP, _NEXT_LOAD_TIP, _PREPARING_TIP, _STARTS_AHEAD, _DONE_AHEAD. Kodlayıcının: PRODUCT_GATE_MOVES, PRODUCT_STAGE_DONE_NOW.

## 7. PRD sessiz/çelişkili (yönetmene 1–7 soru, 8–11 bilgi olarak gitti)
1 B1/KT1 aynı hedef (çubukta zengin panel + üstte B1 satırı soluk). 2 C8 SUGGEST_NONE yazılmadı. 3 R5 STARTS_AHEAD "{w}. hafta" vs KR24.
4 görüşme kalemi hafta başına, iki haftada iki satır. 5 KT10 sistem kâğıdında ask.person null → _ask'a name (gönderici). 6 künyede PM varken
hazırlamadıysa da "PM yok". 7 düzeltme işinin 4. girdisi panelde yok. 8 "Kurucu 0★". 9 erken kapanış taralı alanı yalnız satır altı boşlukta.
10 STAGE_READY R6'da sonraki kart için. 11 D_W_CAP_TIP stamp artırmadı. 12 UK yamaları oturmuyor.
N1: düzeltme kartının "en büyüğü {hesap} ({n} kullanıcı)" parçası fix_full ipucunda; "SPRINT ERKEN BİTER" açıklaması ipucunda. Ekrana yeni metin yok.
N4: EN uzun adlar 288 px'te satır kırar, 48 dökümde taşma yok.

## 8. Kareler: main.gd _A4_WORLDS alanı "tip" + _product_tip_shot → <kök> ve <kök>_tip (imleç, 1,2 sn).
live:a4_eleven_tip TR/EN (tip "card": söz çipli ilk satırın adı); live:a4_eleven_streak (tip "cap": üç sprinttir taşan Test etiketi, TipBox).
Hover'la sınanabilir: a4_run_w2, a4_six_meetings2, a4_run_end.
