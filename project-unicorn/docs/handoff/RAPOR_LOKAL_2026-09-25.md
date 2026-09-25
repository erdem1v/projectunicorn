# Lokal tur raporu: Series A devri (2026-09-25)

**Kaynak:** lokal agent. Görev, `HANDOFF_series_a.md` ve sahibin 2026-09-25 mesajıydı; çelişkide mesaj geçerliydi.

**Durum (tur 2 sonu):**
- İki tur var:
  - tur 1: devir mesajı, §0–§5;
  - tur 2: sahibin ikinci mesajı, "Tur 2" bölümü.
- Sahip, revizeler yapıldıktan sonra push'u onayladı ("söylediğim revizeleri hayata geçirerek push edebilirsin"). Bu raporun commit'iyle birlikte `main` push edildi.
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
| C8 | `2137cfd` | Bu rapor, `runs/` çıktıları, HANDOFF'ta durum satırı | tur 2'de push |
| — | `78d159d` | Sahibin commit'i: Godot MCP (gopeak 2.4.0) addon'u ve `.mcp.json` | tur 2'de push |
| C9 | `95bc9ea` | Tur 2: `TERM_INV_*` TR yeniden yazıldı — TR/EN onay bekliyor | tur 2'de push |
| C10 | `409d9e1` | Tur 2: E2, iki eski fixture vakası emekliye ayrıldı | tur 2'de push |
| C11 | `b43745a` | Tur 2: tarihsel belgelerdeki dal anmaları temizlendi | tur 2'de push |
| C12 | `f50d481` | Tur 2: sonlar ve gazete, EA / tam'da kilometre taşı modu | tur 2'de push |
| C13 | `8df1d83` | Tur 2: debug `--vc-shot` harness'ı (görsel kontrol) | tur 2'de push |
| C14 | bu commit | Tur 2: rapor, tasarım notu §U, HANDOFF §H, `runs/lokal_smoke_final2.txt` | tur 2'de push |

C1–C8 tur 1'de yereldi; hepsi tur 2'nin push'uyla gitti.

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

**Onay bekliyor:** ~~bu tarihsel satırlar da temizlensin mi?~~ Tur 2: sahip onayladı, `b43745a`.

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
- **Onay bekliyor:** ~~E2 kararı.~~ Tur 2: sahip onayladı, `409d9e1`.
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
- **Görsel kontrol tur 1'de yapılmadı.** Tur 2'de yapıldı (T2.4).

**Onay bekliyor:** tasarım notunun açık kararları (madde 3).

## Tur 1 son tam smoke ✅ (342/344)

- Tam smoke `63800db`'de koşuldu: oyun ve harness kodu son hâlinde; sonraki commit'ler yalnız belge ve bir yorum. Düzen `xargs -P 3`, yaklaşık 35 dakika.
- **342/344.** FAIL yalnız baseline'daki aynı iki vaka: `save_migration_v7_to_v8` ve `trait_migration_real_load`, `SAVE_ERR_TOO_OLD`.
- Eksik ya da tekrarlanan vaka yok. İki yeni vaka ve `save_v10_product_state` PASS.
- Çıktı: `runs/lokal_smoke_final.txt`.
- **Koşu sırasında olanlar:**
  - Claude Code, sistemin belleği azaldığı için arka plan kabuğunu durdurdu. Başlatılmış Godot alt süreçleri çalışmaya devam etti ve 344 vakayı tamamladı. Yeni koşu başlatılmadı.
  - 20:50'de, koşu sürerken, repo içinde üç addon dosyası dışarıdan değişti: `addons/godot_mcp_editor/tool_executor.gd`, `addons/godot_mcp_editor/tools/scene_tools.gd`, `addons/godot_mcp_runtime/mcp_runtime_autoload.gd`. Repo kökünde `.mcp.json` oluştu. Bunları ben yapmadım; Godot MCP eklentisinin güncellemesine benziyor.
  - 20:50'den sonra koşan vakalar değişmiş MCP autoload'uyla koştu.
  - Bu dosyalar commit edilmedi ve geri alınmadı. Tur 2: sahibin `78d159d` commit'iyle main'e girdi; sahip tutulmasını istedi.

