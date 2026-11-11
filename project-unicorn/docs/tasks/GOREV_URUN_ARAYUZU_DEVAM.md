# Görev: Ürün > Sprint arayüzü, U2'den U8'e ve Faz D ekleri

2026-10-26 · Yazan: yardımcı yönetmen (oturum `co-director`) · Erdem bu görevi yeni bir oturumda başlatır. Aynı anda iki
oturum daha çalışır: Temizlik (`GOREV_TEMIZLIK.md`, oturum `project-unicorn-1c`) ve Olaylar (`GOREV_OLAY_UYGULAMA.md`).
**Ortak çalışmanın kuralları `docs/tasks/ORTAK_CALISMA.md`'dedir: işe başlamadan oku.** Senin etiketin URUN_ARAYUZU.

## Ne yapacaksın

`docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md`'yi U2'den U8'e uygula. Sonundaki "Erdem'in A4 cevabı ve Faz D ekleri (2026-10-26)"
bölümünün dört yeni adımı da işe dahil:
- UD2: zayıf PM eşiği kalkar;
- UD1: öneri sonraki sütunu da doldurur;
- UM: modül adları;
- UK: kart başına aşama ve yüzde.

U0, U1 ve U1s bitti: `de0182e`, `29ae999`, `c71a691`.

PRD kapalıdır: tasarım sorusu sorma. PRD'nin sessiz ya da çelişkili olduğu bir yer bulursan kodlamayı o noktada durdur ve
yardımcı yönetmene tek mesajda, numaralı liste olarak yaz. Varsayılan seçme.

Erdem'e iki şey gidecek: UM'nin ad sayfası ve UK'nin iki karesi. İkisini de yardımcı yönetmene ver; Erdem'e o götürür.

## Başlamadan oku

1. `docs/tasks/ORTAK_CALISMA.md`.
2. `docs/tasks/GOREV_URUN_ARAYUZU.md`: görevin asıl yazısı. Çalışma kuralları, commit öneki ve rapor oradadır. Oradaki iki
   bölüm geçersiz:
   - D oturumu satırları (D kapandı);
   - "kapı bende / Godot" satırları: yerine ORTAK_CALISMA geçer.
   HARITA emekli olduktan sonra (ORTAK_CALISMA §7) oradaki "HARITA" sözü `sistemler/02_urun_sprint.md`, `08_sekmeler.md` ve
   `09_arayuz_bilesen.md` demektir.
3. `docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md` baştan sona. Özellikle §13, §14, §15 ve sondaki cevap bölümleri: U0, U1, U1s ve
   2026-10-26.
