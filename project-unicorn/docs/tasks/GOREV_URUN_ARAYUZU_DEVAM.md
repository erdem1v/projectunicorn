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