---

## Tur 2: sahibin ikinci mesajı

| # | Sahibin maddesi | Durum | Kanıt |
|---|---|---|---|
| 1 | TR satırları kötü, aynı anlama gelmiyor (EN çok iyi) | ✅ `95bc9ea` | 15 TR yeniden yazıldı, EN değişmedi. İki anadil eleştirmeninden geçti. Aşağıda tablo. |
| 2 | E2 onaylandı, iki eski test kaldırılsın | ✅ `409d9e1` | 344 → 342 vaka. Reddetme davranışı `save_v10_product_state` ve `engine_probe.gd:449-450` ile sabit. |
| 3 | Kadronun %60–70'i satış: kalibre edilmeli mi, not et | ✅ not | Aşağıda ve HANDOFF §H.3 |
| 4 | Sonlar ve gazete değişiklikleri | ✅ `f50d481` | Aşağıda; tasarım notu §U |
| 5 | Tarihsel belgeleri temizle | ✅ `b43745a` | 4 belge, 8 satır. Satır sayıları korundu, başka belgelerin satır referansları geçerli. |
| 6 | Görsel kontrol | ✅ harness ile | Godot MCP araçları bu oturumda yüklenmedi. `--vc-shot` (`8df1d83`) ve `--ending-shot` ile 11 yüzey çekildi ve incelendi. |
| 7 | Godot MCP addon'u kalsın | ✅ | Senin `78d159d` commit'in main'de; dokunulmadı. |
| 8 | Revizelerden sonra push | ✅ | Bu raporun commit'iyle push edildi. |

### T2.1 `TERM_INV_*` TR (`95bc9ea`)

| Anahtar | TR (yeni) | EN (`8457ce3`, değişmedi) |
|---|---|---|
| `TERM_INV_RELAXED_1` | Peki. Listende başka ne var? | All right. What else is on your list? |
| `TERM_INV_RELAXED_2` | Acele etme. Dinliyoruz. | Take your time. We're listening. |
| `TERM_INV_TENSE_1` | Artık sabrımızı sınıyorsun. | Now you're testing us. |
| `TERM_INV_TENSE_2` | Şansını zorlama. | Don't push your luck. |
| `TERM_INV_OUT_ANCHOR` | Devam et. Sonunda bundan fazlası çıkmaz. | Keep going. There's nothing extra waiting at the end. |
| `TERM_INV_OUT_NEXUS` | Ortaklarıma karşı seni ben savunuyorum. İşimi zorlaştırma. | I'm fighting for you with my partners. Don't make it harder. |
| `TERM_INV_OUT_BOSPHORUS` | Bu kapıyı sana Frank açtı. Onu pişman etme. | Frank opened this door for you. Don't make him regret it. |
| `TERM_INV_OUT_MERIDIAN` | Bu hafta üç ürün gördük. Seninki de ötekilere benzemeye başladı. | We've seen three products this week. Yours is starting to look like the others. |
| `TERM_INV_OUT_GENERIC` | Bu iş uzadı. | This is running long. |
| `TERM_INV_FINAL` | Bu kadar. Daha fazla esnemiyoruz. | This is where we land. We're done moving. |
| `TERM_INV_WALKOUT` | Biz bu işte yokuz. Umarım işlerin yolunda gider. | We're going to pass. I hope it works out for you. |
| `TERM_INV_OTHER_MATCH` | Haklısın. Tek bir madde yüzünden bu işi kaçırmayız. | Fair. We won't lose this over one term. |
| `TERM_INV_OTHER_CONDITION` | Aynısını biz de veririz. Ama bedelini başka bir maddede ödersin. | We can match that. It'll cost you somewhere else. |
| `TERM_INV_OTHER_HOLD` | Biz teklif yarışına girmeyiz. | We don't get into bidding wars. |
| `TERM_INV_OTHER_WALK` | Anlaşılan seçimini yapmışsın. Git onlarınkini imzala. | Sounds like you've already picked. Go sign theirs. |

İlk turdaki iki yanlış da bu yazımla gitti:
- "şartlar sertleşir": hiçbir itiş şartı kötüleştirmiyor.
- "Frank'i arayayım": oyunda olmayan bir eylem.

