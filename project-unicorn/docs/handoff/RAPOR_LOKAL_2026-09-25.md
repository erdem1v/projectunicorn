# Lokal tur raporu: Series A devri (2026-09-25)

**Kaynak:** lokal agent. Görev, `HANDOFF_series_a.md` ve sahibin 2026-09-25 mesajıydı; çelişkide mesaj geçerliydi.

**Durum:**
- Yerel `main` bu raporun commit'inde. `origin/main` `6edade6`'da.
- Aradaki 9 commit **push edilmedi**. `main`'e her push ayrıca "push et" bekler.
- Tasarım sabiti değişmedi.

Durum işaretleri: ✅ tamam · ⚠️ tamam ama not var · ❌ yapılmadı.

## Commit'ler

| # | Commit | Ne | Push |
|---|---|---|---|
| C0 | `6edade6` | Cloud'un devir belgeleri, `main`'e fast-forward | ✅ push edildi (mesajdaki tek onay) |
| C1 | `a9c5de4` | Devir belgesi ve CLAUDE.md: dal istisnası kaldırıldı | yerel |
| C2 | `86e33eb` | Madde 5 geri alındı: Anchor uyumu yeniden MRR okuyor | yerel |
| C3 | `8457ce3` | `TERM_INV_*` EN yeniden yazıldı — **TR/EN onay bekliyor** | yerel |
| C4 | `1695cf9` | Smoke: eski v12 kaydı + "Series A yolu kapandı" vakaları | yerel |
| C5 | `05e6a3f` | Probe: `PROBE GATE`, `PROBE MONTH_BURN` (B2, yalnız harness) | yerel |
| C6 | `63800db` | Probe: saf / temkinli Series A politikaları + tekrarlar (E, yalnız harness) | yerel |
| C7 | `3bf7530` | Tasarım notu `docs/design/SONLAR_GAZETE_MODLAR.md` — onay bekliyor | yerel |
| C7b | `3e04627` | Probe: yalnız yorum (kaldıraç üreteci) | yerel |
| C8 | bu commit | Bu rapor, `runs/` çıktıları, HANDOFF'ta durum satırı | yerel |

---

## §0 Dal ve main ✅

**Önkoşullar:**
- Ağaç temizdi.
- `origin/main` (`fc58e7c`) dal ucunun (`6edade6`) atasıydı.
- Uzaktaki referanslar mesajdakiyle aynıydı.

**Yapılan:**
- `git merge --ff-only`: yerel `main` `33c5323` → `6edade6`.
- `git push origin main`: `fc58e7c..6edade6`.
- `git push origin --delete claude/sharp-dirac-lev32p`, ardından `git fetch --prune`.
- DELIVERY LAW gözlemi: `git branch` → `* main`; `git worktree list` → 1 satır; `git ls-remote --heads origin` → yalnız `refs/heads/main`.

**C1 (`a9c5de4`), sahibin "hepsini temizle" cevabıyla:**
- HANDOFF §A durum, §B girişi, §F.2, §G.1 (checkout komutları ve "bu devir için istisna" notu) ve §G.3'teki dal referansları "main'de çalış; her push ayrıca 'push et' bekler" oldu.
- CLAUDE.md HANDOFF RULES'tan "Pushing a working branch is fine." silindi.
- DELIVERY LAW metnine dokunulmadı.
- `ONERI_v3:23` (başlığı "Uygulama planı … tarihsel" diyen bölümde) ve `PUSH_ONCESI_KONTROL.md:11`, `:211`'deki dal anmaları tarihsel kayıt olarak kaldı.

**Onay bekliyor:** bu tarihsel satırlar da temizlensin mi (madde 5)?

## §1 Baseline ✅ (fark yok)

- Tam smoke `a9c5de4`'te koşuldu (oyun kodu `fc58e7c`). `xargs -P 3` ile cloud'la aynı düzen, 41,6 dakika.
- **340/342.** FAIL yalnız `save_migration_v7_to_v8` ve `trait_migration_real_load`, ikisi de `SAVE_ERR_TOO_OLD`.
- Cloud'un `runs/final_smoke.txt` dosyasıyla (`de6ab7f`) vaka ve sonuç kümeleri **birebir aynı**; sıralı `diff` boş.
- Çıktı: `runs/lokal_smoke_baseline.txt`.
- `fc58e7c` böylece ilk kez tam smoke'tan geçti.

