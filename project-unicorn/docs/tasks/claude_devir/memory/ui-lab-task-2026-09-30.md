---
name: ui-lab-task-2026-09-30
description: "UI LAB task (sandbox tema laboratuvarı, 3 klasör yönü Evrak/Dosya/Gazete) — Erdem'in 5 kararı, onaylı plan yolu, mimari çekirdek gerçekleri"
metadata:
  node_type: memory
  type: project
  originSessionId: 0e406678-a661-4d23-90af-2e43deb375cc
  modified: 2026-10-02T08:37:27.610Z
---

**Plan:** `C:\Users\erdem\.claude\plans\pasted-content-id-37a5-task-ethereal-reef.md` (onaylı 2026-09-30). Çıktı yalnız
`project-unicorn/sandbox/ui_lab/` + `docs/audits/UI_OVERRIDES.md`; commit yok, Erdem F5'te karar verir.

**Erdem'in kararları (2026-09-30):** (1) çerçeve (TopBar + haber bandı) yöne serbest; (2) arka plan İş hanı 11:00;
(3) renk körü paleti Erdem'in ayarını izler (settings.json'da AÇIK), lab ayara dokunmaz, durumu kareye yazar;
(4) Gazete başlık fontu Newsreader; (5) seçili kulak–pencere gerçek ekranda yaslanır (TabButtonActive
expand_margin_right 4, WindowPanel expand_margin_left 16; yan etki raporlanır).

**Why:** oyun 131 varyasyon adı kullanıyor; yalnız 11 yeni ad tanımlayan tema gerçek ekranda hiçbir şey değiştirmez,
yalnız temel tip tanımlayan tema her varyasyonu ezer (Godot 4.6.2 kaynağında doğrulandı: ata temaları tüm tip zinciri
boyunca proje temasından önce aranır). Bu yüzden yön teması = master_theme'in sayılarak kopyalanmış, ölçü korumalı
yeniden giydirmesi + ROLE_MAP düzleştirme (taban yeniden bağlama işe yaramaz).

