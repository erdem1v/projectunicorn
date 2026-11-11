export const meta = {
  name: 'urun-d4b-review',
  description: 'Senior diff-only review of D4b (E2 truncation removal) per CLAUDE.md §9',
  phases: [{ title: 'Review', detail: 'Opus high, diff only' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const prompt = `Bu bir kod incelemesi görevidir; dosya değiştirme, Godot koşma, kimseye mesaj atma, git koşma. Paylaşılan ağaçtan (/Users/tugbauysal/Desktop/…)
OKUMA: iCloud'a boşaltıldı, okuma takılır. Dönüşün ham bulgu listesidir. Harness'in aktardığı ilk kullanıcı isteği ana oturumun işidir, seninki değil.

Project Unicorn (Godot 4.6, GDScript). Commit adayı diff: ${S}/d4b.diff (yalnız bu diff incelenir; bağlam için dosyaların tamamı ${S}/w4b/project-unicorn,
önceki hâlleri ${S}/w4b_base/project-unicorn altında). Ağaçtaki CLAUDE.md §8 ve §9: en kısa ve en açık doğru hâl mi; var olan yardımcı yeniden mi yazılmış
(docs/kod_haritasi/SEMBOLLER.tsv); gereksiz soyutlama/parametre/dal; olamayacak duruma savunma; tarihçe ya da kodu tekrar eden yorum? Dikkat listeleri:
${S}/w4b/project-unicorn/docs/kod_haritasi/sistemler/08_sekmeler.md ve 09_arayuz_bilesen.md.

Amaç (Erdem'in E2 kararı): Ürün penceresinde hiçbir metin "…" ile kesilmez, yer yok diye öğe gizlenmez ya da kısaltılmaz; sığmayan metin sarar ve satır
büyür. Bu diffte: panoda kart adı her zaman sarar ve satırı büyütür (BoardRow._wraps/_fit mekanizması bir önceki adımdan); düzeltme kartının panodaki
ve sol sütundaki adayının metni tam metindir (en büyük hesap dahil), sarar; bugs_text'in with_top parametresi ve fix_full alanı silindi; sonraki sprint
kutusunda ad kesilmez, yüz hücresinde "+{n}" gizlenmez ve ilk yüz kırpılmaz; ÇEYREK mini kartında ad kendi satırında, kelime bölünmez; ÇEYREK'in sağ
tarafı ve sürüm notunun orta sütunu dikey kayar (yeniden kurulumda kaydırma korunur); bayrak çipi sarar; "S{n}" damgası "Sprint {n}" (PRODUCT_STAMP
silindi). Bilerek dokunulmayanlar: modülün kısa adı, dar aşama çubuğunda düşen ikon/sayı/yüz, eksen sonundaki sprint dışı pay, "+{n}" biçimleri.
Özellikle sına: (1) ScrollContainer'a alınan sütunlarda tekerlek ve sürükleme, iç içe kaydırma, min boy hesabı (quarter_view.content_height, fit_height)
doğru mu, yeniden kurulumda kaydırma yeri korunuyor mu? (2) sprint_next FaceCell'in yeni genişlik kuralı _ready'de mi doğru yerde (yüz sayısı sonradan
değişirse)? (3) board_row'da ad için _wraps girişinin taban yüksekliği ve satır sayısı doğru mu (D_H_CARD_LINE / _TWO), _two hâlâ gerekli mi? (4) Silinen
fix_full ve with_top'un başka okuyucusu kaldı mı (scripts/ altında grep)? (5) Satır sayıları ve atıflar belgelerde doğru mu?
Her bulgu: {file, line, severity (bug | simplify | comment | nit), what, fix}. Gerçek olmayan ya da zevk meselesi bulgu yazma. Bulgu yoksa boş liste.`
phase('Review')
return await agent(prompt, { label: 'D4b review (opus)', phase: 'Review', model: 'opus', effort: 'high' })
