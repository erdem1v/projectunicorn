---
name: websearch-session-budget
description: "WebSearch oturum başına 200 aramayla sınırlı; büyük tarama workflow'larında bütçe biter, ajanlar sessizce model bilgisine düşer → hükümleri searches/evidence alanıyla kapıla"
metadata:
  node_type: memory
  type: reference
  originSessionId: deba1d13-1b5e-4ea3-b095-0ba82a068fbe
  modified: 2026-10-20T15:48:40.639Z
---

2026-10-07 P1 marka taraması: ilk workflow (129 ad, 32 ajan, 356 araç çağrısı) bütçeyi bitirdi; yeniden deneme turu
"WebSearch bütçesi tükenmiş (200/200), hiçbir arama yapılamadı" diyerek **model bilgisiyle "temiz" hükmü** verdi (bazı
ajanlar WebFetch ile alan adını okuyup kanıt URL'si verdi, bazıları s=0 döndü).

- Tarama şemasına `searches` (int) ve `evidence` (URL ya da "sonuç yok") zorunlu alanlarını koy; tüketici tarafta
  `temiz` yalnız `searches > 0 or 'http' in evidence` ise sayılır, gerisi "belirsiz (kanıtsız)".
- Bütçe oturum başınadır (yeni oturum = yeni 200). Büyük taramayı tek oturuma sığdırmak için ad başına arama
  sayısını önceden hesapla (129 ad × 1,5 ≈ 194 → sınırda); yeniden deneme turunu AYRI oturuma bırak ya da
  önce ucuz adları (dolgu) 1 aramayla geçir.
- Ajanlar bütçe bitince hata vermez, "eğilim" yazar: raporda bunu açıkça ayır (Ek A.9 böyle yazıldı).
- Ajanın `searches` beyanı gerçek sayı değildir (2026-10-20 Pazar 2: beyan 100, gerçek 95; A1 20/17, B1 18/16). Gerçeği
  transkript verir: `~/.claude/projects/<proje>/<oturum>/subagents/workflows/<run>/agent-*.jsonl` içinde `WebSearch`
  `tool_use` blokları, TEKİL `id` ile (bloklar çift yazılıyor: A3 13 blok = 10 çağrı). reddit.com alan filtresi 400
  hatası da çağrı sayılır. Rapora beyanı değil bu sayıyı yaz.

İlgili: [[rival-world-prd-2026-10-02]] · [[smoke-verification-cadence]]