**Onay bekliyor:** yok.

## §2 fc58e7c düzeltmeleri

### 2a. Madde 5 geri alındı ✅ (`86e33eb`)

- `term_sheet_table_system.gd`: `E_FIT_METRICS_GROWTH` ve yorumu kalktı, yerine `de6ab7f`'teki `E_FIT_METRICS_MRR := 6` ve yorumu geldi. "metrics" dalının ilk satırları `de6ab7f` hâline döndü.
- **Kanıt:**
  - `git diff de6ab7f HEAD -- scripts/systems/term_sheet_table_system.gd` yalnız madde 1 (seed board kilidi) ve madde 4 (`OTHER_SHOWN` Frank satırı) hunk'larını gösteriyor.
  - `E_FIT_METRICS_GROWTH` kodda artık yok (yalnız belgelerde, tarihçe olarak geçiyor).
- **Doğrulama:**
  - `--event-lint` PASS (43 kart), `loc_residue` exit 0.
  - Smoke 13/13: `loc_csv_integrity`, `all_scripts_load`, `table_sign_closes_series_a`, `table_walk_not_a_rejection`, `patience_zero_locks_pushes`, `push_decay_lowers_odds`, `leverage_bonus_applies_and_shows`, `no_leverage_no_box`, `investment_figure_tracks_terms`, `table_board_push_sequence`, `hunt_offer_lifecycle`, `seed_table_levers_and_final_offer`, `seed_table_walk_is_locked`.
- Bu, onaylı eski değere dönüştür; yeni bir tasarım değişikliği değil.

**Onay bekliyor:** yok.

### 2b. `TERM_INV_*` EN ✅ (`8457ce3`, mesaj: "TR/EN onay bekliyor")

- 15 anahtarın EN sütunu, aynı sahnenin İngilizce yazılmış hâli olarak yeniden yazıldı. TR'nin çevirisi değil. TR'ye dokunulmadı.
- Satırlar iki bağımsız eleştirmenden geçti (ses/doğallık ve kural/mekanik doğruluk). Yazım sınırları:
  - her satır hem kazanılan hem reddedilen itişin altında doğru okunmalı;
  - OUT satırları seed masasında da çıkıyor, orada fon kalkmıyor;
  - hiçbir satır olmayan bir mekanik vaat etmiyor.
- **Doğrulama:** `--event-lint` PASS, `loc_residue` 0. Smoke 7/7: `loc_csv_integrity`, `loc_event_en_coverage`, `loc_language_switch`, `locale_switch`, `loc_pick_fallback`, `loc_format_args`, `patience_zero_locks_pushes`.

| Anahtar | TR (`fc58e7c`, onay bekliyor) | EN (yeni, onay bekliyor) |
|---|---|---|
| `TERM_INV_RELAXED_1` | Tamam. Sırada ne var? | All right. What else is on your list? |
| `TERM_INV_RELAXED_2` | Devam et, masadayız. | Take your time. We're listening. |
| `TERM_INV_TENSE_1` | Fazla yükleniyorsun. | Now you're testing us. |
| `TERM_INV_TENSE_2` | Bizim de bir sınırımız var. | Don't push your luck. |
| `TERM_INV_OUT_ANCHOR` | İstersen uzatalım. Her turda şartlar biraz daha sertleşir. | Keep going. There's nothing extra waiting at the end. |
| `TERM_INV_OUT_NEXUS` | Ben senin tarafındayım ama ortaklarım hesap yapıyor. | I'm fighting for you with my partners. Don't make it harder. |
| `TERM_INV_OUT_BOSPHORUS` | Kimse kapıyı çarpmadan Frank'i bir arayayım. | Frank opened this door for you. Don't make him regret it. |
| `TERM_INV_OUT_MERIDIAN` | Bu hafta başka görüşmelerimiz de var. | We've seen three products this week. Yours is starting to look like the others. |
| `TERM_INV_OUT_GENERIC` | Uzatmayalım. | This is running long. |
| `TERM_INV_FINAL` | Son sözümüz bu. İster al, ister bırak. | This is where we land. We're done moving. |
| `TERM_INV_WALKOUT` | Burada bitti. Yolun açık olsun. | We're going to pass. I hope it works out for you. |
| `TERM_INV_OTHER_MATCH` | Peki. O maddede biz de yaklaşırız. | Fair. We won't lose this over one term. |
| `TERM_INV_OTHER_CONDITION` | Olur. Ama bir şeyi de biz alırız. | We can match that. It'll cost you somewhere else. |
| `TERM_INV_OTHER_HOLD` | Onlar öyle diyor. Bizim teklif değişmedi. | We don't get into bidding wars. |
| `TERM_INV_OTHER_WALK` | Madem öyle, onlarla devam et. | Sounds like you've already picked. Go sign theirs. |

