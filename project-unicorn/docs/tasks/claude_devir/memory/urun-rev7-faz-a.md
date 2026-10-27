---
name: urun-rev7-faz-a
description: "Ürün rev 7 sprint döngüsü — Faz A (ekran sözleşmesi) + Faz B (sistemler, eski motorun silinmesi, bayrağın kalkması); sahip kararları, doğrulama yolu, ekonomi gerilemesinin kök nedeni (hata havuzu sıfırlama)"
metadata:
  node_type: memory
  type: project
  originSessionId: c035abc5-791b-4063-9220-8a62d9937f33
  modified: 2026-10-01T16:36:05.787Z
---

**Durum 2026-10-01:** Faz A commit'li (`2b2d9b5`, `2c249ce`). Faz B kuruldu: eski yapım motoru + eski Ürün sekmesi + `--product-rev7` bayrağı SİLİNDİ, sprint ekranı artık Ürün sekmesinin kendisi (`scripts/tabs/product/`, `product_tab.gd`). Sistemler `SprintSystem` (GameState.product yazarı) / `SprintCatalog` / `SprintBridges` (tickets, ticket_seq, requests, rival_hits yazarı), veri `data/product/{sprint,rivals}.json`, kayıt şeması 15 (`_migrate_15`, `SprintSystem.new_state`). Faz B commit'leri `1abbb7e` (kod) + `6c87431` (belgeler), push yok, tam smoke 330/330. PRD `docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md`.

**Faz B sahip kararları:** eski motor + 55 smoke silinir (GUNCELLEMELER kaydı); ticket = doğrulanmış hata (`mvp_bugs_confirmed`); tür seçimi Ürün sekmesinde MVP öncesi; B2C fiyat + altyapı otomatik; MVP = herhangi üç kimlik hattı K1; içerik şablonları ajan taslağı (onay bekliyor); ★ kapıları kalır; BuildHUD'da yalnız DESTEK kartı. 54 maddelik ACIK_KARARLAR 96'da onay bekliyor.

**Ekonomi gerilemesi bir HATAYDI, kalibrasyon değil:** eski launch() her sürümde canlı hata havuzunu (`mvp_live_bug_count`) sıfırlıyordu, sprint kapanışı sıfırlamıyordu → havuz koşu boyu büyüdü, kararlılık/dönüşüm/VC çöktü. Sıfırlama geri konunca full_run g103: kasa $1.57M, MRR $227k, 316 müşteri, faz 3 (taban $1.34M/$181k/247). Kalan farklar: 8 kırık vaat (taban 0), moral ort 37.6 (taban 54.8), ticket defteri müşteriyle 135'e kadar şişiyor. Ders: eski motoru silerken her YAN ETKİSİNİ (başka alanların sayaç sıfırlamaları) envantere al.

**Denetim 2026-10-02 (9 ajan, salt okunur, kanıt scratchpad `urun_rev7/audit/RESULT.json`):** mekanik ana yol sağlam ve deterministik AMA 35 doğrulanmış bulgu: ~6 S2 hata (işten çıkan/ayrılan atanmış kişi → Ürün sekmesinde SCRIPT ERROR; araştırma-only aday veya "Hepsini onayla" sonrası plan modunda sonsuz donma; "Gerçekleşen" hiç görünmüyor; beta + talep son tarihi tahmini yalan; boşaltılmış fix kartı v+1 yayımlıyor; solo sprintte 0.6→1 yuvarlama lideri susturuyor). Kalibrasyon KÖTÜ: rev7 kaynaklı = MVP hafta 2→13 (12 hafta sıfır olay, nakdin %42'si), kırık vaat 14-23/koşu (taban 0-3; 2 haftalık vaat vs 2 haftalık kilitli sprint), B2C'de lider ücretli planı solo kurucuya hiç önermiyor. Rev7 öncesi = B2C her koşuda ~hafta 34 iflas (eski motorda da), faz 3 runway %100 INF. Önceki "ekonomi eski akış düzeyinde" iddiam yalnız toplam kasa/MRR için doğruydu. Scratch sahne koşucusu tarifi: mutlak yollu .tscn + Node script (`-s` autoload'dan önce derlendiği için çalışmaz).

**Why:** PRD'nin "sprint döngüsü" eski yapım motorunun yerini alıyor; Erdem "eski halini sil, bayrak yerine direkt sistem bu olmalı" dedi.

**How to apply:** Kareler `--product-shot=<c1..c5|cards|flow|edge:ad|live:pick|plan|active|b2c_mvp|b2b_requests>`; MCP: `GameShell.debug_product_apply("c1")`, `debug_product_act(kind)`; canlı döngü OS-tık ile oynandı (tür seç → lider önerisi → başlat → 4× → kapanışta sekme açılır, `is_clock_held` true → "Sprint N planına geç" saati bırakır). Paralel smoke koşucusu scratchpad `urun_rev7/smoke_par.sh`. Ekonomi karşılaştırma: `--run-log=full_run:120:sim`, taban HEAD loglarıyla `probe_cmp/`.

İlgili: [[godot-mcp-runtime-verification]] · [[smoke-verification-cadence]] · [[ui-lab-task-2026-09-30]] · [[claude-design-source-retrieval]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Ürün rev 7 sprint döngüsü](urun-rev7-faz-a.md) — Faz A `2b2d9b5`/`2c249ce`; Faz B: eski motor + sekme + bayrak silindi, SprintSystem/Catalog/Bridges, şema 15; commit `1abbb7e`/`6c87431` (push yok), smoke 330/330; ekonomi gerilemesi canlı hata havuzu sıfırlama hatasıydı; ACIK_KARARLAR 96 (54 madde)
