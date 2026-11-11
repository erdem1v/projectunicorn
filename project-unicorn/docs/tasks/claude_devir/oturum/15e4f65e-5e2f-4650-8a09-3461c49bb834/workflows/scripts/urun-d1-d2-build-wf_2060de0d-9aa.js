export const meta = {
  name: 'urun-d1-d2-build',
  description: 'D1 E5 prototype frames and D2 UK(a) code + frames, in parallel copies',
  phases: [
    { title: 'D1 prototype', detail: 'Sonnet: E5 prototype world + two forms + frames in d1 copy' },
    { title: 'D2 code', detail: 'Sonnet: UK (a) in work copy, headless checks' },
    { title: 'D2 frames', detail: 'Haiku: before/after frames' },
  ],
}

const S = '/private/tmp/claude-501/-Users-tugbauysal-Desktop-project-steam/15e4f65e-5e2f-4650-8a09-3461c49bb834/scratchpad'
const R = '/Users/tugbauysal/Desktop/project steam/Project Unicorn'
const PRD = `${R}/project-unicorn/docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md`

const COMMON = `
Bağlam: Project Unicorn (Godot 4.6, yalnız GDScript). Sen URUN_ARAYUZU oturumunun alt ajanısın; makine dizüstü Mac (M1, 8 GB).
Ortam: scratchpad S=${S}. Godot'yu yalnız bash'ten ve gdw ile koş (zsh'te işlevler yok):
  bash -c 'export ETIKET=URUN_ARAYUZU_AJAN; . "${S}/bin/env.sh"; gdw <koşu adı> <ağaç/project-unicorn> <godot argümanları> > <log> 2>&1'
  gdw her koşuya kendi HOME'unu verir (user:// = $(udir <koşu adı>)) ve sessiz kilidi, bellek ya da süreç sınırında kendiliğinden bekler.
Kurallar:
- Paylaşılan ağaçta (${R}) hiçbir Godot koşmaz, hiçbir dosya değişmez; git yalnız okumak için (log/show/diff). Commit, add, reset, stash yok.
- Pencereli (ekranlı) Godot yalnız şu betikle: ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh <ağaç> <etiket> <satır dosyası>
  (satır biçimi "<bayrak> <dil> [ölçek]", ör. "--product-shot=live:a4_run_w2 en"; ekran kilidini kendisi bekler ve alır; PNG ve loglar
  ${S}/shots_<etiket>/ altına, özet results.txt). gopeak editor-run/editor-launch kullanılmaz.
- Makinede aynı anda en çok 2 Godot süreci; öbür oturum da koşuyor. Smoke: ETIKET=URUN_ARAYUZU_AJAN P=1 bash ${S}/bin/smoke.sh <ağaç> <etiket> <vaka>...
  (çıktı ${S}/smoke_<etiket>/). Parse denetimi: gdw ile "--headless --path . --quit", logda "SCRIPT ERROR|Parse Error" 0 olmalı.
  class_name ekler ya da silersen önce "--headless --path . --import", sonra bir ısınma koşusu.
- scripts/events/**, data/events/** dokunulmaz. addons/ dokunulmaz.
- strings.csv asla baştan yazılmaz: satır, tırnak bilen bir ayrıştırmayla bulunan bayt aralığına eklenir ya da değiştirilir; UTF-8 BOM'suz, LF.
  Virgül taşıyan değer tırnaklanır. TR ve EN yer tutucu kümeleri aynı.
- Ağaçtaki CLAUDE.md geçerlidir: §5 (oyuncu metni anahtarla doğar, TR ve EN, tire yok), §7 (renk ve boyut UiTokens'tan; ham Color ya da
  ham boyut yok; stil tema varyasyonundan), §8 (kısa ve doğrudan kod; var olan yardımcıyı yeniden yazma; yorum yalnız bugünkü nedeni söyler).
- Oyunda hiçbir metin "…" ile kesilmez, gizlenmez ya da sabit genişlikte kırpılmaz (PRD E2, N4); sığmayan metin sarar, satır büyür.
- Dönüşün ham veridir (insan için mesaj değil): kısa, madde madde, yollar tam.
`

