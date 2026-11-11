<!-- 10-28T16:55 -->
- COMMIT eebf909 (19:55): birleşik ağaç HEAD 87e06d68 + D2; import/ısınma temiz; smoke 56/56 (54 sprint_/product_ + loc_csv_integrity + all_scripts_load); doğrulama 1 (7 yol) ve 2 tam.
- Z6: h1 (HEAD 87e06d68) = h0 (f06bed6) 7/7; birleşik ağaç (g_d2) = h1 7/7.
- Ortak kapılar work'te: lint PASS (0 hata, 10 taban), loc_residue 0, loc_csv_integrity ve all_scripts_load PASS.
<!-- 10-28T17:18 -->

## D5 (UM1, w5 kopyası)
- CSV: yalnız PROD_LINE_HIDDEN_SELF_SERVE ve PROD_RND_NODE_TEST_AUTOMATION_UNLOCK (3277 anahtar korunur, BOM/CR yok).
- Adı yer tutucuyla alan 26 anahtar ({capability}/{line}/{line_name}) yeni adla TR/EN okundu, ek uyumu bozulmadı (liste yukarıda; BUILD_SUPPORT_TIP, RND_NOTE_DEMAND_B2B_0..3, RND_NOTE_DEMAND_B2C_0..3, RND_HIDDEN_LINE_OPENED, NEG_DEAL_IF_ACCEPT, PRODUCT_FIX_CARD, PRODUCT_NEWS_RIVAL_LAUNCH_0/1, PRODUCT_PRESS_CORE_0/1, SUPPORT_RPT_NEW_PRIORITY/CLEARED/WORST, SUPPORT_RPT_SHIPPED, SUPPORT_RPT_BTN_FIX, EFFECT_SHIP_BUGS(_ONE), EFFECT_NEW_BUGS(_ONE), EFFECT_LINE_HARDEN). Adı okuyan kod: ProductLines.line_name_key (product_lines.gd:290), mail_pane.gd:741.
- Kapılar: glyph_audit 0 (missing=0), loc_residue 0, loc_csv_integrity + all_scripts_load 2/2.
- --rnd-shot=discovery TR/EN maili açmıyor (yalnız ofis ve bildirim yığını); cümle MCP'de keşif mailini açarak doğrulandı (evidence/d5_mcp/). Mail cümle hattın adını içerdiği için ayrı "yeni hat" satırı eklemiyor (önceki davranışla aynı); altında "Açtığı devam yuvası adlandı: Yardım Merkezi" (düğümün adı).
- EN MCP karesinde portre boş (Mac'te PersonBust; OLAYLAR inceliyor).
- MCP: 7777'yi açılış anında başka başsız Godot kapınca oyun sunucusuz açılıyor; mcp_start.sh yeniden deniyor.
<!-- 10-28T17:28 -->
- İkon adayları (OLAYLAR, b2639465): docs/tasks/dizustu/raporlar/ikon_adaylari/svg/<modül>_<küme>.svg (D6 için).
<!-- 10-28T17:36 -->

## D3 (UE1, w3 kopyası)
- SPECS["product"] 1424×928 → 1688×928 (1920 − ray 184 − 2×EDGE 24; kareden doğrulandı: pencere x 208–1896, sağda 24).
- Eksen orta sütunun kalanı (en az D_W_TIMELINE 396): 1920'de pano gövdesi 730→994, eksen 396→674, hafta 152,31→259,23 px; 1,25'te pencere 1424, eksen 410, hafta 157,69.
- Düşen çubuk (ikon ve sayı ikisi de yok), 1920: a4_two_pm 3→2 (30 çubuk), a4_eleven 6→4 (38), a4_run_w2 4→1 (8). Yalnız ikon düşen: two_pm 12→3, eleven 10→6. 1,25'te eleven 6→4, two_pm 3.
- Kapasite olukları orta sütunla uzar (Geliştirme ~1050→~1305 px), eksene bağlı değiller.
- İnceleme (Opus): 7 bulgu; 6 uygulandı (static _axis: ilk açılıştan sonra tek kurulum; window_layer yorumunda satır sayısı korundu, SPECS 38'de; yorum sadeleştirme; 08 Dikkat maddesi; satır sayısı), 1 reddedildi (ui_tokens.gd D_W_TIMELINE yorumu: ORTAK §3 dosyadaki her değişikliğe THEME_STAMP artışı ve tema üretimi bağlıyor; anlam 09 sayfasında ve pano başlığında).
- Açılışta iki kurulum aynı karede (CallQueue aynı flush'ta), oyuncu dar ekseni görmüyor (inceleme).
<!-- 10-28T18:20 -->

## iCloud olayı (2026-10-28 20:28–)
- Disk %93 doluyken macOS (iCloud Masaüstü, depolamayı optimize et) .git paketini (486 MB), .rev'i, 253 .git nesnesini ve ağacın 3.307 dosyasını
  boşalttı ("dataless"). D5 commit'inin özel index read-tree'si 20:31–21:17 read()'de bekledi; co-director: git yazımı durduruldu, kapı bırakıldı.
- env.sh paylaşılan mac_env.sh yerine scratchpad'deki yerel kopyayı (bin/mac_env_local.sh, 219a534 hâli) okuyor.
- co-director tüm dataless dosyalar için brctl download başlattı; pack 21:15'te indi. Scratchpad 8,5 → 2,5 GB temizlendi.

## D7 hazırlık
- Maket kareleri: u8/maket/f01..f24.png (A4.html, başsız Chrome CDP, u8_tools/maket_shots.mjs).
- bin/shots2.sh: ek bayraklı kare listesi (renk körü vb.).
<!-- 10-28T19:07 -->
- D3 MCP (21:5x): WindowLayer._area() = (208,24) 1688×928; Ürün penceresinin get_rect() aynı; kare evidence/d3_mcp/a4_eleven_tr_live.png. taşma yok, kesilme yok.
<!-- 10-28T19:16 -->

## D4a (U7 temizlik, w4)
- Ajan: product_fixtures.gd(.uid) silindi; set_source, PRODUCT_FIXTURES, _product_source, debug_product_apply/act; area_row, WORD_TONES, serves;
  area_sentence, _standing, _recent_hit; 18 CSV anahtarı (PRODUCT_AREA_RIVAL, _OVER_CAPACITY, _REVENUE_{NONE,WEAK,ENOUGH,STRONG}, PRODUCT_AUDIENCE_*,
  PRODUCT_STAR_*, PRODUCT_RESEARCH_VOICE_*); sprint.json research_sentence_weeks. Her ad için grep 0 (komut: grep -rIE "<ad>" scripts scenes tools data
  localization docs/kod_haritasi/sistemler docs/kod_haritasi/README.md docs/ACIK_ISLER docs/design CLAUDE.md project.godot). card_effect kaldı.
- Kırılanlar: game_shell._on_sprint_closed → has_method(&"open_area"); main.gd clock-shot released kolundaki set_source(null) silindi.
- Kapsam kaybı (live: karşılığı yok): release_fix, release_reviews, no_release, history_empty, cap_zero, approved, goal_menu → ISLER.md.
  Karşılıklar: history→b2c_live, over_100→a4_six_pm5/pm2, over_125→a4_eleven/a4_twelve_dev, empty_start→a4_empty, quarter_no_pm→a4_solo/devs3/requests,
  team_none→a4_cards_noteam, c1..c5→plan/active/b2c_mvp/b2b_quarter/overview_pre, flow→plan/b2c_mvp/b2b_mvp/b2c_goal, gate→live:gate.
- Smoke 23/23; loc_residue 0.
- İnceleme (Opus): 10 bulgu; 7 uygulandı (tek düzeltme turu), 3 reddedildi: ACIK_KARARLAR (37) (açık maddeye dokunulmaz), localization_glossary:85
  (bağlayıcı sözlük; silinen PRODUCT_STAR_* örneği, sahibine not), üretilmiş kod haritası (commit anında üretilir).
<!-- 10-28T19:34 -->

## D4b (E2 kesmeleri, w4b; taban w4b_base = D3 + D4a'nın ilk hâli)
- Kalkan: pano kart adı "…"/max_lines (sarar, _wraps/_fit ile büyür); düzeltme kartı tam metin (en büyük hesap dahil; fix_full ve bugs_text with_top silindi);
  sonraki kutuda ad kesmesi, FaceCell "+{n}" gizlemesi ve clip_contents; ÇEYREK mini kart (ad kendi satırında, max_lines yok); ÇEYREK sağ tarafı ve sürüm
  notu orta sütunu dikey kayar; bayrak çipi sarar; aday düzeltme kartı tam metin; "S{n}" → "Sprint {n}" (PRODUCT_TAG_SPRINT; PRODUCT_STAMP silindi).
- Kalan (karar): modül kısa adı; dar çubukta ikon/sayı/yüz düşmesi; eksen sonundaki sprint dışı pay; "+{n}" biçimleri; grafik kırpmaları.
- Düz ipucu (TooltipLabel) sarmıyor, ekranda içeri itiliyor; gerçek en uzun EN çubuk ipucu 778 px (popup 826); ~1900 px (~300 karakter) üstünde kesilir.
- Kareler shots_e2_before (w3), shots_e2_after (w4b), shots_e2_long (w4b_long: a4_two_pm_long, a4_release_long, a4_cand, ipuçları), shots_e2_q125.
- ÇEYREK mini kart biçimi değişti (glif+puan üstte, ad altta, +8..24 px): D7'de kare.
- TR/EN onay bekliyor (yeni metin değil, ekranda yeni yerde): aday damgası "Sprint {n}"; pano düzeltme satırında PRODUCT_FX_TOP; aday düzeltme kartında tam metin.
- İnceleme (Opus): 8 bulgu; 6 uygulanıyor (FaceCell boş hücre, ÇEYREK sol kaydırma, 2 yorum, 08 atıfları); reddedilen 2: _two'nun kaldırılması (üç token +
  tema damgası; >22 karakterli tek satırlık adların satırı kısalır, E2 dışı görünür değişiklik), üretilmiş kod haritası (commit anında).
<!-- 10-28T19:37 -->
- D4b MCP (a4_run_end EN canlı): düzeltme satırı tam metin sarar, sonraki kutuda uzun ad 2 satır, yüz şeritle hizalı. Çok yüzlü '+{n}' karede yok; başsız yoklama 5 kişide 1 yüz + '+4'. taşma yok, kesilme yok.
<!-- 10-28T19:58 -->

## D7 (U8 sayfası)
- https://claude.ai/artifact/Wqm2PqBZQXcuGjJzyotNvz (sürüm 1). Kaynak u8_page/index.html (+98 JPEG, img/), üretici u8_tools/build_page.py.
- 56 kare (shots_u8, wfinal = D3+D4a(düz.)+D4b+D5 birleşimi), 25 kırpma (u8/crops), maket f01..f24 (u8/maket).
- Denetim: 54 kare "taşma yok, kesilme yok"; x_paper (Olaylar penceresi) boş portre + mail önizlemesi "…" (Ürün dışı); ipucu karelerinde "→ ×" risk/eforu örter (U4 kararı).
- Kapı: node --check satır içi JS OK; başsız Chrome 375/414/1280 px yatay taşma yok; JS hatası yok.
- Dar çubuk 1920 (E1 sonrası): a4_eleven 4, a4_two_pm 2 (E1 öncesi 6 ve 3); (b) prototipi wproto_b (stage_paint + bar.clip_contents=false).