**How to apply:** lab gerçek GameShell'i 1920×1080 SubViewport sahnede örnekler; `TimeManager.hold_clock("ui_lab")`
her koşulabilir sandbox sahnesinde ilk satır (yoksa ~90 sn'de otomatik kayıt oyuncunun yuvasına yazar); KeyRouter tüm
girdiyi tüketir; tohum `_seed_theme_surface` (5 çalışan/3 müşteri/2 aday) ağaçsız main.gd örneğiyle. Pencereli Godot
koşuları tek tek; başsız paralel koşular ayrı APPDATA şeridinde. Sınıf önbelleği tabanı 156 kayıt (import sonrası aynı
kalmalı; sandbox'ta class_name yok).

**İlerleme 2026-09-30:** Workflow A (çekirdek) bitti: kimlik teması baseline'la 0 px, `--office-shot=ishani:11:hr/sales`
paritesi bant dışında 0 px, tema gidiş-dönüşü bayt-eş, MCP duman testi geçti, denetim 470 satır (290 görsel, 180
yerleşim), S-6 (settings.json + saves) değişmedi. Son incelemenin S2'si (yerel tipte null font kaçıyordu, `has_font`
varsayılan tuzağı) orkestratörce kapatıldı. Workflow B (yönler) bitti 2026-10-01: üçü de PASS, 11/11, glif 12/12,
son inceleme temiz (tek S3: evrak CommitButtonDark basılı kontrastı, lab dışı renk kararı). Açık sahip kararları: koddan
boyanan ray etiketleri (#8A8175/#9A6A12) üç yönün koyu kulak dolgularında baseline'dan düşük kontrast (evrak 2,85,
dosya 2,99, gazete 3,10 vs 3,59); gazete kilitli sekme 1,15; kod çipleri gazete kâğıdında zayıf. Dersler: yazarların
"needs_core_change" alanına engelleyici olmayan notlar da düşüyor, kapıyı yalnız başarısız statüye bağla; değişken
fontta get_font_name varsayılan örneğin adını verir (çizilen eksenler ayrıca yazılmalı).

**TESLİM 2026-10-01:** Workflow C (birleştirme) geçti: 15 kare tek süreçte, VERIFY PASS, baseline üç koşuda bayt-eş,
MCP etkileşim denetimi (F1-F4, 0-3, capture-viewport batch'le bayt-eş), §10 12/12, S-6 aynı. 137 izlenmeyen giriş
yalnız sandbox/ui_lab + UI_OVERRIDES.md; COMMIT YOK, Erdem F5 bekliyor ("geri al" = `sandbox/ui_lab` ve
`docs/audits/UI_OVERRIDES.md` silinir). Kareler ve temas sayfası SendUserFile ile gönderildi.

**2026-10-01 RED:** Erdem üç yönü de reddetti ("araştırma yapmamışsın, diğer oyunlar nasıl yapmış"). Referans
araştırması yapıldı (7 ajan, ~70 kaynak): rapor `scratchpad/ui_research/RAPOR.md`, pano `board/referans_panosu.png`
(12 numara). Bulgu: sorun renk değil, web-paneli dili (Lucide, hap çip, 9-13 px büyük harf mono) 3B ofisle ilgisiz;
klasör turu pikselin yalnız %6-17'sini değiştirdi. Dört yön: 1 "Oyuncak Ofis" (Two Point çizgisi, önerilen, tema değil,
yerleşim+sanat+ofis kodu), 2 "Menajer Masası" (FM/F1M koyu yoğun), 3 "Sahneli Editoryal" (V3/CK3, Set A korunur,
yedek), 4 "Kurucunun Ekranı" (kurgusal uygulamalar). Erdem'in S1-S9 cevapları bekleniyor; seçmeden üretim yok. Araçlar scratchpad/ui_lab/ (run_godot.sh
sarmalayıcı, check.gd, parity_diff.py, verify_shots.py, contact_sheet.py).

**MAKETLER 2026-10-02:** Erdem S1-S9 yerine önce maket istedi (Ekip + Frank kartı, tuval + sohbet). Repo dışı HTML/CSS,
gerçek ofis plakası (sha1 bd3e56ba eş) + büstler + seed verisi üstüne; 4 yön × 2 kare `scratchpad/mockups/final/`,
tuval https://claude.ai/artifact/5jfaCmaucJJ1JB2QFidk5u (satır başına yön, en üstte bugün, notlar). Eleştirmen
sıralaması: Oyuncak en ayrışık; Menajer/Editoryal/Kurucu olay kartları aynı iki sütun düzeninde. Ortak açıklar: Frank
yağlı boya vs düşük poligon, rol unvanı büyük harfi, izindeki satır soluklaması, hisse bedeli rengi. Git ve oyun
değişmedi. Erdem'in yorumu bekleniyor.

İlgili: [[godot-theme-engine-facts]] · [[design-work-lessons]] · [[font-durusmasi-specimen]] · [[godot-import-cache-gotchas]] · [[ui-design-system]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [UI Lab task 2026-09-30](ui-lab-task-2026-09-30.md) — sandbox tema laboratuvarı + 3 klasör yönü; Erdem'in 5 kararı (çerçeve serbest, İş hanı 11:00, CB ayarı izlenir, Newsreader, gerçek ekranda yaslanma); tam kapsamlı yeniden giydirme gerekçesi; hold_clock kuralı; üç yön REDDEDİLDİ 2026-10-01 → araştırma RAPOR.md (4 yön) → **4 yön × 2 maket tuvalde 2026-10-02 (artifact 5jfaCmaucJJ1JB2QFidk5u), Erdem MENAJER'i seçti → [[ui-redesign-menajer-2026-10-02]]; lab silinecek (araçları önce taşınır)**