**Alternatif:** `TERM_INV_OUT_ANCHOR`'ın eski, onaylı EN satırı: "We can keep doing this. Our terms get worse while we do." Kararınla o da yeniden yazıldı.

**Onay bekliyor:** 15 TR ve 15 EN satırı (madde 1).

### 2c. EK maddeler

**Kontrol sonucu:** `fc58e7c`'de iki EK maddeden hiçbiri yapılmamıştı. Smoke diff'i 7 satır ve yalnız `seed_table_levers_and_final_offer`'ı genişletiyor. E2 için de ne öneri ne değişiklik vardı.

**E1, eski v12 kaydı ✅** (`1695cf9` ile eklendi). Vaka: `legacy_v12_save_opens_live_table`.
- Kurulum:
  - Gerçek bir kayıt alınır; yeni altı alanın hepsi varsayılan olmayan değerde.
  - Teklif hafta sonu verilir ve eski 14 takvim günü kuralıyla süre yazılır. Eski kuralın K5'ten ayrıştığı tek gün türü bu.
  - Anahtarların dosyada olduğu doğrulanır, sonra JSON'dan silinir. `read_slot` + `apply_loaded_state` ile yüklenir.
- Beklenenler:
  - GameState alanları varsayılanda;
  - teklifin conviction'ı −1;
  - `expires_day` korunmuş;
  - iş günü sayacı süreden bir hafta sonrasına kadar hiç negatif değil;
  - eksik `move_penalty` 0 okunuyor;
  - masa E = 70 + uyum ile açılıyor; damgalı teklif 88 + uyum ile.
- Kendi kayıt yuvasını kullanıyor.

**Madde 2 smoke vakası ✅** (senin cevabınla eklendi). Vaka: `series_a_road_closed_when_all_funds_close`.
- Dört fon kapalıyken true.
- Yolu açık tutan her şey tek başına false yapıyor: açık fon, geri çağrı, faz < 3, ayarlanmış görüşme, canlı teklif, sıradaki teklif.
- Pivot yolu kapatıyor.
- `HUNT_ROAD_CLOSED` iki dilde çözülüyor.

**Mutasyon kanıtı** (commit edilmedi, her biri geri alındı): 10 farklı mutasyonun her biri ilgili vakayı FAIL'e düşürdü. E1 revizyonundan sonra E1'in 5 mutasyonu yeniden koşuldu, 5'i de FAIL.
- E1 tarafı: −1'i yok sayan açılış; conviction varsayılanı 0; `move_penalty` varsayılanı 5; takvim günü sayan sayaç; sayaçtan kaldırılan `maxi(0,…)`; silinen damga.
- Madde 2 tarafı: `pending_meeting`, faz ve `callback` şartlarının atlanması; boş EN hücresi.

**İnceleme:** WF-R iki boşluk buldu; ikisi de düzeltildi.
- "Negatif çıkmamalı" hiç sınanmıyordu.
- Paylaşılan kayıt yuvası paralel koşuda çakışabiliyordu.

