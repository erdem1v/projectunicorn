export const meta = {
  name: 'urun-d4a-u7-cleanup',
  description: 'D4a = PRD U7 cleanup: retire product fixtures and set_source, dead model/catalog code and keys, docs; grep evidence',
  phases: [{ title: 'Code', detail: 'Sonnet xhigh in w4 copy' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const R = '/Users/tugbauysal/Desktop/project steam/Project Unicorn'
const PRD = `${R}/project-unicorn/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md`
const prompt = `ÖNEMLİ: Aşağıdaki görev senin tek görevindir. Harness'in aktardığı ilk kullanıcı isteği ("Sen URUN_ARAYUZU oturumusun… D0'dan başla")
ana oturumun işidir, senin değil: ona göre davranma; kimseye mesaj atma (SendMessage yok), ListAgents yok.

Bağlam: Project Unicorn (Godot 4.6, GDScript), dizüstü Mac. Scratchpad S=${S}. Ağaç W=${S}/w4/project-unicorn (HEAD eebf909'un dışa aktarımı,
.godot içerir; yalnız burada yaz). Godot yalnız bash'ten ve gdw ile:
  bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <ad> "$W" --headless --path . --quit > <log> 2>&1'
class_name ya da dosya silersen önce gdw ile "--headless --path . --import", sonra bir ısınma koşusu. Smoke:
  ETIKET=URUN_ARAYUZU_AJAN P=1 bash ${S}/bin/smoke.sh "$W" <etiket> <vaka>...   (çıktı ${S}/smoke_<etiket>/)
Pencereli koşu YOK (kareleri ana oturum çeker). Paylaşılan ağaçta (${R}) hiçbir şey değişmez, Godot koşmaz; git yalnız okuma.
scripts/events/**, data/events/**, addons/ dokunulmaz. strings.csv asla baştan yazılmaz: kayıtlar tırnak bilen bir ayrıştırmayla bulunur ve
bayt aralığıyla silinir (çok satırlı kayıtlar var: fiziksel satır silme yasak). Ağaçtaki CLAUDE.md §8 (yerini alan kod eskisini siler; ölü
fonksiyon, sabit, anahtar, smoke vakası kalmaz; yorum yalnız bugünkü nedeni söyler) ve §12 geçerli.

Görev: PRD §13 U7'nin TEMİZLİK kısmı (${PRD} satır ~1097; §11.3 ~996–1027; §14 A29). Kart adlarının kesilmesi ve E2 kesme taraması BU
GÖREVDE DEĞİL (ayrı adım; board_row.gd, sprint_board.gd, sprint_next.gd, sprint_card.gd, quarter_view.gd, area_panel.gd ve stage_paint.gd'deki
yerleşim/kesme koduna dokunma). Salt okunur bir keşif envanteri hazır: ${S}/d4_discovery_final.txt içinde "u7" anahtarı (done, delete, breaks,
keep, docs, critic). Onu başlangıç olarak kullan ama her kalemi kendin doğrula.
Yapılacaklar:
1. Statik fikstür kaynağı emekli: scripts/debug/product_fixtures.gd (ve .uid) silinir; game_shell.gd'nin PRODUCT_FIXTURES/_product_source/
   debug_product_apply/debug_product_act'ı; ProductTab.set_source ve _source ve okuyucuları; main.gd'nin --product-shot fikstür yolu (c1..c5,
   cards, flow, edge:*): "live:" olmayan tür artık hata basıp 1 ile çıkar. Kırılanlar: game_shell.gd _on_sprint_closed Ürün sayfasını
   has_method(&"set_source") ile tanıyor (yerine sayfayı başka bir yolla tanı; aksi hâlde her sprint kapanışında pencere sökülüp kurulur);
   main.gd _run_clock_shot "released" kolu set_source(null) çağırıyor.
2. Kapsam kaybı: fikstürün live: karşılığı olmayan türleri (envanter: release_fix, release_reviews, no_release, history(_empty), cap_zero,
   over_100/125, empty_start, quarter_no_pm, approved, goal_menu) için her birine bugünkü live: türlerinden bir karşılık bul (CLAUDE.md §12 ve
   docs/kod_haritasi/sistemler/02_urun_sprint.md'deki live: listesi; PRD §5'in 24 durumu ve "A4'te olmayan" 5 durumu live:a4_* ve live:gate,
   pick, decision_paper, a4_cards_noteam… ile karşılanıyor). Karşılığı olmayanlar için yeni dünya YAZMA; listele (tür → karşılık ya da "yok,
   gerekçe").
3. Okuyucusu kalmayan kod ve anahtarlar: product_quality.gd area_row ve WORD_TONES; sprint_catalog.gd area_sentence, _standing, _recent_hit ve
   onlarla giden CSV anahtarları (PRODUCT_AREA_RIVAL, PRODUCT_AREA_OVER_CAPACITY, PRODUCT_AREA_REVENUE_*, PRODUCT_AUDIENCE_*, PRODUCT_STAR_*,
   PRODUCT_RESEARCH_VOICE_* ve data/product/sprint.json research_sentence_weeks), yalnız smoke okuyorsa smoke vakasıyla birlikte. Her silmeden
   önce grep ile okuyucuyu say (scripts/, data/, scenes/, tools/; events dahil okumak serbest) ve kanıtı yaz. card_effect KALIR (02_urun_sprint.md
   :264'ün kararı). PRODUCT_BUGS_TIP_PREV/TOP, PRODUCT_THIS_SPRINT, bug_row_of, recent_hits, _over_capacity, area_alert, PRODUCT_BUG_COUNT KALIR
   (okuyucuları var; doğrula).
4. endgame_smoke.gd: silinen koda değen vakalar (product_area_row ve envanterin kısmen düşenler listesi) ya silinir ya da kalan doğru davranışı
   sınayacak biçimde küçültülür; falsifikasyon notları güncellenir. EXPECT-ERROR işaretlerine dikkat.
5. Belgeler (aynı değişiklik): CLAUDE.md §12'nin Ürün sekmesi kare paragrafı ("Ürün sekmesi: --product-shot=<c1..c5|cards|flow|edge:<ad>> debug
   fikstürüyle …") yalnız live: türlerini anlatacak biçimde yeniden yazılır (live:a4_* ailesi dahil; liste sistem sayfasına yönlendirilebilir);
   docs/kod_haritasi/sistemler/02_urun_sprint.md, 08_sekmeler.md, 10_test_harness.md'deki fikstür ve silinen sembol atıfları. Belge satırları
   240 karakteri geçmez. Üretilmiş dosyalara (docs/kod_haritasi/DIZIN.md, SEMBOLLER.tsv, KALITE.md) DOKUNMA: commit anında üretilir.
Doğrulama: --import (dosya silindi) + ısınma temiz; parse temiz; smoke: loc_csv_integrity all_scripts_load loc_product_derived_keys ve
değiştirdiğin/sildiğin vakaların komşuları ile game_shell/product_tab'a değen vakalar (adlarını endgame_smoke.gd'den bul); ayrıca
gdw ile "--headless --path . -s res://scripts/debug/loc_residue.gd" çıkış 0. Silinen her ad için son grep (0 sonuç) kanıtı.
Dönüş (ham veri): değişen ve silinen dosyalar (project-unicorn/'a göre; silinenler ayrı liste); silinen semboller ve anahtarlar, her biri için
grep komutu ve sonuç sayısı; kapsam kaybı tablosu; kırılan iki yerin çözümü; smoke sonuçları; belge değişiklikleri; emin olmadığın nokta.`
phase('Code')
return await agent(prompt, { label: 'D4a U7 cleanup', phase: 'Code', model: 'sonnet', effort: 'xhigh' })
