---
name: parallel-tasks-2026-08
description: "2026-08-06 itibarıyla uçuşta olan paralel task'lar ve ODA task'ının onlara sözleşmeleri (ticker rework, Finance bug-fix)"
metadata: 
  node_type: memory
  type: project
  originSessionId: f0a8d35b-e049-4463-b5f0-3e7cca283a6d
  modified: 2026-08-06T12:00:25.760Z
---

Erdem 2026-08-06'da ODA plan onayıyla birlikte iki paralel task bildirdi:

1. **Ticker rework task'ı:** ticker'ı üç kaynaklı GERÇEK akışa çeviriyor. ODA task'ının eklediği `TICKER_01..10` strings.csv anahtarları **sabit sözleşme** — o task içerikleri üzerine yazacak; ODA'nın 10 TR başlığı GEÇİCİ placeholder.
2. **Finance bug-fix task'ı:** `finance_ozet_view.gd` + `finance_tab.gd`'ye girecek. ODA task'ı bu iki dosyadaki işini (cap-table genişletme + `finance_subpage_requested` handler) ATOMİK tek adımda yapıp **bittiği anda Erdem'e ara bildirim** veriyor; paralel task o dosyalara ondan sonra giriyor.

**How to apply:** Bu dosyalara dokunan herhangi bir oturum önce hangi task'ın sırada olduğunu sormalı; ODA sonrası ticker içeriği veya finance dosyalarında beklenmedik değişiklik görürsen bu task'lardandır — commit etme, sahibine bırak ([[concurrent-session-hazard]]). ODA'nın kâğıt kaynakları (expansion=renewal İKAMESİ, fatura-vadesi yok) gerçek renewal/fatura sistemleri gelince değiştirilecek — ikame oldukları `# İKAME` yorumlarıyla kodda işaretli.

**Durum 2026-08-06 öğleden sonra:** ODA'nın atomik adımı İNDİ (finance_ozet_view/finance_tab cap-table + finance_subpage_requested + event_bus sinyalleri + build_hud_panel oda bekçisi); HR/Finans bug-fix task'ı finance_system.gd'yi (motor) düzeltti, iki view dosyasına dokunmadı. **KIRIK HARNESS (sahibi ODA):** center_viewport `_current_tab_node` → `_current_page` (TabPageChrome sarmalayıcı) yeniden adlandırması `main.gd:923` (`_run_hr_shot`, gider hariç tüm kind'lar) ve `main.gd:1182` (`_run_product_shot`) shot harness'larını kırıyor — windowed süreç crash edip asılı kalıyor; `--hr-shot=gider`, `--finance-shot=*`, smoke süiti çalışıyor. ODA oturumu aktifken düzeltilmedi.

**Canlı gözlem (2026-08-06 ~13:20):** Ticker task'ı ODA oturumunun P7 doğrulaması ORTASINDA ağaca girdi — `time_manager.gd`'ye `NewsFeedSystem` çağrıları + `event_bus.gd`'ye `news_stream_changed` sinyali + `game_state.gd`/`rival_registry.gd` düzenlemeleri; sınıf dosyası birkaç dakika sonradan geldi (o pencerede tree parse-broken'dı). ODA oturumu smoke'u bu yüzden erteledi ve settle monitörüyle bekledi. `event_bus.gd`'de iki task'ın sinyalleri temiz birleşti (`finance_subpage_requested` + `news_stream_changed`).

İlgili: [[project-unicorn-current-stage]], [[concurrent-session-hazard]]
