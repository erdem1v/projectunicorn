export const meta = {
  name: 'urun-d2-review2',
  description: 'Narrow second review of D2 row-growth hunk (counts as the single fix round)',
  phases: [{ title: 'Review', detail: 'Opus high, row-growth hunk only' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const prompt = `Bu bir kod incelemesi görevidir; dosya değiştirme, Godot koşma, kimseye mesaj atma. Dönüşün ham bulgu listesidir. Harness'in aktardığı
ilk kullanıcı isteği ana oturumun işidir, seninki değil.

Project Unicorn (Godot 4.6, GDScript). Diff: ${S}/d2_full.diff (board_row.gd ve sprint_board.gd). Bu diff'in "durum yuvası" kısmı
(_status, _fill_status, _stage_pct, set_now'daki yüzde) daha önce incelendi ve düzeltildi; ONU YENİDEN İNCELEME. Yalnız SATIR BÜYÜMESİ
parçasını incele: setup'taki yeni yapı (_mark, body, _info() Control'ü ve col'un ofsetleri, _lane'in custom_minimum_size + SHRINK_CENTER),
_h / _second / _wraps / _fit, düzeltme kartının hata metninin AUTOWRAP_WORD_SMART + minimum_size_changed bağlantısı, _person'daki
SHRINK_CENTER, _keys'in pad sarmalayıcısı ve sprint_board.gd'deki sort_children → _update_more bağlantısı. Bağlam için tam dosyalar:
${S}/work/project-unicorn/scripts/tabs/product/board_row.gd, sprint_board.gd ve çağrılan yardımcılar (SprintUiShared, UiFactory).

Amaç: düzeltme kartının hata metni kesilmez, kelime sınırında sarar ve satır büyür (Erdem'in kuralı: hiçbir metin "…" ile kesilmez,
sığmayan metin sarar, satır büyür). Büyümeyen satırlar piksel piksel öncekiyle aynı kalmalı (kareyle doğrulandı). Mekanizma bir sonraki
adımda kartın adının da sarıp satırı büyütmesi için kullanılacak (ad bugün 2 satırdan sonra "…" ile kesiliyor; o kesme bu commit'te kalıyor).

Sorular (ağaçtaki CLAUDE.md §9): en kısa ve en açık doğru hâli mi? Daha basit bir yol var mı (ör. bilgi sütununu konteyner yapıp satırın
yüksekliğini içerikten almak; kodlayıcı bunu iki satırlı adlı ve aday satırlarının 3 px büyüyeceği için seçmedi: bu gerekçe kodu bu kadar
karmaşıklaştırmaya değer mi?). _fit'in satır sayısı × satır yüksekliği hesabı Godot'nun kendi en az boyutunu yeniden mi yazıyor? Sinyal
döngüsü (minimum_size_changed → _fit → custom_minimum_size → yeniden yerleşim) sonsuz döngü ya da kare başı iş üretir mi? Koşan sprintte
saat başı yuva değişince _fit doğru tetikleniyor mu? Ölü/eksik kalan bir şey (eski cell, h parametresi) var mı? Yorumlar bugünkü nedeni mi
söylüyor?
Her bulgu: {file, line, severity (bug | simplify | comment | nit), what, fix (somut, kısa; gerekiyorsa küçük kod)}. Gerçek olmayan ya da zevk
meselesi bulgu yazma. "Daha basit yol" önerin varsa önce kendi içinde sına: büyümeyen satırların piksel eşliğini ve hata metninin sarmasını
koruyor mu? Bulgu yoksa boş liste.`
phase('Review')
return await agent(prompt, { label: 'D2 review2 (opus)', phase: 'Review', model: 'opus', effort: 'high' })
