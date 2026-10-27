# Üç oturumun ortak çalışma kuralları

2026-10-26 · Yazan: yardımcı yönetmen (oturum `co-director`) · Üç görev aynı klasörde, aynı git deposunda ve aynı makinede
**aynı anda** koşar:
- TEMIZLIK (`GOREV_TEMIZLIK.md`, oturum `project-unicorn-1c`);
- URUN_ARAYUZU (`GOREV_URUN_ARAYUZU_DEVAM.md`);
- OLAYLAR (`GOREV_OLAY_UYGULAMA.md`).

Bu dosya üç görev yazısının ortak çalışma bölümlerinin yerine geçer; çelişirse bu dosya geçerlidir. Kurallar bir Opus
incelemesinin bulduğu yarışlardan çıktı: ortak index'e giren yabancı silmeler, kaldırılamayan kilit, üretilmiş dosya
çakışması, ezilen kayıt yuvaları.

## 1. Adresler

- Başlarken `ListAgents` koş. Öbür iki oturuma ve yardımcı yönetmene (`co-director`) tek satır yaz. Satırın başında
  etiketin olsun: TEMIZLIK, URUN_ARAYUZU ya da OLAYLAR.
- Bir adresi bilmiyorsan yardımcı yönetmene sor. Adresleri raporunun başına yaz.
- Mesajlar bilgi içindir. Sıra ve dışlama kilitlerle (§4) sağlanır.

## 2. Sahiplik

| Sahip | Dosyalar |
|---|---|
| URUN_ARAYUZU | `scripts/systems/sprint_system.gd`, `sprint_catalog.gd`, `scripts/tabs/product/product_model.gd`, `scripts/tabs/product_tab.gd`, `scripts/tabs/product/**`, `scripts/theme/**`, `themes/**`, `assets/fonts/**` |
| OLAYLAR | `scripts/events/**`, `data/events/**`, `docs/content/events_draft/**` |
| Ortak (sahipsiz) | geri kalan her şey: `main.gd`, `endgame_smoke.gd`, `run_probe.gd`, `sprint_probe.gd`, `strings.csv`, `CLAUDE.md`, `game_state.gd`, `save_manager.gd`, `docs/kod_haritasi/sistemler/*.md`, öbür sistemler |

**Sahip kendi dosyasını serbestçe değiştirir.**

**Ortak dosyaya** herkes küçük hunk'la yazar ve commit anında birleştirir (§3); haber vermek gerekmez.

**Başkasının sahipli dosyasına** üç adımla dokunulur:
1. önce sahibine tek mesaj;
2. küçük ve ayrı hunk;
3. commit anında birleştirme.

**Dosyaya özel kurallar.**
- OLAYLAR `sprint_system.gd`'ye yalnız yeni public işlev ekler, var olan gövdeye dokunmaz. Bir hamle var olan bir gövdeyi
  değiştirmeyi gerektiriyorsa (ör. `_assign`) değişikliği URUN_ARAYUZU'ndan ister, o yazar.
- TEMIZLIK sahipli alanlarda ölü kod, CSV anahtarı ya da asset silmez. Bu alanlardaki adaylar raporunda "sahibi bitince"
  listesine yazılır ve sahibine verilir. İstisnalar adıyla sayılır:
  - C1 (`sprint_system.gd`);
  - A7, B1, B2 (olay motoru);
  - `Chrome*` tema varyasyonları.
  Bu istisnalarda da üç adım geçerlidir.
- TEMIZLIK sahipsiz alanda silmeden önce aday listesini öbür ikisine gönderir: "kullandığınız var mı?" 30 dakika içinde cevap
  gelmezse aday silinmez, sona kalır.
- TEMIZLIK'in C8 maddesi (`main.gd` fikstür blokları) URUN_ARAYUZU'nun U7 commit'inden sonra yapılır. C4, C5, C7 ve C9 şimdi
  yapılabilir.

## 3. Kod kopyası ve commit