const D1 = `${COMMON}
GÖREV D1: E5 kareleri. Commit YOK: yalnız prototip ve kare. Ağaç P=${S}/d1/project-unicorn (HEAD f06bed6'nın dışa aktarımı, .godot içerir).
Yalnız bu ağaçta yaz. Bu kod hiçbir zaman commit'e girmez; prototip düzeyinde olabilir ama oyun bozulmamalı.

Oku: ${PRD} içinde "**E5. Plana alınmış müşteri isteğinin durumu.**" (yaklaşık satır 1621–1638), "**N2. Çeyrek hiyerarşisi" (1558–1563),
"**N4. Taşma" ve "**E2." (1594–1603). Kod (P altında): scripts/tabs/product/area_panel.gd (_add_requests, _request_row, _planned_chip),
scripts/tabs/product/product_model.gd (_requests yaklaşık 276, _due), scripts/tabs/product/sprint_ui_shared.gd (due_chip, HOURGLASS, CHECK,
stage_name), scripts/main/main.gd (_A4_WORLDS yaklaşık 4558, _seed_product_a4, _a4_sign, _a4_plan, _a4_play, _product_a4_ready; a4_requests
ve a4_run_w2 dünyaları), scripts/systems/sprint_bridges.gd (talep durumları open / met yaklaşık 108 / late), scripts/tabs/product/board_row.gd
(set_now: çubuğun dolgusu).

Kur:
1. Yeni dünya a4_requests_run (_A4_WORLDS'e ekle): B2B canlı ERP, sprint koşuyor (a4_run_w2 gibi run 1.0 ya da kartın koşan aşaması olan bir
   an). MÜŞTERİ TALEPLERİ'nde en az şu dört satır görünür:
   (a) kartı bu sprintte planlı istek; kartın koşan bir aşaması var;
   (b) kartı sonraki sprint sütununda planlı istek (SprintSystem.send_next);
   (c) karşılanmış istek: kartı önceki bir sprintin sürümüyle çıkmış (status "met");
   (d) planlanmamış, gelecek çeyreğe düşen istek ("gelecek çeyrek" çipi).
   Motorun seam'lerini kullan (_a4_sign, SprintSystem.add / send_next / start, _a4_play). Bir durum yalnız bir alanı elle yazarak kurulabiliyorsa
   (ör. due_sprint) bu prototipte kabul, ama dönüşüne yaz. Hazır kancada (_product_a4_ready) talep listesi açık olsun (requests_open true;
   page._set_ui(true, "requests_open") gibi) ki satırların hepsi görünsün. Kare kendi PRODUCTSHOT satırını basar.
2. Model (prototip): _requests açık isteklere ek olarak karşılanmış istekleri de döndürür (bugün yalnız open, product_model.gd:287) ve her
   satıra durum ekler: "met" | "this" (kart bu sprintte) | "next" (kart sonraki sütunda) | "". Koşan sprintte "this" satırının durum metni
   UK (a)'nın hesabıyla: koşan aşama, şimdiki an now (sprint başından hafta; ProductModel.now_at) için s.start - EPS <= now < s.end - EPS olan
   aşama (kartın zaman ekseni kaydı SprintSystem.timeline().cards[id].stages); pct = floor(clamp((s.pre + SprintTimeline.done_at(s, now)) /
   (s.pre + s.need), 0, 1) * 100); metin "{stage} {pct}" (SprintUiShared.stage_name, Fmt.percent(pct, 0); prototip anahtarı PRODUCT_STAGE_PCT
   = "{stage} {pct}" TR ve EN). Kart o an hiçbir aşamada koşmuyorsa ne gösterdiğini dönüşüne yaz. "next" → "Sonraki sprint" / "Next sprint"
   (önce var olan anahtarı ara; yoksa prototip anahtarı).
3. Çizim, ortam değişkeniyle iki biçim: E5=1 ve E5=2 (OS.get_environment("E5"); yalnız prototip; değişken gdw'den Godot'ya geçer):
   - Biçim 1 (ikon): plandaki satırda (this ya da next) bugünkü yeşil tikin yerinde ad boyunda bir ilerleme işareti, vurgu renginde (UiTokens'ın
     koyu temadaki vurgu rengi). Söz çipi zaten kum saati (HOURGLASS) taşıdığı için halka tercih edilir: küçük bir Control'de draw_arc ile
     ağzı açık halka, ya da assets/icons altında uygun bir halka / ilerleme ikonu varsa o. Yanında bugünkü gibi tarih metni.
   - Biçim 2 (kartın durumu): tikin yerinde kartın kendi durumu metinle, vurgu mürekkebiyle: "Test %40" ya da "Sonraki sprint"; yanında " · "
     ve tarih metni.
   - İki biçimde de plandaki satır soluk çizilmez: D_PLANNED_ALPHA modulate'i ve RequestRowPlanned zemini yok, normal RequestRow; ad tam parlak.
   - Karşılanmış satır: yalnız yeşil tik (bugünkü CHECK glifi ve rengi), ad boyunda; tarih yazmaz; listenin sonunda.
   - Söz tarihi çipinin metni (bu çeyrek / gelecek çeyrek / {q}. çeyrek) satırdaki müşteri adıyla aynı yazı boyunda ve büyük harfle başlar
     (Fmt.cap_first): "Gelecek çeyrek". Müşteri adının ve bugünkü çip metninin varyasyonlarının yazı boylarını ölç ve yaz; müşteri adının boyunu
     veren var olan bir varyasyonu kullan. Üç biçim aynı boyda kalır (N2); DueChip ile DueChipSoon yalnız renkle ayrılır. Planlı satırlardaki
     tarih metni de aynı boyda.
   - Uzun müşteri adı sarar, satır büyür; hiçbir şey kesilmez.
4. Kareler (pencereli, yalnız shots.sh): satır dosyası iki satır: "--product-shot=live:a4_requests_run tr" ve "--product-shot=live:a4_requests_run en".
   E5=1 ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh ${S}/d1/project-unicorn d1_f1 <dosya>; aynısı E5=2 ile etiket d1_f2.
   Her kareye Read ile bak (dört satır görünüyor mu, soluk satır yok mu, bir şey kesilmiş mi, doğru dilde mi, logda hata var mı).
   En çok 2 düzeltme turu. Son kareler için sol sütunun kırpmasını da üret (ör. Godot'nun Image API'siyle küçük bir headless -s betiği;
   betiği ağaca değil ${S}/d1_tools/'a koy; kırpma 2x büyütülmüş olabilir): ${S}/d1_crops/<tr|en>_f<1|2>.png.
Dönüş: kurulan dünyanın tarifi (her satır hangi yolla kuruldu; elle yazılan alan varsa), değişen dosyalar, kare ve kırpma yolları, her kare
için "taşma yok, kesilme yok" denetiminin sonucu, ölçülen yazı boyları, prototip anahtarları, karşılanmış satır için önerin (satır ne kadar
kalır, nerede sıralanır, "+{n} talep" katlamasına sayılır mı; her birinin kısa gerekçesi), gördüğün sorunlar.`

