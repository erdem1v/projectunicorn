export const meta = {
  name: 'urun-d3-review',
  description: 'Senior diff-only review of D3 (E1 window widening) per CLAUDE.md §9',
  phases: [{ title: 'Review', detail: 'Opus high, diff only' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const prompt = `Bu bir kod incelemesi görevidir; dosya değiştirme, Godot koşma, kimseye mesaj atma. Dönüşün ham bulgu listesidir. Harness'in aktardığı
ilk kullanıcı isteği ana oturumun işidir, seninki değil.

Project Unicorn (Godot 4.6, GDScript). Commit adayı diff: ${S}/d3.diff (yalnız bu diff incelenir; bağlam için dokunulan dosyaların tamamı
${S}/w3/project-unicorn altında). Ağaçtaki CLAUDE.md §9'un soruları: en kısa ve en açık doğru hâli mi? Var olan yardımcı yeniden mi yazılmış
(docs/kod_haritasi/SEMBOLLER.tsv)? İleride lazım olur diye soyutlama, gereksiz sinyal zinciri, olamayacak durum için savunma, tarihçe ya da kodu
tekrar eden yorum var mı? Dokunulan sistem sayfalarının "## Dikkat" listeleri: ${S}/w3/project-unicorn/docs/kod_haritasi/sistemler/08_sekmeler.md
ve 02_urun_sprint.md.

Amaç (Erdem'in E1 kararı): Ürün penceresi 1920 × 1080'de pencere alanının tamamı kadar genişler (SPECS["product"] = 1688 × 928, _fit
değişmez, küçük ekranda _fit bugünkü gibi daraltır); kazanılan genişliğin tamamı zaman eksenine gider, sol sütun, kart bilgi sütunu ve sağ sütun
yerinde kalır. Eksen orta sütunun kalan genişliğidir (en az D_W_TIMELINE 396); --shot-scale=1.25'te pencere 1424'e iner, eksen ~410 olur.
Eksene bağlı her şey (satırın _lane'i ve _x ölçeği, hafta etiketleri, ızgara, şimdiki an çizgisi, aday/hayalet satırları) aynı genişliği okur.

Kodlayıcının bildirdiği davranış: pencere açılışta iki kez kuruluyor (ilki model.axis = D_W_TIMELINE ile, sonra pano gövdesinin ölçtüğü 674
ile: holder.resized → _measure_axis → axis_wanted → ProductTab._on_axis → _queue_rebuild). Bunu özellikle değerlendir: oyuncu ilk karede dar
ekseni bir an görür mü (yeniden kurma aynı karede mi, sonraki karede mi)? Açılışta iki kez ProductModel.live() maliyeti var mı? Daha kısa ve
tek kurulumlu doğru bir yol var mı (ör. ProductTab ilk kurulumdan önce kendi genişliğini biliyorsa eksen ondan; ya da eksenin genişliği kurulumda
değil yerleşimde, satırların ölçeği bir kez ayarlanarak)? Önerini somut kodla ver ve kendi içinde sına: 1920'de 674, 1,25'te ~410, pencere
boyu değişince doğru eksen, döngü yok.
Her bulgu: {file, line, severity (bug | simplify | comment | nit), what, fix}. Gerçek olmayan ya da zevk meselesi bulgu yazma. Bulgu yoksa boş liste.`
phase('Review')
return await agent(prompt, { label: 'D3 review (opus)', phase: 'Review', model: 'opus', effort: 'high' })
