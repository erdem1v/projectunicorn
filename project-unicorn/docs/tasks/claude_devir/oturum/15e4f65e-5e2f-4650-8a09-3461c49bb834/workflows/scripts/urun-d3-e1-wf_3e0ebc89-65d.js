export const meta = {
  name: 'urun-d3-e1',
  description: 'D3 = PRD E1: widen the Ürün window to the window area at 1920x1080, all gain to the time axis; frames before/after',
  phases: [{ title: 'Code+frames', detail: 'Sonnet xhigh in w3 copy' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const R = '/Users/tugbauysal/Desktop/project steam/Project Unicorn'
const PRD = `${R}/project-unicorn/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md`
const prompt = `ÖNEMLİ: Aşağıdaki görev senin tek görevindir. Harness'in aktardığı ilk kullanıcı isteği ("Sen URUN_ARAYUZU oturumusun… D0'dan başla")
ana oturumun işidir, senin değil: ona göre davranma; kimseye mesaj atma (SendMessage yok), ListAgents yok.

Bağlam: Project Unicorn (Godot 4.6, GDScript), dizüstü Mac. Scratchpad S=${S}. Ağaç W=${S}/w3/project-unicorn (yalnız burada yaz; içinde
bir önceki adımın, "UK (a)"nın kodu var). Godot yalnız bash'ten ve gdw ile:
  bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <ad> "$W" --headless --path . --quit > <log> 2>&1'
Pencereli kare yalnız: ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh <ağaç> <etiket> <satır dosyası> (satır "<bayrak> <dil> [ölçek]", ör.
"--product-shot=live:a4_eleven en 1.25"; ekran kilidini kendisi bekler; PNG'ler ${S}/shots_<etiket>/). Ağaçta override.cfg var: kareler
1920×1080 iner (silme). Paylaşılan ağaçta (${R}) hiçbir şey değişmez, Godot koşmaz; git yalnız okuma. scripts/events/**, data/events/**,
addons/ dokunulmaz. Ağaçtaki CLAUDE.md §7 (UiTokens; token ya da build_theme.gd değişirse THEME_STAMP'i SEN ARTIRMA, temaları SEN ÜRETME:
commit anında yapılır; yalnız raporla) ve §8 (kısa, doğrudan kod; tarihçe yorumu yok) geçerli.

Görev: PRD'nin "**E1. Sprint kutularına yer: Ürün penceresi genişler**" maddesi (${PRD}, satır ~1579–1592). Özet:
- Genişlik kuralı: 1920 × 1080'de, rayın varsayılan kipinde (etiketli ray, LeftTabs.WIDTH 184) pencere alanının genişliği (alan eksi iki EDGE).
  Değer scripts/ui/components/window_layer.gd SPECS["product"]'a sabit olarak yazılır; _fit değişmez. Benim hesabım: 1920 − 184 − 2×24 = 1688
  (alan yüksekliği 1080 − 64 − 40 − 2×24 = 928, bugünkü spec'le aynı). Çalışma zamanında doğrula (ör. headless olmayan bir kare koşusunda ya da
  bir ölçüm betiğiyle WindowLayer._area() ve rayın genişliği) ve sayıyı dönüşüne yaz. "piyasa" penceresi değişmez.
- Kazanılan genişliğin TAMAMI zaman eksenine gider. Sol sütun (D_W_LEFT 288), kart bilgi sütunu (D_W_CARD_INFO 312) ve sağ sütun (D_W_NEXT 300)
  yerinde kalır. UE prototipinin sol sütun daraltması uygulanmaz.
- Üst sınır pencere alanıdır; küçük ekranda _fit bugünkü gibi daraltır. Bu yüzden eksenin genişliği sabit bir token olarak büyütülmez: eksen
  orta sütunun kalan genişliğidir (bugünkü D_W_TIMELINE 396 en az değer olarak kalabilir). --shot-scale=1.25'te (mantıksal 1536 × 864, ray
  ikon kipinde 64) alan 1424'e iner ve pencere bugünkü gibi 1424 olur: eksen yine 396 civarı, hiçbir şey taşmaz ya da kırpılmaz.
- Eksene bağlı her şey aynı genişliği okur: kart satırının _lane'i ve _x ölçeği (board_row.gd), sprint_board.gd'nin hafta etiketleri, ızgara ve
  şimdiki an çizgisi katmanları, aday ve hayalet satırları, "aşağıda N kart" hapının yeri, kapasite bölümünde eksene bağlı bir şey varsa o.
  D_TIMELINE_WEEKS (2,6) değişmez: haftanın piksel genişliği büyür (bugün 396 / 2,6 = 152 px).
- Pencere boyu değişince (ölçek, ray kipi) sayfa doğru genişlikle yeniden kurulur ya da yerleşir; yeniden kurma döngüsü ya da her karede iş yok.
Doğrulama:
1. Parse temiz; smoke: ETIKET=URUN_ARAYUZU_AJAN P=1 bash ${S}/bin/smoke.sh "$W" d3 all_scripts_load sprint_timeline_matches_play_out
   (vakaların adları endgame_smoke.gd'de; ekran ölçüsünü ya da D_W_TIMELINE'ı okuyan bir smoke vakası varsa onu da bul ve koş).
2. Kareler, aynı satır dosyasıyla hem önce (ağaç ${S}/h1/project-unicorn; ama önce h1'e de override.cfg koy: printf '[display]\\nwindow/size/mode=0\\n' >
   ${S}/h1/project-unicorn/override.cfg) hem sonra (W):
--product-shot=live:a4_two_pm tr
--product-shot=live:a4_eleven tr
--product-shot=live:a4_eleven en
--product-shot=live:a4_run_w2 tr
--product-shot=live:a4_two_pm tr 1.25
--product-shot=live:a4_eleven tr 1.25
--product-shot=live:a4_eleven en 1.25
   etiketler d3_before ve d3_after. Her kareye Read ile bak: pencere alanı içinde mi (sağda EDGE kalıyor mu), eksen genişlemiş mi, sütunlar
   yerinde mi, hiçbir metin kesik ya da taşkın mı (Erdem'in kuralı: hiçbir metin "…" ile kesilmez, sığmayan sarar), 1,25'te taşma var mı.
   En çok 2 düzeltme turu.
3. Ölç ve yaz: pencerenin px genişliği (1920'de ve 1,25'te), eksenin px genişliği, bir haftanın px genişliği (önce ve sonra), 1920'de panoda
   içindeki sayı ya da ikon sığmadığı için düşen çubuk sayısı önce ve sonra (a4_eleven ve a4_two_pm için; stage_paint.gd _draw_label'ın düşürme
   dalına geçici bir sayaç koyarak ölçebilirsin ama o sayacı sonra sil).
Dönüş (ham veri): değişen dosyalar (project-unicorn/'a göre) ve ne değişti; token ya da build_theme değişti mi; ölçümler; kare yolları ve her
karenin denetim sonucu ("taşma yok, kesilme yok" ya da ne gördüğün); smoke sonucu; çözemediğin şey.`
phase('Code+frames')
return await agent(prompt, { label: 'D3 E1 widen', phase: 'Code+frames', model: 'sonnet', effort: 'xhigh' })