const D2 = `${COMMON}
GÖREV D2: PRD'deki "UK (a)" (Erdem'in E6 kararı). Ağaç W=${S}/work/project-unicorn (HEAD f06bed6'nın dışa aktarımı, .godot içerir; yalnız
burada yaz; bu ağaç commit'e girecek: kod kalitesi tam).
Oku: ${PRD} içinde "### UK: kart başına aşama ve yüzde" (yaklaşık satır 1537–1549) ve "**E6. UK: (a).**" (1640–1647); E2 (1594–1603).
Yol gösteren eski yama: ${R}/project-unicorn/docs/tasks/urun_arayuzu_devir/uk/uk_a.patch (eski bir tabana göre; uygulama, bugünkü
scripts/tabs/product/board_row.gd'nin üstüne yeniden yaz). Modelin satır alanları product_model.gd'nin başındaki yorumda ve _row'da (~701).

İstenen (koşan sprint = ctx.mode == "active"; planlama bugünkü gibi kalır):
1. Kartın tek durum yuvası koşan sprintte öncelik sırasıyla TEK şey gösterir: kırmızı "yetişmez" (card.late) → koşan aşamanın "{aşama} %{n}"i →
   söz tarihi çipi (slot.kind "due") → "devreden" (slot.kind "carried"). Yüzde görününce söz çipi o satırdan kalkar (tarih sol sütunda ve zengin
   kart ipucunda zaten var).
2. Koşan aşama: şimdiki an at (sprint başından hafta) için s.start - EPS <= at < s.end - EPS olan aşama. Yüzde çubuğun dolgusuyla aynı kaynaktan:
   made = s.pre + SprintTimeline.done_at(s, at); pct = floor(clamp(made / (s.pre + s.need), 0, 1) * 100). Modelde yeni hesap yazılmaz (PRD UK 5).
   Saat ilerleyince set_now yüzdeyi ve yuvanın hâlini sayfa yeniden kurulmadan günceller (aşama bitince sonrakine geçer; hiçbiri koşmuyorsa
   yuva bir sonraki öncelikli öğeyi gösterir).
3. Aşama adı var olan SprintUiShared.stage_name(stage)'den (yamadaki STAGE_NAMES sözlüğü yazılmaz), yüzde Fmt.percent(pct, 0). Yeni anahtar
   PRODUCT_STAGE_PCT = "{stage} {pct}" TR ve EN, strings.csv'de PRODUCT_LATE satırının hemen altına bayt aralığıyla eklenir.
4. Boş yuva genişlik almaz: koşan sprintte gösterecek bir şey yoksa yuvanın en az genişliği 0 (yama boş yuvaya da D_W_CARD_SLOT ayırıyordu;
   düzelt). İçerik varken bugünkü gibi en az D_W_CARD_SLOT. Planlamada yuva bugünkü gibi. Düzeltme kartında (fix) koşan sprintte yuva yüzde
   için de kurulur.
5. Yeni metin kesilmez: "Geliştirme %95" ya da EN "Development 95%" yuvaya sığmıyorsa yuva genişler; "…" yok, clip yok. Var olan kesmelere
   (OVERRUN_TRIM_ELLIPSIS, max_lines_visible) bu adımda dokunma: onlar sonraki adımın (D4) işi.
6. board_row.gd'nin baş yorumu ve _status'un yorumu bugünkü davranışı söyler (tarihçe yok). Gereksiz durum değişkeni, savunma kontrolü,
   tek kullanımlık sarmalayıcı yok.
Doğrulama (yalnız headless; kareyi başka aşama çeker): parse denetimi temiz; smoke loc_csv_integrity all_scripts_load (etiket d2c);
gdw res_d2 W --headless --path . -s res://scripts/debug/loc_residue.gd çıkış 0; ayrıca endgame_smoke.gd'nin sprint_ ve product_ önekli
vakalarından board ya da model satırına en çok değen 4 tanesini seç ve koş.
Dönüş: değişen dosyalar (project-unicorn/'a göre yol) ve her birinde ne değişti; eklenen anahtar ve değerleri; koşulan kapılar ve sonuçları;
PRD'nin sessiz kaldığı ya da çeliştiği gördüğün nokta (varsa; varsayım yaptıysan açıkça).`

