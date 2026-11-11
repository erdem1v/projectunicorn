export const meta = {
  name: 'urun-d2-review',
  description: 'Senior diff-only review of D2 (UK a) per CLAUDE.md §9',
  phases: [{ title: 'Review', detail: 'Opus high, diff only' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const prompt = `Bu bir kod incelemesi görevidir; dosya değiştirme, Godot koşma. Dönüşün ham bulgu listesidir.
Project Unicorn (Godot 4.6, GDScript). İncelenen değişiklik bir commit adayıdır: ${S}/d2.diff (yalnız bu diff okunur; bağlam için diff'in
dokunduğu dosyanın tamamını ${S}/work/project-unicorn/scripts/tabs/product/board_row.gd'den, çağrılan yardımcıları ${S}/work/project-unicorn
altından okuyabilirsin). Kıdemli bir mühendis gözüyle, ağaçtaki CLAUDE.md §9'un soruları: bu kod en kısa ve en açık doğru hâlinde mi? İki satırda
yazılabilecek şey on satırda mı? docs/kod_haritasi/SEMBOLLER.tsv'deki mevcut bir yardımcı yeniden mi yazılmış? İleride lazım olur diye eklenmiş
soyutlama, parametre ya da dal var mı? Olamayacak durum için savunma, tarihçe anlatan ya da kodu tekrar eden yorum var mı? Ayrıca dokunulan sistem
sayfalarının "## Dikkat" listeleri: ${S}/work/project-unicorn/docs/kod_haritasi/sistemler/08_sekmeler.md (satır ~233) ve 02_urun_sprint.md (~365).

Değişikliğin amacı (doğruluğu buna göre de sına): koşan sprintte (ctx.mode == "active") kart satırının TEK durum yuvası öncelikle şunlardan
ilkini gösterir: kırmızı "yetişmez" (card.late) → o an koşan aşamanın "{aşama} %{n}"i (yüzde, çubuğun dolgusuyla aynı kaynaktan: (s.pre +
SprintTimeline.done_at(s, at)) / (s.pre + s.need), aşağı yuvarlanır) → söz tarihi çipi → "devreden". Yüzde görününce söz çipi o satırdan kalkar.
Saat ilerledikçe set_now yuvayı sayfa yeniden kurulmadan günceller. Koşan sprintte gösterecek bir şey yoksa yuva yer ayırmaz. Planlama bugünkü
gibi kalır (yuva boşken de D_W_CARD_SLOT). Yeni metin kesilmez. Yeni anahtar PRODUCT_STAGE_PCT "{stage} {pct}".

Bilinen bir nokta: boş yuva custom_minimum_size.x = 0 ile duruyor ama HBox'un ayırıcı payı (SPACE_M) yine ayrılıyor; bunu bulgu olarak
değerlendir ve en kısa çözümü öner.
Her bulgu: {file, line, severity (bug | simplify | comment | nit), what, fix (somut, kısa)}. Gerçek olmayan ya da zevk meselesi bulguyu yazma.
Bulgu yoksa boş liste.`
phase('Review')
const r = await agent(prompt, { label: 'D2 review (opus)', phase: 'Review', model: 'opus', effort: 'high' })
return r