**Doğrulama:**
- `--event-lint` PASS, `loc_residue` 0.
- Smoke, paralel (`-P 3`): iki yeni vaka ve 14 komşu. 15 PASS, 1 FAIL.
  - Komşular: `all_scripts_load`, `loc_csv_integrity`, `hunt_offer_lifecycle`, `deal_prompt_defer_keeps_clock`, `sheet_expiry_no_rejection`, `walk_not_a_rejection`, `pivot_closes_hunt`, `meeting_daylock`, `save_roundtrip_fingerprint`, `save_continuity_seeded`, `save_double_load_no_residue`, `save_v10_product_state`, `sales_save_roundtrip_rev6`, `seed_sheet_round_trips`.
  - FAIL: `save_v10_product_state` ("could not reopen the slot"). Paylaşılan `manual_9001` yuvası paralel koşuda başka bir vakayla çakıştı. Tek başına seri koşuda 2/2 PASS.

**E2, iki eskimiş fixture ⚠️ yalnız öneri, uygulanmadı.** Öneri: **emekliye ayır.**
- `save_migration_v7_to_v8` ve `trait_migration_real_load`, `cc952e4`'te bilinçli olarak öldürülen v7 ve v5 kayıtlarını `read_slot` üzerinden yüklüyor. Commit mesajı: "her eski kayıt öldü, bilerek" (`save_manager.gd:247-250`).
- Cloud'un önerdiği yedek davranış zaten sabit, yeni vaka gerekmiyor:
  - `save_v10_product_state` kaydı v9'a yaşlandırıyor ve `SAVE_ERR_TOO_OLD` ile boş state döndüğünü doğruluyor;
  - `engine_probe.gd:449-450` sabiti kontrol ediyor.
- Yeniden üretme seçeneği, vakaların adındaki göçü artık test etmez.
- **Onay bekliyor:** E2 kararı (madde 2).
- **Ayrı karar:** göç merdiveninde yalnız `_migrate_sales_rev6` ulaşılabilir. Diğer yedi fonksiyon ölü kod, ama yorum onları bilerek sana bırakmış (`save_manager.gd:251-268`). Yorumdaki "v9 gate" ifadesi eskimiş; kapı v10.

## §3 B2 ölçümü ✅ (rakamlar, yorum yok)

**Harness (`05e6a3f`):**
- Kapı günü `PROBE GATE` satırı ve her ay `PROBE MONTH_BURN` satırı. İkisi de salt okur.
- Eklendikten sonra 9 presetin 9'unda diğer `PROBE` çıktısı değişmedi.
- 184 aylık satırın hepsi hizalı.
- Kapı günleri ve kapıdaki durum `RUN_OZET` (`de6ab7f`) ile birebir aynı.

**Kapının açıldığı gün** (ayrıntı ve tanımlar: `runs/LOKAL_OLCUM_2026-09-25.md` §1):

| Tohum | Kapı günü | Çalışan | Roller (hepsi junior) | Aylık maaş yükü | Run-rate gider (günlük×30) | Son kapanan ay gideri (maaş) | Run-rate marj | Son ay marjı |
|---|---|---|---|---|---|---|---|---|
| 1 | 305 | 7 | ÜY 1 · satış 6 | 15.660 | 21.270 | 28.447 (18.475) | %82 | %75 |
| 2 | 357 | 12 (2 izinli) | geliştirici 2 · satış 5 · müşteri 5 | 26.870 | 32.340 | 36.488 (27.369) | %73 | %65 |
| 3 | 287 | 10 | ÜY 1 · geliştirici 1 · satış 6 · müşteri 2 | 22.570 | 30.240 | 35.127 (27.732) | %74 | %65 |
| 4 | 442 | 13 (1 izinli) | ÜY 4 · geliştirici 3 · satış 4 · müşteri 2 | 31.305 | 36.780 | 33.504 (29.013) | %69 | %64 |
| 5 | 261 | 12 | ÜY 1 · geliştirici 3 · test 1 · satış 4 · müşteri 3 | 26.900 | 32.370 | 34.978 (29.729) | %73 | %63 |