Dört satır ekranda görüldü (`--vc-shot`): RELAXED_1, FINAL, WALKOUT, OTHER_HOLD.

**Doğrulama:** `loc_residue` 0. Smoke 5/5: `loc_csv_integrity`, `loc_event_en_coverage`, `loc_language_switch`, `locale_switch`, `patience_zero_locks_pushes`.

### T2.2 Kalibrasyon notu: kadronun satış ağırlığı

- Kapı gününde 5 tohumda 54 çalışan vardı:
  - satış 25 (%46);
  - müşteri temsilcisi 12 (%22), yani satış ve müşteri birlikte %68,5;
  - geliştirici 9 (%17).
- Tohum 1'de 7 kişinin 6'sı satışçı, geliştirici yok.
- **Kaynağı** (olgu):
  - Kadroyu botun merdiveni kuruyor. Merdivenin %62'si tasarım gereği satış ve müşteri; ayrılmalar dağılımı daha da kaydırıyor.
  - Series A kapısı yalnız MRR okuyor (K1+K2).
- **Açık soru, senin:** harness etkisi mi, yoksa Series A'ya ürün tarafında bir şart mı gerekiyor?
  - Ayırmak için üç ölçüm önerisi HANDOFF §H.3'te.
  - Kalibrasyona dokunulmadı.

### T2.3 Sonlar ve gazete (`f50d481`)

**Kararların** (senin cevapların dahil) ve kodda karşılıkları tasarım notunun §U bölümünde. Kısaca:

