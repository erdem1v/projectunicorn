export const meta = {
  name: 'urun-d2-rowgrow',
  description: 'D2 visual fix: fix-card text wraps and the board row grows (E2), frames TR/EN',
  phases: [{ title: 'Code+frames', detail: 'Sonnet xhigh in work copy' }],
}
const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const R = '/Users/tugbauysal/Desktop/project steam/Project Unicorn'
const prompt = `ÖNEMLİ: Aşağıdaki görev senin tek görevindir. Harness'in aktardığı ilk kullanıcı isteği ("Sen URUN_ARAYUZU oturumusun… D0'dan başla")
ana oturumun işidir, senin değil: ona göre davranma, kimseye mesaj atma (SendMessage yok), ListAgents yok.

Bağlam: Project Unicorn (Godot 4.6, GDScript), dizüstü Mac. Scratchpad S=${S}. Ağaç W=${S}/work/project-unicorn (yalnız burada yaz).
Godot yalnız bash'ten ve gdw ile: bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <ad> "$W" --headless --path . --quit > <log> 2>&1'
(gdw kendi HOME'unu verir, sınırda bekler). Pencereli kare yalnız: ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh <ağaç> <etiket> <satır dosyası>
(satır biçimi "<bayrak> <dil>"; PNG'ler ${S}/shots_<etiket>/ altına). Paylaşılan ağaçta (${R}) hiçbir şey değişmez, Godot koşmaz; git yalnız okuma.
Ağaçtaki CLAUDE.md §7 (renk/boyut UiTokens'tan, tema varyasyonu) ve §8 (kısa, doğrudan kod; tek kullanımlık sarmalayıcı yok; yorum yalnız
bugünkü nedeni söyler) geçerli. strings.csv'ye dokunma.

Durum: W'de PRD "UK (a)" uygulandı (scripts/tabs/product/board_row.gd): koşan sprintte kart satırının durum yuvası koşan aşamanın
"{aşama} %{n}"ini gösteriyor. Düzeltme kartında (card.kind == "fix") ikinci satır: hata metni Label'ı (fix_text, SIZE_EXPAND_FILL,
OVERRUN_TRIM_ELLIPSIS) + durum yuvası + PM yuvası. Koşan sprintte yuva yüzdeyle dolunca hata metni "1 hata · 2 hesap · 24 …" diye kesiliyor
(kare: ${S}/shots_d2_after/product-shot_live_a4_run_w2_tr__product_shot_live_a4_run_w2.png, "Stok düzeltmesi" satırı). Erdem'in kuralı (PRD E2):
hiçbir metin "…" ile kesilmez; sığmayan metin sarar ve satır büyür.

Görev: BoardRow'da satır, bilgi sütununun içeriği taban yükseklikten (D_H_CARD_ROW / D_H_CARD_ROW_TWO) uzunsa büyür. Bu adımda yalnız düzeltme
kartının hata metnine uygula: kesme kalkar (OVERRUN_TRIM_ELLIPSIS yok), metin kelime sınırında sarar (AUTOWRAP_WORD_SMART), satır büyür.
Kartın adının max_lines_visible / OVERRUN_TRIM_ELLIPSIS'ine DOKUNMA (sonraki adımın işi), ama kurduğun mekanizma ileride adın da sarıp
satırı büyütmesine izin verecek biçimde genel olsun (satırın yüksekliği içerikten gelir; karakter sayısı sezgisi eklenmez).
Bugün satır mutlak konumlu bir Control'dür (setup: cell = Control, _mark, _info(h) MarginContainer'ı sabit size, _lane(h) sabit size, _acts
ofsetle). En kısa doğru çözümü seç; ör. bilgi sütunu ile zaman eksenini konteynerle yan yana koymak ve eksenin taban yükseklikte kalıp satırda
dikey ortalanması; ya da satırın en az yüksekliğini bilgi sütununun birleşik en az yüksekliğinden almak. Şartlar:
- Büyüyen satırda soldaki vurgu çizgisi (_mark) satırın tam boyunda; "→" ve "×" (_acts) bugünkü yerinde; aday satırının alttaki kesik çizgisi
  (_draw) satırın altında; zaman ekseninin çubukları dikeyde satıra göre düzgün (ortalı ya da bugünkü üst payıyla, tutarlı).
- Büyümeyen satırlar piksel piksel bugünkü gibi kalır (önce/sonra kareleriyle karşılaştır).
- sprint_board.gd'nin satırların altındaki ve üstündeki eksen katmanları (hafta çizgileri, şimdiki an çizgisi), "aşağıda N kart daha" hapı ve
  kaydırma büyüyen satırla doğru çalışır; PRODUCTSHOT satırında row_gaps=0 kalır.
- Autowrap'lı Label'ın en az yüksekliği genişliği bilinince doğru çıkar; ilk karede yanlış yükseklik görünüyorsa çöz (ölç, kareyle doğrula).
Doğrulama:
1. Parse temiz (SCRIPT ERROR|Parse Error 0).
2. Kareler: satır dosyası
--product-shot=live:a4_run_w2 tr
--product-shot=live:a4_run_w2 en
--product-shot=live:a4_fourteen tr
--product-shot=live:a4_eleven en
   etiket d2_grow; aynı dosyayı HEAD ağacında da çek: ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh ${S}/h0/project-unicorn d2_grow_base <dosya>
   (ekran kilidini beklerler, sırayla koş). Her kareye Read ile bak: düzeltme kartının metni tam mı, satır büyümüş mü, büyümeyen satırlar
   önceki gibi mi, başka bir şey kayıyor ya da kesiliyor mu. En çok 2 düzeltme turu.
3. Smoke: ETIKET=URUN_ARAYUZU_AJAN P=1 bash ${S}/bin/smoke.sh "$W" d2g all_scripts_load sprint_timeline_matches_play_out
Dönüş (ham veri): değişen dosyalar ve ne değişti (kısa), seçtiğin yöntem ve nedeni, kare yolları ve her karenin denetim sonucu ("taşma yok,
kesilme yok" ya da ne gördüğün), PRODUCTSHOT satırları, smoke sonucu, çözemediğin şey.`
phase('Code+frames')
return await agent(prompt, { label: 'D2 row grow', phase: 'Code+frames', model: 'sonnet', effort: 'xhigh' })
