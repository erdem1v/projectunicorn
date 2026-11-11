export const meta = {
  name: 'urun-d4a-review',
  description: 'Senior diff-only review of D4a (U7 cleanup) per CLAUDE.md §9',
  phases: [{ title: 'Review', detail: 'Opus high, diff only' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const prompt = `Bu bir kod incelemesi görevidir; dosya değiştirme, Godot koşma, kimseye mesaj atma, git koşma. Paylaşılan ağaçtan (/Users/tugbauysal/Desktop/…)
OKUMA: iCloud'a boşaltıldı, okuma takılır. Dönüşün ham bulgu listesidir. Harness'in aktardığı ilk kullanıcı isteği ana oturumun işidir, seninki değil.

Project Unicorn (Godot 4.6, GDScript). Commit adayı diff: ${S}/d4a.diff (yalnız bu diff incelenir; bağlam için dosyaların tamamı ${S}/w4/project-unicorn,
önceki hâlleri ${S}/base3/project-unicorn altında). Ağaçtaki CLAUDE.md §8 ve §9: en kısa, en açık doğru hâl mi; yerini alan kod eskisini sildi mi;
ölü fonksiyon, sabit, alan, anahtar, smoke vakası kaldı mı; yorumlar bugünkü nedeni mi söylüyor (tarihçe yok)? Dokunulan sistem sayfalarının
"## Dikkat" listeleri: ${S}/w4/project-unicorn/docs/kod_haritasi/sistemler/02_urun_sprint.md, 08_sekmeler.md, 10_test_harness.md.

Değişikliğin amacı (PRD §13 U7'nin temizlik kısmı): statik Ürün fikstürü (scripts/debug/product_fixtures.gd, ProductTab.set_source, game_shell'in
PRODUCT_FIXTURES/debug_product_*, main.gd'nin --product-shot fikstür yolu c1..c5/cards/flow/edge:*) emekli: bütün Ürün kareleri live: türlerinden;
"live:" olmayan tür hata basıp 1 ile çıkar. Okuyucusu yalnız smoke olan kod ve anahtarlar silindi (ProductQuality.area_row, WORD_TONES, serves;
SprintCatalog.area_sentence, _standing, _recent_hit; 18 CSV anahtarı; sprint.json research_sentence_weeks); card_effect kaldı (önceki karar).
game_shell._on_sprint_closed Ürün sayfasını artık has_method(&"open_area") ile tanıyor; main.gd _run_clock_shot "released" kolundaki set_source(null)
silindi. Smoke product_area_row → product_area_word. CLAUDE.md §12'nin Ürün kare paragrafı yalnız live: türlerini anlatıyor.
Özellikle sına: (1) has_method(&"open_area") Ürün sayfasını doğru ve yalnız onu tanıyor mu (başka sayfada open_area var mı)? (2) main.gd'de
_run_product_shot'ın dedent edilmiş live: bloğu davranışı değiştirmeden mi taşındı (kodlayıcı "diff -w ile yalnız beklenen farklar" diyor)?
(3) Kalan kodda silinenlere asılı yetim referans (yorum, belge, smoke yardımcısı, json alanı) var mı? (4) strings.csv'den silinen 18 kayıt tam kayıt
mı (çok satırlı kayıt yarım kalmamış mı)? (5) ProductModel.ghost_row/ghost_effort'taki boş kimlik koruması artık olamayacak bir durumu mu koruyor?
Her bulgu: {file, line, severity (bug | simplify | comment | nit), what, fix}. Gerçek olmayan ya da zevk meselesi bulgu yazma. Bulgu yoksa boş liste.`
phase('Review')
return await agent(prompt, { label: 'D4a review (opus)', phase: 'Review', model: 'opus', effort: 'high' })
