# UE prototipi raporu (Sonnet xhigh, kopya wue = U6'nın w8'i; commit yok)

UE ortam değişkeni tek yerde: `SprintUiShared` (`_ue`, `ue(flag)`, `ue_arg`, `left_w()`, `timeline_w()`, `ue_status()`, `slot_chip()`, `AREA_ICONS`).
Değişenler: sprint_ui_shared, ui_tokens (D_W_LEFT_UE), product_tab, quarter_view, board_row, sprint_board, area_panel, product_model (`chip`),
main.gd (dünyalar a4_two_pm_long, a4_fifty_long, a4_status, a4_status_long), strings.csv (3 anahtar).

## 1 narrow
Hafta px = D_W_TIMELINE / D_TIMELINE_WEEKS = 396 / 2,6; prototipte eksen = 396 + (288 − sol).
Önerilen sol 280 (`narrow=<px>` ile değişir). Sınırı TR talep satırı koyar: "Sultanahmet Gayrimenkul" (TipTitle 14) + "gelecek çeyrek" çipi; 268 altında
sözcük ortadan kırılır; a/b çipi 10 px büyüttüğü için sınır 276; 280 = 276 + 4 pay. TR "Entegrasyonlar düzeltmesi" 264'te üç satır; EN 252'de bozulur.
Önce/sonra (a4_two_pm, a4_fifty, TR=EN): sol 288 → 280, orta 754 → 762, sağ 300, eksen 396 → 404, hafta 152,31 → 155,38 px (+3,1).
272'de 158,46; 252'de 166,15 (ad kırılır). Tavan ~264 (+9 px/hafta). Asıl genişlik: bilgi sütunu 312, sağ sütun 300, gövde dolgusu 24+24, boşluk 16+16.

## 2 icons (modül → ikon)
core Çekirdek ÇK → rail/product.svg (küp) · onboarding İlk Kullanım ve Erişim İK → world/training.svg (şapka; "erişim"in ikonu yok)
growth Büyüme BÜ → stake/cash_in.svg (yukarı ok; YAKLAŞIK) · integrations Entegrasyonlar EN → dept/development.svg (komut satırı; YAKLAŞIK)
trust Güven & Ölçek GÜ → util/shield.svg (kalkan) · revenue Gelir GE → skill/sales.svg (etiket). Tekrar yok, set dışı yok.
Aday kâğıdı `ue/out/ue_icon_sheet.png`. 24 px kutuda 16 px ikon, ipucu modül adı. Panoda modül adı kelime, ikon yok.

## 3 a / b
(a) "Planda" ve son tarih çipleri satır adı stilinde (TipTitle 14), cümle başı büyük: PRODUCT_IN_PLAN_UE (Planda/Planned), PRODUCT_DUE_THIS_Q_UE
(Bu çeyrek/This quarter), PRODUCT_DUE_NEXT_Q_UE (Gelecek çeyrek/Next quarter). (b) "planda" kalkar, yeşil tik (ipucu PRODUCT_IN_PLAN_TIP),
son tarih çipi ad boyunda ve büyük harfli; tik sağda şevronun önünde. a/b çipleri panodaki durum yuvasına da uygulanır.
Dünya a4_status (4 talep; ikisi planda; iki modül planda).

## Kapılar
UE boş smoke 6/6; başsız 30 koşu SCRIPT ERROR 0, row_gaps 0; döküm sağ 300, sol/sağ sütunda kesilme 0.
İstisna: long dünyalarda orta sütunda 2 pano satırı "…" ile kesiliyor ("Hesap & Oturum (Sultanahmet Prodüksiyon)", 3 satır, en çok 2) — UE boşken de
aynı (N4 ihlali, U7/U8'e not).