4. Maket A4: https://claude.ai/artifact/Y7WL12jNTGr8s3DwtNAEU9. Yerel kopya `docs/strateji/sprint_ekrani/A4.html`.
5. `docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md` 2026-10-26 bölümü.
6. Kod haritası: `docs/kod_haritasi/README.md`, `sistemler/02_urun_sprint.md`, `08_sekmeler.md`, `09_arayuz_bilesen.md`.
7. Önceki Ürün arayüzü oturumunun araçları:
   `C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\5ad1dc82-4870-4507-b82a-591327527a0f\scratchpad\`.
   - Kare: `shots.sh`.
   - U1 ve U1s: `u1/stage_u1.sh`, `u1s/stage_u1s.sh`, `u1/merge_onto.sh`, `u1s/gate.sh`.
   - Z6 ve PLANMS: `u1/z6.sh`.
   Yöntemleri hafızadaki `urun-arayuzu-task-2026-10-23` dosyasındadır. Bu betikler ORTAK_CALISMA §3'e uyarlanmadan
   kullanılmaz:
   - özel index ve `update-ref` karşılaştırması;
   - `--force-remove`;
   - `sync_shared.sh`'in silme dalı;
   - stage listesinden `docs/HARITA.md`'nin çıkması.

## Adım tablosu

| Adım | Ne | Model (düşünme) | Süre |
|---|---|---|---|
| UD2 | Zayıf PM eşiği kalkar | Sonnet (xhigh) | 0,5 sa |
| UD1 | Öneri sonraki sütunu da doldurur | Sonnet (xhigh) | 2 sa |
| U2 | Denetim şeridi ve sol sütun; ilk kare ≤100 ms kapısı | Sonnet (xhigh) | 5 sa |
| UM | Modül ve hat adları önerisi, ardından Erdem, ardından CSV (U2 ile paralel) | Sonnet (high) | 1,5 sa |
| U3 | Orta başlık ve kapasite; N2 çeyrek hiyerarşisi | Sonnet (xhigh) | 5 sa |
| U4 | Kart listesi ve zaman ekseni; UK'nin iki karesi buradan Erdem'e | Sonnet (max) | 8 sa |
| UK | Kart başına aşama ve yüzde (Erdem'in seçimiyle) | Sonnet (xhigh) | 3 sa |
| U5 | PRD §13 | Sonnet (xhigh) | 4 sa |
| U6 | PRD §13 | Sonnet (xhigh) | 4 sa |
| U7 | PRD §13 | Sonnet (xhigh) | 5 sa |
| U8 | Görsel kabul turu, taşma satırı dahil | Haiku koşar ve çeker, Opus (high) karşılaştırır | 3 sa |

- Her kod commit'inin diff'i bir Opus (high) ajanınca incelenir. Commit başına en çok 1 inceleme ve 1 düzeltme.
- Toplam yaklaşık **41 saat**: U2–U7 31, U8 3, ekler 7.
- UM ve UK'de Erdem'i beklerken sıradaki adıma geç.

## Bitince

- Her commit'ten sonra yardımcı yönetmene tek satır: adım, sha, oyuncu ne görür.
- U8'in görsel sayfası ve `RAPOR_URUN_ARAYUZU.md`, `GOREV_URUN_ARAYUZU.md`'nin "Bitince" bölümündeki gibi hazırlanır. Raporda
  ayrıca şunlar bulunur:
  - UD1'in run-log ve bozulan söz farkı;
  - UM'nin onaylanan adları;
  - UK'nin seçilen biçimi;
  - N1 listesi: kalan, ipucuna giden ve silinen küçük metinler.

## Devir (2026-10-27)

Bu makine bir haftalığına kapanıyor; iş dizüstünde yeni bir oturumla sürer. Yeni oturum yalnız bu nota, `PRD_URUN_SPRINT_ARAYUZU.md`'ye
(her bölümün altındaki "yardımcı yönetmenin kararı" notları dahil) ve `ORTAK_CALISMA.md`'ye bakarak devam eder. Bu oturumun bütün
taşınabilir dosyaları `docs/tasks/urun_arayuzu_devir/` altındadır (`docs/tasks/` `.gitignore`'da: push'la gitmez, klasör elle taşınır).

### Son commit

`d1eb210` "Ürün arayüzü U6" (ipuçları). Push yok; push'u Erdem ya da yardımcı yönetmen yapar.

### Biten adımlar (main'de, push'suz)

UD2 `92516ba` · UD1 `25a1416` · I01 `ee40bf2` ve ek `0f1114c` · U2 `94e5056` · U3 `8c8bd65` · U4 `32cf58e` · U5 `287f6f5` · U6 `d1eb210`.
Her commit mesajı oyuncunun ne gördüğünü, dayanağı (PRD bölümü, yönetmen kararı) ve TR/EN onay bekleyen anahtarları yazar.

### Kalanlar (sırayla)

1. **UE kare turu** (kod commit'i yok, yalnız kare; yönetmenin 2026-10-27 isteği, `urun_arayuzu_devir/yapilacak/ue_todo.md`).
   Durum: **kareler bitti, Erdem'in seçimi bekleniyor.** Sayfa `docs/tasks/urun_ue/index.html` (14 kare, kırpmalar, ikon kâğıdı) ve
   https://claude.ai/artifact/XHVbFN9e5qy49eKLJyfKrw. Bulgular: sol sütun en çok 280 px'e iner (talep satırındaki uzun müşteri adı), eksende
   hafta yalnız 152 → 155 px; hissedilir genişlik kart bilgi sütunundan (312) ya da sağ sütundan (300) gelir, sınanmadı. Altı modülün ikonu
   setten seçildi (ikisi yaklaşık). (a) ve (b) iki kare; yönetmen (b) öneriyor. Uzun kart adları panoda "…" ile kesiliyor (U6'da da; U7'ye).
   Prototip bu makinede (scratchpad `wue`, `UE` ortam değişkeni; görevi `urun_ue/prototip_gorevi.md`, ölçümleri `prototip_raporu.md`).
   Erdem seçince: seçilenler PRD'ye not olarak yazılır, U6 commit'inin üstünde normal bir adım olarak kodlanır (prototip kodu taşınmaz,
   yalnız yol gösterir; `UE` bayrağı oyuna girmez).
2. **UK yaması**: Erdem seçince (yönetmenin önerisi (a); (a)'da boş yuva yer ayırmaz). `urun_arayuzu_devir/uk/uk_a.patch` ve `uk_b.patch`
   U5'e bile tam oturmuyordu; U6'nın üstüne yeniden çıkarılır. Kareler `uk/frames/`. Seçilen biçim U7'ye ya da kendi commit'ine girer.
3. **U7** (PRD §13): temizlik, fikstürlerin emekliye ayrılması, belgeler. Ek iş: `yapilacak/u7_todo.txt` (ÇEYREK sekmesinde EN kart adları kesiliyor).
4. **U8** (PRD §13): görsel kabul sayfası, her karede "taşma yok" satırı. Ek kareler: `yapilacak/u8_todo.txt` (ÇEYREK EN, geç kalan hap,
   `a4_cards_noteam` + `a4_delegate_noteam` yan yana, `a4_run_delegate_long` EN, DEVREDEN soluk tarama). U6'nın ipucu kareleri:
   `live:a4_eleven_tip` TR/EN, `a4_eleven_streak`, `a4_run_w2_bar`, `a4_fix_tip`, `a4_meet_tip`, `a4_next_tip`, `a4_pm_tip` (her biri `<kök>`
   ve `<kök>_tip` iki kare). U8 sayfasında U6 karar 6 satırı "yardımcı yönetmen kararı" olarak durur (Erdem bakar).
5. **Mutlak PLANMS**: U6'nın ilk kare ölçüsü makine yükündeyken göreli alındı (değişiklik öncesiyle aynı bant). U8'den önce sessiz ölçüm
   (`bin/quiet_planms2.sh`; U5'te HEAD 78 ms, U2 ağacı 95 ms, kapı ≤ 100 ms).
6. **RAPOR_URUN_ARAYUZU.md**: `GOREV_URUN_ARAYUZU.md`'nin "Bitince"si ve bu dosyanın "Bitince"si. Kaynaklar: `urun_arayuzu_devir/rapor_notlari/u3–u6.md`
   (kararlar, inceleme bulguları, N1 listeleri, PLANMS sayıları), `ud1/runlog2.txt` ve `ud1/msg.txt` (UD1'in run-log'u ve bozulan söz farkı 1→0),
   UM'nin onaylı adları, UK'nin seçilen biçimi, TR/EN onay listeleri (U4 8, U5 19, U6 37 anahtar; her commit mesajının sonunda).

### Açık kararlar ve kimde

- **UK** (kart başına aşama yüzdesi): Erdem'de, yönetmen götürdü.
- **UM** (modül ve hat adları): Erdem'de, sayfa https://claude.ai/artifact/GyGe7SztQx3WEQbcViTNF3 (3 soru); onay gelince yalnız CSV değerleri,
  ayrı commit. Taslak ve sayfanın kaynağı `urun_arayuzu_devir/um/`.
- **UE**: Erdem'de (yönetmen iki kare ve önerisiyle götürür): sol sütunun daralması, modül kısaltması yerine ikon, "planda"/"gelecek çeyrek"
  (a) ya da (b) (yönetmen (b) öneriyor).
- **PRODUCT_WAIT_PRODUCT** ("Bekliyor: ürün yöneticisi ya da kurucu"): yönetmen Erdem'e kartın Ar-Ge değil "{n} kullanıcıyla görüş" olduğunu
  açıklıyor; cevaba göre metin değişebilir.
- **TR/EN metin onayları**: commit mesajlarındaki listeler Erdem'de.
- **Karar kuralı** (yönetmen, 2026-10-27): oyuncunun gördüğü yerleşim ve metin seçimleri iki kare ve yönetmenin önerisiyle Erdem'e gider;
  teknik ve doğruluk kararları yönetmende. PRD sessiz ya da çelişkiliyse kodlama o noktada durur, yönetmene numaralı liste gider.

### Bu makineye bağlı yollar (dizüstünde yok)

- Scratchpad: `C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\cb69ca60-0d91-4669-bf47-f4c28dfeaca0\scratchpad`
  (kopyalar `w8` = U6, `wue` = UE prototipi; kapı ağaçları `m_*`, `g_*`; kareler `shots_*`; Z6 referansı `z6_b6` = 287f6f5'in koşusu).
  Dizüstünde yeniden üretilir; buradaki hiçbir ağaç commit'e girmeyi beklemiyor.
- APPDATA: her Godot koşusu `scratchpad/appdata_<ad>` (`env.sh`'deki `gd`); Erdem'in varsayılan APPDATA'sı hiç kullanılmadı.
- Kilit klasörü: `C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\kilit` (`kapi`, `ekran`, `sessiz`). Bu oturumun
  kilidi kalmadı.
- Godot: `C:\Users\erdem\Desktop\Godot_v4.6.2-stable_win64_console.exe`.
- Betikler: `urun_arayuzu_devir/bin/` (kapı: `land.sh` → `merge.sh`, `gate_copy.sh`, `theme_regen.sh`, `smoke.sh`, `commit.sh`; kare: `shots.sh`;
  `z6.sh`, `export.sh`, `regen.sh`, `quiet_planms2.sh`). `env.sh`'nin ilk altı satırı (S, R, K, GODOT, APPDATA, UDIR) bu makinenin yollarıdır.
  Koşan betik düzenlenmez: her koşuda `cp land.sh land_run_<adım>.sh`.

### Dizüstünde ilk üç komut

1. `git -C "<repo>" log --oneline -3`: en üstte `d1eb210 Ürün arayüzü U6…` görünmeli; `docs/tasks/urun_arayuzu_devir/` taşınmış olmalı.
2. `mkdir -p "<scratchpad>/bin" && cp "<repo>/project-unicorn/docs/tasks/urun_arayuzu_devir/bin/"* "<scratchpad>/bin/"`, sonra `env.sh`'de
   S, R, K, GODOT, APPDATA ve UDIR'i dizüstünün yollarına çevir.
3. `bash "<scratchpad>/bin/export.sh" w9 HEAD && . "<scratchpad>/bin/env.sh" && gd imp9 "<scratchpad>/w9/project-unicorn" --headless --path . --import
   && bash "<scratchpad>/bin/smoke.sh" "<scratchpad>/w9/project-unicorn" ilk all_scripts_load`: temiz kopya, import, ilk smoke.

## Masaüstüne dönüş (2026-11-02)

Yazan: URUN_ARAYUZU oturumu (Mac dizüstü). Oturum kimliği `15e4f65e-5e2f-4650-8a09-3461c49bb834`; masaüstünde
`claude --resume 15e4f65e-5e2f-4650-8a09-3461c49bb834` ile sürer. Ana kayıt `15e4f65e-5e2f-4650-8a09-3461c49bb834.jsonl`'dır. Aynı adlı klasörde
şunlar durur: alt ajan kayıtları (`subagents/workflows/*/agent-*.jsonl`; kodu yazan ajanların düzenlemeleri burada), uzun çıktılar (`tool-results/`) ve
kurtarma betikleri (`kurtarma/`). Kayıt ile klasör birlikte taşınmalı.

### Ne oldu

- Commit'li tek adım D2: `eebf909 Ürün arayüzü UK:`. D0 ve D1 zaten commit istemiyordu. D3, D5, D4a ve D4b kopyalarda hazırdı ama commit'lenmedi:
  2026-10-28 20:31'de iCloud `.git` paketini boşalttı, yönetmen git yazımını durdurdu.
- 2026-11-02 01:20–01:40 arası macOS'un /tmp temizliği scratchpad'deki her dosyayı sildi. Bu temizlik 3 günden uzun açılmamış dosyaları siler.
  Giden: D3, D5, D4a ve D4b'nin çalışma kopyaları, Mac'e çevrilmiş `bin/`, notlar, U8 kaynakları. Git izni 2026-11-02'de geldiğinde kopyalar yoktu.
  Paylaşılan ağaçta ve git'te kayıp yok.
- Yönetmen kararı (2026-11-02): Mac'te yeniden kurulmaz. Masaüstünde bu oturum sürdürülür ve adımlar aşağıdaki tarifle yeniden kurulur.
- `main` HEAD şu an `b263946` (OLAYLAR, ikon adayları; eebf909'dan sonra). Diff'ler eebf909'a göredir, 3 yollu birleştirmeyle uygulanır.

### Kurtarılanlar: `docs/tasks/urun_arayuzu_devir/masaustu_2026-11-02/`

- `d3_msg.txt`, `d5_msg.txt`, `d4a_msg.txt`, `d4b_msg.txt`: hazır commit mesajları. Her birinde oyuncu ne görür, teknik, dayanak ve TR/EN onay listesi var.
- Opus incelemesine giden diff'ler. Hepsi düzeltme turundan önceki hâldir:
  - `d3_inceleme.diff`: eebf909 → D3, 7 dosya, 269 satır.
  - `d4a_inceleme.diff`: eebf909 → D4a, 14 dosya, 989 satır. Ayrıca `product_fixtures.gd` ve `.uid` silinir; ISLER.md düzeltme turunda eklendi.
  - `d4b_inceleme.diff`: D3 + D4a'nın ilk hâli → D4b, 12 dosya, 720 satır.
- `komutlar_d3.txt`, `komutlar_d5.txt`, `komutlar_d4a.txt`, `komutlar_d4b.txt`, `komutlar_birlesik.txt`: kopyayı değiştiren komutlar, kayıttaki sırasıyla ve
  olduğu gibi (python düzenlemeleri, cp, perl). Her birinin başında `#<sıra> <zaman> <kayıt>` var. Düzeltme turları ve birleştirmeler burada.
- `oturum_notlari.md`: oturumun notları, kayıttaki eklemelerden yeniden derlendi.
- U8 sayfası `docs/tasks/dizustu/raporlar/u8_gorsel_kabul/` altında (index.html ve `img/` altında 98 kare).
  Yayındaki hâli: https://claude.ai/artifact/Wqm2PqBZQXcuGjJzyotNvz

### Adımlar

**D2 UK(a): commit'li, `eebf909`.**
- Değişenler:
  - `board_row.gd`: durum yuvası ve `_wraps`/`_fit` ile satır büyümesi (düzeltme metni kesilmez, sarar).
  - `sprint_board.gd`: `sort_children` → `_update_more`.
  - strings.csv: `PRODUCT_STAGE_PCT` "{stage} {pct}".
  - 08_sekmeler.md.
- Kapılar: birleşik ağaç (87e06d68 + D2) import ve ısınma temiz. Smoke 56/56 (54 sprint_/product_, loc_csv_integrity, all_scripts_load). Lint PASS,
  loc_residue 0. Z6: h1 = h0, 7/7.
- Opus: iki tur. Biri kabul edilmedi: geç koruma kaldı. Satır büyümesi yönetmenin onayıyla D2'ye girdi; dar ikinci inceleme tek düzeltme turu sayıldı.

**D3 UE1 (E1, Ürün penceresi genişler): commit'lenmedi.**
- `window_layer.gd`: `SPECS["product"]` 1424×928 → 1688×928. Hesap: 1920 − ray 184 − 2 × EDGE 24; pencere x 208–1896. `_fit` ve Piyasa (1424) değişmez.
- `sprint_board.gd`:
  - Eksen `model.axis`'tir, en az `D_W_TIMELINE`. Yeni `_measure_axis(holder)` ve `axis_wanted(width)` sinyali.
  - Hafta etiketi, ızgara, erken kapanış, şimdiki an ve `layers` aynı ekseni okur.
- `board_row.gd` ekseni `ctx.axis`'ten okur. `sprint_panel.gd` `axis_wanted`'ı iletir.
- `product_tab.gd`: `static var _axis: float = UiTokens.D_W_TIMELINE` tutulur, `_on_axis` → `_queue_rebuild`, `m.axis` kurulur.
- 08_sekmeler.md (Dikkat maddesi) ve 09_arayuz_bilesen.md. `ui_tokens.gd`'ye dokunulmadı.
- Sayılar:
  - 1920'de pano gövdesi 730 → 994 px, eksen 396 → 674 px, hafta 152,31 → 259,23 px.
  - 1,25 ölçekte pencere 1424, eksen 410 px, hafta 157,69 px.
  - Dar çubuk (ikon ve sayı ikisi de düşer): a4_eleven 6 → 4, a4_two_pm 3 → 2, a4_run_w2 4 → 1.
  - Kapasite olukları orta sütunla uzar (Geliştirme ~1050 → ~1305 px).
- Kapılar:
  - Parse temiz.
  - Smoke 2/2: all_scripts_load, sprint_timeline_matches_play_out. Düzeltme turundan sonra yeniden 2/2.
  - Altı kare (live:a4_two_pm TR, a4_eleven TR/EN; üçü 1,25'te): rc=0, row_gaps=0.
  - MCP: `WindowLayer._area()` = (208,24) 1688×928, pencerenin `get_rect()`'i aynı. Taşma yok, kesilme yok.
- Opus: 7 bulgu.
  - 6'sı uygulandı (komutlar_d3 #1067–#1069):
    - `static _axis`: ilk açılıştan sonra pencere tek kurulumla açılır.
    - window_layer yorumunda satır sayısı korundu (SPECS :38'de kaldı).
    - Yorum sadeleşti, 08'e Dikkat maddesi girdi, satır atıfları düzeldi.
  - 1'i reddedildi: `ui_tokens.gd`'ye D_W_TIMELINE yorumu. O dosyadaki her değişiklik THEME_STAMP artışı ve tema üretimi ister.
  - Not: açılıştaki iki kurulum aynı karede biter (CallQueue aynı flush'ta işler); oyuncu dar ekseni görmez.

**D5 UM1: commit'lenmedi.**
- Yalnız strings.csv, iki kayıt bayt aralığıyla değişti:
  - `PROD_LINE_HIDDEN_SELF_SERVE`: "Kendi Kendine Servis" → "Yardım Merkezi" / "Help Center".
  - `PROD_RND_NODE_TEST_AUTOMATION_UNLOCK`: "Yardım Merkezi adında yeni bir özellik hattı." / "A new feature line called Help Center.".
- 3277 anahtar korunur, BOM ve CR yok. Adı yer tutucuyla alan 26 anahtar yeni adla TR/EN okundu, ek uyumu bozulmadı (liste oturum notlarında).
- Kapılar: glyph_audit 0, loc_residue 0, loc_csv_integrity + all_scripts_load 2/2. Keşif maili MCP'de açılıp okundu; `--rnd-shot=discovery` maili açmıyor.
- TR/EN onay bekliyor: bu iki anahtar.

**D4a U7 (statik fikstür emekli, ölü alan cümlesi kodu): commit'lenmedi.**
- Silinenler:
  - Fikstür: `scripts/debug/product_fixtures.gd` (452 satır) ve `.uid`.
  - Fikstür kolları: `ProductTab.set_source`, `PRODUCT_FIXTURES`, `_product_source`, `debug_product_apply/act`.
  - `--product-shot` fikstür türleri: c1..c5, cards, flow, edge:*. `live:` olmayan tür hata basıp 1 ile çıkar.
  - Kod: `ProductQuality.area_row`, `WORD_TONES`, `serves`; `SprintCatalog.area_sentence`, `_standing`, `_recent_hit`; sprint.json `research_sentence_weeks`.
  - `_over_capacity` silinmedi, `area_alert`'e katıldı.
- Silinen 18 CSV anahtarı:
  - `PRODUCT_AREA_RIVAL`, `PRODUCT_AREA_OVER_CAPACITY`, `PRODUCT_AREA_REVENUE_NONE/WEAK/ENOUGH/STRONG`, `PRODUCT_AUDIENCE_ENOUGH/OUTGROWN`.
  - `PRODUCT_STAR_NONE/SKIPPED/SERVES/TOP`.
  - `PRODUCT_RESEARCH_VOICE_CORE/ONBOARDING/GROWTH/INTEGRATIONS/TRUST/REVENUE`.
- Değişenler:
  - `game_shell.gd`: `_on_sprint_closed` sayfayı `has_method(&"open_area")` ile tanır; açık Ürün sayfası sökülmez.
  - `main.gd`: `_run_product_shot` yalnız `live:` türlerini kurar; saat karesinin "released" kolu sayfayı kendisi kurar.
  - `endgame_smoke.gd`: `product_area_row` → `product_area_word` (`ProductQuality.word`'ün 13 kademesi). fit_star_context ve
    product_bug_rows_read_the_store'dan silinen koda değen assert'ler çıktı.
  - Ayrıca: `product_tab.gd`, `product_model.gd` (yorum), `product_quality.gd`, `sprint_catalog.gd`, `sprint_system.gd` (yorum), sprint.json, strings.csv,
    CLAUDE.md §12, 02/08/10 sistem sayfaları, `docs/ACIK_ISLER/ISLER.md`.
- `card_effect` kaldı (02'deki karar). Silinen her ad için grep 0.
- `live:` karşılığı olmayan 7 durum ISLER.md'ye yazıldı: release_fix, release_reviews, no_release, history_empty, cap_zero, approved, goal_menu.
- Kapılar:
  - Smoke 23/23, loc_residue 0.
  - Düzeltme turundan sonra smoke 13/13, sonra incident_* ve infra_capacity vakaları.
  - Commit kapısı için 74 vakalık liste hazırdı: bütün sprint_/product_ vakaları + 20 ad (komutlar_d4a'da `d4a_cases`).
- Opus: 10 bulgu.
  - 7'si tek düzeltme turunda uygulandı. Örnekler: `_over_capacity` `area_alert`'e katıldı; product_area_word'deki küçük kitleli B2C bloğu silindi.
  - 3'ü reddedildi:
    - ACIK_KARARLAR (37): açık maddeye dokunulmaz.
    - `localization_glossary.md:85`: bağlayıcı sözlük, sahibine not.
    - Üretilmiş kod haritası: commit anında üretilir.
- D3 ile çakışır (`product_tab.gd`, 08). D3'ün üstündeki `product_tab.gd` atıfları: `_ready` :54, sinyaller :117-122, `_rebuild` :139, live çağrısı :143,
  `open_area` :275, `_on_candidate_hover` :283, `_on_action` :288, `_act` :300, `_queue_rebuild` :333, `_hold_clock` :340, `HOLD` :19.

**D4b E2 kesme taraması (U7, "Ürün arayüzü U7:" ikinci commit): commit'lenmedi.**
- Taban D3 + D4a'nın ilk hâlidir. 12 dosya: board_row, product_model, area_panel, sprint_card, sprint_next, quarter_view, sprint_panel, sprint_ui_shared,
  strings.csv, 02/08/09.
- Kalkan kesmeler:
  - Pano kart adı: "…" ve max_lines kalktı; ad kelime sınırında sarar, satır `_wraps`/`_fit` ile büyür.
  - Düzeltme kartı satırı ve sol sütundaki aday düzeltme kartı tam metni yazar, en büyük hesap dahil. `fix_full` ve `bugs_text`'in `with_top`'u silindi.
  - Sonraki sprint kutusunda ad kesilmez. FaceCell "+{n}"i gizlemez ve ilk yüzü kırpmaz; `clip_contents` kalktı.
  - ÇEYREK mini kartında ad kendi satırında sarar. ÇEYREK'in sağ tarafı ve sürüm notunun orta sütunu dikey kayar; bayrak çipi sarar.
  - Aday damgası "S{n}" → "Sprint {n}" (`PRODUCT_TAG_SPRINT`); `PRODUCT_STAMP` silindi.
- Bilerek kalanlar (karar): modül kısa adı; dar çubukta düşen ikon, sayı ve yüzler; eksen sonundaki sprint dışı pay; "+{n}" biçimleri; grafik kırpmaları.
- Yönetmenin dört D4 kararı (2026-10-28):
  1. Dar çubukta düşen ikon/sayı ve yüzler D4'te değişmez; D7'de (a) bugünkü / (b) sayı çubuğun sağında karar bölümü (öneri b).
  2. Modülün kısa adı kalır (UM'de tasarlanmış ad).
  3. Düzeltme kartının satırı tam metni yazar, en büyük hesap dahil, sarar.
  4. "S{n}" → "Sprint {n}"; aday düzeltme kartı 3'ü izler. Yeni metinler TR/EN onay bekler.
- Düz ipucu (TooltipLabel) sarmaz ama ekranda içeri itilir. Ölçülen en uzun gerçek ipucu 778 px; ~1900 px üstü kesilir.
- Kapılar:
  - Parse temiz, loc_residue 0 (3257 anahtar), glyph_audit 0.
  - Smoke 13/13: all_scripts_load, loc_csv_integrity, loc_product_derived_keys, sprint_timeline_matches_play_out, product_bug_rows_read_the_store,
    clock_resumes_only_by_player, sprint_fix_close_matches_note, line_impact_names_the_accounts, paper_card_trim, save_v14_history_becomes_releases,
    sprint_away_lists_who_cannot_work, sprint_follow_card_cannot_be_removed, sprint_lead_row_until_plan_changes.
  - Düzeltme turundan sonra 3/3.
  - MCP a4_run_end EN: düzeltme satırı sarar, uzun ad iki satır. Başsız yoklamada 5 kişide 1 yüz ve "+4". Taşma yok, kesilme yok.
  - Pano, ÇEYREK ve sürüm notu arayüzünü hiçbir smoke çizmez; kanıt karelerdir.
- Opus: 8 bulgu.
  - 6'sı uygulandı:
    - Yüzsüz FaceCell en az genişlik almaz (`if _faces.is_empty(): return`).
    - ÇEYREK sol sütun kaydırması `_left` ile korunur.
    - İki yorum düzeldi, 08 atıfları güncellendi.
  - 2'si reddedildi:
    - `_two`'nun kaldırılması: üç token ve tema damgası ister; 22 karakteri aşan tek satırlık adların satırı kısalır, bu E2 dışı görünür değişiklik.
    - Üretilmiş kod haritası: commit anında üretilir.
- TR/EN onay bekliyor (anahtar değişmedi, ekranda yeni yerde):
  - `PRODUCT_TAG_SPRINT`: aday damgası.
  - `PRODUCT_FX_TOP`: pano ve aday düzeltme satırı.

**D6: kod yok.** Erdem'in E4/E5 seçimini bekliyor.

**D7 U8: bitti.**
- Sayfa yayında ve repoda.
- 56 kare (D3+D4a+D4b+D5 birleşimi), 25 kırpma, maket f01–f24.
- Kapılar: satır içi JS derlenir; başsız Chrome 375/414/1280 px'te yatay taşma yok; JS hatası yok.

**D8: yapılmadı.**
- PLANMS: D0 tabanı Mac'te 50 kişi 5 koşu, medyan 61,4 ms; kapı ≤ 67,5 ms. Masaüstünde taban yeniden ölçülür.
- `RAPOR_URUN_ARAYUZU.md`: oturum_notlari.md, bu not, `rapor_notlari/` (u3–u6, ud1) ve U8 sayfasından yazılır.

### Bekleyen Erdem kararları

1. E5 biçimi (D1 kareleri, U8'de e5_tr/e5_en):
   - Biçim 1 ya da biçim 2; öneri biçim 2. Biçim 2 seçilirse tarih planlanmamış satırlarda da altta durur (yönetmen).
   - Met satırı 2 hafta görünür; sıra ve katlama önerime göre; "(a) Bu sprintte".
   - Yönetmen kararıyla E5 commit'ine şunlar da girer: (b) pano yuva çipi aynı boyda ve büyük harfle; (c) "bu çeyrek" vurgu renginde.
2. E4 ikonlar:
   - Adaylar `docs/tasks/dizustu/raporlar/ikon_adaylari/svg/<modül>_<küme>.svg` (OLAYLAR, b263946).
   - Seçilince iki harfli işaretler kalkar ve `PRODUCT_AREA_*_MONO`'nun öbür okuyucuları grep'lenir. Commit: "Ürün arayüzü UE2:".
3. Dar aşama çubuğu:
   - (a) bugünkü: ikon ve sayı düşer, bilgi ipucundadır. (b) sayı çubuğun hemen sağında, eksenin içinde yazılır. Yönetmen (b)'yi öneriyor.
   - E1'den sonra 1920'de dar kalan çubuk: a4_eleven'da 4, a4_two_pm'de 2.
   - Prototip: `stage_paint` ve `bar.clip_contents = false` (kayıtta D7 kare ajanı, `wf_4818d0e1-b7a`, kopya `wproto_b`).
4. "+{n}" biçimleri, beş yer (U8'de kareli). E2'ye göre kesme değil, tasarım seçimi; seçilene dek yerlerinde kalırlar:
   - Sonraki sprint DEVREDEN: beşten çoksa en büyük dört ve "+{n} kart".
   - Sol sütun: ilk üç talep ve "+{n} talep".
   - Kapasite: aşamada 9'dan çok kişi "×{n}" yıldız kümesi.
   - Sprint başlığı: en çok 3 yüz ve toplam.
   - Sonraki kutuda önden çalışanların yüz dizisi "+{n}".
5. UM'nin öbür satırları ve üç sorusu Erdem'de; bu turda yalnız UM1 yapıldı.
6. TR/EN onayları:
   - D5: `PROD_LINE_HIDDEN_SELF_SERVE`, `PROD_RND_NODE_TEST_AUTOMATION_UNLOCK`.
   - D4b: `PRODUCT_TAG_SPRINT`, `PRODUCT_FX_TOP`.
7. Yönetmenin görünür kararları (U3–U6, D4): liste U8 sayfasının sonunda. Erdem her birini bozabilir.

### Masaüstünde yeniden kurma

- Taban güncel HEAD'dir (şu an `b263946`). Sıra D3 → D5 → D4a → D4b. Her adım ayrı commit; yöntem ORTAK §3 (özel index, CAS).
- Her adımda yeniden kurulan diff, incelenen diff ile düzeltme turunun toplamıyla karşılaştırılır. Commit öncesi inceleme kuralı için yeni bulgu turu
  açılmaz, dar bir Opus incelemesi bu eşliği doğrular.

1. **D3**
   - eebf909'dan export al; `git apply d3_inceleme.diff`.
   - komutlar_d3 #1067–#1069'teki düzeltmeleri uygula. Sonra yeni HEAD'e 3 yollu birleştir.
   - Kapılar: import, all_scripts_load, sprint_timeline_matches_play_out; altı kare ve ölçü (yukarıdaki sayılar tutmalı).
   - Mesaj: `d3_msg.txt`.
2. **D5**
   - İki CSV değerini bayt aralığıyla değiştir (değerler yukarıda ve `d5_msg.txt`'de). Dosya yeniden yazılmaz.
   - Kapılar: loc_csv_integrity, all_scripts_load, glyph_audit, loc_residue.
3. **D4a**
   - `d4a_inceleme.diff`'i uygula; `product_fixtures.gd` ve `.uid`'i sil.
   - komutlar_d4a'daki düzeltme turunu uygula (`wf_e0c8bea3-6a6` ajanı, beş madde); ISLER.md maddesini ekle; 02'de :296'daki satırı kır.
   - D3'ün üstüne birleştirince `product_tab.gd` ve 08 çakışır; atıflar yukarıda.
   - Kapılar: 74 vaka, loc_residue, silinen her ad için grep 0.
4. **D4b**
   - `d4b_inceleme.diff`'i D3 + D4a'nın ilk hâli üstüne uygula, sonra D4a düzeltmesiyle birleştir.
   - Dikkat: `product_tab.gd` ve 08'de yanlış tabanla birleştirme D3 kodunu düşürür. Mac'te bu bir kez oldu, D4b ağacından geri alındı.
   - komutlar_d4b'deki düzeltme turunu uygula (`wf_ec3e5bec-f3f` ajanı).
   - Kapılar: 74 vaka + paper_card_trim + save_v14_history_becomes_releases (76); kareler.
5. **D8**
   - Sessiz PLANMS: önce OLAYLAR'a yaz. Taban masaüstünde ölçülür; son HEAD medyanı ≤ taban +%10.
   - RAPOR_URUN_ARAYUZU.md'yi yaz; son mesaj "hazır, son commit <sha>".

### Windows'ta geçmeyen Mac'e özgü şeyler

- `override.cfg` (`[display]`, `window/size/mode=0`): Retina'da kareyi 1920×1080'e sabitler. Yalnız kopyalara yazıldı, commit'e girmez. Windows'ta
  gerekmez, yine de kare ölçüsünü denetle.
- `docs/tasks/dizustu/mac_env.sh` ve yerel kopyası: HOME yalıtımı, vm_stat bellek eşiği (1000 MB), bellek baskısı, `pgrep -x Godot`, coreutils GNU
  timeout. Windows'ta `urun_arayuzu_devir/bin/env.sh`'nin APPDATA yalıtımı geçerli.
- Mac'e çevrilmiş `bin/` (shots2.sh, mcp_copy.sh ve yardımcıları `mcp_fix_text`/`mcp_hour`/`mcp_open_mail`, land.sh'nin ETIKET süzgeci) silindi.
  Asıl `urun_arayuzu_devir/bin/` Windows içindir; ekler gerekirse kayıttan alınır.
- Kilit klasörü `project steam/.kilit` Mac'e özgüdür; Windows'ta eski kilit yolu geçerli.
- U8 üreticisi (`build_page.py`) ve maket kare betikleri (Node + başsız Chrome) silindi. Sayfanın kendisi `u8_gorsel_kabul/`'de.
- D0 sayıları:
  - PLANMS 61,4 ms Mac'e özgüdür, masaüstünde yeniden ölçülür.
  - Z6 f06bed6 7/7 (1:335 3:414 6:475 12:120 25:290 50:231 3_b2b:333) deterministiktir, masaüstünde de aynı çıkmalı.

### Ders

- Claude Code'un scratchpad'i macOS'ta `/private/tmp` altındadır ve oradaki dosyalar 3 gün dokunulmazsa silinir. Günü aşan işte çalışma kopyası
  kalıcı bir klasörde durmalı; masaüstünde scratchpad yerine repo dışında kalıcı bir klasör kullanılmalı (ör. `C:\Users\erdem\pu_calisma\`).
- Biten adım beklerken commit'lenemiyorsa patch olarak hemen repoya konmalı.
- iCloud'daki repoda (Masaüstü eşitlemesi + depolamayı optimize et) `.git` paketi boşaltılınca git okumaları takılır. Masaüstünde iCloud yok.
