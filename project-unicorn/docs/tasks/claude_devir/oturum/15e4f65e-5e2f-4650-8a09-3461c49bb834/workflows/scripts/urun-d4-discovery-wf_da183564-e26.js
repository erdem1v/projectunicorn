export const meta = {
  name: 'urun-d4-discovery',
  description: 'Read-only map for D4: E2 truncation sweep of the Ürün window and the U7 cleanup inventory',
  phases: [
    { title: 'Sweep', detail: 'parallel finders, each a different angle' },
    { title: 'Critic', detail: 'completeness critic over the merged lists' },
  ],
}

const H = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad/h0/project-unicorn'
const PRD = '/Users/tugbauysal/Desktop/project steam/Project Unicorn/project-unicorn/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md'

const RULES = `
Salt okuma: hiçbir dosyayı değiştirme, Godot koşma. Ağaç H=${H} (HEAD'in temiz dışa aktarımı; Project Unicorn, Godot 4.6, GDScript).
Ürün penceresinin kodu: H/scripts/tabs/product/** ve H/scripts/tabs/product_tab.gd; ayrıca bunların çağırdığı ortak çizim yardımcıları
(UiFactory, HRUiShared, RnDUiShared, Fmt) yalnız Ürün penceresinde kullanılan yolları kadar.
Erdem'in kuralı (PRD E2, ${PRD} satır ~1594–1603): Ürün penceresinde hiçbir metin "…" ile kesilmez; yer yok diye hiçbir öğe gizlenmez ya da
kısaltılmaz; sığmayan metin sarar ve satır büyür. Bir şeyi toplayıp sayıyla gösteren biçimler ("+{n} kart", yüz dizisinde "+{n}") kesme değil
tasarım seçimidir: listelenir ama "kalır, kare D7'ye" diye işaretlenir.
Dönüşün ham veridir: her bulgu {file, line, kind, what, player_sees, proposed: "kalkar" | "gerekçeyle kalır" | "+{n} tasarım", reason}.
`

const FINDERS = [
  { key: 'tokens', prompt: `${RULES}
Açı: sözcük taraması. Ürün penceresinin kodunda şunların HER geçişini bul: "…" (ve "..." metin içinde), text_overrun_behavior, OVERRUN_,
clip_text, clip_contents, max_lines_visible, visible_characters, autowrap_mode = AUTOWRAP_OFF, trim, substr/left()/right() ile metin kısaltma,
ellipsis. Her biri için oyuncunun hangi metni kesik gördüğünü (hangi ekran, hangi öğe) ve ne yapılmalı olduğunu yaz.` },
  { key: 'hide', prompt: `${RULES}
Açı: "sığmıyorsa gizle / düşür" mantığı. Ürün penceresinin kodunda bir öğeyi yer yetmediği için gizleyen, düşüren, çizmeyen ya da kısaltan her
dal: ör. "sığmayan yerde önce ikon sonra sayı düşer" (stage_paint.gd), "çubuk sığmıyorsa yüz çizilmez" (board_row.gd), sığmayan yüzlerin "+{n}"
olması (sprint_next.gd), visible = false'u bir genişlik karşılaştırmasına bağlayan her yer, sabit genişlikte (custom_minimum_size.x ile birlikte
SIZE_EXPAND_FILL olmayan ve autowrap'sız) Label'lar. Her biri için oyuncunun ne kaybettiğini ve bilginin başka yerde (ipucu) olup olmadığını yaz.` },
  { key: 'quarter', prompt: `${RULES}
Açı: ÇEYREK sekmesi ve sonraki sprint kutusu. Bilinen: ÇEYREK'in sprint sütunlarında (SprintCard'ın dar görünümü, sprint_card.gd) EN kart adları
kelime ortasından bölünüyor ya da kesiliyor ("Spreadshe / et Import", "Basic Bookkeepin", "Accounts and"). quarter_view.gd, sprint_card.gd,
overview_view.gd ve sprint_next.gd'yi oku: adın bölünmesinin/kesilmesinin kod nedeni (autowrap_mode, sabit genişlik, max_lines, font),
düzeltmenin en kısa yolu (ör. AUTOWRAP_WORD_SMART ve satırın büyümesi; sütun genişliği), satır büyüyünce kayan başka bir öğe var mı.
Ayrıca SprintCard'ın hangi görünümlerinin (WIDE / NARROW / LOW) bugün kullanıldığını say (çağıranlarıyla).` },
  { key: 'u7', prompt: `${RULES}
Açı: U7 temizlik envanteri (PRD §13 U7, ${PRD} satır ~1097; §11.3 silinen anahtarlar ~996–1027; §14 A29). Çıkar:
1. SprintCard'ın WIDE / NARROW / LOW görünümlerinin bugünkü çağıranları; yalnız ÇEYREK'in kullandığı görünüm kalır, öbürleri silinecek.
2. ProductFixtures (scripts/debug/product_fixtures.gd) ve ProductTab.set_source: her okuyucu (dosya:satır); --product-shot'ın fikstür türleri
   (c1..c5, cards, flow, edge:<ad>) ve main.gd'deki fikstür yolu (~3689 civarı): silinince ne kırılır.
3. §11.3'ün anahtarlarından strings.csv'de hâlâ duranlar ve her birinin okuyucusu (yoksa "okuyucusuz").
4. product_model.gd ve sprint_catalog.gd'de (lead_sentence, forecast, alan cümleleri) okuyucusu kalmamış alan ve işlevler: her biri için
   grep kanıtı (hangi grep, kaç sonuç).
5. endgame_smoke.gd'de silinecek şeylere değen vakalar.
6. CLAUDE.md §12'nin Ürün shot listesi ve docs/kod_haritasi/sistemler/02_urun_sprint.md, 08_sekmeler.md, 09_arayuz_bilesen.md'de fikstür
   türlerine ya da silinecek sembollere atıflar; tools/kod_haritasi/uret.py'de ilgili yerler.
Her madde için dosya:satır ve grep kanıtı ver.` },
]

const CRITIC = (lists) => `${RULES}
Aşağıda dört ayrı tarayıcının bulguları var. Görevin tamlık eleştirisi: atlanan bir kesme, gizleme ya da U7 kalemi var mı? Ürün penceresinin
her dosyasını (H/scripts/tabs/product/*.gd ve product_tab.gd) tek tek aç ve tarayıcıların göremediği yeri ara (ör. tema varyasyonlarında
clip, build_theme.gd'de Ürün varyasyonlarının autowrap'ı, ScrollContainer'ın yatay kaydırmayı kapatıp kırpması, PopupPanel/ipucu genişlik
sınırları, CardTip'in sabit genişliği D_W_TIP ve metnin sarıp sarmadığı). Sonra bütün bulguları dosya:satır'a göre tekilleştir ve tek liste dön:
{e2: [bulgular], u7: {...}, missed_by_finders: [...], open_questions: [...]}.

TARAYICILARIN BULGULARI:
${lists}`

phase('Sweep')
const results = await parallel(FINDERS.map(f => () => agent(f.prompt, { label: `sweep:${f.key}`, phase: 'Sweep', model: 'opus', effort: 'high' })))
const merged = FINDERS.map((f, i) => `### ${f.key}\n${results[i] || '(boş)'}`).join('\n\n')
phase('Critic')
const final = await agent(CRITIC(merged), { label: 'critic', phase: 'Critic', model: 'opus', effort: 'high' })
return { merged, final }