| | Demo | EA / tam |
|---|---|---|
| Kayıp sonları (iflas, marka, ret zinciri, 730) | son, ekran aynı | son; Frank şeridi, wishlist ve Yakında kartları yok |
| Kârlı bootstrap | son | **kilometre taşı**: gazete bir kez açılır, DEVAM ET ile koşu sürer, 730 sınırı kalkar |
| Series A imzası | son | son (Perde 3'e kadar) |
| Satış | son | son (onay bekliyor, madde 3) |

- **Gazete sayfası değişmedi.** Farklar yalnız sağdaki rayda ve sayfanın altındaki Frank şeridinde.
- **Kilometre taşı rayı:**
  - "KİLOMETRE TAŞI" / "Bu bir son değil. Şirket yoluna devam ediyor.";
  - DEVAM ET;
  - ANA MENÜ.
  - Kararındaki "iki buton" gereği paylaş yok.
- **ANA MENÜ:** koşuyu yeni bir elle kayıt slotuna yazar, sonra oyunu TEKRAR DENE gibi yeniden başlatır. Ana menü sahnesi gelince yalnız yeniden başlatma satırları değişir.
- **Build:**
  - EA / tam export'unun ön ayarına `ea` / `full` özel etiketi eklenir.
  - Editörde EA akışını denemek için: Project Settings → Application → Run → Main Run Args'a `--build=ea`.
  - Smoke ve run probe demo'ya sabitli.

**Yeni smoke vakaları:**
- `ending_modes_by_build`: mod tablosu; demo'da açılan kilometre taşı kaydı demo gibi biter.
- `bootstrap_milestone_keeps_the_run`:
  - gazete bir kez açılır, koşu sürer;
  - 730'da son yok, telgraf susar;
  - 1100. günün gazetesinde "iki yılı aşkın".
- `ending_paper_modes_on_screen`: üç ray; hangi buton ve şerit nerede.
- `milestone_clock_hold`: gazete açıkken saat başka yüzeylerden başlatılamaz.
- `milestone_paper_under_card`:
  - aynı gün açılmış kart gazetenin üstünde kalır;
  - DEVAM ET kilidi bırakır;
  - ANA MENÜ'nün kaydı elle kayıt slotunda.

**İnceleme** (üç mercek: kenar durumlar, sadakat, yasalar). Düzeltilenler:
- ANA MENÜ kaydı dönen otomatik kayıt slotuna yazılıyordu. Yeni oyunun üçüncü haftalık otomatik kaydı onu silebiliyordu. → Elle kayıt slotu.
- Aynı gün önceden açılmış bir kart gazetenin altında kalıyordu. ANA MENÜ de görünmeyen bir karar ekranı yüzünden kaydı reddediyordu. → Gazete kartın altına takılıyor.
- 730'u geçen koşunun gazetesi "iki yıla yakın" diyordu. → Yeni ifade "iki yılı aşkın sürede" / "in over two years".
- Mandal build'e bağlı değildi. Demo'da açılan bir kilometre taşı kaydı hiç bitemezdi. → `bootstrap_milestone_taken()`.
- Main Run Args'taki `--build=ea` smoke'u da EA'ya çevirirdi. → Smoke ve probe demo'ya sabit.
- Kilometre taşı rayında paylaş vardı. → Kaldırıldı.
- Eskimiş yorumlar, sözlük satırı ve üretilmiş `_vocabulary.md` güncellendi.

**Uygulanmayan inceleme önerileri:**
- "Frank şeridi demo'dan da kalksın" ve "Series A / satış EA'da kilometre taşı olsun": eleştirmenler senin ikinci tur cevaplarını görmemişti.
- Yeniden başlatmanın komut satırı argümanlarını taşıması: TEKRAR DENE ile tutarlı kalsın diye yapılmadı. Demo'ya düşen kayıt artık güvenli.
- Kapsam dışı kaldığı için onay bekleyenler (madde 3): `SHIPPED_SCOPES`'un build'e bağlanması, Av sekmesindeki "Tier 2" satırı, Pazarlama kilidi.

**Mutasyon kanıtı** (commit edilmedi, her biri geri alındı): 16 mutasyonun 16'sı ilgili vakayı düşürdü. Örnekler:
- mandal kaldırıldı;
- sınır kaldırılmadı;
- telgraf seam'i sabit false;
- Series A kilometre taşı;
- EA'da Frank ya da wishlist;
- saat kilidi yok;
- gazete kartın üstünde;
- otomatik kayıt slotu;
- mandal build'siz;
- "iki yılı aşkın" dalı yok;
- kilometre taşında paylaş.

**Doğrulama:**
- `--event-lint` PASS (43 kart, 3 arc), `loc_residue` 0.
- `loc_csv_integrity` ve `loc_event_en_coverage` PASS.
- Hedefli smoke: 5 yeni vaka; `profit_condition_fires` (demo kontrolü); 5 soft-cap vakası; kayıt ve harness vakaları.
- Tam smoke: T2.5.

### T2.4 Görsel kontrol

Kareler `%APPDATA%\Godot\app_userdata\Project Unicorn\` klasöründe: `vc_shot_*.png`, `ending_shot_*.png`. Yeniden çekmek için `--vc-shot=<tür>` ya da `--ending-shot=<tür>`; EN için `--lang=en`.

| Yüzey | Görülen | Durum |
|---|---|---|
| Av sayfası (`hunt`) | Tahmini aralık ("değerleme ~$11–16M · pay ~%19–27"), iş günü ("Teklif süresi: 8 iş günü"), sıradaki teklif satırı, ret rozeti | ✅ |
| Yol kapandı (`hunt_closed`) | "Series A için kapısı açık fon kalmadı. Bu yolda oturulacak masa yok." Rozetler: REDDETTİ, MASADAN KALKTIN, SÜRESİ DOLDU | ✅ |
| Masa, bir başarısız itiş (`table`) | Yatırımcı satırı "Peki. Listende başka ne var?", "Bir hamlen kaldı." | ✅ |
| Son teklif (`table_final`) | "Bir kez daha esnediler: %18 → %16. Bu son teklif. İmzala ya da masadan kalk." ve "Bu kadar. Daha fazla esnemiyoruz." | ✅ |
| Fon kalktı (`table_walk`) | "Masadan kalktılar. Teklif gitti." ve "Biz bu işte yokuz. Umarım işlerin yolunda gider." İMZALA kapalı, buton MASADAN AYRIL, sayaç 1/3 | ✅ |
| Diğer teklif (`table_other`) | Anchor: "Biz teklif yarışına girmeyiz." Diğer teklif satırı görünüyor, buton kullanıldıktan sonra kapalı | ✅ |
| Seed masası (`seed_table`) | Board satırı "Seed turunda yönetim kurulu pazarlığa açılmıyor.", İTİR kapalı. MASADAN KALK kilitli (yarı saydam). | ✅ |
| K10 kartı (`k10`) | "Teklifin süresi doldu", tahmini şartlar, iki seçenek, "SEÇİM KALICIDIR · OYUN DURAKLATILDI" | ✅ |
| Kilometre taşı gazetesi (TR ve EN) | Sayfa aynı; rayda başlık, gövde, DEVAM ET, ANA MENÜ | ✅ |
| EA iflas gazetesi | Frank şeridi, wishlist ve Yakında kartları yok; koşu satırı ile TEKRAR DENE, ZOR MOD ve PAYLAŞ var | ✅ |
| Demo Series A gazetesi | Eskisiyle aynı | ✅ |

**Gözlemler** (işlem yapılmadı, senin kararın):
- **TR ekranda İngilizce kalan üç etiket.** Sözlükte ve dil yasasının kabul listesinde yoklar:
  - `TERM_LEVER_BOARD` "Board": masadaki satır adı;
  - `EFFECT_TERM_TABLE` "Term sheet masası açılır": K10 kartının rozeti;
  - `*TIER2*`: "— · Tier 2'de" (Av listesi), "TİER 2 · ORTA ÖLÇEK" (demo gazetesi kartı).
- **Masa kadranı:** ibre ortadaki yüzde yazısının üstünden geçiyor. Tablo ve seed karelerinde "%13" ve "%45" okunmuyor.
- **Seed masasında kilitli board satırı** hâlâ bir hedef gösteriyor: "0 koltuk + veto → temiz".
- **Av sayfası:**
  - Sağ üstteki ürün kartı ("PromptPilot v1 · DESTEK …") TEKLİFLER panelinin sağ üst köşesini örtüyor.
  - BEKLEYEN kutusu görüşme ve hazırlıkları gösteriyor. "Bekleyen yok." yazarken sıradaki teklif TEKLİFLER altında duruyor; iki "bekleme" karışabilir.
- **EA iflas gazetesinin rayı** neredeyse boş: yalnız üstte koşu satırı, altta üç buton.

### T2.5 Tam smoke

- `8df1d83`'te koşuldu. Oyun ve harness kodu son hâlinde; bu raporun commit'i yalnız belge.
- Düzen `xargs -P 2`. Bellek için 3'ten 2'ye indi.
- `milestone_paper_under_card` en sonda tek başına koştu, çünkü kayıt slotu yazıyor.
- Sonuç: **347/347 PASS.** Çıktı: `runs/lokal_smoke_final2.txt`.

---

## Onay bekliyor (tur 2 sonu)

1. **`TERM_INV_*` metinleri:** 15 TR (`95bc9ea`) ve 15 EN (`8457ce3`), T2.1'de.
2. **E ölçümündeki görüşme kuralı** (§4): masa tanımın aynen uygulandı. Görüşme kuralı (en yüksek ihtimalli açı, dürüst cevap, ılık çatalda zorla) benim varsayımım.
3. **Sonlar, açık kalanlar** (tasarım notu §U.4):
   - satış EA / tam'da son;
   - `SHIPPED_SCOPES` ile build'in tek kaynağa bağlanması;
   - Av sekmesindeki "Tier 2" satırı ve Pazarlama kilidi;
   - ANA MENÜ sonrası kayıt yükleme girişi;
   - K17'nin Frank satırlarının yeniden değerlendirilmesi.
4. **Tasarım notunun kalan kararları:** K17 (§5), seed ticker (§6), D5 (§7).
5. **Kalibrasyon adayı:** kadronun satış ağırlığı (T2.2, HANDOFF §H.3).
6. **Görsel gözlemler** (T2.4): İngilizce kalan üç TR etiketi, kadran yazısı, seed board satırı, Av sayfasının iki ayrıntısı, EA gazete rayı.
7. **Ayrı karar** (tur 1'den): yedi ölü göç fonksiyonu (`save_manager.gd:255-268`).

Tur 1'in listesinden kapananlar: E2, tarihsel dal satırları, görsel kontroller, dış addon değişiklikleri, push.

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