- Roller: ÜY = ürün yöneticisi (`product_manager`), satış = `sales_rep`, müşteri = müşteri temsilcisi (`customer_rep`), test = `tester`, geliştirici = `developer`. `designer` hiçbir tohumda yok.
- MRR kapıda 120.423–122.190.
- Son ay gideri = maaş + kurucu (1.400–1.550) + sunucu (3.091–3.947) + tek seferlik (0–4.475).
- Fazla mesai, pazarlama ve ofis her yerde 0.
- **Marj ofis gideri olmadan hesaplandı.** `finance_system.gd:39`: `"office": 0` bir TODO; ofis gideri ofis sistemiyle gelecek. Bu TODO'ya sayı konmadı.
- Yüzdeler tam sayı bölmesiyle aşağı yuvarlanmış.
- Botun işe alım kuralı yalnız olgu olarak ölçüm belgesinde (§1.3). Botun yeterince işe alıp almadığına dair bir değerlendirme yapılmadı. Kalibrasyona dokunulmadı.
- HANDOFF §C.3–4'teki karşılaştırma ve karar kuralı (harness mi, ekonomi mi) mesajındaki talimatla yapılmadı. B2 açık kalıyor.

**Onay bekliyor:** yok. Harness satırları yalnız okuyor, tasarım sabiti değil.

## §4 E modeli harness'ı ✅ (rakamlar; sabitler değişmedi)

**Harness (`63800db`):** `full_run_vc_naive` ve `full_run_vc_cautious` presetleri, tanımların aynen. Ayrıntı: `runs/LOKAL_OLCUM_2026-09-25.md` §2; ham satırlar: `runs/LOKAL_OLCUM_2026-09-25_vc.txt`.
- **Görüşme kuralı** (iki politikada aynı): oda okuma → en yüksek ihtimalli açı → dürüst cevap → ılık çatalda zorla. Hazırlık yok. Red gelirse ertesi gün sıradaki fon.
  - Tanımın yalnız masayı anlatıyordu; görüşme kuralı **benim varsayımım**.
  - Sonuca etkisi var: tohum 4'teki Anchor masası ancak "zorla" ile geldi, sheet inancı 45'ti ve E0 45 = eşik 45 ile açıldı. İlk başarısız itiş kalkma demekti.
- **Tek masa:** imza koşuyu bitiriyor. Fon kalkınca kârlı şirkette `profitable_bootstrap` ertesi gün koşuyu bitiriyor.

**Doğrulama:**
- Tekrarlar gerçek koşuyu değiştirmiyor: 5 tohumun 5'inde `replay=0` ile `replay=20` aynı.
- Saf ve temkinli masa açılışına kadar aynı.
- VC presetleri ilk görüşmeye kadar `full_run` ile aynı.
- Varsayılan preset değişmedi.
- `PROBE ERROR` yok.
- `--event-lint` PASS, `loc_residue` 0, smoke 9/9.

**5 tohum × 2 politika:**

| Politika | Masa | İmza (son teklifsiz) | Son teklif → imza | Fon kalktı |
|---|---|---|---|---|
| Saf | 4 | 0 | 2 (Bosphorus, Meridian) | 2 (Anchor, Nexus) |
| Temkinli | 4 | 4 | 0 | 0 |

- Tohum 3'te dört görüşmenin dördü de red; iki politikada da masa yok.
- **Hedef** (saf politikada kalkma ≤ %25): ölçülen 2/4 (%50). n = 4. Zorla ile gelen teklif hariç tutulursa 1/3.

**Tekrarlar** (senin onayınla; her tohumda aynı durumdan dört fon × 20 masa, E0 = 70 + gerçek uyum):

| Fon | n | Son teklif | Fon kalktı |
|---|---|---|---|
| Anchor | 100 | 0 | 100 |
| Nexus | 100 | 0 | 100 |
| Bosphorus | 100 | 0 | 100 |
| Meridian | 100 | 0 | 100 |

