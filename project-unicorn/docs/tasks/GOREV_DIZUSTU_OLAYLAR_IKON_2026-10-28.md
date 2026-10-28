# Görev · Modül ikonları ve Olaylar 7c, dizüstü turu (OLAYLAR)

2026-10-28 · Yazan: yardımcı yönetmen (`co-director`) · Oturum etiketi: **OLAYLAR** · Paralel oturum: URUN_ARAYUZU
(`GOREV_DIZUSTU_URUN_2026-10-28.md`). Bir Opus incelemesinin bulguları bu metne işlendi.

## Amaç

Bu turun iki işi var.
1. **Modül ikonları.** Erdem sprint ekranının sol sütunundaki altı modül ikonundan dördünü reddetti. Oyuncu her modülü
   adını okumadan, ilk bakışta tanıyan bir ikonla görmeli. Bu oturum yeni adayları hazırlar ve Erdem seçer.
2. **Olaylar 7c.** Söz kartında iki şık aynı memnuniyet okuma kuralını izlemeli. Aynı kartta iki ayrı kural, oyuncuya
   aynı bedelin iki farklı sayıyla yazılması demektir.

## Önce oku

1. `PRD_URUN_SPRINT_ARAYUZU.md` en sondaki "Erdem'in 2026-10-28 kararları", özellikle **E4** ve E3.
2. `urun_ue/`: `index.html` (14 kare), `prototip_raporu.md` §2 (bugünkü ikonlar ve dosyaları), `prototip_gorevi.md`.
   İkonu sol sütuna koyan UE prototipinin kodu repoda **yok**; Windows scratchpad'inde kaldı. Bu görevde yalnız bu iki
   belgeden yeniden kurulur.
3. `GOREV_OLAY_UYGULAMA.md` "Devir (2026-10-27)", özellikle "Yardımcı yönetmenin kararları" 1 ve 2.
4. `ORTAK_CALISMA.md` §1–§8 ve **§9 (dizüstü)**. §9 makineyi, betiklerin Mac'e çevrilmesini, kilitleri ve **MCP tarifini**
   anlatır.
5. Hafıza (`/Users/tugbauysal/.claude/projects/-Users-tugbauysal-Desktop-project-steam-Project-Unicorn/memory/`):
   - `feedback-design-research-first`
   - `feedback-research-include-failures`
   - `feedback-visual-research-one-pair`
   - `feedback-ui-dont-shove-everything`
   - `feedback-no-truncation-mcp-validation`
   - `satisfaction-delta-drift`
   - `godot-mcp-runtime-verification` (yalnız MCP tuzakları)

## Adımlar

| # | Ne | Kanıt / kapı | Süre |
|---|---|---|---|
| O0 | **Kurulum.** `urun_arayuzu_devir/bin/`'in tamamını kendi scratchpad'ine kopyala ve ORTAK §9'un listesine göre çevir; kilit sahibi denetimi `$ETIKET` olur. HEAD'i kopyaya dışa aktar, `--import`, ısınma, `--event-lint`. MCP tarifini bir kez dene. | Lint satırı `LINT PASS` ile başlar ve `0 error(s), 0 warning(s), 10 baselined, 174 card(s)` taşır (sonunda arc sayısı da var); `all_scripts_load`, `event_chip_live_targets`, `event_chip_merge_same`, `event_trust_chip_share` PASS; MCP `runtime-status` connected | 1,5 sa |
| O1a | **İkon araştırması.** Yönetim ve şirket oyunlarının (Startup Company, Software Inc., Big Ambitions, Game Dev Tycoon ve benzeri) ve gerçek SaaS panolarının ilk kullanım, entegrasyon, büyüme ve gelir için kullandığı ikonları gerçek ekran görüntüleriyle topla. Okunmayan ya da eleştirilen örnekleri de ekle. Kaynak sicili ve iddia etiketleri kullan (co-director skill §3). | 8–12 kaynak, her biri ekran görüntüsüyle | 1,5 sa |
| O1b | **Adaylar.** Önce projenin 91 SVG'lik setinden (`assets/icons/`: `rail/`, `world/`, `dept/`, `stake/`, `util/`, `skill/`, `trait/`, `product/`, `dark/`) seç. Stil: düz dolgulu beyaz, 24 px, iki katmanlı (biri 0,4 opaklıkta), örnek `util/shield.svg`. Set yetmezse yalnız Lucide'den al: depoda lisanslı tek aile, `assets/art/office/icons/LICENSE-lucide.txt`. Lucide çizgi ikonudur; setin dolgulu stiline çevir ve kâğıtta "set dışı" diye işaretle. `assets/icons/`'un kaynağı belirsiz ve açık bir yayın engeli (PRD_ANA_MENU_ONBOARDING L4); başka kaynak kullanma. Her modüle (İlk Kullanım ve Erişim, Entegrasyonlar, Büyüme, Gelir) 3 aday. Onaylı Çekirdek küpü ve Güven kalkanı aynen kalır. | Aday listesi: dosya, kaynak, lisans, set içi mi | 1 sa |
| O1c | **Oyunun içinde kare (commit yok).** Kendi kopyanda sol sütunun iki harfli kutusunu ikonla değiştiren küçük prototipi kur (`prototip_gorevi.md`: 24 px kutu, 16 px ikon, ipucu modül adı). **Küme i** = her modülün i. adayı; 3 küme. Her küme iki dünyada çekilir: `live:a4_two_pm` (B2B: İlk Kullanım, Entegrasyonlar) ve `live:b2c_live` (B2C: İlk Kullanım, Büyüme, Gelir), TR. Yakın plan: sol sütunun 1920×1080 karesinden kırpılıp en yakın komşuyla 2× büyütülmüş PNG. MCP tarifiyle canlı bak: ikon keskin mi, koyu zeminde okunuyor mu? | Aday kâğıdı artifact'i: modül başına 3 aday, oyunun içinde ve yakın plan, her modülde "önerim" satırı, araştırmanın 1–2 karesi. Bağlantı `co-director`'e. Prototip kodu repoya girmez. | 2 sa |
| O2 | **Olaylar 7c.** `promise_break` çipi kartın kendi payını okur; `trust_delta` ile aynı kural (karar 1, `B2BSalesSystem.satisfaction_with_trust`). Yardımcı yönetmenin tanımı aşağıda. | Aşağıda | 3 sa |