**Kod yalnız kendi kopyanda yazılır.**
- Kopya: `git archive HEAD` dışa aktarımı ve paylaşılan ağacın `.godot/` kopyası.
- Kopyada ilk iş `--headless --import`, sonra bir ısınma koşusu, sonra kapılar (hafızada `godot-import-cache-gotchas`).
- Paylaşılan ağaçta kod değiştirilmez, Godot koşulmaz, `--import` hiç koşulmaz.

**Paylaşılan ağaca ve ortak index'e yalnız kapı kilidi sendeyken (§4) dokunulur.**
- Kapı dışında `git add`, `git rm`, `git mv` yoktur. Silme de kendi kopyanda yapılır.
- Hiçbir zaman şunlar yok:
  - `git add -A`, `git add .`;
  - `git commit -a`, düz `git commit`;
  - `git reset` (aşağıdaki tek istisna dışında), `git restore`, `git stash`, `git clean`;
  - `git checkout -- <yol>`, `git gc --prune=now`.

**Commit özel index'le kurulur.** Ortak index commit'e hiç girmez; başkasının staged değişikliği böylece commit'ine
sızamaz. Sıra:

1. Kapı kilidini al (§4).
2. **Birleşik ağaç:**
   - Yeni HEAD'in taze `git archive` dışa aktarımı alınır, kendi değişikliklerin üç yollu birleştirmeyle üstüne konur.
   - Taban, kopyanın tabanıdır. Yöntem: `5ad1dc82…/scratchpad/u1/merge_onto.sh`.
   - Kendi silmelerin de bu ağaca uygulanır.
   - `git merge-file` 0 dışında dönerse çakışma elle, iki tarafı da koruyarak çözülür; `--ours` ya da `--theirs` alınmaz.
     Dosya sahipliyse sahibine sorulur.
3. **Üretilmiş dosyalar birleştirmeye girmez ve elle düzenlenmez.** Liste:
   - `docs/kod_haritasi/DIZIN.md`, `SEMBOLLER.tsv`, `KALITE.md`;
   - `docs/EVENT_SIGNAL_MANIFEST.md`;
   - `docs/content/events_draft/_vocabulary.md` (yalnız OLAYLAR üretir);
   - `themes/*.tres`, `assets/fonts/variations/*.tres`.
   Bunlar birleşik ağaçta yeniden üretilir:
   - kod haritası: `GIT_DIR=<repo>/.git python -I tools/kod_haritasi/uret.py`;
   - manifest: `python tools/gen_signal_manifest.py`;
   - temalar: `-s res://scripts/theme/build_theme.gd`, ardından `theme_check`.
   `build_theme.gd` ya da `ui_tokens.gd` değişen commit'te `THEME_STAMP` HEAD'deki değerin bir fazlası olur; kendi
   kopyandaki değer esas alınmaz.
4. **Kapılar:** birleşik ağaçta `--headless --import` ve dokunulan sistemin smoke'u, kendi APPDATA'nla (§5). Kapı
   içinde yalnız headless koşu yapılır. Görsel kabul ve ekranlı koşular kapıdan **önce** biter.
5. **Özel index:**
   ```
   export GIT_INDEX_FILE=<scratchpad>/idx
   git read-tree HEAD
   ```
   - Değişen ve eklenen her yol: `git hash-object -w --path=<yol> <dosya>` ve `git update-index --add --cacheinfo`.
   - Silinen her yol: `git update-index --force-remove <yol>`.
   - Doğrulama 1: `git diff --cached --name-only HEAD` senin yol listenle bire bir aynı.
   - Doğrulama 2: `git checkout-index -a --prefix=<tmp>/` birleşik ağaçla `diff -r` eşit (hafızada `partial-staging-shared-tree`).
6. **Commit, karşılaştırmalı:**
   ```
   tree=$(git write-tree)
   new=$(git commit-tree $tree -p <eski HEAD> -F <mesaj>)
   git update-ref refs/heads/main $new <eski HEAD>
   unset GIT_INDEX_FILE
   ```
   `update-ref` HEAD kıpırdadıysa reddeder: 2. adıma dön.