- Tekrarların hepsinde sheet inancı 70'e sabitlendi, E0 = 70 + uyum (68–80). Bu senin onayladığın kurulumdu; %100 kalkmanın büyük kısmı bu seçimden geliyor (aşağıdaki sınır).
- Masaya gerçekten gelen fonun kendi inancıyla (ör. tohum 1 Bosphorus 83) tekrar koşulmadı.
- Temkinli tekrar koşulmadı: itiş yok, sonuç hep imza.

**Sabitlerden türetilen sınır** (koşularla tutarlı):
- Sabır yalnız başarısız itişte düşüyor. Başarısız itişin bedeli 6 + 4 × adım (en az 10), fonun kendi kaldıracında +3. Kalkma eşiği 75 − 10 × sabır.
- Bu yüzden sabır bitene kadar iten bir oyuncu son teklifi ancak **E0 ≥ 75 + kazanılan itişlerin, adım artışlarının ve fonun kendi kaldıracına yapılan itişlerin bedeli** ise alır. Sınır sabrın büyüklüğünden bağımsız. K7'nin bedeli dahil değil; saf politika K7 kullanmıyor.
- Sınır, E0 < 75 olan 320 tekrarda kalkmayı kesinleştiriyor. Nexus'un E0 80 olan 80 tekrarında son teklif mümkündü; oradaki 0/80 ampirik.
- Son teklife ulaşan iki gerçek masa E0 81 ve 79 ile, hiç kazanmadan bitti.

**İnceleme notu (WF-H):** Politikanın ilk sürümü her itişte aynı kaldıracı seçiyordu (bir karma kusuru). Düzeltildi. Rakamların hepsi düzeltilmiş koddan; ilk sürümün saf sonucu 1 son teklif / 3 kalkmaydı.

**Onay bekliyor:** görüşme kuralı bir harness varsayımı; ölçüm senin tanımına uyuyor mu (madde 6)? Sabit değişikliği yok.

## §5 Dokunma listesi

- **§D ✅ yalnız tasarım notu** (`3bf7530`): `docs/design/SONLAR_GAZETE_MODLAR.md`. Uygulama yok.
  - HANDOFF §D'nin 7 maddesini karşılıyor: bugünkü yapı, mod tablosu, "Devam et" seam'i ve mandallar, 730 seçenekleri (a/b/c), K17 alanları ve eşikleri, seed ticker'ı, D5 bağımlılığı.
  - Sonda 21 açık karar var.
  - Yeni Frank satırı yazılmadı.
- **§E ✅ dokunulmadı.** `ACIK_KARARLAR_D1-D13.md` değişmedi. Tasarım notu D maddelerine yalnız bağımlılık notu olarak değiniyor.
- **Görsel kontrol yapılmadı.** HANDOFF §B doğrulamasının 3. adımındaki görsel kontroller (seed masası, Series A masası, Av sekmesi "yol kapandı" satırı, K10 kartı) bu turda yapılmadı; oyunu açıp bakman gerekiyor. `TERM_INV_*` EN satırları da ekranda görülmedi.

**Onay bekliyor:** tasarım notunun açık kararları (madde 3).

## Son tam smoke ✅ (342/344)

- Tam smoke `63800db`'de koşuldu: oyun ve harness kodu son hâlinde; sonraki commit'ler yalnız belge ve bir yorum. Düzen `xargs -P 3`, yaklaşık 35 dakika.
- **342/344.** FAIL yalnız baseline'daki aynı iki vaka: `save_migration_v7_to_v8` ve `trait_migration_real_load`, `SAVE_ERR_TOO_OLD`.
- Eksik ya da tekrarlanan vaka yok. İki yeni vaka ve `save_v10_product_state` PASS.
- Çıktı: `runs/lokal_smoke_final.txt`.
- **Koşu sırasında olanlar:**
  - Claude Code, sistemin belleği azaldığı için arka plan kabuğunu durdurdu. Başlatılmış Godot alt süreçleri çalışmaya devam etti ve 344 vakayı tamamladı. Yeni koşu başlatılmadı.
  - 20:50'de, koşu sürerken, repo içinde üç addon dosyası dışarıdan değişti: `addons/godot_mcp_editor/tool_executor.gd`, `addons/godot_mcp_editor/tools/scene_tools.gd`, `addons/godot_mcp_runtime/mcp_runtime_autoload.gd`. Repo kökünde `.mcp.json` oluştu. Bunları ben yapmadım; Godot MCP eklentisinin güncellemesine benziyor.
  - 20:50'den sonra koşan vakalar değişmiş MCP autoload'uyla koştu.
  - Bu dosyalar commit edilmedi ve geri alınmadı; çalışma ağacında duruyorlar (madde 8).

