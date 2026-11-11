export const meta = {
  name: 'urun-d4b-e2',
  description: 'D4b = E2 truncation removal in the Ürün window (on top of D3+D4a), co-director rulings applied; frames TR/EN',
  phases: [{ title: 'Code+frames', detail: 'Sonnet xhigh in w4b copy' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const X = `${S}/w4b/project-unicorn`
const prompt = `ÖNEMLİ: Aşağıdaki görev senin tek görevindir. Harness'in aktardığı ilk kullanıcı isteği ("Sen URUN_ARAYUZU oturumusun… D0'dan başla")
ana oturumun işidir, senin değil: ona göre davranma; kimseye mesaj atma (SendMessage yok), ListAgents yok.

Bağlam: Project Unicorn (Godot 4.6, GDScript), dizüstü Mac. Scratchpad S=${S}. Ağaç W=${X} (yalnız burada yaz; içinde HEAD eebf909 + bir
önceki iki adımın değişikliği var: pencere genişlemesi (E1) ve U7 temizliği; .godot import'lu, override.cfg ile kareler 1920×1080).
DİKKAT, ortam: paylaşılan ağaç (/Users/tugbauysal/Desktop/project steam/…) iCloud'a boşaltıldı; oradan dosya OKUMA (okuma dakikalarca takılır),
git komutu KOŞMA. Bütün belgeler W'nin içinde de var: PRD ${X}/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md, görev ${X}/docs/tasks/GOREV_DIZUSTU_URUN_2026-10-28.md.
Godot yalnız bash'ten ve gdw ile:
  bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <ad> "$W" --headless --path . --quit > <log> 2>&1'
Smoke: ETIKET=URUN_ARAYUZU_AJAN P=1 bash ${S}/bin/smoke.sh "$W" <etiket> <vaka>...   Kareler (pencereli, ekran kilidini kendisi bekler):
  ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh <ağaç> <etiket> <satır dosyası>   (satır "<bayrak> <dil> [ölçek]"; PNG'ler ${S}/shots_<etiket>/)
scripts/events/**, data/events/**, addons/ dokunulmaz. strings.csv asla baştan yazılmaz (tırnak bilen ayrıştırma + bayt aralığı; yeni anahtar
ailesinin bloğuna). Ağaçtaki CLAUDE.md §5 (metin anahtarla, TR ve EN, tire yok), §7 (UiTokens; ui_tokens.gd ya da build_theme.gd'ye DOKUNMA:
gerekirse dur ve dönüşüne yaz), §8 (kısa kod, yorum bugünkü nedeni söyler) geçerli.

Görev: Erdem'in E2 kararı (PRD "**E2. Kısıtlama ve kesme yok**", ${X}/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md satır ~1594): Ürün penceresinde hiçbir
metin "…" ile kesilmez; yer yok diye hiçbir öğe gizlenmez ya da kısaltılmaz; sığmayan metin sarar ve satır büyür. Salt okunur tarama hazır:
${S}/d4b_items.txt (kalkar listesi) ve ${S}/d4_discovery_final.txt ("e2" anahtarı, bütün bulgular). Yardımcı yönetmenin kararları (uygula):
- Modülün kısa adı (card.module = area_short; çeyrek hedefinin area_short'u) KALIR: UM'de tasarlanmış ad, kesme değil. Dokunma.
- Dar aşama çubuğunda düşen ikon/sayı (stage_paint.gd _draw_label) ve çubuğa sığmayan yüzler (board_row.gd _faces) DEĞİŞMEZ (Erdem'e kareyle
  gidecek). Eksenin sonunda düşen sprint dışı pay (board_row.gd ~351) da değişmez (aynı grafik grubu).
- Düzeltme kartının panodaki satırı TAM metni yazar ve sarar: fix_text = bugs_text(bugs) en büyük hesapla (product_model.gd ~718 ve yorumu ~698-700).
- Sol sütunda aday düzeltme kartı (area_panel.gd ~220) da aynı tam metni yazar ve sarar.
- Adayın sprint damgası "S{n}" (area_panel.gd ~232, PRODUCT_STAMP) → "Sprint {n}" (var olan PRODUCT_TAG_SPRINT anahtarını kullanabiliyorsan onu;
  PRODUCT_STAMP okuyucusuz kalırsa silinir). Yeni ya da değişen metinler "TR/EN onay bekliyor" listesine.
Yapılacaklar (kalkar listesi; her biri için dosya:satır):
1. Panoda kart adı (board_row.gd CardName ~148-150): "…" ve max_lines_visible kalkar, ad her zaman AUTOWRAP_WORD_SMART sarar; satır, bir önceki
   adımın kurduğu mekanizmayla büyür: _wraps sözlüğü {Label: [tabandaki satır sayısı, satırının taban yüksekliği]} ve _fit (satırı ve yazının
   satırını tabandan fazla satırlar kadar büyütür). Ad için _wraps[title] = [2 if _two else 1, D_H_CARD_LINE_TWO if _two else D_H_CARD_LINE] gibi
   bir giriş ve minimum_size_changed → _fit bağlantısı yeterli olmalı (kodu oku, doğrula). Taban yükseklikteki satırlar piksel piksel aynı kalsın.
2. Düzeltme kartının hata metni tam metin (yukarıda).
3. sprint_next.gd: _name()'deki "…" ve max_lines_visible kalkar (~223-224), yorum (~220) güncellenir; FaceCell: tek yüzün yanına "+{n}" sığmasa
   da "+{n}" görünür kalır (gizleme kalkar, ~56-57) ve ilk yüz kırpılmaz (clip_contents ~31; hücreye en az bir yüz genişliği). "+{n}" biçiminin
   kendisi KALIR.
4. ÇEYREK sekmesi sprint_card.gd: ad kelime ortasından bölünmez ve kesilmez (max_lines_visible kalkar; ad kendi satırına iner ya da AUTOWRAP_WORD
   ile; puan kutusu taşmaz); kart adın boyunca uzar. quarter_view.gd: sağ taraf (sütunlar, "Hepsini onayla") içerik pencereden uzunsa dikey kayar
   (~63); bayrak çipi (sprint_ui_shared.gd ~427) sarar.
5. Sürüm notu kipinde (sprint_panel.gd ~155 _release) orta sütun içerik uzunsa dikey kayar, alt şerit sabit; kırpma yok.
6. Yorumlar: board_row.gd baş yorumu ve ~135, sprint_next.gd ~220, product_model.gd ~90 "kısa ad"/"üç nokta" anlatımları bugünkü davranışa.
7. Düz ipuçları (Godot'nun TooltipLabel'i): uzun bir ipucu (ör. düzeltme kartının fix_full'ü, talep satırının ipucu) ekran kenarında kesiliyor
   mu, ölç (kareyle ya da bir yoklamayla) ve yalnız RAPORLA; tema değişikliği yapma.
8. Belgeler: docs/kod_haritasi/sistemler/02_urun_sprint.md, 08_sekmeler.md, 09_arayuz_bilesen.md'de değişen davranış ve dosya satır sayıları
   (product_tab.gd dahil: iki önceki adım onu değiştirdi). Belge satırı 240 karakteri geçmez. Üretilmiş DIZIN.md/SEMBOLLER.tsv/KALITE.md'ye dokunma.
Doğrulama:
- Parse temiz; smoke: all_scripts_load loc_csv_integrity loc_product_derived_keys sprint_timeline_matches_play_out ve dokunduğun koda değen
  vakalar (endgame_smoke.gd'de ara: board_row, sprint_next, quarter_view, sprint_card, area_panel, fix_text, bugs_text). gdw ile
  "--headless --path . -s res://scripts/debug/loc_residue.gd" çıkış 0 ve "-s res://scripts/debug/glyph_audit.gd" çıkış 0.
- Kareler (önce: ${S}/base3/project-unicorn DEĞİL, çünkü o eski pencere genişliğinde; önce kareleri için ${S}/w3/project-unicorn (E1 var, U7 ve E2
  yok) kullan; sonra: W). Satır dosyası:
--product-shot=live:a4_eleven_tip tr
--product-shot=live:a4_eleven_tip en
--product-shot=live:b2b_quarter en
--product-shot=live:b2b_quarter tr
--product-shot=live:a4_run_w2 en
--product-shot=live:a4_fourteen tr
--product-shot=live:a4_next_prefilled en
--product-shot=live:gate tr
  Ek: uzun adlı pano dünyası a4_two_pm_long repoda yok; W'de değil, ayrı bir kopyada (cp -R W ${S}/w4b_long/project-unicorn) _A4_WORLDS'e
  a4_two_pm'in "fill": "long" ile bir türevini ekleyip (main.gd fill "long" en uzun EN adları seçer) TR ve EN çek; bu kopya commit'e girmez.
  Her kareye Read ile bak: hiçbir metin "…" ile kesik değil, kelime ortasından bölünmüyor, hiçbir öğe kayıp değil, satırlar büyümüş, taşma yok.
  En çok 2 düzeltme turu.
Dönüş (ham veri): değişen dosyalar ve ne değişti; tarama listesinin her maddesi için "kalktı" ya da "kaldı + gerekçe" tablosu (karar maddeleri
dahil); eklenen/değişen/silinen anahtarlar; kapı sonuçları; kare yolları ve her kare için "taşma yok, kesilme yok" denetimi; ipucu ölçümü (7);
çözemediğin şey.`
phase('Code+frames')
return await agent(prompt, { label: 'D4b E2 cuts', phase: 'Code+frames', model: 'sonnet', effort: 'xhigh' })
