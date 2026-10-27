---
name: localization-tr-en-task
description: "TR+EN localization task — Phase 1 report delivered 2026-08-07, gate pending; Phase 2 double-gated (director approval + cleanup commit)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4a5d46b8-b2a3-4597-b971-d1ab29fb6644
  modified: 2026-08-10T09:31:58.450Z
---

**Faz 1 TESLİM EDİLDİ 2026-08-07** → `docs/audits/localization_phase1_2026-08-07.md` (envanter + 78-girdili sözlük + şema önerileri + BILINGUAL BIRTH LAW taslağı + 10-commit'lik Faz 2 planı). Oyun dosyasına sıfır yazım; snapshot HEAD `cb20a18` + 98 kirli giriş. **2026-08-08: rapor dahil tüm birikmiş iş `a71d762` ile commit+push edildi (Erdem isteği), tree temiz — Faz 2'nin "cleanup committed" ön koşulu fiilen sağlandı; kalan tek kapı Erdem'in rapor onayı (§7 kararları). Faz 2 Step 0'ın anchor re-verify'ı artık `a71d762`'ye karşı koşar.**

**Why:** Oyun TR+EN çıkacak; 241 CSV anahtarına karşı ~1.130 hardcoded satır + ~135 sahne literali + 16 canlı event JSON'u (3 debug fixture `_en`'den muaf — Erdem kararı). Faz 2 çifte kapılı: (1) Erdem'in rapor onayı (sözlük = taste gate), (2) bug-cleanup task'ının commit'i. Tek-yazar disiplini `strings.csv` üstünde mutlak.

**KAPI KAPANDI 2026-08-08 — dokuz ruling, hepsi bağlayıcı:** (1) TAM SÜRÜMDE→IN THE FULL GAME (`ONB_LOCKED_FULL`+`ENDING_BADGE_FULL`); (2) İlgilen→Check in (`SALES_ACTION_RETAIN`); (3) Bootstrap·Traction·Series A iki dilde aynı, sonsuza dek kapalı; (4) BURN whitelist'e girer (INTEGRITY law'a `burn` eki Step 0'da); (5) **Origins LOCALIZE (rapordan değişti):** TR adlar Sıfırdan · Mirasyedi · Kurumsal Firari, üçü `[WORKING]` (F5'te revize edilebilir), EN'ler shipped kalır, yalnız `ONB_ORIGIN_*_NAME` TR değerleri değişir, id'lere dokunulmaz; (6) para FULL FLIP (TR $1.234.567); (7) modal bayatlık kabul, 11 modala listener YOK; (8) sahne-gömülü anahtar onaylı; (9) kanun metni verbatim Step 0'da.