---

## Onay bekliyor

1. **`TERM_INV_*` metinleri:** 15 TR (`fc58e7c`) ve 15 EN (`8457ce3`). Anchor'ın eski onaylı EN satırı alternatif olarak yukarıda.
2. **E2:** iki eskimiş vaka emekliye ayrılsın mı? Önerim evet. Yedi ölü göç fonksiyonu ayrı bir karar.
3. **§D tasarım notu:** 21 açık karar. Öne çıkanlar:
   - 730 seçeneği (a/b/c);
   - K17 kuralı ve eşikleri (iki varyant; "dengeli" ancak GDD genişlerse);
   - "Devam et" seam biçimi;
   - EA build'deki sonlarda wishlist.
4. **Push:** C1–C8 (C7b dahil 9 commit) yerel `main`'de; "push et" bekleniyor.
5. **Tarihsel dal satırları:** `ONERI_v3:23` ve `PUSH_ONCESI_KONTROL.md:11`, `:211` de temizlensin mi? Tarihsel kayıt diye bıraktım.
6. **E ölçümündeki görüşme kuralı:** masa tanımın aynen uygulandı. Görüşme kuralı (en yüksek ihtimalli açı, dürüst cevap, ılık çatalda zorla) benim varsayımım.
7. **Görsel kontroller:** HANDOFF §B doğrulamasının 3. adımı ve yeni EN satırları ekranda.
8. **Dış değişiklikler:** çalışma ağacında commit edilmemiş üç `addons/godot_mcp_*` dosyası ve `.mcp.json` var. Benden değil. Tutulsun mu, geri alınsın mı?

**Tasarım sabiti değişikliği yok.** Madde 5'in geri alınması onaylı eski değere dönüş (`86e33eb`).

## Gözlemler (işlem yapılmadı, bilgi için)

**Masa metni ve mekanik:**
- `TERM_INV_OUT_ANCHOR` TR'si "şartlar sertleşir" diyor. Hiçbir itiş şartı kötüleştirmiyor: reddedilen itiş şartı olduğu gibi bırakıyor, kazanılan itiş iyileştiriyor.
- OUT satırları seed masasında da çıkıyor ve dönüşümlü değiller: E eşiğin altındayken her itişte aynı satır tekrar ediyor.
- K7: `SERIES_A_DIL_BY_ARCH` Nexus'a %15, diğerlerine %18–22 veriyor.
  - Nexus'ta "diğer teklifi göster" hep HOLD çıkıyor.
  - Bosphorus'un kurul farkı 2 adıma ulaşamıyor.
  - Yani OTHER_WALK yalnız Anchor ve Meridian'da, değerlemeyle oluşabiliyor.
- `vc_pitch_system.gd:566-569` yorumu masanın `"walked"` gönderdiğini söylüyor; kod varsayılan `"declined"`'ı gönderiyor (tasarım notu §7).

**Kayıt ve test altyapısı:**
- Eski (14 takvim günü) bir kayıtta süre hafta sonuna düşerse, Cuma günü "0 iş günü kaldı" görünür ama karar kartı Cumartesi gelir. Yalnız eski kayıtlar; K5'le verilen teklifler hep hafta içinde biter.
- Paralel smoke'ta `save_v10_product_state` bir kez paylaşılan `manual_9001` yüzünden düştü; seri koşuda 2/2 geçti. Eski kayıt vakalarındaki yuva paylaşımından geliyor.

**Belge düzeltmesi:**
- HANDOFF §D.1: gazete sahnesi `7946ff3`'te değil `3ee3963`'te (2026-07-21) geldi. `7946ff3` Frank şeridini ekledi.