const SHOTS = (codeReport) => `${COMMON}
GÖREV: D2'nin önce/sonra kareleri. Kod yazma, dosya değiştirme (yalnız satır dosyası ${S}/d2_shots.txt yazabilirsin).
D2 kodlayıcısının raporu (bilgi için):
${codeReport}

1. ${S}/d2_shots.txt dosyasına üç satır yaz:
--product-shot=live:a4_run_w2 tr
--product-shot=live:a4_run_w2 en
--product-shot=live:a4_eleven en
2. Önce (HEAD): ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh ${S}/h0/project-unicorn d2_before ${S}/d2_shots.txt
3. Sonra (D2): ETIKET=URUN_ARAYUZU_AJAN bash ${S}/bin/shots.sh ${S}/work/project-unicorn d2_after ${S}/d2_shots.txt
   (sırayla koş; ikisi de ekran kilidini bekler; her biri birkaç dakika sürebilir; arka planda başlatıp bitişini bekleyebilirsin).
4. results.txt satırlarını ve her PNG'nin tam yolunu dön. Her logda SCRIPT ERROR ve ^ERROR sayısını, PRODUCTSHOT satırını (row_gaps dahil) yaz.
Dönüş: ham liste.`

phase('D1 prototype')
const d1p = agent(D1, { label: 'D1 prototype+frames', phase: 'D1 prototype', model: 'sonnet', effort: 'xhigh' })

const d2p = (async () => {
  const code = await agent(D2, { label: 'D2 UK(a) code', phase: 'D2 code', model: 'sonnet', effort: 'xhigh' })
  const shots = await agent(SHOTS(code || '(rapor yok)'), { label: 'D2 frames', phase: 'D2 frames', model: 'haiku' })
  return { code, shots }
})()

const [d1, d2] = await Promise.all([d1p, d2p])
return { d1, d2 }