7. **Paylaşılan ağacı ve ortak index'i senkronla, yalnız kendi yolların için:**
   - Ortak index: `git reset -q -- <kendi yolların>`. `git reset`'in tek izinli kullanımı budur.
   - Değişen yollar yeni HEAD'den yazılır.
   - Silinen yol paylaşılan ağaçtan yalnız dosya eski HEAD'deki blob'a eşitse silinir. `sync_shared.sh` bu silme dalı
     eklenmeden kullanılmaz.
8. Kapıyı bırak, öbür ikisine "bitti <sha>" yaz. Kopyanın yeni tabanı yeni HEAD'dir.

**Ortak index'te ya da paylaşılan ağaçta tanımadığın değişiklik** başkasının açık işidir.
- Dokunma, commit'e alma, unstage etme.
- Üç oturuma tek mesajla "kimin?" diye sor ve o arada sıradaki işe geç.
- Bilinen kirli dosyalar commit'lenmez:
  - `docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md` (yardımcı yönetmen);
  - `docs/tasks/faz_cde/d_taslak/ADIM_TABLOSU_D_v2.md` (D);
  - `project.godot` (editörün satır sırası).

## 4. Kilitler

Kilit klasörleri burada (PowerShell'de aynı yol ters bölüyle):
`K=/c/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/kilit`

`C:\` kökü kullanılmaz: orada `rmdir`'i güvenlik denetimi reddeder. Git Bash'te `mkdir C:\x` de klasörü bulunduğun yerde açar.

| Kilit | Ne için |
|---|---|
| `kapi` | §3'ün 1–8. adımları |
| `ekran` | pencereli Godot: shot, görsel kabul, tema denetimi |
| `sessiz` | süre ölçümleri: PLANMS, `--tick-probe`, `--tempo-probe` ve sürenin kapı olduğu her ölçüm. Kilit varken öbür oturumlar yeni Godot süreci başlatmaz; koşanlar biter. |

- **Almak:**
  ```
  mkdir -p "$K" && mkdir "$K/<kilit>" && echo "<ETIKET> <iş> $(date +%FT%T) pid=<pid>" > "$K/<kilit>/sahip"
  ```
  İkinci `mkdir` başarısızsa kilit başkasındadır.
- **Bırakmak:** `rm "$K/<kilit>/sahip" && rmdir "$K/<kilit>"`.
- **Beklemek:** arka planda ya da Monitor'la `until mkdir "$K/<kilit>" 2>/dev/null; do sleep 30; done`. Ön planda `sleep`
  yok. Beklerken başka işe geçilir.
- **Sıra:**
  - `ekran` ya da `sessiz` tutarken `kapi` istenmez.
  - Her Godot süreci başlamadan önce `$K/sessiz`'e bakılır. Varsa ve senin değilse beklenir.
  - `kapi` tutarken yalnız headless kapılar koşulur.
  - `kapi` en çok 45 dakika tutulur; aşılırsa bırakılır ve yeniden alınır.
- **Bayat kilit:**
  1. 60 dakikadan eski kilidin sahip dosyasındaki pid `tasklist`'te yoksa sahibine yaz.
  2. 10 dakika cevap gelmezse yardımcı yönetmene bildir. Kilidi o kaldırır.

## 5. Godot, APPDATA, bellek

- **Her Godot koşusu kendi APPDATA'sıyla koşar:** smoke, `run_gate`, `--event-*`, kareler, probe'lar. Örnek:
  `export APPDATA='C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\<oturum>\scratchpad\appdata'`
  (`5ad1dc82…/scratchpad/shots.sh` yöntemi). Varsayılan APPDATA Erdem'in kayıtlarıdır; hiçbir oturum oraya yazmaz.
  PNG'ler oturumun kendi APPDATA'sından alınır.
- **Bellek sorun değil.** Makine 32 GB (Erdem, 2026-10-26: "testler paralel koşabilir").
  - Headless koşular oturumlar arasında ve oturum içinde paralel olabilir: smoke, `run_gate`, `plausibility_run`, run-log,
    Z6. `xargs -P` ile `CASE_TIMEOUT=300` (CLAUDE.md §12).
  - **Paralel her süreç kendi APPDATA'sını alır**, oturum başına tek değil. Kayıt yuvası paylaşan vakalar ayrı dizinde
    güvenlidir.
  - Güvenlik payı: boş bellek 2.000 MB'ın altındaysa yeni süreç başlatılmaz.
- **Pencereli koşular** makinede yine teke iner (`ekran` kilidi; CLAUDE.md §12 "Ekran kartı").
- **Süre ölçümleri** sessiz makinede alınır (`sessiz` kilidi). Ölçümü yapan oturum kilidi alır, koşan öbür süreçlerin
  bitmesini bekler, ölçer ve bırakır.
- Arka plan kabuğu bellekte biçilirse yetim Godot süreçlerini öldür. Kendiliğinden yeniden başlatma (hafızada `bg-shell-memory-reap`).
- Son kapılar paylaşılan ağaçta değil, HEAD'in taze dışa aktarımında koşar.

## 6. Kayıt şeması ve `strings.csv`

**`SaveManager.SCHEMA_VERSION`.**
- Yeni alan mümkünse anlamlı varsayılanla ve sürüm artırmadan eklenir.
- Artacaksa öbür iki oturuma sor. Numara commit anında, kapı sendeyken HEAD'deki değer + 1 olarak yazılır.
- Göç işlevi hedef sürümle adlandırılır (TEMIZLIK C4'ün adlandırması).
- TEMIZLIK'in B1'i de sürüm artırıyorsa OLAYLAR'ın artışıyla aynı sürümde birleşir.

**`strings.csv`.**
- Asla baştan yazılmaz. Satır eklenir, silinir ya da bayt aralığıyla değiştirilir (hafızada `strings-csv-surgery`).
- Yeni anahtar kendi aile bloğunun içine eklenir. Dosya sonuna yalnız OLAYLAR (`EV_` ailesi) ekler.

## 7. HARITA'nın emekliliği

1. TEMIZLIK geçişi iki commit'le yapar:
   - (a) HARITA_GECIS §2'nin içeriği sistem sayfalarına girer.
   - (b) `docs/HARITA.md` silinir; CLAUDE.md atıfları, `kod_haritasi/README.md` §1 ve §5, sayfaların "HARITA'da bayat"
     bölümleri güncellenir.
2. (b)'den önce öbür ikisine tek mesaj gider: "HARITA <sha> ile emekli".
3. O mesajdan sonra:
   - Kimse HARITA'ya yazmaz.
   - Kopyalardaki HARITA hunk'ı HARITA_GECIS §1 tablosundaki sistem sayfasına taşınır.
   - `docs/HARITA.md` index'e hiçbir koşulda geri eklenmez; stage betiklerinin dosya listesinden çıkar.
   - GOREV_URUN_ARAYUZU ve PRD'deki "HARITA" sözü `sistemler/02_urun_sprint.md`, `08_sekmeler.md` ve `09_arayuz_bilesen.md`
     demektir.
4. CLAUDE.md §12'nin Ürün kare paragrafını U7 yeniden yazar. TEMIZLIK o paragrafta yalnız "HARITA Ürün'de" ifadesini
   "`sistemler/02_urun_sprint.md`'de" diye değiştirir. Çakışırsa U7'nin metni esastır.

## 8. Belgeler

- `docs/tasks/` git'te izlenmez (`f21b961`). Paralel dönemde TEMIZLIK bu klasörden arşive yeni taşıma yapmaz.
- Görev, PRD, rapor ve oturum çıktıları (ör. OLAYLAR'ın `revize2.json`'u) oturumun kendi scratchpad'inde ya da
  `docs/tasks/`'ta durur, kod ağacına konmaz.