**O2'nin tanımı (yardımcı yönetmen, doğruluk kararı).**
- **Pay:** `clamp(sat + PROMISE_BROKEN_SAT + kayma, 0, 100)`.
  - `kayma` = (ertesi günün hedefi, defter `trust_offset + PROMISE_BROKEN_OFFSET` ve yükselmiş çıta
    `_tolerance_after_break` ile) eksi (ertesi günün hedefi, bugünkü defter ve çıtayla).
  - Sürüklenme, tik affı (karar 2) ve onboarding tabanı paya girmez: üçü de kartın değil, sürüklenmenin parçasıdır.
- **Uygulama:** `EvEffects.break_plan` ve `EvChips._break_parts` bu değeri okur. `satisfaction_after_break`'in başka okuyucusu
  kalmazsa aynı commit'te silinir (CLAUDE.md §8) ve `docs/kod_haritasi/sistemler/03_satis_b2b.md:51` güncellenir.
- **Smoke:** `promise_break_chain` eski kuralı iddia ediyor ("çipteki memnuniyet oyuncunun bir tik sonra okuduğu
  değerdir"). Bilerek düşer ve yeni tanımla yeniden yazılır. İlk tikteki dip denetimi yerinde kalır. Yeni ya da
  güncellenen vaka mutasyonla düşmeli.
- **Kanıt:**
  - `product.promise_due` `extend` ve `slip`, `team.promise_made` `ask_time` ve `drop` şıklarının önce ve sonra okuması,
    çekim dünyasında. Bugün `extend` 72 → 66, `slip` 72 → 31. Sonraki değerleri tanımdan elle hesapla ve okumayla
    karşılaştır.
  - Söz kartının karesi TR ve EN; MCP tarifiyle çipi canlı oku.
- **Kapı:** lint, `loc_residue`, B2B ve söz smoke vakaları; commit `Olaylar 7c:`. Süreç 7b ile aynı: kopya, tek Opus
  inceleme, en çok bir düzeltme.
- **Erdem'in Olaylar sayfası** (https://claude.ai/artifact/LaMBoCBjGfiyEht9w5sA9j): `product.promise_due` ve
  `team.promise_made` kareleri yeniden çekilir. Sayfa devir notunun "Sayfada bir şey değişecekse" tarifiyle (`python3`)
  yeniden kurulur ve aynı bağlantıya yayınlanır.

Toplam yaklaşık 9 saat. Sıra O0 → O1a → O1b → O1c → O2: ikon kâğıdı erken gitsin ki Erdem seçerken 7c sürsün.

## Yapma

- Ürün'ün çizim koduna (`scripts/tabs/product/**`, `sprint_ui_shared.gd` …) commit yapma: ikonları URUN_ARAYUZU bağlar.
  Prototip yalnız kendi kopyanda.
- İkon seçimini kendin kesinleştirme: Erdem seçer.
- Olaylar'ın açık kararlarına dokunma: #7'nin iki şıkkı, #32, ACIK 14'ün kalanı, TR/EN onayları. Bunlar Erdem'de.
- Push etme. Paylaşılan ağaçta Godot koşma. `ekran` kilidi olmadan ekranlı koşu başlatma. Godot'yu `gd`/`gdw` dışında
  başlatma.

## Sorular

Görev ya da PRD sessiz veya çelişkiliyse o noktada dur. `co-director`'e numaralı liste gönder ve beklerken sıradaki adıma
geç. Oyuncunun gördüğü yerleşim ve metin seçimleri iki kare ve önerinle gider. Teknik kararlar senin.

## Bitince

- O2'den sonra `GOREV_OLAY_UYGULAMA.md`'nin devir notuna kısa bir "Dizüstü turu" bölümü ekle: ne bitti, commit, açık
  kalanlar.
- İkon kâğıdının bağlantısı ve 7c'nin sha'sı `co-director`'e gider. Son mesaj: "hazır, son commit <sha>".
