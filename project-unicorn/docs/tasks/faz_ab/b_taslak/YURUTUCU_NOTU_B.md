# Yürütücü notu · Faz B
Her kod, kapı ve inceleme ajanı bunu okur. Çakışmada PRD (`../PRD_FAZ_B_OLAYLAR.md`) geçerlidir; sonra onaylı adım
tablosu (`C:\Users\erdem\.claude\plans\bu-task-devral-ve-fluttering-hearth.md`), sonra bu not, en son `../ek/B_PLAN.md`
(yalnız tasarım girdisi; §0'daki geçersizler listesi kodlanmaz).

## 1. Sahibin kararları
- 2026-10-16: dalgalar inceleme sayfasıyla sunulur; W1 önce, W2 ile W3 sonra; her dalga tek tur Opus eleştirisinden geçer.
- 2026-10-17 00:10: Erdem "yazım dalgalarının hepsini şimdilik onaylı say; sabah tek tek elden geçiririz" dedi ve
  Faz B'nin bütün işlerinin bitirilip commit'lenmesini istedi. Bu yüzden:
  - W1, W2, W3 metinleri onaylı metin gibi bağlanır, ama commit mesajı "TR/EN onay bekliyor" der.
  - A bitince (RAPOR_A, koda başlama koşulu) B0'dan R'ye sormadan ilerlenir; "A'yı bekliyorum" durağından sonra Erdem'in
    yeniden başlatması beklenmez.
- Sayfa: https://claude.ai/artifact/Rsi6PUehHbMiQqVs3tiNmn (işaretler `marks_W1`, `marks_W2`, `marks_W3`). Sabah gelen
  işaretler sonraki bir düzeltme turunun girdisidir; bu turda bağlamayı durdurmaz.
- 2026-10-17 akşam (Erdem, `faz_cde/ERDEM_CDQ_CEVAP.md`): kesinti kademe çarpanı `sprint.json` `incident.tier` =
  local 1,0 · cloud 0,5 · enterprise 0,25. **Onaylı** (onay bekliyor değil); B_PLAN'daki 1,5 / 1,0 / 0,6 geçersiz.
  Olay sıklığı ölçümü (B6b) bu çarpanlarla yapılır. Doluluk: kapasiteyi oyuncu ayarlayacak, yük %90'ı geçince ihtimal
  artacak; kesin sayıları C verir. C'ye kadar B bugünkü sunucu verisini tek doluluk çarpanından (`load_mult`) okur.
- 2026-10-17 gece (C/D oturumu, Erdem'in izniyle; `faz_cde/C_ICERIK_v3.md` §8): kademe çarpanı tavandan SONRA uygulanır:
  p = min(base × load × (1 + hata/8), p_max) × tier (oran 1,0/0,5/0,25 her yük ve hatada korunur). "Testi kısalt" çipi
  yüzde yazmaz, sonucu yazar (Erdem D2: "kart hata ihtimali yazmayalım"); D'nin önerisi "Hesap Planı'nın testi yarıya
  iner" (TR'de belirteç ek almaz, cümle ona göre kurulur; TR/EN onay bekliyor). `trust_offset` modeli DEĞİŞMEZ (C v3
  önerisi Erdem'in onayını bekliyor); `load_mult` C'ye kadar 1,0; yük cümlesi yazılmaz.

## 2. Onaylı metin nasıl bağlanır
- Kaynak tektir: `b_taslak/W1_OLAYLAR.json`, `W2_KAGITLAR.json`, `W3_SOZ_SURUM.json`. EN ve TR metin **bayt bayt** aynen
  `localization/strings.csv`'ye ya da kart JSON'unun `text.en` / `text.tr` bloğuna girer. Kelime, noktalama, büyük harf,
  tırnak değişmez. Her bağlama commit'inde Haiku eşliği betikle kanıtlar.
- Belirteçler: dalgadaki `{seam:ns.ad}` adı bağlamada değişebilir (ör. `olay.clock` başka bir ada bağlanırsa); değişirse
  hem kart metni hem dalga dosyası aynı commit'te değişir ve raporda listelenir. Metnin kelimesi değişmez.
- Dalganın "onay bekliyor" sabitleri kodda tek bir ayar sabitinde (`data/product/sprint.json` `incident` / `decision` /
  `promise` blokları ya da sistemin sabit bloğu) `[WORKING]` işaretiyle durur ve R'de "onay bekliyor" altında listelenir.
- `strings.csv` cerrahisi: byte-span splice, dosyayı baştan yazma yok; token'lar `[a-z_]+` ve iki dilde aynı.

## 3. Ağaç ve commit
- Tek klasör, doğrudan `main`. Worktree, dal, rebase yok. Push yok.
- **Kod ajanı commit atmaz.** Commit'i ana oturum atar: yalnız adımın dosyaları (gerekirse hunk düzeyinde) sahnelenir.
- Sahipsiz fark: `project.godot`, `themes/master_theme.tres`, `themes/menajer_theme.tres`, `docs/mockups/...`,
  `docs/tasks/PRD_*`, `tools/__pycache__`. Dokunulmaz, sahnelenmez.
- `git checkout -- <yol>` yasak. Geri almak gerekirse yalnız kendi parçanı elle geri al.
- `docs/tasks/faz_ab/` commit'lenmez. Rapor ve ölçüm dosyası repoya konmaz (CLAUDE.md §8).
- Commit mesajı `Faz B Bn: ...` ile başlar; metin taşıyorsa "TR/EN onay bekliyor"; sabit taşıyorsa "sabitler onay bekliyor".

## 4. Kapılar
- `export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/`'dan.
- Sıra (CLAUDE.md §12): `--event-lint` → `loc_residue` → `smoke_run.sh loc_csv_integrity` → her yeni kart için
  `--why-fire=<id>` → adımın hedefli smoke'u (`smoke_run.sh <vaka>`) ve probu → onaylı metin eşliği → görsel kabul.
- Tam smoke (`--all`) koşulmaz. `class_name` eklenince/silinince önce `--headless --import`.
- Her Godot koşusu kendi `APPDATA` dizinini alır (scratchpad altında); kayıt taşıyan kullanıcı dizininde çalışılmaz.
  Ekranlı koşular (shot, theme-audit) sırayla, ekransızlar `--headless`.
- `xargs -P 2` altında `CASE_TIMEOUT=300`. Smoke PASS tek başına yetmez: çıktı `Parse Error|Compile Error|Failed to
  instantiate` ile de taranır. Yeni smoke vakası falsification ile kanıtlanır (kuralı bozunca FAIL vermeli).
- Kod ajanı yalnız parse kontrolü yapar (headless açılış ya da hedefli tek vaka); kapıların tamamını Haiku koşar.

## 5. Kod yazımı (CLAUDE.md §8, §9)
Kısa ve doğrudan. Var olan evi ara (`Fmt`, `UiFactory`, `UiTokens`, `EvChips.describe`, `EvDice.unit`,
`FinanceSystem.apply_one_time_cost`, `CustomerRegistry` seam'leri, A'nın adlı noktaları). Tek yerde kullanılan
sarmalayıcı yok, imkânsız durum için savunma yok, ölü kod/anahtar/vaka bırakılmaz, yerini alan kod eskisini aynı
commit'te siler, yorum yalnız bugünkü nedeni söyler (tarihçe, görev etiketi, satır no yok). Write-through kanunu:
başka alanın durumu yalnız sahibinin seam'inden yazılır. UI/STYLE kanunu: ham renk ve boyut yok, koyu yüzey `D_*`.

## 6. Bilinen tuzaklar (B0t'den; B0 tazeler)
1. Gece toplu adımı tek karede senkron koşar; 00:00 saatlik dilimi `advance_day()`'den ÖNCE koşar.
2. `EvQueue.rank`'te son uyarı (`expiring`) `critical`'in üstünde: 03:00 acil kartı ikinci kalabilir (kabul 4.3).
3. Lint C1: `critical` etiketi yalnız `system: true` ya da `terminal_warning` kartta. Acil durum kartları `system: true`.
4. İstek kartında tutuş: `"incident"` tutuşu yalnız `EventGate.request` true dönerse alınır; kart gösterilince bırakılır.
   Pompa kartı düşürürse tutuş bırakılmalı, yoksa saat kilitlenir.
5. Varlık ile görünürlük ayrı: `desk_papers` / `queue_size` gösterim için süzülür; `sprint_system.gd`'nin varlık
   okumaları, `EvQueue.has/holds/ids`, `EvPapers.has/keys_of`, ark adımları süzülmez.
6. `--sprint-probe` bugün dize parametreyi float'a çevirir; `team=3` kurucu + geliştirici + tasarımcı verir.
7. PM bugün `team()`'de tasarım aşamasına atanabiliyor; Karar 10 "PM sprintte kart almaz, önden gider" der. A'nın
   Görevler matrisi bağından sonra B5 bunu doğrular; çelişki sürerse raporda ⚠️.
8. `satisfaction_delta` bir tikte hedefe geri çekilir; kalıcı B2B bedeli yalnız `trust_offset` yoluyla. `trust_offset`
   da haftada ≈2,8 puan affedilir ve bozulma ile affetme aynı tikte koşar: −3 gibi küçük iz oyuncuya hiç görünmeyebilir.
   B2 her memnuniyet çipinin oyuncunun gerçekten göreceği değeri söylediğini bir vakayla kanıtlar; söylemiyorsa sayı
   R'de "onay bekliyor" altında Erdem'e gider (metin değişmez).
9. Kayıt JSON'unda tamsayılar float döner; `int()` şart.
10. Bayrak `--` ayracının arkasına konmaz.