**YEŞİL IŞIK 2026-08-10 — FAZ 2 BAŞLADI, Step 0 sürüyor (HEAD `3d11896`):** delta emildi (SaveLoad+Terminal UI fiilen kanuna uymuş: +101 çift-dilli CSV satırı, tek gerçek hardcode `hr_constants` "Eğitim ücreti", printf 31→40, 7 orphan SAVE anahtarı — F5/F9 toast'suz); kanun CLAUDE.md'de (burn whitelist + INTEGRITY parantezi + bayat blok düzeltmesi dahil); sözlük `docs/design/localization_glossary.md`'de (Deneyim·Experience/Eğitim·Training delta terimleriyle); debris silindi (`git rm` ×2 + `.import`→keep + gitignore); `loc_residue.gd` indi, **baseline 1.433 hit** (filtreler: yorum/log/path/RightPanel/debug). KRİTİK ANCHOR DÜZELTMELERİ: router alanı **`_active_tab_id`** (`_current_tab_id` DEĞİL), `hr_overtime_panel` yolu `scripts/tabs/hr/`, smoke **153 case**, format_share pini `:5111-5114`, suffix siteleri `:806/:249/:87`, founder default `game_state.gd:765`; SAVE ŞEMASI: EventManager.to_dict tüm event metnini yazıyor (`_en` @export'lanınca otomatik biner; eski save→TR-fallback), `meta.phase_name` çözülmüş string donduruyor (Step 1 fix'i), `SAVE_EXCLUDE_FIELDS` boş. **STEP 0 TAMAMLANDI ve COMMIT'LENDİ: `a683ab1`** — smoke 153/153 PASS (stderr-kapılı runner; ilk koşudaki geçici Parse Error'lar paralel oturumun canlı asset-import penceresiydi, izole re-run temiz). DİKKAT: commit **`terminal-ui-reskin`** dalında (checkout o dalda; dal = 3d11896 + a683ab1, main'in 2 önünde, main'e FF adayı — birleştirme Erdem'in kararı). Aynı checkout'ta CANLI paralel iş var: ODA sanat-swap'ı (oda_layout/oda_view M, eski desk PNG'leri silinmiş, yeni room_day/night+keyboard+monitor PNG'leri untracked, elle "Yeni klasör") — commit DIŞI bırakıldı. **Step 1 bu iş yüzünden BEKLEMEDE** (single-writer: art oturumu inip/sahiplenilmeden strings.csv+shell dosyalarının kilidini almıyorum).

**ESKİ HOLD KAYDI (kapandı):** `strings.csv`'nin sahibi şu an SaveLoad task'ı; o commit'leyince Terminal UI task'ı koşacak; **Faz 2 ancak Terminal UI commit'lendikten SONRA Fable'ın açık yeşil ışığıyla başlar** — commit görmek yeterli değil, self-start yok. Step 0 iki task'ın string deltalarını + SaveLoad save-şeması etkileşimini (stored-state fix'leri eski save'leri kırmasın) emer. Dispatch planı: `~/.claude/plans/task-localization-whimsical-lollipop.md` (onaylı).

**How to apply:**
- **Probe kanıtı (Erdem'in tek koşuluydu, GEÇTİ):** proje bağlamında `text="KEY"` olan Control ilk boyamada çözülür VE `set_locale`'de listener'sız canlı çevrilir (INHERIT default; 3 yeşil koşu). Sonuç: .tscn stratejisi = sahneye gömülü anahtar (brief'in script-side varsayımından sapma, onaylatıldı); modallara listener YOK.
- Kapıda bekleyen kararlar: sözlük onayı (3 `[REVISES SHIPPED]`: TAM SÜRÜMDE→IN THE FULL GAME, İlgilen→Check in; `[DIRECTOR]`: faz adları İngilizce-iki-dilde, BURN whitelist-vs-GİDER, Self-Made↔Sıfırdan), para gruplama full-flip (Erdem eğilimli), modal-bayatlık politikası.
- Faz 2 sırası: Step 0 ground-truth re-verify (satır numaraları kaymış olacak — S3-2/S3-20 kanıtı) + debris + kanun ÖNCE; Step 1 altyapı (printf→`{x}` 31 anahtar tek commit, `Fmt`, `Localization.pick`, LanguageGate, `--lang`, router guard); Step 2 sözlük anahtarları; B1-B7 modül batch'leri (sales→hr→product→finance/vc→shell/oda→event içerik→endings).
- Kritik teknikler: `Operating Partner` BYTE-EXACT çevrilmez (`hr_constants.gd:104`); saklanan-state zehri iki yerde (`sales_system.gd:220` Customer.company_name, `game_state.gd:550` "Founder") — id sakla, render'da çöz; ASCII-Türkçe grep kör noktası (SABIR/ILIK/KAZANILDI) → `loc_residue.gd` iki-desen + sahne-anahtar kontrolü.

İlgili: [[project-unicorn-current-stage]], [[concurrent-session-hazard]], [[godot-mcp-runtime-verification]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Localization TR+EN task](localization-tr-en-task.md) — Faz 1 teslim + **KAPI KAPANDI 2026-08-08: 9 ruling bağlayıcı** (origins LOCALIZE: Sıfırdan/Mirasyedi/Kurumsal Firari; para full-flip; kanun verbatim); **Faz 2 HOLD: SaveLoad → Terminal UI → Fable yeşil ışığı, self-start YOK**; dispatch planı onaylı
